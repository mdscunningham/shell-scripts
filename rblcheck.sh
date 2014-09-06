#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-07-14
# Updated: 2014-07-19
#
#
#!/bin/bash

#search=''; if [[ $1 =~ -g ]]; then search=$2; shift; shift; fi

if [[ -f multirbl ]]; then
  DNSBL="$(cat multirbl)" # Local
  lineCount=$(wc -l < multirbl)
else
  DNSBL=$(curl -s nanobots.robotzombies.net/multirbl) # Remote
  lineCount=$(curl -s nanobots.robotzombies.net/multirbl | wc -l)
fi

if [[ $1 =~ -q ]]; then quiet=1; shift; fi
echo;
for IPADDR in "$@"; do
    count=1
    RDNS=$(dig +short -x $IPADDR)
    echo "----- $IPADDR ----- ${RDNS:-Missing rDNS} -----";
    for RBL in $DNSBL; do
      LOOKUP="$(echo $IPADDR | awk -F. '{print $4"."$3"."$2"."$1}').${RBL}"
      LISTED="$(dig +time=2 +tries=2 +short $LOOKUP | grep -v \;)"
      REASON="$(dig +time=1 +tries=1 +short txt $LOOKUP | grep -v \;)"

      if [[ $quiet == 1 ]]; then
        echo -ne "\r$(echo "scale=4;${count}/${lineCount}*100.0" | bc | sed 's/00$//g')%"; count=$(($count+1));
      fi

      if [[ $quiet == 1 && $LISTED =~ ^127\. ]]; then
        printf "%-25s : %-50s : %-15s : %s\n" "$(date +%Y-%m-%d_%H:%M:%S_%Z)" "${LOOKUP}" "${LISTED:-Clean}" "${REASON:------}" >> rbl.log;
      elif [[ $quiet != 1 ]]; then
        printf "%-25s : %-50s : %-15s : %s\n" "$(date +%Y-%m-%d_%H:%M:%S_%Z)" "${LOOKUP}" "${LISTED:-Clean}" "${REASON:------}";
      fi
    done
    echo
done

if [[ -f rbl.log && $quiet == 1 ]]; then cat rbl.log; echo; rm rbl.log; fi
count=''; quiet=''
