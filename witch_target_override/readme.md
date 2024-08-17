# Description | 內容
Change target when the witch incapacitates or kills victim + witch auto follows survivors

* [Video | 影片展示](https://youtu.be/SapXAIOsNJI)

* Image | 圖示
    <br/>![witch_target_override_1](image/witch_target_override_1.gif)
    <br/>![witch_target_override_2](image/witch_target_override_2.gif)

* Require | 必要安裝
    1. [Actions](https://forums.alliedmods.net/showthread.php?t=336374)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/witch_target_override.cfg
        ```php
        // 1=Plugin On. 0=Plugin Off
        witch_target_override_on "1"

        // Chance the witch will chase another target after she incapacitates a survivor. [0-100]
        witch_target_override_incap_chance "100"

        // Chance the witch will chase another target after she kills a survivor. [0-100]
        witch_target_override_kill_chance "100"

        // Add witch health if she is allowed to chase another target after she incapacitates a survivor. (0=Off)
        witch_target_override_incap_health_add "100"

        // Add witch health if she is allowed to chase another target after she kills a survivor. (0=Off)
        witch_target_override_kill_health_add "400"

        // This controls the range for witch to reacquire another target. [1.0, 9999.0] (If no targets within range, witch default behavior)
        witch_target_override_chase_range "9999"

        // Chance of following survivors [0, 100]
        witch_target_override_chance_followsurvivor "100"

        // Witch's vision range, witch will follow survivor if in range. [100.0, 9999.0] 
        witch_target_override_followsurvivor_range "500.0"

        // Witch's following speed.
        witch_target_override_followsurvivor_speed "45.0"

        // Witch stops following when her rage over this value. [0.0, 1.0] (Witch will follow again when her rage below this value)
        witch_target_override_followsurvivor_rage "0.5"
        ```
</details>

* <details><summary>Command | 命令</summary>

    None
</details>

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>Related Plugin | 相關插件</summary>

    1. [l4d_witch_target_forever](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Witch_%E5%A5%B3%E5%B7%AB/l4d_witch_target_forever): If the witch incap/kill players that aren't her initial target, then make the witch proceed to chase her initial target.
        * Witch因為被擋路或改變目標抓傷任何玩家之後，強制繼續追擊原始目標
    2. [Witch fixes](https://forums.alliedmods.net/showthread.php?t=315481): 4 plugins By Lux
        * 四個修復Witch的插件可以裝
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v2.3 (2024-8-17)
        * Support l4d_witch_target_forever

    * v2.2 (2024-6-20)
        * Fixed witch wil be killed after change target 15 seconds 

    * v2.1 (2024-3-11)
        * Update Cvars

    * v2.0 (2024-1-26)
        * Require actions

    * v1.9 (2024-1-9)
        * Update Cvars
        * Witch stops following when her rage over the certain value.

    * v1.8 (2022-11-14)
        * [AlliedModders Post](https://forums.alliedmods.net/showpost.php?p=2732048&postcount=9)
        * Witch is allowed to chase another target after she incapacitates a survivor. 
        * Witch is allowed to chase another target after she kills a survivor. 
        * Witch will not follow survivor if there is a wall between witch and survivor.
        * Witch will not follow survivor if survivor standing on the higher place.
        * Witch burns for a set amount of time and die. (z_witch_burn_time 15 seconds = default)
        * Support L4D1

    * v1.0
        * Initial Release
        * Thanks to BHaType, xZk, cravenge and silvers
</details>

- - - -
# 中文說明
Witch會自動跟蹤你，一旦驚嚇到她，不殺死任何人絕不罷休

* 原理
    * 出現在Witch看得到的視野之內，她將會自動走向你
    * 嚇到Witch之後，將目標玩家倒地或殺死之後，自動把目標轉向剩餘的倖存者繼續發難

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/witch_target_override.cfg
        ```php
        // 1=開啟插件. 0=關閉插件
        witch_target_override_on "1"

        // 目標玩家倒地之後繼續追殺其他倖存者的機率 [0-100]
        witch_target_override_incap_chance "100"

        // 目標玩家死亡之後繼續追殺其他倖存者的機率 [0-100]
        witch_target_override_kill_chance "100"

        // 如果Witch在目標玩家倒地之後繼續追殺其他倖存者，增加數值血量. (0=關閉)
        witch_target_override_incap_health_add "100"

        // 如果Witch在目標玩家死亡之後繼續追殺其他倖存者，增加數值血量. (0=關閉)
        witch_target_override_kill_health_add "400"

        // Witch準備追殺的另外一名倖存者並須在這個範圍之內 [1.0~9999.0] (如果範圍內沒有倖存者, 那Witch繼續遊戲預設行為)
        witch_target_override_chase_range "9999"

        // Witch會跟蹤倖存者的機率
        witch_target_override_chance_followsurvivor "100"

        // 倖存者距離Witch的一定可見範圍內，Witch會跟蹤倖存者 [100.0~9999.0] 
        witch_target_override_followsurvivor_range "500.0"

        // Witch的跟蹤速度
        witch_target_override_followsurvivor_speed "45.0"

        // Witch如果驚嚇值超過此數值會停止跟蹤倖存者. [0.0~1.0] (Witch驚嚇值低於此數值則繼續跟蹤倖存者)
        witch_target_override_followsurvivor_rage "0.5"
        ```
</details>