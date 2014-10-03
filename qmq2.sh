# Send to Address (-R)
qmqtool -R | awk '/Recipient:/ {print $3}'
qmqtool -R | awk '/Recipient:/ {freq[$3]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'

# Send to Domain (-R)
qmqtool -R | awk '/Recipient:/ {print $3}' | cut -d@ -f2

# Send from Address (-R)
qmqtool -R | awk '/From:/ {print $NF}'
qmqtool -R | awk '/From:/ {freq[$NF]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}' | sed 's/<//g;s/>//g'

# Send from  Domain (-R)
qmqtool -R | awk '/Sender:/ {print $3}' | cut -d@ -f2

# Find mailer scripts for all mail in the queue
for x in $(qmqtool -f X-PHP-Script | sed 's/,/ /g'); do qmqtool -v $x | grep X-PHP-Script:; done
for x in $(qmqtool -f X-PHP-Script | sed 's/,/ /g'); do qmqtool -v $x | awk '/X-PHP-Script:/ {print $2}'; done | sort | uniq -c | sort -rn

# Send to Address (-L)
qmqtool -L | awk '/Recipient:/ {print $3}'
qmqtool -L | awk '/Recipient:/ {freq[$3]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'

# Send from Domain (-R)
qmqtool -L | awk -F@ '/Sender:/ {print $NF}'

# Send from Address (-L)
qmqtool -L | awk '/From:/ {print $NF}'
qmqtool -L | awk '/From:/ {freq[$NF]++} END {for (x in freq) {printf "%8s %s\n",freq[x],x}}'

# Send from Domain (-L)
qmqtool -L | awk -F@ '/From:/ {print $NF}'


