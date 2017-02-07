#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-09-11
# Updated: 2017-01-24
#
# Purpose: Cleaning orphaned newer style backups, for accounts not on the server.
#

if [[ -d /backup/cpbackup/ ]]; then
   echo "Cleaning Legacy Backups"
   backuplist=$(find /backup/cpbackup/{daily,weekly,monthly}/ -type f -name "*.tar.gz" 2>/dev/null)
else
   echo "Cleaning Modern Backups"
   backuplist=$(find /backup/{,weekly,monthly}/*/accounts/ -type f -name "*.tar.gz" 2>/dev/null)
fi

for x in $backuplist; do
  user=$(basename $x .tar.gz);
  if [[ ! $(grep $user /etc/domainusers) ]]; then
   echo "Removed orphaned backup :: $user :: $x";
   rm -f $x;
  fi;
done
