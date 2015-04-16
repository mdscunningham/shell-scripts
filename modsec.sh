#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-01-01
# Updated: 2015-04-15
#
#
#!/bin/bash

dash(){ for ((i=1;i<=$1;i++)); do printf "-"; done; }

    QUIET=0;VERBOSE=0;COUNT=20;DATE="$(date +'%a.%b.%d')";LOGFILE="/usr/local/apache/logs/error_log" # Initialization

modsec(){
    local OPTIND
    while getopts d:hi:l:n:qv option; do
      case "${option}" in
        q) QUIET=1 ;;
        v) VERBOSE=1 ;;
	d) DATE=$(date --date="-${OPTARG} days" +"%a.%b.%d") ;;
        i) IP=${OPTARG} ;;
	l) LOGFILE=${OPTARG} ;;
        n) COUNT=${OPTARG} ;;
        h) echo -e "\n Usage: $0 [OPTIONS]\n
    -d ... <days ago> (1-9...) otherwise assumes today
    -h ... display this help output and quit
    -i ... <ipaddress> (can be full IP or regex)
    -l ... <logfile> (set alternate log file)
    -n ... <linecount> (number of results to print)
    -q ... quiet, don't print error message\n";
    -v ... verbose debugging output
        return 0 ;;
      esac
    done

    echo; FORMAT="%-8s %-9s %-16s %-16s\n";

    if [[ $QUIET != 1 ]]; then
      printf "$FORMAT" " Count#" " Error#" " Remote-IP" " Error Message";
      printf "$FORMAT" "--------" "---------" "$(dash 16)" "$(dash 42)";
      grep -Ei "$DATE.*client.$IP.*id..[0-9]{6,}\"" $LOGFILE\
	 | perl -pe 's/.*client\ (.*?)\].*id "([0-9]{6,})".*msg "(.*?)".*/\2\t\1\t\3/' | sed 's/ /_/g'\
	 | sort | uniq -c | sort -rn | awk '{printf "%7s   %-8s  %-16s %s\n",$1,$2,$3,$4}' | sed 's/_/ /g' | head -n $COUNT
    else
      printf "$FORMAT" " Count#" " Error#" " Remote-IP";
      printf "$FORMAT" "--------" "---------" "$(dash 16)";
      if grep -qEi '\[id: [0-9]{6,}\]' $LOGFILE; then
        grep -Eio "$DATE.*client.$IP.*\] |id.*[0-9]{6,}\]" $LOGFILE | awk 'BEGIN {RS="]\nc"} {print $4,$2}'\
	 | tr -d \] | sort | uniq -c | awk '{printf "%7s   %-8s  %s\n",$1,$2,$3}' | sort -rnk1 | head -n $COUNT;
      else
        grep -Eio "$DATE.*client.$IP.*id..[0-9]{6,}\"" $LOGFILE | perl -pe 's/.*client\ (.*?)\].*id "([0-9]{6,})".*/\2\t\1/'\
	 | sort | uniq -c | tr -d \" | tr -d \] | awk '{printf "%7s   %-8s  %s\n",$1,$2,$3}' | sort -rnk1 | head -n $COUNT;
      fi
    fi
    echo

    if [[ $VERBOSE == 1 ]]; then
      echo -e "LOGFILE: $LOGFILE\nDATE   : $DATE\nCOUNT  : $COUNT\nIP     : $IP\n"; fi
}
modsec "$@"

###
#
# http://stackoverflow.com/questions/1103149/non-greedy-regex-matching-in-sed
#
# So apparently the easy way to do this without having to be very very specific with the regex in 'sed'
# is to use 'perl -pe' this allows for 'non-greedy' regex and grab just the bits I want from the error
#
# perl -pe 's/.*client\ (.*?)\].*id "([0-9]{6,})".*hostname "(.*?)".*/\2 \3 \1/'
# ^^ Solution to replace really long sed command
#
####
