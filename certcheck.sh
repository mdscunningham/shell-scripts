#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2017-06-27
# Updated: 2018-02-26
#
# Purpose: Check hashes of cert parts to confirm they match
#

HASH='md5'

case $1 in
  md5|sha1|sha256|sha512) HASH=$1; echo -e "\nUsing $HASH method\n"; shift;;
  -h|--help) echo -e "\nUsage: \n  $0 [hash method] <certfile1> [<certfile2> <certfile3> ...]\n\n  Valid Hash-Methods\n    md5, sha1, sha256, sha512\n"; exit ;;
esac

for x in $@; do
  case $x in
    *.key) echo $(openssl rsa -noout -modulus -in $x | openssl $HASH | awk '{print $NF}') :: $(basename $x) ;;
    *.csr) echo $(openssl req -noout -modulus -in $x | openssl $HASH | awk '{print $NF}') :: $(basename $x) ;;
    *.crt) echo $(openssl x509 -noout -modulus -in $x | openssl $HASH | awk '{print $NF}') :: $(basename $x) ;;
  esac
done

