#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-12
# Updated: 2014-07-25
#
#
#!/bin/bash

#watch -n0.1 "netstat -tn | grep -E ':80.*EST|:http.*EST' | awk -F: '{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn";
#else  watch -n0.1 "ss | grep -E 'EST.*:http' | awk -F: '{print \$1,\$2}' | awk '{print \$4,\"<--\",\$6}' | column -t | sort | uniq -c | sort -rn"; fi

if [[ -n $(ss | grep -o '::ffff:.*:http ') ]]; then
    watch -n0.1 "ss | grep -E 'EST.*:http' | awk -F: '{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn";
else
    watch -n0.1 "ss | grep -E 'EST.*:http' | awk -F: '{print \$1,\$2}' | awk '{print \$4,\"<--\",\$6}' | column -t | sort | uniq -c | sort -rn";
fi

# if [[ -n $(ss | grep -o '::ffff:') ]]; then ss | grep -E 'EST.*:http' | awk -F: '{print $4,"<--",$8}' | column -t | sort | uniq -c | sort -rn; fi
# ss | grep -E 'EST.*:http' | awk -F: '{print $1,$2}' | awk '{print $4,"<--",$6}' | column -t | sort | uniq -c | sort -rn
