# Description | 內容
When a survivor die, on his body appear a grave.

* [Video | 影片展示](https://youtu.be/Pmx64P665rQ)

* Image | 圖示
	<br/>![l4d_graves_1](image/l4d_graves_1.gif)

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg\sourcemod\l4d_graves.cfg
		```php
        // Enable or disable this plugin.
        l4d_graves_enable "1"

        // 1=Disables the solidity of the grave, 0=Enable solidity
        l4d_graves_not_solid "1"

        // How long will it take for the grave to spawn.
        l4d_graves_delay "5.0"

        // Turn glow On or Off.
        l4d_graves_glow "1"

        // L4D2 Only, RGB Color - Change the render color of the glow. Values between 0-255. [-1 -1 -1: Random]
        l4d_graves_glow_color "255 255 255"

        // L4D2 Only, Change the glow range. 
        l4d_graves_glow_range "4000"

        // Number of points of damage to take before breaking. (In L4D2, 0 means don't break)
        l4d_graves_health "1500"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>Related Plugin | 相關插件</summary>

	1. [l4d_death_soul](/l4d_death_soul): Soul of the dead survivor flies away to the afterlife
		> 人類死亡後，靈魂升天
</details>

* <details><summary>Changelog | 版本日誌</summary>

	```php
	//Dartz8901 @ 2018
	//HarryPotter @ 2022-2023
	```
	* v1.0h (2023-7-27)
        * [AlliedModders Post](https://forums.alliedmods.net/showpost.php?p=2771370&postcount=24)
        * Remake Code
        * Random Color
        * Glow Range
        * Safely remvoe grave when player changes team or leaves the game

	* v1.1.1
        * [Original Plugin by Dartz8901](https://forums.alliedmods.net/showthread.php?t=313063)
</details>

- - - -
# 中文說明
為人類屍體造一個墓碑以做紀念

* 原理
    * 死亡之後，在屍體上造一個墓碑
	* 電擊器救活之後，墓碑消失
	* 墓碑不會擋路

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg\sourcemod\l4d_graves.cfg
		```php
        // 0=關閉插件, 1=啟動插件
        l4d_graves_enable "1"

        // 1=墓碑穿透, 0=墓碑不能穿透，必須打掉
        l4d_graves_not_solid "1"

        // 死王五秒後才獲出現墓碑
        l4d_graves_delay "5.0"

        // 為1時，墓碑會發光
        l4d_graves_glow "1"

        // (L4D2) 墓碑的發光顏色，填入RGB三色 (三個數值介於0~255，需要空格)
        l4d_graves_glow_color "255 255 255"

        // (L4D2) 墓碑的發光範圍
        l4d_graves_glow_range "4000"

        // 如果墓碑不能穿透，墓碑的血量是多少? 打掉才會破掉
        // L4D2，0=永遠不會破掉
        l4d_graves_health "1500"
		```
</details>
