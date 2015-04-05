#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-12
# Updated: 2015-04-02
#
#
#!/bin/bash

# watch -n0.1 "netstat -tn | grep -E ':80.*EST|:http.*EST' | awk -F: '{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn";
# else  watch -n0.1 "ss | grep -E 'EST.*:http' | awk -F: '{print \$1,\$2}' | awk '{print \$4,\"<--\",\$6}' | column -t | sort | uniq -c | sort -rn"; fi

# if [[ -n $(ss | grep -o '::ffff:.*:http ') ]]; then
#    watch -n0.1 "ss | grep -E 'EST.*:http' | awk -F: '{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn";
# else
#    watch -n0.1 "ss | grep -E 'EST.*:http' | awk -F: '{print \$1,\$2}' | awk '{print \$4,\"<--\",\$6}' | column -t | sort | uniq -c | sort -rn";
# fi

# if [[ -n $(ss | grep -o '::ffff:') ]]; then ss | grep -E 'EST.*:http' | awk -F: '{print $4,"<--",$8}' | column -t | sort | uniq -c | sort -rn; fi
# ss | grep -E 'EST.*:http' | awk -F: '{print $1,$2}' | awk '{print $4,"<--",$6}' | column -t | sort | uniq -c | sort -rn

if [[ -n $(grep ' 4\.' /etc/redhat-release) ]]; then # CentOS 4
  if [[ $1 =~ -q ]]; then # Established Connections
    watch -n0.1 "netstat -ant | awk -F: '/ffff.*:80.*EST/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn"
  else # Verbose (EST and WAIT Connections)
    watch -n0.1 "netstat -ant | awk -F: '/ffff.*:80/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn"
  fi
else # Not CentOS 4
  if [[ -n "$(ss -ant | grep ffff.*:80)" ]]; then # Pseudo IPv6
    if [[ $1 =~ -q ]]; then # Established Connections
      watch -n0.1 "ss -ant | awk -F: '/EST.*ffff.*:80/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn"
    else # Verbose (EST and WAIT Connections)
      watch -n0.1 "ss -ant | awk -F: '/ffff.*:80/{print \$4,\"<--\",\$8}' | column -t | sort | uniq -c | sort -rn"
    fi
  else # IPv4
    if [[ $1 =~ -q ]]; then # Established Connections
      watch -n0.1 "ss -ant | awk '/EST/ && (\$4 ~ /:80/) {print \$4,\"<--\",\$5}' | sed 's/:80//g; s/:.*$//g' | column -t | sort | uniq -c | sort -rn"
    else # Verbose (EST and WAIT Connections)
      watch -n0.1 "ss -ant | awk '(\$4 ~ /:80/) {print \$4,\"<--\",\$5}' | sed 's/:80//g; s/:.*$//g' | column -t | sort | uniq -c | sort -rn"
    fi
  fi
fi

## CentOS 4 started acting funny and showing only IPv6 addresses and not IPv4
## Also changed default from only showing established connections, to showing
## all connections and a 'quiet' option to only shoe established connections.
