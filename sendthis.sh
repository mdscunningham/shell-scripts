#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-18
# Updated: 2014-03-19
#
#
#!/bin/bash

_sendthis(){
if [[ $@ == '-h' || $@ == '--help' || -z $@ ]]; then echo -e "\n Usage: sendthis <filename> <subject> <emailaddr>\n"; return 0; fi

if [[ -n $1 ]]; then FILE=$1; else read -p "Filename: " FILE; fi
if [[ -n $2 ]]; then SUBJECT=$2; else read -p "Subject: " SUBJECT; fi
if [[ -n $3 ]]; then EMAIL=$3; else read -p "Email: " EMAIL; fi

if grep -Fqi 'CentOS release 6' /etc/redhat-release; then echo "See Attached" | mail -s "$SUBJECT" -a "$FILE" "$EMAIL";
else cat "$FILE" | mail -s "$SUBJECT" "$EMAIL"; fi;
}
_sendthis "$@"
