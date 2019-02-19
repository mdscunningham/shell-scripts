#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-11-29
# Updated: 2019-02-19
#
#
#!/bin/bash

# Check for site's being brute forced (can search for a particular request)
shopt -s extglob

timestamp=$(date +"%d/%b/%Y")
echo; if [[ -n $1 ]]; then SEARCH="$1"; echo "Search: $SEARCH"; else read -p 'Search: ' SEARCH; fi; echo
for x in $(grep -Ec "${timestamp}.*POST.*${SEARCH}" /usr/local/apache/domlogs/*/*[^_log] /usr/local/apache/domlogs/*/*_log] 2> /dev/null | grep -E [0-9]{4}$ | awk -F/ '{print $NF}' | cut -d: -f1); do
  echo $x; grep -E "${timestamp}.*POST.*$SEARCH" /usr/local/apache/domlogs/*/$x | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | grep -E '[0-9]{3}\ '; echo;
done
