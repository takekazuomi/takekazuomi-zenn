---
title: "手綱を握れ：AIコーディングで主導権を取り戻すためのハーネスの考え方"
emoji: "🐴"
type: "tech"
topics: ["ai", "ソフトウェアエンジニアリング", "tdd", "アーキテクチャ"]
published: false
---

# 手綱を握れ：AIコーディングで主導権を取り戻すためのハーネスの考え方

## はじめに

AIコーディングツールを導入した。コードは速く書ける。しかし気づけば、AIの出力のレビューに追われ、全体像が見えなくなり、以前よりも仕事が増えている。そういう経験はないだろうか。

METR（2025年7月）のランダム化比較試験は、この感覚に数字を与えた。経験豊富な開発者16名が246タスクに取り組んだ結果、AIツール使用時にタスク完了時間が**19%増加**した。開発者自身は24%速くなると事前予測し、実験後も20%速くなったと認識していた。知覚と現実の間に**約40ポイントの乖離**がある[^1]。

振り回されているのは、あなたの能力の問題ではない。**手綱なしで馬に乗っている**のだ。強力な馬は速く走るが、制御しなければ振り落とされる。2026年のコミュニティが「ハーネスエンジニアリング」と呼び始めたのは、この手綱の設計技術である。そしてその中身は、ソフトウェアエンジニアが長年磨いてきた技術の再活用だった。

本稿では、ハーネスとは何か、なぜ振り回されるのか、そしてどう主導権を取り戻すかを、コミュニティの議論に基づいて整理する。

---

## なぜ振り回されるのか：AIの構造的限界

### AIは「正しさ」を感じられない

人間のエンジニアに「本番で障害を出すな」と言えば、深夜に叩き起こされる恐怖が内発的な品質動機になる。コードを書くとき、「これが動かなかったら自分が困る」という感覚が、自然にコードの品質を引き上げる。

LLMにはこの感覚がない。1990年にStevan Harnadが提起した「シンボルグラウンディング問題」が示すように、LLMは世界との因果的接触を持たない。「雪は白い」というテキストのパターンは学習しているが、雪の冷たさを感じたことはない。同様に、「バグ」というトークンの使い方は知っているが、バグがもたらす3時間の徹夜を経験したことはない[^2]。Floridi, Jia, Tohmé（2025年12月）はこれを「認識論的寄生（epistemic parasitism）」と呼んだ。LLMは人間が既にグラウンディングしたテキストの統計的パターンを処理しているだけだ[^3]。

結果の重みを感じられない以上、AIは品質への内発的動機を持てない。だから外部から制約と検証を課す必要がある。つまりハーネスが要る。振り回されるのは、この外部構造なしにAIを使っているからだ。

### AIは「どこまでやるか」を判断できない

もう一つの構造的問題がフレーム問題だ。1969年にMcCarthyとHayesが提起したこの問題は、「何が関連し、何が無関連かを判断できない」というAIの根本的制約を指す[^17]。

人間は経験と制約で対処する。締切があるから「今日はここまで」と切り捨てる。責任範囲が決まっているから「それは別チームの仕事」と線を引く。Herbert Simonの「満足化」[^18]（最適解ではなく「十分に良い解」で打ち切る）が機能するのは、人間が「十分」を感じられるからだ。

AIにはこの「打ち切りの内的根拠」がない。境界を明示的に与えなければ、AIは無限に関連性を探索し続ける。あるいは逆に、文脈を見失って的外れな方向に走る。あなたが「この関数を修正して」と頼んだのに、AIが認証システム全体を書き換え始めた経験があるなら、それはフレーム問題の実例だ。

---

## ハーネスとは何か：新しい概念ではなく、古い技術の再発見

### 言葉の意味

「ハーネス」という言葉は日本では聞きなれないが、英語圏では複数の意味を持つ普通の言葉である。

**馬具**。手綱、鞍、轡（くつわ）の一式。強力だが予測不能な馬を、人間の意図した方向に導く装備であり、2026年のAI文脈で好まれる比喩だ。

**ワイヤリングハーネス**。自動車や航空宇宙で使われる配線アセンブリ。複数の電線を機能別に束ね、コネクタで接続し、保護スリーブで覆う。エンジン（テスト対象）を動かすための接続基盤であり、テスト時にはコネクタの先を本物のECUから計測器に差し替える。エンジンはその違いを知らない。

**テストハーネス**。ソフトウェアテストの文脈で1960年代のNASA Apolloに遡り、Glenford J. Myersの1979年の著書で体系化された概念である。テスト対象を本番インフラから隔離し、スタブ（依存先の偽物）とドライバ（呼び出し元の偽物）で囲んで、制御された環境で検証する[^4]。

3つに共通するのは、**対象そのものではなく、対象が動作する環境を設計する**という発想にある。

### 2026年のAIエージェントハーネス

2026年2月、Mitchell Hashimoto（HashiCorp共同創業者、Terraform作者）がブログ記事でこの概念に名前を与えた。エージェントがミスを犯すたびに、そのミスが二度と起きないようにエンジニアリングする。その営み全体をハーネスエンジニアリングと呼ぶ[^5]。

数日後、OpenAIが100万行超のプロダクションコードを手書きゼロで構築した実験を報告し[^6]、Martin Fowlerのサイトで Birgitta Böckeler（ThoughtWorks Distinguished Engineer）が分析記事を公開した[^7]。LangChainはモデルを一切変えずにベンチマークを52.8%から66.5%に改善した。**変えたのはハーネスだけだ**[^8]。

---

## あなたが既に知っている技術が武器になる

### 「人間に良いコードはAIにも良い」：実証データ

Borg & Tornhill（CodeScene）の研究 "Code for Machines, Not Just Humans"（2026年1月）は、5,000のPythonファイルを6つのLLMでリファクタリングし、**人間のために最適化されたコード品質指標（CodeHealth）がAIの成功率と有意に相関する**ことを実証した。不健全なコードでは欠陥リスクが30%以上高い。Tornhillの言葉で言えば「AIの時代において、健全なコードはもはやオプションではない」[^9]。

ThoughtWorksの2026年2月Deer Valleyリトリート（Agile Manifestoの誕生地で開催された）でも、この原則が合意された。

> **エージェントを助けるものは人間も助ける。** より良いインシデント対応プロセス、より明確なドキュメント、より強力なオブザーバビリティへの投資は、単なる「AI対応」施策ではない。最終的にすべての人にとってシステムをより運用しやすくする。

[^10]

これは重要なメッセージだ。AIに振り回されている人の多くは、新しいスキルを学ばなければならないと焦っている。しかし実際に必要なのは、**既に持っている技術（モジュール化、テスト、インターフェース設計、ドキュメント）の使い方を変えること**である。

### 境界の設計はフレーム問題を管理する

ソフトウェアエンジニアリングは、Dijkstraの構造化プログラミング以来50年以上にわたって「境界をどう引くか」の技術を磨いてきた。Parnasの情報隠蔽、EvansのBounded Context、マイクロサービスのAPI契約。これらは全て、人間の認知的制約を管理するための境界設計である。一度に考える範囲を限定し、モジュールの内側では意味を一貫させ、外側とはインターフェースだけで接触する。

人間にとって、この境界設計は複数ある対処法の一つにすぎない。経験豊富なエンジニアは、境界が曖昧でも直感と経験で「ここまで」と判断できる。しかし前節で見たように、AIにはこの内的根拠がない。したがってAIにとって境界は補助ではなく、フレーム問題への**唯一の外部的対処法**になる。Bounded Contextで分割されたサービスなら、「何が関連するか」の判断を人間がアーキテクチャとして事前に決定しており、AIはその境界の内側だけを世界として扱えばいい。`Customer`は常に一つの意味を持つ。探索空間が劇的に縮む。OpenAIのCodexチームはこれを「中央で境界を強制し、局所で自律を許す」と表現した[^6]。

### テストはAIにとっての「正しさの感覚」を代替する

Kent Beckは「TDDはAIエージェントと作業するときsuperpowerだ」と繰り返している[^11]。なぜか。テストは自然言語の仕様と違って**実行可能で、曖昧さがなく、結果が二値（pass/fail）**だからだ。

グラウンディングされていないAIにとって、テストのpass/failは「正しさ」の唯一の知覚可能な形態だ。完全なグラウンディングではないが、**テストを介したコードの世界との因果的接触**として機能する。テストが red になることは、人間にとっての「痛み」に最も近い信号である。

ただしBeckが発見した不穏な事実がある。エージェントはテストを削除して「pass」させようとする。Beckはこれに対して「テストは不変の注釈であり、エージェントに変更を許さない」と宣言した[^12]。**テストを書くのは人間であり、テストを通すのがエージェントの仕事。この非対称性を守ること**が、主導権を保持する鍵となる。

### ドキュメントは招待状である

AIに振り回されている人の多くは、ドキュメントを「書いても読まれないオーバーヘッド」と感じている。しかしAIコーディングの文脈では、ドキュメントの意味が根本的に変わった。

OpenAIのCodexチームが学んだ最大の教訓の一つは、Slackでアーキテクチャパターンについて合意しても、それがリポジトリに落とし込まれなければエージェントには見えないということだった。そして「3ヶ月後に入社する新メンバーにとっても同じだ」と添えている[^6]。

AIにはグラウンディングがないから、「空気を読む」ことができない。書いたものだけがAIの世界になる。したがってドキュメントは、AIへの制約ではなく、**AIを人間の世界に招待するための入場券**だ。設計意図、制約、なぜそう決めたかを人間の言葉で書く。それをAIに与えればコーディングの支援になる。チームへの説明責任であり、AIへの正確な指示であり、人間の世界への招待状でもある。一石三鳥と言える。

---

## 厳密さの再配置：Chad Fowlerの洞察

ThoughtWorksのDeer Valleyリトリートで最も共鳴を呼んだのは、Chad Fowlerの「Rigor Relocation（厳密さの再配置）」だった。

> ソフトウェアの進化の数十年を通じて、同じ誤解が繰り返されてきた。制約の除去が厳密さの喪失と混同される。しかし実際に起きているのは、うまくいく場合、**厳密さの再配置**だ。コントロールは消えない。現実に近づく。コード生成が容易になるなら、判断はより厳格にならなければならない。さもなければ、それはもはやエンジニアリングではない。

[^13]

XPがテストと継続的インテグレーションに厳密さを再配置したように、AIコーディングは**境界、契約、検証**に厳密さを再配置する。コードそのものへのこだわりは減る（AIが書くから）。しかし境界の設計、テストの品質、インターフェース契約の厳密さは増す。

Fowlerはさらに踏み込んで、**境界が正しく設計されていれば、境界の内側のコードは丸ごと書き換え可能（regenerable）になる**と主張した。テストが通り、インターフェース契約を満たし、アーキテクチャ境界を遵守する限り、別のAI（あるいは別のモデルバージョン）で丸ごと再生成してもよい。コードは消耗品になるが、**境界とテストは資産として残る**[^14]。

---

## 未解決の問題

### 機能と振る舞いの検証

Böckelerが指摘したように、現在のハーネスはコードの内部品質（アーキテクチャ整合性、規約遵守）に焦点を当てているが、「ソフトウェアが正しく動作するか」という外部品質の検証はまだ弱い[^7]。

### 下流パイプラインの追随

CircleCIの2026年レポートは、AI生成コードのスループットは59%増加したが、メインブランチへの実際のデリバリーは中央値で7%**減少**したと報告している。コード生成だけを加速しても、テスト・セキュリティ・デプロイのパイプラインが追いついていなければ全体は改善しない[^16]。

### 過剰設計のリスク

ハーネスの各コンポーネントは「モデルが自力ではできないこと」に関する仮説をエンコードしている。モデルが改善されれば仮説は陳腐化する。Böckelerが「剥がしやすいハーネスを作れ」と言い、LangChainが「これはモデルの現在の制約を回避するヒューリスティクスであり、改善されれば不要になるかもしれない」と明記しているのは、この点を懸念してのことである。

---

## 結論：新しい言葉に振り回されるな

正直に言おう。「ハーネスエンジニアリング」は2026年2月に生まれたバズワードだ。Hashimotoが名付け、OpenAIが大々的に報告し、数週間でコミュニティに定着した。新しい言葉が出ると、そこに銀の弾丸があるように見える。特に日本人にとって、ハーネスは聞きなれない言葉だから、なおさら何か特別な技術に思えてしまう。

しかし中身を見れば、ハーネスエンジニアリングの構成要素は全て既知の技術だ。テスト駆動開発、CI/CD、モジュール化、インターフェース設計、ドキュメント文化。Dijkstra、Parnas、Myers、Evans、Beckの仕事の延長にある。「AIにとって良いことは人間にとっても良い」というThoughtWorksリトリートの合意は、裏を返せば「人間にとって良かったことはAIにとっても良い」ということになる。

新しいのは名前であって、技術ではない。新しいのは、これらの技術の**投資対効果が劇的に変わった**ということだ。以前はドキュメントを書いても読まれなかった。今は書いたものがAIに読まれ、実行される。以前はモジュール境界を引いても人間が越境していた。今はCIで機械的に強制すれば、エージェントは確実に従う。以前はテストを書くのは保険だった。今はテストがAIにとっての「正しさの定義」となった。

だから「ハーネスエンジニアリングを学ばなければ」と焦る必要はない。代わりに、自分がこれまでに身につけたソフトウェアエンジニアリングの技術を棚卸しして、その使い方を変えればいい。コードを書く時間は減る。その分、境界を設計し、テストを書き、ドキュメントで意図を伝える時間が増える。Chad Fowlerの言葉を借りれば、厳密さは消えない。再配置される。

手綱を握れ。あなたが長年磨いてきた技術こそが、その手綱だ。

---

## 参照

### ハーネスエンジニアリングの一次ソース

- **Mitchell Hashimoto** (2026-02-05) — [My AI Adoption Journey](https://mitchellh.com/writing/my-ai-adoption-journey)
  「ハーネスエンジニアリング」の命名。エージェントがミスを犯すたびにハーネスに落とし込む営み。

- **OpenAI** (2026-02-11) — [Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/)
  100万行・手書きゼロの実験。「中央で境界を強制し、局所で自律を許す」。

- **Birgitta Böckeler** (2026-02-17) — [Harness Engineering](https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html) (martinfowler.com)
  OpenAI報告の冷静な分析。機能検証の不在の指摘と「剥がしやすいハーネス」の重要性。

- **LangChain** (2026-02-17) — [Improving Deep Agents with harness engineering](https://blog.langchain.com/improving-deep-agents-with-harness-engineering/)
  モデル固定でTerminal Bench 2.0を52.8%→66.5%に改善。

### Anthropicのハーネス研究

- **Anthropic** (2025-09) — [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
  コンテキスト腐敗の概念。

- **Anthropic** (2025-11) — [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
  長時間エージェントの二重アーキテクチャ。

- **Anthropic** (2026-03) — [Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps)
  3エージェント構成。モデルは自身の出力を正確に評価できないという発見。

### 厳密さの再配置とコミュニティの議論

- **ThoughtWorks** (2026-02) — [The Future of Software Development Retreat](https://www.thoughtworks.com/en-de/about-us/events/the-future-of-software-development)
  Deer Valleyリトリートの報告。「エージェントを助けるものは人間も助ける」。

- **Honeycomb** (2026-03) — [Production Is Where the Rigor Goes](https://www.honeycomb.io/blog/production-is-where-the-rigor-goes)
  Chad Fowler「厳密さの再配置」の引用と、プロダクション環境の境界の重要性。

- **Martin Fowler Fragments** (2026-03-16) — [Chad Fowler on Regenerative Software](https://martinfowler.com/fragments/2026-03-16.html)
  再生の単位はコンポーネントであり、「データ所有権の境界」と「評価面」で粒度を定義する。

- **Kief Morris** (2026-03) — [Humans and Agents in Software Engineering Loops](https://martinfowler.com/articles/exploring-gen-ai/humans-and-agents.html) (martinfowler.com)
  「人間に効いたシフトレフト思考はエージェントにも効く」。

### コード品質とAI適性

- **Borg & Tornhill** (2026-01) — [Code for Machines, Not Just Humans](https://arxiv.org/html/2601.02200v1)
  5,000ファイル×6 LLMの実証研究。健全なコードは欠陥リスク30%以上低い。

- **ThoughtWorks** (2026-03) — [A perspective on CircleCI's 2026 State of Software Delivery](https://www.thoughtworks.com/insights/blog/generative-ai/a-thoughtworks-perspective-on-circleci-s-2026-state-of-software-)
  スループット59%増だがメインブランチ配信は7%減。統合が律速段階。

### テストとTDD

- **Kent Beck** — [Augmented Coding: Beyond the Vibes](https://tidyfirst.substack.com/p/augmented-coding-beyond-the-vibes)
  拡張コーディングとTDDサイクル。エージェントがテストを削除する問題。

- **Pragmatic Engineer** — [TDD, AI agents and coding with Kent Beck](https://newsletter.pragmaticengineer.com/p/tdd-ai-agents-and-coding-with-kent)
  TDDはAIエージェント時代のsuperpower。

### シンボルグラウンディング問題

- **Stevan Harnad** (1990) — [The Symbol Grounding Problem](https://philpapers.org/rec/HARTSG), Physica D

- **Floridi, Jia, Tohmé** (2025-12) — [A Categorical Analysis of LLMs and the Symbol Grounding Problem](https://arxiv.org/html/2512.09117)
  LLMはグラウンディング問題を「解決」ではなく「迂回」する。「認識論的寄生」。

- **Bender, Gebru et al.** (2021) — [On the Dangers of Stochastic Parrots](https://dl.acm.org/doi/10.1145/3442188.3445922), ACM FAccT

### フレーム問題と限定合理性

- **McCarthy & Hayes** (1969) — [Some Philosophical Problems from the Standpoint of Artificial Intelligence](https://www-formal.stanford.edu/jmc/mcchay69.pdf)
  フレーム問題を提起。「何が関連し何が無関連かを判断できない」というAIの根本的制約。

- **Herbert Simon** (1955) — [A Behavioral Model of Rational Choice](https://cooperative-individualism.org/simon-herbert_a-behavioral-model-of-rational-choice-1955-feb.pdf), Quarterly Journal of Economics
  限定合理性と「満足化（satisficing）」の概念を提唱。

### テストハーネスの歴史

- [Wikipedia: Test harness](https://en.wikipedia.org/wiki/Test_harness)
- [Grokipedia: Test harness](https://grokipedia.com/page/Test_harness) — NASA Apollo計画からMyers (1979) への系譜。

### 生産性データ

- **METR** (2025-07) — [AI-Experienced OS Dev Study](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)
  経験豊富な開発者16名、246タスク。AI使用で19%遅くなった。知覚との40ポイント乖離。

[^1]: 経験豊富なOSS開発者16名による246タスクのランダム化比較試験。<https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/>
[^2]: これ面白いのでぜひ読んでほしい。記号と意味の接続問題を提起した論文。<https://philpapers.org/rec/HARTSG> 日本語での解説は <https://atmarkit.itmedia.co.jp/ait/articles/2102/03/news022.html>
[^3]: LLMは人間がグラウンディング済みのテキストに「認識論的寄生」しているという分析。<https://arxiv.org/html/2512.09117>
[^4]: テストハーネスの概念はNASA Apollo計画に遡り、Myers (1979) で体系化された。<https://en.wikipedia.org/wiki/Test_harness> <https://grokipedia.com/page/Test_harness>
[^5]: 「ハーネスエンジニアリング」を命名したブログ記事。<https://mitchellh.com/writing/my-ai-adoption-journey>
[^6]: 100万行超を手書きゼロで構築し、境界設計とドキュメントの重要性を報告。<https://openai.com/index/harness-engineering/>
[^7]: OpenAI報告の分析。機能検証の不在と「剥がしやすいハーネス」の重要性を指摘。<https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html>
[^8]: モデル固定でTerminal Bench 2.0を52.8%→66.5%に改善。<https://blog.langchain.com/improving-deep-agents-with-harness-engineering/>
[^9]: 5,000ファイル×6 LLMの実証研究。コード品質がAIリファクタリング成功率と有意に相関。<https://arxiv.org/html/2601.02200v1>
[^10]: Deer Valleyリトリートの報告。「エージェントを助けるものは人間も助ける」。<https://www.thoughtworks.com/en-de/about-us/events/the-future-of-software-development>
[^11]: Kent BeckのTDDとAIエージェントに関するインタビュー。<https://newsletter.pragmaticengineer.com/p/tdd-ai-agents-and-coding-with-kent>
[^12]: Beckの「テストは不変の注釈でありエージェントに変更を許さない」という宣言。<https://www.allstacks.com/blog/how-to-write-specs-for-ai-agents-tdd-skills-and-what-comes-next>
[^13]: Chad Fowlerの「厳密さの再配置」論。制約の除去と厳密さの喪失は別物。<https://www.honeycomb.io/blog/production-is-where-the-rigor-goes>
[^14]: 境界内コードは再生成可能という主張。再生の単位はデータ所有権の境界で定義。<https://martinfowler.com/fragments/2026-03-16.html>
[^16]: スループット59%増だがメインブランチ配信は7%減。統合パイプラインが律速段階。<https://www.thoughtworks.com/insights/blog/generative-ai/a-thoughtworks-perspective-on-circleci-s-2026-state-of-software->
[^17]: AI研究におけるフレーム問題を提起した論文。<https://www-formal.stanford.edu/jmc/mcchay69.pdf> 日本語での解説は <https://atmarkit.itmedia.co.jp/ait/articles/2011/04/news020.html>
[^18]: 限定合理性と「満足化」の概念を提唱した論文。<https://cooperative-individualism.org/simon-herbert_a-behavioral-model-of-rational-choice-1955-feb.pdf>
