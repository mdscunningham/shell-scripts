#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-19
# Updated: 2014-04-03
#
#
#!/bin/bash

# Source of these scripts -> http://qmailrocks.thibs.com/qmqtool.php
function _qmq(){
if [[ -z $@ || $1 == "-h" || $1 == "--help" ]]; then
echo -e "\n Usage $0 [sub|rec|send|radd|rdom|ladd|ldom] [top#]\n
    sub ... Top Subject in Remote Queue
    send .. Top Sender in Remote Queue
    rec ... Top Recipient in Remote Queue
    sdom .. Top Sending Domain in Remote Queue
    radd .. Top Receive Address in Remote Queue
    rdom .. Top Receive Domains in Remote Queue
    ladd .. Top Receive Address in Local Queue
    ldom .. Top Receive Domains in Local Queue\n"; return 0;
else OPT="$1"; fi;
if [[ -z $2 ]]; then N=20; else N=$2; fi
echo; case $OPT in
## Top Subject of the remote queue
sub ) qmqtool -R | grep "Subject: " | sort | uniq -c | sort -rn | head -n$N;;

## Top Receiver of mail stuck in the queue
rec ) qmqtool -R | awk '/Recipient:/ { print $3 }' | sort | uniq -c | sort -n;;

## Top Senders to the remote queue
send ) qmqtool -R | grep "Sender: " | sort | uniq -c | sort -rn | head -n$N;;

## Top Domain of senders in the remote queue
sdom ) qmqtool -R | grep "Sender: " | grep -Eo '\@[a-z0-9].*\>' | sort | uniq -c | sort -rn | head -n$N;;

## Top receive addresses in the remote queue
radd|raddress ) qmqtool -R | grep "Recipient: " | sort | uniq -c | sort -rn | head -n$N;;

## Top domains in the remote queue
rdom|rdomain ) qmqtool -R | grep "Recipient: " | cut -d @ -f2 | tr -d '>' | sort | uniq -c | sort -rn | head -n$N;;

## Top receive addresses in the local queue
ladd|laddress ) qmqtool -L | grep "Recipient: " | sort | uniq -c | sort -rn | head -n$N;;

## Top Domains in the local queue
ldom|ldomain ) qmqtool -L | grep "Recipient: " | cut -d @ -f2 | tr -d '>' | sort | uniq -c | sort -rn | head -n$N;;
esac; echo
}
_qmq $1 $2
