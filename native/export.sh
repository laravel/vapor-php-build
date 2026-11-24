#!/bin/bash

set -e
set -u
set -x

cd /opt

zip --quiet --recurse-paths /export/php-${LAYER_NAME}.zip . --exclude "*php-cgi"
