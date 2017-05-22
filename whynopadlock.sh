#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2017-05-21
# Updated: 2017-05-21
#
# Purpose: Locate content loaded insecurely on an https domain
#

echo -e "----- CONNECTION SUMMARY -----\n";
curl -svILk $1 2>&1 | grep -v '^<';
echo -e "----- CONNECTION SUMMARY -----\n";

echo -e "----- INSECURE CONTENT -----\n";
curl -sLk $1 | grep -Pio '(embed.*src|img.*src|iframe.*src|link.*href|object.*data)=.http://.*?\"' | awk -F'[ \"]' '{print $1,$(NF-1)}'
echo -e "\n----- INSECURE CONTENT -----\n";
