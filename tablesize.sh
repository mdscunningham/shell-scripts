#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-10-27
# Updated: 2014-10-27
#
#
#!/bin/bash

tablesize(){
if [[ -z $1 || $1 == '-h' || $1 = '--help' ]]; then
  echo -e "\n  Usage: tablesize [dbname] [option] [linecount]\n"; return 0; fi

if [[ $1 == '.' ]]; then dbname=$(finddb); shift;
  elif [[ $1 =~ ^[a-z]{1,}_.*$ ]]; then dbname="$1"; shift;
  else read -p "Database: " dbname; fi

case $1 in
 -r ) col='4'; shift;;
 -d ) col='6'; shift;;
 -i ) col='8'; shift;;
  * ) col='6';;
esac

if [[ $1 =~ [0-9]{1,} ]]; then top="$1"; else top="20" ; fi

echo -e "\nDatabase: $dbname\n$(dash 93)"; printf "| %-50s | %8s | %11s | %11s |\n" "Name" "Rows" "Data_Size" "Index_Size"; echo "$(dash 93)";
echo "show table status" | m $dbname | awk 'NR>1 {printf "| %-50s | %8s | %10.2fM | %10.2fM |\n",$1,$5,($7/1024000),($9/1024000)}' | sort -rnk$col | head -n$top
echo -e "$(dash 93)\n"
}

tablesize "$@"
