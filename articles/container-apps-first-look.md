---
title: "Azure Container Apps ãè©¦ã"
emoji: "ðª"
type: "tech" # tech: æè¡è¨äº
topics: ["azure", "conatiner", "containerapps", "å¥é", "bicep"]
published: false
---

# æ¦è¦

Ignite 2021 ã§ã[Azure Container Apps](https://azure.microsoft.com/ja-jp/services/container-apps/) ãçºè¡¨ããããã©ããªãã®ãªã®ãã¯ãã¦ãããã³ã³ãããã¹ãã£ã³ã°é£æ°ã®ãªã¢ã·ã¹ã«ãªãããã«æããªã®ã§ã¾ãã¯ä½¿ã£ã¦ã¿ãã

ã¾ãã¯ããµã³ãã«ã[Container App Store Microservice Sample](https://github.com/Azure-Samples/container-apps-store-api-microservice)ãåããã¦ã¿ããã

ãã®ãµã³ãã«ã¯ãAzure Container Apps ä¸ã§ store serivce ããorder service ã¨ inventory service ãå¼ã¶ãDapr ã§ããµã¼ãã¹éã®éä¿¡ã¨å¼ã³åºããä¿è­·ããAzure API Management ã¨ Azure Cosmos DBãä½¿ã£ã¦ãããCI/CDç¨ã® GitHub Actions ã¨ Bicep ã§æ§æããã¦ããã

æ¦è¦ã¯ã[Azure Container Apps Demo - Serverless Microservices](https://www.youtube.com/watch?v=fmGHEJL81rU)ã®åç»ãè¦ãã¨åããã

![demo](./media/cappdemo01.png)

1. ã¬ãã¸ããªãforkãã
2. GitHub Actionããã«ã¯ã¬ãã³ã·ã£ã«ãè¨­å®ãã

https://github.com/microsoft/azure-container-apps

---

[^1]: ä¸é¨ã®æ©è½ã¯ãå®è£ããªããã¨ããé¸æãã¦ãããã®ãããã[ã¦ã¼ã¶ã¼å®ç¾©é¢æ° Issue 2](https://github.com/Azure/bicep/issues/2)ãå¤é¨ãã³ãã¬ã¼ããouter scopeãªã©ã
[^2]: dev-containersã®åãã¿ã¯ã [ãã](https://github.com/microsoft/vscode-dev-containers/tree/v0.166.1/containers/azure-bicep) ãæ¬²ãããã®ãå¨é¨å¥ã£ã¦ããããã§ã¯ãªãã®ã§ãããã«é©æå¿è¦ãªãã®ãããããèªåç¨ã«ã«ã¹ã¿ãã¤ãºãããdev container ã[ãã](https://github.com/takekazuomi/devcontainer-bicep)ã«ããã¦ããã
[^3]: snippets ã¯[çµ¶è³å®è£ä¸­](https://github.com/Azure/bicep/issues?q=+label%3A%22story%3A+snippets%22)ã§ç¾æç¹(0.3.539)ã§å¤§åè¯ããªã£ãã
[^4]: ARM Template ã ã¨ãããã«`functions` ãå¥ãããbicepã§ã¯æªå®è£ã
[^5]: ãããããã¿ã¤ãæå ±ããããªãã£ãããbicepã§ãã¾ãæ±ããªããã¿ã¼ã³ããã£ããã§ãã¾ã è¶³ããªãé¨åãããããããããªã¨æã£ããã[Missing type validation / inaccuracies #784](https://github.com/Azure/bicep/issues/784) ãè¦ãã¨åèã«ãªãã
[^6]: [bicep ã®FAQ](https://github.com/Azure/bicep#faq)ã® `Is this ready for production use?` ã«ã`Yes. As of v0.3, Bicep is now supported by Microsoft Support Plans` ã¨ãããã¾ã ãã¬ãã¥ã¼ã§ã¯ãããããã­ãã¯ã·ã§ã³ã«å©ç¨ã§ãã¦ã Microsoft Support Plans ã§ãµãã¼ããããã¨ããã


