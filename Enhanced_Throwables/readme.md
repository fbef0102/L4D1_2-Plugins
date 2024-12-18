# Description | 內容
Adds dynamic Light to held and thrown pipe bombs and molotovs

* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* <details><summary>How does it work?</summary>

	* Add dynamic Light when players hold pipe bombs and molotovs
	* Add dynamic Light to pipe bombs and molotovs which are thrown
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/Enhanced_Throwables.cfg
		```php
		// Enables/Disables handheld pipebomb light.
		l4d_handheld_light_pipe_bomb "1"

		// Pipebomb Max light distance (0 = disabled)
		l4d_handheld_light_pipebomb_light_distance "255.0"

		// Pipebomb flash light color (0-255 0-255 0-255)
		l4d_handheld_light_pipebomb_flash_colour "200 1 1"

		// Pipebomb fure light color (0-255 0-255 0-255)
		l4d_handheld_light_pipebomb_fuse_colour "215 215 1"

		// Enables/Disables Molotov light.
		l4d_handheld_light_Molotov "1"

		// Molotovs light color (0-255 0-255 0-255)
		l4d_handheld_light_molotov_colour "255 50 0"

		// Molotovs light distance (0 = disabled)
		l4d_handheld_light_molotov_light_distance "200.0"

		// Enables/Disables handheld light after throwing.
		l4d_handheld_throw_light_enable "1"
		```
</details>

* <details><summary>Command | 命令</summary>

	None
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2024-12-19)
		* Fixed warnings in sm1.11 or above
		* Fix error: Coach does not have attachment named "weapon_bone"

	* Original
		* [By Lux](https://forums.alliedmods.net/showthread.php?t=281902)
</details>

- - - -
# 中文說明
土製炸彈與火瓶有動態光源特效

* 原理
	* 將土製炸彈或火瓶拿在手上有動態光源
	* 丟出去的土製炸彈或火瓶有動態光源

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/Enhanced_Throwables.cfg
		```php
		// 為1時，土製炸彈有動態光源
		l4d_handheld_light_pipe_bomb "1"

		// 土製炸彈 動態光源範圍 (0 = 不發光)
		l4d_handheld_light_pipebomb_light_distance "255.0"

		// 土製炸彈的閃爍燈 動態光源顏色，填入RGB三色 (三個數值介於0~255，需要空格)
		l4d_handheld_light_pipebomb_flash_colour "200 1 1"

		// 土製炸彈的點火線 動態光源顏色，填入RGB三色 (三個數值介於0~255，需要空格)
		l4d_handheld_light_pipebomb_fuse_colour "215 215 1"

		// 為1時，火瓶有動態光源
		l4d_handheld_light_Molotov "1"

		// 火瓶 動態光源顏色，填入RGB三色 (三個數值介於0~255，需要空格)
		l4d_handheld_light_molotov_colour "255 50 0"

		// 火瓶 動態光源範圍 (0 = 不發光)
		l4d_handheld_light_molotov_light_distance "200.0"

		// 為1時，丟出去的投擲物有動態光源
		l4d_handheld_throw_light_enable "1"
		```
</details>

