#!/bin/bash
#							   +----+----+----+----+
# 							   |    |    |    |    |
# Orignal Author: Mark David Scott Cunningham		   | M  | D  | S  | C  |
# Updated By: CJ Saathoff				   |    |    |    |    |
#							   +----+----+----+----+
# Changelog
# Since the orignal script mark wrote I (CJ) have added:
# * wildcard detection
# * commom hostname lookup (only if a wildcard isn't detected)
# * Zone transfer check
#
# Created: 2014-03-20
# Updated: 2020-04-22
#
#
# Purpose: Quick DNS Summary for domain to confirm server/mail/rdns/ns/etc

dash (){ for ((i=1; i<=$1; i++)); do printf "-"; done; }
OPTS="+time=2 +tries=2 +short +noshort"
OPTS2="+time=2 +tries=2 +short"
localns=$(awk '/nameserver/ {print $2}' /etc/resolv.conf | head -1)
all=''
fullwhois=''
nameserver=''
verbose=''
bold=$(tput bold)
normal=$(tput sgr0)
random_subdomain=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Argument parsing with getopt
OPTIONS=$(getopt -o "an:vwh" -- "$@")
eval set -- "$OPTIONS"
while true; do
  case $1 in
    -a) all=1 ;;
    -n) nameserver=$(echo $2 | sed "s/^\(.\)/@\1/g;s/,/ @/g"); shift ;;
    -v) verbose=1 ;;
    -w) fullwhois=1 ;;
    --) shift; break ;;
    -h) echo -e "\n  Usage: $0 [options] [arguments]
    -a ... Check DNS records at default list of resolvers
    -n ... <ns1,ns2,ns3...> to use for DNS records lookups
    -v ... Lookup DNS records and Whois Nameservers/Registrar
    -w ... Provide a whois summary instead of DNS records
    -h ... Print this help and quit\n
  Examples:\n
  DNS Summary with additional WHOIS information
    $0 -v <dom1>\n
  DNS Summary from specified resolver for multiple domains
    $0 -n 8.8.8.8,4.2.2.2 <dom1> <dom2>\n
  WHOIS Summary for multiple domains
    $0 -w <dom1> <dom2>\n"; exit ;;
  esac;
  shift;
done;

# Prompt for input if none provided
if [[ -z "$@" ]]; then  read -p "Domain Name: " D;
else
  D="$@";
fi;

# Clean up inputs and start loop
for domain in $(echo $D | sed 's/\///g;s/http://g;s/https://g'); do
  echo -e "\nDNS Summary: ${domain}\nIntoDNS: http://www.intodns.com/${domain}\nWhatsMyDNS: https://www.whatsmydns.net/#A/${domain}\nGeoPeeker: https://geopeeker.com/fetch/?url=${domain}"

if [[ ! $fullwhois ]]; then
  # Attempt to check whois for nameservers and registrar if verbose
  if [[ $verbose ]]; then
    echo -ne "Whois-NS: ...working...\r"
    if [[ $domain =~ \.edu$ ]]; then
      echo -ne "Whois-NS: "; whois $domain  | tr -d '\r' | awk '/.ame.?.erver.?/,/^$/ {print}' | tail -n+2 | awk '{printf $1" "}'; echo
    else
      whois $domain | tr -d '\r' | awk 'BEGIN{printf "Whois-NS: "}; ($NF !~ /.ervers?:/) && /.ame.?.erver|DNS:/{printf $NF" "}; /egistrar:/ {registrar=$0}; END{printf "\n%s\n",registrar}'
    fi
  fi

  # Use predefined list of resolvers for lookups (all option)
  if [[ $all ]]; then
    nameserver="@$localns @google-public-dns-a.google.com @ns1.liquidweb.com";
    # Check resolvers listed as nameservers in DNS except ns/ns1.liquidweb.com
    if [[ -n $(dig ns $OPTS $domain | grep -Ev 'liquidweb.com|sourcedns.com') ]]; then
      nameserver+=" @$(dig ns $OPTS2 $domain | sort | head -1)"
      nameserver+=" @$(dig ns $OPTS2 $domain | sort | tail -1)"
    fi
  fi

  # Use locally defined resolver if none specified
  if [[ ! $nameserver ]]; then nameserver=$localns; fi

  for resolver in $nameserver; do
    # Print dividers between headers and dns results
    if [[ ! $nameserver == $localns ]]; then
      echo -e "\n$(dash 80)\nDNS Records from :: $resolver\n$(dash 60)";
    else
      echo -e "$(dash 80)";
    fi


  if [[ $(dig $OPTS axfr $domain $resolver | grep -v "Transfer failed") ]];  then
   echo "${bold}Zone transfers appear to be enabled"
   echo "${normal}Doing zone transfer instead"
   echo -e "$(dash 50)";
   dig $OPTS axfr $domain $resolver 
   exit
  fi

    # Lookup A record and first record for www if not already given
    dig $OPTS a $domain $resolver
    if [[ ! $domain =~ ^[wW][wW][wW]\. ]]; then
      dig $OPTS www.${domain} $resolver | head -1
    fi
  
  if [[ $verbose && $(dig $OPTS a $random_subdomain.$domain $resolver) ]];then
	echo ""
	echo "${bold}** Wildcard Detected **"
	echo "${normal}I will not look up common subdomains for you sanity."
	echo ""
  elif [[ $verbose ]]; then
    # Check for common A Records
    # Added some speed inproments by forking procresses into the backgroud and spliting them up
    (for subdomains1 in about content mail mail1 mail2 mail3 remote blog email; do
      dig $OPTS A $subdomains1.$domain $resolver | grep 'A'; done ) &

    (for subdomains2 in ww1 ww2 www1 www2 host web web01 web02 web1 web2 support; do
      dig $OPTS A $subdomains2.$domain $resolver | grep 'A'; done ) &

    (for subdomains3 in  api app app1 app2 m shop ftp test portal ns2 smtp securel; do
      dig $OPTS A $subdomains3.$domain $resolver | grep 'A'; done ) &
     
    (for subdomains4 in  vps news lb lb01 lb02 mdlb mdlb1 mdlb01 ns ns1 server; do
      dig $OPTS A $subdomains4.$domain $resolver | grep 'A'; done ) & 

    (for subdomains5 in video upload static search sites mobile cpanel webmail; do
      dig $OPTS A $subdomains5.$domain $resolver | grep 'A'; done ) &

    (for subdomains6 in  support dev mx mx0 mx1 mx2 mx3 email cloud; do
      dig $OPTS A $subdomains6.$domain $resolver | grep 'A'; done ) &

    (for subdomains7 in  fourm store download info admin mx2 mx3 dev; do
      dig $OPTS A $subdomains7.$domain $resolver | grep 'A'; done ) &

    (for subdomains8 in  webmail server ns ns1 ns2 smtp secure vpn; do
      dig $OPTS A $subdomains8.$domain $resolver | grep 'A'; done ) &

    wait
  fi

    # Loop through the rest of the DNS record lookups
    for record in aaaa ns mx txt soa; do
      if [[ $record == 'ns' || $record == 'mx' ]]; then
        dig $OPTS $record $domain $resolver | grep -v 'root\|run' \
        | while read result; do echo "$result -> "$(dig +short $(echo $result | awk '{print $NF}') $resolver); done | sort -k5
      else
        dig $OPTS $record $domain $resolver | grep -v 'root\|run'
      fi
    done;

  if [[ $verbose ]]; then
    # Check for default DKIM records
    for DKIM in default google protonmail; do
      dig $OPTS txt $DKIM._domainkey.$domain $resolver | grep 'TXT'; done
    for DKIM in selector1 selector2; do
      dig $OPTS cname $DKIM._domainkey.$domain $resolver | grep 'CNAME'; done
      dig $OPTS txt _dmarc.$domain $resolver | grep 'TXT'

    # Lookup SRV records for live.com
    for SRV in '_sip._tls' '_sipfederationtls._tcp'; do
      dig $OPTS srv $SRV.$domain $resolver | grep 'SRV'
    done;#!/bin/bash
#							   +----+----+----+----+
# 							   |    |    |    |    |
# Orignal Author: Mark David Scott Cunningham		   | M  | D  | S  | C  |
# Updated By: CJ Saathoff				   |    |    |    |    |
#							   +----+----+----+----+
# Changelog
# Since the orignal script mark wrote I (CJ) have added:
# wildcard detection and commom hostname lookup
# Zone transfer check
#
# Created: 2014-03-20
# Updated: 2020-04-22
#
#
# Purpose: Quick DNS Summary for domain to confirm server/mail/rdns/ns/etc

dash (){ for ((i=1; i<=$1; i++)); do printf "-"; done; }
OPTS="+time=2 +tries=2 +short +noshort"
OPTS2="+time=2 +tries=2 +short"
localns=$(awk '/nameserver/ {print $2}' /etc/resolv.conf | head -1)
all=''
fullwhois=''
nameserver=''
verbose=''
bold=$(tput bold)
normal=$(tput sgr0)
random_subdomain=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

# Argument parsing with getopt
OPTIONS=$(getopt -o "an:vwh" -- "$@")
eval set -- "$OPTIONS"
while true; do
  case $1 in
    -a) all=1 ;;
    -n) nameserver=$(echo $2 | sed "s/^\(.\)/@\1/g;s/,/ @/g"); shift ;;
    -v) verbose=1 ;;
    -w) fullwhois=1 ;;
    --) shift; break ;;
    -h) echo -e "\n  Usage: $0 [options] [arguments]
    -a ... Check DNS records at default list of resolvers
    -n ... <ns1,ns2,ns3...> to use for DNS records lookups
    -v ... Lookup DNS records and Whois Nameservers/Registrar
    -w ... Provide a whois summary instead of DNS records
    -h ... Print this help and quit\n
  Examples:\n
  DNS Summary with additional WHOIS information
    $0 -v <dom1>\n
  DNS Summary from specified resolver for multiple domains
    $0 -n 8.8.8.8,4.2.2.2 <dom1> <dom2>\n
  WHOIS Summary for multiple domains
    $0 -w <dom1> <dom2>\n"; exit ;;
  esac;
  shift;
done;

# Prompt for input if none provided
if [[ -z "$@" ]]; then  read -p "Domain Name: " D;
else
  D="$@";
fi;

# Clean up inputs and start loop
for domain in $(echo $D | sed 's/\///g;s/http://g;s/https://g'); do
  echo -e "\nDNS Summary: ${domain}\nIntoDNS: http://www.intodns.com/${domain}\nWhatsMyDNS: https://www.whatsmydns.net/#A/${domain}\nGeoPeeker: https://geopeeker.com/fetch/?url=${domain}"

if [[ ! $fullwhois ]]; then
  # Attempt to check whois for nameservers and registrar if verbose
  if [[ $verbose ]]; then
    echo -ne "Whois-NS: ...working...\r"
    if [[ $domain =~ \.edu$ ]]; then
      echo -ne "Whois-NS: "; whois $domain  | tr -d '\r' | awk '/.ame.?.erver.?/,/^$/ {print}' | tail -n+2 | awk '{printf $1" "}'; echo
    else
      whois $domain | tr -d '\r' | awk 'BEGIN{printf "Whois-NS: "}; ($NF !~ /.ervers?:/) && /.ame.?.erver|DNS:/{printf $NF" "}; /egistrar:/ {registrar=$0}; END{printf "\n%s\n",registrar}'
    fi
  fi

  # Use predefined list of resolvers for lookups (all option)
  if [[ $all ]]; then
    nameserver="@$localns @google-public-dns-a.google.com @ns1.liquidweb.com";
    # Check resolvers listed as nameservers in DNS except ns/ns1.liquidweb.com
    if [[ -n $(dig ns $OPTS $domain | grep -Ev 'liquidweb.com|sourcedns.com') ]]; then
      nameserver+=" @$(dig ns $OPTS2 $domain | sort | head -1)"
      nameserver+=" @$(dig ns $OPTS2 $domain | sort | tail -1)"
    fi
  fi

  # Use locally defined resolver if none specified
  if [[ ! $nameserver ]]; then nameserver=$localns; fi

  for resolver in $nameserver; do
    # Print dividers between headers and dns results
    if [[ ! $nameserver == $localns ]]; then
      echo -e "\n$(dash 80)\nDNS Records from :: $resolver\n$(dash 60)";
    else
      echo -e "$(dash 80)";
    fi


  if [[ $(dig $OPTS axfr $domain $resolver | grep -v "Transfer failed") ]];  then
   echo "${bold}Zone transfers appear to be enabled"
   echo "${normal}Doing zone transfer instead"
   echo -e "$(dash 50)";
   dig $OPTS axfr $domain $resolver 
   exit
  fi

    # Lookup A record and first record for www if not already given
    dig $OPTS a $domain $resolver
    if [[ ! $domain =~ ^[wW][wW][wW]\. ]]; then
      dig $OPTS www.${domain} $resolver | head -1
    fi
  
  if [[ $verbose && $(dig $OPTS a $random_subdomain.$domain $resolver) ]];then
	echo ""
	echo "${bold}** Wildcard Detected **"
	echo "${normal}I will not look up common subdomains for you sanity."
	echo ""
  elif [[ $verbose ]]; then
    # Check for common A Records
    # Added some speed inproments by forking procresses into the backgroud and spliting them up
    (for subdomains1 in about content mail mail1 mail2 mail3 remote blog email; do
      dig $OPTS A $subdomains1.$domain $resolver | grep 'A'; done ) &

    (for subdomains2 in ww1 ww2 www1 www2 host web web01 web02 web1 web2 support; do
      dig $OPTS A $subdomains2.$domain $resolver | grep 'A'; done ) &

    (for subdomains3 in  api app app1 app2 m shop ftp test portal ns2 smtp securel; do
      dig $OPTS A $subdomains3.$domain $resolver | grep 'A'; done ) &
     
    (for subdomains4 in  vps news lb lb01 lb02 mdlb mdlb1 mdlb01 ns ns1 server; do
      dig $OPTS A $subdomains4.$domain $resolver | grep 'A'; done ) & 

    (for subdomains5 in video upload static search sites mobile cpanel webmail; do
      dig $OPTS A $subdomains5.$domain $resolver | grep 'A'; done ) &

    (for subdomains6 in  support dev mx mx0 mx1 mx2 mx3 email cloud; do
      dig $OPTS A $subdomains6.$domain $resolver | grep 'A'; done ) &

    (for subdomains7 in  fourm store download info admin mx2 mx3 dev; do
      dig $OPTS A $subdomains7.$domain $resolver | grep 'A'; done ) &

    (for subdomains8 in  webmail server ns ns1 ns2 smtp secure vpn; do
      dig $OPTS A $subdomains8.$domain $resolver | grep 'A'; done ) &

    wait
  fi

    # Loop through the rest of the DNS record lookups
    for record in aaaa ns mx txt soa; do
      if [[ $record == 'ns' || $record == 'mx' ]]; then
        dig $OPTS $record $domain $resolver | grep -v 'root\|run' \
        | while read result; do echo "$result -> "$(dig +short $(echo $result | awk '{print $NF}') $resolver); done | sort -k5
      else
        dig $OPTS $record $domain $resolver | grep -v 'root\|run'
      fi
    done;

  if [[ $verbose ]]; then
    # Check for default DKIM records
    for DKIM in default google protonmail; do
      dig $OPTS txt $DKIM._domainkey.$domain $resolver | grep 'TXT'; done
    for DKIM in selector1 selector2; do
      dig $OPTS cname $DKIM._domainkey.$domain $resolver | grep 'CNAME'; done
      dig $OPTS txt _dmarc.$domain $resolver | grep 'TXT'

    # Lookup SRV records for live.com
    for SRV in '_sip._tls' '_sipfederationtls._tcp'; do
      dig $OPTS srv $SRV.$domain $resolver | grep 'SRV'
    done;
  fi

    # Lookup rDNS/PTR for the IP
    dig $OPTS -x $(dig $OPTS2 $domain) $resolver 2>/dev/null | grep -v '^;;'
  done;

else
  echo -e "$(dash 80)";
  whois $domain | tr -d '\r' | grep -Ei 'Name.?Server:|DNS:|Registrar:|Status:|Expir.*:|Updated';
fi

done;
echo;
  fi

    # Lookup rDNS/PTR for the IP
    dig $OPTS -x $(dig $OPTS2 $domain) $resolver 2>/dev/null | grep -v '^;;'
  done;

else
  echo -e "$(dash 80)";
  whois $domain | tr -d '\r' | grep -Ei 'Name.?Server:|DNS:|Registrar:|Status:|Expir.*:|Updated';
fi

done;
echo;
