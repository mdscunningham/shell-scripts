sinfo ()
{
# OS information
OS="$(cat /etc/redhat-release | awk '{print $1, $3}') $(uname -r)"
if echo $OS | grep -i "centos 4" > /dev/null; then
        OS="$OS WHY ARE YOU USING THIS CRAP? This shit is dead."
fi
SERV=$(chkconfig --list)

# webserver type and version
WEBSERV="WebServer     : $(curl -s -I $(ips | head -1 | awk '{print $3}') | awk '/Server/ {print $2}')"

# modsecurity status/version
if rpm -q mod_security  &> /dev/null; then
    MODSEC_TYPE=$(echo ModSecurity $(rpm -qi mod_security|awk '/Version/ {print $3}'))
else
    MODSEC_TYPE=$(echo "No ModSecurity :'(")
fi

# Ruleset version
if ls /etc/httpd/modsecurity.d/modsecurity_crs_10_*.conf &> /dev/null; then
        OWASP_TYPE=$(echo OWASP CRS $(awk '/Core ModSecurity Rule Set ver/ {print $NF}' /etc/httpd/modsecurity.d/modsecurity_crs_10_*.conf))
fi

# PHP version and type
if [ $(echo "$SERV" | awk '/php-fpm/ && /on/' | wc -l) -ge 1 ]; then
        PHP=$(echo 'php-fpm' $(php --version | awk '/^PHP/ {print $2}'))
elif grep -il "^LoadModule suphp_module" /etc/httpd/conf.d/suphp.conf >& /dev/null; then
        PHP=$(echo 'suphp' $(php --version | awk '/^PHP/ {print $2}'))
elif grep -il "^LoadModule php5_module" /etc/httpd/conf.d/php.conf >& /dev/null; then
        PHP=$(echo 'mod_php' $(php --version | awk '/^PHP/ {print $2}'))
elif grep -il "^LoadModule fastcgi_module" /etc/httpd/conf.d/php.conf >& /dev/null; then
        PHP=$(echo 'php fastcgi' $(php --version | awk '/^PHP/ {print $2}'))
else
        PHP=$(echo fuck this shit my script done broke)
fi

# control panel type and version
if [ -e /home/interworx/iworx.ini ]; then
        CPANEL=$(echo 'InterWorx' $(awk -F'"' '/version/ {i++} i==3 {print $2; exit}' /home/interworx/iworx.ini))
else
        CPANEL='Not seeing anything here, bro'
fi

# database type and version
MYSQLVER=$(mysql --version | awk '{print $5}'|cut -d',' -f1)
if service mysqld status | grep -i percona > /dev/null; then
        MYSQLTYPE="MySQL Percona"
else
        MYSQLTYPE="MySQL"
fi

# server resources
CPUMOD=$(cat /proc/cpuinfo | grep -m1 "model name"|awk -F':' '{print $2}' | tr -s " ")
CPUCORES=$(cat /proc/cpuinfo | awk '/cpu cores/ {print $4;exit;}')
CPUCOUNT=$(echo $(cat /proc/cpuinfo | awk '/physical id/ {print $4}' | sort -n | tail -n1) "+ 1" | bc)
MEM=$(free -m | awk '/Mem/ {print $2}')
DISK=$(df -h|grep -E "chroot|home" | awk '{print $3, "/", $2, "-", $5 }')

echo -e "
OS            : $OS
WebServer     : $WEBSERV, $MODSEC_TYPE, $OWASP_TYPE
PHP           : $PHP
Database      : $MYSQLTYPE, $MYSQLVER
Control Panel : $CPANEL
Processor     : ($CPUCORES cores, $CPUCOUNT cpus) $CPUMOD
Memory        : $MEM MB
Disk (chroot) : $DISK
"
}
sinfo
