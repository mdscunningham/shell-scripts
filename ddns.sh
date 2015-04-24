#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-20
# Updated: 2014-07-04
#
#
#!/bin/bash

dash (){ for ((i=1; i<=$1; i++)); do printf "-"; done; }

if [[ -z "$@" ]]; then
    read -p "Domain Name: " D;
else
    D="$@";
fi;
for x in $(echo $D | sed 's/http:\/\///g;s/\// /g');
do
    echo -e "\nDNS Summary: $x\n$(dash 79)";
    for y in a aaaa ns mx srv txt soa;
    do
        dig +time=2 +tries=2 +short $y $x +noshort;
        if [[ $y == 'ns' ]]; then dig +time=2 +tries=2 +short $(dig +short ns $x) +noshort | grep -v root; fi
    done;
    dig +short -x $(dig +time=2 +tries=2 +short $x) +noshort;
    echo;
done
