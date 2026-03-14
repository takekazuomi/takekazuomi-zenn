---
title: oop reference
---

## OOPとはなにかの議論

日本語（5本）

1. https://qiita.com/hirokidaichi/items/591ad96ab12938878fe1
Simula、Smalltalk、C++、Javaと辿るOOPの歴史。Alan Kayのメッセージング思想にも言及。
2. https://qiita.com/shibukawa/items/2698b980933367ad93b4
長年の実務経験からOOPの本質を問い直すエッセイ。継承の問題点と合成の優位性を論じている。
3. https://ubiteku.wordpress.com/2016/05/09/what-is-oo-all-about/
Kayの原初の思想とC++/Java以降の「三本柱」的OOPの乖離を考察。
4. https://note.com/minato_kame/n/n164a9eeeed2a
Go・Rustがクラスと継承を排除した設計思想の背景を掘り下げている。
5. https://postd.cc/is-go-object-oriented/
Goが型階層なしでOOP的プログラミングを実現する仕組みの解説。

英語（5本）

6. https://medium.com/javascript-scene/the-forgotten-history-of-oop-88d71b9b2d9f
Alan Kayのメッセージング思想が忘れられ、継承中心のOOPが広まった経緯。記事と最も近いテーマ。
7. https://lesleylai.info/en/fifty_shades_of_oop/
OOPを11の個別概念に分解し、各機能の利点・欠点を独立に検討。定義論争を超えた実用的分析。
8. https://www.hillelwayne.com/post/alan-kay/
Kayの貢献と限界を歴史的資料に基づいて検証。SimulaとSmalltalkの関係を再考。
9. https://spf13.com/p/is-go-an-object-oriented-language/
Go共同設計者Steve Franciaによる、GoのOOP的側面の詳細な分析。
10. https://yourbasic.org/golang/inheritance-object-oriented/
Goが継承なしでOOPを実現する具体的パターン（インターフェース、埋め込み、合成）の解説。


## 継承がOOPの中心に据えられた経緯を分析する記事

定義の転換点：Stroustrupの再定義

1. https://stroustrup.com/whatis.pdf
プログラミングパラダイムを手続き型→データ隠蔽→データ抽象→OOPと段階的に整理し、「OOPとは継承を使ったプログラミングである」と定義。継承＋仮想関数なしの言語は「データ抽象」に留まると主張。OOP定義の分水嶺となった論文。
2. https://lesleylai.info/en/fifty_shades_of_oop/
OOPを構成する個別機能（継承、動的ディスパッチ、メッセージパッシング等）を分解して検討。継承の利点と欠点を他の概念と独立に分析。
3. http://stereobooster.github.io/two-big-schools-of-object-oriented-programming
OOPの「Kay派」（メッセージング中心）と「Stroustrup派」（継承・抽象化中心）の二大系統を対比。両学派の起源と設計思想の違いを整理。

継承の神話化と批判

4. https://thevaluable.dev/guide-inheritance-oop/
継承の歴史（Simula→Smalltalk→C++→Java）を辿りつつ、実践的な使い分けガイドラインを提示。Kayが初期Smalltalkから意図的に除外していた事実にも言及。
5. https://avivcarmi.com/the-tragic-death-of-inheritance/
5年間のGo開発経験を通じ、継承重視から合成重視への転換を綴ったエッセイ。可読性と保守性が継承の優美さに勝ることを実感で論証。
6. https://www.sicpers.info/2025/11/when-did-people-favor-composition-over-inheritance/
「合成優先」の原則がいつ・どのように主流化したかのタイムライン分析。1994年のGoF本での提唱から、Go/Rust世代で言語レベルの設計原則になるまでの変遷。

日本語の分析記事

7. http://eed3si9n.com/ja/oop/
Stroustrupの定義を慎重に読み解き、「字面ではOOPと継承を等価に扱っていない」と指摘。Kay定義との乖離を分析しつつ、C++のアプローチをSimula継承モデルの実用的再解釈と評価。
8. https://sumim.hatenablog.com/entry/20040525/p1
Kay、Nygaard/Dahl、Stroustrupそれぞれのオブジェクト指向の定義を原典に基づいて比較。継承がSimula由来の概念であり、Kayの思想では本質ではなかったことを論証。
9. https://ubiteku.wordpress.com/2016/05/09/what-is-oo-all-about/
Kayのメッセージング中心の思想がC++/Java以降の「三本柱」的OOPに置き換わっていった過程を考察。
10. https://plainprogram.com/is-inheritance-evil/
継承がOOPの柱として重視された経緯と、現代の言語設計で再評価されている状況を整理。

