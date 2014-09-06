#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-18
# Updated: 2014-03-18
#
#
#!/bin/bash

## For list of lines in /etc/host.allow
## that contain sshd: prepend the apf information
for IPADDR in $(awk '/^sshd:/ {print "d=22:s="$2}' /etc/hosts.allow); do

	## If there are four segments to the IP, append /32
	if [[ $IPADDR =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		echo "${IPADDR}/32";

	## If there are three segements with a . at the end, append 0/24
	elif [[ $IPADDR =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.$ ]]; then
		echo "${IPADDR}0/24"

	## If there are three segments with no . at the end, append .0/24
	elif [[ $IPADDR =~ [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		echo "${IPADDR}.0/24"

	## If there are two segments and a . at the end, append 0.0/16
	elif [[ $IPADDR =~ [0-9]{1,3}\.[0-9]{1,3}\.$ ]]; then
		echo "${IPADDR}0.0/16"

	## If there are two segments and no . at the end, append .0.0/16
	elif [[ $IPADDR =~ [0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                echo "${IPADDR}.0.0/16"

	## EndIf
	fi;

## finish up, sort, remove duplicates, and output to a file.
done | sort | uniq > whitelistConversion.log

## Tell me where the new file is
echo -e "\n Log file saved to: ${PWD}/whitelistConversion.log\n"
