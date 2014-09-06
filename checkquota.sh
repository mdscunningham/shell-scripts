#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-14
# Updated: 2014-03-31
#
#
#!/bin/bash

_dash(){ for ((i=1; i<=$1; i++)); do printf "-"; done; }
_getusr(){ echo "$(pwd -P | cut -d/ -f4)"; }
_checkquota(){
_quotaheader(){ echo; printf "%8s %12s %14s %14s\n" "Username" "Used(%)" "Used(G)" "Total(G)"; _dash 51; }
_quotausage(){ printf "\n%-10s" "$1"; quota -g $1 2> /dev/null | tail -1 | awk '{printf "%10.3f%%  %10.3f GB  %10.3f GB",($2/$3*100),($2/1024/1024),($3/1024/1024)}' 2> /dev/null; }
case $1 in
  -u|--user   ) _quotaheader; shift; if [[ -z "$@" ]]; then _quotausage $(_getusr); else for x in "$@"; do _quotausage $x; done; fi; echo; echo ;;
  -a|--all    ) _quotaheader; for x in $(_laccounts); do _quotausage $x; done | sort; echo ;;
  -l|--large  ) _quotaheader; echo; for x in $(_laccounts); do _quotausage $x; done | sort | egrep '[8,9][0-9]\..*%|1[0-9]{2}\..*%'; echo ;;
  -h|--help|* ) echo -e "\n Usage: _checkquota [--user <username>|--all|--large]\n   -u|--user user1 [user2..] .. Show quota usage for a user or list of users \n   -a|--all ................... List quota usage for all users\n   -l|--large ................. List all users at or above 80% of quota\n";;
esac
}
_checkquota "$@"
