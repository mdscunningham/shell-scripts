#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-02-08
# Updated: 2016-01-27
#
#
#!/bin/bash

# http://doc.coker.com.au/internet/how-to-debug-smtp-with-tlsssl-and-auth/	(SMTP-ssl)
# http://www.anta.net/misc/telnet-troubleshooting/smtp.shtml			(SMTP-telnet)
# http://www.anta.net/misc/telnet-troubleshooting/imap.shtml			(IMAP-ssl)
# http://www.anta.net/misc/telnet-troubleshooting/pop.shtml			(POP3-ssl)

if [[ -n $1 && $1 != "-h" ]]; then
  if [[ -z $2 ]]; then read -p "Hostname: " host; else host=$2; fi
  if [[ -z $3 ]]; then read -p "Email Address: " emailaddr; else emailaddr=$3; fi
  if [[ -z $4 ]]; then read -p "Password: " emailpass; else emailpass=$4; fi
fi

echo
case $1 in
  -i|--imap   )
	#echo -e "\n  1) [tag] LOGIN <address> <password>\n  2) [tag] LIST \"\" \"*\"\n  3) [tag] SELECT INBOX\n  4) [tag] FETCH 1 BODY[]\n  5) [tag] LOGOUT\n"
	echo | openssl s_client -connect $host:993 -cipher "EDH" 2>/dev/null | grep "Server Temp Key"; echo
	expect -c "
          spawn openssl s_client -connect $host:993 -quiet
	expect OK
	  send \"tag LOGIN ${emailaddr} ${emailpass}\r\"
	expect OK
	  send \"tag SELECT INBOX\r\"
	expect OK
	  send \"tag FETCH 1 BODY\[\]\r\"
	expect completed
	  send \"tag LOGOUT\r\"
	interact
        ";;
  -p|--pop    )
	#echo -e "\n  1) USER <address>\n  2) PASS <password>\n  3) STAT\n  4) LIST\n  5) RETR 1\n  6) QUIT\n";
	echo | openssl s_client -connect $host:995 -cipher "EDH" 2>/dev/null | grep "Server Temp Key"; echo
	expect -c "
	  spawn openssl s_client -connect $host:995 -quiet
	expect OK
	  send \"USER ${emailaddr}\r\"
	expect OK
	  send \"PASS ${emailpass}\r\"
        expect OK
          send \"STAT\r\"
	expect OK
	  send \"RETR 1\r\"
        expect .
          send \"QUIT\r\"
	interact
        ";;
  -s|--smtp   )
	#echo -e "\n  1) HELO $host\n  2) MAIL FROM:<address>\n  3) RCPT TO:<address>\n  4) DATA\n  5) .\n  6) QUIT\n";
	echo | openssl s_client -starttls smtp -connect $host:587 -cipher "EDH" 2>/dev/null | grep "Server Temp Key"; echo
	newuser=$(echo -n $emailaddr | base64)
	newpass=$(echo -n $emailpass | base64)
	expect -c "
	  spawn openssl s_client -starttls smtp -connect $host:587 -quiet
	expect 250
	  send \"EHLO $host\r\"
	expect 250
	  send \"AUTH LOGIN\r\"
	expect 334
	  send \"$newuser\r\"
	expect 334
	  send \"$newpass\r\"
	expect 235
	  send \"QUIT\r\"
	interact
	"
	;;
  -h|--help|* ) echo -e "
 Usage: _emailtest [option] [hostname] [address] [password]\n
    -i|--imap ... Test IMAP-SSL to [hostname]
    -p|--pop .... Test POP3-SSL to [hostname]
    -s|--smtp ... Test SMTP-TLS to [hostname]"
    ;;
esac
echo
