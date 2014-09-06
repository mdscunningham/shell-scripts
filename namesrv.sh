#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-27
# Updated: 2013-12-27
#
#
#!/bin/bash

echo;
for x in $(grep ns[1-2] ~iworx/iworx.ini | cut -d\" -f2;); do echo "$x ($(dig +short $x))"; done
echo
