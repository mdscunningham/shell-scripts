#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2017-04-23
# Updated: 2017-05-04
#
# Purpose: Check available SSL version and ciphers (replicate nmap ssl-enum-ciphers)
#
# Notes: Based on concept and initial code by JBurnham
#

i=0; tempfile="/tmp/cipherlist.tmp";
echo -n > $tempfile; echo

if [[ $1 ]]; then DOMAIN="$1"; else read -p "Domain: " DOMAIN; fi
if [[ $2 ]]; then PORT="$2"; else PORT=443; fi

case $PORT in
  587) opt="-starttls smtp";;
  25) opt="-starttls smtp";;
  21) opt="-starttls ftp";;
  110) opt="-starttls pop3";;
  143) opt="-starttls imap";;
  *) opt="";;
esac

for v in ssl2 ssl3 tls1 tls1_1 tls1_2; do

  case $v in
    ssl2) V="SSLv2.0";;
    ssl3) V="SSLv3.0";;
    tls1) V="TLSv1.0";;
    tls1_1) V="TLSv1.1";;
    tls1_2) V="TLSv1.2";;
    # tls1_3) V="TLSv1.3";;
  esac

  for c in $(openssl ciphers 'ALL:eNULL' | tr ':' ' '); do
    echo -ne " $V :: $c                    \r"
    (echo | openssl s_client $opt -connect $DOMAIN:$PORT -cipher $c -$v > /dev/null 2> /dev/null && echo "|      $c" >> ${tempfile}.$v &)
    i=$(($i+1))
  done;

  if [[ -f ${tempfile}.$v ]]; then
    echo -e "|  $V:\n|    ciphers:" >> $tempfile;
    cat ${tempfile}.$v | sort -r >> $tempfile;
    rm -f ${tempfile}.$v;
  fi

done

if [[ $DOMAIN =~ [a-z] ]]; then I=$(dig +short $DOMAIN | head -1); else I=$DOMAIN; fi
rdns=$(dig +short -x $I)
srv=$(awk "/ $PORT\/tcp/"'{print $2,"("$1")"}' /etc/services)

echo -e "$DOMAIN ($I)                                        "
if [[ -n $rdns ]]; then echo "rDNS for ($I): $rdns"; fi
echo "$srv"

cat $tempfile; echo -e "|_\n"

echo -e "Done: ($i) Ciphers Tested :: ($( grep -E '-' $tempfile | wc -l )) Ciphers Supported\n"
rm -f $tempfile;

