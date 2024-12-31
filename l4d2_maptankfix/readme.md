# Description | 內容
Fix issues where customized map tank does not spawn, cause the map process break 

* Apply to | 適用於
	```
	L4D2
	```

* <details><summary>How does it work?</summary>

	* When map tried to spawn custom tank and server slots are full
		* Tank do not spawn correctly, it will break the map process and game stuck
	* For example: Official Map "The Sacrifice stage 1" train tank
		* If all 32 server slots are occupied, the tank won't spawn, and survivors can't open the second train door to continue game
	* Here is how the plugin fixed
		1. When map entity(commentary_zombie_spawner, info_zombie_spawn) tried to spawn trank -> check the server slots
		2. If servers slots are full -> kick a fake infected bot to release the slot -> spawn tank again
		3. If there is no fake infected bot -> try to give real infected player a tank
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>Changelog | 版本日誌</summary>

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
		* 當伺服器32個位子已滿時，Tank無法正確生成，倖存者無法開啟火車第二個門繼續遊戲
	* 此插件如何修輔
		1. 當地圖實體(commentary_zombie_spawner, info_zombie_spawn) 嘗試生成Tank時 -> 檢查伺服器位子
		2. 如果伺服器已滿 -> 踢出一個AI特感騰出位子空間 -> 再次生成Tank
		3. 如果沒有AI特感 -> 嘗試給一位真人特感扮演Tank