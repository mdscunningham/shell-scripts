#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-06
# Updated: 2014-07-05
#
#
#!/bin/bash

# RewriteCond %{HTTP_USER_AGENT} 80legs\.com [NC]
# RewriteRule .* - [F,L]

if [[ -z $@ || $1 == '-h' || $1 == '--help' ]]; then
  echo -e "\n Usage: blockbot [list of bots]\n"
else
  if grep -Eq '^.*Order Allow,Deny.*$' .htaccess; then
    sed -i 's/\(^.*Order Allow,Deny.*$\)/\1\nDeny from env=bad_bot/' .htaccess
  else echo -e "\nOrder Allow,Deny\nDeny from env=bad_bot\nAllow from All" >> .htaccess; fi

  echo -e "\n# ----- Block Bad Bots Section -----\n" >> .htaccess
  for x in $@; do echo "BrowserMatchNoCase $x bad_bot" >> .htaccess; done
  echo -e "\n# ----- Block Bad Bots Section -----\n" >> .htaccess;
fi
