#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-04-29
# Updated: 2014-07-28
#
#
#!/bin/bash

echo; for I in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.|^10\.|^172\.'); do
    printf "  ${BRIGHT}${YELLOW}%-15s${NORMAL}  " "$I";
    D=$(grep -l $I /etc/httpd/conf.d/vhost_[^000_]*.conf | cut -d_ -f2 | sed 's/.conf$//');
    for x in $D; do printf "$x "; done; echo;
done; echo
