#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-02-01
# Updated: 2014-03-10
#
#
#!/bin/bash

source /etc/nexcess/bash_functions.sh
_mdz(){
test -z "$1" && echo -e "\nUsage: mdz database [-0..-9|--fast|--best]\n" && return;
dbsize=$(m -e"select SUM(Data_length) FROM information_schema.TABLES WHERE TABLE_SCHEMA = \"$1\";" | tail -n1);
echo; if [ -x /usr/bin/pigz ]; then GZIP='/usr/bin/pigz'; else GZIP='/bin/gzip'; fi;
case $2 in
    -b|-9|--best) LEVEL='--best';;
    -f|-0|--fast) LEVEL='--fast';;
    -1|-2|-3|-4|-5|-6|-7|-8) LEVEL=$2;;
    *) LEVEL='--best';;
esac

if [ -x /usr/bin/pv ]; then
mysqldump --opt --skip-lock-tables \
    -u"$(grep ^rootdsn= /usr/local/interworx/iworx.ini | cut -d/ -f3 | cut -d: -f1)" \
    -p"$(grep ^rootdsn= /home/interworx/iworx.ini | cut -d: -f3 | cut -d\@ -f1)" $1 \
    | pv -s$dbsize -N $1 \
    | $GZIP $LEVEL > "$1-$(date --iso-8601=minute).sql.gz"
else
mysqldump --opt --skip-lock-tables \
    -u"$(grep ^rootdsn= /usr/local/interworx/iworx.ini | cut -d/ -f3 | cut -d: -f1)" \
    -p"$(grep ^rootdsn= /home/interworx/iworx.ini | cut -d: -f3 | cut -d\@ -f1)" $1 \
    | $GZIP $LEVEL > "$1-$(date --iso-8601=minute).sql.gz"
fi; echo
}
_mdz "$@"
