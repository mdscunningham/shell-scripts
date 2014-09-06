# Print Server Health Status to screen
nodeworx -u -n -c health -a listHealthStatus | awk '{print $1,$3}' | sed "s/0$/${BRIGHT}${GREEN}GOOD${NORMAL}/g;s/1$/${BRIGHT}${RED}BAD${NORMAL}/g;s/2$/N\/A/g" | column -t

# Print links to Nodeworx service pages
nodeworx -u -n -c Overview -a listServiceStatus | sed 's:, :,:' | awk '{print $1" | https://""'"$(serverName)"'"":2443"$5}' | column -t

# Lookup Siteworx account details
accountdetail(){
  nodeworx -u -n -c Siteworx -a querySiteworxAccountDetails --domain $(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}')\
  | sed 's:\([a-zA-Z]\) \([a-zA-Z]\):\1_\2:g;s:\b1\b:YES:g;s:\b0\b:NO:g' | column -t
}

# Add an IP to a siteworx account
addip(){
  nodeworx -u -n -c Siteworx -a addIp --domain $(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}') --ipv4 $ipAddress
}

# Enable Siteworx backups
nodeworx -u -n -c Siteworx -a edit --domain $(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}') --OPT_BACKUP 1

# Set number of secondary domains
nodeworx -u -n -c Siteworx -a edit --domain $(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}') --OPT_SLAVE_DOMAINS $num

primarydomain(){ ~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}'; }

# List iworx logs
ls /home/interworx/var/log/*.log | column -t

# Iworx DB
$(grep -B1 'dsn.orig=' ~iworx/iworx.ini | head -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|')

# ProFTPd
$(grep -A1 '\[proftpd\]' ~iworx/iworx.ini | tail -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|')

# Horde
$(grep -A1 '\[horde\]' ~iworx/iworx.ini | tail -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|')

# Roundcube
$(grep -A1 '\[roundcube\]' ~iworx/iworx.ini | tail -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|')

# Vpopmail
$(grep -A1 '\[vpopmail\]' ~iworx/iworx.ini | tail -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|')

