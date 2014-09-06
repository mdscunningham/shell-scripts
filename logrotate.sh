#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-18
# Updated: 2014-04-16
#
#
#!/bin/bash

## Create date/time string
datetime=$(date +%Y.%m.%d_%H)

## Get list of secondary domains, and then compress, rename and create new error.log files
for website in $(for sitedir in */html; do echo $sitedir | cut -d/ -f1; done); do
  for file in error.log transfer.log; do
    mv var/$website/logs/$file var/$website/logs/${file}-$datetime;
    gzip var/$website/logs/${file}-$datetime;
  done;
done;

## If php-fpm then compress, rename, and create new error.log files
if [[ -f var/php-fpm/error.log ]]; then
    mv var/php-fpm/error.log var/php-fpm/error.log-$datetime
    gzip var/php-fpm/error.log-$datetime;
fi;
