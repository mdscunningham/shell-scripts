#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-29
# Updated: 2015-01-23
#
#
#!/bin/bash

_freeips ()
{
    echo;
    for x in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.|^10\.|^172\.');
    do
        printf "\n%-15s " "$x";
        grep -l $x /etc/httpd/conf.d/vhost_[^000_]*.conf 2> /dev/null;
    done | grep -v .conf$ | column -t;
    echo
}
_freeips
