https://forums.alliedmods.net/showthread.php?t=286987

# Description | 內容
LMC Allows you to use most models with most characters

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * Require files
        * LMCCore: Core of LMC, manages overlay models
        * SetTransmit: Manages transmitting models to clients
        * LMC_SharedCvars: Modules that share cvars are put in here
    * Optional files
        * Menu_Choosing: Allows players to type ```!lmc``` to choose LMC model with cookie saving
        * RandomSpawns: Makes lmc models random for players and AI
        * CDeathHandler: Manages deaths regarding lmc, overlay deathmodels and ragdolls, and fixes clonesurvivors deathmodels teleporting around.
    * Name with L4D2: For L4D2 only
    * Name with L4D1: For L4D1 only
</details>

* Require | 必要安裝
    1. [ThirdPersonShoulder_Detect](https://forums.alliedmods.net/showthread.php?t=298649)
    2. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/LMCCore.cfg
        ```php
        // ConVars for plugin "LMCCore.smx"

        // 1 = (When client has no lmc model (enforce aggressive model showing base model render mode)) 0 = (compatibility mode (should help with plugins like incap crawling) Depends on the plugin)
        lmc_aggressive_model_checks "0" 
        ```

    * cfg/sourcemod/LMC_SharedCvars.cfg
        ```php
        // ConVars for plugin "LMC_SharedCvars.smx"

        // Allow Survivors to have custom model? (1 = true)
        lmc_allowSurvivors "1"

        // Allow Boomer to have custom model? (1 = true)
        lmc_allowboomer "1"

        // Allow Hunters to have custom model? (1 = true)
        lmc_allowhunter "1"

        // Allow Smoker to have custom model? (1 = true)
        lmc_allowsmoker "1"

        // Allow Tanks to have custom model? (1 = true)
        lmc_allowtank "0"

        // The tank model is big and don't look good on other models so i made it optional(1 = true)
        lmc_allow_tank_model_use "0"

        // Disables model precaching on selected maps to help prevent crashing, e.g. "c1m3_mall," for dead center map 3 separated by ","
        lmc_precache_prevent "" 
        ```

    * cfg/sourcemod/LMC_L4D2_RandomSpawns.cfg
        ```php
        // ConVars for plugin "LMC_L4D2_RandomSpawns.smx"

        // Allow humans to be considered by rng, menu selection will overwrite this in LMC_Menu_Choosing
        lmc_rng_humans "0"

        // (0 = disable custom models)chance on which will get a custom model
        lmc_rng_model_infected "20"

        // (0 = disable custom models)chance on which will get a custom model
        lmc_rng_model_survivor "10" 
        ```

    * cfg/sourcemod/LMC_L4D2_Menu_Choosing.cfg
        ```php
        // ConVars for plugin "LMC_L4D2_Menu_Choosing.smx"

        // Players with these flags have access to use !lmc command and change model. (Empty = Everyone, -1: Nobody)
        // NOTE: this will enable announcement to player who join server.
        lmc_admin_flag "n"

        // Delay On which a message is displayed for !lmc command
        lmc_announcedelay "15.0"

        // Display Mode for !lmc command (0 = off, 1 = Print to chat, 2 = Center text, 3 = Director Hint)
        lmc_announcemode "1"

        // How long (in seconds) the client will be in thirdperson view after selecting a model from !lmc command. (0.5 < = off)
        lmc_thirdpersontime "0.0" 
        ```

    * cfg/sourcemod/LMC_L4D1_RandomSpawns.cfg
        ```php
        // ConVars for plugin "LMC_L4D1_RandomSpawns.smx"

        // Allow humans to be considered by rng, menu selection will overwrite this in LMC_Menu_Choosing
        lmc_rng_humans "0"

        // (0 = disable custom models)chance on which will get a custom model
        lmc_rng_model_infected "100"

        // (0 = disable custom models)chance on which will get a custom model
        lmc_rng_model_survivor "100" 
        ```

    * cfg/sourcemod/LMC_L4D1_Menu_Choosing.cfg
        ```php
        // ConVars for plugin "LMC_L4D1_Menu_Choosing.smx"

        // Allow admins to only change models? (1 = true) NOTE: this will disable announcement to player who join. ((#define COMMAND_ACCESS ADMFLAG_CHAT) change to w/o flag you want)
        lmc_adminonly "0"

        // Delay On which a message is displayed for !lmc command
        lmc_announcedelay "15.0"

        // Display Mode for !lmc command (0 = off, 1 = Print to chat, 2 = Center text)
        lmc_announcemode "1" 
        ```
</details>

* Translation Support | 支援翻譯
    ```
    translations/lmc.phrases.txt
    ```

* <details><summary>Changelog | 版本日誌</summary>

    * v3.1.1 (2024-12-18)
        * Add some instructions how to install plugins (English and Chinese)
        * Update cvar "lmc_adminonly" => "lmc_admin_flag" in _Menu_Choosing, player no needs to modify ```sourcemod/configs/admin_overrides.cfg```

    * v3.1.0c (2024-10-2)
        * Fixed warnings in sm1.11 or above
        * Change LMCCore.inc some functions' name to prevent errors and conflict when include other colors such as
            * colors.inc
            * multicolors.inc
    
    * Original & Credit
        * [Lux](https://forums.alliedmods.net/showthread.php?t=286987)
</details>

- - - -
# 中文說明
可以自由變成其他角色或NPC的模組

* 原理
    * 插件必裝
        * LMCCore: 核心插件
        * SetTransmit: 其他玩家能看到你的模型
        * LMC_SharedCvars: 創造共用的指令
    * 插件自選
        * Menu_Choosing: 輸入```!lmc```能自己選擇模型，下次玩家加入伺服器自動保存相同模型
        * RandomSpawns: 玩家或AI復活與生成時，給他隨機一個模型
        * CDeathHandler: 死亡的屍體模型也是自己選擇的模型
    * 插件名子帶有L4D2: 只能安裝在 L4D2
    * 插件名子帶有L4D1: 只能安裝在 L4D1

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/LMCCore.cfg
        ```php
        // 插件 "LMCCore.smx"

        // 1 = (強制檢查模式) 每秒檢查客戶端有沒有 lmc 模型 0 = (配合模式) 配合其他會改變模型的插件
        lmc_aggressive_model_checks "0" 
        ```

    * cfg/sourcemod/LMC_SharedCvars.cfg
        ```php
        // 插件 "LMC_SharedCvars.smx"

        // 為1時，允許倖存者更換模型
        lmc_allowSurvivors "1"

        // 為1時，允許Boomer更換模型
        lmc_allowboomer "1"

        // 為1時，允許Hunter更換模型
        lmc_allowhunter "1"

        // 為1時，允許Smoker更換模型
        lmc_allowsmoker "1"

        // 為1時，允許Tank更換模型
        lmc_allowtank "0"

        // 為1時，更換成Tank模型 (Tank模型體積很大，可能會導致錯亂)
        lmc_allow_tank_model_use "0"

        // 以下地圖不准換模型，請用逗號區隔 範例: "c1m3_mall,c7m1_docks"
        lmc_precache_prevent "" 
        ```

    * cfg/sourcemod/LMC_L4D2_RandomSpawns.cfg
        ```php
        // 插件 "LMC_L4D2_RandomSpawns.smx"

        // 是否給真人玩家隨機一個模型 (LMC_Menu_Choosing 選單覆蓋)
        // 1=給, 0=不給
        lmc_rng_humans "0"

        // (0 = 不給隨機模型) 特感生成時，給他隨機一個模型的機率 [數值: 1~100]
        lmc_rng_model_infected "20"

        // (0 = 不給隨機模型) 倖存者生成時，給他隨機一個模型的機率 [數值: 1~100]
        lmc_rng_model_survivor "10" 
        ```

    * cfg/sourcemod/LMC_L4D2_Menu_Choosing.cfg
        ```php
        // 插件 "LMC_L4D2_Menu_Choosing.smx"

        // 擁有這些權限的玩家，可以使用 !lmc 命令 (留白 = 任何人都能, -1: 無人)
        // 注意: 玩家進服時會看到提示
        lmc_admin_flag "n"

        // 玩家進服時，等待此秒數後提示可以用使用 !lmc 命令
        lmc_announcedelay "15.0"

        // 提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框, 3: 導演系統提示)
        lmc_announcemode "1"

        // 玩家使用 !lmc 命令選擇模型之後，短暫切緩第三人稱視角的時間 (此數值小於0.5則關閉這項功能)
        lmc_thirdpersontime "0.0" 
        ```

    * cfg/sourcemod/LMC_L4D1_RandomSpawns.cfg
        ```php
        // 插件 "LMC_L4D1_RandomSpawns.smx"

        // 是否給真人玩家隨機一個模型 (LMC_Menu_Choosing 選單覆蓋)
        // 1=給, 0=不給
        lmc_rng_humans "0"

        // (0 = 不給隨機模型) 特感生成時，給他隨機一個模型的機率 [數值: 1~100]
        lmc_rng_model_infected "100"

        // (0 = 不給隨機模型) 倖存者生成時，給他隨機一個模型的機率 [數值: 1~100]
        lmc_rng_model_survivor "100" 
        ```

    * cfg/sourcemod/LMC_L4D1_Menu_Choosing.cfg
        ```php
        // 插件 "LMC_L4D1_Menu_Choosing.smx"

        // 擁有這些權限的玩家，可以使用 !lmc 命令 (留白 = 任何人都能, -1: 無人)
        // 注意: 玩家進服時會看到提示
        lmc_admin_flag "n"

        // 玩家進服時，等待此秒數後提示可以用使用 !lmc 命令
        lmc_announcedelay "15.0"

        // 提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框)
        lmc_announcemode "1"
        ```
</details>
