#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-02-05
# Updated: 2014-04-28
#
#
#!/bin/bash

## Get root database user credentials from server configuration
dbuser=$(grep ^rootdsn= /home/interworx/iworx.ini | cut -d/ -f3 | cut -d: -f1);
dbpass=$(grep ^rootdsn= /home/interworx/iworx.ini | cut -d: -f3 | cut -d\@ -f1);
dbhost="localhost";

## Setup headers for formatted output.
echo;
printf "%-11s  %-11s  %-11s  %-11s  %s\n" " On Disk   " " DataIndex " " Diff      " " DataFree  " " Database Name  "
printf "%-11s  %-11s  %-11s  %-11s  %s\n" "-----------" "-----------" "-----------" "-----------" "---------------------------------------------------"

## Get list of databases
databases=$(mysql -h "$dbhost" -u "$dbuser" -p"$dbpass" --batch --skip-column-names -e 'show databases' | grep -v '^performance_schema$')

for x in $databases; do
    ## Get size on disk and size of data in the tables
	disksize=$(du -sb /var/lib/mysql/$x 2> /dev/null | awk '{print $1}');
	if [[ $disksize == '' ]]; then disksize=0; fi

	dbsize=$(mysql -u$dbuser -p$dbpass -h$dbhost -e"select SUM(Data_length + Index_length) FROM information_schema.TABLES WHERE TABLE_SCHEMA = \"$x\";" | tail -n1);
	if [[ $dbsize == 'NULL' ]]; then dbsize=0; fi

	free=$(mysql -u$dbuser -p$dbpass -h$dbhost -e"select SUM(Data_free) FROM information_schema.TABLES WHERE TABLE_SCHEMA = \"$x\";" | tail -n1);
        if [[ $free == 'NULL' ]]; then free=0; fi

    ## Calculate Megabytes from bytes
	disksizem=$(echo "scale=2;${disksize}/1024/1024" | bc);
	dbsizem=$(echo "scale=2;${dbsize}/1024/1024" | bc);
        freem=$(echo "scale=2;${free}/1024/1024" | bc)
	frag=$(echo "scale=2;(${disksize}-${dbsize})/1024/1024" | bc)

    ## Print out the size on disk, size in tables, and the difference
	printf "%10sM  %10sM  %10sM  %10sM  %-s\n" "${disksizem}" "${dbsizem}" "$frag" "$freem" "$x";
done; echo
