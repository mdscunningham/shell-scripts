#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-07-12
# Updated: 2014-07-12
#
#
#!/bin/bash

    if [[ "$@" =~ "-h" ]]; then
        echo -e "\n Usage: diskhogs [maxdepth] [-d]\n";
        return 0;
    fi;
    if [[ $@ =~ [0-9]{1,} ]]; then
        DEPTH=$(echo $@ | grep -Eo '[0-9]{1,}');
    else
        DEPTH=3;
    fi;
    echo -e "\n---------- Large Directories $(dash 51)";
    du -h --max-depth $DEPTH | grep -E '[0-9]G|[0-9]{3}M';

    if [[ ! $@ =~ '-d' ]]; then
    echo -e "\n---------- Large Files $(dash 57)";
    find . -type f -size +100M -group $(getusr) -exec ls -lah {} \;;
    fi;

    echo -e "\n---------- Large Databases $(dash 53)";
    du -sh /var/lib/mysql/$(getusr)_* | grep -E '[0-9]G|[0-9]{3}M';
    echo
