# Description | 內容
Fixed the final stage get stucked

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* Q&A
    1. <details><summary><b>When do I need this plugin?</b></summary>

        * Sometimes tanks are not appearing on finale map, because "Panic" stage get stucked. 
            * Usuall happen in custom maps. 
            * The rescue vehicle nerver coming.
        * This plugin allows to set timeout (see ConVar) for Panic stage waiting the tank to appear. If that doesn't happen, plugin forcibly call the next stage and director automatically spawns the tank as it normally should.
        </details>

    2. <details><summary><b>What could the reason that final stage stuck?</b></summary>
    
        1. Too many common infected waiting to spawn, cause stage staying too long to proceed
            * People use other plugin or adjust cvars to keep spawning hordes, hordes keep coming and never ends
            * Solution: Try to delete plugins that spawn lots of mobs

        2. Not have valid position to spawn S.I. bots including tanks
            * Custom map nav problem, game director can not find a good place to spawn Tank
            * Solution: Go to contact map author

        3. Slot is full. Let's say if server only allow 18 max players, infected team max slot is 4
            * When players + bots (infected + survivor + spectator) reach 18 max, unable to spawn Tank (server slot is full)
            * When infected players + bots reach 4 max, unable to spawn Tank (infected team slot is full)
            * Solution: increase server slots or infected team slot
    </details>

    3. <details><summary><b>What else can Adm do?</b></summary>
    
        * Adm can type ```!nextstage``` if nothing happened in final stage.
    </details>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d_finale_stage_fix.cfg
        ```php
        // Timeout (in sec.) for finale panic stage waiting for tank/painc horde to appear, otherwise stage forcibly changed
        l4d_finale_stage_fix_panicstage_timeout "60"

        // If 1, reset timer when common infected spawns
        l4d_finale_stage_fix_reset_ci_spawn "1"

        // If 1, reset timer when common infected death
        l4d_finale_stage_fix_reset_ci_death "1"

        // If 1, reset timer when special infected bot or tank bot spawns
        l4d_finale_stage_fix_reset_si_spawn "1"

        // If 1, reset timer when special infected bot or tank bot death
        l4d_finale_stage_fix_reset_si_death "1"
        ```
</details>

* <details><summary>Command | 命令</summary>

    * **(L4D2) Forcibly call the next stage. (Adm required: ADMFLAG_ROOT)**
        ```php
        sm_nextstage
        ```

    * **(L4D2) Prints current stage index and time passed. (Adm required: ADMFLAG_ROOT)**
        ```php
        sm_stage
        ```

    * **Call rescue vehicle immediately. (Adm required: ADMFLAG_ROOT)**
        ```php
        sm_callrescue
        ```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.3h (2025-3-6)
        * Upate cvars

    * v1.2h (2025-1-23)
        * Support L4D1
        
    * v1.1h (2023-10-21)
        * Fix command not working

    * v1.0h (2023-5-12)
        * Add more check after final starts.
        * The plugin will force ForceNextStage if final stage stucks after 60 seconds.
        * Adm can type !nextstage if nothing happened.

    * v1.5
        * [Original Plugin by Dragokas](https://forums.alliedmods.net/showthread.php?t=334759)
</details>

- - - -
# 中文說明
解決最後救援卡關，永遠不能來救援載具的問題

* 原理
    * 最後救援階段過程中如果超過60秒時沒有特感、小殭屍、Tank生成時，就會視為卡關
    * 卡關之後，插件會強制下一個救援階段，救援載具直接來臨讓倖存者上去
    * 經常發生於三方圖，伺服器的控制台頻繁出現"5 attempts to found spawn position faile"字樣，特感、小殭屍、Tank找不到位置生成，導致救援無法進行下一個階段

* Q&A
    1. <details><summary><b>何時安裝這個插件?</b></summary>

        * 如果你經常遇到救援關卡
            * 很久的時候沒有特感、小殭屍、Tank生成卡關
            * 救援載具很久不出現卡關
    </details>

    2. <details><summary><b>為什麼會卡關?</b></summary>
    

        1. 太多普通殭屍等待生成，導致卡關
            * 常使用其他的插件生成大量的屍潮或殭屍，屍潮一直來導致救援階段無法繼續
            * 解決方式: 刪除會大量生成屍潮的插件

        2. 找不到合適的位置生成Tank
            * 常見於三方圖，地圖沒有做好(NAV 問題)，遊戲導演找不到地圖上人類看不見的位置生成Tank
            * 解決方式: 去怪地圖作者

        3. 位子已滿，假設伺服器只允許18個玩家、特感隊伍最大只能4個位子
            * 當真人玩家+Bots (特感 + 倖存者 + 旁觀者) 達到18個位子時，無法生成Tank (伺服器位子已滿)
            * 當特感隊伍的玩家+Bots 達到4個位子時，無法生成Tank (特感隊伍位子已滿)
            * 解決方式: 增加特感隊伍位子或是伺服器位子
    </details>

    3. <details><summary><b>管理員能做什麼?</b></summary>
    
        * 管理員可以於聊天框輸入 ```!nextstage``` 強制跳到下一個救援階段 (救援開始之後才能使用)
    </details>

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d_finale_stage_fix.cfg
        ```php
        // 卡關等待時間，如果有特感Bot、小殭屍、Tank Bot生成時，則重新計時
        // 如果時間到則視為卡關，插件會強制下一個救援階段
        l4d_finale_stage_fix_panicstage_timeout "60"

        // 為1時，小殭屍生成時，則重新計時
        l4d_finale_stage_fix_reset_ci_spawn "1"

        // 為1時，小殭屍死亡時，則重新計時
        l4d_finale_stage_fix_reset_ci_death "1"

        // 為1時，特感Bot、Tank Bot生成時，則重新計時
        l4d_finale_stage_fix_reset_si_spawn "1"

        // 為1時，特感Bot、Tank Bot死亡時，則重新計時
        l4d_finale_stage_fix_reset_si_death "1"
        ```
</details>

* <details><summary>命令中文介紹 (點我展開)</summary>

    * **(L4D2) 強制跳到下一個救援階段 (救援開始之後才能使用) (權限: ADMFLAG_ROOT)**
        ```php
        sm_nextstage
        ```

    * **(L4D2) 顯示目前的救援階段以及已經過的時間 (救援開始之後才能使用) (權限: ADMFLAG_ROOT)**
        ```php
        sm_stage
        ```

    * **強制呼叫救援載具來臨 (救援開始之後才能使用) (權限: ADMFLAG_ROOT)**
        ```php
        sm_callrescue
        ```
</details>
