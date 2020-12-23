SHELL := /bin/bash

build: awscli.Dockerfile
	docker build -f ${PWD}/awscli.Dockerfile -t vapor/runtime/awscli:latest .

distribution: build
	docker run --rm \
		--volume ${PWD}/runtime:/runtime:ro \
		--volume ${PWD}/../export:/export \
		--volume ${PWD}/export.sh:/export.sh:ro \
		vapor/runtime/awscli:latest \
		/export.sh
