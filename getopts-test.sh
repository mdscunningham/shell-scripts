# http://inchoo.net/dev-talk/tools/git-deployment/17566/

## OMG OMG OMG!
## http://stackoverflow.com/questions/16654607/using-getopts-inside-a-bash-function

#!/bin/bash

getopts-test(){
local OPTIND
while getopts ab:c:d: option
do
        case "${option}"
        in
                a) echo "-a flag was set";;
        	b) echo "-b flag was set to ${OPTARG}";;
                c) C=${OPTARG};;
                d) D=${OPTARG};;
        esac
done
#shift $((OPTIND-1))

echo "C: $C"
echo "D: $D"
unset A B C D;
}

getopts-test "$@"
