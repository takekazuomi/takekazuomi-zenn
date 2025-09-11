.DEFAULT_GOAL := help

help: ## Show this help message
	@echo 'Usage:'
	@echo '  make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

up: ## Start preview server
	volta run npm run preview

install: ## Install dependencies
	volta run npm install

clean: ## Remove node_modules
	rm -rf node_modules

.PHONY: help up install clean

