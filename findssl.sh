#!/bin/bash
#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-29
# Updated: 2016-01-25
#
# Purpose: Test SSL connection and cert loading on a particular server and port

dash(){ for ((i=1; i<=$1; i++)); do printf "$2"; done; }

# Check for alternate port
if [[ $2 == '-p' ]]; then P=$3; else P=443; fi

# Cleanup Domain input
D=$(echo $1 | sed 's|^http:||g;s|https:||g;s|\/||g;');
I=$(dig +short $D | grep [0-9])

# Check if local version of OpenSSL has SNI support
if [[ $(openssl version | awk '{print $2}') =~ ^1\. ]]; then SNI="-servername $D"; else SNI=''; fi

if [[ $P == 587 ]]; then SNI="$SNI -starttls smtp";
elif [[ $P == 21 ]]; then SNI="$SNI -starttls ftp"; fi

## if [[ -n $SNI ]]; then echo '(Using SNI)'; else echo '(Not using SNI)'; fi

# Print header
echo; echo "$D:$P :: $I:$P"; echo "$(dash 60 -)";

# Print SSL checker service URLs
echo "https://www.sslshopper.com/ssl-checker.html#hostname=$D:$P"
echo "https://certlogik.com/ssl-checker/$D:$P"
echo "https://www.ssllabs.com/ssltest/analyze.html?d=${D}&s=${I}&latest"

#readssl="$(echo | openssl s_client -connect $D:$P $SNI 2>/dev/null | awk '/-----BEGIN/,/-----END/{print}')"

# Connect to the domain at port, get SSL, Decode SSL, clean up output and print
echo | openssl s_client -connect $D:$P $SNI 2>/dev/null | openssl x509 -text -noout 2>/dev/null | egrep -i 'subject:|dns:|issuer:'\
 | sed 's/DNS:/\nDNS:/;s/Subject: /\nSubject:\n/;s/Issuer: /\nIssuer:\n/;s/, /\n/g;s/[=:]/: /g;s/\/email/\nemail/g;s/\/busi/\nBusi/g;s/\/seri/\nSeri/g;s/\/1\.3\.6\./\n1\.3\.6\./g';
echo | openssl s_client -connect $D:$P $SNI 2>/dev/null | openssl x509 -text -noout | grep Signature.Algorithm | head -1 | sed 's/.*Sig/\nSig/g'
echo | openssl s_client -connect $D:$P $SNI 2>/dev/null | openssl x509 -text -noout | grep Not.After | sed 's/.*Not.After./Expires/g'
echo;

# Check for common SSL issues, and their error messages.
echo "SSL Return Code"; echo "$(dash 60 -)";
rcode=$(echo | openssl s_client -connect $D:$P $SNI 2>/dev/null | grep Verify.*)
echo $rcode
if [[ $(echo $rcode | awk '{print $4}') =~ [0-9]{2} ]]; then
  curl -s https://www.openssl.org/docs/apps/verify.html | grep -A4 "$(echo $rcode | awk '{print $4}') X509" | grep -v X509 | sed 's/<[^>]*>//g' | tr '\n' ' '; echo;
fi; echo
