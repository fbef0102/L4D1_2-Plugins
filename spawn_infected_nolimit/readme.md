# Description | 內容
Spawn special infected without the director limits!

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* <details><summary>How does it work?</summary>

	* 🟥 This plugin does not unlock your server special infected limit automatically. Don't install this plugin until other plugins require this plugin
	* Provide API for other plugins to help spawn special infected without the director limits.
	* Admin can type ```!sm_mdzs``` to open menu to spawn special infected without the director limits.
</details>

* Require | 必要安裝
<br/>None

* Related Plugin | 相關插件
	1. [l4d_together](https://github.com/fbef0102/Game-Private_Plugin/tree/main/l4d_together): A simple anti - runner system , punish the runner by spawn SI behind her.
		> 離隊伍太遠的玩家，特感代替月亮懲罰你

* <details><summary>ConVar | 指令</summary>

	None
</details>

* <details><summary>Command | 命令</summary>

	* **Spawn a special infected, bypassing the limit enforced by the game. (ADM required: ADMFLAG_CHEATS)**
		```php
		sm_dzspawn <witch|witch_bride|smoker|boomer|hunter|spitter|jockey|charger|tank|infected> <number> <0:Crosshair, 1:Self Position>
		```

	* **Open a menu to spawn a special infected, bypassing the limit enforced by the game. (ADM required: ADMFLAG_CHEATS)**
		```php
		sm_mdzs
		```
</details>

* <details><summary>API | 串接</summary>

	```c++
	/**
	* @brief 			   Spawn special infected without the director limits!
	*
	* @param zomb          S.I. Name: "tank", "smoker", "hunter", "boomer"," jockey", "charger", "spitter", "witch", "witch_bride"
	* @param vecPos        Vector coordinate where the special will be spawned
	* @param vecAng         QAngle where special will be facing
	*
	* @return              client index of the spawned special infected, -1 if fail to spawn
	*/
	native int NoLimit_CreateInfected(const char[] zomb, const float vecPos[3], const float vecAng[3]);
	```
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2023-10-27)
		* Add inc file

	* v1.2.4 (2023-5-10)
		* Update API

	* v1.2.3 (2023-3-12)
		* Create Native API

	* v1.2.2
		* [Original Plugin by Shadowysn](https://forums.alliedmods.net/showthread.php?t=320849)
</details>

- - - -
# 中文說明
不受數量與遊戲限制生成特感

* 原理
	* 🟥 這插件只是一個輔助插件，不是自動幫你的伺服器解鎖數量與限制，等其他插件需要的時候再安裝此插件
	* 提供API給其他插件生成特感

* <details><summary>命令中文介紹 (點我展開)</summary>

	* **生成特感, 不會受到導演系統限制 (權限: ADMFLAG_CHEATS)**
		```php
		sm_dzspawn <witch|witch_bride|smoker|boomer|hunter|spitter|jockey|charger|tank|infected> <數量> <0:準心指向, 1:自己身上>
		```

	* **打開菜單生成特感, 不會受到導演系統限制 (權限: ADMFLAG_CHEATS)**
		```php
		sm_mdzs
		```
</details>

