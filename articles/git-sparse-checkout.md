---
title: "git sparse-checkout"
emoji: "🎈"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["git", "紹介"]
published: true
---

## Sparse checkout（疎なチェックアウト）

いつのまにか、git で一部のディレクトリだけチェックアウトすることができるようになってたので試してみた。[^git]

[azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates)のようなファイルが大量になるレポジトリだと一部だけ欲しくなる。また、レポジトリの中に利用しているOSのファイルシステムでは使えないような文字が使われたファイルがある場合もあり、一部だけチェックアウトできるのは嬉しい。[^co]

ここでは、新しいレポジトリをクローンするところから始める。まず、最初にcloneするときに、`--no-checkout` オプションを付ける。こうすると、すべてのGit objectがクローンされるが、ファイルは作成されない。

```sh
$ git clone --no-checkout https://github.com/Azure/azure-quickstart-templates
Cloning into 'azure-quickstart-templates'...
remote: Enumerating objects: 199099, done.
remote: Counting objects: 100% (68/68), done.
remote: Compressing objects: 100% (45/45), done.
remote: Total 199099 (delta 27), reused 56 (delta 19), pack-reused 199031
Receiving objects: 100% (199099/199099), 700.24 MiB | 13.86 MiB/s, done.
Resolving deltas: 100% (135339/135339), done.
```

結構大きなレポジトリなので、それなりに時間がかかりる。終わったら、ディレクトリに入って中が空なのを確認する。

```sh
$ cd azure-quickstart-templates
$ ls
```

`sparse-checkout init --cone` して、欲しいディレクトリを追加する。`add` は、2.26からだそうだ[^git2]

```sh
$ git sparse-checkout init --cone
$ git sparse-checkout add quickstarts/microsoft.app/
```

これで、指定ディレクトリ(quickstarts/microsoft.app/)がチェックアウトされる。

```sh
$ git checkout master
Already on 'master'
Your branch is up to date with 'origin/master'.
$ ls

    Directory: C:\ws\tmp\azure-quickstart-templates

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d----          06/29/2022    00:22                quickstarts
-a---          06/29/2022    00:22             86 .gitattributes
-a---          06/29/2022    00:22            979 .gitignore
-a---          06/29/2022    00:22           7666 az-group-deploy.sh
-a---          06/29/2022    00:22          13865 Deploy-AzTemplate.ps1
-a---          06/29/2022    00:22          14811 Deploy-AzTemplate.psm1
-a---          06/29/2022    00:22          10336 Deploy-AzureResourceGroup.ps1
-a---          06/29/2022    00:22           1083 LICENSE
-a---          06/29/2022    00:22            981 README.md
-a---          06/29/2022    00:22           2757 SECURITY.md
-a---          06/29/2022    00:22           2563 SideLoad-AzCreateUIDefinition.ps1
-a---          06/29/2022    00:22           3560 sideload-createuidef.sh
-a---          06/29/2022    00:22           2634 SideLoad-CreateUIDefinition.ps1

$ tree /F .
Folder PATH listing for volume system
Volume serial number is 0000000D 8236:FAD0
C:\WS\TMP\AZURE-QUICKSTART-TEMPLATES2
│   .gitattributes
│   .gitignore
│   az-group-deploy.sh
│   Deploy-AzTemplate.ps1
│   Deploy-AzTemplate.psm1
│   Deploy-AzureResourceGroup.ps1
│   LICENSE
│   README.md
│   SECURITY.md
│   SideLoad-AzCreateUIDefinition.ps1
│   sideload-createuidef.sh
│   SideLoad-CreateUIDefinition.ps1
│
└───quickstarts
    │   README.md
    │
    └───microsoft.app
        ├───container-app-azurevote
        │       azuredeploy.json
        │       azuredeploy.parameters.json
        │       main.bicep
        │       metadata.json
        │       README.md
        │
        └───container-app-create
                azuredeploy.json
                azuredeploy.parameters.json
                main.bicep
                metadata.json
                README.md
```

さらに追加で、`demos/private-aks-cluster` を持ってくる。

```sh
$ git sparse-checkout add demos/private-aks-cluster
$ tree .
Folder PATH listing for volume system
Volume serial number is 0000002D 8236:FAD0
C:\WS\TMP\AZURE-QUICKSTART-TEMPLATES2
├───demos
│   └───private-aks-cluster
│       └───images
└───quickstarts
    └───microsoft.app
        ├───container-app-azurevote
        └───container-app-create
```

こんな感じで、指定のディレクトリだけをチェックアウトすることができる。ここまでが、**sparse-checkout** の話。これは、git objectをから指定部分を取り出す、疎なチェックアウトをする機能。
なかなか便利だ。

## Partial clone(遅延クローン)

これと、`Partial Clone`[^pc] を組み合わせると、オンデマンドで必要なオブジェクトだけをダウンロードすることができる。`Partial Clone`には、`clone` コマンドに `--filter=blob:none` を指定する。10秒足らずで終わり段違いに早い。

```sh
$ git clone --filter=blob:none --no-checkout https://github.com/Azure/azure-quickstart-templates
Cloning into '.\azure-quickstart-templates3'...
remote: Enumerating objects: 127901, done.
remote: Counting objects: 100% (52/52), done.
remote: Compressing objects: 100% (31/31), done.
remote: Total 127901 (delta 23), reused 45 (delta 17), pack-reused 127849
Receiving objects: 100% (127901/127901), 38.12 MiB | 13.20 MiB/s, done.
Resolving deltas: 100% (77554/77554), done.

$ cd azure-quickstart-templates
$ git sparse-checkout init --cone
$ git sparse-checkout add quickstarts/microsoft.app/
$ git sparse-checkout add demos/private-aks-cluster
$ git checkout master
remote: Enumerating objects: 38, done.
remote: Counting objects: 100% (18/18), done.
remote: Compressing objects: 100% (17/17), done.
Receiving objects:  71% (27/38)sed 1 (delta 1), pack-reused 20
Receiving objects: 100% (38/38), 969.52 KiB | 6.14 MiB/s, done.
Resolving deltas: 100% (9/9), done.
Already on 'master'
Your branch is up to date with 'origin/master'.
```

## NTFSでは作成不可なファイルを除外

NTFSでは作成できないようなファイルが含まれている場合、`git clone` で下記のようなエラーになる。

```powershell
$ git clone  https://github.com/takekazuomi/test-protectNTFS.git
Cloning into 'test-protectNTFS'...
remote: Enumerating objects: 5, done.
remote: Counting objects: 100% (5/5), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 5 (delta 0), reused 5 (delta 0), pack-reused 0
Receiving objects: 100% (5/5), done.
error: invalid path 'work/test:test.txt'
fatal: unable to checkout working tree
warning: Clone succeeded, but checkout failed.
You can inspect what was checked out with 'git status'
and retry with 'git restore --source=HEAD :/'
```

メッセージには、`warning: Clone succeeded, but checkout failed.` と出ており、ファイル名のチェックはクローン後のチェックアウトで行われてるようなことがわかる。この状態で、`git status`すると、作業ディレクトリではステージにファイルがあがっており中途半端な状態になっている。ここからリカバリするより、 `protectNTFS false` でクローンし、該当ファイルやディレクトリを除外した方がいい。

例えば、チェックアウトをしないで、クローンだけして、レポジトリ内で`protectNTFS`を無効に指定。

```powershell
$ git clone  --no-checkout https://github.com/takekazuomi/test-protectNTFS.git
$ cd test-protectNTFS
$ git config core.protectNTFS false
```

他にも、クローン時に、オプションで`protectNTFS`を無効に指定するなど、幾つか方法はある。

```powershell
$ git clone --config core.protectNTFS=false https://github.com/takekazuomi/test-protectNTFS.git
```

最初、`git config --global core.protectNTFS false` のようにしてNTFS保護をグローバルに無効にしてしまえば良いかと思ったが、セミコロンの付いたファイル名を受け付けると脆弱性の問題がある。[^av1] 信頼できるレポジトリでだけで設定するようにして、上記のように、グローバル設定は避けてレポジトリ毎に指定した方が良いだろう。

## 最後に

特定のディレクトリだけ無視したい場合、`git sparse-checkout set --no-cone` を使う。`quickstarts` だけを除外したいなら、下記のようにする。[^fp]

```sh
$ git sparse-checkout set --no-cone '/*' '!quickstarts'
```

[^git]: Bring your monorepo down to size with sparse-checkout <https://github.blog/2020-01-17-bring-your-monorepo-down-to-size-with-sparse-checkout/> 2020年の初頭から使えたらしい、知らなかった、、、
[^co]: 部分チェックアウトは、10数年前に、svnからgitに移行したときに探した機能の１つ。無くて残念な気分になったのを思い出す。
[^git2]: Highlights from Git 2.26 <https://github.blog/2020-03-22-highlights-from-git-2-26/> add 既存ルールに追加で、set はルールの設定（上書き）、add の方が普段使いに便利そうだが既存ルールを上書きしたい場合は set を使う。
[^pc]: Partial Clone <https://git-scm.com/docs/partial-clone>
[^git3]: 既存のリポジトリでスパースチェックアウトを使用する <https://github.blog/2020-01-17-bring-your-monorepo-down-to-size-with-sparse-checkout/#using-sparse-checkout-with-an-existing-repository>
[^sc]: Cone mode: restricted patterns improve performance <https://github.blog/2020-01-17-bring-your-monorepo-down-to-size-with-sparse-checkout/#cone-mode-restricted-patterns-improve-performance> Cone mode というらしい。
[^fp]: FULL PATTERN SET <https://git-scm.com/docs/git-sparse-checkout#_internalsfull_pattern_set>
[^av1]: コロンを含むファイル名を悪用されると、remote code execution vulnerability がある。信頼できないレポジトリをクローンする可能性がある場合は、デフォルトでは、core.protectNTFS をtrueにしておいた方がいい。 <https://github.com/git/git/security/advisories/GHSA-589j-mmg9-733v> <https://github.com/advisories/GHSA-74fq-3g57-65f7>
