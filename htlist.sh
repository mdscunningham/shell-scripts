#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2014-08-03
# Updated: 2014-08-04
#
#
#!/bin/bash

htlist(){
# Parse through options/parameters
if [[ $1 =~ -p ]]; then SITEPATH=$2; shift; shift; else SITEPATH='.'; fi; opt=$1

# Run correct for-loop given list type
case $opt in
-b | --black)
  if ! grep -Eq '.rder .llow,.eny' $SITEPATH/.htaccess &> /dev/null; then
    sudo -u $(getusr) echo -e "Order Allow,Deny\nAllow From All" >> $SITEPATH/.htaccess &&
    echo "$SITEPATH/.htaccess rules updated";
  fi
  shift; echo; for x in "$@"; do
    sed -i "s/\b\(.rder .llow,.eny\)/\1\nDeny From $x/" $SITEPATH/.htaccess &&
    echo "Deny From $x ... Added to $SITEPATH/.htaccess"
  done; echo
  ;;

-w | --white)
  if ! grep -Eq '.rder .eny,.llow' $SITEPATH/.htaccess &> /dev/null; then
    sudo -u $(getusr) echo -e "Order Deny,Allow\nDeny From All" >> $SITEPATH/.htaccess &&
    echo "$SITEPATH/.htaccess rules updated";
  fi
  shift; echo; for x in "$@"; do
    sed -i "s/\b\(.rder .eny,.llow\)/\1\nAllow From $x/" $SITEPATH/.htaccess &&
    echo "Allow From $x ... Added to $SITEPATH/.htaccess"
  done; echo
  ;;

-r | --robot)
  if grep -Eq '.rder .llow,.eny' $SITEPATH/.htaccess &> /dev/null; then
  sed -i 's/\b\(.rder .llow,.eny\)/\1\nDeny from env=bad_bot/' $SITEPATH/.htaccess
  else sudo -u $(getusr) echo -e "\nOrder Allow,Deny\nDeny from env=bad_bot\nAllow from All" >> $SITEPATH/.htaccess && echo "$SITEPATH/.htaccess rules updated."; fi

  shift; echo
  echo -e "\n# ----- Block Bad Bots Section -----\n" >> $SITEPATH/.htaccess
  for x in "$@"; do echo "BrowserMatchNoCase $x bad_bot" | tee -a $SITEPATH/.htaccess; done
  echo -e "\n# ----- Block Bad Bots Section -----\n" >> $SITEPATH/.htaccess; echo
  ;;

-h|--help|*)
  echo -e "\n  Usage: htlist [options] <listType> <IP1> <IP2> ...\n
    Options:
    -p | --path .... Path to .htaccess file
    -h | --help .... Print this help and quit

    List Types:
    -b | --black ... Blacklist IPs
    -w | --white ... Whitelist IPs
    -r | --robot ... Block UserAgent\n";
    return 0;
  ;;

esac
}

htlist "$@"
