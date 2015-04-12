#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-01-01
# Updated: 2015-04-10
#
#
#!/bin/bash

dash(){ for ((i=1;i<=$1;i++)); do printf "-"; done; }

modsec(){
   if [[ "$1" == '-h' || "$1" == '--help' ]]; then
        echo -e "\n Usage: $FUNCNAME [-d <DOMAIN>] [-n <linecount>] [-i|--ip <IPADDR>]\n\n    If <DOMAIN> is . attempt to get domain from path\n    <IPADDR> can be a full IP address, or regex\n";
        return 0;
    fi;

    echo;
    if [[ $1 == '-d' && $2 == '.' ]]; then DOMAIN=$(grep -B5 "DocumentRoot $PWD$" /usr/local/apache/conf/httpd.conf | awk '/ServerName/ {print $2}' | head -1); shift; shift;
       elif [[ $1 == '-d' && -n $2 ]]; then DOMAIN=$(echo $2 | sed 's:/$::'); shift; shift; fi

    if [[ $1 == '-n' ]]; then count="$2"; shift; shift; else count="10"; fi

    if [[ $1 == '-i' ]]; then IP="$2"; shift; shift; fi;

    LOGFILE="/usr/local/apache/logs/error_log"
    FORMAT="%-8s %-9s %-16s %-16s\n";

    if [[ $1 == '-v' ]]; then
      printf "$FORMAT" " Count#" " Error#" " Remote-IP" " Local-IP/Host";
      printf "$FORMAT" "--------" "---------" "$(dash 16)" "$(dash 16)";
      grep -E "client.$IP.*id..[0-9]{6,}\"" $LOGFILE\
	 | perl -pe 's/.*client\ (.*?)\].*id "([0-9]{6,})".*hostname "(.*?)".*/\2 \1 \3/'\
	 | sort | uniq -c | sort -rn | awk '{printf "%7s   %-8s  %-16s %s\n",$1,$2,$3,$4}' | head -n $count
    else
      printf "$FORMAT" " Count#" " Error#" " Remote-IP";
      printf "$FORMAT" "--------" "---------" "$(dash 16)";
      if grep -qEi '\[id: [0-9]{6,}\]' $LOGFILE; then
        grep -Eio "client.$IP.*\] |id.*[0-9]{6,}\]" $LOGFILE | awk 'BEGIN {RS="]\nc"} {print $4,$2}'\
	 | tr -d \] | sort | uniq -c | awk '{printf "%7s   %-8s  %s\n",$1,$2,$3}' | sort -rnk1 | head -n $count;
      else
        grep -Eio "client.$IP.*id..[0-9]{6,}\"" $LOGFILE | awk '{print $NF,$2}'\
	 | sort | uniq -c | tr -d \" | tr -d \] | awk '{printf "%7s   %-8s  %s\n",$1,$2,$3}' | sort -rnk1 | head -n $count;
      fi
    fi

    echo
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

####
#
# Example ModSec error for reference
#
# [Wed Apr 08 17:19:04.315431 2015] [:error] [pid 15280:tid 140008266651392] [client 91.217.90.49] ModSecurity: Warning. Match of "pm AppleWebKit Android" against "REQUEST_HEADERS:User-Agent" required.
# [file "/usr/local/apache/conf/modsec_vendor_configs/OWASP/rules/REQUEST-20-PROTOCOL-ENFORCEMENT.conf"] [line "299"] [id "960015"] [rev "3"] [msg "Request Missing an Accept Header"] [severity "NOTICE"]
# [ver "OWASP_CRS/3.0.0"] [maturity "9"] [accuracy "8"] [tag "Host: 69.167.152.157"] [tag "OWASP_CRS/PROTOCOL_VIOLATION/MISSING_HEADER_ACCEPT"] [tag "WASCTC/WASC-21"] [tag "OWASP_TOP_10/A7"] [tag "PCI/6.5.10"]
# [hostname "69.167.152.157"] [uri "/rom-0"] [unique_id "VSWbSEWnmJ0AADuwZSgAAAAD"]
#
###
