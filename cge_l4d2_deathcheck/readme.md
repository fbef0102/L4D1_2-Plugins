# Description | 內容
Prevents mission loss(Round_End) until all real players and AI bots have died.

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * Mission loss will not occur until there are no living survivors
    * Bots will continue playing after all human players are dead and can rescue them
    * Prevents mission loss(Round_End) even if all survivors are incapacitated
    * This plugin start working once players leave the saferoom 
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/cge_l4d2_deathcheck.cfg
        ```php
        // 0: Disable plugin, 1: Enable plugin
        deathcheck "1"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v2.2 (2026-4-1)
        * Update cvar and optimize code again
        * This plugin start working once players leave the saferoom

    * v2.1
        * Remake code
        * Fixed double round end issue when map change

    * v1.5.6
        * [Original by chinagreenelvis](https://forums.alliedmods.net/showthread.php?t=142432)
</details>

- - - -
# 中文說明
場上所有真人倖存者+AI bots死亡才會回合結束

* 原理
    * 所有真人倖存者死亡時回合還不會結束，AI Bots會繼續遊玩
    * 當所有真人倖存者+AI Bots死亡之後回合才會結束
    * 即使所有倖存者倒地，回合依然不會結束
    * 倖存者出去安全區域之後此插件才會生效

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/cge_l4d2_deathcheck.cfg
        ```php
        // 0: 關閉插件, 1: 開啟插件
        deathcheck "1"
        ```
</details>