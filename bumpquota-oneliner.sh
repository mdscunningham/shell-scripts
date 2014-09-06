echo; read -p "Username: " userName; read -p "New Quota (MB): " newQuota; \
nodeworx -u -n -c Siteworx -a edit --domain $(~iworx/bin/listaccounts.pex | grep $userName | awk '{print $2}') --OPT_STORAGE $newQuota \
&& echo -e "\nDisk Quota for $userName has been set to $newQuota MB\n"
