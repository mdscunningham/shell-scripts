#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-15
# Updated: 2014-05-04
#
#
#!/bin/bash

## Traffic stats / information (collection of Apache one-liners)
# http://www.the-art-of-web.com/system/logs/

_trafficUsage(){
echo " Usage: traffic <DOMAIN> [option] [top#] [-d <day>]
    ua .... Top User Agents by # of hits
    bot ... Top User Agents identifying as bots by # of hits
    scr ... Top empty User Agents (likely scripts) by # of hits
    ip[h] . Top IPs or [h]osts by # of hits
    bw[h] . Top IPs or [h]osts by bandwidth usage
    ref ... Top Referrers by # of hits
    sum ... Summary of response codes and user agents for top ips
    url ... Top URLs by # of hits
    hr .... # of hits per hour
    gr .... # of hits per hour with visual graph

    Top# can be ommitted. If ommitted assumes 20 results
    When specifying day with the -d, do not use leading zero

 Usage: traffic <DOMAIN> [option] <day> <hour>
    min ... Hits per min during some range
    code .. Response Codes (per Day/Hour/Min)

    Day and Hour fields can be '##' 'regex' or 'all'
    Domain field can be . to find the domain from the PWD"
    return 0;
}

DAY=''; SUFFIX=''; opt=$2; DECOMP='cat';

if [[ $1 == "." ]]; then D="$(pwd | sed 's:^/chroot::' | cut -d/ -f4)"; else D="$1"; fi

DIR=$PWD; echo;
cd /home/*/$D 2> /dev/null && cd ../;

if [[ -z "$3" || $3 == '-d' ]]; then TOP="20"; else TOP="$3"; fi

if [[ -z "$4" ]]; then
	DECOMP='cat'; HEADER=0; DAY=$(date +%d)
elif [[ $3 == '-d' ]]; then
	DAY=$4; DECOMP='zcat -f'; SUFFIX="-*[${DAY},$(($DAY+1))]20*.zip"; HEADER=1;
elif [[ $4 == '-d' ]]; then
	DAY=$5; DECOMP='zcat -f'; SUFFIX="-*[${DAY},$(($DAY+1))]20*.zip"; HEADER=1;
fi;

if [[ -n $SUFFIX ]]; then LOGFILE="var/$D/logs/transfer.log${SUFFIX}"; else LOGFILE=''; fi
CRNTLOG="var/$D/logs/transfer.log"

if [[ $HEADER == 1 ]]; then echo -e "$(ls /home/*/$LOGFILE)\n$(ls /home/*/$CRNTLOG)\n"; fi

case $opt in

ua|agent )
	$DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}"\
	 | awk -F\" '{freq[$6]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
	 | sort -rn | head -n$TOP
;;

bot|bots )
	$DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}"\
	 | awk -F\" '($6 ~ /bot|crawler|spider/) {freq[$6]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
	 | sort -rn | head -n$TOP
;;

scr|scripts )
	$DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}"\
	 | awk -F\" '($6 ~ /^-?$/) {print $1}' | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
	 | sort -rn | head -n$TOP
;;

ip|ips )
	$DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}"\
	 | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
	 | sort -rn | head -n$TOP
;;

iph )
	$DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}"\
	 | logresolve | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
	 | sort -rn | head -n$TOP
;;

bw|bandwidth )
	$DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}"\
	 | awk '{tx[$1]+=$10} END {for (x in tx) {printf "   %-15s   %8s M\n",x,(tx[x]/1024000)}}'\
	 | sort -k 2n | tail -n$TOP | tac
;;

bwh )
	$DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}"\
	 | logresolve | awk '{tx[$1]+=$10} END {for (x in tx) {printf "   %-15s   %8s M\n",x,(tx[x]/1024000M)}}'\
	 | sort -k 2n | tail -n$TOP | tac
;;

hr|hour )
	for x in $(seq -w 0 23); do echo -n "${x}:00  ";
		$DECOMP $LOGFILE $CRNTLOG | grep -Ec "${DAY}/.*/[0-9]{4}:$x:";
	done
;;

gr|graph )
	for x in $(seq -w 0 23); do echo -n "${x}:00  ";
		count=$($DECOMP $LOGFILE $CRNTLOG | grep -Ec "${DAY}/.*/[0-9]{4}:$x:");
		printf "%7s %s\n" "$count" "$(dash $(($count/1000)))";
	done
;;

ref|refs )
	$DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}"\
	 | awk '{freq[$11]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
	 | tr -d \" | sort -rn | head -n$TOP
;;

url|urls )
	$DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}"\
	 | awk '{freq[$7]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
	 | sort -rn | head -n$TOP
;;

sum|summary )
	for x in $($DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}" | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP | awk '{print $2}'); do
		echo $x; $DECOMP $LOGFILE $CRNTLOG | grep -E "$DAY/.*/[0-9]{4}" | grep $x | cut -d' ' -f9,12- | sort | uniq -c | sort -nr | head -n$TOP | tr -d \"; echo;
	done
;;

code|res )
	DAY="$3"; HOUR="$4";
	if [[ $3 == "all" ]]; then DAY='[0-9]{2}'; fi;
	if [[ $4 == "all" ]]; then HOUR='[0-9]{2}'; fi;
	if [[ -z $DAY ]]; then
		zgrep -Eh "$DAY/.*/[0-9]{4}:$HOUR" var/$D/logs/transfer.log*\
		| awk '{print $4":"$9}' | awk -F: '{print $1,$5}' | sort | uniq -c | tr -d \[;
	elif [[ -n $DAY && -z $HOUR ]]; then
		zgrep -E -h "$DAY/.*/[0-9]{4}:$HOUR" var/$D/logs/transfer.log*\
		| awk '{print $4":"$9}' | awk -F: '{print $1,$2":00",$5}' | sort | uniq -c | tr -d \[;
	else
		zgrep -Eh "$DAY/.*/[0-9]{4}:$HOUR" var/$D/logs/transfer.log*\
		| awk '{print $4":"$9}' | awk -F: '{print $1,$2":"$3,$5}' | sort | uniq -c | tr -d \[;
	fi
;;

m|min )
	DAY="$3"; HOUR="$4";
	if [[ $3 == "all" ]]; then DAY='[0-9]{2}'; fi;
	if [[ $4 == "all" ]]; then HOUR='[0-9]{2}'; fi;
      	zgrep -Eh "$DAY/.*/[0-9]{4}:$HOUR" var/$D/logs/transfer.log*\
	| awk '{print $4}' | awk -F: '{print $1" "$2":"$3}' | sort | uniq -c | tr -d \[
;;

-h|--help|* ) _trafficUsage ;;

esac

echo; cd $DIR
