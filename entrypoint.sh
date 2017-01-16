#!/bin/bash

DATA=/Config/spotweb
. /spotweb/configure.env

[ ! -d $DATA ] && mkdir -p $DATA

if [ ! -f $DATA/ownsettings.php ] && [ -f /var/www/html/ownsettings.php ]; then
	cp /var/www/html/ownsettings.php $DATA/ownsettings.php
fi

touch $DATA/ownsettings.php && chown www-data:www-data $DATA/ownsettings.php
rm -f /var/www/html/ownsettings.php
ln -s $DATA/ownsettings.php /var/www/html/ownsettings.php

if [[ -n "$SPOTWEB_DB_TYPE" && -n "$SPOTWEB_DB_HOST" && -n "$SPOTWEB_DB_NAME" && -n "$SPOTWEB_DB_USER" && -n "$SPOTWEB_DB_PASS" ]]; then
 	echo "<?php" > $DATA/dbsettings.inc.php
	echo "\$dbsettings['engine'] = '$SPOTWEB_DB_TYPE';" >> $DATA/dbsettings.inc.php
	echo "\$dbsettings['host'] = '$SPOTWEB_DB_HOST';" >> $DATA/dbsettings.inc.php
	echo "\$dbsettings['dbname'] = '$SPOTWEB_DB_NAME';"  >> $DATA/dbsettings.inc.php
	echo "\$dbsettings['user'] = '$SPOTWEB_DB_USER';" >> $DATA/dbsettings.inc.php
	echo "\$dbsettings['pass'] = '$SPOTWEB_DB_PASS';"  >> $DATA/dbsettings.inc.php
fi

echo "$NEWSSERVER" > /spotweb/news_variable_test.txt
echo "$NEWSUSER" >> /spotweb/news_variable_test.txt
echo "$NEWSPASS" >> /spotweb/news_variable_test.txt

if [ -f $DATA/dbsettings.inc.php ]; then
	chown www-data:www-data $DATA/dbsettings.inc.php
	rm /var/www/html/dbsettings.inc.php
	cd /var/www/html
	ln -s $DATA/dbsettings.inc.php

	# Before database initialisation we sleep for 30 seconds to let the database server settle down
	echo "Going to sleep for 30 seconds to let the database server settle down"
	sleep 10
	echo "sleep for another 20 seconds"
	sleep 10
	echo "sleep for another 10 seconds"
	sleep 5
	echo "5"
	sleep 1
	echo "4"
	sleep 1
	echo "3"
	sleep 1
	echo "2"
	sleep 1
	echo "1"
	sleep 1
	/usr/local/bin/php /var/www/html/bin/upgrade-db.php
else
	echo -e "\nWARNING: You have no database configuration file, either create $DATA/dbsettings.inc.php or restart this container with the correct environment variables to auto generate the config.\n"
fi

TZ=${TZ:-"Europe/Amsterdam"}
sed -i "s#^;date.timezone =.*#date.timezone = ${TZ}#g" /usr/local/etc/php/php.ini

/usr/sbin/a2enmod rewrite && /etc/init.d/apache2 restart

tail -F /var/log/apache2/*.log
