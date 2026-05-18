# Description | 內容
Individually control each weapons's reserve ammo

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* Image | 圖示
<br/>![l4d_reserve_ammo_control_1](image/l4d_reserve_ammo_control_1.jpg)

* <details><summary>How does it work?</summary>

	* Individually control weapon reserve independent of "ammo_*" cvars in data: [data/l4d_reserve_ammo_control.cfg](data/l4d_reserve_ammo_control.cfg)
		* Manual in this file, click for more details...
	* Can refill with ammo pile (except for M60 and Grenade Launcher)
</details>

* Require | 必要安裝
	1. [l4d_transition_entity](/https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_transition_entity)
	2. [l4d_save_weapon_ammo](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d_save_weapon_ammo)

* <details><summary>ConVar | 指令</summary>

    * No available cfg and cvars
</details>

* <details><summary>Command | 命令</summary>
    
    * **Reload the reserve ammo data (Access: ADMFLAG_ROOT)**
        ```php
        sm_reserve_ammo_reload
        ```
</details>

* <details><summary>Related Official ConVar</summary>

	* This plugin controls each weapons's reserve ammo, you don't need to change the following cvars
	* L4D1
		| ConVar/Command  				| Parameters or default value 	| Descriptor  			| Effect|
		| -------------|:-----------------:|:-------------:|:-------------:|
		| ammo_assaultrifle_max 	| 360  | count | Rifle weapon max ammo |
		| ammo_buckshot_max      | 128  | count | Pump shotgun and Auto shotgun max ammo |
		| ammo_huntingrifle_max      | 150  | count | Hunting Rifle max ammo |
		| ammo_smg_max      | 480  | count | SMG max ammo |

	* L4D2
		| ConVar/Command  				| Parameters or default value 	| Descriptor  			| Effect|
		| -------------|:-----------------:|:-------------:|:-------------:|
		| ammo_assaultrifle_max 	| 360  | count | Rifle, AK47, Desert rifle, SG552 max ammo |
		| ammo_autoshotgun_max      | 90  | count | Spas shotgun, Auto shotgun max ammo |
		| ammo_grenadelauncher_max  | 30  | count | Grenade Launcher max ammo |
		| ammo_huntingrifle_max  	| 150  | count | Hunting Rifle max ammo |
		| ammo_m60_max  			| 0  | count | M60 max ammo |
		| ammo_shotgun_max  		| 72  | count | Pump shotgun, chrome shotgun max ammo |
		| ammo_smg_max      		| 650  | count | SMG max ammo |
		| ammo_sniperrifle_max  	| 180  | count | Sniper Rifle, Scout, AWP max ammo |
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.1h (2026-5-18)
		* Fixed ammo is not corrent if weapon created by other plugins

	* v1.0h (2026-5-16)
		* Remake code
		* Fix error: client not in game
		* Fix issue when ammo is not corrent when using "give" command and map transition
		* Use new detour to improve performance

	* Credit & Original
		* [Orinuse for original plugin](https://forums.alliedmods.net/showthread.php?t=334274): Reserve (Ammo) Control
		* [Psykotikism for signatures](https://github.com/Psykotikism/L4D1-2_Signatures/blob/main/l4d1/gamedata/l4d1_signatures.txt)
		* [blueblur0730 for better new detour](https://github.com/blueblur0730/modified-plugins/tree/main/source/l4d2_max_ammo): l4d2_max_ammo
</details>

- - - -
# 中文說明
控制每一種武器的後備彈藥數量 (手槍除外)

* 原理
	* 在data文件設置每一種主武器可攜帶的最大後備彈藥數量: [data/l4d_reserve_ammo_control.cfg](data/l4d_reserve_ammo_control.cfg)
		* 內有中文說明，可點擊查看
	* 可以透過彈藥堆補充子彈 (M60與榴彈發射器除外)
	* 這個插件會覆蓋官方指令所設置的彈藥數量 ```ammo_*```

* <details><summary>指令中文介紹 (點我展開)</summary>

    * 此插件沒有可用的cfg與cvars
</details>

* <details><summary>命令中文介紹 (點我展開)</summary>
    
    * **重新載入data文件 (權限: ADMFLAG_ROOT)**
        ```php
        sm_reserve_ammo_reload
        ```
</details>

* <details><summary>相關的官方指令中文介紹 (點我展開)</summary>

	* 這個插件已經接管所有武器的彈藥數量，你無須更動以下任何指令
	* L4D1
		| 指令  				| 預設值 	| 單位  			| 影響|
		| -------------|:-----------------:|:-------------:|:-------------:|
		| ammo_assaultrifle_max 	| 360  | 數量 | 步槍的最大彈藥 |
		| ammo_buckshot_max      | 128  | 數量 | 單發散彈槍與連發散彈槍的最大彈藥 |
		| ammo_huntingrifle_max      | 150  | 數量 | 獵槍的最大彈藥 |
		| ammo_smg_max      | 480  | 數量 | 機槍的最大彈藥 |

	* L4D2
		| 指令  				| 預設值 	| 單位  			| 影響|
		| -------------|:-----------------:|:-------------:|:-------------:|
		| ammo_assaultrifle_max 	| 360  | 數量 | 步槍的最大彈藥 |
		| ammo_autoshotgun_max      | 90  | 數量 | 自動連發散彈槍的最大彈藥 |
		| ammo_grenadelauncher_max  | 30  | 數量 | 榴彈發射器的最大彈藥 |
		| ammo_huntingrifle_max  	| 150  | 數量 | 獵槍的最大彈藥 |
		| ammo_m60_max  			| 0  | 數量 | M60的最大彈藥 |
		| ammo_shotgun_max  		| 72  | 數量 | 單發散彈槍的最大彈藥 |
		| ammo_smg_max  			| 650  | 數量 | 機槍的最大彈藥 |
		| ammo_sniperrifle_max  	| 180  | 數量 | 狙擊槍的最大彈藥 |
</details>

