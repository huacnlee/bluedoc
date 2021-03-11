BASE_VERSION = 2.7.2-alpine
COMMIT_VERSION := `git rev-parse --short HEAD`

build\:base:
	docker build -f Dockerfile-base . -t bluedoc/base:${BASE_VERSION}
	docker push bluedoc/base:${BASE_VERSION}
build:
	docker build --build-arg=COMMIT_VERSION=$(COMMIT_VERSION) . -t bluedoc/bluedoc:latest