# AGENTS.md

このファイルは、coding agents がこのリポジトリで作業する際の指針を提供する。以下の情報を含む：

- プロジェクトの構造と技術スタック
- 開発コマンドとワークフロー
- Zenn固有のMarkdown記法と公開フロー

記事執筆時の文章スタイルガイドラインは[WRITING_STYLE.md](docs/WRITING_STYLE.md)を参照。

## プロジェクト概要

Zenn技術記事管理リポジトリ。Markdownで記事を執筆し、GitHubと連携してZennに公開。主にAzure、Bicep、ARM Template、Container Apps、Git関連の記事を含む。

## 開発環境

- ツールバージョン管理: [mise](https://mise.jdx.dev/)使用（mise.toml で定義）
- Node.js: 24
- zenn-cli: 0.4
- markdownlint-cli2: latest

## コマンド実行

### 主要コマンド

```bash
mise run preview            # プレビューサーバー起動（http://localhost:8000）
mise run new-article        # 新規記事作成
mise run lint               # Markdownファイルのリント
mise run lint-fix           # Markdownファイルのリント＋自動修正
mise run drawio-export      # draw.ioファイルをPNGにエクスポート
```

### 図表生成

draw.io で図を作成し、PNGにエクスポート（Zenn対応形式）。

**使い方**:

1. draw.io で図を作成し `images/*.drawio` として保存
2. PNG エクスポート:

```bash
mise run drawio-export
```

3. 記事内で画像参照:

```markdown
![図の説明](/images/my-diagram.png)
```

**注意**: 旧 svgbob_cli/resvg によるアスキーアート変換パイプラインは廃止済み。`articles/draft/diagrams/*.txt` は参考として残存

## ディレクトリ構造

```
.
├── articles/         # 記事（Markdown）- リポジトリルート直下必須
│   ├── draft/       # 下書き記事
│   ├── media/       # 記事用画像ファイル
│   └── *.md         # 公開済み・公開予定記事
├── books/           # 本（存在する場合）
│   └── {book-slug}/
│       ├── config.yaml
│       └── *.md
├── images/          # 画像ファイル - リポジトリルート直下必須
│   └── *.{png,jpg,jpeg,gif,webp}  # 対応拡張子、3MB以下
└── mise.toml        # mise ツール・タスク定義
```

## 記事ファイル形式

各記事はYAMLフロントマター + Markdown本文で構成:

```yaml
---
title: "記事タイトル"
emoji: "💪"
type: "tech"  # tech: 技術記事 / idea: アイデア
topics: ["azure", "bicep", "arm"]  # トピックタグ
published: false  # true: 公開 / false: 下書き
published_at: 2025-01-15 09:00  # 予約投稿（JST、オプション）
---

本文...
```

### フロントマター詳細

- `published: true`に設定後、GitHubにpushすると自動公開
- `published_at`で予約投稿可能（JST基準、過去日時も設定可能）
- 記事削除はZennダッシュボードから実施（ファイル削除では削除されない）

## Zenn Markdown拡張記法

### コードブロック

```js:example.js
// ファイル名表示
console.log('hello');
```

```diff js
- // 削除行
+ // 追加行
```

### メッセージボックス

```
:::message
通常メッセージ
:::

:::message alert
警告メッセージ
:::
```

### アコーディオン

```
:::details タイトル
折りたたみコンテンツ
:::
```

### 画像埋め込み

- 画像は`/images/`ディレクトリに配置（対応: .png .jpg .jpeg .gif .webp、3MB以下）
- 記事内では絶対パスで参照: `![](/images/example.png)`
- 相対パス（`../images/`）は使用不可
- 幅指定: `![](/images/example.png =250x)`
- キャプション: 画像下に`*キャプション文*`

### 埋め込みコンテンツ

URL単独行で自動埋め込み対応:

- GitHub（ファイル、Gist）
- YouTube
- Twitter/X
- CodePen
- Figma

### 図表

```mermaid
graph TD;
  A-->B;
```

### 数式

- インライン: `$E = mc^2$`
- ブロック: `$$E = mc^2$$`

## 公開フロー

1. ローカルで執筆・プレビュー（`mise run preview`）
2. `published: true`に設定
3. GitHubにpush
4. Zennが自動デプロイ・公開

## Git運用

### コミットメッセージ

- **日本語で記述**
- **簡潔に**（1行、長くても2-3行程度）
- 変更内容を端的に表現
- 例: `記事スタイル改善、接続詞追加と文末表現多様化`
- 例: `PNG図表生成機能追加`

## スペルチェック

cspell.config.yamlで設定管理。カスタム辞書は`words`セクションに追加。

---

## 参考資料

### 開発・技術情報

- [Zenn CLI使い方](https://zenn.dev/zenn/articles/zenn-cli-guide)
- [Zenn Markdown記法](https://zenn.dev/zenn/articles/markdown-guide)
- [Zenn画像管理](https://zenn.dev/zenn/articles/deploy-github-images)

### 文章スタイル

記事執筆時の文章スタイルガイドラインは[WRITING_STYLE.md](docs/WRITING_STYLE.md)を参照。
