---
title: "FASTER"
emoji: "💪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["algorithm", "faster", "紹介"]
published: true
---


---
[^1]: Bicep は、ARM Tempateに変換して実行されるため。元々、ARM Tempateで不可能なことは出来ない。例えば、ARM Runtimeの機能不足としては、[nested property loops](https://github.com/Azure/bicep/discussions/1280)とか、RPの機能不足 は[このあたり](https://github.com/Azure/bicep/issues?q=is%3Aissue+is%3Aopen+label%3A%22provider+improvement%22)、[RPのBUG](https://github.com/Azure/bicep/issues?q=is%3Aissue+is%3Aopen+label%3A%22provider+bug%22)とか、制限で気になるは、[テンプレートが実行されるタイミングで値が決定されている必要があるとか](https://github.com/Azure/bicep/issues/2394#issuecomment-826527968)などいろいろある。これらの部分は、ARM Template/Runtime/RP が改善されていくことになるだろう。
[^2]: ARM Tempateでは、文字列の最初に`[`が来て、最後に`]`来るような文字列に[テンプレートの式](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-expressions)を埋め込める。エスケープする場合、例えば、`[test value]`のような文字列にしたい場合は、`"[[test value]"` のように書く。
[^3]: 現行の構文だと改行の有無に左右される部分が少々多く、もっと構文上改行ルールの制限を減らそうという議論が、[Make the language "less" newline sensitive #146](https://github.com/Azure/bicep/issues/146)で進んでいる。例えば、今は配列リテラルでは必ず改行で要素を区切る必要がある [#498](https://github.com/Azure/bicep/issues/498)、また複数に分けて書けない部分もある。
[^4]: 文字列のエスケープルールは、[ここ](https://github.com/Azure/bicep/blob/main/docs/spec/bicep.md)
[^5]: Language Server、平たく言うと、 [Bicep VS Code extension](https://github.com/Azure/bicep/blob/main/docs/installing.md#bicep-vs-code-extension)、[neovim](https://github.com/Azure/bicep/issues/1141#issuecomment-749372637)でも動くらしい。
[^6]: [ARM Template syntax and the native Bicep equivalent](https://github.com/Azure/bicep/blob/main/docs/arm2bicep.md#arm-template-syntax-and-the-native-bicep-equivalent)も参考になる。