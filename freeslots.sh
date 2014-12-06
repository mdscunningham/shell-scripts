echo "Working ..."
nexaccts=$(nodeworx -unc Siteworx -a listAccounts | sed 's/ /_/g' | awk '($5 ~ /1/) {print $2}' | wc -l)
resaccts=$(nodeworx -unc Siteworx -a listAccounts | sed 's/ /_/g' | awk '($5 !~ /1/) {print $2}' | wc -l)
totaccts=$(~iworx/bin/listaccounts.pex | wc -l)
resellrs=$(nodeworx -unc Reseller -a listResellers | awk '($1 !~ /1/) {print $2}' | wc -l)

echo -e "\nServer Admin Accounts"
echo "Siteworx : $nexaccts"

echo -e "\nReseller Accounts"
echo "Nodeworx : $resellrs"
echo "Siteworx : $resaccts"

#echo -e "\nTotal Accounts"
#echo "Siteworx : $totaccts"

echo
if [[ $(hostname) =~ sip.*1- ]]; then
  echo "Free Slots: $(( 30 - $nexaccts ))"
elif [[ $(hostname) =~ sip.*2- ]]; then
  echo "Free Slots: $(( 13 - $nexaccts ))"
elif [[ $(hostname) =~ sip.*3- ]]; then
  echo "Free Slots: $(( 4 - $nexaccts ))"
elif [[ $(hostname) =~ sipr- ]]; then
  echo "Free Slots: $(( 8 - $resellrs ))"

elif [[ $(hostname) =~ (obp|eep|vbo).*1- ]]; then
  echo "Free Slots: $(( 35 - $nexaccts ))"
elif [[ $(hostname) =~ (opb|eep|vbo).*2- ]]; then
  echo "Free Slots: $(( 15 - $nexaccts ))"
elif [[ $(hostname) =~ (obp|eep|vbo).*3- ]]; then
  echo "Free Slots: $(( 5 - $nexaccts ))"
elif [[ $(hostname) =~ eepr- ]]; then
  echo "Free Slots: $(( 8 - $resellrs ))"

fi

if [[ $(hostname) =~ ^sip ]]; then
  echo -e "\nFree IPAddresses";
  for x in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.|^10\.|^172\.'); do
    printf "\n%-15s " "$x"; grep -l $x /etc/httpd/conf.d/vhost_[^000_]*.conf;
  done | grep -v [a-z] | column -t;
else echo "These do not need dedicated IPs"; fi; echo


