## Backup Server lookup (mmkinst)

old_date=""
old_ip=""
while read -r line; do
    date="$(echo $line | awk '{print $1}' | sed -r 's/(.{4})-(.{3})-(.{2})/\3-\2-\1/')"

    # some servers communicate over an internal network so we convert the
    # internal ip address to the external IP address using sed
    #
    #  UK: 10.17.x.x  -> 178.17.x.x
    #  AU: 10.1.x.x   -> 103.1.x.x
    # MIA: 10.240.x.x -> 192.240.x.x

    ip="$(echo $line | awk '{print $3}' | sed 's/10\.17\./178\.17\./;s/10\.1\./103\.1\./;s/10\.240\./192\.240\./')"

    # 31 days = 2678400 seconds
    if [[ $((($(date '+%s') - $(date -d "$date" '+%s')))) -le 2678400 ]]; then
	#echo "$ip $date"

	# initial/empty state
	if [[ -z $old_ip ]]; then
	    old_ip=$ip
	    old_date=$date
	# ip has changed state
	elif [[ $old_ip != $ip ]]; then
	    rdns="$(dig +short -x $ip | sed 's/.$//')"
	    if [[ $rdns =~ "^r1bs" ]]; then
		echo "https://${rdns}:8001 $old_date to $date"
	    else
		echo "https://${ip}:8001 $old_date to $date"
	    fi
	    old_ip=$ip
	    old_date=$date

	fi

    fi
done <<< "$(awk -F, '/server.allow/ {print $1, $6}' /usr/sbin/r1soft/log/cdp.log |awk '{print $1, $2, $NF}' | sed 's|\x27/usr/sbin/r1soft/conf/server.allow/||;s/^\[//;s/\x27$//' | tr -d ']')"

# end state
rdns="$(dig +short -x $old_ip | sed 's/.$//')"
if [[ $rdns =~ "^r1bs" ]]; then
    echo "https://${rdns}:8001 $old_date to NOW"
else
    echo "https://${old_ip}:8001 $old_date to NOW"
fi
