#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-06-06
# Updated: 2014-06-06
#
#
#!/bin/bash

if [[ $1 =~ ^-.*$ ]]; then
	shift; param=$@
	echo ${param}
else
	param=$@
	echo ${param}
fi;
