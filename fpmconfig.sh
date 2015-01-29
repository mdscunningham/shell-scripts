#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-11-17
# Updated: 2014-11-17
#
#
#!/bin/bash

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
    -d ... Enable display_erorrs
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
