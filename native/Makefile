SHELL := /bin/bash

ARCH := $(shell uname -m)

ifeq ($(ARCH),aarch64)
    IMAGE_SUFFIX := -arm
else ifeq ($(ARCH),arm64)
    IMAGE_SUFFIX := -arm
else
    IMAGE_SUFFIX :=
endif

VOLUMES := --volume ${PWD}/runtime:/runtime:ro --volume ${PWD}/../export:/export --volume ${PWD}/export.sh:/export.sh:ro

clean:
	rm -rf ${PWD}/../export/*

build: clean build-83 build-84 build-85 build-86

build-83:
	docker build -f ${PWD}/Dockerfile --build-arg php=8.3.37 --build-arg redis=6.2.0 --build-arg ini_file=php.ini -t vapor/runtime/php-83al2023:latest .
	docker run --rm --env LAYER_NAME=83al2023$(IMAGE_SUFFIX) $(VOLUMES) vapor/runtime/php-83al2023:latest /export.sh

build-84:
	docker build -f ${PWD}/Dockerfile --build-arg php=8.4.28 --build-arg redis=6.1.0 --build-arg ini_file=php.ini -t vapor/runtime/php-84al2023:latest .
	docker run --rm --env LAYER_NAME=84al2023$(IMAGE_SUFFIX) $(VOLUMES) vapor/runtime/php-84al2023:latest /export.sh

build-85:
	docker build -f ${PWD}/Dockerfile --build-arg php=8.5.13 --build-arg redis=6.3.0 --build-arg ini_file=php85plus.ini -t vapor/runtime/php-85al2023:latest .
	docker run --rm --env LAYER_NAME=85al2023$(IMAGE_SUFFIX) $(VOLUMES) vapor/runtime/php-85al2023:latest /export.sh

build-86:
	docker build -f ${PWD}/Dockerfile --build-arg php=8.6.0 --build-arg redis=dev-develop --build-arg ini_file=php85plus.ini -t vapor/runtime/php-86al2023:latest .
	docker run --rm --env LAYER_NAME=86al2023$(IMAGE_SUFFIX) $(VOLUMES) vapor/runtime/php-86al2023:latest /export.sh