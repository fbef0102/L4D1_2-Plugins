# Description | 內容
Prevents Rushers From Rushing Then Teleports Them Back To Their Teammates.

* Video | 影片展示
<br/>None

* Image
<br/>None

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/no-rushing.cfg
        ```php
        // Maximum rushing limits
        no-rushing_limit "2"

        // Minimum number of alive survivors before No-Rushing function works. Must be 3 or greater.
        no-rushing_require_survivors "3"

        // Ignore Incapacitated Survivors?
        no-rushing_ignore_incapacitated "0"

        // Modes: 0=Teleport only, 1=Teleport and kill after reaching limits, 2=Teleport and kick after reaching limits.
        no-rushing_action_rushers "1"
        ```
</details>

* <details><summary>Command | 命令</summary>

    None
</details>

* <details><summary>Data Config</summary>

    * [configs\no-rushing.cfg](configs\no-rushing.cfg)
        ```php
        "no-rushing"
        {
            "c12m4_barn" // map name
            {
                // 1=Enable plugin, 0=Disable plguin in this map
                "Enable"	"1"
                
                // [0.00~1.00] Warn rushers if they reached this distance (No teleportations, just warnings.)
                "Notice_Rushing_Distance"		"0.15" 
                
                // [0.00~1.00] Teleport rusher back to team after reaching this distance
                "Teleport_Rushing_Distance"				"0.2"
                
                // [0.00~1.00] Teleport player back to team if player is behind team and reach this distance
                "Teleport_Behind_Distance"				"0.31"
                
                // Only teleport player back to team if far away range from team (To prevent nav bug)
                "Range_Distance"				"600.0"
            }

            ...
        }
        ```
</details>

* <details><summary>Translation Support | 支援翻譯</summary>

    ```
    English
    繁體中文
    简体中文
    Russian
    ```
</details>

* <details><summary>Related Plugin | 相關插件</summary>

    1. [l4d_together](https://github.com/fbef0102/Game-Private_Plugin/blob/main/Plugin_%E6%8F%92%E4%BB%B6/Anti_Griefer_%E9%98%B2%E6%83%A1%E6%84%8F%E8%B7%AF%E4%BA%BA/l4d_together/readme.md): A simple anti - runner system , punish the runner by spawn SI behind her.
        * 離隊伍太遠的玩家，特感代替月亮懲罰你
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.1h (2024-8-4)
        * Update Config file

    * v1.0h (2024-7-26)
        * Update Config file

    * v1.7 (2023-2-10)
        * Remake code
        * Replace l4d2direct with left4dhooks
        * Rremove l4d_stock.inc

    * v1.0
        * [Original Plugin by cravenge](https://forums.alliedmods.net/showthread.php?p=2411516)
</details>

- - - -
# 中文說明
離隊伍太遠的玩家會傳送回隊伍之中

* 原理
    * 某一位玩家擅自離開隊伍跑走，離隊伍路程太遠將會傳送回隊伍中
    * 如果超過一定次數，將處死玩家

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/no-rushing.cfg
        ```php
        // 擅自離開隊伍的最大次數 (超過一定次數，將懲罰玩家)
        no-rushing_limit "2"

        // 倖存者隊伍至少需要的活著人數，此插件才會運作 (至少要3人以上)
        no-rushing_require_survivors "3"

        // 為1時，擅自離開隊伍的玩家如果是倒地狀態則不懲罰
        no-rushing_ignore_incapacitated "0"

        // 如何懲罰擅自離隊的玩家 0=傳送回隊伍, 1=傳送回隊伍並處死 (超過容忍次數), 2傳送回隊伍並踢出遊戲 (超過容忍次數).
        no-rushing_action_rushers "1"
        ```
</details>


* <details><summary>文件設定範例</summary>

    * [configs\no-rushing.cfg](configs\no-rushing.cfg)
        ```php
        "no-rushing"
        {
            "c12m4_barn" //地圖名
            {
                // 1=在這張地圖開啟插件, 0=在這張地圖關閉插件
                "Enable"	"1"
                
                // [0.00~1.00] 往前離開隊伍超過15%路程會警告
                "Notice_Rushing_Distance"		"0.15" 
                
                // [0.00~1.00] 往前離開隊伍超過20%路程會傳送回隊伍中
                "Teleport_Rushing_Distance"				"0.2"
                
                // [0.00~1.00] 落後隊伍於後方並且超過31%路程會傳送回隊伍中
                "Teleport_Behind_Distance"				"0.31"
                
                // 與隊伍超過此距離才會傳送玩家並懲罰 (避免隔牆 nav bug)
                "Range_Distance"				"600.0"
            }

            ...
        }
        ```
</details>
