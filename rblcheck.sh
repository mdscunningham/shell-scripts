#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-07-14
# Updated: 2015-04-22
#
#
#!/bin/bash

quiet=0
DNSBL=''

if [[ -f multirbl ]]; then
  DNSBL="$(cat multirbl)" # Local
  lineCount=$(wc -l < multirbl)
else
  DNSBL=$(curl -s axeblade.net/multirbl) # Remote
  lineCount=$(curl -s axeblade.net/multirbl | wc -l)
fi

OPTIONS=$(getopt -o "f:hiq" -- "$@") # Execute getopt
eval set -- "$OPTIONS" # Magic
while true; do # Evaluate the options for their options
case $1 in
  -f ) if [[ -e $2 ]]; then
	 lineCount=$(wc -l < $2)
	 DNSBL="$(cat $2)"; shift;
       else
	 echo -e "\n$2 does not exist\n"
       fi ;;
  -i ) if [[ -f rbl-info ]]; then
         lineCount=$(wc -l < rbl-info)
         DNSBL="$(cat rbl-info)"
       else
         lineCount=$(curl -s axeblade.net/rbl-info | wc -l)
         DNSBL=$(curl -s axeblade.net/rbl-info)
       fi ;;
  -q ) quiet=1 ;;
  -- ) shift; break ;; # More Magic
  -h|--help|* ) echo ;; # print help info
esac;
shift;
done

echo -e "\nChecking $lineCount RBLs\n"
for IPADDR in "$@"; do
    count=1
    RDNS=$(dig +short -x $IPADDR)
    echo "----- $IPADDR ----- ${RDNS:-Missing rDNS} -----";
    for RBL in $DNSBL; do
      LOOKUP="$(echo $IPADDR | awk -F. '{print $4"."$3"."$2"."$1}').${RBL}"
      LISTED="$(dig +time=0 +tries=2 +short $LOOKUP | grep -v \;)"
      REASON="$(dig +time=0 +tries=2 +short txt $LOOKUP | grep -v \;)"

      if [[ $quiet == 1 ]]; then
        printf "\r_%-70s _[%-4.2f%%]\r" "${RBL}_" "$(echo "scale=4;${count}/${lineCount}*100.0" | bc)" | sed 's/ /./g;s/_/ /g'
	count=$(($count+1));
      fi

      if [[ $quiet == 1 && $LISTED =~ ^127\. ]]; then
        printf "%-35s : %-11s : %s\n" "$RBL" "${LISTED:-Clean}" "${REASON:------}" >> rbl.log;

      ### Debugging file creation ###
      # elif [[ $quiet == 1 && ! $LISTED =~ ^127\. ]]; then
      #   printf "%-25s : %-11s : %s\n" "$RBL" "${LISTED:-Clean}" "${REASON:------}" >> rbl-debug.log;

      elif [[ $quiet != 1 ]]; then
        printf "%-35s : %-11s : %s\n" "$RBL" "${LISTED:-Clean}" "${REASON:------}";
      fi
    done
    if [[ -f rbl.log && $quiet == 1 ]]; then printf "%90s\r" ""; cat rbl.log; rm rbl.log; fi
    echo
done;
unset count quiet DNSBL lineCount IPADDR RDNS LOOKUP LISTED REASON;
