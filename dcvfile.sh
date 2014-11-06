#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-10-16
# Updated: 2014-11-02
#
#
#!/bin/bash

# Create DCV txt file for domain validation when ordering an SSL

if [[ -z $1 ]]; then read -p "Domain: " domain; else domain=$1; fi;
  crtfile="/home/*/var/${domain}/ssl/${domain}.csr"
if [[ -f $(echo $crtfile) ]]; then;
  mod="$(openssl req -noout -modulus -in $crtfile)";
  md5=$(echo $mod | openssl md5 | awk '{print $2}' | sed 's/\(.*\)/\U\1/g');
  sha1=$(echo $mod | openssl sha1 | awk '{print $2}' | sed 's/\(.*\)/\U\1/g');
  echo -e "${sha1}\ncomodoca.com" > ${md5}.txt
else echo "Could not find csr for ${domain}!"; fi
