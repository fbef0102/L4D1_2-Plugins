# Description | 內容
Displays the TF2 trophy when a player unlocks an achievement or kill tank/witch

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * Displays the TF2 trophy on player's head when
        * A player unlocks an achievement
        * Kill a tank
        * Kill a witch
    * Displays the Moustachio on player's head when
        * Get puked by boomer
</details>

* Require | 必要安裝
<br/>None

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d_achievement_trophy.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        l4d_trophy_allow "1"

        // Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).
        l4d_trophy_modes ""

        // Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).
        l4d_trophy_modes_off ""

        // Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.
        l4d_trophy_modes_tog "0"

        // Which effects to display. 1=Trophy, 2=Fireworks, 3=Both.
        l4d_trophy_effects "3"

        // 0=Off. 1=Play sound when using the command. 2=When achievement is earned (not required for L4D1). 3=Both.
        l4d_trophy_sound "3"

        // 0.0=Off. How long to put the player into thirdperson view.
        l4d_trophy_third "4.0"

        // Remove the particle effects after this many seconds. Increase time to make the effect loop.
        l4d_trophy_time "3.5"

        // Replay the particles after this many seconds.
        l4d_trophy_wait "3.5"
        ```
</details>

* <details><summary>Command | 命令</summary>
    
    * **Display the achievement trophy on yourself. Or optional arg to specify targets**
        ```php
        sm_trophy [#userid|name]
        ```
</details>


* <details><summary>Changelog | 版本日誌</summary>

    * v1.0h (2026-4-1)
        * Kill a tank
        * Kill a witch
        * Displays the Moustachio on player's head when get puked by boomer

    * v2.7
        * [Original Posy](https://forums.alliedmods.net/showthread.php?t=136174)
</details>

- - - -
# 中文說明
場上有人擊殺Tank或是Witch時，頭上顯示華麗的獎盃特效

* 原理
    * 有以下情況時頭上顯示華麗的獎盃特效
        * 有人擊殺Tank
        * 有人擊殺Witch
        * 有人解鎖成就
    * 有以下情況時頭上顯示C2地圖的鬍鬚模型
        * 被Boomer噴

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/cge_l4d2_deathcheck.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        l4d_trophy_allow "1"

        // 什麼模式下啟動此插件, 逗號區隔 (無空白). (留白 = 所有模式)
        l4d_trophy_modes ""

        // 什麼模式下關閉此插件, 逗號區隔 (無空白). (留白 = 無)
        l4d_trophy_modes_off ""

        // 什麼模式下啟動此插件. 0=所有模式, 1=戰役, 2=生存, 4=對抗, 8=清道夫. 請將數字相加起來
        l4d_trophy_modes_tog "0"

        // 顯示哪些特效? 1=獎盃, 2=煙火, 3=都要.
        l4d_trophy_effects "3"

        // 0=關閉獎盃音效. 1=使用!trophy有音效. 2=成就解鎖時有音效. 3=都有.
        l4d_trophy_sound "3"

        // 0.0=關閉這項功能. 獎盃特效時顯示三人稱的時間
        l4d_trophy_third "4.0"

        // 獎盃特效於此秒數後刪除, 增加時間可以循環播放特效
        l4d_trophy_time "3.5"

        // 此秒數後循環播放獎盃特效
        l4d_trophy_wait "3.5"
        ```
</details>


* <details><summary>命令中文介紹 (點我展開)</summary>
    
    * **在你頭上顯示獎盃特效. 或是指定玩家名稱**
        ```php
        sm_trophy [#userid|name]
        ```
</details>