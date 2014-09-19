#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-24
# Updated: 2014-08-07
#
#
#!/bin/bash

getusr(){ F=3; if [[ $PWD =~ ^\/chroot ]]; then F='4'; fi; pwd | cut -d/ -f$F; }

_whitelist(){
local cur prev opts base
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="ftp mysql other ssh -h --help"

case ${prev} in
    f|ftp|m|mysql|o|other )
        COMPREPLY=( $(compgen -W "in out" -- ${cur}) )
        return 0 ;;
    *) ;;
esac

COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
return 0;
}
complete -F _whitelist whitelist;

whitelist(){
if [[ "$2" == "in" ]]; then SRC="d="; DST="s=";
elif [[ "$2" == "out" ]]; then SRC="d="; DST="d=";
else SRC=""; DST=""; fi; HOST="$3"; CMNT="$4"; TYPE=""

_addrule(){
# Add comment line if it's not in the config file yet
echo; if ! grep -q "^\#.*$(getusr)" $CONFIG; then echo -e "\n# $(getusr)" >> $CONFIG; fi

# Have to use | instead of / in the sed here and below, so the : and / do not cause sed errors
# The : would cause the firewall lists (d=X:s=Y) to fail, and / causes CIDR (10.0.0.0/24) to fail
for x in $HOST;
    do echo "${SRC}${PORT}${DST}${x} .. added to $CONFIG";
    sed -i "s|\(^\#.*$(getusr).*$\)|\1\n${SRC}${PORT}${DST}${x}|" $CONFIG
  done;

# Add type and ticket ID last so it's at the top of the list area
sed -i "s|\(^\#.*$(getusr).*$\)|\1\n# ${TYPE} ${CMNT}|" $CONFIG;

echo; if [[ "$SRC" != "sshd" ]]; then service apf restart; echo; fi;
echo -e "\nHello,\n\nI have white-listed the requested IP address(es) ( $(for x in $HOST; do printf "$x, "; done)) for $TYPE access on $(hostname).\nYou should be all set. Please let us know if you need any further assistance.\n\nSincerely,\n"
}

case $1 in
  f|ftp ) CONFIG='/etc/apf/allow_hosts.rules'; TYPE="(FTP $2)"; PORT="21:"; _addrule ;;
  m|mysql ) CONFIG='/etc/apf/allow_hosts.rules'; TYPE="(MySQL $2)"; PORT="3306:"; _addrule ;;
  o|other ) CONFIG='/etc/apf/allow_hosts.rules'; TYPE="(port $4 $2)"; PORT="${4}:"; CMNT="$5" ; _addrule ;;
  s|ssh )
    CONFIG='/etc/hosts.allow'; if [[ "$2" != "in" && "$2" != "out" ]]; then HOST="$2"; CMNT="$3"; fi; TYPE="(SSH/SFTP)"; SRC="sshd"; DST=": "; PORT=""; _addrule
    echo "Adding whitelist in APF for forward compatability."
    CONFIG='/etc/apf/allow_hosts.rules'; if [[ "$2" != "in" && "$2" != "out" ]]; then HOST="$2"; CMNT="$3"; fi; TYPE="(SSH/SFTP)"; SRC="d="; DST="s="; PORT="22:"; _addrule
    ;;
  -h|--help|*) echo -e "\n Usage: whitelist [ftp|mysql|ssh|other] [in|out] <ip/host> [port#] [comment]
    Ex: whitelist ssh \"10.0.0.1 10.0.1.1 10.1.1.1\" ABCD-1234
    Ex: whitelist mysql in 10.0.0.2 EFGH-5678
    Ex: whitelist other out 10.0.0.3 1187 IJKL-6543\n" ;;
esac
}
whitelist "$@"
