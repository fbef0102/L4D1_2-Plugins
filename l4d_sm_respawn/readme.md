# Description | 內容
Allows players to be respawned by admin.

* Video | 影片展示
<br/>None

* Image | 圖示
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
	Hungarian
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v2.8 (2023-4-1)
		* Replace Gamedata with left4dhooks

	* v2.7
		* fixed stuck ceiling when player respawns
		* delete unuseful gamedata
		* Only respawn Dead Survivor

	* v2.1
		* [Original Plugin by Dragokas](https://forums.alliedmods.net/showthread.php?p=2693455)
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_sm_respawn.cfg
		```php
		// Add 'Respawn player' item in admin menu under 'Player commands' category? (0 - No, 1 - Yes)
		l4d_sm_respawn_adminmenu "1"

		// After respawn player, teleport player to 0=Crosshair, 1=Self (You must be alive).
		l4d_sm_respawn_destination "0"

		// Respawn players with this loadout
		l4d_sm_respawn_loadout "smg"

		// Notify in chat and log action about respawn? (0 - No, 1 - Yes)
		l4d_sm_respawn_showaction "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Respawn a player at your crosshair. Without argument - opens menu to select players (Adm required: ADMFLAG_BAN)**
		```php
		sm_respawn <player name>
		```
</details>

* How to use
    * Type !admin -> Player commands -> Respawn Player

- - - -
# 中文說明
管理員能夠復活死去的玩家

* 原理
	* 管理員輸入!respawn 可以復活指定的死亡玩家並傳送到準心上

* 功能
	* 可以加入到管理員菜單下，輸入!admin->玩家指令->復活玩家
	* 可設置復活後給予的武器
	* 可設置是否給防彈背心與頭盔
	* 紀錄log
