#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-10-16
# Updated: 2014-10-16
#
#
#!/bin/bash

# Create DCV txt file for domain validation when ordering an SSL

if [[ -z $1 ]]; then read -p "Domain: " domain; else domain=$1; fi
md5=$(openssl req -noout -modulus -in /home/*/var/${domain}/ssl/${domain}.csr | openssl md5 | awk '{print $2}' | sed 's/\(.*\)/\U\1/g');
sha1=$(openssl req -noout -modulus -in /home/*/var/${domain}/ssl/${domain}.csr | openssl sha1 | awk '{print $2}' | sed 's/\(.*\)/\U\1/g');
echo -e "${sha1}\ncomodoca.com" >> ${md5}.txt
