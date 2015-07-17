#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-05-07
# Updated: 2014-07-26
#
#
#!/bin/bash

# http://wordpress.org/plugins/wp-multi-network/
# http://codex.wordpress.org/images/9/97/WP3.8-ERD.png

# Taste the rainbow
      BLACK=$(tput setaf 0);        RED=$(tput setaf 1)
      GREEN=$(tput setaf 2);     YELLOW=$(tput setaf 3)
       BLUE=$(tput setaf 4);     PURPLE=$(tput setaf 5)
       CYAN=$(tput setaf 6);      WHITE=$(tput setaf 7)

     BRIGHT=$(tput bold);        NORMAL=$(tput sgr0)
      BLINK=$(tput blink);      REVERSE=$(tput smso)
  UNDERLINE=$(tput smul)

getusr(){ pwd | sed 's:^/chroot::' | cut -d/ -f3; }

echo; runonce=0;
if [[ $1 =~ ^-.*$ ]]; then SITEPATH='.'; opt="$1"; shift; param="$@";
else SITEPATH="$1"; opt="$2"; shift; shift; param="$@"; fi;

if [[ -f $SITEPATH/wp-includes/version.php ]]; then
  version=$(grep "wp_version =" $SITEPATH/wp-includes/version.php | cut -d\' -f2)
  dbversion=$(grep "wp_db_version =" $SITEPATH/wp-includes/version.php | awk '{print $3}' | tr -d \;)
fi

if [[ -f $SITEPATH/wp-config.php ]]; then
  if grep -Eqi "MULTISITE...true" $SITEPATH/wp-config.php; then
    edition='WP Multisite'; else edition='Wordpress'; fi
  prefix=$(grep table_prefix $SITEPATH/wp-config.php | cut -d\' -f2);
fi

# if [[ -f $SITEPATH/wp-config.php ]]; then continue=1; else echo -e "\n Could not find Worpdress configuration file!\n"; return 0; fi

_wpdbinfo(){
dbconnect=($(grep DB_ $SITEPATH/wp-config.php 2> /dev/null | cut -d\' -f4));
dbname=${dbconnect[0]}; dbuser="${dbconnect[1]}"; dbpass="${dbconnect[2]}"; dbhost=${dbconnect[3]};
}

_wpdbusage(){ echo " Usage: wpdb [<path>] <option> [<query>]
    -b | --base ...... Show configured base urls in the database
    -B | --backup .... Backup the Wordpress database as the user
    -c | --clean ..... Remove unapproved comments or old post revisions. ${CYAN}(New)${NORMAL}
    -e | --execute ... Execute a custom query (use '*' and \\\")
    -i | --info ...... Display user credentials for database
    -l | --login ..... Log into database using user credentials
    -m | --multi ..... Display MultiSite information (IDs/domains/paths)
    -P | --password .. Update or reset password for a user ${CYAN}(New)${NORMAL}
    -p | --plugins ... List plugin directories in wp-content
    -s | --swap ...... Temporarily swap out user password ${RED}${BRIGHT}(BETA!)${NORMAL}
    -u | --users ..... Show users configured within the database

    -h | --help ....... Display this help information and quit"
    return 0; }

_wpdbsum(){ echo -e "${BRIGHT}$edition: ${RED}$version ($dbversion) ${NORMAL}\n${BRIGHT}Connection: ${RED}$dbuser:$dbname$(if [[ -n $prefix ]]; then echo .$prefix; fi)${NORMAL}\n"; }

_wpdbconnect(){
	_wpdbinfo &&
	if [[ $runonce -eq 0 ]]; then _wpdbsum; runonce=1; fi &&
	mysql -u $dbuser -p$dbpass -h $dbhost $dbname "$@";
	}

_wpdbbackup(){ _wpdbinfo;
        if [[ -x /usr/bin/pigz ]]; then COMPRESS="/usr/bin/pigz"; echo "Compressing with pigz";
                else COMPRESS="/usr/bin/gzip"; echo "Compressing with gzip"; fi
        echo "Using: mysqldump --opt --skip-lock-tables -u'$dbuser' -p'$dbpass' -h $dbhost $dbname";
        if [[ -f /usr/bin/pv ]]; then sudo -u $(getusr) mysqldump --opt --skip-lock-tables -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
                | pv -N 'MySQL-Dump' | $COMPRESS --fast | pv -N 'Compression' > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz;
        else sudo -u $(getusr) mysqldump --opt --skip-lock-tables -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
                | $COMPRESS --fast > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz; fi;
        }

case $opt in
-b | --base ) option_tables=$(_wpdbconnect -e "SHOW TABLE STATUS" | awk '($1 ~ /options/) {print $1}');
	for x in $option_tables; do _wpdbconnect -e "SELECT * FROM $x WHERE option_name = \"siteurl\" OR option_name = \"home\" OR option_name = \"blogname\";"; echo -e "Options Table Name: $x\n"; done ;;

-B | --backup ) _wpdbbackup ;;

-c | --clean ) if [[ $param =~ ^com.* ]]; then
		    _wpdbconnect -e "DELETE FROM ${prefix}comments WHERE comment_approved = '0';"
		elif [[ $param =~ ^rev.* ]]; then
		    _wpdbconnect -e "DELETE FROM ${prefix}posts WHERE post_type = 'revision';"
		fi ;;

-e | --execute ) _wpdbconnect -e "${param};" ;;

-i | --info ) _wpdbinfo; echo "Database Connection Info:";
    echo -e "\nLoc.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $dbhost \nRem.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $(hostname)\n";
    echo -e "Username: $dbuser \nPassword: $dbpass \nDatabase: $dbname $(if [[ -n $prefix ]]; then echo \\nPrefix..: $prefix; fi) \nLoc.Host: $dbhost \nRem.Host: $(hostname)" ;;

-l | --login ) _wpdbconnect ;;

-m | --multi ) _wpdbconnect -e "SELECT * FROM ${prefix}blogs;" ;;

-u | --users )
    if [[ -z $param ]]; then _wpdbconnect -e "select * from ${prefix}users\G";
    elif [[ $param =~ -s ]]; then _wpdbconnect -e "select id,user_login,display_name,user_email,user_pass from ${prefix}users ORDER BY id";
    elif [[ $param == '-h' || $param == '--help' ]]; then echo -e " Usage: wpdb [path] <-u|--user> [-s|--short]"; fi
    ;;

-P | --password )
	if [[ -n $param ]]; then
	  user_login=$(echo $param | awk '{print $1}'); user_pass=$(echo $param | awk '{print $2}');
	  _wpdbconnect -e "UPDATE ${prefix}users SET user_pass = MD5(\"$user_pass\") WHERE ${prefix}users.user_login = \"$user_login\";"
	  echo -e "New WP Login Credentials:\nUsername: $user_login\nPassword: $user_pass"
	elif [[ -z $param || $param == '-h' || $param == '--help' ]]; then
	  echo -e " Usage: wpdb [<path>] <option> <username> <password>"
	fi ;;

-p | --plugins) find $SITEPATH/wp-content/plugins/ -maxdepth 1 -type d -print | awk -F/ 'BEGIN{printf "Plugins:"} {printf "%s, ",$NF} END{print ""}' ;;

-s | --swap )
	user_login=$(_wpdbconnect -e "SELECT user_login FROM ${prefix}users ORDER BY id LIMIT 1;" | tail -1)
	user_pass=$(_wpdbconnect -e "SELECT user_pass FROM ${prefix}users ORDER BY id LIMIT 1;" | tail -1 | sed 's/\$/\\\$/g')
	# echo -e "\nOld Password: $user_pass"
	_wpdbconnect -e "UPDATE ${prefix}users SET user_pass=MD5('nexpassword') WHERE user_login = \"$user_login\"";
	# echo; echo -n "New Password: "; _wpdbconnect -e "SELECT user_pass FROM ${prefix}users WHERE user_login = \"$user_login\";" | tail -1 | sed 's/\$/\\\$/g'
	# _wpdbconnect -e "SELECT * FROM ${prefix}users WHERE user_login = \"$user_login\"";
	echo -e "You can now login using the following credentials\nOnce you un-pause this script the password will be reset\n"
	echo -n "LoginURL: "; _wpdbconnect -e "SELECT option_value FROM ${prefix}options WHERE option_name LIKE \"siteurl\";" | tail -1 | sed 's/$/\/wp-admin/' | sed 's/\/\/wp-admin$/\/wp-admin/'
	echo -e "Username: $user_login\nPassword: nexpassword\n"
	# for x in {1..30}; do sleep 1; printf "."; done; echo
	read -p "Press [Enter] to continue ... " pause;
	_wpdbconnect -e "UPDATE ${prefix}users SET user_pass=\"$user_pass\" WHERE user_login = \"$user_login\"";
	# _wpdbconnect -e "SELECT * FROM ${prefix}users WHERE user_login = \"$user_login\"";
	echo -e "\nPassword has been reverted." ;;

#	) _wpdbconnect -e "SELECT * FROM ${prefix};" ;;

-h | --help | * ) _wpdbusage ;;
esac;
echo

# Variable cleanup
dbhost=''; dbuser=''; dbpass=''; dbname=''; prefix='';
edition=''; version=''; user_login=''; user_pass='';
