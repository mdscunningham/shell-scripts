#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-09
# Updated: 2014-04-12
#
#
#!/bin/bash

source /home/robotzom/nanobots.robotzombies.net/html/colors.sh
NAME="$1"; nano "$NAME.priv.key" "$NAME.crt" "$NAME.csr"; FORMAT="%-32s: %s\n"

_sslhash(){ openssl $HASHTYPE -noout -modulus -in $FILE | openssl md5 | awk '{print $2}'; }
_ssldisp(){ printf "$FORMAT" "${YELLOW}$1${NORMAL}" "$(echo $FILE | sed 's/_tmp.//g')"; }

echo
for FILE in $NAME.*; do
  if [[ "$FILE" == *crt* ]]; then HASHTYPE="x509"
    elif [[ "$FILE" == *key* ]]; then HASHTYPE="rsa"
    elif [[ "$FILE" == *csr* ]]; then HASHTYPE="req"
    else echo "$FILE does not appear to be an SSL file"
  fi
  case $HASHTYPE in
    x509) CRT=$(_sslhash); _ssldisp $CRT ;;
    rsa ) KEY=$(_sslhash); _ssldisp $KEY ;;
    req ) CSR=$(_sslhash); _ssldisp $CSR ;;
  esac
done

echo "${BRIGHT}"
if [[ $KEY != $CRT ]]; then echo "${RED}SSL does not match Key file."; else echo "${GREEN}SSL and Key match."; fi
if [[ $KEY != $CSR ]]; then echo "${RED}CSR does not match Key file."; else echo "${GREEN}CSR and Key match."; fi
if [[ $CSR != $CRT ]]; then echo "${RED}SSL does not match CSR file."; else echo "${GREEN}SSL and CSR match."; fi

echo -e "\n${NORMAL}SSL hash comparison completed."
read -p "Clean up temporary files? [y/n]: " yn
if [[ $yn == "y" ]]; then rm $NAME.* && echo -e "Cleanup finished.\n"; else echo -e "Leaving temporary files.\n"; fi
