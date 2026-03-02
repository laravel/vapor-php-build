#!/bin/bash

set -e
set -u
set -x

cd /opt

zip --quiet --recurse-paths /export/php-${PHP_SHORT_VERSION}.zip . --exclude "*php-cgi"
