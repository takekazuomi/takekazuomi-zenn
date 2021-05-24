---
title: "ARM tempate DSL、Bicep を使おう(2)"
emoji: "💪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["azure", "arm", "bicep", "入門"]
published: false
---

bicep と、ARM Template はかなり似ている。ARM Template 習熟している人は機械的にbicepに変換することができるだろう。ここでは、ARM Template をある程度知っていることを前提に、bicepの構文を見ていく。ある程度雰囲気を把握すれば、bicep の例を見ながら書くことができるようになるだろう。

ARM Template の複雑さの一部は、「DSL」が `json` の中に埋め込まれているためだ、`Bicep` では、DSL構文を改訂して、独自の`.bicep` 形式に移行し問題を解決している。今回は、bicepが具体的にどんなことをやってるのかを、[前のStorageの例](./articles/bicep-getting-started)を使って解説する。

前回作成した、最小限のは下記のような感じだった。まずは、これをもう少し細かく見いこう。

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

## パラメーターと変数の展開

ARM Template だと、jsonの値部分の文字列に`[]` で囲んで式を埋め込んでいた。例えば、`parameters`や、`variables` で定義された値にアクセスする場合は、下記のように書くことになる。文字列の中に式を埋め込んで、json 値を拡張するという実装だ。[^1]

```json
"name": "[variables('name')]",
```

```json
"location": "[parameters('location')]",
```

Bicep では、json形式を捨てて、`.bicep` 独自の文法を定義し、下記のように書けるようにした。

```yaml
name: name
```

```yaml
location: location
```

json のプロパティ名では、`"`で囲って文字列を書いていたが、`.bicep` では、クオートは必要とせずに、`name`のように書く。また、値は、任意のリテラルまたは式で構成できる。`name: name` の後ろの`name` は式として解釈される。ARM Templeteでは、`paramaters`と`variables` は同じ名前空間を使うので、`variables('name')`や、`parameters('location')`のような指定は必要ない。`.bicep` ではシンプルな構文を目指し冗長性を排除して、`variables()`や、`parameters()` の部分を書かなくて済むようにしている。また、プロパティ間の`,`は必要無く、代わりに改行を書く。[^2]
この調子で、`.bicep` は、シンプルな構文と目指して工夫をしている。カンマを書かなくて良くなったために最後の要素だけを特別扱いする必要も無い。

## 文字列補間(string interpolation)

ARM Templateを手書きしたときは、`concat()`を使って下記のよう書いていたパターンは、bicepだと文字列補間(string interpolation)を使って書くことができる。

```json
"variables": {
  "name": "[concat(parameters('prefix'), uniqueString(resourceGroup().id))]"
},
```

これをと同じことを、Storage Account の例では、下記のように書いている。文字列の中に`${}`で式を書く形式で、C# 6.0で追加された文字列補間(string interpolation)の形式と同じだ。`var｀と `parameters()`　を省略でき、かなり短く書ける。文字列は、シングルクオート `'` で書く。[^3]

```yaml
var name = '${prefix}${uniqueString(resourceGroup().id)}'
```

この部分は、コンパイルすると下記のような変換結果になり、`concat()`は使われないが同じ結果になる。

```json
"variables": {
  "name": "[format('{0}{1}', parameters('prefix'), uniqueString(resourceGroup().id))]"
},
```

ARM Template では、json の値の文字列に`[]`で挟んで式を埋め込んでいた、またパラメーターを式の中で使う場合は、`parameters('prefix')` のように書く必要があった、変数の場合は、`variables()`が必要だった。bicep では、[string interpolation](https://github.com/Azure/bicep/blob/v0.3.539/docs/spec/bicep.md#strings) を使ってスッキリと書ける。

もう少し実用的なテンプレートになるように直していく。まずは、`parameters` に取りうる値やデフォルトを設定し、その後 TODO してみる。

## decorators

`parameters` の修飾、例えば`allowedValues`や、`secureString`は、`param` の decorator で記述する。

```yaml
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param kind string
```

この部分は、ARM Tempateだと、下記のようになる。

```json
"parameters": {
  "kind": {
    "type": "string",
    "allowedValues": [
      "BlobStorage",
      "BlockBlobStorage",
      "FileStorage",
      "Storage",
      "StorageV2"
    ]
  }
},
```

decorators 構文は、[bicep 0.3.1](https://github.com/Azure/bicep/releases/tag/v0.3.1)で実装された機能で、parameter部分の記述がかなり楽になる。`allowedValues`が、`@allowed`になっていたり、キーワードが短くなっているのも使いやすい。Language Serverが動いていると[^4]、`@allowed` に書かれているものと、使われている部分で要求される値のチェックをしてくれる。

![sa05](https://storage.googleapis.com/zenn-user-upload/5qjpeavp7k3wi7n1fkzmusy4i3kh)

①の部分を、`BlobStorageX` のようにして、`kind`を使うと、②のように波線が付いて、`@allowed` の値と期待される値を見ることができる。当然 `@allowed` に列挙するものをサブセットにした場合は警告が出ない。なかなか良くできている、**tooling** は生産性を左右する重要な要因だ。

`@allowed` の他にも、`@secure`、`@minLength/@maxLength`、`@minValue()/@maxValue()`、`@description` など、一式の修飾子をサポートしている。[decorators宣言](https://github.com/Azure/bicep/blob/main/docs/spec/parameters.md#declaration-with-decorators)

---
[^1]: ARM Tempateでは、文字列の最初に`[`が来て、最後に`]`来るような文字列に[テンプレートの式](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-expressions)を埋め込める。エスケープする場合、例えば、`[test value]`のような文字列にしたい場合は、`"[[test value]"` のように書く。
[^2]: 現行の構文だと改行の有無に左右される部分が少々多く、もっと構文上改行ルールの制限を減らそうという議論が、[Make the language "less" newline sensitive #146](https://github.com/Azure/bicep/issues/146)で進んでいる。例えば、今は配列リテラルでは必ず改行で要素を区切る必要がある [#498](https://github.com/Azure/bicep/issues/498)、また複数に分けて書けない部分もある。
[^3]: 文字列のエスケープルールは、[ここ](https://github.com/Azure/bicep/blob/main/docs/spec/bicep.md)
[^4]: Language Server、平たく言うと、 [Bicep VS Code extension](https://github.com/Azure/bicep/blob/main/docs/installing.md#bicep-vs-code-extension)、[neovim](https://github.com/Azure/bicep/issues/1141#issuecomment-749372637)でも動くらしい。