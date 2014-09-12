#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-18
# Updated: 2014-07-28
#
#
#!/bin/bash

#source colors.sh
dash(){ for ((i=1; i<=$1; i++)); do printf "-"; done; }

# echo;
# FORMAT=" %-15s  %-15s  %-3s  %s\n";
# HIGHLIGHT="${BRIGHT}${RED} %-15s  %-15s  %-3s  %s${NORMAL}\n";
# printf "$FORMAT" " ServerIP" " LiveIP" "SSL" " DomainName";
# printf "$FORMAT" "$(dash 15)" "$(dash 15)" "---" "$(dash 44)";
# for x in /etc/httpd/conf.d/vhost_[^000_]*.conf;
# do
#    D=$(basename $x .conf | cut -d_ -f2);
#    I=$(grep -i virtualhost $x 2> /dev/null | head -n1 | awk '{print $2}' | cut -d: -f1);
#    L=$(dig +time=3 +tries=1 +short $D | grep -v \; | head -n1);
#    if grep ':443' $x &> /dev/null; then
#        S="YES";
#    else
#        S="NO";
#    fi;
#    if [[ $I != $L ]]; then
#        printf "$HIGHLIGHT" "$I" "$L" "$S" "$D";
#    else
#        printf "$FORMAT" "$I" "$L" "$S" "$D";
#    fi;
# done;
# echo

#
 echo;
 FMT=" %-15s  %-15s  %3s  %3s  %3s  %s\n"
 HLT="${BRIGHT}${RED} %-15s  %-15s  %3s  %3s  %3s  %s${NORMAL}\n"
 printf "$FMT" " Server IP" " Live IP" "SSL" "FPM" "TMP" " Domain"
 printf "$FMT" "$(dash 15)" "$(dash 15)" "---" "---" "---" "$(dash 44)"

 for x in /etc/httpd/conf.d/vhost_[^000]*.conf; do
   D=$(basename $x .conf | cut -d_ -f2);
   V=$(awk '/.irtual.ost/ {print $2}' $x | head -1 | cut -d: -f1);
   I=$(dig +short +time=1 +tries=1 $D | head -1 | grep -v \;);
   S=$(if grep :443 $x &> /dev/null; then echo SSL; fi);
   F=$(if grep MAGE_RUN $x &> /dev/null; then echo FIX; fi);
   T=$(if [[ -n $(awk '/.irtual.ost/ {print $3}' $x) ]]; then echo FIX; fi)
   if [[ "$I" != "$V" ]];
   then printf "$HLT" "$V" "$I" "${S:- - }" "${F:- - }" "${T:- - }" "$D";
   else printf "$FMT" "$V" "$I" "${S:- - }" "${F:- - }" "${T:- - }" "$D"; fi
 done; echo
#
