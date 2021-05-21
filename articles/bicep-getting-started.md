---
title: "ARM Tempate Dsl、Bicep を使おう"
emoji: "💪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["azure", "arm", "bicep"]
published: true
---

[bicep](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/bicep-overview) は、[ARM Template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/) を書き安くするためのDSLだ。ARM Templateは、低レベル過ぎて手書きは結構辛い。慣れてくると書けるようにはなるが、間違が起こりやすく再利用可能なコードを書くことも難しい。bicepは、この問題を構文を単純化し型をサポートした上位の言語を用意することで解決しようという発想で作られている。これは、JavaScript と TypeScript の関係に似ている。bicep(=TypeScript)で書くと、ARM template(JavaScript) に展開され、展開後の、ARM template がAzureにデプロイできる。というのが基本的な流れである。ARM Templateに比べると書きやすいが、最終的には ARM Templateにコンパイル（変換）されるので、出来ることはARM Templateに左右される。

[![pressure gauge](https://live.staticflickr.com/14/17981034_b94b473ea6.jpg)](https://www.flickr.com/photos/takekazuomi/17981034)

近々の開発状況を見ると、3/2 の [Ignite 2021](https://www.youtube.com/watch?v=l85qv_1N2_A)に合わせて 「[0.3.1 loop, existing, new decorators syntax](https://github.com/Azure/bicep/releases/tag/v0.3.1)」が、3/20には 「[0.3.126 loog index, resource/module loop filters](https://github.com/Azure/bicep/releases/tag/v0.3.126)」が、4/10 には 「[0.3.255 var loop](https://github.com/Azure/bicep/releases/tag/v0.3.255)」が、5/15 には、「[0.3.539 visualizer, snippets](https://github.com/Azure/bicep/releases/tag/v0.3.539)」がリリースと概ね月イチでリリースされている。
3.1以降、ARM Template 直書きじゃないと出来ないことがほとんど無くなり。[^1] 「みんな、そろそろ ARM Template を直書きするのをやめて bicep で書こうぜ」とう感じになってきてる。かれこれ半年ほどプロダクションで使っているので、入門編から書いてみる。

## 準備

bicep が、[az cli](https://docs.microsoft.com/en-us/cli/azure/) と [azure powershell](https://docs.microsoft.com/en-us/powershell/azure/?view=azps-5.9.0) に統合されたので、インストールに関してはあまり面倒なことはない。ここでは、WSL2 ＋ az cli の環境を前提で書いていく。（最近、殆ど開発環境がWSL2上に以降しつつある）
az cli では、bicep は、extentionで 実装されており、下記のようにインストールするだけで使えるようになる。bicep が更新された場合は、`az bicep upgrade` で最新版が落ちてくる。

```sh
az bicep install
```

詳しい使い方は、`az bicep -h` で出てくるヘルプを見ると大体分かる。今のところサブコマンドも、buildとdecompile ぐらいしかなく迷うことも無い。

bicep の最も強力な点(=型安全)は、Langage Server を使うと実感できる、そのためにエディターは、VSCode がお勧めだ。基本、Langage Server Protocol をサポートしているエディターなら何でも良いはずだが、現状だと、VSCode が無難な選択になってる。intelij は問題があるらしく、Issueが出てる [Does not work with Bicep.LangServer.exe #159](https://github.com/gtache/intellij-lsp/issues/159)

VSCode の場合、[bicep 用の dev container](https://github.com/Azure/vscode-remote-try-bicep) を使うと快適に書くことができる。適当に新規ディレクトリを作成して、VSCode を開いた後コマンドバレットで`Remote Containers: Open Folder in Container...`して、コンテナとして`Azure Bicep`を選ぶ。初回はここでビルドが走るので少し時間がかかるので少し待つ。[^2] これで環境は出来たので、次は簡単なコードを書いてみよう。

## Hello world

定番の`Hello world` を書いてみる。bicep の dev containerを使うとデフォルトで、Bicep VS Code extension 、[ms-azuretools.vscode-bicep](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep) がインストールされ、拡張子`.bicep`のときに、`language mode`が、`bicep`になる。さらに、snippets が登録されていて、それなりに便利だ。[^3]
bicepでも、基本構造は、ARM Templateと同じで、`paramters`, `variables`, `resources`, `outputs`から構成される。[^4] 例えば、`param` と打てば、snippets の候補が下記のように出る。
![hello01](https://storage.googleapis.com/zenn-user-upload/q0dgln1qxpjibc6o5v8tspmd5v22)

選択すると、テンプレートコードが展開されるので、それをベースにコードを編集する。

```yaml:hello.bicep
param message string = 'bicep'
output message string = 'Hello, ${message}'
```
ARM Templateのjsonに比べると、`{}`が無くなって読みやすくなり、`'Hello, ${message}'` のように、string interpolation(文字列補間)が使えるようになる、2行で書けるのはとても良い。

これをAzureにデプロイするには、下記のようにする。ARM Template と同じコマンド`(az deployment group)` でデプロイできる、とてもシンプルだ。

```sh
az deployment group create -g your-rg -f hello.bicep \
  --query 'properties.outputs.message.value' -o tsv

Hello, bicep
```

パラメータで文字列を与えて、メッセージを変えてみる。

```sh
az deployment group create -g your-rg -f hello.bicep \
  -p message=Azure --query 'properties.outputs.message.value' -o tsv

Hello, Azure
```

どれだけ無駄な、コンピューティングリソースを費やしているのか考えたくないような、`Hello world`ができた。内部的には、`az cli` で、`bicep` から `ARM Template` に変換して Azure に送っている。では、どんな、ARM Template になるのを見てみよう。下記のコマンドで、bicepファイルから生成されるARM Templateを見ることができる。

```sh
az bicep build -f hello.bicep
```

`hello.json`はこんな感じになる。結構長い、、、

```json:hello.json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.3.255.40792",
      "templateHash": "14724217264646303272"
    }
  },
  "parameters": {
    "message": {
      "type": "string",
      "defaultValue": "bicep"
    }
  },
  "functions": [],
  "resources": [],
  "outputs": {
    "message": {
      "type": "string",
      "value": "[format('Hello, {0}', parameters('message'))]"
    }
  }
}
```

結果を見ると、概ね直接的にARM Templateになっているのがわかる。この場合だと、`string interpolation` は、`format` 関数に展開されるところが少し複雑なぐらいしか見るべき点はない。しかし、変換前後では行数が全然違う。元の2行が24行になる。`metadata` の7行を外しても8倍近く違う。jsonはペイロードとしては使えるが手書きは辛いのがわかる。

## Storage を作る

もう少し実用的な、パラメータでプレフィックスとSKUを指定して、Storage Accountを作成するようなbicepを書いてみよう。

```yaml:sa.bicep
param prefix string
param location string
param sku string
param kind string

var name = '${prefix}${uniqueString(resourceGroup().id)}'

resource sa 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  location: location
  kind: kind
  sku: {
    name: sku
  }
}
```

このコードには注目する点が３つある。1つ目は、変数宣言(variables)で、`var name = '${prefix}${uniqueString(resourceGroup().id)}'` のように書ける。このように書くと、ARM Templateでは下記のように展開される。

```json
"variables": {
    "name": "[format('{0}{1}', parameters('prefix'), uniqueString(resourceGroup().id))]"
},
```

2つ目は、`name: name` や、`location: location` のように、パラメータや変数をそのまま書けることだ。ARM Templateだと`"[variables('name')]"`とか`[parameters('location')]"`のように書く必要があったが、普通に書けるようになった。

3つ目は、`resource sa 'Microsoft.Storage/storageAccounts@2021-02-01'` のようなAPIバージョンを含めたリソースを宣言だ。bicep の Langage Server では、ARM Template Schemaからtype情報を作って持っている。それをベースにリソースがどのような属性を持っているかをサジェストしてくれる。例えば、下記のように、`'Microsoft.Storage/storageAccounts@2021-02-01'` だと、`kind`、`location`、`name`、`sku` だという表示される。これでかなりコーディングが捗る。[^5]

![sa01](https://storage.googleapis.com/zenn-user-upload/nyi9hizxrfswv1tiv5spb48ekgu7)

## 最後に

bicep は、ARM Template 直よりは100倍楽に書けｍ記述後の見通しも良い。薄いラッパーなので、トラブルシューティングが楽、Azureの新機能でも、ARM Templateがサポートされていれば、即時 bicep でも使える。例えば、5/1時点で、[Web PubSub](https://azure.microsoft.com/en-us/services/web-pubsub/)は、ARM Templateのドキュメントも無いし、bicep のtype library にも入っていないが、azure-rest-api-specs の[web pubsubの仕様](// https://github.com/Azure/azure-rest-api-specs/tree/master/specification/webpubsub)読みながらbicepで書けば、deploy出来るものが書ける。

```yaml:webpubsub.bicep
param location string = resourceGroup().location
param name string

@allowed([
  'Free_F1'
  'Standard_S1'
])
@description('The name of the SKU. Required. Allowed values: Standard_S1, Free_F1')
param skuName string = 'Free_F1'

@allowed([
  'Free'
  'Basic'
  'Standard'
  'Premium'
])
@description('Optional tier of this particular SKU. `Standard` or `Free`. `Basic` is deprecated, use `Standard` instead.')
param tier string = 'Free'

@allowed([
  1
  2
  5
  10
  20
  50
  100
])
@description('Optional, integer. The unit count of the resource. 1 by default. If present, following values are allowed: Free: 1, Standard: 1,2,5,10,20,50,100')
param capacity int = 1
param tags object = {}

resource name_resource 'Microsoft.SignalRService/WebPubSub@2021-04-01-preview' = {
  name: name
  location: location
  properties: {}
  sku: {
    name: skuName
    tier: tier
    capacity: capacity
  }
  tags: tags
}
```

ちなみに、ARM（腕）だから、bicep（上腕二頭筋）らしい。

## 脚注

[^1]: 一部の機能は、実装しないことがを選択しているものもある、[ユーザー定義関数 Issue 2](https://github.com/Azure/bicep/issues/2)、外部テンプレート、outer scopeなど。
[^2]: dev-containersの元ネタは、 [ここ](https://github.com/microsoft/vscode-dev-containers/tree/v0.166.1/containers/azure-bicep) 。欲しいものが全部入っているわけではないので、ここに適時必要なものをいれる。自分用にカスタマイズした、dev container を[ここ](https://github.com/takekazuomi/devcontainer-bicep)にあげてある。
[^3]: snippets は[絶賛実装中](https://github.com/Azure/bicep/issues?q=+label%3A%22story%3A+snippets%22)で現時点(0.3.539)で大分良くなった。
[^4]: ARM Template だと、これに`functions` が入るが、bicepでは未実装。
[^5]: そもそも、タイプ情報がたりなかったり、bicepでうまく扱えないパターンがあったりで、まだ足りない部分もある。おかしいなと思ったら、[Missing type validation / inaccuracies #784](https://github.com/Azure/bicep/issues/784) を見ると参考になる。


