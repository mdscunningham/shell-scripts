#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-08-31
# Updated: 2017-10-23
#
# Purpose: Quick rundown of CTB Activation checklist for hardware
#
# To Do: [x] Check for OS (Ubuntu, CentOS 6/7, etc)
#	 [x] Check for cPanel / not-cPanel
#	 [x] Check for RAID, and run appropriate hardware RAID Checks
#	 [x] Check link for all eth devices mentioned in dmesg
#	 [x] Corrected mysql drive lookup in Guardian section
#        [x] Added check for CloudLinux bits 'n' pieces
#        [x] Alert if cPanel license is still 15-day-test
#        [x] No Color mode for emailing or other processing

div='--------------------------------------------------------------------------------';

# Taste the rainbow
      BLACK=$(tput setaf 0);        RED=$(tput setaf 1)
      GREEN=$(tput setaf 2);     YELLOW=$(tput setaf 3)
       BLUE=$(tput setaf 4);     PURPLE=$(tput setaf 5)
       CYAN=$(tput setaf 6);      WHITE=$(tput setaf 7)

     BRIGHT=$(tput bold);        NORMAL=$(tput sgr0)
      BLINK=$(tput blink);      REVERSE=$(tput smso)
  UNDERLINE=$(tput smul)

if [[ $1 == '-n' ]]; then
  # No color mode
  info(){ echo -e "${1}"; }
  alert(){ echo -e "${1}"; }
  warning(){ echo -e "${1}"; }
else
  # Colors for alerting
  info(){ echo -e "${BRIGHT}${GREEN}${1}${NORMAL}"; }
  alert(){ echo -e "${BRIGHT}${YELLOW}${1}${NORMAL}"; }
  warning(){ echo -e "${BRIGHT}${RED}${1}${NORMAL}"; }
fi

echo -e "\n${div}\n  $HOSTNAME\n${div}";

####################
# CPU and Operating System
##########

info "Base Setup"
echo "[ ]Order in Billing matches order in ticket – has setups signed off on the following for all servers in order:
        [ ] SYENG account exists for each MES service (if any)
          [ ] Naming scheme matches standard:
           -  https://wiki.int.liquidweb.com/articles/Standardized_Hostnames_for_Managed_Engineering_Servers_and_Services
          [ ] Pricing has been set in billing and is not \$0"

info '\n    [ ]CPU/Base Build';
  grep model.name /proc/cpuinfo | head -1 | sed 's/^/\t/g'
  echo -e "\t$(grep -c model.name /proc/cpuinfo) Cores"

info '\n    [ ] CPUspeed is off';
if [[ -x /usr/bin/systemctl ]]; then
  systemctl status cpuspeed | sed 's/^/\t/g'
else
  /etc/init.d/cpuspeed status | sed 's/^/\t/g'
fi

info '\n    [ ]OS';
if [[ $(grep -i cloud /etc/redhat-release 2>/dev/null) ]]; then #CloudLinux
  cat /etc/redhat-release
  # Force refresh of CL License
  clnreg_ks --force
  # Check for LVEManager
  if [[ -x $(which lvectl) && -x $(which lveinfo) ]]; then info "LVE Manager appears to be installed"; else warning "LVE utilities appear to be missing"; fi
  # Check for mod_hostinglimits
  if [[ $(httpd -M 2>/dev/null| grep hostinglimits) ]]; then info "mod_hostinglimits installed"; else warning "mod_hostinglimits missing"; fi
  # Check for LVE kernel
  if [[ $(uname -r) =~ lve ]]; then info "Server is using an LVE kernel\n$(uname -r)"; else warning "Server is not running LVE kernel\n$(uname -r)"; fi
  # Check for enabled Repos
  if [[ $(grep 'enabled.*=.*1' /etc/yum.repos.d/cloudlinux*) ]]; then info "$(grep 'enabled.*=.*1' /etc/yum.repos.d/cloudlinux*)"; else warning "No cloudlinux repos enabled at this time"; fi

elif [[ -f /etc/redhat-release ]]; then # CentOS
  cat /etc/redhat-release
  uname -r
elif [[ -x /usr/bin/lsb_release ]]; then #Ubuntu
  lsb_release -a
  uname -r
fi | sed 's/^/\t/g'

####################
# RAID
##########

if [[ $(dmesg | grep -i raid) ]]; then
  info '\n    [ ]RAID'

if [[ $(df | grep '/dev/md[0-9]') ]]; then
  echo -e '          [ ] Software RAID'; fi

if [[ -x /opt/MegaRAID/MegaCli/MegaCli64 ]]; then
  echo '          [ ] LSI RAID configuration'
  echo '          [ ] LSI Controller Firmware version 12.12.0-0073 or higher to fix vpd r/w failed error.'
    /opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -a0 | grep Package.Build | sed 's/^/\t\t/g';

  echo "              [ ] Solid State Drives"
  echo "                  [ ] Disk Cache is enabled"
  echo "                  [ ] Read Ahead caching disabled"
  echo "              [ ] SATA Drives"
  echo "                  [ ] Read Ahead caching enabled"
    /opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -Lall -aAll | grep -E 'Size|Cache' | sed 's/^/\t\t/g'
fi

if [[ -x /usr/StorMan/arcconf ]]; then
  echo -e '          [ ] Adaptec RAID controller Firmware version 7.4-0 build 30862 or higher for 71605E cards:'
    /usr/StorMan/arcconf getconfig 1 | grep Controller.Model | column -t | sed 's/^/\t\t/g';
  if [[ $(/usr/StorMan/arcconf getconfig 1 | grep ASR71605E) ]]; then
    alert "Adaptec RAID 71605E Found:"
    /usr/StorMan/arcconf getconfig 1 | egrep 'Firmware.*7.[0-9]' | awk '{ if ($4 > "(30861)") print "ASR71605E Firmware is up to date: " $4; else print "ASR71605E Build version is < 30862! **Please update!** " }' | sed 's/^/\t\t/g';
  fi
fi

echo -e '          [ ] Raider is configured and working properly'
  /usr/bin/raider --run-jobs

echo -e '          [ ] StorMan removed'
  if [[ -x /usr/bin/systemctl ]]; then
    systemctl stop stor_agent; systemctl disable stor_agent; systemctl status stor_agent
  elif [[ -f /etc/init.d/stor_agent ]]; then
    /etc/init.d/stor_agent stop; chkconfig stor_agent off; /etc/init.d/stor_agent status
  fi
fi

####################
# Hardware
##########

info '\n    [ ]RAM';
  free -m | sed 's/^/\t/g'

info '\n    [ ]Drive Size';
  fdisk -l 2>/dev/null | grep -i disk./dev | sed 's/^/\t/g'

info '\n    [ ]Partitioning';
  lsblk | sed 's/^/\t/g'

if [[ $(uname -r | grep -i el6) ]]; then
  alert '\n[ ]e1000e kmod update per wiki, if Cent6 and intel e1000e driver is in use.'
  lsb_release -a|awk -F: '{
        sub(/^[ \t\r\n]+/, "",$NF) ;
        if($1 ~ /^Dis/) d=$2;
        if($1 ~ /^Rel/) v=$2;
    } END {
        print "Checking OS Version... ";
        if (tolower(d) ~ "centos|cloudlinux" && v ~ /6[.][0-9]+/) {
            printf "  Found: "d" "v"\nChecking for e1000e Driver...\n";
            "dmesg|grep e1000e.*Driver"|getline o;
            if (o) {
                printf "  Found: "o"\nChecking for kmod-e1000e...\n";
                "yum list installed|grep kmod-e1000e"|getline k;
                if(k) {
                    sub(/[ \t\r\n]+/," ",k);
                    print "  Found: "k;
                } else {
                    print "  kmod-e10001 is NOT installed.\n  Check the E1000E internal wiki for more information.";
                };
            } else {
                print "  e1000e Driver is not being used\n  kmod-e1000e is not needed..";
            } ;
        } else {
            print "  "d,v,"is not CentOS 6x, aborting additional checks."
        }
    }'
fi

####################
# cPanel/CloudLinux
##########

if [[ -d /usr/local/cpanel/ ]]; then
info '\n[ x]Cpanel/Non-Cpanel'
echo -e '\n    [ ] If cPanel, make sure the server has a full license.'
  /usr/local/cpanel/cpkeyclt | sed 's/^/\t/g'

  alert "\n       License Type:"
    MAINIP=$(curl -s ip.liquidweb.com)
    LICENSE=$(curl -s https://verify.cpanel.net/index.cgi?ip=$MAINIP | grep -Eio '>.*(LIQUIDWEB|TEST).*<' | tr -d '<>')
    if [[ $LICENSE =~ LIQUIDWEB ]]; then
      info $LICENSE | grep LIQUIDWEB
    else
      warning $LICENSE
    fi | sed 's/^/\t/g'

  alert "\n       Backup Config:"
    whmapi1 backup_config_get|grep -E "backup(_daily|_monthly|_weekly|days)" | sed 's/^/\t/g'

  if [[ ! $(df | grep /backup) ]]; then
    warning "\n       No Backup Drive Found :: Make Sure Backups are Disabled"
    echo -e '      [ ] Disable cPanel Backups if no backup drive was ordered.'
  fi

  if [[ $(ip a | egrep ' 192\.| 10\.') ]]; then
  echo -e '\n      [ ] Private IP addresses are marked as reserved.'
    if [[ ! -s /etc/reservedips ]]; then
    mkdir -p /root/bin;
    wget -qO /root/bin/reserveips http://scripts.ent.liquidweb.com/reserveips;
    chmod +x /root/bin/reserveips;
    reserveips
    else
      cat /etc/reservedips | sed 's/^/\t/g'
    fi
  fi

  if [[ $(ip a | grep ' 172\.') ]]; then
    alert '\n      [ ] If servers are behind hardware FW, make sure the UDP inspection policy is set to "maximum client auto" ** poke networking or check in NOC **'
  fi

  echo -e "\n      [ ] RWHOIS open for cPanel API"
  rwhois=$(iptables -nL | grep :4321)
  if [[ $rwhois ]]; then
    info "$rwhois" | sed 's/^/\t/g'
  else
    warning "Firewall not open for RWHOIS (port 4321)" | sed 's/^/\t/g'
  fi

fi

####################
# Remote Access
##########

echo -e '\n[ ]Complex Root or User Passwords are setup
       "pwgen -syn 15 1" or longer
     [ ]Cable runs requested and acknowledged by Maintenance
     [ ]IPMI - Verified working.'

# https://www.thomas-krenn.com/en/wiki/Configuring_IPMI_under_Linux_using_ipmitool
if [[ -x $(which ipmitool 2>/dev/null) ]]; then
  ipmi_ip=$(ipmitool lan print 1 | awk '/IP Address.*10\./ {print $NF}');
  subacct=$(cat /usr/local/lp/etc/lp-UID);
  if [[ $(ip -o -4 a | egrep $ipmi_ip) ]]; then
    warning "\tIPMI appears to be using an IP assigned to $(ip -o -4 a | grep $ipmi_ip | awk '{print $2}')"
  elif [[ $ipmi_ip ]]; then
    alert "\thttps://$ipmi_ip \neasyipmi $ipmi_ip $subacct";
  else
    warning '\tIPMI does not appear to have an IP configured'
  fi
else
  warning '\tIPMItool is missing or not executable.'
fi

####################
# R1Soft Backups
##########

if [[ -f /usr/sbin/r1soft/log/cdp.log ]]; then
  info '\nGuardian'
  echo -e '[ ]buagent or cdp-agent is installed and running (/etc/init.d/cdp-agent status)'
    /etc/init.d/cdp-agent status | sed 's/^/    /g'

  echo -e '[ ]Port 1167 open/allowed in the software firewall.'
    iptables -nL | grep :1167 | sed 's/^/    /g'

  echo -e '[ ]Make sure the proper partitions are being backed up via the web interface.'
    # Lookup the backup manager from the CDP config and the Guardian IP

  echo -e '[ ]If there a Dedicated MySQL drive make sure it is setup to be backed up.'
    mysqldata=$(mysql -Ne 'select @@datadir' | sed 's|/$||g')
    if [[ $(grep $mysqldata /etc/fstab) ]]; then alert "    Dedicated MySQL Drive :: Make sure to check this in Guardian"; fi

  echo -e "[ ]Verify that backups complete"
  echo -e "[ ]Make sure Guardian monitoring is enabled on the Guardian subaccount"
fi

####################
# Load Balancing
##########

echo -e "\n[ ]Remote IP override module installed or updated if applicable"
echo -e "     [ ]mod_zeus if Apache 2.2"
  if [[ $(httpd -v) =~ 2\.2\. ]]; then httpd -M 2> /dev/null | grep zeus ; fi
echo -e "     [ ]mod_remoteip if Apache 2.4"
  if [[ $(httpd -v) =~ 2\.4\. ]]; then httpd -M 2> /dev/null | grep remote; fi
echo -e "     [ ]mod_cloudflare"
  httpd -M 2>/dev/null | grep cloudflare
echo -e "     [ ]mod_rpaf"
  httpd -M 2>/dev/null | grep rpaf

####################
# Monitoring
##########

echo -e '\n[ ]SonarPush is installed and working properly'
  ps aux | grep [S]onarPush
  alert "https://monitor.liquidweb.com/summary.php?search=$(cat /usr/local/lp/etc/lp-UID)\n"
if [[ -f /usr/local/lp/etc/sonar_password ]]; then
  echo 'Sonar is installed and configured. Check this using Radar link highlighted above.'
else
  warning 'Sonar password file missing :: /usr/local/lp/etc/sonar_password'
  alert 'Fix this if server is Managed. Ignore this if the server is Unmanaged'
fi

echo -e '\nMaintenance
[ x]Servers moved to correct building if necessary
[ x]Cable runs complete'

####################
# Networking
##########

info "\nNetworking"
echo -e "[ ]Public/NAT IPs Configured Correctly ***Consult the original CTB***"
for x in $(ip -o -4 a | awk '{print $2}' | uniq | grep -v lo); do
  echo -n $(info "$x: "); ip -o -4 a | awk "/$x/"'{print $4}' | cut -d/ -f1 | tr '\n' ' '; echo;
done | sed 's/^/    /g';

# ip -o -4 a | grep -v ': lo' | sed 's/^/    /g';

echo -e "[ ]If required, verify that the servers are behind a FW."
  if [[ $(ip -o -4 a | grep ' 172\.') ]]; then alert "    Behind NAT Firewall"; fi

echo -e "[ ]Private Switch/Networking"
echo -e "[ ]Load Balancing"
  httpd -M 2> /dev/null | egrep 'zeus|remote' | sed 's/^/    /g'

echo -e "[ ]IP Requests/VIPs"
echo -e "[ ]Confirm private network cables are plugged into switch/server (ip addr ls dev ethX)"
  for x in $(dmesg | grep -o eth[0-9] | sort | uniq); do
    (printf "$x :: "; ethtool $x | grep -i link.detect) | sed 's/^/    /g';
  done

####################
# Core Managed
##########

if [[ ! -d /usr/local/cpanel ]]; then
  echo -e "\nSupport (For Managed and CoreManaged Customers) – Do requested versions match customer request:"
  echo -e "\n[ ]Apache"
    if [[ -x $(which httpd) ]]; then httpd -v 2> /dev/null; elif [[ -x $(which apache2) ]]; then apache2 -v 2> /dev/null; fi | sed 's/^/    /g'
  echo -e "\n[ ]MySQL"
    if [[ -x $(which mysql) ]]; then
      mysql --version | sed 's/^/    /g'
    fi
  echo -e '\n[ ]DNS/Nameservers as requested
[ ]ServerSecure
[ ]Email address for alerts is correct'

fi

echo -e "\nSpecial Software Requests
[ ] List any requests here. Example: FFMPEG, Tomcat, NGINX"

echo -e "\nMigrations
[ ]Migration ticket is open and owned by system-restore/migrations
[ ]Migration is scheduled and customer has been notified of time frame
[ ]Customer has confirmed that migration was successful"

echo -e "\n$div\n"
