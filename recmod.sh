#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-02
# Updated: 2014-08-09
#
#
#!/bin/bash

recmod(){
if [[ -z "$@" || "$1" == "-h" || "$1" == "--help" ]];
  then echo -e "\n Usage: recmod [-p <path>] [days|{sequence}]\n"; return 0;
elif [[ "$1" == "-p" ]]; then DIR="$2"; shift; shift;
else DIR="."; fi;

for x in "$@"; do
  echo "Files modified within $x day(s) or $((${x}*24)) hours ago";
  find $DIR -type f -mtime $((${x}-1)) -exec ls -lath {} \; | grep -Ev '(var|log|media|tmp|jpg|png|gif)' | column -t; echo;
done

# # # # #
# Originally was printing the files names to xargs, this did not work b/c if it found no files, it would just ls the directory
# Switched this to printing to a variable, and then checking if the variable was non-zero-length, but this was cludgy
#
# Not sure why I didn't think to use the -exec function within find earlier, but it appears that this is working fine now.
# ^^^ This may not have been ideal at first b/c all the file info will not line up, but a simple 'column -t' does the trick.
# # # # #

}
recmod "$@"
