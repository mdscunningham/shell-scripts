#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-05
# Updated: 2014-08-20
#
#
#!/bin/bash

if [[ $2 == 'all' ]]; then domain='';
elif [[ -n $2 ]]; then domain=$(echo $2 | sed 's:/::g');
else domain=$(pwd | sed 's:^/chroot::' | cut -d/ -f4); fi

if [[ -n $2 && ${#2} -gt 3 ]]; then
vhost=$(grep -l " $(echo $domain | sed 's/\(.*\)/\L\1/g')" /etc/httpd/conf.d/vhost_*);
unixuser=$(awk '/SuexecUserGroup/ {print $2}' $vhost | head -1);
else unixuser=$(getusr); fi

_localDeliveryCheck(){
echo -e "\n----- Local Delivery Status -----"
sudo -u $unixuser -- siteworx -u -n -c EmailRemotesetup -a listLocalDeliveryStatus | awk '{print $1,$NF}' | grep -E "^${domain}"\
 | sed "s/0$/${BRIGHT}${RED}Disabled${NORMAL}/g;s/1$/${BRIGHT}${GREEN}Enabled${NORMAL}/g" | column -t; echo
}

case $1 in
-c | --check) # Check
    _localDeliveryCheck ;;

-d | --disable) # Disable
    sudo -u $unixuser -- siteworx -u -n -c EmailRemotesetup -a disableLocalDelivery --domain ${domain}; _localDeliveryCheck ;;

-e | --enable) # Enable
    sudo -u $unixuser -- siteworx -u -n -c EmailRemotesetup -a enableLocalDelivery --domain ${domain}; _localDeliveryCheck ;;

-h | --help | *) # Help
    echo -e "\n  Usage: localDelivery [option] [domain]\n   Note: Run from user's /home/dir/\n
    -c | --check [domain|all] . Check Local Delivery status for domain(s)
    -d | --disable [domain] ... Disable Local Delivery for the domain
    -e | --enable [domain] .... Enable Local Delivery for the domain\n" ;;

esac
