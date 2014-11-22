#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-11-21
# Updated: 2014-11-21
#
#
#!/bin/bash

# Development suggested by Lawrence Leverette
# Copy paste a new SSL and Chain Cert in temp files, then swap them in place and
# reload Apache, if the hashes are the same. The assumption is that you run this
# from the SSL directory for the domain in questions, so the script will get the
# domain from the path --> /chroot/home/username/var/domain.com/ssl/domain.com.*

domain=$(pwd -P | sed 's:/chroot::' | cut -d/ -f5)

sudo -u iworx -- nano ${domain}.new.crt ${domain}.new.chain.crt;
# ^^^ will update this later to just download the right chain crt given an SSL type
# For now, and for non-Comodo certs will just paste in the new chain crt.

keyhash=$(openssl rsa -noout -modulus -in ${domain}.priv.key | openssl md5 | awk '{print $2}')
crthash=$(openssl x509 -noout -modulus -in ${domain}.new.crt | openssl md5 | awk '{print $2}')

if [[ $keyhash != $crthash ]]; then
  echo "${BRIGHT}${RED}SSL does not match Key file.${NORMAL}";
else
  rm $domain.crt
  mv $domain{.new.crt,.crt}

  if [[ -n $(cat $domain.new.chain.crt) ]]; then
    rm ${domain}.chain.crt
    mv ${domain}{.new.chain.crt,.chain.crt}
  fi

  service httpd reload
fi

