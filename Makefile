docker\:build:
	docker build . -t booklab:latest
docker\:test:
	./bin/test-docker-start
docker\:test\:boot:
	rm -Rf /tmp/booklab
	./bin/test-docker-start
docker\:status:
	docker ps | grep booklab
