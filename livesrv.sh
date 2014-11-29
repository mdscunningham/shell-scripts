if [[ -n $1 ]]; then domain=$1; else read -p "Domain: " domain; fi

# Lookup zone id for domain
zoneid=$(sudo -u $(getusr) -- siteworx -u -n -c Dns -a listZones | awk "(\$2 ~ /$domain/)"'{print $1}')

# List existing records
echo; nodeworx -unc DnsRecord --zone_id $zoneid -a queryRecords | awk '($4 ~ /SRV|MX|CNAME|SPF/) {print $1,$4,$5,$6,$7,$8,$9,$10}' | sort -nk3 | column -t; echo

# Autodiscover CNAME
# autodiscover.$domain -> autodiscover.outlook.com
nodeworx -unc DnsRecord -a addCNAME --zone_id $zoneid --host "autodiscover.$domain" --ttl "3600" --alias "autodiscover.outlook.com"

# SPF Record:
# v=spf1 include:spf.protection.outlook.com –all
nodeworx -unc DnsRecord -a addSPF --zone_id $zoneid --spf_record_value "v=spf1 include:spf.protection.outlook.com –all"

# Add srv records
nodeworx -unc DnsRecord -a addSRV --zone_id $zoneid --service _sip --protocol _tls --ttl 3600 --priority 100 --weight 1 --port 443 --target sipdir.online.lync.com
nodeworx -unc DnsRecord -a addSRV --zone_id $zoneid --service _sipfederationtls --protocol _tcp --ttl 3600 --priority 100 --weight 1 --port 5061 --target sipfed.online.lync.com
