# Send to Address (-R)
qmqtool -R | awk '/Recipient:/ {print $3}'

# Send to Domain (-R)
qmqtool -R | awk '/Recipient:/ {print $3}' | cut -d@ -f2

# Send from Address (-R)
qmqtool -R | awk '/From:/ {print $NF}'

# Send from  Domain (-R)
qmqtool -R | awk '/Sender:/ {print $3}' | cut -d@ -f2



# Send to Address (-L)
qmqtool -L | awk '/Recipient:/ {print $3}'

# Send from Domain (-R)
qmqtool -L | awk -F@ '/Sender:/ {print $NF}'

# Send from Address (-L)
qmqtool -L | awk '/From:/ {print $NF}'

# Send from Domain (-L)
qmqtool -L | awk -F@ '/From:/ {print $NF}'


