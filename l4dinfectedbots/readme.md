# Description | 內容
Spawns multi infected bots in any mode + allows playable special infected in coop/survival + unlock infected slots (10 VS 10 available)

* Video | 影片展示
<br>None

* Image | 圖示
	* Spawn infected bots without limit 
	<br/>![l4dinfectedbots_1](image/l4dinfectedbots_1.jpg)
	<br/>![l4dinfectedbots_2](image/l4dinfectedbots_2.jpg)
	* Join infected team and play in coop/survival/realism mode. (在戰役/寫實/生存模式下加入特感陣營)
	<br/>![l4dinfectedbots_3](image/l4dinfectedbots_3.jpg)

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)

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

		// If 1, The plugin will adjust spawn timers depending on the gamemode and human players on infected team
		l4d_infectedbots_adjust_spawn_times "1"

		// If 1, adjust and overrides tank health by this plugin.
		l4d_infectedbots_adjust_tankhealth_enable "1"

		// 0=Plugin off, 1=Plugin on.
		l4d_infectedbots_allow "1"

		// If 1, announce current plugin status when the number of alive survivors changes.
		l4d_infectedbots_announcement_enable "1"

		// Sets the limit for boomers spawned by the plugin
		l4d_infectedbots_boomer_limit "100"

		// The weight for a boomer spawning [0-100]
		l4d_infectedbots_boomer_weight "100"

		// If 1, including 4+ alive and dead players in the server.
		l4d_infectedbots_calculate_including_dead_player "0"

		// Sets the limit for chargers spawned by the plugin
		l4d_infectedbots_charger_limit "2"

		// The weight for a charger spawning [0-100]
		l4d_infectedbots_charger_weight "100"

		// If 1, players can join the infected team in coop/survival/realism (!ji in chat to join infected, !js to join survivors)
		// Enable this also allow game to continue with survivor bots
		l4d_infectedbots_coop_versus "0"

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

		// If 1, disable infected bots spawning in versus/scavenge mode. (Does not disable witch spawn and does not affect director boss spawn)
		l4d_infectedbots_disable_infected_bots "0"

		// Sets the limit for hunters spawned by the plugin
		l4d_infectedbots_hunter_limit "2"

		// The weight for a hunter spawning [0-100]
		l4d_infectedbots_hunter_weight "100"

		// Toggle whether Infected HUD announces itself to clients.
		l4d_infectedbots_infhud_announce "1"

		// Toggle whether Infected HUD is active or not.
		l4d_infectedbots_infhud_enable "1"

		// The spawn timer in seconds used when infected bots are spawned for the first time in a map
		l4d_infectedbots_initial_spawn_timer "10"

		// Sets the limit for jockeys spawned by the plugin
		l4d_infectedbots_jockey_limit "2"

		// The weight for a jockey spawning [0-100]
		l4d_infectedbots_jockey_weight "100"

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

		// If 1, Scale spawn weights with the limits of corresponding SI
		l4d_infectedbots_scale_weights "0"

		// Disable sm_zs in these gamemode (0: None, 1: coop/realism, 2: versus/scavenge, 4: survival, add numbers together)
		l4d_infectedbots_sm_zs_disable_gamemode "6"

		// Sets the limit for smokers spawned by the plugin
		l4d_infectedbots_smoker_limit "2"

		// The weight for a smoker spawning [0-100]
		l4d_infectedbots_smoker_weight "100"

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

		// The weight for a spitter spawning [0-100]
		l4d_infectedbots_spitter_weight "100"

		// Sets the limit for tanks spawned by the plugin (does not affect director tanks)
		l4d_infectedbots_tank_limit "1"

		// If 1, still spawn tank in final stage rescue (does not affect director tanks)
		l4d_infectedbots_tank_spawn_final "1"

		// When each time spawn S.I., how much percent of chance to spawn tank
		l4d_infectedbots_tank_spawn_probability "5"

		// If 1, The plugin will force all players to the infected side against the survivor AI for every round and map in versus/scavenge
		// Enable this also allow game to continue with survivor bots
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
	1. <details><summary>Set Max Special Limit</summary>

		```php
		l4d_infectedbots_charger_limit
		l4d_infectedbots_boomer_limit 
		l4d_infectedbots_hunter_limit
		l4d_infectedbots_jockey_limit
		l4d_infectedbots_smoker_limit
		l4d_infectedbots_spitter_limit
		```

		These 6 values combined together must equal or exceed ```l4d_infectedbots_max_specials```
		* For example
			```php
			// Good
			l4d_infectedbots_charger_limit 1
			l4d_infectedbots_boomer_limit 1
			l4d_infectedbots_hunter_limit 1
			l4d_infectedbots_jockey_limit 1
			l4d_infectedbots_smoker_limit 1
			l4d_infectedbots_spitter_limit 1
			l4d_infectedbots_max_specials 6 
			```

			```php
			// Also Good
			l4d_infectedbots_charger_limit 1
			l4d_infectedbots_boomer_limit 2
			l4d_infectedbots_hunter_limit 4
			l4d_infectedbots_jockey_limit 2
			l4d_infectedbots_smoker_limit 2
			l4d_infectedbots_spitter_limit 2
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
			l4d_infectedbots_max_specials 9 
			```

		> __Note__ 
		<br/>1. Max Special Limit does not count witch, but it counts tank in all gamemode.
		<br/>2. In Versus/Scavenge, Max Special Limit = infected team slots

		> __Warning__ 
		<br/>🟥Infected limit + numbers of survivor + spectators can not exceed 32 slots, otherwise server fails to spawn infected and becomes super lag
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

		> __Note__ 
		<br/>In Versus/Scavenge, Max Special Limit = infected team slots
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

		* Tank hp is affected by gamemode and difficulty eventually. For example, set Tank health 4000hp, but
			* In Easy: 4000 * 0.75 = 3000 
			* In Normal: 4000 * 1.0 = 4000
			* In Advanced/Expert: 4000 * 2.0 = 8000
			* In Versus/Scavenge mode: 4000 * 1.5 = 6000
	</details>

	4. <details><summary>Adjust zombie common limit if 5+ alive players</summary>

		* This means that if server has 5+ alive survivors, each 1 players join, common limit increase 2.
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
		<br/>If there are 5 **ALIVE** survivors in game, special infected spawn timer [max: 60-(5x2) = 50, min: 30-(5x2) = 20]
			```php
			l4d_infectedbots_spawn_time_max "60"
			l4d_infectedbots_spawn_time_min "30"
			l4d_infectedbots_adjust_spawn_times "1"
			l4d_infectedbots_adjust_reduced_spawn_times_on_player "2"
			```

		* To close this feature, do not want to overrides special infected limit by this plugin, set
			```php
			l4d_infectedbots_adjust_spawn_times "0"
			```

		* How to control Human Infected spawn time in versus/scavenge mode?
			* Human infected spawn timer controlled by the official cvars
				```php
				sm_cvar z_ghost_delay_min "20"
				sm_cvar z_ghost_delay_max "30"
				```

			* Also controlled by "human infected count" and "infected team slot"，here is formula
				```php
				// In L4D2, if there are more than 4 human infected players，"human infected count" = 4
				// In L4D2, if infected team slot is above 4，"infected team slot" = 4
				Minimum spawn time: z_ghost_delay_min * (human infected count ÷ infected team slot)
				Maximum spawn time: z_ghost_delay_max * (human infected count ÷ infected team slot)
				```

			* For example
				```php
				// human infected count：3，infected team slot：4，z_ghost_delay_min: 30，z_ghost_delay_max: 40
				In L4D2, Human infected player spawn time is: [Minimum: 30 * (3÷4) = 22.5s, Maximum: 40 * (3÷4) = 30s]
				In L4D1, Human infected player spawn time is: [Minimum: 30 * (3÷4) = 22.5s, Maximum: 40 * (3÷4) = 30s]

				// human infected count：1，infected team slot：1，z_ghost_delay_min: 3，z_ghost_delay_max: 3
				In L4D2, Human infected player spawn time is: 3 * (1÷1) = 3s
				In L4D1, Human infected player spawn time is: 3 * (1÷1) = 3s

				// human infected count：2，infected team slot：4，z_ghost_delay_min: 18，z_ghost_delay_max: 18
				In L4D2, Human infected player spawn time is: 18 * (2÷4) = 9s
				In L4D1, Human infected player spawn time is: 18 * (2÷4) = 9s

				// human infected count：3，infected team slot：8，z_ghost_delay_min: 20，z_ghost_delay_max: 20
				In L4D2, Human infected player spawn time is: 20 * (3÷4) = 15s
				In L4D1, Human infected player spawn time is: 20 * (2÷8) = 5s

				// human infected count：4，infected team slot：8，z_ghost_delay_min: 20，z_ghost_delay_max: 20
				In L4D2, Human infected player spawn time is: 20 * (4÷4) = 20s
				In L4D1, Human infected player spawn time is: 20 * (4÷8) = 10s

				// human infected count：7，infected team slot：8，z_ghost_delay_min: 20，z_ghost_delay_max: 20
				In L4D2, Human infected player spawn time is: 20 * (4÷4) = 20s
				In L4D1, Human infected player spawn time is: 20 * (7÷8) = 17.5s
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

		* Tank limit = The number of tanks on the field at the same time
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
		* Also allow game to continue with survivor bots
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

		* Must be careful to adjust, this cvar will also affect common zombie spawn range and human ghost infected spawn range.
			```php
			l4d_infectedbots_spawn_range_min "350"
			```

		* Make infected player spawn near very close by survivors for better gaming experience
			```php
			l4d_infectedbots_spawn_range_min "0" 
			```

		> __Warning__ 
		<br/>In Versus/Scavenge, this cvar will also affect human infected player ghost spawn range
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

	11. <details><summary>Set Weight of Special Infected</summary>

		* Increase chance to spawn specific special infected except for tank and witch, For example
			```php
			// Most of time, spawn hunter and charger on the field
			// If hunter limit reached and charger limit reached, spawn other infected
			l4d_infectedbots_boomer_weight "5"
			l4d_infectedbots_charger_weight "90"
			l4d_infectedbots_hunter_weight "100"
			l4d_infectedbots_jockey_weight "10"
			l4d_infectedbots_smoker_weight "5"
			l4d_infectedbots_spitter_weight "8"
			```

		* Scale spawn weights with the limits of corresponding SI
			```php
			// If 1, The weight of infected would be increased if limit is greater than others
			// If 1, The weight of infected would be decreased if there are same type of infecteds on the field
			l4d_infectedbots_scale_weights "1" 
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
		* Reason: It means that the game can not find a position to spawn special infected, usually happen when director stops spawning special infected (C1m4 before evelator) or NAV problem (can't find any valid nav area to spawn infected near survivors)

		* 🟥Infected limit + numbers of survivor + spectators can not exceed 32 slots, otherwise server fails to spawn S.I.
		* I can't do anything about the nav pathfinding, only Valve or map authors can handle nav problem.
		* Recommand to install [Zombie Spawn Fix](https://forums.alliedmods.net/showthread.php?t=333351)
	</details>

	4. <details><summary>Count 5+ players including dead</summary>

		* Adjust special limit, tank health, zombie common, Tank limit based on 5+ alive and dead survivor players
			```php
			l4d_infectedbots_calculate_including_dead_player "1"
			```
	</details>

	5. <details><summary>Disable infected bots spawning in versus/scavenge mode.</summary>

		* Only allow real infected players to spawn on the field in versus/scavenge mode.
			```php
			l4d_infectedbots_disable_infected_bots "1"
			```
	</details>

	6. <details><summary>Only 18 infected bots can spawn in server?</summary>

		* By default, l4d server max player slots is 18. Go install [l4dtoolz](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/English/Server/Install_Other_File#l4dtoolz) and set Max. players=32 (Can't increase more)
		<br/>![l4dinfectedbots_4](image/l4dinfectedbots_4.jpg)

	</details>

* Known Issue
	1. In coop/realism mode, the infected/spectator players' screen would be stuck and frozen when they are watching survivor deathfall or final rescue mission failed
		> Install [l4d_fix_deathfall_cam](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_fix_deathfall_cam) to fix camera stuck
	2. In coop/realism mode, the infected player plays as second tank on final chapter, the rescue vehicle show up immediately
		> Install [l4d2_scripted_tank_stage_fix](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d2_scripted_tank_stage_fix) to fix

* Apply to | 適用於
	```
	L4D1 coop/versus/realism/survival/scavenge + all mutation modes
	L4D2 all modes
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

	1. [MultiSlots](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4dmultislots): Allows additional survivor players in server when 5+ player joins the server
		> 創造5位以上倖存者遊玩伺服器
	2. [AI_HardSI](https://github.com/fbef0102/L4D2-Plugins/tree/master/AI_HardSI): Improves the AI behaviour of special infected
		> 強化每個AI 特感的行為與提高智商，積極攻擊倖存者
	3. [Zombie Spawn Fix](https://forums.alliedmods.net/showthread.php?t=333351): To Fixed Special Inected and Player Zombie spawning failures in some cases
		> 修正某些時候遊戲導演刻意停止特感生成的問題 (非100%完整解決特感不生成的問題)
	4. [l4d_ssi_teleport_fix](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Special_Infected_%E7%89%B9%E6%84%9F/l4d_ssi_teleport_fix): Teleport AI Infected player (Not Tank) to the teammate who is much nearer to survivors.
		> 傳送比較遠的AI特感到靠近倖存者的特感隊友附近
	5. [l4d2_auto_add_zombie](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Common_Infected_%E6%99%AE%E9%80%9A%E6%84%9F%E6%9F%93%E8%80%85/l4d2_auto_add_zombie): Adjust common infecteds/hordes/mobs depends on 5+ survivors in server
		> 隨著玩家人數越多，殭屍/屍潮 數量越來越多
	6. [gamemode-based_configs](https://github.com/fbef0102/L4D1_2-Plugins/tree/master/gamemode-based_configs): Allows for custom settings for each gamemode and mutatuion.
		> 根據遊戲模式或突變模式執行不同的cfg文件
</details>

* <details><summary>Changelog | 版本日誌</summary>

	```php
	//mi123645 @ 2009-2011
	//HarryPotter @ 2019-2024
	```
	* v2.8.9 (2024-1-27)
		* Updated L4D1 Gamedata 

	* v2.8.8 (2023-12-2)
		* Infected limit + numbers of survivor + spectators can not exceed 32 slots, otherwise server fails to spawn infected and becomes super lag

	* v2.8.7 (2023-10-9)
		* Fixed the code to avoid calling L4D_SetPlayerSpawnTim native from L4D1. (This Native is only supported in L4D2.)

	* v2.8.6 (2023-9-22)
		* Fixed "l4d_infectedbots_coordination" not working
		* Fixed Bot Spawn timer
		
	* v2.8.5 (2023-9-17)
		* Adjust human spawn timer when 5+ infected slots in versus/scavenge
		* In Versus/Scavenge, human infected spawn timer controlled by the official cvars "z_ghost_delay_min" and "z_ghost_delay_max" 

	* v2.8.4 (2023-8-26)
		* Improve Code.

	* v2.8.3 (2023-7-5)
		* Override L4D2 Vscripts to control infected limit.

	* v2.8.2 (2023-5-27)
		* Add a cvar, including dead survivors or not
		* Add a cvar, disable infected bots spawning or not in versus/scavenge mode

	* v2.8.1 (2023-5-22)
		* Support l4d2 all mutation mode.

	* v2.8.0 (2023-5-5)
		* Add Special Infected Weight
		* Add and modify cvars about Special Infected Weight

	* v2.7.9 (2023-4-13)
		* Fixed Not Working in Survival Mode
		* Fixed cvar "l4d_infectedbots_adjust_spawn_times" calculation mistake

	* v2.7.8 (2023-2-20)
		* [AlliedModder Post](https://forums.alliedmods.net/showpost.php?p=2699220&postcount=1369)
		* ProdigySim's method for indirectly getting signatures added, created the whole code for indirectly getting signatures so the plugin can now withstand most updates to L4D2! (Thanks to [Shadowysn](https://forums.alliedmods.net/showthread.php?t=320849) and [ProdigySim](https://github.com/ProdigySim/DirectInfectedSpawn)
		* L4D1 Signature update. Credit to [Psykotikism](https://github.com/Psykotikism/L4D1-2_Signatures).
		* Remake Code
		* Add translation support.
		* Update L4D2 "The Last Stand" gamedata, credit to [Lux](https://forums.alliedmods.net/showthread.php?p=2714236), [Shadowysn](https://forums.alliedmods.net/showthread.php?t=320849) and [Machine](https://forums.alliedmods.net/member.php?u=74752)
		* Spawn infected without being limited by the director.
		* Join infected team in coop/survival/realism mode.
		* Light up SI ladders in coop/realism/survival. mode for human infected players. (l4d2 only, didn't work if you host a listen server)
		* Add cvars to turn off this plugin.
		* Fixed Hunter Tank Bug in l4d1 coop mode when tank is playable.
		* If you want to fix Camera stuck in coop/versus/realism, install [this plugin by Forgetest](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_fix_deathfall_cam)
		* Fixed Music Bugs when switching to infected team in coop/realism/survival.

	* v1.0.0
		* [Original Plugin By mi123645](https://forums.alliedmods.net/showthread.php?t=99746)
</details>

- - - -
# 中文說明
多特感生成插件，倖存者人數越多，生成的特感越多，且不受遊戲特感數量限制 + 解除特感隊伍的人數限制 (可達成對抗 10 VS 10 玩法)

* 原理
	* 此插件控制遊戲導演生成系統，能夠強制無視遊戲特感數量限制，生成多特感
	* 當倖存者變多時，殭屍數量變多、特感數量變多、Tank數量變多、Tank血量變多，提升遊戲難度
	* 此插件可以讓玩家在戰役/寫實/生存模式下加入特感陣營，用來惡搞戰役玩家XD
	* 解鎖特感隊伍的人數上限，可以加入第五位以上的特感真人玩家，達成對抗 10 VS 10 玩法
	* **支援所有模式包括突變模式**

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

		// 如果爲1，則根據倖存者數量與特感隊伍的真人玩家數量調整特感復活時間
		l4d_infectedbots_adjust_spawn_times "1"

		// 如果爲1，則根據倖存者數量修改Tank血量上限
		l4d_infectedbots_adjust_tankhealth_enable "1"

		// 0=關閉插件, 1=開啓插件
		l4d_infectedbots_allow "1"

		// 如果爲1，則當存活的倖存者數量發生變化時宣布插件狀態
		l4d_infectedbots_announcement_enable "1"

		// 插件可生成boomer的最大數量
		l4d_infectedbots_boomer_limit "2"

		// 插件生成boomer的權重值 [0~100]
		l4d_infectedbots_boomer_weight "100"

		// 為1，計算4+以上的倖存者時也包含死亡的倖存者
		l4d_infectedbots_calculate_including_dead_player "0"

		// 插件可生成charger的最大數量
		l4d_infectedbots_charger_limit "2"

		// 插件生成charger的權重值 [0~100]
		l4d_infectedbots_charger_weight "100"

		// 如果爲1，則玩家可以在戰役/寫實/生存模式中加入感染者(!ji加入感染者 !js加入倖存者)"
		// 開啟此指令，即使都是倖存者Bot，會強制遊戲繼續進行
		l4d_infectedbots_coop_versus "0"

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
		
		// 為1，對抗/清道夫模式下關閉特感bots生成，只允許真人特感玩家生成
		// (此插件會繼續生成Witch、不影響導演系統)
		l4d_infectedbots_disable_infected_bots "0"

		// 插件可生成hunter的最大數量
		l4d_infectedbots_hunter_limit "2"

		// 插件生成hunter的權重值 [0~100]
		l4d_infectedbots_hunter_weight "100"

		// 是否提示感染者玩家如何開啓HUD
		l4d_infectedbots_infhud_announce "1"

		// 感染者玩家是否開啓HUD
		l4d_infectedbots_infhud_enable "1"

		// 在地圖第一關離開安全區後多長時間開始刷特
		l4d_infectedbots_initial_spawn_timer "10"

		// 插件可生成jockey的最大數量
		l4d_infectedbots_jockey_limit "2"

		// 插件生成jockey的權重值 [0~100]
		l4d_infectedbots_jockey_weight "100"

		// AI特感生成多少秒後踢出（AI防卡）
		l4d_infectedbots_lifespan "30"

		// 當倖存者數量低于4個及以下時可生成的最大特感數量（必須讓6個特感數量[Smoker, Boomer, Hunter, Spitter, Jockey, Charger]上限的值加起來超過這個值)
		l4d_infectedbots_max_specials "2"

		// 在這些模式中啓用插件，逗號隔開不需要空格（全空=全模式啓用插件）
		l4d_infectedbots_modes ""

		// 在這些模式中關閉插件，逗號隔開不需要空格（全空=無）
		l4d_infectedbots_modes_off ""

		// 在這些模式中啓用插件. 0=全模式, 1=戰役/寫實, 2=倖存者, 4=對抗, 8=清道夫 多個模式的數字加到一起
		l4d_infectedbots_modes_tog "0"

		// 如果爲1，即使倖存者尚未離開安全區域，遊戲依然能生成特感
		l4d_infectedbots_safe_spawn "0"

		// 如果爲1，可生成的最大數量越多，該特感的權重值越高
		// 如果爲1，場上相同特感種類的數量越多，該特感的權重值越低
		l4d_infectedbots_scale_weights "0"

		// 在哪些遊戲模式中禁止感染者玩家使用sm_zs (0: 無, 1: 戰役/寫實, 2: 對抗/清道夫, 4: 倖存者, 多個模式添加數字輸出)
		l4d_infectedbots_sm_zs_disable_gamemode "6"

		// 插件可生成smoker的最大數量
		l4d_infectedbots_smoker_limit "2"

		// 插件生成smoker的權重值 [0~100]
		l4d_infectedbots_smoker_weight "5"

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

		// 插件生成spitter的權重值 [0~100]
		l4d_infectedbots_spitter_weight "100"

		// 插件可生成tank的最大數量 （不影響劇情tank）
		l4d_infectedbots_tank_limit "1"

		// 如果爲1，則最後一關救援中插件不會生成Tank（不影響劇情生成的Tank）
		l4d_infectedbots_tank_spawn_final "1"

		// 每次生成一個特感的時候多少概率會變成tank
		l4d_infectedbots_tank_spawn_probability "5"

		// 如果爲1，則在對抗/清道夫模式中，強迫所有玩家加入到感染者
		// 開啟此指令，即使都是倖存者Bot，會強制遊戲繼續進行
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
	1. <details><summary>設置特感生成最大數量限制</summary>

		```php
		l4d_infectedbots_charger_limit
		l4d_infectedbots_boomer_limit 
		l4d_infectedbots_hunter_limit
		l4d_infectedbots_jockey_limit
		l4d_infectedbots_smoker_limit
		l4d_infectedbots_spitter_limit
		```

		這6個cvar值加在一起必須等於或超過 ```l4d_infectedbots_max_specials```
		* For example
			```php
			// 好的
			l4d_infectedbots_charger_limit 1
			l4d_infectedbots_boomer_limit 1
			l4d_infectedbots_hunter_limit 1
			l4d_infectedbots_jockey_limit 1
			l4d_infectedbots_smoker_limit 1
			l4d_infectedbots_spitter_limit 1
			l4d_infectedbots_max_specials 6 
			```

			```php
			// 好的
			l4d_infectedbots_charger_limit 1
			l4d_infectedbots_boomer_limit 2
			l4d_infectedbots_hunter_limit 4
			l4d_infectedbots_jockey_limit 2
			l4d_infectedbots_smoker_limit 2
			l4d_infectedbots_spitter_limit 2
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
			l4d_infectedbots_max_specials 9 
			```

		> __Note__ 
		<br/>1. 請注意，最大數量限制不包含witch的數量，但會包含tank的數量
		<br/>2. 在對抗／清道夫模式中，特感最大生成數量 = 特感隊伍的空位
		
		> __Warning__ 
		<br/>🟥警告!!! 特感數量 + 倖存者數量 + 旁觀者數量不得超過32，否則伺服器會變得很卡且無法生成特感 (因為此遊戲只能容納32個)
	</details>

	2. <details><summary>如果第5位以上存活的倖存者，則調整特感最大生成數量</summary>

		* 例如: 如果第5位以上存活的倖存者，每3個玩家加入，最大的特感數量加2
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

		> __Note__ 
		<br/>在對抗／清道夫模式中，特感最大生成數量 = 特感隊伍的空位
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

		* Tank血量會依照遊戲模式與難度自動做出最終調整，譬如設置Tank血量為4000，則
			* 簡單難度下Tank血量最終為 4000 * 0.75 = 3000
			* 一般難度下Tank血量最終為 4000 * 1.0 = 4000
			* 進階/專家難度下Tank血量最終為 4000 * 2.0 = 8000
			* 對抗/清道夫模式下Tank血量最終為 4000 * 1.5 = 6000
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
		<br/>如果有5個存活的倖存者，則特感生成時間爲：[最長時間: 60-(5x2) = 50, 最短時間: 30-(5x2) = 20]
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

		* (對抗/清道夫) 如何控制真人特感玩家的復活時間?
			* 真人玩家的復活時間是根據官方指令設定
				```php
				sm_cvar z_ghost_delay_min "20"
				sm_cvar z_ghost_delay_max "30"
				```

			* 也依照"特感玩家數量"與"特感隊伍空位"自動做出最終調整，其公式為
				```php
				// 在L4D2，如果"特感玩家數量" 大於等於4，則以4代入計算
				// 在L4D2，如果"特感隊伍空位" 大於等於4，則以4代入計算
				最短時間: z_ghost_delay_min * (特感玩家數量 ÷ 特感隊伍空位) 
				最長時間: z_ghost_delay_max * (特感玩家數量 ÷ 特感隊伍空位)
				```

			* 以下舉例
				```php
				// 特感玩家：3人，特感隊伍空位：4人，z_ghost_delay_min: 30，z_ghost_delay_max: 40
				在L4D2，特感玩家復活時間最終為: [最短時間: 30 * (3÷4) = 22.5秒, 最長時間: 40 * (3÷4) = 30秒]
				在L4D1，特感玩家復活時間最終為: [最短時間: 30 * (3÷4) = 22.5秒, 最長時間: 40 * (3÷4) = 30秒]

				// 特感玩家：1人，特感隊伍空位：1人，z_ghost_delay_min: 3，z_ghost_delay_max: 3
				在L4D2，特感玩家復活時間最終為: 3 * (1÷1) = 3秒
				在L4D1，特感玩家復活時間最終為: 3 * (1÷1) = 3秒

				// 特感玩家：2人，特感隊伍空位：4人，z_ghost_delay_min: 18，z_ghost_delay_max: 18
				在L4D2，特感玩家復活時間最終為: 18 * (2÷4) = 9秒
				在L4D1，特感玩家復活時間最終為: 18 * (2÷4) = 9秒

				// 特感玩家：3人，特感隊伍空位：8人，z_ghost_delay_min: 20，z_ghost_delay_max: 20
				在L4D2，特感玩家復活時間最終為: 20 * (3÷4) = 15秒
				在L4D1，特感玩家復活時間最終為: 20 * (2÷8) = 5秒

				// 特感玩家：4人，特感隊伍空位：8人，z_ghost_delay_min: 20，z_ghost_delay_max: 20
				在L4D2，特感玩家復活時間最終為: 20 * (4÷4) = 20秒
				在L4D1，特感玩家復活時間最終為: 20 * (4÷8) = 10秒

				// 特感玩家：7人，特感隊伍空位：8人，z_ghost_delay_min: 20，z_ghost_delay_max: 20
				在L4D2，特感玩家復活時間最終為: 20 * (4÷4) = 20秒
				在L4D1，特感玩家復活時間最終為: 20 * (7÷8) = 17.5秒
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

		* Tank上限 = 場上同時存在Tank的數量
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
		* 即使都是倖存者Bot，會強制遊戲繼續進行
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

		* 請注意！這個指令也會影響普通殭屍的生成範圍。
			```php
			l4d_infectedbots_spawn_range_min "350"
			```

		* 讓特感可以在非常接近幸存者的地方復活，以獲得更好的遊戲體驗。
			```php
			l4d_infectedbots_spawn_range_min "0" 
			```

		> __Warning__ 
		<br/>在對抗/清道夫模式中，這個指令會影響靈魂狀態下真人特感玩家的復活範圍
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

	11. <details><summary>設置特感的權重</summary>

		* 除了Tank與Witch以外可以增減特感的權重, 譬如
			```php
			// 每一次特感生成, 有很大的機率生成Hunter與Charger
			// 如果Hunter與Charger達到最大數量限制, 則根據權重分配生成其他特感
			l4d_infectedbots_boomer_weight "5"
			l4d_infectedbots_charger_weight "90"
			l4d_infectedbots_hunter_weight "100"
			l4d_infectedbots_jockey_weight "10"
			l4d_infectedbots_smoker_weight "5"
			l4d_infectedbots_spitter_weight "8"
			```

		* 可根據"場上特感數量"與"生成最大數量"兩種值調整每個特感的權重 (公式如何計算，不要問)
			```php
			// 如果爲1，可生成的最大數量越多，該特感的權重值越高
			// 如果爲1，場上相同特感種類的數量越多，該特感的權重值越低
			l4d_infectedbots_scale_weights "1"
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
		5. 🟥 特感數量 + 倖存者數量 + 旁觀者數量 超過了32個位子，伺服器會變得很卡且無法生成特感
			* 解決方式：無法解決，因為此遊戲最多只能容納32個真人玩家+AI玩家
	</details>

	4. <details><summary>計算第5位以上死亡的倖存者</summary>

		* 調整特感最大生成數量、Tank血量、普通殭屍最大數量、tank生成限制時，計算倖存者數量時也包含死亡的玩家
			```php
			l4d_infectedbots_calculate_including_dead_player "1"
			```
	</details>

	5. <details><summary>停止特感Bots生成</summary>

		* 在對抗/清道夫模式中，關閉特感bots生成，只允許真人特感玩家生成特感 (此插件會繼續生成Witch、不影響導演系統)
			```php
			l4d_infectedbots_disable_infected_bots "1"
			```
	</details>

	6. <details><summary>伺服器好像只能生成18個特感bots?</summary>

		* 因為此遊戲預設人數上限為18. 請去安裝 [l4dtoolz](https://github.com/fbef0102/Game-Private_Plugin/tree/main/Tutorial_%E6%95%99%E5%AD%B8%E5%8D%80/Chinese_%E7%B9%81%E9%AB%94%E4%B8%AD%E6%96%87/Server/%E5%AE%89%E8%A3%9D%E5%85%B6%E4%BB%96%E6%AA%94%E6%A1%88%E6%95%99%E5%AD%B8#%E5%AE%89%E8%A3%9Dl4dtoolz) ，務必將"玩家上限"改成32 (最高只能到32)
		<br/>![zho/l4dinfectedbots_4](image/zho/l4dinfectedbots_4.jpg)

	</details>

* 已知問題
	1. 在戰役/寫實下，特感玩家的視角畫面會卡住，常發生在倖存者滅團重新回合的時候
		> 如果要修正請安裝[l4d_fix_deathfall_cam](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_fix_deathfall_cam)
	2. 在戰役/寫實下，特感玩家扮演第二隻救援Tank時，救援載具會直接來臨
		> 如果要修正請安裝[l4d2_scripted_tank_stage_fix](https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d2_scripted_tank_stage_fix) to fix
