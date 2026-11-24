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

build-83:
	docker build -f ${PWD}/Dockerfile --build-arg php=8.3.37 --build-arg redis=6.2.0 --build-arg ini_file=php.ini -t vapor/runtime/php-83al2023:latest .
	docker run --rm --env LAYER_NAME=83al2023$(IMAGE_SUFFIX) $(VOLUMES) vapor/runtime/php-83al2023:latest /export.sh