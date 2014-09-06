#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-12-12
# Updated: 2013-12-15
#
#
#!/bin/bash

# check TTFB with curl
_ttfb(){
_timetofirstbyte(){ curl -so /dev/null -w "HTTP: %{http_code} Connect: %{time_connect} TTFB: %{time_starttransfer} Total time: %{time_total} Redirect URL: %{redirect_url}\n" "$1"; }
_getDomain(){ if [[ -z $1 ]]; then read -p "Domain: " D; else D="$1"; fi; }

case $1 in
  -h|--help) echo -e "\n Usage: _ttfb [mag] <domain>\n";;
      m|mag) _getDomain $2; for x in index.php robots.txt; do echo -e "\n$D/$x"; _timetofirstbyte "$D/$x"; done;;
          *) _getDomain $1; echo; _timetofirstbyte $D
esac
echo
}
_ttfb "$@"
