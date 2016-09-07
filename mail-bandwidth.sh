#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-08-31
# Updated: 2016-09-02
#
# Purpose: Check largest bandwidth consumption by mail address and top mail login IPs.
#

# Top bandwidth users by email address
echo "Top Email Users by Bandwidth"
awk '!/cpanel/ && ($NF ~ /bytes/) {split($NF,bytes,/\//); tx[$6]+=bytes[2]} END {for (x in tx) {printf "%8sM %s\n",(tx[x]/1024000),x}}' maillog* \
 | tr -d ':' | sort -rn | head
echo

# Top remote IPs for the user
echo "Top IPS per Email User"
awk -F'[ =]' '/Login:/ {print $13,$9}' maillog* \
 | awk '{freq[$0]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' \
 | tr -d '<>,' | sort -rn | awk '{printf "%8s %-15s %s\n",$1,$2,$3}' | head
echo
