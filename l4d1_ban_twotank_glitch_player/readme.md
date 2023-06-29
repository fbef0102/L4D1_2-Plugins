# Description | 內容
Ban player who uses L4D1 / Split tank glitchpick up

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* Apply to | 適用於
    ```
    L4D1
    ```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.1 (2023-6-30)
        * Remake code, convert code to latest syntax

	* v1.0 (2020-6-24)
        * Initial Release
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\l4d1_ban_twotank_glitch_player.cfg
		```php
        // Ban how many mins.
        l4d1_ban_twotank_glitch_player_ban_time "5"

        // 0=Plugin off, 1=Plugin on.
        l4d1_ban_twotank_glitch_player_enable "1"

        // Kill Tank who's Frustration is 100% a player leaves.
        l4d1_ban_twotank_glitch_player_kill_tank "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* Details
    * [Bug explained here](https://forums.alliedmods.net/showthread.php?t=326023)

- - - -
# 中文說明
修復L4D1遊戲的Bug: 雙重Tank生成的問題

* 原理
    * 此插件修復L4D1遊戲的一個bug

* 如何重現bug
    * 控制Tank的玩家在控制權快沒有的時候重新連線伺服器，會使得場上多出一隻AI Tank