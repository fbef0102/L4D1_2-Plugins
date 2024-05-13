# Description | 內容
When a client pops an adrenaline (or pills), various actions are perform faster (reload, melee swings, firing rates)

* [Video | 影片展示](https://youtu.be/nllanhfXYjY)

* Image | 圖示
    * Reload faster, increase firing rates (裝彈快、射速快)
     <br/>![l4d2_powerups_rush_1](image/l4d2_powerups_rush_1.gif)
    * Melee swings faster (砍速快)
    <br/>![l4d2_powerups_rush_2](image/l4d2_powerups_rush_2.gif)

* Require | 必要安裝
    1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar</summary>

    * cfg/sourcemod/l4d2_powerups_rush.cfg
        ```php
        // (L4D2) If 1, set adrenaline effect time same as l4d_powerups_duration (Progress bar faster, such as use kits faster, save teammates faster... etc)
        l4d_powerups_add_adrenaline_effect "1"

        // If 1, players will be given adrenaline when leaving saferoom? (0 = OFF)
        l4d_powerups_adren_give_on "0"

        // (1.0 = Minspeed(Default speed) 2.0 = 2x speed of recovery
        l4d_powerups_animspeed "2.0"

        // How are players notified when connecting to server about the powerups? (0: Disable, 1:In chat, 2: In Hint Box, 3: Chat/Hint Both)
        l4d_powerups_broadcast_type "1"

        // Changes how countdown timer hint display. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
        l4d_powerups_coutdown_type "2"

        // How long should the duration of the boosts last?
        l4d_powerups_duration "20"

        // Changes how activation hint and deactivation hint display. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
        l4d_powerups_notify_type "1"

        // If 1, players will be given pills when leaving saferoom? (0 = OFF)
        l4d_powerups_pills_give_on "0"

        // The luckey change for pills that will grant the boost. (1 = 1/1  2 = 1/2  3 = 1/3  4 = 1/4  etc.)
        l4d_powerups_pills_luck "3"

        // If 1, enable this plugin ? (0 = Disable)
        l4d_powerups_plugin_on "1"

        // If 1, players will be given either adrenaline or pills when leaving saferoom? (0 = OFF)
        l4d_powerups_random_give_on "0"

        // The interval between bullets fired is multiplied by this value. WARNING: a short enough interval will make SMGs' and rifles' firing accuracy distorted (clamped between 0.02 ~ 0.9)
        l4d_powerups_weaponfiring_rate "0.7"

        // The interval for swinging melee weapon (clamped between 0.3 ~ 0.9)
        l4d_powerups_weaponmelee_rate "0.45"

        // The interval incurred by reloading is multiplied by this value (clamped between 0.2 ~ 0.9)
        l4d_powerups_weaponreload_rate "0.5714"
        ```
</details>

* <details><summary>Command</summary>

    * **Adm gives Adrenaline to all Survivors. (Adm Required: ADMFLAG_CHEATS)**
        ```php
        sm_giveadren
        ```

    * **Adm gives Pills to all Survivors. (Adm Required: ADMFLAG_CHEATS)**
        ```php
        sm_givepills
        ```

    * **Adm gives Random item (Adrenaline or Pills) to all Survivors. (Adm Required: ADMFLAG_CHEATS)**
        ```php
        sm_giverandom
        ```
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
	Russian
	```
</details>

* <details><summary>Changelog | 版本日誌</summary>

    ```php
    //Dusty1029 @ 2010
    //HarryPotter @ 2021-2023
    ```
    * v1.0h (2023-7-5)
        * Add translation

    * v2.2.1
        * [AlliedModder Post](https://forums.alliedmods.net/showpost.php?p=2748223&postcount=15)
        * Remke code
        * Fixed error
        * Fixed Memory leak
        * Powerup returning to normal when player changes team or dies
        * Adrenaline makes you react faster to knockdowns and staggers (Combine with [[L4D2]Adrenaline_Recovery by Lux](https://forums.alliedmods.net/showthread.php?p=2606439))
        * Message display type (chat or hint box or center text)
        * (L4D2) Set adrenaline effect time longer then default 15s

    * v2.0.1
        * [Original plugin from Dusty1029](https://forums.alliedmods.net/showthread.php?t=127513)
</details>

- - - -
# 中文說明
服用腎上腺素或藥丸，提升裝彈速度、開槍速度、近戰砍速、動畫起身速度

* 原理
    * 使用腎上腺素之後
        * 裝彈速度變快
        * 開槍速度變快
        * 近戰揮砍速度變快
        * 被震暈和起身的回復速度快

* <details><summary>指令中文介紹(點我展開)</summary>

    * cfg/sourcemod/l4d2_powerups_rush.cfg
        ```php
        // 為1時, 開啟這個插件 (0 = 關閉插件)
        l4d_powerups_plugin_on "1"

        // (只限二代) 為1時, 腎上腺素的效果時間與官方指令l4d_powerups_duration設置的值相等 (譬如拯救隊友變快、治療變快、罐汽油變快... 等等)
        l4d_powerups_add_adrenaline_effect "1"

        // 為1時, 當玩家離開安全室時給予腎上腺素
        l4d_powerups_adren_give_on "0"

        // 為1時, 當玩家離開安全室時給予止痛藥
        l4d_powerups_pills_give_on "0"

        // 為1時, 當玩家離開安全室時給予止痛藥或腎上腺素(隨機二選一) (0 = OFF)
        l4d_powerups_random_give_on "0"

        // 被震暈以及起身回復的速度 (1.0 = 預設 2.0 = 兩倍快 )
        l4d_powerups_animspeed "2.0"

        // 如何提示給玩家知道藥效的功能? (0: 關閉提示, 1:聊天框, 2: 螢幕下方黑底白字框, 3: 螢幕正中間)
        l4d_powerups_broadcast_type "1"

        // 如何顯示藥效的剩餘時間 (0: 關閉提示, 1:聊天框, 2: 螢幕下方黑底白字框, 3: 螢幕正中間)
        l4d_powerups_coutdown_type "2"

        // 如何顯示服用生效與失效的提示 (0: 關閉提示, 1:聊天框, 2: 螢幕下方黑底白字框, 3: 螢幕正中間)
        l4d_powerups_notify_type "1"

        // 止痛藥丸也會獲得跟腎上腺素一樣的效果，機率為 (1 = 1/1  2 = 1/2  3 = 1/3  4 = 1/4 等等)
        l4d_powerups_pills_luck "3"

        // 腎上腺素的效時間多長?
        l4d_powerups_duration "20"

        // 設置開槍射速 (介於 0.02 ~ 0.9)
        l4d_powerups_weaponfiring_rate "0.7"

        // 設置近戰砍速 (介於 0.3 ~ 0.9)
        l4d_powerups_weaponmelee_rate "0.45"

        // 設置裝彈速度 (介於 0.2 ~ 0.9)
        l4d_powerups_weaponreload_rate "0.5714"
        ```
</details>

* <details><summary>命令中文介紹(點我展開)</summary>

    * **管理員給予所有倖存者腎上腺素 (權限: ADMFLAG_CHEATS)**
        ```php
        sm_giveadren
        ```

    * **管理員給予所有倖存者藥丸 (權限: ADMFLAG_CHEATS)**
        ```php
        sm_givepills
        ```

    * **管理員給予所有倖存者藥丸或腎上腺素 (隨機二選一). (權限: ADMFLAG_CHEATS)**
        ```php
        sm_giverandom
        ```
</details>
