---
title: "Bicep 0.5がリリースされました"
emoji: "💪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["azure", "arm", "bicep", "入門", "bicep入門"]
published: false
---

# 概要

待望の[Bicep 0.5](https://github.com/Azure/bicep/releases/tag/v0.5.6)が出たので少し使ってみた。今回の最も大きな更新は、**Bicep Public Registry** という事で、既存のテンプレートで使ってみる。

4/9時点で公開されてるモジュールは、ソースが[ここに Bicep Registry Modules](https://github.com/Azure/bicep-registry-modules#bicep-registry-modules)にある。まだまだ数が少ないが、VNetがあったので、これを[azure-bastion01](https://github.com/takekazuomi/azure-bastion01)に入れて試してみた。

変更前、下記の[リソース定義](https://github.com/takekazuomi/azure-bastion01/blob/v1.0.0/deploy/vnet.bicep#L10-L22)でVNetが定義されている。

```bicep
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: subnets
  }
}
```

これを、public module の最小限のパラーメータの例、[Virtual Networks module](https://github.com/Azure/bicep-registry-modules/blob/main/modules/network/virtual-network/README.md#example-1)で入れ替える。module のname が被らないように工夫されているなどあるが、ただ入れ替えただけで概ね行けそうな気がする。

```bicep
module vnet 'br/public:network/virtual-network:1.0' = {
  name: '${uniqueString(deployment().name, 'WestEurope')}-minvnet'
  params: {
    name: virtualNetworkName
    addressPrefixes: [
      '10.0.0.0/16'
    ]
  }
}
```

これを、bicepに通してみると、早速エラーになった、残念。

```sh
$ bicep build ./vnet.bicep
/home/takekazu/ghq/github.com/takekazuomi/azure-bastion01/deploy/vnet.bicep(10,13) : Error BCP192: Unable to restore the module with reference "br:mcr.microsoft.com/bicep/network/virtual-network:1.0": The module does not exist in the registry.
/home/takekazu/ghq/github.com/takekazuomi/azure-bastion01/deploy/vnet.bicep(22,26) : Error BCP062: The referenced declaration with name "vnet" is not valid.
```

どうやら、`The module does not exist in the registry`、レポジトリにモジュールが無いらしいので、mcr に登録されているモジュールとして存在するかを確認する。この手の問題が起きたときには、[Microsoft Container Registry (MCR)](https://github.com/microsoft/containerregistry)に書いてある方法を使って調べている。あまり便利では無いが、まあ事足りる。

そもそもレポジトリに登録されているかを調べるとどうやら登録されているらしい。

```sh
curl -s https://mcr.microsoft.com/v2/_catalog | grep bicep
    "bicep/samples/hello-world",
    "bicep/samples/array-loop",
    "bicep/compute/availability-set",
    "bicep/deployment-scripts/import-acr",
    "bicep/network/virtual-network",
```

そうなると、tagが違うのかもしれないので、タグを見る。1.0というのは無くて、1.0.1になっているのがわかる。

```sh
$ curl -s https://mcr.microsoft.com/v2/bicep/network/virtual-network/tags/list
{
  "name": "bicep/network/virtual-network",
  "tags": [
    "1.0.1"
  ]
}
```

これを使うことにして、モジュールのパスを `'br/public:network/virtual-network:1.0.1'` に変更する。subnetの定義を入れると、[こんな感じ](https://github.com/takekazuomi/azure-bastion01/blob/v1.1.0/deploy/vnet.bicep#L10-L21)になる。

```bicep
module vnet 'br/public:network/virtual-network:1.0.1' = {
  name: '${uniqueString(deployment().name, location)}-vnet'
  params: {
    name: virtualNetworkName
    location: location
    addressPrefixes: [
      addressPrefix
    ]
    subnets: subnets
  }
}
```

もう１つ変更がある。このVNetのモジュールでは、subnetで受け付ける形式が、ARM ネイティブと少し違う。もともとは、`properties.addressPrefix`のようになってた部分を、`properties` を省略して１つレベルを上げて書く。これは、vnet public module の実装に依存するが、おそらくデザインパターンとして統一しているのでは無いかと思う。このあたりは、未確認。

```json
"name": "subnet",
"properties": {
  "addressPrefix": "10.1.0.0/24",
```

vnet public moduleの場合

```json
"name": "subnet",
"addressPrefix": "10.1.0.0/24",
```

こんな感じで修正すればデプロイできる。

## 最後に

ちょっとドキュメントの更新が追いついていないのか、初見殺しの部分があるが、VSCodeのプラグインでレポジトリのブラウズができるようにするなどの工夫で十分使えるようなりそうに思う。もっとモジュールが増えるのを期待している。それまでは、[Common Azure Resource Modules Library](https://github.com/Azure/ResourceModules)を有効利用することになるだろう。
