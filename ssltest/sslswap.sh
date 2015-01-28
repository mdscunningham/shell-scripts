#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-11-21
# Updated: 2015-01-27
#
#
#!/bin/bash

# Development suggested by Lawrence Leverett
# Copy paste a new SSL and Chain Cert in temp files, then swap them in place and
# reload Apache, if the hashes are the same. The assumption is that you run this
# from the SSL directory for the domain in questions, so the script will get the
# domain from the path --> /chroot/home/username/var/domain.com/ssl/domain.com.*

domain=$(pwd -P | sed 's:/chroot::' | cut -d/ -f5)

nano ${domain}.new.crt ${domain}.new.chain.crt;
# ^^^ will update this later to just download the right chain crt given an SSL type
# For now, and for non-Comodo certs will just paste in the new chain crt.
# http://download.rensuchan.com/sslchains/
# https://support.comodo.com/index.php?/Default/Knowledgebase/Article/View/620/1/

keyhash=$(openssl rsa -noout -modulus -in ${domain}.priv.key | openssl md5 | awk '{print $2}')
crthash=$(openssl x509 -noout -modulus -in ${domain}.new.crt | openssl md5 | awk '{print $2}')

if [[ $keyhash != $crthash ]]; then
  rm ${domain}.new.crt ${domain}.new.chain.crt
  echo -e "\n[${BRIGHT}${RED}FAILED${NORMAL}] .. SSL does not match Priv.Key!\n\nPriv.Key [${YELLOW}$keyhash${NORMAL}]\nSSL.Cert [${YELLOW}$crthash${NORMAL}]\n";

else
  echo -e "\n[${BRIGHT}${GREEN}UPDATE${NORMAL}] .. SSL Certificate"
  rm ${domain}.crt 2> /dev/null; mv ${domain}{.new.crt,.crt}
  chmod 600 ${domain}.crt; chown iworx. ${domain}.crt

  # Check if new chain cert exists and is non-zero; then remove and replace the old one
  if [[ -f ${domain}.new.chain.crt && -n $(cat ${domain}.new.chain.crt 2> /dev/null) ]]; then
    echo "[${BRIGHT}${GREEN}UPDATE${NORMAL}] .. Chain Certificate"
    rm ${domain}.chain.crt 2> /dev/null; mv ${domain}{.new.chain.crt,.chain.crt}
    chmod 600 ${domain}.chain.crt; chown iworx. ${domain}.chain.crt
  fi

  # Check if new chain cert exists and is non-zero; then install new SSL with Chain, else exclude chain
  if [[ -f ${domain}.chain.crt && -n $(cat ${domain}.chain.crt 2> /dev/null) ]]; then
    sudo -u $(getusr) siteworx -unc Ssl -a install --domain $domain --chain 1
  else
    sudo -u $(getusr) siteworx -unc Ssl -a install --domain $domain --chain 0
  fi
  echo -e "[${BRIGHT}${GREEN}RELOAD${NORMAL}] .. SSL update successful\n"
  echo -e "\nhttps://www.sslshopper.com/ssl-checker.html#hostname=${domain}\n"

fi

