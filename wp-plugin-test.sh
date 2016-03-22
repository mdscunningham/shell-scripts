#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-03-20
# Updated: 2016-03-22
#
# Purpose: Disable all WP pluins, then enable them one at a time, to see which
#          one(s) may be breaking site functionality.
#

# Argument Parsing
while getopts d:u:h option; do
  case "${option}" in
    d) domain=${OPTARG};;
    u) username=${OPTARG};;
    h) echo "
  Usage: $0 [OPTIONS] [ARGUMENTS]
    -u ... <username> Specify username
    -d ... <domain>   Sepcify domain name

    -h ... Print this help and quit
       "; exit;;
  esac
done

# Lookup user's homedir
if [[ ! $username && ! $domain ]]; then
  userdir=$PWD;
elif [[ $username && ! $domain ]]; then
  userdir="/home/$username/public_html"
elif [[ $domain ]]; then
  userdir=$(grep -C5 " ${domain}" /usr/local/apache/conf/httpd.conf | awk '/DocumentRoot/ {print $2}' | head -1)
fi

# Lookup domain name
if [[ ! $domain ]]; then
  domain=$(grep -C5 ${userdir} /usr/local/apache/conf/httpd.conf | awk '/ServerName/ {print $2}' | tail -1);
fi

# Get list of plugin directories
dirs=$(find ${userdir}/wp-content/plugins/* -maxdepth 0 -type d -print);


if [[ ! $(ip a | grep $(dig +time=2 +tries=2 +short $domain) 2>/dev/null) && ! $(grep " $domain" /etc/hosts 2>/dev/null) ]]; then
  echo -e "\n  Looks like the domain is not live on this server, make\n  sure to update /etc/hosts for testing from the server.\n"
else
  # Disable all the plugins
  echo -e "\nDisabling All Plugins";
  for plugin in $dirs;
    do mv $plugin{,.disable};
  done

  # Re-enable each plugin individually and test the site
  for plugin in $dirs; do
    echo -e "\nEnabling :: $plugin";
    mv $plugin{.disable,};
    echo " Testing :: $(ping -c1 $domain | awk 'NR<2 {print $2,"::",$3}')";
    curl -sILk $domain | egrep --color "HTTP/1.[01] [2345][0-9]{2}";
    mv $plugin{,.disable};
  done;

  # Re-Enable all plugins
  echo -e "\nRe-Enabling All Plugins\n";
  for plugin in $dirs;
    do mv $plugin{.disable,};
  done
fi
