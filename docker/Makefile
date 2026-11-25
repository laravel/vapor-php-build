SHELL := /bin/bash

ARCH := $(shell uname -m)

ifeq ($(ARCH),aarch64)
    IMAGE_SUFFIX := -arm
else ifeq ($(ARCH),arm64)
    IMAGE_SUFFIX := -arm
else
    IMAGE_SUFFIX :=
endif

build-83:
	docker build --build-arg php=8.3.37 --build-arg redis=6.2.0 --build-arg ini_file=php.ini -t vapor-php-83:latest .
