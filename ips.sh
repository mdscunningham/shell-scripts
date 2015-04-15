#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-05-03
# Updated: 2014-05-03
#
#
#!/bin/bash

#echo;
#macaddr=($(ifconfig | awk '/^e/ {print $1"_"$5}'))
#ipaddr=($(ifconfig | awk -F: '/\inet addr/ {print $2}' | awk '{print $1}' | grep -Ev '^127\.|^10\.|^172\.'))

#(echo "NIC MAC-Address IP-Address"
#for ((i=0;i<${#ipaddr[@]};i++)); do echo "${macaddr[i]} ${ipaddr[i]}" | sed 's/_/ /g'; done) | column -t
#echo

ip addr show | awk '/inet / && ($2 !~ /^127\.|^10\.|^172\.|^192\.168\./) {print $2}' | cut -d/ -f1
