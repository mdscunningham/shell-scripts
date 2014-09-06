#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-09-15
# Updated: 2013-12-01
#
#
#!/bin/bash

#Get current status script
echo

#SHOW USAGE IF NO INPUTS
if [[ "$@" == "" ]]; then
	echo "Usage: ~/./cur-status.sh [username] [line-count]"
	echo "Status information will not be specific to a user."; echo
fi

#SET FILENAME
if [[ $1 != "" ]]; then FILE=$1.$(date +%Y.%m.%d-%H.%M).$(hostname).txt
else FILE=NEXSTATUS.$(date +%Y.%m.%d-%H.%M).$(hostname).txt; fi
echo "Output file: $FILE"; echo

#SET LINECOUNT
if [[ $2 != "" ]]; then LINES=$2; else LINES="20"; fi

_newline(){ echo >> $FILE; }

#FREE MEMORY IN MEGABYTES
echo "Listing current free memory .. "; echo "n===== FREE MEMORY (MB) =====" >> $FILE
free -m >> $FILE; _newline

#LOGGED IN USERS
echo "Listing logged in users"; echo "===== CURRENT ACTIVE SSH USERS =====" >> $FILE
w >> $FILE; _newline

#CURRENT STATUS FOR A USER
if [[ $1 != "" ]]; then
	echo "Running top -u $1 .."; echo "===== TOP PROCESSES FOR $1 =====" >> $FILE
		top -u $1 -b -n1 >> $FILE; _newline
	echo "Searching ps aux for $1 .."; echo "===== ALL PROCESSES FOR | grep $1 =====" >> $FILE
		ps aux | grep $1 >> $FILE; _newline
	echo "Searching mytop for $1 .."; echo "===== MYTOP | grep $1 =====" >> $FILE
		mytop -b --nocolor | grep $1 >> $FILE; _newline
	echo "Searching php error log for $1 .."; echo "===== PHP LOG | grep $1 =====" >> $FILE
		tail -n$LINES /var/log/php-fpm/error.log | grep $1 >> $FILE; _newline
	echo "Searching httpd error log for $1 .."; echo "===== APACHE LOG | grep $1 =====" >> $FILE
		tail -n$LINES /var/log/httpd/error_log | grep $1 >> $FILE; _newline
	echo "Searching SSH auth log for $1 .."
		tail -n$LINES /var/log/secure | grep $1 >> $FILE; _newline
fi

#CURRENT STATUS OVERVIEW
if [[ -f /usr/bin/atop ]];
then echo "Running atop .."; echo "===== CURRENT ATOP OUTPUT =====" >> $FILE
	atop 1 1 >> $FILE; _newline;
else echo "Running top .."; echo "===== CURRENT TOP OUTPUT =====" >> $FILE
	top -b -n1 >> $FILE; _newline;
fi
echo "Running mytop .."; echo "===== TOP MYSQL QUERIES =====" >> $FILE
	mytop -b --nocolor | head -n$LINES >> $FILE; _newline
echo "Tailing php and httpd logs .."; echo "===== PHP & APACHE LOGS =====" >> $FILE
	tail -n$LINES /var/log/php-fpm/error.log /var/log/httpd/error_log >> $FILE; _newline
echo "Tailing SSH Auth Log"; echo "===== SSH AUTH LOG =====" >> $FILE
	grep -v 'Did not receive' /var/log/secure | tail -n$LINES >> $FILE; _newline
echo "Tailing ftp logs .."; echo "===== FTP LOGS =====" >> $FILE
	tail -n$LINES /var/log/proftpd/auth.log /var/log/proftpd/sftp.log /var/log/proftpd/tls.log /var/log/proftpd/xfer.log >> $FILE; _newline
echo
#less $FILE
