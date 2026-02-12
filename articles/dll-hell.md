---
title: "DLL Hell から .NET の自己完結型デプロイまで：30年の依存関係戦争"
emoji: "🏛️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["dotnet", "windows", "csharp", "dll", "architecture"]
published: false
---

miseに、dotnet(C#)を管理させようとして、dotnetの独自性に気が付かせられた。Microsoftには、コンシューマー向けの独自OSと、幅広い開発者コミュニティを抱え、かなり長い間（今も）バージョン問題に取り組んできた経験がある。その結果が、dotnet に集約されている。ここでは、その長い歴史を振り返り、現在の実装に至る道を再度辿る。

Windows の **DLL Hell** は1990年代に開発者を苦しめた共有ライブラリのバージョン競合問題であり、.NET Framework では、これの解決も含め設計されたが、皮肉にもフレームワーク自体が新たな「DLL Hell」を生み出した。.NET Core/5+ はこの歴史的教訓から、**アプリケーションごとのランタイム分離**という根本的に異なるアーキテクチャを採用し、共有の呪縛から解放される道を選んだ。この30年の進化は、ソフトウェアにおける「共有」と「分離」の本質的なトレードオフを体現している。

---

## Win32 時代の DLL Hell：共有ディレクトリという原罪

1990年代の Windows において、DLL（Dynamic Link Library）は `C:\WINDOWS\SYSTEM32` という単一のフラットなディレクトリに格納されていた。DLL はファイル名のみで識別され、**バージョン情報を強制する仕組みが一切存在しなかった**。アプリケーション A が `MFC42.DLL` バージョン1.0をインストールした後、アプリケーション B がバージョン2.0で上書きすると、アプリケーション A は即座に壊れる。DLL のエクスポートテーブルが再配置され、「テーブルの4番目の関数」を呼び出すコードが全く異なる関数を呼び出すことになるからだ。

この設計には歴史的な理由がある。1990年代半ばの PC は RAM が **8〜16MB**、HDD は **420MB〜850MB** が標準で、PC-9821 V10 の価格は **30万円** 程度だった。DLL の共有はメモリとディスク容量の節約に不可欠だった。しかし、インターネット配布の普及により、どのアプリケーションが何をインストールするか制御不能になり、「最後の書き込み者が勝つ」カオスが始まった。

問題となった DLL は数多い。**MFC42.DLL**（Microsoft Foundation Classes）は最も悪名高い例の一つで、アプリをインストールしただけで MFC42.DLL が置き換えられ、別のアプリケーションが全操作でクラッシュするようになった。**COMCTL32.DLL**（Common Controls Library）は歴史上 [**11以上のメジャーバリエーション**](https://www.geoffchappell.com/studies/windows/shell/comctl32/history/index.htm) が存在し、Windows だけでなく Internet Explorer にもバンドルされていたため、「アクティブなバージョンが OS 出荷時のバージョンと異なる」状況が常態化していた。個人的にも、デスクトップアプリのインストーラに入れた、**COMCTL32.DLL** が古いものに書き換えられてユーザー先で動作に問題が出て難儀するなど苦労が多かった。

**MSVCRT.DLL**（Visual C++ ランタイム）の問題はさらに深刻だった。異なる CRT バージョンで確保したメモリを別の CRT で解放するとアクセス違反が発生する。[PostgreSQL プロジェクト](https://www.postgresql.org/message-id/2c5f9472-d0cc-df61-78e3-bc48909ffb59@chrullrich.net)は、考えうる全ての MSVCRTnn.DLL バリアントをロードして各 `putenv()` のポインタを取得するという苦肉の策を実装した。[Apache HTTP Server](https://httpd.apache.org/docs/2.4/platform/win_compiling.html) は公式ビルドに Visual Studio 6.0 を何年も使い続けた。全ての依存関係が同じ CRT DLL を使う必要があったからだ。

### C/C++ の ABI 問題が地獄を深くした

C++ には**標準化された ABI が存在しない**。名前マングリング方式はコンパイラごとに異なり（MSVC は独自方式、GCC は Itanium C++ ABI）、Visual C++ 6 でコンパイルした DLL は Borland C++ から使用不能だった。唯一の回避策は `extern "C"` だが、これは関数オーバーロードを犠牲にする。構造体のアライメントやパディングも実装定義であり、同じデータ構造が異なるパディングで互換性のないメモリレイアウトを生成する。仮想関数の vtable レイアウトもコンパイラ間で異なり、仮想メソッドの追加は vtable を破壊する。

COM（Component Object Model）は `HKEY_CLASSES_ROOT\CLSID` にグローバル登録されるため、**システム全体で1つの CLSID に1つの DLL しか登録できない**。Don Box は著書 [*Essential COM*](https://www.amazon.com/Essential-COM-Don-Box/dp/0201634465)（1998年）で、COM のインターフェース不変性原則（一度公開されたインターフェースは変更不可）を文書化したが、「クラスのセマンティクスは変わりうる。あるアプリケーションのバグ修正が、別のアプリケーションの機能削除になりうる」と認めている。ActiveX は1996年に IE 3.0 で導入され、Web ページがユーザーの介入なしに COM コントロールを**自動ダウンロード・登録**できたため、事態はさらに悪化した。AOL 5.0 をロードすると VBScript DLL が古いバージョンに置き換わり、他のアプリケーションの VBScript 機能が壊れるということもあった。

まさに、地獄のような状態で、**DLL Hell** として名を轟かせた。

---

## .NET Framework の設計：メタデータと DLL Hell の終焉

2000年1月、Microsoft の Rick Anderson は MSDN に [**"The End of DLL Hell"**](https://web.archive.org/web/20001109130500/http://msdn.microsoft.com/library/techart/dlldanger1.htm) を発表し、DLL Hell を3つの類型に分類した。「Type I: DLL Stomping」（新しいバージョンによる上書き）、「Type II: 副作用 DLL Hell」（アプリとDLLの相補的バグが「機能」として動作し、DLL修正で露呈する）、そしてType:III 標準的な後方非互換性だ。2001年11月には Steven Pratschner が .NET によるDLL Hell解決の公式設計文書 [*Simplifying Deployment and Solving DLL Hell with the .NET Framework*](https://learn.microsoft.com/en-us/previous-versions/dotnet/articles/ms973843(v=msdn.10)) を MSDN Magazine に発表している。

.NET Framework（2002年2月リリース）の核心的な解決策は、**アセンブリ**という自己記述型コンポーネントモデルだった。全ての .NET アセンブリはマニフェストメタデータを持ち、**名前・バージョン（Major.Minor.Build.Revision）・カルチャ・公開鍵トークン**の4要素で一意に識別される。例えば `"MyLib, Version=1.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a"` のように。C/C++ の DLL にはこうした自己記述能力が一切なかった。

**GAC（Global Assembly Cache）** は `System32` のフラットディレクトリとは根本的に異なる設計だった。`<アセンブリ名>\<バージョン>_<カルチャ>_<公開鍵トークン>` という階層構造により、同一アセンブリの複数バージョンが物理的に共存する。.NET 4.0 では CLR 2.0 用と CLR 4.0 用の **2つの GAC が分離**された。「両方が同じ GAC を共有すると、.NET 2.0 アプリが .NET 4.0 のアセンブリをロードして壊れる」からだ。

**Strong Name 署名**は公開鍵/秘密鍵ペアによる暗号的一意性を提供した。異なる発行者が同名のアセンブリを作成しても、公開鍵トークンが異なるため完全に別物として扱われる。CLR は参照アセンブリの正確なバージョンをマニフェストに記録し、ロード時にバージョン検証を行う。C/C++ のように「最初に見つかった同名 DLL を無条件でロード」する野蛮さは消えた。

Jeffrey Richter は [*CLR via C#*](https://www.amazon.com/CLR-via-4th-Developer-Reference/dp/0735667454) で興味深い事実を明らかにしている。.NET 1.0 Beta 1 では、**自動ロールフォワード機構**が実装されていた。CLR ローダーは指定された Major/Minor に対して最新の Build/Revision を自動選択するはずだった。しかしこの機能は **1.0 正式リリース前に削除**され、二度と実装されなかった。`AssemblyFileVersion` 属性はこの機構削除後に追加されたもので、`AssemblyVersion` の変更が互換性破壊になってしまったため、ビルド番号を安全に記録する場所が別途必要になったのだ。

バインディングリダイレクトは `app.config` の `<bindingRedirect>` 要素で制御され、パブリッシャーポリシーとマシン全体のポリシーを含む階層的なバージョン解決アルゴリズムが実装された。これらすべてが、XCOPY デプロイメント（レジストリ不要）を理想とする設計思想のもとに統合されていた。

---

## .NET Framework 自体が生んだ新しい DLL Hell

.NET Framework が C/C++ の DLL Hell を解決したのは事実だが、フレームワーク**自体**が新たなバージョニング地獄を生み出した。問題の根源は、.NET Framework が **Windows のシステムコンポーネント** として Windows Update で更新される共有ランタイムだったことにある。

[Microsoft の公式ドキュメント](https://learn.microsoft.com/en-us/dotnet/framework/migration-guide/version-compatibility)によれば、.NET Framework 4.5 以降は「バージョン 4 を置き換えるインプレースアップデート」だ。つまり .NET 4.5 は 4.0 を、4.6 は 4.5.2 を、最終的に 4.8 まで一貫して上書きし続けた。**CLR のバージョン番号は `v4.0.30319` のまま変わらなかった**。この設計判断は、後述するコミュニティの激しい批判を招いた。[Rick Strahl](https://weblog.west-wind.com/posts/2012/Mar/13/NET-45-is-an-inplace-replacement-for-NET-40) は「4.5 アップデートは .NET 4.0 ランタイムを完全に置き換え、実際のバージョン番号は v4.0.30319 のまま残る」と記録している。

この設計がもたらした具体的な破壊事例は多い。2018年4月の Windows 10 アップデート（1803）は .NET Framework 4.7.2 をインプレースで導入し、以下のような8年間正常に動作していたコードを壊した：

```csharp
new System.Data.SqlClient.SqlConnection("Data Source=;") { ConnectionString = null };
// 4.7.2 で NullReferenceException が発生
```

原因は Azure SQL Server リトライロジック追加時の null チェック漏れだった。[Sentry のブログ](https://blog.sentry.io/2018/05/14/windows-10-update-might-have-broken-your-dotnet-app/)は「昨日、あるいは何年も前に作成したアプリが、OS アップデートのせいで突然クラッシュし始める可能性がある」と警告している。

[Scott Hanselman の2012年のブログ記事](https://www.hanselman.com/blog/net-versioning-and-multitargeting-net-45-is-an-inplace-upgrade-to-net-40) ".NET 4.5 is an in-place upgrade to .NET 4.0" は、コミュニティの激しい反発を記録している。開発者のコメントは痛烈だった：「**これはまた DLL Hell だ**。DLL に破壊的変更を加え、バージョン番号を同じにしている——Microsoft は何も学んでいないのか？」「.NET 1.0 で約束したことを実行してほしい。すべてをサイドバイサイドにしてくれ……理由なく DLL Hell パート3を作り出さないでくれ」。Visual Studio 2012 をインストールすると（.NET 4.5 が必要）開発マシンの .NET 4.0 ランタイムが置き換わり、プロジェクト設定で .NET 4.0 をターゲットしていても**実際には .NET 4.5 の DLL で実行される**。ある WPF 開発者が .NET 4.0 の ObservableCollection バグに気づかないまま開発し、.NET 4.5 のない Windows XP マシンにデプロイした時点で初めてクラッシュが発覚するという隠れたバグシナリオも報告されている。

NuGet パッケージの普及は「**fresh version of DLL Hell**（新たなDLL Hell）」を生み出した。Stack Overflow の [Nick Craver](https://nickcraver.com/blog/2020/02/11/binding-redirects/) は、アセンブリローダーを「**unstable plutonium with a hair trigger coated in flesh eating bacteria behind a gate made of unobtanium above a moat of napalm filled with those jellyfish that kill you**（髪の毛トリガー付きの不安定なプルトニウムを人食いバクテリアでコーティングし、unobtanium の門の向こう、殺人クラゲが泳ぐナパームの堀の上に置いたもの）」と形容した。バインディングリダイレクトは Stack Overflow を .NET Core に移行させた上位5つの理由の一つだという。`System.Net.Http` の例では、NuGet 版（アセンブリバージョン 4.1.1.3）と .NET Standard 2.0 が期待するバージョン（4.2.0.0）と GAC 内のバージョン（4.0.0.0）が三者三様に異なるという混沌が生じた。

.NET Framework 2.0/3.0/3.5 のバージョニング体系自体も混乱の元だった。これら3つは全て **CLR 2.0**（`v2.0.50727`）を共有しており、3.0 は WCF/WPF/WF を追加し、3.5 は LINQ を追加したが、ランタイムは同一だった。Hanselman は「3 と 3.5 が .NET 2.5 と .NET 2.8 と呼ばれていれば、もっと理にかなっていただろう」と述べている。

---

## .NET Core/5+ が選んだ根本的に異なる道

.NET Core は .NET Framework の失敗から明確な教訓を得て設計された。その核心原則は「**共有しない**」ことだ。

**Self-contained deployment（自己完結型デプロイ）** は、アプリケーション・全 NuGet 依存関係・.NET ランタイム全体を単一のパッケージにバンドルする。ターゲットマシンに .NET のプレインストールは不要だ。`dotnet publish -r win-x64 --self-contained true` で生成される出力には、CoreCLR、フレームワークライブラリ、ネイティブホストコンポーネントが全て含まれる。代償としてサイズは最小の ASP.NET Core アプリでも **60〜93MB以上**（Framework-dependent の3MB に対して約30倍）に膨らむが、完全な分離と決定論的動作が得られる。

**Framework-dependent deployment（フレームワーク依存型）** はデフォルトモードで、アプリコードとサードパーティ依存関係のみを含み、ランタイムのプレインストールを前提とする。重要な違いは、.NET Core/5+ では**複数のランタイムバージョンが真のサイドバイサイドで共存する**ことだ。ディレクトリ構造は明確にバージョン分離されている：

```text
{dotnet_root}/
├── shared/Microsoft.NETCore.App/
│   ├── 6.0.11/    ← .NET 6 アプリ用
│   └── 8.0.5/     ← .NET 8 アプリ用
├── sdk/
│   ├── 8.0.300/   ← SDK バージョン A
│   └── 9.0.100/   ← SDK バージョン B
```

.NET 8 をインストールしても .NET 6 のファイルには一切触れない。.NET Framework のインプレース置換とは正反対の設計だ。

**ロールフォワードポリシー**は6段階で制御可能だ。デフォルトの `Minor` は要求されたマイナーバージョンの最新パッチにロールフォワードし、`Disable` は完全一致のみ、`LatestMajor` は最新インストール済みバージョンを常に使用する。`global.json` はプロジェクトレベルで SDK バージョンをピン留めし、`runtimeconfig.json` はランタイムバージョンを制御する。

### 補足：開発者向けバージョンマネージャとの関係

ここまで述べてきた DLL Hell は主に**実行時**の問題だが、開発者にとっては**開発時**のバージョン管理も重要な関心事である。導入部で触れた mise で dotnet を管理しようとした経験から、この問題を掘り下げてみる。

nvm、pyenv、rbenv、そして mise/asdf などのバージョンマネージャは **PATH 操作とシム** という単純なモデルで動作する。「バージョンごとに1つのランタイムバイナリ」が前提だ。しかし .NET はこのモデルに適合しない。

第一に、.NET は **SDK・ランタイム・ASP.NET Core ランタイム・Desktop ランタイム・Host FXR** という複数コンポーネントが個別にバージョニングされる。SDK 8.0.300 はランタイム 8.0.5 を同梱するが、バージョン番号は一致しない。

第二に、.NET は `global.json` という**独自のバージョンピニング機構**を持つ。Node.js の `.nvmrc` や `.node-version` が単純なバージョン文字列を記載するだけなのに対し、`global.json` は `latestPatch`、`latestFeature`、`latestMinor` などの精密なロールフォワードセマンティクスをサポートする。これは単なるバージョン指定ではなく、.NET SDK に組み込まれた高度な機能だ。

Node.js の場合、`package.json` の `engines` フィールドや `.nvmrc` は「推奨バージョンを宣言するだけ」であり、nvm や mise がそれを読んで PATH を切り替える。ツールとランタイムの責務が分離している。一方 .NET では、`global.json` のロールフォワードロジックは `dotnet` コマンド自体に実装されており、外部ツールが介入する余地が少ない。

第三に、`dotnet` 実行可能ファイル（muxer）は**自身のパスからの相対位置**で SDK とランタイムを探索する。PATH を切り替えるだけでは不十分で、`DOTNET_ROOT` 環境変数を適切に設定し、ディレクトリツリー全体を管理する必要がある。

mise や asdf が目指す「ポリグロット開発体験」——複数言語のバージョンを統一的に管理する世界観——において、.NET は独自路線を歩んでいる。この統合を改善するには、.NET コミュニティと mise/asdf コミュニティの双方向の協力が必要だろう。現状では、mise の dotnet プラグインは存在するものの、`global.json` との二重管理という課題が残る。

---

## 共有ライブラリ問題の理論的本質

### なぜ「共有」が問題を複雑化するのか

共有ライブラリの存在理由は明確だ。メモリ節約（OS がコードページを仮想メモリで共有）、ディスク節約、セキュリティパッチの一元適用。しかし、**共有は暗黙の結合を生む**。2つのプログラムが同じライブラリバイナリを共有した瞬間、そのライブラリへのいかなる変更も両方のプログラムと同時に互換性を持たなければならない。消費者の数が増えるほど、この制約は超線形に増大する。

**ダイヤモンド依存関係問題**はこの本質を最も端的に示す。`libuser` が `liba`（`libbase v1` に依存）と `libb`（`libbase v2` に依存）の両方を必要とし、v1 と v2 が非互換なら、解決不能な制約が生じる。[Google の SWE Book](https://abseil.io/resources/swe-book/html/ch21.html) は「libuser が全てを組み合わせる一般的な方法は存在しない」と述べている。C/C++ ではシンボルがフラットな名前空間で解決されるため、この問題は特に深刻だ。互換バージョンセットの発見は**計算量的に困難**であり、現代のパッケージマネージャが洗練された制約ソルバーを内蔵する理由がここにある。

[**Hyrum の法則**](https://www.hyrumslaw.com/)（Google の Hyrum Wright が定式化）は共有ライブラリの進化を理論的に制約する：「十分な数のユーザーがいるAPIでは、契約で何を約束しようと、システムの全ての観察可能な振る舞いが誰かに依存される」。バグ修正すらバグに依存していたユーザーを壊す。エラーメッセージのテキストを正規表現でパースするユーザーがいれば、メッセージ変更は ABI 破壊となる。SONAME やシンボルバージョニングは明示的な ABI 変更からしか保護できず、暗黙の依存関係には無力だ。

### Linux の SONAME と Windows DLL の設計比較

Linux の共有ライブラリバージョニングは SONAME 機構で Windows よりはるかに堅牢だ。ライブラリ `libfoo.so.1.2.3` は ELF ヘッダに SONAME `libfoo.so.1` を埋め込む。ビルド時にリンカは SONAME を実行可能ファイルの `DT_NEEDED` エントリに記録し、実行時に動的リンカは `libfoo.so.1` シンボリックリンクを辿って実際のライブラリを見つける。SONAME のメジャー番号が異なれば別ファイルとして共存でき、`libfoo.so.1` と `libfoo.so.2` が同一マシンに問題なく存在する。

**glibc** は ABI 安定性のゴールドスタンダードだ。10年以上前にコンパイルされたプログラムが現代のシステムで動作する。これは **ELF シンボルバージョニング** で達成されている。同一関数の複数実装が `glob64@GLIBC_2.1`、`glob64@GLIBC_2.2`、`glob64@@GLIBC_2.27` のようにタグ付けされて共存し、動的リンカがビルド時に記録されたバージョンに基づいて正しい実装にルーティングする。

しかし Linux にも固有の「依存関係地獄」がある。低レベルライブラリの SONAME 変更時に依存チェーン全体の再ビルドが必要になる。Windows の DLL Hell がファイル上書きによる即時的破壊だったのに対し、Linux の問題はパッケージ依存関係グラフの整合性維持にある。Debian ポリシーでは、ABI 互換性を壊す変更のたびに SONAME とバイナリパッケージ名の両方を変更することが要求されている。

### 静的リンクという回帰と Go/Rust の選択

Go は最初から**静的リンクをデフォルト**として設計された。DNS 解決やユーザー検索まで純粋な Go で再実装し、C ライブラリへの依存を排除した。「静的バイナリは Go の初期の最大のセールスポイントの一つだった」。Rust も同様に、Rust クレート間の依存関係を全て静的リンクし、**安定した ABI を意図的に持たない**。`extern "Rust"` ABI はコンパイラバージョン間で変更される可能性があり、コンパイラの最適化の自由度を維持する。ジェネリクスの単相化（monomorphization）は本質的に共有ライブラリに収められない——各使用箇所で再コンパイルが必要だ。

Docker コンテナは共有問題の最新の解決策だが、本質的には**共有を放棄することで問題を回避**している。各コンテナが完全なユーザースペースをバンドルし、ホストカーネルのみを共有する。依存関係の衝突は消えるが、ライブラリ脆弱性のパッチにはコンテナの再ビルドが必要で、静的リンクと同じトレードオフに帰着する。

---

## 設計者たちの証言が語る教訓

Jeffrey Richter は [*CLR via C#*](https://www.amazon.com/CLR-via-4th-Developer-Reference/dp/0735667454) で、.NET のアセンブリバージョニングが当初の設計意図からどう逸脱したかを詳細に記録した。.NET 1.0 Beta 1 に存在した自動ロールフォワード機構の削除は、Strong Name の硬直性を決定づけた。`AssemblyVersion` の変更が破壊的変更となり、バインディングリダイレクトなしには新バージョンへの移行が不可能になった。

[Chris Brumme](http://cbrumme.dev/)（CLR チームのリードアーキテクト、2017年没）は、CLR 内部についてどこにも存在しない技術的詳細を記したブログで「全ての .NET ブロガーの父」と呼ばれた。AppDomain によるアプリケーション分離、アセンブリローディングの内部メカニズム、プロセスシャットダウン時の非管理コードとの相互作用を「小冊子のような」長さのエッセイで解説した。

Stack Overflow の [Nick Craver のバインディングリダイレクト地獄の証言](https://nickcraver.com/blog/2020/02/11/binding-redirects/)と、[Scott Hanselman の .NET 4.5 インプレースアップグレードに対するコミュニティの怒りの記録](https://www.hanselman.com/blog/net-versioning-and-multitargeting-net-45-is-an-inplace-upgrade-to-net-40)は、.NET Framework の共有モデルが実際の開発現場でどれほどの苦痛を生んだかを生々しく伝えている。Hanselman 自身は「.NET 3.5SP1 の混乱以来、彼ら（Microsoft）は正しくしようと努力してきた」と弁護しつつも、2.0/3.0/3.5 のバージョニングを「debacle（大失態）」と呼んだ。

---

## 結論：共有から分離へ、そして選択の時代へ

DLL Hell から .NET Core の自己完結型デプロイメントに至る30年の歴史は、一つの明確な軌道を描いている。**最大限の共有**（System32 のフラットディレクトリ）→ **管理された共有**（GAC と Strong Name）→ **共有システムコンポーネントの限界**（.NET Framework 4.x のインプレース更新）→ **分離のデフォルト化**（.NET Core のサイドバイサイドと self-contained デプロイ）。

この進化における最も重要な洞察は、**共有の利益は消費者の数に対して対数的に増加するが、共有のコスト（互換性維持、Hyrum の法則による暗黙的依存関係の増大、ダイヤモンド依存関係）は超線形に増大する**という非対称性だ。1990年代の RAM・ディスク制約下では共有の利益がコストを上回ったが、リソースが豊富になった現代では、分離のコスト（ディスク・メモリの増加）が相対的に低下し、分離の利益（信頼性・再現性・独立性）が支配的になった。

.NET Core/5+ が選んだ self-contained デプロイメントは、30年にわたる共有ライブラリ問題への回答である。エンドユーザーのマシンでランタイム競合が起きない世界——それが DLL Hell からの真の解放だ。

一方、開発者向けのバージョン管理については、.NET は `global.json` とロールフォワードポリシーという独自の体系を持つ。これは mise/asdf のような汎用バージョンマネージャとは異なるアプローチだが、.NET 固有の複雑なバージョニング要件（SDK とランタイムの分離、精密なロールフォワード）に対応するための合理的な選択でもある。
