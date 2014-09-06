#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-02-18
# Updated: 2014-08-02
#
#
#!/bin/bash

if [[ -z $2 || $1 == '.' ]]; then D="$(pwd | sed 's:^/chroot::' | cut -d/ -f4)"; else D=$(echo $1 | sed 's/\///g'); fi
if [[ -z $2 ]]; then opt=$1; else opt=$2; fi

#if [[ $opt != '-h' && $opt != '--help' && -f /etc/httpd/conf.d/vhost_${D}.conf ]]; then
#else echo "/etc/httpd/conf.d/vhost_${D}.conf does not appear to exist."; fi

case $opt in
-c|--check  )
	if [[ -f /etc/httpd/conf.d/vhost_${D}.conf ]]; then
		if grep -Eq 'DocumentRoot.*disabled$' /etc/httpd/conf.d/vhost_${D}.conf > /dev/null; then
			echo -e "\n$D is Disabled\n";
		elif grep -Eq 'DocumentRoot.*html$' /etc/httpd/conf.d/vhost_${D}.conf > /dev/null; then
			echo -e "\n$D is Enabled\n";
		fi
	else
		echo -e "\n/etc/httpd/conf.d/vhost_${D}.conf does not appear to exist on this server.\n"
	fi
	;;
-d|--disable)
	sed -i 's/\(DocumentRoot.*html$\)/DocumentRoot \/home\/interworx\/var\/errors\/disabled\n  \#\1/g' /etc/httpd/conf.d/vhost_${D}.conf &&\
	httpd -t && service httpd reload && echo -e "\nDocumentRoot changed to Disabled\n"
	;;
-e|--enable )
	sed -i 's/DocumentRoot.*disabled$//g' /etc/httpd/conf.d/vhost_${D}.conf &&\
	sed -i 's/\#\(DocumentRoot.*html$\)/\1/g' /etc/httpd/conf.d/vhost_${D}.conf &&\
	httpd -t && service httpd reload && echo -e "\nDocumentRoot changed to Enabled\n"
	;;
-h|--help|*)
	echo "
 Usage: haxed [<domain>] <option>
    -c | --check ..... Check if DocumentRoot is set to disabled
    -d | --disable ... Change DocumentRoot to disabled in vhost file
    -e | --enable .... Change DocumentRoot back to the user directory
    -h | --help ...... Print this help dialogue and exit

    If <domain> is . or empty, haxed will attempt to get the domain from the PWD.
	"
	;;
esac
