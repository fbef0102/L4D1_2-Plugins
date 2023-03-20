# Description | 內容
L4D1/2 Real Realism Mode (No Glow + No Hud)

* Video | 影片展示
<br/>None

* Image
	* No Glow + No Hud
	<br/>![l4d_expertrealism_1](image/l4d_expertrealism_1.gif)

* Apply to | 適用於
    ```
    L4D1 Coop/Versus/Survival
    L4D2 Coop/Versus/Survival/Realism/Scavenge
    ```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.5 (2023-2-28)
		* Request by eviltechno
		* Hide players' name above their head on expert

	* v1.4 (2023-2-27)
		* Request by eviltechno
		* Remake code
		* Control glow and hud flag
		* Enable Hard Core Hud Mode, hide HUD and Glow by default, Hud will show while survivors are in stillness or holding SLOW_WALK(Shift) or holding DUCK
		* Add Cvars

	* v1.0
        * [Original Plugin by th3y](https://forums.alliedmods.net/showthread.php?t=328015)
</details>

* Require | 必要安裝
	1. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_explosive_cars.cfg
        ```php
		// 0=Plugin off, 1=Plugin on.
		l4d_expertrealism_enable "1"

		// If 1, Enable Server Glows for survivor team. (0=Hide Glow)
		l4d_survivor_glowenable "0"

		// For HardCore Mode, changes how message displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
		l4d_survivor_hardcore_announce_type "0"

		// For HardCore Mode, HUD and Glow will show while survivors 1: stay still, 2: Walk(Shift), 4: Crouch(DUCK), 8: Crouch(DUCK) and stay still, add numbers together (0: None).
		l4d_survivor_hardcore_buttons "4"

		// If 1, Enable HardCore Mode, enable HUD and Glow if survivors hold hardcore_buttons.
		l4d_survivor_hardcore_enable "1"

		// For HardCore Mode, How long to keep the hud and glow enabled after surviors release hardcore_buttons. (0=Instant Disable)
		l4d_survivor_hardcore_keep_time "0.0"

		// For HardCore Mode, How long does it take to enable the hud and glow after surviors hold hardcore_buttons. (0=Instant Enable)
		l4d_survivor_hardcore_wait_time "1.0"

		// HUD hidden flag for survivor team. (1=weapon selection, 2=flashlight, 4=all, 8=health, 16=player dead, 32=needssuit, 64=misc, 128=chat, 256=crosshair, 512=vehicle crosshair, 1024=in vehicle)
		l4d_survivor_hidehud "64"

		// Turns on and off the terror glow highlight effects (Hidden Value Cvar)
		sv_glowenable "1"
        ```
</details>

* <details><summary>Command | 命令</summary>

	* **Hide one client glow (Admin Flag: ADMFLAG_BAN)**
		```php
		sm_glowoff
		```

	* **Show one client glow (Admin Flag: ADMFLAG_BAN)**
		```php
		sm_glowon
		```

	* **Hide your hud flag (Admin Flag: ADMFLAG_BAN)**
		```php
		sm_hidehud
		sm_hud
		```

</details>

- - - -
# 中文說明
L4D1/2 真寫實模式 (沒有光圈與介面)

* 原理
	* 玩家看不到光圈，包含
		* 隊友光圈
		* 地圖上的物品光圈
	* 玩家看不到介面，包含
		* 武器欄
		* 手電筒
		* 血量欄
		* 死亡玩家狀態
		* 隊友的血量與頭上名子
		* 聊天室窗
		* 準心
	* 玩家可以蹲下或靜走恢復光圈與介面

* 功能
	* 可設置倖存者隊伍的光圈開關
	* 可設置要隱藏的介面
	* 可設置特定的動作才能恢復光圈與介面
