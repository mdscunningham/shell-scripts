#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2015-12-21
# Updated: 2016-01-04
#
# Purpose: Find accounts full of symlinks (indicating symlink hacks)
#

#Utility functions
dash(){ for ((i=1;i<=$1;i++)); do printf $2; done; }

# Set threshold for reporting and investigating a user dir
if [[ -z $1 ]]; then min=0; else min=$1; fi
if [[ $@ =~ -h ]]; then echo -e "\n  Usage: $0 [min]\n    min ... Minimum # of symlinks to log\n"; exit; fi

# Initialize and count the number of /home/dirs
i=0; t=$(ls -d /home*/*/public_html/ | wc -l)
tmplog="/tmp/symlinkhunter.tmp.log"
log="/root/symlinkhunter_$(date +%Y-%m-%d_%H%M).log"

# Check last runs of EA to see if Symlink Protection is enabled
echo -e "\n$(dash 80 -)\n  Checking for Symlink Protection\n$(dash 60 -)\n" | tee -a $log;
for logfile in /var/cpanel/easy/apache/runlog/build.*; do
  echo -n "$(grep SymlinkProtection $logfile | sed 's/1/Enabled/g;s/0/Disabled/g') :: ";
  stat $logfile | awk '/^Modify/ {print $2}';
done | tail -5 | tee -a $log;

# Start Symlink Hunting
echo -e "\n$(dash 80 -)\n  Searching /home/user/public_html for Symlinks\n$(dash 60 -)\n" | tee -a $log;
for homedir in /home*/*/public_html/; do
  i=$(($i+1));

  # Print scanning progress
  username="$(echo $homedir | cut -d/ -f3)"
  printf "%-80s\r" "Scanning :: [$i/$t] $username ..."

  # Actually search symlinks and count them
  find $homedir -type l -print > $tmplog
  count=$(wc -l < $tmplog)

  # Only print the results above the $min threshold
  if [[ $count -gt $min ]]; then
    # Count per subdirectory (verbose output sent to log)
    #for subdir in $(cat $tmplog); do echo ${subdir%/*}; done\
    #  | awk '{freq[$0]++} END {for (x in freq) {printf "%8s :: %s\n",freq[x],x}}' | tee -a $log;

    awk -F/ '$NF=""; {freq[$0]++} END {for (x in freq) {printf "%8s ::%s\n",freq[x],x}}' $tmplog\
      | sed 's/\b /\//g; s/\/:/ :/g; s/ home/ \/home/g' >> $log;

    printf "%8s :: %-80s\n" "$count" "$homedir";
    echo >> $log;
  else
    printf "%-80s\r" " ";
  fi
done;
echo -e "\n$(dash 80 -)\n" | tee -a $log;
echo -e "Verbose logfile saved to: $log\n\n$(dash 80 -)\n"

# Final log and variable cleanup
rm -f $tmplog
unset tmplog log username homedir count
