# Description | 內容
Makes AI Charger take damage like human SI while charging.

* Apply to | 適用於
	```
	L4D2
	```

* Image | 圖示
	| Before (裝此插件之前)  			| After (裝此插件之後) |
	| -------------|:-----------------:|
	| ![charging_takedamage_patch_1](image/charging_takedamage_patch_1.gif)|![charging_takedamage_patch_2](image/charging_takedamage_patch_2.gif)|

* <details><summary>How does it work?</summary>

	* (Before) Human chargers can be easily killed while charging, but AI chargers can't be easily killed while charging
		* Damage nerf on charging AI chargers
		* Formua: (Original damage / 3) + 1 = actual damage
	* (After) Makes AI chargers take same damage like human SI while charging
		* Remove formua, Make them easily to be killed and melee-leveled
</details>

* Require | 必要安裝
	1. [sourcescramble](https://github.com/nosoop/SMExt-SourceScramble/releases)

* <details><summary>API | 串接</summary>

	```php
	library name: charging_takedamage_patch
	```
</details>

* <details><summary>Known Conflicts</summary>
	
	If you don't use any of these plugins at all, no need to worry about conflicts.
	1. [l4d2_ai_damagefix](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_ai_damagefix.sp)
		* Removed
</details>

* <details><summary>Related Plugin | 相關插件</summary>

	1. [l4d_ai_hunter_skeet_dmg_fix](/l4d_ai_hunter_skeet_dmg_fix): Makes AI Hunter take damage like human SI while pouncing.
		* 對AI Hunter(正在飛撲的途中) 造成的傷害數據跟真人玩家一樣
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2024-8-11)
		* Make script for people who don't know to how install, nothing changed

	* v1.0
		* [Original plugin by umlka](https://github.com/umlka/l4d2/tree/main/charging_takedamage_patch)
</details>

- - - -
# 中文說明
移除AI Charger的衝鋒減傷

* 原理
	* (裝插件之前) 真人扮演的Charger在衝鋒過程中容易被殺死, 但是AI Charger不容易被殺死
		* 因為官方故意設置傷害機制不同
	* (裝插件之後) AI Charger造成的傷害數據跟真人玩家一樣
		* 所以AI Charger衝鋒時容易被殺死或砍死

* <details><summary>會衝突的插件</summary>
	
	如果沒安裝以下插件就不需要擔心衝突
	1. [l4d2_ai_damagefix](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_ai_damagefix.sp)
		* 移除
</details>