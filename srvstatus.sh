#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-18
# Updated: 2014-08-17
#
#
#!/bin/bash

dash(){ for ((i=1;i<=$1;i++)); do printf "-"; done; }

echo; FORMAT="%-18s %s\n"; printf "$FORMAT" " Service" " Status"; printf "$FORMAT" "$(dash 18)" "$(dash 55)";

#for x in $(chkconfig --list | awk '/3:on/ {print $1}' | sort); do
#printf "$FORMAT" " $x" " $(service $x status 2> /dev/null | head -1)"; done; echo

for x in $(chkconfig --list | awk '/3:on/ && !/^u/ && !/^sysst/ {print $1}'); do
printf " %-18s %s\n" "$x" "$(service $x status | head -n1)"; done; echo
