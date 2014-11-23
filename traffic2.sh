#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-10
# Updated: 2014-11-21
#
#
#!/bin/bash

_trafficUsage(){
echo " Usage: traffic DOMAIN COMMAND [OPTIONS]

 Commands:
    ua | useragent . Top User Agents by # of hits
   bot | robots .... Top User Agents identifying as bots by # of hits
   scr | scripts.... Top empty User Agents (likely scripts) by # of hits
    ip | ipaddress . Top IPs by # of hits
    bw | bandwidth . Top IPs by bandwidth usage
   bwt | bwtotal ... Total bandwidth used for a given day
   url | file ...... Top URLs/files by # of hits
   ref | referrer .. Top Referrers by # of hits
  type | request ... Summary of request types (GET/HEAD/POST)
   sum | summary ... Summary of response codes and user agents for top ips
    hr | hour ...... # of hits per hour
    gr | graph ..... # of hits per hour with visual graph
   min | minute .... Hits per min during some range
  code | response .. Response Codes (per Day/Hour/Min)
     s | search .... Only search the log for -s 'search string'
                     This does not have a line limit (ignores -n)

 Options:
    -s | --search .. Search \"string\" (executed before analysis)
                     For a timeframe use 'YYYY:HH:MM:SS' or 'regex'
    -d | --days .... Days before today (1..7) (historical logs)
    -n | --lines ... Number of results to print to the screen
    -h | --help .... Print this help and exit

 Notes:
    DOMAIN can be '.' to find the domain from the PWD"; return 0;
}

_trafficDash(){ for ((i=1;i<=$1;i++));do printf '#'; done; }

# Check how the domain is specified.
if [[ $1 == '.' ]]; then DOMAIN=$(pwd | sed 's:^/chroot::' | cut -d/ -f4); shift;
  else DOMAIN=$(echo $1 | sed 's:/$::'); shift; fi

opt=$1; shift; # Set option variable using command parameter
SEARCH=''; DATE=''; TOP='20'; TIME=''; DECOMP='egrep'; VERBOSE=0; # Initialize variables
OPTIONS=$(getopt -o "s:d:n:hv" --long "search:,days:,lines:,help,verbose" -- "$@") # Execute getopt
eval set -- "$OPTIONS" # Magic

while true; do # Evaluate the options for their options
case $1 in
  -s|--search ) SEARCH="$2"; shift ;; # search string (regex)
  -d|--days   ) DATE="-$(date --date="-$((${2}-1)) day" +%m%d%Y).zip"; DECOMP='zegrep'; shift ;; # days back
  -n|--lines  ) TOP=$2; shift ;; # results
  -v|--verbose) VERBOSE=1 ;; # Debugging Output
  --          ) shift; break ;; # More Magic
  -h|--help|* ) _trafficUsage; return 0 ;; # print help info
esac;
shift;
done

#if [[ $(hostname) =~ (.*-node|.*-fs|.*-lb) ]]; then
#  echo -e "\nRunning in Cluster Mode ... on $(hostname):"
#  LOGFILE="/var/log/interworx/${DOMAIN}/logs/transfer.log${DATE}"
#  if [[ ! -f $LOGFILE ]]; then echo "Couldn't find the log file, try running this from one of the nodes."; fi
#else LOGFILE="/home/*/var/${DOMAIN}/logs/transfer.log${DATE}"; fi

VHOST="/etc/httpd/conf.d/vhost_${DOMAIN}.conf"
LOGFILE="$(awk '/CustomLog/ {print $2}' $VHOST | head -n1)${DATE}"
if [[ ! -f $VHOST ]]; then
   echo "Could not find vhost file for ${DOMAIN}"
elif [[ ! -f $LOGFILE ]]; then
   echo "Could not find log file for ${DOMAIN}"
fi

echo
case $opt in

ua|useragent	) $DECOMP "$SEARCH" $LOGFILE | awk -F\" '{freq[$6]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP ;;

bot|robots	) $DECOMP "$SEARCH" $LOGFILE | awk -F\" '($6 ~ /[Bb]ot|[Cc]rawler|[Ss]pider/) {freq[$6]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP ;;

scr|scripts	) $DECOMP "$SEARCH" $LOGFILE | awk -F\" '($6 ~ /^-?$/) {print $1}' | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP ;;

ip|ipaddress	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP ;;

bw|bandwidth	) $DECOMP "$SEARCH" $LOGFILE | awk '{tx[$1]+=$10} END {for (x in tx) {printf "   %-15s   %8s M\n",x,(tx[x]/1024000)}}' | sort -k 2n | tail -n$TOP | tac ;;

bwt|bwtotal     ) $DECOMP "$SEARCH" $LOGFILE | awk '{tx+=$10} END {print (tx/1024000)"M"}' ;;

sum|summary	) for x in $($DECOMP "$SEARCH" $LOGFILE | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP | awk '{print $2}'); do
		  echo $x; $DECOMP "$SEARCH" $LOGFILE | grep $x | cut -d' ' -f9,12- | sort | uniq -c | sort -rn | head -n$TOP | tr -d \"; echo; done ;;

s|search	) $DECOMP "$SEARCH" $LOGFILE ;;

hr|hour 	) for x in $(seq -w 0 23); do echo -n "${x}:00 "; $DECOMP "$SEARCH" $LOGFILE | egrep -c "/[0-9]{4}:$x:"; done ;;

gr|graph	) for x in $(seq -w 0 23); do echo -n "${x}:00"; count=$($DECOMP "$SEARCH" $LOGFILE | egrep -c "/[0-9]{4}:$x:");
		  printf "%8s |%s\n" "$count" "$(_trafficDash $(($count/500)))"; done;;

min|minute	) $DECOMP "$SEARCH" $LOGFILE | awk '{print $4}' | awk -F: '{print $1" "$2":"$3}' | sort | uniq -c | tr -d \[ ;;

type|request	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$6]++} END {for (x in freq) {print x,freq[x]}}' | tr -d \" | sed 's/-/TIMEOUT/' | column -t ;;

code|response	) $DECOMP "$SEARCH" $LOGFILE | awk '{print $4":"$9}' | awk -F: '{print $1,$5}' | sort | uniq -c | tr -d \[ ;;

url|file	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$7]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP ;;

ref|referrer	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$11]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | tr -d \" | sort -rn | head -n$TOP ;;

-h|--help|*) _trafficUsage ;;

esac

if [[ $VERBOSE == '1' ]]; then echo; echo -e "DECOMP: $DECOMP\nSEARCH: $SEARCH\nDATE: $DATE\nTOP: $TOP\nLOGFILE: $LOGFILE\n" | column -t; fi # Debugging

echo;
unset DOMAIN SEARCH DATE TOP LOGFILE DECOMP VERBOSE # Variable Cleanup
