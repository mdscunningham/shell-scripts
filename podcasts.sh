#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-05-30
# Updated: 2014-07-19
#
#
#!/bin/bash

#####
#
#  Podcast downloading script
#  Author: Mark David Scott Cunningham
#  Last Update: 2014.07.19
#
#####

echo -e "\nList of RSS Feeds:\n"
RSS=(
http://theadamcarollashow.libsyn.com/rss
http://alisonrosen.com/category/podcast/feed/
http://files.libertyfund.org/econtalk/EconTalk.xml
http://feeds.feedburner.com/PennSundaySchool
http://www.causticsodapodcast.com/feed/podcast/
http://www.theskepticsguide.org/feed
http://skeptoid.com/podcast.xml
http://www.quackcast.com/spodcasts/files/mp3rss.xml
http://feeds.twit.tv/twit
http://feeds.twit.tv/floss
http://www.npr.org/rss/podcast.php?id=35
http://www.theovernightscape.com/feed
)

# Print out the list of feeds in the array above.
for (( i=0 ; i<${#RSS[@]} ; i++ )); do echo "[$i] ${RSS[$i]}"; done | column -t;
echo -e "\nEnter (q)uit to exit.";
read -p "Which podcast in the list would you like check? [0-9]: " x;

# Parse the feeds to print out the episode release dates, titles, and file names.
if [[ $x != q* ]]; then
  clear;

# If feed is Adam Carolla Show
  if [[ ${RSS[$x]} =~ "carolla" ]]; then
    URL=($(wget -q -O - ${RSS[$x]} | egrep -io 'url=.*\.mp3' | head -15 | cut -d\" -f2 ));
    PUB=($(wget -q -O - ${RSS[$x]} | egrep -io 'pubDate.*pubDate' | head -15 | cut -d\> -f2 | cut -d\< -f1 | awk '{print $4"-"$3"-"$2}' ));
    NAM=($(wget -q -O - ${RSS[$x]} | egrep -io 'title.*/title' | head -17 | sed s/' '/./g | cut -d\> -f2 | cut -d\< -f1 ))

# If feed is minified feedburner
  elif [[ ${RSS[$x]} =~ "feedburner"  ]]; then
    URL=($(wget -q -O - ${RSS[$x]} | sed 's/></>\n</g' | egrep -io 'url.*http.*\.mp3' | head -15 | cut -d\" -f2 ));
    PUB=($(wget -q -O - ${RSS[$x]} | sed 's/></>\n</g' | egrep -io 'pubDate.*pubDate' | head -15 | cut -d\> -f2 | cut -d\< -f1 | awk '{print $4"-"$3"-"$2}' ));
    NAM=($(wget -q -O - ${RSS[$x]} | sed 's/></>\n</g' | egrep -io 'title.*/title' | head -17 | sed s/' '/./g | cut -d\> -f2 | cut -d\< -f1 ))

# If feed is gzip compressed
  elif [[ $(wget -q -O feed.tmp ${RSS[$x]} && file -b feed.tmp && rm feed.tmp) =~ "gzip" ]]; then
    URL=($(wget -q -O - ${RSS[$x]} | gunzip -c | egrep -io 'url.*http.*\.mp3' | uniq | head -15 | cut -d\" -f2 ));
    PUB=($(wget -q -O - ${RSS[$x]} | gunzip -c | egrep -io 'pubDate.*pubDate' | head -15 | cut -d\> -f2 | cut -d\< -f1 | awk '{print $4"-"$3"-"$2}' ));
    NAM=($(wget -q -O - ${RSS[$x]} | gunzip -c | egrep -io 'title.*/title' | head -17 | sed s/' '/./g | cut -d\> -f2 | cut -d\< -f1 ))

# Everything else
  else
    URL=($(wget -q -O - ${RSS[$x]} | egrep -io 'url.*http.*\.mp3' | uniq | head -15 | cut -d\" -f2 ));
    PUB=($(wget -q -O - ${RSS[$x]} | egrep -io 'pubDate.*pubDate' | head -15 | cut -d\> -f2 | cut -d\< -f1 | awk '{print $4"-"$3"-"$2}' ));
    NAM=($(wget -q -O - ${RSS[$x]} | egrep -io 'title.*/title' | head -17 | sed s/' '/./g | cut -d\> -f2 | cut -d\< -f1 ))
  fi

# Try to remove This week in Rage from Carolla feed. Not working yet.
  for ((i=0;i<${#NAM[@]};i++)); do
	if [[ ${RSS[$x]} =~ "carolla" && ${NAM[$i]} =~ Week\.in\.Rage ]]; then FLAG=$i; fi
  done

# Print the list of episodes from the feed.
  echo -e "\nList of episodes in ${RSS[$x]}:\n"
  for (( i=0 ; i<${#URL[@]} ; i++ )); do
    if [[ ${RSS[$x]} != *econtalk* ]]; then
	echo "[$i] ${PUB[$i]} $(echo ${URL[$i]} | awk -F\/ '{print $NF}') ${NAM[($i+2)]}";
    elif [[ $i != $FLAG ]]; then
        echo "[$i] ${PUB[$i]} $(echo ${URL[$i]} | awk -F\/ '{print $NF}') ${NAM[($i+1)]}"
    fi
  done | column -t;

  echo -e "\nEnter (q)uit to exit.";
  read -p "Which episode in the list would you like to download? [0-9]: " n;

# Download the requested files
  if [[ $n != q* ]]; then
    for x in $n; do wget -c -O $(echo ${URL[$x]} | awk -F\/ '{print $NF}') ${URL[$x]}; done;
  fi;

fi;
