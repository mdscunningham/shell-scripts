#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-30
# Updated: 2014-11-02
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
elif [[ -d /usr/lib64/php/modules/ ]]; then # CentOS 6
  phpdir="/usr/lib64/php/modules/"; config="/etc/php.d/ioncube-loader.ini"
fi

# Copy the correct .so driver file to the target directory
if [[ -f ${phpdir}ioncube.so ]]; then
  echo -e "\n${phpdir}ioncube.so driver file exist, backing up before continuing\n"
  cp ~/downloads/ioncube/ioncube_loader_lin_${ver}* ${phpdir}
  gzip ${phpdir}ioncube.so && mv ${phpdir}ioncube_loader_lin_${ver}.so ${phpdir}ioncube.so
elif [[ -f ${phpdir}ioncube_loader_lin_${ver}.so ]]; then
  echo -e "\n${phpdir}ioncube_loader_lin_${ver}.so driver file exists, backing up before updating.\n"
  gzip ${phpdir}ioncube_loader_lin_${ver}* && cp ~/downloads/ioncube/ioncube_loader_lin_${ver}* ${phpdir}
fi

# Create correct config file for the service if necessary
if [[ -f ${config} ]]; then
  echo -e "${config} file already exists!\n";
else
  echo -e "Setting up new /etc/php.d/ioncube-loader.ini file\n"
  echo -e "zend_extension=${phpdir}ioncube_loader_lin_${ver}.so" >> /etc/php.d/ioncube-loader.ini;
fi

# Check configs and restart php/httpd services
if [[ -d /etc/php-fpm.d/ ]]; then
  php -v && service php-fpm restart
else
  php -v && httpd -t && service httpd restart;
fi
