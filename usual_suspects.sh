#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-28
# Updated: 2014-08-28
#
#
#!/bin/bash

usual_suspects(){
  ## Taste the rainbow!
      BLACK=$(tput setaf 0);        RED=$(tput setaf 1)
      GREEN=$(tput setaf 2);     YELLOW=$(tput setaf 3)
       BLUE=$(tput setaf 4);    MAGENTA=$(tput setaf 5)
       CYAN=$(tput setaf 6);      WHITE=$(tput setaf 7)

     BRIGHT=$(tput bold);        NORMAL=$(tput sgr0)
      BLINK=$(tput blink);      REVERSE=$(tput smso)
  UNDERLINE=$(tput smul)

# nodeworx -u -n -c Health -a listHealthStatus | awk '{print $1,$3}' | sed 's/0/OK/g;s/1/BAD/g;s/2/N\/A/g' | column -t

## shortcut for printing dashes
dash(){ for ((i=1; i<=$1; i++)); do printf "-"; done; }

## shortcut for looking up pid start times/dates
pid_start(){ ps -o lstart --pid=$(pgrep $1 | head -1) 2> /dev/null | tail -1; }

if [[ $@ =~ -h ]]; then
  echo -e "\n  Usage: usual_suspects [linecount] [option]\n\n Options:
    -q|--quiet .... Skip sar and Magento log output
    -v|--verbose .. Also display users at or near disk quota
    -h|--help ..... Show this help output and exit\n";
  return 0;
fi

if [[ $1 =~ [0-9].*$ ]]; then linecount=$1; else linecount=10; fi

## Simple Service Check (web, php, mysql, dns)
echo
FORMAT="%-10s %-26s %s\n";
printf "$FORMAT" " Service" " Started" " Status";
printf "$FORMAT" "--Core----" "$(dash 26)" "$(dash 42)";

# Need to make sure lsws exist and it's configured to run
# if [[ -x /etc/init.d/lsws && $(chkconfig --list | grep lsws.*3:on) ]]; then
# ^^^ Should switch to this if it works right.
if [[ -f /etc/init.d/lsws ]]; then
	printf "$FORMAT" " LiteSpeed" " $(pid_start lite)" " LiteSpeed (pid $(echo $(pgrep lite))) is running ..."
else
	printf "$FORMAT" " Apache" " $(pid_start httpd)" " $(service httpd status)";
fi;

if [[ -f /etc/init.d/php-fpm ]]; then
	printf "$FORMAT" " PHP-FPM" " $(pid_start php-fpm)" " $(service php-fpm status)";
fi;

printf "$FORMAT" " MySQL" " $(pid_start mysqld)" " $(service mysqld status | sed s/' SUCCESS! '//g)";
printf "$FORMAT" " Memcache" " $(pid_start memcached)" " $(service memcached-multi status | head -1)";
printf "$FORMAT" " DJBDNS" " $(pid_start tinydns)" " TinyDNS is$(service djbdns status | head -n1 | awk -F: '{print $2}')";
printf "$FORMAT" " ProFTP" " $(pid_start proftpd)" " $(service proftpd status)";

printf "$FORMAT" "--Mail----" "$(dash 26)" "$(dash 42)";
printf "$FORMAT" " ClamAV" " $(pid_start clamd)" " $(service clamd status)";
printf "$FORMAT" " SMTP" " $(pid_start send)" " SMTP is$(service smtp status | head -n1 | awk -F: '{print $2}')";
printf "$FORMAT" " POP3" " $(ps -o lstart --pid=$(service pop3-ssl status | grep -Eo '[0-9]{2,}\)' | tr -d \) ) | tail -1)" " pop3-ssl$(service pop3-ssl status | awk -F: '{print $2}')";
printf "$FORMAT" " IMAP4" " $(ps -o lstart --pid=$(service imap4-ssl status | grep -Eo '[0-9]{2,}\)' | tr -d \) ) | tail -1)" " imap4-ssl$(service imap4-ssl status | awk -F: '{print $2}')";

printf "$FORMAT" "--Other---" "$(dash 26)" "$(dash 42)";
printf "$FORMAT" " SNMP" " $(pid_start snmpd)" " $(service snmpd status)";
printf "$FORMAT" " Iworx" " $(pid_start iworx)" " $(service iworx status)";

## Check if /var /tmp /chroot are full
echo -e "\nDisk Space and Inode Usage:"; dash 80; echo;
for ((i=1 ; i<=$(df | wc -l) ; i++)); do
	DF="$(df -h | head -n$i | tail -n1 | awk '{printf "%-12s %-6s %-6s %-6s %-5s",$1,$2,$3,$4,$5}')";
	DI="$(df -i | head -n$i | tail -n1 | sed 's/ounted on/ounted_on/g' | awk '{printf "%-9s %-9s %-9s %-6s %s",$2,$3,$4,$5,$6}')";
	if [[ $DF =~ [8,9][0-9]\% || $DF =~ 1[0-9]{2}\% || $DI =~ [8,9][0-9]\% || $DI =~ 1[0-9]{2}\% ]]; then color="${BRIGHT}${RED}"; else color=''; fi
	echo -n "${color}${DF} | "; echo "${color}${DI}${NORMAL}"
done

## Check if the server hit Apache MaxClients or PHP-FPM max_children
# Look for Apache MaxClients errors
if grep -qi maxclients /var/log/httpd/error_log 2> /dev/null; then
	echo -e "\nLast $linecount times httpd hit MaxClients"; dash 80; echo;
	grep -i maxclients /var/log/httpd/error_log | tail -n$linecount;

	echo -e "\nCount per day httpd hit MaxClients"; dash 80; echo;
	grep -i maxclients /var/log/httpd/error_log | cut -d' ' -f1,2,3,5- | sort | uniq -c;
fi

# Look for PHP-FPM max_children errors
if [[ -f /var/log/php-fpm/error.log ]]; then
   if grep -qi max_children /var/log/php-fpm/error.log 2> /dev/null; then
	echo -e "\nMax_Kids: Last ($linecount) Errors"; dash 80; echo;
	grep -i max_children /var/log/php-fpm/error.log | tail -n$linecount;

	echo -e "\nMax_Kids: Count/User/Day"; dash 80; echo;
	grep -i max_children /var/log/php-fpm/error.log | cut -d' ' -f1,5- | sort | uniq -c;
  fi;
fi

if [[ ! $@ =~ -q ]]; then
## Check sar for high ram or cpu usage
    echo -e "\nRecent processer load"; dash 80; echo;
	sar -p | pee "head -n3 | tail -n1" "tail -n$linecount";
    echo -e "\nRecent ram usage"; dash 80; echo;
	sar -r | pee "head -n3 | tail -n1" "tail -n$linecount";

## If you're in a html directory then check the Magento logs
    if [[ -f app/etc/local.xml ]]; then
	echo -e "\nRunning crons from this user:"; dash 80; echo;
	ps aux | head -1; ps aux | awk "(\$1 ~ /$(pwd | sed 's:^/chroot::' | cut -d/ -f3)/) && /cron/"'{print}'; echo
    fi;
    if [[ -f var/log/system.log ]]; then
	echo -e "\nMagento System.log"; dash 80; echo;
	tail -n$linecount var/log/system.log 2> /dev/null; echo;
    fi;
    if [[ -f var/log/exception.log ]]; then
	echo -e "\nMagento Exception.log"; dash 80; echo;
	tail -n$linecount var/log/exception.log 2> /dev/null; echo;
    fi;
fi;

## If using verbose to check user quotas
if [[ $@ =~ -v ]]; then
## Check if any user is having a quota issue
_quotaheader(){ printf "\n%8s %12s %14s %14s\n" "Username" "Used(%)" "Used(G)" "Total(G)"; dash 80; };
_quotausage(){ printf "\n%-10s" "$1"; quota -g $1 2> /dev/null | tail -1 | awk '{printf "%10.3f%%  %10.3f GB  %10.3f GB",($2/$3*100),($2/1000/1024),($3/1000/1024)}' 2> /dev/null; };
_quotaheader; echo; for x in $(~iworx/bin/listaccounts.pex | awk '{print $1}'); do _quotausage $x; done | sort | grep -E '[9][0-9]\..*%|1[0-9]{2}\..*%';
fi;
echo;

}

usual_suspects $@
