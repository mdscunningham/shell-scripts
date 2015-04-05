#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-11-02
# Updated: 2015-03-19
#
#
#!/bin/bash

if [[ -n $1 ]]; then sitepath="$1"; else sitepath='.'; fi

# Version Information
if [[ -n $(grep "define('VERSION'" ${sitepath}/modules/system/system.module) ]]; then
  verfile="${sitepath}/modules/system/system.module"
elif [[ -n $(grep "define('VERSION'" ${sitepath}/includes/bootstrap.inc) ]]; then
  verfile="${sitepath}/includes/bootstrap.inc"
fi;
version=$(grep "define('VERSION'" $verfile | cut -d\' -f4)
installdate=$(stat $verfile | awk '/Change/ {print $2,$3}' | cut -d. -f1)
config="${sitepath}/sites/default/settings.php"

# Database Config (7.x)
# Database, Username, Password, Host, Driver, Prefix
if [[ $version =~ ^7 || $version =~ ^8 ]]; then
dbname=$(awk '($1 ~ /database/ && $3 !~ /array/) {print $3}' $config | cut -d\' -f2)
dbuser=$(awk '($1 ~ /username/) {print $3}' $config | cut -d\' -f2)
dbpass=$(awk '($1 ~ /password/) {print $3}' $config | cut -d\' -f2)
dbhost=$(awk '($1 ~ /host/) {print $3}' $config | cut -d\' -f2)
dbdriv=$(awk '($1 ~ /driver/) {print $3}' $config | cut -d\' -f2)
prefix=$(awk '($1 ~ /prefix/) {print $3}' $config | cut -d\' -f2)

# Database Config (6.x)
# mysql://username:password@localhost/database
elif [[ $version =~ ^6 || $version =~ ^5 ]]; then
dbase=$(awk '($1 ~ /db_url/) {print $3}' $config | cut -d\' -f2)
dbname=$(echo $dbase | cut -d@ -f2 | cut -d/ -f2)
dbuser=$(echo $dbase | cut -d: -f2 | cut -d/ -f3)
dbpass=$(echo $dbase | cut -d: -f3 | cut -d@ -f1)
dbhost=$(echo $dbase | cut -d@ -f2 | cut -d/ -f1)
dbdriv=$(echo $dbase | cut -d: -f1)
prefix=$(awk '($1 ~ /db_prefix/) {print $3}' $config | cut -d\' -f2)

fi
database="${dbdriv}://${dbuser}:${dbpass}@${dbhost}/${dbname}$(if [[ -n ${prefix} ]]; then echo .${prefix}*; fi)"

base_path=$(cd $sitepath; pwd -P;)
base_url=$(grep -C5 $PWD /usr/local/apache/conf/httpd.conf | awk '/ServerName/ {print $2}')
sitename=$(mysql -u $dbuser -p"$dbpass" $dbname -h $dbhost -e "select name,value from ${prefix}variable where name=\"site_name\";" | tail -1 | cut -d\" -f2)
posts=$(mysql -u $dbuser -p"$dbpass" $dbname -h $dbhost -e "select count(*) from ${prefix}node;" | tail -1)

echo
FMT="%-18s: %s\n"
printf "$FMT" "Base Path" "${base_path}"
printf "$FMT" "Site Title" "${sitename}"
printf "$FMT" "Install Date" "${installdate}"
printf "$FMT" "Version" "${version}"
printf "$FMT" "Front End URL" "http://${base_url}"
printf "$FMT" "Back End URL" "http://${base_url}/admin"
printf "$FMT" "Post Count" "${posts}"
printf "$FMT" "DB Connection" "${database}"

# printf "$FMT" "Encryption Key" ""
# printf "$FMT" "Logging" ""
# printf "$FMT" "Return Path" ""
# printf "$FMT" "Session/Cache" ""
# printf "$FMT" "Compression" ""
# printf "$FMT" "Active Modules" ""
# printf "$FMT" "Multi-Site" ""
# printf "$FMT" "" ""

echo
unset verfile version config base_url posts database dbname dbpass dbuser base_path installdate dbhost dbdriv prefix
