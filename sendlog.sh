#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-01
# Updated: 2014-03-01
#
#
#!/bin/bash

if [[ -n $1 ]]; then D=$1; else read -p "Domain: " D; fi
if [[ $2 == 'all' ]]; then cat /var/log/send/* | tai64nlocal | egrep -B1 -A8 "from.*$D" | less;
else cat /var/log/send/current | tai64nlocal | egrep -B1 -A8 "from.*$D" | less; fi

