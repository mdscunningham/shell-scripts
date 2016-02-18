#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-02-11
# Updated: 2016-02-12
#
# Purpose: Script for mass updating database password in files
#

backup_prompt(){
  echo;
  read -p "cPanel User: " username
  read -p "Database: " database
  echo;
  }

backup(){
  echo -n > /root/${username}.dbpass.log
  echo "Logging to /root/${username}.dbpass.log"
  grep -rl $database /home/${username}/public_html/ | while read files; do
    echo "$files -> ${files}.bak" | tee -a /root/${username}.dbpass.log
    cp -a $files{,.bak};
  done; echo
  }

update_prompt(){
  echo;
  read -p "cPanel User: " username
  read -p "Database: " database
  read -p "Old Password: " oldpass
  read -p "New Password: " newpass
  echo;
  }

update(){
  grep -rl $database /home/${username}/public_html/ | grep -Ev '*.bak$' | while read files; do
    echo $files;
    grep $oldpass $files;
    echo "updating to ...";
    grep $oldpass $files | sed "s/$oldpass/$newpass/g";
    sed -i "s/$oldpass/$newpass/g" $files;
    echo;
  done; echo
  }

restore(){
  echo;
  read -p "cPanel User: " username
  echo;
  if [[ -f /root/${username}.dbpass.log ]]; then
    awk '{print $1}' /root/${username}.dbpass.log | while read files; do
      echo "Removing $files";
      rm -f $files;
      echo "Renaming $files.bak -> $files";
      mv $files{.bak,};
      echo;
    done;
  else
    echo "Missing: /root/${username}.dbpass.log"
  fi
  }

cleanup(){
  echo;
  read -p "cPanel User: " username
  echo;
  if [[ -f /root/${username}.dbpass.log ]]; then
    awk '{print $NF}' /root/${username}.dbpass.log | while read files; do
      echo "Removing ${files}";
      rm -f ${files};
    done; echo;
  else
    echo "Missing: /root/${username}.dbpass.log"
  fi
  }

echo "
[1] Backup files
[2] Update files
[3] Restore backup
[4] Cleanup backup
--------------------";
read -p "[1-4]: " opt;

case $opt in
  1) backup_prompt; backup;
     ;;

  2) update_prompt; update;
     ;;

  3) restore;
     ;;

  4) cleanup;
     ;;

  *) echo -e "\n$opt is not a valid option.";
     echo -e "Please enter a valid slection.\n";
     ;;

esac
