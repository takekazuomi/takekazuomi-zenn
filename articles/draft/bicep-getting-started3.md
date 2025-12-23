---
title: "ARM tempate DSL、Bicep を使おう(3)"
emoji: "💪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["azure", "arm", "bicep", "入門", "bicep入門"]
published: false
---

# 概要

本稿は、[Bicep を使おう(1)](https://zenn.dev/takekazuomi/articles/bicep-getting-started)、[Bicep を使おう(2)](https://zenn.dev/takekazuomi/articles/bicep-getting-started2)の続きで３回目。

Bicep が、ARM Template を比較して特徴すべく便利な点は、module と loop だ。Bicepは、汎用的な言語では無い。これがどんなことを意味するかを少し掘り下げてみる。

普通の汎用的な言語は、最低でも下記の機能を持つ。プリミティブな型を組み合わせてデータ構造を定義でき、条件分岐、繰り返しを持ち、関数やメソッドで処理をまとめて書ける。

1. データ構造定義(type/struct)
2. 制御構造(if/loop)
3. 関数(function/method)

現在のBicepでは、データ構造定義はできない。これはなかなか不便だが、実装される見込みはたってない。[^1] 元々、ARM Tempateには無い機だし、型システムを持つことになるので大掛かりな変更になるのだろう。制御構造に関しては、元々、ARM Tempateにある、condition と copy loop を生成する構文が用意されている。関数に相当する機能も無いが、処理をまとめるという意味では、module を使うと似たようなことができる。
元々、宣言型な言語（表現）でのループは、再帰定義とか相関サブクエリーで書いたりとか手続き型とは大きく違うことになり、頭を悩ませることになる場合が多く鬼門だ。その点、Bicepの構文はわりと分かりやすい。

Bicepのターゲットは汎用のプログラミング言語では無い[^1]ので、出来ないことを無理にしようと思わないことも重要だ。このあたりを頭に入れつつ、本稿は、loop と module を見ていく。

[![red leaf](https://live.staticflickr.com/65535/49121168526_80689c0490_z.jpg)](https://www.flickr.com/photos/takekazuomi/49121168526)

## 単純 loop

まずは、リソースを複数作成する。配列にストレージアカウント名をもらって、その数だけループしてストレージアカントを作成する。

```text:loop1.bicep
// ストレージアカウント名の配列
param storageAccounts array

resource sa 'Microsoft.Storage/storageAccounts@2021-02-01' = [for name in storageAccounts:{
  name: name
  location: resourceGroup().location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
}]
```

基本的な構文は、`resource シンボル名 'リソースタイプ' = [for 変数 in 配列:{<リソース定義>}]` のようになっている。`<リソース定義>`の部分では、`変数` にアクセスでき、上の例だと、`name: name` となっている部分に相当する。 `[]` の中に繰り返しを書いて評価後はリストになる感じは、python のリスト内包記法に似てる`[式 for 変数 in イテラブル]`、python だと`式`に相当する部分を、`:{<リソース定義>}` のように書いてるわけだ。[^2]

## インデックス loop

指定数分だけ繰り返し処理をさせることもできる、ここでは前置詞 `storagePrefix` と 数 `storageCount` をもらって、ストレージアカウントを作成している。`range()` を使って

```text:loop2.bicep
param storagePrefix array
param storageCount int

resource sa 'Microsoft.Storage/storageAccounts@2021-02-01' = [for i in range(0, storageCount):{
  name: '${storagePrefix}${i}'
  location: resourceGroup().location
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
}]
```

---
[^1]: custom typeの話。parameter でobjectを受け取る。または、outputでobjectを返す時に欲しい。[](https://github.com/Azure/bicep/issues/898)、これをやるのは大幅な改修がいるってことで進んでない。
[^2]: この比較はイマイチかもしれない。
