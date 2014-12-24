#!/bin/bash
if [[ -f var.tar.gz ]]; then
  echo "Moving current var/ to var.old/"; mv var{,.old}
  echo "Unpacking var archive ..."; tar -zxpf var.tar.gz
  echo "Sync'ing var.old/ with var/ ..."; rsync -a var.old/ var/

  primaryDomain=$(~iworx/bin/listaccounts.pex | awk "/$(pwd | sed 's:^/chroot::' | cut -d/ -f3)/"'{print $2}')
  echo "Runing varpermsfix on Siteworx account [$primaryDomain]"
  ~iworx/bin/varpermsfix.pex --siteworx=$primaryDomain
  echo "Cleaning up var backup ..."; rm -r var.old var.tar.gz; echo "Done"
fi

if [[ -d nex-db-backups ]]; then
  cd nex-db-backups
  for x in *.sql.gz; do
    dbname="$(echo $x | cut -d. -f1)"
    m -e"drop database $dbname; create database $dbname;"
    zcat $x | pv -l "Importing $x" | m $dbname
  done && cd ../ && echo "Cleaning up nex-db-backups" && rm -r nex-db-backups
fi
