# Description | 內容
Hunter high pounces cause meteor strike

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* Image | 圖示
	* Meteor strike, inflict extra damage and send nearby survivors flying. (高撲的核彈衝擊波)
	<br/>![l4d_meteor_hunter_1](image/l4d_meteor_hunter_1.gif)

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_meteor_hunter.cfg
		```php
        // 0=Plugin off, 1=Plugin on.
        l4d_meteor_hunter_allow "1"

        // Damage caused by meteor strike.
        l4d_meteor_hunter_damage "15.0"

        // Hunter Pounce Distance needed to trigger meteor strike.
        l4d_meteor_hunter_distance "800"

        // Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).
        l4d_meteor_hunter_modes ""

        // Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).
        l4d_meteor_hunter_modes_off ""

        // Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.
        l4d_meteor_hunter_modes_tog "0"

        // How much force is applied to the survivor (meteor strike).
        l4d_meteor_hunter_power "300"

        // Hunter meteor strike range.
        l4d_meteor_hunter_range "200"

        // Vertical force multiplier (meteor strike).
        l4d_meteor_hunter_vertical_mult "1.5"
		```
</details>

* <details><summary>Related Plugin | 相關插件</summary>

	1. [pounceannounce](/pounceannounce): Announces hunter pounces to the entire server
		> 顯示Hunter造成的高撲傷害與高撲距離
	2. [l4d_hunter_destructive](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Hunter_Hunter/l4d_hunter_destructive): Allows for unique Hunter abilities to the destructive beast.
		> 增強Hunter，賦予多種超能力成為毀滅性的野獸
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.5 (2023-3-24)
		* Remake code, convert code to latest syntax
		* Fix warnings when compiling on SourceMod 1.11.
		* Optimize code and improve performance
        * Replace Gamedata with left4dhooks
		* Add Convars

	* v1.5
		* [Original Plugin by rekcah](https://forums.alliedmods.net/showthread.php?p=2712447)
</details>

- - - -
# 中文說明
Hunter的高撲造成核彈衝擊波

* 原理
	* AI Hunter或者真人Hunter的高撲如果超過一定高度，則造成核彈衝擊波
        * 給予周圍玩家額外傷害
        * 震飛周圍玩家

* 功能
    * 可設置核彈衝擊範圍與額外傷害
    * 可設置衝擊力道
    * 可設置觸發核彈衝擊的高撲距離門檻