# Description | 內容
When a Survivor dies, will respawn after a period of time.

* Video | 影片展示
<br/>None

* Image | 圖示
<br/>None

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
    2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/Survivor_Respawn.cfg
		```php
		// Respawn bots if is dead in case of using Take Over.
		l4d_survivorrespawn_botreplaced "1"

		// Amount of times a Survivor can respawn before permanently dying
		l4d_survivorrespawn_deathlimit "3"

		// If 1, disable respawning while the final escape starts (rescue vehicle ready)
		l4d_survivorrespawn_disable_rescue_escape "1"

		// If 1, Allows Bots to respawn automatically when killed
		l4d_survivorrespawn_enablebot "1"

		// If 1, Enables Human Survivors to respawn automatically when killed
		l4d_survivorrespawn_enablehuman "1"

		// Which is first slot weapon will be given to the Survivor (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - AK47 Assault Rifle, 5 - SCAR-L Desert Rifle,
		// 6 - M60 Assault Rifle, 7 - Military Sniper Rifle, 8 - SPAS Shotgun, 9 - Chrome Shotgun, 10 - Smg, 0 - 
		l4d_survivorrespawn_firstweapon "9"

		// Invincible time after survivor respawn.
		l4d_survivorrespawn_invincibletime "10.0"

		// If 1, Enables the respawn limit for Survivors
		l4d_survivorrespawn_limitenable "1"

		// Which prime health unit will be given to the Survivor (1 - Medkit, 2 - Defib, 0 - None)
		l4d_survivorrespawn_primehealth "1"

		// Amount of buffer HP a Survivor will respawn with
		l4d_survivorrespawn_respawnbuffhp "30"

		// Amount of HP a Survivor will respawn with
		l4d_survivorrespawn_respawnhp "70"

		// How many seconds till the Survivor respawns
		l4d_survivorrespawn_respawntimeout "30"

		// Which secondary health unit will be given to the Survivor (1 - Pills, 2 - Adrenaline, 0 - None)
		l4d_survivorrespawn_secondaryhealth "2"

		// Which is second slot weapon will be given to the Survivor (1 - Dual Pistol, 2 - Bat, 3 - Magnum, 0 - Only Pistol)
		l4d_survivorrespawn_secondweapon "1"

		// Which is thrown weapon will be given to the Survivor (1 - Moltov, 2 - Pipe Bomb, 3 - Bile Jar, 0 - None)
		l4d_survivorrespawn_thrownweapon "3"
		```
</details>

* <details><summary>Command | 命令</summary>

	* **Respawn Target/s At Your Crosshair. (Admin Access: ADMFLAG_BAN)**
		```php
		sm_respawn <#UserID | Name>
		```

	* **Create A Menu Of Clients List And Respawn Targets At Your Crosshair. (Admin Access: ADMFLAG_BAN)**
		```php
		sm_respawnexmenu
		```
</details>


* Apply to | 適用於
	```
	L4D1
	L4D2
	```

* Translation Support | 支援翻譯
	```
	English
	繁體中文
	简体中文
	```

* <details><summary>Related Plugin | 相關插件</summary>

	1. [MultiSlots Improved](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dmultislots): When 5+ player joins the server but no any bot can be taken over, this plugin will spawn an alive survivor bot for him.
		> 創造5位以上倖存者遊玩伺服器
	2. [Infected Bots Control Improved](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dinfectedbots): Spawns infected bots in L4D1 versus, and gives greater control of the infected bots in L4D1/L4D2 without being limited by the director.
		> 多特感生成插件，倖存者人數越多，生成的特感越多，且不受遊戲特感數量限制
</details>

* <details><summary>Changelog | 版本日誌</summary>

	```php
	//Ernecio @ 2020
	//HarryPotter @ 2021-2023
	```
	* v3.7 (2023-4-14)
		* More hints and translation

	* v3.6 (2023-4-9)
		* Remove useless cvars
		* Optimize code

	* v3.5
		* [AlliedModder Post](https://forums.alliedmods.net/showpost.php?p=2770929&postcount=14)
		* Remake Code
		* Don't remove dead body
		* If player replaces a dead bot, respawn player after a period of time.
		* Invincible time after survivor respawn by this plugin.
		* Respawn again if player dies within Invincible time.
		* Disable respawning while the final escape starts (rescue vehicle ready)

	* v2.1
		* [Original Plugin by Ernecio](https://forums.alliedmods.net/showthread.php?t=323033)
</details>

- - - -
# 中文說明
當人類玩家死亡時，過一段時間自動復活

* 原理
	* 當然人類死亡之後，過一段時間會在其他活著的玩家身上復活，不必等救援房間
    
* 用意在哪?
    * 適合多人戰役伺服器，讓玩家能持續遊玩不乾等

* 功能
	* 可設置每回合復活次數的上限
	* 可設置復活時間
	* 可設置復活後的裝備與血量

