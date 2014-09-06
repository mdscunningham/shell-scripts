#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-27
# Updated: 2014-08-27
#
#
#!/bin/bash

file="/etc/php-fpm.d/$(getusr).conf";
if [[ $(grep zlib.output_compression $file 2> /dev/null) ]]; then echo -e "\nGzip already enabled in FPM pool $file\n";
elif [[ -f $file ]]; then echo "php_admin_value[zlib.output_compression] = On" >> $file && service php-fpm restart && echo -e "\nGzip enabled in FPM pool for $file\n";
else echo -e "\n Could not find $file !\n Try running this from the user's /home/dir/\n"; fi;
unset file;
