.DEFAULT_GOAL := help

help: ## ヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## 依存関係をインストール
	npm install

install-rust: ## Rustとcargoをインストール
	@if ! command -v cargo &> /dev/null; then \
		echo "Installing Rust and cargo..."; \
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; \
		echo "Rust installed. Please run 'source \$$HOME/.cargo/env' or restart your shell."; \
	else \
		echo "Rust is already installed."; \
	fi

install-svgbob: ## svgbob_cliをインストール
	@if ! command -v cargo &> /dev/null && [ ! -f $$HOME/.cargo/bin/cargo ]; then \
		echo "Error: cargo not found. Please run 'make install-rust' first."; \
		exit 1; \
	fi
	@CARGO=$$(command -v cargo 2>/dev/null || echo "$$HOME/.cargo/bin/cargo"); \
	if ! command -v svgbob_cli &> /dev/null && [ ! -f $$HOME/.cargo/bin/svgbob_cli ]; then \
		echo "Installing svgbob_cli..."; \
		$$CARGO install svgbob_cli; \
		echo "svgbob_cli installed successfully."; \
	else \
		echo "svgbob_cli is already installed."; \
	fi

install-resvg: ## resvgをインストール
	@if ! command -v cargo &> /dev/null && [ ! -f $$HOME/.cargo/bin/cargo ]; then \
		echo "Error: cargo not found. Please run 'make install-rust' first."; \
		exit 1; \
	fi
	@CARGO=$$(command -v cargo 2>/dev/null || echo "$$HOME/.cargo/bin/cargo"); \
	if ! command -v resvg &> /dev/null && [ ! -f $$HOME/.cargo/bin/resvg ]; then \
		echo "Installing resvg..."; \
		$$CARGO install resvg; \
		echo "resvg installed successfully."; \
	else \
		echo "resvg is already installed."; \
	fi

install-tools: install-rust install-svgbob install-resvg install ## 全ての必要なツールをインストール
	@echo "All tools installed successfully."

check-tools: ## インストール済みツールを確認
	@echo "Checking installed tools..."
	@command -v node >/dev/null 2>&1 && echo "✓ Node.js: $$(node --version)" || echo "✗ Node.js: not installed"
	@command -v npm >/dev/null 2>&1 && echo "✓ npm: $$(npm --version)" || echo "✗ npm: not installed"
	@(command -v cargo >/dev/null 2>&1 || [ -f $$HOME/.cargo/bin/cargo ]) && \
		echo "✓ cargo: $$(command -v cargo >/dev/null 2>&1 && cargo --version || $$HOME/.cargo/bin/cargo --version)" || \
		echo "✗ cargo: not installed"
	@(command -v svgbob_cli >/dev/null 2>&1 || [ -f $$HOME/.cargo/bin/svgbob_cli ]) && \
		echo "✓ svgbob_cli: $$(command -v svgbob_cli >/dev/null 2>&1 && svgbob_cli --version || $$HOME/.cargo/bin/svgbob_cli --version)" || \
		echo "✗ svgbob_cli: not installed"
	@(command -v resvg >/dev/null 2>&1 || [ -f $$HOME/.cargo/bin/resvg ]) && \
		echo "✓ resvg: $$(command -v resvg >/dev/null 2>&1 && resvg --version || $$HOME/.cargo/bin/resvg --version)" || \
		echo "✗ resvg: not installed"

node_modules: package.json package-lock.json
	npm install
	@touch node_modules

svg-generate: node_modules ## アスキーアートからSVGを生成
	npm run svg:generate

svg-watch: node_modules ## ファイル変更を監視してSVGを自動生成
	npm run svg:watch

up: node_modules svg-generate ## プレビューサーバーを起動（SVG生成後）
	npm run preview

dev: node_modules ## 開発モード（ファイル監視 + プレビュー）
	@npm run svg:watch & npm run preview

clean: ## node_modulesを削除
	rm -rf node_modules

.PHONY: help install install-rust install-svgbob install-resvg install-tools check-tools svg-generate svg-watch up dev clean

