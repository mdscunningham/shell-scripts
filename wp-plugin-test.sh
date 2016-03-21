#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-03-20
# Updated: 2016-03-21
#
# Purpose: Disable all WP pluins, then enable them one at a time, to see which
#          one(s) may be breaking site functionality.
#

# Lookup domain name
domain=$(grep -C5 $PWD /usr/local/apache/conf/httpd.conf | awk '/ServerName/ {print $2}');

# Get list of plugin directories
dirs=$(find $PWD/wp-content/plugins/* -maxdepth 0 -type d -print);

# Disable all the plugins
echo -e "\nDisabling All Plugins";
for plugin in $dirs;
  do mv $plugin{,.disable};
done

# Re-enable each plugin individually and test the site
for plugin in $dirs; do
  echo -e "\nRe-Enabling :: $plugin";
  mv $plugin{.disable,};
  echo "Testing $domain:";
  curl -sILk $domain | egrep --color "HTTP/1.[01] [2345][0-9]{2}";
  mv $plugin{,.disable};
done;

# Re-Enable all plugins
echo -e "\nRe-Enabling All Plugins";
for plugin in $dirs;
  do mv $plugin{.disable,};
done
