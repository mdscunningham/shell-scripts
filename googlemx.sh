#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-29
# Updated: 2014-08-31
#
#
#!/bin/bash

if [[ -z $1 || $1 == '-h' || $1 == '--help' ]]; then
echo -e "\n Usage: googlemx OPTION DOMAIN
    EX: googlemx -a DOMAIN
    Ex: googlemx -c DOMAIN
    Ex: googlemx --list\n
 OPTIONS
     -a ... Remove old MX records and add Google MX
     -c ... Check existing MX records for domain
 --list ... List domains and ids for the account\n"; fi

# Lookup Domain dns_zone id's
if [[ $1 == --list ]]; then
echo; (echo 'ID Domain'; sudo -u $(getusr) -- siteworx -u -n -c Dns -a listZones | awk '($2 !~ /nextmp/) {print $1,$2}') | column -t; echo

# Lookup current MX records on the server for the domain
elif [[ $1 = '-c' && -n $2 ]]; then
# Lookup zone_id for the domain
zoneid=$(sudo -u $(getusr) -- siteworx -u -n -c Dns -a listZones | awk "(\$2 ~ /$2/)"'{print $1}')

# Print out MX records for the domain
echo -e "\nID ... MX-Records-for: $2"
(sudo -u $(getusr) -- siteworx -u -n -c Dns -a queryDnsRecords --zone_id $zoneid) | awk '($4 ~ /MX/) {print $1,$4,$6,$7,$8}' | sort -nk3 | column -t; echo
fi

if [[ $1 == '-a' && -n $2 ]]; then
# Lookup zone_id for a domain
zoneid=$(sudo -u $(getusr) -- siteworx -u -n -c Dns -a listZones | awk "(\$2 ~ /$2/)"'{print $1}')

# Print existing MX records for the domain
echo -e "\nID ... MX-Records-for: $1"
(sudo -u $(getusr) -- siteworx -u -n -c Dns -a queryDnsRecords --zone_id $zoneid) | awk '($4 ~ /MX/) {print $1,$4,$6,$7,$8}' | sort -nk3 | column -t; echo

# Generate list and remove any existing MX records
echo "Removing old records"
mxrecord=$((sudo -u $(getusr) -- siteworx -u -n -c Dns -a queryDnsRecords --zone_id $zoneid) | awk '($4 ~ /MX/) {print $1}')
for x in $mxrecord; do nodeworx -u -n -c DnsRecord -a delete --record_id $x; done

## Print out progress and add records, then disable local delivery
echo
sudo -u $(getusr) -- siteworx -u -n -c Dns -a addMX --zone_id $zoneid --preference 1 --mail_server ASPMX.L.GOOGLE.COM --ttl 3600 && echo '[Added] ASPMX.L.GOOGLE.COM'
sudo -u $(getusr) -- siteworx -u -n -c Dns -a addMX --zone_id $zoneid --preference 5 --mail_server ALT1.ASPMX.L.GOOGLE.COM --ttl 3600 && echo '[Added] ALT1.ASPMX.L.GOOGLE.COM'
sudo -u $(getusr) -- siteworx -u -n -c Dns -a addMX --zone_id $zoneid --preference 5 --mail_server ALT2.ASPMX.L.GOOGLE.COM --ttl 3600 && echo '[Added] ALT2.ASPMX.L.GOOGLE.COM'
sudo -u $(getusr) -- siteworx -u -n -c Dns -a addMX --zone_id $zoneid --preference 10 --mail_server ALT3.ASPMX.L.GOOGLE.COM --ttl 3600 && echo '[Added] ALT3.ASPMX.L.GOOGLE.COM'
sudo -u $(getusr) -- siteworx -u -n -c Dns -a addMX --zone_id $zoneid --preference 10 --mail_server ALT4.ASPMX.L.GOOGLE.COM --ttl 3600 && echo '[Added] ALT4.ASPMX.L.GOOGLE.COM'
localdelivery -d $2
fi

