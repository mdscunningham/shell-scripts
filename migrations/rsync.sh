#!/bin/bash
dbz(){
  mysqldump --opt --skip-lock-tables -u "$(awk -F= '/user/ {print $2}' ~/.mytop)" -p"$(awk -F= '/pass/ {print $2}' ~/.mytop)" ${1} > ./nex-db-backups/${1}.$(date +%Y-%m-%d).sql.gz
}

sitecopy(){

USERNAME=$(pwd | sed 's:^/chroot::' | cut -d/ -f3)
TARGET=$1
LIVE=$2

if [[ -z $1 ]]; then
  echo "This script requires a hostname parameter."; return 1
fi

if [[ "$(pwd | sed 's:^/chroot::')" != "/home/$USERNAME" ]]; then
  echo "You must run this from the user's home directory."
  return 2
fi

if [[ -z $LIVE ]]; then
  echo "PERFORMING DRY-RUN OF RSYNC"
  sudo -u $USERNAME rsync -p --dry-run -v -e ssh -a -u -z ./ $USERNAME@$TARGET:/home/$USERNAME
else
  echo "Backing up var directory ...";
    tar -czf var.tar.gz var/ && chown $USERNAME. var.tar.gz

  echo "Backing up account databases ...";
    if [[ ! -d nex-db-backups ]]; then mkdir nex-db-backups; fi
    for x in /var/lib/mysql/${USERNAME}_*; do
      echo "Backing up $x ..."
      dbz $(echo $x | cut -d/ -f5)
    done && chown -R ${USERNAME}. nex-db-backups

  read -p "Press Enter to continue ..."

  echo "PERFORMING LIVE RSYNC"
  sudo -u $USERNAME rsync --exclude ./var --exclude iworx-backup -p -v -e ssh -a -u -z ./ $USERNAME@$TARGET:/home/$USERNAME

  echo "Cleaning up var and db backups ..."; rm -r nex-db-backups var.tar.gz
fi
}

sitecopy "$@"
