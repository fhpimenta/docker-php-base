USER=fhpimenta
IMAGE=docker-php-base

build:
	docker build -t ${USER}/${IMAGE}:test .

push:
	docker build -t ${USER}/${IMAGE}:$(shell git describe --tags `git rev-list --tags --max-count=1`) .
	docker push ${USER}/${IMAGE}:$(shell git describe --tags `git rev-list --tags --max-count=1`)
