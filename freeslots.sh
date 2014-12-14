#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-12-06
# Updated: 2014-12-13
#
#
#!/bin/bash

echo "Working ..."
nexaccts=$(nodeworx -unc Siteworx -a listAccounts | sed 's/ /_/g' | awk '($5 ~ /1/) {print $2}' | wc -l)
resaccts=$(nodeworx -unc Siteworx -a listAccounts | sed 's/ /_/g' | awk '($5 !~ /1/) {print $2}' | wc -l)
resellrs=$(nodeworx -unc Reseller -a listResellers | awk '($1 !~ /1/) {print $2}' | wc -l)

echo -e "\nServer Admin Accounts\nSiteworx : $nexaccts"
echo -e "\nReseller Accounts\nNodeworx : $resellrs\nSiteworx : $resaccts\n"

if [[ $(hostname) =~ sip[a-z]*1-[0-9]* ]]; then echo "Free Slots: $(( 30 - $nexaccts ))"
elif [[ $(hostname) =~ sip[a-z]*2-[0-9]* ]]; then echo "Free Slots: $(( 13 - $nexaccts ))"
elif [[ $(hostname) =~ sip[a-z]*3-[0-9]* ]]; then echo "Free Slots: $(( 4 - $nexaccts ))"
elif [[ $(hostname) =~ sipr-[0-9]* ]]; then echo "Free Slots: $(( 8 - $resellrs ))"
elif [[ $(hostname) =~ (obp|eep|vbo)[a-z]*1-[0-9]* ]]; then echo "Free Slots: $(( 35 - $nexaccts ))"
elif [[ $(hostname) =~ (opb|eep|vbo)[a-z]*2-[0-9]* ]]; then echo "Free Slots: $(( 15 - $nexaccts ))"
elif [[ $(hostname) =~ (obp|eep|vbo)[a-z]*3-[0-9]* ]]; then echo "Free Slots: $(( 5 - $nexaccts ))"
elif [[ $(hostname) =~ eepr-[0-9]* ]]; then echo "Free Slots: $(( 8 - $resellrs ))"; fi

if [[ $(hostname) =~ ^sip ]]; then echo -e "\nFree IPAddresses";
  for x in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.|^10\.|^172\.'); do
    printf "\n%-15s " "$x"; grep -l $x /etc/httpd/conf.d/vhost_[^000_]*.conf;
  done | grep -v [a-z] | column -t;
else echo "These do not need dedicated IPs"; fi; echo


