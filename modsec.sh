#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-01-01
# Updated: 2014-07-12
#
#
#!/bin/bash

dash(){ for ((i=1;i<=$1;i++)); do printf "-"; done; }

modsec(){
   if [[ "$1" == '-h' || "$1" == '--help' ]]; then
        echo -e "\n Usage: $FUNCNAME <DOMAIN> [-i|--ip <IPADDR>]\n    If <DOMAIN> is . attempt to get domain from path\n    <IPADDR> can be a full IP address, regex, 'otr', or 'mel'\n";
        return 0;
    fi;
    echo;
    if [[ -z "$1" ]]; then
        read -p "Domain: " D;
        echo;
    else
        if [[ $1 == '.' ]]; then
            D="$(pwd | sed 's:^/chroot::' | cut -d/ -f4)";
        else
            D="$(echo $1 | sed 's/\///g')";
        fi;
    fi;
    if [[ "$2" == '-i' && -z "$3" || "$2" == '--ip' && -z "$3" ]]; then
        read -p "IPaddress: " IP;
        echo;
    else
        if [[ "$3" == 'otr' ]]; then
            IP='208.69.120.120';
        else
            if [[ "$3" == 'mel' ]]; then
                IP="192.240.191.2";
            else
                IP="$3";
            fi;
        fi;
    fi;
    FORMAT="%-8s %-9s %s\n";
    printf "$FORMAT" " Count#" " Error#" " IP-Address";
    printf "$FORMAT" "--------" "---------" "$(dash 17)";
    if grep -qEi '\[id: [0-9]{6,}\]' /home/*/var/$D/logs/error.log; then
      grep -Eio "client.$IP.*\] |id.*[0-9]{6,}\]" /home/*/var/$D/logs/error.log | awk 'BEGIN {RS="]\nc"} {print $4,$2}'\
	 | tr -d \] | sort | uniq -c | awk '{printf "%7s   %-8s  %s\n",$1,$2,$3}'
    else
      grep -Eio "client.$IP.*id..[0-9]{6,}\"" /home/*/var/$D/logs/error.log | awk '{print $NF,$2}'\
	 | sort | uniq -c | tr -d \" | tr -d \] | awk '{printf "%7s   %-8s  %s\n",$1,$2,$3}';
    fi
    echo
}
modsec "$@"
