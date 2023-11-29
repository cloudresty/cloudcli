include version.env

BASE = cloudresty
NAME = $$(awk -F'/' '{print $$(NF-0)}' <<< $$PWD)
DOCKER_REPO = ${BASE}/${NAME}
DOCKER_TAG = ${CLR__CLOUDCLI_VERSION}
BUILD_DATE = $(shell date -u +"%Y-%m-%d")

.PHONY: build shell tag push clean help

help: ## Show list of make targets and their description.
	@grep -E '^[%a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

version-update: ## Update the semvers on Dockerfile using 'version.env' file as source of truth.
	@awk '{gsub("(org.opencontainers.image.version=).*","org.opencontainers.image.version=\"${DOCKER_TAG}\" \\",$$0); print $$0}' Dockerfile > Dockerfile.tmp && mv Dockerfile.tmp Dockerfile
	@awk '{gsub("(org.opencontainers.image.revision=).*","org.opencontainers.image.revision=\"${DOCKER_TAG}-${BUILD_DATE}\" \\",$$0); print $$0}' Dockerfile > Dockerfile.tmp && mv Dockerfile.tmp Dockerfile
	@awk '{gsub("(Release:).*","Release: ${DOCKER_TAG}",$$0); print $$0}' 20-welcome > 20-welcome.tmp && mv 20-welcome.tmp 20-welcome
	@awk '{gsub("(Build  :).*","Build  : ${BUILD_DATE}",$$0); print $$0}' 20-welcome > 20-welcome.tmp && mv 20-welcome.tmp 20-welcome
	@awk '{gsub("(Latest version:).*","Latest version: `${DOCKER_TAG}`</br>",$$0); print $$0}' README.md > README.md.tmp && mv README.md.tmp README.md
	@awk '{gsub("(Release version:).*","Release version: `${DOCKER_TAG}-${BUILD_DATE}`</br>",$$0); print $$0}' README.md > README.md.tmp && mv README.md.tmp README.md
	@awk '{gsub("(Docker image:).*","Docker image: `cloudresty/cloudcli:${DOCKER_TAG}` or `cloudresty/cloudcli:latest`</br>",$$0); print $$0}' README.md > README.md.tmp && mv README.md.tmp README.md	

build: version-update ## Build docker image.
	@docker buildx build \
		--platform linux/amd64 \
		--pull \
		--force-rm -t ${DOCKER_REPO}:${DOCKER_TAG} \
		--file Dockerfile .

shell: ## Run docker image locally and open a shell.
	@docker run \
		--platform linux/amd64 \
		--rm \
		--name ${NAME} \
		--hostname ${NAME} \
		-it ${DOCKER_REPO}:${DOCKER_TAG} zsh

tag-latest: ## Tag docker image.
	@docker tag ${DOCKER_REPO}:${DOCKER_TAG} ${DOCKER_REPO}:latest

push: tag-latest ## Push docker image to registry.
	@docker push ${DOCKER_REPO}:${DOCKER_TAG}
	@docker push ${DOCKER_REPO}:latest

clean: ## Remove all local docker images for this repo.
	@if [[ $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep ${DOCKER_REPO}) ]]; then docker rmi $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep ${DOCKER_REPO}); else echo "INFO: No images found for '${DOCKER_REPO}'"; fi