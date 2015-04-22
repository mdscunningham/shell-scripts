#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-04-20
# Updated: 2015-04-20
#
#
#!/bin/bash

## Set time period to clean for
if [[ -n $2 ]]; then d=$2; else d=31; fi

##########
# Clean cpbackup (incremental) dirs older than $d days
###
clean_incremental(){
  echo -e "\nCleaning Incremental Backups older than $d days...\n";
  for dir in $(find /backup/cpbackup/ -type d -name "*.[0-9]" -mtime +$d -print); do
    echo "Removing: $(du -sh $dir)"; rm -rf $dir; done
  echo -e "\nOperation Complete\n"
}

##########
# Clean cpbackup (archive) files older than $d days
###
clean_archives(){
  echo -e "\nCleaning Archive Backups older than $d days...\n";
  new_style=$(find /backup/*/accounts/ -name "*.tar.gz" -mtime +$d -print)
  old_style=$(find /backup/cpbackup/ -type f -name "*.tar.gz" -mtime +$d -print)

  for backup in ${new_style} ${old_style}; do
    echo "Removing: $(ls -lah $backup)"; rm -f $backup; done
  echo -e "\nOperation Complete\n"
}

##########
# Find Orphaned backups
###
find_orphans(){
if [[ -e /backup/cpbackup/ ]]; then
  list=$(for file in /backup/cpbackup/{daily,weekly}/*.tar.gz; do basename $file .tar.gz; done)
  for acct in $list; do
    if [[ -z $(grep ${acct}: /etc/domainusers) ]]; then echo "Missing: $acct"; fi
  done; echo
else echo -e "\n/backup/cpbackup/ does not exist.\n"; fi
}

## Original version from jpotter
#  for i in $(basename /backup/cpbackup/*/*.tar.gz .tar.gz); do
#    t=$(echo grep $i\$ /etc/userdomains); if [[ -z "$t" ]]; echo Absent: $i; fi;
#  done

if [[ $1 =~ -i ]]; then clean_incremental; fi
if [[ $1 =~ -a ]]; then clean_archives; fi
if [[ $1 =~ -o ]]; then find_orphans; fi
if [[ $1 =~ -h ]]; then echo -e "\nUsage: $0 [OPTIONS] [#days]\n\n    -i ... Clean Incremental\n    -a ... Clean Archives\n    -o ... Find Orphans\n    -h ... Print help and quit\n"; fi
