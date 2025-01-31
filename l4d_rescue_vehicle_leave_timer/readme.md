# Description | 內容
When rescue vehicle arrived and a timer will display how many time left before vehicle leaving. If a player is not on rescue vehicle or zone, slay him.

* [Video | 影片展示](https://youtu.be/zC4kZcG8wOA)

* Image | 圖示
    * Nuke explosion (核彈爆炸)
    <br/>![l4d_rescue_vehicle_leave_timer_1](image/l4d_rescue_vehicle_leave_timer_1.gif)

* <details><summary>How does it work?</summary>

    * When rescue vehicle arrived and a timer will display how many time left before vehicle leaving
    * The plugin supports all valve maps and all custom maps.
    * If the map finale is sacrifice, disable this plugin.
</details>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d_rescue_vehicle_leave_timer.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        l4d_rescue_vehicle_leave_timer_allow "1"

        // Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).
        l4d_rescue_vehicle_leave_timer_modes ""

        // Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).
        l4d_rescue_vehicle_leave_timer_modes_off ""

        // Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.
        l4d_rescue_vehicle_leave_timer_modes_tog "0"

        // Changes how count down tumer hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
        l4d_rescue_vehicle_leave_timer_announce_type "2"

        // Default time to escape.
        l4d_rescue_vehicle_leave_timer_escape_time_default "60"

        // (L4D2) If 1, Enable AirStrike (explosion, missile, jets, fire)
        l4d_rescue_vehicle_leave_timer_airstrike_enable "1"
        ```
</details>

* <details><summary>Command | 命令</summary>

    None
</details>

* <details><summary>Data Example</summary>

    * [data/l4d_rescue_vehicle_leave_timer.cfg](data/l4d_rescue_vehicle_leave_timer.cfg)
        > Manual in this file, click for more details...
</details>

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>Translation Support | 支援翻譯</summary>

    ```
    English
    繁體中文
    简体中文
    Русский
    ```
</details>

* <details><summary>Related | 相關插件</summary>

    1. [lockdown_system-l4d2](/lockdown_system-l4d2): Locks Saferoom Door Until Someone Opens It.
        > 倖存者必須等待時間到並合力對抗屍潮與Tank才能打開終點安全門

    2. [l4d2_final_rescue_arrive_time](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Map_%E9%97%9C%E5%8D%A1/l4d2_final_rescue_arrive_time): Increase the finale rescue time, survivors must hold up until time passed
        > 增加最後救援的防守時間，倖存者必須等待時間結束，救援載具才會來臨

    3. [l4d_elevator_getin_timer](https://github.com/fbef0102/Game-Private_Plugin/blob/main/L4D_插件/Anti_Griefer_%E9%98%B2%E6%83%A1%E6%84%8F%E8%B7%AF%E4%BA%BA/l4d_elevator_getin_timer): When someone presses the elevator button or enters the CEDA Trailer, a timer will display how many time left. If a player is not inside the evelator/CEDA Trailer, slay him
        > 當有人按下電梯按鈕或是進入CEDA大拖車時，開始倒數計時，未在時間內進入電梯或CEDA大拖車的玩家將處死
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v2.2 (2024-11-25)
        * Update gamedata
        * Support L4D1 again
        * Change method to detect if player is in rescue vehicle

    * v2.1 (2024-9-14)
        * Add gamedata
        
    * v2.0 (2024-6-23)
    * v1.9 (2024-1-20)
        * Fix some custom maps not working

    * v1.8 (2023-10-21)
        * New method to detect if player is in rescue vehicle
        * Remove gamedata

    * v1.7 (2023-6-20)
        * Require lef4dhooks v1.33 or above

    * v1.6 (2023-4-4)
        * Add a cvar to enable or disable AirStrike (explosion, missile, jets, fire)

    * v1.5 (2023-3-21)
        * Support Gamedata, from [End Safearea Teleport by sorallll](https://forums.alliedmods.net/showthread.php?p=2766575)
        * Support All custom map
        * delete data file

    * v1.4
        * [AlliedModder Post](https://forums.alliedmods.net/showpost.php?p=2725525&postcount=7)
        * Thanks to Marttt and Crasher_3637.
        * Works on l4d1/2 all value maps.
        * Custom timer for each final map (edit data).
        * Translation support
        * The City Will Get Nuked After Countdown Time Passes, Idea from [Nuke | The City Will Get Nuked After Countdown Time Passes by alasfourom](https://forums.alliedmods.net/showthread.php?p=2784677)
        * Silvers F18 Airstrike
</details>

- - - -
# 中文說明
救援來臨之後，未在時間內上救援載具逃亡的玩家將處死

* 原理
    * 當最後一關救援載具來臨時，顯示逃亡倒數剩餘時間
    * 沒有上救援載具的玩家將會被處死

* 注意事項
    * 此插件適用所有官方地圖與三方圖
    * 不適用有犧牲結局的救援地圖

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d_rescue_vehicle_leave_timer.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        l4d_rescue_vehicle_leave_timer_allow "1"

        // 什麼模式下啟動此插件, 逗號區隔 (無空白). (留白 = 所有模式)
        l4d_rescue_vehicle_leave_timer_modes ""

        // 什麼模式下關閉此插件, 逗號區隔 (無空白). (留白 = 無)
        l4d_rescue_vehicle_leave_timer_modes_off ""

        // 什麼模式下啟動此插件. 0=所有模式, 1=戰役, 2=生存, 4=對抗, 8=清道夫. 請將數字相加起來
        l4d_rescue_vehicle_leave_timer_modes_tog "0"

        // 倒數提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框, 3: 螢幕正中間)
        l4d_rescue_vehicle_leave_timer_announce_type "2"

        // 逃亡倒數時間
        l4d_rescue_vehicle_leave_timer_escape_time_default "60"

        // (L4D2) 為1時，啟用空軍轟炸特效 (爆炸, 導彈, 噴射機, 火焰....)
        // (L4D2) 為0時，關閉空軍轟炸，避免太lag
        l4d_rescue_vehicle_leave_timer_airstrike_enable "1"
        ```
</details>

* <details><summary>Data設定範例</summary>

    * 可自行調整關卡，設置每個章節逃亡倒數時間
    * [data/l4d_rescue_vehicle_leave_timer.cfg](data/l4d_rescue_vehicle_leave_timer.cfg)
        > 內有中文說明，可點擊查看
</details>
