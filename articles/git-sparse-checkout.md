---
title: "git sparse-checkout"
emoji: "ð"
type: "tech" # tech: æè¡è¨äº / idea: ã¢ã¤ãã¢
topics: ["git", "ç´¹ä»"]
published: true
---

## Sparse checkoutï¼çãªãã§ãã¯ã¢ã¦ãï¼

ãã¤ã®ã¾ã«ããgit ã§ä¸é¨ã®ãã£ã¬ã¯ããªã ããã§ãã¯ã¢ã¦ããããã¨ãã§ããããã«ãªã£ã¦ãã®ã§è©¦ãã¦ã¿ãã[^git]

[azure-quickstart-templates](https://github.com/Azure/azure-quickstart-templates)ã®ãããªãã¡ã¤ã«ãå¤§éã«ãªãã¬ãã¸ããªã ã¨ä¸é¨ã ãæ¬²ãããªããã¾ããã¬ãã¸ããªã®ä¸­ã«å©ç¨ãã¦ããOSã®ãã¡ã¤ã«ã·ã¹ãã ã§ã¯ä½¿ããªããããªæå­ãä½¿ããããã¡ã¤ã«ãããå ´åããããä¸é¨ã ããã§ãã¯ã¢ã¦ãã§ããã®ã¯å¬ããã[^co]

ããã§ã¯ãæ°ããã¬ãã¸ããªãã¯ã­ã¼ã³ããã¨ããããå§ãããã¾ããæåã«cloneããã¨ãã«ã`--no-checkout` ãªãã·ã§ã³ãä»ãããããããã¨ããã¹ã¦ã®Git objectãã¯ã­ã¼ã³ããããããã¡ã¤ã«ã¯ä½æãããªãã

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

çµæ§å¤§ããªã¬ãã¸ããªãªã®ã§ããããªãã«æéããããããçµãã£ããããã£ã¬ã¯ããªã«å¥ã£ã¦ä¸­ãç©ºãªã®ãç¢ºèªããã

```sh
$ cd azure-quickstart-templates
$ ls
```

`sparse-checkout init --cone` ãã¦ãæ¬²ãããã£ã¬ã¯ããªãè¿½å ããã`add` ã¯ã2.26ããã ããã [^git2]

```sh
$ git sparse-checkout init --cone
$ git sparse-checkout add quickstarts/microsoft.app/
```

ããã§ãæå®ãã£ã¬ã¯ããª(quickstarts/microsoft.app/)ããã§ãã¯ã¢ã¦ããããã

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
â   .gitattributes
â   .gitignore
â   az-group-deploy.sh
â   Deploy-AzTemplate.ps1
â   Deploy-AzTemplate.psm1
â   Deploy-AzureResourceGroup.ps1
â   LICENSE
â   README.md
â   SECURITY.md
â   SideLoad-AzCreateUIDefinition.ps1
â   sideload-createuidef.sh
â   SideLoad-CreateUIDefinition.ps1
â
ââââquickstarts
    â   README.md
    â
    ââââmicrosoft.app
        ââââcontainer-app-azurevote
        â       azuredeploy.json
        â       azuredeploy.parameters.json
        â       main.bicep
        â       metadata.json
        â       README.md
        â
        ââââcontainer-app-create
                azuredeploy.json
                azuredeploy.parameters.json
                main.bicep
                metadata.json
                README.md
```

ããã«è¿½å ã§ã`demos/private-aks-cluster` ãæã£ã¦ããã

```sh
$ git sparse-checkout add demos/private-aks-cluster
$ tree .
Folder PATH listing for volume system
Volume serial number is 0000002D 8236:FAD0
C:\WS\TMP\AZURE-QUICKSTART-TEMPLATES2
ââââdemos
â   ââââprivate-aks-cluster
â       ââââimages
ââââquickstarts
    ââââmicrosoft.app
        ââââcontainer-app-azurevote
        ââââcontainer-app-create
```

ãããªæãã§ãæå®ã®ãã£ã¬ã¯ããªã ãããã§ãã¯ã¢ã¦ããããã¨ãã§ãããããã¾ã§ãã**sparse-checkout** ã®è©±ãããã¯ãgit objectãããæå®é¨åãåãåºããçãªãã§ãã¯ã¢ã¦ããããæ©è½ã
ãªããªãä¾¿å©ã ã

## Partial clone(éå»¶ã¯ã­ã¼ã³)

ããã¨ã`Partial Clone`[^pc] ãçµã¿åãããã¨ããªã³ããã³ãã§å¿è¦ãªãªãã¸ã§ã¯ãã ãããã¦ã³ã­ã¼ããããã¨ãã§ããã`Partial Clone`ã«ã¯ã`clone` ã³ãã³ãã« `--filter=blob:none` ãæå®ããã10ç§è¶³ããã§çµããæ®µéãã«æ©ãã

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

## NTFSã§ã¯ä½æä¸å¯ãªãã¡ã¤ã«ãé¤å¤

NTFSã§ã¯ä½æã§ããªããããªãã¡ã¤ã«ãå«ã¾ãã¦ããå ´åã`git clone` ã§ä¸è¨ã®ãããªã¨ã©ã¼ã«ãªãã

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

ã¡ãã»ã¼ã¸ã«ã¯ã`warning: Clone succeeded, but checkout failed.` ã¨åºã¦ããããã¡ã¤ã«åã®ãã§ãã¯ã¯ã¯ã­ã¼ã³å¾ã®ãã§ãã¯ã¢ã¦ãã§è¡ããã¦ããããªãã¨ããããããã®ç¶æã§ã`git status`ããã¨ãä½æ¥­ãã£ã¬ã¯ããªã§ã¯ã¹ãã¼ã¸ã«ãã¡ã¤ã«ãããã£ã¦ããä¸­éåç«¯ãªç¶æã«ãªã£ã¦ããããããããªã«ããªããããã `protectNTFS false` ã§ã¯ã­ã¼ã³ããè©²å½ãã¡ã¤ã«ããã£ã¬ã¯ããªãé¤å¤ããæ¹ãããã

ä¾ãã°ããã§ãã¯ã¢ã¦ããããªãã§ãã¯ã­ã¼ã³ã ããã¦ãã¬ãã¸ããªåã§`protectNTFS`ãç¡å¹ã«æå®ã

```powershell
$ git clone  --no-checkout https://github.com/takekazuomi/test-protectNTFS.git
$ cd test-protectNTFS
$ git config core.protectNTFS false
```

ä»ã«ããã¯ã­ã¼ã³æã«ããªãã·ã§ã³ã§`protectNTFS`ãç¡å¹ã«æå®ãããªã©ãå¹¾ã¤ãæ¹æ³ã¯ããã

```powershell
$ git clone --config core.protectNTFS=false https://github.com/takekazuomi/test-protectNTFS.git
```

æåã`git config --global core.protectNTFS false` ã®ããã«ãã¦NTFSä¿è­·ãã°ã­ã¼ãã«ã«ç¡å¹ã«ãã¦ãã¾ãã°è¯ããã¨æã£ãããã»ãã³ã­ã³ã®ä»ãããã¡ã¤ã«åãåãä»ããã¨èå¼±æ§ã®åé¡ãããã[^av1] ä¿¡é ¼ã§ããã¬ãã¸ããªã§ã ãã§è¨­å®ããããã«ãã¦ãä¸è¨ã®ããã«ãã°ã­ã¼ãã«è¨­å®ã¯é¿ãã¦ã¬ãã¸ããªæ¯ã«æå®ããæ¹ãè¯ãã ããã

## æå¾ã«

ç¹å®ã®ãã£ã¬ã¯ããªã ãç¡è¦ãããå ´åã`git sparse-checkout set --no-cone` ãä½¿ãã`quickstarts` ã ããé¤å¤ããããªããä¸è¨ã®ããã«ããã[^fp]

```sh
$ git sparse-checkout set --no-cone '/*' '!quickstarts'
```

[^git]: Bring your monorepo down to size with sparse-checkout <https://github.blog/2020-01-17-bring-your-monorepo-down-to-size-with-sparse-checkout/> 2020å¹´ã®åé ­ããä½¿ããããããç¥ããªãã£ãããã
[^co]: é¨åãã§ãã¯ã¢ã¦ãã¯ã10æ°å¹´åã«ãsvnããgitã«ç§»è¡ããã¨ãã«æ¢ããæ©è½ã®ï¼ã¤ãç¡ãã¦æ®å¿µãªæ°åã«ãªã£ãã®ãæãåºãã
[^git2]: Highlights from Git 2.26 <https://github.blog/2020-03-22-highlights-from-git-2-26/> add æ¢å­ã«ã¼ã«ã«è¿½å ã§ãset ã¯ã«ã¼ã«ã®è¨­å®ï¼ä¸æ¸ãï¼ãadd ã®æ¹ãæ®æ®µä½¿ãã«ä¾¿å©ããã ãæ¢å­ã«ã¼ã«ãä¸æ¸ããããå ´åã¯ set ãä½¿ãã
[^pc]: Partial Clone <https://git-scm.com/docs/partial-clone>
[^git3]: æ¢å­ã®ãªãã¸ããªã§ã¹ãã¼ã¹ãã§ãã¯ã¢ã¦ããä½¿ç¨ãã <https://github.blog/2020-01-17-bring-your-monorepo-down-to-size-with-sparse-checkout/#using-sparse-checkout-with-an-existing-repository>
[^sc]: Cone mode: restricted patterns improve performance <https://github.blog/2020-01-17-bring-your-monorepo-down-to-size-with-sparse-checkout/#cone-mode-restricted-patterns-improve-performance> Cone mode ã¨ãããããã
[^fp]: FULL PATTERN SET <https://git-scm.com/docs/git-sparse-checkout#_internalsfull_pattern_set>
[^av1]: ã³ã­ã³ãå«ããã¡ã¤ã«åãæªç¨ãããã¨ãremote code execution vulnerability ããããä¿¡é ¼ã§ããªãã¬ãã¸ããªãã¯ã­ã¼ã³ããå¯è½æ§ãããå ´åã¯ãããã©ã«ãã§ã¯ãcore.protectNTFS ãtrueã«ãã¦ãããæ¹ãããã <https://github.com/git/git/security/advisories/GHSA-589j-mmg9-733v> <https://github.com/advisories/GHSA-74fq-3g57-65f7>
