docker\:build:
	docker build . -t bluedoc:latest
docker\:test:
	./bin/test-docker-start
docker\:test\:boot:
	rm -Rf /tmp/bluedoc
	./bin/test-docker-start
docker\:status:
	docker ps | grep bluedoc
