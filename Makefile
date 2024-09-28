#######################################################################
#                            Main targets                             #
#######################################################################

## Simple tasks for Volumes Browser

# GREP pattern to filter volumes. All, by default
VOLUMES="."

help:     ## Show this help.
	@egrep -h '(\s##\s|^##\s)' $(MAKEFILE_LIST) | egrep -v '^--' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m  %-35s\033[0m %s\n", $$1, $$2}'

build:   ## Build containers.
	@echo "${green}Create app${no_color}"
	docker compose build

update: ## Update images
	@echo "${orange}Update images${no_color}"
	docker compose build --pull

shell: ## Start shell.
	@echo "${green}Start shell interactive console${no_color}"
	docker compose run --rm browser

write: ## ⚠️ Start shell after mounting every volume
	@echo "${red}Start shell interactive console. Be careful!${no_color}"
	@$(MAKE) --quiet MODE=rw COLOR="${red}" -- --mount

read: ## Start shell after mounting every volume (READ-ONLY)
	@echo "${green}Start shell interactive console with read-only volumes${no_color}"
	@$(MAKE) --quiet MODE=ro COLOR="${green}" -- --mount

--mount: ## Start shell after mounting every volume
	@{\
		set -eu;\
		mount=""; \
		for VOLUME_NAME in $$(docker volume ls --format "{{.Name}}" | grep ${VOLUMES}); do\
			echo "Mount ${COLOR}$${VOLUME_NAME}${no_color} to /mnt/$${VOLUME_NAME}";\
			mount="$${mount} -v $${VOLUME_NAME}:/mnt/$${VOLUME_NAME}:${MODE}";\
		done;\
		docker compose run $${mount} -v /tmp/:/tmp/ --rm browser;\
	}

.PHONY: help write read build shell

green=`tput setaf 2`
orange=`tput setaf 9`
red=`tput setaf 1`
no_color=`tput sgr0`

include .env
export COMPOSE_PROFILES
