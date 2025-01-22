# Description | 內容
Survivor players will drop their secondary weapon (including melee) when they die

* Apply to | 適用於
	```
	L4D2
	```

* <details><summary>How does it work?</summary>

	* When you die, drop your secondary weapon
		* Pistol and Dual pistol
		* Magnum
		* Melee weapons
		* Chainsaw
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>Changelog | 版本日誌</summary>

	* v2.6 (2024-1-16)
		* Remake code
		* Clear hidden weapon data for player

	* v2.5 (2022-12-18)
		* Delete l4d_info_editor, too frequently call forward function from l4d_info_editor (every 20~30 seconds)

	* v2.4 (2022-12-7)
		* Use other method to get the melee weapon

	* v2.3 (2022-10-7)
		* Convert All codes to new syntax.
		* Support Custom Melee
		* Create Fake Event "weapon_drop" when drop secondary weapon on death

	* v1.6
		* [Original Plugin by PVNDV](https://forums.alliedmods.net/showthread.php?t=283713)
</details>

* <details><summary>Related Plugin | 相關插件</summary>

	1. [l4d_drop](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d_drop): Allows players to drop the weapon they are holding
		> 玩家可自行丟棄手中的武器
</details>

- - - -
# 中文說明
死亡時掉落第二把武器

* 原理
	* 死亡時掉落手上裝備的第二把武器，譬如手槍、近戰武器、麥格農手槍、電鋸
	* 可掉雙手槍
	* 可掉三方圖自製近戰武器
