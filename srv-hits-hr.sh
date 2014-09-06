#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-04-12
# Updated: 2014-04-18
#
#
#!/bin/bash

if [[ -z $1 ]]; then top=10; else top=$1; fi
echo;
printf "%-30s %-10s\n" " Domain Name" " Hits";
printf "%-30s %-10s\n" "$(dash 30)" "$(dash 10)";

for x in /home/*/var/*/logs/transfer.log; do
	printf "%-30s %-10s\n" " $(echo $x | cut -d/ -f5)" " $(grep -Ec "$(date +%d/%b/%Y.%H)" $x)";
done | sort -rn -k2 | head -n$top
echo
