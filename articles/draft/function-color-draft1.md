---
title: "関数の「色」問題：Go 1.26とC# 13の並行処理設計の分岐点"
emoji: ""
type: "tech"
topics: []
published: false
---

## はじめに

2015年、DartチームのBob Nystromが「What Color is Your Function?」というブログ記事を公開した。この記事は並行処理の言語設計における根本的な選択を、関数の「色」という比喩で鮮やかに描き出した。それから10年が経ち、この問題意識は言語設計の分水嶺として定着している。GoとC#はこの問題に対して正反対のアプローチを取り、その選択は各言語のエコシステム全体に波及している。

本レポートでは、関数の色問題の本質を技術的に掘り下げ、GoとC#の設計選択の違いを公式ソースとコミュニティの議論に基づいて整理する。さらに、主要なプログラミング言語がどちらの方式を選択したか（あるいは第三の道を模索しているか）を俯瞰する。

---

## 関数の「色」問題とは何か

### Nystromの原記事の核心

Nystromは架空の言語を想定し、すべての関数に「赤」か「青」の色が付く世界を描いた。この比喩における「赤」は非同期関数、「青」は同期関数に対応する。問題を構成するルールは以下の5つである。

1. すべての関数は赤か青のどちらかの色を持つ
2. 色は関数の呼び出し方を決定する
3. 青い関数から赤い関数を呼ぶことはできない（同期関数から非同期関数を直接呼べない）
4. 赤い関数は呼び出しがより面倒である（`await`が必要）
5. 赤い関数が増殖していく

3番目のルールが最も深刻だ。Nystromはこれを「ウイルス的伝播」と表現した。ある関数がI/O操作を行う非同期関数を呼ぶ必要が出ると、その関数自体も非同期にせざるを得ない。この変更は呼び出し階層を遡って`main()`まで伝播する可能性がある。

### 技術的な根本原因

この問題の根底にあるのは「I/O操作が完了したとき、どうやって中断箇所から再開するか」という問いである。Nystromは3つのアプローチを整理した。

**コールバック/Promise方式**では、非同期関数をクロージャの連鎖に分解してヒープに配置する。イベントループがI/O完了時にクロージャを呼び出す。しかしこの場合、中断箇所より上のすべてのスタックフレームも巻き戻す必要がある。これが「赤い関数からしか赤い関数を呼べない」というルールの技術的根拠となる。

**async/await方式**（C#が先駆）は、コンパイラがステートマシンを生成することでコールバック地獄を解消する。しかしNystromが指摘した通り、関数の二色問題自体は解決しない。`async`関数は`Task<T>`を返し、呼び出し側は`await`する必要がある。世界は依然として二分されたままである。

**複数のコールスタック方式**（Go、Erlang等）では、各並行タスクが独立したコールスタックを持つ。I/O操作時にコールスタック全体を一時停止し、別のコールスタックに切り替える。上位の関数まで巻き戻す必要がないため、関数に色は付かない。

Nystromは記事の中で明確にGoを名指しした：「**Three more languages that don't have this problem: Go, Lua, and Ruby.**」。その理由は「**Threads. Or, more precisely: multiple independent callstacks that can be switched between.**」である。

---

## C#の選択：明示的な非同期境界

### async/awaitの技術的仕組み

C#は2012年のバージョン5.0で`async`/`await`を導入し、この方式の先駆者となった。技術的には、コンパイラが`async`メソッドを構造体ベースのステートマシンに変換する。各`await`地点がステートマシンの状態遷移点となり、同期完了した場合はヒープ割り当てが発生しない。真に非同期の場合のみステートマシンがヒープにボクシングされる。

`async`/`await`がC#にもたらした恩恵は大きい。コールバック地獄は解消され、`try`/`catch`がそのまま使え、制御フローの中に自然に`await`を埋め込める。しかし、色問題は残る。`async`メソッドは`Task<T>`を返し、同期メソッドからは`.Result`や`.GetAwaiter().GetResult()`でブロッキング待機するしかない。さらに`SynchronizationContext`の捕捉と`ConfigureAwait`の使い分けという、学習コストの高い概念が加わる。Stephen Clearyがまとめた`ConfigureAwait` FAQは.NETコミュニティの必読文献となっているが、そもそもこの種のFAQが必要な時点で複雑さの証左と言える。

### C#側の擁護論

Terry Crowleyは2022年の記事でNystromに対する反論を展開した。彼の主張の核心は「同期と非同期の区別は恣意的な『側面』ではなく、現実世界の根本的な性質である」というものだ。長時間実行されるアプリケーションでは、ローカルで高速な操作（同期）とリモートで低速な操作（非同期）を区別することが設計上不可欠であり、非同期関数はエラー特性、タイムアウト制御、キャンセル機能、内部状態管理において同期関数とは本質的に異なるとCrowleyは主張する。

この観点に立てば、`async`は面倒な「色」ではなく、むしろ有益な**型レベルの文書化**である。関数がブロッキングする可能性があるかどうかをシグネチャから読み取れることは、大規模システムの設計において価値がある。

Cory Benfield（Pythonのhttpコアライブラリの作者）もNystromに対する反論を公開し、関数の色は「非同期性をプログラマに可視化する」ために時として良いトレードオフであると述べた。Arthur O'Dwyer（C++）はさらに踏み込んで、関数の「色」は型システムの自然な拡張であり、返り値の型や例外の有無と本質的に同じだと論じた。

### .NET 8/9における改善

.NET 8以降、`ConfigureAwait`の痛みはASP.Coreの`SynchronizationContext`廃止によりサーバーサイドでは大幅に軽減された。ASP.NET Coreには`SynchronizationContext`が存在しないため、`ConfigureAwait(false)`を至る所に書く必要がなくなっている。しかしデスクトップUI（WPF、WinForms）やXamarin/MAUIでは依然として問題が残り、ライブラリ作者は両方のコンテキストで動作するコードを書くために`ConfigureAwait(false)`を付ける慣習が続いている。

---

## Goの選択：色のない世界

### ゴルーチンの設計思想

Goはすべての関数を同じ「色」で扱う。I/O操作を行う関数とCPU計算を行う関数の間に構文上の区別はない。この設計はTony Hoareの1978年のCSP（Communicating Sequential Processes）論文に遡り、Rob PikeとKen Thompsonが言語レベルに統合した。

技術的には、GoのランタイムはM:Nスケジューリング（GMP: Goroutine-Machine-Processorモデル）を実装している。ゴルーチンは初期スタック約2KBの軽量スレッドであり、`go`キーワード一つで起動する。I/O操作時にはnetpoller（epoll/kqueue）が透過的にゴルーチンをパークし、I/O完了時に再開する。ブロッキングsyscallが発生した場合は、Mスレッド（OSスレッド）がP（論理プロセッサ）から切り離され、別のMスレッドがPを引き継ぐ。Go 1.14以降はプリエンプティブスケジューリング（最大10msでの強制コンテキストスイッチ）を導入し、Go 1.26（2026年2月）ではGreen Tea GCがデフォルトとなった。Green Tea GCはオブジェクト単位のトラバースではなく、連続メモリブロック（span）単位のスキャンを行うことでキャッシュ局所性を改善し、マルチコアCPU上でのGCスキャン性能を向上させている。

Go 1.26のもう一つの注目すべき変更は、**実験的なゴルーチンリークプロファイラ**（`runtime/pprof`のgoroutineleakプロファイル）である。Uberの Vlad Saiocが貢献したこの機能は、到達不能な並行プリミティブ（チャネル、`sync.Mutex`、`sync.Cond`等）でブロックされたゴルーチンを検出できる。色のない世界における「見えない並行処理のデバッグ困難性」というトレードオフに対する、ランタイムレベルでの回答と言える。

Roman Elizarov（Kotlinコルーチンのリード設計者）はGoの方式を高く評価している：「**Go does not color its functions at all. Any function in Go has a right to suspend its goroutine by doing an IO operation.**」。彼は「Go is the language that does this most beautifully in my opinion」とまで述べた。

### Goの方式のトレードオフ

色のない世界は無料ではない。以下のトレードオフが存在する。

**ランタイムの暗黙的コスト**がある。すべてのゴルーチンがスタックを持ち、スケジューラがバックグラウンドで動作する。C#のasync/awaitはコンパイル時にステートマシンに変換されるため、ランタイムオーバーヘッドが最小限であるのに対し、Goはランタイムの複雑さと引き換えにプログラマの単純さを買っている。

**C ABI互換性の犠牲**もある。Lobsters上の議論で指摘されたように、GoはC ABIとランタイムを完全に独自実装しており、Cライブラリとの統合（cgo）にはオーバーヘッドが伴う。async/await方式の言語（C#、Rust、C++）はOSスレッドモデルとC ABIに互換性を保つ代わりに、関数の色問題を受け入れている。ただし**Go 1.26ではcgoのベースラインオーバーヘッドが約30%削減**された。従来のランタイムではsyscall/cgo呼び出し中のPに専用のsyscall状態を使っていたが、Go 1.26ではこの状態が除去され、ゴルーチンのステータスから直接判定する方式に変わった。Apple M1上のベンチマークではCgoCallが33.4%高速化しており、FFI多用のワークロードでは顕著な改善となる。

**ブロッキングの不可視性**が問題になるケースもある。Terry Crowleyが指摘したように、Goではある関数がネットワーク越しの遅い操作を行うのか、メモリ内の高速な操作を行うのかが関数シグネチャからは判別できない。これは大規模システムの設計において不利になりうる。ただし、Goコミュニティは`context.Context`を第一引数として渡す慣習によって、長時間操作のタイムアウトとキャンセルを統一的に扱っている。

---

## 言語の分類：3つのアプローチ

関数の色問題に対する言語の対応は、大きく3つのグループに分類できる。

### グループ1：色なし（ランタイムが透過的に管理）

このグループの言語は、M:Nスケジューリングや軽量プロセスによって、すべての関数を同じ「色」で扱う。プログラマは同期的なコードを書き、ランタイムが並行性を透過的に管理する。

| 言語 | 方式 | 備考 |
|------|------|------|
| **Go** | ゴルーチン（M:N, GMP） | CSP由来。チャネルとselect文が言語プリミティブ。1.26でGreen Tea GCデフォルト化、cgo 30%高速化、goroutineリーク検出（実験的） |
| **Erlang/Elixir** | BEAMプロセス | アクターモデル。プロセスあたり約300ワード。リダクションカウントによるプリエンプション |
| **Java 21+** | 仮想スレッド（Project Loom） | JDK 21でGA。既存のブロッキングAPIをそのまま使用可能。色問題の回避が明示的な設計目標 |
| **Lua** | コルーチン（協調型） | 言語組み込みの`coroutine.yield`/`coroutine.resume` |
| **Ruby** | Fiber（Ruby 3.0+） | Fiber Schedulerにより非同期I/Oをランタイムが管理 |
| **Haskell** | 軽量スレッド（GHC RTS） | M:Nスケジューリング。`forkIO`でスレッド起動。IOモナドは別の「色」とも言えるが、遅延評価で問題が緩和される |

Java 21の仮想スレッド（Project Loom）は特筆に値する。Oracle Java Magazineの記事によれば、Project Loomの設計において「async-awaitや色付き関数のような非同期伝播を示す複雑なプログラミングモデルを避けること」が主要な設計目標だった。Nystromが2015年にJavaはasync/awaitを導入するだろうと予測したが、Javaチームは他言語でのasync/await採用者の経験を観察した結果、それは正しい方向ではないと結論づけた。Red Hatの記事は「**avoiding more complex programming models that display asynchronous contagion (such as async-await or colored functions) was a major design goal for Project Loom**」と明確に述べている。

### グループ2：色あり（async/awaitによる明示的二分）

このグループの言語は、関数を同期と非同期に明示的に分離する。コンパイラがステートマシン変換を行い、プログラマは`async`/`await`キーワードで非同期境界を管理する。

| 言語 | 導入年 | 備考 |
|------|--------|------|
| **C#** | 2012（C# 5.0） | 先駆者。`Task<T>`/`ValueTask<T>`。.NET 8+でサーバー側のConfigureAwait問題が軽減 |
| **JavaScript** | 2017（ES2017） | `Promise`ベース。シングルスレッドイベントループ。色問題が最も顕著 |
| **TypeScript** | 2017 | JavaScriptの型付き拡張。async/awaitをそのまま継承 |
| **Python** | 2015（3.5） | `asyncio`。色問題が深刻で`asyncio.run()`/`await`の二重世界。ライブラリのasync版とsync版が並存 |
| **Dart** | 2015 | `Future<T>`ベース。Nystrom自身のチームの言語だが色問題を持つ。後にIsolateで緩和 |
| **Rust** | 2019（1.39） | ゼロコスト`Future`。ランタイム非同梱（tokio等）。色問題あり+Pinの複雑さ |
| **Swift** | 2021（5.5） | `async`/`await` + Actor。WWDC 2021で導入。構造化並行処理を重視 |
| **C++** | 2020（C++20） | コルーチン（co_await/co_yield/co_return）。標準ライブラリの統合は未成熟 |

Rustは興味深い位置にある。Rustはゼロコスト抽象を原則とし、ランタイムを言語に組み込まない設計を選んだ。結果としてasync/awaitは言語に入ったが、ランタイム（tokio, async-std等）はエコシステムに委ねられた。Lobstersの議論では「**Async style language features are a compromise between your execution model being natively compatible with the 1:1 C ABI, C standard library, and C runtime and a M:N execution model**」と指摘されている。RustはC ABIとの互換性を優先し、その代償として色問題を受け入れた。

### グループ3：第三の道を模索

いくつかの言語は、上記2つのアプローチのどちらにも完全には分類できない独自の方式を採っている。

| 言語 | 方式 | 備考 |
|------|------|------|
| **Kotlin** | `suspend`関数 + コルーチン | 色あり（`suspend`修飾子）だが、awaitが不要でPromiseフリー。JVM互換性のための妥協 |
| **Zig** | コンパイル時async変換 | 0.16.0で再設計中。関数パラメータでasync動作を注入。色問題を回避しつつゼロコスト |

Kotlinの位置づけについて、Roman Elizarovは自ら解説している。Kotlinの`suspend`はC#の`async`と概念的に同等だが、重要な違いがある。Kotlinでは`await`が不要であり、`suspend`関数の戻り値は`Future<T>`でラップされずプレーンな`T`として返る。しかしJVMエコシステムとの相互運用性のために`suspend`修飾子を完全に排除することはできない。Elizarovは「**We cannot eliminate suspend completely. Kotlin has to be interoperable with the JVM ecosystem where functions are blocking and asynchrony is represented via callbacks and futures**」と説明した。つまりKotlinの色問題はJVMという制約に起因する技術的妥協であり、言語設計者の本意ではない。

---

## 技術的比較：同じHTTP呼び出しをどう書くか

同じ問題——「2つのURLから並行にデータを取得し、結合して返す」——に対する両言語の実装を見ると、設計哲学の違いが如実に表れる。

### Go：色のないコード

```go
func fetchBoth(ctx context.Context, url1, url2 string) ([]byte, []byte, error) {
    g, ctx := errgroup.WithContext(ctx)
    var body1, body2 []byte

    g.Go(func() error {
        resp, err := http.Get(url1)
        if err != nil {
            return err
        }
        defer resp.Body.Close()
        body1, err = io.ReadAll(resp.Body)
        return err
    })

    g.Go(func() error {
        resp, err := http.Get(url2)
        if err != nil {
            return err
        }
        defer resp.Body.Close()
        body2, err = io.ReadAll(resp.Body)
        return err
    })

    if err := g.Wait(); err != nil {
        return nil, nil, err
    }
    return body1, body2, nil
}
```

`fetchBoth`のシグネチャに`async`修飾子はない。`http.Get`は内部で非同期I/Oを行うが、呼び出し側から見れば通常の関数呼び出しと何も変わらない。`errgroup`は構造化並行処理を提供するが、言語レベルの制約ではなくライブラリのパターンである。

### C#：色のあるコード

```csharp
async Task<(byte[], byte[])> FetchBothAsync(string url1, string url2)
{
    using var client = new HttpClient();
    var task1 = client.GetByteArrayAsync(url1);
    var task2 = client.GetByteArrayAsync(url2);
    var results = await Task.WhenAll(task1, task2);
    return (results[0], results[1]);
}
```

`FetchBothAsync`は`async`で修飾され、`Task<T>`を返す。これを呼び出す関数もまた`async`である必要がある。`HttpClient.GetByteArrayAsync`は非同期メソッドであり、同期版の`GetByteArray`は存在しない（.NETでは非同期I/Oが推奨される）。

C#のコードはGoより簡潔に見えるが、この関数を呼ぶすべての関数に`async`と`await`が伝播する。一方Goでは、`fetchBoth`を呼ぶ側は通常の関数呼び出しとして扱える。

---

## キャンセルの伝播：色問題の「第二の色」

関数の色問題を実務で最も痛感するのは、キャンセル処理を追加するときだろう。C#の`CancellationToken`とGoの`context.Context`は同じ問題——「もう結果に興味がなくなった処理を止める」——を解決するが、色問題の有無がキャンセルの設計パターンに根本的な影響を及ぼしている。

### C#：async + CancellationToken = 二重の色

C#では、キャンセル対応の非同期メソッドは必然的に`async` **かつ** `CancellationToken`を受け取る。Stephen Clearyはキャンセルのパターンについて「キャンセルコードの約90%は、メソッドに`CancellationToken`パラメータを追加して呼び出し先に渡すだけ」と述べている。Microsoft公式のコード分析ルールCA1068は「`CancellationToken`パラメータは最後に置くべき」と規定しており、これは.NETエコシステム全体の慣習となっている。

問題は、`async`と`CancellationToken`が**二つの独立した「色」として同時にシグネチャを汚染する**ことだ。あるメソッドにキャンセルサポートを追加すると、呼び出し階層のすべての関数に`CancellationToken`パラメータが伝播する。これはasyncの伝播とまったく同じウイルス的な性質を持つ。

```csharp
// タイムアウト付き並行フェッチ（C# 13）
// async + CancellationToken + ConfigureAwait の三重奏
async Task<(byte[], byte[])> FetchBothAsync(
    string url1, string url2,
    CancellationToken cancellationToken = default)   // ← 色の二重化
{
    using var client = new HttpClient();
    using var cts = CancellationTokenSource
        .CreateLinkedTokenSource(cancellationToken);  // ← 外部トークンとリンク
    cts.CancelAfter(TimeSpan.FromSeconds(5));         // ← タイムアウト

    try
    {
        var task1 = client.GetByteArrayAsync(url1, cts.Token);
        var task2 = client.GetByteArrayAsync(url2, cts.Token);
        var results = await Task.WhenAll(task1, task2)
            .ConfigureAwait(false);                   // ← ライブラリ作者の義務
        return (results[0], results[1]);
    }
    catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
    {
        throw; // 外部からのキャンセル → 再スロー
    }
    catch (OperationCanceledException)
    {
        throw new TimeoutException("fetch timed out"); // 内部タイムアウト → 変換
    }
}
```

このコードには3つの「色」的関心事が混在している。第一に`async`/`await`（関数の色）。第二に`CancellationToken`の伝播（キャンセルの色）。第三に`ConfigureAwait(false)`（ライブラリ作者がUIスレッドコンテキストのキャプチャを防ぐための儀式）。Stephen Clearyが.NET 8でのConfigureAwaitについてまとめたように、ASP.NET Coreでは`SynchronizationContext`がないためサーバー側では不要だが、ライブラリコードは**どのコンテキストで呼ばれるかわからない**ため、依然として`ConfigureAwait(false)`を付ける必要がある。

さらに厄介なのは`OperationCanceledException`の**二義性**である。同じ例外型が「外部からのキャンセル要求」と「内部タイムアウト」の両方で投げられるため、`catch`ブロックで`cancellationToken.IsCancellationRequested`を確認して原因を区別する必要がある。高性能ネットワーククライアントのAlterNats作者は、外部キャンセル・タイムアウト・Disposeの3つが組み合わさる状況でのCancellationToken処理を「パターン化しないと正しく書けない」と述べている。

### Go：context.Context の統一的世界

Goの`context.Context`はSameer Ajmaniが2014年にGoogleの内部パッケージとして設計し、Go 1.7（2016年）で標準ライブラリに昇格した。Ajmaniはその動機を次のように説明した：「Goサーバーでは、各リクエストは独自のゴルーチンで処理される。リクエストハンドラはデータベースやRPCサービスにアクセスするために追加のゴルーチンを起動することが多い。リクエストがキャンセルまたはタイムアウトしたとき、そのリクエストに関わるすべてのゴルーチンが速やかに終了すべきである」。

```go
// タイムアウト付き並行フェッチ（Go 1.26）
// context.Context が唯一の制御チャネル
func fetchBoth(ctx context.Context, url1, url2 string) ([]byte, []byte, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second) // ← タイムアウト
    defer cancel()                                          // ← リソースリーク防止

    g, ctx := errgroup.WithContext(ctx)                     // ← 子タスクへキャンセル伝播
    var body1, body2 []byte

    g.Go(func() error {
        req, err := http.NewRequestWithContext(ctx, "GET", url1, nil)
        if err != nil {
            return err
        }
        resp, err := http.DefaultClient.Do(req)
        if err != nil {
            return err
        }
        defer resp.Body.Close()
        body1, err = io.ReadAll(resp.Body)
        return err
    })

    g.Go(func() error {
        req, err := http.NewRequestWithContext(ctx, "GET", url2, nil)
        if err != nil {
            return err
        }
        resp, err := http.DefaultClient.Do(req)
        if err != nil {
            return err
        }
        defer resp.Body.Close()
        body2, err = io.ReadAll(resp.Body)
        return err
    })

    if err := g.Wait(); err != nil {
        return nil, nil, err
    }
    return body1, body2, nil
}
```

このGoのコードとC#のコードを並べると、設計思想の違いが明瞭になる。

**第一に、色の数が異なる。** C#では`async` + `CancellationToken`（+ `ConfigureAwait`）の多重色だが、Goでは`context.Context`が唯一の制御面である。キャンセル、タイムアウト、デッドライン、リクエストスコープ値のすべてが一つのインターフェースに統合されている。公式ドキュメントは「**The Context should be the first parameter, typically named ctx**」と明記しており、これは`CancellationToken`が**最後のパラメータ**であるC#の慣習と正反対だ。Goのctxは関数の主目的に付随する補助パラメータではなく、ゴルーチンのライフサイクルを制御する**第一級の関心事**として設計されている。

**第二に、キャンセルの同期/非同期区別がない。** C#では`CancellationToken`は本来同期コードでも使えるが、実際には非同期メソッドと組み合わせて使うことがほとんどであり、`async Task Method(CancellationToken ct)`というシグネチャが事実上のセットになっている。Goでは`context.Context`は同期関数にも非同期処理にも同じように渡される。データベースクエリ、HTTP呼び出し、CPU計算の中断、すべてが同じパターンである。

**第三に、エラーの区別が明確である。** C#では`OperationCanceledException`が外部キャンセルとタイムアウトの両方で使われるため、catchブロックでの判別が必要。Goでは`context.DeadlineExceeded`（タイムアウト）と`context.Canceled`（明示キャンセル）がセンチネルエラーとして区別されており、`errors.Is(err, context.DeadlineExceeded)`で一意に判定できる。

**第四に、構造化並行処理との統合が自然である。** `errgroup.WithContext(ctx)`は子ゴルーチンの一つが失敗すると自動的にコンテキストをキャンセルし、他の子ゴルーチンにキャンセルが伝播する。C#の`Task.WhenAll` + `CancellationToken`でも同様のパターンは実現可能だが、`CancellationTokenSource.CreateLinkedTokenSource`で手動リンクし、`try`/`catch`でキャンセル例外を処理する必要がある。

### 観察の概要

| 観点 | C# (`CancellationToken`) | Go (`context.Context`) |
|------|--------------------------|------------------------|
| パラメータ位置 | 慣習的に**最後** (CA1068) | 慣習的に**最初** (`ctx`) |
| 非同期との結合 | `async` + `CancellationToken`が事実上セット | 同期/非同期の区別なし |
| タイムアウト | `CancellationTokenSource.CancelAfter` | `context.WithTimeout` |
| デッドライン | `CancellationTokenSource.CancelAfter`で代替 | `context.WithDeadline`（ネイティブ） |
| エラー判別 | `OperationCanceledException`の`CancellationToken`プロパティで判別 | `context.Canceled` / `context.DeadlineExceeded`（センチネルエラー） |
| 構造化並行処理 | `CreateLinkedTokenSource` + `Task.WhenAll` | `errgroup.WithContext`（自動伝播） |
| ConfigureAwait問題 | ライブラリコードで必須 | 該当概念なし |
| 値の伝搬 | 別メカニズム（`AsyncLocal<T>`等） | `context.WithValue`で統合（ただし型安全でない） |

### Go Proverbsとの関係

Goの`context.Context`の設計は、Go Proverbsの複数の格言を体現している。

「**Don't communicate by sharing memory, share memory by communicating.**」——contextの`Done()`チャネルはまさにキャンセルシグナルの「通信」であり、共有フラグの検査ではない。`select`文と組み合わせることで、複数のゴルーチンが同じキャンセルシグナルを受信できる。

「**Channels orchestrate; mutexes serialize.**」——contextはチャネルベースのキャンセル伝播であり、mutex的なロックではない。親コンテキストがキャンセルされると、すべての子コンテキストの`Done()`チャネルが閉じられる。

「**Make the zero value useful.**」——`context.Background()`はゼロ値的な「空のコンテキスト」として使え、キャンセルもデッドラインも値も持たない。これが`CancellationToken.None`に相当するが、Goではこれがコンテキストチェーンのルートとして自然に機能する。

結局のところ、キャンセル処理の設計は関数の色問題の**増幅器**として働く。C#では`async`の伝播に`CancellationToken`の伝播が重なり、さらにライブラリコードでは`ConfigureAwait(false)`が加わる。Goでは`context.Context`が唯一のパラメータとしてすべてを統合し、関数の色が存在しないため「二重の色」問題そのものが発生しない。

---

## コミュニティの議論：収束しつつある方向性

### Java 21の選択が示すもの

2023年にJava 21がProject Loomの仮想スレッドをGA（General Availability）として出荷したことは、関数の色問題に対する業界の態度の転換を象徴している。Javaは世界で最も広く使われているサーバーサイド言語の一つであり、その設計チームがasync/awaitを明示的に拒否してGoスタイルの仮想スレッドを選んだことは重い。仮想スレッドのAPI設計は意図的に既存の`java.lang.Thread`と互換であり、既存のブロッキングコードをそのまま仮想スレッド上で実行できる。Netflixは仮想スレッドへの移行で劇的なスケーラビリティ向上を報告している（ただしデッドロック問題も発見し、Java 25で修正された）。

### Pythonのエコシステム分裂

Pythonはasync/awaitを導入したが、色問題が最も深刻に現れた言語の一つとなった。`requests`（同期）と`aiohttp`（非同期）、`psycopg2`（同期）と`asyncpg`（非同期）のように、主要ライブラリの同期版と非同期版が並存する状況が生まれた。この二重エコシステムの維持コストはコミュニティにとって大きな負担である。

### Rustのasync疲弊

Rustコミュニティでは「Avoid Async Rust」という記事がLobstersで活発に議論されるなど、async/awaitの複雑さに対する不満が根強い。`Pin`、ライフタイムとasyncの相互作用、ランタイム選択の複雑さが参入障壁となっている。一方で、RustがC ABIとの互換性とゼロコスト抽象を原則とする以上、Goスタイルのランタイムは採用できないという構造的な制約がある。

---

## 歴史的系譜：CSPからProject Loomまで

```
1978  Tony Hoare「Communicating Sequential Processes」論文
       └→ CSP理論の確立
           │
1985  Occam言語（Hoare の CSP を直接実装）
           │
1995  Erlang/OTP（Ericsson）
       └→ BEAMプロセス（アクターモデル）
       └→ 「色なし」の先駆
           │
2007  Rob Pike「Newsqueak」→ Limbo → Plan 9
       └→ CSPの実践的研究
           │
2009  Go 言語公開（Pike, Thompson, Griesemer）
       └→ ゴルーチン + チャネル
       └→ M:N スケジューリング
           │
2012  C# 5.0: async/await 導入（Hejlsberg）
       └→ 「色あり」方式の確立
       └→ 以後、JS/Python/Dart/Swift/Rust が追従
           │
2015  Bob Nystrom「What Color is Your Function?」
       └→ 問題の定式化
           │
2018  Project Loom 発表（Ron Pressler, Alan Bateman）
       └→ Java が「色なし」を選択
           │
2019  Kotlin Coroutines 安定版（Elizarov）
       └→ 第三の道：色ありだが await 不要
           │
2021  Swift 5.5: async/await + Actor 導入
       └→ 構造化並行処理を重視
           │
2023  Java 21: 仮想スレッド GA
       └→ 業界の潮流転換の象徴
           │
2025+ Zig: コンパイル時 async 変換を再設計中
           │
2026  Go 1.26: Green Tea GC デフォルト化、cgo 30%高速化
       └→ goroutine リーク検出プロファイラ（実験的）
       └→ 「色なし」方式のランタイム品質がさらに向上
```

この系譜を見ると、Hoareの1978年のCSP論文から始まった「メッセージパッシングによる並行処理」の思想が、Erlang→Go→Java 21と受け継がれ、一方でC# 5.0が確立した「明示的非同期マーキング」の系譜がJS→Python→Swift→Rustへと広がったことがわかる。しかし2020年代に入り、Javaの仮想スレッド採用に象徴されるように、「色なし」方向への揺り戻しが起きている。

---

## まとめ：どちらが「正しい」のか

結論から言えば、どちらも正しい。ただし、**正しさの基準が異なる**。

Goの方式は「プログラマの認知負荷の最小化」を最適化する。すべての関数が同じ色であるため、並行性の導入がリファクタリングの連鎖を引き起こさない。これはGoの「Simplicity is Complicated」（Rob Pike, dotGo 2015）という設計哲学の直接的な帰結である。代償はランタイムの複雑さとC ABI互換性の犠牲だが、Go 1.26ではcgoオーバーヘッドが約30%削減され、Green Tea GCのデフォルト化でGC性能も向上した。さらにgoroutineリーク検出プロファイラの導入により、「色のない世界でのデバッグ困難性」というトレードオフも緩和されつつある。

C#の方式は「非同期性の明示化と型安全性」を最適化する。Terry Crowleyが主張したように、非同期操作と同期操作の区別は現実世界の根本的な性質を反映しており、これを型レベルで表現することには設計上の価値がある。UIフレームワーク、分散システム、あるいはRustのようにCとの密接な統合が必要な領域では、この明示性が重要となる。

**最も注目すべきは、業界の方向性がGoの側に傾きつつあることだ。** Java 21の仮想スレッド、Ruby 3.0のFiber Scheduler、そしてKotlinのElizarovの「理想的にはsuspendを排除したい」という発言はいずれも、「色なし」の世界が開発者体験において優れているという認識の広がりを示している。ただしRustやC++のようにC ABIとの互換性が不可欠な領域では、async/await方式が構造的に不可避であり、この二分は今後も続くだろう。

---

## 主要参考URL

| カテゴリ | リソース | URL |
|---------|---------|-----|
| 原典 | Bob Nystrom「What Color is Your Function?」(2015) | https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/ |
| 反論 | Terry Crowley「What Color is Your Function? You Better Know!」(2022) | https://terrycrowley.medium.com/what-color-is-your-function-you-better-know-f6f3f07a1ee1 |
| 反論 | Cory Benfield「The Function Colour Myth」(2016) | https://lukasa.co.uk/2016/07/The_Function_Colour_Myth/ |
| Kotlin | Roman Elizarov「How do you color your functions?」(2019) | https://elizarov.medium.com/how-do-you-color-your-functions-a6bb423d936d |
| Go設計 | Rob Pike「Concurrency is not Parallelism」(2012) | https://go.dev/talks/2012/waza.slide |
| Go設計 | Rob Pike「Go Concurrency Patterns」(2012) | https://go.dev/talks/2012/concurrency.slide |
| Go設計 | Go公式ブログ「Share Memory By Communicating」 | https://go.dev/blog/codelab-share |
| Go 1.26 | Go 1.26 リリースノート | https://go.dev/doc/go1.26 |
| Go 1.26 | Go 1.26 リリースブログ | https://go.dev/blog/go1.26 |
| Go 1.26 | Anton Zhiyanov「Go 1.26 interactive tour」 | https://antonz.org/go-1-26/ |
| CSP | Tony Hoare, CSP論文 (1978) | https://www.cs.cmu.edu/~crary/819-f09/Hoare78.pdf |
| Java | Oracle Java Magazine「Virtual Threads」 | https://blogs.oracle.com/javamagazine/java-virtual-threads/ |
| Java | Red Hat「Beyond Loom: Weaving new concurrency patterns」(2023) | https://developers.redhat.com/articles/2023/10/03/beyond-loom-weaving-new-concurrency-patterns |
| Java | JEP 444: Virtual Threads | https://openjdk.org/jeps/444 |
| C# | Stephen Toub「How Async/Await Really Works in C#」 | https://devblogs.microsoft.com/dotnet/how-async-await-really-works/ |
| C# | Stephen Toub「ConfigureAwait FAQ」 | https://devblogs.microsoft.com/dotnet/configureawait-faq/ |
| C# | Stephen Cleary「Cancellation, Part 1: Overview」(2022) | https://blog.stephencleary.com/2022/02/cancellation-1-overview.html |
| C# | Microsoft「Recommended patterns for CancellationToken」(2021) | https://devblogs.microsoft.com/premier-developer/recommended-patterns-for-cancellationtoken/ |
| C# | Microsoft CA1068「CancellationToken parameters must come last」 | https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/quality-rules/ca1068 |
| C# | neuecc「Patterns for C# async/await cancel processing and timeouts」(2022) | https://neuecc.medium.com/patterns-practices-for-efficiently-handling-c-async-await-cancel-processing-and-timeouts-b419ce5f69a4 |
| Go | Sameer Ajmani「Go Concurrency Patterns: Context」(2014) | https://go.dev/blog/context |
| Go | context パッケージドキュメント | https://pkg.go.dev/context |
| Swift | Swift Evolution Proposal SE-0296「Async/Await」 | https://github.com/swiftlang/swift-evolution/blob/main/proposals/0296-async-await.md |
| Rust | Rust Async Book「Why Async?」 | https://rust-lang.github.io/async-book/01_getting_started/02_why_async.html |
| Zig | Zig 0.16.0 async再設計 | https://ziglang.org/download/ |
| 解説 | Whexy「Function Color Theory」(2021) | https://www.whexy.com/en/posts/func-color |
| 比較 | Dmitry Kakurin「Concurrency in Go, Pony, Erlang, and Rust」(2022) | https://dmitrykakurin.medium.com/concurrency-in-go-pony-erlang-elixir-and-rust-35a4eb4bb48f |
| 議論 | Lobsters: Avoid Async Rust | https://lobste.rs/s/jkct2m/avoid_async_rust |
