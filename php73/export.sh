#!/bin/bash

set -e
set -u
set -x

cd /opt

cp /runtime/bootstrap bootstrap
cp /runtime/bootstrap.php bootstrap.php

chmod 755 bootstrap
chmod 755 bootstrap.php

rm -rf vapor/

mkdir -p vapor/etc/php/conf.d
cp /runtime/php.ini vapor/etc/php/conf.d/vapor.ini

ls -la

zip --quiet --recurse-paths /export/php-${PHP_SHORT_VERSION}.zip . --exclude "*php-cgi"
# zip --delete /export/php-${PHP_SHORT_VERSION}.zip vapor/sbin/php-fpm bin/php-fpm
