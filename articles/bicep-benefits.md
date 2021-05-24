---
title: "ARM tempate DSL、Bicep の６つの利点"
emoji: "💪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["azure", "arm", "bicep"]
published: false
---

この記事は、前半に[bicep FAQ](https://github.com/Azure/bicep#faq) に記載されている`**Bicepのユニークな利点はなんですか？` の引用。後半に個人的なコメントの構成になっています。

## bicep FAQより

**Bicepのユニークな利点はなんですか？**
1. Day 0 リソースプロバイダー サポート。すべてのAzure リソース (private, public preview, GA)は、Bicepを使用してプロビジョニングできます。
2. [同等のARMテンプレートJSONと比較](https://github.com/Azure/bicep/blob/main/docs/arm2bicep.md)して、はるかに単純な構文です。
3. state や state files を管理する必要はありません。すべての状態がAzureに保存されるため、コラボレーションが簡単になり、リソースの変更が確実になります。
4. ツールの支援(Tooling)は、プログラミング言語での素晴らしい経験の基礎です。BicepのVSCode拡張機能を使用すると、すべてのAzureリソースタイプ[API definitions](https://github.com/Azure/azure-rest-api-specs/tree/master/specification)に基づいて、高度なタイプ検証を非常に簡単に利用できます。
5. コードを簡単に native [modules](https://github.com/Azure/bicep/blob/main/docs/spec/modules.md)に分解できます。
6. Microsoftサポートプランによってサポートされており、100％無料で使用できます。

:::details 上記原文

[bicep FAQ](https://github.com/Azure/bicep#faq) より

**What unique benefits do you get with Bicep?**

1. Day 0 resource provider support. Any Azure resource — whether in private or public preview or GA — can be provisioned using Bicep.
2. Much simpler syntax [compared to equivalent ARM Template JSON](https://github.com/Azure/bicep/blob/main/docs/arm2bicep.md)
3. No state or state files to manage. All state is stored in Azure, so makes it easy to collaborate and make changes to resources confidently.
4. Tooling is the cornerstone to any great experience with a programming language. Our VS Code extension for Bicep makes it extremely easy to author and get started with advanced type validation based on all Azure resource type [API definitions](https://github.com/Azure/azure-rest-api-specs/tree/master/specification).
5. Easily break apart your code with native [modules](https://github.com/Azure/bicep/blob/main/docs/spec/modules.md)
6. Supported by Microsoft support and 100% free to use.
:::

## コメント

ここからは、私見です、bicep チームの公式見解ではありませんので、そのつもりで読んでください。

最初に書いてある、**Day 0 RP サポート** [^1]は、bicepの大きな特徴の１つだ。bicep は、ARM Template にトランスパイルされて実行される仕組みなので、すべてのRPが公開次第使えるようになる。ツールでサポートされるようになるのを待ったり、PR[^2]を書く必要はない。
これは、素晴らしいのですが、少し注意する点があります、新しいRPだと

----
[^1]: RPはリソースプロバイダーの略称です。Azure関連では割とよく出てきます。
[^2]: PRはpull requestの略称です。GitHub関連では割とよく出てきます。

