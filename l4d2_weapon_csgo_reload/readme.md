# Description | 內容
Quickswitch Reloading like CS:GO in L4D2

* Apply to | 適用於
    ```
    L4D2
    ```

* [Video | 影片展示](https://youtu.be/t7n1vYBb5sk)

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696) 

* <details><summary>Other Version | 其他版本</summary>

    1. [l4d_weapon_csgo_reload](https://github.com/fbef0102/Rotoblin-AZMod/blob/master/SourceCode/scripting-az/l4d_weapon_csgo_reload.sp): (L4D1) Quickswitch Reloading like CS:GO
        > (L4D1) 將武器改成現代遊戲的裝子彈機制
</details>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d2_weapon_csgo_reload.cfg
        ```php
        // 0=off plugin, 1=on plugin
        l4d2_weapon_csgo_reload_allow "1"

        // If 1, Enable previous 裝彈時彈夾會填滿的時間 recover
        l4d2_weapon_csgo_reload_clip_recover "1"

        // reload time for ak47 裝彈時彈夾會填滿的時間
        l4d2_ak47_reload_clip_time "1.2"

        // reload time for awp 裝彈時彈夾會填滿的時間
        l4d2_awp_reload_clip_time "2.0"

        // reload time for desert rifle 裝彈時彈夾會填滿的時間
        l4d2_desertrifle_reload_clip_time "1.8"

        // reload time for dual pistol 裝彈時彈夾會填滿的時間
        l4d2_dualpistol_reload_clip_time "1.75"

        // reload time for grenade 裝彈時彈夾會填滿的時間
        l4d2_grenade_reload_clip_time "2.5"

        // reload time for hunting rifle 裝彈時彈夾會填滿的時間
        l4d2_huntingrifle_reload_clip_time "2.6"

        // reload time for m60 裝彈時彈夾會填滿的時間
        l4d2_m60_reload_clip_time "1.2"

        // reload time for mangum 裝彈時彈夾會填滿的時間
        l4d2_mangum_reload_clip_time "1.18"

        // reload time for pistol 裝彈時彈夾會填滿的時間
        l4d2_pistol_reload_clip_time "1.2"

        // reload time for rifle 裝彈時彈夾會填滿的時間
        l4d2_rifle_reload_clip_time "1.2"

        // reload time for scout 裝彈時彈夾會填滿的時間
        l4d2_scout_reload_clip_time "1.45"

        // reload time for sg552 裝彈時彈夾會填滿的時間
        l4d2_sg552_reload_clip_time "1.3"

        // reload time for smg 裝彈時彈夾會填滿的時間
        l4d2_smg_reload_clip_time "1.04"

        // reload time for smg mp5 裝彈時彈夾會填滿的時間
        l4d2_smgmp5_reload_clip_time "1.7"

        // reload time for smg silenced 裝彈時彈夾會填滿的時間
        l4d2_smgsilenced_reload_clip_time "1.05"

        // reload time for sniper military 裝彈時彈夾會填滿的時間
        l4d2_snipermilitary_reload_clip_time "1.8"
        ```
</details>

* <details><summary>Known Conflicts</summary>
	
	If you don't use any of these plugins at all, no need to worry about conflicts.
	1. [l4d_weapon_clear_reload](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_%E6%8F%92%E4%BB%B6/Weapons_%E6%AD%A6%E5%99%A8/l4d_weapon_clear_reload)
		* Abandon magazine when reload weapon
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v2.3 (2023-5-15)
        * Optimize Code
        * Use function "L4D2_GetIntWeaponAttribute" from left4dhooks to get weapons' 裝彈時彈夾會填滿的時間 automatically

	* v2.2 (2022-11-6)
        * [AlliedModders Post](https://forums.alliedmods.net/showthread.php?t=318820)
        * Add m60
        * Fixed DataPack memory leak issue
        * Replace OnPlayerRunCmd with SDKHook_Reload, better safe and improve code.
        * Adjust "l4d2_sg552_reload_clip_time" from 1.3 to 1.6 since L4D2 "The Last Stand" update.
        * New convars, control each weapon max 裝彈時彈夾會填滿的時間.
        * Fixed dual pistol not working.

	* v1.0
	    * Initial Release
</details>

- - - -
# 中文說明
將武器改成現代遊戲的裝子彈機制 (仿CS:GO切槍裝彈設定)

* 原理
	* 裝子彈的時候，彈夾不會歸零
    * 當武器動畫是裝上彈夾的時候，彈夾會填滿

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d2_weapon_csgo_reload.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        l4d2_weapon_csgo_reload_allow "1"

        // 為1時，裝子彈的時候，彈夾不會歸零
        l4d2_weapon_csgo_reload_clip_recover "1"

        // ak47 裝彈時彈夾會填滿的時間
        l4d2_ak47_reload_clip_time "1.2"

        // awp 裝彈時彈夾會填滿的時間
        l4d2_awp_reload_clip_time "2.0"

        // 三連發Scar步槍 裝彈時彈夾會填滿的時間
        l4d2_desertrifle_reload_clip_time "1.8"

        // 雙手槍 裝彈時彈夾會填滿的時間
        l4d2_dualpistol_reload_clip_time "1.75"

        // 榴彈發射器 裝彈時彈夾會填滿的時間
        l4d2_grenade_reload_clip_time "2.5"

        // 獵槍 裝彈時彈夾會填滿的時間
        l4d2_huntingrifle_reload_clip_time "2.6"

        // m60 裝彈時彈夾會填滿的時間
        l4d2_m60_reload_clip_time "1.2"

        // 瑪格南手槍 裝彈時彈夾會填滿的時間
        l4d2_mangum_reload_clip_time "1.18"

        // 單把手槍 裝彈時彈夾會填滿的時間
        l4d2_pistol_reload_clip_time "1.2"

        // rifle 裝彈時彈夾會填滿的時間
        l4d2_rifle_reload_clip_time "1.2"

        // scout 裝彈時彈夾會填滿的時間
        l4d2_scout_reload_clip_time "1.45"

        // sg552 裝彈時彈夾會填滿的時間
        l4d2_sg552_reload_clip_time "1.3"

        // smg 裝彈時彈夾會填滿的時間
        l4d2_smg_reload_clip_time "1.04"

        // smg mp5 裝彈時彈夾會填滿的時間
        l4d2_smgmp5_reload_clip_time "1.7"

        // smg silenced 裝彈時彈夾會填滿的時間
        l4d2_smgsilenced_reload_clip_time "1.05"

        // sniper military 裝彈時彈夾會填滿的時間
        l4d2_snipermilitary_reload_clip_time "1.8"
        ```
</details>

* <details><summary>會衝突的插件</summary>
	
    如果沒安裝以下插件就不需要擔心衝突
    1. [l4d_weapon_clear_reload](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_%E6%8F%92%E4%BB%B6/Weapons_%E6%AD%A6%E5%99%A8/l4d_weapon_clear_reload)
		* 武器裝彈時放棄彈夾內的所有子彈
</details>