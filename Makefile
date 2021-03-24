#!/usr/bin/env make

default:
	$(MAKE) help

x: ## total check for develop
	@echo ♲ STATIC CHECK
	@pre-commit run --all-files
	@make t

t: ## run test
	@echo ♲ TEST START
	@poetry run pytest --cov=src --cov-report xml --cov-report=term --disable-warnings

lf:  ## run test only last failed
	@echo ♲ TEST START
	@poetry run pytest --disable-warnings --lf

help: ## show help
	@echo Usage: make [target]
	@echo $(\n)
	@echo Targets:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

##### KEEL
.PHONY: init
init: ## リポジトリの初期化をします
	@bash bin/rewrite-template-name.sh

.PHONY: create-cfn-stack
create-cfn-stack: ## CloudFormationスタックを作成します
	@bash bin/create-cfn-stack.sh

.PHONY: manifest-builder
manifest-builder: ## manifest-builderを実行します
	@go get github.com/lifull/keelctl@${KEELCTL_VERSION}
	@bash bin/manifest-builder.sh
