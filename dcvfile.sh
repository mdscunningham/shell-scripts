#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-10-16
# Updated: 2014-12-15
#
#
#!/bin/bash

# Create DCV txt file for domain validation when ordering an SSL
# https://redkestrel.co.uk/articles/openssl-commands/ << OMG! OMG! OMG!
# https://redkestrel.co.uk/articles/openssl-commands/#convert-cert << Convert the PEM-CSR to a DER-CSR
# https://redkestrel.co.uk/articles/openssl-commands/#fingerprint << Find the MD5/SHA1 fingerprints of the DER-CSR

if [[ -z $1 ]]; then read -p "Domain: " domain;
elif [[ $1 == '.' ]]; then domain=$(pwd -P | sed 's:/chroot::' | cut -d/ -f4);
else domain=$1; fi;

csrfile="/home/*/var/${domain}/ssl/${domain}.csr"

if [[ -f $(echo $csrfile) ]]; then
  md5=$(openssl req -in $csrfile -outform DER | openssl dgst -md5 | awk '{print $2}' | sed 's/\(.*\)/\U\1/g');
  sha1=$(openssl req -in $csrfile -outform DER | openssl dgst -sha1 | awk '{print $2}' | sed 's/\(.*\)/\U\1/g');
  echo -e "${sha1}\ncomodoca.com" > ${md5}.txt; chown $(getusr). ${md5}.txt
else echo "Could not find csr for ${domain}!"; fi
