#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2015-03-09
# Updated: 2015-03-10
#
#
#!/bin/bash

### Combine .ts files using ffmpeg ###
# http://superuser.com/questions/692990/use-ffmpeg-copy-codec-to-combine-ts-files-into-a-single-mp4
#
# cat segment1_0_av.ts segment2_0_av.ts segment3_0_av.ts > all.ts
# ffmpeg -i all.ts -acodec copy -vcodec copy all.mp4
#
###

if [[ $1 =~ "-q" ]]; then quiet=1; shift; else quiet=0; fi

for ep in $@; do

  mkdir $ep; cd $ep;
  echo "Downloading pieces for $ep"

  ## Download playlist file
  # wget -q http://stream.thisamericanlife.org/${ep}/stream/${ep}_64k.m3u8;
  ## not necessary so commmented out

  ## Read playlist file
  for x in $(curl -s http://stream.thisamericanlife.org/${ep}/stream/${ep}_64k.m3u8 | grep '^[^#]'); do
    if [[ $quiet != 1 ]]; then echo "Retrieving Part: $x"; fi
    wget -q http://stream.thisamericanlife.org/${ep}/stream/$x;
  done;

  ## convert .ts stream segments to single .mp4
  cat *.ts > $ep.ts
  ffmpeg -i $ep.ts -bsf:a aac_adtstoasc -acodec copy -vcodec copy $ep.mp4
  mv $ep.mp4 ../; cd -; rm -r $ep/

done
