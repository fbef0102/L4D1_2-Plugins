# Description | 內容
Fixes survivor_max_incapacitated_count cvar increased values reverting black and white screen.

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* <details><summary>How does it work?</summary>

	* Fixed incorrectly set black/white when official cvar ```survivor_max_incapacitated_count != 2```, [see here](https://forums.alliedmods.net/showthread.php?t=313645)
	* Provide natives api for other plugins to get accurate revive counts.
</details>

* Require
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_heartbeat.cfg
		```php
		// 0=Plugin off, 1=Plugin on.
		l4d_heartbeat_enable "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* <details><summary>API | 串接</summary>

	```php
	Registers a library name: l4d_heartbeat
	```
	* ```scripting\include\l4d_heartbeat.inc```
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2024-10-3)
		* Remove useless and unnecessary cvars, cmds
		* Remove useless codes locking "survivor_max_incapacitated_count" cvar
		* Fixed not working if other plugin using ```FakeClientCommand(client, "give health");```
		* Fixed no ff damage to player after has incapacitated once
		* Add include file

	* Original
		* [Original plugin](https://forums.alliedmods.net/showthread.php?t=322132)
</details>

- - - -
# 中文說明
可用指令調整倖存者有多條生命與黑白狀態

* 原理
	* 修復官方指令```survivor_max_incapacitated_count```被修改後，玩家會有錯亂的黑白狀態與剩餘生命條
	* 提供API，能夠讓其他的插件準確抓到或設置玩家還剩餘幾條生命
	* 總結: 當你有以下情況時，才需要安裝此插件
		* 其他插件有需要
		* 或有修改官方指令```survivor_max_incapacitated_count```
</details>

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_heartbeat.cfg
		```php
		// 0=關閉插件, 1=啟動插件
		l4d_heartbeat_enable "1"
		```
</details>