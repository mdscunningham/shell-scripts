#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-04-15
# Updated: 2015-04-15
#
#
#!/bin/bash

echo -e "\nSuccessful SSH Logins"; awk '/Accept/{print $(NF-5),$(NF-3)}' /var/log/secure* | sort | uniq -c | sort -rn | head;
echo -e "\nFailed SSH Logins"; awk '/Failed/{print $(NF-5),$(NF-3)}' /var/log/secure* | sort | uniq -c | sort -rn | head; echo
