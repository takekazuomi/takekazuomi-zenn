---
title: "Bicep 0.4 3つの新機能"
emoji: "💪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["azure", "arm", "bicep"]
published: false
---

//Build 2021 で出るかと思わせて、翌週(6/2)リリースとなった、待望の [Bicep v0.4 now available!](https://github.com/Azure/bicep/releases/tag/v0.4.1)。個人的な、目玉は下記５つ。最後は、いつかは来る話だったので、シカタガナイですが、手元の既存コードを直さないといけません。まあ、修正は簡単なので問題無いでしょう。::smirk::

1. Linter MVP、俗に言うリンター、エラーじゃないこっちがお勧めだよと教えてくれるやつ。ピットフォール回避に役立つ。
2. Resource snippets、よくあるパターンのコード断片集。定番コードをサクッと埋められる。
3. Resource and module scaffolding、必須パラメータをざっと出してくれるやつ。
4. Bicep visualizer、リソースをビジュアルに表示してくれるやつ。[armviz](http://armviz.io/)のbicep版。
5. 旧 parameter modifier 構文の廃止。これは機能ではない、、、

## 1. Linter MVP

随分前になるが、初めて使ったlintは、[Gimpel Software](https://www.gimpel.com/) の PC-lintだった、便利かなと思ったけどそれほど使い込まず。しかし今では、lint風のツール無しでは暮らせぬ毎日、bashでは、[shellchek](https://github.com/koalaman/shellcheck)、C#では、[R#](https://www.jetbrains.com/resharper/)、golangでは、[staticcheck](https://staticcheck.io/) とお世話になりっぱなしだ。今回、bicepでも、[Linter](https://github.com/Azure/bicep/blob/v0.4.1/docs/linter.md)が出た、今のところ [ルール](https://github.com/Azure/bicep/tree/v0.4.1/docs/linter-rules)は限られているが、これからが楽しみだ。

### ルール1. [Environment URL がハードコードされています](https://github.com/Azure/bicep/blob/v0.4.1/docs/linter-rules/no-hardcoded-env-urls.md)

### ルール2. [パラメータが使われていません](https://github.com/Azure/bicep/blob/v0.4.1/docs/linter-rules/no-unused-params.md)
### ルール3. [変数が使われていません](https://github.com/Azure/bicep/blob/v0.4.1/docs/linter-rules/no-unused-vars.md)
### ルール4. [文字列補間を使いましょう](https://github.com/Azure/bicep/blob/v0.4.1/docs/linter-rules/prefer-interpolation.md)
### ルール5. [secure parameter にデフォルトがあります](https://github.com/Azure/bicep/blob/v0.4.1/docs/linter-rules/secure-parameter-default.md)
### ルール6. [文字列補間は必要ありません](https://github.com/Azure/bicep/blob/v0.4.1/docs/linter-rules/simplify-interpolation.md)

### bicepsettings.jsonで設定できる話



## 2. Resource snippets

## 3. Resource and module scaffolding

## 4. Bicep visualizer

