# Description | 內容
Notifies selected team(s) when someone is on final strike and add glow

* Image | 圖示
    * display who is black and white (顯示哪個玩家黑白)
    <br/>![LMC_Black_and_White_Notifier_1](image/LMC_Black_and_White_Notifier_1.jpg)
    * display who healed (顯示誰治癒了黑白)
    <br/>![LMC_Black_and_White_Notifier_2](image/LMC_Black_and_White_Notifier_2.jpg)

* Apply to | 適用於
    ```
    L4D2
    ```

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/LMC_Black_and_White_Notifier.cfg
        ```php
        // Enable black and white notification plugin?(1/0 = yes/no)
        lmc_blackandwhite "1"

        // Enable making black white players glow?(1/0 = yes/no)
        lmc_glow "1"

        // Glow(255 255 255)
        lmc_glowcolour "255 255 255"

        // Glow range before you don't see the glow max distance
        lmc_glowrange "800.0"

        // while black and white if below 20(Def) start pulsing (0 = disable)
        lmc_glowflash "20"

        // Type to use for notification. (0= off, 1=chat, 2=hint text, 3=director hint)
        lmc_noticetype "3"

        // Method of notification. (0=survivors only, 1=infected only, 2=all players)
        lmc_teamnoticetype "0"

        // Director hint range On Black and white
        lmc_hintrange "600"

        // Director hint Timeout (in seconds)
        lmc_hinttime "5.0"

        // Director hint colour Layout(255 255 255)
        lmc_hintcolour "255 0 0"
        ```
</details>

* <details><summary>Translation Support | 支援翻譯</summary>

    ```
    English
    繁體中文
    简体中文
    ```
</details>

* <details><summary>Related Plugin | 相關插件</summary>

    1. [l4d_blackandwhite](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d_blackandwhite): Notify people when player is black and white.
        > 顯示誰是黑白狀態，比較少的提示與支援
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.1h (2023-6-23)
        * Fixed glow disappear when B&W player switches team

    * v1.0h (2022-11-26)
        * Remake Code
        * Converted plugin source to the latest syntax
        * Changes to fix warnings when compiling on SourceMod 1.11.
        * Support Translation
        * Check Last Life every 1.0 second (For people using admin cheats and other stuff that changes survivor health)
    
    * v2.0.2
        * [By Lux](https://forums.alliedmods.net/showthread.php?p=2612147)
</details>

- - - -
# 中文說明
顯示誰是黑白狀態，有更多的提示與支援LMC模組

* 原理
    * 救起玩家之後判定玩家是否為黑白狀態
    * 支援其他恢复玩家血量的插件
    * [LMC模組是由Lux大佬創建的插件](https://forums.alliedmods.net/showthread.php?t=286987)，可以自由切換角色為任何模組

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/LMC_Black_and_White_Notifier.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        lmc_blackandwhite "1"

        // 為1時，黑白玩家有光圈效果
        lmc_glow "1"

        // 光圈的顏色，填入RGB三色 (三個數值介於0~255，需要空格) [-1: 隨機顏色]
        lmc_glowcolour "255 255 255"

        // 光圈最遠可見範圍
        lmc_glowrange "800.0"

        // 黑白玩家生命值低於此數值時，光圈開始閃爍 (0 = 關閉這項功能)
        lmc_glowflash "20"

        // 黑白提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框, 3: 導演系統提示-玩家需要開啟遊戲指導系統)
        lmc_noticetype "3"

        // 提示給誰看? (0=倖存者隊伍, 1=特感隊伍, 2=所有玩家)
        lmc_teamnoticetype "0"

        // 導演系統提示的範圍
        lmc_hintrange "600"

        // 導演系統提示的時間 (單位: 秒)
        lmc_hinttime "5.0"

        // 導演系統提示的顏色
        lmc_hintcolour "255 0 0"
        ```
</details>