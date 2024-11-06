# Description | 內容
Makes AI Hunter take damage like human SI while pouncing.

* Video | 影片展示
<br/>None

* Image | 圖示
	| Before (裝此插件之前)  			| After (裝此插件之後) |
	| -------------|:-----------------:|
	| ![l4d_ai_hunter_skeet_dmg_fix_1](image/l4d_ai_hunter_skeet_dmg_fix_1.gif)|![l4d_ai_hunter_skeet_dmg_fix_2](image/l4d_ai_hunter_skeet_dmg_fix_2.gif)|

* <details><summary>How does it work?</summary>

	* (Before) Human hunter can be easily killed while pouncing, but AI hunters can't be easily killed while pouncing
		* No skeet mechanics on AI Hunters
	* (After) Makes AI hunters take same damage like human SI while while pouncing
		* Replicate skeet mechanics on AI hunters.
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_ai_hunter_skeet_dmg_fix.cfg
		```php
		// 0=Plugin off, 1=Plugin on.
		l4d_ai_hunter_skeet_dmg_fix_enable "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* <details><summary>API | 串接</summary>

	```php
	library name: l4d_ai_hunter_skeet_dmg_fix
	```
</details>

* <details><summary>Known Conflicts</summary>
	
	If you don't use any of these plugins at all, no need to worry about conflicts.
	1. [l4d2_ai_damagefix](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_ai_damagefix.sp)
		* Removed
</details>

* <details><summary>Related Official ConVar</summary>

	* write down the following cvars in cfg/server.cfg
		```php
		// Taking this much damage interrupts a pounce attempt (default: 150)
		// Taking this much damage while pouncing wiil get you skeeted and die (No matter how much health left you have)
		sm_cvar z_pounce_damage_interrupt "150"
		```
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Related Plugin | 相關插件</summary>

	1. [charging_takedamage_patch](https://github.com/fbef0102/L4D2-Plugins/tree/master/charging_takedamage_patch): Makes AI Charger take damage like human SI while charging.
		* 移除AI Charger的衝鋒減傷
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2024-8-11)
		* Separate functions, remove ai charger
		* Replace SDKHook_OnTakeDamage with SDKHook_OnTakeDamageAlive

	* v1.0
		* [Original plugin from SirPlease/L4D2-Competitive-Rework](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_ai_damagefix.sp)
</details>

- - - -
# 中文說明
對AI Hunter(正在飛撲的途中) 造成的傷害數據跟真人玩家一樣

* 原理
	* (裝插件之前) 真人扮演的Hunter在飛撲的過程中容易被殺死, 但是AI Hunter不容易被殺死
		* 因為官方故意設置傷害機制不同
	* (裝插件之後) 對AI Hunter造成的傷害數據跟真人玩家一樣
		* 所以AI Hunter飛撲的途中容易被殺死

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_ai_hunter_skeet_dmg_fix.cfg
		```php
		// 0=關閉插件, 1=啟動插件
		l4d_ai_hunter_skeet_dmg_fix_enable "1"
		```
</details>

* <details><summary>會衝突的插件</summary>
	
	如果沒安裝以下插件就不需要擔心衝突
	1. [l4d2_ai_damagefix](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_ai_damagefix.sp)
		* 移除
</details>

* <details><summary>相關的官方指令中文介紹 (點我展開)</summary>

	* 以下指令寫入文件 cfg/server.cfg，可自行調整
		```php
		// Hunter 在飛撲途中受傷超過此數值會立刻死亡 (無論你剩餘多少血量都一樣，別問我為捨，此遊戲設計的)
		// 預設: 150
		sm_cvar z_pounce_damage_interrupt "150"
		```
</details>