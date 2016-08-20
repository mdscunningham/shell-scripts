#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-05-24
# Updated: 2015-06-21
#
# Purpose: Count destination addresses for mail in queue, finding bulk senders
#          To be included in the queue processesing for spamfu, but very slow

## Queue Bulk Senders

# section_header "Queue: Bulk-Senders"
FMT="%8s %-16s %s\n"
printf "$FMT" "Count " " MessageID" " SenderID";
printf "$FMT" "--------" "$(dash 16 -)" "$(dash 54 -)";
for HEADER in $(find /var/spool/exim/input/ -type f -name "*-H" -print 2>/dev/null); do
  MSGID=$(head -1 $HEADER | sed 's/-H$//');
  COUNT=$(awk '/_sender$/,/Received/{c+=1}END{print c-6}' $HEADER);
  EMAIL=$(awk '/-auth_sender/{print $2}' $HEADER);
  printf "$FMT" "$COUNT " "$MSGID" " $EMAIL";
done | sort -rn | head -n $RESULTCOUNT
printf "$FMT" "--------" "$(dash 16 -)" "$(dash 54 -)";
