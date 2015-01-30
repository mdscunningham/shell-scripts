# This code asside from external tools and programs are covered under:
# Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
# https://creativecommons.org/licenses/by-sa/3.0/

## Block viewing motd
if [[ ! -f ~/.hushlogin ]]; then touch ~/.hushlogin; fi

## Source global definitions and Nexcess functions
if [ -f /etc/bashrc ]; then . /etc/bashrc; fi
if [ -f /etc/nexcess/bash_functions.sh ]; then . /etc/nexcess/bash_functions.sh; fi

if [[ -n "$PS1" ]]; then ## --> interactive shell
  ## Auto switch to root
    if [[ $UID != "0" ]]; then r; fi;
  NORMAL=$(tput sgr0); ## COLORS!
   BLACK=$(tput setaf 0);     RED=$(tput setaf 1);   GREEN=$(tput setaf 2);   YELLOW=$(tput setaf 3);
    BLUE=$(tput setaf 4);  PURPLE=$(tput setaf 5);    CYAN=$(tput setaf 6);    WHITE=$(tput setaf 7);
  BRIGHT=$(tput bold);      BLINK=$(tput blink);    REVERSE=$(tput smso);  UNDERLINE=$(tput smul);
  ## Once you switch to root, Lookup currently installed version of Iworx, and look to see who else is on the server
    if [[ $UID == "0" ]]; then
        IworxVersion=$(echo -n $(grep -A1 'user="iworx"' /home/interworx/iworx.ini | cut -d\" -f2 | sed 's/^\(.\)/\U\1/'));
        echo -e "\n$IworxVersion\nCurrent Users\n-------------\n$(w | grep -Ev '[0-9]days')\n";
    fi;
fi

export PATH=$PATH:/usr/local/sbin:/sbin:/usr/sbin:/var/qmail/bin/:/usr/nexkit/bin
export GREP_OPTIONS='--color=auto'
export PAGER=/usr/bin/less

# formatted at 2000-03-14 03:14:15
export HISTTIMEFORMAT="%F %T "

export EDITOR=/usr/bin/nano
export VISUAL=/usr/bin/nano

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
alias la='ls -F --color=auto -lah'
alias lr='ls -F --color=auto -larth'

# only append to bash history to prevent it from overwriting it when you have multiple ssh windows open
shopt -s histappend
# save all lines of a multiple-line command in the same history entry
shopt -s cmdhist
# correct minor errors in the spelling of a directory component
shopt -s cdspell
# check the window size after each command and, if necessary, updates the values of LINES and COLUMNS
shopt -s checkwinsize
# add extended globing to bash to do regex pattern matching in file globs
shopt -s extglob

# RESET
txtrst='\[\e[0m\]'    # Text Reset

# NORMAL
txtblk='\[\e[0;30m\]'; txtred='\[\e[0;31m\]'; txtgrn='\[\e[0;32m\]'
txtylw='\[\e[0;33m\]'; txtblu='\[\e[0;34m\]'; txtpur='\[\e[0;35m\]'
txtcyn='\[\e[0;36m\]'; txtwht='\[\e[0;37m\]';

# BOLD
bldblk='\[\e[1;30m\]'; bldred='\[\e[1;31m\]'; bldgrn='\[\e[1;32m\]'
bldylw='\[\e[1;33m\]'; bldblu='\[\e[1;34m\]'; bldpur='\[\e[1;35m\]'
bldcyn='\[\e[1;36m\]'; bldwht='\[\e[1;37m\]'

# UNDERLINE
unkblk='\[\e[4;30m\]'; undred='\[\e[4;31m\]'; undgrn='\[\e[4;32m\]'
undylw='\[\e[4;33m\]'; undblu='\[\e[4;34m\]'; undpur='\[\e[4;35m\]'
undcyn='\[\e[4;36m\]'; undwht='\[\e[4;37m\]'

if [ $UID = 0 ]; then
    # nexkit bash completion
     if [ -e '/etc/bash_completion.d/nexkit' ]; then
         source /etc/bash_completion.d/nexkit
     fi
    PS1="[${txtcyn}\$(date +%H:%M)${txtrst}][${bldred}\u${txtrst}@${txtylw}\h${txtrst} ${txtcyn}\W${txtrst}]\$ "
else
    PS1="[${txtcyn}\$(date +%H:%M)${txtrst}][\u@\h \W]\$ "
fi

## My Aliases
alias vi='vim -n'
alias less='less -R'
alias h='echo; serverName; echo'
alias os='echo; cat /etc/redhat-release; echo'
alias getrsync='wget updates.nexcess.net/scripts/rsync.sh; chmod +x rsync.sh'
alias omg='curl -s http://nanobots.robotzombies.net/aboutbashrc | less'
alias wtf="grep -B1 '^[a-z].*(){' /home/nexmcunningham/.bashrc | sed 's/(){.*$//' | less"
alias credits='curl -s http://nanobots.robotzombies.net/credits | less'
alias quotas='checkquota'

# Iworx DB
i(){ $(grep -B1 'dsn.orig=' ~iworx/iworx.ini | head -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|') "$@"; }

# Vpopmail
v(){ $(grep -A1 '\[vpopmail\]' ~iworx/iworx.ini | tail -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|') "$@"; }

# ProFTPd
f(){ $(grep -A1 '\[proftpd\]' ~iworx/iworx.ini | tail -1 | sed 's|.*://\(.*\):\(.*\)@.*\(/usr.*.sock\)..\(.*\)"|mysql -u \1 -p\2 -S \3 \4|') "$@"; }

## Lookup mail account password (http://www.qmailwiki.org/Vpopmail#vuserinfo)
emailpass(){ echo -e "\nUsername: $1\nPassword: $(~vpopmail/bin/vuserinfo -C $1)\n"; }

## Set my account to use someone else's .bashrc
# sourceme(){ if [[ -z "$1" ]]; then echo; read -p "Username: " U; else U="$1"; fi; source /home/$U/.bashrc; }

## Send a bug report to my email regarding a function in my bashrc
bugreport(){
echo -e "\nPlease include information regarding what you were trying to do, any files
you were working with, the command you ran, and the error you received. I will
try and get back to you with either an explaination or a fix, as soon as I can.\n
Once you save and exit this file, this message will be sent and this file removed.\n"
read -p "Script is paused, press [Enter] to begin editing the message ..."
echo -e "Bug Report (.bashrc): <Put the subject here>\n\nSERVER: $(serverName)\nUSER: $SUDO_USER\nPWD: $PWD\n\n$(cat /etc/redhat-release)\n$IworxVersion\n\nFiles:\n\nCommands:\n\nErrors:\n\n" > ~/tmp.file
vim ~/tmp.file && cat ~/tmp.file | mail -s "$(head -1 ~/tmp.file)" "mcunningham@mdsc.info" && rm ~/tmp.file
}

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

## Download and execute global-dns-checker script
dnscheck(){
    wget -q -O ~/dns-check.sh nanobots.robotzombies.net/dns-check.sh;
    chmod +x ~/dns-check.sh;  ~/./dns-check.sh "$@"; }

## Calculate the free slots on a server depending on the server type
freeslots(){
    wget -q -O ~/freeslots.sh nanobots.robotzombies.net/freeslots.sh;
    chmod +x ~/freeslots.sh;  ~/./freeslots.sh "$@"; }

## Add date and time with username and open server_notes.txt for editing
srvnotes(){
    echo -e "\n#$(date) - $(echo $SUDO_USER | sed 's/nex//g')" >> /etc/nexcess/server_notes.txt;
    nano /etc/nexcess/server_notes.txt; }

## Update IonCube for CentOS 5/6
ioncubeupdate(){
if [[ $1 =~ [0-9]\.[0-9] ]]; then ver="$1";
else read -p "What is the running PHP version: " ver; fi

# Create Download Directory
if [[ ! -d ~/downloads ]]; then mkdir ~/downloads;
else rm -r ~/downloads; mkdir ~/downloads; fi

# Download archive into directory and unpack
cd ~/downloads/
wget -O ioncube_loaders_lin_x86-64.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -zxf ioncube_loaders_lin_x86-64.tar.gz; echo

# check for known configuration combinations
if [[ -f /etc/php.d/ioncube.ini && -f /usr/lib64/php5/ioncube.so ]]; then # CentOS 5
  phpdir="/usr/lib64/php5/"; config="/etc/php.d/ioncube.ini"
elif [[ -d /usr/lib64/php/modules/ ]]; then # CentOS 6
  phpdir="/usr/lib64/php/modules/"; config="/etc/php.d/ioncube-loader.ini"
fi

# Copy the correct .so driver file to the target directory
if [[ -f ${phpdir}ioncube.so ]]; then
  echo -e "\n${phpdir}ioncube.so driver file exist, backing up before continuing\n"
  cp ~/downloads/ioncube/ioncube_loader_lin_${ver}* ${phpdir}
  gzip ${phpdir}ioncube.so && mv ${phpdir}ioncube_loader_lin_${ver}.so ${phpdir}ioncube.so
elif [[ -f ${phpdir}ioncube_loader_lin_${ver}.so ]]; then
  echo -e "\n${phpdir}ioncube_loader_lin_${ver}.so driver file exists, backing up before updating.\n"
  gzip ${phpdir}ioncube_loader_lin_${ver}* && cp ~/downloads/ioncube/ioncube_loader_lin_${ver}* ${phpdir}
fi

# Create correct config file for the service if necessary
if [[ -f ${config} ]]; then
  echo -e "${config} file already exists!\n";
else
  echo -e "Setting up new /etc/php.d/ioncube-loader.ini file\n"
  echo -e "zend_extension=${phpdir}ioncube_loader_lin_${ver}.so" >> /etc/php.d/ioncube-loader.ini;
fi

# Check configs and restart php/httpd services
if [[ -d /etc/php-fpm.d/ ]]; then
  php -v && service php-fpm restart
else
  php -v && httpd -t && service httpd restart;
fi
}

## Install ZendGuard for CentOS 5/6
zendguardinstall(){
if [[ $1 =~ [0-9]\.[0-9] ]]; then ver="$1";
else read -p "What is the running PHP version: " ver; fi

# Create Download Directory
if [[ ! -d ~/downloads ]]; then mkdir ~/downloads; fi

# Download archive into directory and unpack
cd ~/downloads/
wget http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-${ver}-linux-glibc23-x86_64.tar.gz
tar -zxvf ZendGuardLoader-php-${ver}-linux-glibc23-x86_64.tar.gz

# Copy driver the correct .so file to the target directory
if [[ ! -f /usr/lib64/php/modules/ZendGuardLoader.so ]]; then
cp ~/downloads/ZendGuardLoader-php-${ver}-linux-glibc23-x86_64/php-${ver}.x/ZendGuardLoader.so /usr/lib64/php/modules/
else echo "ZendGuardLoader.so already exists! Backing up current version before continuing.";
gzip /usr/lib64/php/modules/ZendGuardLoader.so && cp ~/downloads/ZendGuardLoader-php-${ver}-linux-glibc23-x86_64/php-${ver}.x/ZendGuardLoader.so /usr/lib64/php/modules/
fi

# Create correct config file for the service
if [[ ! -f /etc/php.d/ZendGuard.ini && ! -f /etc/php.d/ioncube.ini && ! -f /etc/php.d/ioncube-loader.ini ]]; then file="/etc/php.d/ZendGuard.ini"
elif [[ -f /etc/php.d/ioncube-loader.ini ]]; then file="/etc/php.d/ioncube-loader.ini";
elif [[ -f /etc/php.d/ioncube.ini ]]; then file="/etc/php.d/ioncube.ini"
elif [[ -f /etc/php.d/ZendGuard.ini ]]; then echo "ZendGuard.ini file already exists!";  file="/dev/null"; fi
echo "Adding Zend Guard config to $file"
echo -e "\n; Enable Zend Guard extension\nzend_extension=/usr/lib64/php/modules/ZendGuardLoader.so\nzend_loader.enable=1\n" >> $file

# Check configs and restart php/httpd services
if [[ -d /etc/php-fpm.d/ ]]; then php -v && service php-fpm restart
else httpd -t && service httpd restart; fi
}

## Rewrite of Ted Wells sinfo
sinfo(){
echo; FMT='%-14s: %s\n'
printf "$FMT" "Hostname" "$(serverName)"
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
printf "$FMT" "FTP/sFTP/SSH" "ProFTPD ($(proftpd --version | awk '{print $3}')); OpenSSH ($(ssh -V 2>&1 | cut -d, -f1 | awk -F_ '{print $2}'))"; fi
printf "\n$FMT" "CPUs (Type)" "$(awk '/model name/{print $4,$5,$7,$9,$10}' /proc/cpuinfo | uniq -c | awk '{print $1,"- "$2,$3" - "$4,$5,$6}')"
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

## Archive a particular target, adding time and date information
archive(){
echo; if [[ -z "$@" ]]; then echo -e " Usage: archive <target>\n"; return 0; fi
FILE=$(getusr).$(hostname | cut -d. -f1)--$(echo "$1" | sed s/"\/"/"-"/g)-$(date +%Y.%m.%d-%H.%M).tgz;
SIZE=$(du -sb "$1" | cut -f1); SIZEM=$(echo "scale=3;$SIZE/1024/1024" | bc); echo "Compressing ${SIZEM}M ... please be patient."
if [[ -f /usr/bin/pv && -f /usr/bin/pigz ]]; then
    tar -cf - "$1" | pv -s ${SIZE} | pigz -c > $FILE;
elif [[ -f /usr/bin/pv ]]; then
    tar -cf - "$1" | pv -s ${SIZE} | gzip -c > $FILE;
else
    echo "Sorry, no idea how long this will take ..."; tar -zcf  $FILE "$1";
fi && echo -e "\nArchive created successfully!\n\n$PWD/\n$FILE\n";
if [[ -f $FILE ]]; then
    read -p "Chown file to [r]oot or [u]ser? [r/u]: " yn;
    if [[ $yn = "r" ]]; then
	U='root';
    else U=$(getusr); fi;
    chown $U. $FILE && echo -e "Archive owned to $U\n"; fi
}

## Update ownership to the username for the PWD
fixowner(){
U=$(getusr)
if [[ -z $2 ]]; then P='.'; else P=$2; fi
case $1 in
    -u|--user) owner="$U:$U" ;;
    -a|--apache) owner="apache:$U" ;;
    -r|--root) owner="root:root" ;;
    *|-h|--help) echo -e "\n Usage: fixowner [option] [path]\n    -u | --user ..... Change ownership to $U:$U\n    -a | --apache ... Change ownership to apache:$U\n    -r | --root ..... Change ownership to root:root\n    -h | --help ..... Show this help output\n"; return 0 ;;
esac
chown -R $owner $P && echo -e "\n Files owned to $owner\n"
}

## Set default permissions for files and directories
fixperms(){
if [[ $1 == '-h' || $1 == '--help' ]]; then echo -e "\n Usage: fixperms [path]\n    Set file permissions to 644 and folder permissions to 2755\n"; return 0; fi
if [[ -n $1 ]]; then SITEPATH="$1"; else SITEPATH="."; fi

if [[ $(grep -i ^loadmodule.*php[0-9]_module /etc/httpd/conf.d/php.conf) ]]; then perms="664"; else perms="644"; fi
printf "\nFixing File Permissions ($perms) ... "; find $SITEPATH -type f -exec chmod $perms {} \;
if [[ $(grep -i ^loadmodule.*php[0-9]_module /etc/httpd/conf.d/php.conf) ]]; then perms="2775"; else perms="2755"; fi
printf "Fixing Directory Permissions ($perms) ... "; find $SITEPATH -type d -exec chmod $perms {} \;
printf "Operation Completed.\n\n";
}

## Generate .ftpaccess file to create read only FTP user
# http://www.proftpd.org/docs/howto/Limit.html
ftpreadonly(){
echo; if [[ -z "$1" ]]; then read -p "FTP Username: " U; else U="$1"; fi
sudo -u $(getusr) echo -e "\n<Limit WRITE>\n  DenyUser $U\n</Limit>\n" >> .ftpaccess &&
echo -e "\n.ftpaccess file has been updated.\n"
}

complete -W '-h --help -u --user -p --pass -l' htpasswdauth
## Generate or update .htpasswd file to add username
htpasswdauth(){
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
echo -e "\n Usage: htpasswdauth [-u|--user username] [-p|--pass password] [-l length]\n    Ex: htpasswdauth -u username -p passwod\n    Ex: htpasswdauth -u username -l 5\n    Ex: htpasswdauth -u username\n"; return 0; fi
if [[ -z $1 ]]; then echo; read -p "Username: " U; elif [[ $1 == '-u' || $1 == '--user' ]]; then U="$2"; fi;
if [[ -z $3 ]]; then P=$(xkcd); elif [[ $3 == '-p' || $3 == '--pass' ]]; then P="$4"; elif [[ $3 == '-l' ]]; then P=$(xkcd -l $4); fi
if [[ -f .htpasswd ]]; then sudo -u $(getusr) htpasswd -mb .htpasswd $U $P; else sudo -u $(getusr) htpasswd -cmb .htpasswd $U $P; fi;
echo -e "\nUsername: $U\nPassword: $P\n";
}

## Create or add http-auth section for given .htaccess file
htaccessauth(){
sudo -u $(getusr) echo -e "\n# ----- Password Protection Section -----
\nAuthUserFile $(pwd)/.htpasswd
AuthGroupFile /dev/null
AuthName \"Authorized Access Only\"
AuthType Basic
\nRequire valid-user
\n# ----- Password Protection Section -----\n" >> .htaccess
}

## Manage .htaccess black-lists, white-lists, and bot-lists.
htlist(){
# Parse through options/parameters
if [[ $1 =~ -p ]]; then SITEPATH=$2; shift; shift; else SITEPATH='.'; fi; opt=$1

# Run correct for-loop given list type
case $opt in
-b | --black)
  if ! grep -Eq '.rder .llow,.eny' $SITEPATH/.htaccess &> /dev/null; then
    sudo -u $(getusr) echo -e "Order Allow,Deny\nAllow From All" >> $SITEPATH/.htaccess &&
    echo "$SITEPATH/.htaccess rules updated";
  fi
  shift; echo; for x in "$@"; do
    sed -i "s/\b\(.rder .llow,.eny\)/\1\nDeny From $x/" $SITEPATH/.htaccess &&
    echo "Deny From $x ... Added to $SITEPATH/.htaccess"
  done; echo
  ;;

-w | --white)
  if ! grep -Eq '.rder .eny,.llow' $SITEPATH/.htaccess &> /dev/null; then
    sudo -u $(getusr) echo -e "Order Deny,Allow\nDeny From All" >> $SITEPATH/.htaccess &&
    echo "$SITEPATH/.htaccess rules updated";
  fi
  shift; echo; for x in "$@"; do
    sed -i "s/\b\(.rder .eny,.llow\)/\1\nAllow From $x/" $SITEPATH/.htaccess &&
    echo "Allow From $x ... Added to $SITEPATH/.htaccess"
  done; echo
  ;;

-r | --robot)
  if grep -Eq '.rder .llow,.eny' $SITEPATH/.htaccess &> /dev/null; then
  sed -i 's/\b\(.rder .llow,.eny\)/\1\nDeny from env=bad_bot/' $SITEPATH/.htaccess
  else sudo -u $(getusr) echo -e "\nOrder Allow,Deny\nDeny from env=bad_bot\nAllow from All" >> $SITEPATH/.htaccess && echo "$SITEPATH/.htaccess rules updated."; fi

  shift; echo
  echo -e "\n# ----- Block Bad Bots Section -----\n" >> $SITEPATH/.htaccess
  for x in "$@"; do echo "BrowserMatchNoCase $x bad_bot" | tee -a $SITEPATH/.htaccess; done
  echo -e "\n# ----- Block Bad Bots Section -----\n" >> $SITEPATH/.htaccess; echo
  ;;

-h|--help|*)
  echo -e "\n  Usage: htlist [options] <listType> <IP1> <IP2> ...\n
    Options:
    -p | --path .... Path to .htaccess file
    -h | --help .... Print this help and quit

    List Types:
    -b | --black ... Blacklist IPs
    -w | --white ... Whitelist IPs
    -r | --robot ... Block UserAgent\n";
    return 0;
  ;;

esac
}

## Generate nexinfo.php to view php info in browser
nexinfo(){
sudo -u "$(getusr)" echo '<?php phpinfo(); ?>' > nexinfo.php
echo -e "\nhttp://$(pwd | sed 's:^/chroot::' | cut -d/ -f4-)/nexinfo.php created successfully.\n" | sed 's/html\///';
}

## System resource usage by account
sysusage(){
echo; colsort="4"; printf "%-10s %10s %10s %10s %10s\n" "User" "Mem (MB)" "Process" "CPU(%)" "MEM(%)"; echo "$(dash 54)"
ps aux | grep -v ^USER | awk '{ mem[$1]+=$6; procs[$1]+=1; pcpu[$1]+=$3; pmem[$1]+=$4; } END { for (i in mem) { printf "%-10s %10.2f %10d %9.1f%% %9.1f%%\n", i, mem[i]/(1024), procs[i], pcpu[i], pmem[i] } }' | sort -nrk$colsort | head; echo
}

# Lookup Siteworx account details
acctdetail(){
  nodeworx -u -n -c Siteworx -a querySiteworxAccountDetails --domain $(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}')\
  | sed 's:\([a-zA-Z]\) \([a-zA-Z]\):\1_\2:g;s:\b1\b:YES:g;s:\b0\b:NO:g' | column -t
}

## Add an IP to a Siteworx account
addip(){ nodeworx -u -n -c Siteworx -a addIp --domain $(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}') --ipv4 $1; }

## Enable Siteworx backups for an account
addbackups(){ nodeworx -u -n -c Siteworx -a edit --domain $(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}') --OPT_BACKUP 1; }

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
if [[ $NEW_IPADDR =~ ^172\. ]]; then INTERNAL=$(curl -s http://mdsc.info/r1bs-internal); fi

_printbackupsvr(){
  if [[ $1 =~ ^172\. ]]; then
    for x in $INTERNAL; do echo -n $x | awk -F_ "/$1/"'{printf "R1Soft IP..: https://"$3":8001\n" "R1Soft rDNS: https://"$2":8001\n"}'; done
  else
    IP=$1; RDNS=$(dig +short -x $1 2> /dev/null);
    echo "R1Soft IP..: https://${IP}:8001";
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
for x in $(echo $D | sed 's/\// /g'); do echo -e "\nDNS Summary: $x\n$(dash 79)";
for y in a aaaa ns mx txt soa; do dig +time=2 +tries=2 +short $y $x +noshort;
if [[ $y == 'ns' ]]; then dig +time=2 +tries=2 +short $(dig +short ns $x) +noshort | grep -v root; fi; done;
dig +short -x $(dig +time=2 +tries=2 +short $x) +noshort; echo; done
}

## List server IPs, and all domains configured on them.
domainips(){
echo; for I in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.'); do
    printf "  ${BRIGHT}${YELLOW}%-15s${NORMAL}  " "$I";
    D=$(grep -l $I /etc/httpd/conf.d/vhost_[^000_]*.conf | cut -d_ -f2 | sed 's/.conf$//');
    for x in $D; do printf "$x "; done; echo;
done; echo
}

## Find IPs in use by a Siteowrx account
accountips(){ domaincheck -a $1; }

## Find IPs in use by a Reseller account
resellerips(){ domaincheck -r $1; }

## Match secondary domains to IPs on the server using vhost files
domaincheck(){
vhost="$(echo /etc/httpd/conf.d/vhost_[^000]*.conf)"; sub='';

case $1 in
  -a) if [[ -n $2 ]]; then sub=$2; else sub=''; fi
      vhost="$(grep -l $(getusr) /etc/httpd/conf.d/vhost_[^000]*.conf)" ;;
  -r) if [[ -z $2 ]]; then read -p "ResellerID: " r_id; else r_id=$2; fi;
      vhost=$(for r_user in $(nodeworx -unc Siteworx -a listAccounts | awk "(\$5 ~ /^$r_id$/)"'{print $2}'); do grep -l $r_user /etc/httpd/conf.d/vhost_[^000]*.conf; done | sort | uniq) ;;
  -v) FMT=" %-15s  %-15s  %3s  %3s  %3s  %s\n"
      HLT="${BRIGHT}${RED} %-15s  %-15s  %3s  %3s  %3s  %s${NORMAL}\n"
      #printf "$FMT" " Server IP" " Live IP" "SSL" "FPM" "TMP" " Domain"
      #printf "$FMT" "$(dash 15)" "$(dash 15)" "---" "---" "---" "$(dash 44)"
      ;;
esac; echo

FMT=" %-15s  %-15s  %3s  %3s  %s\n"
HLT="${BRIGHT}${RED} %-15s  %-15s  %3s  %3s  %s${NORMAL}\n"
printf "$FMT" " Server IP" " Live IP" "SSL" "FPM" " Domain"
printf "$FMT" "$(dash 15)" "$(dash 15)" "---" "---" "$(dash 44)"

for x in $vhost; do
   D=$(basename $x .conf | cut -d_ -f2);
   V=$(awk '/.irtual.ost/ {print $2}' $x | head -1 | cut -d: -f1);
   I=$(dig +short +time=1 +tries=1 ${sub}$D | grep -E '^[0-9]{1,3}\.' | head -1);
   S=$(if grep :443 $x &> /dev/null; then echo SSL; fi);
   F=$(if grep MAGE_RUN $x &> /dev/null; then echo FIX; fi);
   if [[ "$I" != "$V" ]];
   then printf "$HLT" "$V" "$I" "${S:- - }" "${F:- - }" "${sub}$D";
   else printf "$FMT" "$V" "$I" "${S:- - }" "${F:- - }" "${sub}$D"; fi
 done; echo
}

## Find IPs that are not configured in any vhost files
freeips(){
echo; for x in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.|^10\.|^172\.'); do
  printf "\n%-15s " "$x"; grep -l $x /etc/httpd/conf.d/vhost_[^000_]*.conf 2> /dev/null;
done | grep -v \.conf$ | column -t; echo
}

## Check if gzip is working for domain(s)
chkgzip(){
echo; if [[ -z "$@" ]]; then read -p "Domain name(s): " DNAME; else DNAME="$@"; fi
for x in "$DNAME"; do curl -I -H 'Accept-Encoding: gzip,deflate' $x; done; echo
}

## Check Time To First Byte with curl
ttfb(){
if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then echo -e "\n Usage: ttfb [mag] <domain>\n"; return 0; fi;

_timetofirstbyte(){ curl -so /dev/null -w "HTTP: %{http_code} Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} Redirect URL: %{redirect_url}\n" "$1"; }
if [[ "$1" == "m" || "$1" == "mag" ]]; then if [[ -z "$2" ]]; then read -p "Domain: " D; else D="$2"; fi;
for x in index.php robots.txt; do echo -e "\n$D/$x"; _timetofirstbyte "$D/$x"; done;
else D="$1"; echo; _timetofirstbyte "$D"; fi; echo
}

## CD to document root in vhost containing the given domain
cdomain(){
if [[ -z "$@" ]]; then echo -e "\n  Usage: cdomain <domain.tld>\n"; return 0; fi
vhost=$(grep -l " $(echo $1 | sed 's/\(.*\)/\L\1/g')" /etc/httpd/conf.d/vhost_[^000]*.conf)
if [[ -n $vhost ]]; then cd $(awk '/DocumentRoot/ {print $2}' $vhost | head -1); pwd;
else echo -e "\nCould not find $1 in the vhost files!\n"; fi
}

## Attempt to list Secondary Domains on an account
ldomains(){
DIR=$PWD; cd /home/$(getusr); for x in */html; do echo $x | sed 's/\/html//g'; done; cd $DIR
}

## Edit a list of vhosts in a loop for adding temp fixes
tempfix(){
for x in $(echo "$@" | sed 's/\// /g'); do nano /etc/httpd/conf.d/vhost_$x.conf; done; httpd -t && service httpd reload
}

## List the usernames for all accounts on the server
laccounts(){ ~iworx/bin/listaccounts.pex | awk '{print $1}'; }

## List Sitworx accouts sorted by Reseller
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

## Backup, and restore a database from a snapshot file
restoredb(){
echo; if [[ -z "$1" ]]; then read -p "Backup filename: " DBFILE; else DBFILE="$1"; fi;

DBNAME=$(echo $DBFILE | cut -d. -f1);
echo "Creating current $DBNAME backup ..."; mdz $DBNAME;
echo "Dropping current $DBNAME ..."; m -e"drop database $DBNAME";
echo "Creating empty $DBNAME ..."; m -e"create database $DBNAME";
echo "Importing backup $DBFILE ...";

if [[ $DBFILE =~ \.gz$ ]]; then SIZE=$(gzip -l $DBFILE | awk 'END {print $2}');
elif [[ $DBFILE =~ \.zip$ ]]; then SIZE=$(unzip -l $DBFILE | awk '{print $1}'); fi

if [[ -f /usr/bin/pv ]]; then zcat -f $DBFILE | pv -s $SIZE | m $DBNAME;
else zcat -f $DBFILE | m $DBNAME; fi;

if [[ -d /home/mysql/$DBNAME/ ]]; then echo "Fixing Ownership on new DB ..."; chown -R mysql:$(echo $DBNAME | cut -d_ -f1) /home/mysql/$DBNAME/; fi
echo
}

## Kill SELECT or Sleep queries on a server, potentialy for just one username
killqueries(){
_querieslog(){ filename="mytop-dump--$(date +%Y.%m.%d-%H.%M).dump";
	mytop -b --nocolor > ~/"$filename"; echo -e "\n~/$filename created ...\nBegin killing queries ..."; }
case $1 in
sel|select) _querieslog; x=$(awk '/SELECT/ {print $1}' ~/"$filename");
	for i in $x; do echo "Killing: $i"; m -e"kill $i"; done; echo -e "Operation completed.\n" ;;
sle|sleep) _querieslog; x=$(awk '/Sleep/ {print $1}' ~/"$filename");
	for i in $x; do echo "Killing $i"; m -e"kill $i"; done; echo -e "Operation completed.\n" ;;
-h|--help|*) echo -e "\n Usage: killqueries [sleep|select]\n" ;;
esac
}

## Create user functions for memcached socket configured in local.xml
memcachedalias(){
if [[ -z $1 || $1 == '-h' || $1 == '--help' ]]; then
    echo -e "\n Usage: memcachealias [sitepath] [name]\n"
elif [[ -f $1/app/etc/local.xml ]]; then
    if [[ -n $2 ]]; then NAME="_$2"; else NAME='_memcached'; fi
    U=$(getusr);
    CACHE_SOCKET=$(grep -Eo '\/var.*_cache\.sock' $1/app/etc/local.xml | head -1)
    SESSIONS_SOCKET=$(grep -Eo '\/var.*_sessions\.sock' $1/app/etc/local.xml | head -1)

    echo; for x in flush_all stats; do
        if [[ -n $SESSIONS_SOCKET ]]; then
            echo "Adding ${x}${NAME}_cache to /home/$U/.bashrc ... ";
            sudo -u $U echo "${x}${NAME}_cache(){ echo $x \$@ | nc -U $CACHE_SOCKET; }" >> /home/$U/.bashrc;
            echo "Adding ${x}${NAME}_sessions to /home/$U/.bashrc ... ";
            sudo -u $U echo "${x}${NAME}_sessions(){ echo $x \$@ | nc -U $SESSIONS_SOCKET; }" >> /home/$U/.bashrc;
        else
            echo "Adding ${x}${NAME}_cache to /home/$U/.bashrc ... ";
	    sudo -u $U echo "${x}${NAME}_cache(){ echo $x \$@ | nc -U $CACHE_SOCKET; }" >> /home/$U/.bashrc; fi;
    done; echo;

    echo "Adding bash completion for stats function"
        sudo -u $U echo -e "\ncomplete -W 'items slabs detail sizes reset' stats${NAME}_cache" >> /home/$U/.bashrc
        sudo -u $U echo -e "\ncomplete -W 'items slabs detail sizes reset' stats${NAME}_sessions" >> /home/$U/.bashrc
    echo "Adding $U to the (nc) group"; usermod -a -G nc $U; echo;
else echo "\n Could not find local.xml file in $1\n"; fi;
}

## Add PHP-FPM fix for pointer method Magento Multistores
fpmfix(){
if [[ -z $1 || $1 == '.' ]]; then D=$(pwd | sed 's:^/chroot::' | cut -d/ -f4);
else D=$(echo $1 | sed 's:/::g'); fi
vhost="/etc/httpd/conf.d/vhost_${D}.conf"

if [[ -f $vhost ]]; then
  sed -i 's/\(RewriteCond.*\.fcgi\)/\1\n  # ----- PHP-FPM-Multistore-Fix -----\n  SetEnvIf REDIRECT_MAGE_RUN_CODE (\.\+) MAGE_RUN_CODE=\$1\n  SetEnvIf REDIRECT_MAGE_RUN_TYPE (\.\+) MAGE_RUN_TYPE=\$1\n  # ----- PHP-FPM-Multistore-Fix -----/g' $vhost
  httpd -t && service httpd reload && echo -e "\nFPM fix has been applied to $(basename $vhost)\n"
else echo -e "\n$(basename $vhost) not found!\n";
fi
}


## Set common and custom php-fpm configuration options
fpmconfig(){

if [[ -f $(echo /opt/nexcess/php5*/root/etc/php-fpm.d/$(getusr).conf) ]]; then
  config="/opt/nexcess/php5*/root/etc/php-fpm.d/$(getusr).conf";
  srv="$(echo $config | cut -d/ -f4)-php-fpm";
elif [[ -f /etc/php-fpm.d/$(getusr).conf ]]; then
  config="/etc/php-fpm.d/$(getusr).conf";
  srv="php-fpm"; fi;

_fpmconfig(){
    if [[ $(grep $1 $config 2> /dev/null) ]]; then
      echo -e "\n$1 is already configured in the PHP-FPM pool $config\n";
      awk "/$1/"'{print}' $config; echo
    elif [[ -f $(echo $config) ]]; then
      echo "php_admin_value[$1] = $2" >> $config && service $srv reload && echo -e "\n$1 has been set to $2 in the PHP-FPM pool for $config\n";
    else
      echo -e "\n Could not find $config !\n Try running this from the user's /home/dir/\n"; fi;
    }

case $1 in
-a) _fpmconfig apc.enabled Off ;;
-b) _fpmconfig open_basedir "$(php -i | awk '/open_basedir/ {print $NF}'):$2" ;;
-c) _fpmconfig $2 $3 ;;
-d) _fpmconfig display_errors On ;;
-e) _fpmconfig max_execution_time $2 ;;
-f) _fpmconfig allow_url_fopen On ;;
-g|-z) _fpmconfig zlib.output_compression On ;;
-m) _fpmconfig memory_limit $2 ;;
-s) _fpmconfig session.cookie_lifetime $2; _fpmconfig session.gc_maxlifetime $2 ;;
-u) _fpmconfig upload_max_filesize $2; _fpmconfig post_max_size $2 ;;
-h) echo -e "\n Usage: fpmconfig [option] [value]
  Options:
    -a ... Disable APC
    -b ... Set open_basedir
    -c ... Set a custom [parameter] to [value]
    -d ... Enable display_errors
    -e ... Set max_execution_time to [value]
    -f ... Enable allow_url_fopen
    -g ... Enable gzip (zlib.output_compression)
    -m ... Set memory_limit to [value]
    -s ... Set session timeouts (session.gc_maxlifetime, session.cookie_lifetime)
    -u ... Set upload_max_filesize and post_max_size to [value]
    -z ... Enable gzip (zlib.output_compression)

    -h ... Print this help output and quit
    Default behavior is to print the contents and location of config file.\n"
    ;;

 *) echo; ls $config; echo; cat $config; echo;;
esac;

unset srv config;
}

## Enable zlib.output_compression for a user's PHP-FPM config pool
fpmgzip(){ fpmconfig -g; }

## Enable allow_url_fopen for a users PHP-FPM config pool
fpmfopen(){ fpmconfig -f; }

## Setup parallel downloads in vhost
magparallel(){
if [[ -z $@ || $1 == '-h' || $1 == '--help' ]]; then echo -e '\n Usage: parallel <domain> \n'; return 0;
elif [[ -f /etc/httpd/conf.d/vhost_$1.conf ]]; then D=$1;
elif [[ $1 == '.' && -f /etc/httpd/conf.d/vhost_$(pwd | sed 's:^/chroot::' | cut -d/ -f4).conf ]]; then D=$(pwd | sed 's:^/chroot::' | cut -d/ -f4)
else echo -e '\nCould not find requested vhost file!\n'; return 1; fi
domain=$(echo $D | sed 's:\.:\\\\\\.:g'); # Covert domain into Regex
# Place comment followed by a blank line, logic for parallel downloads, then another comment preceded by a blank line
sed -i "s:\(.*RewriteCond %{HTTP_HOST}...$domain.\[NC\]\):\1\n  \# ----- Magento-Parallel-Downloads -----\n:g" /etc/httpd/conf.d/vhost_$D.conf
for x in skin media js; do sed -i "s:\(.*RewriteCond %{HTTP_HOST}...$domain.\[NC\]\):\1\n  RewriteCond %{HTTP_HOST} \!\^$x\\\.$domain [NC]:g" /etc/httpd/conf.d/vhost_$D.conf; done
sed -i "s:\(.*RewriteCond %{HTTP_HOST}...$domain.\[NC\]\):\1\n\n  \# ----- Magento-Parallel-Downloads -----:g" /etc/httpd/conf.d/vhost_$D.conf
httpd -t && service httpd reload && echo -e "\nParallel Downloads configure for $D\n" # Test and restart Apache, print success message
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
echo; U=$(getusr); if [[ -z $1 ]]; then read -p "Domain Name: " D; else D=$1; fi
for X in app includes js lib media skin var; do sudo -u $U ln -s /home/$U/$D/html/$X/ $X; done;
echo; read -p "Copy .htaccess and index.php? [y/n]: " yn; if [[ $yn == "y" ]]; then
for Y in index.php .htaccess; do sudo -u $U cp /home/$U/$D/html/$Y .; done; fi
}

## Look up large tables of a given database to see what's taking up space
tablesize(){
if [[ -z $1 || $1 == '-h' || $1 = '--help' ]]; then
  echo -e "\n  Usage: tablesize [dbname] [option] [linecount]\n\n  Options:\n    -r ... Sort by most Rows\n    -d ... Sort by largest Data_Size\n    -i ... Sort by largest Index_Size\n"; return 0; fi
if [[ $1 == '.' ]]; then dbname=$(finddb); shift;
  elif [[ $1 =~ ^[a-z]{1,}_.*$ ]]; then dbname="$1"; shift;
  else read -p "Database: " dbname; fi
case $1 in
 -r ) col='4'; shift;;
 -d ) col='6'; shift;;
 -i ) col='8'; shift;;
  * ) col='6';;
esac
if [[ $1 =~ [0-9]{1,} ]]; then top="$1"; else top="20" ; fi
echo -e "\nDatabase: $dbname\n$(dash 93)"; printf "| %-50s | %8s | %11s | %11s |\n" "Name" "Rows" "Data_Size" "Index_Size"; echo "$(dash 93)";
echo "show table status" | m $dbname | awk 'NR>1 {printf "| %-50s | %8s | %10.2fM | %10.2fM |\n",$1,$5,($7/1024000),($9/1024000)}' | sort -rnk$col | head -n$top
echo -e "$(dash 93)\n"
}

## Find Magento database connection info, and run common queries
magdb(){
echo; runonce=0;
if [[ $1 =~ ^-.*$ ]]; then SITEPATH='.'; opt="$1"; shift; param="$@";
else SITEPATH="$1"; opt="$2"; shift; shift; param="$@"; fi;

tables="core_cache core_cache_option core_cache_tag core_session dataflow_batch_import dataflow_batch_export\
    index_process_event log_customer log_quote log_summary log_summary_type\
    log_url log_url_info log_visitor log_visitor_info log_visitor_online\
    report_viewed_product_index report_compared_product_index report_event catalog_compare_item"

prefix="$(echo 'cat /config/global/resources/db/table_prefix/text()' | xmllint --nocdata --shell $SITEPATH/app/etc/local.xml | sed '1d;$d')"
adminurl="$(echo 'cat /config/admin/routers/adminhtml/args/frontName/text()' | xmllint --nocdata --shell $SITEPATH/app/etc/local.xml | sed '1d;$d')"

# if [[ -f $SITEPATH/app/etc/local.xml ]]; then continue=1; else echo -e "\n ${RED}Could not find Magento configuration file!${NORMAL}\n"; return 0; fi

_magdbusage(){ echo " Usage: magdb [<path>] <option> [<query>]
    -a | --amazon .... Show Amazon errors from the exception log
    -A | --admin ..... Add a new admin user into the database ${CYAN}(New)${NORMAL}
    -b | --base ...... Show all configured Base Urls
    -B | --backup .... Backup the Magento database as the user
    -c | --cron ...... Show Cron Jobs and Their Statuses
    -d | --dataflow .. Show size of dataflow batch tables
    -e | --execute ... Execute a custom query (use '*' and \\\")
    -i | --info ...... Display user credentials for database
    -l | --login ..... Log into database using user credentials
    -L | --logsize ... Show size of the log tables
    -m | --multi ..... Show Multistore Information (Urls/Codes)
    -o | --logclean .. Clean out (truncate) log tables
    -O | --optimize .. Truncate and optimize log tables
    -p | --parallel .. Show all parallel download base_urls
    -P | --password .. Update or reset password for user
    -r | --rewrite ... Show the count of Url Rewrites
    -s | --swap ...... Temporarily swap out admin password ${RED}${BRIGHT}(BETA!)${NORMAL}
    -u | --users ..... Show all Admin Users' information
    -v | --visit ..... Show count of Visitors in the Log
    -x | --index ..... Show Current Status of all Re-Index Processes
    -X | --reindex ... Execute a reindex as the user (indexer.php)
    -z | --zend ...... Clear user's Zend cache files in /tmp/

    -h | --help ...... Display this help output and quit"
    return 0; }

_magdbinfo(){ if [[ -f $SITEPATH/app/etc/local.xml ]]; then #Magento
    dbhost="$(echo 'cat /config/global/resources/default_setup/connection/host/text()' | xmllint --nocdata --shell $SITEPATH/app/etc/local.xml | sed '1d;$d')"
    dbuser="$(echo 'cat /config/global/resources/default_setup/connection/username/text()' | xmllint --nocdata --shell $SITEPATH/app/etc/local.xml | sed '1d;$d')"
    dbpass="$(echo 'cat /config/global/resources/default_setup/connection/password/text()' | xmllint --nocdata --shell $SITEPATH/app/etc/local.xml | sed '1d;$d')"
    dbname="$(echo 'cat /config/global/resources/default_setup/connection/dbname/text()' | xmllint --nocdata --shell $SITEPATH/app/etc/local.xml | sed '1d;$d')"
    ver=($(grep 'function getVersionInfo' -A8 $SITEPATH/app/Mage.php | grep major -A4 | cut -d\' -f4)); version="${ver[0]}.${ver[1]}.${ver[2]}.${ver[3]}"
    if grep -E 'Enterprise Edition|Commercial Edition' $SITEPATH/app/Mage.php > /dev/null; then edition="Enterprise Edition"; else edition="Community Edition"; fi
    else echo "${RED}Could not find configuration file!${NORMAL}"; return 1; fi; }

_magdbsum(){ echo -e "${BRIGHT}$edition: ${RED}$version ${NORMAL}\n${BRIGHT}Connection Summary: ${RED}$dbuser:$dbname$(if [[ -n $prefix ]]; then echo .$prefix; fi)${NORMAL}\n"; }

_magdbconnect(){ _magdbinfo && if [[ $runonce -eq 0 ]]; then _magdbsum; runonce=1; fi && mysql -u"$dbuser" -p"$dbpass" -h $dbhost $dbname "$@"; }

_magdbbackup(){ _magdbinfo;
        if [[ -x /usr/bin/pigz ]]; then COMPRESS="/usr/bin/pigz"; echo "Compressing with pigz";
                else COMPRESS="/usr/bin/gzip"; echo "Compressing with gzip"; fi
        echo "Using: mysqldump --opt --skip-lock-tables -u'$dbuser' -p'$dbpass' -h $dbhost $dbname";
        if [[ -f /usr/bin/pv ]]; then sudo -u $(getusr) mysqldump --opt --skip-lock-tables -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
                | pv -N 'MySQL-Dump' | $COMPRESS --fast | pv -N 'Compression' > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz;
        else sudo -u $(getusr) mysqldump --opt --skip-lock-tables -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
                | $COMPRESS --fast > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz; fi; }

case $opt in
 -a|--amazon) _magdbconnect -e "SELECT * FROM ${prefix}amazon_log_exception ORDER BY log_id DESC LIMIT 1;";;
 -A|--admin) read -p "Firstname: " firstname; read -p "Lastname: " lastname; read -p "Email: " emailaddr; read -p "Username: " username; password=$(xkcd);
        _magdbconnect -e "INSERT INTO ${prefix}admin_user SELECT NULL \`user_id\`, \"$firstname\" \`firstname\`, \"$lastname\" \`lastname\`, \"$emailaddr\" \`email\`, \"$username\" \`username\`, MD5(\"$password\") \`password\`, NOW() \`created\`, NULL \`modified\`, NULL \`logdate\`, 0 \`lognum\`, 0 \`reload_acl_flag\`, 1 \`is_active\`, NULL \`extra\`, NULL \`rp_token\`, NOW() \`rp_token_created_at\`";
        _magdbconnect -e "INSERT INTO ${prefix}admin_role SELECT NULL \`role_id\`, (SELECT \`role_id\` FROM ${prefix}admin_role WHERE \`role_name\` = 'Administrators') \`parent_id\`, 2 \`tree_level\`, 0 \`sort_order\`, 'U' \`role_type\`, (SELECT \`user_id\` FROM ${prefix}admin_user WHERE \`username\` = \"$username\") \`user_id\`, 'admin' \`role_name\`;";
        echo -e "Username: $username\nPassword: $password" ;;
 -b|--base) _magdbconnect -e "SELECT * FROM ${prefix}core_config_data WHERE path RLIKE \"base_url\";";;
 -B|--backup) _magdbbackup ;;
 -c|--cron) runonce=1; if [[ -z $param ]]; then
          _magdbconnect -e "SELECT * FROM ${prefix}cron_schedule;"
        elif [[ $param =~ ^clear$ ]]; then
          _magdbconnect -e "DELETE FROM ${prefix}cron_schedule WHERE status RLIKE \"success|missed\";"
          echo "Cron_Schedule table has been cleared of old crons"
        elif [[ $param =~ ^clear.*-f$ ]]; then
          _magdbconnect -e "TRUNCATE ${prefix}cron_schedule;"
          echo "Cron_Schedule table has been truncated"
        elif [[ $param == '-h' || $param == '--help' ]]; then
          echo -e " Usage: magdb [<path>] <-c|--cron> [clear] [-f]\n    clear : Remove completed or missed cron jobs\n    clear -f : Truncate the cron_schedule table"
        fi ;;
 -e|--execute) _magdbconnect -e "${param};" ;;
 -i|--info) _magdbinfo; echo "Database Connection Info:";
    echo -e "\nLoc.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $dbhost \nRem.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $(hostname)\n";
    echo -e "Username: $dbuser \nPassword: $dbpass \nDatabase: $dbname $(if [[ -n $prefix ]]; then echo \\nPrefix..: $prefix; fi) \nLoc.Host: $dbhost \nRem.Host: $(hostname)";;
 -l|--login) _magdbconnect;;
 -L|--logsize|-d|--dataflow|-v|--visit|-r|--rewrite) _magdbinfo; _magdbsum; datatotal=0; indextotal=0; rowtotal=0; freetotal=0;
        if [[ $opt == '-d' || $opt == '--dataflow' ]]; then tables="dataflow_batch_import dataflow_batch_export";
        elif [[ $opt == '-v' || $opt == '--visit' ]]; then tables="log_visitor log_visitor_info log_visitor_online";
        elif [[ $opt == '-r' || $opt == '--rewrite' ]]; then tables="core_url_rewrite"; fi
        div='+------------------------------------------+-----------------+----------------+----------------+'
        LOGFMT="| %-40s | %15s | %12s M | %12s M |\n"
        echo $div; printf "$LOGFMT" "Table Name" "Row Count" "Data Size" "Index Size"; echo $div
        for x in $tables; do
            datasize=$(_magdbconnect -e "SELECT data_length/1024000 FROM information_schema.TABLES WHERE table_name = \"${prefix}$x\";" | tail -1)
                datatotal=$(echo "scale=3;$datatotal + $datasize" | bc)
            indexsize=$(_magdbconnect -e "SELECT index_length/1024000 FROM information_schema.TABLES WHERE table_name = \"${prefix}$x\";" | tail -1)
                indextotal=$(echo "scale=3;$indextotal+$indexsize" | bc)
	    rowcount=$(_magdbconnect -e "SELECT table_rows FROM information_schema.TABLES WHERE table_name = \"${prefix}$x\";" | tail -1)
                rowtotal=$(($rowcount+$rowtotal))
	    printf "$LOGFMT" "$x" "$rowcount" "$datasize" "$indexsize"
        done
        echo $div; printf "$LOGFMT" "Totals" "$rowtotal" "$datatotal" "$indextotal"; echo $div ;;
 -m|--multi) _magdbconnect -e "SELECT * FROM ${prefix}core_config_data WHERE path RLIKE \"base_url\"; SELECT * FROM ${prefix}core_website; SELECT * FROM ${prefix}core_store";;
 -o|--logclean|-O|--optimize)
        if [[ -z $param ]]; then tablename='-h'; else tablename="$param"; fi; runonce=1;
        if [[ $tablename != *-h* ]]; then touch $SITEPATH/maintenance.flag && echo -e "Maintenance Flag set while cleaning tables\n"; fi
        case $tablename in
            all) if [[ $opt == '-o' || $opt == '--logclean' ]];
                then for x in $tables; do echo "Truncating ${prefix}$x"; _magdbconnect -e "TRUNCATE ${prefix}$x;" >> /dev/null; done;
                else for x in $tables; do echo; echo "Truncating/Optimizing ${prefix}$x"; _magdbconnect -e "TRUNCATE ${prefix}$x; OPTIMIZE TABLE ${prefix}$x;" >> /dev/null; done; fi ;;
            -h|--help) echo -e " Usage: magdb $SITEPATH $opt [<option>]\n    <option> can be a table_name, 'list of tables', or 'all'\n\n  Individual Table Names\n $(dash 78)";
                (for x in $tables; do echo "  $x"; done) | column -x;;
            *)  if [[ $opt == '-o' || $opt == '--logclean' ]];
                then for x in $tablename; do echo "Truncating ${prefix}$x"; _magdbconnect -e "TRUNCATE ${prefix}$x;" >> /dev/null; done;
                else for x in $tablename; do echo; echo "Truncating/Optimizing ${prefix}$x"; _magdbconnect -e "TRUNCATE ${prefix}$x; OPTIMIZE TABLE ${prefix}$x;" >> /dev/null; done; fi ;;
        esac
        if [[ -f $SITEPATH/maintenance.flag ]]; then rm $SITEPATH/maintenance.flag && echo -e "\nTable cleaning complete, maintenance.flag removed"; fi ;;
 -p|--parallel) _magdbconnect -e "SELECT * FROM ${prefix}core_config_data WHERE path RLIKE \"base.*url\";";;
 -P|--password) runonce=1;
        if [[ -n $param ]]; then
          username=$(echo $param | awk '{print $1}'); password=$(echo $param | awk '{print $2}');
          _magdbconnect -e "UPDATE ${prefix}admin_user SET password = MD5(\"$password\") WHERE ${prefix}admin_user.username = \"$username\";"
          echo -e "New Magento Login Credentials:\nUsername: $username\nPassword: $password"
        elif [[ -z $param || $param == '-h' || $param == '--help' ]]; then
          echo -e " Usage: magdb [<path>] <-P|--password> <username> <password>"
        fi ;;
 -s|--swap )
        username=$(_magdbconnect -e "SELECT username FROM ${prefix}admin_user WHERE is_active = 1 LIMIT 1;" | tail -1)
        password=$(_magdbconnect -e "SELECT password FROM ${prefix}admin_user WHERE is_active = 1 LIMIT 1;" | tail -1 | sed 's/\$/\\\$/g')
        _magdbconnect -e "UPDATE ${prefix}admin_user SET password=MD5('nexpassword') WHERE is_active = 1 LIMIT 1";
        echo -e "You have 20 seconds to login using the following credentials\n"
        echo -n "LoginURL: "; _magdbconnect -e "SELECT value FROM ${prefix}core_config_data WHERE path LIKE \"web/unsecure/base_url\" LIMIT 1;" | tail -1 | sed "s/\/$/\/$adminurl/"
        echo -e "Username: $username\nPassword: nexpassword\n"
        for x in {1..20}; do sleep 1; printf ". "; done; echo
        _magdbconnect -e "UPDATE ${prefix}admin_user SET password=\"$password\" WHERE is_active = 1 LIMIT 1";
        echo -e "\nPassword has been reverted." ;;
 -u|--user|--users)
    if [[ -z $param ]]; then _magdbconnect -e "select * from ${prefix}admin_user\G" | grep -v 'extra:';
    elif [[ $param =~ -s ]]; then _magdbconnect -e "select username,CONCAT( firstname,\" \",lastname ) AS \"Full Name\",email,password from ${prefix}admin_user";
    elif [[ $param == '-h' || $param == '--help' ]]; then echo -e " Usage: magdb [path] <-u|--user> [-s|--short]"; fi
    ;;
 -x|--index) _magdbconnect -e "SELECT * FROM ${prefix}index_process";;
 -X|--reindex) if [[ -z $param ]]; then index='help' ; else index="$param"; fi
    _magdbinfo; _magdbsum; DIR=$PWD; cd $SITEPATH; sudo -u $(getusr) php -f shell/indexer.php -- $index; cd $DIR;;
 -z|--zend)
    if [[ -z $param ]]; then
        echo "There are $(find /tmp/ -type f -name zend* -user $(getusr) -print | wc -l) Zend cache files for $(getusr) in /tmp/";
    elif [[ $param =~ ^clear$ ]]; then
        echo "Clearing Zend cache files for $(getusr) in /tmp/";
        for x in $(find /tmp/ -type f -name zend* -user $(getusr) -print); do echo -n $x; rm $x && echo "... Removed"; done;
    else
        echo "$param is not a valid parameter for this option."
    fi ;;
 -h|--help|*) _magdbusage;;
esac; echo; dbhost=''; dbuser=''; dbpass=''; dbname=''; prefix='';
version=''; edition=''; adminurl=''; username=''; password='';
}

## Find Wordpress database configuration and run common queries
wpdb(){
echo; runonce=0;
if [[ $1 =~ ^-.*$ ]]; then SITEPATH='.'; opt="$1"; shift; param="$@";
else SITEPATH="$1"; opt="$2"; shift; shift; param="$@"; fi;

if [[ -f $SITEPATH/wp-includes/version.php ]]; then
  version=$(grep "wp_version =" $SITEPATH/wp-includes/version.php | cut -d\' -f2)
  dbversion=$(grep "wp_db_version =" $SITEPATH/wp-includes/version.php | awk '{print $3}' | tr -d \;)
fi

if [[ -f $SITEPATH/wp-config.php ]]; then
  if grep -Eqi "MULTISITE...true" $SITEPATH/wp-config.php; then
    edition='WP Multisite'; else edition='Wordpress'; fi
  prefix=$(grep table_prefix $SITEPATH/wp-config.php | cut -d\' -f2);
fi

# if [[ -f $SITEPATH/wp-config.php ]]; then continue=1; else echo -e "\n ${RED}Could not find Worpdress configuration file!${NORMAL}\n"; return 0; fi

_wpdbinfo(){
dbconnect=($(grep DB_ $SITEPATH/wp-config.php 2> /dev/null | cut -d\' -f4));
dbname=${dbconnect[0]}; dbuser="${dbconnect[1]}"; dbpass="${dbconnect[2]}"; dbhost=${dbconnect[3]};
}

_wpdbusage(){ echo " Usage: wpdb [<path>] <option> [<query>]
    -b | --base ...... Show configured base urls in the database
    -B | --backup .... Backup the Wordpress database as the user
    -c | --clean ..... Remove unapproved comments or old post revisions. ${CYAN}(New)${NORMAL}
    -e | --execute ... Execute a custom query (use '*' and \\\")
    -i | --info ...... Display user credentials for database
    -l | --login ..... Log into database using user credentials
    -m | --multi ..... Display MultiSite information (IDs/domains/paths)
    -P | --password .. Update or reset password for a user ${CYAN}(New)${NORMAL}
    -s | --swap ...... Temporarily swap out user password ${RED}${BRIGHT}(BETA!)${NORMAL}
    -u | --users ..... Show users configured within the database

    -h | --help ....... Display this help information and quit"
    return 0; }

_wpdbsum(){ echo -e "${BRIGHT}$edition: ${RED}$version ($dbversion) ${NORMAL}\n${BRIGHT}Connection: ${RED}$dbuser:$dbname$(if [[ -n $prefix ]]; then echo .$prefix; fi)${NORMAL}\n"; }

_wpdbconnect(){
        _wpdbinfo &&
        if [[ $runonce -eq 0 ]]; then _wpdbsum; runonce=1; fi &&
        mysql -u $dbuser -p$dbpass -h $dbhost $dbname "$@";
        }

_wpdbbackup(){ _wpdbinfo;
        if [[ -x /usr/bin/pigz ]]; then COMPRESS="/usr/bin/pigz"; echo "Compressing with pigz";
                else COMPRESS="/usr/bin/gzip"; echo "Compressing with gzip"; fi
        echo "Using: mysqldump --opt --skip-lock-tables -u'$dbuser' -p'$dbpass' -h $dbhost $dbname";
        if [[ -f /usr/bin/pv ]]; then sudo -u $(getusr) mysqldump --opt --skip-lock-tables -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
                | pv -N 'MySQL-Dump' | $COMPRESS --fast | pv -N 'Compression' > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz;
        else sudo -u $(getusr) mysqldump --opt --skip-lock-tables -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
                | $COMPRESS --fast > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz; fi;
        }

case $opt in
-b | --base ) option_tables=$(_wpdbconnect -e "SHOW TABLE STATUS" | awk '($1 ~ /options/) {print $1}');
        for x in $option_tables; do _wpdbconnect -e "SELECT * FROM $x WHERE option_name = \"siteurl\" OR option_name = \"home\" OR option_name = \"blogname\";"; echo -e "Options Table Name: $x\n"; done ;;
-B | --backup ) _wpdbbackup ;;
-c | --clean ) if [[ $param =~ ^com.* ]]; then _wpdbconnect -e "DELETE FROM ${prefix}comments WHERE comment_approved = '0';"
                elif [[ $param =~ ^rev.* ]]; then _wpdbconnect -e "DELETE FROM ${prefix}posts WHERE post_type = 'revision';"; fi ;;
-e | --execute ) _wpdbconnect -e "${param};" ;;
-i | --info ) _wpdbinfo; echo "Database Connection Info:";
    echo -e "\nLoc.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $dbhost \nRem.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $(hostname)\n";
    echo -e "Username: $dbuser \nPassword: $dbpass \nDatabase: $dbname $(if [[ -n $prefix ]]; then echo \\nPrefix..: $prefix; fi) \nLoc.Host: $dbhost \nRem.Host: $(hostname)" ;;
-l | --login ) _wpdbconnect ;;
-m | --multi ) _wpdbconnect -e "SELECT * FROM ${prefix}blogs;" ;;
-P | --password )
        if [[ -n $param ]]; then user_login=$(echo $param | awk '{print $1}'); user_pass=$(echo $param | awk '{print $2}');
          _wpdbconnect -e "UPDATE ${prefix}users SET user_pass = MD5(\"$user_pass\") WHERE ${prefix}users.user_login = \"$user_login\";"
          echo -e "\nNew WP Login Credentials:\nUsername: $user_login\nPassword: $user_pass\n"
        elif [[ -z $param || $param == '-h' || $param == '--help' ]]; then echo -e "\n Usage: wpdb [<path>] <option> <username> <password>\n"; fi ;;
-u | --users )
    if [[ -z $param ]]; then _wpdbconnect -e "select * from ${prefix}users\G";
    elif [[ $param =~ -s ]]; then _wpdbconnect -e "select id,user_login,display_name,user_email,user_pass from ${prefix}users ORDER BY id";
    elif [[ $param == '-h' || $param == '--help' ]]; then echo -e " Usage: wpdb [path] <-u|--user> [-s|--short]"; fi ;;
-s | --swap )
        user_login=$(_wpdbconnect -e "SELECT user_login FROM ${prefix}users ORDER BY id LIMIT 1;" | tail -1)
        user_pass=$(_wpdbconnect -e "SELECT user_pass FROM ${prefix}users ORDER BY id LIMIT 1;" | tail -1 | sed 's/\$/\\\$/g')
        _wpdbconnect -e "UPDATE ${prefix}users SET user_pass=MD5('nexpassword') WHERE user_login = \"$user_login\"";
        echo -e "You can now login using the following credentials\nOnce you un-pause this script the password will be reset\n"
        echo -n "LoginURL: "; _wpdbconnect -e "SELECT option_value FROM ${prefix}options WHERE option_name LIKE \"siteurl\";" | tail -1 | sed 's/\/$/\/wp-admin/'
        echo -e "Username: $user_login\nPassword: nexpassword\n"
        read -p "Press [Enter] to continue ... " pause;
        _wpdbconnect -e "UPDATE ${prefix}users SET user_pass=\"$user_pass\" WHERE user_login = \"$user_login\"";
        echo -e "\nPassword has been reverted." ;;
-h | --help | * ) _wpdbusage ;;
esac; echo; dbhost=''; dbuser=''; dbpass=''; dbname=''; prefix=''; edition=''; version=''; user_login=''; user_pass='';
}

## Find Joomla information and perform some common tasks
nkjoomla(){
# Set path to Joomla install
echo; runonce=0;
if [[ $1 =~ ^-.*$ ]]; then SITEPATH='.'; opt="$1"; shift; param="$@";
elif [[ -z $@ ]]; then SITEPATH='.'; else SITEPATH="$1"; opt="$2"; shift; shift; param="$@"; fi;

# Set path to configuration.php file
CONFIG="$SITEPATH/configuration.php"

# Check if there is a Joomla install here (sanity check)
if [[ -f "$CONFIG" ]]; then

# Gather DB Connection info
dbtype=$(grep '$dbtype ' $CONFIG | cut -d\' -f2)
dbhost=$(grep '$host ' $CONFIG | cut -d\' -f2)
dbuser=$(grep '$user ' $CONFIG | cut -d\' -f2)
dbpass=$(grep '$password ' $CONFIG | cut -d\' -f2)
dbname=$(grep '$db ' $CONFIG | cut -d\' -f2)
prefix=$(grep '$dbprefix ' $CONFIG | cut -d\' -f2)

# Check location of version file
if [[ -f "$SITEPATH/libraries/cms/version/version.php" ]]; then VERFILE="$SITEPATH/libraries/cms/version/version.php"; else VERFILE="$SITEPATH/libraries/joomla/version.php"; fi

# Gather version information
RELEASE="$(grep '$RELEASE' $VERFILE | cut -d\' -f2)";
DEV_LEVEL="$(grep '$DEV_LEVEL' $VERFILE | cut -d\' -f2)";
DEV_STATUS="$(grep '$DEV_STATUS' $VERFILE | cut -d\' -f2)";
BUILD="$(grep '$BUILD' $VERFILE | cut -d\' -f2)";
RELDATE="$(grep '$RELDATE' $VERFILE | cut -d\' -f2)";
CODENAME="$(grep '$CODENAME' $VERFILE | cut -d\' -f2)";
VERSION="$RELEASE.$DEV_LEVEL $DEV_STATUS ($RELDATE) $BUILD";

_joomlausage(){
echo " Usage: nkjoomla [path] OPTION [query]
    -B | --backup .... Backup the Joomla database as the user
    -c | --clear ..... Clear Joomla cache
    -C | --cache ..... Enable/Disable cache
    -e | --execute ... Execute a custom query (use '*' and \\\")
    -g | --gzip ...... Enable/Disable gzip compression
    -i | --info ...... Display user credentials for database
    -l | --login ..... Log into database using user credentials
    -P | --password .. Update or reset password for a user
    -s | --swap ...... Temporarily swap out user password
    -u | --users ..... Show users configured within the database

    -h | --help ....... Display this help and quit
    If run with no options, returns summary information"
    return 0; }

_joomlainfo(){
# Output collected information
FORMAT="%-18s: %s\n"
printf "$FORMAT" "Base Path" "$(cd $SITEPATH; pwd -P)"
printf "$FORMAT" "Product Name" "$(grep '$PRODUCT' $VERFILE | cut -d\' -f2) \"$CODENAME\""
printf "$FORMAT" "Site Title" "$(grep '$sitename ' $CONFIG | cut -d\' -f2)"
printf "$FORMAT" "Install Date" "$(stat $VERFILE | awk '/Change/ {print $2,$3}' | cut -d. -f1)"
printf "$FORMAT" "Encryption Key" "$(grep '$secret' $CONFIG | cut -d\' -f2)"
printf "$FORMAT" "Version (Date)" "$VERSION"
printf "$FORMAT" "Front End URL" "http://$(cd $SITEPATH; pwd -P | sed 's:^/chroot::' | cut -d/ -f4- | sed 's:/html::')/"
printf "$FORMAT" "Back End URL" "http://$(cd $SITEPATH; pwd -P | sed 's:^/chroot::' | cut -d/ -f4- | sed 's:/html::')/administrator"
printf "$FORMAT" "Return-Path Email" "$(grep '$mailfrom' $CONFIG | cut -d\' -f2)"
printf "$FORMAT" "Gzip Compression" "$(grep '$gzip' $CONFIG | cut -d\' -f2 | sed 's/0/Disabled/;s/1/Enabled/')"
printf "$FORMAT" "DB Connection" "$dbtype://$dbuser:$dbpass@$dbhost/$dbname$(if [[ -n $prefix ]]; then echo .$prefix*; fi)"
printf "$FORMAT" "Session Method" "$(grep '$session' $CONFIG | cut -d\' -f2)"
printf "$FORMAT" "Cache Method" "$(grep '$cache_' $CONFIG | cut -d\' -f2) / $(grep '$caching' $CONFIG | cut -d\' -f2 | sed 's/0/Disabled/;s/1/Enabled/')"

## Show installed: components, modules, plugins, and templates
# Component Module Plugin Template
  for x in Plugin; do printf "%-18s: " "Active ${x}s"; mysql -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
    -e "select name,type from ${prefix}extensions where type like \"$x\" and enabled = 1;"\
    | egrep -v 'name.*type|^plg' | sed 's/ /_/g' | sort | uniq | awk '{printf "%s, ",$1}' | sed 's/, $//';
  echo; done; }

_joomlasum(){ echo -e "${BRIGHT}Joomla! \"$CODENAME\": ${RED}$VERSION ${NORMAL}\n${BRIGHT}Connection: ${RED}$dbuser:$dbname$(if [[ -n $prefix ]]; then echo .$prefix; fi)${NORMAL}\n"; }

_joomlaconnect(){
  if [[ $runonce -eq 0 ]]; then _joomlasum; runonce=1; fi &&
  mysql -u $dbuser -p$dbpass -h $dbhost $dbname -e "$@";
  }

_joomlabackup(){ _joomlasum;
  if [[ -x /usr/bin/pigz ]]; then COMPRESS="/usr/bin/pigz"; echo "Compressing with pigz"; else COMPRESS="/usr/bin/gzip"; echo "Compressing with gzip"; fi
  echo "Using: mysqldump --opt --skip-lock-tables -u'$dbuser' -p'$dbpass' -h $dbhost $dbname";
    if [[ -f /usr/bin/pv ]]; then mysqldump --opt --skip-lock-tables -u"$dbuser" -p"dbpass" -h $dbhost $dbname \
      | pv -N 'MySQL-Dump' | $COMPRESS --fast | pv -N 'Compression' > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz;
    else mysqldump --opt --skip-lock-tables -u"$dbuser" -p"$dbpass" -h $dbhost $dbname \
      | $COMPRESS --fast > ${dbname}-$(date +%Y.%m.%d-%H.%M).sql.gz; fi;
  }

case $opt in
 -B|--backup) _joomlabackup ;;
 -c|--clear) cd $SITEPATH/cache/ && for x in */; do echo "Clearing $x Cache" | sed 's:/::'; find $x -type f -exec rm {} \;; done; cd - &> /dev/null ;;
 -C|--cache)
    if [[ $(grep "caching = '0'" $CONFIG 2> /dev/null) ]]; then sed -i "s/caching = '0'/caching = '1'/" $CONFIG; echo "Caching is ${BRIGHT}${GREEN}Enabled${NORMAL}";\
    else sed -i "s/caching = '1'/caching = '0'/" $CONFIG; echo "Caching is ${BRIGHT}${GREEN}Disabled${NORMAL}"; fi ;;
 -e|--execute) _joomlaconnect "${param};";;
 -g|--gzip)
    if [[ $(grep "gzip = '0'" $CONFIG 2> /dev/null) ]]; then sed -i "s/gzip = '0'/gzip = '1'/" $CONFIG; echo "Gzip is ${BRIGHT}${GREEN}Enabled${NORMAL}";\
    else sed -i "s/gzip = '1'/gzip = '0'/g" $CONFIG; echo "Gzip is ${BRIGHT}${GREEN}Disabled${NORMAL}"; fi ;;
 -i|--info) echo "Database Connection Info:";
    echo -e "\nLoc.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $dbhost \nRem.Conn: mysql -u'$dbuser' -p'$dbpass' $dbname -h $(hostname)\n";
    echo -e "Username: $dbuser \nPassword: $dbpass \nDatabase: $dbname $(if [[ -n $prefix ]]; then echo \\nPrefix..: $prefix; fi) \nLoc.Host: $dbhost \nRem.Host: $(hostname)" ;;
 -l|--login) mysql -u $dbuser -p$dbpass -h $dbhost $dbname ;;
 -P|--password)
    if [[ -n $param ]]; then
      username=$(echo $param | awk '{print $1}'); password=$(echo $param | awk '{print $2}'); salt=$(echo $param | awk '{print $3}');
      _joomlaconnect "UPDATE ${prefix}users SET password = MD5(\"${password}\") WHERE ${prefix}users.username = \"$username\";"
      echo -e "New Joomla Login Credentials:\nUsername: $username\nPassword: $password"
    elif [[ -z $param || $param == '-h' || $param == '--help' ]]; then
      echo -e " Usage: nkjoomla [path] <-P|--password> <username> <password>"
    fi
    ;;
 -s|--swap)
    username=$(_joomlaconnect "SELECT username FROM ${prefix}users ORDER BY id LIMIT 1;" | tail -1)
    password=$(_joomlaconnect "SELECT password FROM ${prefix}users ORDER BY id LIMIT 1;" | tail -1 | sed 's/\$/\\\$/g')
    _joomlaconnect "UPDATE ${prefix}users SET password=MD5('nexpassword') ORDER BY id LIMIT 1";
    echo -e "You have 20 seconds to login using the following credentials\n"
    echo -e "LoginURL: http://$(cd $SITEPATH; pwd -P | sed "s:^/chroot::" | cut -d/ -f4- | sed 's:html/::')/administrator"
    echo -e "Username: $username\nPassword: nexpassword\n"
    for x in {1..20}; do sleep 1; printf ". "; done; echo
    _joomlaconnect "UPDATE ${prefix}users SET password=\"$password\" ORDER BY id LIMIT 1";
    echo -e "\nPassword has been reverted."
    ;;
 -u|--user)
    if [[ -z $param ]]; then _joomlaconnect "select * from ${prefix}users\G";
    elif [[ $param =~ -s ]]; then _joomlaconnect "select id,username,name,email,password from ${prefix}users ORDER BY id";
    elif [[ $param == '-h' || $param == '--help' ]]; then echo -e " Usage: nkjoomla [path] <-u|--user> [-s|--short]"; fi
    ;;
 -h|--help) _joomlausage ;;
  * ) _joomlainfo ;;
esac; echo

else echo -e "Could not find Joomla install at $SITEPATH\n"; fi
}

## Find basic Drupal information and display it in the nexkit-style
nkdrupal(){
if [[ -n $1 ]]; then sitepath="$1"; else sitepath='.'; fi
config="${sitepath}/sites/default/settings.php"

if [[ -f ${config} ]]; then

# Version Information
if [[ -n $(grep "define('VERSION'" ${sitepath}/modules/system/system.module) ]]; then
  verfile="${sitepath}/modules/system/system.module"
elif [[ -n $(grep "define('VERSION'" ${sitepath}/includes/bootstrap.inc) ]]; then
  verfile="${sitepath}/includes/bootstrap.inc"
fi;
version=$(grep "define('VERSION'" $verfile | cut -d\' -f4)
installdate=$(stat $verfile | awk '/Change/ {print $2,$3}' | cut -d. -f1)

# Database Config (7.x)
# Database, Username, Password, Host, Driver, Prefix
if [[ $version =~ ^7 || $version =~ ^8 ]]; then
dbname=$(awk '($1 ~ /database/ && $3 !~ /array/) {print $3}' $config | cut -d\' -f2)
dbuser=$(awk '($1 ~ /username/) {print $3}' $config | cut -d\' -f2)
dbpass=$(awk '($1 ~ /password/) {print $3}' $config | cut -d\' -f2)
dbhost=$(awk '($1 ~ /host/) {print $3}' $config | cut -d\' -f2)
dbdriv=$(awk '($1 ~ /driver/) {print $3}' $config | cut -d\' -f2)
prefix=$(awk '($1 ~ /prefix/) {print $3}' $config | cut -d\' -f2)

# Database Config (6.x)
# mysql://username:password@localhost/database
elif [[ $version =~ ^6 || $version =~ ^5 ]]; then
dbase=$(awk '($1 ~ /db_url/) {print $3}' $config | cut -d\' -f2)
dbname=$(echo $dbase | cut -d@ -f2 | cut -d/ -f2)
dbuser=$(echo $dbase | cut -d: -f2 | cut -d/ -f3)
dbpass=$(echo $dbase | cut -d: -f3 | cut -d@ -f1)
dbhost=$(echo $dbase | cut -d@ -f2 | cut -d/ -f1)
dbdriv=$(echo $dbase | cut -d: -f1)
prefix=$(awk '($1 ~ /db_prefix/) {print $3}' $config | cut -d\' -f2)

fi
database="${dbdriv}://${dbuser}:${dbpass}@${dbhost}/${dbname}$(if [[ -n ${prefix} ]]; then echo .${prefix}*; fi)"

base_path=$(cd $sitepath; pwd -P;)
base_url=$(cd $sitepath; pwd -P | sed 's:/chroot::g;s:/html::g' | cut -d/ -f4-)
sitename=$(mysql -u $dbuser -p"$dbpass" $dbname -h $dbhost -e "select name,value from ${prefix}variable where name=\"site_name\";" | tail -1 | cut -d\" -f2)
posts=$(mysql -u $dbuser -p"$dbpass" $dbname -h $dbhost -e "select count(*) from ${prefix}node;" | tail -1)

echo
FMT="%-18s: %s\n"
printf "$FMT" "Base Path" "${base_path}"
printf "$FMT" "Site Title" "${sitename}"
printf "$FMT" "Install Date" "${installdate}"
printf "$FMT" "Version" "${version}"
printf "$FMT" "Front End URL" "http://${base_url}"
printf "$FMT" "Back End URL" "http://${base_url}/admin"
printf "$FMT" "Post Count" "${posts}"
printf "$FMT" "DB Connection" "${database}"
echo
unset verfile version config base_url posts database dbname dbpass dbuser base_path installdate dbhost dbdriv prefix

else echo -e "\nCould not find Drupal install at ${sitepath}\n"; fi
}

## Check the Usual Suspects when things aren't working right
usual_suspects(){
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
if [[ -f /etc/init.d/lsws ]]; then printf "$FORMAT" " LiteSpeed" " $(pid_start lite)" " LiteSpeed (pid $(echo $(pgrep lite))) is running ...";
elif [[ -f /etc/init.d/nginx ]]; then printf "$FORMAT" " Nginx" " $(pid_start nginx)" " $(service nginx status)";
else printf "$FORMAT" " Apache" " $(pid_start httpd)" " $(service httpd status)"; fi;

if [[ -f /etc/init.d/php-fpm ]]; then printf "$FORMAT" " PHP-FPM" " $(pid_start php-fpm)" " $(service php-fpm status)"; fi;

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
    echo -e "\nRecent processor load"; dash 80; echo;
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
if [[ $@ =~ -v ]]; then checkquota -l; fi;
echo;
}

## Find configuration file, and echo configured DB name
finddb(){
if [[ -z "$1" ]]; then SITEPATH="."; else SITEPATH="$1"; fi;
    if [[ -f $SITEPATH/app/etc/local.xml ]]; then	# If site is Mage
        echo $(grep dbname $SITEPATH/app/etc/local.xml | cut -d\[ -f3 | cut -d\] -f1)
    elif [[ -f $SITEPATH/wp-config.php ]]; then		# If site is WP
        echo $(grep DB_NAME $SITEPATH/wp-config.php | cut -d\' -f4)
    elif [[ -f $SITEPATH/configuration.php ]]; then	# If site is Joomla
        echo $(grep '$db ' $SITEPATH/configuration.php | cut -d\' -f2)
    elif [[ -f $SITEPATH/sugar_version.php ]]; then	# If site is SurgarCRM
        echo $(grep db_name $SITEPATH/config.php | cut -d\' -f4)
    elif [[ -f $SITEPATH/includes/config.php ]]; then	# If site is vBulletin 4.x
        echo $(grep dbname $SITEPATH/includes/config.php | cut -d\' -f6)
    elif [[ -f $SITEPATH/upload/core/includes/config.php ]]; then	# If site is vBulletin 5.x
        echo $(grep dbname $SITEPATH/upload/core/includes/config.php | cut -d\' -f6)
    elif [[ "$1" == "EE" || "$1" == "ee" ]]; then	# If site is EE or another CodeIgniter app
        if [[ -z "$2" ]]; then SITEPATH="/home/$(getusr)"; else SITEPATH="$2"; fi
        CONFIG=$(find $SITEPATH -type f -name database.php -print)
        echo $(grep \'database\' $CONFIG | cut -d\' -f6)
    else # If there is no config to be found ...
	echo "${RED}Could not find configuration file!${NORMAL}"; fi
# Done .. that was a lot of work!
}

## Look up what domain is covered by the SSL loading at the requested domain
findssl(){
if [[ $2 == '-p' ]]; then P=$3; else P=443; fi
if [[ $@ =~ -v ]]; then type="subject issuer"; else type="subject"; fi

D=$(echo $1 | sed 's/\///g')
echo; echo "$D:$P"; dash 80; echo;

if [[ $(cat /etc/redhat-release) =~ 6\.[0-9] ]]; then SNI="-servername $D"; fi;

for x in $type; do
    echo | openssl s_client -nbio -connect $D:$P $SNI 2> /dev/null\
     | grep $x | sed 's/ /_/g;s/\/\([A-Ze]\)/\n\1/g;s/=/: /g' | grep ^[A-Ze] | column -t | sed 's/_/ /g';
    echo;
done

echo "SSL Return Code"; dash 80; echo
rcode=$(echo | openssl s_client -nbio -connect $D:$P $SNI 2>/dev/null | grep Verify.*)
echo $rcode
if [[ $(echo $rcode | awk '{print $4}') =~ [0-9]{2} ]]; then
  curl -s https://www.openssl.org/docs/apps/verify.html | grep -A4 "$(echo $rcode | awk '{print $4}') X509" | grep -v X509 | sed 's/<[^>]*>//g' | tr '\n' ' '; echo;
fi;
echo -e "\nhttps://www.sslshopper.com/ssl-checker.html#hostname=${D}\nhttps://certlogik.com/ssl-checker/${D}:${P}/\n"
}

## Use CSR or CRT, generate a new key and CSR (SHA-256).
sslrekey(){
if [[ -z $1 ]]; then read -p "Domain Name: " domain; else domain="$(echo $1 | sed 's:/::g')"; fi
csrfile="/home/*/var/${domain}/ssl/${domain}.csr"
crtfile="/home/*/var/${domain}/ssl/${domain}.crt"
if [[ -f $(echo $csrfile) ]]; then
  subject="$(openssl req -in $csrfile -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')"
  openssl req -nodes -sha256 -newkey rsa:2048 -keyout new.$domain.priv.key -out new.$domain.csr -subj "$subject" && cat new.${domain}.*
elif [[ -f $(echo $crtfile) ]]; then
  subject="$(openssl x509 -in $crtfile -subject -noout | sed 's/^subject= //' | sed -n l0 | sed 's/$$//')"
  openssl req -nodes -sha256 -newkey rsa:2048 -keyout new.$domain.priv.key -out new.$domain.csr -subj "$subject" && cat new.${domain}.*
else
  echo -e "\nNo CSR/CRT to souce from!\n"
fi
}

## Use CSR or CRT, and KEY, generate new CSR (SHA-256)
sslrehash(){
if [[ -z $1 ]]; then read -p "Domain Name: " domain; else domain="$(echo $1 | sed 's:/::g')"; fi
keyfile="/home/*/var/${domain}/ssl/${domain}.priv.key"
csrfile="/home/*/var/${domain}/ssl/${domain}.csr"
crtfile="/home/*/var/${domain}/ssl/${domain}.crt"

if [[ -f $(echo $csrfile) && -f $(echo $keyfile) ]]; then
  subject="$(openssl req -in $csrfile -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')"
  openssl req -nodes -sha256 -new -key $keyfile -out $domain.sha256.csr -subj "${subject}" && cat $domain.sha256.csr
elif [[ -f $(echo $crtfile) && -f $(echo $keyfile) ]]; then
  subject="$(openssl x509 -in $crtfile -subject -noout | sed 's/^subject= //' | sed -n l0 | sed 's/$$//')"
  openssl req -nodes -sha256 -new -key $keyfile -out $domain.sha256.csr -subj "${subject}" && cat $domain.sha256.csr
else
  echo -e "\nNo CSR/CRT or KEY to souce from!\n"
fi
}

## Generate DCV file from the hash of the CSR for a Domain
dcvfile(){
if [[ -z $1 ]]; then read -p "Domain: " domain;
elif [[ $1 == '.' ]]; then domain=$(pwd -P | sed 's:/chroot::' | cut -d/ -f4);
else domain=$1; fi
csrfile="/home/*/var/${domain}/ssl/${domain}.csr"
if [[ -f $(echo $csrfile) ]]; then
  md5=$(openssl req -in $csrfile -outform DER | openssl dgst -md5 | awk '{print $2}' | sed 's/\(.*\)/\U\1/g');
  sha1=$(openssl req -in $csrfile -outform DER | openssl dgst -sha1 | awk '{print $2}' | sed 's/\(.*\)/\U\1/g');
  echo -e "${sha1}\ncomodoca.com" > ${md5}.txt; chown $(getusr). ${md5}.txt
else echo "Could not find csr for ${domain}!"; fi
}

## Swap new SSL into place of old SSL and reload Apache
sslswap(){
domain=$(pwd -P | sed 's:/chroot::' | cut -d/ -f5)
nano ${domain}.new.crt ${domain}.new.chain.crt;

keyhash=$(openssl rsa -noout -modulus -in ${domain}.priv.key | openssl md5 | awk '{print $2}')
crthash=$(openssl x509 -noout -modulus -in ${domain}.new.crt | openssl md5 | awk '{print $2}')

if [[ $keyhash != $crthash ]]; then
  rm ${domain}.new.crt ${domain}.new.chain.crt
  echo -e "\n[${BRIGHT}${RED}FAILED${NORMAL}] .. SSL does not match Priv.Key!\n\nPriv.Key .. [${YELLOW}${keyhash}${NORMAL}]\nSSL.Cert .. [${YELLOW}${crthash}${NORMAL}]\n";

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
  echo -e "\nhttps://www.sslshopper.com/ssl-checker.html#hostname=${domain}\nhttps://certlogik.com/ssl-checker/${domain}:443/\n"
fi
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
find /home/tmp -type f -size +100000k -group $(getusr) -exec ls -lah {} \;
find /tmp -type f -size +100000k -group $(getusr) -exec ls -lah {} \;
find /home/nex* -type f -group $(getusr) -exec ls -lah {} \;
}

## Give a breakdown of user's large disk objects
diskhogs(){
if [[ $@ =~ "-h" ]]; then echo -e "\n Usage: diskhogs [maxdepth] [-d]\n"; return 0; fi;
if [[ $@ =~ [0-9]{1,} ]]; then DEPTH=$(echo $@ | grep -Eo '[0-9]{1,}'); else DEPTH=3; fi;
echo -e "\n---------- Large Directories $(dash 51)"; du -h --max-depth $DEPTH | grep -E '[0-9]G|[0-9]{3}M';
if [[ ! $@ =~ '-d' ]]; then echo -e "\n---------- Large Files $(dash 57)"; find . -type f -size +100000k -group $(getusr) -exec ls -lah {} \;; fi;
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

complete -W '-d -e -f -h --list -m -n -p -r -s -x' iworxcredz
## List Users, or Reset passwords for FTP/Siteworx/Reseller/Nodeworx
iworxcredz(){

# Generate a password using the xkcd function
genPass(){
  if [[ $1 == '-m' ]]; then newPass=$(mkpasswd -l 15);
  elif [[ $1 == '-x' ]]; then newPass=$(xkcd);
  elif [[ $1 == '-p' ]]; then newPass="$2";
  else newPass=$(xkcd); fi
  }

if [[ $1 == '-d' ]]; then primaryDomain=$2; shift; shift;
else primaryDomain=$(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}'); fi

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
if [[ -z $2 || $2 == '--list' ]]; then
  echo; (echo "ShortName FullName"; sudo -u $(getusr) siteworx -unc Ftp -a list) | column -t; echo
elif [[ $2 == '.' ]]; then
  ftpUser='ftp'; genPass $3 $4
  sudo -u $(getusr) siteworx -u --login_domain $primaryDomain -n -c Ftp -a edit --password $newPass --confirm_password $newPass --user $ftpUser
  echo -e "\nFor Testing: \nlftp -e'ls;quit' -u ${ftpUser}@${primaryDomain},'$newPass' $(serverName)"
  echo -e "\nHostname: $(serverName)\nUsername: ${ftpUser}@${primaryDomain}\nPassword: $newPass\n"
else
  ftpUser=$2; genPass $3 $4;
  sudo -u $(getusr) siteworx -u --login_domain $primaryDomain -n -c Ftp -a edit --password $newPass --confirm_password $newPass --user $ftpUser
  echo -e "\nFor Testing: \nlftp -e'ls;quit' -u ${ftpUser}@${primaryDomain},'$newPass' $(serverName)"
  echo -e "\nHostname: $(serverName)\nUsername: ${ftpUser}@${primaryDomain}\nPassword: $newPass\n"
fi
;;

-s ) # Listing/Updating Siteworx Users
if [[ -z $2 || $2 = '--list' ]]; then
  echo; (echo "EmailAddress Name Status"; sudo -u $(getusr) siteworx -unc Users -a listUsers | sed 's/ /_/g' | awk '{print $2,$3,$5}') | column -t; echo
elif [[ $2 == '.' ]]; then # Lookup primary domain and primary email address
  primaryEmail=$(nodeworx -unc Siteworx -a querySiteworxAccounts --domain $primaryDomain --account_data email)
  genPass $3 $4
  nodeworx -unc Siteworx -a edit --password "$newPass" --confirm_password "$newPass" --domain $primaryDomain
  echo -e "\nLoginURL: https://$(serverName):2443/siteworx/?domain=$primaryDomain\nUsername: $primaryEmail\nPassword: $newPass\nDomain: $primaryDomain\n"
else # Update Password for specific user
  emailAddress=$2; genPass $3 $4
  sudo -u $(getusr) siteworx -unc Users -a edit --user $emailAddress --password $newPass --confirm_password $newPass
  echo -e "\nFor Testing:\nsiteworx --login_email $emailAddress --login_password $newPass --login_domain $primaryDomain"
  echo -e "\nLoginURL: https://$(serverName):2443/siteworx/?domain=$primaryDomain\nUsername: $emailAddress\nPassword: $newPass\nDomain: $primaryDomain\n"
fi
;;

-r ) # Listing/Updating Reseller Users
if [[ -z $2 || $2 == '--list' ]]; then # List out Resellers nicely
  echo; (echo "ID Reseller_Email Name"; nodeworx -unc Reseller -a listResellers | sed 's/ /_/g' | awk '{print $1,$2,$3}') | column -t; echo
else # Update Password for specific Reseller
  resellerID=$2; genPass $3 $4
  nodeworx -unc Reseller -a edit --reseller_id $resellerID --password $newPass --confirm_password $newPass
  emailAddress=$(nodeworx -unc Reseller -a listResellers | grep ^$resellerID | awk '{print $2}')
  echo -e "\nFor Testing:\nnodeworx --login_email $emailAddress --login_password $newPass"
  echo -e "\nLoginURL: https://$(serverName):2443/nodeworx/\nUsername: $emailAddress\nPassword: $newPass\n\n"
fi
;;

-m ) # Listing/Updating MySQL Users
if [[ -z $2 || $2 == '--list' ]]; then
  echo; ( echo -e "Username   Databases"
  sudo -u $(getusr) siteworx -unc Mysqluser -a listMysqlUsers | awk '{print $2,$3}' ) | column -t; echo
else
  genPass $3 $4
  dbs=$(sudo -u $(getusr) siteworx -unc Mysqluser -a listMysqlUsers | grep "$2" | awk '{print $3}' | sed 's/,/, /')
  sudo -u $(getusr) siteworx -unc MysqlUser -a edit --name $(echo $2 | sed "s/$(getusr)_//") --password $newPass --confirm_password $newPass
  echo -e "\nFor Testing: \nmysql -u'$2' -p'$newPass' $(echo $dbs | cut -d, -f1)"
  echo -e "\nUsername: $2\nPassword: $newPass\nDatabases: $dbs\n"
fi
;;

-n ) # Listing/Updating Nodeworx Users
if [[ -z $2 || $2 == '--list' ]]; then # List Nodeworx (non-Nexcess) users
  echo; (echo "Email_Address Name"; nodeworx -unc Users -a list | grep -v nexcess.net | sed 's/ /_/g') | column -t; echo
elif [[ ! $2 =~ nexcess\.net$ ]]; then # Update Password for specific Nodeworx user
  emailAddress=$2; genPass $3 $4
  nodeworx -unc Users -a edit --user $emailAddress --password $newPass --confirm_password $newPass
  echo -e "\nFor Testing:\nnodeworx --login_email $emailAddress --login_password $newPass"
  echo -e "\nLoginURL: https://$(serverName):2443/nodeworx/\nUsername: $emailAddress\nPassword: $newPass\n\n"
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
unset primaryDomain primaryEmail emailAddress resellerID newPass # Cleanup
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

## Setup SSH for me, so I can transfer files from HOST
givemessh(){
echo; PASS=$(xkcd) && nksshd userControl -Csr $SUDO_USER -p $PASS
if [[ -z "$1" ]]; then echo; read -p "Hostname: " HOST; else HOST="$1"; fi
whitelist ssh $(dig +short $HOST) "# $HOST for file transfer"
}

## Bash completion for Whitelist
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
echo -e "\nHello,\n\nI have white-listed the requested IP address(es) ( $(for x in $HOST; do printf "$x, "; done)) for $TYPE access on $(hostname).\nYou should be all set. Please let us know if you need any further assistance.\n\nSincerely,\n"
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

## Shortcut for piping math equation(s) into bc
calc(){
if [[ -z "$@" ]]; then echo -e "\nThis function requires a parameter.\n"; else
echo; for x in "$@"; do printf "$x = "; echo "scale=5;$x" | bc; done; echo; fi
}

## Send a file to an email address
sendthis(){
if [[ $@ == '-h' || $@ == '--help' || -z $@ ]]; then echo -e "\n Usage: sendthis <filename> <subject> <emailaddr>\n"; return 0; fi
if [[ -n $1 ]]; then FILE=$1; else read -p "Filename: " FILE; fi
if [[ -n $2 ]]; then SUBJECT=$2; else read -p "Subject: " SUBJECT; fi
if [[ -n $3 ]]; then EMAIL=$3; else read -p "Email: " EMAIL; fi
if grep -Fqi 'CentOS release 6' /etc/redhat-release; then echo "See Attached" | mail -s "$SUBJECT" -a "$FILE" "$EMAIL";
else cat "$FILE" | mail -s "$SUBJECT" "$EMAIL"; fi;
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
	   echo -e "\n---------- FTP LOGS ----------\n$(tail -n$N /var/log/proftpd/auth.log /var/log/proftpd/xfer.log)" ;;
    -h|--help) echo -e "\n Usage: logs [ftp|php|sql|http|ssh|cron|all] [linecount]\n" ;;
    * ) echo -e "\n---------- APACHE LOG ----------\n$(tail -n$N /var/log/httpd/error_log)\n"
        if [[ -f /var/log/php-fpm/error.log ]]; then echo -e "\n---------- PHP LOG ----------\n$(tail -n$N /var/log/php-fpm/error.log)\n"; fi
        echo -e "\n---------- MYSQL LOG ----------\n$(tail -n$N /var/log/mysqld.log)\n" ;;
esac
}

## List the last 10 reboots
findreboot(){ last | awk '/boot/ {$4=""; print}' | head -n10 | column -t; }

## Simple System Status to check if services that should be running are running
srvstatus(){
echo; FORMAT="%-18s %s\n";
printf "$FORMAT" " Service" " Status";
printf "$FORMAT" "$(dash 18)" "$(dash 55)";
for x in $(chkconfig --list | awk '/3:on/ {print $1}' | sort); do
  printf "$FORMAT" " $x" " $(service $x status 2> /dev/null | head -1)";
done; echo
}

## Show geographical and network information about a given IP address
ipinfo(){
for x in "$@"; do echo; echo -e "GEO-IP INFO: ($x)\n$(dash 79)";
  curl -s ipinfo.io/$x | sed 's/,\"/\n\"/g' | awk -F\" '/[a-z]/ {printf "%8s : %s\n",$2,$4}';
done; echo
}

## Watch connections to server, and the IPs those connections are coming from
liveips(){
if [[ -n $(grep ' 4\.' /etc/redhat-release) ]]; then # CentOS 4
  if [[ $1 =~ -q ]]; then # Established Connections
    watch -n0.1 "netstat -ant | awk -F: '/ffff.*:80.*EST/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn"
  else # Verbose (EST and WAIT Connections)
    watch -n0.1 "netstat -ant | awk -F: '/ffff.*:80/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn"
  fi
else # Not CentOS 4
  if [[ -n "$(ss -ant | grep ffff.*:80)" ]]; then # Pseudo IPv6
    if [[ $1 =~ -q ]]; then # Established Connections
      watch -n0.1 "ss -ant | awk -F: '/EST.*ffff.*:80/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn"
    else # Verbose (EST and WAIT Connections)
      watch -n0.1 "ss -ant | awk -F: '/ffff.*:80/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn"
    fi
  else # IPv4
    if [[ $1 =~ -q ]]; then # Established Connections
      watch -n0.1 "ss -ant | awk '/EST/ && (\$4 ~ /:80/) && !/\*/ {print \$4,\"<--\",\$5}' | sed 's/:80//g; s/:.*$//g' | column -t | sort | uniq -c | sort -rn"
    else # Verbose (EST and WAIT Connections)
      watch -n0.1 "ss -ant | awk '(\$4 ~ /:80/) && !/\*/ {print \$4,\"<--\",\$5}' | sed 's/:80//g; s/:.*$//g' | column -t | sort | uniq -c | sort -rn"
    fi
  fi
fi
}

## Find ModSec error codes in an Apache error.log for a domain
modsec(){
if [[ "$1" == '-h' || "$1" == '--help' ]]; then
  echo -e "\n Usage: modsec <DOMAIN> [-i|--ip <IPADDR>]\n If <DOMAIN> is . attempt to get domain from path\n <IPADDR> can be a full IP address, regex, 'otr', or 'mel'\n"; return 0; fi;

echo;
if [[ -z "$1" ]]; then read -p "Domain: " D; echo;
  elif [[ $1 == '.' ]]; then D="$(pwd | sed 's:^/chroot::' | cut -d/ -f4)"; else D="$(echo $1 | sed 's/\///g')"; fi
if [[ "$2" == '-i' && -z "$3" || "$2" == '--ip' && -z "$3" ]]; then read -p "IPaddress: " IP; echo;
  elif [[ "$3" == 'otr' ]]; then IP='208.69.120.120'; elif [[ "$3" == 'mel' ]]; then IP="192.240.191.2"; else IP="$3"; fi

FORMAT="%-8s %-9s %s\n";
printf "$FORMAT" " Count#" " Error#" " IP-Address";
printf "$FORMAT" "--------" "---------" "$(dash 17)";
if grep -qEi '\[id: [0-9]{6,}\]' /home/*/var/$D/logs/error.log; then
   grep -Eio "client.$IP.*\] |id.*[0-9]{6,}\]" /home/*/var/$D/logs/error.log | awk 'BEGIN {RS="]\nc"} {print $4,$2}'\
     | tr -d \] | sort | uniq -c | awk '{printf "%7s   %-8s  %s\n",$1,$2,$3}'
else
   grep -Eio "client.$IP.*id..[0-9]{6,}\"" /home/*/var/$D/logs/error.log | awk '{print $NF,$2}'\
     | sort | uniq -c | tr -d \" | tr -d \] | awk '{printf "%7s   %-8s  %s\n",$1,$2,$3}';
fi; echo
}

## Show requests to all sites on server for the last hour in the transfer logs
hits_lasthour(){
if [[ -z $1 ]]; then top=10; else top=$1; fi
echo;
printf "%-30s %-10s\n" " Domain Name" " Hits";
printf "%-30s %-10s\n" "$(dash 30)" "$(dash 10)";
for x in /home/*/var/*/logs/transfer.log; do
    printf "%-30s %-10s\n" " $(echo $x | cut -d/ -f5)" " $(grep -Ec "$(date +%d/%b/%Y:%H:)" $x)";
done | sort -rn -k2 | head -n$top
echo
}

## Change DocRoot to disabled, enabled, or check current DocRoot
haxed(){
if [[ -z $2 || $1 == '.' ]]; then D="$(pwd | sed 's:^/chroot::' | cut -d/ -f4)"; else D=$(echo $1 | sed 's/\///g'); fi
if [[ -z $2 ]]; then opt=$1; else opt=$2; fi

case $opt in
-c|--check  )
        if [[ -f /etc/httpd/conf.d/vhost_${D}.conf ]]; then
            if grep -Eq 'DocumentRoot.*disabled$' /etc/httpd/conf.d/vhost_${D}.conf > /dev/null; then echo -e "\n$D is Disabled\n";
            elif grep -Eq 'DocumentRoot.*html$' /etc/httpd/conf.d/vhost_${D}.conf > /dev/null; then echo -e "\n$D is Enabled\n"; fi
        else echo -e "\n/etc/httpd/conf.d/vhost_${D}.conf does not appear to exist on this server.\n"; fi ;;
-d|--disable)
        sed -i 's/\(DocumentRoot.*html$\)/DocumentRoot \/home\/interworx\/var\/errors\/disabled\n  \#\1/g' /etc/httpd/conf.d/vhost_${D}.conf &&\
        httpd -t && service httpd reload && echo -e "\nDocumentRoot changed to Disabled\n" ;;
-e|--enable )
        sed -i 's/DocumentRoot.*disabled$//g' /etc/httpd/conf.d/vhost_${D}.conf &&\
        sed -i 's/\#\(DocumentRoot.*html$\)/\1/g' /etc/httpd/conf.d/vhost_${D}.conf &&\
        httpd -t && service httpd reload && echo -e "\nDocumentRoot changed to Enabled\n" ;;
-h|--help|*)
        echo "
 Usage: haxed [<domain>] <option>
    -c | --check ..... Check if DocumentRoot is set to disabled
    -d | --disable ... Change DocumentRoot to disabled in vhost file
    -e | --enable .... Change DocumentRoot back to the user directory
    -h | --help ...... Print this help dialogue and exit

    If <domain> is . or empty, haxed will attempt to get the domain from the PWD.
    ";;
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

## Check for sites getting more than 1000 POST requests from a single IP.
brutecheck(){
echo; if [[ -n $1 ]]; then SEARCH="$1"; echo "Search: $SEARCH"; else read -p 'Search: ' SEARCH; fi; echo
for x in $(grep -Ec "POST.*${SEARCH}" /home/*/var/*/logs/transfer.log /var/log/interworx/*/*/logs/transfer.log /var/log/interworx/*/logs/transfer.log 2> /dev/null | grep -E [0-9]{4}$ | cut -d/ -f5); do
  echo $x; traffic $x ip -s "POST.*${SEARCH}" | grep -E [0-9]{4}; echo;
done
}

# http://www.the-art-of-web.com/system/logs/
## Traffic stats / information (collection of Apache one-liners)
traffic(){
_trafficDash(){ for ((i=1;i<=$1;i++));do printf '#'; done; }
_trafficUsage(){
echo " Usage: traffic DOMAIN COMMAND [OPTIONS]

 Commands:
    ua | useragent . Top User Agents by # of hits
   bot | robots .... Top User Agents identifying as bots by # of hits
   scr | scripts.... Top empty User Agents (likely scripts) by # of hits
    ip | ipaddress . Top IPs by # of hits
    bw | bandwidth . Top IPs by bandwidth usage
   bwt | bwtotal ... Total bandwidth used for a given day
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
    -v | --verbose . Debugging output (prints parameter values)
    -h | --help .... Print this help and exit

 Notes:
    DOMAIN can be '.' to find the domain from the PWD"; return 0;
}

# Check how the domain is specified.
if [[ $1 == '.' ]]; then DOMAIN=$(pwd | sed 's:^/chroot::' | cut -d/ -f4); shift;
  else DOMAIN=$(echo $1 | sed 's:/$::'); shift; fi

opt=$1; shift; # Set option variable using command parameter

# Determin Log File Location
VHOST="/etc/httpd/conf.d/vhost_${DOMAIN}.conf"
if [[ $(hostname) =~ .*-lb ]]; then LOGFILE="/var/log/interworx/*/${DOMAIN}/logs/transfer.log";
else LOGFILE="$(awk '/CustomLog/ {print $2}' $VHOST | head -n1)${DATE}"; fi

SEARCH=''; DATE=''; TOP='20'; DECOMP='egrep -h'; VERBOSE=0; # Initialize variables
OPTIONS=$(getopt -o "s:d:n:hv" --long "search:,days:,lines:,help,verbose" -- "$@") # Execute getopt
eval set -- "$OPTIONS" # Magic

while true; do # Evaluate the options for their options
case $1 in
  -s|--search ) SEARCH="$2"; shift ;; # search string (regex)
  -d|--days   ) DATE="-$(date --date="-$((${2}-1)) day" +%m%d%Y).zip"; DECOMP='zegrep';
		echo; date --date="-${2} day" +"%A, %B %d, %Y -- %Y.%m.%d";
                LOGFILE="/home/*/var/${DOMAIN}/logs/transfer.log${DATE}"; shift ;; # days back
  -n|--lines  ) TOP=$2; shift ;; # results
  -v|--verbose) VERBOSE=1 ;; # Debugging Output
  --          ) shift; break ;; # More Magic
  -h|--help|* ) _trafficUsage; return 0 ;; # print help info
esac;
shift;
done

echo
case $opt in

ua|useragent	) $DECOMP "$SEARCH" $LOGFILE | awk -F\" '{freq[$6]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
	 	  | sort -rn | head -n$TOP ;;

bot|robots	) $DECOMP "$SEARCH" $LOGFILE | awk -F\" '($6 ~ /[Bb]ot|[Cc]rawler|[Ss]pider/) {freq[$6]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
	 	  | sort -rn | head -n$TOP ;;

scr|scripts	) $DECOMP "$SEARCH" $LOGFILE | awk -F\" '($6 ~ /^-?$/) {print $1}' | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
		  | sort -rn | head -n$TOP ;;


ip|ipaddress	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
		  | sort -rn | head -n$TOP ;;


bw|bandwidth	) $DECOMP "$SEARCH" $LOGFILE | awk '{tx[$1]+=$10} END {for (x in tx) {printf "   %-15s   %8s M\n",x,(tx[x]/1024000)}}'\
		  | sort -k 2n | tail -n$TOP | tac ;;

bwt|bwtotal     ) $DECOMP "$SEARCH" $LOGFILE | awk '{tx+=$10} END {print (tx/1024000)"M"}' ;;

sum|summary	) for x in $($DECOMP "$SEARCH" $LOGFILE | awk '{freq[$1]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn | head -n$TOP | awk '{print $2}'); do
		echo $x; $DECOMP "$SEARCH" $LOGFILE | grep $x | cut -d' ' -f9,12- | sort | uniq -c | sort -rn | head -n$TOP | tr -d \"; echo;
		done ;;

s|search	) $DECOMP "$SEARCH" $LOGFILE ;;

hr|hour 	) for x in $(seq -w 0 23); do echo -n "${x}:00 "; $DECOMP "$SEARCH" $LOGFILE | egrep -c "/[0-9]{4}:$x:"; done ;;

gr|graph	) for x in $(seq -w 0 23); do echo -n "${x}:00"; count=$($DECOMP "$SEARCH" $LOGFILE | egrep -c "/[0-9]{4}:$x:");
		printf "%7s |%s\n" "$count" "$(_trafficDash $(($count/500)))"; done;;

min|minute	) $DECOMP "$SEARCH" $LOGFILE | awk '{print $4}' | awk -F: '{print $1" "$2":"$3}' | sort | uniq -c | tr -d \[ ;;

type|request	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$6]++} END {for (x in freq) {print x,freq[x]}}' | tr -d \" | sed 's/-/TIMEOUT/' | column -t ;;

url|file	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$7]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
		  | sort -rn | head -n$TOP ;;

ref|referrer	) $DECOMP "$SEARCH" $LOGFILE | awk '{freq[$11]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'\
		  | tr -d \" | sort -rn | head -n$TOP ;;

code|response	) $DECOMP "$SEARCH" $LOGFILE | awk '{print $4":"$9}' | awk -F: '{print $1,$5}' | sort | uniq -c | tr -d \[ ;;

-h|--help|*) _trafficUsage ;;

esac

if [[ $VERBOSE == '1' ]]; then echo; echo -e "DECOMP: $DECOMP\nSEARCH: $SEARCH\nDATE: $DATE\nTOP: $TOP\nLOGFILE: $LOGFILE\n" | column -t; fi # Debugging

echo;
unset DOMAIN SEARCH DATE TOP TIME LOGFILE DECOMP VERBOSE # Variable Cleanup
}

# http://qmailrocks.thibs.com/qmqtool.php
complete -W 'sub rec send sdom radd rdom ladd ldom -h --help' qmq
## Series of qmqtool one-liners for checking the makeup of mail stuck in the queue
qmq(){
if [[ -n "$1" && -z "$2" ]]; then N=20; else N=$2; fi; echo;
case "$1" in
sub ) qmqtool -R | grep "Subject: " | sort | uniq -c | sort -rn | head -n$N ;;
rec ) qmqtool -R | awk '/Recipient:/ { print $3 }' | sort | uniq -c | sort -n ;;
send ) qmqtool -R | grep "From: " | sort | uniq -c | sort -rn | head -n$N ;;
sdom ) qmqtool -R | grep "From: " | grep -Eo '\@[a-z0-9].*\>' | sort | uniq -c | sort -rn | head -n$N;;
radd|raddress ) qmqtool -R | grep "To: " | sort | uniq -c | sort -rn | head -n$N ;;
rdom|rdomain ) qmqtool -R | grep "To: " | cut -d @ -f2 | tr -d '>' | sort | uniq -c | sort -rn | head -n$N ;;
ladd|laddress ) qmqtool -L | grep "To: " | sort | uniq -c | sort -rn | head -n$N ;;
ldom|ldomain ) qmqtool -L | grep "To: " | cut -d @ -f2 | tr -d '>' | sort | uniq -c | sort -rn | head -n$N ;;
-h|--help) echo -e " Usage: qmq [sub|rec|send|sdom|radd|rdom|ladd|ldom] [top#]\n    sub ... Top Subject in Remote Queue\n    send .. Top Sender in Remote Queue\n    sdom .. Top Sending Domain in the Remote Queue\n    rec ... Top Recipient in Remote Queue\n    radd .. Top Receive Address in Remote Queue\n    rdom .. Top Receive Domains in Remote Queue\n    ladd .. Top Receive Address in Local Queue\n    ldom .. Top Receive Domains in Local Queue" ;;
*) qmqtool -s ;;
esac; echo
}

# http://stackoverflow.com/questions/2552402/cat-file-vs-file
complete -W 'send smtp smtp2 pop3 pop3-ssl imap4 imap4-ssl' q
## Load the desired mail log through the necessary timestamp converter
q(){
    case "$1" in
        'send'      ) log='/var/log/send/current'      ;;
        'smtp'      ) log='/var/log/smtp/current'      ;;
	'smtp2'     ) log='/var/log/smtp2/current'     ;;
        'pop3'      ) log='/var/log/pop3/current'      ;;
        'pop3-ssl'  ) log='/var/log/pop3-ssl/current'  ;;
        'imap4'     ) log='/var/log/imap4/current'     ;;
        'imap4-ssl' ) log='/var/log/imap4-ssl/current' ;;
        # works
        #*[0-9]*    ) log="/var/log/send/$1"           ;;
        *[0-9]*     ) log="$(find /var/log/{send,smtp,smtp2,pop3,pop3-ssl,imap4,imap4-ssl}/ -name '*$1*' -type f | head -1)" ;;
    esac
    echo "$log"
    /usr/bin/tai64nlocal < "$log" | $PAGER
}

## Search send log(s) for a domain (look for error messages)
sendlog(){
if [[ -n $1 ]]; then D=$1; else read -p "Domain: " D; fi
if [[ $2 == 'all' ]]; then cat /var/log/send/* | tai64nlocal | egrep -B2 -A8 "$D" | less;
else cat /var/log/send/current | tai64nlocal | egrep -B2 -A8 "$D" | less; fi
}

## Check/Enable/Disable Local Delivery for domain(s)
localdelivery(){
if [[ $2 == 'all' ]]; then domain='';
elif [[ -n $2 ]]; then domain=$(echo $2 | sed 's:/::g');
else domain=$(pwd | sed 's:^/chroot::' | cut -d/ -f4); fi

if [[ -n $2 && ${#2} -gt 3 ]]; then
vhost=$(grep -l " $(echo $domain | sed 's/\(.*\)/\L\1/g')" /etc/httpd/conf.d/vhost_*);
unixuser=$(awk '/SuexecUserGroup/ {print $2}' $vhost | head -1);
else unixuser=$(getusr); fi

_localDeliveryCheck(){
echo; echo "----- Local Delivery Status -----"
sudo -u $unixuser -- siteworx -u -n -c EmailRemotesetup -a listLocalDeliveryStatus | awk '{print $1,$NF}' | grep -E "^${domain}"\
 | sed "s/0$/${BRIGHT}${RED}Disabled${NORMAL}/g;s/1$/${BRIGHT}${GREEN}Enabled${NORMAL}/g" | column -t; echo
}

case $1 in
-c | --check) # Check
    _localDeliveryCheck ;;
-d | --disable) # Disable
    sudo -u $unixuser -- siteworx -u -n -c EmailRemotesetup -a disableLocalDelivery --domain ${domain}; _localDeliveryCheck ;;
-e | --enable) # Enable
    sudo -u $unixuser -- siteworx -u -n -c EmailRemotesetup -a enableLocalDelivery --domain ${domain}; _localDeliveryCheck ;;
-h | --help | *) # Help
    echo -e "\n  Usage: localDelivery [option] [domain]
    -c | --check [domain|all] . Check Local Delivery status for domain(s)
    -d | --disable [domain] ... Disable Local Delivery for the domain
    -e | --enable [domain] .... Enable Local Delivery for the domain\n" ;;
esac
}

## Setup Google MX records and turn off local delivery
googlemx(){
if [[ -z $1 || $1 == '-h' || $1 == '--help' ]]; then
  echo -e "\n Usage: googlemx OPTION DOMAIN
    EX: googlemx -a DOMAIN\n    Ex: googlemx -c DOMAIN\n    Ex: googlemx --list\n\n OPTIONS
     -a ... Remove old MX records and add Google MX\n     -c ... Check existing MX records for domain\n --list ... List domains and ids for the account\n";
fi

if [[ $1 == --list ]]; then
  echo; (echo 'ID Domain'; sudo -u $(getusr) -- siteworx -u -n -c Dns -a listZones | awk '($2 !~ /nextmp/) {print $1,$2}') | column -t; echo
elif [[ $1 = '-c' && -n $2 ]]; then
  zoneid=$(sudo -u $(getusr) -- siteworx -u -n -c Dns -a listZones | awk "(\$2 ~ /$2/)"'{print $1}')
  echo -e "\nID ... MX-Records-for: $2"
  (sudo -u $(getusr) -- siteworx -u -n -c Dns -a queryDnsRecords --zone_id $zoneid) | awk '($4 ~ /MX/) {print $1,$4,$6,$7,$8}' | sort -nk3 | column -t; echo
fi

if [[ $1 == '-a' && -n $2 ]]; then
  zoneid=$(sudo -u $(getusr) -- siteworx -u -n -c Dns -a listZones | awk "(\$2 ~ /$2/)"'{print $1}')
  echo -e "\nID ... MX-Records-for: $1"
  (sudo -u $(getusr) -- siteworx -u -n -c Dns -a queryDnsRecords --zone_id $zoneid) | awk '($4 ~ /MX/) {print $1,$4,$6,$7,$8}' | sort -nk3 | column -t; echo

  echo "Removing old records"
  mxrecord=$((sudo -u $(getusr) -- siteworx -u -n -c Dns -a queryDnsRecords --zone_id $zoneid) | awk '($4 ~ /MX/) {print $1}')
  for x in $mxrecord; do nodeworx -u -n -c DnsRecord -a delete --record_id $x; done

  echo
  sudo -u $(getusr) -- siteworx -u -n -c Dns -a addMX --zone_id $zoneid --preference 1 --mail_server ASPMX.L.GOOGLE.COM --ttl 3600 && echo '[Added] ASPMX.L.GOOGLE.COM'
  sudo -u $(getusr) -- siteworx -u -n -c Dns -a addMX --zone_id $zoneid --preference 5 --mail_server ALT1.ASPMX.L.GOOGLE.COM --ttl 3600 && echo '[Added] ALT1.ASPMX.L.GOOGLE.COM'
  sudo -u $(getusr) -- siteworx -u -n -c Dns -a addMX --zone_id $zoneid --preference 5 --mail_server ALT2.ASPMX.L.GOOGLE.COM --ttl 3600 && echo '[Added] ALT2.ASPMX.L.GOOGLE.COM'
  sudo -u $(getusr) -- siteworx -u -n -c Dns -a addMX --zone_id $zoneid --preference 10 --mail_server ALT3.ASPMX.L.GOOGLE.COM --ttl 3600 && echo '[Added] ALT3.ASPMX.L.GOOGLE.COM'
  sudo -u $(getusr) -- siteworx -u -n -c Dns -a addMX --zone_id $zoneid --preference 10 --mail_server ALT4.ASPMX.L.GOOGLE.COM --ttl 3600 && echo '[Added] ALT4.ASPMX.L.GOOGLE.COM'

  localdelivery -d $2
fi
}
