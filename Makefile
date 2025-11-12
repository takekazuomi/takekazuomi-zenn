.DEFAULT_GOAL := help

help: ## ヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## 依存関係をインストール
	npm install

node_modules: package.json package-lock.json
	npm install
	@touch node_modules

up: node_modules ## プレビューサーバーを起動
	npm run preview

clean: ## node_modulesを削除
	rm -rf node_modules

.PHONY: help install up clean

