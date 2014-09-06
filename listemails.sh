for x in /home/$(getusr)/var/*/mail/*/Maildir/; do echo $(echo $x | awk -F/ '{print $7"@"$5}'); done
