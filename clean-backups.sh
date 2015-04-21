#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-04-20
# Updated: 2015-04-20
#
#
#!/bin/bash


## Original version from jpotter
# for i in $(basename /backup/cpbackup/*/*.tar.gz .tar.gz); do t=$(echo grep $i\$ /etc/userdomains); if [[ -z "$t" ]]; echo Absent: $i; fi; done

# list=$(for file in *.tar.gz; do basename $file .tar.gz; done); for acct in $list; do grep $acct\$ /etc/userdomains; done

# list=$(for file in $(find /backup/cpbackup/ -name "*.tar.gz" -mtime +30 -print); do basename $file .tar.gz; done); for acct in $list; do grep $acct\$ /etc/userdomains; done

#######
#
# Clean cpbackup (incremental) directories older than 30 days
#
###
d=30;
echo "Started cleaning Backup Data older than $d days...";
for dir in $(find /backup/cpbackup/ -name "*.[0-9]" -type d -mtime +$d); do
  echo Processing: $(du -sh $dir); echo "    Purging $i"; rm -rf $dir;
done;
echo "Finished Cleaning Backup Data older than $d days"

######
#
# Clean cpbackup (archives) older than 30 days
#
###
d=30;
echo "Started cleaning Backup Data older than $d days...";
for file in $(find /backup/cpbackup/ -name "*.tar.gz" -type d -mtime +$d); do
  echo Processing: $(du -sh $file); echo "    Purging $file"; rm $file;
done;
echo "Finished Cleaning Backup Data older than $d days"

######
#
# Find Orphaned backups
#
###
list=$(for file in *.tar.gz; do basename $file .tar.gz; done)
for acct in $list; do grep ${acct}: /etc/domainusers; done

