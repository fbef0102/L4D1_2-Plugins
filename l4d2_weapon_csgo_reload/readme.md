# Description | 內容
(CSGO or CS2 Reload Mechanism) Modern weapon reload + Abandon magazine when reload in L4D1/2

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* [Video | 影片展示](https://youtu.be/JqhY-ubmoLo)

* Image | 圖示
    * Before (裝此插件之前-官方的裝彈方式)
    <br/>![l4d2_weapon_csgo_reload_1](image/l4d2_weapon_csgo_reload_1.gif)
    * After-CSGO style (使用CSGO 風格)
    <br/>![l4d2_weapon_csgo_reload_2](image/l4d2_weapon_csgo_reload_2.gif)
    * After-CS2 style (使用CS2 風格)
    <br/>![l4d2_weapon_csgo_reload_3](image/l4d2_weapon_csgo_reload_3.gif)

* <details><summary>How does it work?</summary>

    * There are two reload method you can choose
        1. CSGO style
            * The magazine will not be emptied when start reloading
            * Quickswitch Reloading
            * Won't drop the entire magazine
            * For example, Reload Ak47: 30/360
                * (Original) 0/390 -> (around 2.4 second) 40/350
                * (After) 30/360-> (around 1.2 second) 40/350
        2. CS2 style
            * The magazine will not be emptied when start reloading
            * Quickswitch Reloading
            * 🟦 Drop the entire magazine when finish reloading
            * 🟦 Reserve ammo is displayed as exact magazines instead of total bullets
            * For example, Reload Ak47: 30/360
                * (Original) 0/390 -> (around 2.4 second) 40/350
                * (After) 30/9 -> (around 1.2 second) 40/8
</details>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696) 
    2. [sendproxy](https://github.com/jensewe/Left4SendProxy/releases)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d2_weapon_csgo_reload.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        l4d2_weapon_csgo_reload_allow "1"

        // Choose weapon reload method
        // 0=CSGO style: Don't drop the entire magazine
        // 1=CS2 style: Drop the entire magazine when finish reloading, reserve ammo is displayed as exact magazines instead of total bullets.
        l4d2_weapon_csgo_reload_magazine_type "1"

        // (L4D2) reload time for ak47
        l4d2_ak47_reload_clip_time "1.2"

        // (L4D2) reload time for awp
        l4d2_awp_reload_clip_time "2.0"

        // (L4D2) reload time for desert rifle
        l4d2_desertrifle_reload_clip_time "1.8"

        // (L4D2) reload time for dual pistol
        l4d2_dualpistol_reload_clip_time "1.75"

        // (L4D2) reload time for grenade
        l4d2_grenade_reload_clip_time "2.5"

        // (L4D2) reload time for hunting rifle
        l4d2_huntingrifle_reload_clip_time "2.6"

        // (L4D2) reload time for m60
        l4d2_m60_reload_clip_time "1.2"

        // (L4D2) reload time for mangum
        l4d2_mangum_reload_clip_time "1.18"

        // (L4D2) reload time for pistol
        l4d2_pistol_reload_clip_time "1.2"

        // (L4D2) reload time for rifle
        l4d2_rifle_reload_clip_time "1.2"

        // (L4D2) reload time for scout
        l4d2_scout_reload_clip_time "1.45"

        // (L4D2) reload time for sg552
        l4d2_sg552_reload_clip_time "1.3"

        // (L4D2) reload time for smg
        l4d2_smg_reload_clip_time "1.04"

        // (L4D2) reload time for mp5
        l4d2_smgmp5_reload_clip_time "1.7"

        // (L4D2) reload time for silenced smg
        l4d2_smgsilenced_reload_clip_time "1.05"

        // (L4D2) reload time for sniper military
        l4d2_snipermilitary_reload_clip_time "1.8"

        // (L4D1) reload time for hunting rifle clip
        l4d_huntingrifle_reload_clip_time "2.6"

        // (L4D1) reload time for pistol clip
        l4d_pistol_reload_clip_time "1.5"

        // (L4D1) reload time for dual pistol clip
        l4d_dualpistol_reload_clip_time "2.1"

        // (L4D1) reload time for rifle clip
        l4d_rifle_reload_clip_time "1.2"

        // (L4D1) reload time for smg clip
        l4d_smg_reload_clip_time "1.65"
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v2.7 (2026-6-26)
        * Add gamedata for l4d1
        * Optimize code

    * v2.6 (2026-6-25)
        * Require sendproxy
        * If choose cs2 reloading style, reserve ammo is displayed as exact magazines instead of total bullets
        * Update cvars

    * v2.5 (2026-5-19)
        * When reload weapon, abandon the magazine like CS2 (You can disable in cvar)
        * Improve code
        * Support L4D1
        * Update cvars

    * v2.3 (2023-5-15)
        * Optimize Code
        * Use function "L4D2_GetIntWeaponAttribute" from left4dhooks to get weapons' clip automatically

	* v2.2 (2022-11-6)
        * [AlliedModders Post](https://forums.alliedmods.net/showthread.php?t=318820)
        * Add m60
        * Fixed DataPack memory leak issue
        * Replace OnPlayerRunCmd with SDKHook_Reload, better safe and improve code.
        * Adjust "l4d2_sg552_reload_clip_time" from 1.3 to 1.6 since L4D2 "The Last Stand" update.
        * New convars, control each weapon max clip
        * Fixed dual pistol not working.

	* v1.0
	    * Initial Release
</details>

- - - -
# 中文說明
將武器改成現代遊戲的裝子彈機制 (仿CSGO或CS2裝彈設定)

* 原理
    * 有兩種裝彈方式
        1. CSGO 風格
            * 開始裝子彈的時候，彈匣不會歸零
            * 當武器動畫是裝上彈匣的時候，彈匣會填滿
            * 不會丟棄彈夾內所有子彈
            * 譬如裝一個AK47武器: 30/360
                * (裝此插件之前) 0/390 -> (大約2.4秒後) 40/350
                * (裝此插件之後) 30/360-> (大約1.2秒後) 40/350
        2. CS2 風格
            * 開始裝子彈的時候，彈匣不會歸零
            * 當武器動畫是裝上彈匣的時候，彈匣會填滿
            * 🟦 裝彈完成後會丟棄彈夾內所有子彈
            * 🟦 備用彈藥以彈匣數量顯示，而非子彈總數顯示
            * 譬如裝一個AK47武器: 30/360
                * (裝此插件之前) 0/390 -> (大約2.4秒後) 40/350
                * (裝此插件之後) 30/9-> (大約1.2秒後) 40/8

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d2_weapon_csgo_reload.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        l4d2_weapon_csgo_reload_allow "1"

        // 選擇裝彈方式
        // 0=CSGO 風格: 快速填裝+不會丟棄彈夾內所有子彈
        // 1=CS2 風格: 快速填裝+裝彈完成後會丟棄彈夾內所有子彈+備用彈藥以彈匣數量顯示，而非子彈總數顯示
        l4d2_weapon_csgo_reload_magazine_type "1"

        // (L4D2) ak47 裝彈時彈匣會填滿的時間
        l4d2_ak47_reload_clip_time "1.2"

        // (L4D2) awp 裝彈時彈匣會填滿的時間
        l4d2_awp_reload_clip_time "2.0"

        // (L4D2) 三連發Scar步槍 裝彈時彈匣會填滿的時間
        l4d2_desertrifle_reload_clip_time "1.8"

        // (L4D2) 雙手槍 裝彈時彈匣會填滿的時間
        l4d2_dualpistol_reload_clip_time "1.75"

        // (L4D2) 榴彈發射器 裝彈時彈匣會填滿的時間
        l4d2_grenade_reload_clip_time "2.5"

        // (L4D2) 獵槍 裝彈時彈匣會填滿的時間
        l4d2_huntingrifle_reload_clip_time "2.6"

        // (L4D2) m60 裝彈時彈匣會填滿的時間
        l4d2_m60_reload_clip_time "1.2"

        // (L4D2) 瑪格南手槍 裝彈時彈匣會填滿的時間
        l4d2_mangum_reload_clip_time "1.18"

        // (L4D2) 單把手槍 裝彈時彈匣會填滿的時間
        l4d2_pistol_reload_clip_time "1.2"

        // (L4D2) rifle 裝彈時彈匣會填滿的時間
        l4d2_rifle_reload_clip_time "1.2"

        // (L4D2) scout 裝彈時彈匣會填滿的時間
        l4d2_scout_reload_clip_time "1.45"

        // (L4D2) sg552 裝彈時彈匣會填滿的時間
        l4d2_sg552_reload_clip_time "1.3"

        // (L4D2) smg 裝彈時彈匣會填滿的時間
        l4d2_smg_reload_clip_time "1.04"

        // (L4D2) mp5 裝彈時彈匣會填滿的時間
        l4d2_smgmp5_reload_clip_time "1.7"

        // (L4D2) silenced smg 裝彈時彈匣會填滿的時間
        l4d2_smgsilenced_reload_clip_time "1.05"

        // (L4D2) sniper military 裝彈時彈匣會填滿的時間
        l4d2_snipermilitary_reload_clip_time "1.8"

        // (L4D1) 獵槍 裝彈時彈匣會填滿的時間
        l4d_huntingrifle_reload_clip_time "2.6"

        // (L4D1) 單把手槍 裝彈時彈匣會填滿的時間
        l4d_pistol_reload_clip_time "1.5"

        // (L4D1) 雙手槍 裝彈時彈匣會填滿的時間
        l4d_dualpistol_reload_clip_time "2.1"

        // (L4D1) rifle 裝彈時彈匣會填滿的時間
        l4d_rifle_reload_clip_time "1.2"

        // (L4D1) smg 裝彈時彈匣會填滿的時間
        l4d_smg_reload_clip_time "1.65"
        ```
</details>