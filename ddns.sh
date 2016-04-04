#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-20
# Updated: 2016-04-03
#
#
#!/bin/bash

dash (){ for ((i=1; i<=$1; i++)); do printf "-"; done; }
OPTS="+time=2 +tries=2 +short +noshort"

if [[ -z "$@" ]]; then
  read -p "Domain Name: " D;
else
  D="$@";
fi;

for domain in $(echo $D | sed 's/http:\/\///g;s/\// /g'); do
  echo -e "\nDNS Summary: $x\n$(dash 79)";
  for record in a aaaa ns mx txt soa; do
    if [[ $record == 'ns' || $record == 'mx' ]]; then
      dig $OPTS $record $domain | grep -v root \
      | while read result; do echo "$result -> "$(dig +short $(echo $result | awk '{print $NF}')); done
    else
      dig $OPTS $record $domain
    fi
  done;

  # Lookup SRV records for live.com
  dig $OPTS srv _sip._tls.$domain
  dig $OPTS srv _sipfederationtls._tcp.$domain

  # Lookup rDNS/PTR for the IP
  dig $OPTS -x $(dig +time=2 +tries=2 +short $domain)
  echo;
done
