# SPF Record:
# v=spf1 include:spf.protection.outlook.com –all

# Autodiscover CNAME
# autodiscover.$domain -> autodiscover.outlook.com

# Lookup zone id for domain
zoneid=$(sudo -u $(getusr) -- siteworx -u -n -c Dns -a listZones | awk "(\$2 ~ /$domain/)"'{print $1}')

# List existing records
echo; nodeworx -unc DnsRecord --zone_id 104 -a queryRecords | awk '($4 ~ /SRV/) {print $1,$4,$5,$6,$7,$8,$9,$10}' | sort -nk3 | column -t; echo

# Add srv records
nodeworx -unc DnsRecord -a addSRV --zone_id $zoneid --service _sip --protocol _tls --ttl 3600 --priority 100 --weight 1 --port 443 --target sipdir.online.lync.com
nodeworx -unc DnsRecord -a addSRV --zone_id $zoneid --service _sipfederationtls --protocol _tcp --ttl 3600 --priority 100 --weight 1 --port 5061 --target sipfed.online.lync.com
