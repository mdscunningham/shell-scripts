#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2014-08-02
# Updated: 2014-08-19
#
#
#!/bin/bash

cdomain(){
if [[ -z "$@" ]]; then echo -e "\n  Usage: cdomain <domain.tld>\n"; return 0; fi

# convert input to lowercase (better input handling)
vhost=$(grep -l " $(echo $1 | sed 's/\(.*\)/\L\1/g')" /etc/httpd/conf.d/vhost_*)
if [[ -n $vhost ]]; then
  cd $(awk '/DocumentRoot/ {print $2}' $vhost | head -1); pwd
else
  echo -e "\nCould not find $1 in the vhost files!\n"
fi
}
cdomain "$@"
