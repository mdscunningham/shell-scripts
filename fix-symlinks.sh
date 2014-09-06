#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-04-27
# Updated: 2014-04-27
#
#
#!/bin/bash

for x in $(~iworx/bin/listaccounts.pex | awk '{print $1}'); do
    find /home/$x/ -type l -user root -exec chown -h $x:$x {} \;
done
