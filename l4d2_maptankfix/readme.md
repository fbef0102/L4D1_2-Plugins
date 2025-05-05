# Description | 內容
Fix issues where customized map tank does not spawn, cause the map process break 

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>How does it work?</summary>

	* When map tried to spawn custom tank and server slots are full
		* Tank do not spawn correctly, it will break the map process and game stuck
	* For example: Official Map "The Sacrifice stage 1" train tank
		* (L4D2) If all 31 server slots are occupied, the tank won't spawn, and survivors can't open the second train door to continue game
			* server slots = maxplayers
		* (L4D1) If all infected team slots are occupied, the tank won't spawn, and survivors can't open the second train door to continue game
			* infecte team slot = z_max_player_zombies+1
	* Here is how the plugin fixed
		1. When map entity tried to spawn trank -> check if tank spawns successfully
			* commentary_zombie_spawner
			* info_zombie_spawn
		2. If the tank not exist -> kick a fake infected bot to release the slot -> spawn tank again
		3. If there is no fake infected bot -> try to give real infected player a tank
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [spawn_infected_nolimit](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/spawn_infected_nolimit)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d2_maptankfix.cfg
		```php
		// 0=Plugin off, 1=Plugin on.
		l4d2_maptankfix_enable "1"
		```
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.5 (2025-2-13)
	* v1.4 (2025-2-9)
	* v1.3 (2025-2-7)
		* Fixed error
		* Support L4D1
		* Update gamedata

	* v1.2 (2024-12-30)
		* Improve code
		* Find real infected player and give tank

	* v1.1
		* [Original Plugin by 洛琪 central_lq](https://forums.alliedmods.net/showthread.php?t=349834)
</details>

- - - -
# 中文說明
防止地圖自帶的機關Tank因為人數不夠問題​​無法刷新而造成卡關

* 原理
	* 當伺服器滿位且地圖自帶的機關嘗試生成Tank時
		* Tank無法正確生成，導致遊戲無法繼續
	* 舉例: 官方圖 "犧牲第一關" 火車Tank
		* (L4D2) 當伺服器31個位子已滿時，Tank無法正確生成，倖存者無法開啟火車第二個門繼續遊戲
			* 伺服器位子 = maxplayers
		* (L4D1) 特感隊伍位子已滿，Tank無法正確生成，倖存者無法開啟火車第二個門繼續遊戲
			* 特感隊伍位子 = z_max_player_zombies+1
	* 此插件如何修輔
		1. 當地圖實體嘗試生成Tank時 -> 檢查Tank是否已生成成功
			* commentary_zombie_spawner
			* info_zombie_spawn
		2. 如果沒有Tank -> 踢出一個AI特感騰出位子空間 -> 再次生成Tank
		3. 如果沒有AI特感 -> 嘗試給一位真人特感扮演Tank

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d2_maptankfix.cfg
		```php
		// 是否开启tank修复. 1=开启，0=关闭.
		l4d2_maptankfix_enable "1"
		```
</details>