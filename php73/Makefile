SHELL := /bin/bash

compiler: compiler.Dockerfile
	docker build -f ${PWD}/compiler.Dockerfile -t vapor/runtime/compiler:latest .

build: compiler
	docker build --no-cache -f ${PWD}/php.Dockerfile -t vapor/runtime/php-73:latest $(shell helpers/buildArguments.php php73) .

distribution: build
	docker run --rm \
		--env PHP_SHORT_VERSION=73 \
		--volume ${PWD}/runtime:/runtime:ro \
		--volume ${PWD}/../export:/export \
		--volume ${PWD}/export.sh:/export.sh:ro \
		vapor/runtime/php-73:latest \
		/export.sh
