#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-12
# Updated: 2014-09-17
#
#
#!/bin/bash

#watch -n0.1 "netstat -tn | grep -E ':80.*EST|:http.*EST' | awk -F: '{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn";
#else  watch -n0.1 "ss | grep -E 'EST.*:http' | awk -F: '{print \$1,\$2}' | awk '{print \$4,\"<--\",\$6}' | column -t | sort | uniq -c | sort -rn"; fi

# if [[ -n $(ss | grep -o '::ffff:.*:http ') ]]; then
#    watch -n0.1 "ss | grep -E 'EST.*:http' | awk -F: '{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn";
# else
#    watch -n0.1 "ss | grep -E 'EST.*:http' | awk -F: '{print \$1,\$2}' | awk '{print \$4,\"<--\",\$6}' | column -t | sort | uniq -c | sort -rn";
# fi

# if [[ -n $(ss | grep -o '::ffff:') ]]; then ss | grep -E 'EST.*:http' | awk -F: '{print $4,"<--",$8}' | column -t | sort | uniq -c | sort -rn; fi
# ss | grep -E 'EST.*:http' | awk -F: '{print $1,$2}' | awk '{print $4,"<--",$6}' | column -t | sort | uniq -c | sort -rn

if [[ -n $(grep ' 4\.' /etc/redhat-release) ]]; then # CentOS 4
  if [[ $1 =~ -q ]]; then watch -n0.1 "netstat -ant | awk -F: '/ffff.*:80.*EST/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn" # Established Connections
    else watch -n0.1 "netstat -ant | awk -F: '/ffff.*:80/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn" # Verbose (EST and WAIT Connections)
  fi
else # Not CentOS 4
  if [[ -n $(ss | grep ffff) ]]; then
    if [[ $1 =~ -q ]]; then watch -n0.1 "ss -ant | awk -F: '/EST.*ffff.*:80/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn" # Established Connections
      else watch -n0.1 "ss -ant | awk -F: '/ffff.*:80/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn" # Verbose (EST and WAIT Connections)
    fi
  else
    if [[ $1 =~ -q ]]; then watch -n0.1 "ss -ant | awk -F: '/EST.*:80/ && !/\*/ {print \$1,\$2}' | awk '{print \$4,\"<--\",\$6}' | column -t | sort | uniq -c | sort -rn" # Established Connections
      else watch -n0.1 "ss -ant | awk -F: '/:80/ && !/\*/ {print \$1,\$2}' | awk '{print \$4,\"<--\",\$6}' | column -t | sort | uniq -c | sort -rn" # Verbose (EST and WAIT Connections)
    fi
  fi
fi

## CentOS 4 started acting funny and showing only IPv6 addresses and not IPv4
## Also changed default from only showing established connections, to showing
## all connections and a 'quiet' option to only shoe established connections.
