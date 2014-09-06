#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-29
# Updated: 2014-09-06
#
#
#!/bin/bash

if [[ $2 == '-p' ]]; then P=$3; else P=443; fi
if [[ $@ =~ -v ]]; then type="subject issuer"; else type="subject"; fi

D=$(echo $1 | sed 's/\///g')
echo; echo "SSL loading on $D:$P"; dash 80; echo;

for x in $type; do
    echo "$x: "
    echo | openssl s_client -connect $D:$P -nbio 2> /dev/null\
     | grep $x\
     | sed 's/ /_/g;s/\/\([A-Ze]\)/\n\1/g;s/=/: /g'\
     | grep ^[A-Ze]\
     | column -t\
     | sed 's/_/ /g';
    echo;
done

# Try to find any additional domains that the certificate is good for (multidomain)
# echo "Domains: "
# echo | openssl s_client -connect $D:$P -nbio 2> /dev/null | grep 'DNS:' | sed 's/, /\n/g' | sed 's/.*DNS:/DNS = /g'
# echo;
