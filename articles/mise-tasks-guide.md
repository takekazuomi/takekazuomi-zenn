---
title: "make から mise に移行する"
emoji: "🔧"
type: "tech"
topics: ["mise", "make", "開発環境", "タスクランナー"]
published: false
---

## はじめに

プロジェクトでよく使われる Makefile。太古からあるシンプルなタスクランナーとして便利だが癖が強い。外部コマンド依存しつつも、その外部コマンドのバージョンを管理ができない。などの問題がある。[^5][^6]個人的には、付き合いが長いので諸々面倒という点も含め、あまり違和感が無いが、最近お勧めされてmise[^1]に乗り換えようとしている。

make[^3] は、シェルのすべての機能が使えるため外部コマンド依存が高く、環境再現性に問題が発生しやすい。make の実行で必要な外部コマンドにバージョン依存があると、開発者間で動作が異なってしまう。awkや、make 自身のバージョンもMacOSや、Ubuntu、あるいはバージョン間で違う。非常にシンプルに見えて、実は複雑な問題を抱えがちという問題がある。[^4]

現在の多くのプロジェクトは複数のランタイム（Node.js、Python、Ruby 等）に依存している。各プラットフォームは独自のバージョンマネージャー（nvm、pyenv、rbenv 等）を持ち、問題は複雑化する。プロジェクト毎に異なるバージョンを使う場合、ディスク消費やセットアップ時間も課題となる。Makefile でこれらを解決するには、それぞれのプラットフォームに対する知識が必要となる。

## 移行前の状態

現在の Makefile：

```makefile
up:
	npx zenn preview
```

シンプルだが、Node.js のバージョン管理は別途必要。

## mise.toml の作成

:::message
設定ファイル名は `mise.toml` が新しいデフォルト。`.mise.toml` は後方互換性のために残されているが、新規プロジェクトでは `mise.toml` を使用すべき。

- [コミュニティでの議論](https://github.com/jdx/mise/discussions/2206)で `mise.toml` への移行が決定
- 理由：隠しファイルより発見しやすく、`Makefile` や `Cargo.toml` と同様の慣習に従う
:::

### ツールとタスクの定義

```toml
[tools]
node = "24"

[tasks.preview]
description = "Zenn プレビューサーバーを起動"
alias = "up"
run = "npx zenn preview"

[tasks.new-article]
description = "新規記事を作成"
run = "npx zenn new:article"

[tasks.new-book]
description = "新規本を作成"
run = "npx zenn new:book"

[tasks.install]
description = "依存関係をインストール"
run = "npm install"
```

ポイント：

- `[tools]` でツールバージョンを固定
- `description` でタスクの説明を追加（`mise tasks` で表示）
- `alias` で短縮名を設定


:::message
Node.js のバージョン選定:
1. 使用ツールのランタイムサポートを確認（[zenn-cli](https://github.com/zenn-dev/zenn-editor) は `>=22.0.0`）
2. サポート範囲内で [Active LTS](https://nodejs.org/en/about/previous-releases) を選択。執筆時点では v24 が active LTS なので24を選択
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
install       依存関係をインストール
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

- **ツール管理の統合** - バージョン固定とタスク定義が1ファイル
- **補完サポート** - `mise run <Tab>` でタスク補完[^2]
- **description** - タスクの説明を一覧表示
- **クロスプラットフォーム** - シェルの差異を吸収

[^1]: mise <https://mise.jdx.dev/> - 開発ツールのバージョン管理とタスクランナー
[^2]: 補完設定については [prezto ユーザーのための mise 簡単ガイド](https://zenn.dev/takekazu/articles/mise-prezto-guide) を参照
[^3]: GNU Make - <https://www.gnu.org/software/make/>
[^4]: BSD系とGNU系。*NIXと呼ばれる、派生OSがあります。これらは、分かれていって最終的には、MacOSと、Linuxとして現代に生き残っています。今に生きる我々には、少しだけオプションが違うコマンドとして見えるのです。面白い記事があったのでリンクを置いておきます。 https://sosheskaz.github.io/technology/2017/05/12/Adventures-In-Bsd.html
[^5]: [I Like Makefiles](https://news.ycombinator.com/item?id=41607059)
[^6]: [Your Makefiles are wrong](https://tech.davis-hansson.com/p/make/) 
[^7]: mise Tasks - <https://mise.jdx.dev/tasks/>


