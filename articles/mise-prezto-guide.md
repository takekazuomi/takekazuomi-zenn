---
title: "prezto ユーザーのための mise 簡単ガイド"
emoji: "🧐"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["howto", "prezto", "mise", "紹介"]
published: false
---

最近、miseを使い始めたので紹介。makeは時代遅れとか、プロジェクト毎に依存するツール類が重すぎるとかいろいろあり。プロジェクトメンバーにお勧めされたのもあり、mise を使い始めた。
今のところ気に入っている。「tasks が補完に出てくると便利なので、`mise completion` すると良いよ」ってだけの話ではある。

## 前提条件

- Ubuntu 22.04 LTS
- zsh + [prezto][1] がインストール済み
- [XDG Base Directory][2] に従った環境（`~/.config`, `~/.local` など）

## インストール

### mise のインストール

```bash
curl https://mise.run | sh
```

デフォルトで `~/.local/bin/mise` にインストールされる。

### activate 設定

`~/.zshrc` に追加（prezto初期化の後）：

```zsh
# mise
eval "$(mise activate zsh)"
```

シェルを再起動：

```bash
exec zsh
```

### usage CLI のインストール（重要）

mise の補完には `usage` CLI が必須。

```bash
mise use -g usage
```

## prezto 補完設定

### 補完スクリプトの配置

```bash
mkdir -p ~/.zprezto/modules/completion/external/src
mise completion zsh > ~/.zprezto/modules/completion/external/src/_mise
```

### キャッシュクリア

```bash
rm -f ~/.zcompdump
rm -rf ~/.cache/prezto/*
```

### シェル再起動

```bash
exec zsh
```

## 動作確認

```bash
# 補完のテスト
mise <Tab>

# ツールのインストールと確認
mise use --global node@20
mise ls

# パスの確認
which node
# → ~/.local/share/mise/installs/node/20.x.x/bin/node
```

## トラブルシューティング

### エラー: usage CLI not found

```bash
mise use -g usage
```

### 補完が効かない場合

```bash
# usage CLIの確認
which usage

# mise の状態確認
mise doctor

# 手動で compinit 再実行
autoload -Uz compinit && compinit
```

## mise の基本的な使い方

```bash
# グローバルにインストール
mise use --global node@20 python@3.12

# プロジェクト固有の設定
cd my-project
mise use node@18

# インストール済みツールの確認
mise ls

# ツールの削除
mise uninstall node@18
```

## 補足

- mise は `~/.local/share/mise` にツールをインストール
- 設定ファイルは `~/.config/mise/config.toml` に保存
- `usage` CLI は mise の補完を動的に生成するために必要

## 参考資料

- [mise 公式ドキュメント](https://mise.jdx.dev/)
- [usage CLI](https://usage.jdx.dev/)

[1]: https://github.com/sorin-ionescu/prezto
[2]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
