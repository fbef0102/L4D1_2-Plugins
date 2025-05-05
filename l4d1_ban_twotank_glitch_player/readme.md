# Description | 內容
Ban player who uses L4D1 / Split tank glitchpick up

* Apply to | 適用於
    ```
    L4D1
    ```

* <details><summary>How does it work?</summary>

    * (Before) There is a bug that a lot of people use nowadays where split the tank into two
        * [Details](https://forums.alliedmods.net/showthread.php?t=326023)
        1. When player-controlled tank losing control and is about to pass tank to other players
        2. Reconnect to server immediately
        3. You have the second tank on the field now
    * (After) Ban the tank player who leaves the game when losing control
</details>

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

- - - -
# 中文說明
修復L4D1遊戲的Bug: 雙重Tank生成的問題

* 原理
    * 此插件修復L4D1遊戲的一個bug

* 如何重現bug
    * 控制Tank的玩家在控制權快沒有的時候重新連線伺服器，會使得場上多出一隻AI Tank