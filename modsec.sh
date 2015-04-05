#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-01-01
# Updated: 2015-04-02
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

    if [[ $1 == "-n" ]]; then count="$2"; shift; else count="10"; fi

    # if [[ $1 == '.' ]]; then D="$(pwd | sed 's:^/chroot::' | cut -d/ -f4)";
    # else D="$(echo $1 | sed 's/\///g')"; fi;

    if [[ "$1" == '-i' && -z "$2" || "$1" == '--ip' && -z "$2" ]]; then
        read -p "IPaddress: " IP; echo;
    else IP="$2"; shift; fi;

    FORMAT="%-8s %-9s %s\n";
    printf "$FORMAT" " Count#" " Error#" " IP-Address";
    printf "$FORMAT" "--------" "---------" "$(dash 17)";
    if grep -qEi '\[id: [0-9]{6,}\]' /usr/local/apache/logs/error_log; then
      grep -Eio "client.$IP.*\] |id.*[0-9]{6,}\]" /usr/local/apache/logs/error_log | awk 'BEGIN {RS="]\nc"} {print $4,$2}'\
	 | tr -d \] | sort | uniq -c | awk '{printf "%7s   %-8s  %s\n",$1,$2,$3}' | sort -rnk1 | head -n $count;
    else
      grep -Eio "client.$IP.*id..[0-9]{6,}\"" /usr/local/apache/logs/error_log | awk '{print $NF,$2}'\
	 | sort | uniq -c | tr -d \" | tr -d \] | awk '{printf "%7s   %-8s  %s\n",$1,$2,$3}' | sort -rnk1 | head -n $count;
    fi
    echo
}
modsec "$@"
