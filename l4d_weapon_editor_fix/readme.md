# Description | 內容
Fix some Weapon attribute not exactly obey keyvalue in weapon_*.txt

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [WeaponHandling_API](https://forums.alliedmods.net/showthread.php?t=319947)

* <details><summary>Support | 支援插件</summary>

	* [l4d_info_editor](https://forums.alliedmods.net/showthread.php?t=310586): Modify weapons.txt values by config
		* 修改武器的參數
	* [Incapped Weapons Patch](https://forums.alliedmods.net/showthread.php?t=322859): allow using melee while Incapped
		* 可以在倒地狀態下使用主武器與近戰
</details>

* <details><summary>How does it work?</summary>

	* Fix some Weapon attribute not exactly obey keyvalue in weapon_*.txt
	* Weapons
		* Fire Rate (Standing)
			* Dual pistol, shotguns obey "CycleTime" keyvalue in weapon_*.txt
		* Fire Rate (Incap) 
			* If weapon_*.txt "CycleTime" slower than official cvar "survivor_incapacitated_cycle_time", ignores the cvar and uses weapon "CycleTime" for incap shooting cycle rate
			* If weapon_*.txt "CycleTime" faster than official cvar "survivor_incapacitated_cycle_time", use "survivor_incapacitated_cycle_time" for incap shooting cycle rate
		* Reload Duration
			* Dual pistol, shotguns obey "ReloadDuration" keyvalue in weapon_*.txt
	* Melee
		* Swing Rate (Standing)
			* All Melee weapons including custom melee obey "refire_delay" keyvalue in melee\*.txt
		* Swing Rate (Incap) 
			* Modify melee swinging rate multi when incapacitate
</details>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_weapon_editor_fix.cfg
		```php
		// 0=Plugin off, 1=Plugin on.
		l4d_weapon_editor_fix_enable "1"

		// The dual pistol Cycle Time (fire rate, 0: keeps vanilla cycle rate of 0.075)
		l4d_weapon_editor_fix_dual_pistol_CycleTime "0.1"

		// The dual pistol Reload Duration (0: keeps vanilla reload duration of 2.333)
		l4d_weapon_editor_fix_dual_pistol_ReloadDuration "0"

		// If 1, Make shotgun fire rate obey "CycleTime" keyvalue in weapon_*.txt
		l4d_weapon_editor_fix_shotgun_fire_rate "1"

		// If 1, Make shotgun reload duration obey "ReloadDuration" keyvalue in weapon_*.txt
		l4d_weapon_editor_fix_shotgun_reload "1"

		// If 1, Use weapon_*.txt "CycleTime" or official cvar "survivor_incapacitated_cycle_time" for incap shooting cycle rate, depends on which cycle rate is slower than another
		// ("wh_use_incap_cycle_cvar" must be 1)
		l4d_weapon_editor_fix_incap_fire_rate "1"

		// If 1, Make melee swing rate obey "refire_delay" keyvalue in melee\*.txt
		l4d_weapon_editor_fix_melee_swing "1"

		// 0=Unchanged, Modify melee swinging rate multi when incapacitated, (ex. Use 'Incapped Weapons Patch by Silvers' to allow using melee while Incapped)
		l4d_weapon_editor_fix_melee_swing_incap_multi "1.3"
		```
</details>

* <details><summary>Known Conflicts</summary>
	
	If you don't use any of these plugins at all, no need to worry about conflicts.
	1. [l4d2_pistol_delay from SirPlease/L4D2-Competitive-Rework](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_pistol_delay.sp): Allows you to adjust the rate of fire of pistols (with a high tickrate, the rate of fire of dual pistols is very high).
		* Please Remove
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.3 (2025-5-10)
		* Fixed Shotgun fire rate when incap

	* v1.2 (2024-6-25)
		* Fixed Reload playback when shove

	* v1.1 (2024-3-7)
		* Update cvars
		* Delete function: pistol obey "CycleTime" keyvalue

	* v1.0 (2024-2-17)
		* Initial Release
</details>

- - - -
# 中文說明
修復一些武器的 weapon_*.txt 參數沒有作用

* 原理
	* 修復官方文件內的某些武器參數，即使修改了數值依然沒有作用

* <details><summary>修補內容</summary>

	* 槍械武器
		* 射速
			* 雙手槍、散彈槍符合武器參數 "CycleTime"
		* 倒地射速
			* 修復部分武器倒地射速比站立時的射速還快
		* 裝彈時間
			* 雙手槍、散彈槍符合武器參數 "ReloadDuration"
	* 近戰武器
		* 揮砍速度
			* 所有近戰符合武器參數 "refire_delay" (支援三方圖近戰)
		* 倒地揮砍速度
			* 倒地使用近戰，揮砍速度變更慢
</details>

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_weapon_editor_fix.cfg
		```php
		// 0=關閉插件, 1=啟動插件
		l4d_weapon_editor_fix_enable "1"

		// 設置雙手槍的開槍間隔 (射速, 0: 維持遊戲預設的0.075秒)
		l4d_weapon_editor_fix_dual_pistol_CycleTime "0.1"

		// 設置雙手槍的裝彈時間 (0: 維持遊戲預設的2.333秒)
		l4d_weapon_editor_fix_dual_pistol_ReloadDuration "0"

		// 為1時，散彈槍的開槍間隔強制符合 weapon_*.txt 的武器參數"CycleTime"
		l4d_weapon_editor_fix_shotgun_fire_rate "1"

		// 為1時，散彈槍的裝彈時間強制符合 weapon_*.txt 的武器參數"ReloadDuration"
		l4d_weapon_editor_fix_shotgun_reload "1"

		// 為1時，倒地狀態下的開槍間隔使用 weapon_*.txt 的武器參數"CycleTime" 或是官方指令 "survivor_incapacitated_cycle_time"，取決於哪一種數值比較大
		// (WeaponHandling_API的插件指令 "wh_use_incap_cycle_cvar" 必須為1)
		l4d_weapon_editor_fix_incap_fire_rate "1"

		// 為1時，近戰武器的揮砍間隔強制符合 melee\*.txt 的武器參數"refire_delay"
		l4d_weapon_editor_fix_melee_swing "1"

		// 倒地狀態下，近戰武器的揮砍間隔 0=不變, >0: 調整砍速 (使用Silvers的Incapped Weapons Patch插件，可以在倒地狀態下使用近戰)
		l4d_weapon_editor_fix_melee_swing_incap_multi "1.3"
		```
</details>

* <details><summary>會衝突的插件</summary>
	
	如果沒安裝以下插件就不需要擔心衝突
	1. [l4d2_pistol_delay from SirPlease/L4D2-Competitive-Rework](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_pistol_delay.sp): 修復手槍在高tickrate下的射速
		* 請移除
</details>


