accountips () 
{ 
    echo;
    DIR=$PWD;
    cd /home/$(getusr);
    FORMAT=" %-15s  %-15s  %-3s  %-3s  %s\n";
    HIGHLIGHT="${BRIGHT}${RED} %-15s  %-15s  %-3s  %-3s  %s${NORMAL}\n";
    printf "$FORMAT" " ServerIP" " LiveIP" "SSL" "FPM" " DomainName";
    printf "$FORMAT" "$(dash 15)" "$(dash 15)" "---" "---" "$(dash 39)";
    for x in */html;
    do
        D=$(echo $x | cut -d/ -f1);
        L=$(dig +tries=1 +time=3 +short $1$D | grep -v \; | head -n1);
        I=$(grep -i virtualhost /etc/httpd/conf.d/vhost_$D.conf 2> /dev/null | head -n1 | awk '{print $2}' | cut -d: -f1);
        S=$(if grep -q ':443' /etc/httpd/conf.d/vhost_$D.conf &> /dev/null; then echo SSL; fi)
	F=$(if grep -q 'MAGE_RUN' /etc/httpd/conf.d/vhost_$D.conf &> /dev/null; then echo FIX; fi)
        if [[ $I != $L ]]; then
            printf "$HIGHLIGHT" "$I" "$L" "${S:- - }" "${F:- - }" "$1$D";
        else
            printf "$FORMAT" "$I" "$L" "${S:- - }" "${F:- - }" "$1$D";
        fi;
    done;
    echo;
    cd $DIR
}
accountips
