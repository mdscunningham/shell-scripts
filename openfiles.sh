#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-31
# Updated: 2014-08-31
#
#
#!/bin/bash

# Deleted but are being held open, so you can kill the PID and let the file die.
printf "\n%8s %12s %11s %s\n" "PID " "Command " "Size " " Deleted Files (being held open)";
printf "%8s %12s %11s %s\n" "--------" "------------" "-----------" "$(dash 57)";
(lsof -u $(getusr) | awk '($5 ~ /DEL/) {printf "%8s %12s %10.2fM %s\n",$2,$1,($7/1024/1000),$9}') | sort -rnk3 | head -20; echo
