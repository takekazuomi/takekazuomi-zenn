---
title: "Azure Container Apps のMSIを試す"
emoji: "💪"
type: "tech" # tech: 技術記事
topics: ["azure", "conatiner", "containerapps", "入門", "bicep", "msi"]
published: false
---

# 概要

今朝起きたら、ACAの更新が出てると教えもらい。どうやら、MSI（待望の）がサポートされるようになった[^MSI]らしいと聞き、ちょっと試してみた。

コードは[github:aca-msi01](https://github.com/takekazuomi/aca-msi01)に置いた。

MSI自体は、Azureの他のリソースと違いは無く同じような感じでデプロイできるので、あまり言うことはなく。少し配慮する点があるので、それだけをメモとして残しておく。

## デプロイとRole Assignment

MSI(System Managed Identity)は、`'Microsoft.App/containerApps`（以下アプリ） と、アクセス対処のリソースを繋ぐ形になる。アプリは、1つもしくは復数のコンテナで構成され[^pod]、構成の変更や増減は割と頻繁に行なわれることが想定される。どのアプリがどのリソースにアクセスすることを許可するかは、MSIで決めるという位置付けにする。なので、今回は、アプリをデプロイするモジュール[container.bicep](https://github.com/takekazuomi/aca-msi01/blob/v1.0.0/deploy-app/container.bicep)と、割当て(Role Assignments)を行うモジュール[roleAssignment.bicep](https://github.com/takekazuomi/aca-msi01/blob/v1.0.0/deploy-app/roleAssignment.bicep)を分け、デプロイはこの２つをまとめて[main.bicep](https://github.com/takekazuomi/aca-msi01/blob/v1.0.0/deploy-app/main.bicep)で行うようにした。

この書き方だと、異なったリソースへのアクセス権をもったアプリを同じbicepでデプロイ出来ないので、もう少し工夫する必要があるように思うが。とりあえず、こうしておけば、[az cli](https://github.com/takekazuomi/aca-msi01/blob/v1.0.0/Makefile#L37) 一発でデプロイできる。

```Makefile
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


[^MSI]: Public preview: Managed identities support in Azure Container Apps https://azure.microsoft.com/ja-jp/updates/public-preview-managed-identities-support-in-azure-container-apps/
[^pod]: k8sでいうPODのような位置付けになる。新しいAPIやサービスを作ると増えることを想定している。場合によっては3桁になる場合もあるだろう。
