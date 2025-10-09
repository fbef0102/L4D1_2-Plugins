# Description | 內容
Voice Announce in centr text + create hat to Show Who is speaking.

* Apply to | 適用於
    ```
    L4D2
    ```

* Image | 圖示
    * Hat + Text (MIC說話的玩家頭上會有對話框)
    <br/>![show_mic_1](image/show_mic_1.jpg)

* <details><summary>How does it work?</summary>

    * Display center text who's mic speaking
        * Only same team will see the text
        * If enable ```sv_alltalk 1```, all players can see
    * Display hat on player's head when mic speaking
        * Only same team will see the hat
        * If enable ```sv_alltalk 1```, all players can see
    * Apply to coop mode also
</details>

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)
    3. [ThirdPersonShoulder_Detect](https://forums.alliedmods.net/showthread.php?p=2529779)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/show_mic.cfg
        ```php
        // If 1, display hat on player's head if player is speaking
        show_mic_center_hat_enable "1"

        // If 1, display player speaking message in center text
        show_mic_center_text_enable "1"
        ```
</details>

* Translation Support | 支援翻譯
	```
	translations/show_mic.phrases.txt
	```

* <details><summary>Related Plugin | 相關插件</summary>

    1. [l4d_versus_specListener](https://github.com/fbef0102/Game-Private_Plugin/tree/main/L4D_插件/Spectator_%E6%97%81%E8%A7%80%E8%80%85/l4d_versus_specListener): Allows spectator listen others team voice and see others team chat for l4d
        * 旁觀者可以透過聊天視窗看到倖存者和特感的隊伍對話，亦可透過音頻聽到隊伍談話
</details>

* <details><summary>Changelog | 版本日誌</summary>

    * v1.9 (2023-1-11)
        * Fixed center text disappear when show_mic_center_hat_enable is 0

    * v1.8 (2022-12-1)
        * Remove voicehook (voicehook is now included with SourceMod 1.11)

    * v1.7
        * Remake Code

    * v1.8
        * [foxhound27's fork](https://forums.alliedmods.net/showpost.php?p=2671963&postcount=7)
</details>

- - - -
# 中文說明
顯示誰在語音並且在說話的玩家頭上帶帽子

* 原理
    * 當玩家在遊戲中使用麥克風說話時，顯示提示在螢幕中心
        * 只有相同的隊伍才能知道誰使用麥克風說話
        * 如果伺服器開啟```sv_alltalk 1```，則所有人都能知道誰使用麥克風說話
    * 當倖存者在遊戲中使用麥克風說話時，頭上產生對話框的模組   
        * 只有相同的倖存者隊伍才看得到頭上對話框的模組
        * 如果伺服器開啟```sv_alltalk 1```，則所有人都能看到倖存者頭上對話框的模組
    * 戰役模式也適用

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/show_mic.cfg
        ```php
        // 為1時，玩家用MIC說話時，頭上產生對話框的模組 
        show_mic_center_hat_enable "1"

        // 為1時，玩家用MIC說話時，顯示提示在螢幕中心
        show_mic_center_text_enable "1"
        ```
</details>