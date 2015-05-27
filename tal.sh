#!/bin/bash

for x in $@; do
  echo; echo "Retrieving $x.mp3"
  wget -q audio.thisamericanlife.org/$x/$x.mp3;

  TITLE=$(ffmpeg -i $x.mp3 -f ffmetadata 2>&1 | grep title | head -1 | cut -d: -f3- | sed 's/ /./g');
  echo "Title: $TITLE .. found"

  echo "Renaming $x.mp3 to ${x}${TITLE}.mp3"
  mv $x.mp3 ${x}${TITLE}.mp3;
done; echo
