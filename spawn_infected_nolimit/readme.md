# Description | 內容
Spawn special infected without the director limits!

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.2.3 (2023-3-12)
		* Create Native api

	* v1.2.2
		* [Original Plugin by Shadowysn](https://forums.alliedmods.net/showthread.php?t=320849)
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
		sm_dzspawn <zombie> <mode> <number>
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
	* @param zomb          S.I. Name: "tank", "witch", "smoker", "hunter", "boomer"," jockey", "charger", "spitter" 
	* @param pos_1         Vector coordinate where special will be spawned
	* @param pos_2         Vector coordinate where special will be spawned
	* @param pos_3         Vector coordinate where special will be spawned
	* @param ang_1         QAngle where special will be facing
	* @param ang_2         QAngle where special will be facing
	* @param ang_3         QAngle where special will be facing
	*
	* @return              nothing
	*/
	native void NoLimit_CreateInfected(const char[] zomb, float pos_1, float pos_2, float pos_3, float ang_1, float ang_2, float ang_3);
	```
</details>

- - - -
# 中文說明
不受數量與遊戲限制生成特感

* 原理
	* 這插件只是一個輔助插件，等其他插件需要的時候再安裝

* 功能
	* 可以打命令!sm_mdzs出現介面選單，手動生成特感
	* 不會受到導演系統限制

