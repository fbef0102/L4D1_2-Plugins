# Description | 內容
Show damage done to S.I. by survivors

* Video | 影片展示
<br/>None

* Image | 圖示
	* Display message
        > 顯示傷害統計
        <br/>![l4d2_assist_1](image/l4d2_assist_1.jpg)  

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* Translation Support | 支援翻譯
	```
	English
	繁體中文
	简体中文
	```

* <details><summary>Changelog | 版本日誌</summary>

    * v2.1
        * Translation Support

    * v2.0
        * Remake code

    * v1.6
		* [Original Post by [E]c](https://forums.alliedmods.net/showthread.php?t=123811?t=123811)
</details>

* Require | 必要安裝
	1. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d2_assist.cfg
		```php
        // If 1, Enables this plugin.
        sm_assist_enable "1"

        // Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).
        sm_assist_modes ""

        // Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).
        sm_assist_modes_off ""

        // Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.
        sm_assist_modes_tog "0"

        // If 1, only show damage done to Tank.
        sm_assist_tank_only "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

- - - -
# 中文說明
特感死亡時顯示人類造成的傷害統計

* 原理
	* 記錄人類對特感造成的傷害，當特改死亡時顯示傷害統計
    * Tank死亡時也會有傷害統計

* 功能
	* 可設置在哪些模式能開啟
    * 可設置只打印Tank的傷害統計


