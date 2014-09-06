#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-04-10
# Updated: 2014-04-10
#
#
#!/bin/bash

read -p "Domain Name: " domain; openssl req -nodes -newkey rsa:2048 -keyout ~/new.$domain.priv.key -out ~/new.$domain.csr -subj "$(openssl req -in /home/*/var/${domain}/ssl/${domain}.csr -subject -noout | sed 's/^subject=//' | sed -n l0 | sed 's/$$//')" && cat ~/new.${_domain}.*
