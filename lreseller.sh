#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-02
# Updated: 2014-09-02
#
#
#!/bin/bash

(
nodeworx -u -n -c Siteworx -a listAccounts | sed 's/ /_/g' | awk '{print $5,$2,$10}';
nodeworx -u -n -c Reseller -a listResellers | sed 's/ /_/g' | awk '{print $1,"0.Reseller",$3}'
) | sort -n | column -t | sed 's/\(.*0\.Re.*\)/\n\1/' | grep -Ev '^1 '
