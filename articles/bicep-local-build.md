---
title: "Bicep ãlocal buildãã"
emoji: "ðª"
type: "tech" # tech: æè¡è¨äº / idea: ã¢ã¤ãã¢
topics: ["azure", "arm", "bicep"]
published: true
---

æ®éã«Bicep ã®ææ°ãã«ããä½¿ãå ´åã[bicepã®ã¬ãã¸ããª](https://github.com/Azure/bicep/) ã®ãGitHub Actionã®Artifactsãããã¦ã³ã­ã¼ãããããã®èª¬æã¯ããã®ãããã«ããã[Installing the "Nightly" build of Bicep CLI and VS Code extension](https://github.com/Azure/bicep/blob/v0.4.1272/docs/installing-nightly.md)

Nightly buildã§ããæ°ããAPIã®è¿½å ãåæ ãããã¾ã§çµæ§æéãããããææ°ã®APIã«è¿½å¾ãããå ´åã¯ãèªåã§ãã«ãããå¿è¦ããããããã»ã©é¢åã§ã¯ãªãããå¹¾ã¤ãæé ãããã®ã§ãã¡ã¢ã¨ãã¦ããã«æ®ãã¦ããã

é©æç°å¢ãç¨æãããubuntuããå§ãï¼WSL2ã§ãå¯ï¼ã§ãnodeã¨.net 6ãå¥ãã¦ããã

å¤§ç­ã®æµãã¯ãä¸è¨ã®ããã«ãªãã

1. [azure rest api specs](https://github.com/Azure/azure-rest-api-specs) ãåå¾
2. [bicep-types-az](https://github.com/Azure/bicep-types-az)ããã«ã
3. [bicep](https://github.com/Azure/bicep)ããã«ã

## 1. api specs ç·¨

ã¾ãã¯ã[Azure/azure-rest-api-specs](https://github.com/Azure/azure-rest-api-specs) ãé©å½ãªãã£ã¬ã¯ããªã«ã¯ã­ã¼ã³ãã¦æ¬²ãããã©ã³ãã¸åãæ¿ããç°å¢å¤æ°ã«å ´æãã»ããããã

```sh
git clone git@github.com:Azure/azure-rest-api-specs.git
cd azure-rest-api-specs
export AZURE_REST_API_SPECS=`pwd`
```

## 2. Azure/bicep-types-az ç·¨

æ¬¡ã«ã[Azure/bicep-types-az](https://github.com/Azure/bicep-types-az) ãé©å½ãªãã£ã¬ã¯ããªã«ã¯ã­ã¼ã³ãã¦ãã«ããããã­ã¼ã«ã«ãã«ãã®æé ã¯ã[ãã®ããã](https://github.com/Azure/bicep-types-az#running-generation-locally)ã«è¨è¼ããããæé ã¯æ¦ã­ä¸è¨ã®ãããªæãã

### git clone

```sh
git clone git@github.com:Azure/bicep-types-az.git
cd bicep-types-az
```

### åæè¨­å®

ååã®ãã«ãæã«ã¯ãã¼ã«ãå¥ããã

1. autorest extension code ããã«ããã

```sh
cd src/autorest.bicep
npm ci
npm run build
```

2. generator directory ã«ç§»åãã¦ dependenciesããã¤ã³ã¹ãã¼ã«ãã

```sh
cd ../../src/generator
npm ci
```

### ã³ã¼ãçæãã

specs repo å¨ä½ã§ãgeneration ãå®è¡ãæåã§ã¯ã400ç§ã»ã©æãã£ããçµæ§æéããããã

```sh
npm run generate -- --specs-dir $AZURE_REST_API_SPECS
```

## 3. bicep ç·¨

æå¾ã«ã[Azure/bicep](https://github.com/Azure/bicep) ãé©å½ãªãã£ã¬ã¯ããªã«ã¯ã­ã¼ã³ããã

```sh
git clone git@github.com:Azure/bicep.git
cd bicep
```

### ãã­ã¸ã§ã¯ãã®åç§ã«å¤æ´

`src/Bicep.Core/Bicep.Core.csproj` ãä¿®æ­£ãã¦ã[Azure/bicep-types-az](https://github.com/Azure/bicep-types-az) ãæãããã«ããã

```xml
<!--
  <PackageReference Include="Azure.Bicep.Types" Version="0.1.400" />
  <PackageReference Include="Azure.Bicep.Types.Az" Version="0.1.400" />
-->
  <ProjectReference Include="../../../bicep-types-az/src/Bicep.Types/Bicep.Types.csproj" />
  <ProjectReference Include="../../../bicep-types-az/src/Bicep.Types.Az/Bicep.Types.Az.csproj" />
```

### ãã«ããã

bicep cliãæ¬²ããå ´åã¯ã`./src/Bicep.Cli/Bicep.Cli.csproj` ããã«ããããVS Codeæ¡å¼µãæ¬²ããå ´åã¯ã`./src/Bicep.LangServer/Bicep.LangServer.csproj` ããã«ããã¦çµæãã`./src/vscode-bicep/bicepLanguageServer/` ãã¦ããã`src/vscode-bicep` ã§ã`npm run package` ããã

æ®æ®µã¯ããã«ãç¨ã«ä½ã£ãä¸è¨ã®ãããªMakefileãä½¿ã£ã¦ããããã«ããããã¡ã¤ã«ã¯ãPATHãåãããã£ã¬ã¯ããªã«é©æã³ãã¼ãã¦ä½¿ããã¨ã«ãªãã

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

ãããªæãã§ãã«ãã§ãããaz cli ã§ä½¿ãbicepã¯å¥ãã£ã¬ã¯ããªã«å¥ãã®ã§ãé©å½ã«ãªã³ã¯ãè²¼ããªã©ã®å·¥å¤«ãå¿è¦ã«ãªãã
