# Description | 內容
Give Hittable Prop Glow when tank is alive + Stop tank props from fading whilst the tank is alive

* Apply to | 適用於
    ```
    L4D2
    ```

* [Video | 影片展示](https://youtu.be/u7-D--uGlj8)

* Image | 圖示
    * Hittabe car glow (打到的車子均會發光)
    <br/>![l4d2_tank_props_glow_1](image/l4d2_tank_props_glow_1.jpg)

* Require | 必要安裝
    1. [[INC] l4d2_hittable_control](https://github.com/fbef0102/Game-Private_Plugin/blob/main/L4D_插件/Require_檔案/scripting/include/l4d2_hittable_control.inc)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d2_tank_props_glow.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        l4d2_tank_props_glow_enable "1"

        // 0=Show Hittable Glow when tank punches hittable prop, 1=Show Hittable Glow when tank spawns
        l4d2_tank_props_glow_type "0"

        // Prop Glow Color, three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue.
        l4d2_tank_props_glow_color "255 255 255"

        // How near to props do players need to be to enable their glow. (0=Any distance)
        l4d2_tank_props_glow_range_max "4500"

        // How near to props do players need to be to disable their glow. (0=Off)
        l4d2_tank_props_glow_range_min "256"

        // 0=All players in infected team can see the glow
        // 1=Only Tank in infected team can see the glow
        l4d2_tank_props_glow_tank_only "0"

        // If 1, Spectators can see the glow too
        l4d2_tank_props_glow_spectators "1"

        // If 1, Survivors can see the glow too
        l4d2_tank_props_glow_surs "0"

        // Time it takes for hittables that were punched by Tank to dissapear after the Tank dies.
        l4d2_tank_props_glow_dissapear_time_death "10.0"

        // Time it takes for hittables that were punched by Tank to dissapear while tank is alive. (0=Off)
        l4d2_tank_props_glow_dissapear_time_alive "0.0"
        ```
</details>

* <details><summary>Other Version | 其他版本</summary>

    1. [l4d_tank_props](https://github.com/fbef0102/Rotoblin-AZMod/blob/master/SourceCode/scripting-az/l4d_tank_props.sp): (L4D1 only) Stop tank props from fading whilst the tank is alive + add Hittable Glow
        * (L4D1) Tank打到的物件都會產生光圈，只有特感能看見 + Tank死亡之後車子自動消失
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v2.9 (2026-1-11)
        * Update cvars
        * Add cvar to show hittable glow when tank spawns
        * Add cvar to let survivor team see the hittable glow

    * v2.8 (2025-10-25)
    * v2.7 (2023-3-18)
        * Optimize Code

    * v2.5 (2022-12-12)
        * Credit to [Sir, A1m`, Derpduck](https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_tank_props_glow.sp)
        
    * v2.0
        * fixed issue that tank hittable props disappear, this happens when tank is alive and then changes same map.

    * v1.8
        * update sm 1.10 syntax + improve code
    
    * v1.7
        * Converted plugin source to the latest syntax. Requires SourceMod 1.8 or newer.

    * v1.6
        * smooth glow for left4dead1

    * v1.5
        * Fixed a l4d1 value bug. Add Shadow Model color which attaches to the real hittable hitbox so that everyone including survivors can see.

    * v1.4
        * update l4d1 code syntax and make hittable prop glow better

    * v1.3 
        * fixed l4d1 problem when infected pass tank to AI

    * v1.2
        * update syntax

    * v1.0
        * [Initial Release](https://forums.alliedmods.net/showthread.php?t=312447)
</details>

- - - -
# 中文說明
Tank打到的物件都會產生光圈，只有特感能看見 + Tank死亡之後車子自動消失

* 原理
    * 當Tank拍打能動的車子時，在車子上產生光圈，只有特感能看見
    * 穿透牆壁也能看見光圈
    * Tank死亡之後打過的車子都會消失
    * 倖存者也能看見光圈 (查看指令)
    * 可讓Tank生成時所有車子全部發光 (查看指令)

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d2_tank_props_glow.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        l4d2_tank_props_glow_enable "1"

        // 0=Tank打到車子才會發光, 1=Tank生成時全部車子都發光
        l4d2_tank_props_glow_type "0"

        // 車子光圈的顏色，填入RGB三色 (三個數值介於0~255，需要空格)
        l4d2_tank_props_glow_color "255 255 255"

        // 光圈發光最遠的距離 (0=無限制)
        l4d2_tank_props_glow_range_max "4500"

        // 玩家在此範圍內光圈不會發光
        l4d2_tank_props_glow_range_min "256"

        // 為1時，特感隊伍中只有Tank可以看見
        // 為0時，特感隊伍中所有人都能看見
        l4d2_tank_props_glow_tank_only "0"

        // 為1時，旁觀者隊伍可以看見
        l4d2_tank_props_glow_spectators "1"

        // 為1時，倖存者隊伍可以看見
        l4d2_tank_props_glow_surs "0"

        // Tank死掉之後要過多久時間車子才消失
        l4d2_tank_props_glow_dissapear_time_death "10.0"

        // Tank打到車子後要過多久時間車子才消失 (0=Tank存活期間不消失)
        l4d2_tank_props_glow_dissapear_time_alive "0.0"
        ```
</details>





