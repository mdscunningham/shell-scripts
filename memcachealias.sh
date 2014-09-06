#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-03-12
# Updated: 2014-07-28
#
#
#!/bin/bash

# grep -Eo '\/var.*_cache\.sock' $(find $SITEPATH -name local.xml -print | grep '/app/etc/local.xml')
# grep -Eo '\/var.*_sessions\.sock' $(find $SITEPATH -name local.xml -print | grep '/app/etc/local.xml')

getusr(){ echo "$(pwd -P | cut -d/ -f4)"; }

if [[ -z $1 ]]; then
    echo -e "\n Usage: memcachealias [sitepath] [name]\n"

elif [[ -f $1/app/etc/local.xml ]]; then
    if [[ -n $2 ]]; then NAME="_$2"; else NAME='_memcached'; fi
    U=$(getusr);
    CACHE_SOCKET=$(grep -Eo '\/var.*_cache\.sock' $1/app/etc/local.xml | head -1)
    SESSIONS_SOCKET=$(grep -Eo '\/var.*_sessions\.sock' $1/app/etc/local.xml | head -1)

    echo; for x in flush_all stats; do
        echo "Adding ${x}_memcached to /home/$U/.bashrc ... ";
        if [[ -n $SESSIONS_SOCKET ]]; then
	    sudo -u $U echo -e "\n${x}${NAME}_cache(){ echo $x \$@ | nc -U $CACHE_SOCKET; }" >> /home/$U/.bashrc;
	    sudo -u $U echo -e "\n${x}${NAME}_sessions(){ echo $x \$@ | nc -U $SESSIONS_SOCKET; }" >> /home/$U/.bashrc;
	else
	    sudo -u $U echo -e "\n${x}${NAME}_cache(){ echo $x \$@ | nc -U $CACHE_SOCKET; }" >> /home/$U/.bashrc;
	fi
    done; echo;

    echo "Adding bash completion for stats functions"

    if [[ -n $SESSIONS_SOCKET ]]; then
    	sudo -u $U echo -e "\ncomplete -W 'items slabs detail settings sizes reset' stats${NAME}_cache" >> /home/$U/.bashrc
    	sudo -u $U echo -e "\ncomplete -W 'items slabs detail settings sizes reset' stats${NAME}_sessions" >> /home/$U/.bashrc
    else
    	sudo -u $U echo -e "\ncomplete -W 'items slabs detail settings sizes reset' stats${NAME}_cache" >> /home/$U/.bashrc
    fi

    echo "Adding $U to the (nc) group";
    usermod -a -G nc $U; echo;
else
    echo "\n Could not find local.xml file in $1\n"
fi;
