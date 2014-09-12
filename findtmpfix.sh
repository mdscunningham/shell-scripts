#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-09-10
# Updated: 2014-09-11
#
#
#!/bin/bash

# for x in /etc/httpd/conf.d/vhost_[^000]*.conf; do if [[ -n $(awk '/VirtualHost/{print $3}' $x) ]]; then echo "$x: TempFix"; fi; done

echo
(for x in /etc/httpd/conf.d/vhost_[^000]*.conf; do
  if [[ -n $(awk '/VirtualHost/{print $3}' $x) ]]; then
    domain=$(echo $x | cut -d_ -f2 | sed 's/\.conf//')
    tmpips=$(awk '/VirtualHost/{print $2,$3}' $x | sed 's/:80//g;s/:8080//g;s/>//g')
    echo "TempFix: $domain $tmpips";
  fi;
done) | column -t
echo
