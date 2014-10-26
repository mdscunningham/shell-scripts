#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-30
# Updated: 2014-10-09
#
#
#!/bin/bash

if [[ $1 =~ [0-9]\.[0-9] ]]; then ver="$1";
else read -p "What is the running PHP version: " ver; fi

# Create Download Directory
if [[ ! -d ~/downloads ]]; then mkdir ~/downloads;
else rm -r ~/downloads; mkdir ~/downloads; fi

# Download archive into directory and unpack
cd ~/downloads/
wget -O ioncube_loaders_lin_x86-64.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -zxf ioncube_loaders_lin_x86-64.tar.gz; echo

# check for known configuration combinations
if [[ -f /etc/php.d/ioncube.ini && -f /usr/lib64/php5/ioncube.so ]]; then # CentOS 5
  phpdir="/usr/lib64/php5/"; config="/etc/php.d/ioncube.ini"
elif [[-d /usr/lib64/php/modules/ ]]; then # CentOS 6
  phpdir="/usr/lib64/php/modules/"; config="/etc/php.d/ioncube-loader.ini"
fi

# Copy the correct .so driver file to the target directory
if [[ ! -f ${phpdir}ioncube_loader_lin_${ver}.so ]]; then
  cp ~/downloads/ioncube/ioncube_loader_lin_${ver}* ${phpdir}
else echo -e "driver file already exists backing up before continuing.\n"
  gzip ${phpdir}ioncube_loader_lin_${ver}*;
  cp ~/downloads/ioncube/ioncube_loader_lin_${ver}* ${phpdir}
fi

# Create correct config file for the service
if [[ -f /etc/php.d/ioncube-loader.ini ]]; then
  echo -e "ioncube-loader.ini file already exists!\n";
elif [[ -f /etc/php.d/ioncube.ini ]]; then
  echo -e "ioncube.ini file exists, replacing with ioncube-loader.ini\n"; gzip /etc/php.d/ioncube.ini;
  echo -e "zend_extension=${phpdir}ioncube_loader_lin_${ver}.so" >> /etc/php.d/ioncube-loader.ini;
else
  echo -e "Setting up new ioncube-loader.ini file\n"
  echo -e "zend_extension=${phpdir}ioncube_loader_lin_${ver}.so" >> /etc/php.d/ioncube-loader.ini;
fi

# Check configs and restart php/httpd services
if [[ -d /etc/php-fpm.d/ ]]; then
  php -v && service php-fpm restart
else
  httpd -t && service httpd restart;
fi
