#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-01-30
# Updated: 2014-03-02
#
#
#!/bin/bash

getusr(){ U=$(pwd | cut -d/ -f3); if [[ $U == "home" ]]; then U=$(pwd | cut -d/ -f4); fi; echo $U; }
archive(){
  #Check for proper input
    echo; if [[ -z "$@" ]]; then echo -e " Usage: archive <target>\n"; return 0; fi

  #Generate file name from user.server.target
    FILE=$(getusr).$(hostname | cut -d. -f1)--$(echo "$1" | sed s/"\/"/"-"/g)-$(date +%Y.%m.%d-%H.%M).tgz;

  #Calculate data size before compression
    SIZE=$(du -sb "$1" | cut -f1)
    SIZEM=$(echo "scale=3;$SIZE/1024/1024" | bc)
    echo "Compressing ${SIZEM}M ... please be patient."

  #Select compression method
    if [[ -f /usr/bin/pv && -f /usr/bin/pigz ]]; then
        tar -cf - "$1" | pv -s $SIZE | pigz -c > $FILE;
    elif [[ -f /usr/bin/pv ]]; then
        tar -cf - "$1" | pv -s $SIZE | gzip -c > $FILE;
    else
        echo "No idea how long this will take ..."; tar -zcf  $FILE "$1";
    fi && echo -e "\nArchive created successfully!\n\n$PWD/$FILE\n";

  #Set file ownership
    if [[ -f $FILE ]]; then read -p "Chown file to [r]oot or [u]ser? [r/u]: " yn;
        if [[ $yn = "r" ]]; then U='root'; else U=$(getusr); fi
        chown $U. $FILE && echo -e "Archive owned to $U\n";
    fi
}
archive "$@"

