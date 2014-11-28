# http://unix.stackexchange.com/questions/83385/parse-xml-to-get-node-value-in-bash-script

dbhost="$(echo 'cat /config/global/resources/default_setup/connection/host/text()' | xmllint --nocdata --shell app/etc/local.xml | sed '1d;$d')"
dbuser="$(echo 'cat /config/global/resources/default_setup/connection/username/text()' | xmllint --nocdata --shell app/etc/local.xml | sed '1d;$d')"
dbpass="$(echo 'cat /config/global/resources/default_setup/connection/password/text()' | xmllint --nocdata --shell app/etc/local.xml | sed '1d;$d')"
dbname="$(echo 'cat /config/global/resources/default_setup/connection/dbname/text()' | xmllint --nocdata --shell app/etc/local.xml | sed '1d;$d')"
prefix="$(echo 'cat /config/global/resources/db/table_prefix/text()' | xmllint --nocdata --shell app/etc/local.xml | sed '1d;$d')"
admin="$(echo 'cat /config/admin/routers/adminhtml/args/frontName/text()' | xmllint --nocdata --shell app/etc/local.xml | sed '1d;$d')"

echo
connect="mysql -u $dbuser -p$dbpass -h $dbhost $dbname"
echo "DBConnect : $connect"
base_url=$(echo "select value from ${prefix}core_config_data where path rlike \"base\" limit 1" | $connect | tail -1)
echo "AdminURL  : $base_url$admin"
echo
