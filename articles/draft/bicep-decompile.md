---
title: "Bicep decompile日記、application-gateway-webapp-iprestriction編"
emoji: "💪"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["azure", "arm", "bicep"]
published: false
---

まずは、decompile する。２つのtemplateがあるので両方やる。

```sh
% bicep decompile azuredeploy.json
WARNING: Decompilation is a best-effort process, as there is no guaranteed mapping from ARM JSON to Bicep.
You may need to fix warnings and errors in the generated bicep file(s), or decompilation may fail entirely if an accurate conversion is not possible.
If you would like to report any issues or inaccurate conversions, please see https://github.com/Azure/bicep/issues.
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(44,7) : Warning no-unused-params: Declared parameter must be referenced within the document scope.
[See : https://aka.ms/bicep/linter/no-unused-params]
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(48,7) : Warning no-unused-params: Declared parameter must be referenced within the document scope.
[See : https://aka.ms/bicep/linter/no-unused-params]
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(209,23) : Error BCP085: The specified module path contains one ore more invalid path characters. The following are not permitted: """, "*", ":", "<", ">", "?", "\", "|".
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(227,15) : Warning BCP036: The property "capacity" expected a value of type "int | null" but the provided value is of type "'1'".
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(230,5) : Warning BCP037: The property "name" is not allowed on objects of type "schemas:6_properties". Permissible properties include "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName".
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(238,5) : Warning BCP037: The property "name" is not allowed on objects of type "schemas:49_properties". Permissible properties include "clientAffinityEnabled", "clientCertEnabled", "clientCertExclusionPaths", "cloningInfo", "containerSize", "dailyMemoryTimeQuota", "enabled", "hostingEnvironmentProfile", "hostNamesDisabled", "hostNameSslStates", "httpsOnly", "hyperV", "isXenon", "redundancyMode", "reserved", "scmSiteAlsoStopped", "siteConfig".
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(260,23) : Error BCP062: The referenced declaration with name "fetchIpAddress" is not valid.
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(274,5) : Warning BCP037: The property "storageMB" is not allowed on objects of type "Default". Permissible properties include "infrastructureEncryption", "minimalTlsVersion", "publicNetworkAccess", "sslEnforcement", "storageProfile".
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(279,11) : Warning BCP036: The property "size" expected a value of type "null | string" but the provided value is of type "int".
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(286,3) : Error BCP037: The property "location" is not allowed on objects of type "Microsoft.DBForMySQL/servers/firewallRules". Permissible properties include "dependsOn".
/home/takekazu/projects/azure-quickstart-templates/quickstarts/microsoft.network/application-gateway-webapp-iprestriction/azuredeploy.bicep(296,9) : Warning simplify-interpolation: String interpolation can be simplified. String variables can be directly assigned to string properties and variables.
[See : https://aka.ms/bicep/linter/simplify-interpolation]
```

```
% bicep decompile fetchIpAddress.json
WARNING: Decompilation is a best-effort process, as there is no guaranteed mapping from ARM JSON to Bicep.
You may need to fix warnings and errors in the generated bicep file(s), or decompilation may fail entirely if an accurate conversion is not possible.
If you would like to report any issues or inaccurate conversions, please see https://github.com/Azure/bicep/issues.
```

## エラーメッセージを眺める

エラーは、3箇所

(1)209行目：BCP085のmodule パス不正
```log
azuredeploy.bicep(209,23) : Error BCP085: The specified module path contains one ore more invalid path characters. The following are not permitted: """, "*", ":", "<", ">", "?", "\", "|".
```

(2)260行目：BCP062のreferenced 参照なし
```log
azuredeploy.bicep(260,23) : Error BCP062: The referenced declaration with name "fetchIpAddress" is not valid.
```

(3)286行目：BCP037 のここでの`location`指定は無効
```log
azuredeploy.bicep(286,3) : Error BCP037: The property "location" is not allowed on objects of type "Microsoft.DBForMySQL/servers/firewallRules". Permissible properties include "dependsOn".
```

## 該当部分を確認しながら修正

### (1)209行目：BCP085のmodule パス不正
エラーの部分のコード。
```yaml
module fetchIpAddress '?' /*TODO: replace with correct path to [uri(parameters('_artifactsLocation'), concat('fetchIpAddress.json', parameters('_artifactsLocationSasToken')))]*/ = {
  name: 'fetchIpAddress'
  params: {
    publicIPAddressId: publicIPAddressName.id
  }
  dependsOn: [
    applicationGatewayName
  ]
}
```

ここは、元々、テンプレートリンクになってた部分なので、module参照に変更

```yaml
module fetchIpAddress 'fetchIpAddress.bicep' = {
  name: 'fetchIpAddress'
  params: {
    publicIPAddressId: publicIPAddressName.id
  }
  dependsOn: [
    applicationGatewayName
  ]
}
```

### (2)260行目：BCP062のreferenced 参照なし

```
resource siteName_web 'Microsoft.Web/sites/config@2019-08-01' = {
  parent: siteName_resource
  name: 'web'
  properties: {
    ipSecurityRestrictions: [
      {
        ipAddress: '${fetchIpAddress.properties.outputs.ipAddress.value}/32'
      }
    ]
  }
}
```

`fetchIpAddress` をモジュールにしたので、モジュール側を確認。

```yaml
param publicIPAddressId string = 'nestedPublicIp'

output ipAddress string = reference(publicIPAddressId, '2020-05-01').ipAddress
```

`output ipAddress` になってるので、それを参照するように変更。

```yaml
resource siteName_web 'Microsoft.Web/sites/config@2019-08-01' = {
  parent: siteName_resource
  name: 'web'
  properties: {
    ipSecurityRestrictions: [
      {
        ipAddress: '${fetchIpAddress.outputs.ipAddress}/32'
      }
    ]
  }
}
```

### (3)286行目：BCP037 のここでの`location`指定は無効

下記のようになってるので、`location`を削除。

```yaml
resource serverName_serverName_firewall 'Microsoft.DBforMySQL/servers/firewallrules@2017-12-01' = {
  parent: serverName
  location: location
  name: '${serverName_var}firewall'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}
```

名前を、`azuredeploy.bicep` から、`main.bicep`に変更。こうしておくとbuildした時に名前がかぶらない。

## 警告を確認

linterで引っかかるので、見ながらざっと直す。

```
% bicep build main.bicep
main.bicep(44,7) : Warning no-unused-params: Declared parameter must be referenced within the document scope.
[See : https://aka.ms/bicep/linter/no-unused-params]
main.bicep(48,7) : Warning no-unused-params: Declared parameter must be referenced within the document scope.
[See : https://aka.ms/bicep/linter/no-unused-params]
main.bicep(227,15) : Warning BCP036: The property "capacity" expected a value of type "int | null" but the provided value is of type "'1'".
main.bicep(230,5) : Warning BCP037: The property "name" is not allowed on objects of type "schemas:6_properties". Permissible properties include "freeOfferExpirationTime", "hostingEnvironmentProfile", "hyperV", "isSpot", "isXenon", "maximumElasticWorkerCount", "perSiteScaling", "reserved", "spotExpirationTime", "targetWorkerCount", "targetWorkerSizeId", "workerTierName".
main.bicep(238,5) : Warning BCP037: The property "name" is not allowed on objects of type "schemas:49_properties". Permissible properties include "clientAffinityEnabled", "clientCertEnabled", "clientCertExclusionPaths", "cloningInfo", "containerSize", "dailyMemoryTimeQuota", "enabled", "hostingEnvironmentProfile", "hostNamesDisabled", "hostNameSslStates", "httpsOnly", "hyperV", "isXenon", "redundancyMode", "reserved", "scmSiteAlsoStopped", "siteConfig".
main.bicep(274,5) : Warning BCP037: The property "storageMB" is not allowed on objects of type "Default". Permissible properties include "infrastructureEncryption", "minimalTlsVersion", "publicNetworkAccess", "sslEnforcement", "storageProfile".
main.bicep(279,11) : Warning BCP036: The property "size" expected a value of type "null | string" but the provided value is of type "int".
main.bicep(295,9) : Warning simplify-interpolation: String interpolation can be simplified. String variables can be directly assigned to string properties and variables.
[See : https://aka.ms/bicep/linter/simplify-interpolation]
```

修正したのは下記7点

1. テンプレートリンクのパラメーターを削除
2. `Microsoft.Web/serverfarms`のcapacityは数字
3. `Microsoft.Web/serverfarms`のpropertiesにはnameは無い
4. `Microsoft.Web/sites`のpropertiesにはnameは無い
5. `Microsoft.DBforMySQL/servers`のpropertiesにはstorageMBは無い
6. `Microsoft.DBforMySQL/servers`のskuのdatabaseSkuSizeMBは文字列
7. `name: '${databaseName}'` は、`name: databaseName` と書く

変更点

```diff
diff --git a/main.bicep b/main.bicep
index 6448c6b..e462f7f 100644
--- a/main.bicep
+++ b/main.bicep
@@ -24,11 +24,11 @@ param databaseSkuName string = 'GP_Gen5_8'
 param databaseSkuFamily string = 'Gen5'

 @allowed([
-  102400
-  51200
+  '102400'
+  '51200'
 ])
 @description('Azure database for MySQL Sku Size')
-param databaseSkuSizeMB int = 51200
+param databaseSkuSizeMB string = '51200'

 @description('Azure database for MySQL pricing tier')
 param databaseSkuTier string = 'GeneralPurpose'
@@ -217,10 +217,7 @@ resource hostingPlanName 'Microsoft.Web/serverfarms@2019-08-01' = {
   }
   sku: {
     name: 'S1'
-    capacity: '1'
-  }
-  properties: {
-    name: hostingPlanName_var
+    capacity: 1
   }
 }

@@ -228,7 +225,6 @@ resource siteName_resource 'Microsoft.Web/sites@2019-08-01' = {
   name: siteName
   location: location
   properties: {
-    name: siteName
     serverFarmId: hostingPlanName.id
   }
 }
@@ -264,7 +260,6 @@ resource serverName 'Microsoft.DBforMySQL/servers@2017-12-01' = {
     version: mysqlVersion
     administratorLogin: administratorLogin
     administratorLoginPassword: administratorLoginPassword
-    storageMB: databaseSkuSizeMB
   }
   sku: {
     name: databaseSkuName
@@ -285,7 +280,7 @@ resource serverName_serverName_firewall 'Microsoft.DBforMySQL/servers/firewallru

 resource serverName_databaseName 'Microsoft.DBforMySQL/servers/databases@2017-12-01' = {
   parent: serverName
-  name: '${databaseName}'
+  name: databaseName
   properties: {
     charset: 'utf8'
     collation: 'utf8_general_ci'
```

デプロイできるか確認。ここまでで一通りの変換は終了。ここからは、改善を計る。

## 改善のポイント

1. decompileで作成された名前を直す
2. API Versionを最新にする
3. fetchIPAddress を exist 構文に直す

## 1. decompileで作成された名前を直す

decompileでは、param でもらったのをシンボル名にして、変数の場合は、`_var` と付るなど、見ずらいので名前を一通り直す。VSCode の

```diff
-resource virtualNetworkName 'Microsoft.Network/virtualNetworks@2020-05-01' = {
-  name: virtualNetworkName_var
+resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' = {
+  name: virtualNetworkName
```

[ここでの修正](https://github.com/takekazuomi/bicep-random-note/commit/cd01c7c69da5966290a170a615013285e5302533#diff-981cee71aef7b05bed2cd6c585ab46ab8cbd4f01ac7da0992090bb2ebd3085a4)

## 2. API Versionを最新にする

元のテンプレートのAPI Versionが古かったので更新した。[変更差分](https://github.com/takekazuomi/bicep-random-note/commit/195e4e13b189ab7afc0a275c8cf66c2f4693b3ca#diff-981cee71aef7b05bed2cd6c585ab46ab8cbd4f01ac7da0992090bb2ebd3085a4)

VSCodeでは、この手の修正は簡単にできるので、修正はサクサク進む。これをやると、APIに非互換の修正がされていてデプロイが壊れてしまうことがある。実際壊れているかはデプロイして確認するしかないので修正後デプロイして確認する。

## 3. bicep風に直す

今回は、全体を見直すと、下記のような変更をした。[１から３の変更の差分](https://github.com/takekazuomi/bicep-random-note/compare/195e4e1...3b5ee52)

1. subnetRef を `existing` 構文に直す
2. 簡単な変数宣言は直接書く
3. fetchIPAddress を外部に出すのをやめる

### 1. subnetRef を `existing` 構文に直す

元のものだと下記のように`resourceId()`で書かれている。bicep では、基本`resourceId()` は使わずに、`existing` に書き換える。この方が、リソースを文字列で指定する型のチェックがかかるので間違えづらい。[^1]

```yaml
var subnetRef = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
```

`existing` で書くとこんな風になる。subnetの親リソースは、`parent:virtualNetwork` の用に指定する。

```yaml
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent:virtualNetwork
  name:subnetName
}
```

参照する部分は、変数 `subnetRef` からオブジェクトのプロパティ参照に `subnet.id` 

```diff
- id: subnetRef
+ id: subnet.id
```

### 2. 簡単な変数宣言は直接書く
### 3. fetchIPAddress を外部に出すのをやめる



## moduleに分割する


https://github.com/takekazuomi/bicep-random-note/compare/195e4e1...3b5ee52

https://github.com/takekazuomi/bicep-random-note/compare/195e4e1..a57e2d4


ここからは、bicep 風に直して行く、


moduleに分割する



module分割してパラメータを調整した。

ポイント

1. module の outputsを使うとmodule間の依存関係を自動解決してくれる。
2. 依存関係の無いものとあるものは意識する。pip, vnetは他に依存しない
3. main 以外のモジュールはデフォルトを書かないのがお勧め（今は）


## 

改善案
VNETをarrayにする

ダメな点
vnetがAGWサブネットを知っているのはおかしい。
vnet は、指定されたサブネットで作成し、指定する側がサブネットの中から必要なものを選んで、agwに渡すべき。

---
[^1]: 現時点では、大きな例外がある。https://github.com/Azure/bicep/issues/1852