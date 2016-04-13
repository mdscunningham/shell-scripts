#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-04-29
# Updated: 2016-04-12
#
#
#!/bin/bash

# Taste the rainbow
      BLACK=$(tput setaf 0);        RED=$(tput setaf 1)
      GREEN=$(tput setaf 2);     YELLOW=$(tput setaf 3)
       BLUE=$(tput setaf 4);     PURPLE=$(tput setaf 5)
       CYAN=$(tput setaf 6);      WHITE=$(tput setaf 7)

     BRIGHT=$(tput bold);        NORMAL=$(tput sgr0)
      BLINK=$(tput blink);      REVERSE=$(tput smso)
  UNDERLINE=$(tput smul)

echo; for I in $(ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.|^10\.|^172\.|^192\.168\.'); do
    printf "  ${BRIGHT}${YELLOW}%-15s${NORMAL}  " "$I";
    D=$(grep -A5 "<VirtualHost.*$I" /usr/local/apache/conf/httpd.conf | awk '!'"/$(hostname)/"' && /ServerName/{print $NF}');
    for x in $D; do printf "$x "; done; echo;
done; echo
