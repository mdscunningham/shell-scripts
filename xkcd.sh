#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-07-10
# Updated: 2014-08-19
#
#
#!/bin/bash

xkcd(){
# Check for help option
# ^^^ regex should match -h | --help
if [[ $@ =~ -h ]]; then
  echo -e "\n  Usage: xkcd [-l <length>] [-v]\n"
  return 0;
fi

if [[ -x /usr/bin/shuf ]]; then
# Set verbose flag, in this case vulgar flag, since the regular dictionary hasn't been sanitized
# ^^^ regex should match -v | --verbose | --vulgar ...
# if [[ $@ =~ -v ]]; then
  wordList='/usr/share/dict/words';
# else
#   wordList='/usr/local/interworx/lib/dict/words';
# fi

# Set length flag to determine size of words to use
# ^^^ regex should match -l | --length
if [[ $1 =~ -l ]]; then
  wordLength=$(( (${2} - 4) / 4 )) # total length - 4 digits / four words
else
  wordLength="4,8" # any words between 5 and 8 charachters
fi

echo $(shuf -n1000 $wordList | grep -E ^[a-z]{$wordLength}$ | shuf -n4 )$(( ($RANDOM % 9000) + 1000 ))\
  | sed 's/\b\([a-zA-Z]\)/\u\1/g' | sed 's/ //g'

else
# Tried to do this with $RANDOM % MAX + MIN, and this was not random enough, got passwords with only A, B, C, words
# http://www.cyberciti.biz/faq/bash-shell-script-generating-random-numbers/ <<< Much better random using /dev/urandom
# Finally a good fallback version for use on CentOS 4,5 !
  n=0;  word=(); len=$(wc -l < $wordList)
  while [[ $n -lt 4 ]]; do
    rnd=$(( $(od -vAn -N4 -tu4 < /dev/urandom) % $len + 1 ));
    word[$n]=$(sed -n "${rnd}p" $wordList | egrep "^[a-z]{4,8}$" | sed 's:\b\(.\):\u\1:');
    if [[ -n ${word[$n]} ]]; then n=$n+1; fi;
  done;
  echo "${word[0]}${word[1]}${word[2]}${word[3]}$(( $RANDOM % 9000 + 1000 ))";
  unset n word len
fi
}
xkcd "$@"
