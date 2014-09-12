accountips () 
{ 
    echo;
    DIR=$PWD;
    cd /home/$(getusr);
    FORMAT=" %-15s  %-15s  %3s  %3s  %3s  %s\n";
    HIGHLIGHT="${BRIGHT}${RED} %-15s  %-15s  %3s  %3s  %3s  %s${NORMAL}\n";
    printf "$FORMAT" " ServerIP" " LiveIP" "SSL" "FPM" "TMP" " DomainName";
    printf "$FORMAT" "$(dash 15)" "$(dash 15)" "---" "---" "---" "$(dash 39)";
    for x in */html;
    do
        D=$(echo $x | cut -d/ -f1);
	vhost="/etc/httpd/conf.d/vhost_$D.conf"
        L=$(dig +tries=1 +time=3 +short $1$D | grep -v \; | head -n1);
        I=$(awk '/.irtual.ost/ {print $2}' $vhost 2> /dev/null | head -n1 | cut -d: -f1);
        S=$(if grep -q ':443' $vhost &> /dev/null; then echo SSL; fi)
	F=$(if grep -q 'MAGE_RUN' $vhost &> /dev/null; then echo FIX; fi)
	T=$(if [[ -n $(awk '/.irtual.ost/ {print $3}' $vhost) ]]; then echo FIX; fi)
        if [[ $I != $L ]]; then
            printf "$HIGHLIGHT" "$I" "$L" "${S:- - }" "${F:- - }" "${T:- - }" "$1$D";
        else
            printf "$FORMAT" "$I" "$L" "${S:- - }" "${F:- - }" "${T:- - }" "$1$D";
        fi;
    done;
    echo;
    cd $DIR
}
accountips
