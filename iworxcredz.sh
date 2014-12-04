#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-07-30
# Updated: 2014-11-17
#
#
#!/bin/bash


# Print the hostname, or if the hostname does not resolve print the main IP
serverName(){
  if [[ -n $(dig +time=1 +tries=1 +short $(hostname)) ]]; then hostname;
  else ip addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -Ev '^127\.' | head -1; fi
  }

complete -W '-d -e -f -h --list -m -n -p -r -s -x' iworxcredz
iworxcredz(){

# if password option is given use prefered password method
# ^^^ defaults to xkcd method if no method is specified
genPass(){
  if [[ $1 == '-m' ]]; then newPass=$(mkpasswd -l 15);
  elif [[ $1 == '-x' ]]; then newPass=$(xkcd);
  elif [[ $1 == '-p' ]]; then newPass="$2";
  else newPass=$(xkcd); fi
  }

if [[ $1 == '-d' ]]; then
  primaryDomain=$2; shift; shift;
else
  primaryDomain=$(~iworx/bin/listaccounts.pex | awk "/$(getusr)/"'{print $2}')
fi

case $1 in
-e ) # Listing/Updating Email Passwords
if [[ -z $2 || $2 == '--list' ]]; then
  echo -e "\n----- EmailAddresses -----"
  for x in /home/$(getusr)/var/*/mail/*/Maildir/; do echo $(echo $x | awk -F/ '{print $7"@"$5}'); done; echo
else
  emailAddress=$2; genPass $3 $4
  ~vpopmail/bin/vpasswd $emailAddress $newPass
  echo -e "\nLoginURL: https://$(serverName):2443/webmail\nUsername: $emailAddress\nPassword: $newPass\n"
fi
;;

-f ) # Listing/Updating FTP Users
if [[ -z $2 || $2 == '--list' ]]; then
  echo; (echo "ShortName FullName"; sudo -u $(getusr) siteworx -unc Ftp -a list) | column -t; echo
elif [[ $2 == '.' ]]; then
  ftpUser='ftp'; genPass $3 $4
  sudo -u $(getusr) siteworx -u --login_domain $primaryDomain -n -c Ftp -a edit --password $newPass --confirm_password $newPass --user $ftpUser
  echo -e "\nFor Testing: \nlftp -e'ls;quit' -u ${ftpUser}@${primaryDomain},'$newPass' $(serverName)"
  echo -e "\nHostname: $(serverName)\nUsername: ${ftpUser}@${primaryDomain}\nPassword: $newPass\n"
else
  ftpUser=$2; genPass $3 $4;
  sudo -u $(getusr) siteworx -u --login_domain $primaryDomain -n -c Ftp -a edit --password $newPass --confirm_password $newPass --user $ftpUser
  echo -e "\nFor Testing: \nlftp -e'ls;quit' -u ${ftpUser}@${primaryDomain},'$newPass' $(serverName)"
  echo -e "\nHostname: $(serverName)\nUsername: ${ftpUser}@${primaryDomain}\nPassword: $newPass\n"
fi
;;

-s ) # Listing/Updating Siteworx Users
if [[ -z $2 || $2 = '--list' ]]; then
  echo; (echo "EmailAddress Name Status"; sudo -u $(getusr) siteworx -unc Users -a listUsers | sed 's/ /_/g' | awk '{print $2,$3,$5}') | column -t; echo
elif [[ $2 == '.' ]]; then # Lookup primary domain and primary email address
  primaryEmail=$(nodeworx -unc Siteworx -a querySiteworxAccounts --domain $primaryDomain --account_data email)
  genPass $3 $4
  nodeworx -unc Siteworx -a edit --password "$newPass" --confirm_password "$newPass" --domain $primaryDomain
  echo -e "\nLoginURL: https://$(serverName):2443/siteworx/?domain=$primaryDomain\nUsername: $primaryEmail\nPassword: $newPass\nDomain: $primaryDomain\n"
else # Update Password for specific user
  emailAddress=$2; genPass $3 $4
  sudo -u $(getusr) siteworx -unc Users -a edit --user $emailAddress --password $newPass --confirm_password $newPass
  echo -e "\nLoginURL: https://$(serverName):2443/siteworx/?domain=$primaryDomain\nUsername: $emailAddress\nPassword: $newPass\nDomain: $primaryDomain\n"
fi
;;

-r ) # Listing/Updating Reseller Users
if [[ -z $2 || $2 == '--list' ]]; then # List out Resellers nicely
  echo; (echo "ID Reseller_Email Name"; nodeworx -unc Reseller -a listResellers | sed 's/ /_/g' | awk '{print $1,$2,$3}') | column -t; echo
else # Update Password for specific Reseller
  resellerID=$2; genPass $3 $4
  nodeworx -unc Reseller -a edit --reseller_id $resellerID --password $newPass --confirm_password $newPass
  emailAddress=$(nodeworx -unc Reseller -a listResellers | grep ^$resellerID | awk '{print $2}')
  echo -e "\nLoginURL: https://$(serverName):2443/nodeworx/\nUsername: $emailAddress\nPassword: $newPass\n\n"
fi
;;

-m ) # Listing/Updating MySQL Users
if [[ -z $2 || $2 == '--list' ]]; then
  echo; ( echo -e "Username   Databases"
  sudo -u $(getusr) siteworx -unc Mysqluser -a listMysqlUsers | awk '{print $2,$3}' ) | column -t; echo
else
  genPass $3 $4
  dbs=$(sudo -u $(getusr) siteworx -unc Mysqluser -a listMysqlUsers | grep "$2" | awk '{print $3}' | sed 's/,/, /')
  sudo -u $(getusr) siteworx -unc MysqlUser -a edit --name $(echo $2 | sed "s/$(getusr)_//") --password $newPass --confirm_password $newPass
  echo -e "\nFor Testing: \nmysql -u'$2' -p'$newPass' $(echo $dbs | cut -d, -f1)"
  echo -e "\nUsername: $2\nPassword: $newPass\nDatabases: $dbs\n"
fi
;;

-n ) # Listing/Updating Nodeworx Users
if [[ -z $2 || $2 == '--list' ]]; then # List Nodeworx (non-Nexcess) users
  echo; (echo "Email_Address Name"; nodeworx -unc Users -a list | grep -v nexcess.net | sed 's/ /_/g') | column -t; echo
elif [[ ! $2 =~ nexcess\.net$ ]]; then # Update Password for specific Nodeworx user
  emailAddress=$2; genPass $3 $4
  nodeworx -unc Users -a edit --user $emailAddress --password $newPass --confirm_password $newPass
  echo -e "\nLoginURL: https://$(serverName):2443/nodeworx/\nUsername: $emailAddress\nPassword: $newPass\n\n"
fi
;;

-h | --help | * )
echo -e "\n  For FTP and Siteworx, run this from within the user's /home/dir/\n
  Usage: iworxcredz OPTION [--list] [USER/ID] PASSWORD [newPassword]
    Ex: iworxcredz -d secondaryDomain -f ftpUserName -m
    Ex: iworxcredz -f ftpUserName -p newPassword
    Ex: iworxcredz -s emailAddress -x
    Ex: iworxcredz -r --list

  OPTIONS: (use '--list' to list available users)
    -d [domain] . Specify domain for secondary FTP users
    -e [email] .. Email Users
    -f [user] ... FTP Users (default is ftp@primarydomain.tld)
    -s [email] .. Siteworx Users (default is primary user)
    -r [id] ..... Reseller Users
    -n [email] .. Nodeworx Users
    -m [user] ... MySQL Users

  PASSWORD: (password generation or input)
    -m ... Generate password using mkpasswd
    -x ... Generate password using xkcd (default)
    -p ... Specify new password directly (-p <password>)\n"; return 0;
;;

esac

unset primaryDomain primaryEmail emailAddress resellerID newPass # Cleanup
}

iworxcredz "$@"
