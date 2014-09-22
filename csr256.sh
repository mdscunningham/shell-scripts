#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-09-21
# Updated: 2014-09-21
#
#
#!/bin/bash

## A script for generating a sha256 CSR file using an existing Private Key and an existing CSR or CRT file.

read -p "Domain Name: " domain;

privkey="/home/*/var/${domain}/ssl/${domain}.priv.key"
csrfile="/home/*/var/${domain}/ssl/${domain}.csr"
crtfile="/home/*/var/${domain}/ssl/${domain}.crt"
newcsr="/home/*/var/${domain}/ssl/${domain}.sha256.csr"

if [[ -f $csrfile && -f $privkey ]]; then
  subject="$(openssl req -in $csrfile -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')"
  openssl req -nodes -sha256 -new -key $privkey -out $newcsr -subj ${subject} && cat $newcsr
elif [[ -f $crtfile && -f $privkey ]]; then
  subject="$(openssl x509 -in $crtfile -subject -noout | sed 's/^subject= //' | sed -n l0 | sed 's/$$//')"
  openssl req -nodes -sha256 -new -key $privkey -out $newcsr -subj ${subject} && cat $newcsr
else
  echo -e "\nNo CSR or CRT to souce from!\n"
fi

