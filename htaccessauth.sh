#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-08
# Updated: 2013-11-08
#
#
#!/bin/bash

echo -e "\n# ----- Password Protection Section -----\nAuthUserFile $(pwd)/.htpasswd\nAuthGroupFile /dev/null\nAuthName \"Authorized Access Only\"\nAuthType Basic\nRequire valid-user\n# ----- Password Protection Section -----\n" >> .htaccess
