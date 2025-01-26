# Description | 內容
Improves the AI behaviour of special infected

* Apply to | 適用於
    ```
    L4D2
    ```

* <details><summary>How does it work?</summary>

    * Improves the AI behaviour of special infected, make each of them very aggresive
    * Make special infected behop jump as they can
    * Use official cvar to improve AI bots, please check[cfg/AI_HardSI/aggressive_ai.cfg](cfg/AI_HardSI/aggressive_ai.cfg)
	* Execute ```nb_assault``` every 2.0 seconds, read more details about this command below
</details>

* Improve Infected
    * <details><summary><b>AI Tank</b></summary>

        * Stop throwing the underhand rock
        * Modify Official ConVar in ```cfg\AI_HardSI\aggressive_ai.cfg```
            ```php
            // AI Tank will not throw rock within this range (default: 250)
            sm_cvar tank_throw_allow_range 300
            ```

        * Plugin ConVar
            ```php
            // If 1, bhop facsimile on AI tanks
            ai_tank_bhop "1"

            // 1=AI tanks throw rock
            // 0=Ai tanl won't throw rocks
            ai_tank_rock "1"
            ```
    </details>

    * <details><summary><b>AI Smoker</b></summary>

        * Modify Official ConVar in ```cfg\AI_HardSI\aggressive_ai.cfg```
            ```php
            // How much damage to the AI + Human Smoker makes him let go of his victim. (Default: 50)
            // Taking this much damage while pulling victim will make you die (No matter how much health left you have)
            tongue_break_from_damage_amount 250

            // Start to shoot his tongue after 0.1 seconds (Default: 1.5)
            smoker_tongue_delay 0.1
            ```
    </details>

    * <details><summary><b>AI Boomer</b></summary>

        * Modify Official ConVar in ```cfg\AI_HardSI\aggressive_ai.cfg```
            ```php
            // How long an out-of-range Boomer will tolerate being visible before fleeing (Default: 1.0)
            boomer_exposed_time_tolerance 1000.0

            // How long the Boomer waits before he vomits on his target on Normal difficulty (Default: 1.0)
            boomer_vomit_delay 0.1
            ```

        * Plugin ConVar
            ```php
            // If 1, enable bhop facsimile on AI boomers
            ai_boomer_bhop "1"
            ```
    </details>

    * <details><summary><b>AI Hunter</b></summary>

        * Won't leap away (Coop/Realism)
        * Modify Official ConVar in ```cfg\AI_HardSI\aggressive_ai.cfg```
            ```php
            // Range at which hunter prepares pounce	 (Default: 1000)
            hunter_pounce_ready_range 1000

            // Range at which hunter is committed to attack (Default: 75)
            hunter_committed_attack_range 10000

            // Range at which shooting a non-committed AI hunter will cause it to leap away (Coop/Realism, Default: 1000)
            // 0=Disable leap away ability, >0: Restore back Leap Away ability and wait in ambush mode again.
            hunter_leap_away_give_up_range 0

            // Maximum vertical angle hunters can pounce (Default: 45)
            hunter_pounce_max_loft_angle 0

            // AI + Human Hunter skeet damage (Default: 50)
            // Taking this much damage while pouncing will get you skeeted and die (No matter how much health left you have)
            z_pounce_damage_interrupt 150
            ```

        * Plugin ConVar
            ```php
            // At what distance to start pouncing fast
            ai_fast_pounce_proximity 1000

            // Vertical angle to which AI hunter pounces will be restricted
            ai_pounce_vertical_angle 7

            // Mean angle produced by Gaussian RNG
            ai_pounce_angle_mean 10

            // One standard deviation from mean as produced by Gaussian RNG
            ai_pounce_angle_std 20

            // Distance to nearest survivor at which hunter will consider pouncing straight
            ai_straight_pounce_proximity 200

            // If the hunter has a target, it will not straight pounce if the target's aim on the horizontal axis is within this radius
            ai_aim_offset_sensitivity_hunter 30

            // How far in front of himself infected bot will check for a wall. Use '-1' to disable feature
            ai_wall_detection_distance -1

            // If 1, Hunter do scratch animation when pouncing
            ai_pounce_dancing_enable "1"
            ```
    </details>

    * <details><summary><b>AI Spitter</b></summary>

        * Plugin ConVar
            ```php
            // If 1, enable bhop facsimile on AI spitters
            ai_spitter_bhop "1"
            ```
    </details>

    * <details><summary><b>AI Jockey</b></summary>

        * Modify Official ConVar in ```cfg\AI_HardSI\aggressive_ai.cfg```
            ```php
            // AI Jockeys will move to attack survivors within this range (Default: 200)
            z_jockey_leap_range 1000
            ```

        * Plugin ConVar
            ```php
            // How close a jockey will approach before it starts hopping
            ai_hop_activation_proximity 500
            ```
    </details>

    * <details><summary><b>AI Charger</b></summary>

        * Plugin ConVar
            ```php
            // If 1, enable bhop facsimile on AI chargers
            ai_charger_bhop "1"

            // How close a charger will approach before charging
            ai_charger_proximity 300

            // If the charger has a target, it will not straight pounce if the target's aim on the horizontal axis is within this radius
            ai_aim_offset_sensitivity_charger 22.5

            // Charger will charge if its health drops to this level
            ai_health_threshold_charger 300
            ```
    </details>

    * <details><summary><b>What is nb_assault</b></summary>

        * Tell all special infected bots to assault, attack survivors actively instead of not moving like idiots
        * This is official command from valve
        * Not affect AI Smoker
    </details>



* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [Actions](https://forums.alliedmods.net/showthread.php?t=336374)

* <details><summary>ConVar | 指令</summary>

    * cfg\sourcemod\AI_HardSI.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        AI_HardSI_enable "1"

        // Frequency(sec) at which the 'nb_assault' command is fired to make SI attack
        ai_assault_reminder_interval "2"

        // File to execute for AI aggressive cvars (in cfg/AI_HardSI folder)
        // Execute file every map changed
        AI_HardSI_aggressive_cfg "aggressive_ai.cfg"

        // 0=Improves the Boomer behaviour off, 1=Improves the Boomer behaviour on.
        AI_HardSI_Boomer_enable "1"

        // 0=Improves the Charger behaviour off, 1=Improves the Charger behaviour on.
        AI_HardSI_Charger_enable "1"

        // 0=Improves the Hunter behaviour off, 1=Improves the Hunter behaviour on.
        AI_HardSI_Hunter_enable "1"

        // 0=Improves the Jockey behaviour off, 1=Improves the Jockey behaviour on.
        AI_HardSI_Jockey_enable "1"

        // 0=Improves the Smoker behaviour off, 1=Improves the Smoker behaviour on.
        AI_HardSI_Smoker_enable "1"

        // 0=Improves the Spitter behaviour off, 1=Improves the Spitter behaviour on.
        AI_HardSI_Spitter_enable "1"

        // 0=Improves the Tank behaviour off, 1=Improves the Tank behaviour on.
        AI_HardSI_Tank_enable "1"

        ... (see "Improve Infected" part)
        ```
</details>

* <details><summary>Related Plugin | 相關插件</summary>

    1. [l4dinfectedbots](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dinfectedbots): Spawns multi infected bots in any mode + allows playable special infected in coop/survival + unlock infected slots (10 VS 10 available)
        * 生成多特感控制插件
    2. [l4d_ssi_teleport_fix](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Special_Infected_%E7%89%B9%E6%84%9F/l4d_ssi_teleport_fix): Teleport AI Infected player to the teammate who is much nearer to survivors.
        * 傳送比較遠的AI特感到靠近倖存者的特感隊友附近
    3. [smart_ai_rock](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/smart_ai_rock): Fix sticking aim after throws for AI Tanks.
        * AI Tank不會丟underhand rocks動作且丟完石頭後會立馬轉頭攻擊背後的倖存者
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v2.2 (2025-1-15)
        * Fixed ai tank rock won't throw rocks

    * v2.1 (2025-1-2)
        * Improve code

    * v2.0 (2024-9-9)
        * Add cfg to execute AI aggressive cvars

    * v1.9 (2024-9-4)
        * Fixed AI Smoker not moving after tongue breaks
        * Require Actions

    * v1.8 (2024-4-4)
        * Improve hunter, boomer and charger behavior

    * v1.7 (2024-1-28)
        * Update Cvars

    * v1.6 (2023-6-4)
        * Enable or Disable Each special infected behaviour

    * v1.5 (2023-5-4)
        * Use server console to execute command "nb_assault"

    * v1.4
        * Remake code
        * Replace left4downtown with left4dhooks
        * Compatibility support for SourceMod 1.11. Fixed various warnings.
    </details>

- - - -
# 中文說明
強化每個AI 特感的行為與提高智商，積極攻擊倖存者

* 原理
    * 改變各種特感的行為
    * 可以開關各特感的強化行為
    * 每兩秒執行```nb_assault```命令 (往下看說明)
    * 修改官方指令強化AI智商，請查看[cfg/AI_HardSI/aggressive_ai.cfg](cfg/AI_HardSI/aggressive_ai.cfg)

* 用意在哪?
    * 每一個特感的攻擊對倖存者造成巨大的壓力
    * 有效解決許多特感長期站著不動也不攻擊的智商與行為
    * 伺服器遊玩難度提升10倍以上

* 各特感強化內容
    * <details><summary><b>AI Tank</b></summary>

        * 取消"低手投擲"的丟石頭動作，因為瞄準率0%
        * 更動的官方指令，請查看```cfg\AI_HardSI\aggressive_ai.cfg```
            ```php
            // AI Tank 在距離倖存者此範圍內不會丟石頭 (預設: 250)
            sm_cvar tank_throw_allow_range 300
            ```

        * 插件自帶的指令
            ```php
            // 為1時，AI Tank會連跳
            ai_tank_bhop "1"

            // 1=AI tanks會丟石頭
            // 0=AI tanks不丟石頭
            ai_tank_rock "1"
            ```
    </details>

    * <details><summary><b>AI Smoker</b></summary>

        * 更動的官方指令，請查看```cfg\AI_HardSI\aggressive_ai.cfg```
            ```php
            // AI + 真人 Smoker的舌頭拉走倖存者的期間，被攻擊超過此數值會立刻死亡 (無論剩餘多少血量都一樣，別問我為捨，此遊戲設計的, 預設: 50)
            tongue_break_from_damage_amount 250

            // 當倖存者靠近範圍內的0.1秒後立刻吐舌頭 (預設: 1.5)
            smoker_tongue_delay 0.1
            ```
    </details>

    * <details><summary><b>AI Boomer</b></summary>

        * 更動的官方指令，請查看```cfg\AI_HardSI\aggressive_ai.cfg```
            ```php
            // 被人類看見的1000秒之後才會逃跑 (預設: 1.0)
            boomer_exposed_time_tolerance 1000.0

            // 當倖存者靠近範圍內的0.1秒後立刻嘔吐 (預設: 1.0)
            boomer_vomit_delay 0.1
            ```

        * 插件自帶的指令
            ```php
            // 為1時，AI Boomer會連跳
            ai_boomer_bhop "1"
            ```
    </details>

    * <details><summary><b>AI Hunter</b></summary>

        * 被攻擊的時候不會自動逃跑跳走 (只會出現在戰役/寫實模式)
        * 更動的官方指令，請查看```cfg\AI_HardSI\aggressive_ai.cfg```
            ```php
            // 此數值的範圍內才會蹲下準備撲人 (預設: 1000)
            hunter_pounce_ready_range 1000

            // 此數值的範圍內才會開始撲人 (預設: 75)
            hunter_committed_attack_range 10000

            // 此數值的範圍內還沒攻擊的AI Hunter被人類傷害時會逃跑跳走 (只會出現在戰役/寫實模式，預設: 1000)
            // 0=關閉逃跑跳走能力, >0: 回復逃跑跳走能力並且等待玩家過來
            hunter_leap_away_give_up_range 0

            // AI Hunter跳躍的最大傾角 (避免飛過頭或飛太高，預設: 45)
            hunter_pounce_max_loft_angle 0

            // 此數值的範圍內還沒攻擊的AI Hunter被人類傷害時會逃跑跳走 (只會出現在戰役/寫實模式，預設: 1000)
            // 0=關閉逃跑跳走能力, >0: 回復逃跑跳走能力並且等待玩家過來
            z_pounce_damage_interrupt 150
            ```

        * 插件自帶的指令
            ```php
            // 強迫AI Hunter在1000公尺範圍內蹲下準備撲人
            ai_fast_pounce_proximity 1000

            // 強迫AI Hunter跳躍的最大傾角 (避免飛過頭或飛太高)
            ai_pounce_vertical_angle 7

            // 強制左右飛撲靠近目標，不要垂直飛向目標
            ai_pounce_angle_mean 10
            ai_pounce_angle_std 20

            // 離目標200公尺範圍內考慮直接垂直飛向目標
            ai_straight_pounce_proximity 200

            // 目標倖存者的準心如果在瞄自身AI Hunter的身體低於30度視野範圍內則強制飛撲
            ai_aim_offset_sensitivity_hunter 30

            // 前面有牆壁的範圍內則飛撲的角度會變高，嘗試越過障礙物 (-1: 無限範圍)
            ai_wall_detection_distance -1

            // 為1時，Hunter邊飛撲邊嘗試做出抓傷動作
            ai_pounce_dancing_enable "1"
            ```
    </details>

    * <details><summary><b>AI Spitter</b></summary>

        * 插件自帶的指令
            ```php
            // 為1時，AI Spitter會連跳
            ai_spitter_bhop "1"
            ```
    </details>

    * <details><summary><b>AI Jockey</b></summary>

        * 更動的官方指令，請查看```cfg\AI_HardSI\aggressive_ai.cfg```
            ```php
            // 1000公尺範圍內才會跳躍攻擊倖存者 (預設: 200)
            z_jockey_leap_range 1000
            ```

        * 插件自帶的指令
            ```php
            // 強迫AI Jockey在500公尺範圍內開始連跳
            ai_hop_activation_proximity 500
            ```
    </details>

    * <details><summary><b>AI Charger</b></summary>

        * 插件自帶的指令
            ```php
            // 為1時，AI Charger會連跳
            ai_charger_bhop "1"

            // 強迫AI Charger在300公尺範圍內開始衝刺
            ai_charger_proximity 300

            // 目標倖存者的準心如果在瞄自身AI Charger的身體低於20度視野範圍內則強制衝刺
            ai_aim_offset_sensitivity_charger 22.5

            // 當Charger低於300血量時，強迫AI Charger開始衝刺
            ai_health_threshold_charger 300
            ```
    </details>

    * <details><summary><b>甚麼是 nb_assault ?</b></summary>

        * 強迫所有特感Bots主動往前攻擊倖存者而非像智障一樣待在原地等倖存者過來
        * 這是官方的指令
        * 不影響AI Smoker的行為
    </details>

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg\sourcemod\AI_HardSI.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        AI_HardSI_enable "1"

        // 每兩秒執行 nb_assault 命令，強迫所有特感Bots主動往前攻擊倖存者
        ai_assault_reminder_interval "2"

        // 修改官方指令強化AI智商的文件 (位於 cfg/AI_HardSI 資料夾)
        // 每次換圖都會執行一次
        AI_HardSI_aggressive_cfg "aggressive_ai.cfg"

        // 0=不強化AI Boomer, 1=強化AI Boomer
        AI_HardSI_Boomer_enable "1"

        // 0=不強化AI Charger, 1=強化AI Charger
        AI_HardSI_Charger_enable "1"

        // 0=不強化AI Hunter, 1=強化AI Hunter
        AI_HardSI_Hunter_enable "1"

        // 0=不強化AI Jockey, 1=強化AI Jockey
        AI_HardSI_Jockey_enable "1"

        // 0=不強化AI Smoker, 1=強化AI Smoker
        AI_HardSI_Smoker_enable "1"

        // 0=不強化AI Spitter, 1=強化AI Spitter
        AI_HardSI_Spitter_enable "1"

        // 0=不強化AI Tank, 1=強化AI Tank
        AI_HardSI_Tank_enable "1"

        // 以下指令說明請查看"各特感強化內容"
        ....
        ```
</details> 