---
title: "mise × Claude Code で DrawIO MCP を使う"
emoji: "🎨"
type: "tech"
topics: ["drawio", "mcp", "claude", "mise", "diagram"]
published: true
publication_name: baleenstudio
---

## はじめに

[青空](https://bsky.app/profile/drawio.bsky.social/post/3meitpzppec2s)に、draw.io mcp[^1]なるものが流れてたので試してみた。今まで、draw.io は、テキストで書くものに比べ、手間がかかりレイアウトの制約が多いものにしか使わなかったのだが、MCPをかませると、AIが良い感じにやってくれそうで期待値が高い。

最近使い始めた、mise をベースにして、Claude Code から DrawIO MCP を使う設定を紹介する。npx を直接使う標準的な設定は公式ドキュメント[^2]で十分カバーされているので、ここでは mise 環境特有の設定に焦点を当てる。

## DrawIO MCP とは

DrawIO MCP は、draw.io の開発元である JGraph 社が提供する公式 MCP サーバー[^1]。Claude Code から図の生成を依頼すると、ブラウザで draw.io が開いて編集可能な状態で表示される仕組みになっている。

利用可能なツールは3つ：

- `open_drawio_mermaid` - Mermaid 記法で図を生成
- `open_drawio_csv` - CSV データから図を生成
- `open_drawio_xml` - draw.io の XML 形式で直接図を定義

それぞれ用途が異なるらしいが、XML 形式で直接図を書くパターンしか使ったことがない。

## セットアップ（mise × Claude Code）

mise には2つの動作モードがあり、MCP の設定方法に影響する。まず自分の環境がどちらかを確認しておく。

### mise の shim 設定確認

| モード                  | 設定場所                | 非インタラクティブ環境 |
| ----------------------- | ----------------------- | ---------------------- |
| `mise activate`         | .zshrc/.bashrc          | 機能しない             |
| `mise activate --shims` | .zprofile/.bash_profile | 機能する               |

`mise activate` のみの場合、シェルを起動したときに mise が有効になる。したがって、IDE やエディタから直接コマンドを実行する場合には mise が機能しない。一方、`mise activate --shims` を設定していれば、shim 経由でコマンドが実行されるため、非インタラクティブな環境でも動作する。詳しくは mise の公式ドキュメント[^3][^4]を参照。

### mise.toml でNode.jsバージョンを固定

DrawIO MCP は Node.js で動作するため、プロジェクトの mise.toml で Node.js のバージョンを指定しておく：

```toml
[tools]
node = "24"
```

### .mcp.json で MCP サーバーを設定

#### パターンA: shim 設定済みの場合

shim が PATH に設定されていれば、npx を直接呼び出せる：

```json
{
  "mcpServers": {
    "drawio": {
      "command": "npx",
      "args": ["@drawio/mcp"]
    }
  }
}
```

#### パターンB: shim 未設定の場合

`mise activate` のみの場合、mise x 経由で実行する必要がある：

```json
{
  "mcpServers": {
    "drawio": {
      "command": "mise",
      "args": ["x", "--", "npx", "@drawio/mcp"]
    }
  }
}
```

自分の環境がどちらか分からない場合は、パターンBを使えば確実に動作する。

## 実践例1：バブルソートのフローチャート

まず、`open_drawio_xml` を使ってバブルソートのフローチャートを描いてみる。Claude Code で以下のように依頼する：

```text
バブルソートのアルゴリズムをdraw.io XMLでフローチャートにして。
開始・終了は丸角、処理は長方形、条件分岐はひし形で。
```

Claude は以下のような XML を生成してブラウザで開く：

```xml
<!-- 開始（丸角長方形） -->
<mxCell id="start" value="開始" style="rounded=1;whiteSpace=wrap;html=1;
  fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
  <mxGeometry x="100" y="20" width="80" height="40" as="geometry" />
</mxCell>

<!-- 処理（長方形） -->
<mxCell id="init-i" value="i = 0" style="rounded=0;whiteSpace=wrap;html=1;
  fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="80" height="40" as="geometry" />
</mxCell>

<!-- 条件分岐（ひし形） -->
<mxCell id="cond-i" value="i &lt; n-1?" style="rhombus;whiteSpace=wrap;html=1;
  fillColor=#fff2cc;strokeColor=#d6b656;" vertex="1" parent="1">
  <mxGeometry x="80" y="180" width="120" height="60" as="geometry" />
</mxCell>

<!-- 矢印 -->
<mxCell id="edge1" value="" style="endArrow=classic;html=1;"
  edge="1" parent="1" source="start" target="init-i">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

主要なスタイル要素：

- `rounded=1` - 丸角長方形。開始・終了ノードに使用
- `rounded=0` - 通常の長方形。処理ステップに使用
- `rhombus` - ひし形。条件分岐に使用
- `fillColor` / `strokeColor` - 背景色と枠線色。役割ごとに色分けすると見やすい

XML 形式では各ノードの位置（x, y）とサイズ（width, height）を明示的に指定できるため、draw.io で開いた後の微調整が容易になる。

生成された図の例：

![バブルソートのフローチャート](/images/bubble-sort-flowchart.drawio.png)

## 実践例2：Azure ACA Landing Zone アーキテクチャ図

次に、`open_drawio_xml` を使って Azure Container Apps のアーキテクチャ図を描く。Azure の公式 Landing Zone Accelerator[^5] を参考にした、ハブ・スポーク構成の図を依頼してみる：

```text
Azure Container Apps Landing Zone のアーキテクチャ図を描いて。
ハブ・スポーク構成で、以下の要素を含めて：
- ハブVNet: Azure Firewall, Bastion
- スポークVNet: ACA Environment, Application Gateway
- 共通: Log Analytics, Key Vault
```

Claude は `open_drawio_xml` を使って、位置やサイズを細かく制御した XML を生成する。以下はその一部：

```xml
<!-- Hub VNet -->
<mxCell id="hub-vnet" value="" style="rounded=1;whiteSpace=wrap;html=1;
  fillColor=#E6F2FF;strokeColor=#0078D4;strokeWidth=2;dashed=1;"
  vertex="1" parent="1">
  <mxGeometry x="60" y="80" width="280" height="280" as="geometry" />
</mxCell>

<!-- Azure Firewall -->
<mxCell id="firewall" value="" style="image;aspect=fixed;html=1;points=[];
  align=center;image=img/lib/azure2/networking/Firewalls.svg;"
  vertex="1" parent="1">
  <mxGeometry x="100" y="150" width="56" height="56" as="geometry" />
</mxCell>

<!-- ACA Environment -->
<mxCell id="aca-env" value="" style="rounded=1;whiteSpace=wrap;html=1;
  fillColor=#E8F5E9;strokeColor=#43A047;strokeWidth=2;"
  vertex="1" parent="1">
  <mxGeometry x="560" y="130" width="200" height="140" as="geometry" />
</mxCell>
```

draw.io にはAzure アイコンライブラリが組み込まれており、`img/lib/azure2/` パスで参照できる。複雑な配置やアイコンの使用が必要な図では、XML 形式が適している。

生成された図の例：結構それらしい。

![Azure ACA Landing Zone アーキテクチャ図](/images/azure-aca-landing-zone.drawio.png)

## 実践例3：システムアーキテクチャ図

バックエンドサービスの構成図を `open_drawio_xml` で描く。以下のような手書きのスケッチを元に、ユーザー、オペレーターからBackend APIs を経由して外部システムに接続する構成を依頼してみる。

![手書きのスケッチ](/images/system-architecture-handwritten.jpg)

```text
システムアーキテクチャ図をdraw.io XMLで描いて：
- User（umlActor）→ スマホアプリ → BFF API（Go gRPC）→ Backend APIs → Broker → External A, B
- Op（umlActor）が横からBackend APIsに点線でアクセス
- Backend APIs内にAPI 1〜Nを2行で配置
```

このプロンプトでは、`umlActor` シェイプの指定や点線（dashed）の明示がポイント。Claude は以下のような XML を生成する：

```xml
<!-- User（人の図形） -->
<mxCell id="user" value="User" style="shape=umlActor;verticalLabelPosition=bottom;
  verticalAlign=top;html=1;aspect=fixed;" vertex="1" parent="1">
  <mxGeometry x="40" y="120" width="30" height="60" as="geometry" />
</mxCell>

<!-- Backend APIs（swimlaneでグループ化） -->
<mxCell id="backend-apis" value="Backend APIs" style="swimlane;whiteSpace=wrap;html=1;
  fillColor=#E3F2FD;strokeColor=#1976D2;" vertex="1" parent="1">
  <mxGeometry x="400" y="80" width="200" height="160" as="geometry" />
</mxCell>

<!-- API群（2行配置） -->
<mxCell id="api1" value="API 1" style="rounded=1;..." vertex="1" parent="backend-apis">
  <mxGeometry x="20" y="40" width="70" height="40" as="geometry" />
</mxCell>
<mxCell id="api2" value="API 2" style="rounded=1;..." vertex="1" parent="backend-apis">
  <mxGeometry x="110" y="40" width="70" height="40" as="geometry" />
</mxCell>

<!-- Opからの点線矢印 -->
<mxCell id="op-edge" value="" style="endArrow=classic;html=1;dashed=1;strokeColor=#666;"
  edge="1" parent="1" source="op" target="backend-apis">
  <mxGeometry relative="1" as="geometry" />
</mxCell>
```

主要なスタイル要素：

- `shape=umlActor;aspect=fixed` - 人の図形。縦横比を固定して歪みを防ぐ
- `swimlane` - 複数コンポーネントのグループ化。Backend APIs 内に子要素を配置
- `dashed=1` - 点線。運用系アクセスなど通常フローと区別したい接続に使用
- `parent="backend-apis"` - swimlane 内に配置。座標は親要素からの相対位置

プロンプトで図形タイプ（umlActor）や線種（点線）を明示すると、意図した出力を得やすい。

生成された図の例： これもなかなかだ

![システムアーキテクチャ図](/images/system-architecture.drawio.png)

## 図の管理：PNG を Single Source of Truth に

生成した図をどう管理するか。この記事では **PNG ファイルを Single Source of Truth** とするアプローチを採用している。

### PNG に XML を埋め込む

draw.io CLI の `--embed-diagram` オプションを使うと、PNG のメタデータに元の XML が埋め込まれる。mise タスクで自動化：

```toml
[tasks.drawio-export]
description = "draw.ioファイルをPNG（XML埋め込み）にエクスポート"
run = """
for f in images/*.drawio; do
  [ -f "$f" ] || continue
  drawio --export --format png --scale 2 \
    --embed-diagram \
    --output "${f%.drawio}.drawio.png" "$f"
done
"""
```

`--embed-diagram` により、PNG は画像として表示できるだけでなく、draw.io にドラッグ＆ドロップすれば編集可能な状態で開ける。

:::message alert
ここで残念なお知らせがある、drawio desktop が、electron のアプリになっており、WSL2だとGUI(Wayland、X11)が必要で、さらにmiseで管理できない。WSL2環境なら、Windows版を入れて、パスを切っておくとかすれば良さそうだが。残念ながら試したことはない。
:::

### なぜ PNG を Single Source of Truth にするか

`.drawio` ファイルは GitHub 上でレンダリングされない。Markdown 内で参照しても表示されないため、事前に PNG や SVG に変換しておく必要がある。

draw.io は PNG/SVG への XML 埋め込みをサポートしており、変換後も編集可能な状態を維持できる。これが PNG を Single Source of Truth とするアプローチの根拠となる。

| 管理方法                     | メリット                                    | デメリット                               |
| ---------------------------- | ------------------------------------------- | ---------------------------------------- |
| `.drawio` + PNG              | 編集しやすい                                | 二重管理、`.drawio` は GitHub で表示不可 |
| Markdown に XML 埋め込み     | 記事と一体化                                | Markdown 肥大化、編集体験が悪い          |
| **PNG のみ（XML 埋め込み）** | ファイル数最小、単独流通可、GitHub で表示可 | バイナリで diff 不可                     |

PNG に XML が埋め込まれていれば：

- 画像として記事に表示できる
- draw.io で開いて編集できる
- `.drawio` ファイルの管理が不要
- PNG が単独で流通しても編集可能

この時に、`bubble-sort-flowchart.drawio.png` のような名前にしておいて、元のxmlを埋め込んでおくと、VSCode のdraw.io extension[^6]で編集できるので便利である。

こんな風に、VSCodeで開いて編集することもできる。

![alt text](/images/vscode-drawio.png)

この記事中の XML サンプルはあくまで解説用。実際の図は PNG に埋め込まれた XML がソースとなっている。

## まとめ

mise 環境で DrawIO MCP を使う設定を紹介した。shim の設定状況によって .mcp.json の書き方が変わる点がポイントとなる。不明な場合は `mise x` 経由のパターンBを使えば確実。

DrawIO MCP は draw.io の開発元が提供している公式ツールなので、生成される図の品質も安定している。XML 形式は位置やサイズを明示的に指定できるため編集しやすく、多くのケースで推奨。シーケンス図や ER 図など Mermaid 記法が充実している図には `open_drawio_mermaid` が適している。

DrawIO Desktop が、miseで管理できなかったのは、返す返すも残念だ。

[^1]: jgraph/drawio-mcp - <https://github.com/jgraph/drawio-mcp>
[^2]: @drawio/mcp on npm - <https://www.npmjs.com/package/@drawio/mcp>
[^3]: Shims - mise - <https://mise.jdx.dev/dev-tools/shims.html>
[^4]: IDE Integration - mise - <https://mise.jdx.dev/ide-integration.html>
[^5]: Azure/aca-landing-zone-accelerator - <https://github.com/Azure/aca-landing-zone-accelerator>
[^6]: Draw.io Integration <https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio>
