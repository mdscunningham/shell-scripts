#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-20
# Updated: 2014-04-25
#
#
#!/bin/bash

for x in "$@"; do
echo
echo "GEO-IP INFO: ($x)"
echo "--------------------------------------------------------------------------------"
curl -s ipinfo.io/$x | sed 's/,\"/\n\"/g' | awk -F\" '/[a-z]/ {printf "%8s : %s\n",$2,$4}'
done;
echo
