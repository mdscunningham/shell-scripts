complete -W 'raddr rdom rsend laddr ldom lsend lsub rsub script' QMQ
QMQ(){
case $1 in

raddr ) # Send to Address (-R)
# qmqtool -R | awk '/Recipient:/ {print $3}'
qmqtool -R | awk '/Recipient:/ {freq[$3]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn ;;

rdom ) # Send to Domain (-R)
qmqtool -R | awk '/Recipient:/ {print $3}' | cut -d@ -f2 | sort | uniq -c | sort -rn ;;

rsend ) # Send from Address (-R)
# qmqtool -R | awk '/From:/ {print $NF}'
qmqtool -R | awk '/From:/ {freq[$NF]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sed 's/<//g;s/>//g' | sort -rn ;;

# rsdom ) # Send from  Domain (-R)
# qmqtool -R | awk -F@ '/From:/ {print $NF}' | sort | uniq -c | sort -rn ;;

laddr ) # Send to Address (-L)
# qmqtool -L | awk '/Recipient:/ {print $3}'
qmqtool -L | awk '/Recipient:/ {freq[$3]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn ;;

ldom ) # Send to Domain (-L)
qmqtool -L | awk '/Recipient:/ {print $3}' | cut -d@ -f2 | sort | uniq -c | sort -rn ;;

lsend ) # Send from Address (-L)
# qmqtool -L | awk '/From:/ {print $NF}'
qmqtool -L | awk '/From:/ {freq[$NF]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sort -rn ;;

# lsdom ) # Send from Domain (-L)
# qmqtool -L | awk -F@ '/From:/ {print $NF}' | sort | uniq -c | sort -rn ;;

lsub ) # Subject in Local
qmqtool -L | awk '/Subject:/ {$1=""; print}' | sort | uniq -c | sort -rn ;;

rsub ) # Subject in Remote
qmqtool -R | awk '/Subject:/ {$1=""; print}' | sort | uniq -c | sort -rn ;;

script ) # Find mailer scripts for all mail in the queue
# for x in $(qmqtool -f X-PHP | sed 's/,/ /g'); do qmqtool -v $x | grep X-PHP; done
for x in $(qmqtool -f X-PHP | sed 's/,/ /g'); do qmqtool -v $x | awk '/X-PHP/ {print $2}'; done | sort | uniq -c | sort -rn ;;

esac
}
QMQ "$@"
