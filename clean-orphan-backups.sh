#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-09-11
# Updated: 2016-09-11
#
# Purpose: Cleaning orphaned newer style backups, for accounts not on the server.
#

for x in /backup/*/accounts/*.tar.gz /backup/weekly/*/accounts/*.tar.gz; do
  user=$(basename $x .tar.gz);
  if [[ ! $(grep $user /etc/domainusers) ]]; then
   echo "Removed orphaned backup :: $user :: $x";
   rm -f $x;
  fi;
done
