#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-01
# Updated: 2014-08-02
#
#
#!/bin/bash

# ----- Magento PHP-FPM pointer domain Multistore fix -----
#  <IfModule mod_fastcgi.c>
#  RewriteCond %{REQUEST_URI} !^/php\.fcgi
#  SetEnvIf REDIRECT_MAGE_RUN_CODE (.+) MAGE_RUN_CODE=$1
#  SetEnvIf REDIRECT_MAGE_RUN_TYPE (.+) MAGE_RUN_TYPE=$1
#  </IfModule>

fpmfix(){

if [[ -z $1 || $1 == '.' ]]; then
  D=$(pwd | sed 's:^/chroot::' | cut -d/ -f4)
else
  D=$(echo $1 | sed 's:/::g');
fi

vhost="/etc/httpd/conf.d/vhost_${D}.conf"

if [[ -f $vhost ]]; then
  sed -i 's/\(RewriteCond.*\.fcgi\)/\1\n  # ----- PHP-FPM-Multistore-Fix -----\n  SetEnvIf REDIRECT_MAGE_RUN_CODE (\.\+) MAGE_RUN_CODE=\$1\n  SetEnvIf REDIRECT_MAGE_RUN_TYPE (\.\+) MAGE_RUN_TYPE=\$1\n  # ----- PHP-FPM-Multistore-Fix -----/g' $vhost
  httpd -t && service httpd reload
  echo -e "\nFPM fix has been applied to $(basename $vhost)\n"
else
  echo -e "\n$(basename $vhost) not found!\n"
fi

}

fpmfix "$@"
