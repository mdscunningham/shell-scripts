#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-23
# Updated: 2014-08-23
#
#
#!/bin/bash

parallel(){
if [[ -z $@ || $1 == '-h' || $1 == '--help' ]]; then echo -e '\n Usage: parallel <domain> \n'; return 0;
elif [[ -f /etc/httpd/conf.d/vhost_$1.conf ]]; then D=$1;
elif [[ $1 == '.' && -f /etc/httpd/conf.d/vhost_$(pwd | sed 's:^/chroot::' | cut -d/ -f4).conf ]]; then
  D=$(pwd | sed 's:^/chroot::' | cut -d/ -f4)
else
  echo -e '\nCould not find requested vhost file!\n'; return 1;
fi

# Covert domain into Regex
domain=$(echo $D | sed 's:\.:\\\\\\.:g');

# Place first comment followed by a blank line
sed -i "s:\(.*RewriteCond %{HTTP_HOST}...$domain.\[NC\]\):\1\n  \# ----- Magento-Parallel-Downloads -----\n:g" /etc/httpd/conf.d/vhost_$D.conf

# Place logic for parallel downloads
for x in skin media js; do sed -i "s:\(.*RewriteCond %{HTTP_HOST}...$domain.\[NC\]\):\1\n  RewriteCond %{HTTP_HOST} \!\^$x\\\.$domain [NC]:g" /etc/httpd/conf.d/vhost_$D.conf; done

# Plase the secone comment preceded by a blank line
sed -i "s:\(.*RewriteCond %{HTTP_HOST}...$domain.\[NC\]\):\1\n\n  \# ----- Magento-Parallel-Downloads -----:g" /etc/httpd/conf.d/vhost_$D.conf

# Test and restart Apache
 httpd -t && service httpd reload && echo -e "\nParallel Downloads configured for $D\n"
}
parallel "$@"
