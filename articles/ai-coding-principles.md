---
title: AIコーディングの原則
emoji: "🤖"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["ai", "aicoding", "llm"]
published: true
---

AIコーディングツールを使い始めて、しばらく経った。進歩は目覚ましく、便利だし役に立つ。一方で、OSS界隈では[AI Slop](https://arxiv.org/abs/2509.19163) (AIが生成する低品質なコードやテキスト) が問題になっている。個人なら自分で気づいて直せるが、チームでは人数分だけ増幅される。誰かが流したSlopのレビューとリワークにチーム全体が巻き込まれ、AIコーディングのメリットを上回る生産性の低下を招く。この記事では、チームでその罠に落ちないための原則を定義する。

## コードのオーナーは人間であり、責任を取るのも人間

LLMがコードを生成しても、そのコミットに名前が刻まれるのは人間で、深夜に障害対応で呼び出されるのも人間。「AIが書いたから」は通用しない。AIは7〜8割のコードを書けるが、プロダクション品質に仕上げるのはまだ人間の仕事だ。

## コンテキストの共有とドキュメント

良いコードにはコンテキストの共有が要る。なぜその設計を選び、何を捨てたか。これは人間が書く場合もAIが書く場合も同じだ。従来、コンテキストは隣のシニアエンジニアとの会話やコードレビューで共有されていた。ドキュメントはあったが「書かれても読まれないもの」になりがちで、コンテキストの本体は人の頭の中にあった。

AIには雑談ができない。コンテキストを渡すには、言語化して書くしかない。しかもAIが必要としているのは、コードそのものには書けない部分 **なぜその設計を選び、何を捨て、どんな制約を前提にしているか** だ。加えてAIのコンテキストウィンドウには制限があり、ドキュメントは適切なサイズに整理されている必要がある。長すぎるドキュメントが読みづらいのは人間も同じで、簡潔さの要件は両者に共通する。AIの登場によってドキュメントはオーバーヘッドではなく、開発のスループットを決める重要な要素となった。

## 原則

**判断は人間がする。** AIの提案をそのままコミットしない。オンコールで呼ばれたとき、1000行の変更を説明できるか。現状だとコードの品質は時に低く、特にセキュリティ境界「認証、認可、入力検証」はAIが見落としやすい。

**人間が読めるドキュメントを優先して書く。** 設計意図、制約、なぜそう決めたかを人間の言葉で記す。それをAIに与えればコーディングの支援になる。ドキュメントは人とAIが共有するコンテキストである。AIだけが読む専用ファイル（CLAUDE.md など）はあくまで補助であって、本体ではない。人間向けのドキュメントを充実させれば、AIへの指示は自然と最小化される。

**AIへの指示は「発見できないことだけ」書く。** コードを読めばわかることを繰り返す必要はない。「AIが繰り返し失敗したこと、プロジェクト固有の制約、ツール選択の理由」、そういった「コードベースの外にある知識」だけを補助的に書く。

## まとめ

コードの責任を取るのは人間だ。判断は自分で下し、コンテキストを言語化し、人間が読めるドキュメントに投資する。AI専用の指示はいずれ陳腐化するが、人間のために書いたドキュメントの価値は残る。

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
