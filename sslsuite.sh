#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-09-21
# Updated: 2014-09-21
#
#
#!/bin/bash

# --------------------------------------------------------------------------------
#
# A suite of tools for generating and managing SSLs and their various parts
#
# --------------------------------------------------------------------------------

newkey="${domain}.priv.key"; newcsr="${domain}.csr";
pfxfile="${domain}.pfx"; pemfile="${domain}.pem"

keyfile="/home/*/var/${domain}/ssl/${domain}.priv.key"
cstfile="/home/*/var/${domain}/ssl/${domain}.csr"
crtfile="/home/*/var/${domain}/ssl/${domain}.crt"
chaincrt="/home/*/var/${domain}/ssl/${domain}.chain.crt"


opt=$1; shift;


# --------------------------------------------------------------------------------
## Comparison of SSL parts to see what matches.

## MD5 KEY
# openssl rsa -noout -modulus -in privateKey.key | openssl md5

## MD5 CRT
# openssl x509 -noout -modulus -in certificate.crt | openssl md5

## MD5 CSR
# openssl req -noout -modulus -in CSR.csr | openssl md5
# --------------------------------------------------------------------------------


# --------------------------------------------------------------------------------
## Check SSL loading on a domain (subject and issuer)
chk | check )
echo | openssl s_client -connect ${1}:${2:-443} -nbio 2> /dev/null | grep -E 'subject|issuer'\
 | sed 's:/:\n:g;s/subject=/\nSubject:/;s/issuer=/\nIssuer:/;s/=/: /g'; echo
;;
# --------------------------------------------------------------------------------


# --------------------------------------------------------------------------------
## Decoding CRT and CSR to display content
dec | decode )
  if [[ $1 == '-crt' ]]; then # Decode CRT
    echo; file=$2; openssl x509 -in $file -text -noout | grep -E 'Subject:|DNS:'\
    | sed 's/.*C=/C=/g;s/, /\n/g;s/: /\n/g;s/\//\n/g;' | sed 's/.*DNS/DNS/g'; echo

  elif [[ $1 == '-csr' ]]; then # Decode CSR
    echo; file=$2; openssl req -in $file -noout -text | grep -E 'Subject:|DNS:'\
    | sed 's/.*C=/C=/g;s/, /\n/g;s/: /\n/g;s/\//\n/g;' | sed 's/.*DNS/DNS/g'; echo

  fi
  ;;
# --------------------------------------------------------------------------------


# --------------------------------------------------------------------------------
## Conversions
con | convert )
  if [[ $1 == '-pfx' ]]; then # Make PFX from PEM parts
    openssl pkcs12 -export -in $crtfile -inkey $keyfile -out $domain.pfx -certfile $chaincrt
    echo -e "\nPFX File: ${PWD}$domain.pfx\n";

  elif [[ $1 == '-pem' ]]; then # Make PEM from PFX
    pfxfile=$2; openssl pkcs12 -in $pfxfile -out $domain.pem -nodes
    echo -e "\nPEM File: ${PWD}$domain.pem\n"; cat $domain.pem

  fi
  ;;
# --------------------------------------------------------------------------------


# --------------------------------------------------------------------------------
gen | generate )
  if [[ $1 == '-key' ]]; then # Generate a Private Key
    openssl genrsa -nodes -out $keyfile 2048
  elif [[ $1 == '-csr' ]]; then # Generate a CSR

  elif [[ $1 == '-csr' && $2 == '-san' ]]; then # Generate SAN CSR

# --------------------------------------------------------------------------------
## Create SAN CSR (include domains in the request file)
  # download template
  # forloop do echo "DNS.${i}=$x" >> $csrconf
  # gemerate new csr using privkey and conf file.


csrconf="/home/*/${domain}/ssl/${domain}.csr.conf"
newcsr="${domain}.SAN.csr"
wget -q -O $crtconf http://nanobots.robotzombies.net/ssltest/csr.conf

#### Generate Multidomain CSR using config file and existing CSR
openssl req -sha256 -new -key $keyfile -out $newcsr -config $csrconf\
 -subj "$(openssl req -in ${domain}.csr -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')"

#### Generate Multidomain CSR using config file and existing CRT
openssl req -sha256 -new -key $keyfile -out $newcsr -config $csrconf\
 -subj "$(openssl x509 -in ${domain}.crt -subject -noout | sed 's/^subject= //' | sed -n l0 | sed 's/$$//')"
# --------------------------------------------------------------------------------

  fi
  ;;
# --------------------------------------------------------------------------------


# --------------------------------------------------------------------------------
#Self-Sign CRT (NO CSR Needed)
ss | seflsign )
if [[ ! -f $keyfile ]]; then
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout $keyfile -out $crtfile
elif [[ -f $keyfile && -f $csrfile ]]; then
  openssl x509 -req -days 3650 -in $csrfile -signkey $keyfile -out $crtfile
elif [[ -f $keyfile && -f $csrfile  && $1 == '-san' ]]; then

# --------------------------------------------------------------------------------
## Self-Sign SAN CRT (add domains at signing)
crtconf="/home/*/${domain}/ssl/${domain}.crt.conf"
newcrt="${domain}.SAN.crt"
wget -q -O $crtconf http://nanobots.robotzombies.net/ssltest/crt.conf

#### Generate self-signed Multidomain SSL using config file
openssl x509 -req -days 3650 -in $csrfile -signkey $keyfile -out $newcrt -extensions v3_req -extfile $crtconf
echo -e "\nNew CRT: $newcrt\n"; cat $newcrt; echo
# --------------------------------------------------------------------------------

else
  echo -e "\nKey file exists but there is no CSR!\n"
fi
;;
# --------------------------------------------------------------------------------


# --------------------------------------------------------------------------------
## ReyKey CSR
rk | rekey )
csrfile="/home/*/var/${domain}/ssl/${domain}.csr"
crtfile="/home/*/var/${domain}/ssl/${domain}.crt"

if [[ -f $csrfile ]]; then
  subject="$(openssl req -in $csrfile -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')"
  openssl req -nodes -sha256 -newkey rsa:2048 -keyout $newkey -out $newcsr -subj $subject
  echo -e "\nNew KEY: ${PWD}$newkey\nNew CSR: ${PWD}$newcsr\n"; cat $newcsr; echo
elif [[ -f $crtfile ]]; then
  subject="$(openssl x509 -in $crtfile -subject -noout | sed 's/^subject= //' | sed -n l0 | sed 's/$$//')"
  openssl req -nodes -sha256 -newkey rsa:2048 -keyout $newkey -out $newcsr -subj $subject
  echo -e "\nNew KEY: ${PWD}$newkey\nNew CSR: ${PWD}$newcsr\n"; cat $newcsr; echo
else
  echo -e "\nNo CSR/CRT to souce from!\n"
fi
;;
# --------------------------------------------------------------------------------


# --------------------------------------------------------------------------------
## ReyHash CSR
rh | rehash )
newcsr="/home/*/var/${domain}/ssl/${domain}.sha256.csr"
if [[ -f $csrfile && -f $keyfile ]]; then
  subject="$(openssl req -in $csrfile -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')"
  openssl req -nodes -sha256 -new -key $keyfile -out $newcsr -subj $subject
  echo -e "\nNew CSR: ${PWD}$newcsr\n"; cat $newcsr; echo
elif [[ -f $crtfile && -f $filekey ]]; then
  subject="$(openssl x509 -in $crtfile -subject -noout | sed 's/^subject= //' | sed -n l0 | sed 's/$$//')"
  openssl req -nodes -sha256 -new -key $keyfile -out $newcsr -subj $subject
  echo -e "\nNew CSR: ${PWD}$newcsr\n"; cat $newcsr; echo
else
  echo -e "\nNo CSR/CRT to souce from, or no PRIV.KEY!\n"
fi
;;
# --------------------------------------------------------------------------------


