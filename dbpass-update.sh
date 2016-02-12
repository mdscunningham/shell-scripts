#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-02-11
# Updated: 2016-02-11
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
	echo > /root/${username}.dbpass.log
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
			echo "Removeing $files"; rm -f $files;
			echo "Renaming $files.bak -> $files" mv $files{.bak,}
			echo;
		done;
	else
		echo "Missing: /root/${username}.dbpass.log"
	fi
	}

echo;
read -p "[1] Backup files? / [2] Update files? / [3] Restore backup ? [1/2/3]: " opt;

if [[ $opt == 1 ]]; then
	backup_prompt;
	backup;
elif [[ $opt == 2 ]]; then
	update_prompt;
	update;
elif [[ $opt == 3 ]]; then
	restore;
else
	echo -e "\n$opt is not a valid option.";
	echo -e "Please enter a valid slection.\n";
fi;
