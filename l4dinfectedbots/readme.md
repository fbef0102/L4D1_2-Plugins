# Description | 內容
Spawns infected bots in L4D1 versus, and gives greater control of the infected bots in L4D1/L4D2 without being limited by the director.

* Video | 影片展示
<br>None

* Image | 圖示
	* Spawn many Special Infected on the field.
		> 在場上生成多特感
		<br/>![l4dinfectedbots_1](image/l4dinfectedbots_1.jpg)
	* Message
		> 存活的倖存者數量改變時顯示訊息
		<br/>![l4dinfectedbots_2](image/l4dinfectedbots_2.jpg)
	* Join infected team and play in coop/survival/realism mode.
		> 在戰役/寫實/生存模式下加入特感陣營
		<br/>![l4dinfectedbots_3](image/l4dinfectedbots_3.jpg)

* Apply to | 適用於
	```
	L4D1 Coop/Survival/Versus
	L4D2 Coop/Survival/Versus/Realism
	```

* Translation Support | 支援翻譯
	```
	English
	繁體中文
	简体中文
	Russian
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v2.7.8
		* [AlliedModder Post](https://forums.alliedmods.net/showpost.php?p=2699220&postcount=1369)
		* ProdigySim's method for indirectly getting signatures added, created the whole code for indirectly getting signatures so the plugin can now withstand most updates to L4D2! (Thanks to [Shadowysn](https://forums.alliedmods.net/showthread.php?t=320849) and [ProdigySim](https://github.com/ProdigySim/DirectInfectedSpawn)
		* L4D1 Signature update. Credit to [Psykotikism](https://github.com/Psykotikism/L4D1-2_Signatures).
		* Remake Code
		* Add translation support.
		* Update L4D2 "The Last Stand" gamedata, credit to [Lux](https://forums.alliedmods.net/showthread.php?p=2714236), [Shadowysn](https://forums.alliedmods.net/showthread.php?t=320849) and [Machine](https://forums.alliedmods.net/member.php?u=74752)
		* Spawn infected without being limited by the director.
		* Join infected team in coop/survival/realism mode.
		* Light up SI ladders in coop/realism/survival. mode for human infected players. (l4d2 only, didn't work if you host a listen server)
		* Add convars to turn off this plugin.
		* Fixed Hunter Tank Bug in l4d1 coop mode when tank is playable.
		* If you want to fix Camera stuck in coop/versus/realism, install [this plugin by Forgetest](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_fix_deathfall_cam)
		* Fixed Music Bugs when switching to infected team in coop/realism/survival.

	* v1.0.0
		* [Original Plugin By mi123645](https://forums.alliedmods.net/showthread.php?t=99746)
</details>

* Require
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

* Related Plugin | 相關插件
	1. [MultiSlots](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dmultislots): Allows additional survivor players in coop/survival/realism when 5+ player joins the server
		> 創造5位以上倖存者遊玩伺服器
	2. [Zombie Spawn Fix](https://forums.alliedmods.net/showthread.php?t=333351): To Fixed Special Inected and Player Zombie spawning failures in some cases
		> 修正某些時候遊戲導演刻意停止特感生成的問題 (非100%完整解決特感不生成的問題)
	3. [l4d_ssi_teleport_fix](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Special_Infected_%E7%89%B9%E6%84%9F/l4d_ssi_teleport_fix): Teleport AI Infected player (Not Tank) to the teammate who is much nearer to survivors.
		> 傳送比較遠的AI特感到靠近倖存者的特感隊友附近

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4dinfectedbots.cfg
		```php
		// If server has more than 4+ alive players, increase the certain value to 'l4d_infectedbots_default_commonlimit' each 'l4d_infectedbots_add_commonlimit_scale' players joins
		l4d_infectedbots_add_commonlimit "2"

		// If server has more than 4+ alive players, zombie common limit = 'default_commonlimit' + [(alive players - 4) ÷ 'add_commonlimit_scale' × 'add_commonlimit'].
		l4d_infectedbots_add_commonlimit_scale "1"

		// If server has more than 4+ alive players, increase the certain value to 'l4d_infectedbots_max_specials' each 'l4d_infectedbots_add_specials_scale' players joins
		l4d_infectedbots_add_specials "2"

		// If server has more than 4+ alive players, how many special infected = 'max_specials' + [(alive players - 4) ÷ 'add_specials_scale' × 'add_specials'].
		l4d_infectedbots_add_specials_scale "2"

		// If server has more than 4+ alive players, increase the certain value to 'l4d_infectedbots_default_tankhealth' each 'l4d_infectedbots_add_tankhealth_scale' players joins
		l4d_infectedbots_add_tankhealth "500"

		// If server has more than 4+ alive players, how many Tank Health = 'default_tankhealth' + [(alive players - 4) ÷ 'add_tankhealth_scale' × 'add_tankhealth'].
		l4d_infectedbots_add_tankhealth_scale "1"

		// If server has more than 4+ alive players, increase the certain value to 'l4d_infectedbots_tank_limit' each 'l4d_infectedbots_add_tanklimit_scale' players joins
		l4d_infectedbots_add_tanklimit "1"

		// If server has more than 4+ alive players, how many tanks on the field = 'tank_limit' + [(alive players - 4) ÷ 'add_tanklimit_scale' × 'add_tanklimit'].
		l4d_infectedbots_add_tanklimit_scale "3"

		// If 1, adjust and overrides zombie common limit by this plugin.
		l4d_infectedbots_adjust_commonlimit_enable "1"

		// Reduce certain value to maximum spawn timer based per alive player
		l4d_infectedbots_adjust_reduced_spawn_times_on_player "1"

		// If 1, The plugin will adjust spawn timers depending on the gamemode
		l4d_infectedbots_adjust_spawn_times "1"

		// If 1, adjust and overrides tank health by this plugin.
		l4d_infectedbots_adjust_tankhealth_enable "1"

		// 0=Plugin off, 1=Plugin on.
		l4d_infectedbots_allow "1"

		// If 1, announce current plugin status when the number of alive survivors changes.
		l4d_infectedbots_announcement_enable "1"

		// Sets the limit for boomers spawned by the plugin
		l4d_infectedbots_boomer_limit "2"

		// Sets the limit for chargers spawned by the plugin
		l4d_infectedbots_charger_limit "2"

		// If 1, players can join the infected team in coop/survival/realism (!ji in chat to join infected, !js to join survivors)
		l4d_infectedbots_coop_versus "1"

		// If 1, clients will be announced to on how to join the infected team
		l4d_infectedbots_coop_versus_announce "1"

		// If 1, human infected player will spawn as ghost state in coop/survival/realism.
		l4d_infectedbots_coop_versus_human_ghost_enable "1"

		// If 1, attaches red flash light to human infected player in coop/survival/realism. (Make it clear which infected bot is controlled by player)
		l4d_infectedbots_coop_versus_human_light "1"

		// Sets the limit for the amount of humans that can join the infected team in coop/survival/realism
		l4d_infectedbots_coop_versus_human_limit "2"

		//  Players with these flags have access to join infected team in coop/survival/realism. (Empty = Everyone, -1: Nobody)
		l4d_infectedbots_coop_versus_join_access "z"

		// If 1, tank will always be controlled by human player in coop/survival/realism.
		l4d_infectedbots_coop_versus_tank_playable "0"

		// If 1, bots will only spawn when all other bot spawn timers are at zero.
		l4d_infectedbots_coordination "0"

		// Sets Default zombie common limit.
		l4d_infectedbots_default_commonlimit "30"

		// Sets Default Health for Tank, Tank hp is affected by gamemode and difficulty (Example, Set Tank health 4000hp, but in Easy: 3000, Normal: 4000, Versus: 6000, Advanced/Expert: 8000)
		l4d_infectedbots_default_tankhealth "4000"

		// Sets the limit for hunters spawned by the plugin
		l4d_infectedbots_hunter_limit "2"

		// Toggle whether Infected HUD announces itself to clients.
		l4d_infectedbots_infhud_announce "1"

		// Toggle whether Infected HUD is active or not.
		l4d_infectedbots_infhud_enable "1"

		// The spawn timer in seconds used when infected bots are spawned for the first time in a map
		l4d_infectedbots_initial_spawn_timer "10"

		// Sets the limit for jockeys spawned by the plugin
		l4d_infectedbots_jockey_limit "2"

		// Amount of seconds before a special infected bot is kicked
		l4d_infectedbots_lifespan "30"

		// Defines how many special infected can be on the map on all gamemodes(does not count witch on all gamemodes, count tank in all gamemode)
		l4d_infectedbots_max_specials "2"

		// Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).
		l4d_infectedbots_modes ""

		// Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).
		l4d_infectedbots_modes_off ""

		// Turn on the plugin in these game modes. 0=All, 1=Coop/Realism, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.
		l4d_infectedbots_modes_tog "0"

		// If 1, spawn special infected before survivors leave starting safe room area.
		l4d_infectedbots_safe_spawn "0"

		// Disable sm_zs in these gamemode (0: None, 1: coop/realism, 2: versus/scavenge, 4: survival, add numbers together)
		l4d_infectedbots_sm_zs_disable_gamemode "6"

		// Sets the limit for smokers spawned by the plugin
		l4d_infectedbots_smoker_limit "2"

		// If 1, infected bots can spawn on the same game frame (careful, this could cause sever laggy)
		l4d_infectedbots_spawn_on_same_frame "0"

		// The minimum of spawn range for infected. (default: 550, coop/realism only)
		// This cvar will also affect common zombie spawn range and ghost infected player spawn range
		l4d_infectedbots_spawn_range_min "350"

		// Sets the max spawn time for special infected spawned by the plugin in seconds.
		l4d_infectedbots_spawn_time_max "60"

		// Sets the minimum spawn time for special infected spawned by the plugin in seconds.
		l4d_infectedbots_spawn_time_min "40"

		// Where to spawn infected? 0=Near the first ahead survivor. 1=Near the random survivor
		l4d_infectedbots_spawn_where_method "0"

		// If 1, Plugin will disable spawning infected bot when a tank is on the field.
		l4d_infectedbots_spawns_disabled_tank "0"

		// Sets the limit for spitters spawned by the plugin
		l4d_infectedbots_spitter_limit "2"

		// Sets the limit for tanks spawned by the plugin (does not affect director tanks)
		l4d_infectedbots_tank_limit "1"

		// If 1, still spawn tank in final stage rescue (does not affect director tanks)
		l4d_infectedbots_tank_spawn_final "1"

		// When each time spawn S.I., how much percent of chance to spawn tank
		l4d_infectedbots_tank_spawn_probability "5"

		// If 1, The plugin will force all players to the infected side against the survivor AI for every round and map in versus/scavenge
		l4d_infectedbots_versus_coop "0"

		// Amount of seconds before a witch is kicked. (only remove witches spawned by this plugin)
		l4d_infectedbots_witch_lifespan "200"

		// Sets the limit for witches spawned by the plugin (does not affect director witches)
		l4d_infectedbots_witch_max_limit "6"

		// If 1, still spawn witch in final stage rescue
		l4d_infectedbots_witch_spawn_final "0"

		// Sets the max spawn time for witch spawned by the plugin in seconds.
		l4d_infectedbots_witch_spawn_time_max "120.0"

		// Sets the mix spawn time for witch spawned by the plugin in seconds.
		l4d_infectedbots_witch_spawn_time_min "90.0"
		```
</details>

* <details><summary>Command | 命令</summary>
	
	* **(Coop/Realism/Survival only) Join Infected**
		```php
		sm_ji
		```

	* **(Coop/Realism/Survival only) Join Survivors**
		```php
		sm_js
		```

	* **(Infected only) Toggle HUD on/off for themselves**
		```php
		sm_infhud
		```

	* **(Infected only) suicide infected player himself (If infected get stuck or something)**
		```php
		sm_zs
		```

	* **Control special zombies spawn timer (Adm Required: ADMFLAG_SLAY)**
		```php
		sm_timer
		```

	* **Control max special zombies limit (Adm Required: ADMFLAG_SLAY)**
		```php
		sm_zlimit
		```
</details>

* How to set the correct Convar ?
	1. <details><summary>Set special limit</summary>

		```php
		l4d_infectedbots_charger_limit
		l4d_infectedbots_boomer_limit 
		l4d_infectedbots_hunter_limit
		l4d_infectedbots_jockey_limit
		l4d_infectedbots_smoker_limit
		l4d_infectedbots_spitter_limit
		l4d_infectedbots_tank_limit
		```

		These 7 values combined together must equal or exceed ```l4d_infectedbots_max_specials```
		* For example
			```php
			// Good
			l4d_infectedbots_charger_limit 1
			l4d_infectedbots_boomer_limit 1
			l4d_infectedbots_hunter_limit 1
			l4d_infectedbots_jockey_limit 1
			l4d_infectedbots_smoker_limit 1
			l4d_infectedbots_spitter_limit 1
			l4d_infectedbots_tank_limit  0
			l4d_infectedbots_max_specials 6 
			```

			```php
			// Also Good
			l4d_infectedbots_charger_limit 1
			l4d_infectedbots_boomer_limit 2
			l4d_infectedbots_hunter_limit 3
			l4d_infectedbots_jockey_limit 2
			l4d_infectedbots_smoker_limit 2
			l4d_infectedbots_spitter_limit 2
			l4d_infectedbots_tank_limit  1
			l4d_infectedbots_max_specials 10 
			```

			```php
			// Bad
			l4d_infectedbots_charger_limit 0
			l4d_infectedbots_boomer_limit 1
			l4d_infectedbots_hunter_limit 2
			l4d_infectedbots_jockey_limit 0
			l4d_infectedbots_smoker_limit 1
			l4d_infectedbots_spitter_limit 0
			l4d_infectedbots_tank_limit  0
			l4d_infectedbots_max_specials 9 
			```

		> __Note__ Note that it does not counts witch in all gamemode, but it counts tank in all gamemode.
	</details>

	2. <details><summary>Adjust special limit if 5+ alive players</summary>

		* This means that if server has 5+ alive survivors, each 3 players join, max specials limit plus 2.
		<br/>So if there are 10 **ALIVE** survivors, specials limit: 4+2+2 = 8
			```php
			l4d_infectedbots_max_specials "4"
			l4d_infectedbots_add_specials "2"
			l4d_infectedbots_add_specials_scale "3"
			```

		* If you don't want to adjust specials limit, set
			```php
			l4d_infectedbots_add_specials "0"
			```
	</details>

	3. <details><summary>Adjust tank health if 5+ alive players</summary>

		* This means that if server has 5+ alive survivors, each 3 players join, tank health increase 1200hp.
		<br/>So if there are 10 **ALIVE** survivors, tank health: 4000+1200+1200 = 6400hp
			```php
			l4d_infectedbots_adjust_tankhealth_enable "1"
			l4d_infectedbots_default_tankhealth "4000"
			l4d_infectedbots_add_tankhealth "1200"
			l4d_infectedbots_add_tankhealth_scale "3"
			```

		* To close this feature, do not want to overrides tank HP by this plugin, set 
			```php
			l4d_infectedbots_adjust_tankhealth_enable "0"
			```
	</details>

	4. <details><summary>Adjust zombie zommon limit if 5+ alive players</summary>

		* This means that if server has 5+ alive survivors, each 1 players join, zommon limit increase 2.
		<br/>So if there are 10 **ALIVE** survivors, common limit: 30+2+2+2+2+2+2 = 42
			```php
			l4d_infectedbots_adjust_commonlimit_enable "1"
			l4d_infectedbots_default_commonlimit "30"
			l4d_infectedbots_add_commonlimit_scale "1"
			l4d_infectedbots_add_commonlimit "2"
			```

		* To close this feature, do not want to overrides zombie common limit by this plugin, set
			```php
			l4d_infectedbots_adjust_commonlimit_enable "0"
			```
	</details>

	5. <details><summary>Adjust special infected spawn timer</summary>

		* Reduce certain value to spawn timer based per alive player.
		<br/>If there are 5 **ALIVE** survivors in game, special infected spawn timer [max: 60-(5*2) = 50, min: 30-(5*2) = 20]
			```php
			l4d_infectedbots_spawn_time_max "60"
			l4d_infectedbots_spawn_time_min "30"
			l4d_infectedbots_adjust_spawn_times "1"
			l4d_infectedbots_adjust_reduced_spawn_times_on_player "2"
			```

		* To close this feature, do not want to overrides zombie common limit by this plugin, set
			```php
			l4d_infectedbots_adjust_spawn_times "0"
			```
	</details>

	6. <details><summary>How to spawn tank</summary>

		* This means that each time 5% chance to spawn tank instead of infected bot. 
		<br/>Note that if tank limit is reached or is 0, still don't spawn tank (does not affect director tanks)
			```php
			l4d_infectedbots_tank_limit "2"
			l4d_infectedbots_tank_spawn_probability "5"
			```

		* Do not Spawn tank in final stage rescue (does not affect director tanks)
			```php
			l4d_infectedbots_tank_spawn_final "0"
			```
	</details>

	7. <details><summary>Adjust Tank limit if 5+ alive players</summary>

		* This means that if server has 5+ alive survivors, each 5 players join, Tank limit plus 1
		<br/>So if there are 10 alive survivors, tank limit: 2+1 = 3 (Does not affect director tanks)
			```php
			l4d_infectedbots_tank_limit "2"
			l4d_infectedbots_add_tanklimit "1"
			l4d_infectedbots_add_tanklimit_scale "5"
			```

		* If you don't want to adjust tank limit, set
			```php
			l4d_infectedbots_add_tanklimit "0"
			```
	</details>

	8. <details><summary>Play infected team in coop/survival/realism</summary>

		* Only players with "z" access can join the infected team, and there are only 2 infected team slots for real player
			```php
			l4d_infectedbots_coop_versus "1"
			l4d_infectedbots_coop_versus_join_access "z"
			l4d_infectedbots_coop_versus_human_limit "2"
			```

		* If you want everyone can join infected, then set
			```php
			l4d_infectedbots_coop_versus_join_access ""
			```

		* Human infected player will spawn as ghost state in coop/survival/realism.
			```php
			l4d_infectedbots_coop_versus_human_ghost_enable "1" 
			```	

		* AI Tank always be playable by real infected player.
			```php
			l4d_infectedbots_coop_versus_tank_playable "1" 
			```	
	</details>

	9. <details><summary>Spawn range (Coop/Realism only)</summary>

		* Must be careful to adjust, these convars will also affect common zombie spawn range and human ghost infected spawn range.
			```php
			l4d_infectedbots_spawn_range_min "350"
			```

		* Make infected player spawn near very close by survivors for better gaming experience
			```php
			l4d_infectedbots_spawn_range_min "0" 
			```
	</details>

	10. <details><summary>Spawn Infected together</summary>

		* Bots will only spawn when all other bot spawn timers are at zero, and then spawn together.
			```php
			l4d_infectedbots_coordination "1" 
			```

		* Plugin will disable spawning infected bot when a tank is on the field.
			```php
			l4d_infectedbots_spawns_disabled_tank "1" 
			```
	</details>

* Q&A
	1. <details><summary>How to disable this message?</summary>

		![l4dinfectedbots_2](image/l4dinfectedbots_2.jpg)
		```php
		l4d_infectedbots_announcement_enable "0" 
		```
	</details>

	2. <details><summary>How to turn off flashlights on human infected player in coop/survival/realism ?</summary>

		![image](https://user-images.githubusercontent.com/12229810/209463883-ecf76a44-0da1-4044-81d4-68933d1c09d6.png)
		```php
		l4d_infectedbots_coop_versus_human_light "0" 
		```
	</details>

	3. <details><summary>Couldn't find XXXX Spawn position in 5 tries</summary>

		Special Infected can't spawn sometimes, and server console spamming message
		<br/><img width="406" alt="image" src="https://user-images.githubusercontent.com/12229810/209465301-a816bd24-44d7-4e48-93ac-872857115631.png">
		* Reason: It means that the game can not find a position to spawn speical infected, usually happen when director stops spawning speical infected (C1m4 before evelator) or NAV problem (can't find any valid nav area to spawn infected near survivors)

		* I can't do anything about the nav pathfinding, only Valve or map authors can handle nav problem.
		* Recommand to install [Zombie Spawn Fix](https://forums.alliedmods.net/showthread.php?t=333351)
	</details>

* Known Issue
	* In coop/realism mode, the infected/spectator players' screen would be stuck and frozen when they are watching survivor deathfall or final rescue mission failed. Install [l4d_fix_deathfall_cam](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_fix_deathfall_cam) by Forgetest to fix Camera stuck.

- - - -
# 中文說明
多特感生成插件，倖存者人數越多，生成的特感越多，且不受遊戲特感數量限制

* 原理
	* 此插件控制遊戲導演生成系統，用於控制遊戲生成多特感，提升遊戲難度
	* 當倖存者變多時，殭屍數量變多、特感數量變多、Tank數量變多、Tank血量變多
	* 此插件可以讓玩家在戰役/寫實/生存模式下加入特感陣營，用來惡搞戰役玩家XD

* 功能
	1. 見下方指令中文介紹與如何設置正確的指令值

* <details><summary>指令中文介紹 (點我展開)</summary>

	* cfg/sourcemod/l4dmultislots.cfg
		```php
		// 存活的倖存者數量超過4個時，每加入一個'l4d_infectedbots_default_commonlimit'的玩家，就增加一定的值到'l4d_infectedbots_add_commonlimit_scale'
		l4d_infectedbots_add_commonlimit "2"

		// 存活的倖存者數量超過4個時, 最大普通殭屍數量上限 = default_commonlimit + [(存活的倖存者數量-4) ÷ 'add_commonlimit_scale'] × 'add_commonlimit'
		l4d_infectedbots_add_commonlimit_scale "1"

		// 存活的倖存者數量超過4個時，每加入一個'l4d_infectedbots_max_specials'的玩家，就增加一定的值到'l4d_infectedbots_add_specials_scale'
		l4d_infectedbots_add_specials "2"

		// 存活的倖存者數量超過4個時，最大特感數量上限 = max_specials + [(存活的倖存者數量-4) ÷ 'add_specials_scale'] × 'add_specials'
		l4d_infectedbots_add_specials_scale "2"

		// 存活的倖存者數量超過4個時，每加入一個'l4d_infectedbots_default_tankhealth'的玩家，就增加一定的數值到'l4d_infectedbots_add_tankhealth_scale'
		l4d_infectedbots_add_tankhealth "500"

		// 存活的倖存者數量超過4個時，Tank血量上限 = max_specials + [(存活的倖存者數量-4) ÷ 'add_specials_scale'] × 'add_specials']
		l4d_infectedbots_add_tankhealth_scale "1"

		// 存活的倖存者數量超過4個時，每加入一個'l4d_infectedbots_tank_limit'的玩家，就增加一定的值給'l4d_infectedbots_add_tanklimit_scale'
		l4d_infectedbots_add_tanklimit "1"

		// 存活的倖存者數量超過4個時，Tank數量上限 = tank_limit + [(存活的倖存者數量-4) ÷ 'add_tanklimit_scale'] × 'add_tanklimit'
		l4d_infectedbots_add_tanklimit_scale "3"

		// 如果爲1，則啓用根據存活的倖存者數量調整殭屍數量
		l4d_infectedbots_adjust_commonlimit_enable "1"

		// 每增加一位倖存者，則減少(存活的倖存者數量-l4d_infectedbots_adjust_reduced_spawn_times_on_player)復活時間（初始4位倖存者也算在內）
		l4d_infectedbots_adjust_reduced_spawn_times_on_player "1"

		// 如果爲1，則根據倖存者數量調整特感復活時間
		l4d_infectedbots_adjust_spawn_times "1"

		// 如果爲1，則根據倖存者數量修改Tank血量上限
		l4d_infectedbots_adjust_tankhealth_enable "1"

		// 0=關閉插件, 1=開啓插件
		l4d_infectedbots_allow "1"

		// 如果爲1，則當存活的倖存者數量發生變化時宣布插件狀態
		l4d_infectedbots_announcement_enable "1"

		// 插件可生成boomer的最大數量
		l4d_infectedbots_boomer_limit "2"

		// 插件可生成charger的最大數量
		l4d_infectedbots_charger_limit "2"

		// 如果爲1，則玩家可以在戰役/寫實/生存模式中加入感染者(!ji加入感染者 !js加入倖存者)"
		l4d_infectedbots_coop_versus "1"

		// 如果爲1，則通知玩家如何加入到倖存者和感染者
		l4d_infectedbots_coop_versus_announce "1"

		// 如果爲1，則在戰役/寫實/生存模式中，感染者玩家將以靈魂狀態復活
		l4d_infectedbots_coop_versus_human_ghost_enable "1"

		// 如果爲1，則感染者玩家將發出紅色的光
		l4d_infectedbots_coop_versus_human_light "1"

		// 在戰役/倖存者/清道夫中設置通過插件加入到感染者的玩家數量
		l4d_infectedbots_coop_versus_human_limit "2"

		// 有什麽權限的玩家在戰役/寫實/生存模式中可以加入到感染者 (無內容 = 所有人, -1: 無法加入)
		l4d_infectedbots_coop_versus_join_access "z"

		// 如果爲1，玩家可以在戰役/寫實/生存模式中接管Tank
		l4d_infectedbots_coop_versus_tank_playable "0"

		// 如果爲1，則感染者需要等待其他感染者准備好才能一起被插件生成攻擊倖存者
		l4d_infectedbots_coordination "0"

		// 當倖存者數量不超過5人的殭屍數量
		l4d_infectedbots_default_commonlimit "30"

		// 設置Tank默認血量上限, Tank血量上限受到遊戲難度或模式影響 （若Tank血量上限設置爲4000，則簡單難度3000血，普通難度4000血，對抗類型模式6000血，高級/專家難度血量8000血）
		l4d_infectedbots_default_tankhealth "4000"

		// 插件可生成hunter的最大數量
		l4d_infectedbots_hunter_limit "2"

		// 是否提示感染者玩家如何開啓HUD
		l4d_infectedbots_infhud_announce "1"

		// 感染者玩家是否開啓HUD
		l4d_infectedbots_infhud_enable "1"

		// 在地圖第一關離開安全區後多長時間開始刷特
		l4d_infectedbots_initial_spawn_timer "10"

		// 插件可生成jockey的最大數量
		l4d_infectedbots_jockey_limit "2"

		// AI特感生成多少秒後踢出（AI防卡）
		l4d_infectedbots_lifespan "30"

		// 當倖存者數量低于4個及以下時可生成的最大特感數量（必須讓7個特感數量{不包括witch}上限的值加起來超過這個值
		l4d_infectedbots_max_specials "2"

		// 在這些模式中啓用插件，逗號隔開不需要空格（全空=全模式啓用插件）
		l4d_infectedbots_modes ""

		// 在這些模式中關閉插件，逗號隔開不需要空格（全空=無）
		l4d_infectedbots_modes_off ""

		// 在這些模式中啓用插件. 0=全模式, 1=戰役/寫實, 2=倖存者, 4=對抗, 8=清道夫 多個模式的數字加到一起
		l4d_infectedbots_modes_tog "0"

		// 如果爲1，即使倖存者尚未離開安全區域，遊戲依然能生成特感
		l4d_infectedbots_safe_spawn "0"

		// 在哪些遊戲模式中禁止感染者玩家使用sm_zs (0: 無, 1: 戰役/寫實, 2: 對抗/清道夫, 4: 倖存者, 多個模式添加數字輸出)
		l4d_infectedbots_sm_zs_disable_gamemode "6"

		// 插件可生成smoker的最大數量
		l4d_infectedbots_smoker_limit "2"

		// 允許特感在同一個時間點復活沒有誤差 (小心啟動，會影響伺服器卡頓)
		l4d_infectedbots_spawn_on_same_frame 0

		// 特感生成的最小距離 (默認: 550, 僅戰役/寫實)
		// 這個cvar也會影響普通殭屍的生成範圍和靈魂狀態下感染者玩家的復活距離
		l4d_infectedbots_spawn_range_min "350"

		// 設置插件生成的特感最大時間(秒)
		l4d_infectedbots_spawn_time_max "60"

		// 設置插件生成的特感最小時間(秒)
		l4d_infectedbots_spawn_time_min "40"

		// 從哪裡尋找位置復活特感? (0=最前方倖存者附近, 1=隨機的倖存者附近)
		l4d_infectedbots_spawn_where_method "0"

		// 如果爲1，則當Tank存活時禁止特感復活
		l4d_infectedbots_spawns_disabled_tank "0"

		// 插件可生成spitter的最大數量
		l4d_infectedbots_spitter_limit "2"

		// 插件可生成tank的最大數量 （不影響劇情tank）
		l4d_infectedbots_tank_limit "1"

		// 如果爲1，則最後一關救援中插件不會生成Tank（不影響劇情生成的Tank）
		l4d_infectedbots_tank_spawn_final "1"

		// 每次生成一個特感的時候多少概率會變成tank
		l4d_infectedbots_tank_spawn_probability "5"

		// 如果爲1，則在對抗/清道夫模式中，強迫所有玩家加入到感染者
		l4d_infectedbots_versus_coop "0"

		// witch生成多少秒才會踢出（不影響劇情生成的witch）
		l4d_infectedbots_witch_lifespan "200"

		// 插件可生成witch的最大數量 （不影響劇情生成的witch）
		l4d_infectedbots_witch_max_limit "6"

		// 如果爲1，則救援開始時會生成witch
		l4d_infectedbots_witch_spawn_final "0"

		// 插件生成witch的最大時間(秒)
		l4d_infectedbots_witch_spawn_time_max "120.0"

		// 插件生成witch的最小時間(秒)
		l4d_infectedbots_witch_spawn_time_min "90.0"
		```
</details>

* <details><summary>命令中文介紹 (點我展開)</summary>
	
	* **(僅限戰役/寫實/倖存者) 加入到感染者陣營**
		```php
		sm_ji
		```

	* **(僅限戰役/寫實/倖存者) 加入到倖存者陣營**
		```php
		sm_js
		```

	* **(僅限感染者玩家) 開關感染者HUD**
		```php
		sm_infhud
		```

	* **(僅限感染者玩家) 感染者玩家自殺 (讓感染者卡住時可以死亡)**
		```php
		sm_zs
		```

	* **設置特感的生成時間 (權限: ADMFLAG_SLAY)**
		```php
		sm_timer
		```

	* **設置場上特感的數量上限 (權限: ADMFLAG_SLAY)**
		```php
		sm_zlimit
		```
</details>

* 如何設置正確的指令值?
	1. <details><summary>設置特感生成</summary>

		```php
		l4d_infectedbots_charger_limit
		l4d_infectedbots_boomer_limit 
		l4d_infectedbots_hunter_limit
		l4d_infectedbots_jockey_limit
		l4d_infectedbots_smoker_limit
		l4d_infectedbots_spitter_limit
		l4d_infectedbots_tank_limit
		```

		這7個cvar值加在一起必須等於或超過 ```l4d_infectedbots_max_specials```
		* For example
			```php
			// 好的
			l4d_infectedbots_charger_limit 1
			l4d_infectedbots_boomer_limit 1
			l4d_infectedbots_hunter_limit 1
			l4d_infectedbots_jockey_limit 1
			l4d_infectedbots_smoker_limit 1
			l4d_infectedbots_spitter_limit 1
			l4d_infectedbots_tank_limit  0
			l4d_infectedbots_max_specials 6 
			```

			```php
			// 好的
			l4d_infectedbots_charger_limit 1
			l4d_infectedbots_boomer_limit 2
			l4d_infectedbots_hunter_limit 3
			l4d_infectedbots_jockey_limit 2
			l4d_infectedbots_smoker_limit 2
			l4d_infectedbots_spitter_limit 2
			l4d_infectedbots_tank_limit  1
			l4d_infectedbots_max_specials 10 
			```

			```php
			// 爛，沒設置好
			l4d_infectedbots_charger_limit 0
			l4d_infectedbots_boomer_limit 1
			l4d_infectedbots_hunter_limit 2
			l4d_infectedbots_jockey_limit 0
			l4d_infectedbots_smoker_limit 1
			l4d_infectedbots_spitter_limit 0
			l4d_infectedbots_tank_limit  0
			l4d_infectedbots_max_specials 9 
			```

		> __Note__ 請注意，插件在所有遊戲模式中都不會計算witch的數量，但在所有遊戲模式中都會計算tank的數量
	</details>

	2. <details><summary>如果第5位以上存活的倖存者，則調整特感最大生成數量</summary>

		* 例如: 如果第5位以上存活的倖存者，每3個玩家加入，最大的特殊限制加2
		<br/>因此，如果有10個存活的倖存者，則特感最大生成數量爲：4+2+2=8
			```php
			l4d_infectedbots_max_specials "4"
			l4d_infectedbots_add_specials "2"
			l4d_infectedbots_add_specials_scale "3"
			```

		* 如果不想改變特感生成數量，可以設置
			```php
			l4d_infectedbots_add_specials "0"
			```
	</details>

	3. <details><summary>如果第5位以上存活的倖存者，則調整Tank血量</summary>

		* 例如: 有第5位以上存活的倖存者，每3個玩家加入，Tank的血量就會增加1200
		<br/>因此，如果有10個存活的倖存者，Tank血量爲：4000+1200+1200=6400hp
			```php
			l4d_infectedbots_adjust_tankhealth_enable "1"
			l4d_infectedbots_default_tankhealth "4000"
			l4d_infectedbots_add_tankhealth "1200"
			l4d_infectedbots_add_tankhealth_scale "3"
			```

		* 如果想關閉這個功能，不想讓這個插件改變Tank血量，請設置
			```php
			l4d_infectedbots_adjust_tankhealth_enable "0"
			```
	</details>

	4. <details><summary>如果第5位以上存活的倖存者，則調整普通殭屍最大數量</summary>

		* 例如：有第5位以上存活的倖存者，每一個玩家加入, 普通殭屍最大數量將會增加2個
		<br/>因此，如果有10個存活的倖存者，普通殭屍數量爲: 30+2+2+2+2+2+2 = 42
			```php
			l4d_infectedbots_adjust_commonlimit_enable "1"
			l4d_infectedbots_default_commonlimit "30"
			l4d_infectedbots_add_commonlimit_scale "1"
			l4d_infectedbots_add_commonlimit "2"
			```

		* 如果想關閉這個功能，不想讓這個插件改變殭屍最大數量，請設置
			```php
			l4d_infectedbots_adjust_commonlimit_enable "0"
			```
	</details>

	5. <details><summary>調整特感生成時間</summary>

		* 根據每個存活的倖存者，減少一定數值的特感生成時間
		<br/>如果有5個存活的倖存者，則特感生成時間爲：[最長時間: 60-(5*2) = 50, 最短時間: 30-(5*2) = 20]
			```php
			l4d_infectedbots_spawn_time_max "60"
			l4d_infectedbots_spawn_time_min "30"
			l4d_infectedbots_adjust_spawn_times "1"
			l4d_infectedbots_adjust_reduced_spawn_times_on_player "2"
			```

		* 如果想關閉這個功能，請設置 
			```php
			l4d_infectedbots_adjust_spawn_times "0"
			```
	</details>

	6. <details><summary>如何生成Tank</summary>

		* 每次生成特感都有5%的幾率生成tank
		<br/>請注意，如果達到了Tank數量上限或生成tank的概率爲0%，仍然不會産生Tank (不影響遊戲生成的Tank)
			```php
			l4d_infectedbots_tank_limit "2"
			l4d_infectedbots_tank_spawn_probability "5"
			```

		* 如果想在最後救援時不生成tank(不影響遊戲生成的Tank)，請設置
			```php
			l4d_infectedbots_tank_spawn_final "0"
			```
	</details>

	7. <details><summary>如果第5位以上存活的倖存者，則調整tank生成限制</summary>

		* 這意味著如果有第5位以上存活的倖存者，每5個玩家加入，tank可生成上限數量加1
		<br/>因此，如果有10個存活的倖存者，tank可生成上限數量爲: 2+1=3 (不影響遊戲生成的Tank)
			```php
			l4d_infectedbots_tank_limit "2"
			l4d_infectedbots_add_tanklimit "1"
			l4d_infectedbots_add_tanklimit_scale "5"
			```

		* 如果想關閉這個功能，請設置 
			```php
			l4d_infectedbots_add_tanklimit "0"
			```
	</details>

	8. <details><summary>在戰役/倖存者/寫實模式下成為感染者</summary>

		* 例如：只有擁有 "z "權限的玩家才能加入感染者陣營，且感染者只能有2個名額。
			```php
			l4d_infectedbots_coop_versus "1"
			l4d_infectedbots_coop_versus_join_access "z"
			l4d_infectedbots_coop_versus_human_limit "2"
			```

		* 如果想所有玩家可以加入感染者陣營，請設置
			```php
			l4d_infectedbots_coop_versus_join_access ""
			```

		* 在戰役/倖存者/寫實中，感染者玩家將以靈魂狀態下復活
			```php
			l4d_infectedbots_coop_versus_human_ghost_enable "1" 
			```	

		* 感染者玩家可以接管在場上的tank:
			```php
			l4d_infectedbots_coop_versus_tank_playable "1" 
			```	
	</details>

	9. <details><summary>特感生成距離 (僅限戰役/寫實)</summary>

		* 請注意！這個數字也會影響普通殭屍的生成範圍和靈魂狀態下感染者玩家的復活範圍。
			```php
			l4d_infectedbots_spawn_range_min "350"
			```

		* 讓特感可以在非常接近幸存者的地方復活，以獲得更好的遊戲體驗。
			```php
			l4d_infectedbots_spawn_range_min "0" 
			```
	</details>

	10. <details><summary>一次性生成全部特感</summary>

		* 只有當所有AI特感的復活時間爲零時，才會生成特感，然後一起生成。
			```php
			l4d_infectedbots_coordination "1" 
			```

		* 當場上有存活的tank時停止生成AI特感。
			```php
			l4d_infectedbots_spawns_disabled_tank "1" 
			```
	</details>

* Q&A問題
	1. <details><summary>如何關閉這個消息?</summary>

		![Message](https://user-images.githubusercontent.com/12229810/209463323-5c9336af-1883-4a20-a7f5-7d83d4357587.png)
		```php
		l4d_infectedbots_announcement_enable "0" 
		```
	</details>

	2. <details><summary>在戰役/寫實/生存下如何關閉特感真人玩家的紅色光燈?</summary>

		![image](https://user-images.githubusercontent.com/12229810/209463883-ecf76a44-0da1-4044-81d4-68933d1c09d6.png)
		```php
		l4d_infectedbots_coop_versus_human_light "0" 
		```
	</details>

	3. <details><summary>為什麼有些時候不會有特感生成?</summary>

		* 問題：特感無法生成，然後伺服器後台經常冒出```Couldn't find xxxxx Spawn position in X tries```
		<br/><img width="406" alt="image" src="https://user-images.githubusercontent.com/12229810/209465301-a816bd24-44d7-4e48-93ac-872857115631.png">

		* 分析：AI特感與普通感染者生成的範圍是受到限制的，在官方的預設當中，是距離人類550~1500公尺範圍之間找位置復活，如果在這範圍內找不到，那就不會有特感與普通感染者。

		* 原因一：地圖故意作者為之，為了怕人類滅團所以停止特感生成一段時間，常發生在三方圖開啟地圖機關的時候或者開啟最終章救援無線電之前
			* 解決方式法一：去跟地圖作者抱怨
  			* 解決方式法二：自己修改地圖vscript
			* 解決方式法三：推薦安裝[Zombie Spawn Fix](https://forums.alliedmods.net/showthread.php?t=333351)，修正某些時候遊戲導演刻意停止特感生成的問題 (非100%完整解決特感不生成的問題)
		2. 原因二：地圖問題，找不到附近的地形特感，常發生在NAV沒有做好的爛圖或是人類已經抵達地圖終點，譬如死亡都心第一關人類抵達終點安全室的附近
			* 解決方式法一：去跟地圖作者抱怨
  			* 解決方式法二：自己修改地圖的NAV
		3. 原因三：所有能生成特感的地方都被倖存者看見，導致特感找不到位置無法復活，常發生在地圖太寬闊的地形，沒有任何障礙物掩護。
			* 解決方式法一：去跟地圖作者抱怨
			* 解決方式法二：自己修改地圖的NAV
			* 解決方式法三：把特感生成範圍弄大點，修改官方指令
				* 有副作用，會導致特感生成得太遠攻擊不到倖存者，不建議此方法
				```php
				// 預設是1500
				sm_cvar z_spawn_range 2500
				```
			* 解決方式法四：請倖存者隊伍移動位置，讓特感可以生成
		4. 原因四：有設置指令值```director_no_specials 1```，這會關閉遊戲導演系統
			* 解決方式：```sm_cvar director_no_specials 0```
	</details>

* 已知問題
	* 在戰役/寫實/生存下，特感玩家的視角畫面會卡住，常發生在倖存者滅團重新回合的時候，如果要修正請安裝[l4d_fix_deathfall_cam](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_fix_deathfall_cam)，由Forgetest大佬開發的插件修正玩家鏡頭卡住等問題