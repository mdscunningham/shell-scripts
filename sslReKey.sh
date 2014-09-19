#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-04-09
# Updated: 2014-04-12
#
#
#!/bin/bash

# https://raymii.org/s/snippets/OpenSSL_generate_CSR_non-interactivemd.html (create csr's from the commandline)
# [X] https://langui.sh/2009/02/27/creating-a-subjectaltname-sanucc-csr/ (Multidomain CSRs)
# [X] https://langui.sh/2009/02/28/openssl-sanucc-certificate-generation/ (Adding to an existing CSR)
# [!] http://apetec.com/support/GenerateSAN-CSR.htm

for x in /home/*/var/*/ssl/*.csr; do
  _domain=$(basename $x .csr)
  _csrfile=$(basename $x)
  _keyfile="${_domain}.priv.key"
  _subject="$(openssl req -in ${x} -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')"

  mkdir $_domain
  openssl req -nodes -sha256 -newkey rsa:2048 -keyout ${_domain}/${_keyfile} -out ${_domain}/${_csrfile} -subj "$_subject"
done

#### Generate Multidomain CSR using config file and existing CSR
# openssl req -new -key ${domain}.priv.key -out ${domain}.new.csr -config ${domain}.cnf\
# -subj "$(openssl req -in ${domain}.csr -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')"
#
#### Generate self-signed Multidomain SSL using config file
# openssl x509 -req -days 3650 -in robotzombies.net.csr -signkey robotzombies.net.priv.key -out robotzombies.net.crt2 -extensions v3_req -extfile robotzombies.net.cnf
#
