# Description | 內容
Adjustable melee swing rate for each melee weapon.

* Apply to | 適用於
    ```
    L4D2
    ```

* Image | 圖示
	<br/>![l4d2_melee_swing_1](image/l4d2_melee_swing_1.gif)

* Require | 必要安裝
 <br/>None

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d2_melee_swing.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        l4d2_melee_swing_allow "1"

        // 0=Value Default, The interval for swinging Baseball Bat. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_baseball_bat_rate "0.75"

        // 0=Value Default, The interval for swinging Cricket Bat.(clamped between 0.2 and 1.0)
        l4d2_melee_swing_cricket_bat_rate "0.8"

        // 0=Value Default, The interval for swinging Crowbar. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_crowbar_rate "0.8"

        // 0=Value Default, The interval for swinging Electric Guitar.(clamped between 0.2 and 1.0)
        l4d2_melee_swing_electric_guitar_rate "1.0"

        // 0=Value Default, The interval for swinging Fire Axe. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_fireaxe_rate "1.0"

        // 0=Value Default, The interval for swinging Frying Pan. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_frying_pan_rate "0.75"

        // 0=Value Default, The interval for swinging Golf Club. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_golfclub_rate "0.75"

        // 0=Value Default, 1=Each melee rate unchanged, modify melee swinging rate multi when incapacitated. (ex. Use 'Incapped Weapons Patch by Silvers' to allow using Weapons while Incapped)
        l4d2_melee_swing_incapacitated_multi_rate "2.0"

        // 0=Value Default, The interval for swinging Katana. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_katana_rate "0.8"

        // 0=Value Default, The interval for swinging Knife. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_knife_rate "0.8"

        // 0=Value Default, The interval for swinging Machete.(clamped between 0.2 and 1.0)
        l4d2_melee_swing_machete_rate "0.8"

        // 0=Value Default, The interval for swinging Pitchfork. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_pitchfork_rate "0.88"

        // 0=Value Default, The interval for swinging shovel. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_shovel_rate "1.0"

        // 0=Value Default, The interval for swinging Tonfa. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_tonfa_rate "0.75"

        // 0=Value Default, Custom Third Party Melee, The interval for swinging unknown melee weapon. (clamped between 0.2 and 1.0)
        l4d2_melee_swing_unknown_rate "0.0"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.3 (2023-7-27)
		* Fix warnings when compiling on SourceMod 1.11.

    * v1.2 (2021-9-29)
        * Fixed "m_strMapSetScriptName not found" errors. Thanks to "bald14" for reporting.
        * Add new Convar "l4d2_melee_swing_incapacitated_multi_rate" to modify melee swinging rate multi when incapacitated (ex. Use 'Incapped Weapons Patch by Silvers' to allow using Weapons while Incapped)

    * v1.1 (2021-9-3)
        * Optimize code

    * v1.0 (2021-5-30)
        * [Initial release](https://forums.alliedmods.net/showthread.php?t=332737)
</details>

- - - -
# 中文說明
調整每個近戰武器的揮砍速度

* 原理
	* 每個近戰武器擁有不同的砍速

* 功能
    * 可以設置每個近戰武器的砍速



