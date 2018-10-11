.ONESHELL:
.SHELL := /bin/bash
.PHONY: ALL
.DEFAULT_GOAL := help
CURRENT_FOLDER=$(shell basename "$$(pwd)")
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
RESET=$(shell tput sgr0)

help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup-local: ## Install required tools for local environment
	brew install awscli || exit 0
	brew install aws-elasticbeanstalk || exit 0
	brew install pre-commit || exit 0
	pre-commit install || exit 0
	brew install ctop || exit 0
	brew install terraform_landscape || exit 0

pre-commit: ## Run the pre-commit checks on-demand (outside of git hooks)
	@pre-commit run --all-files --verbose

build: # Test
	./gradlew docker
	docker-compose up

test: ## Run tests
	@docker-compose up localstack &
	@sleep 10
	@./gradlew cleanTest test
#	@docker stop `docker ps -a -q`
