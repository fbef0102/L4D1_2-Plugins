# Description | 內容
If a player die as a survivor, this model character(Nick/Ellis/Bill/Zoey...) keep death until campaign change or server shutdown

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * Example: If Bill dies, then all players with Bill model will die always (force player suidice) until
        * Server restarts
        * Change next campaign map 1
</details>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d2_Death_Survivor.cfg
        ```php
        // Enable this plugin?[1-Enable,0-Disable]
        l4d2_enable_death_survivor "1"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.3
        * Initial Release
</details>

- - - -
# 中文說明
該角色死亡之後，相同模型的角色(Nick/Ellis/Bill/Zoey...)會一直保持死亡，直到更換大地圖或是伺服器重啟

* 原理
    * 舉例: 當Bill死亡之後，其他有相同Bill模型的玩家全部處死
        * 下次復活依然處死
        * 這種狀況直到伺服器重啟或是重新下一張大地圖的第一關


* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d2_Death_Survivor.cfg
        ```php
        // 1=開啟插件, 0=關閉插件
        l4d2_enable_death_survivor "1"
        ```
</details>
