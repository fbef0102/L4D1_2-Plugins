# Description | 內容
Allows players to drop the weapon they are holding

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* <details><summary>How does it work?</summary>

	* Type ```!drop``` to drop your guns or items
	* Apply to pistol, melee, M60...
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\l4d_drop.cfg
		```php
		// Prevent players from dropping their secondaries? (Fixes bugs that can come with incapped weapons or A-Posing.)
		sm_drop_block_secondary "0"

		// Prevent players from dropping objects in between actions? (Fixes throwable cloning.) 1 = All weapons. 2 = Only throwables.
		sm_drop_block_mid_action "1"

		// Prevent players from dropping the M60? (Allows for better compatibility with certain plugins.)
		sm_drop_block_m60 "0"

		// (L4D2) Drop - sound file (relative to to sound/, empty=disable)
		sm_drop_soundfile "ui/gift_pickup.wav"

		// (L4D1) Drop - sound file (relative to to sound/, empty=disable)
		sm_drop_soundfile "items/itempickup.wav"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Drop weapon**
		```php
		sm_drop
		sm_g
		```
</details>

* <details><summary>API | 串接</summary>

	* [l4d_drop.inc](scripting\include\l4d_drop.inc)
		```php
		library name: l4d_drop
		```
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Related Plugin | 相關插件</summary>

	1. [drop_secondary](https://github.com/fbef0102/L4D2-Plugins/tree/master/drop_secondary): Survivor players will drop their secondary weapon (including melee) when they die
		> 死亡時掉落第二把武器
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.12 (2023-1-7)
		* Add Drop Sound
		* Add Cvars

	* v1.11 (2023-10-28)
		* Optimize code and improve performance
		* Add inc file

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

- - - -
# 中文說明
玩家可自行丟棄手中的武器

* 原理
	* 輸入```!drop```掉落手上的武器
	* 可掉雙手槍

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg\sourcemod\l4d_drop.cfg
		```php
		// 為1時，禁止丟棄副武器 (避免玩家手上空空如也)
		sm_drop_block_secondary "0"

		// 為1時，所有武器在裝彈、切換、開槍、投擲....時禁止丟棄
		// 為2時，只有投擲物品禁止丟棄
		sm_drop_block_mid_action "1"

		// 為1時，禁止丟棄M60 (搭配其他有使用M60相關的插件)
		sm_drop_block_m60 "0"

		// (L4D2) 丟棄武器的音效檔案 (路徑相對於 sound 資料夾, 空=無音效)
		sm_drop_soundfile "ui/gift_pickup.wav"

		// (L4D1) 丟棄武器的音效檔案 (路徑相對於 sound 資料夾, 空=無音效)
		sm_drop_soundfile "items/itempickup.wav"
		```
</details>

* <details><summary>命令中文介紹 (點我展開)</summary>

	* **丟棄手中的武器**
		```php
		sm_drop
		sm_g
		```
</details>