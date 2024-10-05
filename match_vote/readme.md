# Description | 內容
Type !match/!load/!mode to vote a new mode

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* <details><summary>How does it work?</summary>

    * Admin types ```!admin``` -> Server Commands -> "Match Mode" -> Choose a mode and change mode immediately
    * Player types ```!match/!load/!mode``` -> Choose a mode -> Call a vote to change
</details>

* Require | 必要安裝
    1. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)
    2. [builtinvotes](https://github.com/L4D-Community/builtinvotes/actions)

* <details><summary>ConVar | 指令</summary>

    * cfg\sourcemod\match_vote.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        match_vote_enable "1"

        // Delay to start another vote after vote ends.
        match_vote_delay "60"

        // Numbers of real survivor and infected player required to start a match vote.
        match_vote_required "1"
        ```
</details>

* <details><summary>Command | 命令</summary>

    * **Start a vote to change mode (Execute .cfg)**
        ```php
        sm_match
        sm_load
        sm_mode
        ```
</details>

* <details><summary>Data Config</summary>

    * [configs/matchmodes.txt](addons/sourcemod/configs/matchmodes.txt)
        ```php
        "Settings"
        {
            "Test"
            {
                "test" //  cfg/test.cfg
                {
                    "name" "Exec cfg/test.cfg" // appears in the menu
                }
            }

            "HarryMode"
            {
                "HarryMode/HarryMode_4v4" //  cfg/HarryMode/HarryMode_4v4.cfg
                {
                    "name" "HarryMode 4v4 " // appears in the menu
                }
                "HarryMode/HarryMode_3v3"//  cfg/HarryMode/HarryMode_3v3.cfg
                {
                    "name" "HarryMode 3v3 "
                }
                "HarryMode/HarryMode_2v2" //  cfg/HarryMode/HarryMode_2v2.cfg
                {
                    "name" "HarryMode 2v2 "
                }
            }
        }
        ```

    * You can delete any section. Or add your own.
</details>

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>Changelog | 版本日誌</summary>

    * v1.1 (2024-8-25)
        * Add in Admin menu => Server Commands

    * v1.0 (2023-6-30)
        * Initial Release
</details>

- - - -
# 中文說明
輸入!match/!load/!mode投票執行cfg文件，用於更換模式或玩法

* 原理
    * 管理員輸入```!admin``` -> 伺服器指令 -> "Match Mode"，即可出現所有模式列表
        * 管理員選擇模式之後，立刻換模式 (無須投票)
    * 玩家輸入```!match/!load/!mode```選擇模式進行投票
        * 選模式之後，發起投票換模式
        * 投票成功後執行指定的cfg，用於切換模式或玩法

* 用意在哪?
    * 給玩家投票決定切換模式或玩法用，譬如
        * 變更模式為對抗
        * 切換難度為專家

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg\sourcemod\match_vote.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        match_vote_enable "1"
        
        // 投票間隔冷卻時間
        match_vote_delay "60"

        // 至少需要的真人倖存者+真人特感數量在場，才可以發起投票
        match_vote_required "1"
        ```
</details>

* <details><summary>命令中文介紹 (點我展開)</summary>

    * **打開選單選擇模式 (Execute .cfg)**
        ```php
        sm_match
        sm_load
        sm_mode
        ```
</details>

* <details><summary>Data設定範例</summary>

    * [configs/matchmodes.txt](addons/sourcemod/configs/matchmodes.txt)
        ```php
        "Settings"
        {
            "Test" //名稱隨意
            {
                "test" //  執行cfg文件的路徑為: cfg/test.cfg
                {
                    "name" "Exec cfg/test.cfg" // 出現在選單介面上的名稱
                }
            }

            "HarryMode" //名稱隨意
            {
                "HarryMode/HarryMode_4v4" //  執行cfg文件的路徑為: cfg/HarryMode/HarryMode_4v4.cfg
                {
                    "name" "HarryMode 4v4 " // 出現在選單介面上的名稱
                }
                "HarryMode/HarryMode_3v3"
                {
                    "name" "HarryMode 3v3 "
                }
                "HarryMode/HarryMode_2v2"
                {
                    "name" "HarryMode 2v2 "
                }
            }
        }
        ```

    * 你可以隨意修改或新增
</details>
