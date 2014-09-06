#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-05
# Updated: 2013-12-19
#
#
#!/bin/bash

# Setup color and formatting codes
      BLACK=$(tput setaf 0)
        RED=$(tput setaf 1)
      GREEN=$(tput setaf 2)
     YELLOW=$(tput setaf 3)
       BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
       CYAN=$(tput setaf 6)
      WHITE=$(tput setaf 7)
     BRIGHT=$(tput bold)
     NORMAL=$(tput sgr0)
      BLINK=$(tput blink)
    REVERSE=$(tput smso)
  UNDERLINE=$(tput smul)
# example color code usage:
# echo "${RED}this is red ${NORMAL}this is normal"
# printf "%-40s\n" "${BLUE}This text is blue${NORMAL}"

# Set default recordType and display
recordType="A"
highlight=0
linetwo=0

# Output correct usage for bad inputs
function usage(){
echo "
${BRIGHT}Usage:${NORMAL} $0 [options] domain [domain2 domain3 ...]

${BRIGHT}-h|--help${NORMAL} ......... Show this help/usage message.
${BRIGHT}-l|--links${NORMAL} ........ Generate links to the Global DNS Checker page and exit.
${BRIGHT}-2|--secondline${NORMAL} ... Display the second line of a record lookup response.
${BRIGHT}-n|--new${NORMAL} <Record> . Check if the record lookup matches the new record.
${BRIGHT}-t|--type${NORMAL} <Type> .. Change the requested record type of lookup.

${BRIGHT}ALLOWED RECORD TYPES:${NORMAL}
    A ..... IPv4 Address
    AAAA .. IPv6 Address
    CNAME . CNAME (Alias)
    MX .... Mail Exchange
    NS .... Name Server
    TXT ... Text Record
    SOA ... Start of Authority
    PTR.... PTR/rDNS Records
"
}

# Execute Getopt
OPTIONS=$(getopt -o "hl2t:n:" --long "help,links,secondline,type:,new:" -- "$@")

# Check for bad arguments
if [ $? -ne 0 ] ; then usage ; exit 1 ; fi

# Magic
eval set -- "$OPTIONS"

# Evaluate the options for their options
while true; do
case "$1" in
	-h|--help)
		usage; exit 1;;
        -l|--links)
		#echo "$@"
		echo
		shift;shift;
		for domain in "$@"; do
		        echo "${BLUE}http://www.nexcess.net/global-dns-checker/?h=${CYAN}$domain${BLUE}&t=$recordType${NORMAL}"
		done
		echo
		exit;;
	-2|--secondline)
		# Set response to be the second line of the record
		linetwo=1;;
	-t|--type)
		# Set recordType to option parameter and check for valid input
		recordType="$2";
		case $recordType in
			A|a) shift;;
			AAAA|aaaa) shift;;
			CNAME|cname) shift;;
			MX|mx) shift;;
			NS|ns) shift;;
			TXT|txt) shift;;
			SOA|soa) shift;;
			PTR|ptr|RDNS|rdns|X|x) recordType="-x"; shift;;
			*)
			echo "$recordType is not an allowed record type"; echo
			usage; exit 1;;
		esac;;
	-n|--new)
		highlight=1
		newResult="$2"; shift;;
	--)
		# Announce the type of record lookup
		echo "${RED}Checking ${YELLOW}$recordType ${RED}Records for the following domain(s) ${YELLOW}...${NORMAL}"
		shift; break;;
	*)
		usage; exit 1;;
esac
shift
done

# Source of all the dns servers used 
# http://public-dns.tk/

# Read in data from remote file
data=($(curl -s http://nanobots.robotzombies.net/nameserver))

# Read in data from local file
# data=($(cat nameserver))

# Find length of primary array
dataLen=${#data[@]}

# Create secondary arrays from primary array
for (( i=0; i<$dataLen; i += 3 )); do
    nameserver=("${nameserver[@]}" ${data[$i]})
    location=("${location[@]}" ${data[($i+1)]})
    ipaddress=("${ipaddress[@]}" ${data[($i+2)]})
done

# Find length of secondary arrays
namLen=${#nameserver[@]}; locLen=${#location[@]}

# Sanity Checking - Make sure arrays are the same length
if [ $namLen = $locLen ]; then echo

# Iterate through the array of domain parameters
for domain in "$@"; do
	echo "${WHITE}========== $domain ==========${NORMAL}"
	echo "http://www.nexcess.net/global-dns-checker/?h=$domain&t=$recordType"

	# Check if at office and use rdns01/rdns02 else use ns1/ns2
	if [[ $(hostname) == *nex* ]]; then
		newLen=($namLen-2); i=0
	else
		newLen=$namLen; i=2
	fi

	# Iterate through the array of nameservers
	for (( $i; i<$newLen; i++ )); do
		if [[ $linetwo = 1 ]]; then
		result=$(dig +time=2 +tries=2 +short "$recordType" "$domain" @"${ipaddress[i]}" | head -n2 | tail -n1 | grep -v \;)
		else
		result=$(dig +time=2 +tries=2 +short "$recordType" "$domain" @"${ipaddress[i]}" | head -n1 | grep -v \;)
		fi
		if [[ $highlight = 1 && $result = $newResult ]]; then
		printf "${BLUE}%-30s ${NORMAL}: ${BLUE}%-26s ${NORMAL}: ${RED}%s\n${NORMAL}" "${nameserver[i]}" "$(echo ${location[i]} | sed s/_/\ /g)" "$result"
		else
		printf "${BLUE}%-30s ${NORMAL}: ${BLUE}%-26s ${NORMAL}: ${CYAN}%s\n${NORMAL}" "${nameserver[i]}" "$(echo ${location[i]} | sed s/_/\ /g)" "$result"
		fi
	done #end nameserver for loop

	echo
#Pause between domains
#read -p "Press [Enter] to continue ..."

done #end domain for loop

else # Error message if sanity check not passed
	echo "${RED}Nameserver Count = $namLen"; echo "Location Count = $locLen"
	echo "Array Lengths Do Not Match! Quitting ...${NORMAL}"
fi
