#######################################################################
#                            Main targets                             #
#######################################################################

## Simple tasks for Volumes Browser

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

.PHONY: help backup shell root sql logs list build update data

green=`tput setaf 2`
orange=`tput setaf 9`
red=`tput setaf 1`
no_color=`tput sgr0`

include .env
export COMPOSE_PROFILES
