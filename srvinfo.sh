#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-09-15
# Updated: 2014-01-04
#
#
#!/bin/bash

echo -e "\n===== PHP INFO ===== \n$(php -v) $(php -m | column -x | sed s/"\["/"\\n\\n\["/g) 
\n\n\n===== APACHE INFO ===== \n$(httpd -v) \n\n$(httpd -M | column -x) 
\n\n\n===== DATABASE INFO ===== \n $(mysql --version) \n$(mysqld --version) 
\n\n\n===== VERSION CONTROL INFO ===== \n $(git --version) \n\n$(svn --version) 
\n\n\n===== OS & KERNEL INFO ===== \n$(cat /etc/redhat-release) \n$(cat /proc/version | sed s/\(/\\n\(/g)
\n\n\n===== HARDWARE INFO ===== \n$(lscpu) \n\n$(lspci)\n " > ~/serverinfo.txt
echo -e "\n~/serverinfo.txt created successfully.\n"
