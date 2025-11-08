# Description | 內容
Create a survivor bot in game + Teleport player

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* Image
	* teleport menu
	<br/>![l4d_wind_1](image/l4d_wind_1.jpg)

* Require | 必要安裝
	1. [l4d_CreateSurvivorBot](/l4d_CreateSurvivorBot)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_wind.cfg
		```php
		// If 1, Adm can use command to add a survivor bot
		l4d_wind_add_bot_enable "1"

		// Add 'Teleport player' item in admin menu under 'Player commands' category? (0 - No, 1 - Yes)
		l4d_wind_teleport_adminmenu "1"

		// If 1, Adm can teleport special infected
		l4d_wind_teleport_infected_enable "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Add a survivor bot (Adm required: ADMFLAG_BAN)**
		```php
		sm_addbot
		sm_createbot
		```

	* **Open 'Teleport player' menu (Adm required: ADMFLAG_BAN)**
		```php
		sm_teleport
		sm_tp
		```
</details>

* Translation Support | 支援翻譯
	```
	translations/l4d_wind.phrases.txt
	```

* <details><summary>Similar Plugin | 相似插件</summary>

	1. [l4d_teleport_call](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Survivor_人類/l4d_teleport_call): Teleport Call Menu
		> 呼叫傳送功能選單，能傳送玩家到起點、終點、救援區域
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.8 (2025-11-8)
		* Require l4d_CreateSurvivorBot

	* v1.7 (2024-5-31)
		* Respawn bot if bot was added as dead state

	* v1.6 (2022-11-23)
		* Initial Release
</details>

- - - -
# 中文說明
新增Bot + 傳送玩家到其他位置上

* 圖示
	* 傳送玩家選單
	<br/>![zho/l4d_wind_1](image/zho/l4d_wind_1.jpg)

* 原理
	* 管理員輸入!teleport 可以傳送指定玩家到準心上或是其他玩家身上

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_wind.cfg
		```php
		// 為1時，管理員可以輸入!addbot 增加bot數量
		l4d_wind_add_bot_enable "1"

		// 為1時，加入到管理員選單下，輸入!admin->玩家指令->傳送玩家
		l4d_wind_teleport_adminmenu "1"

		// 為1時，管理員可以傳送特感
		l4d_wind_teleport_infected_enable "1"
		```
</details>

* <details><summary>命令中文介紹 (點我展開)</summary>

	* **增加一個bot (權限: ADMFLAG_BAN)**
		```php
		sm_addbot
		sm_createbot
		```

	* **打開"傳送玩家選單" (權限: ADMFLAG_BAN)**
		```php
		sm_teleport
		sm_tp
		```
</details>
