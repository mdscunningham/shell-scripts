#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-24
# Updated: 2014-03-24
#
#
#!/bin/bash

echo; if [[ -z "$1" ]]; then printf "FTP Username: "; read U; else U="$1"; fi
echo "Generating .ftpaccess ..."; echo
echo -e "\n<Limit WRITE>\n  DenyUser $U\n</Limit>\n" >> .ftpaccess
