#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-10
# Updated: 2015-03-19
#
#
#!/bin/bash

# Taste the Rainbow!
      BLACK=$(tput setaf 0);        RED=$(tput setaf 1)
      GREEN=$(tput setaf 2);     YELLOW=$(tput setaf 3)
       BLUE=$(tput setaf 4);    MAGENTA=$(tput setaf 5)
       CYAN=$(tput setaf 6);      WHITE=$(tput setaf 7)

     BRIGHT=$(tput bold);        NORMAL=$(tput sgr0)
      BLINK=$(tput blink);      REVERSE=$(tput smso)
  UNDERLINE=$(tput smul)

# Set path to Joomla install
echo; runonce=0;
if [[ $1 =~ ^-.*$ ]]; then SITEPATH='.'; opt="$1"; shift; param="$@";
elif [[ -z $@ ]]; then SITEPATH='.'; else SITEPATH="$1"; opt="$2"; shift; shift; param="$@"; fi;

# Set path to configuration.php file
CONFIG="$SITEPATH/configuration.php"

# Check if there is a Joomla install here (sanity check)
if [[ -f "$CONFIG" ]]; then

# Gather DB Connection info
#dbconnect=($(grep -B5 '$dbprefix ' $CONFIG | cut -d\' -f2));
#dbtype="${dbconnect[0]}"; dbhost="${dbconnect[1]}"; dbuser="${dbconnect[2]}"; dbpass="${dbconnect[3]}"; dbname="${dbconnect[4]}"; prefix="${dbconnect[5]}";
dbtype=$(grep '$dbtype ' $CONFIG | cut -d\' -f2)
dbhost=$(grep '$host ' $CONFIG | cut -d\' -f2)
dbuser=$(grep '$user ' $CONFIG | cut -d\' -f2)
dbpass=$(grep '$password ' $CONFIG | cut -d\' -f2)
dbname=$(grep '$db ' $CONFIG | cut -d\' -f2)
prefix=$(grep '$dbprefix ' $CONFIG | cut -d\' -f2)

# Check location of version file
if [[ -f "$SITEPATH/libraries/cms/version/version.php" ]]; then VERFILE="$SITEPATH/libraries/cms/version/version.php"; else VERFILE="$SITEPATH/libraries/joomla/version.php"; fi

# Gather version information
RELEASE="$(grep '$RELEASE' $VERFILE | cut -d\' -f2)";
DEV_LEVEL="$(grep '$DEV_LEVEL' $VERFILE | cut -d\' -f2)";
DEV_STATUS="$(grep '$DEV_STATUS' $VERFILE | cut -d\' -f2)";
BUILD="$(grep '$BUILD' $VERFILE | cut -d\' -f2)";
RELDATE="$(grep '$RELDATE' $VERFILE | cut -d\' -f2)";
CODENAME="$(grep '$CODENAME' $VERFILE | cut -d\' -f2)";
VERSION="$RELEASE.$DEV_LEVEL $DEV_STATUS ($RELDATE) $BUILD";

_joomlausage(){
echo " Usage: nkjoomla [path] OPTION [query]
    -B | --backup .... Backup the Joomla database as the user
    -c | --clear ..... Clear Joomla cache
    -C | --cache ..... Enable/Disable cache
    -e | --execute ... Execute a custom query (use '*' and \\\")
    -g | --gzip ...... Enable/Disable gzip compression
    -i | --info ...... Display user credentials for database
    -l | --login ..... Log into database using user credentials
    -P | --password .. Update or reset password for a user
    -s | --swap ...... Temporarily swap out user password
    -u | --users ..... Show users configured within the database

    -h | --help ....... Display this help and quit
    If run with no options, returns summary information"
    return 0; }

_joomlainfo(){
# Output collected information
FORMAT="%-18s: %s\n"
printf "$FORMAT" "Base Path" "$(cd $SITEPATH; pwd -P)"
printf "$FORMAT" "Product Name" "$(grep '$PRODUCT' $VERFILE | cut -d\' -f2) \"$CODENAME\""
printf "$FORMAT" "Site Title" "$(grep '$sitename ' $CONFIG | cut -d\' -f2)"
printf "$FORMAT" "Install Date" "$(stat $VERFILE | awk '/Change/ {print $2,$3}' | cut -d. -f1)"
printf "$FORMAT" "Encryption Key" "$(grep '$secret' $CONFIG | cut -d\' -f2)"
printf "$FORMAT" "Version (Date)" "$VERSION"
printf "$FORMAT" "Front End URL" "http://$(cd $SITEPATH; grep -C5 $PWD /usr/local/apache/conf/httpd.conf | awk '/ServerName/ {print $2}')/"
printf "$FORMAT" "Back End URL" "http://$(cd $SITEPATH; grep -C5 $PWD /usr/local/apache/conf/httpd.conf | awk '/ServerName/ {print $2}')/administrator"
printf "$FORMAT" "Return-Path Email" "$(grep '$mailfrom' $CONFIG | cut -d\' -f2)"
printf "$FORMAT" "Gzip Compression" "$(grep '$gzip' $CONFIG | cut -d\' -f2 | sed 's/0/Disabled/;s/1/Enabled/')"
printf "$FORMAT" "DB Connection" "$dbtype://$dbuser:$dbpass@$dbhost/$dbname$(if [[ -n $prefix ]]; then echo .$prefix*; fi)"
printf "$FORMAT" "Session Method" "$(grep '$session' $CONFIG | cut -d\' -f2)"
printf "$FORMAT" "Cache Method" "$(grep '$cache_' $CONFIG | cut -d\' -f2) / $(grep '$caching' $CONFIG | cut -d\' -f2 | sed 's/0/Disabled/;s/1/Enabled/')"

## Show installed: components, modules, plugins, and templates
# Component Module Plugin Template
  for x in Plugin; do printf "%-18s: " "Active ${x}s"; mysql -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
    -e "select name,type from ${prefix}extensions where type like \"$x\" and enabled = 1;"\
    | egrep -v 'name.*type|^plg' | sed 's/ /_/g' | sort | uniq | awk '{printf "%s, ",$1}' | sed 's/, $//';
  echo; done; }

_joomlasum(){ echo -e "${BRIGHT}Joomla! \"$CODENAME\": ${RED}$VERSION ${NORMAL}\n${BRIGHT}Connection: ${RED}$dbuser:$dbname$(if [[ -n $prefix ]]; then echo .$prefix; fi)${NORMAL}\n"; }

_joomlaconnect(){
  if [[ $runonce -eq 0 ]]; then _joomlasum; runonce=1; fi &&
  mysql -u $dbuser -p$dbpass -h $dbhost $dbname -e "$@";
  }

_joomlabackup(){ _joomlasum;
  if [[ -x /usr/bin/pigz ]]; then COMPRESS="/usr/bin/pigz"; echo "Compressing with pigz"; else COMPRESS="/usr/bin/gzip"; echo "Compressing with gzip"; fi
  echo "Using: mysqldump --opt --skip-lock-tables -u'$dbuser' -p'$dbpass' -h $dbhost $dbname";
    if [[ -f /usr/bin/pv ]]; then mysqldump --opt --skip-lock-tables -u"$dbuser" -p"dbpass" -h $dbhost $dbname \
      | pv -N 'MySQL-Dump' | $COMPRESS --fast | pv -N 'Compression' > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz;
    else mysqldump --opt --skip-lock-tables -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
      | $COMPRESS --fast > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz; fi;
  }

case $opt in

# Backup the Database
 -B|--backup) _joomlabackup ;;

# Clear the cache
 -c|--clear) cd $SITEPATH/cache/ && for x in */; do echo "Clearing $x Cache" | sed 's:/::'; find $x -type f -exec rm {} \;; done; cd - &> /dev/null ;;

# Enable / Disable cache
 -C|--cache)
    if [[ $(grep "caching = '0'" $CONFIG 2> /dev/null) ]]; then sed -i "s/caching = '0'/caching = '1'/" $CONFIG; echo "Caching is ${BRIGHT}${GREEN}Enabled${NORMAL}";\
    else sed -i "s/caching = '1'/caching = '0'/" $CONFIG; echo "Caching is ${BRIGHT}${GREEN}Disabled${NORMAL}"; fi ;;

# Run a custom query
 -e|--execute) _joomlaconnect "${param};";;

# Enable / Disable gzip
 -g|--gzip)
    if [[ $(grep "gzip = '0'" $CONFIG 2> /dev/null) ]]; then sed -i "s/gzip = '0'/gzip = '1'/" $CONFIG; echo "Gzip is ${BRIGHT}${GREEN}Enabled${NORMAL}";\
    else sed -i "s/gzip = '1'/gzip = '0'/g" $CONFIG; echo "Gzip is ${BRIGHT}${GREEN}Disabled${NORMAL}"; fi ;;

# Print out DB connection summary
 -i|--info) echo "Database Connection Info:";
    echo -e "\nLoc.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $dbhost \nRem.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $(hostname)\n";
    echo -e "Username: $dbuser \nPassword: $dbpass \nDatabase: $dbname $(if [[ -n $prefix ]]; then echo \\nPrefix..: $prefix; fi) \nLoc.Host: $dbhost \nRem.Host: $(hostname)" ;;

# Login to the database as the user
 -l|--login) mysql -u $dbuser -p$dbpass -h $dbhost $dbname ;;

# Reset password for a user
 -P|--password)
    if [[ -n $param ]]; then
      username=$(echo $param | awk '{print $1}'); password=$(echo $param | awk '{print $2}'); salt=$(echo $param | awk '{print $3}');
      _joomlaconnect "UPDATE ${prefix}users SET password = MD5(\"${password}\") WHERE ${prefix}users.username = \"$username\";"
      echo -e "New Joomla Login Credentials:\nUsername: $username\nPassword: $password"
    elif [[ -z $param || $param == '-h' || $param == '--help' ]]; then
      echo -e " Usage: nkjoomla [path] <-P|--password> <username> <password>"
    fi
    ;;

# Temporarily swap out user password
 -s|--swap)
    username=$(_joomlaconnect "SELECT username FROM ${prefix}users ORDER BY id LIMIT 1;" | tail -1)
    password=$(_joomlaconnect "SELECT password FROM ${prefix}users ORDER BY id LIMIT 1;" | tail -1 | sed 's/\$/\\\$/g')
    _joomlaconnect "UPDATE ${prefix}users SET password=MD5('nexpassword') ORDER BY id LIMIT 1";
    echo -e "You have 20 seconds to login using the following credentials\n"
    echo -e "LoginURL: http://$(cd $SITEPATH; pwd -P | sed "s:^/chroot::" | cut -d/ -f4- | sed 's:html/::')/administrator"
    echo -e "Username: $username\nPassword: nexpassword\n"
    for x in {1..20}; do sleep 1; printf ". "; done; echo
    _joomlaconnect "UPDATE ${prefix}users SET password=\"$password\" ORDER BY id LIMIT 1";
    echo -e "\nPassword has been reverted."
    ;;

# List users, both long or short format
 -u|--user)
    if [[ -z $param ]]; then _joomlaconnect "select * from ${prefix}users\G";
    elif [[ $param =~ -s ]]; then _joomlaconnect "select id,username,name,email,password from ${prefix}users ORDER BY id";
    elif [[ $param == '-h' || $param == '--help' ]]; then echo -e " Usage: nkjoomla [path] <-u|--user> [-s|--short]"; fi
    ;;

# Print the help output
 -h|--help) _joomlausage ;;
  * ) _joomlainfo ;;
esac; echo

else
    echo -e "Could not find Joomla install at $SITEPATH\n"
fi

## Potential features
#
# 1) [X] Reset password for a user
#	Format is password+salt:salt
# 2) [X] Backup Database --> Look in to using Expect to enter password correctly when it contains od characters.
# 3) [X] Clear cache --> cache/; find -type f -exec rm {} \;
# 4) [X] Look up list of users
#	select * from ${prefix}users
# 5) [X] Swap admin user
# 6) [X] Summarize version and connection info
# 7) [X] Print out MySQL credentials
# 8) [X] Enable/Disable Cache
# 9) [X] Enable/Disable Gzip
# 10 [ ] Enable memcache: http://www.siteground.com/tutorials/supercacher/joomla_memcached.htm
# 11 [ ] Create a copy function to create dev sites
# sudo -u $(getusr) -- siteworx -u -n -c MysqlDb -a add --name $newDB --create_user 1 --user $newUser --password $dbpass --confirm_password $dbpass
# mysqldump -u'$dbuser' -p'$dbpass' $dbname | pv | mysql -u'$newUser' -p'$dbpass' $newDB
# rsync -a source/dir/ dest/dir/
