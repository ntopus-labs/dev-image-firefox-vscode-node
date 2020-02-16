
# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

export BASE_VERSION=$(VERSION_MAJOR).$(VERSION_MINOR)
export VERSION=$(BASE_VERSION).$(VERSION_PATCH)

SHELL := /bin/bash
# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS
# Build the container
build: ## Build the container
	docker build -t $(CONTAINER_NAME) ./

build-nc: ## Build the container without caching
	docker build --no-cache -t $(CONTAINER_NAME) ./

run: ## Run container on port configured
	source $(dpl) && ./run.sh

up: build run ## Run container on port  80 (Build and run)

stop: ## Stop and remove a running container
	docker stop $(CONTAINER_NAME); docker rm $(CONTAINER_NAME)

release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR

publish: publish-version-major publish-version-minor publish-version-patch publish-version-alias ## Publish the `{version}` and `alias` tagged containers to ECR

publish-version-alias: tag-version-alias ## Publish the `alias` taged container to ECR
	@echo 'publish alias to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(GROUP_NAME)/$(CONTAINER_NAME):$(VERSION_ALIAS)

tag-version-alias: ## Generate container `alias` tag
	@echo 'create tag alias'
	docker tag $(CONTAINER_NAME) $(DOCKER_REPO)/$(GROUP_NAME)/$(CONTAINER_NAME):$(VERSION_ALIAS)

publish-version-major: tag-version-major ## Publish the `major` taged container to ECR
	@echo 'publish major to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(GROUP_NAME)/$(CONTAINER_NAME):$(VERSION_MAJOR)

tag-version-major: ## Generate container `major` tag
	@echo 'create tag major'
	docker tag $(CONTAINER_NAME) $(DOCKER_REPO)/$(GROUP_NAME)/$(CONTAINER_NAME):$(VERSION_MAJOR)

publish-version-minor: tag-version-minor ## Publish the `minor` taged container to ECR
	@echo 'publish minor to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(GROUP_NAME)/$(CONTAINER_NAME):$(BASE_VERSION)

tag-version-minor: ## Generate container `minor` tag
	@echo 'create tag minor'
	docker tag $(CONTAINER_NAME) $(DOCKER_REPO)/$(GROUP_NAME)/$(CONTAINER_NAME):$(BASE_VERSION)

publish-version-patch: tag-version-patch ## Publish the `patch` taged container to ECR
	@echo 'publish patch to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(GROUP_NAME)/$(CONTAINER_NAME):$(VERSION)

tag-version-patch: ## Generate container `patch` tag
	@echo 'create tag patch'
	docker tag $(CONTAINER_NAME) $(DOCKER_REPO)/$(GROUP_NAME)/$(CONTAINER_NAME):$(VERSION)