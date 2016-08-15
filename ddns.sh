#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-20
# Updated: 2016-08-14
#
#
#!/bin/bash

dash (){ for ((i=1; i<=$1; i++)); do printf "-"; done; }
OPTS="+time=2 +tries=2 +short +noshort"
verbose=''

# Check for verbose flag
if [[ $1 == '-v' ]]; then verbose=1; shift; fi

# Prompt for input if none provided
if [[ -z "$@" ]]; then
  read -p "Domain Name: " D;
else
  D="$@";
fi;

# Clean up inputs and start loop
for domain in $(echo $D | sed 's/\///g;s/http://g;s/https://g'); do
  echo -e "\nDNS Summary: $domain\nIntoDNS: http://www.intodns.com/check/?domain=$domain"

  # Attempt to check whois for nameservers and registrar if verbose
  if [[ $verbose ]]; then
    echo -ne "Whois-NS: ...working...\r"
    if [[ $domain =~ \.edu$ ]]; then
      echo -ne "Whois-NS: "; whois $domain | awk '/.ame.?.erver.?/,/^$/ {print}' | tail -n+2 | awk '{printf $1" "}'; echo
    else
      whois $domain | awk 'BEGIN{printf "Whois-NS: "}; ($NF !~ /.ervers?:/) && /.ame.?.erver|DNS:/{printf $NF" "}; /egistrar:/ {registrar=$0}; END{printf "\n%s\n",registrar}' | tr -d '\r'
    fi
  fi

  echo -e "$(dash 80)";
  for record in a aaaa ns mx txt soa; do
    if [[ $record == 'ns' || $record == 'mx' ]]; then
      dig $OPTS $record $domain | grep -v root \
      | while read result; do echo "$result -> "$(dig +short $(echo $result | awk '{print $NF}')); done | sort -k5
    else
      dig $OPTS $record $domain | grep -v '^;;'
    fi
  done;

  # Lookup SRV records for live.com
  for SRV in '_sip._tls' '_sipfederationtls._tcp'; do
    dig $OPTS srv $SRV.$domain | grep 'SRV'
  done

  # Lookup rDNS/PTR for the IP
  dig $OPTS -x $(dig +time=2 +tries=2 +short $domain) 2>/dev/null

done
echo;
