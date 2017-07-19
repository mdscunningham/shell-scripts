#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2017-06-27
# Updated: 2017-07-19
#
# Purpose: Check hashes of cert parts to confirm they match
#

for x in $@; do
  echo -n "$(basename $x) :: "
  case $x in
    *.key) openssl rsa -noout -modulus -in $x | openssl md5 | awk '{print $NF}' ;;
    *.csr) openssl req -noout -modulus -in $x | openssl md5 | awk '{print $NF}' ;;
    *.crt) openssl x509 -noout -modulus -in $x | openssl md5 | awk '{print $NF}' ;;
  esac
done
