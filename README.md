# Zenn Contents

* [📘 How to use](https://zenn.dev/zenn/articles/zenn-cli-guide)
* [📘 Markdown guide](https://zenn.dev/zenn/articles/markdown-guide)

## 開発環境

### 前提条件

- [mise](https://mise.jdx.dev/) がインストール済み

### セットアップ

```bash
mise install     # Node.js をインストール
mise run install # npm パッケージをインストール
```

### タスク

| コマンド | 説明 |
|----------|------|
| `mise run preview` | プレビューサーバー起動 |
| `mise run new-article` | 新規記事作成 |
| `mise run new-book` | 新規本作成 |

> 💡 `mise run preview` は `mise preview` と省略可能（[詳細](https://mise.jdx.dev/tasks/)）