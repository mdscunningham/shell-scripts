#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-18
# Updated: 2014-12-21
#
#
#!/bin/bash

#source colors.sh
dash(){ for ((i=1; i<=$1; i++)); do printf "-"; done; }

domaincheck(){
vhost="$(echo /etc/httpd/conf.d/vhost_[^000]*.conf)"; sub='';

case $1 in
  -a) if [[ -n $2 ]]; then sub=$2; else sub=''; fi
      vhost="$(grep -l $(getusr) /etc/httpd/conf.d/vhost_[^000]*.conf)" ;;
  -r) if [[ -z $2 ]]; then read -p "ResellerID: " r_id; else r_id=$2; fi; echo;
      vhost=$(for r_user in $(nodeworx -unc Siteworx -a listAccounts | awk "(\$5 ~ /^$r_id$/)"'{print $2}'); do grep -l $r_user /etc/httpd/conf.d/vhost_[^000]*.conf; done | sort | uniq) ;;
  -v) FMT=" %-15s  %-15s  %3s  %3s  %3s  %s\n"
      HLT="${BRIGHT}${RED} %-15s  %-15s  %3s  %3s  %3s  %s${NORMAL}\n"
      #printf "$FMT" " Server IP" " Live IP" "SSL" "FPM" "TMP" " Domain"
      #printf "$FMT" "$(dash 15)" "$(dash 15)" "---" "---" "---" "$(dash 44)"
      ;;
esac

FMT=" %-15s  %-15s  %3s  %3s  %s\n"
HLT="${BRIGHT}${RED} %-15s  %-15s  %3s  %3s  %s${NORMAL}\n"
printf "$FMT" " Server IP" " Live IP" "SSL" "FPM" " Domain"
printf "$FMT" "$(dash 15)" "$(dash 15)" "---" "---" "$(dash 44)"

for x in $vhost; do
  D=$(basename $x .conf | cut -d_ -f2);
  V=$(awk '/.irtual.ost/ {print $2}' $x | head -1 | cut -d: -f1);
  I=$(dig +short +time=1 +tries=1 ${sub}$D | grep -E '^[0-9]{1,3}\.' | head -1);
  S=$(if grep :443 $x &> /dev/null; then echo SSL; fi);
  F=$(if grep MAGE_RUN $x &> /dev/null; then echo FIX; fi);
  T=$(if [[ -n $(awk '/.irtual.ost/ {print $3}' $x) ]]; then echo FIX; fi)
  if [[ "$I" != "$V" ]];
  # then printf "$HLT" "$V" "$I" "${S:- - }" "${F:- - }" "${T:- - }" "${sub}$D";
  then printf "$HLT" "$V" "$I" "${S:- - }" "${F:- - }" "${sub}$D";
  # else printf "$FMT" "$V" "$I" "${S:- - }" "${F:- - }" "${T:- - }" "${sub}$D"; fi
  else printf "$FMT" "$V" "$I" "${S:- - }" "${F:- - }" "${sub}$D"; fi
done; echo
}

domaincheck "$@"
