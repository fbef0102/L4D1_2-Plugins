# Description | 內容
Prevents Rushers From Rushing Then Teleports Them Back To Their Teammates.

* Video | 影片展示
<br/>None

* Image
<br/>None

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* Translation Support | 支援翻譯
	```
	English
	繁體中文
	简体中文
	Russian
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.7 (2023-2-10)
        * Remake code
        * Replace l4d2direct with left4dhooks
        * Rremove l4d_stock.inc

    * v1.0
        * [Original Plugin by cravenge](https://forums.alliedmods.net/showthread.php?p=2411516)
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* Similar Plugin | 相似插件
	1. [l4d_together](https://github.com/fbef0102/Game-Private_Plugin/blob/main/Plugin_%E6%8F%92%E4%BB%B6/Anti_Griefer_%E9%98%B2%E6%83%A1%E6%84%8F%E8%B7%AF%E4%BA%BA/l4d_together/readme.md): A simple anti - runner system , punish the runner by spawn SI behind her.
		> 離隊伍太遠的玩家，特感代替月亮懲罰你

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/no-rushing.cfg
        ```php
        // Modes: 0=Teleport only, 1=Teleport and kill after reaching limits, 2=Teleport and kick after reaching limits.
        l4d_rushing_action_rushers "1"

        // Ignore Incapacitated Survivors?
        l4d_rushing_ignore_incapacitated "0"

        // Ignore lagging or lost players?
        l4d_rushing_ignore_lagging "0"

        // Maximum rushing limits
        l4d_rushing_limit "2"

        // Minimum number of alive survivors before No-Rushing function works. Must be 3 or greater.
        l4d_rushing_require_survivors "3"
        ```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* Data Config
    * configs\norushing\XXXX.cfg (XXXX is map name)
        ```c
        "c12m4_barn"
        {
            "Notice Rushing Distance"		"0.15"  // Warn rushers if they reached this distance (No teleportations, just warnings.)
            "Warning Distance"		"0.2"   // Teleport rusher back to team after reaching this distance
            "Behind Distance"		"0.31"  // Teleport player back to team if player is behind team and reach this distance
        }
        ```

- - - -
# 中文說明
離隊伍太遠的玩家會傳送回隊伍之中

* 原理
	* 某一位玩家擅自離開隊伍跑走，離隊伍路程太遠將會傳送回隊伍中
    * 如果超過一定次數，將處死玩家

* 功能
	* 可設置如何懲罰擅自離隊的玩家
    * 可設置隊伍至少需要的人數
    * 可忽略後方離隊的玩家
    * 根據地圖設置每個關卡的離隊與警告路程

* Data文件
    * configs\norushing\XXXX.cfg (XXXX是地圖名)
        ```c
        "c12m4_barn"
        {
            "Notice Rushing Distance"		"0.15"  // 離開隊伍超過15%路程會警告
            "Warning Distance"		"0.2"   // 離開隊伍超過20%路程會傳送回隊伍中
            "Behind Distance"		"0.31"  // 落後隊伍於後方並且超過31%路程會傳送回隊伍中
        }
        ```
