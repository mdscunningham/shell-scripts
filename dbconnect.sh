#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-07
# Updated: 2014-05-04
#
#
#!/bin/bash

_dbcredz(){ # Get db credentials depending on site type
if [[ -f $SITEPATH/wp-config.php ]]; then #Wordpress
    dbconnect=($(grep DB_ $SITEPATH/wp-config.php | cut -d\' -f4));
    dbname=${dbconnect[0]}; dbuser="${dbconnect[1]}"; dbpass="${dbconnect[2]}"; dbhost=${dbconnect[3]};

elif [[ -f $SITEPATH/app/etc/local.xml ]]; then #Magento
    dbconnect=($(grep -B3 dbname $SITEPATH/app/etc/local.xml | cut -d\[ -f3 | cut -d\] -f1));
    dbhost=${dbconnect[0]}; dbuser="${dbconnect[1]}"; dbpass="${dbconnect[2]}"; dbname=${dbconnect[3]};

elif [[ -f $SITEPATH/configuration.php ]]; then #Joomla
    dbconnect=($(grep -B3 '$db ' $SITEPATH/configuration.php | cut -d\' -f2));
    dbhost=${dbconnect[0]}; dbuser="${dbconnect[1]}"; dbpass="${dbconnect[2]}"; dbname=${dbconnect[3]};

elif [[ -f $SITEPATH/sugar_version.php ]]; then #SugarCRM
    dbconnect=($(grep 'db_' $SITEPATH/config.php | cut -d\' -f4));
    dbhost=${dbconnect[0]}; dbuser="${dbconnect[2]}"; dbpass="${dbconnect[3]}"; dbname=${dbconnect[4]};

elif [[ "$1" == "ee" ]]; then #Expression Engine / CodeIgniter Apps
    dbconnect=($(grep '$db' $(find $SITEPATH -type f -name database.php) | cut -d\' -f6));
    dbhost=${dbconnect[0]}; dbuser="${dbconnect[1]}"; dbpass="${dbconnect[2]}"; dbname=${dbconnect[3]};

else echo -e "\nNo configuration found. Could not find database credentials.\n"; return 1; fi; }

_backup(){
if [[ -f /usr/bin/pigz ]]; then COMPRESS="pigz"; else COMPRESS="gzip"; fi
if [[ -f /usr/bin/pv ]];
then mysqldump -u$dbuser -p$dbpass $dbname -h $dbhost | pv -N 'Database Export' | $COMPRESS --fast > $dbname.sql.gz;
else mysqldump -u$dbuser -p$dbpass $dbname -h $dbhost | $COMPRESS --fast > $dbname.sql.gz; fi;
}

_import(){
if [[ $(file -b $dbfile) =~ ^gzip ]]; then DECOMP='zcat';
elif [[ $(file -b $dbfile) =~ ^bzip2 ]]; then DECOMP='bzcat';
elif [[ $(file -b $dbfile) =~ ^zip ]]; then DECOMP='zcat';
elif [[[ $(file -b $dbfile) =~^xz ]]; then DECOMP='xzcat';
else DECOMP='cat'; fi

if [[ -f /usr/bin/pv ]]; then
$DECOMP "$dbfile" | pv -N 'Database Import' | mysql -u"$dbuser" -p"$dbpass" -h$dbhost $dbname;
else $DECOMP "$dbfile" | mysql -u"$dbuser" -p"$dbpass" -h$dbhost $dbname; fi;
}

case "$1" in # Perform operation depending on parameters
    backup )
	if [[ -z "$2" ]]; then SITEPATH="."; else SITEPATH="$2"; fi;
	if [[ "$2" == "ee" || "$2" == "EE" ]]; then
		if [[ -z "$3" ]]; then SITEPATH="."; else SITEPATH="$3"; fi;
		_dbcredz ee; else _dbcredz; fi;
	echo -e "\nOutputting to $dbname.sql.gz ..."; _backup
        echo -e "Operation Completed.\n" ;;
    import )
	if [[ -z "$3" ]]; then SITEPATH="."; else SITEPATH="$3"; fi;
	if [[ "$2" == "ee" || "$2" == "EE" ]]; then
		if [[ -z "$4" ]]; then SITEPATH="."; else SITEPATH="$4"; fi;
		_dbcredz ee; echo -e "\nReading in $3 ...";
		dbfile="$3"; _import; echo -e "Operation Completed.\n"
	else
		_dbcredz; echo -e "\nReading in $2 ..."
	        dbfile="$2"; _import; echo -e "Operation Completed.\n"
	fi ;;
-h|--help|*)
	echo "
 This script works for the following:
   Databases: Magento, Wordpress, CodeIgniter (EE), SugarCRM, and Joomla.
   Filetypes: *.sql, *.sql.gz, *.sql.zip, *.sql.bz2, *.sql.xz

 Usage: $0 backup [ee] [path]
 Usage: $0 import [ee] <dbfile> [path]
" ;;
esac
