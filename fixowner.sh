#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-08
# Updated: 2014-04-27
#
#
#!/bin/bash

_fixowner(){
U=$(getusr)
if [[ -z $2 ]]; then P='.'; else P=$2; fi
case $1 in
    -u|--user) owner="$U:$U" ;;
    -a|--apache) owner="apache:$U" ;;
    -r|--root) owner="root:root" ;;
    *|-h|--help) echo -e "\n Usage: fixowner [option] [path]\n    -u | --user ..... Change ownership to $U:$U\n    -a | --apache ... Change ownership to apache:$U\n    -r | --root ..... Change ownership to root:root\n    -h | --help ..... Show this help output\n"; return 0 ;;
esac
chown -R $owner $P && echo -e "\n Files owned to $owner\n"
}
_fixowner "$@"
