#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2015-11-30
# Updated: 2015-12-05
#
# Purpose: Gather IP/DNS/Mail informaion for some or all domains on a server
#

# Taste the rainbow
      BLACK=$(tput setaf 0);        RED=$(tput setaf 1)
      GREEN=$(tput setaf 2);     YELLOW=$(tput setaf 3)
       BLUE=$(tput setaf 4);     PURPLE=$(tput setaf 5)
       CYAN=$(tput setaf 6);      WHITE=$(tput setaf 7)

     BRIGHT=$(tput bold);        NORMAL=$(tput sgr0)
      BLINK=$(tput blink);      REVERSE=$(tput smso)
  UNDERLINE=$(tput smul)

# Setting defaults
recordType="MX"
account=".*"

getusr(){ pwd | sed 's:^/chroot::' | cut -d/ -f3; }

# Parsing input from command line flags
#local OPTIND
while getopts a:d:h option; do
  case "${option}" in
    a) if [[ ${OPTARG} == '.' ]]; then account=$(getusr); else account=${OPTARG}; fi ;;
    d) recordType=${OPTARG};;
    h) echo ;;
  esac
done

# Formatting
FMT="%-15s %-15s %-3s %-6s %-40s %-s\n"
HIGHLIGHT="${BRIGHT}${RED}%-15s %-15s${NORMAL} %-3s %-6s ${BRIGHT}${RED}%-40s${NORMAL} %-s\n"

# Lookup all the domains on the server
domainList=$(awk -F: "/: ${account}/ &&"'!/: nobody/ {print $1}' /etc/userdomains)
#domainList=$(awk '/ServerName/ {print $2}' /usr/local/apache/conf/httpd.conf | sort | uniq)

# Check if mail is configured for remote or local
_remoteLocal(){
  if [[ -n $(grep $1 /etc/localdomains) ]]; then echo "${GREEN}Local${NORMAL} "
    elif [[ -n $(grep $1 /etc/remotedomains) ]]; then echo "${RED}Remote${NORMAL}"
    else echo "${BRIGHT}NoConf${NORMAL}"
  fi
}

printf "\n$FMT" " Vhost-IP" " DNS-IP" "SSL" "MailEx" " Domain" " DNS-${recordType}"
printf "$FMT" "---------------" "---------------" "---" "------" "----------------------------------------" "---------------------------------------------"

# Loop through the list of domains and gather information.
for domain in $domainList; do
  # Find the IP configured in httpd.conf
  vhostIP=$(grep -B5 -E "Server(Name|Alias).*\ $domain" /usr/local/apache/conf/httpd.conf | awk '/<VirtualHost.*:80/ {print $2}' | cut -d: -f1;)

  # Find if there is an SSL installed on the domain
  if [[ $(grep -B5 -E "Server(Name|Alias).*\ $domain" /usr/local/apache/conf/httpd.conf | awk '/<VirtualHost.*:443/ {print $2}' | cut -d: -f1;) ]]; then ssl="${YELLOW}SSL${NORMAL}"; else ssl=""; fi

  # Find the IP resolving in DNS
  dnsIP=$(dig +short +time=1 +tries=1 $domain | grep [0-9] | head -1;)

  # Find the DNS MX record
  dnsRecord=$(dig $recordType +short +time=1 +tries=1 $domain | tail -1;)

  if [[ $vhostIP == $dnsIP ]]; then
    printf "$FMT" "$vhostIP" "$dnsIP" "${ssl:- - }" "$(_remoteLocal $domain)" " $domain" " $dnsRecord"
  else
    printf "$HIGHLIGHT" "$vhostIP" "$dnsIP" "${ssl:- - }" "$(_remoteLocal $domain)" " $domain" " $dnsRecord"
  fi
done; echo
