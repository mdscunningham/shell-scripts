#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-08-31
# Updated: 2016-11-09
#
# Purpose: Quick rundown of CTB Activation checklist for hardware
#
# To Do: [x] Check for OS (Ubuntu, CentOS 6/7, etc)
#	 [x] Check for cPanel / not-cPanel
#	 [x] Check for RAID, and run appropriate hardware RAID Checks
#	 [x] Check link for all eth devices mentioned in dmesg
#	 [x] Corrected mysql drive lookup in Guardian section

div='--------------------------------------------------------------------------------';

echo -e "\n${div}\n  $HOSTNAME\n${div}";

echo "Base Setup
[ ]Order in Billing matches order in ticket – has setups signed off on the following for all servers in order:
        [ ] SYENG account exists for each MES service (if any)
          [ ] Naming scheme matches standard:
           -  https://wiki.int.liquidweb.com/articles/Standardized_Hostnames_for_Managed_Engineering_Servers_and_Services
          [ ] Pricing has been set in billing and is not \$0"

echo -e '\n        [ ]CPU/Base Build';
  grep model.name /proc/cpuinfo | head -1;

echo -e '\n          [ ] CPUspeed is off';
if [[ -x /usr/bin/systemctl ]]; then
  systemctl status cpuspeed
else
  /etc/init.d/cpuspeed status;
fi

echo -e '\n    [ ]OS';
if [[ -f /etc/redhat-release ]]; then
  cat /etc/redhat-release
elif [[ -x /usr/bin/lsb_release ]]; then
  lsb_release -a;
fi

if [[ $(dmesg | grep -i raid) ]]; then
  echo -e '\n    [ ]RAID'

if [[ $(df | grep '/dev/md[0-9]') ]]; then
  echo -e '          [ ] Software RAID'; fi

if [[ -x /opt/MegaRAID/MegaCli/MegaCli64 ]]; then
  echo -e '          [ ] LSI Controller Firmware version 12.12.0-0073 or higher to fix vpd r/w failed error.'
    /opt/MegaRAID/MegaCli/MegaCli64 -AdpAllInfo -a0 | grep "Package Build";

## Will need to work out more logic on these commands
#  echo '          [ ] LSI RAID configuration
#              NOTE: "-Lx" should be "-L0" or "-L1" etc. so you are only targeting specific arrays. If all of the arrays use the same kind of disks, you can use "-Lall"
#              NOTE: Occasionally, there will be two adapters in a server instead of one.  In which case, do not use "-aAll", but use "-aX" where "X" is the adapter you are modifying.'
#
#  echo "              [ ] SSDs"
#  echo "                  [ ] Disk Cache is enabled"
#    /opt/MegaRAID/MegaCli/MegaCli64 -LDInfo -L0 -aAll | grep -i 'Disk Cache'
#
#  echo "                      If disabled run the following commands and check to ensure its now enabled (otherwise may need a reboot)"
#    /opt/MegaRAID/MegaCli/MegaCli64 -LDSetProp -EnDskCache -Immediate -L0 -aAll
#
#  echo "                  [ ] Read Ahead caching disabled"
#    /opt/MegaRAID/MegaCli/MegaCli64 -LDSetProp -NORA -Immediate -L0 -aAll
#
#  echo "              [ ] Spinners"
#  echo "                  [ ] Read Ahead caching enabled"
#    /opt/MegaRAID/MegaCli/MegaCli64 -LDSetProp -RA -Immediate -L0 -aAll

fi

if [[ -x /usr/StorMan/arcconf ]]; then
  echo -e '          [ ] Adaptec RAID controller Firmware version 7.4-0 build 30862 or higher for 71605E cards:'
    /usr/StorMan/arcconf getconfig 1 | grep Controller.Model
  if [[ $(/usr/StorMan/arcconf getconfig 1 | grep ASR71605E) ]]; then
    /usr/StorMan/arcconf getconfig 1 | egrep 'Firmware.*7.[0-9]' | awk '{ if ($4 > "(30861)") print "ASR71605E Firmware is up to date: " $4; else print "ASR71605E Build version is < 30862! **Please update!** " }';
  fi
fi

echo -e '          [ ] Raider is configured and working properly'
  /usr/bin/raider --run-jobs

echo -e '          [ ] StorMan removed'
  if [[ -x /usr/bin/systemctl ]]; then
    systemctl stop stor_agent; systemctl disable stor_agent; systemctl status stor_agent
  else
    /etc/init.d/stor_agent stop; chkconfig stor_agent off; /etc/init.d/stor_agent status
  fi
fi

echo -e '\n    [ ]Drive Size';
  fdisk -l 2>/dev/null | grep -i disk./dev;

echo -e '\n    [ ]RAM';
  free -m;

echo -e '\n    [ ]Partitioning';
  lsblk;

if [[ -f /etc/redhat-release && $(cat /etc/redhat-release | grep ' 6\.') ]]; then
  echo -e '\n[ ]e1000e kmod update per wiki, if Cent6 and intel e1000e driver is in use.'
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

if [[ -d /usr/local/cpanel/ ]]; then
echo -e '\n    [ x]Cpanel/Non-Cpanel'
echo -e '\n          [ ] If cPanel, make sure the server has a full license.'
  /usr/local/cpanel/cpkeyclt
  if [[ $(df | grep /backup) ]]; then
    echo -e '\n          [ x] Disable cPanel Backups if no backup drive was ordered.'
  fi

  if [[ $(ip a | egrep ' 192\.| 10\.') ]]; then
  echo -e '\n          [ ] Private IP addresses are marked as reserved.'
    if [[ ! -s /etc/reservedips ]]; then
    mkdir -p /root/bin;
    wget -qO /root/bin/reserveips http://scripts.ent.liquidweb.com/reserveips;
    chmod +x /root/bin/reserveips;
    reserveips
    else
      cat /etc/reservedips
    fi
  fi

  if [[ $(ip a | grep ' 172\.') ]]; then
    echo -e '\n          [ ] If servers are behind hardware FW, make sure the UDP inspection policy is set to "maximum client auto" ** poke networking or check in NOC **'
  fi
fi

echo -e '\n    [ ]Complex Root or User Passwords are setup
           "pwgen -syn 15 1" or longer
        [ ]Cable runs requested and acknowledged by Maintenance
        [ ]IPMI - Verified working.'

if [[ -f /usr/sbin/r1soft/log/cdp.log ]]; then
  echo -e "\nGuardian"
  echo -e "[ ]buagent or cdp-agent is installed and running (/etc/init.d/cdp-agent status)"
    /etc/init.d/cdp-agent status

  echo -e "[ ]Port 1167 open/allowed in the software firewall."
    iptables -nL | grep :1167

  echo -e "[ ]Make sure the proper partitions are being backed up via the web interface."
  echo -e "[ ]If there a Dedicated MySQL drive make sure it is setup to be backed up."
    mysqldata=$(mysql -Ne 'select @@datadir' | sed 's|/$||g')
    if [[ $(grep $mysqldata /etc/fstab) ]]; then echo "Dedicated MySQL Drive :: Make sure to check this in Guardian"; fi

  echo -e "[ ]Verify that backups complete"
  echo -e "[ ]Make sure Guardian monitoring is enabled on the Guardian subaccount"
fi

echo -e "\n[ ]Remote IP override module installed or updated if applicable"
echo -e "          [ ]mod_zeus if Apache 2.2"
  if [[ $(httpd -v) =~ 2\.2 ]]; then httpd -M 2> /dev/null | grep zeus; fi
echo -e "          [ ]mod_remoteip if Apache 2.4"
  if [[ $(httpd -v) =~ 2\.4 ]]; then httpd -M 2> /dev/null | grep remote; fi

echo -e '\n[ ]SonarPush is installed and working properly'
if [[ -f /usr/local/lp/etc/sonar_password ]]; then
  echo 'Sonar is installed and configured. Check this using Radar link in Billing'
else
  echo -e 'Sonar password file missing :: /usr/local/lp/etc/sonar_password \nFix this if server is Managed. Ignore this if the server is Unmanaged'
fi

echo -e '\nMaintenance
[ x]Servers moved to correct building if necessary
[ x]Cable runs complete'

echo -e "\nNetworking"
echo -e "[ ]Public/NAT IPs Configured Correctly ***Consult the original CTB***"
  ip -o -4 a | grep -v ': lo';

echo -e "[ ]If required, verify that the servers are behind a FW."
  if [[ $(ip -o -4 a | grep ' 172\.') ]]; then echo "Behind NAT Firewall"; fi

echo -e "[ ]Private Switch/Networking"
echo -e "[ ]Load Balancing"
  httpd -M 2> /dev/null | egrep 'zeus|remote'

echo -e "[ ]IP Requests/VIPs"
echo -e "[ ]Confirm private network cables are plugged into switch/server (ip addr ls dev ethX)"
  for x in $(dmesg | grep -o eth. | sort | uniq); do
    printf "$x :: "; ethtool $x | grep -i link.detect;
  done

echo -e "\nMigrations
[ ]Migration ticket is open and owned by system-restore/migrations
[ ]Migration is scheduled and customer has been notified of time frame
[ ]Customer has confirmed that migration was successful"

if [[ ! -d /usr/local/cpanel ]]; then
  echo -e "\nSupport (For Managed and CoreManaged Customers) – Do requested versions match customer request:"
  echo -e "\n[ ]Apache"
    if [[ -x $(which httpd) ]]; then httpd -v 2> /dev/null; elif [[ -x $(which apache2) ]]; then apache2 -v 2> /dev/null; fi
  echo -e "\n[ ]MySQL"
    if [[ -x $(which mysql) ]]; then
      mysql --version
    fi
  echo -e '\n[ ]DNS/Nameservers as requested
[ ]ServerSecure
[ ]Email address for alerts is correct'

fi

echo -e "\nSpecial Software Requests
[ ] List any requests here. Example: FFMPEG, Tomcat, NGINX"

echo -e "\n$div\n"
