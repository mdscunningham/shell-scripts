#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-12-26
# Updated: 2016-12-28
#
# Purpose: Check if SSL is revoked by making an OCSP requet to the SSL issuer
#

domain=$1;

echo | openssl s_client -connect $domain:443 -showcerts 2>/dev/null| awk '/BEGIN/,/END/ {print}' > /tmp/fullchain.pem
  cat /tmp/fullchain.pem | openssl x509 > /tmp/$domain.crt

linenum=$(grep -n BEGIN /tmp/fullchain.pem | awk -F: 'NR==2 {print $1}')
  tail -n +$linenum /tmp/fullchain.pem > /tmp/chain.pem

ocspurl=$(openssl x509 -in /tmp/$domain.crt -noout -ocsp_uri)
  echo "OCSP URL : $ocspurl"
ocsphost=$(echo $ocspurl | cut -d/ -f3)
  echo "OCSP HOST: $ocsphost"

openssl ocsp -no_nonce -header host $ocsphost -issuer /tmp/chain.pem -cert /tmp/$domain.crt -url $ocspurl -CAfile /tmp/chain.pem 2>/dev/null

rm -f /tmp/fullchain.pem
rm -f /tmp/chain.pem
rm -f /tmp/$domain.crt
