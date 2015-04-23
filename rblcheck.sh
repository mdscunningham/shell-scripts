#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-07-14
# Updated: 2015-04-22
#
#
#!/bin/bash

if [[ -f multirbl ]]; then
  DNSBL="$(cat multirbl)" # Local
  lineCount=$(wc -l < multirbl)
else
  DNSBL=$(curl -s axeblade.net/multirbl) # Remote
  lineCount=$(curl -s axeblade.net/multirbl | wc -l)
fi

if [[ $1 =~ -q ]]; then quiet=1; shift; fi
echo;
for IPADDR in "$@"; do
    count=1
    RDNS=$(dig +short -x $IPADDR)
    echo "----- $IPADDR ----- ${RDNS:-Missing rDNS} -----";
    for RBL in $DNSBL; do
      LOOKUP="$(echo $IPADDR | awk -F. '{print $4"."$3"."$2"."$1}').${RBL}"
      LISTED="$(dig +time=0 +tries=1 +short $LOOKUP | grep -v \;)"
      REASON="$(dig +time=0 +tries=1 +short txt $LOOKUP | grep -v \;)"

      if [[ $quiet == 1 ]]; then
        echo -ne "\r$(echo "scale=4;${count}/${lineCount}*100.0" | bc | sed 's/00$//g')%"; count=$(($count+1));
      fi

      if [[ $quiet == 1 && $LISTED =~ ^127\. ]]; then
        printf "%-40s : %-10s : %s\n" "${LOOKUP}" "${LISTED:-Clean}" "${REASON:------}" >> rbl.log;

      ### Debugging file creation ###
      # elif [[ $quiet == 1 && ! $LISTED =~ ^127\. ]]; then
      #   printf "%-40s : %-10s : %s\n" "${LOOKUP}" "${LISTED:-Clean}" "${REASON:------}" >> rbl-debug.log;

      elif [[ $quiet != 1 ]]; then
        printf "%-50s : %-10s : %s\n" "${LOOKUP}" "${LISTED:-Clean}" "${REASON:------}";
      fi
    done
    echo -ne "\r"
    if [[ -f rbl.log && $quiet == 1 ]]; then cat rbl.log; echo; rm rbl.log; fi
done
unset count quiet DNSBL lineCount IPADDR RDNS LOOKUP LISTED REASON;
