#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2017-02-28
# Updated: 2017-03-01
#
# Purpose: Send an alert if the SSL on a domain is going to expire
#

domain=domain.com
email=username@domain.com

connect=$(echo | openssl s_client -connect ${domain}:443 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null)

if [[ $connect =~ notAfter ]]; then

  end=$(echo $connect | cut -d= -f2);
  d1=$(date +%s);
  d2=$(date -d "$end" +%s);
  datediff=$(( (d2 - d1) / 86400 ))

  if [[ $datediff -le 30 ]]; then

    echo "

The SSL currently installed on $domain will expire in $datediff days. Please rewnew this in Manage
(https://manage.liquidweb.com/manage/ssl/) or contact support@liquidweb.com so we can assist.

You can find more information about this process here:
https://support.liquidweb.com/hc/en-us/search?query=renew+ssl

" | mail -s "SSL on $domain will expire in $datediff days" $email;

  fi

fi
