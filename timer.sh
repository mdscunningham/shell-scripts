#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-04-30
# Updated: 2016-04-30
#
# Purpose: Put a count-up timer into the title bar
#

m=0;
s=0;
while true; do
  ((s++));
  sleep 1;
  if [[ $[$s % 60] == 0 ]]; then
    ((m++));
    s=0;
  fi;
  clear;
  printf "\033]0;$m:$s\007";
done

