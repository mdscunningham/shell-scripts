#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-06
# Updated: 2014-04-11
#
#
#!/bin/bash

format="%2sx%-2s=%-4s";
echo;
for x in {1..10}; do
	for y in $(seq 1 $x); do
		printf $format "$y" "$x" "$(($x*$y))";
	done;
	echo; echo;
done
