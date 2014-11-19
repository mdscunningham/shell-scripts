#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-11-09
# Updated: 2014-11-09
#
#
#!/bin/bash

# Adapted from work by Ken Howell
# Poll Interworx for Bandwidth Quota usage and print to the screen
# Shows the top 20 bandwidth users by percentage use of their quota

if [[ -z $1 ]]; then linecount=20; else linecount=$1; fi

printf "\n%-40s %11s %11s %11s\n" " Domain" "Used(%)" "Used(G)" "Total(G)"; echo $(dash 80);
nodeworx -unc Siteworx -a listBandwidthAndStorage\
 | awk '($4 !~ /999999999/) {printf "%-40s %10.3f%% %10.2fG %10.1fG\n"," "$2,(($3/1000)/$4*100),($3/1000),$4}'\
 | sort -rnk2 | head -$linecount;
echo
