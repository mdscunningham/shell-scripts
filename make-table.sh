#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-04-28
# Updated: 2014-04-28
#
#
#!/bin/bash

# If you output hits per hour using traffic, and do this for a series of days, you can
# build a table using this loop. You can also then put that table into a spreadsheet
# and you can then get a visual graph per day and compare the traffic during the hours
# of the week, day by day. It really is neato

trafficfile=$1
days=$2

for x in $(seq -w 0 23); do
	echo -n "$x:00 ";
	for y in $(seq 1 $days); do
		printf " $(grep $x: $trafficfile | awk '{print $2}' | head -n$y | tail -1)";
	done;
	echo;
done | column -t
