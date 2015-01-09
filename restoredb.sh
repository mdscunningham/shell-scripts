#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: A long time ago
# Updated: 2014-12-25
#
#
#!/bin/bash

echo; if [[ -z "$1" ]]; then read -p "Backup filename: " DBFILE; else DBFILE="$1"; fi;

DBNAME=$(echo $DBFILE | cut -d. -f1);
echo "Creating current $DBNAME backup ..."; mdz $DBNAME;
echo "Dropping current $DBNAME ..."; m -e"drop database $DBNAME";
echo "Creating empty $DBNAME ..."; m -e"create database $DBNAME";
echo "Importing backup $DBFILE ...";

if [[ $DBFILE =~ \.gz$ ]]; then SIZE=$(gzip -l $DBFILE | awk 'END {print $2}');
elif [[ $DBFILE =~ \.zip$ ]]; then SIZE=$(unzip -l $DBFILE | awk '{print $1}'); fi

if [[ -f /usr/bin/pv ]]; then zcat -f $DBFILE | pv -s $SIZE | m $DBNAME;
else zcat -f $DBFILE | m $DBNAME; fi;

if [[ -d /home/mysql/$DBNAME/ ]]; then echo "Fixing Ownership on new DB ..."; chown -R mysql:$(echo $DBNAME | cut -d_ -f1) /home/mysql/$DBNAME/; fi
echo
