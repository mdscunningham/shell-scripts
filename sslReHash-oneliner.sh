#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-09-22
# Updated: 2014-09-22
#
#
#!/bin/bash

read -p "Domain Name: " domain; openssl req -nodes -sha256 -new -key /home/*/var/${domain}/ssl/${domain}.priv.key -out ~/new.$domain.csr\
 -subj "$(openssl req -in /home/*/var/${domain}/ssl/${domain}.csr -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')" && cat ~/new.${domain}.*
