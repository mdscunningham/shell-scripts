if [[ $1 =~ [0-9]\.[0-9] ]]; then ver="$1";
else read -p "What is the running PHP version: " ver; fi

# Create Download Directory
if [[ ! -d ~/downloads ]]; then mkdir ~/downloads; fi

# Download archive into directory and unpack
cd ~/downloads/
wget -O ioncube_loaders_lin_x86-64.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -zxf ioncube_loaders_lin_x86-64.tar.gz

# Copy driver the correct .so file to the target directory
if [[ ! -f /usr/lib64/php/modules/ioncube_loader_lin_${ver}.so ]]; then
cp ~/downloads/ioncube/ioncube_loader_lin_${ver}* /usr/lib64/php/modules/
else echo "ioncube_loader_lin already exists backing up before continuing."
gzip /usr/lib64/php/modules/ioncube_loader_lin_${ver}*; cp ~/downloads/ioncube/ioncube_loader_lin_${ver}* /usr/lib64/php/modules/; fi

# Create correct config file for the service
if [[ ! -f /etc/php.d/ioncube.ini && ! -f /etc/php.d/ioncube-loader.ini ]]; then
echo -e "zend_extension=/usr/lib64/php/modules/ioncube_loader_lin_${ver}.so" >> /etc/php.d/ioncube.ini
else echo "ioncube ini file already exists!"; fi

# Check configs and restart php/httpd services
php -v && (service php-fpm restart; service httpd restart)
