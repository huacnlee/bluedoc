BASE_VERSION = 2.7.2-alpine

build\:base:
	docker build -f Dockerfile-base . -t bluedoc/base:${BASE_VERSION}
	docker push bluedoc/base:${BASE_VERSION}