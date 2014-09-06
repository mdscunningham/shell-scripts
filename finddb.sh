#							   +----+----+----+----+
# 							   |    |    |    |    |
# Author: Mark David Scott Cunningham			   | M  | D  | S  | C  |
# 							   +----+----+----+----+
# Created: 2013-11-29
# Updated: 2014-01-05
#
#
#!/bin/bash

source colors.sh
## Find configuration file, and echo configured DB name
_finddb(){
if [[ -z "$1" ]]; then SITEPATH="."; else SITEPATH="$1"; fi;
# If site is Magento
    if [[ -f $SITEPATH/app/etc/local.xml ]]; then 
        echo $(grep dbname $SITEPATH/app/etc/local.xml | cut -d\[ -f3 | cut -d\] -f1)
# If site is Wordpress
    elif [[ -f $SITEPATH/wp-config.php ]]; then
        echo $(grep DB_NAME $SITEPATH/wp-config.php | cut -d\' -f4)
# If site is Joomla
    elif [[ -f $SITEPATH/configuration.php ]]; then
        echo $(grep '$db ' $SITEPATH/configuration.php | cut -d\' -f2)
# If site is SugarCRM
    elif [[ -f $SITEPATH/sugar_version.php ]]; then
        echo $(grep db_name $SITEPATH/config.php | cut -d\' -f4)
# If site is vBulletin 4.x
    elif [[ -f $SITEPATH/includes/config.php ]]; then
        echo $(grep dbname $SITEPATH/includes/config.php | cut -d\' -f6)
# If site is vBulletin 5.x
    elif [[ -f $SITEPATH/upload/core/includes/config.php ]]; then
        echo $(grep dbname $SITEPATH/upload/core/includes/config.php | cut -d\' -f6)
# If site is EE (or any other CodeIgniter application)
    elif [[ "$1" == "EE" || "$1" == "ee" ]]; then
        if [[ -z "$2" ]]; then SITEPATH="/home/$(./getusr.sh)"; else SITEPATH="$2"; fi;
        CONFIG=$(find $SITEPATH -type f -name database.php -print);
        echo $(grep \'database\' $CONFIG | cut -d\' -f6);
# If there is no config to be found ...
    else echo "${BRIGHT}${RED}Could not find configuration file!${NORMAL}"; fi
# Done .. that was a lot of work!
}
_finddb "$@"
