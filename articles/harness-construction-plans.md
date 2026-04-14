---
title: "手綱を握れ：Goマイクロサービスプロジェクトのためのハーネス構築案"
emoji: "🐴"
type: "tech"
topics: ["go", "ai", "tdd", "マイクロサービス", "アーキテクチャ"]
published: false
---

## はじめに

「手綱を握れ」[^art1]で提示した原則を、~50のGoマイクロサービス、gRPC/Google AIP統一、Flutter フロントエンド、Azure上のB2C/B2Bサービスというプロジェクトに適用する。本稿では、議論を通じて浮かび上がった8つのハーネス構築案と、その背後にある設計原則をまとめる。

ハーネスエンジニアリングは新しい技術ではなく、Dijkstra以来の境界設計とテストを「AIの環境設計」として再配置したものである[^mh1]。したがって以下の構築案はいずれも、「新しいツールの導入」ではなく「既存の技術の使い方を変える」ことを軸にしている。厳密さは消えない、境界・契約・検証に再配置される[^hc1]。

プロジェクトの特性として、ビジネス要件は時間とともに変化し、その変更に迅速に追従することが重要視される。したがって、ハーネス自体も「剥がしやすく、進化させやすい」設計でなければならない。この「剥がしやすさ」を全構築案を貫く設計方針とする。

---

## 全体像：ハーネスの配置

議論を通じて、プロジェクトのアーキテクチャ上にハーネスを配置すべき場所と、配置しない場所が明確になった。

![ハーネスの配置](/images/harness-overview.png)

---

## 3つの設計原則

8つの構築案を貫く原則が3つある。議論の中で徐々に明確になったものだ。

### 原則1：テストは挙動を検証し、実装には関知しない

議論の中で最も重要な転換点は、「実装のテストをハーネスでコントロールするのは筋が悪い」という認識だった。EpsillaはOpenAI報告を分析し、「完全なハーネスは、コード品質を超えて、振る舞いの正しさ（behavioral correctness）を厳密に検証しなければならない」と結論づけた[^ep1]。IMPACT Frameworkは「失敗するテストは、望ましい振る舞いの曖昧さのない仕様だ」と定式化した[^im1]。

Chad Fowlerの「境界の内側のコードは再生成可能」[^cf1]という主張と直結する問題だ。状態マシンの内部実装（mapベースかswitchベースか）をテストすると、エージェントがコードを再生成するたびにテストが壊れる可能性がある。壊れるべきではないのに壊れる。これは偽陽性であり、ハーネスの信号としてノイズになる。

したがって、すべてのテストはAPI境界（gRPC、BFF、Flutter）での挙動を検証する。内部実装はエージェントの自由だ。テストが知っているのはprotoの型とgRPCのステータスコードだけ。`internal`パッケージのimportは一切しない。

### 原則2：人間が境界を定義し、エージェントは内側で自律する

OpenAIのCodexチームが言う「中央で境界を強制し、局所で自律を許す」[^oa1]。この原則はprotoファイルからDBスキーマ、Bicepまで一貫して適用する。

- **proto定義** → 人間が設計。エージェントは変更禁止。
- **DBスキーマ** → 人間が設計。エージェントはSQLBoiler生成コード経由でのみアクセス。
- **Bicep/IaC** → 人間が設計。エージェントは変更禁止。
- **挙動テスト** → 人間が仕様を定義。エージェントは変更禁止。
- **サービス実装** → エージェントが自由に書く。テストがpassすれば正しい。

Kent Beckの「テストを書くのは人間、テストを通すのがエージェントの仕事」[^kb2]という非対称性が、全層で維持される。

### 原則3：セマンティクスの欠落は層ごとに異なる手段で埋める

protoは強力な境界だが、セマンティクスが欠落している。Pactflowの分析は端的だ。「Protobufのような自己記述型データフォーマットは、セマンティックな保証を一切提供しない」[^pf1]。pgv/protovalidateは値の制約を埋めるが、状態遷移のルールや副作用の契約は射程外だ。

この問題に対し、セマンティクスの層ごとに異なる手段で補完する設計とした。

```text
proto定義         → 構造（フィールド名、型、RPC署名）       ← buf lint
pgv/protovalidate → 値の制約（形式、範囲、必須）            ← protovalidate
protoコメント     → 意図の伝達（人間とAIへの招待状）        ← AIP-192、レビュー
DB CHECK制約      → データの不変条件（値の範囲、非NULL）     ← MySQL
挙動テスト        → セマンティクス（遷移、副作用、不変条件） ← gRPC境界テスト
OTELメトリクス    → 実行時の正しさ（SLO、エラー率）         ← 観測ハーネス
```

---

## 構築案(1)：アプリE2Eハーネス：ユーザーの意図が実現されているかを最外殻で検証する

### 課題

構築案(2)〜(6)はシステムの内側から外側に向かって検証の層を積み上げてきた。しかしAnthropicの2026年3月の実験が不都合な事実を明らかにした。「以前のハーネスで作られたアプリケーションは、見た目は印象的だったが、実際に使ってみると本物のバグがあった」[^an1]。コードレベルのテストがすべてpassしても、ユーザーがアプリを操作したときに初めて見えるバグが存在する。

Anthropicの実験では、EvaluatorエージェントがPlaywright MCPを使って実際にアプリをクリックして回り、UI機能、APIエンドポイント、データベースの状態をテストした。各スプリントの前にGeneratorとEvaluatorが「完了の定義」を合意し、1つでも閾値を下回ればスプリントは失敗としてフィードバックを返した。

### 設計

Flutter向けにはPatrol（LeanCode、月間20万DL）[^pt1]がE2Eテストフレームワークとして成熟している。ネイティブUI（OSのパーミッションダイアログ、WebView認証、通知）を横断するテストが可能で、標準のintegration_testでは扱えない領域をカバーする。

テスト対象はビジネス上最もクリティカルなユーザージャーニーに限定する。ログイン→商品一覧→カート→チェックアウト→決済完了のようなフローだ。テストが操作するのはウィジェットのKey（セマンティックラベル）のみで、内部のState管理やBlocの状態を直接参照しない。

```dart
patrolTest(
  'チェックアウト: 商品選択→カート→決済→完了画面',
  ($) async {
    app.main();
    await $.pumpAndSettle();

    await $(#email_field).enterText('test@example.com');
    await $(#password_field).enterText('password123');
    await $(#login_button).tap();
    await $.pumpAndSettle();

    await $(#product_card).first.tap();
    await $.pumpAndSettle();
    await $(#add_to_cart_button).tap();
    await $(#cart_icon).tap();
    await $.pumpAndSettle();

    await $(#checkout_button).tap();
    await $.pumpAndSettle();
    await $(#pay_button).tap();
    await $.pumpAndSettle(timeout: Duration(seconds: 10));

    expect($(#order_complete_screen), findsOneWidget);
    expect($(#order_number_text), findsOneWidget);
  },
);
```

### 各層の検証責務

```text
(1) アプリE2E       問い：ユーザーの意図が実現されているか
(3) BFF挙動         問い：サービス間の協調は正しいか
(5) サービス挙動     問い：単一サービスの挙動は正しいか
(4) Proto契約        問い：構造と境界は守られているか
(6) 永続化層         問い：データの整合性は守られているか
```

下から上に向かって粒度が粗くなり、テスト数は減り、コストは上がる。しかし検証する「意味」の層は深くなる。

### 投資対効果

アプリE2Eは実行コストが最も高く、不安定さ（flakiness）が最も顕著な層だ。最初は2〜3の主要ユーザージャーニーから始め、安定性を確認しながら段階的に拡張する。

---

## 構築案(2)：リポジトリ文書ハーネス：AIを人間の世界に招待する

### 課題

OpenAIのCodexチームが学んだ最大の教訓は、「Slackでアーキテクチャパターンについて合意しても、リポジトリに落とし込まれなければエージェントには見えない」[^oa1]ということだった。書いたものだけがAIの世界になる。

### 設計

3つの文書群で構成する。

**AGENTS.md**。AIエージェントがリポジトリ内でどう振る舞うべきかを機械可読な形で記述する。プロジェクト固有の規約（slog使用、境界でのエラーログ、go-sql-driver/mysql + SQLBoilerパターンなど）を明記する。

**ADR**。「なぜそう決めたか」を人間の言葉で記録する。ADRはAIへの制約ではなく、AIを人間の設計意図に招待するための入場券だ。例えば「なぜslogをZapに替えて採用したか」のADRがあれば、エージェントはZapを提案しなくなる。

**Googleデザインドック**。新サービスの設計意図、トレードオフ、代替案を文書化する。人間のチームへの説明責任であり、AIへの正確な指示であり、一石三鳥の投資だ。

### 投資対効果

ドキュメントの読者が人間だけだった時代は終わった。書いたものがAIに読まれ、実行される時代になった。AGENTS.mdを1回書けば、すべてのエージェントセッションで参照される。Mitchell Hashimotoの言葉で言えば、ハーネスへの改善は複利で効いてくる[^mh1]。

---

## 構築案(3)：BFF挙動検証ハーネス：サービス横断のセマンティクスを評価面で捕捉する

### 課題

構築案(5)は各サービスの境界でセマンティクスを検証する。しかし現実のビジネスルールはサービスを横断する。「Paymentが成功しない限りOrderはSHIPPEDに遷移しない」。「在庫がゼロになったらカタログの表示が変わる」。これらのルールは、OrderService単独のテストでは検証できない。

では、この組み合わせの挙動をどこで検証するか。答えは既にアーキテクチャの中にある。BFF（Backend For Frontend）だ。

### BFFはなぜハーネスになれるのか

Sam Newmanが定義したBFFパターン[^sn1]において、BFFは単なるプロキシではなく、EvansのAnti-Corruption Layer（ACL）として機能する。バックエンドサービスはビジネスドメイン用に設計されたデータモデルを公開するが、フロントエンドが必要とするのはプレゼンテーション用のモデルだ。BFFはこの境界で翻訳者として振る舞う[^up1]。

Chad Fowlerの「評価面（evaluation surface）」の概念[^cf1]で捉えると、BFFは2つの安定した契約（Flutter↔BFF、BFF↔proto）に挟まれた「再生成可能な層」であると同時に、その出力を検証する「評価面」でもある。個々のマイクロサービスのテストでは見えない**サービス間の組み合わせの挙動**が、BFFの境界でのみ観測できる。

```text
Flutter ──→ BFF ──→ OrderService
                 ├──→ PaymentService
                 ├──→ InventoryService
                 └──→ NotificationService
             ↑
          評価面
```

### 設計

構築案(5)で確立した「挙動テスト」の原則がそのまま適用される。テストはBFFの公開gRPC APIのみを使用し、BFF内部の集約ロジック（呼び出し順序、並列化、キャッシュ）にはテストは関知しない。

テスト対象はサービス横断の不変条件に集中させる。「決済が失敗したらCONFIRMEDの注文が存在してはならない」「在庫が尽きた商品はカタログで利用不可であるべき」。こうしたルールはprotoにもpgvにも書けないが、BFF挙動テストのpass/failとして表現できる。

```go
func TestCheckout_PaymentFails_OrderRemainsUnchanged(t *testing.T) {
    ctx := context.Background()
    env, cleanup := testinfra.SetupBFFEnvironment(t)
    defer cleanup()

    // カートに商品を追加してチェックアウト（無効カード）
    _, err := env.BFF.AddToCart(ctx, &bffpb.AddToCartRequest{...})
    require.NoError(t, err)
    _, err = env.BFF.Checkout(ctx, &bffpb.CheckoutRequest{
        PaymentMethod: &bffpb.PaymentMethod{CardToken: "tok_declined"},
    })
    // 決済失敗を確認
    require.Error(t, err)

    // 不変条件の検証：CONFIRMEDの注文が存在してはならない
    orders, err := env.OrderClient.ListOrders(ctx, &orderpb.ListOrdersRequest{...})
    require.NoError(t, err)
    for _, o := range orders.GetOrders() {
        assert.NotEqual(t, orderpb.OrderStatus_ORDER_STATUS_CONFIRMED, o.GetStatus(),
            "決済失敗後、CONFIRMEDの注文が存在してはならない")
    }
}
```

### 投資対効果

統合テスト環境のコストは高い（Testcontainersで複数サービス起動）。したがってBFF挙動テストはクリティカルなビジネスルールに集中させ、網羅性は各サービスの挙動テスト（(5)）に委ねる。

---

## 構築案(4)：Proto契約ハーネス：境界を機械的に強制する

### 課題

前記事で論じたフレーム問題[^art1]は、~50のマイクロサービス・~150kのprotoドキュメントという規模では特に深刻になる。境界を越えた暴走リスクが現実的な脅威だ。「この関数を修正して」と頼んだのに認証システム全体を書き換え始めるのが典型例である。

### 設計

このプロジェクトではgRPC統一・Google AIP準拠が既に確立されている。したがってprotoファイルが「境界の機械可読な定義」として機能する。

第一に、protoファイルの不変性を確保する。protoファイルはエージェントが直接変更してはならない資産として扱う。API契約の変更は人間が設計判断として行い、AIはその契約の内側でコードを生成する。

第二に、`buf`によるlint・breaking change検出を機械的に強制する。`buf lint`はGoogle AIP準拠をCIで検証し、`buf breaking`は既存APIとの互換性を自動検出する。エージェントがprotoを変更しようとしても、CIが即座にrejectする。

第三に、サービス単位のBounded Contextを明示する。protoパッケージ構造がEvansのBounded Contextと一致するよう設計する。`user/v1`のprotoを見れば、Customerが常に一つの意味を持ち、エージェントの探索空間が劇的に縮む。

```text
proto/
├── user/v1/           ← Bounded Context: ユーザー管理
│   ├── user.proto
│   └── user_service.proto
├── notification/v1/   ← Bounded Context: 通知
│   ├── notification.proto
│   └── notification_service.proto
└── buf.yaml           ← AIP lint + breaking change検出
```

### protoのセマンティクスの欠落

議論の中で、protoの構造的な限界が明確になった。protoは構造（フィールド名、型、RPC署名）を定義するが、「このフィールドに何を入れるべきか」「このRPCの事前条件は何か」「どの状態遷移が許されるか」といったセマンティクスは表現しきれない。

pgv/protovalidateへの移行は進行中であり、値レベルの制約（emailの形式、ageの範囲、フィールド間の依存関係）はCELベースのカスタムルールで強化される。しかしprotovalidateが「セマンティック」と名乗っているのは値レベルの制約であって、状態遷移や副作用のセマンティクスではない。

この欠落を埋めるのが構築案(5)（挙動テスト）と(2)（protoコメント+ADR）の責務だ。protoコメント（AIP-192準拠）で人間とAIの理解を助け、テストでセマンティクスを強制する。コメントは「招待状」であり強制力を持たない。強制力はテストが持つ。

### 投資対効果

protoファイルとbuf設定は既に存在するため、追加コストはほぼゼロだ。以前はbufのlint結果を人間が確認していた。今はエージェントがbufの出力を「正しさの信号」として受け取り、自律的に修正する。同じツールの使い方が変わる。

---

## 構築案(5)：サービス挙動テストハーネス：AIに「正しさの感覚」を与える

### 課題

前記事で論じたとおり[^art1]、AIに「正しさの感覚」を与える唯一の手段がテストのpass/failだ[^sh1]。Kent Beckが「TDDはAIエージェント時代のsuperpowerだ」と繰り返す[^kb1]のは、この構造的理由による。

### 設計

プロジェクトでは古典学派テストアプローチとTestcontainersを既に採用している。この基盤の上に、3つの柱でハーネスを構築する。

**第一の柱：テストの不変性**。テストを書くのは人間であり、テストを通すのがエージェントの仕事だ。Beckが発見した「エージェントはテストを削除してpassさせようとする」[^kb2]という問題に対し、テストファイルの変更をPRレビュー必須とする。

**第二の柱：gRPC境界での挙動テスト**。テストはAPI境界での挙動を検証し、内部実装には関知しない。テストが知っているのはprotoの型とgRPCのステータスコードだけだ。

**第三の柱：Testcontainersによる「真のフィードバック」**。モックではなく実MySQLに対してテストすることで、AIが受け取るpass/fail信号の信頼性が上がる。実データベースが返す「本物の失敗」こそが、Beckの言う「人間にとっての痛みに最も近い信号」[^art1]だ。

### 状態遷移の挙動テスト

protoが表現できない状態遷移のセマンティクスは、gRPC境界で挙動テストとして検証する。重要なのは、**何を返すか（挙動）をテストし、なぜ弾いたか（実装の判断ロジック）にはテストが関知しない**ことだ。

```go
// order_behavior_test.goAPI境界での挙動テスト
// ⚠️ このテストはエージェントによる変更禁止。

func TestOrderTransition_Forbidden(t *testing.T) {
    ctx := context.Background()
    conn, cleanup := testinfra.SetupOrderService(t) // Testcontainers
    defer cleanup()
    client := pb.NewOrderServiceClient(conn)

    tests := []struct {
        name    string
        setup   []pb.OrderStatus // ここまで遷移させてからテスト
        attempt pb.OrderStatus   // テスト対象の遷移先
    }{
        {
            name:    "逆行禁止: CONFIRMED→PENDING",
            setup:   []pb.OrderStatus{pb.OrderStatus_ORDER_STATUS_CONFIRMED},
            attempt: pb.OrderStatus_ORDER_STATUS_PENDING,
        },
        {
            name:    "スキップ禁止: PENDING→SHIPPED",
            setup:   []pb.OrderStatus{},
            attempt: pb.OrderStatus_ORDER_STATUS_SHIPPED,
        },
        {
            name:    "出荷後キャンセル禁止: SHIPPED→CANCELLED",
            setup: []pb.OrderStatus{
                pb.OrderStatus_ORDER_STATUS_CONFIRMED,
                pb.OrderStatus_ORDER_STATUS_SHIPPED,
            },
            attempt: pb.OrderStatus_ORDER_STATUS_CANCELLED,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            order := createAndAdvance(t, ctx, client, tt.setup)
            _, err := client.UpdateOrderStatus(ctx, &pb.UpdateOrderStatusRequest{
                Name: order.GetName(), Status: tt.attempt,
            })
            require.Error(t, err)
            st, ok := status.FromError(err)
            require.True(t, ok)
            assert.Equal(t, codes.FailedPrecondition, st.Code(),
                "禁止された遷移は FailedPrecondition を返すべき")
        })
    }
}
```

テストはgRPC APIの公開契約のみに依存する。エージェントが状態遷移ロジックをmapで書こうがswitchで書こうが、DB制約で強制しようが、テストは関知しない。Chad Fowlerの「再生成可能性」と古典学派テストアプローチの両方と整合する設計だ。

### C#移行のGolden Fileハーネス

現在進行中のC#→Go移行では、Golden File（JSONフィクスチャ）で行動互換性を検証する。C#サービスの実レスポンスをキャプチャし、Go実装が同一のレスポンスを返すことを確認する。移行完了後に剥がすことを前提とする。本稿で言う「剥がしやすいハーネス」の典型例だ。

### 投資対効果

Testcontainersとテスト文化は既に存在する。追加投資はAGENTS.mdへのルール明記とGolden Fileのキャプチャスクリプトだけだ。テストは保険から正しさの定義に役割を変える。Borg & Tornhillの研究が示すように、健全なコードではリファクタリング失敗率が最良ケースで約30%低い[^bt1]。

---

## 構築案(6)：永続化層ハーネス：スキーマは人間が握り、AIはコードだけを書く

### 課題

コードはrevertできる。protoの変更はbuf breakingで検出できる。しかしデータの破壊は取り消せない。カラムをDROPした後にロールバックしても、データは戻らない。Chad Fowlerの「境界の内側のコードは再生成可能」という原則は、データベースのスキーマとデータには適用できない。

### 根拠

OpenAIのCodexデータエージェントガイドは「必要なテーブルへのSELECTのみを持つユーザーを作成し、書き込みは承認モードで人間が確認する」と明記している[^oa2]。Fowlerの「データ所有権の境界」[^cf1]はスキーマが境界の定義そのものであり再生成の対象ではないことを示す。

このプロジェクトではさらに一歩進めて「エージェントはSQLを書かない」とする。

### 設計

SQLBoilerがprotoと同じ構造を持つことが、この設計の鍵だ。

```text
proto定義   →  buf gen     →  Go生成コード  →  サービスが使う
DBスキーマ  →  SQLBoiler   →  Go生成コード  →  サービスが使う
```

どちらも「人間が契約を定義し、ツールがコードを生成し、エージェントは生成されたコードだけを触る」。protoファイルを変更禁止にするのと同じ理由で、`migrations/`も変更禁止とする。

```text
人間が書く（不変境界）           AIが触れる（再生成可能）
─────────────────────          ─────────────────────
  migrations/                    サービス実装コード
  SQLBoiler.toml                 ├── モデルメソッド呼び出し
                                 └── ビジネスロジック
                                       │
                                       │ SQLBoilerが生成した
                                       │ モデルを呼ぶだけ
                                       ▼
                                 models/
                                 ├── users.go           ← SQLBoiler生成
                                 └── boil_queries.go    ← SQLBoiler生成
```

SQLBoilerの生成モデルとquery modifier（qm）で、すべてのデータアクセスを一本化する。動的クエリもqmで構築できるため、生SQLや外部のクエリビルダは不要だ。データアクセスパスがスキーマから自動生成されたメソッドに限定されることで、エージェントが予期しないデータ変更を行うリスクを構造的に排除する。

MySQLのCHECK制約（8.0.16+）・NOT NULL・UNIQUE・外部キーは、アプリケーションコードの外側にあり、エージェントが迂回できない最終防衛線として機能する。構築案(5)の挙動テストを補完する多層防御だ。

### 投資対効果

スキーマとSQLBoilerモデルは既に存在する。AGENTS.mdへのルール追記だけで即日有効になり、既存運用への追加負荷は無視できる。

---

## 構築案(7)：CI構造テストハーネス：不変条件を決定論的に検証する

### 課題

Martin FowlerはOpenAIの報告を分析し、「決定論的なカスタムリンターと構造テストの両方で」アーキテクチャを監視していることを指摘した[^bb1]。AIエージェントは「ドキュメントに書いてあるから従う」のではなく、「CIで弾かれるから従う」のが最も確実な強制力だ。

### 設計

4段階のエスカレーションラダーとして実装する。

**Level 1: ドキュメント**（AGENTS.md、ADR）。最初は言語化するだけで十分なルールが多い。違反頻度が高ければ上位レベルに昇格させる。

**Level 2: Lint**（golangci-lint + buf lint）。forbidigoでfmt.Println/log.Printlnを禁止し、エラーメッセージにADR番号を含めることで、エージェントが「なぜ禁止か」まで知れる。

```yaml
linters-settings:
  forbidigo:
    forbid:
      - p: ^fmt\.Print
        msg: "slogを使ってください (ADR-0003)"
```

**Level 3: 構造テスト**（Goのテストで依存方向を検証）。サービス間の依存関係がアーキテクチャ境界を越えていないことをテストコードで検証する。

**Level 4: buf breaking**（API互換性の強制）。protoの破壊的変更をCIで自動検出する。

### 投資対効果

golangci-lintもbufも既に導入済みだ。追加投資はforbidigoの設定強化と構造テストの追加だけ。以前はモジュール境界を引いても人間が越境していた。CIで機械的に強制すれば、エージェントは確実に従う。

---

## 構築案(8)：OTEL観測ハーネス：実行時フィードバックループを閉じる

### 課題

Böckelerが指摘した重要な盲点がある。OpenAIの報告はコードの内部品質と保守性を強調しているが、「機能検証」、つまりコードがユーザーの期待通りに動作するかどうかについては手薄だ[^bb1]。構築案(1)〜(7)はいずれもビルド時・テスト時の検証だが、プロダクション環境での振る舞いを検証するハーネスも必要だ。

### 設計

OpenTelemetryはプロジェクトの標準として現在実装を進めている。統合が進んだ段階で、このインフラをエージェントのフィードバックループとして活用する。

第一に、パフォーマンス契約のテスト化だ。「レスポンスタイムを500ms以下にせよ」という要件を実行可能なテストとして定義する。第二に、トレースによるサービス間依存の可視化だ。trace_idが全サービスチェーンを貫通していれば、境界を越えた協調が機能している証拠となる。第三に、Google SRE Workbook[^sre1]のエラーバジェット概念をデプロイ後の自動ロールバック判定に活用する。

### 投資対効果

構築案(1)〜(7)は「正しいコードが書かれたか」を検証するが、(8)は「正しく動いているか」を検証する。Honeycombの記事[^hc1]が示すように、プロダクション環境こそが厳密さの再配置先だ。

---

## 対象外の領域

### B群：非同期通信層（Kafka/Redis）

Kafka/Redisには、protoのような機械可読な契約が存在しない。記事の文脈で言えば、フレーム問題への外部的対処法（境界の明示）が整備されていない領域だ。エージェントに渡しても境界を理解できないため、現時点ではハーネスの対象外とする。インターフェース定義の整備が先決であり、ハーネスはその後の話になる。

### C群：インフラ定義層（Bicep/Container Apps/ko build）

Bicep/IaCは変更不能な境界として定義する。proto（構築案(4)）やDBスキーマ（構築案(6)）と同じ扱いだ。人間が設計し、エージェントはその内側でのみ動く。AGENTS.mdに「Bicepファイルの変更禁止」と明記すれば、構築案(4)の延長で済む。

### D群：外部サービス層（Firebase/FCM、第三者API）

制御できない外部依存だ。GoMock使用が許可される唯一のケース（プロジェクトの既存方針）で対処済み。

---

## 導入戦略：段階的に、剥がしやすく

8つの構築案は独立して導入可能だが、投資対効果の順序がある。

**Phase 1（即日）**：構築案(4)（Proto契約）、(6)（永続化層）、(2)の一部（AGENTS.md作成）。既存インフラだけで実現できる。AGENTS.mdにproto変更禁止、DB変更禁止、IaC変更禁止を書いてリポジトリに置く。bufの設定を確認する。これだけでエージェントの出力品質が変わる。

**Phase 2（1-2週間）**：構築案(5)（サービス挙動テスト）のテスト不変性ルールと、(7)（CI構造テスト）のforbidigo強化。テストファイルの変更をPRレビュー必須にする設定と、エラーメッセージへのADR参照埋め込み。状態遷移の挙動テストを主要サービスから書き始める。

**Phase 3（1ヶ月）**：構築案(2)のADR運用開始、(5)のGolden Fileハーネス（C#移行用）、(3)（BFF挙動検証）の初期導入。ADRは新規判断からのみ。BFF挙動テストはチェックアウトフローなどクリティカルパスに限定。

**Phase 4（継続）**：構築案(8)（OTEL観測）と(1)（アプリE2E）。パフォーマンス契約テストを段階的に追加し、エラーバジェット閾値を設定する。Flutter E2Eは2〜3の主要ユーザージャーニーから。

重要なのは、各ハーネスが「剥がしやすい」ことだ。C#移行が完了すればGolden Fileハーネスは剥がす。モデルの能力が向上してAGENTS.mdのルールが不要になれば削除する。ハーネスは恒久的なインフラではなく、現在のモデルの限界を補完する一時的な足場である。

---

## AGENTS.md 統合版

```markdown
# AGENTS.md

## プロジェクト規約
- ロギング: slog（log/slogパッケージ）を使用。Zapは使わない（ADR-0003）。
- DB: go-sql-driver/mysql + SQLBoiler（スキーマ駆動ORM、動的クエリはqmで構築）。
- API: Google AIP準拠。
- エラー: gRPC Richer Error Model。境界で1回のみログ出力。
- テスト: Testcontainersで実DB使用。GoMockは外部依存のみ。
- コンテナ: ko build + distroless。Dockerfileは書かない。
- トレース: OpenTelemetry。全RPCにspan生成。

## 変更禁止の資産（人間が設計する領域）
- proto/ ディレクトリ: 変更はPRレビュー必須。
- migrations/ ディレクトリ: スキーマ変更は人間が設計。
- models/ ディレクトリ: SQLBoiler生成コード。手動編集禁止。
- Bicep/IaCファイル: 変更禁止。
- *_behavior_test.go: 挙動テストは人間が定義。
- integration_test/: ユーザージャーニーはプロダクトチームが定義。

## テストのルール
1. 既存テストの削除・無効化は禁止。テストはred→greenの方向にのみ動かせ。
2. テストはAPI境界でのみ挙動を検証する。内部実装をテストしてはならない。
3. テストが import するのは proto生成コード、gRPC、testcontainers のみ。
   internal パッケージの import は禁止。
4. テストが失敗した場合、テストではなく実装を修正せよ。

## データベース層のルール
1. データベースアクセスは SQLBoiler 生成モデル（models/）を通じてのみ行う。
2. database/sql を直接使ったSQLの記述は禁止。
3. 動的クエリは SQLBoiler の query modifier（qm）で構築する。
4. 新しいクエリが必要な場合、必要なクエリの仕様を報告せよ。

## 禁止事項
- fmt.Println、log.Println の使用
- Hexagonal/Clean Architectureのレイヤ構造
- Kafka/Redisの直接操作（インターフェース定義整備まで）
```

---

## まとめ

8つの構築案は、記事[^art1]の3つの構造的洞察に対応している。

**フレーム問題への対処**（何が関連し何が無関連かを判断できない）。Proto契約（(4)）、CI構造テスト（(7)）、永続化層（(6)）、そしてBicep/IaCの変更禁止が、AIの探索空間を境界で制限する。

**グラウンディング問題への対処**（正しさを感じられない）。サービス挙動テスト（(5)）、BFF挙動検証（(3)）、アプリE2E（(1)）が、テストのpass/failをAIの「正しさの感覚」として代替する。すべて境界での挙動を検証し、実装には関知しない。

**認識論的寄生の限界への対処**（書かれたものしか理解できない）。リポジトリ文書（(2)）がAIを人間の世界に招待し、OTEL観測（(8)）がプロダクション環境でのフィードバックループを閉じる。

どれも新しい技術ではない。proto、buf、Testcontainers、slog、golangci-lint、OpenTelemetry、ADR、SQLBoiler、Patrol。すべて既に手元にある道具だ。変わるのは使い方だけである。

手綱を握れ。長年磨いてきた技術こそが、その手綱だ。

---

## 脚注

### 記事

[^art1]: Takekazu Omi (2026)「手綱を握れ：AIコーディングで主導権を取り戻すためのハーネスの考え方」 <https://zenn.dev/takekazuomi/articles/take-the-reins>

### ハーネスエンジニアリングの一次ソース

[^mh1]: Mitchell Hashimoto (2026-02-05)"My AI Adoption Journey"。ハーネスエンジニアリングの命名。 <https://mitchellh.com/writing/my-ai-adoption-journey>
[^oa1]: OpenAI (2026-02-11)"Harness engineering: leveraging Codex in an agent-first world"。100万行・手書きゼロの実験。「中央で境界を強制し、局所で自律を許す」。 <https://openai.com/index/harness-engineering/>
[^bb1]: Birgitta Böckeler (2026-02-17)"Harness Engineering" (martinfowler.com)。「Agent = Model + Harness」の定式化。機能検証用のハーネスは発展途上と指摘。 <https://martinfowler.com/articles/exploring-gen-ai/harness-engineering.html>
[^an1]: Anthropic (2026-03)"Harness design for long-running application development"。Playwright MCPによるアプリ検証とGenerator-Evaluator分離。 <https://www.anthropic.com/engineering/harness-design-long-running-apps>

### 厳密さの再配置

[^hc1]: Honeycomb (2026-03)"Production Is Where the Rigor Goes"。Chad Fowler「厳密さの再配置」。 <https://www.honeycomb.io/blog/production-is-where-the-rigor-goes>
[^cf1]: Martin Fowler Fragments (2026-03-16)Chad Fowler on Regenerative Software。境界内コードの再生成可能性。「データ所有権の境界」と「評価面」。 <https://martinfowler.com/fragments/2026-03-16.html>

### テストとTDD

[^kb1]: Kent Beck"TDD, AI agents and coding with Kent Beck" (Pragmatic Engineer)。TDDはAIエージェント時代のsuperpower。 <https://newsletter.pragmaticengineer.com/p/tdd-ai-agents-and-coding-with-kent>
[^kb2]: Kent Beck"Augmented Coding: Beyond the Vibes"。テストは不変の注釈でありエージェントに変更を許さない。 <https://www.allstacks.com/blog/how-to-write-specs-for-ai-agents-tdd-skills-and-what-comes-next>

### コード品質とAI適性

[^bt1]: Borg & Tornhill (2026-01)"Code for Machines, Not Just Humans"。5,000ファイル×6 LLMの実証研究。健全なコードは欠陥リスク30%以上低い。 <https://arxiv.org/html/2601.02200v1>

### 挙動テスト vs 実装テスト

[^ep1]: Epsilla (2026-03)"Harness Engineering: Why the Focus is Shifting"。「完全なハーネスは振る舞いの正しさを検証しなければならない」。 <https://www.epsilla.com/blogs/2026-03-12-harness-engineering>
[^im1]: morphllm (2026)"Agent Engineering: IMPACT Framework"。「失敗するテストは望ましい振る舞いの曖昧さのない仕様」。 <https://www.morphllm.com/agent-engineering>

### protoのセマンティクスの欠落

[^pf1]: Pactflow"Contract testing Protobufs, gRPC & Avro with Pact"。「Protobufはセマンティックな保証を一切提供しない」。 <https://pactflow.io/blog/the-case-for-contract-testing-protobufs-grpc-avro/>
[^sh1]: Stevan Harnad (1990)"The Symbol Grounding Problem", Physica D。 <https://philpapers.org/rec/HARTSG>

### BFFパターン

[^sn1]: Sam Newman"Backends For Frontends"。BFFパターンの定義。 <https://samnewman.io/patterns/architectural/bff/>
[^up1]: Uplatz (2025-11)"The BFF Pattern: A Strategic Blueprint"。BFFをAnti-Corruption Layerとして分析。 <https://uplatz.com/blog/the-backend-for-frontend-bff-pattern-a-strategic-blueprint-for-client-centric-api-architecture/>

### Flutter E2E

[^pt1]: LeanCode (2025-12)"Patrol 4.0 Released"。Flutter E2Eテストフレームワーク。 <https://leancode.co/blog/patrol-4-0-release>

### データベースとAI

[^oa2]: OpenAI (2026-02)"Using Codex to Build a Data Agent"。最小権限、SELECT限定、承認モード。 <https://index.app/blog/using-codex-to-build-data-agent>

### その他

[^sre1]: Google SRE Workbook"Implementing SLOs"。エラーバジェット概念。 <https://sre.google/workbook/implementing-slos/>
