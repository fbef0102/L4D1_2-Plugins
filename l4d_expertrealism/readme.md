# Description | 內容
L4D1/2 Real Realism Mode (No Glow + No Hud)

* Video | 影片展示
<br/>None

* Image
	* No Glow + No Hud
	<br/>![l4d_expertrealism_1](image/l4d_expertrealism_1.gif)

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>How does it work?</summary>

	* You can't see the arua
		* Colors of player body
		* Colors of item
	* You can't see the hud
		* Health bar
		* Teammate Health bar
	* You can Walk or Crouch to restore hud and arua temporarily
</details>

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_explosive_cars.cfg
        ```php
		// 0=Plugin off, 1=Plugin on.
		l4d_expertrealism_enable "1"

		// Turns on and off the terror glow highlight effects (Hidden Value Cvar)
		sv_glowenable "1"

		// If 1, Enable Server Glows for survivor team. (0=Hide Glow)
		// Does not work in realism mode
		l4d_survivor_glowenable "0"

		// HUD hidden flag for survivor team. (1=weapon selection, 2=flashlight, 4=all, 8=health, 16=player dead, 32=needssuit, 64=misc, 128=chat, 256=crosshair, 512=vehicle crosshair, 1024=in vehicle)
		l4d_survivor_hidehud "64"
		
		// If 1, Enable HardCore Mode, enable HUD and Glow if survivors hold hardcore_buttons.
		l4d_survivor_hardcore_enable "1"

		// For HardCore Mode, HUD and Glow will show while survivors 1: stay still, 2: Walk(Shift), 4: Crouch(DUCK), 8: Crouch(DUCK) and stay still, add numbers together (0: None).
		l4d_survivor_hardcore_buttons "4"

		// For HardCore Mode, How long to keep the hud and glow enabled after surviors release hardcore_buttons. (0=Instant Disable)
		l4d_survivor_hardcore_keep_time "0.0"

		// For HardCore Mode, How long does it take to enable the hud and glow after surviors hold hardcore_buttons. (0=Instant Enable)
		l4d_survivor_hardcore_wait_time "1.0"

		// For HardCore Mode, changes how message displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
		l4d_survivor_hardcore_announce_type "0"

		// If 1, Enable Server Glows for infected team. (0=Hide Glow)
		// Work in realism mode
		l4d_infected_glowenable "0"
        ```
</details>

* <details><summary>Command | 命令</summary>

	* **Hide one client glow (Admin Flag: ADMFLAG_BAN)**
		```php
		sm_glowoff <name/#userid>
		```

	* **Show one client glow (Admin Flag: ADMFLAG_BAN)**
		```php
		sm_glowon <name/#userid>
		```

	* **Hide your hud flag (Admin Flag: ADMFLAG_BAN)**
		```php
		sm_hidehud <HUD flag>
		```
</details>

* Apply to | 適用於
    ```
    L4D1 Coop/Versus/Survival
    L4D2 Coop/Versus/Survival/Realism/Scavenge
    ```

* <details><summary>Changelog | 版本日誌</summary>

	* v1.0h (2023-3-7)
		* Disable glow for infected team
		* Update cvars

	* v1.5 (2023-2-28)
		* Hide players' name above their head on expert

	* v1.4 (2023-2-27)
		* Remake code
		* Control glow and hud flag
		* Enable Hard Core Hud Mode, hide HUD and Glow by default, Hud will show while survivors are in stillness or holding SLOW_WALK(Shift) or holding DUCK
		* Add Cvars

	* v1.0
        * [Original Plugin by th3y](https://forums.alliedmods.net/showthread.php?t=328015)
</details>

- - - -
# 中文說明
L4D1/2 真寫實模式 (沒有光圈與介面)

* 原理
	* 玩家看不到光圈，包含
		* 隊友光圈
		* 地圖上的物品光圈
	* 玩家看不到介面，包含
		* 血量欄
		* 隊友的血量與頭上名子
	* 玩家可以蹲下或靜走恢復光圈與介面

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4d_explosive_cars.cfg
        ```php
		// 0=關閉插件, 1=啟動插件
		l4d_expertrealism_enable "1"

		// 為1時，啟動伺服器所有光圈的效果 (這是隱藏的官方指令)
		sv_glowenable "1"

		// 0=倖存者玩家看不到任何光圈 (隊友輪廓與物品光圈)，1=倖存者玩家看得到任何光圈
		// 寫實模式下此指令不起作用
		l4d_survivor_glowenable "0"

		// 隱藏介面 1=武器欄, 2=手電筒, 4=全部, 8=血量欄, 16=死亡玩家狀態, 32=needssuit(不會用到), 64=misc(不會用到), 128=聊天室窗, 256=準心, 512=vehicle crosshair(不會用到), 1024=in vehicle(不會用到)
		// 請將想要隱藏的介面，數字相加起來
		l4d_survivor_hidehud "64"
		
		// 為1時，啟動 HardCore模式，倖存者會看不見光圈與介面，必須按下特定的按鈕才會回復恢復光圈與介面
		l4d_survivor_hardcore_enable "1"

		// (HardCore Mode) 倖存者按下特定的按鈕才會回復恢復光圈與介面 1: 站著不動, 2: 靜走 (Shift), 4: 蹲下 (DUCK), 8: 蹲下 (DUCK)且不要動 (0: 關閉這項功能，請將數字相加起來)
		l4d_survivor_hardcore_buttons "4"

		// (HardCore Mode) 倖存者釋放按鈕之後，光圈與介面能維持多久？ (0=瞬間隱藏)
		l4d_survivor_hardcore_keep_time "0.0"

		// (HardCore Mode) 倖存者按下多少秒之後，才會回復恢復光圈與介面 (0=瞬間顯示)
		l4d_survivor_hardcore_wait_time "1.0"

		// (HardCore Mode) 提示該如何顯示. (0: 不提示, 1: 聊天框, 2: 黑底白字框, 3: 螢幕正中間)
		l4d_survivor_hardcore_announce_type "0"

		// 0=特感玩家看不到任何光圈 (倖存者輪廓與隊友輪廓)，1=特感玩家看得到任何光圈
		// 寫實模式下此指令可以起作用
		l4d_infected_glowenable "0"
        ```
</details>
