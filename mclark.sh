# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Source nexcess functions
if [ -f /etc/nexcess/bash_functions.sh ]; then
        . /etc/nexcess/bash_functions.sh
fi

if [[ -n "$PS1" ]]; then ## --> interactive shell
  ## On first login, switch to root
    if [[ $UID != "0" ]]; then r; fi;
  NORMAL=$(tput sgr0); ## COLORS!
   BLACK=$(tput setaf 0);     RED=$(tput setaf 1);   GREEN=$(tput setaf 2);   YELLOW=$(tput setaf 3);
    BLUE=$(tput setaf 4);  PURPLE=$(tput setaf 5);    CYAN=$(tput setaf 6);    WHITE=$(tput setaf 7);
  BRIGHT=$(tput bold);      BLINK=$(tput blink);    REVERSE=$(tput smso);  UNDERLINE=$(tput smul);
  ## Once you switch to root, Lookup currently installed version of Iworx, and look to see who else is on the server
    if [[ $UID == "0" ]]; then
        IworxVersion=$(echo -n $(grep -A1 'user="iworx"' /home/interworx/iworx.ini | cut -d\" -f2 | sed 's/^\(.\)/\U\1/'));
        echo -e "\n$IworxVersion\nCurrent Users\n-------------\n$(w | grep -Ev '[0-9]days')\n"; fi;
fi

export PATH=$PATH:/usr/local/sbin:/sbin:/usr/sbin:/var/qmail/bin/:/usr/nexkit/bin
export GREP_OPTIONS='--color=auto'
export PAGER=/usr/bin/less

# formatted at 2000-03-14 03:14:15
export HISTTIMEFORMAT="%F %T "

if [ -e /usr/bin/vim ]; then
    export EDITOR=/usr/bin/vim
    export VISUAL=/usr/bin/vim
else
    export EDITOR=/bin/vi
    export VISUAL=/bin/vi
fi

# lulz
alias rtfm=man

# protect myself from myself
alias rm='rm --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# With -F, on listings append the following
#    '*' for executable regular files
#    '/' for directories
#    '@' for symbolic links
#    '|' for FIFOs
#    '=' for sockets
alias ls='ls -F --color=auto'

# only append to bash history to prevent it from overwriting it when you have
# multiple ssh windows open
shopt -s histappend
# save all lines of a multiple-line command in the same history entry
shopt -s cmdhist
# correct minor errors in the spelling of a directory component
shopt -s cdspell
# check the window size after each command and, if necessary, updates the values of LINES and COLUMNS
shopt -s checkwinsize
# add extended globing to bash to do regex pattern matching in file globs
shopt -s extglob

txtblk='\[\e[0;30m\]' # Black - Regular
txtred='\[\e[0;31m\]' # Red
txtgrn='\[\e[0;32m\]' # Green
txtylw='\[\e[0;33m\]' # Yellow
txtblu='\[\e[0;34m\]' # Blue
txtpur='\[\e[0;35m\]' # Purple
txtcyn='\[\e[0;36m\]' # Cyan
txtwht='\[\e[0;37m\]' # White
bldblk='\[\e[1;30m\]' # Black - Bold
bldred='\[\e[1;31m\]' # Red
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldblu='\[\e[1;34m\]' # Blue
bldpur='\[\e[1;35m\]' # Purple
bldcyn='\[\e[1;36m\]' # Cyan
bldwht='\[\e[1;37m\]' # White
unkblk='\[\e[4;30m\]' # Black - Underline
undred='\[\e[4;31m\]' # Red
undgrn='\[\e[4;32m\]' # Green
undylw='\[\e[4;33m\]' # Yellow
undblu='\[\e[4;34m\]' # Blue
undpur='\[\e[4;35m\]' # Purple
undcyn='\[\e[4;36m\]' # Cyan
undwht='\[\e[4;37m\]' # White
txtrst='\[\e[0m\]'    # Text Reset

if [ $UID = 0 ]; then
    # nexkit bash completion
     if [ -e '/etc/bash_completion.d/nexkit' ]; then
         source /etc/bash_completion.d/nexkit
     fi
    PS1="[${txtcyn}\$(date +%H%M)${txtrst}][${bldred}\u${txtrst}@\h \W]\$ "
else
    PS1="[${txtcyn}\$(date +%H%M)${txtrst}][\u@\h \W]\$ "
fi

# List functions within this bashrc file
alias wtf="grep -B1 '^[a-z].*(){' /home/nexmclark/.bashrc | sed 's/(){.*$//' | less"

## Send a bug report to Mark's email regarding a function in this bashrc
bugreport(){
echo -e "\nPlease include information regarding what you were trying to do, any files
you were working with, the command you ran, and the error you received. I will
try and get back to you with either an explanation or a fix, as soon as I can.\n
Once you save and exit this file, this message will be sent and this file removed.\n"
read -p "Script is paused, press [Enter] to begin editing the message ..."
echo -e "Bug Report (.bashrc): <Put the subject here>\n\nSERVER: $(serverName)\nUSER: $SUDO_USER\nPWD: $PWD\n$IworxVersion\n\nFiles:\n\nCommands:\n\nErrors:\n\n" > ~/tmp.file
nano ~/tmp.file && cat ~/tmp.file | mail -s "$(head -1 ~/tmp.file)" "mcunningham@nexcess.net" && rm ~/tmp.file
}

## Download and execute global-dns-checker script
dnscheck(){
    wget -q -O ~/dns-check.sh nanobots.robotzombies.net/dns-check.sh;
    chmod +x ~/dns-check.sh; ~/./dns-check.sh "$@"; }

## Check the Usual Suspects when things aren't working right
usual_suspects(){
    wget -q -O ~/usual_suspects.sh nanobots.robotzombies.net/usual_suspects.sh;
    chmod +x ~/usual_suspects.sh; ~/./usual_suspects.sh "$@"; }

## Function to print a number of dashes to the screen
dash(){ for ((i=1;i<=$1;i++)); do printf "-"; done; }

## Get the username from the PWD
getusr(){ pwd | sed 's:^/chroot::' | cut -d/ -f3; }

## Print the hostname if it resolves, otherwise print the main IP
serverName(){
  if [[ -n $(dig +time=1 +tries=1 +short $(hostname)) ]]; then hostname;
  else ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.' | head -1; fi
  }

## Print out most often accessed Nodeworx links
lworx(){
  echo; if [[ -z "$1" ]]; then (for x in siteworx reseller dns/zone ip;
  do echo "$x : https://$(serverName):2443/nodeworx/$x"; done; echo "webmail : https://$(serverName):2443/webmail") | column -t
  else echo -e "Siteworx:\nLoginURL: https://$(serverName):2443/siteworx/?domain=$1"; fi; echo
  }

## Find files in a directory that were modified a certain number of days ago
recmod(){
if [[ -z "$@" || "$1" == "-h" || "$1" == "--help" ]]; then
    echo -e "\n Usage: recmod [-p <path>] [days|{sequence}]\n  Note: Paths with * in them need to be quoted\n"; return 0;
elif [[ "$1" == "-p" ]]; then
   DIR="$2"; shift; shift; else DIR="."; fi;
for x in "$@"; do
  echo "Files modified within $x day(s) or $((${x}*24)) hours ago";
  find $DIR -type f -mtime $((${x}-1)) -exec ls -lath {} \; | grep -Ev '(var|log|cache|media|tmp|jpg|png|gif)' | column -t; echo;
done
}

## Rewrite of Ted Wells sinfo
sinfo(){
echo; FMT='%-14s: %s\n'
printf "$FMT" "OS (Kernel)" "$(cat /etc/redhat-release | awk '{print $1,$3}') ($(uname -r))"
ssl="$(openssl version | awk '{print $2}')"
web="$(curl -s -I $(serverName) | awk '/Server:/ {print $2}')";
if [[ -z $web ]]; then web="$(curl -s -I $(serverName):8080 | awk '/Server:/ {print $2}')"; fi
if [[ $web =~ Apache ]]; then webver=$(httpd -v | head -1 | awk '{print $3}' | sed 's:/: :');
elif [[ $web =~ LiteSpeed ]]; then webver=$(/usr/local/lsws/bin/lshttpd -v | sed 's:/: :');
elif [[ $web =~ nginx ]]; then webver=$(nginx -v 2>&1 | head -1 | awk '{print $3}' | sed 's:/: :'); fi
printf "$FMT" "Web Server" "$webver; OpenSSL ($ssl)"
if [[ -f /etc/init.d/varnish ]]; then printf "$FMT" "Varnish" "$(varnishd -V 2>&1 | awk -F- 'NR<2 {print $2}' | tr -d \))"; fi
_phpversion(){
    phpv=$($1 -v | awk '/^PHP/ {print $2}');
    zend=$($1 -v | awk '/Engine/ {print "; "$1,$2" ("$3")"}' | sed 's/v//;s/,//');
    ionc=$($1 -v | awk '/ionCube/ {print "; "$3" ("$6")"}' | sed 's/v//;s/,//');
    eacc=$($1 -v | awk '/eAcc/ {print "; "$2" ("$3")"}' | sed 's/v//;s/,//');
    guard=$($1 -v | awk '/Guard/ {print "; "$2,$3" ("$5")"}' | sed 's/v//;s/,//');
    suhos=$($1 -v | awk '/Suhosin/ {print "; "$2" ("$3")"}' | sed 's/v//;s/,//');
    opche=$($1 -v | awk '/OPcache/ {print "; "$2,$3" ("$4")"}' | sed 's/v//;s/,//')
    if [[ -d /etc/php-fpm.d/ ]]; then phpt='php-fpm'; else
      phpt=$(awk '/^LoadModule/ {print $2}' /etc/httpd/conf.d/php.conf /etc/httpd/conf.d/suphp.conf | sed 's/php[0-9]_module/mod_php/;s/_module//'); fi;
    printf "$FMT" "PHP Version" "${phpt} (${phpv})${zend}${ionc}${guard}${opche}${eacc}${suhos}";
}
_phpversion /usr/bin/php; if [[ -f /opt/nexcess/php54u/root/usr/bin/php ]]; then for x in /opt/nexcess/*/root/usr/bin/php; do _phpversion $x; done; fi
modsecv=$(rpm -qi mod_security | awk '/Version/ {print $3}' 2> /dev/null)
modsecr=$(awk -F\" '/SecComp.*\"$/ {print "("$2")"}' /etc/httpd/modsecurity.d/*_crs_10_*.conf 2> /dev/null)
printf "$FMT" "ModSecurity" "${modsecv:-No ModSecurity} ${modsecr}"
printf "$FMT" "MySQL Version" "$(mysql --version | awk '{print $5}' | tr -d ,) $(mysqld --version 2> /dev/null | grep -io 'percona' 2> /dev/null)"
pstgrs="/usr/*/bin/postgres"; if [[ -f $(echo $pstgrs) ]]; then printf "$FMT" "PostgreSQL" "$($pstgrs -V | awk '{print $NF}')"; fi
printf "$FMT" "Interworx" "$(grep -A1 'user="iworx"' /home/interworx/iworx.ini | tail -1 | cut -d\" -f2)"
if [[ $1 =~ -v ]]; then
  printf "$FMT" "Rev. Control" "Git ($(git --version | awk '{print $3}')); SVN ($(svn --version | awk 'NR<2 {print $3}')); $(hg --version | awk 'NR<2 {print $1" ("$NF}')"
  perlv=$(perl -v | awk '/v[0-9]/ {print "Perl ("$4")"}' | sed 's/v//')
  pythv=$(python -V 2>&1 | awk '{print $1" ("$2")"}')
  rubyv=$(ruby -v | awk '{print "Ruby ("$2")"}')
  railv=$(if [[ ! $(which rails 2>&1) =~ /which ]]; then rails -v | awk '{print $1" ("$2")"}'; fi)
  printf "$FMT" "Script Langs" "${perlv}; ${pythv}; ${rubyv}; ${railv:-No Rails}"
  printf "$FMT" "FTP/sFTP/SSH" "ProFTPD ($(proftpd --version | awk '{print $3}')); OpenSSH ($(ssh -V 2>&1 | cut -d, -f1 | awk -F_ '{print $2}'))";
fi
printf "$FMT" "Memory (RAM)" "$(free -m | awk '/Mem/ {print ($2/1000)"G / "($4/1000)"G ("($4/$2*100)"% Free)"}')"
printf "$FMT" "Memory (Swap)" "$(if [[ $(free -m | awk '/Swap/ {print $2}') != 0 ]]; then free -m | awk '/Swap/ {print ($2/1000)"G / "($4/1000)"G ("($4/$2*100)"% Free)"}'; else echo 'No Swap'; fi)"
printf "$FMT" "HDD (/home)" "$(df -h /home | tail -1 | awk '{print $2" / "$4" ("($4/$2*100)"% Free)"}')"
echo
}

## Generate xkcd / iworx style passwords
xkcd(){
if [[ $@ =~ -h ]]; then echo -e "\n  Usage: xkcd [-l <length>] [-v]\n"; return 0; fi
if [[ $@ =~ -v ]]; then wordList='/usr/share/dict/words'; else wordList='/usr/local/interworx/lib/dict/words'; fi
if [[ $1 =~ -l ]]; then wordLength=$(( (${2} - 4) / 4 )); else wordLength="4,8"; fi
if [[ -x /usr/bin/shuf ]]; then
echo $(shuf -n1000 $wordList | grep -E ^[a-z]{$wordLength}$ | shuf -n4 )$(( ($RANDOM % 9000) + 1000 ))\
  | sed 's/\b\([a-zA-Z]\)/\u\1/g' | sed 's/ //g'
else
  n=0;  word=(); len=$(wc -l < $wordList)
  while [[ $n -lt 4 ]]; do
    rnd=$(( ( $(od -vAn -N4 -tu4 < /dev/urandom) )%($len)+1 ));
    word[$n]=$(sed -n "${rnd}p" $wordList | egrep "^[a-z]{4,8}$" | sed 's:\b\(.\):\u\1:');
    if [[ -n ${word[$n]} ]]; then n=$n+1; fi;
  done;
  echo "${word[0]}${word[1]}${word[2]}${word[3]}$(( $RANDOM % 9000 + 1000 ))";
  unset n word len
fi
}

## Set default permissions for files and directories
fixperms(){
if [[ $1 == '-h' || $1 == '--help' ]]; then echo -e "\n Usage: fixperms [path]\n    Set file permissions to 644 and folder permissions to 2755\n"; return 0; fi
if [[ -n $1 ]]; then SITEPATH="$1"; else SITEPATH="."; fi

echo; read -p "Are you sure you want to update permissions for $SITEPATH? [y/n]: " yn
if [[ $yn == 'y' ]]; then echo -e '\nStarting operation ...'; else echo -e '\nOperation aborted!\n'; return 1; fi

if [[ $(grep -i ^loadmodule.*php[0-9]_module /etc/httpd/conf.d/php.conf) ]]; then perms="664"; else perms="644"; fi
printf "\nFixing File Permissions ($perms) ... "; find $SITEPATH -type f -exec chmod $perms {} \;
if [[ $(grep -i ^loadmodule.*php[0-9]_module /etc/httpd/conf.d/php.conf) ]]; then perms="2775"; else perms="2755"; fi
printf "Fixing Directory Permissions ($perms) ... "; find $SITEPATH -type d -exec chmod $perms {} \;
printf "Operation Completed.\n\n";
}


complete -W '-h --help -u --user -p --pass -l' htpasswdauth
## Generate or update .htpasswd file to add username
htpasswdauth(){
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
echo -e "\n Usage: htpasswdauth [-u|--user username] [-p|--pass password] [-l length]\n    Ex: htpasswdauth -u username -p passwod\n    Ex: htpasswdauth -u username -l 5\n    Ex: htpasswdauth -u username\n"; return 0; fi
if [[ -z $1 ]]; then echo; read -p "Username: " U; elif [[ $1 == '-u' || $1 == '--user' ]]; then U="$2"; fi;
if [[ -z $3 ]]; then P=$(xkcd); elif [[ $3 == '-p' || $3 == '--pass' ]]; then P="$4"; elif [[ $3 == '-l' ]]; then P=$(xkcd -l $4); fi

echo; read -p "Are you sure you want to modify $PWD/.htpasswd [y/n]: " yn
if [[ $yn == 'y' ]]; then echo -e '\nStarting operation ...'; else echo -e '\nOperation aborted!\n'; return 1; fi

if [[ -f .htpasswd ]]; then sudo -u $(getusr) htpasswd -mb .htpasswd $U $P; else sudo -u $(getusr) htpasswd -cmb .htpasswd $U $P; fi;
echo -e "\nUsername: $U\nPassword: $P\n";
}

## Create or add http-auth section for given .htaccess file
htaccessauth(){
echo; read -p "Are you sure you want to modify $PWD/.htaccess [y/n]: " yn
if [[ $yn == 'y' ]]; then echo -e '\nStarting operation ...'; else echo -e '\nOperation aborted!\n'; return 1; fi

sudo -u $(getusr) echo -e "\n# ----- Password Protection Section -----
\nAuthUserFile $(pwd)/.htpasswd
AuthGroupFile /dev/null
AuthName \"Authorized Access Only\"
AuthType Basic
\nRequire valid-user
\n# ----- Password Protection Section -----\n" >> .htaccess
}

## Adjust user quota on the fly using Nodeworx CLI
bumpquota(){
if [[ -z $@ || $1 =~ -h ]]; then echo -e "\n Usage: bumpquota <username> <newquota>\n  Note: <username> can be '.' to get user from PWD\n"; return 0;
elif [[ $1 =~ ^[a-z].*$ ]]; then U=$1; shift;
elif [[ $1 == '.' ]]; then U=$(getusr); shift; fi
newQuota=$1; primaryDomain=$(~iworx/bin/listaccounts.pex | grep $U | awk '{print $2}')
nodeworx -u -n -c Siteworx -a edit --domain $primaryDomain --OPT_STORAGE $newQuota &&
echo -e "\nDisk Quota for $U has been set to $newQuota MB\n"; checkquota -u $U
}

complete -W '-h --help -a --all -l --large -u --user' checkquota
## Check users quota usage
checkquota(){
_quotaheader(){ echo; printf "%8s %12s %14s %14s\n" "Username" "Used(%)" "Used(G)" "Total(G)"; dash 51; }
_quotausage(){ printf "\n%-10s" "$1"; quota -g $1 2> /dev/null | tail -1 | awk '{printf "%10.3f%%  %10.3f GB  %10.3f GB",($2/$3*100),($2/1000/1024),($3/1000/1024)}' 2> /dev/null; }
case $1 in
  -h|--help   ) echo -e "\n Usage: checkquota [--user <username>|--all|--large]\n   -u|--user user1 [user2..] .. Show quota usage for a user or list of users \n   -a|--all ................... List quota usage for all users\n   -l|--large ................. List all users at or above 80% of quota\n";;
  -a|--all    ) _quotaheader; for x in $(laccounts); do _quotausage $x; done | sort; echo ;;
  -l|--large  ) _quotaheader; echo; for x in $(laccounts); do _quotausage $x; done | sort | grep -E '[8,9][0-9]\..*%|1[0-9]{2}\..*%'; echo ;;
  -u|--user|* ) _quotaheader; shift; if [[ -z "$@" ]]; then _quotausage $(getusr); else for x in "$@"; do _quotausage $x; done; fi; echo; echo ;;
esac
}

## Show backupserver and disk usage for current home directory
backupsvr(){
checkquota;
NEW_IPADDR=$(awk -F/ '/server.allow/ {print $NF}' /usr/sbin/r1soft/log/cdp.log | tail -1 | tr -d \' | sed 's/10\.17\./178\.17\./g; s/10\.1\./103\.1\./g; s/10\.240\./192\.240\./g');
ALL_IPADDR=$(awk -F/ '/server.allow/ {print $NF}' /usr/sbin/r1soft/log/cdp.log | sort | uniq | tr -d \' | sed 's/10\.17\./178\.17\./g; s/10\.1\./103\.1\./g; s/10\.240\./192\.240\./g');
if [[ $NEW_IPADDR =~ ^172\. ]]; then INTERNAL=$(curl -s nanobots.robotzombies.net/r1bs-internal); fi

_printbackupsvr(){
  if [[ $1 =~ ^172\. ]]; then
    for x in $INTERNAL; do echo -n $x | awk -F_ "/$1/"'{printf "R1Soft IP..: https://"$3":8001\n" "R1Soft rDNS: https://"$2":8001\n"}'; done
  else
    IP=$1; RDNS=$(dig +short -x $1 2> /dev/null); echo "R1Soft IP..: https://${IP}:8001";
    if [[ -n $RDNS ]]; then echo "R1Soft rDNS: https://$(echo $RDNS | sed 's/\.$//'):8001"; fi;
  fi
  echo
}

FIRSTSEEN=$(grep $(echo $NEW_IPADDR | cut -d. -f2-) /usr/sbin/r1soft/log/cdp.log | head -1 | awk '{print $1}');
echo "----- Current R1Soft Server ----- $FIRSTSEEN] $(dash 32)"; _printbackupsvr $NEW_IPADDR

for IPADDR in $ALL_IPADDR; do
  if [[ $IPADDR != $NEW_IPADDR ]]; then
    LASTSEEN=$(grep $(echo $IPADDR | cut -d. -f2-) /usr/sbin/r1soft/log/cdp.log | tail -1 | awk '{print $1}');
    echo "----- Previous R1Soft Server ----- $LASTSEEN] $(dash 31)"; _printbackupsvr $IPADDR
  fi;
done
}

## Lookup the DNS Nameservers on the host
nameserver(){ echo; for x in $(grep ns[1-2] ~iworx/iworx.ini | cut -d\" -f2;); do echo "$x ($(dig +short $x))"; done; echo; }

## Quick summary of domain DNS info
ddns(){
if [[ -z "$@" ]]; then read -p "Domain Name: " D; else D="$@"; fi
for x in $(echo $D | sed 's:/::g'); do echo -e "\nDNS Summary: $x\n$(dash 79)";
for y in a aaaa ns mx txt soa; do dig +time=2 +tries=2 +short $y $x +noshort;
if [[ $y == 'ns' ]]; then dig +time=2 +tries=2 +short $(dig +short ns $x) +noshort | grep -v root; fi; done;
dig +short -x $(dig +time=2 +tries=2 +short $x) +noshort; echo; done
}

## Find IPs in use by account by finding secondary domains, and searching the vhost files
accountips(){
echo; DIR=$PWD; cd /home/$(getusr);
FORMAT=" %-15s  %-15s  %-3s  %-3s  %s\n";
HIGHLIGHT="${BRIGHT}${RED} %-15s  %-15s  %-3s  %-3s  %s${NORMAL}\n";
printf "$FORMAT" " ServerIP" " LiveIP" "SSL" "FPM" " DomainName";
printf "$FORMAT" "$(dash 15)" "$(dash 15)" "---" "---" "$(dash 39)";
for x in */html; do
  D=$(echo $x | cut -d/ -f1);
  L=$(dig +tries=1 +time=3 +short $1$D | grep -v \; | head -n1);
  I=$(grep -i virtualhost /etc/httpd/conf.d/vhost_$D.conf 2> /dev/null | head -n1 | awk '{print $2}' | cut -d: -f1);
  S=$(if grep -q ':443' /etc/httpd/conf.d/vhost_$D.conf &> /dev/null; then echo SSL; fi);
  F=$(if grep -q 'MAGE_RUN' /etc/httpd/conf.d/vhost_$D.conf &> /dev/null; then echo FIX; fi);
  if [[ $I != $L ]]; then printf "$HIGHLIGHT" "$I" "$L" "${S:- - }" "${F:- - }" "$1$D";
  else printf "$FORMAT" "$I" "$L" "${S:- - }" "${F:- - }" "$1$D"; fi;
done; echo; cd $DIR
}

## CD to document root in vhost containing the given domain
cdomain(){
if [[ -z "$@" ]]; then echo -e "\n  Usage: cdomain <domain.tld>\n"; return 0; fi
vhost=$(grep -l " $(echo $1 | sed 's/\(.*\)/\L\1/g')" /etc/httpd/conf.d/vhost_[^000]*.conf)
if [[ -n $vhost ]]; then cd $(awk '/DocumentRoot/ {print $2}' $vhost | head -1); pwd;
else echo -e "\nCould not find $1 in the vhost files!\n"; fi
}

## List the unix usernames for Siteworx accounts on the server
laccounts(){ ~iworx/bin/listaccounts.pex | awk '{print $1}'; }

## List Siteworx accouts sorted by Reseller
lreseller(){
( nodeworx -u -n -c Siteworx -a listAccounts | sed 's/ /_/g' | awk '{print $5,$2,$10}';
  nodeworx -u -n -c Reseller -a listResellers | sed 's/ /_/g' | awk '{print $1,"0.Reseller",$3}' )\
  | sort -n | column -t | sed 's/\(.*0\.Re.*\)/\n\1/' | grep -Ev '^1 '; echo
}

## List the daily snapshots for a database to see the dates/times on the snapshots
lsnapshots(){
echo; if [[ -z "$1" ]]; then read -p "Database Name: " DBNAME; else DBNAME="$1"; fi
ls -lah /home/.snapshots/daily.*/localhost/mysql/$DBNAME.sql.gz; echo
}

## Download scheduler.php and then list out the Magento Cron jobs
magcrons(){
if [[ -z "$1" ]]; then SITEPATH="."; else SITEPATH="$1"; fi
BASEURL=$(nkmagento info $SITEPATH | awk '/^Base/ {print $4}')
sudo -u $(getusr) wget -q -O $SITEPATH/scheduler.php nanobots.robotzombies.net/scheduler
curl -s "$BASEURL/scheduler.php" | less; echo
read -p "Remove scheduler.php? [y/n]: " yn; if [[ $yn == "n" ]]; then echo "Link: $BASEURL/scheduler.php";
else rm $SITEPATH/scheduler.php; echo "scheduler.php has been removed."; fi; echo
}

## Create Magento Multi-Store Symlinks
magsymlinks(){
U=$(getusr); if [[ -z $1 ]]; then echo; read -p "Domain Name: " D; else D=$1; fi

echo; read -p "Are you sure you want to create symlinks in $PWD for /home/$U/$D/html/ [y/n]: " yn
if [[ $yn == 'y' ]]; then echo -e '\nStarting operation ...'; else echo -e '\nOperation aborted!\n'; return 1; fi

for X in app includes js lib media skin var; do sudo -u $U ln -s /home/$U/$D/html/$X/ $X; done;
echo; read -p "Copy .htaccess and index.php? [y/n]: " yn; if [[ $yn == "y" ]]; then
for Y in index.php .htaccess; do sudo -u $U cp /home/$U/$D/html/$Y .; done; fi; echo
}

## Create symlinks to log directories for user
linklogs(){
DIR=$PWD; U=$(getusr); cd /home/$U/; sudo -u $U mkdir logs
for x in var/*/logs/; do sudo -u $U ln -s ../$x logs/$(echo $x | awk -F/ '{print $2}'); done;
if [[ -f var/php-fpm/error.log ]]; then sudo -u $U ln -s ../var/php-fpm/ logs/php-fpm; fi
echo -e "\nLinks to log directories created in:\n$PWD/logs/\n"; cd $DIR
}

## Find files group owned by username in employee folders or temp directories
savethequota(){
find /home/nex* -type f -group $(getusr) -exec ls -lah {} \;
find /home/tmp -type f -size +100M -group $(getusr) -exec ls -lah {} \;
find /tmp -type f -size +100M -group $(getusr) -exec ls -lah {} \;
}

## Give a breakdown of user's large disk objects
diskhogs(){
if [[ $@ =~ "-h" ]]; then echo -e "\n Usage: diskhogs [maxdepth] [-d]\n"; return 0; fi;
if [[ $@ =~ [0-9]{1,} ]]; then DEPTH=$(echo $@ | grep -Eo '[0-9]{1,}'); else DEPTH=3; fi;
echo -e "\n---------- Large Directories $(dash 51)"; du -h --max-depth $DEPTH | grep -E '[0-9]G|[0-9]{3}M';
if [[ ! $@ =~ '-d' ]]; then echo -e "\n---------- Large Files $(dash 57)"; find . -type f -size +100M -group $(getusr) -exec ls -lah {} \;; fi;
echo -e "\n---------- Large Databases $(dash 53)"; du -sh /var/lib/mysql/$(getusr)_* | grep -E '[0-9]G|[0-9]{3}M';
echo
}

## Give a breakdown of user's disk usage by area of use
diskusage(){
DIR=$PWD; cd /home/$(getusr)
echo -e "\n---------- File Usage ----------"; du -h --max-depth 2 | grep -v var;
echo -e "\n---------- Mail Usage ----------"; du -sh var/*/mail/*/Maildir;
echo -e "\n---------- Log File Usage ----------"; du -sh var/*/logs; du -sh var/php-fpm/ 2> /dev/null;
echo -e "\n---------- Database Usage ----------"; du -sh /var/lib/mysql/$(getusr)_*;
echo; cd $DIR
}

## List Users, or Reset passwords for FTP/Siteworx/Reseller/Nodeworx
iworxcredz(){

## Check method and generate new password
genPass(){
  if [[ $1 == '-m' ]]; then newPass=$(mkpasswd -l 15);
  elif [[ $1 == '-x' ]]; then newPass=$(xkcd);
  elif [[ $1 == '-p' ]]; then newPass="$2";
  else newPass=$(xkcd); fi
  }

if [[ $1 == '-d' ]]; then primaryDomain=$2; shift; shift;
else primaryDomain=$(~iworx/bin/listaccounts.pex | grep $(getusr) | awk '{print $2}'); fi

case $1 in
-e ) # Listing/Updating Email Passwords
if [[ -z $2 || $2 == '--list' ]]; then
  echo -e "\n----- EmailAddresses -----"
  for x in /home/$(getusr)/var/*/mail/*/Maildir/; do echo $(echo $x | awk -F/ '{print $7"@"$5}'); done; echo
else
  emailAddress=$2; genPass $3 $4
  ~vpopmail/bin/vpasswd $emailAddress $newPass
  echo -e "\nLoginURL: https://$(serverName):2443/webmail\nUsername: $emailAddress\nPassword: $newPass\n"
fi
;;


-f ) # Listing/Updating FTP Users
if [[ $2 == '--list' ]]; then
  echo; (echo "ShortName FullName"; sudo -u $(getusr) -- siteworx -u -n -c Ftp -a list) | column -t; echo
elif [[ -z $2 || $2 =~ ^- ]]; then
  ftpUser='ftp'; genPass $2 $3
  sudo -u $(getusr) -- siteworx -u --login_domain $primaryDomain -n -c Ftp -a edit --password $newPass --confirm_password $newPass --user $ftpUser
  echo -e "\nFor Testing: \nlftp -e'ls;quit' -u ${ftpUser}@${primaryDomain},'$newPass' $(serverName)"
  echo -e "\nHostname: $(serverName)\nUsername: ${ftpUser}@${primaryDomain}\nPassword: $newPass\n"
else
  ftpUser=$2; genPass $3 $4;
  sudo -u $(getusr) -- siteworx -u --login_domain $primaryDomain -n -c Ftp -a edit --password $newPass --confirm_password $newPass --user $ftpUser
  echo -e "\nFor Testing: \nlftp -e'ls;quit' -u ${ftpUser}@${primaryDomain},'$newPass' $(serverName)"
  echo -e "\nHostname: $(serverName)\nUsername: ${ftpUser}@${primaryDomain}\nPassword: $newPass\n"
fi
;;

-s ) # Listing/Updating Siteworx Users
if [[ $2 = '--list' ]]; then
  echo; (echo "EmailAddress Name Status"; sudo -u $(getusr) -- siteworx -u -n -c Users -a listUsers | sed 's/ /_/g' | awk '{print $2,$3,$5}') | column -t; echo
elif [[ -z $2 || $2 =~ ^- ]]; then # Lookup primary domain and primary email address
  primaryEmail=$(nodeworx -u -n -c Siteworx -a querySiteworxAccounts --domain $primaryDomain --account_data email)
  genPass $2 $3
  nodeworx -u -n -c Siteworx -a edit --password "$newPass" --confirm_password "$newPass" --domain $primaryDomain
  echo -e "\nLoginURL: https://$(serverName):2443/siteworx/?domain=$primaryDomain\nUsername: $primaryEmail\nPassword: $newPass\nDomain: $primaryDomain\n"
else # Updaet Password for specific user
  emailAddress=$2; genPass $3 $4
  sudo -u $(getusr) -- siteworx -u -n -c Users -a edit --user $emailAddress --password $newPass --confirm_password $newPass
  echo -e "\nLoginURL: https://$(serverName):2443/siteworx/?domain=$primaryDomain\nUsername: $emailAddress\nPassword: $newPass\nDomain: $primaryDomain\n"
fi
;;

-r ) # Listing/Updating Reseller Users
if [[ -z $2 || $2 == '--list' ]]; then # List out Resellers nicely
  echo; (echo "ID Reseller_Email Name"; nodeworx -u -n -c Reseller -a listResellers | sed 's/ /_/g' | awk '{print $1,$2,$3}') | column -t; echo
else # Update Password for specific Reseller
  resellerID=$2; genPass $3 $4
  nodeworx -u -n -c Reseller -a edit --reseller_id $resellerID --password $newPass --confirm_password $newPass
  emailAddress=$(nodeworx -u -n -c Reseller -a listResellers | grep ^$resellerID | awk '{print $2}')
  echo -e "\nLoginURL: https://$(serverName):2443/nodeworx/\nUsername: $emailAddress\nPassword: $newPass\n\n"
fi
;;

-n ) # Listing/Updating Nodeworx Users
if [[ -z $2 || $2 == '--list' ]]; then # List Nodeworx (non-Nexcess) users
  echo; (echo "Email_Address Name"; nodeworx -u -n -c Users -a list | grep -v nexcess.net | sed 's/ /_/g') | column -t; echo
elif [[ ! $2 =~ nexcess\.net$ ]]; then # Update Password for specific Nodeworx user
  emailAddress=$2; genPass $3 $4
  nodeworx -u -n -c Users -a edit --user $emailAddress --password $newPass --confirm_password $newPass
  echo -e "\nLoginURL: https://$(serverName):2443/nodeworx/\nUsername: $emailAddress\nPassword: $newPass\n\n"
fi
;;

-m ) # Listing/Updating MySQL Users
if [[ -z $2 || $2 == '--list' ]]; then
  echo; ( echo -e "Username   Databases"
  sudo -u $(getusr) -- siteworx -u -n -c Mysqluser -a listMysqlUsers | awk '{print $2,$3}' ) | column -t; echo
else
  genPass $3 $4
  dbs=$(sudo -u $(getusr) -- siteworx -u -n -c Mysqluser -a listMysqlUsers | grep "$2" | awk '{print $3}' | sed 's/,/, /')
  sudo -u $(getusr) -- siteworx -u -n -c MysqlUser -a edit --name $(echo $2 | sed "s/$(getusr)_//") --password $newPass --confirm_password $newPass
  echo -e "\nFor Testing: \nmysql -u'$2' -p'$newPass' $(echo $dbs | cut -d, -f1)"
  echo -e "\nUsername: $2\nPassword: $newPass\nDatabase: $dbs\n"
fi
;;

-h | --help | * )
echo -e "\n  For FTP and Siteworx, run this from within the user's /home/dir/\n
  Usage: iworxcredz OPTION [--list] [USER/ID] PASSWORD [newPassword]
    Ex: iworxcredz -d secondaryDomain -f ftpUserName -m
    Ex: iworxcredz -f ftpUserName -p newPassword
    Ex: iworxcredz -s emailAddress -x
    Ex: iworxcredz -r --list

  OPTIONS: (use '--list' to list available users)
    -d [domain] . Specify domain for secondary FTP users
    -e [email] .. Email Users
    -f [user] ... FTP Users (default is ftp@primarydomain.tld)
    -s [email] .. Siteworx Users (default is primary user)
    -r [id] ..... Reseller Users
    -n [email] .. Nodeworx Users
    -m [user] ... MySQL Users

  PASSWORD: (password generation or input)
    -m ... Generate password using mkpasswd
    -x ... Generate password using xkcd (default)
    -p ... Specify new password directly (-p <password>)\n"; return 0;
;;

esac
unset primaryDomain primaryEmail emailAddress resellerID dbs dbuser newPass # Cleanup
}

## Setup or reset SSH account
sshcredz(){
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo -e "\n Usage: sshcredz [-p <password>] [-i \"<IP1> <IP2> <IP3> ...\"] [comment]\n"; return 0; fi

# if password specified
if [[ $1 == '-p' ]]; then newPass="$2"; shift; shift; else newPass=$(mkpasswd -l 15); fi

# if whitelist specified
if [[ $1 == '-i' ]]; then whitelist ssh "$2" "$3"; fi

# Set shell, and add to ssh user's group; then reset failed logins, and reset password.
usermod -s /bin/bash -a -G sshusers $(getusr) && echo -n "User $(getusr) added to sshusers, and shell set to /bin/bash ... "
pam_tally2 -u $(getusr) -r &> /dev/null && echo -n "Failures for $(getusr) reset ... "
echo "$newPass" | passwd --stdin $(getusr) &> /dev/null && echo "Password set to $newPass"

# Output block for copy pasta
echo -e "\nHostname: $(serverName)\nUsername: $(getusr)\nPassword: $newPass\n";
}

## Tab completion for whitelist function
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

## Whitelist a hostname or ip address in the appropriate config
whitelist(){
if [[ "$2" == "in" ]]; then SRC="d="; DST="s=";
  elif [[ "$2" == "out" ]]; then SRC="d="; DST="d=";
    else SRC=""; DST=""; fi;
      HOST="$3"; CMNT="$4"; TYPE=""

_addrule(){
echo; if ! grep -q "^\#.*$(getusr)" $CONFIG; then echo -e "\n# $(getusr)" >> $CONFIG; fi
for x in $HOST; 
    do echo "${SRC}${PORT}${DST}${x} .. added to $CONFIG";
    sed -i "s|\(^\#.*$(getusr).*$\)|\1\n${SRC}${PORT}${DST}${x}|" $CONFIG
  done;
sed -i "s|\(^\#.*$(getusr).*$\)|\1\n# ${TYPE} ${CMNT}|" $CONFIG;
echo -e "\nGreetings,\n\nI have white-listed the requested IP address(es) ( $(for x in $HOST; do printf "$x, "; done)) for $TYPE access on $(hostname).\nYou should be all set. Please let us know if you need any further assistance.\n\nBest Regards,\n"
if [[ "$SRC" != "sshd" ]]; then echo; service apf restart; fi;
}

case $1 in
  f|ftp ) CONFIG='/etc/apf/allow_hosts.rules'; TYPE="(FTP $2)"; PORT="21:"; _addrule ;;
  m|mysql ) CONFIG='/etc/apf/allow_hosts.rules'; TYPE="(MySQL $2)"; PORT="3306:"; _addrule ;;
  o|other ) CONFIG='/etc/apf/allow_hosts.rules'; TYPE="(port $4 $2)"; PORT="${4}:"; CMNT="$5" ; _addrule ;;
  s|ssh )
    if [[ $(grep 'sshd: ALL' /etc/hosts.allow 2> /dev/null) ]]; then CONFIG='/etc/apf/allow_hosts.rules';
        if [[ "$2" != "in" && "$2" != "out" ]]; then HOST="$2"; CMNT="$3"; fi; TYPE="(SSH/SFTP)"; SRC="d="; DST="s="; PORT="22:"; _addrule
    else CONFIG='/etc/hosts.allow';
        if [[ "$2" != "in" && "$2" != "out" ]]; then HOST="$2"; CMNT="$3"; fi; TYPE="(SSH/SFTP)"; SRC="sshd"; DST=": "; PORT=""; _addrule
    fi
    ;;
  -h|--help|*) echo -e "\n Usage: whitelist [ftp|mysql|ssh|other] [in|out] <ip/host> [port#] [comment]
    Ex: whitelist ssh \"10.0.0.1 10.0.1.1 10.1.1.1\" ABCD-1234
    Ex: whitelist mysql in 10.0.0.2 EFGH-5678
    Ex: whitelist other out 10.0.0.3 1187 IJKL-6543\n" ;;
esac
}

## Truncate large log files, chown and move the original for later review
trimfile(){
U=$(getusr); if [[ -z "$1" ]]; then echo; read -p "File Name (without path): " FILE; else FILE="$1"; fi
chown root:root $FILE && tail -n10000 $FILE > temp.txt && mv $FILE ~/"$(pwd | sed 's:^/::;s:/:-:g')--$(date +%Y.%m.%d)--$FILE" && mv temp.txt $FILE && chown $U. $FILE
echo "Operation completed."; echo
}

complete -W 'ftp php mysql http ssh cron all -h --help' logs
## Quick log check of the major logs to see what might be the matter
logs(){
if [[ -z "$2" ]]; then N=20; else N="$2"; fi
case "$1" in
    ftp  ) echo; tail -n"$N" /var/log/proftpd/auth.log /var/log/proftpd/xfer.log; echo ;;
    php  ) echo; tail -n"$N" /var/log/php-fpm/error.log; echo ;;
    mysql) echo; tail -n"$N" /var/log/mysqld.log; echo ;;
    http ) echo; tail -n"$N" /var/log/httpd/error_log; echo ;;
    ssh  ) echo; grep -v 'Did not receive' /var/log/secure | tail -n$N; echo ;;
    cron ) echo; tail -n"$N" /var/log/cron; echo ;;
    all  ) echo -e "\n---------- APACHE LOG ----------\n$(tail -n$N /var/log/httpd/error_log)\n"
           if [[ -f /var/log/php-fpm/error.log ]]; then echo -e "\n---------- PHP LOG ----------\n$(tail -n$N /var/log/php-fpm/error.log)\n"; fi
           echo -e "\n---------- MYSQL LOG ----------\n$(tail -n$N /var/log/mysqld.log)\n"
           echo -e "\n---------- SSH LOG ----------\n$(grep -v 'Did not receive' /var/log/secure | tail -n$N)\n"
           echo -e "\n---------- CRON LOG ----------\n$(tail -n$N /var/log/cron)\n"
		   echo -e "\n---------- FTP LOGS ----------\n$(tail -n$N /var/log/proftpd/auth.log /var/log/proftpd/xfer.log)";;
    -h|--help) echo -e "\n Usage: logs [ftp|php|mysql|http|ssh|cron|all] [linecount]\n" ;;
    * ) echo -e "\n---------- APACHE LOG ----------\n$(tail -n$N /var/log/httpd/error_log)\n"
        if [[ -f /var/log/php-fpm/error.log ]]; then echo -e "\n---------- PHP LOG ----------\n$(tail -n$N /var/log/php-fpm/error.log)\n"; fi
        echo -e "\n---------- MYSQL LOG ----------\n$(tail -n$N /var/log/mysqld.log)\n" ;;
esac
}

## Print hits per hour for all domains on the server (using current transfer.log's)
sum_traffic(){
echo; FMT=" %5s"

## Header
printf "${BRIGHT} %9s" "User/Hour"
for hour in $(seq -w 0 23); do printf "$FMT" "$hour:00"; done
printf "%8s %-s${NORMAL}\n" "Total" " Domain Name"

## Initializations
hourtotal=($(for ((i=0;i<23;i++)); do echo 0; done)); grandtotal=0

# Caclulate filname suffix of previous logs
if [[ $1 == '-d' ]]; then DECOMP='zgrep' DATE="-$(date --date="-$2 day" +%m%d%Y).zip"; shift; shift; else DECOMP='grep' DATE=''; fi

## Data gathering and display
for logfile in /home/*/var/*/logs/transfer.log${DATE}; do
        total=0; i=0;
        if [[ $1 != '-n' && $1 != '--nocolor' ]]; then color="${BLUE}"; else color=''; fi
        printf "${color} %9s" "$(echo $logfile | cut -d/ -f3)"
        for hour in $(seq -w 0 23); do
                count=$($DECOMP -Ec "[0-9]{4}:$hour:" $logfile);
                hourtotal[$i]=$((${hourtotal[$i]}+$count))

                ## COLOR VERSION (HEAT MAP)
                if [[ $1 != '-n' && $1 != '--nocolor' ]]; then
                    if [[ $count -gt 20000 ]]; then color="${BRIGHT}${RED}";
                    elif [[ $count -gt 2000 ]]; then color="${RED}";
                    elif [[ $count -gt 200 ]]; then color="${YELLOW}";
                    else color="${GREEN}"; fi
                else color=''; fi
                printf "${color}$FMT${NORMAL}" "$count"
                total=$((${total}+${count})); i=$(($i+1))
        done
        grandtotal=$(($grandtotal+$total))

if [[ $1 != '-n' && $1 != '--nocolor' ]]; then ## Color version
    printf "${CYAN}%8s ${PURPLE}%-s${NORMAL}\n" "$total" "$(echo $logfile | cut -d/ -f5)"
else printf "%8s %-s\n" "$total" "$(echo $logfile | cut -d/ -f5)"; fi

done

## Footer
printf "${BRIGHT} %9s" "Total"
for i in $(seq 0 23); do printf "$FMT" "${hourtotal[$i]}"; done
printf "%8s %-s${NORMAL}\n" "$grandtotal" "<< Grand Total"
echo
}

## Traffic stats / information (collection of Apache one-liners)
traffic(){
_trafficUsage(){
echo " Usage: traffic DOMAIN COMMAND [OPTIONS]

 Commands:
    ua | useragent . Top User Agents by # of hits
   bot | robots .... Top User Agents identifying as bots by # of hits
   scr | scripts.... Top empty User Agents (likely scripts) by # of hits
    ip | ipaddress . Top IPs by # of hits
    bw | bandwidth . Top IPs by bandwidth usage
   url | file ...... Top URLs/files by # of hits
   ref | referrer .. Top Referrers by # of hits
  type | request ... Summary of request types (GET/HEAD/POST)
   sum | summary ... Summary of response codes and user agents for top ips
    hr | hour ...... # of hits per hour
    gr | graph ..... # of hits per hour with visual graph
   min | minute .... Hits per min during some range
  code | response .. Response Codes (per Day/Hour/Min)
     s | search .... Only search the log for -s 'search string'
                     This does not have a line limit (ignores -n)

 Options:
    -s | --search .. Search \"string\" (executed before analysis)
                     For a timeframe use 'YYYY:HH:MM:SS' or 'regex'
    -d | --days .... Days before today (1..7) (historical logs)
    -n | --lines ... Number of results to print to the screen
    -h | --help .... Print this help and exit

 Notes:
    DOMAIN can be '.' to find the domain from the PWD"; return 0;
}

_trafficDash(){ for ((i=1;i<=$1;i++));do printf '#'; done; }

# Check how the domain is specified.
if [[ $1 == '.' ]]; then DOMAIN=$(pwd | sed 's:^/chroot::' | cut -d/ -f4); shift;
  else DOMAIN=$(echo $1 | sed 's:/$::'); shift; fi

opt=$1; shift; # Set option variable using command parameter
SEARCH=''; DATE=''; TOP='20'; TIME=''; DECOMP='egrep'; VERBOSE=0; # Initialize variables
OPTIONS=$(getopt -o "s:d:n:hv" --long "search:,days:,lines:,help,verbose" -- "$@") # Execute getopt
eval set -- "$OPTIONS" # Magic

while true; do # Evaluate the options for their options
case $1 in
  -s|--search ) SEARCH="$2"; shift ;; # search string (regex)
  -d|--days   ) DATE="-$(date --date="-$((${2}-1)) day" +%m%d%Y).zip"; DECOMP='zegrep'; shift ;; # days back
  -n|--lines  ) TOP=$2; shift ;; # results
  -v|--verbose) VERBOSE=1 ;; # Debugging Output
  --          ) shift; break ;; # More Magic
  -h|--help|* ) _trafficUsage; return 0 ;; # print help info
esac;
shift;
done

LOGFILE="/home/*/var/${DOMAIN}/logs/transfer.log${DATE}"

echo
case $opt in

ua|useragent	) $DECOMP "$SEARCH" $LOGFILE | awk -F\" '{freq[$6]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP ;;

bot|robots	) $DECOMP "$SEARCH" $LOGFILE | awk -F\" '($6 ~ /[Bb]ot|[Cc]rawler|[Ss]pider/) {freq[$6]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP ;;

scr|scripts	) $DECOMP "$SEARCH" $LOGFILE | awk -F\" '($6 ~ /^-?$/) {print $1}' | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP ;;

ip|ipaddress	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP ;;

bw|bandwidth	) $DECOMP "$SEARCH" $LOGFILE | awk '{tx[$1]+=$10} END {for (x in tx) {printf "   %-15s   %8s M\n",x,(tx[x]/1024000)}}' | sort -k 2n | tail -n$TOP | tac ;;

sum|summary	) for x in $($DECOMP "$SEARCH" $LOGFILE | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP | awk '{print $2}'); do
		  echo $x; $DECOMP "$SEARCH" $LOGFILE | grep $x | cut -d' ' -f9,12- | sort | uniq -c | sort -rn | head -n$TOP | tr -d \"; echo; done ;;

s|search	) $DECOMP "$SEARCH" $LOGFILE ;;

hr|hour 	) for x in $(seq -w 0 23); do echo -n "${x}:00 "; $DECOMP "$SEARCH" $LOGFILE | egrep -c "/[0-9]{4}:$x:"; done ;;

gr|graph	) for x in $(seq -w 0 23); do echo -n "${x}:00"; count=$($DECOMP "$SEARCH" $LOGFILE | egrep -c "/[0-9]{4}:$x:");
		  printf "%8s |%s\n" "$count" "$(_trafficDash $(($count/500)))"; done;;

min|minute	) $DECOMP "$SEARCH" $LOGFILE | awk '{print $4}' | awk -F: '{print $1" "$2":"$3}' | sort | uniq -c | tr -d \[ ;;

type|request	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$6]++} END {for (x in freq) {print x,freq[x]}}' | tr -d \" | sed 's/-/TIMEOUT/' | column -t ;;

code|response	) $DECOMP "$SEARCH" $LOGFILE | awk '{print $4":"$9}' | awk -F: '{print $1,$5}' | sort | uniq -c | tr -d \[ ;;

url|file	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$7]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP ;;

ref|referrer	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$11]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | tr -d \" | sort -rn | head -n$TOP ;;

-h|--help|*) _trafficUsage ;;

esac

if [[ $VERBOSE == '1' ]]; then echo; echo -e "DECOMP: $DECOMP\nSEARCH: $SEARCH\nTIME: $TIME\nDATE: $DATE\nTOP: $TOP\nLOGFILE: $LOGFILE\n" | column -t; fi # Debugging

echo;
unset DOMAIN SEARCH DATE TOP TIME LOGFILE DECOMP VERBOSE # Variable Cleanup
}
