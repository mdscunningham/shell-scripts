## Create Magento Multi-Store Symlinks
magsymlinks(){
U=$(getusr); if [[ -z $1 ]]; then echo; read -p "Domain Name: " D; else D=$1; fi

echo; read -p "Are you sure you want to create symlinks in $PWD for /home/$U/$D/html/ [y/n]: " yn
if [[ $yn == 'y' ]]; then echo -e '\nStarting operation ...'; else echo -e '\nOperation aborted!\n'; return 1; fi

for X in app includes js lib media skin var; do sudo -u $U ln -s /home/$U/$D/html/$X/ $X; done;
echo; read -p "Copy .htaccess and index.php? [y/n]: " yn; if [[ $yn == "y" ]]; then
for Y in index.php .htaccess; do sudo -u $U cp /home/$U/$D/html/$Y .; done; fi; echo
}
magsymlinks "$@"
