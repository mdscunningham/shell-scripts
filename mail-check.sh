#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2015-03-09
# Updated: 2015-03-09
#
#
#!/bin/bash

###
#
# Based on work by Brian Nelson
#
###

dash (){ for ((i=1; i<=$1; i++)); do printf "-"; done; }

clear

if [[ -n $1 ]]; then
    ipaddr="$1";
else
    ipaddr="$(ip addr show | awk '/inet / && ($2 !~ /^127\./) {print $2}' | cut -d/ -f1 | head -1)";
fi

echo -e "\n$(dash 80)\n  Web Based Checks \n$(dash 80)\n"

rdns="$(dig +short -x $ipaddr)"
echo "rDNS/PTR: ${rdns:-Is not setup ...}"

echo "http://multirbl.valli.org/lookup/${ipaddr}.html"
echo "http://www.senderbase.org/lookup/?search_string=${ipaddr}"
echo "http://mxtoolbox.com/SuperTool.aspx?action=blacklist%3a${ipaddr}&run=toolpage"

echo -e "\n$(dash 80)\n  Swaks Based Checks \n$(dash 80)"

for x in live.com att.net earthlink.com gmail.com yahoo.com; do
    echo -e "\n=> $x <=\n$(dash 80)"; swaks -4 -t postmaster@${x} -q RCPT -li $ipaddr 2>&1 | egrep '421|521|450|550|554|571';
done; echo

unset ipaddr
