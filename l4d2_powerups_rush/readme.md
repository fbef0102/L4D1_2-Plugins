# Description | 內容
When a client pops an adrenaline (or pills), various actions are perform faster (reload, melee swings, firing rates)

* [Video | 影片展示](https://youtu.be/nllanhfXYjY)

* Image | 圖示
	* Reload faster, increase firing rates
        > 裝彈快、射速快
	    <br/>![l4d2_powerups_rush_1](image/l4d2_powerups_rush_1.gif)
	* Melee swings faster
        > 砍速快
	    <br/>![l4d2_powerups_rush_2](image/l4d2_powerups_rush_2.gif)

* Apply to | 適用於
    ```
    L4D1
    L4D2
    ```

* <details><summary>Changelog | 版本日誌</summary>

	```php
	//Dusty1029 @ 2010
	//HarryPotter @ 2021-2023
	```
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

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)

* <details><summary>ConVar | 指令</summary>

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

* <details><summary>Command | 命令</summary>

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

- - - -
# 中文說明
服用腎上腺素或藥丸，提升裝彈速度、開槍速度、近戰砍速、動畫起身速度

* 原理
	* 使用腎上腺素之後
        * 裝彈速度變快
        * 開槍速度變快
        * 近戰揮砍速度變快
        * 被震暈的回復速度快

* 功能
	* 管理員可以輸入!giveadren給予腎上腺素或輸入!givepills給予藥丸
    * 可設置提示的位置
    * 可設置提升速度的時間
    * 可設置裝彈速度、開槍速度、近戰砍速