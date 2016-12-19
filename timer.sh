#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-04-30
# Updated: 2016-12-18
#
# Purpose: Put a count-up timer into the title bar
#

h=0;
m=0;
s=0;
while true; do
  ((s++));
  sleep 1;
  if [[ $[$s % 60] == 0 ]]; then
    ((m++));
    s=0;
  fi;

  if [[ $[$m % 60] == 0 && $[$s % 60] == 0 ]]; then
    ((h++));
    m=0;
  fi;

  clear;
  printf "\033]0;"
  for t in $h $m $s; do
    if [[ $t -lt 10 ]]; then
      printf "0$t:";
    else
      printf "$t:";
    fi;
  done
  printf "\007"
done

