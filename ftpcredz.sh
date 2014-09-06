#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2014-07-31
# Updated: 2014-07-31
#
#
#!/bin/bash

ftpcredz(){
# Parse input parameters (Check for help option, or empty run)
if [[ -z $@ || $1 =~ -h ]]; then
  echo "
   Usage: ftpcredz [-u <ftpuser>] [-d <domain>] [ -m | -x | -p <password> ]
    -u ... Specify username of ftp user w/o domain (assumes primary domain)
    -d ... Specify domain for secondry ftp users
    -m ... Generate password using mkpasswd
    -p ... Specify new password directly
    -x ... Generate password using xkcd (default if no method specified)
"
  return 0;
fi

# if -u option is given then next parameter is username
# otherwise assume that the user if ftp@primaryDomain.tld
if [[ $1 = '-u' ]]; then
  ftpUser=$2; shift; shift;
else
  ftpUser='ftp';
fi

if [[ $1 == '-d' ]]; then
  primaryDomain=$2; shift; shift
else
  #Lookup primary domain given unix user
  primaryDomain=$(~iworx/bin/listaccounts.pex | grep $(getusr) | awk '{print $2}')
fi

# if password option is given use prefered password method
# ^^^ defaults to xkcd method if no method is specified
if [[ $1 == '-m' ]]; then
  newPass=$(mkpasswd -l 15);
elif [[ $1 == '-x' ]]; then
  newPass=$(xkcd);
elif [[ $1 == '-p' ]]; then
  newPass="$2";
else
  newPass=$(xkcd);
fi

# Log into Siteworx using unix user for account
# ^^^ Can't run a ftp reset from Nodeworx, to log into Siteworx without credz, sudo to the unix user.
sudo -u $(getusr) -- siteworx -u --login_domain $primaryDomain -n -c Ftp -a edit --password $newPass --confirm_password $newPass --user $ftpUser

# Print new credentials as block for copy pasta
echo "
Hostname: $(hostname)
Username: ${ftpUser}@${primaryDomain}
Password: $newPass
"
}
ftpcredz "$@"
