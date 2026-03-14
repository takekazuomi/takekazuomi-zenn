---
title: "我が古き友人、オブジェクト指向へ"
emoji: "🪞"
type: "idea"
topics: ["oop", "go", "プログラミング言語", "poem"]
published: false
publication_name: baleenstudio
---

## はじめに

初めてオブジェクト指向に触れたのは、Digitalk Smalltalk/Vで、30年以上前のことになる。アセンブラ、C、Smalltalk、C++、Java、C#、Goと渡り歩いてきた。入り口がSmalltalkだったせいで、自分のオブジェクト指向観には偏りがある。この記事もその偏りの上に書かれている。それを承知の上で読んでほしい。

コンピューターの中の世界と人間の世界には大きなギャップがあり、高級言語は、このギャップを大きく埋めてくれると感じていた。Intel 8051のROM解析のためにCでディスアセンブラを書いた時、半日程度で書けた感動は今でも覚えている。それまで、アセンブラが実用度最高で高級言語は興味深いが実用性には疑問を感じていた、それが覆った瞬間だ。しかし、高級言語では埋められない、人間の世界とコンピューターの世界の構造的な隔たりがある。Smalltalkを知り、オブジェクト指向という概念に触れて、ギャップの本質の1つに気がついた。コンピューターの中にモデルを構築し、それとインタラクションする。つまり、オブジェクトの世界は人が住んでる世界に似ている、という斬新な考えである。

ここでは、オブジェクト指向の歴史を辿りながら、OOPとは何だったのかを考えてみたい。

## 始まり：Simula

オブジェクト指向プログラミングの起源は、1960年代のノルウェーに遡る。Ole-Johan DahlとKristen NygaardがSimula 67[^simula]を設計し、クラス、継承、仮想手続きといった概念を導入した。シミュレーションの世界を階層的に記述するための道具であり、現実世界の構造をコードに写し取る試みだったと言える。

ここで生まれたのは、データと処理を1つにまとめて扱うというパラダイムである。それ以前のプログラミングでは、データ構造と手続きは別々に定義され、プログラマが両者の対応関係を頭の中で管理していた。Simulaはこの対応関係をコードの構造そのものに埋め込んだ。後にBjarne Stroustrupが「抽象データ型の次の段階」[^stroustrup-whatis]としてこの概念を発展させることになるが、その種はここに蒔かれている。

データと操作の統合という着想は、オブジェクト指向の系譜において一貫して受け継がれていく。しかし、この同じ根から、異なる木が育つことになる。

## 分岐：2つの系統

「オブジェクト指向プログラミング」という用語を作ったAlan Kayは、Simulaに深い影響を受けつつも、そこから異なる本質を汲み取った。Kayにとって重要だったのは継承ではなくメッセージングである。2003年のStefan Ram宛メール[^kay-email]で次のように述べている。

> OOP to me means only messaging, local retention and protection and hiding of state-process, and extreme late-binding of all things.
>
> （私にとってOOPとは、メッセージング、状態プロセスのローカルな保持・保護・隠蔽、そしてあらゆる事柄の極端に遅延したバインディング、それだけを意味する）

注目すべきは、1972年のSmalltalk-72には**継承が存在しなかった**という事実だ。Kayは"The Early History of Smalltalk" (1993)[^early-smalltalk]の中で次のように述べている。

> I decided to leave inheritance out as a feature in Smalltalk-72, knowing that we could simulate it back using Smalltalk's LISPlike flexibility.
>
> （私はSmalltalk-72の機能から継承を外すことにした。SmalltalkのLISP的な柔軟性があれば、継承をシミュレートして取り戻せると分かっていたからだ）

動的言語の柔軟性があれば継承は再現できる。だからこそ意図的に除外した。継承が追加されたのは1976年のSmalltalk-76においてであり、Dan IngallsがSimula的なクラス継承モデル[^early-smalltalk]を導入した。しかしKay自身はこの設計に満足していなかった。

> I was not completely thrilled with it because it seemed that we needed a better theory about inheritance entirely.
>
> （私はこれに完全には納得していなかった。継承についてはまったく新しい理論が必要だと思えたからだ）

それでも「より良い代替案が現れなかった」ために残された。同論文でKayは継承の本質的な問題も指摘している。

> Unfortunately, inheritance――though an incredibly powerful technique――has turned out to be very difficult for novices (and even professionals) to deal with.
>
> （残念ながら、継承は――きわめて強力な技法であるにもかかわらず――初心者にとっても、専門家にとってさえも、扱いがきわめて難しいものであることが判明した）

一方、1980年代にBjarne Stroustrupは別の道を切り拓く。SimulaのクラスとC言語の効率性を組み合わせたC++[^cpp]の誕生である。Stroustrupの貢献は、抽象データ型の延長線上にオブジェクト指向を位置づけ、型階層と継承によって現実世界の構造を表現する体系を築いたことにある。Kayがメッセージングと遅延バインディングに本質を見出したのに対し、Stroustrupはデータと操作の統合、そして型の階層的な組織化に力点を置いた。

同じSimulaという根から、2つの系統が育った。Kayの系統は「すべてはオブジェクト、メッセージで対話する」という世界観を追求し、Stroustrupの系統は「型階層でシステムを構造化する」という実践的な手法を発展させた。どちらもオブジェクト指向を名乗り、どちらも独自の洞察を持っている。この分岐そのものが、OOPに確固たる定義がない理由の1つだろう。

## 主流化と転換

1990年代、Javaの登場を経て、Stroustrup系の型階層アプローチが産業界の主流となる。教科書は「**カプセル化・継承・多態性**」を三本柱として定式化し、「is-a関係」で世界を分類することが、設計の作法とされた時代である。

しかし、大規模システムの現場で問題が噴出する。**脆弱な基底クラス問題**がその典型だ。基底クラスの一見無害な変更が、予期しない形でサブクラスを破壊してしまう。この問題はAlan Snyderが1986年のOOPSLA論文[^snyder]で既に指摘していたが、広く認識されたのは1990年代に入ってからだった。

転換点は1994年。GoFの『Design Patterns[^gof]』（Gamma, Helm, Johnson, Vlissides著、ISBN 0-201-63361-2）が明確に宣言する。

> Favor object composition over class inheritance.
>
> （クラス継承よりオブジェクト合成を優先せよ）

2001年にはJoshua Blochの『Effective Java[^effective-java]』が追い打ちをかけた。

> Inheritance is a powerful way to achieve code reuse, but it is not always the best tool for the job. Used inappropriately, it leads to fragile software.
>
> （継承は強力なコード再利用の手段だが、常に最善のツールではない。不適切に使うと、脆弱なソフトウェアにつながる）

Blochはさらに「継承のために設計し文書化するか、さもなければ継承を禁止せよ」とも述べている。

これらの警告を、失敗の物語として読むこともできる。しかし別の読み方もあるだろう。コミュニティが大規模な実践を通じて学び、合成とインターフェースという、より堅牢な設計原則に収束していった過程でもある。実装継承への過度な依存から離れ、振る舞いの契約による疎結合へ。それは挫折ではなく、成熟と呼ぶべき転換だったのではないか。

## もう1つの視角：データ抽象の2つの形

ここまで歴史と実践の流れを追ってきたが、理論の側からこの問題を照らした研究にも触れておきたい。テキサス大学のWilliam R. Cookが1990年[^cook1990]と2009年[^cook2009]に発表した2本の論文は、OOPの本質について鋭い洞察を含んでいる。教科書が「オブジェクトはADT（抽象データ型）の一種」と書くのは誤りであり、両者は根本的に異なるデータ抽象のメカニズムだと、Cookは論じた。

> Objects and abstract data types are not the same thing, and neither one is a variation of the other. They are fundamentally different and in many ways complementary, in that the strengths of one are the weaknesses of the other.
>
> （オブジェクトと抽象データ型は同じものではなく、一方が他方の変種でもない。両者は根本的に異なり、多くの点で相補的だ。一方の強みが他方の弱みとなる）

Cookの最も独創的な洞察は、データ抽象を「コンストラクタ × オブザーバ」の仕様行列として捉えた点にある。リストを例にとれば、コンストラクタは`nil`（空リスト）と`cons`（要素の追加）、オブザーバは`isEmpty`、`head`、`tail`だ。この行列をどちらの方向に分解するかで、2つのまったく異なるプログラミングモデルが生まれる。

ADTは行列を行（オブザーバ）ごとに分解する。各関数がパターンマッチで全てのデータバリアントを処理する形だ。`isEmpty`関数は`nil`なら`true`、`cons`なら`false`を返すように書く。一方、オブジェクト指向――Cookの用語で**手続的データ抽象（Procedural Data Abstraction, PDA）**――は列（コンストラクタ）ごとに分解する。`nil`オブジェクトが`isEmpty`、`head`、`tail`の全メソッドを持ち、`cons`オブジェクトもまた全メソッドを持つ。

この直交する分解方向が、拡張性に決定的な非対称性をもたらす。ADTでは新しい操作の追加は容易だが、新しいデータバリアントの追加には既存の全関数を修正しなければならない。PDAではその逆で、新しいクラスの追加は容易だが、新しいメソッドの追加は全クラスに波及する。Philip Wadlerが後に「Expression Problem」と名づけた問題の核心が、ここにある。

Cookはさらに、**自己認識原理（Autognosis）**という概念を導入した。オブジェクトは自分自身の内部だけを知り、他のオブジェクトは公開インターフェースを通じてしか扱えない。対照的に、ADTでは同じ型の複数の値の内部表現を同時に検査できる。だからこそ`equal`や`union`のような二項操作を効率的に実装できるのだ。この区別から、ファイルやGUIコンポーネントのように単一の値に対する操作で完結するものはオブジェクトが適切で、数や集合のように複数の値を横断する操作が必要な型はADTが適切だという実践的な指針が導かれる。

そして、この記事の文脈で最も重要なのは、Cookの継承に対する見解だろう。

> Inheritance is often mentioned as one of the essential characteristics of object-oriented programming. However, inheritance will not be used in this section because it is neither necessary for, nor specific to, object-oriented programming.
>
> （継承はしばしばオブジェクト指向プログラミングの本質的な特徴として挙げられる。しかし、このセクションでは継承は扱わない。継承はオブジェクト指向プログラミングに必要でも固有でもないからだ）

Cookにとって、OOPの本質は手続的抽象化――つまりクロージャのレコード――であり、継承はその上に構築される付加的な機構にすぎない。この理論的分析は、GoFやBlochが実践の中から導き出した「合成を優先せよ」という教訓と、見事に符合している。

Cookはまた、現実の言語がADTとPDAを混在させていることも指摘した。Javaでクラス名を型として使えばADT的に機能し、インターフェースを型として使えばPDA的に機能すると。この視点から見ると、Go、Rust、Kotlinといった言語が体現しているのは、型の抽象化（ADT的）と手続き的抽象化（PDA的）の融合であり、そこに実装継承は含まれていない。これらの言語は、単にOOPの遺産を継いだのではなく、データ抽象の2つの形態を継承なしに再統合したと見ることもできるのだ。

## 名前のない成熟

2000年代後半から2010年代にかけて、新しい世代の言語が登場する。Go[^go]、Rust[^rust]、Kotlin[^kotlin]に共通するのは、実装継承を排除するか厳しく制限する設計方針だ。

Rob Pikeは2012年の講演"Less is Exponentially More"[^pike-less]でこう述べている。

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

「何であるか（is-a）」ではなく「何ができるか（can-do）」。Pikeは2020年のEvrone誌インタビュー[^pike-evrone]で、「型駆動プログラミング、型階層、クラスと継承のファンではない」と述べている。型階層に基づくアプローチは、重要な設計上の決定を経験が蓄積される前の早い段階で固定化してしまう。それがその理由だ。

Rustもまた古典的継承を持たず、トレイトシステム[^rust-traits]で多態性を実現している。継承による型階層を持たず、`class`キーワードすら存在しない。GoもRustも「オブジェクト指向言語」を名乗っていない。

Kotlinの立場はやや異なる。Javaエコシステム内の新しい言語である以上、互換性のために`class`を必要とする。しかしクラスをデフォルトでfinal[^kotlin-final]とし、継承には明示的な`open`宣言を要求する設計は、実装継承よりも合成を志向する意思表明だ。Kotlinはオブジェクト指向を公式に特徴の1つとして掲げているが、その内実は古典的なOOP言語とは明らかに異なる。

Cookが示し、GoFやBlochが実践から導いたように、継承はOOPに必要でも固有でもない。この認識は今日では広く受け入れられている。では、OOPから型階層を外したものを何と呼ぶのか。特定の名前はない。OOP絶対主義の時代はだいぶ前に終わり、その中で学ばれた知見は多い。新しい世代の言語は、最初から不要な部分を削ぎ落としている。

いずれの言語も、オブジェクト指向が数十年の実践を通じて蒸留した設計原則を宿している。名前を継がなかったか、名乗り方を変えたかの違いはあっても、その精神は形を変えて残っている。

「OOPの終焉」と言われることがある。しかし終わったのは名前であって、考え方ではない。かつてオブジェクト指向と呼ばれた設計原則の多くが、あまりに当たり前のものとして言語に組み込まれ、もはやわざわざ名前を付ける必要がなくなった。共通認識として成熟した、というのが実態に近い。

## 結び：わが友へ

Go公式FAQ[^go-faq]はこう答えている。

> Yes and no. Although Go has types and methods and allows an object-oriented style of programming, there is no type hierarchy.
>
> （イエスでもありノーでもある。Goは型とメソッドを持ち、オブジェクト指向スタイルのプログラミングを可能にするが、型階層は存在しない）

「GoはOOPか」という問いに、明快な答えはない。しかし、ここまで辿ってきた歴史を振り返ると、この問い自体があまり意味を持たないことに気づく。OOPには確固たる定義がない。Kayにとってはメッセージング、Stroustrupにとってはデータと操作の統合、教科書にとってはカプセル化・継承・多態性。どれも正しく、どれも全体像ではない。OOPは理論から演繹された体系ではなく、現場の格闘から帰納的に生まれたものだからだ。

Goにないのは`class`キーワードと型階層だ。データに振る舞いを紐づけ、インターフェースで抽象化し、合成で構造を組み立てる。Stroustrupがデータと操作をまとめて扱う仕組みとして始めたものの本質は、形を変えて確かに生きている。

オブジェクト指向は、30年以上一緒に歩いてきた古い友人だ。かつての名前では呼ばれなくなっても、その教えは今書くコードの中に息づいている。わが友は死んでいない。名前が静かに溶けただけで、心は生きている。

「Goにはクラスが無いのですね」と聞かれ、型階層と継承、そしてオブジェクト指向の本質とは何かを答えたかったのだが、口頭で話すには長すぎる。だからこの記事を書いた。

[^simula]: Simula 67 - 1967年にノルウェーのNorwegian Computing CenterでOle-Johan DahlとKristen Nygaardが開発したオブジェクト指向の祖。シミュレーション記述のためにクラス・継承・仮想手続きの概念を導入し、後続のすべてのOOP言語に影響を与えた。<https://en.wikipedia.org/wiki/Simula>
[^stroustrup-whatis]: Bjarne Stroustrup, "What is Object-Oriented Programming?" (1991)。プログラミングパラダイムを手続き型→データ隠蔽→データ抽象→OOPと段階的に整理し、継承＋仮想関数をOOPの要件と定義した分水嶺的論文。この定義がOOPにおける継承中心の理解を広めた。<https://www.stroustrup.com/whatis.pdf>
[^kay-email]: Alan Kay, Stefan Ram宛メール (2003)。OOPの定義論争で最も広く引用される一次資料の一つ。Kayは継承ではなくメッセージングこそがOOPの本質であると明言し、Smalltalk設計時の意図を直接語っている。<http://www.purl.org/stefan_ram/pub/doc_kay_oop_en>
[^early-smalltalk]: Alan Kay, "The Early History of Smalltalk" (1993)。ACM SIGPLAN Notices掲載の回顧録。Smalltalk-72から-76、-80への変遷と各バージョンでの設計判断を詳述し、メッセージングを中心に据えた設計思想の原点を記録している。<http://worrydream.com/EarlyHistoryOfSmalltalk/>
[^cpp]: C++ - Bjarne Stroustrupが1979年から開発。当初「C with Classes」の名称で、1985年に初版をリリース。Simula由来のクラス・継承とCのゼロオーバーヘッド原則を両立させ、OOPの産業界への普及を決定づけた。<https://en.wikipedia.org/wiki/C%2B%2B>
[^snyder]: Alan Snyder, "Encapsulation and Inheritance in Object-Oriented Programming Languages" (OOPSLA 1986)。脆弱な基底クラス問題を学術的に初めて体系的に分析した論文の一つ。継承がカプセル化を破壊する問題を早期に指摘し、後のGoF本「合成優先」原則の理論的基盤となった。<https://dl.acm.org/doi/10.1145/960112.28702>
[^gof]: Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides, "Design Patterns: Elements of Reusable Object-Oriented Software" (1994, ISBN 0-201-63361-2)。通称「Gang of Four本」。「クラス継承よりオブジェクト合成を優先せよ」はOOP設計原則で最も影響力のある提言の一つであり、現代の言語設計にも影響を及ぼしている。<https://en.wikipedia.org/wiki/Design_Patterns>
[^effective-java]: Joshua Bloch, "Effective Java" (初版2001)。Javaの実践的設計指針を体系化した名著。Item 18「継承よりコンポジションを選ぶ」とItem 19「継承のために設計し文書化するか、さもなければ禁止せよ」は、後のKotlinのデフォルトfinal設計にも直接影響を与えた。<https://en.wikipedia.org/wiki/Effective_Java>
[^cook1990]: William R. Cook, "Object-Oriented Programming Versus Abstract Data Types" (REX Workshop, LNCS 489, 1990)。REX School/Workshop "Foundations of Object-Oriented Languages"での発表。行列分解モデルを用いてADTとPDA（手続き的データ抽象＝オブジェクト）の直交性を示し、OOPとADTの根本的な違いを論証した。<https://www.cs.utexas.edu/~wcook/papers/OOPvsADT/CookOOPvsADT90.pdf>
[^cook2009]: William R. Cook, "On Understanding Data Abstraction, Revisited" (OOPSLA 2009)。OOPSLA 2009 Onward! Essaysに採択された1990年論文の再訪と精緻化。Autognosis（自己認識）原理を導入し、Java・Haskell等の実践言語での検証を通じてオブジェクトとADTの区別をより明確にした。<https://www.cs.utexas.edu/~wcook/Drafts/2009/essay.pdf>
[^go]: Go - Robert Griesemer、Rob Pike、Ken Thompsonが設計し、Googleが2009年に公開。クラスと継承を意図的に排除し、合成と暗黙的インターフェース（構造的型付け）を基本とする静的型付け言語。<https://go.dev/>
[^rust]: Rust - Graydon Hoareが設計を開始し、Mozillaの支援のもと2015年に1.0をリリース。所有権システムによるメモリ安全性を特徴とし、クラスと継承を持たずトレイトで多態性を実現する言語。<https://www.rust-lang.org/>
[^kotlin]: Kotlin - JetBrainsが2011年に公開し、2016年に1.0をリリース。2019年にGoogleがAndroid公式言語として推奨。JVM上で動作しJavaとの完全互換性を保ちつつ、クラスはデフォルトfinalとして継承をデフォルトで制限する設計を採用。<https://kotlinlang.org/>
[^pike-less]: Rob Pike, "Less is Exponentially More" (2012)。C++に対するアンチテーゼとしてGoが生まれた経緯を語った講演記録。型の祖先関係よりも「何ができるか」が重要であるという設計思想を表明している。<https://commandcenter.blogspot.com/2012/06/less-is-exponentially-more.html>
[^pike-evrone]: Rob Pike, Evrone誌インタビュー (2020)。型階層が設計初期に重要な決定を固定化してしまう問題を指摘し、Goが型階層を避ける理由と設計哲学を回顧している。<https://evrone.com/blog/rob-pike-interview>
[^rust-traits]: Rustのトレイトシステム。Haskellの型クラスに着想を得た仕組みで、継承なしに多態性を実現する。トレイト境界による静的ディスパッチとtraitオブジェクトによる動的ディスパッチの両方を提供する。<https://doc.rust-lang.org/book/ch10-02-traits.html>
[^kotlin-final]: Kotlinのクラスはデフォルトでfinal。継承にはopen宣言が必要。Effective Java Item 19「継承のために設計するか禁止せよ」を言語レベルで実装した設計判断であり、Javaのデフォルト非finalとは対照的なアプローチ。<https://kotlinlang.org/docs/inheritance.html>
[^go-faq]: Go公式FAQ "Is Go an object-oriented language?"。型とメソッドによるOOPスタイルのプログラミングは可能だが型階層は存在しないと公式に回答。Goのインターフェースが他言語の型階層とは異なるアプローチであることを説明している。<https://go.dev/doc/faq#Is_Go_an_object-oriented_language>
