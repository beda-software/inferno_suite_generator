.PHONY: typecheck lint lint-fixes tests check docker-build docker-typecheck docker-lint docker-lint-fixes docker-tests docker-check

# Local commands

fasterer:
	fasterer

reek:
	reek

typecheck:
	steep check

lint:
	rubocop .

lint-fixes:
	rubocop . -A

tests:
	bundle exec rake test

check:
	$(MAKE) lint
	$(MAKE) fasterer
	$(MAKE) reek
	$(MAKE) typecheck
	$(MAKE) tests

# Dockerized alternatives
DOCKER_IMAGE ?= inferno-suite-generator:dev
PROJECT_ROOT := $(shell pwd)
DOCKER_RUN = docker run --rm --entrypoint "" -v $(PROJECT_ROOT):/app -w /app $(DOCKER_IMAGE)

docker-build:
	docker build -t $(DOCKER_IMAGE) .

docker-typecheck: docker-build
	$(DOCKER_RUN) steep check

docker-lint: docker-build
	$(DOCKER_RUN) rubocop .

docker-tests: docker-build
	$(DOCKER_RUN) bundle exec rake test

docker-fasterer: docker-build
	$(DOCKER_RUN) fasterer .

docker-reek: docker-build
	$(DOCKER_RUN) reek .

docker-check: docker-build
	$(MAKE) docker-lint
	$(MAKE) docker-fasterer
	$(MAKE) docker-reek
	$(MAKE) docker-typecheck
	$(MAKE) docker-tests