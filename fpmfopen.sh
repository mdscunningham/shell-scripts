#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-10-18
# Updated: 2014-10-29
#
#
#!/bin/bash

if [[ -f $(echo /opt/nexcess/php5*/root/etc/php-fpm.d/$(getusr).conf) ]]; then
  config="/opt/nexcess/php5*/root/etc/php-fpm.d/$(getusr).conf";
  srv="$(echo $config | cut -d/ -f4)-php-fpm";
elif [[ -f /etc/php-fpm.d/$(getusr).conf ]]; then
  config="/etc/php-fpm.d/$(getusr).conf";
  srv="php-fpm"; fi;

if [[ $(grep allow_url_fopen $config 2> /dev/null) ]]; then
  echo -e "\nallow_url_fopen already enabled in FPM pool $config\n";
elif [[ -f $(echo $config) ]]; then
  echo "php_admin_value[allow_url_fopen] = On" >> $config && service $srv reload && echo -e "\nallow_url_fopen enabled in FPM pool for $config\n";
else
  echo -e "\n Could not find $config !\n Try running this from the user's /home/dir/\n"; fi;

unset srv config;
