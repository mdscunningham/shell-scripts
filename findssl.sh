#!/bin/bash
#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-29
# Updated: 2016-08-16
#
# Purpose: Test SSL connection and cert loading on a particular server and port

dash(){ for ((i=1; i<=$1; i++)); do printf "$2"; done; }

quiet=''
links=''
ip=''
P=443

OPTIONS=$(getopt -o "hi:lp:q" -- "$@") # Execute getopt
eval set -- "$OPTIONS" # Magic
while true; do # Evaluate the options for their options
case $1 in
  -i ) I=$2; ip=1; shift ;;
  -l ) links=1 ;;
  -q ) quiet=1 ;;
  -p ) P=$2; shift ;;
  -- ) shift; break ;; # More Magic
  -h|* ) echo -e "\n  Usage: $0 [options] <dom1> <dom2> ...
    -i ... <ipaddress> for SSL connections
    -l ... Print just web links
    -q ... Hide web links
    -p ... <port> for SSL connections\n
    -h ... Print this help and quit\n"; exit;;
esac;
shift;
done

echo;
for domain in $@; do
  # Cleanup Domain input
  D=$(echo $domain | sed 's|^http:||g;s|https:||g;s|\/||g;');

  # If IP not specified lookup IP
  if [[ ! $ip ]]; then I=$(dig +short $D | grep [0-9]); fi

  # Check if local version of OpenSSL has SNI support
  if [[ $(openssl version | awk '{print $2}') =~ ^1\. ]]; then SNI="-servername $D"; else SNI=''; fi

  # Add some TLS options if special ports are specified
  if [[ $P == 587 ]]; then SNI="$SNI -starttls smtp";
  elif [[ $P == 21 ]]; then SNI="$SNI -starttls ftp"; fi

  # Print header
  echo "$(dash 80 =)"; echo "$D:$P :: $I:$P"; echo "$(dash 80 -)";

  # Print SSL checker service URLs
  if [[ ! $quiet ]]; then
    echo "https://www.sslshopper.com/ssl-checker.html#hostname=$D:$P"
    echo "https://certlogik.com/ssl-checker/$D:$P"
    echo "https://www.ssllabs.com/ssltest/analyze.html?d=${D}&s=${I}&latest"
    echo
  fi

  # Print full output if not links mode
  if [[ ! $links ]]; then
    # Connect to the IP at port; get SSL; Decode SSL; clean up output and print
    echo | openssl s_client -connect $I:$P $SNI 2>/dev/null | openssl x509 -text -noout 2>/dev/null | egrep -i 'subject:|dns:|issuer:'\
     | sed 's/DNS:/\nDNS:/;s/.*Subject: /\nSubject:\n/;s/.*Issuer: /Issuer:\n/;s/, /\n/g;s/[=:]/: /g;s/\/email/\nemail/g;s/\/busi/\nBusi/g;s/\/seri/\nSeri/g;s/\/1\.3\.6\./\n1\.3\.6\./g';
    echo | openssl s_client -connect $I:$P $SNI 2>/dev/null | openssl x509 -text -noout | grep Signature.Algorithm | head -1 | sed 's/.*Sig/\nSig/g'
    echo | openssl s_client -connect $I:$P $SNI 2>/dev/null | openssl x509 -text -noout | grep Not.After | sed 's/.*Not.After./Expires/g'
    echo;

    # Check for common SSL issues, and their error messages.
    echo "SSL Return Code"; echo "$(dash 80 -)";
    rcode=$(echo | openssl s_client -connect $I:$P $SNI 2>/dev/null | grep Verify.*)
    echo $rcode
    if [[ $(echo $rcode | awk '{print $4}') =~ [0-9]{2} ]]; then
      curl -s https://www.openssl.org/docs/apps/verify.html | grep -A4 "$(echo $rcode | awk '{print $4}') X509" | grep -v X509 | sed 's/<[^>]*>//g' | tr '\n' ' '; echo;
    fi; echo
  fi
done
