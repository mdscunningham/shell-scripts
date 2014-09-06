#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-06-28
# Updated: 2014-07-25
#
#
#!/bin/bash

## http://www.tutorialspoint.com/mysql/mysql-using-sequences.htmindex_process_event
## ^^^ great reference for command examples

## https://dev.mysql.com/doc/refman/5.6/en/show-table-status.html
## ^^^ much faster way to get rows, data, index, data_free if necessary

echo; runonce=0;
if [[ $1 =~ ^-.*$ ]]; then SITEPATH='.'; opt="$1"; shift; param="$@";
else SITEPATH="$1"; opt="$2"; shift; shift; param="$@"; fi;

tables="core_cache core_cache_option core_cache_tag core_session dataflow_batch_import dataflow_batch_export\
    index_process_event log_customer log_quote log_summary log_summary_type\
    log_url log_url_info log_visitor log_visitor_info log_visitor_online\
    report_viewed_product_index report_compared_product_index report_event catalog_compare_item"

prefix=$(grep -i 'table_prefix' $SITEPATH/app/etc/local.xml 2> /dev/null | sed 's/.*A\[\(.*\)]].*/\1/');
adminurl=$(grep -i 'frontname' $SITEPATH/app/etc/local.xml 2> /dev/null | sed 's/.*A\[\(.*\)]].*/\1/');

_magdbusage(){ echo " Usage: magdb [<path>] <option> [<query>]
    -a | --amazon .... Show Amazon errors from the exception log
    -b | --base ...... Show all configured Base Urls
    -B | --backup .... Backup the Magento database as the user
    -c | --cron ...... Show Cron Jobs and Their Statuses
    -d | --dataflow .. Show size of dataflow batch tables
    -e | --execute ... Execute a custom query (use '*' and \\\")
    -i | --info ...... Display user credentials for database
    -l | --login ..... Log into database using user credentials
    -L | --logsize ... Show size of the log tables
    -m | --multi ..... Show Multistore Information (Urls/Codes)
    -o | --logclean .. Clean out (truncate) log tables
    -O | --optimize .. Truncate and optimize log tables
    -p | --parallel .. Show all parallel download base_urls
    -P | --password .. Update or reset password for user ${CYAN}(New)${NORMAL}
    -r | --rewrite ... Show the count of Url Rewrites
    -s | --swap ...... Temporarily swap out admin password ${RED}${BRIGHT}(BETA!)${NORMAL}
    -S | --ssl ....... Check/Set secure frontEnd or Admin
    -u | --users ..... Show all Admin Users' information
    -v | --visit ..... Show count of Visitors in the Log
    -x | --index ..... Show Current Status of all Re-Index Processes
    -X | --reindex ... Execute a reindex as the user (indexer.php)
    -z | --zend ...... Clear user's Zend cache files in /tmp/

    -h | --help ...... Display this help output and quit"
    return 0; }

_magdbinfo(){ if [[ -f $SITEPATH/app/etc/local.xml ]]; then #Magento
    dbconnect=($(grep -B3 dbname $SITEPATH/app/etc/local.xml | sed 's/.*A\[\(.*\)]].*/\1/'));
    dbhost="${dbconnect[0]}"; dbuser="${dbconnect[1]}"; dbpass="${dbconnect[2]}"; dbname="${dbconnect[3]}";
    ver=($(grep 'function getVersionInfo' -A8 $SITEPATH/app/Mage.php | grep major -A4 | cut -d\' -f4)); version="${ver[0]}.${ver[1]}.${ver[2]}.${ver[3]}"
    if grep 'Enterprise Edition' $SITEPATH/app/Mage.php > /dev/null; then edition="Enterprise Edition"; else edition="Community Edition"; fi
    else echo "${RED}Could not find configuration file!${NORMAL}"; return 1; fi; }

_magdbsum(){ echo -e "${BRIGHT}$edition: ${RED}$version ${NORMAL}\n${BRIGHT}Connection Summary: ${RED}$dbuser:$dbname$(if [[ -n $prefix ]]; then echo .$prefix; fi)${NORMAL}\n"; }

_magdbconnect(){ _magdbinfo && if [[ $runonce -eq 0 ]]; then _magdbsum; runonce=1; fi && mysql -u"$dbuser" -p"$dbpass" -h $dbhost $dbname "$@"; }

_magdbbackup(){ _magdbinfo;
	if [[ -x /usr/bin/pigz ]]; then COMPRESS="/usr/bin/pigz"; echo "Compressing with pigz";
		else COMPRESS="/usr/bin/gzip"; echo "Compressing with gzip"; fi
	echo "Using: mysqldump --opt --skip-lock-tables -u'$dbuser' -p'$dbpass' -h $dbhost $dbname";
	if [[ -f /usr/bin/pv ]]; then sudo -u $(getusr) mysqldump --opt --skip-lock-tables -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
		| pv -N 'MySQL-Dump' | $COMPRESS --fast | pv -N 'Compression' > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz;
	else sudo -u $(getusr) mysqldump --opt --skip-lock-tables -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
		| $COMPRESS --fast > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz; fi;
	}

case $opt in
 -a|--amazon) _magdbconnect -e "SELECT * FROM ${prefix}amazon_log_exception ORDER BY log_id DESC LIMIT 1;" ;;

 -b|--base) _magdbconnect -e "SELECT * FROM ${prefix}core_config_data WHERE path RLIKE \"base_url\";" ;;

 -B|--backup) _magdbbackup ;;

 -c|--cron) runonce=1; if [[ -z $param ]]; then
	  _magdbconnect -e "SELECT * FROM ${prefix}cron_schedule;"
	elif [[ $param =~ ^clear$ ]]; then
	  _magdbconnect -e "DELETE FROM ${prefix}cron_schedule WHERE status RLIKE \"success|missed\";"
	  echo "Cron_Schedule table has been cleared of old crons"
	elif [[ $param =~ ^clear.*-f$ ]]; then
	  _magdbconnect -e "TRUNCATE ${prefix}cron_schedule;"
	  echo "Cron_Schedule table has been truncated"
	elif [[ $param == '-h' || $param == '--help' ]]; then
	  echo -e " Usage: magdb [<path>] <-c|--cron> [clear] [-f]\n    clear : Remove completed or missed cron jobs\n    clear -f : Truncate the cron_schedule table"
	fi ;;

 -e|--execute) _magdbconnect -e "${param};" ;;

 -i|--info) _magdbinfo; echo "Database Connection Info:";
    echo -e "\nLoc.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $dbhost \nRem.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $(hostname)\n";
    echo -e "Username: $dbuser \nPassword: $dbpass \nDatabase: $dbname $(if [[ -n $prefix ]]; then echo \\nPrefix..: $prefix; fi) \nLoc.Host: $dbhost \nRem.Host: $(hostname)" ;;

 -l|--login) _magdbconnect;;

 -L|--logsize|-d|--dataflow|-v|--visit|-r|--rewrite) _magdbinfo; _magdbsum; datatotal=0; indextotal=0; rowtotal=0; freetotal=0;
	if [[ $opt == '-d' || $opt == '--dataflow' ]]; then tables="dataflow_batch_import dataflow_batch_export";
	elif [[ $opt == '-v' || $opt == '--visit' ]]; then tables="log_visitor log_visitor_info log_visitor_online";
	elif [[ $opt == '-r' || $opt == '--rewrite' ]]; then tables="core_url_rewrite"; fi
	div='+------------------------------------------+-----------------+----------------+----------------+'
	LOGFMT="| %-40s | %15s | %12s M | %12s M |\n"
	echo $div; printf "$LOGFMT" "Table Name" "Row Count" "Data Size" "Index Size"; echo $div
	for x in $tables; do
	    datasize=$(_magdbconnect -e "SELECT data_length/1024000 FROM information_schema.TABLES WHERE table_name = \"${prefix}$x\";" | tail -1)
		datatotal=$(echo "scale=3;$datatotal + $datasize" | bc)
	    indexsize=$(_magdbconnect -e "SELECT index_length/1024000 FROM information_schema.TABLES WHERE table_name = \"${prefix}$x\";" | tail -1)
		indextotal=$(echo "scale=3;$indextotal+$indexsize" | bc)
	    rowcount=$(_magdbconnect -e "SELECT table_rows FROM information_schema.TABLES WHERE table_name = \"${prefix}$x\";" | tail -1)
		rowtotal=$(($rowcount+$rowtotal))
	    printf "$LOGFMT" "$x" "$rowcount" "$datasize" "$indexsize"
	done
	echo $div; printf "$LOGFMT" "Totals" "$rowtotal" "$datatotal" "$indextotal"; echo $div ;;

 -m|--multi) _magdbconnect -e "SELECT * FROM ${prefix}core_config_data WHERE path RLIKE \"base_url\"; SELECT * FROM ${prefix}core_website; SELECT * FROM ${prefix}core_store" ;;

 -p|--parallel) _magdbconnect -e "SELECT * FROM ${prefix}core_config_data WHERE path RLIKE \"base.*url\";" ;;

# CONCAT(MD5(CONCAT(MD5(12345),12345)),CONCAT(':',MD5(12345))) <-- hash(hash(passwd)+passwd):hash(passwd)
# ^^^ considering this for additional security (Need to check what version of Magento started supporting salted hashes)
 -P|--password) runonce=1;
        if [[ -n $param ]]; then
          username=$(echo $param | awk '{print $1}'); password=$(echo $param | awk '{print $2}');
          _magdbconnect -e "UPDATE ${prefix}admin_user SET password = MD5(\"$password\") WHERE ${prefix}admin_user.username = \"$username\";"
          echo -e "New Magento Login Credentials:\nUsername: $username\nPassword: $password"
        elif [[ -z $param || $param == '-h' || $param == '--help' ]]; then
          echo -e " Usage: magdb [<path>] <-P|--password> <username> <password>"
        fi ;;

 -o|--logclean|-O|--optimize)
	if [[ -z $param ]]; then tablename='-h'; else tablename="$param"; fi; runonce=1;
	if [[ $tablename != *-h* ]]; then touch $SITEPATH/maintenance.flag && echo -e "Maintenance Flag set while cleaning tables\n"; fi
	case $tablename in
	    all) if [[ $opt == '-o' || $opt == '--logclean' ]];
		then for x in $tables; do echo "Truncating ${prefix}$x"; _magdbconnect -e "TRUNCATE ${prefix}$x;" >> /dev/null; done;
		else for x in $tables; do echo; echo "Truncating/Optimizing ${prefix}$x"; _magdbconnect -e "TRUNCATE ${prefix}$x; OPTIMIZE TABLE ${prefix}$x;" >> /dev/null; done; fi ;;
	    -h|--help) echo -e " Usage: magdb $SITEPATH $opt [<option>]\n    <option> can be a table_name, 'list of tables', or 'all'\n\n  Individual Table Names\n $(dash 78)";
		(for x in $tables; do echo "  $x"; done) | column -x;;
	    *)  if [[ $opt == '-o' || $opt == '--logclean' ]];
		then for x in $tablename; do echo "Truncating ${prefix}$x"; _magdbconnect -e "TRUNCATE ${prefix}$x;" >> /dev/null; done;
		else for x in $tablename; do echo; echo "Truncating/Optimizing ${prefix}$x"; _magdbconnect -e "TRUNCATE ${prefix}$x; OPTIMIZE TABLE ${prefix}$x;" >> /dev/null; done; fi ;;
	esac
	if [[ -f $SITEPATH/maintenance.flag ]]; then rm $SITEPATH/maintenance.flag && echo -e "\nTable cleaning complete, maintenance.flag removed"; fi ;;

-s | --swap )
        username=$(_magdbconnect -e "SELECT username FROM ${prefix}admin_user WHERE is_active = 1 LIMIT 1;" | tail -1)
        password=$(_magdbconnect -e "SELECT password FROM ${prefix}admin_user WHERE is_active = 1 LIMIT 1;" | tail -1 | sed 's/\$/\\\$/g')
        # echo -e "\nOld Password: $password"
        _magdbconnect -e "UPDATE ${prefix}admin_user SET password=MD5('nexpassword') WHERE is_active = 1 LIMIT 1";
        # echo; echo -n "New Password: "; _magdbconnect -e "SELECT password FROM ${prefix}admin_user WHERE is_active = 1 LIMIT 1;" | tail -1 | sed 's/\$/\\\$/g'
        # _magdbconnect -e "SELECT username,password FROM ${prefix}admin_user WHERE is_active = 1 LIMIT 1"
        echo -e "You have 20 seconds to login using the following credentials\n"
        echo -n "LoginURL: "; _magdbconnect -e "SELECT value FROM core_config_data WHERE path LIKE \"web/unsecure/base_url\" LIMIT 1;" | tail -1 | sed "s/\/$/\/$adminurl/"
        echo -e "Username: $username\nPassword: nexpassword\n"
        for x in {1..20}; do sleep 1; printf ". "; done; echo
        _magdbconnect -e "UPDATE ${prefix}admin_user SET password=\"$password\" WHERE is_active = 1 LIMIT 1";
        # _magdbconnect -e "SELECT username,password FROM ${prefix}admin_user WHERE is_active = 1 LIMIT 1";
        echo -e "\nPassword has been reverted." ;;

-S | --ssl )
	if [[ $param =~ -h ]]; then echo " Usage: magdb [path] -S [on|off] [front|admin]"
	else _magdbconnect -e "select * from ${prefix}core_config_data where path rlike \"use_in\""; fi ;;

 -u|--user|--users)
    # _magdbconnect -e "SELECT * FROM ${prefix}admin_user\G;" | grep -v 'extra:' ;;
    if [[ -z $param ]]; then _magdbconnect -e "select * from ${prefix}admin_user ORDER BY user_id\G" | grep -v 'extra:';
    elif [[ $param =~ -s ]]; then _magdbconnect -e "select user_id AS ID,username,CONCAT( firstname,\" \",lastname ) AS \"Full Name\",email,password from ${prefix}admin_user ORDER BY user_id";
    elif [[ $param == '-h' || $param == '--help' ]]; then echo -e " Usage: magdb [path] <-u|--user> [-s|--short]"; fi
    ;;

 -x|--index) _magdbconnect -e "SELECT * FROM ${prefix}index_process" ;;

 -X|--reindex) if [[ -z $param ]]; then index='help' ; else index="$param"; fi
    _magdbinfo; _magdbsum; DIR=$PWD; cd $SITEPATH; sudo -u $(getusr) php -f shell/indexer.php -- $index; cd $DIR ;;

 -z|--zend)
    if [[ -z $param ]]; then
	echo "There are $(find /tmp/ -type f -name zend* -group $(getusr) -print | wc -l) Zend cache files for $(getusr) in /tmp/";
    elif [[ $param =~ ^clear$ ]]; then
	echo "Clearing Zend cache files for $(getusr) in /tmp/";
	for x in $(find /tmp/ -type f -name zend* -group $(getusr) -print); do echo -n $x; rm $x && echo "... Removed"; done;
    else
	echo "$param is not a valid parameter for this option."
    fi ;;

 -h|--help|*) _magdbusage;;
esac; echo;

# Variable cleanup
dbhost=''; dbuser=''; dbpass=''; dbname=''; prefix='';
edition=''; version=''; adminurl=''; username=''; password='';
