#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-10-18
# Updated: 2014-10-18
#
#
#!/bin/bash

file="/etc/php-fpm.d/$(getusr).conf";
if [[ $(grep allow_url_fopen $file 2> /dev/null) ]]; then echo -e "\nallow_url_fopen already enabled in FPM pool $file\n";
elif [[ -f $file ]]; then echo "php_admin_value[allow_url_fopen] = On" >> $file && service php-fpm reload && echo -e "\nallow_url_fopen enabled in FPM pool for $file\n";
else echo -e "\n Could not find $file !\n Try running this from the user's /home/dir/\n"; fi;
unset file;
