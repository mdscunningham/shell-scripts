#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-12-26
# Updated: 2016-12-27
#
# Purpose: Check if SSL is revoked by making an OCSP requet to the SSL issuer
#

domain=$1;

echo | openssl s_client -connect $domain:443 -showcerts 2>/dev/null| awk '/BEGIN/,/END/ {print}' > fullchain.pem
  cat fullchain.pem | openssl x509 > $domain.crt

linenum=$(grep -n BEGIN fullchain.pem | awk -F: 'NR==2 {print $1}')
  tail -n +$linenum fullchain.pem > chain.pem

ocspurl=$(openssl x509 -in $domain.crt -noout -ocsp_uri)
  echo "OCSP URL : $ocspurl"
ocsphost=$(echo $ocspurl | cut -d/ -f3)
  echo "OCSP HOST: $ocsphost"

openssl ocsp -no_nonce -header host $ocsphost -issuer chain.pem -cert $domain.crt -url $ocspurl -CAfile chain.pem 2>/dev/null

rm -f fullchain.pem
rm -f chain.pem
rm -f $domain.crt
