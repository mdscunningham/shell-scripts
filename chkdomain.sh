#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2015-11-30
# Updated: 2015-12-06
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

# Utility Functions
getusr(){ pwd | sed 's:^/chroot::' | cut -d/ -f3; }
dash(){ for ((i=1; i<=$1; i++)); do printf "-"; done; }

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
FMT="%-15s %-15s %-3s %-6s %-8s %-40s %-s\n"
HIGHLIGHT="${BRIGHT}${RED}%-15s %-15s${NORMAL} %-3s %-6s %-8s ${BRIGHT}${RED}%-40s${NORMAL} %-s\n"

# Lookup all the domains on the server
domainList=$(sed 's/==/: /g' < /etc/userdatadomains | sort -k2 | awk -F: "/: ${account}/"' {print $1}')
#domainList=$(awk -F: "/: ${account}/"' {print $1}' /etc/userdatadomains)
#domainList=$(awk '/ServerName/ {print $2}' /usr/local/apache/conf/httpd.conf | sort | uniq)

# Check if mail is configured for remote or local
_remoteLocal(){
  if [[ -n $(grep $1 /etc/localdomains) ]]; then echo "${GREEN}Local${NORMAL} "
    elif [[ -n $(grep $1 /etc/remotedomains) ]]; then echo "${RED}Remote${NORMAL}"
    else echo "${BRIGHT}NoConf${NORMAL}"
  fi
}

# Printing Column Headers
printf "\n$FMT" " Vhost-IP" " DNS-IP" "SSL" "MailEx" " Type" " Domain" " DocumentRoot"
printf "$FMT" "$(dash 15)" "$(dash 15)" "---" "------" "--------" "$(dash 40)" "$(dash 40)"

# Loop through the list of domains and gather information.
for domain in $domainList; do
  # Find the IP configured in httpd.conf
  vhostIP=$(grep -B5 -E "Server(Name|Alias).*\ $domain" /usr/local/apache/conf/httpd.conf | awk '/<VirtualHost.*:80/ {print $2}' | cut -d: -f1;)

  # Find if there is an SSL installed on the domain
  if [[ -n $(grep -B5 -E "Server(Name|Alias).*\ $domain" /usr/local/apache/conf/httpd.conf | awk '/<VirtualHost.*:443/ {print}') ]]; then ssl="${YELLOW}SSL${NORMAL}"; else ssl=""; fi

  # Find the IP resolving in DNS
  dnsIP=$(dig +short +time=1 +tries=1 $domain | grep [0-9] | head -1;)

  # Find the DNS MX record
  dnsRecord=$(dig $recordType +short +time=1 +tries=1 $domain | tail -1;)

  # Lookup DocRoot in  httpd.conf
  docRoot=$(grep -A5 -E "Server(Name|Alias).*\ $domain" /usr/local/apache/conf/httpd.conf | awk '/DocumentRoot/ {print $2}' | head -1)
  #docRoot=$(sed 's/==/: /g' < /etc/userdatadomains | awk -F: "/^$domain/"'{print $6}')

  # Lookup domain type in /etc/userdatadomains
  domType=$(sed 's/==/: /g' < /etc/userdatadomains | awk -F: "/^$domain/"'{print $4}')

  # Get user/acct from the document root
  acct=$(echo $docRoot | sed 's:^/chroot::' | cut -d/ -f3;)

  if [[ $vhostIP == $dnsIP ]]; then
    printf "$FMT" "$vhostIP" "$dnsIP" "${ssl:- - }" "$(_remoteLocal $domain)" "$domType" "$domain" "$docRoot"
  else
    printf "$HIGHLIGHT" "$vhostIP" "$dnsIP" "${ssl:- - }" "$(_remoteLocal $domain)" "$domType" "$domain" "$docRoot"
  fi
done; echo
