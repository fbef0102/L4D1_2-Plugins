# Description | 內容
When revived from a ledge, you recover the health you had before hanging the ledge

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * (Before) 
        1. The Survivor will lose some health if they hang from the ledge for a while
            * Example: 100hp -> hang from the ledge -> revived -> 98hp
        2. Fall from ledge having 1 HP and 0 Temp HP -> revived -> get 30 free temp health (By official cvar ```survivor_revive_health``` default value)
    * (裝此插件之後) 
        1. The Survivor recovers the health they had before hanging from the ledge
            * Example: 100hp -> hang from the ledge -> revived -> still 100hp
        2. Disabling abuse method of receiving free health
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d_both_ledge.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        l4d_both_ledge_enable "1"

        // If 1, Restore perment health survivors had before grabbing the ledge
        l4d_both_ledge_permanent_hp "1"

        // If 1, Restore temporary health survivors had before grabbing the ledge
        l4d_both_ledge_temp_hp "1"

        // If 1, Disabling abuse method of receiving free health
        // Fall from ledge having 1 HP and 0 Temp HP -> revived -> get 30 free temp health
        l4d_both_ledge_abuse_fix "1"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.0h (2026-8-29)
        * Optimize code and improve performance
        * Add cvars
        * Fix the plugin name

    * v1.0
        * [Original Plugin by bullet28](https://forums.alliedmods.net/showthread.php?t=322158)
</details>

- - - -
# 中文說明
掛邊的玩家被救起來之後，血量恢復到掛邊之前的狀態

* 原理
    * (裝此插件之前) 
        1. 掛邊的玩家被救起來之後會失去部分原有的血量
            * 舉例: 100血量 -> 掛邊 -> 被救起來 -> 血量變成98
        2. 如果玩家剩餘1滴血量無虛血掛邊 -> 被救起來 -> 會獲得30虛血 (由官方指令```survivor_revive_health```數值決定)
    * (裝此插件之後) 
        1. 掛邊的玩家被救起來之後不會失去原有的血量
            * 舉例: 100血量 -> 掛邊 -> 被救起來 -> 血量依然100
        2. 禁止玩家濫用掛邊獲得額外的免費血量

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d_both_ledge.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        l4d_both_ledge_enable "1"

        // 為1時，掛邊的玩家被救起來之後恢復實血（掛邊前的狀態）
        l4d_both_ledge_permanent_hp "1"

        // 為1時，掛邊的玩家被救起來之後恢復虛血（掛邊前的狀態）
        l4d_both_ledge_temp_hp "1"

        // 為1時，禁止玩家濫用掛邊獲得額外的免費血量
        // 剩餘 1 HP 無虛血掛邊 -> 被救起來 -> 會獲得30虛血
        l4d_both_ledge_abuse_fix "1"
        ```
</details>