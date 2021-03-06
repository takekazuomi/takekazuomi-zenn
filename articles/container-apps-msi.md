---
title: "Azure Container Apps ã®MSIãè©¦ã"
emoji: "ð"
type: "tech" # tech: æè¡è¨äº
topics: ["azure", "conatiner", "containerapps", "å¥é", "bicep", "msi", "ACA"]
published: true
---

# æ¦è¦

ä»æèµ·ããããACA[^aca]ã®æ´æ°ãåºã¦ãã¨æãããããã©ããããMSIï¼å¾æã®ï¼ããµãã¼ããããããã«ãªã£ã[^MSI]ãããã¨èããã¡ãã£ã¨è©¦ãã¦ã¿ãã

ã³ã¼ãã¯[github:aca-msi01](https://github.com/takekazuomi/aca-msi01)ã«ç½®ããã

MSIèªä½ã¯ãAzureã®ä»ã®ãªã½ã¼ã¹ã¨éãã¯ç¡ãåããããªæãã§ããã­ã¤ã§ããã®ã§ããã¾ãè¨ããã¨ã¯ãªããå°ãéæ®ããç¹ãããã®ã§ãããã ããã¡ã¢ã¨ãã¦æ®ãã¦ããã

## ããã­ã¤ã¨Role Assignment

MSI(System Managed Identity)ã¯ã`'Microsoft.App/containerApps`ï¼ä»¥ä¸ã¢ããªï¼ ã¨ãã¢ã¯ã»ã¹å¯¾å¦ã®ãªã½ã¼ã¹ãç¹ãå½¢ã«ãªããã¢ããªã¯ã1ã¤ãããã¯å¾©æ°ã®ã³ã³ããã§æ§æãã[^pod]ãæ§æã®å¤æ´ãå¢æ¸ã¯å²ã¨é »ç¹ã«è¡ãªããããã¨ãæ³å®ããããã©ã®ã¢ããªãã©ã®ãªã½ã¼ã¹ã«ã¢ã¯ã»ã¹ãããã¨ãè¨±å¯ãããã¯ãMSIã§æ±ºããã¨ããä½ç½®ä»ãã«ããããªã®ã§ãä»åã¯ãã¢ããªãããã­ã¤ããã¢ã¸ã¥ã¼ã«[container.bicep](https://github.com/takekazuomi/aca-msi01/blob/v1.0.1/deploy-app/container.bicep)ã¨ãå²å½ã¦(Role Assignments)ãè¡ãã¢ã¸ã¥ã¼ã«[roleAssignment.bicep](https://github.com/takekazuomi/aca-msi01/blob/v1.0.1/deploy-app/roleAssignment.bicep)ãåããããã­ã¤ã¯ãã®ï¼ã¤ãã¾ã¨ãã¦[main.bicep](https://github.com/takekazuomi/aca-msi01/blob/v1.0.1/deploy-app/main.bicep)ã§è¡ãããã«ããã

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

ãã®æ¸ãæ¹ã ã¨ãç°ãªã£ããªã½ã¼ã¹ã¸ã®ã¢ã¯ã»ã¹æ¨©ããã£ãã¢ããªãåãbicepã§ããã­ã¤åºæ¥ãªãã®ã§ãããå°ãå·¥å¤«ããå¿è¦ãããããã«æãããã¨ããããããããã¦ããã°ã[az cli](https://github.com/takekazuomi/aca-msi01/blob/v1.0.1/Makefile#L37) ä¸çºã§ããã­ã¤ã§ããã

ãããªæã

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

## å®è¡ã³ã¼ãå´

ãã¡ãã¯æ®éã®MSIã®ã³ã¼ããazure go sdk ã®`azure-sdk-for-go/sdk/azidentity`(https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azidentity@v0.14.0) ã[ä½¿ã£ã¦ãã](https://github.com/takekazuomi/aca-msi01/blob/main/web/main.go#L69)ã[DefaultAzureCredential](https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azidentity@v0.14.0#readme-defaultazurecredential)ãä½¿ãã¨ããã©ã«ãè¨­å®ã§ããã©ã¼ã«ããã¯ããªãããèªè¨¼åãæ¢ãã¦ãããã®ä¸­ã«MSIãå¥ã£ã¦ããã

![DefaultAzureCredential](https://github.com/Azure/azure-sdk-for-go/raw/sdk/azidentity/v0.14.0/sdk/azidentity/img/DAC_flow.PNG)

ãªããªãä¾¿å©ï¼ã ã¨æãï¼ãªã®ã ãããã¼ã¸ã§ã³å®å®æ§ãä½ããä»åã¯ã[azcore 0.23.0](https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azcore@v0.23.0)ã«ã[azblob](https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/storage/azblob@v0.3.0) ãä»ãã¦ããã¦ãªãããããï¼[ãã®ããã](https://github.com/Azure/azure-sdk-for-go/issues/17472#issuecomment-1092926620)ã«äºæãããã¦ããï¼
ã¨ããããåã®ãã¼ã¸ã§ã³ãä½¿ããã¨ã«ããã[^azb]

## æå¾ã«

Azure Container Apps ãªããªãè¯ããã§ãå§ãã§ãããã¡ãããbicepãã

[^aca]: Azure Container Apps ãç¥ãã¦**ACA**ã¨å¼ã¶ããã§ãã
[^MSI]: https://kogelog.com/2022/04/14/20220414-01/
        Public preview: Managed identities support in Azure Container Apps https://azure.microsoft.com/ja-jp/updates/public-preview-managed-identities-support-in-azure-container-apps/
[^pod]: ã¢ããªã¯ãk8sã§ããPODã®ãããªä½ç½®ä»ãã«ãªããæ°ããAPIããµã¼ãã¹ãä½ãã¨å¢æ¸ãããã¨ãæ³å®ãã¦ãããå ´åã«ãã£ã¦ã¯3æ¡ã«ãªãå ´åãããã ããã
[^azb]: ããã[Migrate azblob to latest version of azcore #17528](https://github.com/Azure/azure-sdk-for-go/pull/17528)ãæ¥ããç´ãããããªããã¨æã£ã¦ããã
