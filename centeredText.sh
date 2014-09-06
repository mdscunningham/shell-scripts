#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-11
# Updated: 2014-06-08
#
#
#!/bin/bash

dash(){ for ((i=1; i<=$1; i++)); do printf "-"; done; }
_center(){
if [[ -z $1 ]]; then echo "No Input Given"; return 0; fi
if [[ -n $1 && -z $2 ]]; then LEN=80; else LEN=$2; fi

dash $(( ($LEN - ${#1} - 2)/2 ));
    printf " $1 ";
dash $(( ($LEN - ${#1} - 2)/2 ));
echo
}
_center "$1" $2
