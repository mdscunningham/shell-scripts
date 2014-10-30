#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-27
# Updated: 2014-10-28
#
#
#!/bin/bash

if [[ -f $(echo /opt/nexcess/php5*/root/etc/php-fpm.d/$(getusr).conf) ]]; then
  config="/opt/nexcess/php5*/root/etc/php-fpm.d/$(getusr).conf";
  srv="$(echo $config | cut -d/ -f4)-php-fpm";
elif [[ -f /etc/php-fpm.d/$(getusr).conf ]]; then
  config="/etc/php-fpm.d/$(getusr).conf";
  srv="php-fpm"; fi;

if [[ $(grep zlib.output_compression $config 2> /dev/null) ]]; then
  echo -e "\nGzip already enabled in FPM pool $config\n";
elif [[ -f $(echo $config) ]]; then
  echo "php_admin_value[zlib.output_compression] = On" >> $config && service $srv reload && echo -e "\nGzip enabled in FPM pool for $config\n";
else
  echo -e "\n Could not find $config !\n Try running this from the user's /home/dir/\n"; fi;

unset config srv;
