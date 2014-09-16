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

INTERNAL=(
172.17.192.119_r1bs-31.nexcess.net_208.69.120.91
172.17.192.117_r1bs-32.nexcess.net_208.69.120.106
172.17.192.115_r1bs-33.nexcess.net_208.69.120.108
172.17.192.113_r1bs-34.nexcess.net_208.69.120.241
172.17.192.111_r1bs-35.nexcess.net_208.69.120.110
172.17.192.109_r1bs-36.nexcess.net_208.69.120.112
172.17.192.107_r1bs-37.nexcess.net_208.69.120.114
172.17.192.105_r1bs-38.nexcess.net_208.69.120.116
172.17.192.103_r1bs-39.nexcess.net_
172.17.192.101_r1bs-40.nexcess.net_
)
# ^^^ US servers using internal IPs
# Lookup r1bs in lookup table above

_printbackupsvr(){
  if [[ $1 =~ ^172\. ]]; then
    IP=$(for ((i=0;i<${#INTERNAL[@]};i++)); do echo ${INTERNAL[i]} | awk -F_ "/$1/"'{print $3}'; done)
    RDNS=$(for ((i=0;i<${#INTERNAL[@]};i++)); do echo ${INTERNAL[i]} | awk -F_ "/$1/"'{print $2}'; done)
  else
    IP=$1
    RDNS=$(dig +short -x $1 2> /dev/null);
  fi
  echo "R1Soft IP..: https://${IP}:8001";
  if [[ -n $RDNS ]]; then echo "R1Soft rDNS: https://$(echo $RDNS | sed 's/\.$//'):8001"; fi;
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

