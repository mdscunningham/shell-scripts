#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-02-10
# Updated: 2016-02-10
#
# Purpose: Convert courier imap-subscription files to dovecot imap-subscription files
#

echo "Creating list of current Courier-Imap subscriptions ..."
find /home*/*/mail/*/ -type f -name courierimapsubscribed -print > /root/courierimapsubscribed.list

echo "Starting conversions ..."
cat /root/courierimapsubscribed.list | while read imapsub; do

  dovecot=$(echo $imapsub | sed 's/courierimapsubscribed/subscriptions/');
  username=$(echo $imapsub | cut -d/ -f3);
  email="$(echo $imapsub | cut -d/ -f6)@$(echo $imapsub | cut -d/ -f5)"

  if [[ ! -f $dovecot || -s $dovecot ]]; then
    echo "$username :: Converting $email config :: $dovecot"
    sed 's/^Inbox\.\(.*\)$/\1/g;s/^INBOX\.\(.*\)$/\1/g' $imapsub > $dovecot;
    chown ${username}. $dovecot; chmod 640 $dovecot;
  else
    echo "$username :: $email already using :: $dovecot"
  fi;

done
