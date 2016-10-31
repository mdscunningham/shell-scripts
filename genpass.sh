#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-10-10
# Updated: 2016-10-10
#
# Purpose: Quickly and simply generate random, secure passwords
#

usage(){
echo "
  Usage: $(basename $0) [OPTIONS] [ARGUMENTS]

    -l ... <length> in characters
    -m ... Use NIST mkpasswd
    -b ... Use OpenSSL Rand Base64
    -x ... Use OpenSSL Rand Hex
    -k ... Use xkcd.com/936/ method
"; exit 1
  }


if [[ $@ =~ --help ]]; then usage; fi

length=24
method="xkcd"

while getopts l:kmxbh option; do
  case "${option}" in
    l) length=${OPTARG} ;;
    k) method="xkcd" ;;
    m) method="mkpasswd" ;;
    x) method="hex" ;;
    b) method="base64" ;;
    h|*) usage ;;
  esac
done

case $method in

  mkpasswd )
	if [[ $(grep NIST $(which mkpasswd)) ]]; then mkpasswd -l ${length}
	else echo "You do not appear to have the NIST mkpasswd installed."; fi
	;;

  base64 )
	openssl rand -base64 ${length} | tr -d '\n' | sed 's/ //g' | cut -c 1-${length}
	;;

  hex )
	openssl rand -hex ${length} | cut -c 1-${length}
	;;

  xkcd )
	if [[ -x /usr/bin/shuf ]]; then
	  wordList='/usr/share/dict/words';
	  wordLength=$(( (${length} - 4) / 4 ))
	  echo $(shuf -n 1000 $wordList | grep -E ^[a-z]{$wordLength}$ | shuf -n 4 )$(( ($RANDOM % 9000) + 1000 ))\
	   | sed 's/\b\(.\)/\u\1/g' | sed 's/ //g' | cut -c 1-${2}

	else
	  n=0;  word=(); len=$(wc -l < $wordList)
	  while [[ $n -lt 4 ]]; do
	    rnd=$(( $(od -vAn -N4 -tu4 < /dev/urandom) % $len + 1 ));
	    word[$n]=$(sed -n "${rnd}p" $wordList | grep -E ^[a-z]{4,8}$ | sed 's:\b\(.\):\u\1:');
	    if [[ -n ${word[$n]} ]]; then n=$n+1; fi;
	  done;
	  echo "${word[0]}${word[1]}${word[2]}${word[3]}$(( $RANDOM % 9000 + 1000 ))";
	  unset n word len
	fi
	;;

esac
