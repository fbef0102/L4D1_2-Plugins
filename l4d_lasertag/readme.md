# Description | 內容
Shows a laser for straight-flying fired projectiles

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* [Video | 影片展示](https://youtu.be/JnBM7GyYdGI)

* Image | 圖示
	* Laser when player shoots (子彈光線)
    <br/>![l4d_lasertag_1](image/l4d_lasertag_1.jpg)

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_lasertag.cfg
		```php
		// Turnon Lasertagging. 0=disable, 1=enable
		l4d_lasertag_enable "1"

		// Enable or Disable Lasertagging in Versus / Scavenge. 0=disable, 1=enable
		l4d_lasertag_vs "1"

		// Enable or Disable Lasertagging in Coop / Realism. 0=disable, 1=enable
		l4d_lasertag_coop "1"

		// Enable or Disable lasertagging for bots. 0=disable, 1=enable
		l4d_lasertag_bots "1"

		// LaserTagging for Pistols. 0=disable, 1=enable
		l4d_lasertag_pistols "1"

		// LaserTagging for Rifles. 0=disable, 1=enable
		l4d_lasertag_rifles "1"

		// LaserTagging for Sniper Rifles. 0=disable, 1=enable
		l4d_lasertag_snipers "1"

		// LaserTagging for SMGs. 0=disable, 1=enable
		l4d_lasertag_smgs "1"

		// LaserTagging for Shotguns. 0=disable, 1=enable
		l4d_lasertag_shotguns "1"

		// If 1, Enable Random Color.
		l4d_lasertag_random "1"

		// Lasertagging Color. Three values between 0-255 separated by spaces. RGB: Red Green Blue.
		l4d_lasertag_rgb "0 125 255"

		// Transparency (Alpha) of Laser
		l4d_lasertag_alpha "100"

		// If 1, Enable Random Color for Bot.
		l4d_lasertag_bots_random "1"

		// Bots Laser - Color. Three values between 0-255 separated by spaces. RGB: Red Green Blue.
		l4d_lasertag_bots_rgb "0 255 75"

		// Bots Laser - Transparency (Alpha) of Laser
		l4d_lasertag_bots_alpha "70"

		// Seconds Laser will remain
		l4d_lasertag_life "0.80"

		// Width of Laser
		l4d_lasertag_width "1.0"

		// Lasertag Offset
		l4d_lasertag_offset "36"

		// Players with these flags have Lasertagging. (Empty = Everyone, -1: Nobody)
		l4d_lasertag_access_flag ""
		```
</details>

* <details><summary>Related Plugin | 相關插件</summary>

	1. [l4d_dynamic_muzzle_flash](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Real_Realism_%E7%9C%9F%E5%AF%AB%E5%AF%A6%E6%A8%A1%E5%BC%8F/l4d_dynamic_muzzle_flash): Adds dynamic muzzle flash to gunfire
    	* 槍口增加逼真的閃光
</details>

* <details><summary>Changelog | 版本日誌</summary>

	```php
	//Whosat @ 2010-2011
	//HarryPotter @ 2022-2024
	```
	* v1.0 (2024-1-20)
		* Optimize code and improve performance
		* Update Cvars

	* v0.3 (2022-12-5)
        * Remake Code
		* Add Cvars to enable random colors
		* Support [Ready up plugin](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Server_%E4%BC%BA%E6%9C%8D%E5%99%A8/readyup), enable laser tag during ready-up

	* v0.2 (2021-8-29)
        * [Original Plugin by Whosat](https://forums.alliedmods.net/showthread.php?t=129050)
</details>

- - - -
# 中文說明
開槍會有子彈光線

* 原理
    * 開槍會有光線軌跡
	* 地圖上的機槍砲台不會有光線
	* 榴彈發射器不會有光線

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_lasertag.cfg
		```php
		// 0=關閉插件, 1=啟動插件
		l4d_lasertag_enable "1"

		// (對抗 / 清道夫模式) 0=關閉插件, 1=啟動插件
		l4d_lasertag_vs "1"

		// (戰役 / 寫實模式) 0=關閉插件, 1=啟動插件
		l4d_lasertag_coop "1"

		// 為1時，Bot開槍也會有光線軌跡
		l4d_lasertag_bots "1"

		// 為1時，手槍武器有光線軌跡
		l4d_lasertag_pistols "1"

		// 為1時，步槍武器有光線軌跡
		l4d_lasertag_rifles "1"

		// 為1時，狙擊槍武器有光線軌跡
		l4d_lasertag_snipers "1"

		// 為1時，機槍武器有光線軌跡
		l4d_lasertag_smgs "1"

		// 為1時，散彈槍武器有光線軌跡
		l4d_lasertag_shotguns "1"

		// 為1時，光線軌跡是隨機的顏色
		l4d_lasertag_random "1"

		// 如果光線軌跡不是隨機的顏色，則設置顏色，填入RGB三色 (三個數值介於0~255，需要空格)
		l4d_lasertag_rgb "0 125 255"

		// 光線軌跡透明度
		l4d_lasertag_alpha "100"

		// 為1時，Bot開槍的光線軌跡是隨機的顏色
		l4d_lasertag_bots_random "1"

		// 如果Bot開槍的光線軌跡不是隨機的顏色，則設置顏色，填入RGB三色 (三個數值介於0~255，需要空格)
		l4d_lasertag_bots_rgb "0 255 75"

		// Bot開槍的光線軌跡透明度
		l4d_lasertag_bots_alpha "70"

		// 光線軌跡停留時間
		l4d_lasertag_life "0.80"

		// 光線軌跡寬度
		l4d_lasertag_width "1.0"

		// 光線軌跡與槍口的距離
		l4d_lasertag_offset "36"

		// 擁有這些權限的玩家，才有光線軌跡 (留白 = 任何人都能, -1: 無人)
		l4d_lasertag_access_flag ""
		```
</details>