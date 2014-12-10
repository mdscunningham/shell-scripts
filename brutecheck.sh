#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-11-29
# Updated: 2014-11-29
#
#
#!/bin/bash

# Check for site's being brute forced (can search for a particular request)

echo; if [[ -n $1 ]]; then SEARCH="$1"; echo "Search: $SEARCH"; else read -p 'Search: ' SEARCH; fi; echo
for x in $(grep -Ec "POST.*${SEARCH}" /home/*/var/*/logs/transfer.log | grep -E [0-9]{4} | cut -d/ -f5); do
  echo $x; traffic $x ip -s POST.*${SEARCH} | grep -E [0-9]{4}; echo;
done

# Determin Log File Location
#VHOST="/etc/httpd/conf.d/vhost_*.conf"
#if [[ $(hostname) =~ .*-lb ]]; then
#  LOGFILE="/var/log/interworx/*/*/logs/transfer.log";
#  DOMAINS="$(echo $LOGFILE | cut -d/ -f6)"
#else
#  LOGFILE="$(awk '/CustomLog/ {print $2}' $VHOST | head -n1)";
#  DOMAINS="$(echo $LOGFILE | cut -d/ -f5)";
#fi

#for x in $(grep -Ec "POST.*${SEARCH}" /home/*/var/*/logs/transfer.log | grep -E [0-9]{4} | cut -d/ -f5); do
#  echo $x;
#  grep -E "POST.*${SEARCH}" /home/*/var/$x/logs/transfer.log\
#   | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
#   | sort -rn | grep -E [0-9]{4}; echo
#done;
