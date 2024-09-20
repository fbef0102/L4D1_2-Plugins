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
		// 0=Plugin off, 1=Plugin on.
		l4d2_final_rescue_arrive_time_enable "0"

		// If 1, Enables Human Survivors to respawn automatically when killed
		l4d_survivorrespawn_human "1"

		// If 1, Allows Bots to respawn automatically when killed
		l4d_survivorrespawn_bot "1"

		// If 1, Enables the respawn limit for Survivors
		l4d_survivorrespawn_limitenable "1"

		// Amount of times a Survivor can respawn before permanently dying
		l4d_survivorrespawn_deathlimit "3"

		// How many seconds until the Survivor respawns
		l4d_survivorrespawn_respawntimeout "30"

		// Amount of HP a Survivor will respawn with
		l4d_survivorrespawn_respawnhp "70"

		// Amount of buffer HP a Survivor will respawn with
		l4d_survivorrespawn_respawnbuffhp "30"

		// Respawn bots if is dead in case of using Take Over.
		l4d_survivorrespawn_botreplaced "1"

		// Invincible time after survivor respawn.
		l4d_survivorrespawn_invincibletime "10.0"

		// If 1, disable respawning while the final escape starts (rescue vehicle ready)
		l4d_survivorrespawn_disable_rescue_escape "1"

		// (L4D2) First slot weapon for repawn Survivor (1-Autoshot, 2-SPAS, 3-M16, 4-SCAR, 5-AK47, 6-SG552, 7-Mil Sniper, 8-AWP, 9-Scout, 10=Hunt Rif, 11=M60, 12=GL, 13-SMG, 14-Sil SMG, 15=MP5, 16-Pump Shot, 17=Chrome Shot, 18=Rand T1, 19=Rand T2, 20=Rand T3, 0=off)
		// GL = Grenade Launcher
		// Rand T3 = M60 or Grenade Launcher
		l4d_survivorrespawn_firstweapon "1"

		// (L4D2) Second slot weapon for new 5+ Survivor (1- Dual Pistol, 2-Magnum, 3-Chainsaw, 4=Melee weapon from map, 5=Random, 0=Only Pistol)
		l4d_survivorrespawn_secondweapon "4"

		// (L4D2) Third slot weapon for repawn Survivor (1 - Moltov, 2 - Pipe Bomb, 3 - Bile Jar, 4=Random, 0=off)
		l4d_survivorrespawn_thirdweapon "4"

		// (L4D2) Fourth slot weapon for repawn Survivor (1 - Medkit, 2 - Defib, 3 - Incendiary Pack, 4 - Explosive Pack, 5=Random, 0=off)
		l4d_survivorrespawn_forthweapon "1"

		// (L4D2) Fifth slot weapon for repawn Survivor (1 - Pills, 2 - Adrenaline, 3=Random, 0=off)
		l4d_survivorrespawn_fifthweapon "2"

		// (L4D1) First slot weapon for new 5+ Survivor (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - smg, 5 - shotgun, 6=Random T1, 7=Random T2, 0=off)
		l4d_survivorrespawn_firstweapon "6"

		// (L4D1) Second slot weapon for new 5+ Survivor (1 - Dual Pistol, 0=Only Pistol)
		l4d_survivorrespawn_secondweapon "1"

		// (L4D1) Third slot weapon for new 5+ Survivor (1 - Moltov, 2 - Pipe Bomb, 3=Random, 0=off)
		l4d_survivorrespawn_thirdweapon "3"

		// (L4D1) Fourth slot weapon for new 5+ Survivor (1 - Medkit, 0=off)
		l4d_survivorrespawn_forthweapon "0"

		// (L4D1) Fifth slot weapon for new 5+ Survivor (1 - Pills, 0=off)
		l4d_survivorrespawn_fifthweapon "0"
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

* <details><summary>Translation Support | 支援翻譯</summary>

	```
	English
	繁體中文
	简体中文
	Russian
	```
</details>

* <details><summary>Related Plugin | 相關插件</summary>

	1. [MultiSlots Improved](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dmultislots): When 5+ player joins the server but no any bot can be taken over, this plugin will spawn an alive survivor bot for him.
		> 創造5位以上倖存者遊玩伺服器
	2. [Infected Bots Control Improved](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dinfectedbots): Spawns multi infected bots in any mode + allows playable special infected in coop/survival + unlock infected slots (10 VS 10 available)
		> 多特感生成插件，倖存者人數越多，生成的特感越多，且不受遊戲特感數量限制
</details>

* <details><summary>Changelog | 版本日誌</summary>

	* v4.1 (2024-5-10)
		* Give melee weapons from the meleeweapons StringTable

	* v4.0 (2024-3-5)
		* Update Translation

	* v3.9 (2024-2-26)
	* v3.8 (2024-1-23)
		* Update Cvars

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

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/Survivor_Respawn.cfg
		```php
		// 0=關閉插件, 1=啟動插件
		l4d2_final_rescue_arrive_time_enable "0"

		// 為1時，倖存者玩家死亡之後，過一段時間自動復活
		l4d_survivorrespawn_human "1"

		// 為1時，倖存者bot死亡之後，過一段時間自動復活
		l4d_survivorrespawn_bot "1"

		// 為1時，倖存者死亡會有次數限制
		l4d_survivorrespawn_limitenable "1"

		// 每回合復活次數的上限
		l4d_survivorrespawn_deathlimit "3"

		// 復活時間
		l4d_survivorrespawn_respawntimeout "30"

		// 復活的實血值 (預設 80)
		l4d_survivorrespawn_respawnhp "70"

		// 復活的虛血值 (預設 20)
		l4d_survivorrespawn_respawnbuffhp "30"

		// 為1時，如果bot取代的是死亡的玩家則也會復活
		l4d_survivorrespawn_botreplaced "1"

		// 復活後的無敵時間
		l4d_survivorrespawn_invincibletime "10.0"

		// 為1時，救援載具來臨之後不能再復活
		l4d_survivorrespawn_disable_rescue_escape "1"

		// (L4D2) 復活後給予的主武器 (1-Autoshot, 2-SPAS, 3-M16, 4-SCAR, 5-AK47, 6-SG552, 7-Mil Sniper, 8-AWP, 9-Scout, 10=Hunt Rif, 11=M60, 12=GL, 13-SMG, 14-Sil SMG, 15=MP5, 16-Pump Shot, 17=Chrome Shot, 18=隨機T1武器, 19=隨機T2武器, 20=隨機T3武器, 0=關閉)
		// GL = 榴彈發射器
		// 隨機T3武器 = M60機槍 或 榴彈發射器
		l4d_survivorrespawn_firstweapon "1"

		// (L4D2) 給予新生成的倖存者Bot副武器 (1- 雙手槍, 2-沙漠之鷹, 3-電鋸, 4=任一把近戰武器, 5=隨機, 0=只有一把手槍)
		l4d_survivorrespawn_secondweapon "4"

		// (L4D2) 復活後給予的投擲物品 (1 - 火瓶, 2 - 土製炸彈, 3 - 膽汁, 4=隨機, 0=關閉)
		l4d_survivorrespawn_thirdweapon "4"

		// (L4D2) 復活後給予的醫療物品 (1 - 治療包, 2 - 電擊器, 3 - 火焰包, 4 - 高爆彈, 5=隨機, 0=關閉)
		l4d_survivorrespawn_forthweapon "1"

		// (L4D2) 復活後給予的副醫療物品 (1 - 藥丸, 2 - 腎上腺素, 3=隨機, 0=關閉)
		l4d_survivorrespawn_fifthweapon "2"

		// (L4D1) 復活後給予的主武器 (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - smg, 5 - shotgun, 6=隨機T1武器, 7=隨機T2武器, 0=關閉)
		l4d_survivorrespawn_firstweapon "6"

		// (L4D1) 復活後給予的副武器 (1 - 雙手槍, 0=只有一把手槍)
		l4d_survivorrespawn_secondweapon "1"

		// (L4D1) 復活後給予的投擲物品 (1 - 火瓶, 2 - 土製炸彈, 3=隨機, 0=關閉)
		l4d_survivorrespawn_thirdweapon "3"

		// (L4D1) 復活後給予的醫療物品 (1 - 治療包, 0=關閉)
		l4d_survivorrespawn_forthweapon "0"

		// (L4D1) 復活後給予的副醫療物品 (1 - 藥丸, 0=關閉)
		l4d_survivorrespawn_fifthweapon "0"
		```
</details>

