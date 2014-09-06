#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-01-08
# Updated: 2014-03-19
#
#
#!/bin/bash

_killqueries(){
_querieslog(){ filename="mytop-dump--$(date +%Y.%m.%d-%H.%M).dump";
	mytop -b --nocolor > ~/"$filename"; echo -e "\n~/$filename created ...\nBegin killing queries ..."; }
case $1 in
sel|select) _querieslog; x=$(awk '/SELECT/ {print $1}' ~/"$filename");
	for i in $x; do echo "Killing $i"; m -e"kill $i"; done; echo -e "Operation completed.\n" ;;
sle|sleep) _querieslog; x=$(awk '/Sleep/ {print $1}' ~/"$filename");
	for i in $x; do echo "Killing $i"; m -e"kill $i"; done; echo -e "Operation completed.\n" ;;
-h|--help|*) echo -e "\n Usage: killqueries [sleep|select]\n" ;;
esac;
}
_killqueries "$@"
