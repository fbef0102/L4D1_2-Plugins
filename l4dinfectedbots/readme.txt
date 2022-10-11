Spawns infected bots in L4D1 versus, and gives greater control of the infected bots in L4D1/L4D2 without being limited by the director.

-AlliedModder-
Infected Bots Control Improved Version: https://forums.alliedmods.net/showpost.php?p=2699220&postcount=1369

-Version-
v2.7.6
- ProdigySim's method for indirectly getting signatures added, created the whole code for indirectly getting signatures so the plugin can now withstand most updates to L4D2!
	(Thanks to Shadowysn: https://forums.alliedmods.net/showthread.php?t=320849 and ProdigySim: https://github.com/ProdigySim/DirectInfectedSpawn)
-L4D1 Signature update. (Credit to Psykotikism: https://github.com/Psykotikism/L4D1-2_Signatures)
-Remake Code
-Add translation support.
-Update L4D2 "The Last Stand" gamedata, credit to Lux(https://forums.alliedmods.net/showthread.php?p=2714236), Shadowysn(https://forums.alliedmods.net/showthread.php?t=320849) and Machine(https://forums.alliedmods.net/member.php?u=74752)
-Spawn infected without being limited by the director.
-Join infected team in coop/survival/realism mode.
-Light up SI ladders in coop/realism/survival. mode for human infected players. (l4d2 only, didn't work if you host a listen server)
-Add convars to turn off this plugin.
-Fixed Hunter Tank Bug in l4d1 coop mode when tank is playable.
-If you want to fix Camera stuck in coop/versus/realism, install this plugin by Forgetest: https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_fix_deathfall_cam

v1.0.0
-Original Post: https://forums.alliedmods.net/showthread.php?t=99746

-Require-
1. left4dhooks: https://forums.alliedmods.net/showthread.php?p=2684862
2. [INC] Multi Colors: https://forums.alliedmods.net/showthread.php?t=247770

-Related Plugin-
1. MultiSlots Improved: https://forums.alliedmods.net/showpost.php?p=2715546&postcount=249
When 5+ player joins the server but no any bot can be taken over, this plugin will spawn an alive survivor bot for him.

2. Zombie Spawn Fix: https://forums.alliedmods.net/showthread.php?t=333351
To Fixed Special Inected and Player Zombie spawning failures in some cases

3. l4d_ssi_teleport_fix: https://github.com/fbef0102/Game-Private_Plugin/tree/main/l4d_ssi_teleport_fix
Teleport AI Infected player (Not Tank) to the teammate who is much nearer to survivors.

-Convar-
cfg/sourcemod/l4dinfectedbots.cfg
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



-How to set the correct Convar-
1. Set special limit
-l4d_infectedbots_charger_limit
-l4d_infectedbots_boomer_limit 
-l4d_infectedbots_hunter_limit
-l4d_infectedbots_jockey_limit
-l4d_infectedbots_smoker_limit
-l4d_infectedbots_spitter_limit
-l4d_infectedbots_tank_limit
These 7 values combined together must equal or exceed
-l4d_infectedbots_max_specials

For example:
Good:
l4d_infectedbots_charger_limit 1
l4d_infectedbots_boomer_limit 1
l4d_infectedbots_hunter_limit 1
l4d_infectedbots_jockey_limit 1
l4d_infectedbots_smoker_limit 1
l4d_infectedbots_spitter_limit 1
l4d_infectedbots_tank_limit  0
l4d_infectedbots_max_specials 6 

Also Good:
l4d_infectedbots_charger_limit 1
l4d_infectedbots_boomer_limit 2
l4d_infectedbots_hunter_limit 3
l4d_infectedbots_jockey_limit 2
l4d_infectedbots_smoker_limit 2
l4d_infectedbots_spitter_limit 2
l4d_infectedbots_tank_limit  1
l4d_infectedbots_max_specials 10 

Bad:
l4d_infectedbots_charger_limit 0
l4d_infectedbots_boomer_limit 1
l4d_infectedbots_hunter_limit 2
l4d_infectedbots_jockey_limit 0
l4d_infectedbots_smoker_limit 1
l4d_infectedbots_spitter_limit 0
l4d_infectedbots_tank_limit  0
l4d_infectedbots_max_specials 9 

* Note that it does not counts witch in all gamemode, but it counts tank in all gamemode.

2. Adjust special limit if 5+ alive players
For example.
-l4d_infectedbots_max_specials "4"
-l4d_infectedbots_add_specials "2"
-l4d_infectedbots_add_specials_scale "3"
This means that if server has 5+ alive survivors, each 3 players join, max specials limit plus 2
So if there are 10 alive survivors, specials limit: 4+2+2 = 8

if you don't want to adjust specials limit, set
-l4d_infectedbots_add_specials "0"

3. Adjust tank health if 5+ alive players
For example
-l4d_infectedbots_adjust_tankhealth_enable "1"
-l4d_infectedbots_default_tankhealth "4000"
-l4d_infectedbots_add_tankhealth "1200"
-l4d_infectedbots_add_tankhealth_scale "3"
This means that if server has 5+ alive survivors, each 3 players join, tank health increase 1200hp
So if there are 10 alive survivors, tank health: 4000+1200+1200 = 6400hp

To close this feature, do not want to overrides tank HP by this plugin, set
-l4d_infectedbots_adjust_tankhealth_enable "0"

4. Adjust zombie zommon limit if 5+ alive players
For example
- l4d_infectedbots_adjust_commonlimit_enable "1"
- l4d_infectedbots_default_commonlimit "30"
- l4d_infectedbots_add_commonlimit_scale "1"
- l4d_infectedbots_add_commonlimit "2"
This means that if server has 5+ alive survivors, each 1 players join, zommon limit increase 2
So if there are 10 alive survivors, common limit: 30+2+2+2+2+2+2 = 42

To close this feature, do not want to overrides zombie common limit by this plugin, set
-l4d_infectedbots_adjust_commonlimit_enable "0"

5. Adjust special infected spawn timer
Reduce certain value to spawn timer based per alive player,For example
-l4d_infectedbots_spawn_time_max "60"
-l4d_infectedbots_spawn_time_min "30"
-l4d_infectedbots_adjust_spawn_times "1"
-l4d_infectedbots_adjust_reduced_spawn_times_on_player "2"
If there are 5 "ALIVE" survivors in game, special infected spawn timer[max: 60-(5*2) = 50, min: 30-(5*2) = 20]

To close this feature, set 
-l4d_infectedbots_adjust_spawn_times "0"

6. How to spawn tank
For example.
-l4d_infectedbots_tank_limit "2"
-l4d_infectedbots_tank_spawn_probability "5"
This means that each time 5% chance to spawn tank instead of infected bot. 
Note that if tank limit is reached or is 0, still don't spawn tank (does not affect director tanks)

Do not Spawn tank in final stage rescue (does not affect director tanks)
-l4d_infectedbots_tank_spawn_final "0"

7. Adjust Tank limit if 5+ alive players
For example.
-l4d_infectedbots_tank_limit "2"
-l4d_infectedbots_add_tanklimit "1"
-l4d_infectedbots_add_tanklimit_scale "5"
This means that if server has 5+ alive survivors, each 5 players join, Tank limit plus 1
So if there are 10 alive survivors, tank limit: 2+1 = 3 (Does not affect director tanks)

if you don't want to adjust tank limit, set
-l4d_infectedbots_add_tanklimit "0"

8. Play infected team in coop/survival/realism
For example.
-l4d_infectedbots_coop_versus "1"
-l4d_infectedbots_coop_versus_join_access "z"
-l4d_infectedbots_coop_versus_human_limit "2"
Only players with "z" access can join the infected team, and there are only 2 infected team slots for real player

If you want everyone can join infected, then set
-l4d_infectedbots_coop_versus_join_access ""

human infected player will spawn as ghost state in coop/survival/realism.
-l4d_infectedbots_coop_versus_human_ghost_enable "1" 

make tank always be playable by real infected player
-l4d_infectedbots_coop_versus_tank_playable "1" 

9. Spawn range (Coop/Realism only)
Must be careful to adjust, these convars will also affect common zombie spawn range and human ghost infected spawn range.
-l4d_infectedbots_spawn_range_min "350"

Make infected player spawn near very close by survivors for better gaming experience
-l4d_infectedbots_spawn_range_min "0" 

10. Spawn Infected together
bots will only spawn when all other bot spawn timers are at zero, and then spawn together.
-l4d_infectedbots_coordination "1" 

Plugin will disable spawning infected bot when a tank is on the field.
-l4d_infectedbots_spawns_disabled_tank "1" 

11. Other
a. How to disable this message?
***[TS] Numbers of Alive Survivor: 4, Infected Limit: 2, Tank Health: 4000, Common Limit: 40***
- l4d_infectedbots_announcement_enable "0" 

b. How to turn off flashlights on human infected player in coop/survival/realism ?
- l4d_infectedbots_coop_versus_human_light "0" 

-Command-
(coop/realism/survival only) !ji - JoinInfected
(coop/realism/survival only) !js - JoinSurvivors
(infected only) !infhud - toggle HUD on/off for themselves
(infected only) !zs - suicide infected player himself (if infected get stuck or something)
(adm only) !timer - control special zombies spawn timer
(adm only) !zlimit - control max special zombies limit



*中文說明*
-指令-
cfg/sourcemod/l4dinfectedbots.cfg
// 存活的生還者數量超過4個時，每加入壹個'l4d_infectedbots_default_commonlimit'的玩家，就增加壹定的值到'l4d_infectedbots_add_commonlimit_scale'
l4d_infectedbots_add_commonlimit "2"

// 存活的生還者數量超過4個時, 最大普通僵屍數量上限 = default_commonlimit + [(存活的生還者數量-4) ÷ 'add_commonlimit_scale'] × 'add_commonlimit'
l4d_infectedbots_add_commonlimit_scale "1"

// 存活的生還者數量超過4個時，每加入壹個'l4d_infectedbots_max_specials'的玩家，就增加壹定的值到'l4d_infectedbots_add_specials_scale'
l4d_infectedbots_add_specials "2"

// 存活的生還者數量超過4個時，最大特感數量上限 = max_specials + [(存活的生還者數量-4) ÷ 'add_specials_scale'] × 'add_specials'
l4d_infectedbots_add_specials_scale "2"

// 存活的生還者數量超過4個時，每加入壹個'l4d_infectedbots_default_tankhealth'的玩家，就增加壹定的數值到'l4d_infectedbots_add_tankhealth_scale'
l4d_infectedbots_add_tankhealth "500"

// 存活的生還者數量超過4個時，坦克血量上限 = max_specials + [(存活的生還者數量-4) ÷ 'add_specials_scale'] × 'add_specials']
l4d_infectedbots_add_tankhealth_scale "1"

// 存活的生還者數量超過4個時，每加入壹個'l4d_infectedbots_tank_limit'的玩家，就增加壹定的值給'l4d_infectedbots_add_tanklimit_scale'
l4d_infectedbots_add_tanklimit "1"

// 存活的生還者數量超過4個時，Tank數量上限 = tank_limit + [(存活的生還者數量-4) ÷ 'add_tanklimit_scale'] × 'add_tanklimit'
l4d_infectedbots_add_tanklimit_scale "3"

// 如果爲1，則啓用根據存活的生還者數量調整僵屍數量
l4d_infectedbots_adjust_commonlimit_enable "1"

// 每增加壹位生還者，則減少(存活的生還者數量-l4d_infectedbots_adjust_reduced_spawn_times_on_player)複活時間（初始4位生還者也算在內）
l4d_infectedbots_adjust_reduced_spawn_times_on_player "1"

// 如果爲1，則根據生還者數量調整特感複活時間
l4d_infectedbots_adjust_spawn_times "1"

// 如果爲1，則根據生還者數量修改坦克血量上限
l4d_infectedbots_adjust_tankhealth_enable "1"

// 0=關閉插件, 1=開啓插件
l4d_infectedbots_allow "1"

// 如果爲1，則當存活的生還者數量發生變化時宣布插件狀態
l4d_infectedbots_announcement_enable "1"

// 插件可生成boomer的最大數量
l4d_infectedbots_boomer_limit "2"

// 插件可生成charger的最大數量
l4d_infectedbots_charger_limit "2"

// 如果爲1，則玩家可以在戰役/寫實/生還者模式中加入感染者(!ji加入感染者 !js加入生還者)"
l4d_infectedbots_coop_versus "1"

// 如果爲1，則通知玩家如何加入到生還者和感染者
l4d_infectedbots_coop_versus_announce "1"

// 如果爲1，則在戰役/寫實/生還者模式中，感染者玩家將以靈魂狀態複活
l4d_infectedbots_coop_versus_human_ghost_enable "1"

// 如果爲1，則感染者玩家將發出紅色的光
l4d_infectedbots_coop_versus_human_light "1"

// 在戰役/生還者/清道夫中設置通過插件加入到感染者的玩家數量
l4d_infectedbots_coop_versus_human_limit "2"

// 有什麽權限的玩家在戰役/寫實/生還者模式中可以加入到感染者 (無內容 = 所有人, -1: 無法加入)
l4d_infectedbots_coop_versus_join_access "z"

// 如果爲1，玩家可以在戰役/寫實/生還者模式中接管坦克
l4d_infectedbots_coop_versus_tank_playable "0"

// 如果爲1，則感染者需要等待其他感染者准備好才能壹起被插件生成攻擊生還者
l4d_infectedbots_coordination "0"

// 當生還者數量不超過5人的僵屍數量
l4d_infectedbots_default_commonlimit "30"

// 設置坦克默認血量上限, 坦克血量上限受到遊戲難度或模式影響 （若坦克血量上限設置爲4000，則簡單難度3000血，普通難度4000血，對抗類型模式6000血，高級/專家難度血量8000血）
l4d_infectedbots_default_tankhealth "4000"

// 插件可生成hunter的最大數量
l4d_infectedbots_hunter_limit "2"

// 是否提示感染者玩家如何開啓HUD
l4d_infectedbots_infhud_announce "1"

// 感染者玩家是否開啓HUD
l4d_infectedbots_infhud_enable "1"

// 在地圖第壹關離開安全區後多長時間開始刷特
l4d_infectedbots_initial_spawn_timer "10"

// 插件可生成jockey的最大數量
l4d_infectedbots_jockey_limit "2"

// AI特感生成多少秒後踢出（AI防卡）
l4d_infectedbots_lifespan "30"

// 當生還者數量低于4個及以下時可生成的最大特感數量（必須讓7個特感數量{不包括witch}上限的值加起來超過這個值
l4d_infectedbots_max_specials "2"

// 在這些模式中啓用插件，逗號隔開不需要空格（全空=全模式啓用插件）
l4d_infectedbots_modes ""

// 在這些模式中關閉插件，逗號隔開不需要空格（全空=無）
l4d_infectedbots_modes_off ""

// 在這些模式中啓用插件. 0=全模式, 1=戰役/寫實, 2=生還者, 4=對抗, 8=清道夫 多個模式的數字加到壹起
l4d_infectedbots_modes_tog "0"

// 如果爲1，則生還者離開安全區域才生成特感
l4d_infectedbots_safe_spawn "0"

// 在哪些遊戲模式中禁止感染者玩家使用sm_zs (0: 無, 1: 戰役/寫實, 2: 對抗/清道夫, 4: 生還者, 多個模式添加數字輸出)
l4d_infectedbots_sm_zs_disable_gamemode "6"

// 插件可生成smoker的最大數量
l4d_infectedbots_smoker_limit "2"

// 允許特感在同一個時間點復活沒有誤差 (小心啟動，會影響伺服器卡頓)
l4d_infectedbots_spawn_on_same_frame 0

// 特感生成的最小距離 (默認: 550, 僅戰役/寫實)
// 這個cvar也會影響普通僵屍的生成範圍和靈魂狀態下感染者玩家的複活距離
l4d_infectedbots_spawn_range_min "350"

// 設置插件生成的特感最大時間(秒)
l4d_infectedbots_spawn_time_max "60"

// 設置插件生成的特感最小時間(秒)
l4d_infectedbots_spawn_time_min "40"

// 如果爲1，則當坦克存活時禁止特感複活
l4d_infectedbots_spawns_disabled_tank "0"

// 插件可生成spitter的最大數量
l4d_infectedbots_spitter_limit "2"

// 插件可生成tank的最大數量 （不影響劇情tank）
l4d_infectedbots_tank_limit "1"

// 如果爲1，則最後壹關救援中插件不會生成坦克（不影響劇情生成的坦克）
l4d_infectedbots_tank_spawn_final "1"

// 每次生成壹個特感的時候多少概率會變成tank
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



-如何設置插件cvar-
1. 設置特感生成
-l4d_infectedbots_charger_limit
-l4d_infectedbots_boomer_limit 
-l4d_infectedbots_hunter_limit
-l4d_infectedbots_jockey_limit
-l4d_infectedbots_smoker_limit
-l4d_infectedbots_spitter_limit
-l4d_infectedbots_tank_limit
這7個cvar值加在壹起必須等于或超過l4d_infectedbots_max_specials

例如:
好的:
l4d_infectedbots_charger_limit 1
l4d_infectedbots_boomer_limit 1
l4d_infectedbots_hunter_limit 1
l4d_infectedbots_jockey_limit 1
l4d_infectedbots_smoker_limit 1
l4d_infectedbots_spitter_limit 1
l4d_infectedbots_tank_limit  0
l4d_infectedbots_max_specials 6 

還算好:
l4d_infectedbots_charger_limit 1
l4d_infectedbots_boomer_limit 2
l4d_infectedbots_hunter_limit 3
l4d_infectedbots_jockey_limit 2
l4d_infectedbots_smoker_limit 2
l4d_infectedbots_spitter_limit 2
l4d_infectedbots_tank_limit  1
l4d_infectedbots_max_specials 10 

糟糕的:
l4d_infectedbots_charger_limit 0
l4d_infectedbots_boomer_limit 1
l4d_infectedbots_hunter_limit 2
l4d_infectedbots_jockey_limit 0
l4d_infectedbots_smoker_limit 1
l4d_infectedbots_spitter_limit 0
l4d_infectedbots_tank_limit  0
l4d_infectedbots_max_specials 9 

* 請注意，插件在所有遊戲模式中都不會計算witch的數量，但在所有遊戲模式中都會計算tank的數量

2. 如果有4個以上存活的生還者，則調整特感生成限制
例如：
-l4d_infectedbots_max_specials "4"
-l4d_infectedbots_add_specials "2"
-l4d_infectedbots_add_specials_scale "3"
這意味著，如果有4個以上存活的生還者，每3個玩家加入，最大的特殊限制加2
因此，如果有10個存活的生還者，則可生成最大的特感數量爲：4+2+2=8


如果不想設置特感生成限制，可以設置
-l4d_infectedbots_add_specials "0"

3. 如果有4個以上存活的生還者，則調整坦克最大血量
例如：
-l4d_infectedbots_adjust_tankhealth_enable "1"
-l4d_infectedbots_default_tankhealth "4000"
-l4d_infectedbots_add_tankhealth "1200"
-l4d_infectedbots_add_tankhealth_scale "3"
這意味著，有4個以上存活的生還者，每3個玩家加入，tank的最大血量就會增加1200
因此，如果有10個存活的生還者，tank最大血量爲：4000+1200+1200=6400hp

如果想關閉這個功能，不想讓這個插件覆蓋tank最大血量，請設置
-l4d_infectedbots_adjust_tankhealth_enable "0"

4. 如果有4個以上存活的生還者，則調整僵屍最大數量
例如：
- l4d_infectedbots_adjust_commonlimit_enable "1"
- l4d_infectedbots_default_commonlimit "30"
- l4d_infectedbots_add_commonlimit_scale "1"
- l4d_infectedbots_add_commonlimit "2"
這意味著，有4個以上存活的生還者，每壹個玩家加入, 僵屍最大數量將會增加2個
因此，如果有10個存活的生還者，僵屍最大數量爲: 30+2+2+2+2+2+2 = 42

如果想關閉這個功能，不想讓這個插件覆蓋僵屍數量，請設置
-l4d_infectedbots_adjust_commonlimit_enable "0"

5.調整特感生成時間
根據每個存活的生還者，減少壹定數值的特感生成時間，例如：
-l4d_infectedbots_spawn_time_max "60"
-l4d_infectedbots_spawn_time_min "30"
-l4d_infectedbots_adjust_spawn_times "1"
-l4d_infectedbots_adjust_reduced_spawn_times_on_player "2"
這意味著，如果有5個存活的生還者，則特感生成時間爲：[最大: 60-(5*2) = 50, 最小: 30-(5*2) = 20]

如果想關閉這個功能，請設置 
-l4d_infectedbots_adjust_spawn_times "0"

6. 如何生成坦克
例如：
-l4d_infectedbots_tank_limit "2"
-l4d_infectedbots_tank_spawn_probability "5"
這意味著，每次生成特感都有5%的幾率生成tank
請注意，如果達到了tank上限或生成tank的概率爲0%，仍然不會産生坦克 (不影響遊戲生成的坦克)

如果想在最後救援時不生成tank(不影響遊戲生成的坦克)，請設置：
-l4d_infectedbots_tank_spawn_final "0"

7. 如果有4個以上存活的生還者則調整tank生成限制
例如：
-l4d_infectedbots_tank_limit "2"
-l4d_infectedbots_add_tanklimit "1"
-l4d_infectedbots_add_tanklimit_scale "5"
這意味著如果有5個以上存活的生還者，每5個玩家加入，tank可生成上限數量加1
因此，如果有10個存活的生還者，tank可生成上限數量爲: 2+1=3 (不影響遊戲生成的坦克)

如果不想要設置坦克可生成上限數量，請設置：
-l4d_infectedbots_add_tanklimit "0"

8. 在戰役/生還者/寫實中加入感染者
例如：
-l4d_infectedbots_coop_versus "1"
-l4d_infectedbots_coop_versus_join_access "z"
-l4d_infectedbots_coop_versus_human_limit "2"
只有擁有 "z "權限的玩家才能加入感染者陣營，而有權限的玩家只有2個隊伍名額。

如果想所有玩家可以加入感染者陣營，請設置
-l4d_infectedbots_coop_versus_join_access ""

在戰役/生還者/寫實中，感染者玩家將以靈魂狀態下複活：
-l4d_infectedbots_coop_versus_human_ghost_enable "1" 

感染者玩家可以接管生成的tank:
-l4d_infectedbots_coop_versus_tank_playable "1" 

9. 特感生成距離 (僅戰役/寫實)
請注意！這個數字也會影響普通僵屍的生成範圍和靈魂狀態下感染者玩家的複活範圍。
-l4d_infectedbots_spawn_range_min "350"

讓感染者玩家在非常接近幸存者的地方複活，以獲得更好的遊戲體驗。
-l4d_infectedbots_spawn_range_min "0" 

10. 壹次性生成全部特感
只有當所有AI特感的複活時間爲零時，才會生成特感，然後壹起生成。
-l4d_infectedbots_coordination "1" 

當場上有存活的tank時無法生成AI特感
-l4d_infectedbots_spawns_disabled_tank "1" 

11. 其他
a. 如何關閉這個消息？
***[TS] Numbers of Alive Survivor: 4, Infected Limit: 2, Tank Health: 4000, Common Limit: 40***
- l4d_infectedbots_announcement_enable "0" 

b. 如何在戰役/生還者/寫實中關閉感染者玩家的手電筒 ?
- l4d_infectedbots_coop_versus_human_light "0" 

-命令-
(僅戰役/寫實/生還者) !ji - 加入到感染者陣營
(僅戰役/寫實/生還者) !js - 加入到生還者陣營
(僅感染者戰役) !infhud - 開關感染者HUD
(僅感染者戰役) !zs - 感染者玩家自殺 (讓感染者卡住時)
(僅管理員) !timer - 設置僵屍生成時間
(僅管理員) !zlimit - 設置僵屍生成數量