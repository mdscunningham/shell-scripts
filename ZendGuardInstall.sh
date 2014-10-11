if [[ $1 =~ [0-9]\.[0-9] ]]; then ver="$1";
else read -p "What is the running PHP version: " ver; fi

# Create Download Directory
if [[ ! -d ~/downloads ]]; then mkdir ~/downloads; fi

# Download archive into directory and unpack
cd ~/downloads/
wget http://downloads.zend.com/guard/5.5.0/ZendGuardLoader-php-${ver}-linux-glibc23-x86_64.tar.gz
tar -zxvf ZendGuardLoader-php-${ver}-linux-glibc23-x86_64.tar.gz

# Copy driver the correct .so file to the target directory
if [[ ! -f /usr/lib64/php/modules/ZendGuardLoader.so ]]; then
cp ~/downloads/ZendGuardLoader-php-${ver}-linux-glibc23-x86_64/php-${ver}.x/ZendGuardLoader.so /usr/lib64/php/modules/
else echo "ZendGuardLoader.so already exists! Backing up current version before continuing.";
gzip /usr/lib64/php/modules/ZendGuardLoader.so && cp ~/downloads/ZendGuardLoader-php-${ver}-linux-glibc23-x86_64/php-${ver}.x/ZendGuardLoader.so /usr/lib64/php/modules/
fi

# Create correct config file for the service
if [[ ! -f /etc/php.d/ZendGuard.ini && ! -f /etc/php.d/ioncube.ini && ! -f /etc/php.d/ioncube-loader.ini ]]; then file="/etc/php.d/ZendGuard.ini"
elif [[ -f /etc/php.d/ioncube-loader.ini ]]; then file="/etc/php.d/ioncube-loader.ini";
elif [[ -f /etc/php.d/ioncube.ini ]]; then file="/etc/php.d/ioncube.ini"
elif [[ -f /etc/php.d/ZendGuard.ini ]]; then echo "ZendGuard.ini file already exists!";  file="/dev/null"; fi
echo "Adding Zend Guard config to $file"
echo -e "\n; Enable Zend Guard extension\nzend_extension=/usr/lib64/php/modules/ZendGuardLoader.so\nzend_loader.enable=1\n" >> $file

# Check configs and restart php/httpd services
if [[ -d /etc/php-fpm.d/ ]]; then php -v && service php-fpm restart
else httpd -t && service httpd restart; fi

