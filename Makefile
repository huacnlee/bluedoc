docker\:build:
	docker build . -t booklab:latest
	docker ps -aqf status=exited | xargs docker rm && docker images -qf dangling=true | xargs docker rmi
docker\:test:
	./bin/test-docker-start
docker\:test\:boot:
	rm -Rf /tmp/booklab
	./bin/test-docker-start
docker\:status:
	docker ps | grep booklab