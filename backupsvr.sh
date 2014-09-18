#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-21
# Updated: 2014-09-16
#
#
#!/bin/bash

checkquota;
NEW_IPADDR=$(awk -F/ '/server.allow/ {print $NF}' /usr/sbin/r1soft/log/cdp.log | tail -1 | tr -d \' | sed 's/10\.17\./178\.17\./g; s/10\.1\./103\.1\./g; s/10\.240\./192\.240\./g');
ALL_IPADDR=$(awk -F/ '/server.allow/ {print $NF}' /usr/sbin/r1soft/log/cdp.log | sort | uniq | tr -d \' | sed 's/10\.17\./178\.17\./g; s/10\.1\./103\.1\./g; s/10\.240\./192\.240\./g');
# ^^^
# 10.17.x.x  --> 178.17.x.x  -- UK Servers
# 10.1.x.x   --> 103.1.x.x   -- AU Servers
# 10.240.x.x --> 192.240.x.x -- MIA Servers

if [[ $NEW_IPADDR =~ ^172\. ]]; then INTERNAL=$(curl -s nanobots.robotzombies.net/r1bs-internal); fi

# ^^^ US servers using internal IPs -- Lookup r1bs in lookup table above
# 172.x.x.x  --> Internal IP for US servers

_printbackupsvr(){
  if [[ $1 =~ ^172\. ]]; then
    for x in $INTERNAL; do echo -n $x | awk -F_ "/$1/"'{printf "R1Soft IP..: https://"$3":8001\n" "R1Soft rDNS: https://"$2":8001\n"}'; done
  else
    IP=$1; RDNS=$(dig +short -x $1 2> /dev/null);
    echo "R1Soft IP..: https://${IP}:8001";
    if [[ -n $RDNS ]]; then echo "R1Soft rDNS: https://$(echo $RDNS | sed 's/\.$//'):8001"; fi;
  fi
  echo
}

FIRSTSEEN=$(grep $(echo $NEW_IPADDR | cut -d. -f2-) /usr/sbin/r1soft/log/cdp.log | head -1 | awk '{print $1}');
echo "----- Current R1Soft Server ----- $FIRSTSEEN] $(dash 32)";
_printbackupsvr $NEW_IPADDR

for IPADDR in $ALL_IPADDR;
do
  if [[ $IPADDR != $NEW_IPADDR ]]; then
    LASTSEEN=$(grep $(echo $IPADDR | cut -d. -f2-) /usr/sbin/r1soft/log/cdp.log | tail -1 | awk '{print $1}');
    echo "----- Previous R1Soft Server ----- $LASTSEEN] $(dash 31)";
    _printbackupsvr $IPADDR
  fi;
done

