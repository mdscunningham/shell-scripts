#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-07
# Updated: 2014-08-23
#
#
#!/bin/bash

bumpquota(){
if [[ -z $@ || $1 =~ -h ]]; then echo -e "\n Usage: bumpquota <username> <newquota>\n  Note: <username> can be '.' to get user from PWD\n"; return 0;
elif [[ $1 =~ ^[a-z].*$ ]]; then U=$1; shift;
elif [[ $1 == '.' ]];then U=$(pwd | sed 's:^/chroot::' | cut -d/ -f3); shift; fi
newQuota=$1; primaryDomain=$(~iworx/bin/listaccounts.pex | grep $U | awk '{print $2}')
nodeworx -u -n -c Siteworx -a edit --domain $primaryDomain --OPT_STORAGE $newQuota &&
echo -e "\nDisk Quota for $U has been set to $newQuota MB\n"
}
bumpquota "$@"
