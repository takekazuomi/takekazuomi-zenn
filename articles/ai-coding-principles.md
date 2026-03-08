---
title: AIコーディングの原則
emoji: "🤖"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["ai", "ai-coding", "llm"]
published: false
---

AIコーディングツールを使い始めて、しばらく経った。GitHub Copilot、Claude Code——ツールの進化は目覚ましく、便利に使ってる。一方で、使えば使うほど「便利だけど、どう付き合うべきか」という問いが避けられなくなってきた。この記事では、実務の中で感じた課題を整理し、AIコーディングと向き合うための原則をまとめている。

## コードを書くのは人間であり、責任を取るのも人間

LLMがコードを生成しても、そのコミットに名前が刻まれるのは人間で、深夜に障害対応で呼び出されるのも、バグの説明を求められるのも、人間。「AIが書いたから」は通用しない。この非対称な責任の構造は、AIがどれだけ賢くなっても変わらない。これからもしばらくは変わらないだろう。

AIはコーディングを支援するツールであって、コーディングの主体にはなれない。「AIコーディング時代」とは、「AIというコーディング支援ツールを使える時代」のことである。主体が人間であることは、以前と何も変わっていない。そして残念ながら、AIは7〜8割のコードは書けても、プロダクション品質のコードを仕上げるにはまだ力不足と言える。

## コーディングにはコンテキストが必要だ

良いコードを書くためには、コンテキストが欠かせない。何を解決しようとしているのか、なぜその設計を選んだのか、どんな制約があるのか。これはベテランの人間が書く場合でも、AIが書く場合でも、まったく同じである。コンテキストなしに書かれたコードは、動いたとしても意図を失っている。

では、コンテキストはどのように共有されてきたのか。人間だけの時代、それは主に人と人のコミュニケーションによって共有されていた。隣に座ったシニアエンジニアとの会話、コードレビューのコメント、チャットの流れ——そういった非形式的なやり取りの積み重ねが、チームのコンテキストを形成していた。

しかし、ドキュメントはどうだったか。あったにはあったが、「書かれても読まれないもの」になりがちだった。READMEは古くなり、設計書は棚に眠った。コンテキストの本体は、あくまで人の頭の中にあった。この状況が、AIの登場で一変することになった。

## AIとのコンテキスト共有がドキュメントを変えた

AIをコーディング支援ツールとして使うとき、コンテキストの伝達方法が根本から変わる。AIには雑談ができない。廊下での立ち話も、チャットの流れも届かない。コンテキストを渡すには、言語化して書くしかない。しかも、コードそのものには書けない部分——なぜその設計を選んだか、何を捨てたか、どんな制約を前提にしているか——こそが、AIが必要としているコンテキストの核心と言える。

結果として、ドキュメントがコードの出発点になる。AIの支援を受けるためには、人間がまず意図を言語化しなければならない。この構造こそが、AIがもたらしたドキュメント革命の本質である。ドキュメントが「書いても読まれないもの」から「書かなければコードが生まれないもの」へと変わったのだ。

この変化は、ドキュメントと開発速度の関係も逆転させた。かつてドキュメントは「開発を遅くするもの」と見なされがちだった。しかしAIがコンテキストを消費するようになった今、ドキュメントの質が開発の速度と品質を直接左右する。意図が言語化されていればAIは的確に動き、されていなければ的外れなコードを量産する。ドキュメントはもはやオーバーヘッドではなく、開発のスループットを決める変数になった。

## 原則

**判断は人間がする。** AIの提案をそのままコミットしない。オンコールで呼ばれたとき、1000行の変更を説明できるか。それが判断の基準となる。特にセキュリティ境界——認証、認可、入力検証——はAIが最も見落としやすく、人間の判断が欠かせない領域である。AIは強力な支援ツールだが、判断を外注することはできない。

**人間が読めるドキュメントを優先して書く。** 設計意図、制約、なぜそう決めたかを人間の言葉で記す。それをAIに与えればコーディングの支援になる。ドキュメントは人とAIが共有するコンテキストである。AIだけが読む専用ファイル（CLAUDE.md など）はあくまで補助であって、本体ではない。人間向けのドキュメントを充実させれば、AIへの指示は自然と最小化される。

**AIへの指示は「発見できないことだけ」書く。** コードを読めばわかることを繰り返す必要はない。AIが繰り返し失敗したこと、プロジェクト固有の制約、ツール選択の理由——そういった「コードベースの外にある知識」だけを補助的に書く。

**古くなったAIへの指示は積極的に削除する。** 残ったままの指示はノイズになり、むしろAIのパフォーマンスを下げる。`.gitignore` のように、必要に応じて育て、不要になれば刈り込む。

## まとめ

AIコーディングツールは強力だ。しかし強力なツールほど、使う人間の判断力が問われる。ドキュメントを書くことは、その判断の記録であり、チームへの説明責任であり、AIへの正確なコンテキスト伝達でもある。一石三鳥だ。今こそドキュメントを書く動機が揃ったと言える。

LLMは進歩を続けている。いずれAI専用の指示が不要になる時期が来るのかもしれない。そのとき、AI向けの指示は陳腐化するが、人間のために書いたドキュメントの価値は残る。むしろ、AIが活用できる範囲が広がる分だけ、その価値は増していく。ここからも、AI向けのドキュメントより対人ドキュメントへの投資を優先すべきだと言える。

---

## 参照

この原則は、以下のコミュニティの議論と研究に基づいている。

### 責任の原則

- **Simon Willison** (2025-12-18) — [Your job is to deliver code you have proven to work](https://simonwillison.net/2025/Dec/18/code-proven-to-work/)
  「コンピュータはアカウンタビリティを持てない。それがhuman in the loopとしての君の仕事だ」

- **Matteo Collina** (Node.js TSC Chair, Fastify作者, 2026-01-18) — [The Human in the Loop](https://adventures.nodeland.dev/archive/the-human-in-the-loop/)
  「コードを出荷するとき、私の名前がそこについている。AIを使って速く動くことはできるが、自分の判断を外注することはできない」

- **Birgitta Böckeler** (Thoughtworks Distinguished Engineer, 2025-07-09) — [I still care about the code](https://martinfowler.com/articles/exploring-gen-ai/i-still-care-about-the-code.html) (martinfowler.com)
  「深夜にオンコールで呼ばれるのは人間だ。LLMはコンパイラではなく推論器であり、使用は常にリスクアセスメントだ」

### AGENTS.md・コンテキストファイルの実証研究

- **Gloaguen et al., ETH Zurich** (2026-02-12) — [Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?](https://arxiv.org/abs/2602.11988)
  138リポジトリ・5694件のPRを対象とした実証研究。LLM生成のコンテキストファイルはエージェント性能を2〜3%低下させ、開発者が書いても4%改善に留まる一方、コストは20%以上増加。「不要な要件がタスクを困難にする。人間が書くファイルは最小限の要件のみ記述すべき」と結論。

- **Vercel Engineering** (2026-01-) — [AGENTS.md outperforms skills in our agent evals](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals)
  Next.js 16 APIを対象としたevalで「発見できない知識だけを書いた圧縮インデックス」が100%のpass rateを達成。

- **Upsun Developer Center** (2026-02) — [The research is in: your AGENTS.md is probably too long](https://devcenter.upsun.com/posts/agents-md-less-is-more/)
  「CLAUDE.mdは`.gitignore`のように扱え。エッジケースを発見するたびに育て、不要になれば刈り込む」

### コミュニティの議論

- **Hacker News** — [Evaluating AGENTS.md: are they helpful for coding agents?](https://news.ycombinator.com/item?id=47034087) (76 points, 36 comments, 2026)
  論文著者のnielstron本人がスレッドに参加。「モデルはセッション開始時にREADMEとCONTRIBUTING.mdを自動でインジェストすればいい」とのコメントに著者が賛同。ユーザーpamelafoxが「エージェントが失敗したときだけAGENTS.mdに追加し、追加後は変更を戻して再実行して改善を確認する」という実践的な運用法を共有。

- **Hacker News** — [Compressed Agents.md > Agent Skills](https://news.ycombinator.com/item?id=46809708) (72 points, 34 comments, 2026)
  Vercel記事の議論。「SkillsよりAGENTS.mdが有効な理由は、エージェントが取得するかどうかを判断する必要のない確実な文脈提供にある」という議論が展開された。

### ドキュメント・仕様駆動開発

- **GitHub Blog** (2025-11) — [How to write a great agents.md: Lessons from over 2,500 repositories](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
  2500以上のリポジトリ分析。成功するコンテキストファイルの共通点は「具体的なコマンド、明確な境界、コードで示すスタイル例」。

- **Addy Osmani** (Google Chrome, 2026-01) — [How to write a good spec for AI agents](https://addyosmani.com/blog/good-spec/) (O'Reilly Radarにも転載)
  「仕様はwhatとwhyに集中すべき。巨大な仕様を一度に渡してもコンテキストウィンドウとattention budgetが邪魔をする」

- **Thoughtworks** (2025-12) — [Spec-Driven Development: Unpacking one of 2025's key new AI-assisted engineering practices](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)
  「仕様はGateではなく、エージェントがリアルタイムで消費し行動するための会話だ。従来のデザインドキュメントとの決定的な違いは、仕様が実際に使われるようになった点にある」
