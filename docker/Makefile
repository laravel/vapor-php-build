SHELL := /bin/bash

ARCH := $(shell uname -m)

ifeq ($(ARCH),aarch64)
    IMAGE_SUFFIX := -arm
else ifeq ($(ARCH),arm64)
    IMAGE_SUFFIX := -arm
else
    IMAGE_SUFFIX :=
endif

build: build-83 build-84 build-85 build-86

build-83:
	docker build --build-arg php=8.3.37 --build-arg redis=6.2.0 --build-arg ini_file=php.ini -t laravelphp/vapor:php83$(IMAGE_SUFFIX):php .

build-84:
	docker build --build-arg php=8.4.28 --build-arg redis=6.2.0 --build-arg ini_file=php.ini -t laravelphp/vapor:php84$(IMAGE_SUFFIX):php .

build-85:
	docker build --build-arg php=8.5.13 --build-arg redis=6.3.0 --build-arg ini_file=php.ini -t laravelphp/vapor:php85$(IMAGE_SUFFIX):php .

build-86:
	docker build --build-arg php=8.6.0 --build-arg redis=dev-develop --build-arg ini_file=php.ini -t laravelphp/vapor:php86$(IMAGE_SUFFIX):php .