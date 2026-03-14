---
title: "わが友、オブジェクト指向"
emoji: "🪞"
type: "idea"
topics: ["oop", "go", "プログラミング言語", "エッセイ"]
published: false
publication_name: baleenstudio
---

## はじめに

Goはオブジェクト指向言語なのかは繰り返し議論されるテーマである。初めてオブジェクト指向に触れたのは、Digitalk Smalltalk/Vで、30年以上前のことになる。アセンブラ、C、Smalltalk、C++、Java、C#、Goと渡り歩いてきた。

コンピューターの中の世界と人間の世界には大きなギャップがあり、高級言語は、このギャップを大きく埋めてくれると感じていた。Intel 8051のROM解析のためにCでディスアセンブラを書いた時、半日程度で感動は今でも覚えている。それまで、アセンブラが実用度最高で高級言語は興味深いが実用性には疑問を感じていた、それが覆った瞬間だ。

高級言語では埋められない、人間の世界とコンピューターの世界の構造的な隔たりがある。Smalltalkを知り、オブジェクト指向という概念に触れて、ギャップの本質の１つに気がついた。コンピューターの中にモデルを構築し、それとインタラクションする。オブジェクトの世界は人間の住んでる世界に似ている、という斬新な考えである。後にSmalltalkがSimulaというシミュレーション言語から発想されたと知り、コンピューターの中に人が理解できるモデルを作ることでギャップを埋める、それがOOPなのだと腑に落ちた。

ここでは、オブジェクト指向の歴史を辿りながら、その定義の変遷を振り返ってみたい。

## テーゼ：夢

オブジェクト指向プログラミングの起源は、1960年代のノルウェーに遡る。Ole-Johan DahlとKristen Nygaardが[Simula 67](https://en.wikipedia.org/wiki/Simula)を設計し、クラス、継承、仮想手続きといった概念を導入した。シミュレーションの世界を階層的に記述するための道具であり、現実世界の構造をコードに写し取る試みだったと言える。

一方、「オブジェクト指向プログラミング」という用語を作ったAlan Kayは、Simulaに深い影響を受けつつも、そこから異なる本質を汲み取った。Kayにとって重要だったのは継承ではなくメッセージングである。[2003年のStefan Ram宛メール](http://www.purl.org/stefan_ram/pub/doc_kay_oop_en)で次のように述べている。

> OOP to me means only messaging, local retention and protection and hiding of state-process, and extreme late-binding of all things.
>
> （私にとってOOPとは、メッセージング、状態プロセスのローカルな保持・保護・隠蔽、そしてあらゆる事柄の極端に遅延したバインディング、それだけを意味する）

注目すべきは、1972年のSmalltalk-72には**継承が存在しなかった**という事実だ。Kayは["The Early History of Smalltalk" (1993)](http://worrydream.com/EarlyHistoryOfSmalltalk/)の中で次のように述べている。

> I decided to leave inheritance out as a feature in Smalltalk-72, knowing that we could simulate it back using Smalltalk's LISPlike flexibility.
>
> （私はSmalltalk-72の機能から継承を外すことにした。SmalltalkのLISP的な柔軟性があれば、継承をシミュレートして取り戻せると分かっていたからだ）

動的言語の柔軟性があれば継承は再現できる――だからこそ意図的に除外した。継承が追加されたのは1976年のSmalltalk-76においてであり、Dan Ingallsが[Simula的なクラス継承モデル](http://worrydream.com/EarlyHistoryOfSmalltalk/)を導入した。しかしKay自身はこの設計に満足していなかった。

> I was not completely thrilled with it because it seemed that we needed a better theory about inheritance entirely.
>
> （私はこれに完全には納得していなかった。継承についてはまったく新しい理論が必要だと思えたからだ）

それでも「より良い代替案が現れなかった」ために残された。Kayは同論文で継承の本質的な問題も指摘している。

> Unfortunately, inheritance――though an incredibly powerful technique――has turned out to be very difficult for novices (and even professionals) to deal with.
>
> （残念ながら、継承は――きわめて強力な技法であるにもかかわらず――初心者にとっても、専門家にとってさえも、扱いがきわめて難しいものであることが判明した）

この経緯を見ると、継承はOOPの本質というより、実用上の妥協から後に加わったものと考えられる。

Smalltalkが描いたのは、「すべてはオブジェクト」「メッセージパッシング」というビジョンである。計算の世界をオブジェクト同士の対話として捉え、プログラムを自律したオブジェクト間の協調として構成する。型の階層や手続きの列挙とは異なる、新しいプログラミングの見方を提示したと言えるだろう。

## アンチテーゼ：現実

1980年代、Bjarne StroustrupがSimulaの概念を[C言語に移植してC++](https://en.wikipedia.org/wiki/C%2B%2B)を生み出した。1990年代にはJavaが登場し、これらの言語を通じてオブジェクト指向は企業システム開発の主流パラダイムとなる。教科書は「**カプセル化・継承・多態性**」を三本柱として定式化し、型階層を設計の基本原理に据えた。「is-a関係」で世界を分類することが設計の作法とされた時代である。

しかし、大規模システムの現場で問題が噴出する。まず**脆弱な基底クラス問題**がある。基底クラスの一見無害な変更が、予期しない形でサブクラスを破壊してしまう。この問題はAlan Snyderが[1986年のOOPSLA論文](https://dl.acm.org/doi/10.1145/960112.28702)で既に指摘していたが、広く認識されたのは1990年代に入ってからだった。さらに**ダイヤモンド問題**がある。C++が1989年に多重継承を導入した結果、仮想継承という複雑な仕組みが必要となり、正しく使うことの困難さが明らかになった。

転換点は1994年。GoFの『[Design Patterns](https://en.wikipedia.org/wiki/Design_Patterns)』（Gamma, Helm, Johnson, Vlissides著、ISBN 0-201-63361-2）が明確に宣言する。

> Favor object composition over class inheritance.
>
> （クラス継承よりオブジェクト合成を優先せよ）

2001年にはJoshua Blochの『[Effective Java](https://en.wikipedia.org/wiki/Effective_Java)』が追い打ちをかけた。

> Inheritance is a powerful way to achieve code reuse, but it is not always the best tool for the job. Used inappropriately, it leads to fragile software.
>
> （継承は強力なコード再利用の手段だが、常に最善のツールではない。不適切に使うと、脆弱なソフトウェアにつながる）

Blochはさらに「継承のために設計し文書化するか、さもなければ継承を禁止せよ」とも述べている。OOPの中心概念であったはずの継承が、実は取り扱い注意の手段であるという認識が、Javaコミュニティを中心に広く浸透していった。この認識は、次の世代の言語設計に大きな影響を与えることになる。

## ジンテーゼ：解体と再構成

2000年代後半から2010年代にかけて、新しい世代の言語が登場する。[Go](https://go.dev/)、[Rust](https://www.rust-lang.org/)、[Kotlin](https://kotlinlang.org/)に共通するのは、継承を排除するか厳しく制限する設計方針だ。OOPの「解体と再構成」とも呼べる動きである。

とりわけGoの設計思想は明快だ。Rob Pikeは2012年の講演["Less is Exponentially More"](https://commandcenter.blogspot.com/2012/06/less-is-exponentially-more.html)でこう述べている。

> If C++ and Java are about type hierarchies and the taxonomy of types, Go is about composition. [...] What matters isn't the ancestor relations between things but what they can do for you.
>
> （C++とJavaが型階層と型の分類学に関するものだとすれば、Goは合成に関するものだ。[…] 重要なのは物事の祖先関係ではなく、それらが何をできるかだ）

Goの回答は徹底している。クラスなし、継承なし、型階層なし。代わりに提供されたのは、構造的型付けによる暗黙的インターフェースと、埋め込みによる合成である。

```go
// Goにはクラスがない。あらゆる型にメソッドを定義できる
type Writer interface {
    Write(p []byte) (n int, err error)
}

// 明示的なimplements宣言は不要
// メソッドを実装していれば、自動的にインターフェースを満たす
```

「何であるか（is-a）」ではなく「何ができるか（can-do）」。この転換は、Kayのメッセージング重視の思想と通じる部分があるように見える。型の祖先関係に縛られず、振る舞いによって関係が決まる世界だ。Pikeは[2020年のEvrone誌インタビュー](https://evrone.com/blog/rob-pike-interview)で、「型駆動プログラミング、型階層、クラスと継承のファンではない」と述べている。型階層に基づくアプローチは、重要な設計上の決定を経験が蓄積される前の早い段階で固定化してしまう、というのがその理由だ。

Rustもまた古典的継承を持たず、[トレイトシステム](https://doc.rust-lang.org/book/ch10-02-traits.html)で多態性を実現している。Kotlinはクラスをデフォルトで[final](https://kotlinlang.org/docs/inheritance.html)とし、継承には明示的な`open`宣言を要求する。これらの言語に共通するのは、継承の産業的利用で得られた教訓を言語設計に織り込んだことだと言えるだろう。

## コーダ：わが友へ

オブジェクト指向は死んだのか。この問いに対する[Go公式FAQ](https://go.dev/doc/faq#Is_Go_an_object-oriented_language)の回答が示唆的である。

> Yes and no. Although Go has types and methods and allows an object-oriented style of programming, there is no type hierarchy.
>
> （イエスでもありノーでもある。Goは型とメソッドを持ち、オブジェクト指向スタイルのプログラミングを可能にするが、型階層は存在しない）

GoもRustも、データに振る舞いを紐づけ、インターフェースで多態性を実現している。これをオブジェクト指向と呼ぶかどうかは定義次第だろう。「オブジェクト指向」という言葉が、Kayの夢、Stroustrupの工学、GoFの反省、Pikeの簡潔さなど、それぞれ異なるものを指して使われてきたこと自体が、この概念の多義性を物語っている。

一方で、その多義的な議論がもたらした恩恵は確かなものだ。「データと操作をまとめる」「インターフェースで抽象化する」「実装詳細を隠蔽する」。これらの知恵は、名前を変え形を変えて、あらゆる現代言語に息づいている。定義の揺れこそが、オブジェクト指向の豊かさなのかもしれない。

<!-- TODO: 著者の体験があれば追記 —— 30年の経験を踏まえた個人的な所感 -->
