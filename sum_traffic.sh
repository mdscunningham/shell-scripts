#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2014-04-18
# Updated: 2015-03-31
#
#
#!/bin/bash

## COLORS: Taste the Rainbow
      BLACK=$(tput setaf 0);        RED=$(tput setaf 1)
      GREEN=$(tput setaf 2);     YELLOW=$(tput setaf 3)
       BLUE=$(tput setaf 4);     PURPLE=$(tput setaf 5)
       CYAN=$(tput setaf 6);	  WHITE=$(tput setaf 7)
     BRIGHT=$(tput bold);        NORMAL=$(tput sgr0)
      BLINK=$(tput blink);	REVERSE=$(tput smso)
  UNDERLINE=$(tput smul);

## Add extended globbing
shopt -s extglob

## Initializations
hourtotal=($(for ((i=0;i<23;i++)); do echo 0; done))
grandtotal=0
nocolor=0
DECOMP="$(which grep)"
DATE="$(date +%d/%b/%Y)"
DOMAINS="/usr/local/apache/domlogs/*/*[^_log$]"
THRESH=''
RANGE=$(seq -w 0 23); TRANGE=$(seq 0 23)
FMT=" %5s"

while getopts d:l:nr:t:vh option; do
    case "${option}" in
	# Caclulate date string for searches
        d) DATE=$(date --date="-${OPTARG} days"  +%d/%b/%Y) ;;

	# Use list of domains rather than all sites
        l) DOMAINS="$(for x in $(echo ${OPTARG} | sed 's/,/ /g'); do echo /usr/local/apache/domlogs/*/$x; done)" ;;

	# Print w/o color in b/w
	n) nocolor=1 ;;

	# Print only a specified range of hours
	r) INPUT=$(echo ${OPTARG} | sed 's/,/ /g'); RANGE=$(seq -w $INPUT); TRANGE=$(seq $INPUT); FMT=" %8s";;

	# Threshold for printing only busy sites
        t) THRESH=${OPTARG} ;;

	# Verbose outpout for debugging
	v) echo -e "\nDecomp   : $DECOMP\nDate     : $DATE\nDomains  : $DOMAINS\nThreshold: $THRESH" ;;

	# Help output
	h) echo -e "\n ${BRIGHT}Usage:${NORMAL} $0 [OPTIONS]\n
    -d ... days-ago <##>
    -h ... Print this help and quit
    -l ... list of domains <dom1,dom2,...>
    -n ... No Color (for output to files)
    -r ... Range of hours <start#,end#>
    -t ... threshold value <#####>
    -v ... Verbose (debugging output)\n"; exit ;;
    esac
done; echo

## Header
printf "${BRIGHT} %15s" "User/Hour";
for hour in $RANGE; do printf "$FMT" "$hour:00"; done;
printf "%8s %-s${NORMAL}\n" "Total" " Domain Name"

## Data gathering and display
for logfile in $DOMAINS; do
        total=0; i=0;

    # Only print if the threshold condition is set/met
    if [[ -z $THRESH || $THRESH -le $($DECOMP -c $DATE $logfile) ]]; then
        if [[ $nocolor != '1' ]]; then color="${BLUE}"; else color=''; fi
        printf "${color} %15s" "$(echo $logfile | cut -d/ -f6)"

	# Iterate through the hours
        for hour in $RANGE; do
                count=$($DECOMP -c "$DATE:$hour:" $logfile);
                hourtotal[$i]=$((${hourtotal[$i]}+$count))

                if [[ $nocolor != '1' ]]; then ## COLOR VERSION (HEAT MAP)
                    if [[ $count -gt 20000 ]]; then color="${BRIGHT}${RED}";
                    elif [[ $count -gt 2000 ]]; then color="${RED}";
                    elif [[ $count -gt 200 ]]; then color="${YELLOW}";
                    else color="${GREEN}"; fi
                else color=''; fi

                printf "${color}$FMT${NORMAL}" "$count"
                total=$((${total}+${count})); i=$(($i+1))
        done
        grandtotal=$(($grandtotal+$total))

        if [[ $nocolor != '1' ]]; then ## Color version
          printf "${CYAN}%8s ${PURPLE}%-s${NORMAL}\n" "$total" "$(echo $logfile | cut -d/ -f7)"
        else printf "%8s %-s\n" "$total" "$(echo $logfile | cut -d/ -f7)"; fi
    fi
done

## Footer
printf "${BRIGHT} %15s" "Total"
for i in $TRANGE; do printf "$FMT" "${hourtotal[$i]}"; done
printf "%8s %-s${NORMAL}\n" "$grandtotal" "<< Grand Total"
echo
