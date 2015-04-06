#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-01-01
# Updated: 2015-04-06
#
#
#!/bin/bash

_getusr(){ U=$(pwd | cut -d/ -f3); if [[ $U == "home" ]]; then U=$(pwd | cut -d/ -f4); fi; echo $U; }

_htpasswdauth (){
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
echo -e "\n Usage: htpasswdauth [-u|--user username] [-p|--pass password] [-l length]
    Ex: htpasswdauth -u username -p password
    Ex: htpasswdauth -u username -l 5
    Ex: htpasswdauth -u username\n"; return 0; fi

if [[ -z $1 ]]; then echo; read -p "Username: " U; elif [[ $1 == '-u' || $1 == '--user' ]]; then U="$2"; fi;
if [[ -z $3 ]]; then P=$(mkpasswd -l 12); elif [[ $3 == '-p' || $3 == '--pass' ]]; then P="$4"; elif [[ $3 == '-l' ]]; then P=$(mkpasswd -l $4); fi

# if [[ -f .htpasswd ]]; then htpasswd -mb .htpasswd $U $P; else htpasswd -cmb .htpasswd $U $P; fi;

echo "$U:$(echo $P | openssl passwd -stdin -apr1)" >> .htpasswd

echo -e "\nUsername: $U\nPassword: $P\n";
}
_htpasswdauth "$@"
