for x in $(~iworx/bin/listaccounts.pex | awk '{print $1}'); do
find /home/mysql/${x}* -maxdepth 0 -type d -group mysql -exec du -s {} \; 2>/dev/null | sed 's:/home/mysql/::;s:_: :' | awk '{tx[$2]+=$1} END {for (x in tx) {printf "%10.3f M %8s\n",(tx[x]/1024000),x}}';
done
