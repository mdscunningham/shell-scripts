#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-19
# Updated: 2014-08-19
#
#
#!/bin/bash

n=0;  word=(); len=$(wc -l < /usr/local/interworx/lib/dict/words)
while [[ $n -lt 4 ]]; do

  # http://www.cyberciti.biz/faq/bash-shell-script-generating-random-numbers/
  rnd=$(( $(od -vAn -N4 -tu4 < /dev/urandom) % $len + 1 ));

  word[$n]=$(sed -n "${rnd}p" /usr/local/interworx/lib/dict/words | egrep '^[a-z]{4,8}$' | sed 's:\b\(.\):\u\1:');
  if [[ -n ${word[$n]} ]]; then n=$n+1; fi;
done;
echo "${word[0]}${word[1]}${word[2]}${word[3]}$(( $RANDOM % 9999 + 1000 ))";
unset n word len
