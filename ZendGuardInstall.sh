ver="$1"

# Create Download Directory
if [[ ! -d ~/downloads ]]; then mkdir ~/downloads; fi

# Download archive into directory and unpack
cd ~/downloads/
wget http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-${ver}-linux-glibc23-x86_64.tar.gz
tar -zxvf ZendGuardLoader-php-${ver}-linux-glibc23-x86_64.tar.gz

# Copy driver the correct .so file to the target directory
if [[ ! -f /usr/lib64/php/modules/ZendGuardLoader.so ]]; then
cp ~/downloads/ZendGuardLoader-php-${ver}-linux-glibc23-x86_64/php-${ver}.x/ZendGuardLoader.so /usr/lib64/php/modules
else echo "ZendGuardLoader.so already exists!"; fi

# Create correct config file for the service
if [[ ! -f /etc/php.d/ZendGuard.ini ]]; then
echo -e "; Enable Zend Guard extension\nzend_extension=/usr/lib64/php/modules/ZendGuardLoader.so\nzend_loader.enable=1\n" >> /etc/php.d/ZendGuard.ini
else echo "ZendGuard.ini already exists!"; fi

# Check configs and restart php/httpd services
php -v && (service php-fpm restart; service httpd restart)
