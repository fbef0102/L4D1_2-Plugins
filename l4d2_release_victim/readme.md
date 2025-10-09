# Description | 內容
Allow to release victim

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* [Video | 影片展示](https://youtu.be/IzL-UIF6K-Y)

* Image | 圖示
    * Press Right Mouse to release the victim (右鍵釋放抓住的倖存者)
    <br/>![l4d2_release_victim_1](image/l4d2_release_victim_1.gif)
    * Can't use attack1/attack2 (0=Off) for short time after release victim (釋放後短時間不能攻擊)
    <br/>![l4d2_release_victim_2](image/l4d2_release_victim_2.jpg)

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

    * cfg/sourcemod/l4d2_release_victim.cfg
        ```php
        // 0=Plugin off, 1=Plugin on.
        l4d2_release_victim_enable "1"

        // If 1, Infected player fly away when release victim
        l4d2_release_victim_fly "1"

        // Release distance
        l4d2_release_victim_distance "900.0"

        // Release height
        l4d2_release_victim_height "600.0"

        // If 1, Reset ability
        l4d2_release_victim_ability_reset "1"

        // If 1, Show effect after release
        l4d2_release_victim_effect "1"

        // If 1, Jockey can release victim (0=Can't)
        l4d2_release_victim_jockey_yes "1"

        // If 1, Hunter can release victim (0=Can't)
        l4d2_release_victim_hunter_yes "1"

        // If 1, Charger can release victim (0=Can't)
        l4d2_release_victim_charger_yes "1"

        // If 1, Smoker can release victim (0=Can't)
        l4d2_release_victim_smoker_yes "1"

        // After dismounting with the jockey, how long the player can not use attack1/attack2 (0=Off)
        l4d2_release_victim_jockey_attack_delay "6.0"

        // After dismounting with the hunter, how long the player can not use attack1/attack2 (0=Off)
        l4d2_release_victim_hunter_attack_delay "6.0"

        // After dismounting with the charger, how long the player can not use attack1/attack2 (0=Off)
        l4d2_release_victim_charger_attack_delay "6.0"

        // After dismounting with the smoker, how long the player can not use attack1/attack2 (0=Off)
        l4d2_release_victim_smoker_attack_delay "10.0"

        // How long can the infected player releases victim after pinned the survivor
        l4d2_release_victim_release_delay "1.5"

        // Changes how message displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
        l4d2_release_victim_announce_type "1"
        ```
</details>

* Translation Support | 支援翻譯
	```
	translations/l4d2_release_victim.phrases.txt
	```

* <details><summary>Changelog | 版本日誌</summary>

    * v1.4h (2025-1-13)
        * Support L4D1
        * Optimize code

    * v1.3h (2023-8-25)
    * v1.2h (2023-8-1)
        * Update Cvars

    * v1.1h (2023-2-6)
        * Use better way to release victim
        * Require left4dhooks
        * Fixed crash when map change

    * v1.0h (2023-4-11)
        * Translation Support
        * Add cvars, infected can't use attack1/attack2 (0=Off) for short time after release victim.

    * v2.5 (2023-1-27)
        * [Shadowysn's fork](https://forums.alliedmods.net/showpost.php?p=2785929&postcount=25)
        * Remove Gamedata

    * v0.4
        * [Original Plugin by BHaType](https://forums.alliedmods.net/showthread.php?p=2676902)
</details>

- - - -
# 中文說明
特感可以釋放被抓住的倖存者

* 原理
    * Charger、Smoker、Jockey、Hunter抓住倖存者之後，可以按下右鍵釋放倖存者
    * AI 特感不適用

* <details><summary>指令中文介紹 (點我展開)</summary>

    * cfg/sourcemod/l4d2_release_victim.cfg
        ```php
        // 0=關閉插件, 1=啟動插件
        l4d2_release_victim_enable "1"

        // 為1時，釋放倖存者時，特感會被彈飛
        l4d2_release_victim_fly "1"

        // 釋放倖存者後彈走的距離
        l4d2_release_victim_distance "900.0"

        // 釋放倖存者後彈走的高度
        l4d2_release_victim_height "600.0"

        // 為1時，釋放倖存者後，特感的能力CD重置
        l4d2_release_victim_ability_reset "1"

        // 為1時，釋放倖存者時，顯示白光特效
        l4d2_release_victim_effect "1"

        // 為1時，Jockey可以釋放倖存者 (0=不能釋放)
        l4d2_release_victim_jockey_yes "1"

        // 為1時，Hunter可以釋放倖存者 (0=不能釋放)
        l4d2_release_victim_hunter_yes "1"

        // 為1時，Charger可以釋放倖存者 (0=不能釋放)
        l4d2_release_victim_charger_yes "1"

        // 為1時，Smoker可以釋放倖存者 (0=不能釋放)
        l4d2_release_victim_smoker_yes "1"

        // Jockey釋放倖存者後不能攻擊的時間 (0=關閉這項功能)
        l4d2_release_victim_jockey_attack_delay "6.0"

        // Hunter釋放倖存者後不能攻擊的時間 (0=關閉這項功能)
        l4d2_release_victim_hunter_attack_delay "6.0"

        // Charger釋放倖存者後不能攻擊的時間 (0=關閉這項功能)
        l4d2_release_victim_charger_attack_delay "6.0"

        // Smoker釋放倖存者後不能攻擊的時間 (0=關閉這項功能)
        l4d2_release_victim_smoker_attack_delay "10.0"

        // 特感抓住人類後需要等待的時間才能釋放倖存者 (避免按錯鍵)
        l4d2_release_victim_release_delay "1.5"

        // 提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框, 3: 螢幕正中間)
        l4d2_release_victim_announce_type "1"
        ```
</details>