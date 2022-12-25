# Description | 內容
Adds commands to let the player spectate and join team. (!afk, !survivors, !infected, etc.), but no change team abuse.

* Video | 影片展示
<br>None

* Image | 圖示
<br>None

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
	Russian
	Hungarian
	```

* <details><summary>Changelog | 版本日誌</summary>

	* v4.4
		* [AlliedModder Post](https://forums.alliedmods.net/showpost.php?p=2719702&postcount=32)
		* Remake Code
		* Add translation support.
		* Update L4D2 "The Last Stand" gamedata, credit to [Lux](https://forums.alliedmods.net/showthread.php?p=2714236)
		* Add more convar and limit to prevent players from changing team abuse.
		* Add more commands
		* No change team abuse
		* Player can go idle even if alone in server
		* Allow alive survivor player suicides by using '!zs'
		* Adm Command ```sm_swapto <player> <team>```, Adm forces player to swap team
		* Compatible with [r2comp_unscramble](https://forums.alliedmods.net/showthread.php?t=327711)
		* Remove gamedata

	* v1.2
		* [Original Plugin By MasterMe](https://forums.alliedmods.net/showthread.php?p=1130434)
</details>

* Require | 必要安裝
	1. [left4dhooks](https://forums.alliedmods.net/showthread.php?t=321696)
	2. [[INC] Multi Colors](https://github.com/fbef0102/L4D1_2-Plugins/releases/tag/Multi-Colors)
	3. Optional - [[INC] unscramble.inc](https://github.com/raziEiL/r2comp-standalone/blob/master/sourcemod/scripting/include/unscramble.inc)

* <details><summary>ConVar | 指令</summary>

	* cfg/sourcemod/l4d_afk_commands.cfg
		```php
		// Cold Down Time in seconds a player can not change team again after he switches team. (0=off)
		l4d_afk_commands_changeteam_cooltime_block "10.0"

		// If 1, Dead Survivor player can not switch team.
		l4d_afk_commands_deadplayer_block "1"

		// Player can switch team until players have left start safe area for at least x seconds (0=off).
		l4d_afk_commands_during_game_seconds_block "0"

		// Cold Down Time in seconds a player can not change team after he ignites molotov, gas can, firework crate or barrel fuel. (0=off).
		l4d_afk_commands_igniteprop_cooltime_block "15.0"

		// Players with these flags have immune to all 'block' limit (Empty = Everyone, -1: Nobody)
		l4d_afk_commands_immue_block_flag "-1"

		// Players with these flags have access to use command to infected team. (Empty = Everyone, -1: Nobody)
		l4d_afk_commands_infected_access_flag ""

		// If 1, Player can not change team when he is capped by special infected.
		l4d_afk_commands_infected_attack_block "1"

		// If 1, Infected player can not change team when he has pounced/ridden/charged/smoked a survivor.
		l4d_afk_commands_infected_cap_block "1"

		// Cold Down Time in seconds an infected player can not change team after he is spawned as a special infected. (0=off).
		l4d_afk_commands_infected_spawn_cooltime_block "10.0"

		// If 1, Block player from using 'jointeam' command in console. (This also blocks player from switching team by choosing team menu)
		l4d_afk_commands_pressM_block "1"

		// Players with these flags have access to use command to spectator team. (Empty = Everyone, -1: Nobody)
		l4d_afk_commands_spec_access_flag ""

		// If 1, Allow alive survivor player suicides by using '!zs'.
		l4d_afk_commands_suicide_allow "1"

		// Players with these flags have access to use command to survivor team. (Empty = Everyone, -1: Nobody)
		l4d_afk_commands_survivor_access_flag ""

		// If 1, Block player from using 'go_away_from_keyboard' command in console. (This also blocks player from going idle with 'esc->take a break')
		l4d_afk_commands_takeabreak_block "1"

		// If 1, Block player from using 'sb_takecontrol' command in console.
		l4d_afk_commands_takecontrol_block "1"

		// Cold Down Time in seconds a player can not change team after he throws molotov, pipe bomb or boomer juice. (0=off).
		l4d_afk_commands_throwable_cooltime_block "10.0"

		// If 1, Player can not change team when he startle witch or being attacked by witch.
		l4d_afk_commands_witch_attack_block "1"

		// Players with these flags have access to use command to be an observer. (Empty = Everyone, -1: Nobody)
		l4d_afk_commands_observer_access_flag "z"
		```
</details>

* <details><summary>Command | 命令</summary>
	
	* **Change team to Spectate**
		```php
		sm_afk
		sm_s
		sm_away
		sm_idle
		sm_spectate
		sm_spec
		sm_spectators
		sm_joinspectators
		sm_joinspectator
		sm_jointeam1
		sm_js
		```

	* **Change team to Survivor**
		```php
		sm_join
		sm_bot
		sm_jointeam
		sm_survivors
		sm_survivor
		sm_sur
		sm_joinsurvivors
		sm_joinsurvivor
		sm_jointeam2
		sm_jg
		sm_takebot
		sm_takeover
		```

	* **Change team to Infected**
		```php
		sm_infected
		sm_inf
		sm_joininfected
		sm_joininfecteds
		sm_jointeam3
		sm_zombie
		```

	* **Switch team to fully an observer**
		```php
		sm_observer
		sm_ob
		sm_observe
		```

	* **Survivor Player Suicides**
		```php
		sm_zs
		```

	* **Adm force player to change team (Adm Required: ADMFLAG_BAN)**
		* teamnum is 1,2,3. 1=Spectator, 2=Survivor, 3=Infected
			```php
			sm_swapto <player1> [player2] ... [playerN] <teamnum> - swap all listed players to <teamnum> (1,2, or 3)
			```
</details>

* Notice
	* The plugin will work once survivor has left the saferoom or survival begins
	* You can't go idle or use command to switch team if you are in one of below situation
		1. You startle witch or witch attacks you.
		2. You are capped by special infected.
		3. You are a dead survivor.
		4. Player can switch team until players have left start safe area for at least X seconds. (set time by convar below)
		5. Cold Down Time in seconds a player can not change team again after he switches team.
		6. Cold Down Time in seconds a player can not change team after he ignites molotov, gas can, firework crate or barrel fuel.
		7. Cold Down Time in seconds a player can not change team after he throws molotov, pipe bomb or boomer juice.
		8. Infected player can not change team when he has pounced/ridden/charged/smoked a survivor.
		9. Cold Down Time in seconds an infected player can not change team after he is spawned as a special infected.


- - - -
# 中文說明
提供多種命令轉換隊伍陣營 (譬如: !afk, !survivors, !infected), 但不可濫用.

* 原理
	* 此插件會控制玩家切換隊伍的行為包括
		1. 使用ESC->休息一下
		<br/>![POI)A31HUG3M(O (0IK`SY2](https://user-images.githubusercontent.com/12229810/209460474-e795534e-335c-4cff-83e7-3a737ec0d47e.png)
		2. 對抗模式下按M切換隊伍
		<br/>![image](https://user-images.githubusercontent.com/12229810/209460497-af899ea0-d670-4de8-9da9-e242eeae30e2.png)
		3. 控制台輸入```jointeam 2 <Nick|Ellis|Rochelle|Coach|Bill|Zoey|Francis|Louis>```
		<br/>![image](https://user-images.githubusercontent.com/12229810/209460517-547fe0c9-eb9b-456c-8fc7-f72f2d70f59c.png)
		4. 控制台輸入```sb_takecontrol <Nick|Ellis|Rochelle|Coach|Bill|Zoey|Francis|Louis>```
		<br/>![image](https://user-images.githubusercontent.com/12229810/209469875-f17e87bd-907a-4a64-b9b4-023bac157b13.png)
	* 此插件會禁止玩家濫用閒置的bug，譬如
		1. 導致witch失去目標
		2. 省略裝子彈時間
		3. 逃避特感抓住造成的傷害
		4. 特感故意切換旁觀省略下次的靈魂特感復活時間
		5. 死亡倖存者玩家跳隊重新拿到活著的倖存者Bot
		6. 遊戲開始後故意跳隊到對面擾亂對方隊伍
	* 盡量不要安裝其他也有換隊指令的插件，否則換隊衝突後果自負
	* 倖存者玩家如果要成為旁觀者而非閒置狀態可以輸入```!ob```

* 功能
	1. 可設置跳隊到倖存者、特感、旁觀的權限
	2. 可設置每個跳隊限制的功能開關與冷卻時間限制
	3. 可設置管理員不會受到此插件的換隊限制影響
	4. 可禁用ESC-休息一下
	5. 可禁用對抗模式下按M切換隊伍與控制台輸入```jointeam```
	6. 管理員可以輸入```sm_swapto <玩家名稱> <隊伍數字>```，強制該位玩家換到隊伍
		* 隊伍數字，請寫1或2或3，1為旁觀者, 2為倖存者, 3為特感
	7. 倖存者可以輸入```!zs```自殺，可以使用指令關閉這項功能

* 注意事項
	* 遊戲開始之後此插件才會生效
		* 離開安全區域或是生存模式計時開始
	* 有以下情況不能使用命令換隊，否則強制旁觀
		1. 嚇到Witch或者Witch正在攻擊你
		2. 被特感抓住的期間
		3. 你已經是死亡的倖存者
		4. 離開安全區域或是生存模式計時開始之後一段時間內 (查看指令設置的時間)
		5. 換隊之後短時間內不能換第二次
		6. 點燃汽油桶、煤氣罐一段時間內
		7. 丟出火焰瓶、土製炸彈、膽汁瓶一段時間內
		8. 特感抓住倖存者的期間
		9. 特感剛復活的時候
