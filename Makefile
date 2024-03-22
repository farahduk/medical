MAKEFLAGS += --silent

#####
# Targets for generating files
#####

# Try to detect the runing OS
ifeq ($(OS), Windows_NT)
detected_OS := Windows
else
detected_OS := $(shell uname -s)
endif

.PHONY: .host.env

.host.env:
	touch .host.env
	@ if [ "$(detected_OS)" = "Linux" ]; then \
		echo "HOST_UID=$(shell id -u)" > .host.env; \
		echo "HOST_GID=$(shell id -g)" >> .host.env; \
	fi

poetry.lock:
	poetry lock


#####
# Targets for interacting with docker
#####
export DOCKER_BUILDKIT=1


# Try to detect if Docker compose v2 is available
compose_v2 ?= $(shell docker compose version 2>/dev/null)
ifneq ($(compose_v2),)
compose-cmd = docker compose
else
compose-cmd = docker-compose
endif

project-name ?= medical
image-name ?= fernando/medical
target ?= dev
tag ?= dev
cmd ?=

# Check if dev image exists
ifeq (, $(shell docker images -q $(image-name):dev))
	dev-image-not-present=true
endif


.PHONY: build build-dev compose stop start

build: poetry.lock
	docker build . --target=$(target) --tag=$(image-name):$(tag)

build-dev:
	$(MAKE) build target=dev tag=dev


compose:
	${compose-cmd} \
		-f docker/docker-compose.yml \
		-f docker/docker-compose.$(env).yml \
		-p $(project-name)-$(env) $(cmd)

stop:
	$(MAKE) compose env=dev cmd=stop

start: .host.env $(if $(filter true,$(build)$(dev-image-not-present)), build-dev)
	$(MAKE) compose env=dev cmd=up

debug: stop .host.env
	$(MAKE) compose env=dev cmd="run --service-ports -T --rm medical"


#####
# Targets for setting up the local environment
#####
.PHONY: clean

clean:
	-docker rmi $(docker images $(image-name) -q)
	-poetry cache clear --all pypi -n
	-poetry env remove $(shell python --version | cut -d" " -f2) -q