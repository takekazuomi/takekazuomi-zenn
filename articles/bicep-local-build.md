---
title: "Bicep をlocal buildする"
emoji: "💪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["azure", "arm", "bicep"]
published: true
---

普通にBicep の最新ビルドを使う場合、[bicepのレポジトリ](https://github.com/Azure/bicep/) の、GitHub ActionのArtifactsからダウンロードする。この説明は、このあたりにある。[Installing the "Nightly" build of Bicep CLI and VS Code extension](https://github.com/Azure/bicep/blob/v0.4.1272/docs/installing-nightly.md)

Nightly buildでも、新しいAPIの追加が反映されるまで結構時間がかかる。最新のAPIに追従したい場合は、自分でビルドする必要がある。それほど面倒ではないが、幾つか手順があるので、メモとしてここに残しておく。

適時環境を用意する。ubuntuがお勧め（WSL2でも可）で、nodeと.net 6を入れておく。

大筋の流れは、下記のようになる。

1. [azure rest api specs](https://github.com/Azure/azure-rest-api-specs) を取得
2. [bicep-types-az](https://github.com/Azure/bicep-types-az)をビルド
3. [bicep](https://github.com/Azure/bicep)をビルド

## 1. api specs 編

まずは、[Azure/azure-rest-api-specs](https://github.com/Azure/azure-rest-api-specs) を適当なディレクトリにクローンして欲しいブランチへ切り替え、環境変数に場所をセットする。

```sh
git clone git@github.com:Azure/azure-rest-api-specs.git
cd azure-rest-api-specs
export AZURE_REST_API_SPECS=`pwd`
```

## 2. Azure/bicep-types-az 編

次に、[Azure/bicep-types-az](https://github.com/Azure/bicep-types-az) を適当なディレクトリにクローンしてビルドする。ローカルビルドの手順は、[このあたり](https://github.com/Azure/bicep-types-az#running-generation-locally)に記載がある。手順は概ね下記のような感じ。

### git clone

```sh
git clone git@github.com:Azure/bicep-types-az.git
cd bicep-types-az
```

### 初期設定

初回のビルド時にはツールを入れる。

1. autorest extension code をビルドする

```sh
cd src/autorest.bicep
npm ci
npm run build
```

2. generator directory に移動して dependencies　をインストールする

```sh
cd ../../src/generator
npm ci
```

### コード生成する

specs repo 全体で、generation を実行。手元では、400秒ほど掛かった、結構時間がかかる。

```sh
npm run generate -- --specs-dir $AZURE_REST_API_SPECS
```

## 3. bicep 編

最後に、[Azure/bicep](https://github.com/Azure/bicep) を適当なディレクトリにクローンする。

```sh
git clone git@github.com:Azure/bicep.git
cd bicep
```

### プロジェクトの参照に変更

`src/Bicep.Core/Bicep.Core.csproj` を修正して、[Azure/bicep-types-az](https://github.com/Azure/bicep-types-az) を指すようにする。

```xml
<!--
  <PackageReference Include="Azure.Bicep.Types" Version="0.1.400" />
  <PackageReference Include="Azure.Bicep.Types.Az" Version="0.1.400" />
-->
  <ProjectReference Include="../../../bicep-types-az/src/Bicep.Types/Bicep.Types.csproj" />
  <ProjectReference Include="../../../bicep-types-az/src/Bicep.Types.Az/Bicep.Types.Az.csproj" />
```

### ビルドする

bicep cliが欲しい場合は、`./src/Bicep.Cli/Bicep.Cli.csproj` をビルドする。VS Code拡張が欲しい場合は、`./src/Bicep.LangServer/Bicep.LangServer.csproj` をビルドして結果を、`./src/vscode-bicep/bicepLanguageServer/` してから、`src/vscode-bicep` で、`npm run package` する。

普段は、ビルド用に作った下記のようなMakefileを使っている。ビルドしたファイルは、PATHが切れたディレクトリに適時コピーして使うことになる。

```sh
$ cat Makefile
build: build-vscode-extension
#        dotnet publish --configuration ubuntu-latest --self-contained true -p:PublishTrimmed=true -p:PublishSingleFile=true -r linux-x64 ./src/Bicep.Cli/Bicep.Cli.csproj
        dotnet publish --configuration ubuntu-latest --self-contained true -p:PublishTrimmed=true -p:PublishSingleFile=true -p:TrimmerDefaultAction=copyused -p:SuppressTrimAnalysisWarnings=true -r linux-x64 ./src/Bicep.Cli/Bicep.Cli.csproj


build-language-server:
        dotnet publish --configuration release ./src/Bicep.LangServer/Bicep.LangServer.csproj

install: build
        cp -f ./src/Bicep.Cli/bin/ubuntu-latest/net6.0/linux-x64/publish/* ~/.local/bin
        cp src/vscode-bicep/vscode-bicep.vsix ~/.local/tmp

baseline:
        dotnet test --filter "TestCategory=Baseline" -- 'TestRunParameters.Parameter(name="SetBaseLine", value="true")'

# Running the Bicep VSCode extension
# https://github.com/Azure/bicep/blob/main/CONTRIBUTING.md#running-the-bicep-vscode-extension

build-vscode-extension: build-language-server
        mkdir -p ./src/vscode-bicep/bicepLanguageServer/
        \cp -f -R ./src/Bicep.LangServer/bin/release/net6.0/publish/* ./src/vscode-bicep/bicepLanguageServer/
        cd src/vscode-bicep; npm i; npm run package
```

こんな感じでビルドできる。az cli で使うbicepは別ディレクトリに入るので、適当にリンクを貼るなどの工夫が必要になる。
