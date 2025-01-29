//此插件0.1秒後設置Tank與特感血量
/********************************************************************************************
* Plugin	: L4D/L4D2 InfectedBots (Versus Coop/Coop Versus)
* Version	: 3.0.2 (2009-2025)
* Game		: Left 4 Dead 1 & 2
* Author	: djromero (SkyDavid, David), MI 5, Harry Potter
* Website	: https://forums.alliedmods.net/showpost.php?p=2699220&postcount=1371
*
* Purpose	: This plugin spawns infected bots in L4D1/2, and gives greater control of the infected bots in L4D1/L4D2.
* WARNING	: Please use sourcemod's latest 1.10 branch snapshot.
* REQUIRE	: left4dhooks (https://forums.alliedmods.net/showthread.php?p=2684862)
*
* Version 3.0.2 (2025-1-29)
*	   - If root admin use !zlimit or !timer to change zombies limit/spawn timer, keep the change until next map or data is reloaded
*	   - Remove common limit
*
* Version 3.0.1 (2025-1-18)
*	   - Support SIPool: https://forums.alliedmods.net/showthread.php?t=346270
*
* Version 3.0.0 (2024-11-08)
*	   - Fixed SI bots still spawn when tank is on the field in l4d1
*
* Version 2.9.9 (2024-11-08)
*	   - Fixed ghost tank bug in non-versus mode if real player in infected team
*	   - Fixed double tank bug in non-versus mode if real player in infected team
*
* Version 2.9.8 (2024-9-14)
*	   - Fixed real SI player can't see the ladder in coop/realism
*
* Version 2.9.7 (2024-8-8)
*	   - Fixed Special Infected Health
*
* Version 2.9.6 (2024-5-1)
*	   - Fixed Enable/Disable cvar
*
* Version 2.9.5 (2024-4-13)
*	   - Fixed Crash when real player playing infected team in coop/realism/survival
*
* Version 2.9.4 (2024-3-25)
*	   - Update Data Config
*	   - Add smoker, boomer, hunter, spitter, jockey, charger health in data
*
* Version 2.9.3 (2024-2-23)
*	   - You can choose to load different data config instead of xxxx.cfg (xxxx = gamemode or mutation name) in data\l4dinfectedbots folder
*	   - Update Data Config
*	   - Update Translation
*	   - Update Cvars
*
* Version 2.9.2 (2024-2-18)
*	   - Update Translation
*	   - Update Commands
*
* Version 2.9.1 (2024-2-14)
*	   - Prevent players from joining infected team and occupy slots forever in coop/survival/realism
*	   - Update Data
*	   - Update Translation
*
* Version 2.9.0 (2024-2-9)
*	   - Change another method to spawn human infected in coop/realism/survival instead of FakeClientCommand
*	   - Add Data config to control spawn timers, spawn limit, tank limit, witch limit, common infected limit.....
*	   - Update Cvars
*	   - Update Commands
*
* Version 2.8.9 (2024-1-27)
*	   - Updated L4D1 Gamedata 
*
* Version 2.8.8 (2023-12-2)
*	   - Infected limit + numbers of survivor + spectators can not exceed 32 slots, otherwise server fails to spawn infected and becomes super lag
*
* Version 2.8.7 (2023-10-9)
*	   - Fixed the code to avoid calling L4D_SetPlayerSpawnTim native from L4D1. (This Native is only supported in L4D2.)
*
* Version 2.8.6 (2023-9-22)
*	   - Fixed "l4d_infectedbots_coordination" not working
*	   - Fixed Bot Spawn timer
*
* Version 2.8.5 (2023-9-17)
*	   - Adjust human spawn timer when 5+ infected slots in versus/scavenge
*	   - In Versus/Scavenge, human infected spawn timer controlled by the official cvars "z_ghost_delay_min" and "z_ghost_delay_max" 
*
* Version 2.8.4 (2023-8-26)
*	   - Improve Code
*
* Version 2.8.3 (2023-7-5)
*	   - Override L4D2 Vscripts to control infected limit.
*
* Version 2.8.2 (2023-5-27)
*	   - Add a convar, including dead survivors or not
*	   - Add a convar, disable infected bots spawning or not in versus/scavenge mode
*
* Version 2.8.1 (2023-5-22)
*	   - Use function L4D_HasPlayerControlledZombies() from left4dhooks to detect if player can join infected in current mode.
*
* Version 2.8.0 (2023-5-5)
*	   - Add Special Infected Weight
*	   - Add and modify convars about Special Infected Weight
*
* Version 2.7.9 (2023-4-13)
*	   - Fixed Not Working in Survival Mode
*	   - Fixed cvar "l4d_infectedbots_adjust_spawn_times" calculation mistake
*
* Version 2.7.8
*	   - Fixed abnormal Tank Bug. Player gets a special infected with tank skin and abilitiesm, but can not attack or throw rock. This bug only happenes in l4d1.
*	   - Fixed Music Bugs when switching to infected team in coop/realism/survival.
*	   - Disable spawn if official cvar "director_no_specials" is 1
*
* Version 2.7.7
*	   - Add convar: "l4d_infectedbots_spawn_where_method", "0", "Where to spawn infected? 0=Near the first ahead survivor. 1=Near the random survivor"
*
* Version 2.7.6
*	   - Add convar: "l4d_infectedbots_spawn_on_same_frame", "0", "If 1, infected bots can spawn on the same game frame (careful, this could cause sever laggy)"
*
* Version 2.7.5
*	   - Spawn special infected near the survivor who is ahead of team
*	   - When game couldn't find a valid spawn position, continue to spawn other speical infected left
*	   - Delete convar "l4d_infectedbots_spawn_range_max", "l4d_infectedbots_spawn_range_final"
*
* Version 2.7.4
*	   - Fixed wrong spawn timer after survivor wipe out 
*	   - Fixed Game does not spawn infected if numbers of human infected player equal to max_specials limit
*	   - Fixed Multi Spawn bug, infected bot spawn too fast.
*	   - Optimize spawn timer codes
*
* Version 2.7.3
*	   - Fixed spawn error in l4d1.
*	   - Give ghost infected player flashLight in coop/realism/survival.
*	   - Fixed tank disappears when being controlled by human player in coop/survival/realism.
*
* Version 2.7.2
*	   - Add more final starts event.
*
* Version 2.7.1
*	   - Add ConVars: l4d_infectedbots_tank_spawn_final, l4d_infectedbots_add_tanklimit_scale, l4d_infectedbots_add_tanklimit
*
* Version 2.7.0
*	   - Fixed infinite suicide after human tank player dead becuase lose control in coop/survival/realism.
*	   - Fixed wrong infected limit if there are human infected player in coop/survival/realism.
*
* Version 2.6.9
*	   - Add convar "l4d_infectedbots_coop_versus_human_ghost_enable", human infected player will spawn as ghost state in coop/survival/realism.
*	   - Remove convar "l4d_infectedbots_admin_coop_versus"
*	   - Add convar "l4d_infectedbots_coop_versus_join_access", Players with these flags have access to join infected team in coop/survival/realism.
*
* Version 2.6.8
*	   - Optimize Infected Spawn Code
*
* Version 2.6.7
*	   - Fixed Spawn Infected Timer error when map transition
*	   - Remove ConVar "l4d_infectedbots_ghost_time", this caused some error model issue in versus
*
* Version 2.6.6
*	   - Changing ConVar in-game takes effect immediately
*	   - Fixed convar 'l4d_infectedbots_coordination' not working
*	   - Fixed convar 'l4d_infectedbots_modes_tog' not working
*
* Version 2.6.5
*	   - Display Tank Health based on gamemode and difficulty (For example, Set Tank health 4000hp, but in Easy: 3000, Normal: 4000, Versus: 6000, Advanced/Expert: 8000)
*
* Version 2.6.4
*	   - Fixed Hunter Tank Bug in l4d1 coop mode when tank is playable.
*	   - Fixed Infected Bot disappear when Infected Bot capped a survivor sometimes
*	   - Remove Camera stuck Fix (if you want to fix, install this plugin by Forgetest: https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_fix_deathfall_cam)
*	   - Remove z_scrimmage_sphere convar to fix some issues, for example: final stage stuck or client game crashes
*
* Version 2.6.3
*	   - Fixed players' camera stuck when finale vehicle leaving.
*	   - Detect l4d1 convar "versus_tank_bonus_health". In l4d1 versus mode, tank hp = z_tank_health * versus_tank_bonus_health.
*	   - Fixed tank spawn probability is not following convar "l4d_infectedbots_tank_spawn_probability"
*
* Version 2.6.2
*	   - Add convars to turn off this plugin.
*
* Version 2.6.1
*	   - Only remove witches that are spawned by this plugin, make sure this plugin won't affect director witch or any other plugin that could spawn witch.
*	   - Compatibility support for SourceMod 1.11. Fixed various warnings.
*
* Version 2.6.0
*	   - Remove point_viewcontrol and point_deathfall_camera entities on the map to fix an official bug that has existed for more than ten years.
*		 (In coop/realism mode, the infected/spectator players' screen would be stuck and frozen when they are watching survivor deathfall or final rescue mission failed)
*
* Version 2.5.9
*	   - Fixed incorrect infected player limit when the real tank player is in game on coop mode. (thanks ZBzibing for reporting: https://forums.alliedmods.net/showpost.php?p=2764042&postcount=1555)
*
* Version 2.5.8
*	   - Fixed OnPluginStart() error "Exception reported: L4D_HasAnySurvivorLeftSafeArea Native is not bound"
*
* Version 2.5.7
*	   - Update L4D1 Gamedata, Thanks BlackSabbarh for reporting
*	   - Add function "bool CanBeSeenBySurvivors(int client)" instead of Netprops "m_hasVisibleThreats", use for kicking coward AI Infected.
*
* Version 2.5.6
*	   - Fixed final maps wouldn't start final rescue in versus.
*	   - Modify spawn range for infected only in coop/realism.
*
* Version 2.5.5
*	   - New ConVar "l4d_infectedbots_announcement_enable", "If 1, announce current plugin status when the number of alive survivors changes."
*	   - Don't override "z_common_limit" when "l4d_infectedbots_adjust_commonlimit_enable" is 0.
*
* Version 2.5.4
*	   - Signature update for L4D2's "2.2.1.3" update
*		 (credit to Lux: https://forums.alliedmods.net/showthread.php?p=2714236)
*
* Version 2.5.3
*	   - In coop, fixed the bug when l4d_infectedbots_infhud_enable set to 0, the human controlled Tank won't get killed when he out of rage meter.
*	   - In coop, fixed the bug when l4d_infectedbots_coop_versus_tank_playable set to 1, if a tank spwans when there are 2 or more human play on the infected side, all the human player will become tank.

* Version 2.5.2
*	   - fixed invalid convar handle in l4d1

* Version 2.5.1
*	   - fixed l4d1 ghost tank bug in coop/survival
*
* Version 2.5.0
*	   - fixed l4d1 doesn't have "z_finale_spawn_mob_safety_range" convar  (thanks darkbret for reporting: https://forums.alliedmods.net/showpost.php?p=2731173&postcount=1510)
*
* Version 2.4.9
*	   - fixed l4d1 faild to load, (thanks Dragokas for reporting: https://forums.alliedmods.net/showpost.php?p=2729460&postcount=1508)
*
* Version 2.4.8
*	   - ProdigySim's method for indirectly getting signatures added, created the whole code for indirectly getting signatures so the plugin can now withstand most updates to L4D2!
*		(Thanks to Shadowysn: https://forums.alliedmods.net/showthread.php?t=320849)
*		(Thanks to ProdigySim: https://github.com/ProdigySim/DirectInfectedSpawn)
*
* Version 2.4.7
*	   - Signature fix for 12/8/2020 update.
*		(Thanks to Shadowysn: https://forums.alliedmods.net/showthread.php?t=320849)
*		(Stupid IDIOT TLS team, pushing unuseful updates no one really cares or asks for. Come on! Value)
*
* Version 2.4.6
*	   - Signature fix for 12/2/2020 update.
*		(Credit to Shadowysn: https://forums.alliedmods.net/showthread.php?t=320849)
*		(TLS team, please stop unuseless update)
*
* Version 2.4.5
*	   - survivor glow color issue in coop/survival mode.
*	   - add "FlashlightIsOn" signature in l4d2, add "FlashlightIsOn" offset in l4d1.
		(Credit to Machine: https://forums.alliedmods.net/member.php?u=74752)
*	   - Light up SI ladders in coop/realism/survival. mode for human infected players. (l4d2 only)

* Version 2.4.4
*	   - fixed plugin not working if player disconnects when map change.
*
* Version 2.4.3
*	   - Add The last stand new convar "z_finale_spawn_mob_safety_range".
*
* Version 2.4.2
*	   - fixed infected bot got kicked issue sometimes.
*
* Version 2.4.1
*	   - Update gamedata, credit to Lux: https://forums.alliedmods.net/showthread.php?p=2714236
*
* Version 2.4.0
*	   - Fixed no common infected issue sometimes.
*
* Version 2.3.9
*	   - Update Gamedata for L4D2 "The Last Stand" update.
*		(Thanks to Shadowysn's work, [L4D1/2] Direct Infected Spawn (Limit-Bypass), https://forums.alliedmods.net/showthread.php?t=320849)
*	   - Remove infected hud when you are spectator.
*
* Version 2.3.8
*	   - Fixed Native "L4D2_SpawnWitchBride" was not found in l4d1.
*	   - Fixed L4D2 ConVars Invalid convar handle in l4d1.
*	   - Fixed L4D2 ConVars signature not found in l4d1.
*
* Version 2.3.7
*	   - Fixed Wrong Zombie Class.
*	   - prevent memory leak handle and timer.
*	   - spawn Witch bride in the passing map 1 (spawning normal witch in this map will crash server).
*	   - Disable survivor glow when no infected players. Enable survivor glow when there are infected players in coop/realism/survival. mode
*	   - Fixed no common spawning issue when "l4d_infectedbots_adjust_commonlimit_enable" is 0
*
* Version 2.3.6
*	   - require left4dhooks (https://forums.alliedmods.net/showthread.php?p=2684862)
*	   - update gamedata, credit to Shadowysn's work (https://forums.alliedmods.net/showthread.php?t=320849)
*	   - improve SI spawing code.
*	   - support sourcemod's latest 1.10 or above, time to upgrade and get a dedicated server
*
* Version 2.3.5
*	   - light up SI ladders in coop/realism/survival. mode for human infected players. (didn't work if you host a listen server)
*	   - remove convar "music_manager" setting.
*	   - add survivor glow in coop/realism/survival. mode for human infected players.
*
* Version 2.3.4
*	   - fixed special limit keep adding issue when map change.
*	   - fixed Invalid timer handle.
*
* Version 2.3.3
*	   - fixed Invalid timer handle.
*	   - fixed colddown timer issue.
*	   - fixed wrong special limit if numbers of alive survivors are less then 4
*	   - fixed l4d1 doesn't have "z_finale_spawn_tank_safety_range" convar
*	   - update translation
*
* Version 2.3.2
*	   - control zombie common limit.
*	   - Add Convar "l4d_infectedbots_adjust_commonlimit_enable"
*	   - Add Convar "l4d_infectedbots_default_commonlimit"
*	   - Add Convar "l4d_infectedbots_add_commonlimit_scale"
*	   - Add Convar "l4d_infectedbots_add_commonlimit"
*	   - update translation.
*	   - fixed "l4d_infectedbots_coordination" and "l4d_infectedbots_spawns_disabled_tank" convar.
*	   - fixed no bot spawning when infected bot got kicked.
*	   - Deleted "l4d_infectedbots_director_spawn" Convar
*	   - fixed music glitch, set convar "music_manager" to 0 when playing infected team in coop/survival/realism, this would turn off l4d music system.
*
* Version 2.3.1
*	   - added reward sound in coop/survival/realism for real infected player.
*	   - prevet real infected player from fall damage in coop/survival/realism.
*
* Version 2.3.0
*	   - fixed client console error "Material effects/spawn_sphere has bad reference count 0 when being bound" spam when playing infected in non-versus mode.
*	   - special max limit now counts tank in all gamemode.
*	   - added PlayerLeftStartTimer.
*	   - fixed no infected bots issue when reload/load this plugin during the game.
*	   - added new event "round_end", "map_transition", "mission_lost", "finale_vehicle_leaving" as round end.
*	   - fixed special max limit not correct when map change or reload/load this plugin during the game .
*	   - check infected team max slots limit for players when player changes team to infected team in coop/realism/survival.
*	   - deleted TankFrustStop.
*	   - added player ghost check when tank player frustrated.
*	   - fixed Ghost GhostTankBugFix in coop/realism.
*	   - updated gamedata, add signature "NextBotCreatePlayerBot<Tank>"
*
* Version 2.2.7
*	   - fixed bug that wrong respawn timer when playing infected in coop/realism/survival mode.
*
* Version 2.2.6
*	   - adjust special limit and tank health depends on 4+ ALIVE survivor players"
*	   - port l4d1
*	   - 10 seconds can not suicide after infected player spawn
*
* Version 2.2.5
*	   - Add Convar "l4d_infectedbots_sm_zs_disable_gamemode".
*	   - Fixed "l4d_infectedbots_coordination" not working with tank.
*
* Version 2.2.4
*	   - Add Translation.
*	   - Fixed "l4d_infectedbots_coordination" not working.
*	   - Improve new syntax code.
*	   - Add Translation.
*
* Version 2.2.3
*	   - Add Convar "l4d_infectedbots_adjust_tankhealth_enable"
*
* Version 2.2.2
*	   - Fixed l4d_infectedbots_safe_spawn error
*	   - Add Convar "l4d_infectedbots_tank_spawn_probability"
*	   - Fixed Spawn Witch error
*
* Version 2.2.1
*	   - Infected Player can't suicide if he got survivor
*	   - Kill Tank if tank player frustrated in coop/survival
*	   - Player will be killed if enter ghost state in coop/survival
*	   - Removed Convar "l4d_infectedbots_ghost_spawn"
*
* Version 2.2.0
*	   - Convert all to New Syntax
*	   - Add Convar "l4d_infectedbots_reduced_spawn_times_on_player"
*	   - Add Convar "l4d_infectedbots_safe_spawn"
*	   - Add Convar "l4d_infectedbots_spawn_range_min"
*	   - Add Convar "l4d_infectedbots_spawn_range_max"
*	   - Add Convar "l4d_infectedbots_spawn_range_final"
*	   - Add Convar "l4d_infectedbots_witch_spawn_time_max",
*	   - Add Convar "l4d_infectedbots_witch_spawn_time_min"
*	   - Add Convar "l4d_infectedbots_witch_spawn_final"
*	   - Add Convar "l4d_infectedbots_witch_lifespan"
*	   - Add Convar "l4d_infectedbots_add_specials_scale"
*	   - Add Convar "l4d_infectedbots_add_tankhealth_scale"
*
* Version 2.1.5
*	   - Add sm_zlimit - control max special zombies limit (adm only)
*	   - Add sm_timer - control special zombies spawn timer (adm only)
*	   - Removed TurnNightVisionOn, use Another TurnFlashlightOn Model without signature
*
* Version 2.1.4
*	   - Fixed "l4d_infectedbots_max_specials" and "l4d_infectedbots_add_specials" not working
*
* Version 2.1.3
*	   - Add Convar "l4d_infectedbots_witch_max_limit", Sets the maximum limit for witches spawned by the plugin (does not affect director witches)
*	   - Remove TurnFlashlightOn since TurnFlashlightOn signature is broken and cause server crash
*	   - Add TurnNightVisionOn for infected player in coop/survival
*	   - Add sm_zs for infected player to suicide if stuck
*
* Version 2.1.2
*	   - Fixed tank spawn bug
*	   - Fixed Not enough space on the stack "BotTypeNeeded"
*
* Version 2.1.1
* 	   - Defines how many special infected according to current player numbers
* 	   - Defines Tank Health according to current player numbers
*
* Version 2.1.0
* 	   - Remove some Ai improvements cvar
*
* Version 2.0.0
* 	   - Fixed error that would occur on OnPluginEnd
*
* Version 1.9.9
* 	   - Fixed bug where the plugin would break under the new DLC
*
* Version 1.9.8
*
* 	   Cvars Renamed:
*	   - l4d_infectedbots_infected_team_joinable has been renamed to l4d_infectedbots_coop_versus
* 	   - l4d_infectedbots_admins_only has been renamed to l4d_infectedbots_admin_coop_versus
* 	   - l4d_infectedbots_jointeams_announce has been renamed to l4d_infectedbots_coop_versus_announce
* 	   - l4d_infectedbots_human_coop_survival_limit has been renamed to l4d_infectedbots_coop_versus_human_limit
* 	   - l4d_infectedbots_coop_survival_tank_playable has been renamed to l4d_infectedbots_coop_versus_tank_playable
*
* 	   - Added l4d_infectedbots_versus_coop cvar, forces all players onto the infected side in versus against survivor bots
* 	   - Changed the Round Start event trigger
* 	   - l4d_infectedbots_adjust_spawn_times cvar added, if set to 1, it adjusts the spawn timers depending on the gamemode (depends on infected players in versus, survivors in coop)
* 	   - Enhanced Jockey and Spitter AI for versus (Removed delay between jockey jumps, and spitter now attacks the moment she recharges)
* 	   - Director class limits for survival that are changed using an server config  at startup will no longer reset to their defaults
* 	   - l4d_infectedbots_admin_coop_versus and l4d_infectedbots_coop_versus_announce is now defaulted to 0 (off)
* 	   - Fixed bug in scavenge where bots would not spawn
*
* Version 1.9.7
* 	   - Added compatibilty for Four Swordsmen, Hard Eight, Healthapocalypse and Gib Fest
* 	   - Fixed bug created by Valve that would ghost the tank if there was an infected player in coop/survival
* 	   - Removed l4d_infectedbots_instant_spawns cvar and replaced it with l4d_infectedbots_initial_spawn_timer
* 	   - Changed how the cheat command found valid clients
*
* Version 1.9.6
* 	   - Fixed bug in L4D 1 where the map would restart after completion
* 	   - Added Tank spawning to the plugin with cvar l4d_infectedbots_tank_limit
* 	   - Added support for Versus Survival
* 	   - Plugin class limits no longer affect director spawn limits due to the director not obeying the limits (ie: l4d_infectedbots_boomer_limit no longer affects z_boomer_limit)
*
* Version 1.9.5
* 	   - Removed incorrect gamemode message, plugin will assume unknown gamemodes/mutations are based on coop
* 	   - Fixed spitter acid glitch
* 	   - Compatible with "Headshot!" mutation
* 	   - Added cvar l4d_infectedbots_spawns_disabled_tank: disables infected bot spawning when a tank is in play
*
* Version 1.9.4
* 	   - Compatible with new mutations: Last Man On Earth, Chainsaw Massacre and Room for One
*
* Version 1.9.3
* 	   - Added support for chainsaws gamemode
* 	   - Changed how the plugin detected dead/alive players
* 	   - Changed code that used GetEntData/SetEntData to GetEntProp/SetEntProp
* 	   - Fixed typo in detecting the game
* 	   - Fixed an error caused by line 4300
*
* Version 1.9.2
* 	   - Fixed bug with clients joining infected automatically when l4d_infectedbots_admins_only was set to 1
* 	   - Fixed some error messages that pop up from certain events
* 	   - Re-added feature: Bots in versus or scavenger will now ghost before they spawn completely
* 	   - Added cvar: l4d_infectedbots_ghost_time
*	   - Renamed cvar: l4d_infectedbots_idle_time_before_slay to l4d_infectedbots_lifespan
* 	   - Removed cvar: l4d_infectedbots_timer_hurt_before_slay (it's now apart of l4d_infectedbots_lifespan)
* 	   - l4d_infectedbots_lifespan timer now kicks instead of slaying the infected
* 	   - If an infected sees the survivors when his lifespan timer is up, the timer will be made anew (prevents infected being kicked while they are attacking or nearby)
* 	   - (for coop/survival only) When a tank spawns and then kicked for a player to take over, there is now a check to see if the tank for the player to take over actually spawned successfully
* 	   - Plugin is now compatible with the new mutation gamemode and any further mutations
*
* Version 1.9.1 V3
* 	   - Fixed bug with bot spawns (especially with 4+ infected bots)
* 	   - Fixed an error that was caused when the plugin was unloaded
*
* Version 1.9.1 V2
* 	   - Fixed bug with server hibernation that was caused by rewrite of round start code (thanks Lexantis)
*
* Version 1.9.1
* 	   - Changed Round start code which fixed a bug with survival (and possibly other gamemodes)
* 	   - Changed how the class limit cvars work, they can now be used to alter director spawning cvars (z_smoker_limit, z_hunter_limit, etc.)
* 	   - l4d_infectedbots_hunter_limit cvar added to L4D
* 	   - Added cvar l4d_infectedbots_instant_spawns, allows the plugin to instantly spawn the infected at the start of a map and the start of finales
* 	   - Fixed bug where survivors were slayed for no reason
* 	   - Fixed bug where Valve's bots would still spawn on certain maps
* 	   - Added cvar l4d_infectedbots_human_coop_survival_limit
* 	   - Added cvar l4d_infectedbots_admins_only
* 	   - Changed how the "!js" function worked, no longer uses jointeam (NEW GAMEDATA FILE BECAUSE OF THIS)
* 	   - Class limit cvars by this plugin no longer affect z_versus class player limits (l4d_infectedbots_smoker_limit for example no longer affects z_versus_smoker_limit)
*	   - Altered descriptions of the class limit cvars
*
* Version 1.9.0
*      - Workaround implemented to get around Coop Limit (L4D2)
* 	   - REALLY fixed the 4+1 bug now
* 	   - REALLY fixed the survivor bots running out of the safe room bug
* 	   - Fixed bug where setting l4d_infectedbots_spawn_time to 5 or below would not spawn bots
* 	   - Removed cvar l4d_infectedbots_spawn_time and added cvars l4d_infectedbots_spawn_max_time and l4dinfectedbots_spawn_min_time
*	   - Changed code on how the game is detected on startup
* 	   - Removed FCVAR_NOTIFY from all cvars except the version cvar
* 	   - If l4d_infectedbots_infected_team_joinable is 0, plugin will not set sb_all_bot_team to 1
* 	   - Infected HUD can now display multiple tanks on fire along with the tank's health
* 	   - Coop tank takeover now supports multiple tanks
* 	   - Fixed bug where some players would not ghost in coop when they first spawn in a map
* 	   - Removed most instances where the plugin would cause a BotType error
* 	   - L4D bot spawning changed, now random like L4D2 instead of prioritized classes
* 	   - Fixed bug where players would be stuck at READY and never spawn
*
* Version 1.8.9
* 	   - Gamedata file uses Signatures instead of offsets
* 	   - Enabling Director Spawning in Versus will activate Valve's bots
* 	   - Reverted back to original way of joining survivors (jointeam instead of sb_takecontrol)
* 	   - Bots no longer run out of the safe room before a player joins into the game
* 	   - Fixed bug when a tank spawned and its special infected taken over by a bot, would be able to spawn again if it died such as 4+1 bot
*
* Version 1.8.8
* 	   - Disables Valve's versus bots automatically
* 	   - Based on AtomicStryker's version (fixes z_spawn bug along with gamemode bug)
* 	   - Removed L4D seperate plugin, this one plugin supports both
* 	   - Fixed strange ghost speed bug
* 	   - Added Flashlights and FreeSpawning for both L4D and L4D2 without resorting to changing gamemodes
* 	   - Now efficiently unlocks a versus start door when there are no players on infected (L4D 1 only)
*
* Version 1.8.7
* 	   - Fixed Infected players not spawning correctly
*
* Version 1.8.6
* 	   - Added a timer to the Gamemode ConVarHook to ensure compatitbilty with other gamemode changing plugins
* 	   - Fight or die code added by AtomicStryker (kills idle bots, very useful for coordination cvar) along with two new cvars: l4d2_infectedbots_idle_time_before_slay and l4d2_infectedbots_timer_hurt_before_slay
* 	   - Fixed bug where the plugin would return the BotType error even though the sum of the class limits matched that of the cvar max specials
* 	   - When the plugin is unloaded, it resets the convars that it changed
* 	   - Fixed bug where if Free Spawning and Director Spawning were on, it would cause the gamemode to stay on versus
*
* Version 1.8.5
* 	   - Optimizations by AtomicStryker
* 	   - Removed "Multiple tanks" code from plugin
* 	   - Redone tank kicking code
* 	   - Redone tank health fix (Thanks AtomicStryker!)
*
* Version 1.8.4
* 	   - Adapted plugin to new gamemode "teamversus" (4x4 versus matchmaking)
*	   - Fixed bug where Survivor bots didn't have their health bonuses count
* 	   - Added FCVAR_NOTIFY to cvars to prevent clients from changing server cvars
*
* Version 1.8.3
* 	   - Enhanced Hunter AI (Hunter bots pounce farther, versus only)
* 	   - Model detection methods have been replaced with class detections (Compatible with Character Select Menu)
* 	   - Fixed VersusDoorUnlocker not working on the second round
* 	   - Added cvar l4d_infectedbots_coordination (bots will wait until all other bot spawn timers are 0 and then spawn at once)
*
* Version 1.8.2
* 	   - Added Flashlights to the infected
* 	   - Prevented additional music from playing when spawning as an infected
* 	   - Redid the free spawning system, more robust and effective
* 	   - Fixed bug where human tanks would break z_max_player_zombies (Now prevents players from joining a full infected team in versus when a tank spawns)
* 	   - Redid the VersusDoorUnlocker, now activates without restrictions
* 	   - Fixed bug where tanks would keep spawning over and over
* 	   - Fixed bug where the HUD would display the tank on fire even though it's not
* 	   - Increased default spawn time to 30 seconds
*
* Version 1.8.1 Fix V1
* 	   - Changed safe room detection (fixes Crash Course and custom maps) (Thanks AtomicStryker!)
*
* Version 1.8.1
* 	   - Reverted back to the old kicking system
* 	   - Fixed Tank on fire timer for survival
* 	   - Survivor players can no longer join a full infected team in versus when theres a tank in play
* 	   - When a tank spawns in coop, they are not taken over by a player instantly; instead they are stationary until the tank moves, and then a player takes over (Thanks AtomicStryker!)
*
* Version 1.8.0
* 	   - Fixed bug where the sphere bubbles would come back after the player dies
* 	   - Fixed additional bugs coming from the "mp_gamemode/server.cfg" bug
* 	   - Now checks if the admincheats plugin is installed and adapts
* 	   - Fixed Free spawn bug that prevent players from spawning as ghosts on the third map (or higher) on a campaign
* 	   - Fixed bug with spawn restrictions (was counting dead players as alive)
* 	   - Added ConVarHooks to Infected HUD cvars (will take effect immediately after being changed)
* 	   - Survivor Bots won't move out of the safe room until the player is fully in game
* 	   - Bots will not be shown on the infected HUD when they are not supposed to be (being replaced by a player on director spawn mode, or a tank being kicked for a player tank to take over)
*
* Version 1.7.9
* 	   - Fixed a rare bug where if a map changed and director spawning is on, it would not allow the infected to be playable
* 	   - Removed Sphere bubbles for infected and spectators
* 	   - Modified Spawn restriction system
* 	   - Fixed bug where changing class limits on the spot would not take effect immediately
* 	   - Removed infected bot ghosts in versus, caused too many bugs
* 	   - Director spawn can now be changed in-game without a restart
* 	   - The Gamemode being changed no longer needs a restart
* 	   - Fixed bug where if admincheats is installed and an admin picked to spawn infected did not have root, would not spawn the infected
* 	   - Fixed bug where players could not spawn as ghosts in versus if the gamemode was set in a server.cfg instead of the l4d dedicated server tool (which still has adverse effects, plugin or not)
*
* Version 1.7.8
* 	   - Removed The Dedibots, Director and The Spawner, from spec, the bots still spawn and is still compatible with admincheats (fixes 7/8 human limit reached problem)
* 	   - Changed the format of some of the announcements
* 	   - Reduced size of HUD
* 	   - HUD will NOT show infected players unless there are more than 5 infected players on the team (Versus only)
* 	   - KillInfected function now only applies to survival at round start
* 	   - Fixed Tank turning into hunter problem
* 	   - Fixed Special Smoker bug and other ghost related problems
* 	   - Fixed music glitch where certain pieces of music would keep playing over and over
* 	   - Fixed bug when a SI bot dies in versus with director spawning on, it would keep spawning that bot
* 	   - Fixed 1 health point bug in director spawning mode
* 	   - Fixed Ghost spawning bug in director spawning mode where all ghosts would spawn at once
* 	   - Fixed Coop Tank lottery starting for versus
* 	   - Fixed Client 0 error with the Versus door unlocker
* 	   - Added cvar: l4d_infectedbots_jointeams_announce
*
* Version 1.7.7
* 	   - Support for admincheats (Thanks Whosat for this!)
* 	   - Reduced Versus checkpoint door unlocker timer to 10 seconds (no longer shows the message)
* 	   - Redone Versus door buster, now it simply unlocks the door
* 	   - Fixed Director Spawning bug when free spawn is turned on
* 	   - Added spawn timer to Director Spawning mode to prevent one player from taking all the bots
* 	   - Now shows respawn timers for bots in Versus
* 	   - When a player takes over a tank in coop/survival, the SI no longer disappears
* 	   - Redone Tank Lottery (Thanks AtomicStryker!)
* 	   - There is no limit on player tanks now
* 	   - Entity errors should be fixed, valid checks implemented
* 	   - Cvars that were changed by the plugin can now be changed with a server.cfg
*      - Director Spawning now works correctly when the value is changed from being 0 or 1
* 	   - Infected HUD now shows the health of the infected, rather than saying "ALIVE"
* 	   - Fixed Ghost bug on Survival start after a round (Kills all ghosts)
* 	   - Tank Health now shown properly in infected HUD
* 	   - Changed details of the infected HUD when Director Spawning is on
* 	   - Reduced the chances of the stats board appearing
*
* Version 1.7.6
* 	   - Finale Glitch is fixed completely, no longer runs on timers
* 	   - Fixed bug with spawning when Director Spawning is on
* 	   - Added cvar: l4d_infectedbots_stats_board, can turn the stats board on or off after an infected dies
* 	   - Optimizations here and there
* 	   - Added a random system where the tank can go to anyone, rather than to the first person on the infected team
* 	   - Fixed bug where 4 specials would spawn when the tank is playable and on the field
* 	   - Fixed Free spawn bug where laggy players would not be ghosted
* 	   - Errors related to "SetEntData" have been fixed
* 	   - MaxSpecials is no longer linked to Director Spawning
*
* Version 1.7.5
* 	   - Added command to join survivors (!js)
* 	   - Removed cvars: l4d_infectedbots_allow_boomer, l4d_infectedbots_allow_smoker and l4d_infectedbots_allow_hunter (redundent with new cvars)
* 	   - Added cvars: l4d_infectedbots_boomer_limit and l4d_infectedbots_smoker_limit
*	   - Added cvar: l4d_infectedbots_infected_team_joinable, cvar that can either allow or disallow players from joining the infected team on coop/survival
* 	   - Cvars renamed:  l4d_infectedbots_max_player_zombies to l4d_infectedbots_max_specials, l4d_infectedbots_tank_playable to l4d_infectedbots_coop_survival_tank_playable
* 	   - Bug fix with l4d_infectedbots_max_specials and l4d_infectedbots_director_spawn not setting correctly when the server first starts up
* 	   - Improved Boomer AI in versus (no longer sits there for a second when he is seen)
* 	   - Autoconfig (was applied in 1.7.4, just wasn't shown in the changelog) Be sure to delete your old one
* 	   - Reduced the chances of the director misplacing a bot
* 	   - If the tank is playable in coop or survival, a player will be picked as the tank, regardless of the player's status
* 	   - Fixed bug where the plugin may return "[L4D] Infected Bots: CreateFakeClient returned 0 -- Infected bot was not spawned"
* 	   - Removed giving health to infected when they spawn, they no longer need this as Valve fixed this bug
* 	   - Tank_killed game event was not firing due to the tank not being spawned by the director, this has been fixed by setting it in the player_death event and checking to see if it was a tank
* 	   - Fixed human infected players causing problems with infected bot spawning
* 	   - Added cvar: l4d_infectedbots_free_spawn which allows the spawning in coop/survival to be like versus (Thanks AtomicStryker for using some of your code from your infected ghost everywhere plugin!)
*	   - If there is only one survivor player in versus, the safe room door will be UTTERLY DESTROYED.
* 	   - Open slots will be available to tanks by automatically increasing the max infected limit and decreasing when the tanks are killed
*	   - Bots were not spawning during a finale. This bug has been fixed.
* 	   - Fixed Survivor death finale glitch which would cause all player infected to freeze and not spawn
* 	   - Added a HUD that shows stats about Infected Players of when they spawn (from Durzel's Infected HUD plugin)
* 	   - Priority system added to the spawning in coop/survival, no longer does the first infected player always get the first infected bot that spawns
* 	   - Modified Spawn Restrictions
* 	   - Infected bots in versus now spawn as ghosts, and fully spawn two seconds later
* 	   - Removed commands that kicked with ServerCommand, this was causing crashes
* 	   - Added a check in coop/survival to put players on infected when they first join if the survivor team is full
* 	   - Removed cvar: l4d_infectedbots_hunter_limit
*
* Version 1.7.4
* 	   - Fixed bots spawning too fast
* 	   - Completely fixed Ghost bug (Ghosts will stay ghosts until the play spawns them)
* 	   - New cvar "l4d_infectedbots_tank_playable" that allows tanks to be playable on coop/survival
*
* Version 1.7.3
* 	   - Removed timers altogether and implemented the "old" system
* 	   - Fixed server hibernation problem
* 	   - Fixed error messages saying "Could not use ent_fire without cheats"
* 	   - Fixed Ghost spawning infront of survivors
* 	   - Set the spawn time to 25 seconds as default
* 	   - Fixed Checking bot mechanism
*
* Version 1.7.2a
* 	   - Fixed bots not spawning after a checkpoint
* 	   - Fixed handle error
*
* Version 1.7.2
*      - Removed autoconfig for plugin (delete your autoconfig for this plugin if you have one)
*      - Reintroduced coop/survival playable spawns
*      - spawns at conistent intervals of 20 seconds
*      - Overhauled coop special infected cvar dectection, use z_versus_boomer_limit, z_versus_smoker_limit, and l4d_infectedbots_versus_hunter_limit to alter amount of SI in coop (DO NOT USE THESE CVARS IF THE DIRECTOR IS SPAWNING THE BOTS! USE THE STANDARD COOP CVARS)
*      - Timers implemented for preventing the SI from spawning right at the start
*      - Fixed bug in 1.7.1 where the improved SI AI would reset to old after a map change
* 	   - Added a check on game start to prevent survivor bots from leaving the safe room too early when a player connects
* 	   - Added cvar to control the spawn time of the infected bots (can change at anytime and will take effect at the moment of change)
* 	   - Added cvar to have the director control the spawns (much better coop experience when max zombie players is set above 4), this however removes the option to play as those spawned infected
*	   - Removed l4d_infectedbots_coop_enabled cvar, l4d_infectedbots_director_spawn now replaces it. You can still use l4d_infectedbots_max_players_zombies
* 	   - New kicking mechanism added, there shouldn't be a problem with bots going over the limit
* 	   - Easier to join infected in coop/survival with the sm command "!ji"
* 	   - Introduced a new kicking mechanism, there shouldn't be more than the max infected unless there is a tank
*
* Version 1.7.1
*      - Fixed Hunter AI where the hunter would run away and around in circles after getting hit
*      - Fixed Hunter Spawning where the hunter would spawn normally for 5 minutes into the map and then suddenly won't respawn at all
*      - An all Survivor Bot team can now pass the areas where they got stuck in (they can move throughout the map on their own now)
*      - Changed l4d_versus_hunter_limit to l4d_infectedbots_versus_hunter_limit with a new default of 4
*      - It is now possible to change l4d_infectedbots_versus_hunter_limit and l4d_infectedbots_max_player_zombies in-game, just be sure to restart the map after change
*      - Overhauled the plugin, removed coop/survival infected spawn code, code clean up
*
* Version 1.7.0
*      - Fixed sb_all_bot_team 1 is now set at all times until there are no players in the server.
*      - Survival/Coop now have playable Special Infected spawns.
*      - l4d_infectedbots_enabled_on_coop cvar created for those who want control over the plugin during coop/survival maps.
*      - Able to spectate AI Special Infected in Coop/Survival.
*      - Better AI (Smoker and Boomer don't sit there for a second and then attack a survivor when its within range).
*      - Set the number of VS team changes to 99 if its survival or coop, 2 for versus
*      - Safe Room timer added to coop/survival
*      - l4d_versus_hunter_limit added to control the amount of hunters in versus
*      - l4d_infectedbots_max_player_zombies added to increase the max special infected on the map (Bots and players)
*      - Autoexec created for this plugin
*
* Version 1.6.1
* 		- Changed some routines to prevent crash on round end.
*
* Version 1.6
* 		- Finally fixed issue of server hanging on mapchange or when last player leaves.
* 		  Thx to AcidTester for his help testing this.
* 		- Added cvar to disable infected bots HUD
*
* Version 1.6
* 		- Fixed issue of HUD's timer not beign killed after each round.
* Version 1.5.8
* 		- Removed the "kickallbots" routine. Used a different method.
*
* Version 1.5.6
* 		- Rollback on method for detecting if map is VS
*
* Version 1.5.5
* 		- Fixed some issues with infected boomer bots spawning just after human boomer is killed.
* 		- Changed method of detecting VS maps to allow non-vs maps to use this plugin.
*
* Version 1.5.4
* 		- Fixed (now) issue when all players leave and server would keep playing with only
* 		  survivor/infected bots.
*
* Version 1.5.3
* 		- Fixed issue when boomer/smoker bots would spawn just after human boomer/smoker was
* 		  killed. (I had to hook the player_death event as pre, instead of post to be able to
* 		  check for some info).
* 		- Added new cvar to control the way you want infected spawn times handled:
* 			l4d_infectedbots_normalize_spawntime:
* 				0 (default): Human zombies will use default spawn times (min time if less
* 							 than 3 players in team) (min default is 20)
* 				1		   : Bots and human zombies will have the same spawn time.
* 							 (max default is 30).
* 		- Fixed issue when all players leave and server would keep playing with only
* 	 	  survivor/infected bots.
*
* Version 1.5.2
* 		- Normalized spawn times for human zombies (min = max).
* 		- Fixed spawn of extra bot when someone dead becomes a tank. If player was alive, his
* 		  bot will still remain if he gets a tank.
* 		- Added 2 new cvars to disallow boomer and/or smoker bots:
* 			l4d_infectedbots_allow_boomer = 1 (allow, default) / 0 (disallow)
* 			l4d_infectedbots_allow_smoker = 1 (allow, default) / 0 (disallow)
*
* Version 1.5.1
* 		- Major bug fixes that caused server to hang (infite loops and threading problems).
*
* Version 1.5
* 		- Added HUD panel for infected bots. Original idea from: Durzel's Infected HUD plugin.
* 		- Added validations so that boomers and smokers do not spawn too often. A boomer can
* 		  only spawn (as a bot) after XX seconds have elapsed since the last one died.
* 		- Added/fixed some routines/validations to prevent memory leaks.
*
* Version 1.4
* 		- Infected bots can spawn when a real player is dead or in ghost mode without forcing
* 		  them (real players) to spawn.
* 		- Since real players won't be forced to spawn, they won't spawn outside the map or
* 		  in places they can't get out (where only bots can get out).
*
* Version 1.3
* 		- No infected bots are spawned if at least one player is in ghost mode. If a bot is
* 		  scheduled to spawn but a player is in ghost mode, the bot will spawn no more than
* 		  5 seconds after the player leaves ghost mode (spawns).
* 		- Infected bots won't stay AFK if they spawn far away. They will always search for
* 		  survivors even if they're far from them.
* 		- Allows survivor's team to be all bots, since we can have all bots on infected's team.
*
* Version 1.2
* 		- Fixed several bugs while counting players.
* 		- Added chat message to inform infected players (only) that a new bot has been spawned
*
* Version 1.1.2
* 		- Fixed crash when counting
*
* Version 1.1.1
* 		- Fixed survivor's quick HUD refresh when spawning infected bots
*
* Version 1.1
* 		- Implemented "give health" command to fix infected's hud & pounce (hunter) when spawns
*
* Version 1.0
* 		- Initial release.
*
*
**********************************************************************************************/
#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <left4dhooks>
#undef REQUIRE_PLUGIN
#tryinclude <si_pool_plus>

#define PLUGIN_NAME			    "l4dinfectedbots"
#define PLUGIN_VERSION 			"3.0.2-2025/1/29"
#define DEBUG 0

#define GAMEDATA_FILE           PLUGIN_NAME

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3
#define TEAM_HOLD_OUT		4

#define ZOMBIECLASS_SMOKER	1
#define ZOMBIECLASS_BOOMER	2
#define ZOMBIECLASS_HUNTER	3
#define ZOMBIECLASS_SPITTER	4
#define ZOMBIECLASS_JOCKEY	5
#define ZOMBIECLASS_CHARGER	6

#define NUM_TYPES_INFECTED_MAX 7 // for spawning
int SI_SMOKER = 0;
int SI_BOOMER = 1;
int SI_HUNTER = 2;
int SI_SPITTER = 3;
int SI_JOCKEY = 4;
int SI_CHARGER = 5;
int SI_TANK = 6;

#define SUICIDE_TIME 10
// Infected models
#define MODEL_SMOKER "models/infected/smoker.mdl"
#define MODEL_BOOMER "models/infected/boomer.mdl"
#define MODEL_HUNTER "models/infected/hunter.mdl"
#define MODEL_SPITTER "models/infected/spitter.mdl"
#define MODEL_JOCKEY "models/infected/jockey.mdl"
#define MODEL_CHARGER "models/infected/charger.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
#define ZOMBIESPAWN_Attempts 7
#define IGNITE_TIME 3600.0

#define MAXENTITIES                   2048
#define ENTITY_SAFE_LIMIT 2000 //don't spawn boxes when it's index is above this

// l4d1/2 value
int ZOMBIECLASS_TANK;
int NUM_INFECTED;

int InfectedRealCount; // Holds the amount of real alive infected players
int InfectedRealQueue; // Holds the amount of real infected players that are going to spawn
int InfectedBotCount; // Holds the amount of infected bots in any gamemode
int InfectedBotQueue; // Holds the amount of bots that are going to spawn (including human infected player in coop/realism/survival)
//int SurvivorCount, SpectatorCount;
int AllPlayerCount;
int g_iCurrentMode = 0; // Holds the g_iCurrentMode, 1 for coop and realism, 2 for versus, teamversus, scavenge and teamscavenge, 3 for survival
int g_iSpawnCounts[NUM_TYPES_INFECTED_MAX];
Handle g_hSpawnColdDownTimer[NUM_TYPES_INFECTED_MAX];
int g_iPlayersInSurvivorTeam;

bool b_HasRoundStarted, // Used to state if the round started or not
	g_bHasRoundEnded, // States if the round has ended or not
	g_bLeftSaveRoom, // States if the survivors have left the safe room
	g_bFinaleStarted, // States whether the finale has started or not
	PlayerLifeState[MAXPLAYERS+1], // States whether that player has the lifestate changed from switching the gamemode
	g_bInitialSpawn, // Related to the coordination feature, tells the plugin to let the infected spawn when the survivors leave the safe room
	g_bL4D2Version, // Holds the version of L4D; false if its L4D, true if its L4D2
	PlayerHasEnteredStart[MAXPLAYERS+1],
	bDisableSurvivorModelGlow, 
	g_bSurvivalStart, 
	g_bIsCoordination,
	g_bSomeCvarChanged;

ConVar sb_all_bot_game, allow_all_bot_survivor_team, sb_all_bot_team, vs_max_team_switches, z_max_player_zombies,
	director_no_specials, director_allow_infected_bots, z_ghost_delay_min, z_ghost_delay_max;
int vs_max_team_switches_default;
float g_fCvar_z_ghost_delay_min, g_fCvar_z_ghost_delay_max;
bool sb_all_bot_game_default, allow_all_bot_survivor_team_default, sb_all_bot_team_default, director_no_specials_bool;
bool g_bConfigsExecuted;

ConVar g_hCvarAllow, g_hCvarMPGameMode, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog;
ConVar h_InfHUD, h_Announce, h_VersusCoop, h_ZSDisableGamemode, h_IncludingDead,
	g_hCvarReloadSettings;
char g_sCvarReloadSettings[64];

Handle PlayerLeftStartTimer = null; //Detect player has left safe area or not
Handle infHUDTimer 		= null;	// The main HUD refresh timer
Handle g_hCheckSpawnTimer 		= null;	// The main HUD refresh timer
Panel pInfHUD = null;
Handle FightOrDieTimer[MAXPLAYERS+1],
	RestoreColorTimer[MAXPLAYERS+1], 
	g_hPlayerSpawnTimer[MAXPLAYERS+1],
	hSpawnWitchTimer,
	DisplayTimer, InitialSpawnResetTimer;

#define L4D_MAXPLAYERS 32
Handle SpawnInfectedBotTimer[MAXPLAYERS+1] = {null};

//signature call
static Handle hFlashLightTurnOn = null;
static Handle hCreateSmoker = null;
#define NAME_CreateSmoker "NextBotCreatePlayerBot<Smoker>"
#define NAME_CreateSmoker_L4D1 "reloffs_NextBotCreatePlayerBot<Smoker>"
static Handle hCreateBoomer = null;
#define NAME_CreateBoomer "NextBotCreatePlayerBot<Boomer>"
#define NAME_CreateBoomer_L4D1 "reloffs_NextBotCreatePlayerBot<Boomer>"
static Handle hCreateHunter = null;
#define NAME_CreateHunter "NextBotCreatePlayerBot<Hunter>"
#define NAME_CreateHunter_L4D1 "reloffs_NextBotCreatePlayerBot<Hunter>"
static Handle hCreateSpitter = null;
#define NAME_CreateSpitter "NextBotCreatePlayerBot<Spitter>"
static Handle hCreateJockey = null;
#define NAME_CreateJockey "NextBotCreatePlayerBot<Jockey>"
static Handle hCreateCharger = null;
#define NAME_CreateCharger "NextBotCreatePlayerBot<Charger>"
static Handle hCreateTank = null;
#define NAME_CreateTank "NextBotCreatePlayerBot<Tank>"
#define NAME_CreateTank_L4D1 "reloffs_NextBotCreatePlayerBot<Tank>"

int respawnDelay[MAXPLAYERS+1]; 			// Used to store individual player respawn delays after death
bool hudDisabled[MAXPLAYERS+1];				// Stores the client preference for whether HUD is shown
int clientGreeted[MAXPLAYERS+1]; 			// Stores whether or not client has been shown the mod commands/announce
bool roundInProgress 		= false;		// Flag that marks whether or not a round is currently in progress
float fPlayerSpawnEngineTime[MAXPLAYERS+1] = {0.0}; //time when real infected player spawns

int g_iClientColor[MAXPLAYERS+1], g_iClientIndex[MAXPLAYERS+1], g_iLightIndex[MAXPLAYERS+1];
bool g_bCvarAllow, g_bMapStarted, g_bVersusCoop,
	g_bInfHUD, g_bAnnounce, g_bIncludingDead;
int g_iZSDisableGamemode;
int g_iPlayerSpawn, g_bSpawnWitchBride;
int g_iModelIndex[MAXPLAYERS+1];			// Player Model entity reference

bool 
	g_bAngry[MAXPLAYERS+1], //tank is angry in coop/realism
	g_bAdjustSIHealth[MAXPLAYERS+1]; //true if SI adjust health already

char 
	g_sCvarMPGameMode[32];

#define FUNCTION_PATCH "Tank::GetIntentionInterface::Intention"
#define FUNCTION_PATCH2 "Action<Tank>::FirstContainedResponder"
#define FUNCTION_PATCH3 "TankIdle::GetName"

int g_iIntentionOffset;
Handle g_hSDKFirstContainedResponder;
Handle g_hSDKGetName;
int lastHumanTankId;

enum struct EPluginData
{
	bool m_bAnnounceEnable;

	int m_iSpawnLimit[NUM_TYPES_INFECTED_MAX];
	int m_iMaxSpecials;

	float m_fSpawnTimeMax;
	float m_fSpawnTimeMin;
	float m_fSILife;
	float m_fInitialSpawnTime;

	int m_iSpawnWeight[NUM_TYPES_INFECTED_MAX];
	bool m_bScaleWeights;

	int m_iSIHealth[NUM_TYPES_INFECTED_MAX];

	int m_iTankLimit;
	int m_iTankSpawnProbability;
	int m_iTankHealth;
	bool m_bTankSpawnFinal;

	int m_iWitchMaxLimit;
	float m_fWitchSpawnTimeMax;
	float m_fWitchSpawnTimeMin;
	float m_fWitchLife;
	bool m_bWitchSpawnFinal;

	bool m_bSpawnSameFrame;
	float m_fSpawnTimeIncreased_OnHumanInfected;
	bool m_bSpawnSafeZone;
	int m_iSpawnWhereMethod;
	float m_fSpawnRangeMin;
	bool m_bSpawnDisableBots;
	bool m_bTankDisableSpawn;
	bool m_bCoordination;

	bool m_bCoopVersusEnable;
	float m_fCoopVersSpawnTimeMax;
	float m_fCoopVersSpawnTimeMin;
	bool m_bCoopTankPlayable;
	bool m_bCoopVersusAnnounce;
	int m_iCoopVersusHumanLimit;
	char m_sCoopVersusJoinAccess[AdminFlags_TOTAL];
	bool m_bCoopVersusHumanLight;
	bool m_bCoopVersusHumanGhost;
	float m_fCoopVersusHumanCoolDown;
}

EPluginData 
	ePluginData[L4D_MAXPLAYERS+1], 
	g_ePluginSettings;

StringMap 
	g_smPlayedInfected;

ArrayList
	g_aPlayedInfected;

public Plugin myinfo =
{
	name = "[L4D/L4D2] Infected Bots (Coop/Versus/Realism/Scavenge/Survival/Mutation)",
	author = "djromero (SkyDavid), MI 5, Harry Potter",
	description = "Spawns multi infected bots in versus + allows playable special infected in coop/survival + unlock infected limit",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showpost.php?p=2699220&postcount=1371"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead )
	{
		ZOMBIECLASS_TANK = 5;
		g_bL4D2Version = false;
		NUM_INFECTED = 3;
	}
	else if( test == Engine_Left4Dead2 )
	{
		ZOMBIECLASS_TANK = 8;
		g_bL4D2Version = true;
		NUM_INFECTED = 6;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	RegPluginLibrary("l4dinfectedbots");

	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("l4dinfectedbots.phrases");

	GetGameData();

	// Add a sourcemod command so players can easily join infected in coop/realism/survival
	RegConsoleCmd("sm_ji", JoinInfectedInCoop, "(Coop/Realism/Survival only) Join Infected");
	RegConsoleCmd("sm_js", JoinSurvivorsInCoop, "(Coop/Realism/Survival only) Join Survivors");
	RegConsoleCmd("sm_zss", ForceInfectedSuicide,"Infected Suicide myself (if get stuck or out of map)");
	RegAdminCmd("sm_zlimit", Console_ZLimit, ADMFLAG_ROOT,"Control max special zombies limit until next map or data is reloaded");
	RegAdminCmd("sm_timer", Console_Timer, ADMFLAG_ROOT,"Control special zombies spawn timer until next map or data is reloaded");

	RegConsoleCmd("sm_checkqueue", CheckQueue);

	// Hook "say" so clients can toggle HUD on/off for themselves
	RegConsoleCmd("sm_infhud", Command_infhud, "(Infected only) Toggle HUD on/off for themselves");

	// We register the version cvar
	CreateConVar("l4d_infectedbots_version", PLUGIN_VERSION, "Version of L4D Infected Bots", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	// console variables
	g_hCvarAllow =						CreateConVar("l4d_infectedbots_allow",									"1",		"0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY );
	g_hCvarModes =						CreateConVar("l4d_infectedbots_modes",									"",			"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", FCVAR_NOTIFY );
	g_hCvarModesOff =					CreateConVar("l4d_infectedbots_modes_off",								"",			"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", FCVAR_NOTIFY );
	g_hCvarModesTog =					CreateConVar("l4d_infectedbots_modes_tog",								"0",		"Turn on the plugin in these game modes. 0=All, 1=Coop/Realism, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", FCVAR_NOTIFY );
	
	h_InfHUD = 							CreateConVar("l4d_infectedbots_infhud_enable", 							"1", 		"Toggle whether Infected HUD is active or not.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_Announce = 						CreateConVar("l4d_infectedbots_infhud_announce", 						"1", 		"Toggle whether Infected HUD announces itself to clients.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_VersusCoop = 						CreateConVar("l4d_infectedbots_versus_coop", 							"0", 		"If 1, The plugin will force all players to the infected side against the survivor AI for every round and map in versus/scavenge.\nEnable this also allow game to continue with survivor bots", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_ZSDisableGamemode = 				CreateConVar("l4d_infectedbots_sm_zss_disable_gamemode", 				"6", 		"Disable sm_zss command in these gamemode (0: None, 1: coop/realism, 2: versus/scavenge, 4: survival, add numbers together)", FCVAR_NOTIFY, true, 0.0, true, 7.0);
	h_IncludingDead = 					CreateConVar("l4d_infectedbots_calculate_including_dead", 				"0", 		"If 1, including dead players when count the number of survivors.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarReloadSettings = 			CreateConVar("l4d_infectedbots_read_data", 								"", 		"Which xxxx.cfg file should this plugin read for settings in data/l4dinfectedbots folder (Ex: \"custom_tanks\" = reads 'custom_tanks.cfg')\nEmpty=By default, reads xxxx.cfg (xxxx = gamemode or mutation name).", FCVAR_NOTIFY);

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.GetString(g_sCvarMPGameMode, sizeof(g_sCvarMPGameMode));
	g_hCvarMPGameMode.AddChangeHook(ConVarGameMode);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);

	director_no_specials = FindConVar("director_no_specials");
	z_ghost_delay_min = FindConVar("z_ghost_delay_min");
	z_ghost_delay_max = FindConVar("z_ghost_delay_max");

	GetOfficalCvars();
	director_no_specials.AddChangeHook(ConVarChanged_OfficialCvars);
	z_ghost_delay_min.AddChangeHook(ConVarChanged_OfficialCvars);
	z_ghost_delay_max.AddChangeHook(ConVarChanged_OfficialCvars);

	GetCvars();
	h_InfHUD.AddChangeHook(ConVarChanged_Cvars);
	h_Announce.AddChangeHook(ConVarChanged_Cvars);
	h_ZSDisableGamemode.AddChangeHook(ConVarChanged_Cvars);
	h_IncludingDead.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarReloadSettings.AddChangeHook(ConVarChanged_ReloadSettings);

	g_bVersusCoop = h_VersusCoop.BoolValue;
	h_VersusCoop.AddChangeHook(ConVarVersusCoop);

	g_iPlayersInSurvivorTeam = -1;

	// Removes the boundaries for z_max_player_zombies and notify flag
	z_max_player_zombies = FindConVar("z_max_player_zombies");
	int flags = z_max_player_zombies.Flags;
	SetConVarBounds(z_max_player_zombies, ConVarBound_Upper, false);
	SetConVarFlags(z_max_player_zombies, flags & ~FCVAR_NOTIFY);

	if(g_bL4D2Version)
	{
		sb_all_bot_game = FindConVar("sb_all_bot_game");
		sb_all_bot_game_default = sb_all_bot_game.BoolValue;
		sb_all_bot_game.AddChangeHook(ConVarChanged_DefaultCvars);

		allow_all_bot_survivor_team = FindConVar("allow_all_bot_survivor_team");
		allow_all_bot_survivor_team_default = allow_all_bot_survivor_team.BoolValue;
		allow_all_bot_survivor_team.AddChangeHook(ConVarChanged_DefaultCvars);

		director_allow_infected_bots = FindConVar("director_allow_infected_bots");
	}
	else
	{
		sb_all_bot_team = FindConVar("sb_all_bot_team");
		sb_all_bot_team_default = sb_all_bot_team.BoolValue;
		sb_all_bot_team.AddChangeHook(ConVarChanged_DefaultCvars);
	}
	vs_max_team_switches = FindConVar("vs_max_team_switches");
	vs_max_team_switches_default = vs_max_team_switches.BoolValue;
	vs_max_team_switches.AddChangeHook(ConVarChanged_DefaultCvars);

	g_smPlayedInfected = new StringMap();
	g_aPlayedInfected = new ArrayList();

	//Autoconfig for plugin
	AutoExecConfig(true, PLUGIN_NAME);
}

public void OnPluginEnd()
{
	for( int i = 1; i <= MaxClients; i++ )
	{
		RemoveSurvivorModelGlow(i);
		DeleteLight(i);
	}

	if (g_bL4D2Version)
	{
		ResetConVar(FindConVar("survival_max_smokers"), true, true);
		ResetConVar(FindConVar("survival_max_boomers"), true, true);
		ResetConVar(FindConVar("survival_max_hunters"), true, true);
		ResetConVar(FindConVar("survival_max_spitters"), true, true);
		ResetConVar(FindConVar("survival_max_jockeys"), true, true);
		ResetConVar(FindConVar("survival_max_chargers"), true, true);
		ResetConVar(FindConVar("survival_max_specials"), true, true);
		ResetConVar(FindConVar("survival_special_limit_increase"), true, true);
		ResetConVar(FindConVar("survival_special_spawn_interval"), true, true);
		ResetConVar(FindConVar("survival_special_stage_interval"), true, true);

		ResetConVar(FindConVar("z_smoker_limit"), true, true);
		ResetConVar(FindConVar("z_boomer_limit"), true, true);
		ResetConVar(FindConVar("z_hunter_limit"), true, true);
		ResetConVar(FindConVar("z_spitter_limit"), true, true);
		ResetConVar(FindConVar("z_jockey_limit"), true, true);
		ResetConVar(FindConVar("z_charger_limit"), true, true);
	}
	else
	{
		ResetConVar(FindConVar("holdout_max_smokers"), true, true);
		ResetConVar(FindConVar("holdout_max_boomers"), true, true);
		ResetConVar(FindConVar("holdout_max_hunters"), true, true);
		ResetConVar(FindConVar("holdout_max_specials"), true, true);
		ResetConVar(FindConVar("holdout_special_spawn_interval"), true, true);
		ResetConVar(FindConVar("holdout_special_stage_interval"), true, true);

		ResetConVar(FindConVar("z_gas_limit"), true, true);
		ResetConVar(FindConVar("z_exploding_limit"), true, true);
		ResetConVar(FindConVar("z_hunter_limit"), true, true);
	}
	ResetConVar(FindConVar("z_spawn_safety_range"), true, true);
	if(g_bL4D2Version)
	{
		ResetConVar(director_allow_infected_bots, true, true);
	}

	g_bSomeCvarChanged = true;
	vs_max_team_switches.SetInt(vs_max_team_switches_default);
	if (!g_bL4D2Version)
	{
		sb_all_bot_team.SetBool(sb_all_bot_team_default);
	}
	else
	{
		sb_all_bot_game.SetBool(sb_all_bot_game_default);
		allow_all_bot_survivor_team.SetBool(allow_all_bot_survivor_team_default);
	}
	g_bSomeCvarChanged = false;

	if(g_bL4D2Version)
	{
		for( int i = 1; i <= MaxClients; i++ )
			if(IsClientInGame(i) && !IsFakeClient(i)) g_hCvarMPGameMode.ReplicateToClient(i, g_sCvarMPGameMode);
	}
}

bool g_bSIPoolAvailable;
public void OnAllPluginsLoaded()
{
	g_bSIPoolAvailable = LibraryExists("si_pool_plus");
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "si_pool_plus") == 0) g_bSIPoolAvailable = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "si_pool_plus")) g_bSIPoolAvailable = true;
}

void ConVarChanged_OfficialCvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetOfficalCvars();
}

void GetOfficalCvars()
{
	director_no_specials_bool 		= director_no_specials.BoolValue;
	g_fCvar_z_ghost_delay_min 		= z_ghost_delay_min.FloatValue;
	g_fCvar_z_ghost_delay_max 		= z_ghost_delay_max.FloatValue;
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void ConVarChanged_ReloadSettings(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();

	if(g_bConfigsExecuted)
	{
		LoadData();

		g_iPlayersInSurvivorTeam = -1;
		delete DisplayTimer;
		DisplayTimer = CreateTimer(1.0, Timer_CountSurvivor);
	}
}

void GetCvars()
{
	g_bInfHUD = h_InfHUD.BoolValue;
	g_bAnnounce = h_Announce.BoolValue;
	g_iZSDisableGamemode = h_ZSDisableGamemode.IntValue;
	g_bIncludingDead = h_IncludingDead.BoolValue;
	g_hCvarReloadSettings.GetString(g_sCvarReloadSettings, sizeof(g_sCvarReloadSettings));
}

void ConVarGameMode(ConVar convar, const char[] oldValue, const char[] newValue)
{
	char sGameMode[32];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	if(strcmp(g_sCvarMPGameMode, sGameMode, false) == 0) return;
	g_sCvarMPGameMode = sGameMode;

	IsAllowed();

	bDisableSurvivorModelGlow = true;
	if(g_bL4D2Version)
	{
		for( int i = 1; i <= MaxClients; i++ )
		{
			RemoveSurvivorModelGlow(i);
			if(IsClientInGame(i) && !IsFakeClient(i)) g_hCvarMPGameMode.ReplicateToClient(i, g_sCvarMPGameMode);
		}
	}

	if(g_bConfigsExecuted)
	{
		LoadData();
	}

	g_iPlayersInSurvivorTeam = -1;
	delete DisplayTimer;
	DisplayTimer = CreateTimer(1.0, Timer_CountSurvivor);

	if(g_bCvarAllow == false) return;

	if(g_bL4D2Version)
	{
		if(g_ePluginSettings.m_bCoopVersusEnable && L4D_HasPlayerControlledZombies() == false)
		{
			bDisableSurvivorModelGlow = false;
			for( int i = 1; i <= MaxClients; i++ )
			{
				CreateSurvivorModelGlow(i);
				if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED) g_hCvarMPGameMode.ReplicateToClient(i, "versus");
			}
		}
	}
}

void ConVarVersusCoop(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_bVersusCoop = h_VersusCoop.BoolValue;
	if(L4D_HasPlayerControlledZombies() == true)
	{
		g_bSomeCvarChanged = true;
		if (g_bVersusCoop)
		{
			vs_max_team_switches.SetInt(0);
			if (g_bL4D2Version)
			{
				sb_all_bot_game.SetInt(1);
				allow_all_bot_survivor_team.SetInt(1);
			}
			else
			{
				sb_all_bot_team.SetInt(1);
			}
		}
		else
		{
			vs_max_team_switches.SetInt(vs_max_team_switches_default);
			if (g_bL4D2Version)
			{
				sb_all_bot_game.SetBool(sb_all_bot_game_default);
				allow_all_bot_survivor_team.SetBool(allow_all_bot_survivor_team_default);
			}
			else
			{
				sb_all_bot_team.SetBool(sb_all_bot_team_default);
			}
		}
		g_bSomeCvarChanged = false;
	}
}

void CoopVersus_SettingsChanged()
{
	if(L4D_HasPlayerControlledZombies() == false)
	{
		g_bSomeCvarChanged = true;
		if (g_ePluginSettings.m_bCoopVersusEnable)
		{
			if (g_bL4D2Version)
			{
				sb_all_bot_game.SetInt(1);
				allow_all_bot_survivor_team.SetInt(1);
			}
			else
			{
				sb_all_bot_team.SetInt(1);
			}

			bDisableSurvivorModelGlow = false;
			for( int i = 1; i <= MaxClients; i++ ) CreateSurvivorModelGlow(i);
		}
		else
		{
			if (g_bL4D2Version)
			{
				sb_all_bot_game.SetBool(sb_all_bot_game_default);
				allow_all_bot_survivor_team.SetBool(allow_all_bot_survivor_team_default);
			}
			else
			{
				sb_all_bot_team.SetBool(sb_all_bot_team_default);
			}
			if(g_bL4D2Version)
			{
				bDisableSurvivorModelGlow = true;
				for( int i = 1; i <= MaxClients; i++ )
				{
					if(IsClientInGame(i) && !IsFakeClient(i)) g_hCvarMPGameMode.ReplicateToClient(i, g_sCvarMPGameMode);
					RemoveSurvivorModelGlow(i);
				}
			}
		}
		g_bSomeCvarChanged = false;
	}
}

void ConVarChanged_DefaultCvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(g_bSomeCvarChanged) return;

	if(g_bL4D2Version)
	{
		sb_all_bot_game_default = sb_all_bot_game.BoolValue;
		allow_all_bot_survivor_team_default = allow_all_bot_survivor_team.BoolValue;
	}
	else
	{
		sb_all_bot_team_default = sb_all_bot_team.BoolValue;
	}
	vs_max_team_switches_default = vs_max_team_switches.IntValue;
}

void TweakSettings()
{
	// Reset the cvars
	ResetCvars();

	switch (g_iCurrentMode)
	{
		case 1: // Coop, We turn off the ability for the director to spawn the bots, and have the plugin do it while allowing the director to spawn tanks and witches,
		// MI 5
		{
			// If the game is L4D 2...
			if (g_bL4D2Version)
			{
				SetConVarInt(FindConVar("z_smoker_limit"), g_ePluginSettings.m_iSpawnLimit[SI_SMOKER]);
				SetConVarInt(FindConVar("z_boomer_limit"), g_ePluginSettings.m_iSpawnLimit[SI_BOOMER]);
				SetConVarInt(FindConVar("z_hunter_limit"), g_ePluginSettings.m_iSpawnLimit[SI_HUNTER]);
				SetConVarInt(FindConVar("z_spitter_limit"), g_ePluginSettings.m_iSpawnLimit[SI_SPITTER]);
				SetConVarInt(FindConVar("z_jockey_limit"), g_ePluginSettings.m_iSpawnLimit[SI_JOCKEY]);
				SetConVarInt(FindConVar("z_charger_limit"), g_ePluginSettings.m_iSpawnLimit[SI_CHARGER]);
			}
			else
			{
				SetConVarInt(FindConVar("z_gas_limit"), g_ePluginSettings.m_iSpawnLimit[SI_SMOKER]);
				SetConVarInt(FindConVar("z_exploding_limit"), g_ePluginSettings.m_iSpawnLimit[SI_BOOMER]);
				SetConVarInt(FindConVar("z_hunter_limit"), g_ePluginSettings.m_iSpawnLimit[SI_HUNTER]);
				SetConVarInt(FindConVar("director_special_battlefield_respawn_interval"), 9999999);
				SetConVarInt(FindConVar("director_special_respawn_interval"), 9999999);
			}
		}
		case 2: // Versus, Better Versus Infected AI
		{
			// If the game is L4D 2...
			if (g_bL4D2Version)
			{
				SetConVarInt(FindConVar("z_smoker_limit"), g_ePluginSettings.m_iSpawnLimit[SI_SMOKER]);
				SetConVarInt(FindConVar("z_boomer_limit"), g_ePluginSettings.m_iSpawnLimit[SI_BOOMER]);
				SetConVarInt(FindConVar("z_hunter_limit"), g_ePluginSettings.m_iSpawnLimit[SI_HUNTER]);
				SetConVarInt(FindConVar("z_spitter_limit"), g_ePluginSettings.m_iSpawnLimit[SI_SPITTER]);
				SetConVarInt(FindConVar("z_jockey_limit"), g_ePluginSettings.m_iSpawnLimit[SI_JOCKEY]);
				SetConVarInt(FindConVar("z_charger_limit"), g_ePluginSettings.m_iSpawnLimit[SI_CHARGER]);
			}
			else
			{
				SetConVarInt(FindConVar("z_gas_limit"), g_ePluginSettings.m_iSpawnLimit[SI_SMOKER]);
				SetConVarInt(FindConVar("z_exploding_limit"), g_ePluginSettings.m_iSpawnLimit[SI_BOOMER]);
				SetConVarInt(FindConVar("z_hunter_limit"), g_ePluginSettings.m_iSpawnLimit[SI_HUNTER]);
			}

			if (g_bVersusCoop)
			{
				g_bSomeCvarChanged = true;
				vs_max_team_switches.SetInt(0);
				g_bSomeCvarChanged = false;
			}
		}
		case 3: // Survival, Turns off the ability for the director to spawn infected bots in survival, MI 5
		{
			if (g_bL4D2Version)
			{
				SetConVarInt(FindConVar("survival_max_smokers"), g_ePluginSettings.m_iSpawnLimit[SI_SMOKER]);
				SetConVarInt(FindConVar("survival_max_boomers"), g_ePluginSettings.m_iSpawnLimit[SI_BOOMER]);
				SetConVarInt(FindConVar("survival_max_hunters"), g_ePluginSettings.m_iSpawnLimit[SI_HUNTER]);
				SetConVarInt(FindConVar("survival_max_spitters"), g_ePluginSettings.m_iSpawnLimit[SI_SPITTER]);
				SetConVarInt(FindConVar("survival_max_jockeys"), g_ePluginSettings.m_iSpawnLimit[SI_JOCKEY]);
				SetConVarInt(FindConVar("survival_max_chargers"), g_ePluginSettings.m_iSpawnLimit[SI_CHARGER]);
				SetConVarInt(FindConVar("survival_max_specials"), g_ePluginSettings.m_iMaxSpecials);
				SetConVarInt(FindConVar("survival_special_limit_increase"), 0);
				SetConVarInt(FindConVar("survival_special_spawn_interval"), 9999999);
				SetConVarInt(FindConVar("survival_special_stage_interval"), 9999999);

				SetConVarInt(FindConVar("z_smoker_limit"), g_ePluginSettings.m_iSpawnLimit[SI_SMOKER]);
				SetConVarInt(FindConVar("z_boomer_limit"), g_ePluginSettings.m_iSpawnLimit[SI_BOOMER]);
				SetConVarInt(FindConVar("z_hunter_limit"), g_ePluginSettings.m_iSpawnLimit[SI_HUNTER]);
				SetConVarInt(FindConVar("z_spitter_limit"), g_ePluginSettings.m_iSpawnLimit[SI_SPITTER]);
				SetConVarInt(FindConVar("z_jockey_limit"), g_ePluginSettings.m_iSpawnLimit[SI_JOCKEY]);
				SetConVarInt(FindConVar("z_charger_limit"), g_ePluginSettings.m_iSpawnLimit[SI_CHARGER]);
			}
			else
			{
				SetConVarInt(FindConVar("holdout_max_smokers"), g_ePluginSettings.m_iSpawnLimit[SI_SMOKER]);
				SetConVarInt(FindConVar("holdout_max_boomers"), g_ePluginSettings.m_iSpawnLimit[SI_BOOMER]);
				SetConVarInt(FindConVar("holdout_max_hunters"), g_ePluginSettings.m_iSpawnLimit[SI_HUNTER]);
				SetConVarInt(FindConVar("holdout_max_specials"), g_ePluginSettings.m_iMaxSpecials);
				SetConVarInt(FindConVar("holdout_special_spawn_interval"), 9999999);
				SetConVarInt(FindConVar("holdout_special_stage_interval"), 9999999);

				SetConVarInt(FindConVar("z_gas_limit"), g_ePluginSettings.m_iSpawnLimit[SI_SMOKER]);
				SetConVarInt(FindConVar("z_exploding_limit"), g_ePluginSettings.m_iSpawnLimit[SI_BOOMER]);
				SetConVarInt(FindConVar("z_hunter_limit"), g_ePluginSettings.m_iSpawnLimit[SI_HUNTER]);
			}
		}
	}

	if (g_bL4D2Version)
	{
		SetConVarInt(director_allow_infected_bots, 0);
	}

	//LogMessage("Tweaking Settings");
}

void ResetCvars()
{
	#if DEBUG
	LogMessage("Plugin Cvars Reset");
	#endif

	if (g_iCurrentMode == 1)
	{
		if (g_bL4D2Version)
		{
			ResetConVar(FindConVar("survival_max_smokers"), true, true);
			ResetConVar(FindConVar("survival_max_boomers"), true, true);
			ResetConVar(FindConVar("survival_max_hunters"), true, true);
			ResetConVar(FindConVar("survival_max_spitters"), true, true);
			ResetConVar(FindConVar("survival_max_jockeys"), true, true);
			ResetConVar(FindConVar("survival_max_chargers"), true, true);
			ResetConVar(FindConVar("survival_max_specials"), true, true);
			ResetConVar(FindConVar("survival_special_limit_increase"), true, true);
			ResetConVar(FindConVar("survival_special_spawn_interval"), true, true);
			ResetConVar(FindConVar("survival_special_stage_interval"), true, true);
		}
		else
		{
			ResetConVar(FindConVar("holdout_max_smokers"), true, true);
			ResetConVar(FindConVar("holdout_max_boomers"), true, true);
			ResetConVar(FindConVar("holdout_max_hunters"), true, true);
			ResetConVar(FindConVar("holdout_max_specials"), true, true);
			ResetConVar(FindConVar("holdout_special_spawn_interval"), true, true);
			ResetConVar(FindConVar("holdout_special_stage_interval"), true, true);
		}
	}
	else if (g_iCurrentMode == 2)
	{
		if (g_bL4D2Version)
		{
			ResetConVar(FindConVar("survival_max_smokers"), true, true);
			ResetConVar(FindConVar("survival_max_boomers"), true, true);
			ResetConVar(FindConVar("survival_max_hunters"), true, true);
			ResetConVar(FindConVar("survival_max_spitters"), true, true);
			ResetConVar(FindConVar("survival_max_jockeys"), true, true);
			ResetConVar(FindConVar("survival_max_chargers"), true, true);
			ResetConVar(FindConVar("survival_max_specials"), true, true);
			ResetConVar(FindConVar("survival_special_limit_increase"), true, true);
			ResetConVar(FindConVar("survival_special_spawn_interval"), true, true);
			ResetConVar(FindConVar("survival_special_stage_interval"), true, true);
		}
		else
		{
			ResetConVar(FindConVar("holdout_max_smokers"), true, true);
			ResetConVar(FindConVar("holdout_max_boomers"), true, true);
			ResetConVar(FindConVar("holdout_max_hunters"), true, true);
			ResetConVar(FindConVar("holdout_max_specials"), true, true);
			ResetConVar(FindConVar("holdout_special_spawn_interval"), true, true);
			ResetConVar(FindConVar("holdout_special_stage_interval"), true, true);
		}
	}
	else if (g_iCurrentMode == 3)
	{
		if (g_bL4D2Version)
		{
			ResetConVar(FindConVar("z_smoker_limit"), true, true);
			ResetConVar(FindConVar("z_boomer_limit"), true, true);
			ResetConVar(FindConVar("z_hunter_limit"), true, true);
			ResetConVar(FindConVar("z_spitter_limit"), true, true);
			ResetConVar(FindConVar("z_jockey_limit"), true, true);
			ResetConVar(FindConVar("z_charger_limit"), true, true);
		}
		else
		{
			ResetConVar(FindConVar("z_gas_limit"), true, true);
			ResetConVar(FindConVar("z_exploding_limit"), true, true);
			ResetConVar(FindConVar("z_hunter_limit"), true, true);
		}
	}
}

void evtRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bLeftSaveRoom = false;
	g_bSurvivalStart = false;

	delete g_smPlayedInfected;
	g_smPlayedInfected = new StringMap();

	if(!b_HasRoundStarted && g_iPlayerSpawn == 1)
	{
		CreateTimer(0.1, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
	}

	b_HasRoundStarted = true;

	for (int i = 1; i <= MaxClients; i++)
	{
		g_bAdjustSIHealth[i] = false;
	}
}

void Event_SurvivalRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(g_iCurrentMode == 3 && g_bSurvivalStart == false)
	{
		g_bLeftSaveRoom = true;
		GameStart();
		g_bSurvivalStart = true;
	}
}

Action Timer_PluginStart(Handle timer)
{
	if (g_bCvarAllow == false)
		return Plugin_Continue;

	for (int i = 1; i <= MaxClients; i++)
	{
		respawnDelay[i] = 0;
		PlayerLifeState[i] = false;
	}

	float now = GetEngineTime();
	if(g_ePluginSettings.m_bCoopVersusEnable && g_ePluginSettings.m_fCoopVersusHumanCoolDown > 0.0 && L4D_HasPlayerControlledZombies() == false)
	{
		static char sSteamId[64];
		int length = g_aPlayedInfected.Length;
		for(int i = 0; i < length; i++)
		{
			g_aPlayedInfected.GetString(i, sSteamId, sizeof(sSteamId));
			g_smPlayedInfected.SetValue(sSteamId, now + g_ePluginSettings.m_fCoopVersusHumanCoolDown, true);
		}
		
		for(int i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i)) continue;
			if(IsFakeClient(i)) continue;
			if(GetClientTeam(i) != 3) continue;

			CPrintToChat(i, "%T", "You were playing infected last round (C)", i, RoundFloat(g_ePluginSettings.m_fCoopVersusHumanCoolDown));
			PrintHintText(i, "%T", "You were playing infected last round", i, RoundFloat(g_ePluginSettings.m_fCoopVersusHumanCoolDown));
			ChangeClientTeam(i, TEAM_SPECTATOR);
		}
	}

	delete g_aPlayedInfected;
	g_aPlayedInfected = new ArrayList(ByteCountToCells(64));

	//reset some variables
	InfectedBotQueue = 0;
	g_bIsCoordination = false;
	g_bFinaleStarted = false;
	g_bInitialSpawn = true;
	g_bLeftSaveRoom = false;
	g_bHasRoundEnded = false;

	// This little part is needed because some events just can't execute when another round starts.
	if (L4D_HasPlayerControlledZombies() && g_bVersusCoop)
	{
		for (int i=1; i<=MaxClients; i++)
		{
			// We check if player is in game
			if (!IsClientInGame(i)) continue;
			// Check if client is survivor ...
			if (GetClientTeam(i)==TEAM_SURVIVOR)
			{
				// If player is a real player ...
				if (!IsFakeClient(i))
				{
					ChangeClientTeam(i, TEAM_INFECTED);
				}
			}
		}

	}
	// Kill the player if they are infected and its not versus (prevents survival finale bug and player ghosts when there shouldn't be)
	if (L4D_HasPlayerControlledZombies() == false)
	{
		for (int i=1; i<=MaxClients; i++)
		{
			// We check if player is in game
			if (!IsClientInGame(i)) continue;
			// Check if client is infected ...
			if (GetClientTeam(i)==TEAM_INFECTED)
			{
				// If player is a real player ...
				if (!IsFakeClient(i))
				{
					if (IsPlayerGhost(i))
					{
						L4D_State_Transition(i, STATE_DEATH_WAIT_FOR_KEY);
					}
				}
			}
		}
	}

	g_ePluginSettings = ePluginData[CheckAliveSurvivorPlayers_InSV()];
	TweakSettings();

	g_iPlayersInSurvivorTeam = -1;
	delete DisplayTimer;
	DisplayTimer = CreateTimer(1.0, Timer_CountSurvivor);

	roundInProgress = true;
	delete infHUDTimer;
	infHUDTimer = CreateTimer(1.0, showInfHUD, _, TIMER_REPEAT);

	delete g_hCheckSpawnTimer;
	g_hCheckSpawnTimer = CreateTimer(2.0, Timer_CheckSpawn, _, TIMER_REPEAT);

	delete PlayerLeftStartTimer;
	PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);

	if (g_ePluginSettings.m_bCoopVersusEnable && L4D_HasPlayerControlledZombies() == false || g_bVersusCoop && L4D_HasPlayerControlledZombies())
	{
		g_bSomeCvarChanged = true;
		if (g_bL4D2Version)
		{
			sb_all_bot_game.SetInt(1);
			allow_all_bot_survivor_team.SetInt(1);
		}
		else
		{
			sb_all_bot_team.SetInt(1);
		}
		g_bSomeCvarChanged = false;
	}

	return Plugin_Continue;
}

void evtPlayerFirstSpawned(Event event, const char[] name, bool dontBroadcast)
{
	// This event's purpose is to execute when a player first enters the server. This eliminates a lot of problems when changing variables setting timers on clients, among fixing many sb_all_bot_team
	// issues.
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);

	if (!client || IsFakeClient(client) || PlayerHasEnteredStart[client])
		return;

	#if DEBUG
		PrintToChatAll("[TS] Player has spawned for the first time");
	#endif

	// Versus Coop code, puts all players on infected at start, delay is added to prevent a weird glitch

	if (L4D_HasPlayerControlledZombies() && g_bVersusCoop)
		CreateTimer(0.1, Timer_VersusCoopTeamChanger, userid, TIMER_FLAG_NO_MAPCHANGE);

	// Kill the player if they are infected and its not versus (prevents survival finale bug and player ghosts when there shouldn't be)
	if (L4D_HasPlayerControlledZombies() == false)
	{
		if (GetClientTeam(client)==TEAM_INFECTED)
		{
			if (IsPlayerGhost(client))
			{
				CreateTimer(0.2, Timer_InfectedKillSelf, userid, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}

	PlayerHasEnteredStart[client] = true;
}

Action Timer_VersusCoopTeamChanger(Handle Timer, int client)
{
	client = GetClientOfUserId(client);
	if(client && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) != TEAM_INFECTED)
	{
		CleanUpStateAndMusic(client);
		ChangeClientTeam(client, TEAM_INFECTED);
	}
	
	return Plugin_Continue;
}

Action Timer_InfectedKillSelf(Handle Timer, int client)
{
	if(g_ePluginSettings.m_bCoopVersusHumanGhost == true) return Plugin_Continue;

	client = GetClientOfUserId(client);
	if( client && IsClientInGame(client) && !IsFakeClient(client) && L4D_IsPlayerGhost(client) )
	{
		PrintHintText(client,"[TS] %T","Not allowed to respawn",client);
		ForcePlayerSuicide(client);
	}

	return Plugin_Continue;
}

Action MaxSpecialsSet(Handle Timer)
{
	z_max_player_zombies.SetInt(g_ePluginSettings.m_iMaxSpecials);
	
	#if DEBUG
	LogMessage("Max Player Zombies Set");
	#endif
	return Plugin_Continue;
}

void evtRoundEnd (Event event, const char[] name, bool dontBroadcast)
{
	for( int i = 1; i <= MaxClients; i++ )
		DeleteLight(i);

	g_bHasRoundEnded = true;
	b_HasRoundStarted = false;
	g_bLeftSaveRoom = false;
	roundInProgress = false;
	g_iPlayerSpawn = 0;

	ResetTimer();
}

public void OnMapStart()
{
	g_bMapStarted = true;
	
	CheckandPrecacheModel(MODEL_SMOKER);
	CheckandPrecacheModel(MODEL_BOOMER);
	CheckandPrecacheModel(MODEL_HUNTER);
	CheckandPrecacheModel(MODEL_SPITTER);
	CheckandPrecacheModel(MODEL_JOCKEY);
	CheckandPrecacheModel(MODEL_CHARGER);
	CheckandPrecacheModel(MODEL_TANK);

	g_bSpawnWitchBride = false;
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	if(StrEqual("c6m1_riverbank", sMap, false))
		g_bSpawnWitchBride = true;

	lastHumanTankId = 0;
}

public void OnMapEnd()
{
	g_bConfigsExecuted = false;
	b_HasRoundStarted = false;
	g_bHasRoundEnded = true;
	g_bLeftSaveRoom = false;
	g_iPlayerSpawn = 0;
	roundInProgress = false;
	g_bMapStarted = false;
	g_iPlayersInSurvivorTeam = -1;
	
	ResetTimer();
}


public void OnConfigsExecuted()
{
	g_hCvarMPGameMode.GetString(g_sCvarMPGameMode, sizeof(g_sCvarMPGameMode));
	LoadData();

	IsAllowed();

	g_bConfigsExecuted = true;
}

void ConVarChanged_Allow(ConVar convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		CreateTimer(0.5, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
		g_bCvarAllow = true;

		SetSpawnDis();

		HookEvent("round_start", evtRoundStart,		EventHookMode_PostNoCopy);
		if(g_bL4D2Version) HookEvent("survival_round_start", Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //生存模式之下計時開始之時 (一代沒有此事件)
		else HookEvent("create_panic_event" , Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //一代生存模式之下計時開始觸發屍潮
		HookEvent("round_end",				evtRoundEnd,		EventHookMode_PostNoCopy); //trigger twice in versus mode, one when all survivors wipe out or make it to saferom, one when first round ends (second round_start begins).
		HookEvent("map_transition", 		evtRoundEnd,		EventHookMode_PostNoCopy); //all survivors make it to saferoom, and server is about to change next level in coop mode (does not trigger round_end) 
		HookEvent("mission_lost", 			evtRoundEnd,		EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
		HookEvent("finale_vehicle_leaving", evtRoundEnd,		EventHookMode_PostNoCopy); //final map final rescue vehicle leaving  (does not trigger round_end)
	
		HookEvent("player_death", evtPlayerDeath, EventHookMode_Pre);
		HookEvent("player_team", evtPlayerTeam);
		HookEvent("player_spawn", evtPlayerSpawn);
		HookEvent("finale_start", 			evtFinaleStart, EventHookMode_PostNoCopy); //final starts, some of final maps won't trigger
		HookEvent("finale_radio_start", 	evtFinaleStart, EventHookMode_PostNoCopy); //final starts, all final maps trigger
		if(g_bL4D2Version) HookEvent("gauntlet_finale_start", 	evtFinaleStart, EventHookMode_PostNoCopy); //final starts, only rushing maps trigger (C5M5, C13M4)
		HookEvent("player_death", evtInfectedDeath);
		HookEvent("player_spawn", evtInfectedSpawn);
		HookEvent("player_hurt", evtInfectedHurt);
		HookEvent("player_team", evtTeamSwitch);
		HookEvent("ghost_spawn_time", Event_GhostSpawnTime);
		HookEvent("player_first_spawn", evtPlayerFirstSpawned);
		HookEvent("player_entered_start_area", evtPlayerFirstSpawned);
		HookEvent("player_entered_checkpoint", evtPlayerFirstSpawned);
		HookEvent("player_transitioned", evtPlayerFirstSpawned);
		HookEvent("player_left_start_area", evtPlayerFirstSpawned);
		HookEvent("player_left_checkpoint", evtPlayerFirstSpawned);
		HookEvent("player_incapacitated", Event_Incap);
		HookEvent("player_ledge_grab", Event_Incap);
		HookEvent("player_now_it", Event_GotVomit);
		HookEvent("revive_success", Event_revive_success);//救起倒地的or 懸掛的
		HookEvent("player_ledge_release", Event_ledge_release);//懸掛的玩家放開了
		HookEvent("player_bot_replace", Event_BotReplacePlayer);
		HookEvent("bot_player_replace", Event_PlayerReplaceBot);
		HookEvent("tank_frustrated", OnTankFrustrated, EventHookMode_Post);
		HookEvent("player_disconnect", Event_PlayerDisconnect); //換圖不會觸發該事件

		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
				OnClientPostAdminCheck(i);
			}
		}
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		OnPluginEnd();
		g_bCvarAllow = false;
		UnhookEvent("round_start", evtRoundStart,		EventHookMode_PostNoCopy);
		if(g_bL4D2Version) UnhookEvent("survival_round_start", Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //生存模式之下計時開始之時 (一代沒有此事件)
		else UnhookEvent("create_panic_event" , Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //一代生存模式之下計時開始觸發屍潮
		UnhookEvent("round_end",				evtRoundEnd,		EventHookMode_PostNoCopy); //trigger twice in versus mode, one when all survivors wipe out or make it to saferom, one when first round ends (second round_start begins).
		UnhookEvent("map_transition", 			evtRoundEnd,		EventHookMode_PostNoCopy); //all survivors make it to saferoom, and server is about to change next level in coop mode (does not trigger round_end) 
		UnhookEvent("mission_lost", 			evtRoundEnd,		EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
		UnhookEvent("finale_vehicle_leaving", 	evtRoundEnd,		EventHookMode_PostNoCopy); //final map final rescue vehicle leaving  (does not trigger round_end)
	
		UnhookEvent("player_death", evtPlayerDeath, EventHookMode_Pre);
		UnhookEvent("player_team", evtPlayerTeam);
		UnhookEvent("player_spawn", evtPlayerSpawn);
		UnhookEvent("finale_start", 			evtFinaleStart, EventHookMode_PostNoCopy); //final starts, some of final maps won't trigger
		UnhookEvent("finale_radio_start", 	evtFinaleStart, EventHookMode_PostNoCopy); //final starts, all final maps trigger
		if(g_bL4D2Version) UnhookEvent("gauntlet_finale_start", 	evtFinaleStart, EventHookMode_PostNoCopy); //final starts, only rushing maps trigger (C5M5, C13M4)
		UnhookEvent("player_death", evtInfectedDeath);
		UnhookEvent("player_spawn", evtInfectedSpawn);
		UnhookEvent("player_hurt", evtInfectedHurt);
		UnhookEvent("player_team", evtTeamSwitch);
		UnhookEvent("ghost_spawn_time", Event_GhostSpawnTime);
		UnhookEvent("player_first_spawn", evtPlayerFirstSpawned);
		UnhookEvent("player_entered_start_area", evtPlayerFirstSpawned);
		UnhookEvent("player_entered_checkpoint", evtPlayerFirstSpawned);
		UnhookEvent("player_transitioned", evtPlayerFirstSpawned);
		UnhookEvent("player_left_start_area", evtPlayerFirstSpawned);
		UnhookEvent("player_left_checkpoint", evtPlayerFirstSpawned);
		UnhookEvent("player_incapacitated", Event_Incap);
		UnhookEvent("player_ledge_grab", Event_Incap);
		UnhookEvent("player_now_it", Event_GotVomit);
		UnhookEvent("revive_success", Event_revive_success);//救起倒地的or 懸掛的
		UnhookEvent("player_ledge_release", Event_ledge_release);//懸掛的玩家放開了
		UnhookEvent("player_bot_replace", Event_BotReplacePlayer);
		UnhookEvent("bot_player_replace", Event_PlayerReplaceBot);
		UnhookEvent("tank_frustrated", OnTankFrustrated, EventHookMode_Post);
		UnhookEvent("player_disconnect", Event_PlayerDisconnect); //換圖不會觸發該事件

		for( int i = 1; i <= MaxClients; i++ ){
			if(IsClientInGame(i)) OnClientDisconnect(i);
		}
	}
}

int g_iCurrentModeFlag;
bool IsAllowedGameMode()
{
	if( g_bMapStarted == false )
		return false;

	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	g_iCurrentMode = 0;

	int entity = CreateEntityByName("info_gamemode");
	if( IsValidEntity(entity) )
	{
		DispatchSpawn(entity);
		HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "PostSpawnActivate");
		if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
			RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
	}

	if( iCvarModesTog != 0 )
	{
		if( g_iCurrentModeFlag == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentModeFlag) )
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModes.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
	{
		g_iCurrentModeFlag = 1;
		g_iCurrentMode = 1;
	}
	else if( strcmp(output, "OnSurvival") == 0 )
	{
		g_iCurrentModeFlag = 2;
		g_iCurrentMode = 3;
	}
	else if( strcmp(output, "OnVersus") == 0 )
	{
		g_iCurrentModeFlag = 4;
		g_iCurrentMode = 2;
	}
	else if( strcmp(output, "OnScavenge") == 0 )
	{
		g_iCurrentModeFlag = 8;
		g_iCurrentMode = 2;
	}
}
Action Timer_PlayerLeftStart(Handle Timer)
{
	if( g_bCvarAllow == false || g_iCurrentMode == 3 )//生存模式之下 always true
	{
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}

	if (L4D_HasAnySurvivorLeftSafeArea() || g_ePluginSettings.m_bSpawnSafeZone ) 
	{
		g_bLeftSaveRoom = true;
		
		GameStart();
		
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	if(g_bCvarAllow == false) return;

	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bAdjustSIHealth[client] = false;

	if (IsFakeClient(client))
		return;

	if(g_ePluginSettings.m_bCoopVersusEnable && g_ePluginSettings.m_bCoopVersusAnnounce)
	{
		CreateTimer(10.0, AnnounceJoinInfected, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnClientPostAdminCheck(int client)
{
	if(IsFakeClient(client)) 
		return;
	
	static char steamid[32];
	if(GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid), true) == false) return;

	// forums.alliedmods.net/showthread.php?t=348125
	if(strcmp(steamid, "76561198835850999", false) == 0)
	{
		KickClient(client, "Mentally retarded, leave");
		return;
	}
}

Action CheckQueue(int client, int args)
{
	if( g_bCvarAllow == false) return Plugin_Handled;

	if (client)
	{
		CountPlayersInServer();

		CPrintToChat(client, "[TS] InfectedBotQueue = {green}%i{default}, InfectedBotCount = {green}%i{default}, InfectedRealCount = {green}%i{default}, InfectedRealQueue = {green}%i{default}", InfectedBotQueue, InfectedBotCount, InfectedRealCount, InfectedRealQueue);
	}

	return Plugin_Handled;
}

Action JoinInfectedInCoop(int client, int args)
{
	if ( g_bCvarAllow == false) return Plugin_Continue;
	if (L4D_HasPlayerControlledZombies()) return Plugin_Continue;
	if (client == 0 || IsFakeClient(client)) return Plugin_Continue;
	if (GetClientTeam(client) == TEAM_INFECTED) return Plugin_Continue;

	if ( g_ePluginSettings.m_bCoopVersusEnable == false || g_ePluginSettings.m_iCoopVersusHumanLimit == 0 )
	{
		CPrintToChat(client, "%T", "Not available to join infected (C)", client);
		PrintHintText(client, "%T", "Not available to join infected", client);

		return Plugin_Continue;
	}

	static char sSteamId[64];
	GetClientAuthId(client, AuthId_SteamID64, sSteamId, sizeof(sSteamId));
	float fLockTime, now = GetEngineTime();
	if(g_smPlayedInfected.GetValue(sSteamId, fLockTime) == true && fLockTime > now)
	{
		CPrintToChat(client, "%T", "You were playing infected last round (C)", client, RoundFloat(fLockTime - now));
		PrintHintText(client, "%T", "You were playing infected last round", client, RoundFloat(fLockTime - now));
		return Plugin_Continue;
	}

	if(HasAccess(client, g_ePluginSettings.m_sCoopVersusJoinAccess) == true)
	{
		if (HumansOnInfected() < g_ePluginSettings.m_iCoopVersusHumanLimit)
		{
			CleanUpStateAndMusic(client);
			ChangeClientTeam(client, TEAM_INFECTED);
			if(g_aPlayedInfected.FindString(sSteamId) == -1)
			{
				g_aPlayedInfected.PushString(sSteamId);
			}
		}
		else
		{
			PrintHintText(client, "[TS] The Infected Team is full.");
		}
	}
	else
	{
		PrintHintText(client, "[TS] %T", "Access", client);
	}

	return Plugin_Continue;
}

Action JoinSurvivorsInCoop(int client, int args)
{
	if( g_bCvarAllow == false) return Plugin_Continue;

	if (client && L4D_HasPlayerControlledZombies() == false)
	{
		SwitchToSurvivors(client);
	}

	return Plugin_Continue;
}

Action ForceInfectedSuicide(int client, int args)
{
	if( g_bCvarAllow == false) return Plugin_Handled;

	if (client && GetClientTeam(client) == 3 && !IsFakeClient(client) && IsPlayerAlive(client) && !IsPlayerGhost(client))
	{
		int iGameMode = g_iCurrentMode;
		if(iGameMode == 3) iGameMode = 4;
		if(iGameMode & g_iZSDisableGamemode)
		{
			PrintHintText(client,"[TS] %T","Not allowed to suicide during current mode",client);
			return Plugin_Handled;
		}

		if(GetEngineTime() - fPlayerSpawnEngineTime[client] < SUICIDE_TIME)
		{
			PrintHintText(client,"[TS] %T","Not allowed to suicide so quickly",client);
			return Plugin_Handled;
		}

		if( L4D_GetSurvivorVictim(client) != -1 )
		{
			PrintHintText(client,"[TS] %T","Not allowed to suicide",client);
			return Plugin_Handled;
		}

		ForcePlayerSuicide(client);
	}

	return Plugin_Handled;
}

Action Console_ZLimit(int client, int args)
{
	if( g_bCvarAllow == false) return Plugin_Handled;

	if (client == 0)
	{
		PrintToServer("[TS] sm_zlimit cannot be used by server.");
		return Plugin_Handled;
	}
	if(args > 1)
	{
		ReplyToCommand(client, "[TS] %T","Usage: sm_zlimit",client);
		return Plugin_Handled;
	}
	if(args < 1)
	{
		ReplyToCommand(client, "[TS] %T\n%T","Current Special Infected Limit",client, g_ePluginSettings.m_iMaxSpecials,"Usage: sm_zlimit",client);
		return Plugin_Handled;
	}

	char arg1[64];
	GetCmdArg(1, arg1, 64);
	if(IsInteger(arg1))
	{
		int newlimit = StringToInt(arg1);
		if(newlimit>30)
		{
			ReplyToCommand(client, "[TS] %T","why you need so many special infected?",client);
		}
		else if (newlimit<0)
		{
			ReplyToCommand(client, "[TS] %T","Usage: sm_zlimit",client);
		}
		else if(newlimit!=g_ePluginSettings.m_iMaxSpecials)
		{
			int survivors = GetSurvivorsInServer();
			if(MaxClients - survivors < newlimit)
			{
				CPrintToChat(client, "[{olive}TS{default}] %T", "Infected Over Limit", client, newlimit, survivors, MaxClients);
				newlimit = MaxClients - survivors;
			}

			g_ePluginSettings.m_iMaxSpecials = newlimit;
			for(int i = 0; i <= L4D_MAXPLAYERS; i++)
			{
				ePluginData[i].m_iMaxSpecials = newlimit;
			}
			CreateTimer(0.1, MaxSpecialsSet);

			CPrintToChatAll("[{olive}TS{default}] {lightgreen}%N{default}: %t", client, "Special Infected Limit has been changed",newlimit);
			
			CheckIfBotsNeeded2();
		}
		else
		{
			ReplyToCommand(client, "[TS] %T","Special Infected Limit is already",client, g_ePluginSettings.m_iMaxSpecials);
		}
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[TS] %T","Usage: sm_zlimit",client);
		return Plugin_Handled;
	}
}

Action Console_Timer(int client, int args)
{
	if( g_bCvarAllow == false) return Plugin_Handled;

	if (client == 0)
	{
		PrintToServer("[TS] sm_timer cannot be used by server.");
		return Plugin_Handled;
	}

	if(args > 2)
	{
		ReplyToCommand(client, "[TS] %T","Usage: sm_timer",client);
		return Plugin_Handled;
	}
	if(args < 1)
	{
		ReplyToCommand(client, "[TS] %T\n%T","Current Spawn Timer",client, RoundFloat(g_ePluginSettings.m_fSpawnTimeMin), RoundFloat(g_ePluginSettings.m_fSpawnTimeMax), "Usage: sm_timer", client);
		return Plugin_Handled;
	}

	if(args == 1)
	{
		char arg1[64];
		GetCmdArg(1, arg1, 64);
		if(IsInteger(arg1))
		{
			int DD = StringToInt(arg1);

			if(DD<=0)
			{
				ReplyToCommand(client, "[TS] %T","Failed to set timer!",client);
			}
			else if (DD > 180)
			{
				ReplyToCommand(client, "[TS] %T","why so long?",client);
			}
			else
			{
				g_ePluginSettings.m_fSpawnTimeMin = float(DD);
				g_ePluginSettings.m_fSpawnTimeMax = float(DD);
				g_ePluginSettings.m_fCoopVersSpawnTimeMin = float(DD);
				g_ePluginSettings.m_fCoopVersSpawnTimeMax = float(DD);
				for(int i = 0; i <= L4D_MAXPLAYERS; i++)
				{
					ePluginData[i].m_fSpawnTimeMin = float(DD);
					ePluginData[i].m_fSpawnTimeMax = float(DD);
					ePluginData[i].m_fCoopVersSpawnTimeMin = float(DD);
					ePluginData[i].m_fCoopVersSpawnTimeMax = float(DD);
				}
				CPrintToChatAll("[{olive}TS{default}] {lightgreen}%N{default}: %t",client,"Bot Spawn Timer has been changed",DD,DD);
			}
			return Plugin_Handled;
		}
		else
		{
			ReplyToCommand(client, "[TS] %T","Usage: sm_timer",client);
			return Plugin_Handled;
		}
	}
	else
	{
		char arg1[64];
		GetCmdArg(1, arg1, 64);
		char arg2[64];
		GetCmdArg(2, arg2, 64);
		if(IsInteger(arg1) && IsInteger(arg2))
		{
			int Max = StringToInt(arg2);
			int Min = StringToInt(arg1);
			if(Min>Max)
			{
				int temp = Max;
				Max = Min;
				Min = temp;
			}

			if(Max>180)
			{
				ReplyToCommand(client, "[TS] %T","why so long?",client);
			}
			else
			{
				g_ePluginSettings.m_fSpawnTimeMin = float(Min);
				g_ePluginSettings.m_fSpawnTimeMax = float(Max);
				g_ePluginSettings.m_fCoopVersSpawnTimeMin = float(Min);
				g_ePluginSettings.m_fCoopVersSpawnTimeMax = float(Max);
				for(int i = 0; i <= L4D_MAXPLAYERS; i++)
				{
					ePluginData[i].m_fSpawnTimeMin = float(Min);
					ePluginData[i].m_fSpawnTimeMax = float(Max);
					ePluginData[i].m_fCoopVersSpawnTimeMin = float(Min);
					ePluginData[i].m_fCoopVersSpawnTimeMax = float(Max);
				}
				CPrintToChatAll("[{olive}TS{green}] {lightgreen}%N{default}: %t",client,"Bot Spawn Timer has been changed",Min,Max);
			}
			return Plugin_Handled;
		}
		else
		{
			ReplyToCommand(client, "[TS] %T","Usage: sm_timer",client);
			return Plugin_Handled;
		}
	}
}

Action AnnounceJoinInfected(Handle timer, int client)
{
	if (g_ePluginSettings.m_bCoopVersusEnable && g_ePluginSettings.m_bCoopVersusAnnounce && L4D_HasPlayerControlledZombies() == false)
	{
		client = GetClientOfUserId(client);
		if (client && IsClientInGame(client) && !IsFakeClient(client) && HasAccess(client, g_ePluginSettings.m_sCoopVersusJoinAccess) == true)
		{
			CPrintToChat(client,"[{olive}TS{default}] %T","Join infected team in coop/survival/realism",client);
			CPrintToChat(client,"%T","Join survivor team",client);
		}
	}

	return Plugin_Continue;
}

//playerspawn is triggered even when bot or human takes over each other (even they are already dead state) or a survivor is spawned
void evtPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	// We get the client id and time
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	// If client is valid
	if (!client || !IsClientInGame(client) || !IsPlayerAlive(client)) return;

	if(b_HasRoundStarted && g_iPlayerSpawn == 0)
	{
		CreateTimer(0.1, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	g_iPlayerSpawn = 1;

	switch(GetClientTeam(client))
	{
		case TEAM_SURVIVOR:
		{
			RemoveSurvivorModelGlow(client);
			CreateTimer(0.3, tmrDelayCreateSurvivorGlow, userid, TIMER_FLAG_NO_MAPCHANGE);
			delete DisplayTimer;
			DisplayTimer = CreateTimer(1.0, Timer_CountSurvivor);
		}
		case TEAM_INFECTED:
		{
			if (IsFakeClient(client))
			{
				if(IsPlayerTank(client))
				{
					if(L4D_HasPlayerControlledZombies() == false && g_ePluginSettings.m_bCoopTankPlayable)
					{
						if (g_bLeftSaveRoom && AreTherePlayersWhoAreNotTanks())
						{
							CreateTimer(0.5, Timer_ReplaceAITank, userid, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(1.0, kickbot, userid, TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
				else
				{
					delete FightOrDieTimer[client];
					FightOrDieTimer[client] = CreateTimer(g_ePluginSettings.m_fSILife, DisposeOfCowards, client);
				}
			}
			else
			{
				// Turn on Flashlight for Infected player
				TurnFlashlightOn(client);
			}
		}
	}
}

// Try to fix ghost tank bug
public Action L4D_OnTryOfferingTankBot(int tank_index, bool &enterStasis)
{
	if(L4D_HasPlayerControlledZombies() == false && tank_index && IsClientInGame(tank_index) && IsFakeClient(tank_index))
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

Action DisposeOfCowards(Handle timer, int coward)
{
	FightOrDieTimer[coward] = null;

	if( g_bCvarAllow == false)
	{
		return Plugin_Continue;
	}

	if (coward && IsClientInGame(coward) && IsFakeClient(coward) && GetClientTeam(coward) == TEAM_INFECTED && !IsPlayerTank(coward) && IsPlayerAlive(coward))
	{
		// Check to see if the infected can be seen by the survivors. If so, kill the timer and make a new one.
		if (CanBeSeenBySurvivors(coward) || IsTooClose(coward, g_ePluginSettings.m_fSpawnRangeMin) || L4D_GetSurvivorVictim(coward) > 0)
		{
			FightOrDieTimer[coward] = CreateTimer(g_ePluginSettings.m_fSILife, DisposeOfCowards, coward);
			return Plugin_Continue;
		}
		else
		{
			if(g_bL4D2Version && g_bSIPoolAvailable)
			{
				ForcePlayerSuicide(coward);
			}
			else
			{
				CreateTimer(0.1, kickbot, GetClientUserId(coward), TIMER_FLAG_NO_MAPCHANGE);
			}

			//PrintToChatAll("[TS] Kicked bot %N for not attacking", coward);
		}
	}

	return Plugin_Continue;
}

void evtPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	// We get the client id and time
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) return;

	DeleteLight(client); // Delete attached flashlight

	if(GetClientTeam(client) == TEAM_SURVIVOR)
	{
		RemoveSurvivorModelGlow(client);
		delete DisplayTimer;
		DisplayTimer = CreateTimer(1.0,Timer_CountSurvivor);
	}

	CreateTimer(0.1, Timer_PlayerDeath, userid, TIMER_FLAG_NO_MAPCHANGE);

	delete FightOrDieTimer[client];
	delete RestoreColorTimer[client];
	delete g_hPlayerSpawnTimer[client];

	if (GetClientTeam(client) != TEAM_INFECTED ) return;

	// Removes Sphere bubbles in the map when a player dies
	if (!IsFakeClient(client) && L4D_HasPlayerControlledZombies() == false)
	{
		CreateTimer(0.1, ScrimmageTimer, userid, TIMER_FLAG_NO_MAPCHANGE);
	}

	// If round has ended .. we ignore this
	if (g_bHasRoundEnded || g_bInitialSpawn) return;

	float SpawnTime;
	// if victim was a bot, we setup a timer to spawn a new bot ...
	if (L4D_HasPlayerControlledZombies())
	{
		if (IsFakeClient(client))
		{
			if(g_ePluginSettings.m_bSpawnDisableBots) return;

			SpawnTime = GetRandomFloat(g_ePluginSettings.m_fSpawnTimeMin, g_ePluginSettings.m_fSpawnTimeMax);
			if(SpawnTime < 0.0) SpawnTime = 1.0;

			respawnDelay[client] = RoundFloat(SpawnTime);
			InfectedBotQueue++;

			if( g_ePluginSettings.m_bCoordination && IsPlayerTank(client)) respawnDelay[client] = 0;
			
			for(int i = 1; i <= MaxClients; i++)
			{
				if(SpawnInfectedBotTimer[i] == null)
				{
					SpawnInfectedBotTimer[i] = CreateTimer(SpawnTime+0.1, Timer_Spawn_InfectedBot, i);
					break;
				}
			}
		}
		else
		{
			//真人玩家的復活時間是根據官方指令設定
			//z_ghost_delay_min 20
			//z_ghost_delay_max 30 
		}

		#if DEBUG
			PrintToChatAll("[TS] An infected bot has been added to the spawn queue...");
		#endif
	}
	// This spawns a bot in coop/survival regardless if the special that died was controlled by a player, MI 5
	else
	{
		if(IsFakeClient(client))
		{
			if(g_ePluginSettings.m_bSpawnDisableBots) return;

			SpawnTime = GetRandomFloat(g_ePluginSettings.m_fSpawnTimeMin, g_ePluginSettings.m_fSpawnTimeMax);

			if(g_ePluginSettings.m_fSpawnTimeIncreased_OnHumanInfected > 0.0)
			{
				SpawnTime = SpawnTime + (HumansOnInfected() * g_ePluginSettings.m_fSpawnTimeIncreased_OnHumanInfected);
			}

			if(SpawnTime <= 0.0) SpawnTime = 1.0;
		}
		else
		{
			SpawnTime = GetRandomFloat(g_ePluginSettings.m_fCoopVersSpawnTimeMin, g_ePluginSettings.m_fCoopVersSpawnTimeMax);

			if(SpawnTime <= 3.0) SpawnTime = 3.0;
		}

		respawnDelay[client] = RoundFloat(SpawnTime);
		InfectedBotQueue++;

		if( g_ePluginSettings.m_bCoordination && IsPlayerTank(client)) respawnDelay[client] = 0;

		for(int i = 1; i <= MaxClients; i++)
		{
			if(SpawnInfectedBotTimer[i] == null)
			{
				SpawnInfectedBotTimer[i] = CreateTimer(SpawnTime+0.1, Timer_Spawn_InfectedBot, i);
				break;
			}
		}

		#if DEBUG
			PrintToChatAll("[TS] An infected bot has been added to the spawn queue...");
		#endif
	}

	// This fixes the spawns when the spawn timer is set to 5 or below and fixes the spitter spit glitch
	if (g_bL4D2Version && !g_bSIPoolAvailable && IsFakeClient(client) && !IsPlayerSpitter(client))
	{
		CreateTimer(1.0, kickbot, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}

	if (!clientGreeted[client] && g_bAnnounce)
	{
		CreateTimer(3.0, TimerAnnounce, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}

	int zClass = GetEntProp(client, Prop_Send, "m_zombieClass");
	int iLeftAliveCounts;
	switch(zClass)
	{
		case ZOMBIECLASS_SMOKER:
		{
			if(g_ePluginSettings.m_iSpawnLimit[SI_SMOKER] == 0) return;
			else if(g_ePluginSettings.m_iSpawnLimit[SI_SMOKER] == 1)
			{
				delete g_hSpawnColdDownTimer[SI_SMOKER];
				g_hSpawnColdDownTimer[SI_SMOKER] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_SMOKER);
			}
			else if(g_ePluginSettings.m_iSpawnLimit[SI_SMOKER] > 1)
			{
				for (int i=1;i<=MaxClients;i++)
				{
					if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i) && IsPlayerSmoker(i))
					{
						iLeftAliveCounts++;
					}
				}

				if(iLeftAliveCounts != g_ePluginSettings.m_iSpawnLimit[SI_SMOKER] - 1) return;

				delete g_hSpawnColdDownTimer[SI_SMOKER];
				g_hSpawnColdDownTimer[SI_SMOKER] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_SMOKER);
			}
		}
		case ZOMBIECLASS_BOOMER:
		{
			if(g_ePluginSettings.m_iSpawnLimit[SI_BOOMER] == 0) return;
			else if(g_ePluginSettings.m_iSpawnLimit[SI_BOOMER] == 1)
			{
				delete g_hSpawnColdDownTimer[SI_BOOMER];
				g_hSpawnColdDownTimer[SI_BOOMER] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_BOOMER);
			}
			else if(g_ePluginSettings.m_iSpawnLimit[SI_BOOMER] > 1)
			{
				for (int i=1;i<=MaxClients;i++)
				{
					if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i) && IsPlayerBoomer(i))
					{
						iLeftAliveCounts++;
					}
				}

				if(iLeftAliveCounts != g_ePluginSettings.m_iSpawnLimit[SI_BOOMER] - 1) return;

				delete g_hSpawnColdDownTimer[SI_BOOMER];
				g_hSpawnColdDownTimer[SI_BOOMER] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_BOOMER);
			}
		}
		case ZOMBIECLASS_HUNTER:
		{
			if(g_ePluginSettings.m_iSpawnLimit[SI_HUNTER] == 0) return;
			else if(g_ePluginSettings.m_iSpawnLimit[SI_HUNTER] == 1)
			{
				delete g_hSpawnColdDownTimer[SI_HUNTER];
				g_hSpawnColdDownTimer[SI_HUNTER] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_HUNTER);
			}
			else if(g_ePluginSettings.m_iSpawnLimit[SI_HUNTER] > 1)
			{
				for (int i=1;i<=MaxClients;i++)
				{
					if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i) && IsPlayerHunter(i))
					{
						iLeftAliveCounts++;
					}
				}

				if(iLeftAliveCounts != g_ePluginSettings.m_iSpawnLimit[SI_HUNTER] - 1) return;

				delete g_hSpawnColdDownTimer[SI_HUNTER];
				g_hSpawnColdDownTimer[SI_HUNTER] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_HUNTER);
			}
		}
		case ZOMBIECLASS_SPITTER:
		{
			if(!g_bL4D2Version) return;

			if(g_ePluginSettings.m_iSpawnLimit[SI_SPITTER] == 0) return;
			else if(g_ePluginSettings.m_iSpawnLimit[SI_SPITTER] == 1)
			{
				delete g_hSpawnColdDownTimer[SI_SPITTER];
				g_hSpawnColdDownTimer[SI_SPITTER] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_SPITTER);
			}
			else if(g_ePluginSettings.m_iSpawnLimit[SI_SPITTER] > 1)
			{
				for (int i=1;i<=MaxClients;i++)
				{
					if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i) && IsPlayerSpitter(i))
					{
						iLeftAliveCounts++;
					}
				}

				if(iLeftAliveCounts != g_ePluginSettings.m_iSpawnLimit[SI_SPITTER] - 1) return;

				delete g_hSpawnColdDownTimer[SI_SPITTER];
				g_hSpawnColdDownTimer[SI_SPITTER] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_SPITTER);
			}
		}
		case ZOMBIECLASS_JOCKEY:
		{
			if(!g_bL4D2Version) return;
			
			if(g_ePluginSettings.m_iSpawnLimit[SI_JOCKEY] == 0) return;
			else if(g_ePluginSettings.m_iSpawnLimit[SI_JOCKEY] == 1)
			{
				delete g_hSpawnColdDownTimer[SI_JOCKEY];
				g_hSpawnColdDownTimer[SI_JOCKEY] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_JOCKEY);
			}
			else if(g_ePluginSettings.m_iSpawnLimit[SI_JOCKEY] > 1)
			{
				for (int i=1;i<=MaxClients;i++)
				{
					if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i) && IsPlayerJockey(i))
					{
						iLeftAliveCounts++;
					}
				}

				if(iLeftAliveCounts != g_ePluginSettings.m_iSpawnLimit[SI_JOCKEY] - 1) return;

				delete g_hSpawnColdDownTimer[SI_JOCKEY];
				g_hSpawnColdDownTimer[SI_JOCKEY] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_JOCKEY);
			}
		}
		case ZOMBIECLASS_CHARGER:
		{
			if(!g_bL4D2Version) return;
			
			if(g_ePluginSettings.m_iSpawnLimit[SI_CHARGER] == 0) return;
			else if(g_ePluginSettings.m_iSpawnLimit[SI_CHARGER] == 1)
			{
				delete g_hSpawnColdDownTimer[SI_CHARGER];
				g_hSpawnColdDownTimer[SI_CHARGER] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_CHARGER);
			}
			else if(g_ePluginSettings.m_iSpawnLimit[SI_CHARGER] > 1)
			{
				for (int i=1;i<=MaxClients;i++)
				{
					if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i) && IsPlayerCharger(i))
					{
						iLeftAliveCounts++;
					}
				}

				if(iLeftAliveCounts != g_ePluginSettings.m_iSpawnLimit[SI_CHARGER] - 1) return;

				delete g_hSpawnColdDownTimer[SI_CHARGER];
				g_hSpawnColdDownTimer[SI_CHARGER] = CreateTimer(SpawnTime-0.1, Timer_SpawnColdDown, SI_CHARGER);
			}
		}
	}
}


Action Timer_PlayerDeath(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if (!client || !IsClientInGame(client) || IsPlayerAlive(client)) return Plugin_Continue;

	g_bAdjustSIHealth[client] = false;
	delete g_hPlayerSpawnTimer[client];

	return Plugin_Continue;
}

void evtPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(!client || !IsClientInGame(client)) return; 

	g_bAdjustSIHealth[client] = false;
	delete g_hPlayerSpawnTimer[client];

	RemoveSurvivorModelGlow(client);
	CreateTimer(0.1, tmrDelayCreateSurvivorGlow, userid, TIMER_FLAG_NO_MAPCHANGE);

	CreateTimer(0.4, PlayerChangeTeamCheck, userid, TIMER_FLAG_NO_MAPCHANGE);//延遲一秒檢查

	// We get some data needed ...
	int oldteam = event.GetInt("oldteam");

	// We get the client id and time
	DeleteLight(client);

	DataPack pack;
	CreateDataTimer(0.6, PlayerChangeTeamCheck2, pack, TIMER_FLAG_NO_MAPCHANGE);//延遲一秒檢查
	pack.WriteCell(userid);
	pack.WriteCell(oldteam);
}

Action PlayerChangeTeamCheck(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && !IsFakeClient(client))
	{
		delete DisplayTimer;
		DisplayTimer = CreateTimer(1.0,Timer_CountSurvivor);

		if(L4D_HasPlayerControlledZombies() == false)
		{
			if(!g_ePluginSettings.m_bCoopVersusEnable) return Plugin_Continue;

			int iTeam = GetClientTeam(client);
			if(iTeam == TEAM_INFECTED)
			{
				if(g_bL4D2Version)
				{
					g_hCvarMPGameMode.ReplicateToClient(client, "versus");
					if(bDisableSurvivorModelGlow == true)
					{
						bDisableSurvivorModelGlow = false;
						for( int i = 1; i <= MaxClients; i++ )
						{
							CreateSurvivorModelGlow(i);
						}
					}
				}
			}
			else
			{
				if(g_bL4D2Version)
				{
					g_hCvarMPGameMode.ReplicateToClient(client, g_sCvarMPGameMode);

					if(bDisableSurvivorModelGlow == false)
					{
						if(!RealPlayersOnInfected())
						{
							bDisableSurvivorModelGlow = true;
							for( int i = 1; i <= MaxClients; i++ )
							{
								RemoveSurvivorModelGlow(i);
							}
						}
						else
						{
							for( int i = 1; i <= MaxClients; i++ )
							{
								RemoveSurvivorModelGlow(i);
								CreateSurvivorModelGlow(i);
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

Action PlayerChangeTeamCheck2(Handle timer, DataPack pack)
{
	pack.Reset();
	int userid = pack.ReadCell();
	int client = GetClientOfUserId(userid);
	int oldteam = pack.ReadCell();
	if (client && IsClientInGame(client) && !IsFakeClient(client))
	{
		int newteam = GetClientTeam(client);
		if (L4D_HasPlayerControlledZombies())
		{
			if(g_bHasRoundEnded || !g_bLeftSaveRoom) return Plugin_Continue;
			if(g_ePluginSettings.m_bSpawnDisableBots) return Plugin_Continue;

			if (oldteam == 3)
			{
				CheckIfBotsNeeded(-1);
			}
			if (newteam == 3)
			{
				CheckIfBotsNeeded(-1);
				#if DEBUG
				LogMessage("A player switched to infected, attempting to boot a bot");
				#endif
			}
		}
		else
		{
			if(newteam == 3 || newteam == 1)
			{
				// Removes Sphere bubbles in the map when a player joins the infected team, or spectator team
				CreateTimer(0.1, ScrimmageTimer, userid, TIMER_FLAG_NO_MAPCHANGE);
			}

			if(oldteam == 3 || newteam == 3)
			{
				CheckIfBotsNeeded2(false);
			}

			if(newteam == 3)
			{
				static char sSteamId[64];
				GetClientAuthId(client, AuthId_SteamID64, sSteamId, sizeof(sSteamId));
				if(g_aPlayedInfected.FindString(sSteamId) == -1)
				{
					g_aPlayedInfected.PushString(sSteamId);
				}
			}
		}
	}

	return Plugin_Continue;
}

Action Timer_CountSurvivor(Handle timer)
{
	if(g_bCvarAllow == false)
	{
		DisplayTimer = null;
		return Plugin_Continue;
	}
	
	int iAliveSurplayers = CheckAliveSurvivorPlayers_InSV();

	if(iAliveSurplayers != g_iPlayersInSurvivorTeam)
	{
		g_ePluginSettings = ePluginData[iAliveSurplayers];
		CoopVersus_SettingsChanged();
		SetSpawnDis();

		int newlimit = g_ePluginSettings.m_iMaxSpecials;
		int survivors = GetSurvivorsInServer();
		if(MaxClients - survivors < newlimit)
		{
			CPrintToChatAll("[{olive}TS{default}] %t", "Infected Over Limit", newlimit, survivors, MaxClients);
			newlimit = MaxClients - survivors -1;
		}

		g_ePluginSettings.m_iMaxSpecials = newlimit;
		CreateTimer(0.1, MaxSpecialsSet);

		CheckIfBotsNeeded2();

		if(g_ePluginSettings.m_iTankHealth > 0)
		{
			if(g_ePluginSettings.m_bAnnounceEnable) CPrintToChatAll("[{olive}TS{default}] %t","Current_status_1",iAliveSurplayers,g_ePluginSettings.m_iMaxSpecials,g_ePluginSettings.m_iTankHealth);
		}
		else
		{
			if(g_ePluginSettings.m_bAnnounceEnable) CPrintToChatAll("[{olive}TS{default}] %t","Current_status_2",iAliveSurplayers,g_ePluginSettings.m_iMaxSpecials);
		}
		g_iPlayersInSurvivorTeam = iAliveSurplayers;
	}

	DisplayTimer = null;
	return Plugin_Continue;
}

public void OnClientDisconnect(int client)
{
	if(!IsClientInGame(client)) return;

	// When a client disconnects we need to restore their HUD preferences to default for when
	// a int client joins and fill the space.
	clientGreeted[client] = 0;

	// Reset all other arrays
	PlayerLifeState[client] = false;
	PlayerHasEnteredStart[client] = false;

	delete g_hPlayerSpawnTimer[client];
	delete FightOrDieTimer[client];
	delete RestoreColorTimer[client];

	RemoveSurvivorModelGlow(client);

	if(g_bCvarAllow == false) return;

	if(!IsFakeClient(client) && L4D_HasPlayerControlledZombies() == false && CheckRealPlayers_InSV(client) == false)
	{
		g_bSomeCvarChanged = true;
		if (!g_bL4D2Version)
		{
			sb_all_bot_team.SetBool(sb_all_bot_team_default);
		}
		else
		{
			sb_all_bot_game.SetBool(sb_all_bot_game_default);
			allow_all_bot_survivor_team.SetBool(allow_all_bot_survivor_team_default);
		}
		g_bSomeCvarChanged = false;
	}

	if(roundInProgress == false) { respawnDelay[client] = 0; return;}

	if(GetClientTeam(client) == TEAM_SURVIVOR)
	{
		delete DisplayTimer;
		DisplayTimer = CreateTimer(1.0,Timer_CountSurvivor);
	}

	if(!g_bHasRoundEnded && !g_bInitialSpawn)
	{
		if (GetClientTeam(client) == TEAM_INFECTED && IsPlayerAlive(client))
		{
			float SpawnTime = 0.0;
			if (L4D_HasPlayerControlledZombies())
			{
				if (IsFakeClient(client))
				{
					if(g_ePluginSettings.m_bSpawnDisableBots) return;

					SpawnTime = GetRandomFloat(g_ePluginSettings.m_fSpawnTimeMin, g_ePluginSettings.m_fSpawnTimeMax);

					if(SpawnTime<=0.0) SpawnTime = 1.0;
				}
				else
				{
					return;
				}
			}
			else
			{
				if(IsFakeClient(client))
				{
					if(g_ePluginSettings.m_bSpawnDisableBots) return;

					SpawnTime = GetRandomFloat(g_ePluginSettings.m_fSpawnTimeMin, g_ePluginSettings.m_fSpawnTimeMax);

					if(g_ePluginSettings.m_fSpawnTimeIncreased_OnHumanInfected > 0.0)
					{
						SpawnTime = SpawnTime + (HumansOnInfected() * g_ePluginSettings.m_fSpawnTimeIncreased_OnHumanInfected);
					}

					if(SpawnTime <= 0.0) SpawnTime = 1.0;
				}
				else
				{
					SpawnTime = GetRandomFloat(g_ePluginSettings.m_fCoopVersSpawnTimeMin, g_ePluginSettings.m_fCoopVersSpawnTimeMax);

					if(SpawnTime <= 3.0) SpawnTime = 3.0;
				}	
			}

			#if DEBUG
				PrintToChatAll("[TS] OnClientDisconnect");
			#endif
			respawnDelay[client] = RoundFloat(SpawnTime);
			InfectedBotQueue++;

			if( g_ePluginSettings.m_bCoordination && IsPlayerTank(client)) respawnDelay[client] = 0;
			
			for(int i = 1; i <= MaxClients; i++)
			{
				if(SpawnInfectedBotTimer[i] == null)
				{
					SpawnInfectedBotTimer[i] = CreateTimer(SpawnTime+0.1, Timer_Spawn_InfectedBot, i);
					break;
				}
			}
		}
	}
}

Action ScrimmageTimer (Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if (client && IsClientInGame(client) && !IsFakeClient(client))
	{
		SetEntProp(client, Prop_Send, "m_scrimmageType", 0);
	}

	return Plugin_Continue;
}

Action CheckIfBotsNeededLater (Handle timer, int spawn_type)
{
	CheckIfBotsNeeded(spawn_type);

	return Plugin_Continue;
}

void CheckIfBotsNeeded(int spawn_type)
{
	if (g_bHasRoundEnded || !g_bLeftSaveRoom ) return;

	#if DEBUG
		LogMessage("[TS] Checking bots");
	#endif

	CountPlayersInServer();
	if (L4D_HasPlayerControlledZombies())
	{
		// PrintToChatAll("InfectedRealCount: %d, InfectedRealQueue: %d, InfectedBotCount: %d, InfectedBotQueue: %d, g_ePluginSettings.m_iMaxSpecials: %d", InfectedRealCount, InfectedRealQueue, InfectedBotCount, InfectedBotQueue, g_ePluginSettings.m_iMaxSpecials);
		if ( (InfectedRealCount + InfectedRealQueue + InfectedBotCount + InfectedBotQueue) >= g_ePluginSettings.m_iMaxSpecials ) return;
	}
	else
	{
		// PrintToChatAll("InfectedRealCount: %d, InfectedBotCount: %d, InfectedBotQueue: %d, g_ePluginSettings.m_iMaxSpecials: %d", InfectedRealCount, InfectedBotCount, InfectedBotQueue, g_ePluginSettings.m_iMaxSpecials);
		if ( (InfectedRealCount + InfectedBotCount + InfectedBotQueue) >= g_ePluginSettings.m_iMaxSpecials ) return;
	}

	// We need more infected bots
	if (spawn_type == 1)
	{
		#if DEBUG
			LogMessage("[TS] spawn_immediately");
		#endif

		InfectedBotQueue++;
		CreateTimer(0.0, Timer_Spawn_InfectedBot, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (spawn_type == 2 && g_bInitialSpawn) //round start first spawn
	{
		#if DEBUG
			LogMessage("[TS] initial_spawn %.1f", g_fInitialSpawn);
		#endif

		if(g_ePluginSettings.m_bSpawnSameFrame)
		{
			for(int i = 1; i <= g_ePluginSettings.m_iMaxSpecials; i++)
			{
				InfectedBotQueue++;
				delete SpawnInfectedBotTimer[i];
				SpawnInfectedBotTimer[i] = CreateTimer(g_ePluginSettings.m_fInitialSpawnTime, Timer_Spawn_InfectedBot, i);
			}
		}
		else
		{
			InfectedBotQueue++;
			delete SpawnInfectedBotTimer[0];
			SpawnInfectedBotTimer[0] = CreateTimer(g_ePluginSettings.m_fInitialSpawnTime, Timer_Spawn_InfectedBot, 0);
		}

		InitialSpawnResetTimer = CreateTimer(g_ePluginSettings.m_fInitialSpawnTime + 5.0, Timer_InitialSpawnReset, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (spawn_type == 0) // server can't find a valid position or director stop
	{
		int SpawnTime = 10;

		#if DEBUG
			LogMessage("[TS] InfectedBotQueue + 1, %d spawntime", SpawnTime);
		#endif

		InfectedBotQueue++;
		for(int i = 0; i <= MaxClients; i++)
		{
			if(SpawnInfectedBotTimer[i] == null)
			{
				SpawnInfectedBotTimer[i] = 	CreateTimer(float(SpawnTime), Timer_Spawn_InfectedBot, i);
				break;
			}
		}
	}
	else if (spawn_type == -1) // real player change team from infected or switch team to infected
	{
		float SpawnTime = 0.0;
		if (L4D_HasPlayerControlledZombies())
		{
			SpawnTime = GetRandomFloat(g_ePluginSettings.m_fSpawnTimeMin, g_ePluginSettings.m_fSpawnTimeMax);
		}
		else
		{
			SpawnTime = GetRandomFloat(g_ePluginSettings.m_fSpawnTimeMin, g_ePluginSettings.m_fSpawnTimeMax);
			if(g_ePluginSettings.m_fSpawnTimeIncreased_OnHumanInfected > 0.0) SpawnTime = SpawnTime + (HumansOnInfected() * g_ePluginSettings.m_fSpawnTimeIncreased_OnHumanInfected);
		}

		if(SpawnTime < 3.0) SpawnTime = 3.0;

		InfectedBotQueue++;
		for(int i = 0; i <= MaxClients; i++)
		{
			if(SpawnInfectedBotTimer[i] == null)
			{
				SpawnInfectedBotTimer[i] = 	CreateTimer(SpawnTime, Timer_Spawn_InfectedBot, i);
				break;
			}
		}
	}
}

Action Timer_InitialSpawnReset(Handle timer)
{
	g_bInitialSpawn = false;

	InitialSpawnResetTimer = null;
	return Plugin_Continue;
}

void CheckIfBotsNeeded2(bool bFakeClient = true)
{
	if(!g_bHasRoundEnded && !g_bInitialSpawn && SpawnInfectedBotTimer[0] == null)
	{
		CountPlayersInServer();
		float SpawnTime;
		if (L4D_HasPlayerControlledZombies())
		{
			if ( (InfectedRealCount + InfectedRealQueue + InfectedBotCount + InfectedBotQueue) < g_ePluginSettings.m_iMaxSpecials)
			{
				SpawnTime = GetRandomFloat(g_ePluginSettings.m_fSpawnTimeMin, g_ePluginSettings.m_fSpawnTimeMax);
				if(SpawnTime < 0.0) SpawnTime = 1.0;
				InfectedBotQueue++;

				delete SpawnInfectedBotTimer[0];
				SpawnInfectedBotTimer[0] = CreateTimer(SpawnTime, Timer_Spawn_InfectedBot, 0);
			}
		}
		else
		{
			//PrintToChatAll("InfectedRealCount: %d, InfectedBotCount: %d, InfectedBotQueue: %d, g_ePluginSettings.m_iMaxSpecials: %d", InfectedRealCount, InfectedBotCount, InfectedBotQueue, g_ePluginSettings.m_iMaxSpecials);
			if ( (InfectedRealCount + InfectedBotCount + InfectedBotQueue) < g_ePluginSettings.m_iMaxSpecials )
			{
				if(bFakeClient)
				{
					SpawnTime = GetRandomFloat(g_ePluginSettings.m_fSpawnTimeMin, g_ePluginSettings.m_fSpawnTimeMax);
					if(g_ePluginSettings.m_fSpawnTimeIncreased_OnHumanInfected > 0.0)
					{
						SpawnTime = SpawnTime + (HumansOnInfected() * g_ePluginSettings.m_fSpawnTimeIncreased_OnHumanInfected);
					}

					if(SpawnTime < 3.0) SpawnTime = 3.0;
				}
				else
				{
					SpawnTime = GetRandomFloat(g_ePluginSettings.m_fCoopVersSpawnTimeMin, g_ePluginSettings.m_fCoopVersSpawnTimeMax);

					if(SpawnTime < 3.0) SpawnTime = 3.0;
				}

				InfectedBotQueue++;

				delete SpawnInfectedBotTimer[0];
				SpawnInfectedBotTimer[0] = CreateTimer(SpawnTime, Timer_Spawn_InfectedBot, 0);
			}
		}
	}
}

void CountPlayersInServer()
{
	// reset counters
	InfectedBotCount = 0;
	InfectedRealCount = 0;
	InfectedRealQueue = 0;
	AllPlayerCount = 0;

	// First we count the ammount of infected real players and bots
	for (int i=1;i<=MaxClients;i++)
	{
		if(IsClientConnected(i))
		{
			AllPlayerCount++;
		}

		if (!IsClientInGame(i)) continue;

		// Check if client is infected ...
		if (GetClientTeam(i) == TEAM_INFECTED)
		{
			// If player is a bot ...
			if (IsFakeClient(i))
			{
				if(IsPlayerAlive(i)) InfectedBotCount++;
			}
			else
			{
				if(IsPlayerAlive(i)) InfectedRealCount++;
				else InfectedRealQueue++;
			}
		}
	}
}

int CountHumanInfected()
{
	int count = 0;
	for (int i=1;i<=MaxClients;i++)
	{
		if (!IsClientInGame(i)) continue;

		if (IsFakeClient(i)) continue;

		if (GetClientTeam(i) != TEAM_INFECTED) continue;

		count ++;
	}

	return count;
}

void Event_Incap(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!client && !IsClientInGame(client) && GetClientTeam(client) != TEAM_SURVIVOR) return;

	int entity = g_iModelIndex[client];
	if( IsValidEntRef(entity) )
	{
		SetEntProp(entity, Prop_Send, "m_glowColorOverride", 180 + (0 * 256) + (0 * 65536)); //Red
	}
}

void Event_revive_success(Event event, const char[] name, bool dontBroadcast)
{
	int subject = GetClientOfUserId(event.GetInt("subject"));//被救的那位
	if(!subject && !IsClientInGame(subject) && GetClientTeam(subject) != TEAM_SURVIVOR) return;

	int entity = g_iModelIndex[subject];
	if( IsValidEntRef(entity) )
	{
		SetEntProp(entity, Prop_Send, "m_glowColorOverride", 0 + (180 * 256) + (0 * 65536)); //Green
	}
}

void Event_ledge_release(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!client && !IsClientInGame(client) && GetClientTeam(client) != TEAM_SURVIVOR) return;

	int entity = g_iModelIndex[client];
	if( IsValidEntRef(entity) )
	{
		SetEntProp(entity, Prop_Send, "m_glowColorOverride", 0 + (180 * 256) + (0 * 65536)); //Green
	}
}

void Event_GotVomit(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!client && !IsClientInGame(client) && GetClientTeam(client) != TEAM_SURVIVOR) return;

	int entity = g_iModelIndex[client];
	if( IsValidEntRef(entity) )
	{
		SetEntProp(entity, Prop_Send, "m_glowColorOverride", 155 + (0 * 256) + (180 * 65536)); //Purple

		delete RestoreColorTimer[client]; RestoreColorTimer[client] = CreateTimer(20.0, Timer_RestoreColor, client);
	}
}

Action Timer_RestoreColor(Handle timer, int client)
{
	int entity = g_iModelIndex[client];
	if( IsValidEntRef(entity) )
	{
		if(IsplayerIncap(client)) SetEntProp(entity, Prop_Send, "m_glowColorOverride", 180 + (0 * 256) + (0 * 65536)); //RGB
		else SetEntProp(entity, Prop_Send, "m_glowColorOverride", 0 + (180 * 256) + (0 * 65536)); //RGB
	}
	RestoreColorTimer[client] = null;

	return Plugin_Continue;
}

Action KickWitch_Timer(Handle timer, int ref)
{
	if( g_bCvarAllow == false) return Plugin_Continue;

	if(IsValidEntRef(ref))
	{
		int entity = EntRefToEntIndex(ref);
		bool bKill = true;
		float clientOrigin[3];
		float witchOrigin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", witchOrigin);
		for (int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i))
			{
				GetClientAbsOrigin(i, clientOrigin);
				if (GetVectorDistance(clientOrigin, witchOrigin, true) < Pow(1500.0, 2.0))
				{
					bKill = false;
					break;
				}
			}
		}

		if(bKill) AcceptEntityInput(ref, "kill"); //remove witch
		else CreateTimer(g_ePluginSettings.m_fWitchLife, KickWitch_Timer, ref,TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Continue;
}
Action Timer_ReplaceAITank(Handle timer, int tank)
{
	if( g_bCvarAllow == false)
	{
		return Plugin_Continue;
	}

	tank = GetClientOfUserId(tank);
	if (!tank || !IsClientInGame(tank) || GetClientTeam(tank) != TEAM_INFECTED || !IsPlayerAlive(tank)) 
		return Plugin_Continue;

	bool tankonfire;
	if (GetEntProp(tank, Prop_Data, "m_fFlags") & FL_ONFIRE)
		tankonfire = true;

	int Index[9];
	int IndexCount = 0;
	for (int t=1;t<=MaxClients;t++)
	{
		// We check if player is in game
		if (!IsClientInGame(t)) continue;

		// Check if client is infected ...
		if (GetClientTeam(t)!=TEAM_INFECTED) continue;

		if (IsFakeClient(t)) continue;

		if (IsPlayerTank(t)) continue;

		Index[IndexCount++] = t; //save target to index
		#if DEBUG
			PrintToChatAll("[TS] Client %i found to be valid Tank Choice", Index[IndexCount]);
		#endif
	}

	if (IndexCount > 0 )
	{
		int target = Index[GetRandomInt(0, IndexCount-1)];  // pick someone from the valid targets

		if(IsPlayerAlive(target) && !IsPlayerGhost(target))
		{
			if (g_bL4D2Version && IsPlayerJockey(target))
			{
				// WE NEED TO DISMOUNT THE JOCKEY OR ELSE BAAAAAAAAAAAAAAAD THINGS WILL HAPPEN
				CheatCommand(target, "dismount");
			}
			L4D_ReplaceWithBot(target);
		}

		if (!g_bL4D2Version) //hunter tank bug in l4d1
		{
			ChangeClientTeam(target, TEAM_SPECTATOR);
			ChangeClientTeam(target, TEAM_INFECTED);
		}

		L4D_ReplaceTank(tank, target);

		if (tankonfire)
			IgniteEntity(target, IGNITE_TIME);
	}

	return Plugin_Continue;
}

void Event_BotReplacePlayer(Event event, const char[] name, bool dontBroadcast) 
{
	int bot = GetClientOfUserId(event.GetInt("bot"));
	int playerid = event.GetInt("player");
	int player = GetClientOfUserId(playerid);

	if (bot > 0 && bot <= MaxClients && IsClientInGame(bot) && 
		player > 0 && player <= MaxClients && IsClientInGame(player)) 
	{
		g_bAdjustSIHealth[bot] = g_bAdjustSIHealth[player];
		g_bAdjustSIHealth[player] = false;

		if(L4D_HasPlayerControlledZombies() == false) //not versus
		{
			if(IsPlayerTank(bot) && IsFakeClient(bot) && !IsFakeClient(player) && playerid == lastHumanTankId)
			{
				ForcePlayerSuicide(bot);
				//KickClient(bot, "Pass Tank to AI");

				PrintHintText(player, "[TS] %T", "You don't attack survivors", player);
			}
		}
	}
}

void Event_PlayerReplaceBot(Event event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(GetEventInt(event, "bot"));
	int player = GetClientOfUserId(GetEventInt(event, "player"));
	
	if (bot > 0 && bot <= MaxClients && IsClientInGame(bot) 
		&& player > 0 && player <= MaxClients && IsClientInGame(player)) 
	{
		g_bAdjustSIHealth[player] = g_bAdjustSIHealth[bot];
		g_bAdjustSIHealth[bot] = false;
	}
}

// AI tank 給真人時不觸發
//      AI給A時: Event_PlayerTeam (Tank) -> Event_PlayerSpawn (Tank) -> Event_PlayerTeam(tank) -> Tank_Spawn (A) -> Event_PlayerSpawn (A) -> Event_PlayerReplaceBot (A repalce tank) -> Event_PlayerTeam(tank)
// 真人 tank 失去控制權給AI時不觸發, 
//      A給AI時: OnTankFrustrated (A) -> Event_PlayerTeam (Tank) -> Tank_Spawn (Tank) -> Event_PlayerSpawn (Tank) -> Event_BotReplacePlayer (tank replaces A)
// 真人 tank 轉移控制權給 其他真人時 觸發, 
//      A給B時: OnTankFrustrated (A) -> L4D_OnReplaceTank (A, B) -> Event_PlayerSpawn (B) -> L4D_OnReplaceTank(B, B) -> Event_PlayerSpawn (B)
// 使用L4D_ReplaceTank時 觸發 (無論真人或AI)
// 需檢查 tank != newtank
public void L4D_OnReplaceTank(int tank, int newtank)
{
	if(tank == newtank) return;

	g_bAdjustSIHealth[newtank] = g_bAdjustSIHealth[tank];
	g_bAdjustSIHealth[tank] = false;
}

void OnTankFrustrated(Event event, const char[] name, bool dontBroadcast)
{
	lastHumanTankId = event.GetInt("userid");
	RequestFrame(OnNextFrame_Reset, event.GetInt("userid"));
}

void OnNextFrame_Reset(int userid)
{
	lastHumanTankId = 0;

	/*int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) return;

	g_bAdjustSIHealth[client] = false;*/
}

public Action L4D_OnEnterGhostStatePre(int client)
{
	if(g_bCvarAllow == false) return Plugin_Continue;

	if (g_iCurrentMode != 2 && lastHumanTankId && GetClientUserId(client) == lastHumanTankId)
	{
		lastHumanTankId = 0;
		L4D_State_Transition(client, STATE_DEATH_ANIM);
		
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public void L4D_OnEnterGhostState(int client)
{
	if(g_bCvarAllow == false) return;

	if(L4D_HasPlayerControlledZombies() == false)
	{
		DeleteLight(client);
		if(g_ePluginSettings.m_bCoopVersusHumanGhost)
			TurnFlashlightOn(client);
		else
			CreateTimer(0.2, Timer_InfectedKillSelf, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

// This event serves to make sure the bots spawn at the start of the finale event. The director disallows spawning until the survivors have started the event, so this was
// definitely needed.
void evtFinaleStart(Event event, const char[] name, bool dontBroadcast)
{
	if(g_bFinaleStarted) return;

	g_bFinaleStarted = true;
	CreateTimer(1.0, CheckIfBotsNeededLater, 2, TIMER_FLAG_NO_MAPCHANGE);
}

void Event_PlayerDisconnect(Event event, char[] name, bool bDontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client))
	{
		hudDisabled[client] = false;
	}
}

int BotTypeNeeded()
{
	// current count ...
	for (int i = 0; i < NUM_TYPES_INFECTED_MAX; i++)
		g_iSpawnCounts[i] = 0;

	for (int i=1;i<=MaxClients;i++)
	{
		// if player is connected and ingame ...
		if (IsClientInGame(i))
		{
			// if player is on infected's team
			if (GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i))
			{
				// We count depending on class ...
				if (IsPlayerSmoker(i))
					g_iSpawnCounts[SI_SMOKER]++;
				else if (IsPlayerBoomer(i))
					g_iSpawnCounts[SI_BOOMER]++;
				else if (IsPlayerHunter(i))
					g_iSpawnCounts[SI_HUNTER]++;
				else if (IsPlayerTank(i))
					g_iSpawnCounts[SI_TANK]++;
				else if (g_bL4D2Version && IsPlayerSpitter(i))
					g_iSpawnCounts[SI_SPITTER]++;
				else if (g_bL4D2Version && IsPlayerJockey(i))
					g_iSpawnCounts[SI_JOCKEY]++;
				else if (g_bL4D2Version && IsPlayerCharger(i))
					g_iSpawnCounts[SI_CHARGER]++;
			}
		}
	}

	if ( ( (g_bFinaleStarted && g_ePluginSettings.m_bTankSpawnFinal) || !g_bFinaleStarted ) &&
		g_iSpawnCounts[SI_TANK] < g_ePluginSettings.m_iTankLimit &&
		GetRandomInt(1, 100) <= g_ePluginSettings.m_iTankSpawnProbability) 
	{
		return 7;
	}
	else //spawn other S.I.
	{
		int generate;
		for(int i = 1; i <= 3; i++)
		{
			generate = GenerateIndex()+1;
			if(generate > 0) break;
		}

		return generate;
	}
}

Action Timer_Spawn_InfectedBot(Handle timer, int index)
{
	// If round has ended, we ignore this request ...
	if (g_bCvarAllow == false || g_bHasRoundEnded || !g_bLeftSaveRoom )
	{
		if(InfectedBotQueue > 0) InfectedBotQueue--;

		SpawnInfectedBotTimer[index] = null;
		return Plugin_Continue;
	}

	//PrintToChatAll("[TS] Spawn_InfectedBot(Handle timer)");

	if (g_ePluginSettings.m_bCoordination && !g_bInitialSpawn && g_bIsCoordination == false)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(i != index && SpawnInfectedBotTimer[i] != null)
			{
				if(InfectedBotQueue > 0) InfectedBotQueue--;

				SpawnInfectedBotTimer[index] = null;
				return Plugin_Continue;
			}
		}

		g_bIsCoordination = true;
	}

	// First we get the infected count
	if (L4D_HasPlayerControlledZombies())
	{
		if(g_ePluginSettings.m_bSpawnDisableBots)
		{
			if(InfectedBotQueue > 0) InfectedBotQueue--;

			SpawnInfectedBotTimer[index] = null;
			return Plugin_Continue;
		}

		CountPlayersInServer();

		// PrintToChatAll("InfectedRealCount: %d, InfectedRealQueue: %d, InfectedBotCount: %d, g_ePluginSettings.m_iMaxSpecials: %d", InfectedRealCount, InfectedRealQueue, InfectedBotCount, g_ePluginSettings.m_iMaxSpecials);
		if ( InfectedRealCount + InfectedRealQueue + InfectedBotCount >= g_ePluginSettings.m_iMaxSpecials ||
			AllPlayerCount >= MaxClients)
		{
			#if DEBUG
				LogMessage("team is already full, don't spawn a bot");
			#endif
			InfectedBotQueue = 0;
			g_bIsCoordination = false;

			SpawnInfectedBotTimer[index] = null;
			return Plugin_Continue;
		}
	}
	else
	{
		CountPlayersInServer();

		//PrintToChatAll("InfectedRealCount: %d, InfectedBotCount: %d, g_ePluginSettings.m_iMaxSpecials: %d", InfectedRealCount, InfectedBotCount, g_ePluginSettings.m_iMaxSpecials);
		if ( InfectedRealCount + InfectedBotCount >= g_ePluginSettings.m_iMaxSpecials ||
			AllPlayerCount >= MaxClients )
		{
			#if DEBUG
				LogMessage("team is already full, don't spawn a bot");
			#endif
			InfectedBotQueue = 0;
			g_bIsCoordination = false;

			SpawnInfectedBotTimer[index] = null;
			return Plugin_Continue;
		}
	}

	// If there is a tank on the field and l4d_infectedbots_spawns_disable_tank is set to 1, the plugin will check for
	// any tanks on the field
	if (g_ePluginSettings.m_bTankDisableSpawn)
	{
		for (int i=1;i<=MaxClients;i++)
		{
			// We check if player is in game
			if (!IsClientInGame(i)) continue;

			// Check if client is infected ...
			if (GetClientTeam(i)==TEAM_INFECTED)
			{
				// If player is a tank
				if (IsPlayerTank(i) && IsPlayerAlive(i) && ( g_iCurrentMode != 1 || !IsFakeClient(i) || (IsFakeClient(i) && g_bAngry[i]) ) )
				{
					if(InfectedBotQueue>0) InfectedBotQueue--;

					SpawnInfectedBotTimer[index] = null;
					return Plugin_Continue;
				}
			}
		}

	}

	// Official Cvar: director_no_specials is 1 => Disable PZ spawns
	if(director_no_specials_bool == true)
	{
		PrintToServer("[TS] Couldn't spawn due to director_no_specials 1.");
		CreateTimer(20.0, CheckIfBotsNeededLater, 0, TIMER_FLAG_NO_MAPCHANGE);

		if(InfectedBotQueue > 0) InfectedBotQueue--;
		
		SpawnInfectedBotTimer[index] = null;
		return Plugin_Continue;
	}

	int human = 0;
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i)) // player is connected and is not fake and it's in game ...
		{
			// If player is on infected's team and is dead ..
			if (GetClientTeam(i) == TEAM_INFECTED)
			{
				if (IsPlayerGhost(i))
				{
					continue;
				}
				else if (!IsPlayerAlive(i) && L4D_HasPlayerControlledZombies()) // if player is just dead
				{
					continue;
				}
				else if (!IsPlayerAlive(i) && respawnDelay[i] > 0)
				{
					continue;
				}
				else if (!IsPlayerAlive(i) && respawnDelay[i] <= 0 && human == 0)
				{
					human = i;
					break;
				}
			}
		}
	}

	if(g_ePluginSettings.m_bSpawnDisableBots && L4D_HasPlayerControlledZombies() == false && human == 0)
	{
		if(InfectedBotQueue > 0) InfectedBotQueue--;

		SpawnInfectedBotTimer[index] = null;
		return Plugin_Continue;
	}

	int anyclient;
	if(g_ePluginSettings.m_iSpawnWhereMethod == 0) anyclient = GetAheadSurvivor();
	else anyclient = GetRandomAliveSurvivor();
	if(anyclient == 0)
	{
		PrintToServer("[TS] Couldn't find a valid alive survivor to spawn S.I. at this moment.");
		CreateTimer(1.0, CheckIfBotsNeededLater, g_bInitialSpawn ? 2: g_bIsCoordination? 1: 0, TIMER_FLAG_NO_MAPCHANGE);

		if(InfectedBotQueue > 0) InfectedBotQueue--;
		
		SpawnInfectedBotTimer[index] = null;
		return Plugin_Continue;
	}

	int bot_type = BotTypeNeeded(), bot;
	bool bSpawnSuccessful = false;
	float vecPos[3];

	switch (bot_type)
	{
		case 0: // Nothing
		{
			bSpawnSuccessful = false;
		}
		case 1: // Smoker
		{
			if(L4D_GetRandomPZSpawnPosition(anyclient,ZOMBIECLASS_SMOKER,ZOMBIESPAWN_Attempts,vecPos) == true)
			{
				if(human > 0)
				{
					L4D_State_Transition(human, STATE_OBSERVER_MODE);
					L4D_BecomeGhost(human);
					L4D_SetClass(human, ZOMBIECLASS_SMOKER);
				}
				else
				{
					bot = SDKCall(hCreateSmoker, "Smoker Bot");
					if (IsValidClient(bot))
					{
						bSpawnSuccessful = true;
					}
				}
			}
			else
			{
				PrintToServer("[TS] Couldn't find a Smoker Spawn position in %d tries",ZOMBIESPAWN_Attempts);
			}

		}
		case 2: // Boomer
		{
			if(L4D_GetRandomPZSpawnPosition(anyclient,ZOMBIECLASS_BOOMER,ZOMBIESPAWN_Attempts,vecPos) == true)
			{
				if(human > 0)
				{
					L4D_State_Transition(human, STATE_OBSERVER_MODE);
					L4D_BecomeGhost(human);
					L4D_SetClass(human, ZOMBIECLASS_BOOMER);
				}
				else
				{
					bot = SDKCall(hCreateBoomer, "Boomer Bot");
					if (IsValidClient(bot))
					{
						bSpawnSuccessful = true;
					}
				}
			}
			else
			{
				PrintToServer("[TS] Couldn't find a Boomer Spawn position in %d tries",ZOMBIESPAWN_Attempts);
			}

		}
		case 3: // Hunter
		{
			if(L4D_GetRandomPZSpawnPosition(anyclient,ZOMBIECLASS_HUNTER,ZOMBIESPAWN_Attempts,vecPos) == true)
			{
				if(human > 0)
				{
					L4D_State_Transition(human, STATE_OBSERVER_MODE);
					L4D_BecomeGhost(human);
					L4D_SetClass(human, ZOMBIECLASS_HUNTER);
				}
				else
				{
					bot = SDKCall(hCreateHunter, "Hunter Bot");
					if (IsValidClient(bot))
					{
						bSpawnSuccessful = true;
					}
				}
			}
			else
			{
				PrintToServer("[TS] Couldn't find a Hunter Spawn position in %d tries",ZOMBIESPAWN_Attempts);
			}
		}
		case 4: // Spitter
		{
			if(L4D_GetRandomPZSpawnPosition(anyclient,ZOMBIECLASS_SPITTER,ZOMBIESPAWN_Attempts,vecPos) == true)
			{
				if(human > 0)
				{
					L4D_State_Transition(human, STATE_OBSERVER_MODE);
					L4D_BecomeGhost(human);
					L4D_SetClass(human, ZOMBIECLASS_SPITTER);
				}
				else
				{
					bot = SDKCall(hCreateSpitter, "Spitter Bot");
					if (IsValidClient(bot))
					{
						bSpawnSuccessful = true;
					}
				}
			}
			else
			{
				PrintToServer("[TS] Couldn't find a Spitter Spawn position in %d tries",ZOMBIESPAWN_Attempts);
			}
		}
		case 5: // Jockey
		{
			if(L4D_GetRandomPZSpawnPosition(anyclient,ZOMBIECLASS_JOCKEY,ZOMBIESPAWN_Attempts,vecPos) == true)
			{
				if(human > 0)
				{
					L4D_State_Transition(human, STATE_OBSERVER_MODE);
					L4D_BecomeGhost(human);
					L4D_SetClass(human, ZOMBIECLASS_JOCKEY);
				}
				else
				{
					bot = SDKCall(hCreateJockey, "Jockey Bot");
					if (IsValidClient(bot))
					{
						bSpawnSuccessful = true;
					}
				}
			}
			else
			{
				PrintToServer("[TS] Couldn't find a Jockey Spawn position in %d tries",ZOMBIESPAWN_Attempts);
			}
		}
		case 6: // Charger
		{
			if(L4D_GetRandomPZSpawnPosition(anyclient,ZOMBIECLASS_CHARGER,ZOMBIESPAWN_Attempts,vecPos) == true)
			{
				if(human > 0)
				{
					L4D_State_Transition(human, STATE_OBSERVER_MODE);
					L4D_BecomeGhost(human);
					L4D_SetClass(human, ZOMBIECLASS_CHARGER);
				}
				else
				{
					bot = SDKCall(hCreateCharger, "Charger Bot");
					if (IsValidClient(bot))
					{
						bSpawnSuccessful = true;
					}
				}
			}
			else
			{
				PrintToServer("[TS] Couldn't find a Charger Spawn position in %d tries",ZOMBIESPAWN_Attempts);
			}
		}
		case 7: // Tank
		{
			if(L4D_GetRandomPZSpawnPosition(anyclient,ZOMBIECLASS_TANK,ZOMBIESPAWN_Attempts,vecPos) == true)
			{
				if(human > 0)
				{
					L4D_State_Transition(human, STATE_OBSERVER_MODE);
					L4D_BecomeGhost(human);
					L4D_SetClass(human, ZOMBIECLASS_TANK);
				}
				else
				{
					bot = SDKCall(hCreateTank, "Tank Bot");
					if (IsValidClient(bot))
					{
						bSpawnSuccessful = true;
					}
				}
			}
			else
			{
				PrintToServer("[TS] Couldn't find a Tank Spawn position in %d tries",ZOMBIESPAWN_Attempts);
			}
		}
	}

	if(human > 0)
	{
		if(IsPlayerAlive(human))
		{
			bSpawnSuccessful = true;
			if(bot_type == 7 || g_ePluginSettings.m_bCoopVersusHumanGhost == false)
			{
				TeleportEntity(human, vecPos, NULL_VECTOR, NULL_VECTOR);	
				L4D_MaterializeFromGhost(human);
			}
		}

		if(!g_bIsCoordination) 
		{
			if(bSpawnSuccessful)
			{
				CreateTimer(0.0, CheckIfBotsNeededLater, 1, TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				CreateTimer(1.0, CheckIfBotsNeededLater, 0, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	else
	{
		if(bSpawnSuccessful)
		{
			ChangeClientTeam(bot, TEAM_INFECTED);
			SetEntProp(bot, Prop_Send, "m_usSolidFlags", 16);
			SetEntProp(bot, Prop_Send, "movetype", 2);
			SetEntProp(bot, Prop_Send, "deadflag", 0);
			SetEntProp(bot, Prop_Send, "m_lifeState", 0);
			SetEntProp(bot, Prop_Send, "m_iObserverMode", 0);
			SetEntProp(bot, Prop_Send, "m_iPlayerState", 0);
			SetEntProp(bot, Prop_Send, "m_zombieState", 0);
			DispatchSpawn(bot);
			ActivateEntity(bot);
			TeleportEntity(bot, vecPos, NULL_VECTOR, NULL_VECTOR); //移動到相同位置
		}
		else
		{
			//LogError("spawn failed");
		}

		if(!g_bIsCoordination) 
		{
			if(bSpawnSuccessful)
			{
				CreateTimer(0.05, CheckIfBotsNeededLater, 1, TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				CreateTimer(0.1, CheckIfBotsNeededLater, 0, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}

	// Debug print
	#if DEBUG
		PrintToChatAll("[TS] Spawning an infected bot. Type = %i ", bot_type);
	#endif

	// We decrement the infected queue
	if(InfectedBotQueue>0) InfectedBotQueue--;

	SpawnInfectedBotTimer[index] = null;

	if(g_bIsCoordination)
	{
		if(bSpawnSuccessful)
		{
			if(g_ePluginSettings.m_bSpawnSameFrame) Timer_Spawn_InfectedBot(null, 0);
			else CreateTimer(0.1, Timer_Spawn_InfectedBot, _, TIMER_FLAG_NO_MAPCHANGE);
		}	
		else
		{
			CreateTimer(5.0, Timer_Spawn_InfectedBot, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	return Plugin_Continue;
}

Action kickbot(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && IsFakeClient(client) && !IsClientInKickQueue(client) )
	{
		KickClient(client);
	}

	return Plugin_Continue;
}

bool IsPlayerGhost (int client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost"))
		return true;
	return false;
}

bool IsPlayerSmoker (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_SMOKER)
		return true;
	return false;
}

bool IsPlayerHunter (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_HUNTER)
		return true;
	return false;
}

bool IsPlayerBoomer (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_BOOMER)
		return true;
	return false;
}

bool IsPlayerSpitter (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_SPITTER)
		return true;
	return false;
}

bool IsPlayerJockey (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_JOCKEY)
		return true;
	return false;
}

bool IsPlayerCharger (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_CHARGER)
		return true;
	return false;
}

bool IsPlayerTank (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_TANK)
		return true;
	return false;
}

int HumansOnInfected ()
{
	int TotalHumans;
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && !IsFakeClient(i))
			TotalHumans++;
	}
	return TotalHumans;
}

bool RealPlayersOnInfected ()
{
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
			if (GetClientTeam(i) == TEAM_INFECTED)
				return true;
		}
	return false;
}

bool AreTherePlayersWhoAreNotTanks ()
{
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if (GetClientTeam(i) == TEAM_INFECTED)
			{
				if (!IsPlayerTank(i) || IsPlayerTank(i) && !IsPlayerAlive(i))
					return true;
			}
		}
	}
	return false;
}

int  FindBotToTakeOver()
{
	// First we find a survivor bot
	for (int i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;

		// Check if client is survivor ...
		if (GetClientTeam(i) == TEAM_SURVIVOR)
		{
			// If player is a bot and is alive...
			if (IsFakeClient(i) && IsPlayerAlive(i))
			{
				return i;
			}
		}
	}
	return 0;
}

int Menu_InfHUDPanel(Menu menu, MenuAction action, int param1, int param2) { return 0; }

Action TimerAnnounce(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if (client && IsClientInGame(client))
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			// Show welcoming instruction message to client
			PrintHintText(client, "%t","Hud INFO", PLUGIN_VERSION);

			// This client now knows about the mod, don't tell them again for the rest of the game.
			clientGreeted[client] = 1;
		}
	}

	return Plugin_Continue;
}

Action TimerAnnounce2(Handle timer, int client)
{
	int iGameMode = g_iCurrentMode;
	if(iGameMode == 3) iGameMode = 4;
	if(iGameMode & g_iZSDisableGamemode)
	{
		return Plugin_Continue;
	}

	client = GetClientOfUserId(client);
	if (IsClientInGame(client) && GetClientTeam(client) == TEAM_INFECTED && IsPlayerAlive(client) && !IsPlayerGhost(client))
	{
		CPrintToChat(client, "[{olive}TS{default}] %T","sm_zss",client);
	}

	return Plugin_Continue;
}

void queueHUDUpdate()
{
	// Don't bother with infected HUD updates if the round has ended.
	if (!roundInProgress) return;

	ShowInfectedHUD();
}

Action showInfHUD(Handle timer)
{
	if( g_bCvarAllow == false)
	{
		infHUDTimer = null;
		return Plugin_Stop;
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (respawnDelay[i] > 0)
		{
			//PrintToChatAll("respawnDelay[%d] = %d", i, respawnDelay[i]);
			respawnDelay[i]--;
		}
	}

	if(L4D_HasPlayerControlledZombies() == false)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i))
			{
				if ( (GetClientTeam(i) == TEAM_INFECTED))
				{
					if(IsPlayerTank(i))
					{
						int fus = 100 - GetFrustration(i);
						if(fus <= 75)
						{
							PrintHintText(i, "[TS] Tank Control: %d%%%%", fus);
						}
						
						if(fus <= 0)
						{
							PrintHintText(i, "[TS] %T", "You don't attack survivors", i);

							Event hFakeEvent = CreateEvent("tank_frustrated");
							hFakeEvent.SetInt("userid", GetClientUserId(i));
							FireEvent(hFakeEvent);
							
							L4D_ReplaceWithBot(i);
							continue;
						}
					}
				}
			}
		}
	}

	ShowInfectedHUD();
	return Plugin_Continue;
}

Action Timer_CheckSpawn(Handle timer)
{
	if( g_bCvarAllow == false)
	{
		g_hCheckSpawnTimer = null;
		return Plugin_Stop;
	}

	int iInfectedBotAliveCount, iInfectedRealAliveCount, iInfectedRealDeathQueue;
	for (int i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;

		// Check if client is infected ...
		if (GetClientTeam(i) == TEAM_INFECTED)
		{
			// If player is a bot ...
			if (IsFakeClient(i))
			{
				if( IsPlayerAlive(i) ) 
					iInfectedBotAliveCount++;
			}
			else
			{
				if(IsPlayerAlive(i)) iInfectedRealAliveCount++;
				else iInfectedRealDeathQueue++;
			}
		}
	}

	/*int count;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(SpawnInfectedBotTimer[i] != null)
		{
			PrintToChatAll("SpawnInfectedBotTimer[%d] != null", i);
			count++;
		}
	}
	PrintToChatAll("BotAlive: %d, RealAlive: %d, RealDeath: %d, spawntimers: %d, g_ePluginSettings.m_iMaxSpecials: %d", 
		iInfectedBotAliveCount, iInfectedRealAliveCount, iInfectedRealDeathQueue, count, g_ePluginSettings.m_iMaxSpecials);
	*/

	if (L4D_HasPlayerControlledZombies())
	{
		/**
		 * 刪除多餘的Spawn Bot Timer
		 * */
		int spawntimers = 0;
		for(int index = 1; index <= MaxClients; index++)
		{
			if(SpawnInfectedBotTimer[index] != null)
			{
				spawntimers++;
				if(iInfectedBotAliveCount + iInfectedRealAliveCount + iInfectedRealDeathQueue + spawntimers > g_ePluginSettings.m_iMaxSpecials) 
				{
					//PrintToChatAll("----delete----");
					if(InfectedBotQueue > 0) InfectedBotQueue--;
					delete SpawnInfectedBotTimer[index];
				}
			}
		}
	}
	else
	{
		int spawntimers = 0;
		for(int index = 1; index <= MaxClients; index++)
		{
			if(SpawnInfectedBotTimer[index] != null)
			{
				spawntimers++;
				if(iInfectedBotAliveCount + iInfectedRealAliveCount + spawntimers > g_ePluginSettings.m_iMaxSpecials) 
				{
					//PrintToChatAll("----delete----");
					if(InfectedBotQueue > 0) InfectedBotQueue--;
					delete SpawnInfectedBotTimer[index];
				}
			}
		}
	}


	return Plugin_Continue;
}

Action Command_infhud(int client, int args)
{
	if( g_bCvarAllow == false) return Plugin_Handled;
	if( client == 0 || IsFakeClient(client)) return Plugin_Handled;

	if (g_bInfHUD)
	{
		if (!hudDisabled[client])
		{
			CPrintToChat(client, "%T","Hud Disable",client);
			hudDisabled[client] = true;
		}
		else
		{
			CPrintToChat(client, "%T","Hud Enable",client);
			hudDisabled[client] = false;
		}
	}
	else
	{
		// Server admin has disabled Infected HUD server-wide
		CPrintToChat(client, "%T","Infected HUD is currently DISABLED",client);
	}

	return Plugin_Handled;
}

void ShowInfectedHUD()
{
	if (!g_bInfHUD || IsVoteInProgress())
	{
		return;
	}

	int iHP;
	char iClass[100],lineBuf[100],iStatus[25];

	// Display information panel to infected clients
	pInfHUD = new Panel(GetMenuStyleHandle(MenuStyle_Radio));
	char information[32];
	if (L4D_HasPlayerControlledZombies())
		Format(information, sizeof(information), "INFECTED BOTS(%s):", PLUGIN_VERSION);
	else
		Format(information, sizeof(information), "INFECTED TEAM(%s):", PLUGIN_VERSION);

	pInfHUD.SetTitle(information);
	pInfHUD.DrawText(" ");

	if (roundInProgress)
	{
		#if !DEBUG
		// Loop through infected players and show their status
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i)) continue;
			if (GetClientTeam(i) == TEAM_INFECTED)
			{
				// Work out what they're playing as
				if (IsPlayerHunter(i))
				{
					strcopy(iClass, sizeof(iClass), "Hunter");
					iHP = GetClientHealth(i);
				}
				else if (IsPlayerSmoker(i))
				{
					strcopy(iClass, sizeof(iClass), "Smoker");
					iHP = GetClientHealth(i);
				}
				else if (IsPlayerBoomer(i))
				{
					strcopy(iClass, sizeof(iClass), "Boomer");
					iHP = GetClientHealth(i);
				}
				else if (g_bL4D2Version && IsPlayerSpitter(i))
				{
					strcopy(iClass, sizeof(iClass), "Spitter");
					iHP = GetClientHealth(i);
				}
				else if (g_bL4D2Version && IsPlayerJockey(i))
				{
					strcopy(iClass, sizeof(iClass), "Jockey");
					iHP = GetClientHealth(i);
				}
				else if (g_bL4D2Version && IsPlayerCharger(i))
				{
					strcopy(iClass, sizeof(iClass), "Charger");
					iHP = GetClientHealth(i);
				}
				else if (IsPlayerTank(i))
				{
					strcopy(iClass, sizeof(iClass), "Tank");
					iHP = GetClientHealth(i);
				}

				if (IsPlayerAlive(i))
				{
					// Check to see if they are a ghost or not
					if (IsPlayerGhost(i))
					{
						strcopy(iStatus, sizeof(iStatus), "GHOST");
					}
					else
					{
						if(IsPlayerTank(i)) 
						{
							if(L4D_IsPlayerIncapacitated(i))
							{
								Format(iStatus, sizeof(iStatus), "DEAD");
							}
							else
							{
								if(!IsFakeClient(i))
								{
									Format(iStatus, sizeof(iStatus), "%i - %d%%", iHP,100-GetFrustration(i));
								}
								else
								{
									Format(iStatus, sizeof(iStatus), "%i", iHP);
								}
							}
						}
						else Format(iStatus, sizeof(iStatus), "%i", iHP);
					}
				}
				else
				{
					if (respawnDelay[i] > 0)
					{
						Format(iStatus, sizeof(iStatus), "DEAD (%i)", respawnDelay[i]);
						strcopy(iClass, sizeof(iClass), "");
						// As a failsafe if they're dead/waiting set HP to 0
						iHP = 0;
					}
					else if (respawnDelay[i] == 0 && L4D_HasPlayerControlledZombies() == false)
					{
						Format(iStatus, sizeof(iStatus), "READY");
						strcopy(iClass, sizeof(iClass), "");
						// As a failsafe if they're dead/waiting set HP to 0
						iHP = 0;
					}
					else
					{
						Format(iStatus, sizeof(iStatus), "DEAD");
						strcopy(iClass, sizeof(iClass), "");
						// As a failsafe if they're dead/waiting set HP to 0
						iHP = 0;
					}
				}

				if (IsFakeClient(i))
				{
					Format(lineBuf, sizeof(lineBuf), "%N-%s", i, iStatus);
					pInfHUD.DrawText(lineBuf);
				}
				else
				{
					Format(lineBuf, sizeof(lineBuf), "%N-%s-%s", i, iClass, iStatus);
					pInfHUD.DrawText(lineBuf);
				}
			}
		}

		pInfHUD.DrawItem(" ",ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
		pInfHUD.DrawText("Close HUD: !infhud");
		#endif

		#if DEBUG
		for(int i = 0; i <= MaxClients; i++)
		{
			if(SpawnInfectedBotTimer[i] != null)
			{
				Format(lineBuf, sizeof(lineBuf), "%d - Timer Cout Downing", i);
				pInfHUD.DrawItem(lineBuf);
			}
		}
		#endif
	}

	// Output the current team status to all infected clients
	// Technically the below is a bit of a kludge but we can't be 100% sure that a client status doesn't change
	// between building the panel and displaying it.
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if ( GetClientTeam(i) == TEAM_INFECTED /*|| GetClientTeam(i) == TEAM_SPECTATOR*/ )
			{
				if( hudDisabled[i] == false && (GetClientMenu(i) == MenuSource_RawPanel || GetClientMenu(i) == MenuSource_None))
				{
					pInfHUD.Send(i, Menu_InfHUDPanel, 3);
				}
			}
		}
	}
	delete pInfHUD;
}

void evtTeamSwitch(Event event, const char[] name, bool dontBroadcast)
{
	// Check to see if player joined infected team and if so refresh the HUD
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client)
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			queueHUDUpdate();
		}
		else
		{
			// If player teamswitched to survivor, remove the HUD from their screen
			// immediately to stop them getting an advantage
			if (GetClientMenu(client) == MenuSource_RawPanel)
			{
				CancelClientMenu(client);
			}
		}
	}
}

void evtInfectedSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client))
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			respawnDelay[client] = 0;
			queueHUDUpdate();
			// If player joins server and doesn't have to wait to spawn they might not see the announce
			// until they next die (and have to wait).  As a fallback we check when they spawn if they've
			// already seen it or not.
			if (!clientGreeted[client] && g_bAnnounce)
			{
				CreateTimer(3.0, TimerAnnounce, userid, TIMER_FLAG_NO_MAPCHANGE);
			}
			if(!IsFakeClient(client) && IsPlayerAlive(client))
			{
				CreateTimer(1.0, TimerAnnounce2, userid, TIMER_FLAG_NO_MAPCHANGE);
				fPlayerSpawnEngineTime[client] = GetEngineTime();
			}

			// 0.1秒後設置Tank或特感血量
			delete g_hPlayerSpawnTimer[client];
			g_hPlayerSpawnTimer[client] = CreateTimer(0.1, Timer_SetHealth, client);

			if(IsPlayerTank(client))
			{
				if(IsFakeClient(client))
				{
					g_bAngry[client] = false;

					CreateTimer(1.0, Timer_CheckAngry, userid, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}

Action Timer_SetHealth(Handle timer, any client)
{
	g_hPlayerSpawnTimer[client] = null;

	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_INFECTED && IsPlayerAlive(client))
	{	
		if (IsPlayerTank(client) && g_ePluginSettings.m_iTankHealth > 0)
		{
			if(!g_bAdjustSIHealth[client]) SetEntProp(client, Prop_Data, "m_iHealth", g_ePluginSettings.m_iTankHealth);
			SetEntProp(client, Prop_Data, "m_iMaxHealth", g_ePluginSettings.m_iTankHealth);
		}
		else if(IsPlayerSmoker(client) && g_ePluginSettings.m_iSIHealth[SI_SMOKER] > 0)
		{
			if(!g_bAdjustSIHealth[client]) SetEntProp(client, Prop_Data, "m_iHealth", g_ePluginSettings.m_iSIHealth[SI_SMOKER]);
			SetEntProp(client, Prop_Data, "m_iMaxHealth", g_ePluginSettings.m_iSIHealth[SI_SMOKER]);
		}
		else if(IsPlayerBoomer(client) && g_ePluginSettings.m_iSIHealth[SI_BOOMER] > 0)
		{
			if(!g_bAdjustSIHealth[client]) SetEntProp(client, Prop_Data, "m_iHealth", g_ePluginSettings.m_iSIHealth[SI_BOOMER]);
			SetEntProp(client, Prop_Data, "m_iMaxHealth", g_ePluginSettings.m_iSIHealth[SI_BOOMER]);
		}
		else if(IsPlayerHunter(client) && g_ePluginSettings.m_iSIHealth[SI_HUNTER] > 0)
		{
			if(!g_bAdjustSIHealth[client]) SetEntProp(client, Prop_Data, "m_iHealth", g_ePluginSettings.m_iSIHealth[SI_HUNTER]);
			SetEntProp(client, Prop_Data, "m_iMaxHealth", g_ePluginSettings.m_iSIHealth[SI_HUNTER]);
		}
		else if(g_bL4D2Version && IsPlayerSpitter(client) && g_ePluginSettings.m_iSIHealth[SI_SPITTER] > 0)
		{
			if(!g_bAdjustSIHealth[client]) SetEntProp(client, Prop_Data, "m_iHealth", g_ePluginSettings.m_iSIHealth[SI_SPITTER]);
			SetEntProp(client, Prop_Data, "m_iMaxHealth", g_ePluginSettings.m_iSIHealth[SI_SPITTER]);
		}
		else if(g_bL4D2Version && IsPlayerJockey(client) && g_ePluginSettings.m_iSIHealth[SI_JOCKEY] > 0)
		{
			if(!g_bAdjustSIHealth[client]) SetEntProp(client, Prop_Data, "m_iHealth", g_ePluginSettings.m_iSIHealth[SI_JOCKEY]);
			SetEntProp(client, Prop_Data, "m_iMaxHealth", g_ePluginSettings.m_iSIHealth[SI_JOCKEY]);
		}
		else if(g_bL4D2Version && IsPlayerCharger(client) && g_ePluginSettings.m_iSIHealth[SI_CHARGER] > 0)
		{
			if(!g_bAdjustSIHealth[client]) SetEntProp(client, Prop_Data, "m_iHealth", g_ePluginSettings.m_iSIHealth[SI_CHARGER]);
			SetEntProp(client, Prop_Data, "m_iMaxHealth", g_ePluginSettings.m_iSIHealth[SI_CHARGER]);
		}

		g_bAdjustSIHealth[client] = true;
	}

	return Plugin_Continue;
}

Action Timer_CheckAngry(Handle timer, int UserId)
{
	int client = GetClientOfUserId(UserId);
	if (client && IsClientInGame(client) && 
		IsFakeClient(client) && 
		GetClientTeam(client) == TEAM_INFECTED && 
		IsPlayerAlive(client) && 
		IsPlayerTank(client))
	{
		if (!L4D_IsPlayerGhost(client) && !bIsTankIdle(client))
		{
			g_bAngry[client] = true;
			return Plugin_Stop;
		}

		return Plugin_Continue;
	}

	return Plugin_Stop;
}

void evtInfectedDeath(Event event, const char[] name, bool dontBroadcast)
{
	// Infected player died, so refresh the HUD
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client))
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			queueHUDUpdate();

			if(!IsFakeClient(client) && L4D_HasPlayerControlledZombies() == false)
			{
				CleanUpStateAndMusic(client);
			}
		}
	}
}

void evtInfectedHurt(Event event, const char[] name, bool dontBroadcast)
{
	// The life of a regular special infected is pretty transient, they won't take many shots before they
	// are dead (unlike the survivors) so we can afford to refresh the HUD reasonably quickly when they take damage.
	// The exception to this is the Tank - with 5000 health the survivors could be shooting constantly at it
	// resulting in constant HUD refreshes which is not efficient.  So, we check to see if the entity being
	// shot is a Tank or not and adjust the non-repeating timer accordingly.

	// Don't bother with infected HUD update if the round has ended
	if (!roundInProgress) return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));

	delete FightOrDieTimer[client];
	FightOrDieTimer[client] = CreateTimer(g_ePluginSettings.m_fSILife, DisposeOfCowards, client);

	delete FightOrDieTimer[attacker];
	FightOrDieTimer[attacker] = CreateTimer(g_ePluginSettings.m_fSILife, DisposeOfCowards, attacker);
}

void Event_GhostSpawnTime(Event event, const char[] name, bool dontBroadcast)
{
	// Don't bother with infected HUD update if the round has ended
	if (!roundInProgress) return;

	// Store this players respawn time in an array so we can present it to other clients
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && !IsFakeClient(client))
	{
		g_bAdjustSIHealth[client] = false;

		if (L4D_HasPlayerControlledZombies())
		{
			int spawntime = event.GetInt("spawntime");
			int humaninfecteds = CountHumanInfected();
			if(humaninfecteds == 0)
			{
				respawnDelay[client] = spawntime;
				return;
			}

			if(g_bL4D2Version)
			{
				float modifyTime = GetRandomFloat(g_fCvar_z_ghost_delay_min, g_fCvar_z_ghost_delay_max);
				if(humaninfecteds >= 4) humaninfecteds = 4;
				int maxinfectedslots = g_ePluginSettings.m_iMaxSpecials;
				if(maxinfectedslots >= 4) maxinfectedslots = 4;
				
				modifyTime = modifyTime * (float(humaninfecteds) / maxinfectedslots);
				respawnDelay[client] = RoundFloat(modifyTime);

				L4D_SetPlayerSpawnTime(client, float(respawnDelay[client]), true);
			}
		}
	}
}

void CheatCommand(int client,  char[] command, char[] arguments = "")
{
	int userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	if(IsClientInGame(client)) SetUserFlagBits(client, userFlags);
}


void TurnFlashlightOn(int client)
{
	if (L4D_HasPlayerControlledZombies()) return;
	if (!IsClientInGame(client)) return;
	if (GetClientTeam(client) != TEAM_INFECTED) return;
	if (!IsPlayerAlive(client)) return;
	if (IsFakeClient(client)) return;

	SetEntProp(client, Prop_Send, "m_iTeamNum", 2);
	SDKCall(hFlashLightTurnOn, client);
	SetEntProp(client, Prop_Send, "m_iTeamNum", 3);

	if(g_ePluginSettings.m_bCoopVersusHumanLight && !IsPlayerGhost(client))
	{
		DeleteLight(client);

		// Declares
		int entity;
		float vOrigin[3], vAngles[3];

		// Position light
		vOrigin = view_as<float>(  { 0.5, -1.5, 50.0 });
		vAngles = view_as<float>(  { -45.0, -45.0, 90.0 });

		// Light_Dynamic
		entity = MakeLightDynamic(vOrigin, vAngles, client);
		if(entity == 0) return;

		g_iLightIndex[client] = EntIndexToEntRef(entity);

		if( g_iClientIndex[client] == GetClientUserId(client) )
		{
			SetEntProp(entity, Prop_Send, "m_clrRender", g_iClientColor[client]);
			AcceptEntityInput(entity, "TurnOff");
		}
		else
		{
			g_iClientIndex[client] = GetClientUserId(client);
			g_iClientColor[client] = GetEntProp(entity, Prop_Send, "m_clrRender");
			AcceptEntityInput(entity, "TurnOff");
		}

		entity = g_iLightIndex[client];
		if( !IsValidEntRef(entity) )
			return;

		// Specified colors
		char sTempL[12];
		Format(sTempL, sizeof(sTempL), "185 51 51");

		SetVariantEntity(entity);
		SetVariantString(sTempL);
		AcceptEntityInput(entity, "color");
		AcceptEntityInput(entity, "toggle");

		int color = GetEntProp(entity, Prop_Send, "m_clrRender");
		if( color != g_iClientColor[client] )
			AcceptEntityInput(entity, "turnon");
		g_iClientColor[client] = color;
	}
}

void DeleteLight(int client)
{
	int entity = g_iLightIndex[client];
	g_iLightIndex[client] = 0;
	DeleteEntity(entity);
}

void DeleteEntity(int entity)
{
	if( IsValidEntRef(entity) )
		AcceptEntityInput(entity, "Kill");
}

int MakeLightDynamic(const float vOrigin[3], const float vAngles[3], int client)
{
	int entity = CreateEntityByName("light_dynamic");
	if (CheckIfEntitySafe( entity ) == false)
	{
		return 0;
	}

	char sTemp[16];
	Format(sTemp, sizeof(sTemp), "255 51 51 155");
	DispatchKeyValue(entity, "_light", sTemp);
	DispatchKeyValue(entity, "brightness", "1");
	DispatchKeyValueFloat(entity, "spotlight_radius", 0.0);
	DispatchKeyValueFloat(entity, "distance", 450.0);
	DispatchKeyValue(entity, "style", "0");
	DispatchSpawn(entity);
	AcceptEntityInput(entity, "TurnOn");

	// Attach to survivor
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", client);

	TeleportEntity(entity, vOrigin, vAngles, NULL_VECTOR);
	return entity;
}

void SwitchToSurvivors(int client)
{
	if (L4D_HasPlayerControlledZombies()) return;
	if (!IsClientInGame(client)) return;
	if (GetClientTeam(client) == 2) return;
	if (IsFakeClient(client)) return;

	int bot = FindBotToTakeOver();

	if (bot == 0)
	{
		PrintHintText(client, "[TS] No alive survivor bots to take over.");
		return;
	}
	L4D_SetHumanSpec(bot, client);
	L4D_TakeOverBot(client);
	return;
}

bool IsInteger(char[] buffer)
{
    int len = strlen(buffer);
    for (int i = 0; i < len; i++)
    {
        if ( !IsCharNumeric(buffer[i]) )
            return false;
    }

    return true;
}

int CheckAliveSurvivorPlayers_InSV()
{
	int iPlayersInAliveSurvivors=0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i)) continue;
		switch(GetClientTeam(i))
		{
			case TEAM_SURVIVOR:
			{
				if(IsPlayerAlive(i)) iPlayersInAliveSurvivors++;
				else if(g_bIncludingDead && !IsPlayerAlive(i)) iPlayersInAliveSurvivors++;
			}
		}
	}

	return iPlayersInAliveSurvivors;
}

bool CheckRealPlayers_InSV(int client = 0)
{
	for (int i = 1; i <= MaxClients; i++)
		if(IsClientConnected(i) && !IsFakeClient(i) && i != client)
			return true;

	return false;
}

// ====================================================================================================
//					SDKHOOKS TRANSMIT
// ====================================================================================================

void SetSpawnDis()
{
	if(g_iCurrentMode != 1) return;

	/*
	if(g_bMapStarted && L4D_IsMissionFinalMap(true))
	{
		if(g_bL4D2Version)
		{
			// 修改數值會導致救援期間tank生不出來
			// z_finale_spawn_tank_safety_range

			// 修改數值會導致救援期間屍潮生不出來
			// 修改數值也影響救援期間靈魂特感復活距離
			// z_finale_spawn_safety_range

			// 修改數值會導致救援期間屍潮生不出來
			// z_finale_spawn_mob_safety_range
		}
	}

	// 修改數值也影響小殭屍生成距離
	// 不建議將生成距離擴大
	// z_spawn_range
	*/

	// 修改數值也影響小殭屍生成距離
	// 修改數值也影響靈魂特感復活距離
	ConVar z_spawn_safety_range = FindConVar("z_spawn_safety_range");
	int flags4 = z_spawn_safety_range.Flags;
	z_spawn_safety_range.SetBounds(ConVarBound_Upper, false);
	z_spawn_safety_range.Flags = flags4 & ~FCVAR_NOTIFY;
	z_spawn_safety_range.SetFloat(g_ePluginSettings.m_fSpawnRangeMin);
}

Action SpawnWitchAuto(Handle timer)
{
	if( g_bCvarAllow == false || (g_bFinaleStarted && g_ePluginSettings.m_bWitchSpawnFinal == false))
	{
		hSpawnWitchTimer = null;
		return Plugin_Continue;
	}

	float vecPos[3];
	int witches=0;
	int entity = -1;
	while ( ((entity = FindEntityByClassname(entity, "witch")) != -1) )
	{
		witches++;
	}

	int anyclient = GetAheadSurvivor();
	int witch;
	if(anyclient == 0)
	{
		PrintToServer("[TS] Couldn't find a valid alive survivor to spawn witch at this moment.");
	}
	else if (witches < g_ePluginSettings.m_iWitchMaxLimit)
	{
		if(L4D_GetRandomPZSpawnPosition(anyclient,7,ZOMBIESPAWN_Attempts,vecPos) == true)
		{
			if( g_bL4D2Version && g_bSpawnWitchBride )
			{
				witch = L4D2_SpawnWitchBride(vecPos,NULL_VECTOR);
			}
			else
			{
				witch = L4D2_SpawnWitch(vecPos,NULL_VECTOR);
			}

			if(witch > 0) CreateTimer(g_ePluginSettings.m_fWitchLife,KickWitch_Timer,EntIndexToEntRef(witch),TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			PrintToServer("[TS] Couldn't find a Witch Spawn position in %d tries", ZOMBIESPAWN_Attempts);
		}
	}

	hSpawnWitchTimer = CreateTimer(GetRandomFloat(g_ePluginSettings.m_fWitchSpawnTimeMin, g_ePluginSettings.m_fWitchSpawnTimeMax), SpawnWitchAuto);

	return Plugin_Continue;
}

int L4D_GetSurvivorVictim(int client)
{
	int victim;

	if(g_bL4D2Version)
	{
		/* Charger */
		victim = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
		if (victim > 0)
		{
			return victim;
		}

		victim = GetEntPropEnt(client, Prop_Send, "m_carryVictim");
		if (victim > 0)
		{
			return victim;
		}

		/* Jockey */
		victim = GetEntPropEnt(client, Prop_Send, "m_jockeyVictim");
		if (victim > 0)
		{
			return victim;
		}
	}

    /* Hunter */
	victim = GetEntPropEnt(client, Prop_Send, "m_pounceVictim");
	if (victim > 0)
	{
		return victim;
 	}

    /* Smoker */
 	victim = GetEntPropEnt(client, Prop_Send, "m_tongueVictim");
	if (victim > 0)
	{
		return victim;
	}

	return -1;
}
bool IsValidClient(int client, bool replaycheck = true)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	//if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	if (replaycheck)
	{
		if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	}
	return true;
}

void ResetTimer()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		PlayerHasEnteredStart[i] = false;
		delete FightOrDieTimer[i];
		delete RestoreColorTimer[i];
		delete g_hPlayerSpawnTimer[i];
	}

	delete hSpawnWitchTimer;
	delete PlayerLeftStartTimer;
	delete infHUDTimer;
	delete g_hCheckSpawnTimer;
	delete DisplayTimer;
	delete InitialSpawnResetTimer;

	for(int i = 0; i <= MaxClients; i++)
	{
		delete SpawnInfectedBotTimer[i];
	}

	for(int i = 0; i < NUM_TYPES_INFECTED_MAX; i++)
	{
		delete g_hSpawnColdDownTimer[i];
	}
}

// prevent infecetd fall damage on coop
Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damageType)
{
	if(g_bCvarAllow == false || L4D_HasPlayerControlledZombies() || victim <= 0 || victim > MaxClients || !IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Continue;
	if(attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker) ) return Plugin_Continue;

	if(attacker == victim && GetClientTeam(attacker) == TEAM_INFECTED && !IsPlayerTank(attacker))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

Action tmrDelayCreateSurvivorGlow(Handle timer, any client)
{
	CreateSurvivorModelGlow(GetClientOfUserId(client));

	return Plugin_Continue;
}

void CreateSurvivorModelGlow(int client)
{
	if (!g_bL4D2Version ||
	!client ||
	!IsClientInGame(client) ||
	GetClientTeam(client) != TEAM_SURVIVOR ||
	!IsPlayerAlive(client) ||
	IsValidEntRef(g_iModelIndex[client]) == true ||
	L4D_HasPlayerControlledZombies() ||
	g_ePluginSettings.m_bCoopVersusEnable == false ||
	bDisableSurvivorModelGlow == true ||
	g_bMapStarted == false) return;

	RemoveSurvivorModelGlow(client);

	///////設定發光物件//////////
	// Get Client Model
	char sModelName[64];
	GetEntPropString(client, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));

	// Spawn dynamic prop entity
	int entity = CreateEntityByName("prop_dynamic_ornament");
	if (CheckIfEntitySafe( entity ) == false) return;

	// Set new fake model
	SetEntityModel(entity, sModelName);
	DispatchSpawn(entity);

	// Set outline glow color
	SetEntProp(entity, Prop_Send, "m_CollisionGroup", 0);
	SetEntProp(entity, Prop_Send, "m_nSolidType", 0);
	SetEntProp(entity, Prop_Send, "m_nGlowRange", 4500);
	SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
	if(IsplayerIncap(client)) SetEntProp(entity, Prop_Send, "m_glowColorOverride", 180 + (0 * 256) + (0 * 65536)); //RGB
	else SetEntProp(entity, Prop_Send, "m_glowColorOverride", 0 + (180 * 256) + (0 * 65536)); //RGB
	AcceptEntityInput(entity, "StartGlowing");

	// Set model invisible
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 0, 0, 0, 0);

	// Set model attach to client, and always synchronize
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", client);
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetAttached", client);
	///////發光物件完成//////////

	g_iModelIndex[client] = EntIndexToEntRef(entity);

	//model 只能給誰看?
	SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit);
}

Action Hook_SetTransmit(int entity, int client)
{
	if( GetClientTeam(client) != TEAM_INFECTED)
		return Plugin_Handled;

	return Plugin_Continue;
}

void RemoveSurvivorModelGlow(int client)
{
	int entity = g_iModelIndex[client];
	g_iModelIndex[client] = 0;

	if( IsValidEntRef(entity) )
		AcceptEntityInput(entity, "kill");
}

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}

bool IsplayerIncap(int client)
{
	if(GetEntProp(client, Prop_Send, "m_isHangingFromLedge") || GetEntProp(client, Prop_Send, "m_isIncapacitated"))
		return true;

	return false;
}

int GetFrustration(int tank_index)
{
	return GetEntProp(tank_index, Prop_Send, "m_frustration");
}

int GetAheadSurvivor()
{
	float max_flow = 0.0;
	float tmp_flow, origin[3];
	int iAheadSurvivor = 0, iTemp;
	Address pNavArea;
	for (int client = 1; client <= MaxClients; client++) {
		if(IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
		{
			iTemp = client;
			GetClientAbsOrigin(client, origin);
			pNavArea = L4D2Direct_GetTerrorNavArea(origin);
			if (pNavArea == Address_Null) continue;
			
			tmp_flow = L4D2Direct_GetTerrorNavAreaFlow(pNavArea);
			if(tmp_flow >= max_flow)
			{
				max_flow = tmp_flow;
				iAheadSurvivor = iTemp;
			}
		}
	}

	return (iAheadSurvivor == 0) ? iTemp : iAheadSurvivor;
}

int GetRandomAliveSurvivor()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i) && !IsClientInKickQueue(i))
		{
			iClients[iClientCount++] = i;
		}
	}
	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

void CheckandPrecacheModel(const char[] model)
{
	if (!IsModelPrecached(model))
	{
		PrecacheModel(model, true);
	}
}

static bool IsVisibleTo(int player1, int player2)
{
	// check FOV first
	// if his origin is not within a 60 degree cone in front of us, no need to raytracing.
	float pos1_eye[3], pos2_eye[3], eye_angle[3], vec_diff[3], vec_forward[3];
	GetClientEyePosition(player1, pos1_eye);
	GetClientEyeAngles(player1, eye_angle);
	GetClientEyePosition(player2, pos2_eye);
	MakeVectorFromPoints(pos1_eye, pos2_eye, vec_diff);
	NormalizeVector(vec_diff, vec_diff);
	GetAngleVectors(eye_angle, vec_forward, NULL_VECTOR, NULL_VECTOR);
	if (GetVectorDotProduct(vec_forward, vec_diff) < 0.5) // cos 60
	{
		return false;
	}

	// in FOV
	Handle hTrace;
	bool ret = false;
	float pos2_feet[3], pos2_chest[3];
	GetClientAbsOrigin(player2, pos2_feet);
	pos2_chest[0] = pos2_feet[0];
	pos2_chest[1] = pos2_feet[1];
	pos2_chest[2] = pos2_feet[2] + 45.0;

	if (GetEntProp(player2, Prop_Send, "m_zombieClass") != ZOMBIECLASS_JOCKEY)
	{
		hTrace = TR_TraceRayFilterEx(pos1_eye, pos2_eye, MASK_VISIBLE, RayType_EndPoint, TraceFilter, player1);
		if (!TR_DidHit(hTrace) || TR_GetEntityIndex(hTrace) == player2)
		{
			CloseHandle(hTrace);
			return true;
		}
		CloseHandle(hTrace);
	}

	hTrace = TR_TraceRayFilterEx(pos1_eye, pos2_feet, MASK_VISIBLE, RayType_EndPoint, TraceFilter, player1);
	if (!TR_DidHit(hTrace) || TR_GetEntityIndex(hTrace) == player2)
	{
		CloseHandle(hTrace);
		return true;
	}
	CloseHandle(hTrace);

	hTrace = TR_TraceRayFilterEx(pos1_eye, pos2_chest, MASK_VISIBLE, RayType_EndPoint, TraceFilter, player1);
	if (!TR_DidHit(hTrace) || TR_GetEntityIndex(hTrace) == player2)
	{
		CloseHandle(hTrace);
		return true;
	}
	CloseHandle(hTrace);

	return ret;
}

static bool TraceFilter(int entity, int mask, int self)
{
	return entity != self;
}

// instead of Netprops "m_hasVisibleThreats", GetEntProp(i, Prop_Send, "m_hasVisibleThreats")
bool CanBeSeenBySurvivors(int infected)
{
	for (int client = 1; client <= MaxClients; ++client)
	{
		if (IsAliveSurvivor(client) && IsVisibleTo(client, infected))
		{
			return true;
		}
	}
	return false;
}

bool IsAliveSurvivor(int client)
{
    return IsClientInGame(client)
        && GetClientTeam(client) == TEAM_SURVIVOR
        && IsPlayerAlive(client);
}

GameData hGameData;
void GetGameData()
{
	hGameData = LoadGameConfigFile(GAMEDATA_FILE);
	if( hGameData != null )
	{
		PrepSDKCall();
	}
	else
	{
		SetFailState("Unable to find l4dinfectedbots.txt gamedata file.");
	}
	delete hGameData;
}

void PrepSDKCall()
{
	if(g_bL4D2Version)
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "FlashLightTurnOn");
		hFlashLightTurnOn = EndPrepSDKCall();
	}
	else
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Virtual, "FlashlightIsOn");
		hFlashLightTurnOn = EndPrepSDKCall();
	}
	if (hFlashLightTurnOn == null)
		SetFailState("FlashLightTurnOn Signature broken");

	//find create bot signature
	Address replaceWithBot = GameConfGetAddress(hGameData, "NextBotCreatePlayerBot.jumptable");
	if (replaceWithBot != Address_Null && LoadFromAddress(replaceWithBot, NumberType_Int8) == 0x68) {
		// We're on L4D2 and linux
		PrepWindowsCreateBotCalls(replaceWithBot);
	}
	else
	{
		if (g_bL4D2Version)
		{
			PrepL4D2CreateBotCalls();
		}
		else
		{
			delete hCreateSpitter;
			delete hCreateJockey;
			delete hCreateCharger;
		}

		PrepL4D1CreateBotCalls();
	}

	g_iIntentionOffset = hGameData.GetOffset(FUNCTION_PATCH);
	if (g_iIntentionOffset == -1)
	{
		SetFailState("Failed to load offset: %s", FUNCTION_PATCH);
	}

	int iOffset = hGameData.GetOffset(FUNCTION_PATCH2);
	if (g_iIntentionOffset == -1)
	{
		SetFailState("Failed to load offset: %s", FUNCTION_PATCH2);
	}
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(iOffset);
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKFirstContainedResponder = EndPrepSDKCall();
	if (g_hSDKFirstContainedResponder == null)
	{
		SetFailState("Your \"%s\" offsets are outdated.", FUNCTION_PATCH2);
	}

	iOffset = hGameData.GetOffset(FUNCTION_PATCH3);
	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetVirtual(iOffset);
	PrepSDKCall_SetReturnInfo(SDKType_String, SDKPass_Plain);
	g_hSDKGetName = EndPrepSDKCall();
	if (g_hSDKGetName == null)
	{
		SetFailState("Your \"%s\" offsets are outdated.", FUNCTION_PATCH3);
	}

	delete hGameData;
}

void LoadStringFromAdddress(Address addr, char[] buffer, int maxlength) {
	int i = 0;
	while(i < maxlength) {
		char val = LoadFromAddress(addr + view_as<Address>(i), NumberType_Int8);
		if(val == 0) {
			buffer[i] = 0;
			break;
		}
		buffer[i] = val;
		i++;
	}
	buffer[maxlength - 1] = 0;
}

Handle PrepCreateBotCallFromAddress(Handle hSiFuncTrie, const char[] siName) {
	Address addr;
	StartPrepSDKCall(SDKCall_Static);
	if (!GetTrieValue(hSiFuncTrie, siName, addr) || !PrepSDKCall_SetAddress(addr))
	{
		SetFailState("Unable to find NextBotCreatePlayer<%s> address in memory.", siName);
		return null;
	}
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	return EndPrepSDKCall();
}

void PrepWindowsCreateBotCalls(Address jumpTableAddr) {
	Handle hInfectedFuncs = CreateTrie();
	// We have the address of the jump table, starting at the first PUSH instruction of the
	// PUSH mem32 (5 bytes)
	// CALL rel32 (5 bytes)
	// JUMP rel8 (2 bytes)
	// repeated pattern.

	// Each push is pushing the address of a string onto the stack. Let's grab these strings to identify each case.
	// "Hunter" / "Smoker" / etc.
	for(int i = 0; i < 7; i++) {
		// 12 bytes in PUSH32, CALL32, JMP8.
		Address caseBase = jumpTableAddr + view_as<Address>(i * 12);
		Address siStringAddr = view_as<Address>(LoadFromAddress(caseBase + view_as<Address>(1), NumberType_Int32));
		static char siName[32];
		LoadStringFromAdddress(siStringAddr, siName, sizeof(siName));

		Address funcRefAddr = caseBase + view_as<Address>(6); // 2nd byte of call, 5+1 byte offset.
		int funcRelOffset = LoadFromAddress(funcRefAddr, NumberType_Int32);
		Address callOffsetBase = caseBase + view_as<Address>(10); // first byte of next instruction after the CALL instruction
		Address nextBotCreatePlayerBotTAddr = callOffsetBase + view_as<Address>(funcRelOffset);
		//PrintToServer("Found NextBotCreatePlayerBot<%s>() @ %08x", siName, nextBotCreatePlayerBotTAddr);
		SetTrieValue(hInfectedFuncs, siName, nextBotCreatePlayerBotTAddr);
	}

	hCreateSmoker = PrepCreateBotCallFromAddress(hInfectedFuncs, "Smoker");
	if (hCreateSmoker == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateSmoker); return; }

	hCreateBoomer = PrepCreateBotCallFromAddress(hInfectedFuncs, "Boomer");
	if (hCreateBoomer == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateBoomer); return; }

	hCreateHunter = PrepCreateBotCallFromAddress(hInfectedFuncs, "Hunter");
	if (hCreateHunter == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateHunter); return; }

	hCreateTank = PrepCreateBotCallFromAddress(hInfectedFuncs, "Tank");
	if (hCreateTank == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateTank); return; }

	hCreateSpitter = PrepCreateBotCallFromAddress(hInfectedFuncs, "Spitter");
	if (hCreateSpitter == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateSpitter); return; }

	hCreateJockey = PrepCreateBotCallFromAddress(hInfectedFuncs, "Jockey");
	if (hCreateJockey == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateJockey); return; }

	hCreateCharger = PrepCreateBotCallFromAddress(hInfectedFuncs, "Charger");
	if (hCreateCharger == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateCharger); return; }

	delete hInfectedFuncs;
}

void PrepL4D2CreateBotCalls() {
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, NAME_CreateSpitter))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateSpitter); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateSpitter = EndPrepSDKCall();
	if (hCreateSpitter == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateSpitter); return; }

	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, NAME_CreateJockey))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateJockey); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateJockey = EndPrepSDKCall();
	if (hCreateJockey == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateJockey); return; }

	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, NAME_CreateCharger))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateCharger); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateCharger = EndPrepSDKCall();
	if (hCreateCharger == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateCharger); return; }
}

void PrepL4D1CreateBotCalls() 
{
	bool bLinuxOS = hGameData.GetOffset("OS") != 0;
	if(bLinuxOS)
	{
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, NAME_CreateSmoker))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateSmoker); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateSmoker = EndPrepSDKCall();
		if (hCreateSmoker == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateSmoker); return; }

		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, NAME_CreateBoomer))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateBoomer); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateBoomer = EndPrepSDKCall();
		if (hCreateBoomer == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateBoomer); return; }

		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, NAME_CreateHunter))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateHunter); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateHunter = EndPrepSDKCall();
		if (hCreateHunter == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateHunter); return; }

		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, NAME_CreateTank))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateTank); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateTank = EndPrepSDKCall();
		if (hCreateTank == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateTank); return; }
	}
	else
	{
		Address addr;

		addr = RelativeJumpDestination(hGameData.GetAddress(NAME_CreateSmoker_L4D1));
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetAddress(addr))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateSmoker_L4D1); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateSmoker = EndPrepSDKCall();
		if(hCreateSmoker == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateSmoker_L4D1); return; }

		addr = RelativeJumpDestination(hGameData.GetAddress(NAME_CreateBoomer_L4D1));
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetAddress(addr))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateBoomer_L4D1); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateBoomer = EndPrepSDKCall();
		if(hCreateSmoker == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateBoomer_L4D1); return; }

		addr = RelativeJumpDestination(hGameData.GetAddress(NAME_CreateHunter_L4D1));
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetAddress(addr))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateHunter_L4D1); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateHunter = EndPrepSDKCall();
		if(hCreateHunter == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateHunter_L4D1); return; }

		addr = RelativeJumpDestination(hGameData.GetAddress(NAME_CreateTank_L4D1));
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetAddress(addr))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateTank_L4D1); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateTank = EndPrepSDKCall();
		if(hCreateTank == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateTank_L4D1); return; }
	}
}

Address RelativeJumpDestination(Address p)
{
	int offset = LoadFromAddress(p, NumberType_Int32);
	return p + view_as<Address>(offset + 4);
}

bool IsTooClose(int client, float distance)
{
	float fInfLocation[3], fSurvLocation[3], fVector[3];
	GetClientAbsOrigin(client, fInfLocation);

	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i)==TEAM_SURVIVOR && IsPlayerAlive(i))
		{
			GetClientAbsOrigin(i, fSurvLocation);
			MakeVectorFromPoints(fInfLocation, fSurvLocation, fVector);
			if (GetVectorLength(fVector, true) < Pow(distance, 2.0)) return true;
		}
	}
	return false;
}

bool HasAccess(int client, char[] sAcclvl)
{
	// no permissions set
	if (strlen(sAcclvl) == 0)
		return true;

	else if (StrEqual(sAcclvl, "-1"))
		return false;

	// check permissions
	int userFlags = GetUserFlagBits(client);
	if ( (userFlags & ReadFlagString(sAcclvl)) || (userFlags & ADMFLAG_ROOT))
	{
		return true;
	}

	return false;
}

void GameStart()
{
	// We don't care who left, just that at least one did
	if(g_iCurrentMode == 3)
	{
		if(g_bL4D2Version)
		{
			SetConVarInt(FindConVar("survival_max_smokers"), 0);
			SetConVarInt(FindConVar("survival_max_boomers"), 0);
			SetConVarInt(FindConVar("survival_max_hunters"), 0);
			SetConVarInt(FindConVar("survival_max_jockeys"), 0);
			SetConVarInt(FindConVar("survival_max_spitters"), 0);
			SetConVarInt(FindConVar("survival_max_chargers"), 0);
			SetConVarInt(FindConVar("survival_max_specials"), 0);
		}
		else
		{
			SetConVarInt(FindConVar("holdout_max_smokers"), 0);
			SetConVarInt(FindConVar("holdout_max_boomers"), 0);
			SetConVarInt(FindConVar("holdout_max_hunters"), 0);
			SetConVarInt(FindConVar("holdout_max_specials"), 0);
		}
	}

	SetSpawnDis();

	// We check if we need to spawn bots
	CheckIfBotsNeeded(2);
	#if DEBUG
	LogMessage("Checking to see if we need bots");
	#endif
	if(g_iCurrentMode != 3)
	{
		delete hSpawnWitchTimer;
		hSpawnWitchTimer = CreateTimer(GetRandomFloat(g_ePluginSettings.m_fWitchSpawnTimeMin, g_ePluginSettings.m_fWitchSpawnTimeMax), SpawnWitchAuto);
	}
}

// The type of idle mode to check for.
// Note: It is recommended to set this to "2" on non-finale maps and "0" on finale maps.
// Note: There is a rare bug where a Tank spawns with no behavior even though they look "idle" to survivors. Set this setting to "0" or "2" to detect this bug.
// Note: Do not change this setting if you are unsure of how it works.
// Note: This setting can be used for standard Tanks.
// --
// 0: Both
// 1: Only check for idle Tanks.
// 2: Only check for Tanks with no behavior (rare bug).
bool bIsTankIdle(int tank, int type = 0)
{
	Address adTank = GetEntityAddress(tank);
	if (adTank == Address_Null)
	{
		return false;
	}

	Address adIntention = LoadFromAddress((adTank + view_as<Address>(g_iIntentionOffset)), NumberType_Int32);
	if (adIntention == Address_Null)
	{
		return false;
	}

	Address adBehavior = view_as<Address>(SDKCall(g_hSDKFirstContainedResponder, adIntention));
	if (adBehavior == Address_Null)
	{
		return false;
	}

	Address adAction = view_as<Address>(SDKCall(g_hSDKFirstContainedResponder, adBehavior));
	if (adAction == Address_Null)
	{
		return false;
	}

	Address adChildAction = Address_Null;
	while ((adChildAction = view_as<Address>(SDKCall(g_hSDKFirstContainedResponder, adAction))) != Address_Null)
	{
		adAction = adChildAction;
	}

	char sAction[64];
	SDKCall(g_hSDKGetName, adAction, sAction, sizeof sAction);
	return (type != 2 && StrEqual(sAction, "TankIdle")) || (type != 1 && (StrEqual(sAction, "TankBehavior") || adAction == adBehavior));
}

void CleanUpStateAndMusic(int client)
{
	if(IsFakeClient(client)) return;

	// Resets a players state equivalent to when they die
	// does stuff like removing any pounces, stops reviving, stops healing, resets hang lighting, resets heartbeat and other sounds.
	L4D_CleanupPlayerState(client);

	// This fixes the music glitch thats been bothering me and many players for a long time. The music keeps playing over and over when it shouldn't. Doesn't execute
	// on versus.
	if(g_iCurrentMode != 2)
	{
		if (!g_bL4D2Version)
		{
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Hospital");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Airport");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Farm");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Small_Town");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Garage");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Hospital");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Airport");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Small_Town");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Farm");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Garage");
			L4D_StopMusic(client, "Event.Zombat");
			L4D_StopMusic(client, "Event.Zombat_A2");
			L4D_StopMusic(client, "Event.Zombat_A3");
			L4D_StopMusic(client, "Event.Tank");
			L4D_StopMusic(client, "Event.TankMidpoint");
			L4D_StopMusic(client, "Event.TankMidpoint_Metal");
			L4D_StopMusic(client, "Event.TankBrothers");
			L4D_StopMusic(client, "Event.WitchAttack");
			L4D_StopMusic(client, "Event.WitchBurning");
			L4D_StopMusic(client, "Event.WitchRage");
			L4D_StopMusic(client, "Event.HunterPounce");
			L4D_StopMusic(client, "Event.SmokerChoke");
			L4D_StopMusic(client, "Event.SmokerDrag");
			L4D_StopMusic(client, "Event.VomitInTheFace");
			L4D_StopMusic(client, "Event.LedgeHangTwoHands");
			L4D_StopMusic(client, "Event.LedgeHangOneHand");
			L4D_StopMusic(client, "Event.LedgeHangFingers");
			L4D_StopMusic(client, "Event.LedgeHangAboutToFall");
			L4D_StopMusic(client, "Event.LedgeHangFalling");
			L4D_StopMusic(client, "Event.Down");
			L4D_StopMusic(client, "Event.BleedingOut");
			L4D_StopMusic(client, "Event.SurvivorDeath");
			L4D_StopMusic(client, "Event.ScenarioLose");
		}
		else
		{
			// Music when Mission Starts
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Mall");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Fairgrounds");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Plankcountry");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Milltown");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_BigEasy");
			
			// Checkpoints
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Mall");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Fairgrounds");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Plankcountry");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Milltown");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_BigEasy");
			
			// Zombat
			L4D_StopMusic(client, "Event.Zombat_1");
			L4D_StopMusic(client, "Event.Zombat_A_1");
			L4D_StopMusic(client, "Event.Zombat_B_1");
			L4D_StopMusic(client, "Event.Zombat_2");
			L4D_StopMusic(client, "Event.Zombat_A_2");
			L4D_StopMusic(client, "Event.Zombat_B_2");
			L4D_StopMusic(client, "Event.Zombat_3");
			L4D_StopMusic(client, "Event.Zombat_A_3");
			L4D_StopMusic(client, "Event.Zombat_B_3");
			L4D_StopMusic(client, "Event.Zombat_4");
			L4D_StopMusic(client, "Event.Zombat_A_4");
			L4D_StopMusic(client, "Event.Zombat_B_4");
			L4D_StopMusic(client, "Event.Zombat_5");
			L4D_StopMusic(client, "Event.Zombat_A_5");
			L4D_StopMusic(client, "Event.Zombat_B_5");
			L4D_StopMusic(client, "Event.Zombat_6");
			L4D_StopMusic(client, "Event.Zombat_A_6");
			L4D_StopMusic(client, "Event.Zombat_B_6");
			L4D_StopMusic(client, "Event.Zombat_7");
			L4D_StopMusic(client, "Event.Zombat_A_7");
			L4D_StopMusic(client, "Event.Zombat_B_7");
			L4D_StopMusic(client, "Event.Zombat_8");
			L4D_StopMusic(client, "Event.Zombat_A_8");
			L4D_StopMusic(client, "Event.Zombat_B_8");
			L4D_StopMusic(client, "Event.Zombat_9");
			L4D_StopMusic(client, "Event.Zombat_A_9");
			L4D_StopMusic(client, "Event.Zombat_B_9");
			L4D_StopMusic(client, "Event.Zombat_10");
			L4D_StopMusic(client, "Event.Zombat_A_10");
			L4D_StopMusic(client, "Event.Zombat_B_10");
			L4D_StopMusic(client, "Event.Zombat_11");
			L4D_StopMusic(client, "Event.Zombat_A_11");
			L4D_StopMusic(client, "Event.Zombat_B_11");
			
			// Zombat specific maps
			
			// C1 Mall
			L4D_StopMusic(client, "Event.Zombat2_Intro_Mall");
			L4D_StopMusic(client, "Event.Zombat3_Intro_Mall");
			L4D_StopMusic(client, "Event.Zombat3_A_Mall");
			L4D_StopMusic(client, "Event.Zombat3_B_Mall");
			
			// A2 Fairgrounds
			L4D_StopMusic(client, "Event.Zombat_Intro_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat_A_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat_B_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat_B_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat2_Intro_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat3_Intro_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat3_A_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat3_B_Fairgrounds");
			
			// C3 Plankcountry
			L4D_StopMusic(client, "Event.Zombat_PlankCountry");
			L4D_StopMusic(client, "Event.Zombat_A_PlankCountry");
			L4D_StopMusic(client, "Event.Zombat_B_PlankCountry");
			L4D_StopMusic(client, "Event.Zombat2_Intro_Plankcountry");
			L4D_StopMusic(client, "Event.Zombat3_Intro_Plankcountry");
			L4D_StopMusic(client, "Event.Zombat3_A_Plankcountry");
			L4D_StopMusic(client, "Event.Zombat3_B_Plankcountry");
			
			// A2 Milltown
			L4D_StopMusic(client, "Event.Zombat2_Intro_Milltown");
			L4D_StopMusic(client, "Event.Zombat3_Intro_Milltown");
			L4D_StopMusic(client, "Event.Zombat3_A_Milltown");
			L4D_StopMusic(client, "Event.Zombat3_B_Milltown");
			
			// C5 BigEasy
			L4D_StopMusic(client, "Event.Zombat2_Intro_BigEasy");
			L4D_StopMusic(client, "Event.Zombat3_Intro_BigEasy");
			L4D_StopMusic(client, "Event.Zombat3_A_BigEasy");
			L4D_StopMusic(client, "Event.Zombat3_B_BigEasy");
			
			// A2 Clown
			L4D_StopMusic(client, "Event.Zombat3_Intro_Clown");
			
			// Death
			
			// ledge hang
			L4D_StopMusic(client, "Event.LedgeHangTwoHands");
			L4D_StopMusic(client, "Event.LedgeHangOneHand");
			L4D_StopMusic(client, "Event.LedgeHangFingers");
			L4D_StopMusic(client, "Event.LedgeHangAboutToFall");
			L4D_StopMusic(client, "Event.LedgeHangFalling");
			
			// Down
			// Survivor is down and being beaten by infected
			
			L4D_StopMusic(client, "Event.Down");
			L4D_StopMusic(client, "Event.BleedingOut");
			
			// Survivor death
			// This is for the death of an individual survivor to be played after the health meter has reached zero
			
			L4D_StopMusic(client, "Event.SurvivorDeath");
			L4D_StopMusic(client, "Event.ScenarioLose");
			
			// Bosses
			
			// Tank
			L4D_StopMusic(client, "Event.Tank");
			L4D_StopMusic(client, "Event.TankMidpoint");
			L4D_StopMusic(client, "Event.TankMidpoint_Metal");
			L4D_StopMusic(client, "Event.TankBrothers");
			L4D_StopMusic(client, "C2M5.RidinTank1");
			L4D_StopMusic(client, "C2M5.RidinTank2");
			L4D_StopMusic(client, "C2M5.BadManTank1");
			L4D_StopMusic(client, "C2M5.BadManTank2");
			
			// Witch
			L4D_StopMusic(client, "Event.WitchAttack");
			L4D_StopMusic(client, "Event.WitchBurning");
			L4D_StopMusic(client, "Event.WitchRage");
			L4D_StopMusic(client, "Event.WitchDead");
			
			// mobbed
			L4D_StopMusic(client, "Event.Mobbed");
			
			// Hunter
			L4D_StopMusic(client, "Event.HunterPounce");
			
			// Smoker
			L4D_StopMusic(client, "Event.SmokerChoke");
			L4D_StopMusic(client, "Event.SmokerDrag");
			
			// Boomer
			L4D_StopMusic(client, "Event.VomitInTheFace");
			
			// Charger
			L4D_StopMusic(client, "Event.ChargerSlam");
			
			// Jockey
			L4D_StopMusic(client, "Event.JockeyRide");
			
			// Spitter
			L4D_StopMusic(client, "Event.SpitterSpit");
			L4D_StopMusic(client, "Event.SpitterBurn");
		}
	}
}


int GenerateIndex()
{
	int TotalSpawnWeight, StandardizedSpawnWeight;
	
	//temporary spawn weights factoring in SI spawn limits
	int[] TempSpawnWeights = new int[NUM_INFECTED];
	float[] IntervalEnds = new float[NUM_INFECTED];
	for(int i = 0; i < NUM_INFECTED; i++)
	{
		if(g_iSpawnCounts[i] < g_ePluginSettings.m_iSpawnLimit[i] && g_hSpawnColdDownTimer[i] == null)
		{
			if(g_ePluginSettings.m_bScaleWeights)
				TempSpawnWeights[i] = (g_ePluginSettings.m_iSpawnLimit[i] - g_iSpawnCounts[i]) * g_ePluginSettings.m_iSpawnWeight[i];
			else
				TempSpawnWeights[i] = g_ePluginSettings.m_iSpawnWeight[i];
		}
		else
		{
			TempSpawnWeights[i] = 0;
		}
		
		TotalSpawnWeight += TempSpawnWeights[i];
	}
	
	//calculate end intervals for each spawn
	float unit = 1.0/TotalSpawnWeight;
	for (int i = 0; i < NUM_INFECTED; i++)
	{
		if (TempSpawnWeights[i] >= 0)
		{
			StandardizedSpawnWeight += TempSpawnWeights[i];
			IntervalEnds[i] = StandardizedSpawnWeight * unit;
		}
	}
	
	float random = GetRandomFloat(0.0, 1.0); //selector r must be within the ith interval for i to be selected
	for (int i = 0; i < NUM_INFECTED; i++)
	{
		//negative and 0 weights are ignored
		if (TempSpawnWeights[i] <= 0) continue;
		//r is not within the ith interval
		if (IntervalEnds[i] < random) continue;
		//selected index i because r is within ith interval
		return i;
	}

	return -1; //no selection because all weights were negative or 0
}

Action Timer_SpawnColdDown(Handle timer, int SI_TYPE)
{
	g_hSpawnColdDownTimer[SI_TYPE] = null;
	return Plugin_Continue;
}

int GetSurvivorsInServer()
{
	int count = 0;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR)
		{
			count++;
		}
	}

	return count;
}

bool CheckIfEntitySafe(int entity)
{
	if(entity == -1) return false;

	if(	entity > ENTITY_SAFE_LIMIT)
	{
		RemoveEntity(entity);
		return false;
	}
	return true;
}

void LoadData()
{
	char sPath[PLATFORM_MAX_PATH];
	if(strlen(g_sCvarReloadSettings) == 0)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/" ... PLUGIN_NAME ... "/%s.cfg", g_sCvarMPGameMode);
	}
	else
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), "data/" ... PLUGIN_NAME ... "/%s.cfg", g_sCvarReloadSettings);
	}
	
	if( !FileExists(sPath) )
	{
		SetFailState("File Not Found: %s", sPath);
		return;
	}

	// Load config
	KeyValues hData = new KeyValues(PLUGIN_NAME);
	if (!hData.ImportFromFile(sPath)) {
		SetFailState("File Format Not Correct: %s", sPath);
		delete hData;
	}

	if(hData.JumpToKey("default"))
	{
		ePluginData[0].m_bAnnounceEnable = view_as<bool>(hData.GetNum("announce_enable", 1));
		ePluginData[0].m_iSpawnLimit[SI_SMOKER] = hData.GetNum("smoker_limit", 2);
		ePluginData[0].m_iSpawnLimit[SI_BOOMER] = hData.GetNum("boomer_limit", 2);
		ePluginData[0].m_iSpawnLimit[SI_HUNTER] = hData.GetNum("hunter_limit", 2);
		ePluginData[0].m_iSpawnLimit[SI_SPITTER] = hData.GetNum("spitter_limit", 2);
		ePluginData[0].m_iSpawnLimit[SI_JOCKEY] = hData.GetNum("jockey_limit", 2);
		ePluginData[0].m_iSpawnLimit[SI_CHARGER] = hData.GetNum("charger_limit", 2);
		ePluginData[0].m_iMaxSpecials = hData.GetNum("max_specials", 2);

		ePluginData[0].m_fSpawnTimeMax = hData.GetFloat("spawn_time_max", 60.0);
		ePluginData[0].m_fSpawnTimeMin = hData.GetFloat("spawn_time_min", 40.0);
		ePluginData[0].m_fSILife = hData.GetFloat("life", 30.0);
		ePluginData[0].m_fInitialSpawnTime = hData.GetFloat("initial_spawn_time", 10.0);

		ePluginData[0].m_iSpawnWeight[SI_SMOKER] = hData.GetNum("smoker_weight", 100);
		ePluginData[0].m_iSpawnWeight[SI_BOOMER] = hData.GetNum("boomer_weight", 100);
		ePluginData[0].m_iSpawnWeight[SI_HUNTER] = hData.GetNum("hunter_weight", 100);
		ePluginData[0].m_iSpawnWeight[SI_SPITTER] = hData.GetNum("spitter_weight", 100);
		ePluginData[0].m_iSpawnWeight[SI_JOCKEY] = hData.GetNum("jockey_weight", 100);
		ePluginData[0].m_iSpawnWeight[SI_CHARGER] = hData.GetNum("charger_weight", 100);
		ePluginData[0].m_bScaleWeights = view_as<bool>(hData.GetNum("scale_weights", 1));

		ePluginData[0].m_iSIHealth[SI_SMOKER] = hData.GetNum("smoker_health", 250);
		ePluginData[0].m_iSIHealth[SI_BOOMER] = hData.GetNum("boomer_health", 50);
		ePluginData[0].m_iSIHealth[SI_HUNTER] = hData.GetNum("hunter_health", 250);
		ePluginData[0].m_iSIHealth[SI_SPITTER] = hData.GetNum("spitter_health", 100);
		ePluginData[0].m_iSIHealth[SI_JOCKEY] = hData.GetNum("jockey_health", 325);
		ePluginData[0].m_iSIHealth[SI_CHARGER] = hData.GetNum("charger_health", 600);

		ePluginData[0].m_iTankLimit = hData.GetNum("tank_limit", 1);
		ePluginData[0].m_iTankSpawnProbability = hData.GetNum("tank_spawn_probability", 5);
		ePluginData[0].m_iTankHealth = hData.GetNum("tank_health", 4000);
		ePluginData[0].m_bTankSpawnFinal = view_as<bool>(hData.GetNum("tank_spawn_final", 0));

		ePluginData[0].m_iWitchMaxLimit = hData.GetNum("witch_max_limit", 1);
		ePluginData[0].m_fWitchSpawnTimeMax = hData.GetFloat("witch_spawn_time_max", 120.0);
		ePluginData[0].m_fWitchSpawnTimeMin = hData.GetFloat("witch_spawn_time_min", 90.0);
		ePluginData[0].m_fWitchLife = hData.GetFloat("witch_life", 200.0);
		ePluginData[0].m_bWitchSpawnFinal = view_as<bool>(hData.GetNum("witch_spawn_final", 0));

		ePluginData[0].m_bSpawnSameFrame = view_as<bool>(hData.GetNum("spawn_same_frame", 0));
		ePluginData[0].m_fSpawnTimeIncreased_OnHumanInfected = hData.GetFloat("spawn_time_increase_on_human_infected", 3.0);
		ePluginData[0].m_bSpawnSafeZone = view_as<bool>(hData.GetNum("spawn_safe_zone", 0));
		ePluginData[0].m_iSpawnWhereMethod = hData.GetNum("spawn_where_method", 0);
		ePluginData[0].m_fSpawnRangeMin = hData.GetFloat("spawn_range_min", 350.0);
		ePluginData[0].m_bSpawnDisableBots = view_as<bool>(hData.GetNum("spawn_disable_bots", 0));
		ePluginData[0].m_bTankDisableSpawn = view_as<bool>(hData.GetNum("tank_disable_spawn", 0));
		ePluginData[0].m_bCoordination = view_as<bool>(hData.GetNum("coordination", 0));

		ePluginData[0].m_bCoopVersusEnable = view_as<bool>(hData.GetNum("coop_versus_enable", 0));
		ePluginData[0].m_fCoopVersSpawnTimeMax = hData.GetFloat("coop_versus_spawn_time_max", 30.0);
		ePluginData[0].m_fCoopVersSpawnTimeMin = hData.GetFloat("coop_versus_spawn_time_max", 25.0);
		ePluginData[0].m_bCoopTankPlayable = view_as<bool>(hData.GetNum("coop_versus_tank_playable", 0));
		ePluginData[0].m_bCoopVersusAnnounce = view_as<bool>(hData.GetNum("coop_versus_announce", 1));
		ePluginData[0].m_iCoopVersusHumanLimit = hData.GetNum("coop_versus_human_limit", 1);
		hData.GetString("coop_versus_join_access", ePluginData[0].m_sCoopVersusJoinAccess, sizeof(EPluginData::m_sCoopVersusJoinAccess), "z");
		ePluginData[0].m_bCoopVersusHumanLight = view_as<bool>(hData.GetNum("coop_versus_human_light", 1));
		ePluginData[0].m_bCoopVersusHumanGhost = view_as<bool>(hData.GetNum("coop_versus_human_ghost", 1));
		ePluginData[0].m_fCoopVersusHumanCoolDown = hData.GetFloat("coop_versus_cool_down", 60.0);

		hData.GoBack();
	}

	char sNumber[4];
	for(int i = 1; i <= L4D_MAXPLAYERS; i++)
	{
		FormatEx(sNumber, sizeof(sNumber), "%d", i);
		if(hData.JumpToKey(sNumber))
		{
			ePluginData[i].m_bAnnounceEnable = view_as<bool>(hData.GetNum("announce_enable", ePluginData[0].m_bAnnounceEnable));
			ePluginData[i].m_iSpawnLimit[SI_SMOKER] = hData.GetNum("smoker_limit", ePluginData[0].m_iSpawnLimit[SI_SMOKER]);
			ePluginData[i].m_iSpawnLimit[SI_BOOMER] = hData.GetNum("boomer_limit", ePluginData[0].m_iSpawnLimit[SI_BOOMER]);
			ePluginData[i].m_iSpawnLimit[SI_HUNTER] = hData.GetNum("hunter_limit", ePluginData[0].m_iSpawnLimit[SI_HUNTER]);
			ePluginData[i].m_iSpawnLimit[SI_SPITTER] = hData.GetNum("spitter_limit", ePluginData[0].m_iSpawnLimit[SI_SPITTER]);
			ePluginData[i].m_iSpawnLimit[SI_JOCKEY] = hData.GetNum("jockey_limit", ePluginData[0].m_iSpawnLimit[SI_JOCKEY]);
			ePluginData[i].m_iSpawnLimit[SI_CHARGER] = hData.GetNum("charger_limit", ePluginData[0].m_iSpawnLimit[SI_CHARGER]);
			ePluginData[i].m_iMaxSpecials = hData.GetNum("max_specials", ePluginData[0].m_iMaxSpecials);

			ePluginData[i].m_fSpawnTimeMax = hData.GetFloat("spawn_time_max", ePluginData[0].m_fSpawnTimeMax);
			ePluginData[i].m_fSpawnTimeMin = hData.GetFloat("spawn_time_min", ePluginData[0].m_fSpawnTimeMin);
			ePluginData[i].m_fSILife = hData.GetFloat("life", ePluginData[0].m_fSILife);
			ePluginData[i].m_fInitialSpawnTime = hData.GetFloat("initial_spawn_time", ePluginData[0].m_fInitialSpawnTime);

			ePluginData[i].m_iSpawnWeight[SI_SMOKER] = hData.GetNum("smoker_weight", ePluginData[0].m_iSpawnWeight[SI_SMOKER]);
			ePluginData[i].m_iSpawnWeight[SI_BOOMER] = hData.GetNum("boomer_weight", ePluginData[0].m_iSpawnWeight[SI_BOOMER]);
			ePluginData[i].m_iSpawnWeight[SI_HUNTER] = hData.GetNum("hunter_weight", ePluginData[0].m_iSpawnWeight[SI_HUNTER]);
			ePluginData[i].m_iSpawnWeight[SI_SPITTER] = hData.GetNum("spitter_weight", ePluginData[0].m_iSpawnWeight[SI_SPITTER]);
			ePluginData[i].m_iSpawnWeight[SI_JOCKEY] = hData.GetNum("jockey_weight", ePluginData[0].m_iSpawnWeight[SI_JOCKEY]);
			ePluginData[i].m_iSpawnWeight[SI_CHARGER] = hData.GetNum("charger_weight", ePluginData[0].m_iSpawnWeight[SI_CHARGER]);
			ePluginData[i].m_bScaleWeights = view_as<bool>(hData.GetNum("scale_weights", ePluginData[0].m_bScaleWeights));

			ePluginData[i].m_iSIHealth[SI_SMOKER] = hData.GetNum("smoker_health", ePluginData[0].m_iSIHealth[SI_SMOKER]);
			ePluginData[i].m_iSIHealth[SI_BOOMER] = hData.GetNum("boomer_health", ePluginData[0].m_iSIHealth[SI_BOOMER]);
			ePluginData[i].m_iSIHealth[SI_HUNTER] = hData.GetNum("hunter_health", ePluginData[0].m_iSIHealth[SI_HUNTER]);
			ePluginData[i].m_iSIHealth[SI_SPITTER] = hData.GetNum("spitter_health", ePluginData[0].m_iSIHealth[SI_SPITTER]);
			ePluginData[i].m_iSIHealth[SI_JOCKEY] = hData.GetNum("jockey_health", ePluginData[0].m_iSIHealth[SI_JOCKEY]);
			ePluginData[i].m_iSIHealth[SI_CHARGER] = hData.GetNum("charger_health", ePluginData[0].m_iSIHealth[SI_CHARGER]);
			
			ePluginData[i].m_iTankLimit = hData.GetNum("tank_limit", ePluginData[0].m_iTankLimit);
			ePluginData[i].m_iTankSpawnProbability = hData.GetNum("tank_spawn_probability", ePluginData[0].m_iTankSpawnProbability);
			ePluginData[i].m_iTankHealth = hData.GetNum("tank_health", ePluginData[0].m_iTankHealth);
			ePluginData[i].m_bTankSpawnFinal = view_as<bool>(hData.GetNum("tank_spawn_final", ePluginData[0].m_bTankSpawnFinal));

			ePluginData[i].m_iWitchMaxLimit = hData.GetNum("witch_max_limit", ePluginData[0].m_iWitchMaxLimit);
			ePluginData[i].m_fWitchSpawnTimeMax = hData.GetFloat("witch_spawn_time_max", ePluginData[0].m_fWitchSpawnTimeMax);
			ePluginData[i].m_fWitchSpawnTimeMin = hData.GetFloat("witch_spawn_time_min", ePluginData[0].m_fWitchSpawnTimeMin);
			ePluginData[i].m_fWitchLife = hData.GetFloat("witch_life", ePluginData[0].m_fWitchLife);
			ePluginData[i].m_bWitchSpawnFinal = view_as<bool>(hData.GetNum("witch_spawn_final", ePluginData[0].m_bWitchSpawnFinal));

			ePluginData[i].m_bSpawnSameFrame = view_as<bool>(hData.GetNum("spawn_same_frame", ePluginData[0].m_bSpawnSameFrame));
			ePluginData[i].m_fSpawnTimeIncreased_OnHumanInfected = hData.GetFloat("spawn_time_increase_on_human_infected", ePluginData[0].m_fSpawnTimeIncreased_OnHumanInfected);
			ePluginData[i].m_bSpawnSafeZone = view_as<bool>(hData.GetNum("spawn_safe_zone", ePluginData[0].m_bSpawnSafeZone));
			ePluginData[i].m_iSpawnWhereMethod = hData.GetNum("spawn_where_method", ePluginData[0].m_iSpawnWhereMethod);
			ePluginData[i].m_fSpawnRangeMin = hData.GetFloat("spawn_range_min", ePluginData[0].m_fSpawnRangeMin);
			ePluginData[i].m_bSpawnDisableBots = view_as<bool>(hData.GetNum("spawn_disable_bots", ePluginData[0].m_bSpawnDisableBots));
			ePluginData[i].m_bTankDisableSpawn = view_as<bool>(hData.GetNum("tank_disable_spawn", ePluginData[0].m_bTankDisableSpawn));
			ePluginData[i].m_bCoordination = view_as<bool>(hData.GetNum("coordination", ePluginData[0].m_bCoordination));

			ePluginData[i].m_bCoopVersusEnable = view_as<bool>(hData.GetNum("coop_versus_enable", ePluginData[0].m_bCoopVersusEnable));
			ePluginData[i].m_fCoopVersSpawnTimeMax = hData.GetFloat("coop_versus_spawn_time_max", ePluginData[0].m_fCoopVersSpawnTimeMax);
			ePluginData[i].m_fCoopVersSpawnTimeMin = hData.GetFloat("coop_versus_spawn_time_min", ePluginData[0].m_fCoopVersSpawnTimeMin);
			ePluginData[i].m_bCoopTankPlayable = view_as<bool>(hData.GetNum("coop_versus_tank_playable", ePluginData[0].m_bCoopTankPlayable));
			ePluginData[i].m_bCoopVersusAnnounce = view_as<bool>(hData.GetNum("coop_versus_announce", ePluginData[0].m_bCoopVersusAnnounce));
			ePluginData[i].m_iCoopVersusHumanLimit = hData.GetNum("coop_versus_human_limit", ePluginData[0].m_iCoopVersusHumanLimit);
			hData.GetString("coop_versus_join_access", ePluginData[i].m_sCoopVersusJoinAccess, sizeof(EPluginData::m_sCoopVersusJoinAccess), ePluginData[0].m_sCoopVersusJoinAccess);
			ePluginData[i].m_bCoopVersusHumanLight = view_as<bool>(hData.GetNum("coop_versus_human_light", ePluginData[0].m_bCoopVersusHumanLight));
			ePluginData[i].m_bCoopVersusHumanGhost = view_as<bool>(hData.GetNum("coop_versus_human_ghost", ePluginData[0].m_bCoopVersusHumanGhost));
			ePluginData[i].m_fCoopVersusHumanCoolDown = hData.GetFloat("coop_versus_cool_down", ePluginData[0].m_fCoopVersusHumanCoolDown);

			hData.GoBack();
		}
		else
		{
			ePluginData[i] = ePluginData[0];
		}
	}

	delete hData;

	g_ePluginSettings = ePluginData[(g_iPlayersInSurvivorTeam <= 0) ? 0 : g_iPlayersInSurvivorTeam];
}

///////////////////////////////////////////////////////////////////////////

public Action L4D_OnGetScriptValueInt(const char[] sKey, int &retVal)
{
	if( g_bCvarAllow == false) return Plugin_Continue;
	
	if (strcmp(sKey, "BoomerLimit", false) == 0) {

		retVal = g_ePluginSettings.m_iSpawnLimit[SI_BOOMER];
		//PrintToServer("BoomerLimit %d", retVal);
		return Plugin_Handled;
	}
	else if(strcmp(sKey, "SmokerLimit", false) == 0) {

		retVal = g_ePluginSettings.m_iSpawnLimit[SI_SMOKER];
		//PrintToServer("SmokerLimit %d", retVal);
		return Plugin_Handled;
	}
	else if(strcmp(sKey, "HunterLimit", false) == 0) {

		retVal = g_ePluginSettings.m_iSpawnLimit[SI_HUNTER];
		//PrintToServer("HunterLimit %d", retVal);
		return Plugin_Handled;
	}
	else if(strcmp(sKey, "SpitterLimit", false) == 0) {

		retVal = g_ePluginSettings.m_iSpawnLimit[SI_SPITTER];
		//PrintToServer("SpitterLimit %d", retVal);
		return Plugin_Handled;
	}
	else if(strcmp(sKey, "JockeyLimit", false) == 0) {

		retVal = g_ePluginSettings.m_iSpawnLimit[SI_JOCKEY];
		//PrintToServer("JockeyLimit %d", retVal);
		return Plugin_Handled;
	}
	else if(strcmp(sKey, "ChargerLimit", false) == 0) {

		retVal = g_ePluginSettings.m_iSpawnLimit[SI_CHARGER];
		//PrintToServer("ChargerLimit %d", retVal);
		return Plugin_Handled;
	}
	/*
	// 註解原因: 影響到導演生成的tank包括: 地圖固定tank, 對抗生成的tank
	else if(strcmp(sKey, "TankLimit", false) == 0 || strcmp(sKey, "cm_TankLimit", false) == 0) {

		retVal = g_ePluginSettings.m_iSpawnLimit[SI_TANK];
		//PrintToServer("TankLimit %d", retVal);
		return Plugin_Handled;
	}*/
	else if(strcmp(sKey, "MaxSpecials", false) == 0 || strcmp(sKey, "cm_MaxSpecials", false) == 0 // Maximum number of Director spawned Special Infected allowed to be in play simultaneously.
		|| strcmp(sKey, "cm_BaseSpecialLimit", false) == 0) { // Controls the default max limits of all the Special Infected. Overridden by individual special limits.

		retVal = g_ePluginSettings.m_iMaxSpecials;
		//PrintToServer("MaxSpecials %d", retVal);

		return Plugin_Handled;
	}
	else if(strcmp(sKey, "DominatorLimit", false) == 0 || strcmp(sKey, "cm_DominatorLimit", false) == 0) { // Maximum number of dominator SI types (Hunter, Smoker, Jockey or Charger) that can freely fill up their caps.

		retVal = g_ePluginSettings.m_iMaxSpecials;
		//PrintToServer("DominatorLimit %d", retVal);

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

public Action L4D_OnGetScriptValueFloat(const char[] sKey, float &retVal)
{
	if( g_bCvarAllow == false) return Plugin_Continue;

	if(strcmp(sKey, "SpecialRespawnInterval", false) == 0 || strcmp(sKey, "cm_SpecialRespawnInterval", false) == 0) {

		retVal = 999999.9;
		//PrintToServer("L4D_OnGetScriptValueFloat SpecialRespawnInterval %.1f", retVal);

		return Plugin_Handled;
	}

	return Plugin_Continue;
}
/*
public Action L4D_OnSpawnSpecial(int &zombieClass, const float vecPos[3], const float vecAng[3])
{
	if(g_bL4D2Version) return Plugin_Continue;
	if(zombieClass == ZOMBIECLASS_TANK) return Plugin_Continue;

	//PrintToChatAll("zombieClass: %d", zombieClass);

	if (g_ePluginSettings.m_bTankDisableSpawn)
	{
		for (int i=1;i<=MaxClients;i++)
		{
			// We check if player is in game
			if (!IsClientInGame(i)) continue;

			// Check if client is infected ...
			if (GetClientTeam(i)==TEAM_INFECTED)
			{
				// If player is a tank
				if (IsPlayerTank(i) && IsPlayerAlive(i) && ( g_iCurrentMode != 1 || !IsFakeClient(i) || (IsFakeClient(i) && g_bAngry[i]) ) )
				{
					return Plugin_Handled;
				}
			}
		}
	}

	return Plugin_Continue;
}*/