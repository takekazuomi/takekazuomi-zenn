---
title: "make から mise に移行する"
emoji: "🔧"
type: "tech"
topics: ["mise", "make", "開発環境", "タスクランナー"]
published: true
---

## はじめに

プロジェクトでよく使われる make[^3]、太古の昔からあるタスクランナーとして便利だが、タブ必須・`.PHONY` 宣言・暗黙ルールなど癖が強い。[^6] さらに、タスクで使うランタイムのバージョン管理は別途必要になる。[^5]個人的には、付き合いが長いので「諸々面倒という点も含め、あまり違和感が無い」が、最近お勧めされてmise[^1]に乗り換えようとしている。

現在の多くのプロジェクトは複数のランタイム（Node.js、Python、Ruby 等）に依存している。各ランタイムは独自のバージョンマネージャー（nvm、pyenv、rbenv 等）を持ち、Makefile とは別にバージョン管理の仕組みが必要になる。プロジェクト毎に異なるバージョンを使う場合、セットアップ手順も煩雑になりがちだ。mise は、このあたりも解決してくれる。

## 移行前の状態

現在の Makefile：

```makefile
up:
 npx zenn preview
```

シンプルだが、Node.js のバージョン管理は別途必要。npx[^8] は `node_modules/.bin/` からバイナリを探して実行するツールで、package.json の dependency として管理されたツールを呼び出す。npm scripts では自動的に `node_modules/.bin` が PATH に追加されるが、Makefile からは PATH が通っていないため npx が必要になる。

## mise.toml の作成

:::message
設定ファイル名は `mise.toml` が新しいデフォルト。`.mise.toml` は後方互換性のために残されているが、新規プロジェクトでは `mise.toml` を使用すべき。

[このあたりが、mise.toml への移行の議論](https://github.com/jdx/mise/discussions/2206)、隠しファイルより発見しやすく、`Makefile` や `cargo.toml` と同様の慣習に従うという感じの話がされている。

:::

### ツールとタスクの定義

```toml
[tools]
node = "24"
"npm:zenn-cli" = "0.4"

[tasks.preview]
description = "Zenn プレビューサーバーを起動"
alias = "up"
run = "zenn preview"

[tasks.new-article]
description = "新規記事を作成"
run = "zenn new:article"

[tasks.new-book]
description = "新規本を作成"
run = "zenn new:book"
```

ポイント：

- `[tools]` で Node.js と zenn-cli のバージョンを固定（npm backend[^9]）
- npm backend により `npx` 不要 — mise が PATH を管理するため `zenn` コマンドを直接実行可能
- `mise install` で Node.js と zenn-cli が同時にインストールされるため `npm install` によるセットアップ不要
- `description` でタスクの説明を追加（`mise tasks` で表示）
- `alias` で短縮名を設定

:::message
Node.js のバージョン選定:

1. 使用ツールのランタイムサポートを確認（[zenn-cli](https://github.com/zenn-dev/zenn-editor) は `>=22.0.0`）
2. サポート範囲内で [active LTS](https://nodejs.org/en/about/previous-releases) を選択。執筆時点では v24 が active LTS なので24を選択

:::

## 動作確認

### ツールのインストール

```bash
mise install
```

### タスク一覧の確認

```bash
mise tasks
```

出力例：

```
new-article   新規記事を作成
new-book      新規本を作成
preview       Zenn プレビューサーバーを起動
```

### タスクの実行

```bash
# フルネームで実行
mise run preview

# エイリアスで実行
mise run up

# 短縮形
mise r preview

# タスクを指定
mise preview
```

`mise preview` のように、`run` を省略[^7]して実行することできる。

## まとめ

mise tasks への移行メリット：

- **ランタイムバージョン管理の統合** — バージョン固定とタスク定義が1ファイル
- **構文のシンプルさ** — タブ必須や `.PHONY` 等の make 固有の癖がない
- **タスクの description / 補完サポート** — `mise tasks` で一覧表示、`mise run <Tab>` で補完[^2]

[^1]: mise <https://mise.jdx.dev/> - 開発ツールのバージョン管理とタスクランナー
[^2]: 補完設定については [prezto ユーザーのための mise 簡単ガイド](https://zenn.dev/takekazu/articles/mise-prezto-guide) をどうぞ
[^3]: GNU Make - <https://www.gnu.org/software/make/>
[^5]: I Like Makefiles - <https://news.ycombinator.com/item?id=41607059>
[^6]: Your Makefiles are wrong - <https://tech.davis-hansson.com/p/make/>
[^7]: mise Tasks - <https://mise.jdx.dev/tasks/>
[^8]: npx - <https://docs.npmjs.com/cli/commands/npx>
[^9]: mise npm backend - <https://mise.jdx.dev/dev-tools/backends/npm.html>、mise Node.js Cookbook - <https://mise.jdx.dev/mise-cookbook/nodejs.html>
