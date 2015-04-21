#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2015-04-15
# Updated: 2015-04-15
#
#
#!/bin/bash

# for x in /home/*/public_html; do echo $x | cut -d/ -f3; done

awk -F: '{print $1}' /etc/domainusers
