# Description | 內容
Announces hunter pounces to the entire server, and save record to data/pounce_database.tx

* Video | 影片展示
<br/>None

* Image | 圖示
	* Hunter High Pounce notify and Top 5 pouncers
        > 高撲提示與前五名
	    <br/>![pounce_database_1](image/pounce_database_1.jpg)

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.3 (2023-6-12)
		* Fix out of memory error

	* v1.2
        * Initial Release
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/pounce_database.cfg
        ```php
		// Announces the pounce in chatbox.
		pounce_database_announce "0"

		// Enable this plugin?
		pounce_database_enable "1"

		// The minimum amount of damage required to record the pounce
		pounce_database_minimum "25"

		// Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus. Add numbers together.
		pounce_database_modes_tog "4"

		// Numbers of Survivors required at least to enable this plugin
		pounce_database_survivors_required "4"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Show your current pounce statistics and rank.**
		```php
		sm_pounces
		```

	* **Show TOP 5 pounce players in statistics.**
		```php
		sm_pounce5
		```
</details>

- - - -
# 中文說明
統計高撲的數量與顯示前五名高撲的大佬 (支援文件儲存)

* 原理
	* 當玩家被高撲顯示提示與前五名排名
	* 高撲Bot不會生效
	* 倖存者隊伍有四位以上的真人玩家才會生效
	* 高撲的數量與統計會寫入```data\pounce_database.txt```，因此就算重開服也不會重置統計

* 功能
	* 輸入!pounce5查看前五名高撲的大佬
	* 可開關聊天窗的提示
	* 可調整遊戲模式支援
	* 可調整倖存者隊伍至少需要的真人玩家