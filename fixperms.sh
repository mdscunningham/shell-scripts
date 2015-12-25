# if [[ $(grep -i ^loadmodule.*php[0-9]_module /etc/httpd/conf.d/php.conf) ]]; then echo mod_php; fi

## Set default permissions for files and directories
fixperms(){
if [[ $1 == '-h' || $1 == '--help' ]]; then echo -e "\n Usage: fixperms [path]\n    Set file permissions to 644 and folder permissions to 2755\n"; return 0; fi
if [[ -n $1 ]]; then SITEPATH="$1"; else SITEPATH="."; fi

echo; read -p "Are you sure you want to update permissions for $SITEPATH? [y/n]: " yn
if [[ $yn == 'y' ]]; then echo -e '\nStarting operation ...'; else echo -e '\nOperation aborted!\n'; return 1; fi

if [[ $(grep -i ^loadmodule.*php[0-9]_module /etc/httpd/conf.d/php.conf) ]]; then perms="664"; else perms="644"; fi
printf "\nFixing File Permissions ($perms)... "; find $SITEPATH -type f -not -perm $perms -print0 | xargs -r0 chmod $perms;
if [[ $(grep -i ^loadmodule.*php[0-9]_module /etc/httpd/conf.d/php.conf) ]]; then perms="2775"; else perms="2755"; fi
printf "Fixing Directory Permissions ($perms) ... "; find $SITEPATH -type d -not -perm $perms -print0 | xargs -r0 chmod $perms;
printf "Operation Completed.\n\n";
}
fixperms "$@"
