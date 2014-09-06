#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-05-22
# Updated: 2014-05-22
#
#
#!/bin/bash

for url in $(curl -s http://playerservices.streamtheworld.com/pls/CBC_R2_IET_H.pls | awk -F= '/:443/ {print $2}' | sed 's/\r/ /g'); do
if [[ $(wget --spider "$x" 2>&1 | grep -i 'audio') ]]; then
  echo -e "$url\tExists"; break;
else
  echo "$url\tMissing";
fi
done

wget -q -c -O CBCRadio2-Tonic-$(date +%Y.%m.%d).mp3 $url &; sleep 7200; kill $(pgrep wget)

# wget -q -c -O CBCRadio2-Tonic-$(date +%Y.%m.%d).mp3 http://6733.live.streamtheworld.com:443/CBC_R2_IET_H_SC &
# pgrep wget > pid.file
