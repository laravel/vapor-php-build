#!/bin/bash

set -e
set -u
set -x

cd /opt

ls -la

zip --quiet --recurse-paths /export/awscli.zip .
