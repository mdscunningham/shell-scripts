#!/bin/bash
sitecopy(){
USERNAME=$(pwd | sed 's:^/chroot::' | cut -d/ -f3)
TARGET=$1; LIVE=$2

if [[ -z $1 ]]; then
  echo "This script requires a hostname parameter."; return 1; fi

if [[ "$(pwd | sed 's:^/chroot::')" != "/home/$USERNAME" ]]; then
  echo "You must run this from the user's home directory."; return 2; fi

if [[ -z $LIVE ]]; then
  echo "PERFORMING DRY-RUN OF RSYNC"
  sudo -u $USERNAME rsync -p --dry-run -v -e ssh -a -u -z ./ $USERNAME@$TARGET:/home/$USERNAME

else
  echo "Backing up var directory ...";
  tar -czf var.tar.gz var/ && chown $USERNAME. var.tar.gz
  echo "PERFORMING LIVE RSYNC"
  sudo -u $USERNAME rsync --exclude ./var --exclude iworx-backup -p -v -e ssh -a -u -z ./ $USERNAME@$TARGET:/home/$USERNAME
  echo "Cleaning up var backups ..."; rm var.tar.gz
fi
}
sitecopy "$@"
