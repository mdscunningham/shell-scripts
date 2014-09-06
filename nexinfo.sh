#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-08
# Updated: 2014-08-02
#
#
#!/bin/bash

echo; if [ "$1" == "" ]; then printf 'Username: '; read U; else U="$1"; fi
echo 'Generating nexinfo.php ...'; echo

# This is an encoded version of the phpInfo call, so that it won't render when viewed online
sudo -u "$U" echo '<?php phpinfo(); ?>' > nexinfo.php &&
echo -e "\nhttp://$(pwd | sed 's:^/chroot::' | cut -d/ -f4-)/nexinfo.php created successfully.\n" | sed 's/html\///'
