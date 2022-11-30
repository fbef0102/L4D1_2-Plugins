
# Description | 內容
Allows players to drop the weapon they are holding

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

	* v1.10 (2022-12-1)
		* Add OnWeaponDrop API, thanks to NoroHime. Called whenever weapon prepared to drop by this plugin.

	* v1.9
		* Can't drop weapons when survivor is hanging from ledge, incapacitated, or pinned by infected attacker
		* Drop single pistol instead of dual pistols

	* v1.7
		* [Shadowysn's fork](https://forums.alliedmods.net/showpost.php?p=2763385&postcount=90)

	* 1.5
		* [Original Plugin by Machine](https://forums.alliedmods.net/showthread.php?t=123098)
</details>

* Require | 必要安裝
<br/>None

* Related Plugin | 相關插件
	1. [drop_secondary](https://github.com/fbef0102/L4D2-Plugins/tree/master/drop_secondary): Survivor players will drop their secondary weapon (including melee) when they die
	    > 死亡時掉落第二把武器

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\l4d_drop.cfg
		```php
		// Prevent players from dropping the M60? (Allows for better compatibility with certain plugins.)
		sm_drop_block_m60 "0"

		// Prevent players from dropping objects in between actions? (Fixes throwable cloning.) 1 = All weapons. 2 = Only throwables.
		sm_drop_block_mid_action "1"

		// Prevent players from dropping their secondaries? (Fixes bugs that can come with incapped weapons or A-Posing.)
		sm_drop_block_secondary "0"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Drop weapon**
		```php
		sm_drop
		sm_g
		```
</details>

- - - -
# 中文說明
玩家可自行丟棄手中的武器

* 原理
    * 輸入!drop掉落手上的武器
    * 可掉雙手槍

* 功能
    * 可禁止丟棄M60，因為有些插件會修改M60
    * 可禁止丟棄第二把武器，避免玩家手上空空如也
	* 可禁止切換武器動畫或是投擲物品時候禁止丟棄，避免無限手榴彈問題