#!/bin/bash
dbz(){ DBUSER="$(awk -F= '/user/ {print $2}' /root/.mytop)"; DBPASS="$(awk -F= '/pass/ {print $2}' /root/.mytop)";
  mysqldump --opt --skip-lock-tables -u "$DBUSER" -p"$DBPASS" ${1} > ./nex-db-backups/${1}.$(date +%Y-%m-%d).sql.gz; }

sitecopy(){
USERNAME="$(pwd | sed 's:^/chroot::' | cut -d/ -f3)"
local OPTIND
while getopts w:t:dlvhs option; do
  case "${option}" in
    t) TARGET="${OPTARG}" ;;
    l) LIVE='1' ;;
    d) echo; mkdir nex-db-backups;
       for x in $(sudo -u $USERNAME siteworx -unc MysqlDb -a list | awk '{print $2}'); do
         echo "Backing up $x ..."; dbz $(echo "$x" | cut -d/ -f5);
       done && chown -R ${USERNAME}. nex-db-backups ;;
    v) echo -e "\nBacking up var directory ..."; tar -czpf var.tar.gz var/ && chown $USERNAME. var.tar.gz ;;
    w) REMOTE="${OPTARG}"; echo -e "\n# $USERNAME (Mysql to $REMOTE)\nd=3306:d=$(dig +short $REMOTE)" | tee -a /etc/apf/allow_hosts.rules; apf -r ;;
    s) ~iworx/bin/backup.pex --structure-only --domains=$(~iworx/bin/listaccounts.pex | awk  "(\$1 ~ /$USERNAME/)"'{print $2}') --output-dir=$(pwd) ;;
    h) echo -e "\n  Usage: ./migrate.sh [options]
    -s .. create structure backup
    -t <host> .. target server name
    -w <host> .. whitelist for mysql out
    -d .. backup databases
    -v .. backup var directory
    -l .. live transfer
    -h .. print this help and quit\n"; return 0 ;;
  esac
done; echo

if [[ $LIVE != '1' && -n $TARGET ]]; then
  echo -e "PERFORMING DRY-RUN OF RSYNC\n"
  sudo -u $USERNAME rsync -p --dry-run -v -e ssh -a -u -z ./ $USERNAME@$TARGET:/home/$USERNAME
elif [[ $LIVE == '1' && -n $TARGET ]]; then
  echo -e "PERFORMING LIVE RSYNC\n"
  sudo -u $USERNAME rsync --exclude ./var --exclude iworx-backup -p -v -e ssh -a -u -z ./ $USERNAME@$TARGET:/home/$USERNAME
  echo -e "Cleaning up var and db backups ...\n"; rm -r nex-db-backups var.tar.gz 2> /dev/null; echo -e "Done!\n"
fi

unset USERNAME TARGET REMOTE LIVE
}

sitecopy "$@"
