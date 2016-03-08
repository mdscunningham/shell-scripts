#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2015-03-09
# Updated: 2015-10-08
#
#
#!/bin/bash

###
#
# Based on work by Brian Nelson
#
###

# Taste the rainbow
      BLACK=$(tput setaf 0);        RED=$(tput setaf 1)
      GREEN=$(tput setaf 2);     YELLOW=$(tput setaf 3)
       BLUE=$(tput setaf 4);    PURPLE=$(tput setaf 5)
       CYAN=$(tput setaf 6);	  WHITE=$(tput setaf 7)

     BRIGHT=$(tput bold);        NORMAL=$(tput sgr0)
      BLINK=$(tput blink);	REVERSE=$(tput smso)
  UNDERLINE=$(tput smul)

dash (){ for ((i=1; i<=$1; i++)); do printf "$2"; done; }

mailcheck(){

# Help Output and quit
if [[ $1 =~ -h ]]; then
  echo -e "\n  Usage: mailcheck [options] [<ip1> <ip2> ... | ALL]
    -q ... Quiet (don't print web links)
    -v ... Verbose (print empty swaks results)
    -h ... Print this help
   all ... check all IPs\n";
  return 0;
fi

# Set Quiet Mode for not printing links
if [[ $1 =~ -q ]]; then quiet=1; shift; else quiet=0; fi

# Print out resuts for all the mail hosts regardless of errors
if [[ $1 =~ -v ]]; then verb=1; shift; else verb=0; fi

# What IPs to check
if [[ -z "$@" ]]; then
  ip_list="$(/sbin/ip addr show | awk '/inet / && ($2 !~ /^127\.|^10\.|^172\.|^192\.168\./) {print $2}' | cut -d/ -f1 | head -1)"; # Main IP
elif [[ $1 == 'all' ]]; then
  ip_list="$(/sbin/ip addr show | awk '/inet / && ($2 !~ /^127\.|^10\.|^172\.|^192\.168\./) {print $2}' | cut -d/ -f1)"; # All IPs
else
  ip_list="$@" # List of IPs
fi

for ipaddr in $ip_list; do
  if [[ $quiet == '0' ]]; then
    echo -e "\n$(dash 80 =)\n${WHITE}  Web Based Checks -- ${ipaddr} ${NORMAL}\n$(dash 80 -)"
    rdns="$(dig +short -x $ipaddr)" # Check RDNS
    echo "rDNS/PTR: ${GREEN}${rdns:-${RED}Is not setup ...}${NORMAL}"

    # Web based lookups
    echo "http://multirbl.valli.org/lookup/${YELLOW}${ipaddr}${NORMAL}.html"
    echo "http://www.senderbase.org/lookup/?search_string=${YELLOW}${ipaddr}${NORMAL}"
    echo "http://mxtoolbox.com/SuperTool.aspx?action=blacklist%3a${YELLOW}${ipaddr}${NORMAL}&run=toolpage"
  fi

  # Sanity Check -- Does Swaks exist, if not, install it
  if [[ ! -x /usr/bin/swaks ]]; then wget -q http://jetmore.org/john/code/swaks/latest/swaks -O /usr/bin/swaks; chmod +x /usr/bin/swaks; fi
  echo -e "\n$(dash 80 =)\n${WHITE}  Swaks Based Checks -- ${ipaddr} ${NORMAL}\n$(dash 80 -)"

  # Send test emails with swaks to check for errors
  for domain in aol.com att.net comcast.net earthlink.com gmail.com live.com verizon.net yahoo.com; do
    mx=$(dig mx +short ${domain} | awk 'NR<2 {print $2}')
    if [[ $domain =~ gmail.com ]]; then emailAddress="no-reply@gmail.com"; else emailAddress="postmaster@${domain}"; fi
    result=$(swaks -4 -q RCPT --server $mx -t $emailAddress -li $ipaddr 2>&1 | egrep ' 4[25][01]| 5[257][0-4]';)
    if [[ $verb == "1" || -n $result ]]; then
      printf "\n%-40s  %-40s\n" "${CYAN}Domain:${NORMAL} $domain" "${CYAN}Server:${NORMAL} $mx"
      echo -e "$(dash 80 -)\n${result:-No Reported Errors}";
    fi
  done; echo
done
echo -e "$(dash 80 =)\n"

unset ipaddr rdns result verb quiet cont
}

mailcheck "$@"
