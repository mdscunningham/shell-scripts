#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-02-28
# Updated: 2015-04-03
#
#
#!/bin/bash

cdomain(){
doc=$(grep -C5 " $1" /usr/local/apache/conf/httpd.conf | awk '/DocumentRoot/ {print $2}')

if [[ -z $1 ]]; then
  echo -e "\nUsage: cdomain <domain.tld|ipaddress>\n"
elif [[ -n $doc ]]; then
  cd $doc; pwd
else
  echo -e "\nCould not find $1 in httpd.conf\n"
fi
}

cdomain $1
