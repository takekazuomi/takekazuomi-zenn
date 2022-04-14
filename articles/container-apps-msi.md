---
title: "Azure Container Apps のMSIを試す"
emoji: "🚀"
type: "tech" # tech: 技術記事
topics: ["azure", "conatiner", "containerapps", "入門", "bicep", "msi", "ACA"]
published: true
---

# 概要

今朝起きたら、ACA[^aca]の更新が出てると教えもらい。どうやら、MSI（待望の）がサポートされるようになった[^MSI]らしいと聞き、ちょっと試してみた。

コードは[github:aca-msi01](https://github.com/takekazuomi/aca-msi01)に置いた。

MSI自体は、Azureの他のリソースと違いは無く同じような感じでデプロイできるので、あまり言うことはなく。少し配慮する点があるので、それだけをメモとして残しておく。

## デプロイとRole Assignment

MSI(System Managed Identity)は、`'Microsoft.App/containerApps`（以下アプリ） と、アクセス対処のリソースを繋ぐ形になる。アプリは、1つもしくは復数のコンテナで構成され[^pod]、構成の変更や増減は割と頻繁に行なわれることが想定される。どのアプリがどのリソースにアクセスすることを許可するかは、MSIで決めるという位置付けにする。なので、今回は、アプリをデプロイするモジュール[container.bicep](https://github.com/takekazuomi/aca-msi01/blob/v1.0.1/deploy-app/container.bicep)と、割当て(Role Assignments)を行うモジュール[roleAssignment.bicep](https://github.com/takekazuomi/aca-msi01/blob/v1.0.1/deploy-app/roleAssignment.bicep)を分け、デプロイはこの２つをまとめて[main.bicep](https://github.com/takekazuomi/aca-msi01/blob/v1.0.1/deploy-app/main.bicep)で行うようにした。

```bicep :main.bicep
module containerApps 'container.bicep' = {
  name: 'containerApps'
  params: {
    location: location
    containerAppName: containerAppName
    containerImage: containerImage
....
    transport: transport
    allowInsecure: allowInsecure
    env: env
    acrName: acrName
  }
}

module roleAssignment 'roleAssignment.bicep' = {
  name: 'roleAssignment'
  params: {
    roleDefinitionResourceId: role.id
    containerAppPrincipalId: containerApps.outputs.principalId
    containerAppResourceId: containerApps.outputs.id
    storageAccountName: storageAccountName
  }
}
```

この書き方だと、異なったリソースへのアクセス権をもったアプリを同じbicepでデプロイ出来ないので、もう少し工夫する必要があるように思うが。とりあえず、こうしておけば、[az cli](https://github.com/takekazuomi/aca-msi01/blob/v1.0.1/Makefile#L37) 一発でデプロイできる。

こんな感じ

```Makefile :Makefile
deploy-apps:		## deploy msi check app
	envsubst < web/env.json.template > web/env.json
	az deployment group create -g $(RESOURCE_GROUP) -f ./deploy-app/main.bicep \
	-p \
	containerAppName=msicheck \
	environmentName=$(ENVIRONMENT_NAME) \
	containerImage=$(ACR_NAME).azurecr.io/msicheck:latest \
	containerPort=5000 \
	acrName=$(ACR_NAME) \
	storageAccountName=$(STORAGE_ACCOUNT_NAME) \
	roleDefinitionName=$(STORAGE_ACCOUNT_CONTRIBUTOR_ROLE) \
	env=@web/env.json
```

## 実行コード側

こちらは普通のMSIのコード。azure go sdk の`azure-sdk-for-go/sdk/azidentity`(https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azidentity@v0.14.0) を[使っている](https://github.com/takekazuomi/aca-msi01/blob/main/web/main.go#L69)。[DefaultAzureCredential](https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azidentity@v0.14.0#readme-defaultazurecredential)を使うとデフォルト設定で、フォールバックしながら、認証元を探してく、その中にMSIが入っている。

![DefaultAzureCredential](https://github.com/Azure/azure-sdk-for-go/raw/sdk/azidentity/v0.14.0/sdk/azidentity/img/DAC_flow.PNG)

なかなか便利（だと思う）なのだが、バージョン安定性が低い。今回は、[azcore 0.23.0](https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azcore@v0.23.0)に、[azblob](https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/storage/azblob@v0.3.0) が付いてこれてないらしく。（[このあたり](https://github.com/Azure/azure-sdk-for-go/issues/17472#issuecomment-1092926620)に事情がかいてある）
とりあえず前のバージョンを使うことにした。[^azb]

## 最後に

Azure Container Apps なかなか良さげでお勧めです。もちろん、bicepも。

[^aca]: Azure Container Apps を略して**ACA**と呼ぶそうです。
[^MSI]: https://kogelog.com/2022/04/14/20220414-01/ Public preview: Managed identities support in Azure Container Apps https://azure.microsoft.com/ja-jp/updates/public-preview-managed-identities-support-in-azure-container-apps/
[^pod]: アプリは、k8sでいうPODのような位置付けになり、新しいAPIやサービスを作ると増減することを想定している。場合によっては3桁になる場合もあるだろう。
[^azb]: これ、[Migrate azblob to latest version of azcore #17528](https://github.com/Azure/azure-sdk-for-go/pull/17528)が来たら直るんじゃないかと思っている。
