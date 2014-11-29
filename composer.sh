# Install Composer
sudo -u $(getusr) -- curl -sS https://getcomposer.org/installer | php -d allow_url_fopen=On -d apc.enable_cli=Off
alias composer="php ~/composer.phar"

# Install WP-CLI
sudo -u $(getusr) -- curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
alias wp="php -d disable_functions='' ~/wp-cli.phar"

# Install Drush
sudo -u $(getusr) -- wget http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz
sudo -u $(getusr) -- tar -zxf drush-7.x-5.9.tar.gz
alias drush="/usr/bin/php -d disable_functions='' -d open_basedir='' ~/drush/drush.php --php=/usr/bin/php"
