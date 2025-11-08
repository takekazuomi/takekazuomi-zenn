---
title: "Hexagonal/Clean Architecture は時代遅れ"
emoji: "🎈"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Architecture", "紹介"]
published: false
---

> [!Note]
> 論旨が曖昧になってるので、下記のように整理し直す
> 1. Separation of Concerns は、ソフトウェア開発の基本。分割することで複雑さをコントロールする。
> 2. これは、人間は、同時に扱えるコンテキストに限界があるから
> 3. 分割は繰り返出てくる、マトリョーシカのような構造
> 4.

## マイクロサービスにおけるアーキテクチャーパターンの適用

プロジェクトでマイクロサービス風[^arch1]の実装をしている。周りを見てみると、Hexagonal Architecture（ポート&アダプター）やClean Architectureを各サービス内部に律儀に適用してるケースをママ見かけるし、そうしたいという話も聞く。

これは一種の**over-engineering**で、まるで「Enterprise Hello World」のように、シンプルであるべきものを過剰に複雑にしてしまっている。なぜそう言えるのか、順を追って説明していく。

### 核心的な論点：垂直分解 vs 水平分解

ソフトウェア開発では、複雑性を分割することでコントロールするのが基本だ。。関数にする、モジュールにする、オブジェクトにする、サービスにする、といった具合にあらゆるところでこの技法は使われる。

ある程度の規模になったシステムを分割する方法には、2つの対照的なアプローチがある[^arch19]。これが今回の核心的な話だ。

> [!Note]
>
> Edsger W. Dijkstra "Separation of Concerns" (1974)
>
> - 関心の分離（Separation of Concerns）
>
> ソフトウェアの複雑性に対処するには、問題を分割して各側面に個別に集中できるようにすることが基本
>
> - 原典: "On the Role of Scientific Thought" (1974)
> - URL: <https://en.wikipedia.org/wiki/Separation_of_concerns>
> - <https://www.cs.utexas.edu/~EWD/transcriptions/EWD04xx/EWD447.html>

**【水平分解（Horizontal Decomposition）】- 旧来のアプローチ**:

2000年代から主流となっていたこのアプローチでは、以下のような特徴がある：

- Hexagonal Architecture / Clean Architectureが採用
- 1つのアプリケーション内部を技術的関心事で層（レイヤー）に分割
- ビジネスロジックを他の層（UI、DB、外部API）から切り離す
- 目的：ビジネスロジックの独立性と再利用性の確保

つまり、アプリケーション内部で横方向に技術層を分離することで、ビジネスロジックを守ろうとする設計だ。

**【垂直分解（Vertical Decomposition）】- マイクロサービスのアプローチ**:

対照的に、マイクロサービスアーキテクチャでは異なるアプローチをとる：

- マイクロサービスアーキテクチャが採用
- システム全体をビジネス機能単位で複数のサービスに分割
- 各サービスは単純で見通しの良いコードで実装
- 目的：サービス間の独立性と複雑性の分散化

こちらは、システム全体を縦方向にビジネス機能で分割することで、複雑性を分散させる設計だ。

**重要な原則**[^arch20]：この2つのアプローチを同時に適用すると、過剰な複雑性がプロジェクトに持ち込まれる。マイクロサービスを選択したなら、各サービス内部はシンプルに保つべきだ。

なぜ適していないのか？

**1. 分解アプローチの違い：垂直 vs 水平**

Hexagonal ArchitectureとClean Architectureは、**水平分解（Horizontal Decomposition）**のアプローチを採用している。単一のアプリケーション境界内における内部構造を複数のレイヤーやコンポーネントに分割することを想定した設計パターンだ[^arch15][^arch16]。

対照的に、マイクロサービスアーキテクチャでは、**垂直分解（Vertical Decomposition）**を採用する。**サービス境界そのものが最も強力な分離メカニズム**として機能する[^arch7]。

```text
【水平分解 - Hexagonal/Clean Architecture】
┌─────────────────────────────────────┐
│  Application                        │
│  ┌────────────────────────────────┐│
│  │ ═══════════════════════════  ││ ← 水平方向に技術層で分離
│  │ Presentation Layer             ││
│  │ ───────────────────────────  ││
│  │ Business Logic Layer           ││
│  │ ───────────────────────────  ││
│  │ Data Access Layer              ││
│  └────────────────────────────────┘│
└─────────────────────────────────────┘
      複雑性がアプリケーション内部に集中

【垂直分解 - マイクロサービス】
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ User Service │    │ Order Service│    │ Product Svc  │
│              │    │              │    │              │
│  handler     │    │  handler     │    │  handler     │
│  service     │    │  service     │    │  service     │
│  repository  │    │  repository  │    │  repository  │
│  (Simple)    │    │  (Simple)    │    │  (Simple)    │
└──────────────┘    └──────────────┘    └──────────────┘
      ↑                   ↑                   ↑
  ビジネス機能で     ビジネス機能で      ビジネス機能で
  垂直方向に分離     垂直方向に分離      垂直方向に分離

      複雑性がサービス間に分散
```

**Sam Newman（『Building Microservices』著者）**[^arch8]：「マイクロサービスにおいて、サービス境界を越えた通信はすべてネットワーク越しのAPI呼び出しである。これは、プロセス内のレイヤー分離よりも遥かに強力な分離メカニズムだ」

---

**2. 余計なレイヤーによる複雑性の増大**

マイクロサービスは、**小さく、単純であることが価値**だ[^arch9]。各サービス内にHexagonal Architectureのような複雑なレイヤー構造を導入すると、以下のような問題が発生する：

- **コードの複雑性が増加**: インターフェース、アダプター、ポートといった抽象レイヤーが追加される
- **開発速度の低下**: 単純な変更でも複数のレイヤーを跨ぐ必要がある
- **認知負荷の増大**: 開発者が理解すべき構造が増える

結果として、マイクロサービスの利点である「小さく理解しやすい」という特性が失われてしまう。これじゃ本末転倒だ。

**Martin Fowler**[^arch10]：「マイクロサービスの利点の1つは、各サービスが独立して理解・変更可能なことだ。サービス内部を過度に複雑にすると、この利点が損なわれる」

---

**3. 垂直分解と水平分解を同時適用する問題**

マイクロサービスアーキテクチャ（垂直分解）を採用している環境で、各サービス内部にHexagonal ArchitectureやClean Architecture（水平分解）を適用すると、**2つの分解アプローチが競合**する。具体的には以下のような問題が発生する：

- **分離の重複**: サービス境界と内部レイヤーで二重の分離が発生
- **複雑性の増幅**: 複雑性が掛け算的に増加（サービス数 × レイヤー数）
- **開発速度の低下**: マイクロサービスの利点（独立デプロイ、迅速な変更）が損なわれる

このように、2つの異なる複雑性管理アプローチを同時に適用することは、むしろ複雑性を増大させる結果になってしまう。経験上、こういうプロジェクトは開発速度が上がらず難儀することが多い。

Martin Fowler[^arch20]は、モノリスをマイクロサービスに分割する際、「**垂直に分離し、データを早期に解放する（Decouple Vertically and Release the Data Early）**」ことを推奨している。水平分解は、マイクロサービス分割のアンチパターンとされている。

---

**4. マイクロサービスに適した構造**

マイクロサービス内部では、**シンプルな3層構造**で十分だ：

```go
// マイクロサービス内部の推奨構造
user-service/
├── cmd/
│   └── server/
│       └── main.go           // エントリーポイント
├── internal/
│   ├── handler/              // gRPCハンドラー（境界）
│   │   └── user_handler.go
│   ├── service/              // ビジネスロジック
│   │   └── user_service.go
│   └── repository/           // データアクセス
│       └── user_repository.go
└── proto/
    └── user/v1/
        └── user_service.proto

// ❌ 過度に複雑な構造（Hexagonal/Clean適用）
user-service/
├── cmd/
├── internal/
│   ├── domain/              // ドメインモデル（Pure）
│   ├── ports/               // インターフェース定義
│   │   ├── inbound/         // ユースケース
│   │   └── outbound/        // リポジトリ
│   ├── adapters/
│   │   ├── primary/         // HTTPハンドラー
│   │   └── secondary/       // DB実装
│   └── application/         // アプリケーションサービス
└── ... (さらに増える)
```

**推奨される原則**[^arch11]

マイクロサービス内部では、以下のシンプルな3層構造で十分だ：

- **ハンドラー層**: gRPC/HTTPのリクエストを受け取り、サービス層を呼び出す（境界）
- **サービス層**: ビジネスロジックを実装（純粋なGoコード）
- **リポジトリ層**: データベースアクセスを抽象化（インターフェースで分離）

この構造は、各層の責任が明確で、見通しが良く、保守しやすい。

**重要**：リポジトリをインターフェースで分離することは推奨されるが、これは**テストのため**ではなく、**複数の実装（PostgreSQL、MongoDB、インメモリ）を切り替えるため**だ[^arch12]。

---

**5. データベース技術の選択は実装の詳細**

マイクロサービスでは、**各サービスが独自のデータベース技術を選択できる**ことが利点だ[^arch13]。例えば以下のように、サービスごとに最適なデータベースを選択できる：

- User Service → PostgreSQL
- Order Service → MongoDB
- Analytics Service → Cassandra

この選択は、**サービス外部には公開されない実装の詳細**だ。サービス境界がすでに強力な分離を提供しているため、サービス内部でさらにデータベースを抽象化する必要はない。

**Chris Richardson（『Microservices Patterns』著者）**[^arch14]：「Database per Service パターンにおいて、データベースはサービスのプライベートな実装の詳細である。他のサービスは、APIを通じてのみアクセスすべきだ」

---

**最後に**

マイクロサービスを採用するなら、各サービス内部はシンプルに保つのが筋だと思う。

**核心的な原則**

この記事で最も重要なポイントは以下の3つ：

- マイクロサービスは垂直分解、Hexagonal/Cleanは水平分解
- 両方を同時に適用すると、複雑性が掛け算的に増加
- 垂直分解を選んだら、各サービス内部はシンプルに保つ

つまり、分解のアプローチは1つに絞るべきってわけだ。

**実践的な推奨事項**

マイクロサービスを構築する際は、以下の点を意識すると良い：

- サービス境界（垂直分解）が最も重要な分離メカニズム
- サービス内部は見通しの良い3層構造で十分（handler → service → repository）
- 余計なレイヤー（水平分解）を持ち込むのは極力避ける
- 複雑性はサービス間に分散させ、各サービスは単純に保つ

これだけでも、なかなか保守しやすいシステムになる。

**選択の基準**

どちらのアプローチを選ぶべきかは、構築するシステムの性質による：

- **モノリシックアプリケーション**を構築する場合 → 水平分解（Hexagonal/Clean Architecture）は有効
- **マイクロサービス**を構築する場合 → 垂直分解（各サービスはシンプルな構造で十分）

ただし、小規模なシステムでマイクロサービスを採用するのは、かえって複雑性が増すので要注意だ。Martin Fowlerも言ってるように[^arch9]、単純なシステムならモノリスで十分。

---

**脚注（アーキテクチャー）**:

[^arch7]: Sam Newman, "Monolith to Microservices" (2019), Chapter 2: Planning a Migration, <https://samnewman.io/books/monolith-to-microservices/> DDDと境界コンテキストでサービス境界を特定。段階的移行の重要性を解説。モノリス分割を考えてる人には必見の内容。
[^arch8]: Sam Newman, "Building Microservices, 2nd Edition" (2021), Chapter 1: What Are Microservices?, <https://samnewman.io/books/building_microservices_2nd_edition/> 「独立したデプロイ可能性」と「情報隠蔽」がマイクロサービスの核心。安定したサービス境界が疎結合を実現。マイクロサービスを始めるなら、この本は必読だ。
[^arch9]: Martin Fowler, "Microservice Trade-Offs" (2015), <https://martinfowler.com/articles/microservice-trade-offs.html> マイクロサービスのトレードオフを分析。単純なシステムではモノリスで十分、複雑性を補えるシステムでのみ有効と結論。素晴らしい分析で、マイクロサービス導入前に読んでおくと良い。
[^arch10]: Martin Fowler, "Microservices Guide" (2014), <https://martinfowler.com/microservices/> マイクロサービスの基礎的な定義。各サービスがビジネス能力中心に構築され、独立したプロセスで実行。
[^arch11]: Sam Newman, "Building Microservices, 2nd Edition" (2021), Chapter 3: Splitting the Monolith, <https://samnewman.io/books/building_microservices_2nd_edition/> Strangler Fig Patternを紹介。一括書き直しではなく段階的な置き換えを推奨。
[^arch12]: Vladimir Khorikov, "Unit Testing Principles, Practices, and Patterns" (2020), Chapter 6: Styles of Unit Testing, <https://www.manning.com/books/unit-testing> London SchoolとClassical Styleを比較。インターフェース分離は過剰なモック化のためではなく適切な抽象化のため。
[^arch13]: Chris Richardson, "Microservices Patterns" (2018), Chapter 3: Inter-process Communication, <https://microservices.io/book> サービス間通信パターンを解説。各サービスが独自DBを持ち、ポリグロット永続性を推奨。マイクロサービスのパターンを体系的に学ぶなら、この本がお勧めだ。
[^arch14]: Chris Richardson, "Pattern: Database per Service" (2018), <https://microservices.io/patterns/data/database-per-service.html> Database per Serviceパターン。各サービスがDBを専有し、他サービスから直接アクセスされない。microservices.ioは、パターンカタログが充実してて参考になる。
[^arch15]: Alistair Cockburn, "Hexagonal Architecture" (2005年9月4日、最終更新2025年), <https://alistair.cockburn.us/hexagonal-architecture> 単一のアプリケーションを中心に、内部と外部の技術要素を分離する設計パターン。古典的だが、今でも有用な考え方だ。
[^arch16]: Robert C. Martin, "The Clean Architecture" (2012年8月13日), <https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html> 単一アプリケーション内部を4つの同心円状のレイヤー(Entities, Use Cases, Interface Adapters, Frameworks & Drivers)に分割。Uncle Bobの記事は、いつ読んでも勉強になる。
[^arch19]: Martin Fowler, "Break Monolith into Microservices" (2024), <https://martinfowler.com/articles/break-monolith-into-microservices.html> 「垂直に分離し、データを早期に解放する」ことを推奨。水平分解はアンチパターン。この記事は必見の情報満載で、モノリス分割を考えてる人には素晴らしいガイドになる。
[^arch20]: DZone, "Vertical vs. Horizontal Decomposition of Responsibilities" (2020), <https://dzone.com/articles/vertical-vs-horizontal-decomposition-of-responsibi> 垂直分解と水平分解の対比を解説。垂直分解がビジネス機能単位での独立性を高める。この対比を理解するのに、なかなか良い記事だ。
