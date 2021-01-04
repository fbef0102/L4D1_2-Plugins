/********************************************************************************************
* Plugin	: L4D/L4D2 InfectedBots (Versus Coop/Coop Versus)
* Version	: 2.5.0
* Game		: Left 4 Dead 1 & 2
* Author	: djromero (SkyDavid, David) and MI 5 and Harry Potter
* Website	: https://forums.alliedmods.net/showpost.php?p=2699220&postcount=1371
* 
* Purpose	: This plugin spawns infected bots in L4D1/2, and gives greater control of the infected bots in L4D1/L4D2.
* WARNING	: Please use sourcemod's latest 1.10 branch snapshot. 
* REQUIRE	: left4dhooks  (https://forums.alliedmods.net/showthread.php?p=2684862)
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
* Version 2.3.4ConVarChanged_Cvars
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
*	   - fixed Ghost TankBugFix in coop/realism.
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
#undef REQUIRE_PLUGIN
#include <left4dhooks>
#define PLUGIN_VERSION "2.5.0"
#define DEBUG 0

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVORS 		2
#define TEAM_INFECTED 		3

#define ZOMBIECLASS_SMOKER	1
#define ZOMBIECLASS_BOOMER	2
#define ZOMBIECLASS_HUNTER	3
#define ZOMBIECLASS_SPITTER	4
#define ZOMBIECLASS_JOCKEY	5
#define ZOMBIECLASS_CHARGER	6

#define MAXENTITIES 2048
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

// l4d1/2 value
static char sSpawnCommand[32];
static int ZOMBIECLASS_TANK;

// Variables
static int InfectedRealCount; // Holds the amount of real infected players
static int InfectedBotCount; // Holds the amount of infected bots in any gamemode
static int InfectedBotQueue; // Holds the amount of bots that are going to spawn
static int GameMode; // Holds the GameMode, 1 for coop and realism, 2 for versus, teamversus, scavenge and teamscavenge, 3 for survival
static int TanksPlaying; // Holds the amount of tanks on the playing field
static int g_iBoomerLimit; // Sets the Boomer Limit, related to the boomer limit cvar
static int g_iSmokerLimit; // Sets the Smoker Limit, related to the smoker limit cvar
static int g_iHunterLimit; // Sets the Hunter Limit, related to the hunter limit cvar
static int g_iSpitterLimit; // Sets the Spitter Limit, related to the Spitter limit cvar
static int g_iJockeyLimit; // Sets the Jockey Limit, related to the Jockey limit cvar
static int g_iChargerLimit; // Sets the Charger Limit, related to the Charger limit cvar
static int g_iMaxPlayerZombies; // Holds the amount of the maximum amount of special zombies on the field
static int MaxPlayerTank; // Used for setting an additional slot for each tank that spawns
static int BotReady; // Used to determine how many bots are ready, used only for the coordination feature
static int GetSpawnTime[MAXPLAYERS+1]; // Used for the HUD on getting spawn times of players
static int iPlayersInSurvivorTeam;

// Booleans
static bool b_HasRoundStarted; // Used to state if the round started or not
static bool b_HasRoundEnded; // States if the round has ended or not
static bool b_LeftSaveRoom; // States if the survivors have left the safe room
static bool canSpawnBoomer; // States if we can spawn a boomer (releated to spawn restrictions)
static bool canSpawnSmoker; // States if we can spawn a smoker (releated to spawn restrictions)
static bool canSpawnHunter; // States if we can spawn a hunter (releated to spawn restrictions)
static bool canSpawnSpitter; // States if we can spawn a spitter (releated to spawn restrictions)
static bool canSpawnJockey; // States if we can spawn a jockey (releated to spawn restrictions)
static bool canSpawnCharger; // States if we can spawn a charger (releated to spawn restrictions)
static bool FinaleStarted; // States whether the finale has started or not
static bool WillBeTank[MAXPLAYERS+1]; // States whether that player will be the tank
//bool TankHalt; // Loop Breaker, prevents player tanks from spawning over and over
static bool TankWasSeen[MAXPLAYERS+1]; // Used only in coop, prevents the Sound hook event from triggering over and over again
static bool PlayerLifeState[MAXPLAYERS+1]; // States whether that player has the lifestate changed from switching the gamemode
static bool InitialSpawn; // Related to the coordination feature, tells the plugin to let the infected spawn when the survivors leave the safe room
static bool L4D2Version = false; // Holds the version of L4D; false if its L4D, true if its L4D2
static bool TempBotSpawned; // Tells the plugin that the tempbot has spawned
static bool AlreadyGhosted[MAXPLAYERS+1]; // Loop Breaker, prevents a player from spawning into a ghost over and over again
static bool AlreadyGhostedBot[MAXPLAYERS+1]; // Prevents bots taking over a player from ghosting
static bool SurvivalVersus;
static bool PlayerHasEnteredStart[MAXPLAYERS+1];
static bool bDisableSurvivorModelGlow;

// ConVar
ConVar h_BoomerLimit; // Related to the Boomer limit cvar
ConVar h_SmokerLimit; // Related to the Smoker limit cvar
ConVar h_HunterLimit; // Related to the Hunter limit cvar
ConVar h_SpitterLimit; // Related to the Spitter limit cvar
ConVar h_JockeyLimit; // Related to the Jockey limit cvar
ConVar h_ChargerLimit; // Related to the Charger limit cvar
ConVar h_MaxPlayerZombies; // Related to the max specials cvar
ConVar h_PlayerAddZombiesScale;
ConVar h_PlayerAddZombies;
ConVar h_PlayerAddTankHealthScale; 
ConVar h_PlayerAddTankHealth; 
ConVar h_InfectedSpawnTimeMax; // Related to the spawn time cvar
ConVar h_InfectedSpawnTimeMin; // Related to the spawn time cvar
ConVar h_CoopPlayableTank; // yup, same thing again
ConVar h_JoinableTeams; // Can you guess this one?
ConVar h_StatsBoard; // Oops, now we are
ConVar h_JoinableTeamsAnnounce;
ConVar h_Coordination;
ConVar h_Idletime_b4slay;
ConVar h_InitialSpawn;
ConVar h_HumanCoopLimit;
ConVar h_AdminJoinInfected;
ConVar h_BotGhostTime;
ConVar h_DisableSpawnsTank;
ConVar h_TankLimit;
ConVar h_WitchLimit;
ConVar h_VersusCoop;
ConVar h_AdjustSpawnTimes;
ConVar h_InfHUD;
ConVar h_Announce ;
ConVar h_TankHealthAdjust;
ConVar h_TankHealth;
ConVar h_GameMode; 
ConVar h_Difficulty; 
ConVar cvarZombieHP[7];				// Array of handles to the 4 cvars we have to hook to monitor HP changes
ConVar h_SafeSpawn;
ConVar h_SpawnDistanceMin;
ConVar h_SpawnDistanceMax;
ConVar h_SpawnDistanceFinal;
ConVar h_WitchPeriodMax;
ConVar h_WitchPeriodMin;
ConVar h_WitchSpawnFinal;
ConVar h_WitchKillTime;
ConVar h_ReducedSpawnTimesOnPlayer;
ConVar h_SpawnTankProbability;
ConVar h_ZSDisableGamemode;
ConVar h_CommonLimitAdjust, h_CommonLimit, h_PlayerAddCommonLimitScale, h_PlayerAddCommonLimit,h_common_limit_cvar;
ConVar h_CoopInfectedPlayerFlashLight;

//Handle
static Handle PlayerLeftStartTimer = null; //Detect player has left safe area or not
static Handle infHUDTimer 		= null;	// The main HUD refresh timer
static Handle respawnTimer 	= null;	// Respawn countdown timer
static Handle delayedDmgTimer 	= null;	// Delayed damage update timer
static Panel pInfHUD = null;
static Handle usrHUDPref 		= null;	// Stores the client HUD preferences persistently
Handle FightOrDieTimer[MAXPLAYERS+1] = null; // kill idle bots
Handle hSpawnWitchTimer = null;
Handle RestoreColorTimer[MAXPLAYERS+1] = null;

//signature call
static Handle hSpec = null;
static Handle hSwitch = null;
static Handle hFlashLightTurnOn = null;
static Handle hCreateSmoker = null;
#define NAME_CreateSmoker "NextBotCreatePlayerBot<Smoker>"
#define SIG_CreateSmoker_LINUX "@_Z22NextBotCreatePlayerBotI6SmokerEPT_PKc"
static Handle hCreateBoomer = null;
#define NAME_CreateBoomer "NextBotCreatePlayerBot<Boomer>"
#define SIG_CreateBoomer_LINUX "@_Z22NextBotCreatePlayerBotI6BoomerEPT_PKc"
static Handle hCreateHunter = null;
#define NAME_CreateHunter "NextBotCreatePlayerBot<Hunter>"
#define SIG_CreateHunter_LINUX "@_Z22NextBotCreatePlayerBotI6HunterEPT_PKc"
static Handle hCreateSpitter = null;
#define NAME_CreateSpitter "NextBotCreatePlayerBot<Spitter>"
#define SIG_CreateSpitter_LINUX "@_Z22NextBotCreatePlayerBotI7SpitterEPT_PKc"
static Handle hCreateJockey = null;
#define NAME_CreateJockey "NextBotCreatePlayerBot<Jockey>"
#define SIG_CreateJockey_LINUX "@_Z22NextBotCreatePlayerBotI6JockeyEPT_PKc"
static Handle hCreateCharger = null;
#define NAME_CreateCharger "NextBotCreatePlayerBot<Charger>"
#define SIG_CreateCharger_LINUX "@_Z22NextBotCreatePlayerBotI7ChargerEPT_PKc"
static Handle hCreateTank = null;
#define NAME_CreateTank "NextBotCreatePlayerBot<Tank>"
#define SIG_CreateTank_LINUX "@_Z22NextBotCreatePlayerBotI4TankEPT_PKc"

// Stuff related to Durzel's HUD (Panel was redone)
static int respawnDelay[MAXPLAYERS+1]; 			// Used to store individual player respawn delays after death
static int hudDisabled[MAXPLAYERS+1];				// Stores the client preference for whether HUD is shown
static int clientGreeted[MAXPLAYERS+1]; 			// Stores whether or not client has been shown the mod commands/announce
static int zombieHP[7];					// Stores special infected max HP
static bool roundInProgress 		= false;		// Flag that marks whether or not a round is currently in progress
static float fPlayerSpawnEngineTime[MAXENTITIES] = 0.0; //time when real infected player spawns

int g_iClientColor[MAXPLAYERS+1], g_iClientIndex[MAXPLAYERS+1], g_iLightIndex[MAXPLAYERS+1];
int iPlayerTeam[MAXPLAYERS+1];
bool g_bSafeSpawn, g_bTankHealthAdjust, g_bVersusCoop, g_bJoinableTeams, g_bCoopPlayableTank , g_bJoinableTeamsAnnounce,
	g_bInfHUD, g_bAnnounce , g_bAdminJoinInfected, g_bAdjustSpawnTimes, g_bCommonLimitAdjust, g_bCoopInfectedPlayerFlashLight;
int g_iZSDisableGamemode, g_iTankHealth, g_iInfectedSpawnTimeMax, g_iInfectedSpawnTimeMin, g_iHumanCoopLimit,
	g_iReducedSpawnTimesOnPlayer, g_iWitchPeriodMax, g_iWitchPeriodMin, g_iSpawnTankProbability, g_iCommonLimit;
int g_iPlayerSpawn, g_bMapStarted, g_bSpawnWitchBride;
float g_fIdletime_b4slay, g_fInitialSpawn, g_fWitchKillTime;
int g_iModelIndex[MAXPLAYERS+1];			// Player Model entity reference

public Plugin myinfo = 
{
	name = "[L4D/L4D2] Infected Bots (Coop/Versus/Realism/Scavenge/Survival)",
	author = "djromero (SkyDavid), MI 5, Harry Potter",
	description = "Spawns infected bots in versus, allows playable special infected in coop/survival, and changable z_max_player_zombies limit",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showpost.php?p=2699220&postcount=1371"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		ZOMBIECLASS_TANK = 5;
		sSpawnCommand = "z_spawn";
		L4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		ZOMBIECLASS_TANK = 8;
		sSpawnCommand = "z_spawn_old";
		L4D2Version = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{
	LoadTranslations("l4dinfectedbots.phrases");
	
	// Notes on the offsets: altough m_isGhost is used to check or set a player's ghost status, for some weird reason this disallowed the player from spawning.
	// So I found and used m_isCulling to allow the player to press use and spawn as a ghost (which in this case, I forced the client to press use)
	
	// m_lifeState is an alternative to the "switching to spectator and back" method when a bot spawns. This was used to prevent players from taking over those bots, but
	// this provided weird movements when a player was spectating on the infected team.
	
	// ScrimmageType is interesting as it was used in the beta. The scrimmage code was abanonded and replaced with versus, but some of it is still left over in the final.
	// In the previous versions of this plugin (or not using this plugin at all), you might have seen giant bubbles or spheres around the map. Those are scrimmage spawn
	// spheres that were used to prevent infected from spawning within there. It was bothering me, and a whole lot of people who saw them. Thanks to AtomicStryker who
	// URGED me to remove the spheres, I began looking for a solution. He told me to use various source handles like m_scrimmageType and others. I experimented with it,
	// and found out that it removed the spheres, and implemented it into the plugin. The spheres are no longer shown, and they were useless anyway as infected still spawn 
	// within it.
	
	
	// Notes on the sourcemod commands:
	// JoinSpectator is actually a DEBUG command I used to see if the bots spawn correctly with and without a player. It was incredibly useful for this purpose, but it
	// will not be in the final versions.
	
	// Add a sourcemod command so players can easily join infected in coop/survival
	RegConsoleCmd("sm_ji", JoinInfected);
	RegConsoleCmd("sm_js", JoinSurvivors);
	RegConsoleCmd("sm_zs", ForceInfectedSuicide,"suicide myself (if infected get stuck or somthing)");
	RegAdminCmd("sm_zlimit", Console_ZLimit, ADMFLAG_SLAY,"control max special zombies limit");
	RegAdminCmd("sm_timer", Console_Timer, ADMFLAG_SLAY,"control special zombies spawn timer");
	#if DEBUG
	RegConsoleCmd("sm_sp", JoinSpectator);
	RegConsoleCmd("sm_gamemode", CheckGameMode);
	RegConsoleCmd("sm_count", CheckQueue);
	#endif
	
	// Hook "say" so clients can toggle HUD on/off for themselves
	RegConsoleCmd("sm_infhud", Command_Say);
	
	// We register the version cvar
	CreateConVar("l4d_infectedbots_version", PLUGIN_VERSION, "Version of L4D Infected Bots", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	// console variables
	h_BoomerLimit = CreateConVar("l4d_infectedbots_boomer_limit", "2", "Sets the limit for boomers spawned by the plugin", FCVAR_NOTIFY, true, 0.0);
	h_SmokerLimit = CreateConVar("l4d_infectedbots_smoker_limit", "2", "Sets the limit for smokers spawned by the plugin", FCVAR_NOTIFY, true, 0.0);
	h_HunterLimit = CreateConVar("l4d_infectedbots_hunter_limit", "2", "Sets the limit for hunters spawned by the plugin", FCVAR_NOTIFY, true, 0.0);
	h_TankLimit = CreateConVar("l4d_infectedbots_tank_limit", "1", "Sets the limit for tanks spawned by the plugin (does not affect director tanks)", FCVAR_NOTIFY, true, 0.0);
	h_WitchLimit = CreateConVar("l4d_infectedbots_witch_max_limit", "10", "Sets the limit for witches spawned by the plugin (does not affect director witches)", FCVAR_NOTIFY, true, 0.0);
	if (L4D2Version)
	{
		h_SpitterLimit = CreateConVar("l4d_infectedbots_spitter_limit", "2", "Sets the limit for spitters spawned by the plugin", FCVAR_NOTIFY, true, 0.0);
		h_JockeyLimit = CreateConVar("l4d_infectedbots_jockey_limit", "2", "Sets the limit for jockeys spawned by the plugin", FCVAR_NOTIFY, true, 0.0);
		h_ChargerLimit = CreateConVar("l4d_infectedbots_charger_limit", "2", "Sets the limit for chargers spawned by the plugin", FCVAR_NOTIFY, true, 0.0);
	}
	
	h_MaxPlayerZombies = CreateConVar("l4d_infectedbots_max_specials", "2", "Defines how many special infected can be on the map on all gamemodes(does not count witch on all gamemodes, count tank in all gamemode)", FCVAR_NOTIFY, true, 0.0); 
	h_PlayerAddZombiesScale = CreateConVar("l4d_infectedbots_add_specials_scale", "2", "If server has more than 4+ alive players, how many special infected = 'max_specials' + [(alive players - 4) ÷ 'add_specials_scale' × 'add_specials'].", FCVAR_NOTIFY, true, 1.0); 
	h_PlayerAddZombies = CreateConVar("l4d_infectedbots_add_specials", "2", "If server has more than 4+ alive players, increase the certain value to 'l4d_infectedbots_max_specials' each 'l4d_infectedbots_add_specials_scale' players joins", FCVAR_NOTIFY, true, 0.0); 

	h_TankHealthAdjust = CreateConVar("l4d_infectedbots_adjust_tankhealth_enable", "1", "If 1, adjust and overrides tank health by this plugin.", FCVAR_NOTIFY, true, 0.0,true, 1.0); 
	h_TankHealth = CreateConVar("l4d_infectedbots_default_tankhealth", "4000", "Sets Default Health for Tank", FCVAR_NOTIFY, true, 1.0); 
	h_PlayerAddTankHealthScale = CreateConVar("l4d_infectedbots_add_tankhealth_scale", "1", "If server has more than 4+ alive players, how many Tank Health = 'default_tankhealth' + [(alive players - 4) ÷ 'add_tankhealth_scale' × 'add_tankhealth'].", FCVAR_NOTIFY, true, 1.0); 
	h_PlayerAddTankHealth = CreateConVar("l4d_infectedbots_add_tankhealth", "500", "If server has more than 4+ alive players, increase the certain value to 'l4d_infectedbots_default_tankhealth' each 'l4d_infectedbots_add_tankhealth_scale' players joins", FCVAR_NOTIFY, true, 0.0); 
	h_InfectedSpawnTimeMax = CreateConVar("l4d_infectedbots_spawn_time_max", "60", "Sets the max spawn time for special infected spawned by the plugin in seconds.", FCVAR_NOTIFY, true, 1.0);
	h_InfectedSpawnTimeMin = CreateConVar("l4d_infectedbots_spawn_time_min", "40", "Sets the minimum spawn time for special infected spawned by the plugin in seconds.", FCVAR_NOTIFY, true, 1.0);
	h_CoopPlayableTank = CreateConVar("l4d_infectedbots_coop_versus_tank_playable", "0", "If 1, tank will be playable in coop/survival", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_JoinableTeams = CreateConVar("l4d_infectedbots_coop_versus", "1", "If 1, players can join the infected team in coop/survival (!ji in chat to join infected, !js to join survivors)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	if (!L4D2Version)
	{
		h_StatsBoard = CreateConVar("l4d_infectedbots_stats_board", "0", "If 1, the stats board will show up after an infected player dies (L4D1 ONLY)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	}
	h_JoinableTeamsAnnounce = CreateConVar("l4d_infectedbots_coop_versus_announce", "1", "If 1, clients will be announced to on how to join the infected team", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_Coordination = CreateConVar("l4d_infectedbots_coordination", "0", "If 1, bots will only spawn when all other bot spawn timers are at zero", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_InfHUD = CreateConVar("l4d_infectedbots_infhud_enable", "1", "Toggle whether Infected HUD is active or not.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_Announce = CreateConVar("l4d_infectedbots_infhud_announce", "1", "Toggle whether Infected HUD announces itself to clients.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_Idletime_b4slay = CreateConVar("l4d_infectedbots_lifespan", "30", "Amount of seconds before a special infected bot is kicked", FCVAR_NOTIFY, true, 1.0);
	h_InitialSpawn = CreateConVar("l4d_infectedbots_initial_spawn_timer", "10", "The spawn timer in seconds used when infected bots are spawned for the first time in a map", FCVAR_NOTIFY, true, 0.0);
	h_HumanCoopLimit = CreateConVar("l4d_infectedbots_coop_versus_human_limit", "2", "Sets the limit for the amount of humans that can join the infected team in coop/survival", FCVAR_NOTIFY, true, 0.0);
	h_AdminJoinInfected = CreateConVar("l4d_infectedbots_admin_coop_versus", "1", "If 1, only admins can join the infected team in coop/survival", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_BotGhostTime = CreateConVar("l4d_infectedbots_ghost_time", "1", "If higher than zero, the plugin will ghost bots before they fully spawn on versus/scavenge", FCVAR_NOTIFY);
	h_DisableSpawnsTank = CreateConVar("l4d_infectedbots_spawns_disabled_tank", "0", "If 1, Plugin will disable spawning infected bot when a tank is on the field.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_VersusCoop = CreateConVar("l4d_infectedbots_versus_coop", "0", "If 1, The plugin will force all players to the infected side against the survivor AI for every round and map in versus/scavenge", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_AdjustSpawnTimes = CreateConVar("l4d_infectedbots_adjust_spawn_times", "1", "If 1, The plugin will adjust spawn timers depending on the gamemode", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_ReducedSpawnTimesOnPlayer = CreateConVar("l4d_infectedbots_adjust_reduced_spawn_times_on_player", "1", "Reduce certain value to maximum spawn timer based per alive player", FCVAR_NOTIFY, true, 0.0);
	h_SafeSpawn = CreateConVar("l4d_infectedbots_safe_spawn", "0", "If 1, spawn special infected before survivors leave starting safe room area.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_SpawnDistanceMin = CreateConVar("l4d_infectedbots_spawn_range_min", "0", "The minimum of spawn range for infected (default: 550)", FCVAR_NOTIFY, true, 0.0);
	h_SpawnDistanceMax = CreateConVar("l4d_infectedbots_spawn_range_max", "2000", "The maximum of spawn range for infected (default: 1500)", FCVAR_NOTIFY, true, 1.0);
	h_SpawnDistanceFinal = CreateConVar("l4d_infectedbots_spawn_range_final", "0", "The minimum of spawn range for infected in final stage rescue.", FCVAR_NOTIFY, true, 0.0);
	h_WitchPeriodMax = CreateConVar("l4d_infectedbots_witch_spawn_time_max", "120.0", "Sets the max spawn time for witch spawned by the plugin in seconds.", FCVAR_NOTIFY, true, 1.0);
	h_WitchPeriodMin = CreateConVar("l4d_infectedbots_witch_spawn_time_min", "90.0", "Sets the mix spawn time for witch spawned by the plugin in seconds.", FCVAR_NOTIFY, true, 1.0);
	h_WitchSpawnFinal = CreateConVar("l4d_infectedbots_witch_spawn_final", "0", "If 1, still spawn witch in final stage rescue", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_WitchKillTime = CreateConVar("l4d_infectedbots_witch_lifespan", "200", "Amount of seconds before a witch is kicked", FCVAR_NOTIFY, true, 1.0);
	h_SpawnTankProbability = CreateConVar("l4d_infectedbots_tank_spawn_probability", "5", "When each time spawn S.I., how much percent of chance to spawn tank", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	h_ZSDisableGamemode = CreateConVar("l4d_infectedbots_sm_zs_disable_gamemode", "6", "Disable sm_zs in these gamemode (0: None, 1: coop/realism, 2: versus/scavenge, 4: survival, add numbers together)", FCVAR_NOTIFY, true, 0.0, true, 7.0);
	h_CommonLimitAdjust = CreateConVar("l4d_infectedbots_adjust_commonlimit_enable", "1", "If 1, adjust and overrides zombie common limit by this plugin.", FCVAR_NOTIFY, true, 0.0,true, 1.0); 
	h_CommonLimit = CreateConVar("l4d_infectedbots_default_commonlimit", "30", "Sets Default zombie common limit.", FCVAR_NOTIFY, true, 1.0); 
	h_PlayerAddCommonLimitScale = CreateConVar("l4d_infectedbots_add_commonlimit_scale", "1", "If server has more than 4+ alive players, zombie common limit = 'default_commonlimit' + [(alive players - 4) ÷ 'add_commonlimit_scale' × 'add_commonlimit'].", FCVAR_NOTIFY, true, 1.0); 
	h_PlayerAddCommonLimit = CreateConVar("l4d_infectedbots_add_commonlimit", "2", "If server has more than 4+ alive players, increase the certain value to 'l4d_infectedbots_default_commonlimit' each 'l4d_infectedbots_add_commonlimit_scale' players joins", FCVAR_NOTIFY, true, 0.0); 
	h_CoopInfectedPlayerFlashLight = CreateConVar("l4d_infectedbots_coop_versus_human_light", "1", "If 1, attaches red flash light to human infected player in coop/survival. (Make it clear which infected bot is controlled by player)", FCVAR_NOTIFY, true, 0.0, true, 1.0); 

	h_GameMode = FindConVar("mp_gamemode");
	h_GameMode.AddChangeHook(ConVarGameMode);
	h_Difficulty = FindConVar("z_difficulty");
	h_common_limit_cvar = FindConVar("z_common_limit");

	GetCvars();
	h_BoomerLimit.AddChangeHook(ConVarChanged_Cvars);
	h_SmokerLimit.AddChangeHook(ConVarChanged_Cvars);
	h_HunterLimit.AddChangeHook(ConVarChanged_Cvars);
	if (L4D2Version)
	{
		h_SpitterLimit.AddChangeHook(ConVarChanged_Cvars);
		h_JockeyLimit.AddChangeHook(ConVarChanged_Cvars);
		h_ChargerLimit.AddChangeHook(ConVarChanged_Cvars);
	}
	h_SafeSpawn.AddChangeHook(ConVarChanged_Cvars);
	h_TankHealth.AddChangeHook(ConVarChanged_Cvars);
	h_InfectedSpawnTimeMax.AddChangeHook(ConVarChanged_Cvars);
	h_InfectedSpawnTimeMin.AddChangeHook(ConVarChanged_Cvars);
	h_CoopPlayableTank.AddChangeHook(ConVarChanged_Cvars);
	h_JoinableTeamsAnnounce.AddChangeHook(ConVarChanged_Cvars);
	h_InfHUD.AddChangeHook(ConVarChanged_Cvars);
	h_Announce.AddChangeHook(ConVarChanged_Cvars);
	h_Idletime_b4slay.AddChangeHook(ConVarChanged_Cvars);
	h_InitialSpawn.AddChangeHook(ConVarChanged_Cvars);
	h_HumanCoopLimit.AddChangeHook(ConVarChanged_Cvars);
	h_AdminJoinInfected.AddChangeHook(ConVarChanged_Cvars);
	h_AdjustSpawnTimes.AddChangeHook(ConVarChanged_Cvars);
	h_ReducedSpawnTimesOnPlayer.AddChangeHook(ConVarChanged_Cvars);
	h_ZSDisableGamemode.AddChangeHook(ConVarChanged_Cvars);
	h_WitchPeriodMax.AddChangeHook(ConVarChanged_Cvars);
	h_WitchPeriodMin.AddChangeHook(ConVarChanged_Cvars);
	h_WitchKillTime.AddChangeHook(ConVarChanged_Cvars);
	h_SpawnTankProbability.AddChangeHook(ConVarChanged_Cvars);
	h_CommonLimit.AddChangeHook(ConVarChanged_Cvars);
	h_CoopInfectedPlayerFlashLight.AddChangeHook(ConVarChanged_Cvars);

	GetSpawnDisConvars();
	g_iMaxPlayerZombies = h_MaxPlayerZombies.IntValue;
	g_bTankHealthAdjust = h_TankHealthAdjust.BoolValue;
	g_bVersusCoop = h_VersusCoop.BoolValue;
	g_bJoinableTeams = h_JoinableTeams.BoolValue; bDisableSurvivorModelGlow = !g_bJoinableTeams;
	g_bCommonLimitAdjust = h_CommonLimitAdjust.BoolValue;
	h_SpawnDistanceMin.AddChangeHook(ConVarDistanceChanged);
	h_SpawnDistanceMax.AddChangeHook(ConVarDistanceChanged);
	h_SpawnDistanceFinal.AddChangeHook(ConVarDistanceChanged);
	h_Difficulty.AddChangeHook(ConVarDifficulty);
	h_MaxPlayerZombies.AddChangeHook(ConVarMaxPlayerZombies);
	h_TankHealthAdjust.AddChangeHook(ConVarTankHealthAdjust);
	h_VersusCoop.AddChangeHook(ConVarVersusCoop);
	h_JoinableTeams.AddChangeHook(ConVarCoopVersus);
	h_CommonLimitAdjust.AddChangeHook(hCommonLimitAdjustChanged);

	// Some of these events are being used multiple times. Although I copied Durzel's code, I felt this would make it more organized as there is a ton of code in events 
	// Such as PlayerDeath, PlayerSpawn and others.
	
	HookEvent("round_start", evtRoundStart);
	HookEvent("round_end", evtRoundEnd);
	HookEvent("map_transition", evtRoundEnd); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", evtRoundEnd); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", evtRoundEnd); //救援載具離開之時  (沒有觸發round_end)

	// We hook some events ...
	HookEvent("player_death", evtPlayerDeath, EventHookMode_Pre);
	HookEvent("player_team", evtPlayerTeam);
	HookEvent("player_spawn", evtPlayerSpawn);
	HookEvent("create_panic_event", evtSurvivalStart);
	HookEvent("finale_start", evtFinaleStart);
	HookEvent("player_death", evtInfectedDeath);
	HookEvent("player_spawn", evtInfectedSpawn);
	HookEvent("player_hurt", evtInfectedHurt);
	HookEvent("player_team", evtTeamSwitch);
	HookEvent("player_death", evtInfectedWaitSpawn);
	HookEvent("ghost_spawn_time", evtInfectedWaitSpawn);
	HookEvent("spawner_give_item", evtUnlockVersusDoor);
	HookEvent("player_bot_replace", evtBotReplacedPlayer);
	HookEvent("player_first_spawn", evtPlayerFirstSpawned);
	HookEvent("player_entered_start_area", evtPlayerFirstSpawned);
	HookEvent("player_entered_checkpoint", evtPlayerFirstSpawned);
	HookEvent("player_transitioned", evtPlayerFirstSpawned);
	HookEvent("player_left_start_area", evtPlayerFirstSpawned);
	HookEvent("player_left_checkpoint", evtPlayerFirstSpawned);
	HookEvent("witch_spawn", Event_WitchSpawn);
	HookEvent("player_incapacitated", Event_Incap);
	HookEvent("player_ledge_grab", Event_Incap);
	HookEvent("player_now_it", Event_GotVomit);
	HookEvent("revive_success", Event_revive_success);//救起倒地的or 懸掛的
	HookEvent("player_ledge_release", Event_ledge_release);//懸掛的玩家放開了

	// Hook a sound
	AddNormalSoundHook(view_as<NormalSHook>(HookSound_Callback));
	
	//----- Zombie HP hooks ---------------------	
	//We store the special infected max HP values in an array and then hook the cvars used to modify them
	//just in case another plugin (or an admin) decides to modify them.  Whilst unlikely if we don't do
	//this then the HP percentages on the HUD will end up screwy, and since it's a one-time initialisation
	//when the plugin loads there's a trivial overhead.
	cvarZombieHP[0] = FindConVar("z_hunter_health");
	cvarZombieHP[1] = FindConVar("z_gas_health");
	cvarZombieHP[2] = FindConVar("z_exploding_health");
	if (L4D2Version)
	{
		cvarZombieHP[3] = FindConVar("z_spitter_health");
		cvarZombieHP[4] = FindConVar("z_jockey_health");
		cvarZombieHP[5] = FindConVar("z_charger_health");
	}
	cvarZombieHP[6] = FindConVar("z_tank_health");
	zombieHP[0] = cvarZombieHP[0].IntValue; 
	cvarZombieHP[0].AddChangeHook(cvarZombieHPChanged);
	zombieHP[1] = cvarZombieHP[1].IntValue; 
	cvarZombieHP[1].AddChangeHook(cvarZombieHPChanged);
	zombieHP[2] = cvarZombieHP[2].IntValue;
	cvarZombieHP[2].AddChangeHook(cvarZombieHPChanged);
	if (L4D2Version)
	{
		zombieHP[3] = cvarZombieHP[3].IntValue;
		cvarZombieHP[3].AddChangeHook(cvarZombieHPChanged);
		zombieHP[4] = cvarZombieHP[4].IntValue;
		cvarZombieHP[4].AddChangeHook(cvarZombieHPChanged);
		zombieHP[5] = cvarZombieHP[5].IntValue;
		cvarZombieHP[5].AddChangeHook(cvarZombieHPChanged);
	}
	zombieHP[6] = cvarZombieHP[6].IntValue;
	cvarZombieHP[6].AddChangeHook(cvarZombieHPChanged);
	
	// Create persistent storage for client HUD preferences 
	usrHUDPref = CreateTrie();

	GetGameData();

	// Removes the boundaries for z_max_player_zombies and notify flag
	int flags = FindConVar("z_max_player_zombies").Flags;
	SetConVarBounds(FindConVar("z_max_player_zombies"), ConVarBound_Upper, false);
	SetConVarFlags(FindConVar("z_max_player_zombies"), flags & ~FCVAR_NOTIFY);

	CreateTimer(1.0, PluginStart);

	//Autoconfig for plugin
	AutoExecConfig(true, "l4dinfectedbots");
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iBoomerLimit = h_BoomerLimit.IntValue;
	g_iSmokerLimit = h_SmokerLimit.IntValue;
	g_iHunterLimit = h_HunterLimit.IntValue;
	if(L4D2Version)
	{
		g_iSpitterLimit = h_SpitterLimit.IntValue;
		g_iJockeyLimit = h_JockeyLimit.IntValue;
		g_iChargerLimit = h_ChargerLimit.IntValue;
	}
	g_bSafeSpawn = h_SafeSpawn.BoolValue;
	g_iTankHealth = h_TankHealth.IntValue;
	g_iInfectedSpawnTimeMax = h_InfectedSpawnTimeMax.IntValue;
	g_iInfectedSpawnTimeMin = h_InfectedSpawnTimeMin.IntValue;
	g_bCoopPlayableTank = h_CoopPlayableTank.BoolValue;
	g_bJoinableTeamsAnnounce = h_JoinableTeamsAnnounce.BoolValue;
	g_bInfHUD = h_InfHUD.BoolValue;
	g_bAnnounce = h_Announce.BoolValue;
	g_fIdletime_b4slay = h_Idletime_b4slay.FloatValue;
	g_fInitialSpawn = h_InitialSpawn.FloatValue;
	g_iHumanCoopLimit = h_HumanCoopLimit.IntValue;
	g_bAdminJoinInfected = h_AdminJoinInfected.BoolValue;
	g_bAdjustSpawnTimes = h_AdjustSpawnTimes.BoolValue;
	g_iReducedSpawnTimesOnPlayer = h_ReducedSpawnTimesOnPlayer.IntValue;
	g_iZSDisableGamemode = h_ZSDisableGamemode.IntValue;
	g_iWitchPeriodMax = h_WitchPeriodMax.IntValue;
	g_iWitchPeriodMin = h_WitchPeriodMin.IntValue;
	g_fWitchKillTime = h_WitchKillTime.FloatValue;
	g_iSpawnTankProbability = h_SpawnTankProbability.IntValue;
	g_iCommonLimit = h_CommonLimit.IntValue;
	g_bCoopInfectedPlayerFlashLight = h_CoopInfectedPlayerFlashLight.BoolValue;
}

public void ConVarMaxPlayerZombies(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_iMaxPlayerZombies = h_MaxPlayerZombies.IntValue;
	iPlayersInSurvivorTeam = -1;
	CreateTimer(0.1, MaxSpecialsSet);
	CreateTimer(1.0, ColdDown_Timer,_,TIMER_FLAG_NO_MAPCHANGE);
}

public void ConVarTankHealthAdjust(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_bTankHealthAdjust = h_TankHealthAdjust.BoolValue;
	if(g_bTankHealthAdjust) SetConVarInt(FindConVar("z_tank_health"), g_iTankHealth);
	else ResetConVar(FindConVar("z_tank_health"), true, true);
}

public void hCommonLimitAdjustChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_bCommonLimitAdjust = h_CommonLimitAdjust.BoolValue;
	if(g_bCommonLimitAdjust) SetConVarInt(h_common_limit_cvar, g_iCommonLimit);
	else ResetConVar(h_common_limit_cvar, true, true);
}

public void ConVarGameMode(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GameModeCheck();
	
	TweakSettings();

	bDisableSurvivorModelGlow = true;
	if(L4D2Version)
	{
		static char mode[64];
		h_GameMode.GetString(mode, sizeof(mode));
		for( int i = 1; i <= MaxClients; i++ ) 
		{
			RemoveSurvivorModelGlow(i);
			if(IsClientInGame(i) && !IsFakeClient(i)) SendConVarValue(i, h_GameMode, mode);
		}
	}

	if(L4D2Version)
	{
		if(GameMode != 2 && g_bJoinableTeams)
		{
			bDisableSurvivorModelGlow = false;
			for( int i = 1; i <= MaxClients; i++ ) 
			{
				CreateSurvivorModelGlow(i);
				if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_INFECTED) SendConVarValue(i, h_GameMode, "versus");
			}	
		}
	}
}

public void ConVarDifficulty(ConVar convar, const char[] oldValue, const char[] newValue)
{
	TankHealthCheck();
}

public void ConVarVersusCoop(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_bVersusCoop = h_VersusCoop.BoolValue;
	if(GameMode == 2)
	{
		if (g_bVersusCoop)
		{
			SetConVarInt(FindConVar("vs_max_team_switches"), 0);
			if (L4D2Version)
			{
				SetConVarInt(FindConVar("sb_all_bot_game"), 1);
				SetConVarInt(FindConVar("allow_all_bot_survivor_team"), 1);
			}
			else
			{
				SetConVarInt(FindConVar("sb_all_bot_team"), 1);
			}
		}
		else
		{
			ResetConVar(FindConVar("vs_max_team_switches"), true, true);
			if (L4D2Version)
			{
				ResetConVar(FindConVar("sb_all_bot_game"), true, true);
				ResetConVar(FindConVar("allow_all_bot_survivor_team"), true, true);
			}
			else
			{
				ResetConVar(FindConVar("sb_all_bot_team"), true, true);
			}
		}
	}
}

public void ConVarDistanceChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{	
	GetSpawnDisConvars();
}

public void ConVarCoopVersus(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_bJoinableTeams = h_JoinableTeams.BoolValue;
	if(GameMode != 2)
	{
		if (g_bJoinableTeams)
		{
			if (L4D2Version)
			{
				SetConVarInt(FindConVar("sb_all_bot_game"), 1);
				SetConVarInt(FindConVar("allow_all_bot_survivor_team"), 1);
			}
			else
			{
				SetConVarInt(FindConVar("sb_all_bot_team"), 1);
			}

			bDisableSurvivorModelGlow = false;
			for( int i = 1; i <= MaxClients; i++ ) CreateSurvivorModelGlow(i);
		}
		else
		{
			if (L4D2Version)
			{
				ResetConVar(FindConVar("sb_all_bot_game"), true, true);
				ResetConVar(FindConVar("allow_all_bot_survivor_team"), true, true);
			}
			else
			{
				ResetConVar(FindConVar("sb_all_bot_team"), true, true);
			}
			if(L4D2Version)
			{
				static char mode[64];
				h_GameMode.GetString(mode, sizeof(mode));
				bDisableSurvivorModelGlow = true;
				for( int i = 1; i <= MaxClients; i++ )
				{
					if(IsClientInGame(i) && !IsFakeClient(i)) SendConVarValue(i, h_GameMode, mode);
					RemoveSurvivorModelGlow(i);
				}
			}
		}
	}
}

void TweakSettings()
{
	// We tweak some settings ...
	
	// Some interesting things about this. There was a bug I discovered that in versions 1.7.8 and below, infected players would not spawn as ghosts in VERSUS. This was
	// due to the fact that the coop class limits were not being reset (I didn't think they were linked at all, but I should have known better). This bug has been fixed
	// with the coop class limits being reset on every gamemode except coop of course.
	
	// Reset the cvars
	ResetCvars();
	
	switch (GameMode)
	{
		case 1: // Coop, We turn off the ability for the director to spawn the bots, and have the plugin do it while allowing the director to spawn tanks and witches, 
		// MI 5
		{
			// If the game is L4D 2...
			if (L4D2Version)
			{
				SetConVarInt(FindConVar("z_smoker_limit"), 0);
				SetConVarInt(FindConVar("z_boomer_limit"), 0);
				SetConVarInt(FindConVar("z_hunter_limit"), 0);
				SetConVarInt(FindConVar("z_spitter_limit"), 0);
				SetConVarInt(FindConVar("z_jockey_limit"), 0);
				SetConVarInt(FindConVar("z_charger_limit"), 0);
			}
			else
			{
				SetConVarInt(FindConVar("z_gas_limit"), 0);
				SetConVarInt(FindConVar("z_exploding_limit"), 0);
				SetConVarInt(FindConVar("z_hunter_limit"), 0);
			}
			SetConVarInt(FindConVar("z_scrimmage_sphere"), 0);
		}
		case 2: // Versus, Better Versus Infected AI
		{
			// If the game is L4D 2...
			if (L4D2Version)
			{
				SetConVarInt(FindConVar("z_smoker_limit"), 0);
				SetConVarInt(FindConVar("z_boomer_limit"), 0);
				SetConVarInt(FindConVar("z_hunter_limit"), 0);
				SetConVarInt(FindConVar("z_spitter_limit"), 0);
				SetConVarInt(FindConVar("z_jockey_limit"), 0);
				SetConVarInt(FindConVar("z_charger_limit"), 0);
				SetConVarInt(FindConVar("z_jockey_leap_time"), 0);
				SetConVarInt(FindConVar("z_spitter_max_wait_time"), 0);
			}
			else
			{
				SetConVarInt(FindConVar("z_gas_limit"), 999);
				SetConVarInt(FindConVar("z_exploding_limit"), 999);
				SetConVarInt(FindConVar("z_hunter_limit"), 999);
			}
			// Enhance Special Infected AI
			SetConVarInt(FindConVar("hunter_leap_away_give_up_range"), 0);
			SetConVarInt(FindConVar("z_hunter_lunge_distance"), 5000);
			SetConVarInt(FindConVar("hunter_pounce_ready_range"), 1500);
			SetConVarFloat(FindConVar("hunter_pounce_loft_rate"), 0.055);
			if (g_bVersusCoop)
				SetConVarInt(FindConVar("vs_max_team_switches"), 0);
		}
		case 3: // Survival, Turns off the ability for the director to spawn infected bots in survival, MI 5
		{
			if (L4D2Version)
			{
				SetConVarInt(FindConVar("survival_max_smokers"), 0);
				SetConVarInt(FindConVar("survival_max_boomers"), 0);
				SetConVarInt(FindConVar("survival_max_hunters"), 0);
				SetConVarInt(FindConVar("survival_max_spitters"), 0);
				SetConVarInt(FindConVar("survival_max_jockeys"), 0);
				SetConVarInt(FindConVar("survival_max_chargers"), 0);
				SetConVarInt(FindConVar("survival_max_specials"), g_iMaxPlayerZombies);
				SetConVarInt(FindConVar("z_smoker_limit"), 0);
				SetConVarInt(FindConVar("z_boomer_limit"), 0);
				SetConVarInt(FindConVar("z_hunter_limit"), 0);
				SetConVarInt(FindConVar("z_spitter_limit"), 0);
				SetConVarInt(FindConVar("z_jockey_limit"), 0);
				SetConVarInt(FindConVar("z_charger_limit"), 0);
			}
			else
			{
				SetConVarInt(FindConVar("holdout_max_smokers"), 0);
				SetConVarInt(FindConVar("holdout_max_boomers"), 0);
				SetConVarInt(FindConVar("holdout_max_hunters"), 0);
				SetConVarInt(FindConVar("holdout_max_specials"), g_iMaxPlayerZombies);
				SetConVarInt(FindConVar("z_gas_limit"), 0);
				SetConVarInt(FindConVar("z_exploding_limit"), 0);
				SetConVarInt(FindConVar("z_hunter_limit"), 0);
			}
			SetConVarInt(FindConVar("z_scrimmage_sphere"), 0);
		}
	}
	
	//Some cvar tweaks
	SetConVarInt(FindConVar("z_attack_flow_range"), 50000);
	SetConVarInt(FindConVar("director_spectate_specials"), 1);
	SetConVarInt(FindConVar("z_spawn_flow_limit"), 50000);
	if (L4D2Version)
	{
		SetConVarInt(FindConVar("versus_special_respawn_interval"), 99999999);
	}
	#if DEBUG
	LogMessage("Tweaking Settings");
	#endif
	
}

void ResetCvars()
{
	#if DEBUG
	LogMessage("Plugin Cvars Reset");
	#endif

	if (GameMode == 1)
	{
		ResetConVar(FindConVar("z_scrimmage_sphere"), true, true);
		if (L4D2Version)
		{
			ResetConVar(FindConVar("survival_max_smokers"), true, true);
			ResetConVar(FindConVar("survival_max_boomers"), true, true);
			ResetConVar(FindConVar("survival_max_hunters"), true, true);
			ResetConVar(FindConVar("survival_max_spitters"), true, true);
			ResetConVar(FindConVar("survival_max_jockeys"), true, true);
			ResetConVar(FindConVar("survival_max_chargers"), true, true);
			ResetConVar(FindConVar("survival_max_specials"), true, true);
		}
		else
		{
			ResetConVar(FindConVar("holdout_max_smokers"), true, true);
			ResetConVar(FindConVar("holdout_max_boomers"), true, true);
			ResetConVar(FindConVar("holdout_max_hunters"), true, true);
			ResetConVar(FindConVar("holdout_max_specials"), true, true);
		}
	}
	else if (GameMode == 2)
	{
		if (L4D2Version)
		{
			ResetConVar(FindConVar("survival_max_smokers"), true, true);
			ResetConVar(FindConVar("survival_max_boomers"), true, true);
			ResetConVar(FindConVar("survival_max_hunters"), true, true);
			ResetConVar(FindConVar("survival_max_spitters"), true, true);
			ResetConVar(FindConVar("survival_max_jockeys"), true, true);
			ResetConVar(FindConVar("survival_max_chargers"), true, true);
			ResetConVar(FindConVar("survival_max_specials"), true, true);
		}
		else
		{
			ResetConVar(FindConVar("holdout_max_smokers"), true, true);
			ResetConVar(FindConVar("holdout_max_boomers"), true, true);
			ResetConVar(FindConVar("holdout_max_hunters"), true, true);
			ResetConVar(FindConVar("holdout_max_specials"), true, true);
		}
	}
	else if (GameMode == 3)
	{
		if (L4D2Version)
		{
			ResetConVar(FindConVar("z_smoker_limit"), true, true);
			ResetConVar(FindConVar("z_boomer_limit"), true, true);
			ResetConVar(FindConVar("z_hunter_limit"), true, true);
			ResetConVar(FindConVar("z_spitter_limit"), true, true);
			ResetConVar(FindConVar("z_jockey_limit"), true, true);
			ResetConVar(FindConVar("z_charger_limit"), true, true);
			ResetConVar(FindConVar("z_jockey_leap_time"), true, true);
			ResetConVar(FindConVar("z_spitter_max_wait_time"), true, true);
		}
		else
		{
			ResetConVar(FindConVar("z_gas_limit"), true, true);
			ResetConVar(FindConVar("z_exploding_limit"), true, true);
			ResetConVar(FindConVar("z_hunter_limit"), true, true);
		}
		ResetConVar(FindConVar("hunter_leap_away_give_up_range"), true, true);
		ResetConVar(FindConVar("z_hunter_lunge_distance"), true, true);
		ResetConVar(FindConVar("hunter_pounce_ready_range"), true, true);
		ResetConVar(FindConVar("hunter_pounce_loft_rate"), true, true);
		ResetConVar(FindConVar("z_scrimmage_sphere"), true, true);
	}
}

public Action evtRoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	// If round has started ...
	if (b_HasRoundStarted)
		return;

	b_LeftSaveRoom = false;
	b_HasRoundEnded = false;

	if(!b_HasRoundStarted && g_iPlayerSpawn == 1)
	{
		CreateTimer(0.5, PluginStart);
	}

	b_HasRoundStarted = true;
}

public Action PluginStart(Handle timer)
{
	//Check the GameMode
	GameModeCheck();
	
	if (GameMode == 0)
		return;

	for (int i = 1; i <= MaxClients; i++)
	{
		respawnDelay[i] = 0;
		PlayerLifeState[i] = false;
		TankWasSeen[i] = false;
		AlreadyGhosted[i] = false;
	}

	//reset some variables
	InfectedBotQueue = 0;
	TanksPlaying = 0;
	BotReady = 0;
	FinaleStarted = false;
	InitialSpawn = false;
	TempBotSpawned = false;
	SurvivalVersus = false;

	// Added a delay to setting MaxSpecials so that it would set correctly when the server first starts up
	CreateTimer(0.4, MaxSpecialsSet);
	
	// This little part is needed because some events just can't execute when another round starts.
	if (GameMode == 2 && g_bVersusCoop)
	{
		for (int i=1; i<=MaxClients; i++)
		{
			// We check if player is in game
			if (!IsClientInGame(i)) continue;
			// Check if client is survivor ...
			if (GetClientTeam(i)==TEAM_SURVIVORS)
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
	if (GameMode != 2)
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
					if (g_bJoinableTeams && g_bJoinableTeamsAnnounce)
					{
						CreateTimer(10.0, AnnounceJoinInfected, i, TIMER_FLAG_NO_MAPCHANGE);
					}
					if (IsPlayerGhost(i))
					{
						CreateTimer(0.1, Timer_InfectedKillSelf, i, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
	
	// Check the Tank's health to properly display it in the HUD
	TankHealthCheck();
	// Start up TweakSettings
	TweakSettings();

	roundInProgress = true;
	if(infHUDTimer == null) infHUDTimer = CreateTimer(1.0, showInfHUD, _, TIMER_REPEAT);

	#if DEBUG
		PrintToChatAll("PluginStart()!");
	#endif
	if(PlayerLeftStartTimer == null) PlayerLeftStartTimer = CreateTimer(1.0, PlayerLeftStart, _, TIMER_REPEAT);

	if (g_bJoinableTeams && GameMode != 2 || g_bVersusCoop && GameMode == 2)
	{
		if (L4D2Version)
		{
			SetConVarInt(FindConVar("sb_all_bot_game"), 1);
			SetConVarInt(FindConVar("allow_all_bot_survivor_team"), 1);
		}
		else
		{
			SetConVarInt(FindConVar("sb_all_bot_team"), 1);
		}
	}

	iPlayersInSurvivorTeam = -1;
	if(g_bCommonLimitAdjust == true) SetConVarInt(h_common_limit_cvar, 0);
	CreateTimer(1.0,ColdDown_Timer,_,TIMER_FLAG_NO_MAPCHANGE);
}

public Action evtPlayerFirstSpawned(Event event, const char[] name, bool dontBroadcast) 
{
	// This event's purpose is to execute when a player first enters the server. This eliminates a lot of problems when changing variables setting timers on clients, among fixing many sb_all_bot_team
	// issues.
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (!client || IsFakeClient(client) || PlayerHasEnteredStart[client])
		return;
	
	#if DEBUG
		PrintToChatAll("Player has spawned for the first time");
	#endif

	// Versus Coop code, puts all players on infected at start, delay is added to prevent a weird glitch
	
	if (GameMode == 2 && g_bVersusCoop)
		CreateTimer(0.1, Timer_VersusCoopTeamChanger, client, TIMER_FLAG_NO_MAPCHANGE);
	
	// Kill the player if they are infected and its not versus (prevents survival finale bug and player ghosts when there shouldn't be)
	if (GameMode != 2)
	{
		if (GetClientTeam(client)==TEAM_INFECTED)
		{
			if (IsPlayerGhost(client))
			{
				CreateTimer(0.1, Timer_InfectedKillSelf, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		if(g_bJoinableTeams && g_bJoinableTeamsAnnounce)
		{
			CreateTimer(10.0, AnnounceJoinInfected, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	
	PlayerHasEnteredStart[client] = true;
}

public Action Timer_VersusCoopTeamChanger(Handle Timer, int client)
{
	ChangeClientTeam(client, TEAM_INFECTED);
}

public Action Timer_InfectedKillSelf(Handle Timer, int client)
{
	if( client && IsClientInGame(client) && !IsFakeClient(client) )
	{
		PrintHintText(client,"[TS] %T","Not allowed to respawn",client);
		ForcePlayerSuicide(client);
	}
}

void GameModeCheck()
{
	#if DEBUG
	LogMessage("Checking Gamemode");
	#endif
	// We determine what the gamemode is
	char GameName[16];
	h_GameMode.GetString(GameName, sizeof(GameName));
	if (StrEqual(GameName, "survival", false))
		GameMode = 3;
	else if (StrEqual(GameName, "versus", false) || StrEqual(GameName, "teamversus", false) || StrEqual(GameName, "scavenge", false) || StrEqual(GameName, "teamscavenge", false) || StrEqual(GameName, "mutation12", false) || StrEqual(GameName, "mutation13", false) || StrEqual(GameName, "mutation15", false) || StrEqual(GameName, "mutation11", false))
		GameMode = 2;
	else if (StrEqual(GameName, "coop", false) || StrEqual(GameName, "realism", false) || StrEqual(GameName, "mutation3", false) || StrEqual(GameName, "mutation9", false) || StrEqual(GameName, "mutation1", false) || StrEqual(GameName, "mutation7", false) || StrEqual(GameName, "mutation10", false) || StrEqual(GameName, "mutation2", false) || StrEqual(GameName, "mutation4", false) || StrEqual(GameName, "mutation5", false) || StrEqual(GameName, "mutation14", false))
		GameMode = 1;
	else
		GameMode = 1;
}

void TankHealthCheck()
{
	char difficulty[100];
	h_Difficulty.GetString(difficulty, sizeof(difficulty));
	
	zombieHP[6] = cvarZombieHP[6].IntValue;
	if (GameMode == 2)
	{
		zombieHP[6] = RoundToFloor(cvarZombieHP[6].IntValue * 1.5);	// Tank health is multiplied by 1.5x in VS	
	}
	else if (StrContains(difficulty, "Easy", false) != -1)  
	{
		zombieHP[6] = RoundToFloor(cvarZombieHP[6].IntValue * 0.75);
	}
	else if (StrContains(difficulty, "Normal", false) != -1)
	{
		zombieHP[6] = cvarZombieHP[6].IntValue;
	}
	else if (StrContains(difficulty, "Hard", false) != -1 || StrContains(difficulty, "Impossible", false) != -1)
	{
		zombieHP[6] = RoundToFloor(cvarZombieHP[6].IntValue * 2.0);
	}
}

public Action MaxSpecialsSet(Handle Timer)
{
	SetConVarInt(FindConVar("z_max_player_zombies"), g_iMaxPlayerZombies);
	#if DEBUG
	LogMessage("Max Player Zombies Set");
	#endif
}

public Action evtRoundEnd (Event event, const char[] name, bool dontBroadcast) 
{
	// If round has not been reported as ended ..
	if (!b_HasRoundEnded)
	{
		for( int i = 1; i <= MaxClients; i++ )
			DeleteLight(i);
			
		// we mark the round as ended
		b_HasRoundEnded = true;
		b_HasRoundStarted = false;
		b_LeftSaveRoom = false;
		roundInProgress = false;
		g_iPlayerSpawn = 0;
		
		// This spawns a Survivor Bot so that the health bonus for the bots count (L4D only)
		if (!L4D2Version && GameMode == 2 && !RealPlayersOnSurvivors() && !AllSurvivorsDeadOrIncapacitated())
		{
			int bot = CreateFakeClient("Fake Survivor");
			ChangeClientTeam(bot,TEAM_SURVIVORS);
			DispatchKeyValue(bot,"classname","SurvivorBot");
			DispatchSpawn(bot);
			
			CreateTimer(0.1,kickbot,bot);
		}
		ResetTimer();
	}
	
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

	GetSpawnDisConvars();

	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	if(StrEqual("c6m1_riverbank", sMap, false))
		g_bSpawnWitchBride = true;
}

public void OnMapEnd()
{
	b_HasRoundStarted = false;
	b_HasRoundEnded = true;
	b_LeftSaveRoom = false;
	g_iPlayerSpawn = 0;
	roundInProgress = false;
	g_bMapStarted = false;
	g_bSpawnWitchBride = false;
	iPlayersInSurvivorTeam = 0;
	ResetTimer();
}

public Action PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea() || g_bSafeSpawn)
	{	
		// We don't care who left, just that at least one did
		if (!b_LeftSaveRoom)
		{
			char GameName[16];
			h_GameMode.GetString(GameName, sizeof(GameName));
			if (StrEqual(GameName, "mutation15", false))
			{
				SurvivalVersus = true;
				SetConVarInt(FindConVar("survival_max_smokers"), 0);
				SetConVarInt(FindConVar("survival_max_boomers"), 0);
				SetConVarInt(FindConVar("survival_max_hunters"), 0);
				SetConVarInt(FindConVar("survival_max_jockeys"), 0);
				SetConVarInt(FindConVar("survival_max_spitters"), 0);
				SetConVarInt(FindConVar("survival_max_chargers"), 0);
				return Plugin_Continue; 
			}
			
			b_LeftSaveRoom = true;
			
			// We reset some settings
			canSpawnBoomer = true;
			canSpawnSmoker = true;
			canSpawnHunter = true;
			if (L4D2Version)
			{
				canSpawnSpitter = true;
				canSpawnJockey = true;
				canSpawnCharger = true;
			}
			InitialSpawn = true;
			
			// We check if we need to spawn bots
			CheckIfBotsNeeded(false);
			#if DEBUG
			LogMessage("Checking to see if we need bots");
			#endif
			CreateTimer(g_fInitialSpawn + 10.0, InitialSpawnReset, _, TIMER_FLAG_NO_MAPCHANGE);
			if(hSpawnWitchTimer == null) hSpawnWitchTimer = CreateTimer(float(GetRandomInt(g_iWitchPeriodMin, g_iWitchPeriodMax)), SpawnWitchAuto);
		}
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}



// This is hooked to the panic event, but only starts if its survival. This is what starts up the bots in survival.

public Action evtSurvivalStart(Event event, const char[] name, bool dontBroadcast) 
{
	if (GameMode == 3 || SurvivalVersus)
	{  
		// We don't care who left, just that at least one did
		if (!b_LeftSaveRoom)
		{
			#if DEBUG
			PrintToChatAll("A player triggered the survival event, spawning bots");
			#endif
			b_LeftSaveRoom = true;
			
			// We reset some settings
			canSpawnBoomer = true;
			canSpawnSmoker = true;
			canSpawnHunter = true;
			if (L4D2Version)
			{
				canSpawnSpitter = true;
				canSpawnJockey = true;
				canSpawnCharger = true;
			}
			InitialSpawn = true;
			
			// We check if we need to spawn bots
			CheckIfBotsNeeded(false);
			#if DEBUG
			LogMessage("Checking to see if we need bots");
			#endif
			CreateTimer(g_fInitialSpawn + 10.0, InitialSpawnReset, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

public Action InitialSpawnReset(Handle Timer)
{
	InitialSpawn = false;
}

public Action BotReadyReset(Handle Timer)
{
	BotReady = 0;
}

public Action evtUnlockVersusDoor(Event event, const char[] name, bool dontBroadcast) 
{
	if (L4D2Version || b_LeftSaveRoom || GameMode != 2 || RealPlayersOnInfected() || TempBotSpawned)
		return Plugin_Continue;
	
	#if DEBUG
	PrintToChatAll("Attempting to spawn tempbot");
	#endif
	int bot = CreateFakeClient("tempbot");
	if (bot != 0)
	{
		ChangeClientTeam(bot,TEAM_INFECTED);
		CreateTimer(0.1,kickbot,bot);
		TempBotSpawned = true;
	}
	else
	{
		LogError("Temperory Infected Bot was not spawned for the Versus Door Unlocker!");
	}
	
	return Plugin_Continue;
}

public Action InfectedBotBooterVersus(Handle Timer)
{
	//This is to check if there are any extra bots and boot them if necessary, excluding tanks, versus only
	if (GameMode == 2)
	{
		// current count ...
		int total;
		
		for (int i=1; i<=MaxClients; i++)
		{
			// if player is ingame ...
			if (IsClientInGame(i))
			{
				// if player is on infected's team
				if (GetClientTeam(i) == TEAM_INFECTED)
				{
					// We count depending on class ...
					if (!IsPlayerTank(i) || (IsPlayerTank(i) && !PlayerIsAlive(i)))
					{
						total++;
					}
				}
			}
		}
		if (total + InfectedBotQueue > g_iMaxPlayerZombies)
		{
			int kick = total + InfectedBotQueue - g_iMaxPlayerZombies; 
			int kicked = 0;
			
			// We kick any extra bots ....
			for (int i=1;(i<=MaxClients)&&(kicked < kick);i++)
			{
				// If player is infected and is a bot ...
				if (IsClientInGame(i) && IsFakeClient(i))
				{
					//  If bot is on infected ...
					if (GetClientTeam(i) == TEAM_INFECTED)
					{
						// If player is not a tank
						if (!IsPlayerTank(i) || ((IsPlayerTank(i) && !PlayerIsAlive(i))))
						{
							// timer to kick bot
							CreateTimer(0.1,kickbot,i);
							
							// increment kicked count ..
							kicked++;
							#if DEBUG
							LogMessage("Kicked a Bot");
							#endif
						}
					}
				}
			}
		}
	}
}

// This code, combined with Durzel's code, announce certain messages to clients when they first enter the server

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	// If is a bot, skip this function
	if (IsFakeClient(client))
		return;

	iPlayerTeam[client] = 1;
	
	// Durzel's code ***********************************************************************************
	char clientSteamID[32];
	int doHideHUD;
	
//	GetClientAuthString(client, clientSteamID, 32);
	
	// Try and find their HUD visibility preference
	int foundKey = GetTrieValue(usrHUDPref, clientSteamID, doHideHUD);
	if (foundKey)
	{
		if (doHideHUD)
		{
			// This user chose not to view the HUD at some point in the game
			hudDisabled[client] = 1;
		}
	}
	//else hudDisabled[client] = 1;
	// End Durzel's code **********************************************************************************
}

public Action CheckGameMode(int client, int args)
{
	if (client)
	{
		PrintToChat(client, "GameMode = %i", GameMode);
	}
}

public Action CheckQueue(int client, int args)
{
	if (client)
	{
		if (GameMode == 2)
			CountInfected();
		else
		CountInfected_Coop();
		
		PrintToChat(client, "InfectedBotQueue = %i, InfectedBotCount = %i, InfectedRealCount = %i", InfectedBotQueue, InfectedBotCount, InfectedRealCount);
	}
}

public Action JoinInfected(int client, int args)
{	
	if (client && (GameMode == 1 || GameMode == 3) && g_bJoinableTeams)
	{
		if ((g_bAdminJoinInfected && IsPlayerGenericAdmin(client)) || !g_bAdminJoinInfected)
		{
			if (HumansOnInfected() < g_iHumanCoopLimit)
			{
				ChangeClientTeam(client, TEAM_INFECTED);
				iPlayerTeam[client] = TEAM_INFECTED;
			}
			else
				PrintHintText(client, "The Infected Team is full.");
		}
	}
}

public Action JoinSurvivors(int client, int args)
{
	if (client && (GameMode == 1 || GameMode == 3))
	{
		SwitchToSurvivors(client);
	}
}

public Action ForceInfectedSuicide(int client, int args)
{
	if (client && GetClientTeam(client) == 3 && !IsFakeClient(client) && IsPlayerAlive(client) && !IsPlayerGhost(client))
	{
		int bGameMode = GameMode;
		if(bGameMode == 3) bGameMode = 4;
		if(bGameMode & g_iZSDisableGamemode)
		{
			PrintHintText(client,"[TS] %T","Not allowed to suicide during current mode",client);
			return Plugin_Handled;
		}

		if(GetEngineTime() - fPlayerSpawnEngineTime[client] < SUICIDE_TIME)
		{
			PrintHintText(client,"[TS] %T","Not allowed to suicide so quickly",client);
			return Plugin_Handled;
		}

		if( L4D2_GetSurvivorVictim(client) != -1 )
		{
			PrintHintText(client,"[TS] %T","Not allowed to suicide",client);
			return Plugin_Handled;
		}
		
		ForcePlayerSuicide(client);
	}

	return Plugin_Handled;
}

public Action Console_ZLimit(int client, int args)
{
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
		ReplyToCommand(client, "[TS] %T\n%T","Current Special Infected Limit",client, g_iMaxPlayerZombies,"Usage: sm_zlimit",client);	
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
		else if(newlimit!=g_iMaxPlayerZombies)
		{
			g_iMaxPlayerZombies = newlimit;
			CreateTimer(0.1, MaxSpecialsSet);
			C_PrintToChatAll("[{olive}TS{default}] {lightgreen}%N{default}: %t", client, "Special Infected Limit has been changed",newlimit);	
		}
		else
		{
			ReplyToCommand(client, "[TS] %T","Special Infected Limit is already",client, g_iMaxPlayerZombies);	
		}
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[TS] %T","Usage: sm_zlimit",client);		
		return Plugin_Handled;
	}	
}

public Action Console_Timer(int client, int args)
{
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
		ReplyToCommand(client, "[TS] %T\n%T","Current Spawn Timer",client,g_iInfectedSpawnTimeMax,g_iInfectedSpawnTimeMin,"Usage: sm_timer",client );	
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
				SetConVarInt(FindConVar("l4d_infectedbots_adjust_spawn_times"), 0);
				SetConVarInt(FindConVar("l4d_infectedbots_spawn_time_max"), DD);
				SetConVarInt(FindConVar("l4d_infectedbots_spawn_time_min"), DD);
				C_PrintToChatAll("[{olive}TS{default}] {lightgreen}%N{default}: %t",client,"Bot Spawn Timer has been changed",DD,DD);	
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
				SetConVarInt(FindConVar("l4d_infectedbots_adjust_spawn_times"), 0);
				SetConVarInt(FindConVar("l4d_infectedbots_spawn_time_max"), Max);
				SetConVarInt(FindConVar("l4d_infectedbots_spawn_time_min"), Min);
				C_PrintToChatAll("[{olive}TS{green}] {lightgreen}%N{default}: %t",client,"Bot Spawn Timer has been changed",Min,Max);	
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

// Joining spectators is for developers only, commented in the final

public Action JoinSpectator(int client, int args)
{
	if ((client) && (g_bJoinableTeams))
	{
		ChangeClientTeam(client, TEAM_SPECTATOR);
	}
}

public Action AnnounceJoinInfected(Handle timer, int client)
{
	if (IsClientInGame(client) && (!IsFakeClient(client)))
	{
		if (g_bJoinableTeamsAnnounce && g_bJoinableTeams && GameMode != 2)
		{
			if(g_bAdminJoinInfected)
				C_PrintToChat(client,"[{olive}TS{default}] %T","Join infected team in coop/survival/realism(adm only)",client);
			else
				C_PrintToChat(client,"[{olive}TS{default}] %T","Join infected team in coop/survival/realism",client);
			C_PrintToChat(client,"%T","Join survivor team",client);
		}
	}
}

public Action evtPlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	// We get the client id and time
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	// If client is valid
	if (!client || !IsClientInGame(client)) return Plugin_Continue;
	
	if(GetClientTeam(client) == TEAM_SURVIVORS)
	{
		RemoveSurvivorModelGlow(client);
		CreateTimer(0.3, tmrDelayCreateSurvivorGlow, userid);
		CreateTimer(1.0, ColdDown_Timer,_,TIMER_FLAG_NO_MAPCHANGE);
	}

	if (GetClientTeam(client) != TEAM_INFECTED)
		return Plugin_Continue;
	
	if (IsPlayerTank(client))
	{
		char clientname[256];
		GetClientName(client, clientname, sizeof(clientname));
		if (L4D2Version && GameMode == 1 && IsFakeClient(client) && RealPlayersOnInfected() && StrContains(clientname, "Bot", false) == -1)
		{
			CreateTimer(0.1, TankBugFix, client);
		}
		if (b_LeftSaveRoom)
		{	
			#if DEBUG
			LogMessage("Tank Event Triggered");
			#endif

			TanksPlaying = 0;
			MaxPlayerTank = 0;
			for (int i=1;i<=MaxClients;i++)
			{
				// We check if player is in game
				if (!IsClientInGame(i)) continue;
				
				// Check if client is infected ...
				if (GetClientTeam(i)==TEAM_INFECTED)
				{
					// If player is a tank
					if (IsPlayerTank(i) && PlayerIsAlive(i))
					{
						TanksPlaying++;
						MaxPlayerTank++;
					}
				}
			}
			
			MaxPlayerTank = MaxPlayerTank + g_iMaxPlayerZombies;
			SetConVarInt(FindConVar("z_max_player_zombies"), MaxPlayerTank);
			#if DEBUG
			LogMessage("Incremented Max Zombies from Tank Spawn EVENT");
			#endif
			
			if (GameMode == 3)
			{
				if (IsFakeClient(client) && RealPlayersOnInfected())
				{
					if (L4D2Version && !AreTherePlayersWhoAreNotTanks() && g_bCoopPlayableTank && StrContains(clientname, "Bot", false) == -1 || L4D2Version && !g_bCoopPlayableTank && StrContains(clientname, "Bot", false) == -1)
					{
						CreateTimer(0.1, TankBugFix, client);
					}
					else if (g_bCoopPlayableTank && AreTherePlayersWhoAreNotTanks())
					{
						CreateTimer(0.5, TankSpawner, client);
						CreateTimer(0.6, kickbot, client);
					}
				}
			}
			else
			{
				MaxPlayerTank = g_iMaxPlayerZombies;
				SetConVarInt(FindConVar("z_max_player_zombies"), g_iMaxPlayerZombies);
			}
		}
	}
	else if (IsFakeClient(client))
	{
		delete FightOrDieTimer[client];
		FightOrDieTimer[client] = CreateTimer(g_fIdletime_b4slay, DisposeOfCowards, client);
	}

	// Turn on Flashlight for Infected player
	TurnFlashlightOn(client);
	
	// If its Versus and the bot is not a tank, make the bot into a ghost
	if (IsFakeClient(client) && GameMode == 2 && !IsPlayerTank(client))
		CreateTimer(0.1, Timer_SetUpBotGhost, client, TIMER_FLAG_NO_MAPCHANGE);


	return Plugin_Continue;
}

public Action evtBotReplacedPlayer(Event event, const char[] name, bool dontBroadcast) 
{
	// The purpose of using this event, is to prevent a bot from ghosting after the player leaves or joins another team
	
	int bot = GetClientOfUserId(event.GetInt("bot"));
	AlreadyGhostedBot[bot] = true;
}

public Action DisposeOfCowards(Handle timer, int coward)
{
	if (coward && IsClientInGame(coward) && IsFakeClient(coward) && GetClientTeam(coward) == TEAM_INFECTED && !IsPlayerTank(coward) && PlayerIsAlive(coward))
	{
		// Check to see if the infected thats about to be slain sees the survivors. If so, kill the timer and make a int one.
		if (GetEntProp(coward, Prop_Send, "m_hasVisibleThreats") || L4D2_GetSurvivorVictim(coward) != -1)
		{
			FightOrDieTimer[coward] = null;
			FightOrDieTimer[coward] = CreateTimer(g_fIdletime_b4slay, DisposeOfCowards, coward);
			return;
		}
		else
		{
			CreateTimer(0.1, kickbot, coward);	
			//PrintToChatAll("Kicked bot %N for not attacking", coward);
		}
	}
	FightOrDieTimer[coward] = null;
}

public Action Timer_SetUpBotGhost(Handle timer, int client)
{
	// This will set the bot a ghost, stop the bot's movement, and waits until it can spawn
	if (IsValidEntity(client))
	{
		if (!AlreadyGhostedBot[client])
		{
			SetGhostStatus(client, true);
			SetEntityMoveType(client, MOVETYPE_NONE);
			CreateTimer(h_BotGhostTime.FloatValue, Timer_RestoreBotGhost, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
			AlreadyGhostedBot[client] = false;
	}
}

public Action Timer_RestoreBotGhost(Handle timer, int client)
{
	if (IsValidEntity(client))
	{
		SetGhostStatus(client, false);
		SetEntityMoveType(client, MOVETYPE_WALK);
	}
}

public Action evtPlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	// We get the client id and time
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client) DeleteLight(client); // Delete attached flashlight

	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS) 
	{
		RemoveSurvivorModelGlow(client);
		CreateTimer(1.0,ColdDown_Timer,_,TIMER_FLAG_NO_MAPCHANGE);
	}

	// If round has ended .. we ignore this
	if (b_HasRoundEnded || !b_LeftSaveRoom) return Plugin_Continue;
	
	delete FightOrDieTimer[client];
	delete RestoreColorTimer[client];
	
	
	if (!client || !IsClientInGame(client)) return Plugin_Continue;
	
	if (GetClientTeam(client) !=TEAM_INFECTED) return Plugin_Continue;
	
	if (IsPlayerTank(client))
	{
		TankWasSeen[client] = false;
	}
	
	// if victim was a bot, we setup a timer to spawn a int bot ...
	if (GetEventBool(event, "victimisbot") && GameMode == 2)
	{
		if (!IsPlayerTank(client))
		{
			int SpawnTime = GetRandomInt(g_iInfectedSpawnTimeMin, g_iInfectedSpawnTimeMax);
			if (g_bAdjustSpawnTimes && g_iMaxPlayerZombies != HumansOnInfected())
				SpawnTime = SpawnTime  - (TrueNumberOfAliveSurvivors() * g_iReducedSpawnTimesOnPlayer);
			
			if(SpawnTime < 0)
				SpawnTime = 1;
			#if DEBUG
			PrintToChatAll("playerdeath");
			#endif
			CreateTimer(float(SpawnTime), Spawn_InfectedBot, _, 0);
			InfectedBotQueue++;
		}
		
		#if DEBUG
		PrintToChatAll("An infected bot has been added to the spawn queue...");
		#endif
	}
	// This spawns a bot in coop/survival regardless if the special that died was controlled by a player, MI 5
	else if (GameMode != 2)
	{
		int SpawnTime = GetRandomInt(g_iInfectedSpawnTimeMin, g_iInfectedSpawnTimeMax);
		if (GameMode == 1 && g_bAdjustSpawnTimes)
			SpawnTime = SpawnTime - (TrueNumberOfAliveSurvivors() * g_iReducedSpawnTimesOnPlayer);
			
		if(!IsFakeClient(client)) 
		{
			SpawnTime = g_iInfectedSpawnTimeMin - TrueNumberOfAliveSurvivors() * g_iReducedSpawnTimesOnPlayer + (HumansOnInfected() - 1) * 3;
			if(SpawnTime <= 10)
				SpawnTime = 10;
		}

		if(SpawnTime <= 0)
			SpawnTime = 1;
		#if DEBUG
		PrintToChatAll("playerdeath2");
		#endif
		CreateTimer(float(SpawnTime), Spawn_InfectedBot);
		GetSpawnTime[client] = SpawnTime;
		InfectedBotQueue++;
		
		#if DEBUG
		PrintToChatAll("An infected bot has been added to the spawn queue...");
		#endif
	}
	
	//This will prevent the stats board from coming up if the cvar was set to 1 (L4D 1 only)
	if (!L4D2Version && !IsFakeClient(client) && h_StatsBoard.BoolValue == false && GameMode != 2)
	{
		CreateTimer(1.0, ZombieClassTimer, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// Removes Sphere bubbles in the map when a player dies
	if (GameMode != 2)
	{
		CreateTimer(0.1, ScrimmageTimer, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	// This fixes the spawns when the spawn timer is set to 5 or below and fixes the spitter spit glitch
	if (IsFakeClient(client) && !IsPlayerSpitter(client))
		CreateTimer(0.1, kickbot, client);
	
	return Plugin_Continue;
}

public Action ZombieClassTimer(Handle timer, int client)
{
	if (client)
	{
		SetEntProp(client, Prop_Send, "m_zombieClass", 0);
	}
}

public Action evtPlayerTeam(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	RemoveSurvivorModelGlow(client);
	CreateTimer(0.1, tmrDelayCreateSurvivorGlow, userid);

	CreateTimer(1.0, PlayerChangeTeamCheck,userid);//延遲一秒檢查

	// If player is a bot, we ignore this ...
	if (GetEventBool(event, "isbot")) return Plugin_Continue;
	
	// We get some data needed ...
	int newteam = event.GetInt("team");
	int oldteam = event.GetInt("oldteam");
	
	// We get the client id and time
	if(client) DeleteLight(client);

	// If player's new/old team is infected, we recount the infected and add bots if needed ...
	if (!b_HasRoundEnded && b_LeftSaveRoom && GameMode == 2)
	{
		if (oldteam == 3||newteam == 3)
		{
			CheckIfBotsNeeded(false);
		}
		if (newteam == 3)
		{
			//Kick Timer
			CreateTimer(1.0, InfectedBotBooterVersus, _, TIMER_FLAG_NO_MAPCHANGE);
			#if DEBUG
			LogMessage("A player switched to infected, attempting to boot a bot");
			#endif
		}
	}
	else if ((newteam == 3 || newteam == 1) && GameMode != 2)
	{
		// Removes Sphere bubbles in the map when a player joins the infected team, or spectator team
		
		CreateTimer(0.1, ScrimmageTimer, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Continue;
}

public Action PlayerChangeTeamCheck(Handle timer,int userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && !IsFakeClient(client))
	{
		CreateTimer(1.0,ColdDown_Timer,_,TIMER_FLAG_NO_MAPCHANGE);

		if(GameMode != 2)
		{
			int iTeam = GetClientTeam(client);
			if(iTeam == TEAM_INFECTED)
			{
				if(iPlayerTeam[client] != TEAM_INFECTED) 
				{
					ChangeClientTeam(client,TEAM_SPECTATOR);
					FakeClientCommand(client,"sm_js");
					return Plugin_Continue;
				}

				if(g_bJoinableTeams)
				{
					if((g_bAdminJoinInfected && IsPlayerGenericAdmin(client)) || !g_bAdminJoinInfected)
					{
						if (HumansOnInfected() <= g_iHumanCoopLimit)
						{
							if(L4D2Version)
							{
								//PrintToChatAll("%N Fake versus convar",client);
								SendConVarValue(client, h_GameMode, "versus");
								if(bDisableSurvivorModelGlow == true)
								{
									bDisableSurvivorModelGlow = false;
									for( int i = 1; i <= MaxClients; i++ )
									{
										CreateSurvivorModelGlow(i);
									}
								}
							}

							return Plugin_Continue;
						}
					}
				}
				else
				{
					PrintHintText(client, "%T", "Can't Join The Infected Team.", client);
				}
				ChangeClientTeam(client,TEAM_SPECTATOR);
			}
			else
			{
				iPlayerTeam[client] = iTeam;
				if(L4D2Version)
				{
					static char mode[64];
					h_GameMode.GetString(mode, sizeof(mode));
					SendConVarValue(client, h_GameMode, mode);

					if(!RealPlayersOnInfected() && bDisableSurvivorModelGlow == false)
					{
						bDisableSurvivorModelGlow = true;
						for( int i = 1; i <= MaxClients; i++ )
						{
							RemoveSurvivorModelGlow(i);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
public Action ColdDown_Timer(Handle timer)
{
	int iAliveSurplayers = CheckAliveSurvivorPlayers_InSV();

	if(iAliveSurplayers >= 0 && iAliveSurplayers != iPlayersInSurvivorTeam)
	{
		int addition = iAliveSurplayers - 4;
		if(addition < 0) addition = 0;
		
		if(h_PlayerAddZombies.IntValue > 0) 
		{
			g_iMaxPlayerZombies = h_MaxPlayerZombies.IntValue + (h_PlayerAddZombies.IntValue * (addition/h_PlayerAddZombiesScale.IntValue));
			CreateTimer(0.1, MaxSpecialsSet);
		}
		if(g_bTankHealthAdjust)
		{
			SetConVarInt(cvarZombieHP[6], g_iTankHealth + (h_PlayerAddTankHealth.IntValue * (addition/h_PlayerAddTankHealthScale.IntValue)));
			if(g_bCommonLimitAdjust)
			{
				SetConVarInt(h_common_limit_cvar, g_iCommonLimit + (h_PlayerAddCommonLimit.IntValue * (addition/h_PlayerAddCommonLimitScale.IntValue)));
				C_PrintToChatAll("[{olive}TS{default}] %t","Current status1",iAliveSurplayers,g_iMaxPlayerZombies,cvarZombieHP[6].IntValue,h_common_limit_cvar.IntValue);
			}
			else
			{
				SetConVarInt(h_common_limit_cvar, g_iCommonLimit);
				C_PrintToChatAll("[{olive}TS{default}] %t","Current status3",iAliveSurplayers,g_iMaxPlayerZombies,cvarZombieHP[6].IntValue);
			}
		}
		else
		{
			if(g_bCommonLimitAdjust)
			{
				SetConVarInt(h_common_limit_cvar, g_iCommonLimit + h_PlayerAddCommonLimit.IntValue * (addition/h_PlayerAddCommonLimitScale.IntValue));
				C_PrintToChatAll("[{olive}TS{default}] %t","Current status2",iAliveSurplayers,g_iMaxPlayerZombies,h_common_limit_cvar.IntValue);
			}
			else
			{
				SetConVarInt(h_common_limit_cvar, g_iCommonLimit);
				C_PrintToChatAll("[{olive}TS{default}] %t","Current status4",iAliveSurplayers,g_iMaxPlayerZombies);	
			}
		}
		iPlayersInSurvivorTeam = iAliveSurplayers;
	}
}

public void OnClientDisconnect(int client)
{
	delete FightOrDieTimer[client];
	delete RestoreColorTimer[client];

	RemoveSurvivorModelGlow(client);
	
	if(roundInProgress == false) return;
		
	if(IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS)
		CreateTimer(1.0,ColdDown_Timer,_,TIMER_FLAG_NO_MAPCHANGE);

	if (IsClientInGame(client) && GetClientTeam(client) == TEAM_INFECTED && IsPlayerAlive(client))
	{
		char name[MAX_NAME_LENGTH];
		GetClientName(client, name, sizeof(name));

		int SpawnTime = GetRandomInt(g_iInfectedSpawnTimeMin, g_iInfectedSpawnTimeMax);
		if (g_bAdjustSpawnTimes)
			SpawnTime = SpawnTime - (TrueNumberOfAliveSurvivors() * g_iReducedSpawnTimesOnPlayer);
		
		if(SpawnTime<=0)
			SpawnTime = 1;
		#if DEBUG
		PrintToChatAll("OnClientDisconnect");
		#endif
		CreateTimer(float(SpawnTime), Spawn_InfectedBot);
		InfectedBotQueue++;
	}

	if (IsFakeClient(client))
		return;
	
	iPlayerTeam[client] = 1;
	// When a client disconnects we need to restore their HUD preferences to default for when 
	// a int client joins and fill the space.
	hudDisabled[client] = 0;
	clientGreeted[client] = 0;
	
	// Reset all other arrays
	respawnDelay[client] = 0;
	WillBeTank[client] = false;
	PlayerLifeState[client] = false;
	GetSpawnTime[client] = 0;
	TankWasSeen[client] = false;
	AlreadyGhosted[client] = false;
	PlayerHasEnteredStart[client] = false;
}

public Action ScrimmageTimer (Handle timer, int client)
{
	if (client && IsValidEntity(client))
	{
		SetEntProp(client, Prop_Send, "m_scrimmageType", 0);
	}
}

public Action CheckIfBotsNeededLater (Handle timer, bool spawn_immediately)
{
	CheckIfBotsNeeded(spawn_immediately);
}

void CheckIfBotsNeeded(bool spawn_immediately)
{
	if (b_HasRoundEnded || !b_LeftSaveRoom ) return;

	#if DEBUG
		PrintToChatAll("Checking bots");
	#endif 

	// First, we count the infected
	if (GameMode == 2)
	{
		CountInfected();
	}
	else
	{
		CountInfected_Coop();
	}
	
	// If we need more infected bots
	if ( (g_iMaxPlayerZombies - (InfectedBotCount + InfectedRealCount + InfectedBotQueue)) > 0)
	{
		if (spawn_immediately)
		{
			InfectedBotQueue++;
			#if DEBUG
			PrintToChatAll("spawn_immediately");
			#endif
			CreateTimer(0.1, Spawn_InfectedBot);
			#if DEBUG
			LogMessage("Setting up the bot now");
			#endif
		}
		else if (InitialSpawn) //round start first spawn 
		{
			InfectedBotQueue++;
			#if DEBUG
			PrintToChatAll("initial_spawn");
			#endif
			CreateTimer(g_fInitialSpawn, Spawn_InfectedBot);
			#if DEBUG
				PrintToChatAll("Setting up the initial bot now");
			#endif
		}
		else // server can't find a valid position, we use the normal time ..
		{
			#if DEBUG
			PrintToChatAll("InfectedBotQueue++");
			#endif
			InfectedBotQueue++;
			int SpawnTime = GetRandomInt(g_iInfectedSpawnTimeMin, g_iInfectedSpawnTimeMax);
			/*
			if (GameMode == 2 && g_bAdjustSpawnTimes)
				CreateTimer(float(SpawnTime - (TrueNumberOfAliveSurvivors() * g_iReducedSpawnTimesOnPlayer) ), Spawn_InfectedBot, _, 0);
			else if (GameMode == 1 && g_bAdjustSpawnTimes)
				CreateTimer(float(SpawnTime - (TrueNumberOfAliveSurvivors() * g_iReducedSpawnTimesOnPlayer) ), Spawn_InfectedBot, _, 0);
			else
				CreateTimer(float(SpawnTime), Spawn_InfectedBot);
			*/
			CreateTimer(float(SpawnTime), Spawn_InfectedBot);
		}
	}
}

void CountInfected()
{
	// reset counters
	InfectedBotCount = 0;
	InfectedRealCount = 0;
	
	// First we count the ammount of infected real players and bots
	for (int i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is infected ...
		if (GetClientTeam(i) == TEAM_INFECTED)
		{
			// If player is a bot ...
			if (IsFakeClient(i))
				InfectedBotCount++;
			else
			InfectedRealCount++;
		}
	}
	
}

// Note: This function is also used for coop/survival.
void CountInfected_Coop()
{
	#if DEBUG
	LogMessage("Counting Bots for Coop");
	#endif
	
	// reset counters
	InfectedBotCount = 0;
	InfectedRealCount = 0;
	
	// First we count the ammount of infected real players and bots
	
	for (int i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is infected ...
		if (GetClientTeam(i) == TEAM_INFECTED)
		{
			char name[MAX_NAME_LENGTH];
			
			GetClientName(i, name, sizeof(name));
			
			// If someone is a tank and the tank is playable...count him in play
			if (IsPlayerTank(i) && PlayerIsAlive(i) && g_bCoopPlayableTank && !IsFakeClient(i))
			{
				InfectedRealCount++;
			}
			
			// If player is a bot ...
			if (IsFakeClient(i))
			{
				InfectedBotCount++;
				#if DEBUG
				LogMessage("Found a bot");
				#endif
			}
			else if (PlayerIsAlive(i) || (IsPlayerGhost(i)))
			{
				InfectedRealCount++;
				#if DEBUG
				LogMessage("Found a player");
				#endif
			}
		}
	}
}

public Action Event_WitchSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int witch = event.GetInt("witchid");
	CreateTimer(g_fWitchKillTime,KickWitch_Timer,EntIndexToEntRef(witch),TIMER_FLAG_NO_MAPCHANGE);
}

public Action Event_Incap(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client && !IsClientInGame(client) && GetClientTeam(client) != TEAM_SURVIVORS) return;

	int entity = g_iModelIndex[client];
	if( IsValidEntRef(entity) )
	{
		SetEntProp(entity, Prop_Send, "m_glowColorOverride", 180 + (0 * 256) + (0 * 65536)); //Red
	}
}

public Action Event_revive_success(Event event, const char[] name, bool dontBroadcast)
{
	int subject = GetClientOfUserId(GetEventInt(event, "subject"));//被救的那位
	if(!subject && !IsClientInGame(subject) && GetClientTeam(subject) != TEAM_SURVIVORS) return;

	int entity = g_iModelIndex[subject];
	if( IsValidEntRef(entity) )
	{
		SetEntProp(entity, Prop_Send, "m_glowColorOverride", 0 + (180 * 256) + (0 * 65536)); //Green
	}
}

public Action Event_ledge_release(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client && !IsClientInGame(client) && GetClientTeam(client) != TEAM_SURVIVORS) return;

	int entity = g_iModelIndex[client];
	if( IsValidEntRef(entity) )
	{
		SetEntProp(entity, Prop_Send, "m_glowColorOverride", 0 + (180 * 256) + (0 * 65536)); //Green
	}
}

public Action Event_GotVomit(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client && !IsClientInGame(client) && GetClientTeam(client) != TEAM_SURVIVORS) return;

	int entity = g_iModelIndex[client];
	if( IsValidEntRef(entity) )
	{
		SetEntProp(entity, Prop_Send, "m_glowColorOverride", 155 + (0 * 256) + (180 * 65536)); //Purple
		
		delete RestoreColorTimer[client]; RestoreColorTimer[client] = CreateTimer(20.0, Timer_RestoreColor, client);
	}
}

public Action Timer_RestoreColor(Handle timer, int client)
{
	int entity = g_iModelIndex[client];
	if( IsValidEntRef(entity) )
	{
		if(IsplayerIncap(client)) SetEntProp(entity, Prop_Send, "m_glowColorOverride", 180 + (0 * 256) + (0 * 65536)); //RGB
		else SetEntProp(entity, Prop_Send, "m_glowColorOverride", 0 + (180 * 256) + (0 * 65536)); //RGB
	}
	RestoreColorTimer[client] = null;
}

public Action KickWitch_Timer(Handle timer, int ref)
{
	if(IsValidEntRef(ref))
	{
		int entity = EntRefToEntIndex(ref);
		if(IsWitch(entity))
		{
			bool bKill = true;
			float clientOrigin[3];
			float witchOrigin[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", witchOrigin);
			for (int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i))
				{
					GetClientAbsOrigin(i, clientOrigin);
					if (GetVectorDistance(clientOrigin, witchOrigin, true) < Pow(h_SpawnDistanceMax.FloatValue,2.0))
					{
						bKill = false;
						break;
					}
				}
			}

			if(bKill) AcceptEntityInput(ref, "kill"); //remove witch
			else CreateTimer(g_fWitchKillTime,KickWitch_Timer,EntIndexToEntRef(entity),TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}
// The main Tank code, it allows a player to take over the tank when if allowed, and adds additional tanks if the tanks per spawn cvar was set.
public Action TankSpawner(Handle timer, int client)
{
	#if DEBUG
	LogMessage("Tank Spawner Triggred");
	#endif
	int Index[8];
	int IndexCount = 0;
	float position[3];
	int tankhealth;
	bool tankonfire;
	
	if (client && IsClientInGame(client))
	{
		tankhealth = GetClientHealth(client);
		GetClientAbsOrigin(client, position);
		if (GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONFIRE && PlayerIsAlive(client))
			tankonfire = true;
	}
	
	if (g_bCoopPlayableTank)
	{
		for (int t=1;t<=MaxClients;t++)
		{
			// We check if player is in game
			if (!IsClientInGame(t)) continue;
			
			// Check if client is infected ...
			if (GetClientTeam(t)!=TEAM_INFECTED) continue;
			
			if (!IsFakeClient(t))
			{
				// If player is not a tank, or a dead one
				if (!IsPlayerTank(t) || (IsPlayerTank(t) && !PlayerIsAlive(t)))
				{
					IndexCount++; // increase count of valid targets
					Index[IndexCount] = t; //save target to index
					#if DEBUG
					PrintToChatAll("Client %i found to be valid Tank Choice", Index[IndexCount]);
					#endif
				}
			}	
		}
	}
	
	if (g_bCoopPlayableTank && IndexCount != 0 )
	{
		MaxPlayerTank--;
		#if DEBUG
		PrintToChatAll("Tank Kicked");
		#endif
		
		int tank = GetRandomInt(1, IndexCount);  // pick someone from the valid targets
		WillBeTank[Index[tank]] = true;
		
		#if DEBUG
		PrintToChatAll("Random Number pulled: %i, from %i", tank, IndexCount);
		PrintToChatAll("Client chosen to be Tank: %i", Index[tank]);
		#endif
		
		if (L4D2Version && IsPlayerJockey(Index[tank]))
		{
			// WE NEED TO DISMOUNT THE JOCKEY OR ELSE BAAAAAAAAAAAAAAAD THINGS WILL HAPPEN
			
			CheatCommand(Index[tank], "dismount");
		}
		
		ChangeClientTeam(Index[tank], TEAM_SPECTATOR);
		ChangeClientTeam(Index[tank], TEAM_INFECTED);
	}
	
	bool resetGhost[MAXPLAYERS+1];
	bool resetLife[MAXPLAYERS+1];
	
	if (g_bCoopPlayableTank && IndexCount != 0)
	{
		for (int i=1;i<=MaxClients;i++)
		{
			if ( IsClientInGame(i) && !IsFakeClient(i)) // player is connected and is not fake and it's in game ...
			{
				// If player is on infected's team and is dead ..
				if ((GetClientTeam(i)==TEAM_INFECTED) && WillBeTank[i] == false)
				{
					// If player is a ghost ....
					if (IsPlayerGhost(i))
					{
						resetGhost[i] = true;
						SetGhostStatus(i, false);
						#if DEBUG
						LogMessage("Player is a ghost, taking preventive measures to prevent the player from taking over the tank");
						#endif
					}
					else if (!PlayerIsAlive(i))
					{
						resetLife[i] = true;
						SetLifeState(i, false);
						#if DEBUG
						LogMessage("Dead player found, setting restrictions to prevent the player from taking over the tank");
						#endif
					}
				}
			}
		}
		
		// Find any human client and give client admin rights
		int anyclient = GetAnyClient();
		
		CheatCommand(anyclient, sSpawnCommand, "tank auto");
		
		// We restore the player's status
		for (int i=1;i<=MaxClients;i++)
		{
			if (resetGhost[i] == true)
				SetGhostStatus(i, true);
			if (resetLife[i] == true)
				SetLifeState(i, true);
			if (WillBeTank[i] == true)
			{
				if (client && IsClientInGame(i))
				{
					TeleportEntity(i, position, NULL_VECTOR, NULL_VECTOR);
					SetEntityHealth(i, tankhealth);
					if (tankonfire)
						CreateTimer(0.1, PutTankOnFireTimer, i, TIMER_FLAG_NO_MAPCHANGE);
					if (g_bCoopPlayableTank)
						TankWasSeen[i] = true;
				}
				WillBeTank[i] = false;
				Handle datapack = CreateDataPack();
				WritePackCell(datapack, tankhealth);
				WritePackCell(datapack, tankonfire);
				WritePackCell(datapack, i);
				CreateTimer(1.0, TankRespawner, datapack, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
			}
		}
		
		
		#if DEBUG
		if (IsPlayerTank(client) && IsFakeClient(client))
		{
			PrintToChatAll("Bot Tank Spawn Event Triggered");
		}
		else if (IsPlayerTank(client) && !IsFakeClient(client))
		{
			PrintToChatAll("Human Tank Spawn Event Triggered");
		}
		#endif
	}
	
	MaxPlayerTank = g_iMaxPlayerZombies;
	SetConVarInt(FindConVar("z_max_player_zombies"), g_iMaxPlayerZombies);
}


public Action TankRespawner(Handle timer, Handle datapack)
{
	// This function is used to check if the tank successfully spawned, and if not, respawn him
	
	// Reset the data pack
	ResetPack(datapack);
	
	int tankhealth = ReadPackCell(datapack);
	int tankonfire = ReadPackCell(datapack);
	int client = ReadPackCell(datapack);
	
	if (IsClientInGame(client) && IsFakeClient(client) && IsPlayerTank(client) && PlayerIsAlive(client))
	{
		CreateTimer(0.1, kickbot, client);
		return;
	}
	
	if (IsClientInGame(client) && IsPlayerTank(client) && PlayerIsAlive(client))
		return;
	
	WillBeTank[client] = true;
	
	bool resetGhost[MAXPLAYERS+1];
	bool resetLife[MAXPLAYERS+1];
	
	for (int i=1;i<=MaxClients;i++)
	{
		if ( IsClientInGame(i) && !IsFakeClient(i)) // player is connected and is not fake and it's in game ...
		{
			// If player is on infected's team and is dead ..
			if ((GetClientTeam(i)==TEAM_INFECTED) && WillBeTank[i] == false)
			{
				// If player is a ghost ....
				if (IsPlayerGhost(i))
				{
					resetGhost[i] = true;
					SetGhostStatus(i, false);
					#if DEBUG
					LogMessage("Player is a ghost, taking preventive measures to prevent the player from taking over the tank");
					#endif
				}
				else if (!PlayerIsAlive(i))
				{
					resetLife[i] = true;
					SetLifeState(i, false);
					#if DEBUG
					LogMessage("Dead player found, setting restrictions to prevent the player from taking over the tank");
					#endif
				}
			}
		}
	}
	
	// Find any human client and give client admin rights
	int anyclient = GetAnyClient();

	CheatCommand(anyclient, sSpawnCommand, "tank auto");

	
	// We restore the player's status
	for (int i=1;i<=MaxClients;i++)
	{
		if (resetGhost[i] == true)
			SetGhostStatus(i, true);
		if (resetLife[i] == true)
			SetLifeState(i, true);
		if (WillBeTank[i] == true && IsClientInGame(i))
		{
			if (client && IsClientInGame(i))
			{
				SetEntityHealth(i, tankhealth);
				if (tankonfire)
					CreateTimer(0.1, PutTankOnFireTimer, i, TIMER_FLAG_NO_MAPCHANGE);
				if (g_bCoopPlayableTank)
					TankWasSeen[i] = true;
			}
			WillBeTank[i] = false;
			Handle hpack = CreateDataPack();
			WritePackCell(hpack, tankhealth);
			WritePackCell(hpack, tankonfire);
			WritePackCell(hpack, i);
			CreateTimer(1.0, TankRespawner, hpack, TIMER_FLAG_NO_MAPCHANGE|TIMER_DATA_HNDL_CLOSE);
		}
	}
}

public Action TankBugFix(Handle timer, int client)
{
	#if DEBUG
	LogMessage("Tank BugFix Triggred");
	#endif
	
	if (IsClientInGame(client) && IsFakeClient(client) && GetClientTeam(client) == 3)
	{
		int lifestate = GetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_lifeState"));
		if (lifestate == 0)
		{
			int bot = SDKCall(hCreateTank, "Tank Bot"); //召喚坦克
			if (bot > 0 && IsValidClient(bot))
			{
				#if DEBUG
					PrintToChatAll("Ghost BugFix");
				#endif
				SetEntityModel(bot, MODEL_TANK);
				ChangeClientTeam(bot, TEAM_INFECTED);
				//SDKCall(hRoundRespawn, bot);
				SetEntProp(bot, Prop_Send, "m_usSolidFlags", 16);
				SetEntProp(bot, Prop_Send, "movetype", 2);
				SetEntProp(bot, Prop_Send, "deadflag", 0);
				SetEntProp(bot, Prop_Send, "m_lifeState", 0);
				//SetEntProp(bot, Prop_Send, "m_fFlags", 129);
				SetEntProp(bot, Prop_Send, "m_iObserverMode", 0);
				SetEntProp(bot, Prop_Send, "m_iPlayerState", 0);
				SetEntProp(bot, Prop_Send, "m_zombieState", 0);
				DispatchSpawn(bot);
				ActivateEntity(bot);

				float Origin[3], Angles[3];
				GetClientAbsOrigin(client, Origin);
				GetClientAbsAngles(client, Angles);
				KickClient(client);
				TeleportEntity(bot, Origin, Angles, NULL_VECTOR); //移動到相同位置
			}
		}	
	}
}

public Action PutTankOnFireTimer(Handle Timer, int client)
{
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_INFECTED)
		IgniteEntity(client, 9999.0);
}

public Action HookSound_Callback(int Clients[64], int &NumClients, char StrSample[PLATFORM_MAX_PATH], int &Entity)
{
	if (GameMode != 1 || !g_bCoopPlayableTank)
		return Plugin_Continue;

	//to work only on tank steps, its Tank_walk
	if (StrContains(StrSample, "Tank_walk", false) == -1) return Plugin_Continue;

	for (int i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is infected ...
		if (GetClientTeam(i)==TEAM_INFECTED)
		{
			// If player is a tank
			if (IsPlayerTank(i) && PlayerIsAlive(i) && TankWasSeen[i] == false)
			{
				if (RealPlayersOnInfected() && AreTherePlayersWhoAreNotTanks())
				{
					CreateTimer(0.2, kickbot, i);
					CreateTimer(0.1, TankSpawner, i);
				}
			}
		}
	}
	return Plugin_Continue;
}


// This event serves to make sure the bots spawn at the start of the finale event. The director disallows spawning until the survivors have started the event, so this was
// definitely needed.
public Action evtFinaleStart(Event event, const char[] name, bool dontBroadcast) 
{
	FinaleStarted = true;
	CreateTimer(1.0, CheckIfBotsNeededLater, true);
}

int BotTypeNeeded()
{
	#if DEBUG
	LogMessage("Determining Bot type now");
	#endif
	#if DEBUG
	PrintToChatAll("Determining Bot type now");
	#endif
	
	// current count ...
	int boomers=0;
	int smokers=0;
	int hunters=0;
	int spitters=0;
	int jockeys=0;
	int chargers=0;
	int tanks=0;
	
	for (int i=1;i<=MaxClients;i++)
	{
		// if player is connected and ingame ...
		if (IsClientInGame(i))
		{
			// if player is on infected's team
			if (GetClientTeam(i) == TEAM_INFECTED && PlayerIsAlive(i))
			{
				// We count depending on class ...
				if (IsPlayerSmoker(i))
					smokers++;
				else if (IsPlayerBoomer(i))
					boomers++;	
				else if (IsPlayerHunter(i))
					hunters++;	
				else if (IsPlayerTank(i))
					tanks++;	
				else if (L4D2Version && IsPlayerSpitter(i))
					spitters++;	
				else if (L4D2Version && IsPlayerJockey(i))
					jockeys++;	
				else if (L4D2Version && IsPlayerCharger(i))
					chargers++;	
			}
		}
	}

	if  (L4D2Version)
	{
		if (tanks < h_TankLimit.IntValue && GetRandomInt(1, 100) < g_iSpawnTankProbability)
		{
			#if DEBUG
			LogMessage("Bot type returned Tank");
			#endif
			return 7;
		}
		else //spawn other S.I.
		{
			int random = GetRandomInt(1, 6);
			int i=0;
			while(i++<5)
			{
				if (random == 1)
				{
					if ((smokers < g_iSmokerLimit) && (canSpawnSmoker))
					{
						#if DEBUG
						LogMessage("Bot type returned Smoker");
						#endif
						return 1;
					}
					random++;
				}
				if (random == 2)
				{
					if ((boomers < g_iBoomerLimit) && (canSpawnBoomer))
					{
						#if DEBUG
						LogMessage("Bot type returned Boomer");
						#endif
						return 2;
					}
					random++;
				}
				if (random == 3)
				{
					if ((hunters < g_iHunterLimit) && (canSpawnHunter))
					{
						#if DEBUG
						LogMessage("Bot type returned Hunter");
						#endif
						return 3;
					}
					random++;
				}
				if (random == 4)
				{
					if ((spitters < g_iSpitterLimit) && (canSpawnSpitter))
					{
						#if DEBUG
						LogMessage("Bot type returned Spitter");
						#endif
						return 4;
					}
					random++;
				}
				if (random == 5)
				{
					if ((jockeys < g_iJockeyLimit) && (canSpawnJockey))
					{
						#if DEBUG
						LogMessage("Bot type returned Jockey");
						#endif
						return 5;
					}
					random++;
				}
				if (random == 6)
				{
					if ((chargers < g_iChargerLimit) && (canSpawnCharger))
					{
						#if DEBUG
						LogMessage("Bot type returned Charger");
						#endif
						return 6;
					}
					random = 1;
				}
			}
		}
	}
	else
	{
		if (tanks < h_TankLimit.IntValue && GetRandomInt(1, 100) < g_iSpawnTankProbability)
		{
			#if DEBUG
			LogMessage("Bot type returned Tank");
			#endif
			return 7;
		}
		else
		{
			int random = GetRandomInt(1, 3);
			
			int i=0;
			while(i++<10)
			{
				if (random == 1)
				{
					if ((smokers < g_iSmokerLimit) && (canSpawnSmoker)) // we need a smoker ???? can we spawn a smoker ??? is smoker bot allowed ??
					{
						#if DEBUG
						LogMessage("Returning Smoker");
						#endif
						return 1;
					}
					random++;
				}
				if (random == 2)
				{
					if ((boomers < g_iBoomerLimit) && (canSpawnBoomer))
					{
						#if DEBUG
						LogMessage("Bot type returned Boomer");
						#endif
						return 2;
					}
					random++;
				}
				if (random == 3)
				{
					if ((hunters < g_iHunterLimit) && (canSpawnHunter))
					{
						#if DEBUG
						LogMessage("Bot type returned Hunter");
						#endif
						return 3;
					}
					random=1;
				}
			}
		}
	}
	return 0;
	
}


public Action Spawn_InfectedBot(Handle timer)
{
	#if DEBUG
	PrintToChatAll("Spawn_InfectedBot(Handle timer)");
	#endif
	// If round has ended, we ignore this request ...
	if (b_HasRoundEnded || !b_LeftSaveRoom ) return;
	
	int Infected = g_iMaxPlayerZombies;
	
	if (h_Coordination.BoolValue && !InitialSpawn && !PlayerReady())
	{
		BotReady++;
		
		for (int i=1;i<=MaxClients;i++)
		{
			// We check if player is in game
			if (!IsClientInGame(i)) continue;
			
			// Check if client is infected ...
			if (GetClientTeam(i)==TEAM_INFECTED)
			{
				// If player is a real player 
				if (!IsFakeClient(i))
					Infected--;
			}
		}
		//PrintToChatAll("BotReady: %d, Infected,: %d, InfectedBotQueue: %d",BotReady,Infected,InfectedBotQueue);
		if (BotReady >= Infected)
		{
			CreateTimer(3.0, BotReadyReset, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			if(InfectedBotQueue > 0) InfectedBotQueue--;
			if(!ThereAreNoInfectedBotsRespawnDelay()) return;
			/*if(ThereAreNoInfectedBotsRespawnDelay() && InfectedBotQueue >= 0)
			{
				PrintToChatAll("try to spawn bot");
				CreateTimer(0.2, Spawn_InfectedBot, _, TIMER_FLAG_NO_MAPCHANGE);
			}
			return;*/
		}
	}
	
	// First we get the infected count
	if (GameMode == 2)
	{
		CountInfected();
	}
	else
	{
		CountInfected_Coop();
	}
	// If infected's team is already full ... we ignore this request (a real player connected after timer started ) ..
	if ((InfectedRealCount + InfectedBotCount) >= g_iMaxPlayerZombies || (InfectedRealCount + InfectedBotCount + InfectedBotQueue) > g_iMaxPlayerZombies) 	
	{
		#if DEBUG
		LogMessage("We found a player, don't spawn a bot");
		#endif
		if(InfectedBotQueue>0) InfectedBotQueue--;
		return;
	}
	
	// If there is a tank on the field and l4d_infectedbots_spawns_disable_tank is set to 1, the plugin will check for
	// any tanks on the field
	
	if (h_DisableSpawnsTank.BoolValue)
	{
		for (int i=1;i<=MaxClients;i++)
		{
			// We check if player is in game
			if (!IsClientInGame(i)) continue;
			
			// Check if client is infected ...
			if (GetClientTeam(i)==TEAM_INFECTED)
			{
				// If player is a tank
				if (IsPlayerTank(i) && IsPlayerAlive(i) && ( (IsFakeClient(i) && GetEntProp(i, Prop_Send, "m_hasVisibleThreats")) || !IsFakeClient(i) ))
				{
					if(InfectedBotQueue>0) InfectedBotQueue--;
					return;
				}
			}
		}
		
	}
	
	// Before spawning the bot, we determine if an real infected player is dead, since the int infected bot will be controlled by this player
	bool resetGhost[MAXPLAYERS+1];
	bool resetLife[MAXPLAYERS+1];
	bool binfectedfreeplayer = false;
	int bot = 0;
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i)) // player is connected and is not fake and it's in game ...
		{
			// If player is on infected's team and is dead ..
			if (GetClientTeam(i) == TEAM_INFECTED)
			{
				// If player is a ghost ....
				if (IsPlayerGhost(i))
				{
					resetGhost[i] = true;
					SetGhostStatus(i, false);
					#if DEBUG
					LogMessage("Player is a ghost, taking preventive measures for spawning an infected bot");
					#endif
				}
				else if (!PlayerIsAlive(i) && GameMode == 2) // if player is just dead
				{
					resetLife[i] = true;
					SetLifeState(i, false);
				}
				else if (!PlayerIsAlive(i) && respawnDelay[i] > 0)
				{
					resetLife[i] = true;
					SetLifeState(i, false);
					#if DEBUG
					LogMessage("Found a dead player, spawn time has not reached zero, delaying player to Spawn an infected bot");
					#endif
				}
				else if (!PlayerIsAlive(i) && respawnDelay[i] <= 0)
				{
					AlreadyGhosted[i] = false;
					SetLifeState(i, true);
					binfectedfreeplayer = true;
					bot = i;
				}
				
			}
		}
	}
	
	// We get any client ....
	int anyclient = GetRandomClient();
	if(anyclient == 0)
	{
		PrintToServer("[TS] Couldn't find a valid alive survivor to spawn S.I. at this moment.",ZOMBIESPAWN_Attempts);
		CreateTimer(1.0, CheckIfBotsNeededLater, false);
		return;
	}

	// Determine the bot class needed ...
	int bot_type = BotTypeNeeded();

	if (binfectedfreeplayer)
	{		
		// We spawn the bot ...
		switch (bot_type)
		{
			case 0: // Nothing
			{
			}
			case 1: // Smoker
			{
				CheatCommand(anyclient, sSpawnCommand, "smoker auto");
			}
			case 2: // Boomer
			{	
				CheatCommand(anyclient, sSpawnCommand, "boomer auto");
			}
			case 3: // Hunter
			{
				CheatCommand(anyclient, sSpawnCommand, "hunter auto");
			}
			case 4: // Spitter
			{
				CheatCommand(anyclient, sSpawnCommand, "spitter auto");
			}
			case 5: // Jockey
			{
				CheatCommand(anyclient, sSpawnCommand, "jockey auto");
			}
			case 6: // Charger
			{
				CheatCommand(anyclient, sSpawnCommand, "charger auto");
			}
			case 7: // Tank
			{
				CheatCommand(anyclient, sSpawnCommand, "tank auto");
			}
		}
		if(IsPlayerAlive(bot)) CreateTimer(0.2, CheckIfBotsNeededLater, true);
		else CreateTimer(1.0, CheckIfBotsNeededLater, false);
	}
	else
	{
		bool bSpawnSuccessful = false;
		float vecPos[3];
		// We spawn the bot ...
		switch (bot_type)
		{
			case 0: // Nothing
			{
			}
			case 1: // Smoker
			{
				if(L4D_GetRandomPZSpawnPosition(anyclient,ZOMBIECLASS_SMOKER,ZOMBIESPAWN_Attempts,vecPos) == true)
				{
					bot = SDKCall(hCreateSmoker, "Smoker Bot");
					if (IsValidClient(bot))
					{
						SetEntityModel(bot, MODEL_SMOKER);
						bSpawnSuccessful = true;
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
					bot = SDKCall(hCreateBoomer, "Boomer Bot");
					if (IsValidClient(bot))
					{
						SetEntityModel(bot, MODEL_BOOMER);
						bSpawnSuccessful = true;
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
					bot = SDKCall(hCreateHunter, "Hunter Bot");
					if (IsValidClient(bot))
					{
						SetEntityModel(bot, MODEL_HUNTER);
						bSpawnSuccessful = true;
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
					bot = SDKCall(hCreateSpitter, "Spitter Bot");
					if (IsValidClient(bot))
					{
						SetEntityModel(bot, MODEL_SPITTER);
						bSpawnSuccessful = true;
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
					bot = SDKCall(hCreateJockey, "Jockey Bot");
					if (IsValidClient(bot))
					{
						SetEntityModel(bot, MODEL_JOCKEY);
						bSpawnSuccessful = true;
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
					bot = SDKCall(hCreateCharger, "Charger Bot");
					if (IsValidClient(bot))
					{
						SetEntityModel(bot, MODEL_CHARGER);
						bSpawnSuccessful = true;
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
					bot = SDKCall(hCreateTank, "Tank Bot");
					if (IsValidClient(bot))
					{
						SetEntityModel(bot, MODEL_TANK);
						bSpawnSuccessful = true;
					}					
				}
				else
				{
					PrintToServer("[TS] Couldn't find a Tank Spawn position in %d tries",ZOMBIESPAWN_Attempts);
				}
			}
		}

		if (bSpawnSuccessful && IsValidClient(bot))
		{
			ChangeClientTeam(bot, 3);
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
			CreateTimer(0.2, CheckIfBotsNeededLater, true);
		}
		else
		{
			CreateTimer(1.0, CheckIfBotsNeededLater, false);
		}
	}
	
	// We restore the player's status
	for (int i=1;i<=MaxClients;i++)
	{
		if (resetGhost[i] == true)
			SetGhostStatus(i, true);
		if (resetLife[i] == true)
			SetLifeState(i, true);
	}
	
	// Debug print
	#if DEBUG
	PrintToChatAll("Spawning an infected bot. Type = %i ", bot_type);
	#endif
	
	// We decrement the infected queue
	if(InfectedBotQueue>0) InfectedBotQueue--;
}

int GetAnyClient() 
{ 
	for (int target = 1; target <= MaxClients; target++) 
	{ 
		if (IsClientInGame(target)) return target; 
	} 
	return -1; 
}

public Action kickbot(Handle timer, int client)
{
	if (IsClientInGame(client) && (!IsClientInKickQueue(client)))
	{
		if (IsFakeClient(client)) KickClient(client);
	}
}

bool IsPlayerGhost (int client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost"))
		return true;
	return false;
}

bool PlayerIsAlive (int client)
{
	if (!GetEntProp(client,Prop_Send, "m_lifeState"))
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

void SetGhostStatus (int client, bool ghost)
{
	if (ghost)
		SetEntProp(client, Prop_Send, "m_isGhost", 1, 1);
	else
		SetEntProp(client, Prop_Send, "m_isGhost", 0, 1);
}

void SetLifeState (int client, bool ready)
{
	if (ready)
		SetEntProp(client, Prop_Send,  "m_lifeState", 1, 1);
	else
		SetEntProp(client, Prop_Send, "m_lifeState", 0, 1);
}

bool RealPlayersOnSurvivors ()
{
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
			if (GetClientTeam(i) == TEAM_SURVIVORS)
				return true;
		}
	return false;
}

int TrueNumberOfSurvivors ()
{
	int TotalSurvivors;
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS)
				TotalSurvivors++;
	}
	return TotalSurvivors;
}

int TrueNumberOfAliveSurvivors ()
{
	int TotalSurvivors;
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i))
				TotalSurvivors++;
	}
	return TotalSurvivors;
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

bool AllSurvivorsDeadOrIncapacitated ()
{
	int PlayerIncap;
	int PlayerDead;
	
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && IsFakeClient(i))
			if (GetClientTeam(i) == TEAM_SURVIVORS)
		{
			if (GetEntProp(i, Prop_Send, "m_isIncapacitated"))
			{
				PlayerIncap++;
			}
			else if (!PlayerIsAlive(i))
			{
				PlayerDead++;
			}
		}
	}
	
	if (PlayerIncap + PlayerDead == TrueNumberOfSurvivors())
	{
		return true;
	}
	return false;
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
				if (!IsPlayerTank(i) || IsPlayerTank(i) && !PlayerIsAlive(i))
					return true;
			}
		}
	}
	return false;
}

bool BotsAlive ()
{
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && IsFakeClient(i))
			if (GetClientTeam(i) == TEAM_INFECTED)
				return true;
		}
	return false;
}

bool PlayerReady()
{
	// First we count the ammount of infected real players
	for (int i=1;i<=MaxClients;i++)
	{
		// We check if player is in game
		if (!IsClientInGame(i)) continue;
		
		// Check if client is infected ...
		if (GetClientTeam(i) == TEAM_INFECTED)
		{
			// If player is a real player and is dead...
			if (!IsFakeClient(i) && !PlayerIsAlive(i))
			{
				if (!respawnDelay[i])
				{
					return true;
				}
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
		if (GetClientTeam(i) == TEAM_SURVIVORS)
		{
			// If player is a bot and is alive...
			if (IsFakeClient(i) && PlayerIsAlive(i))
			{
				return i;
			}
		}
	}
	return 0;
}

//---------------------------------------------Durzel's HUD------------------------------------------

public void OnPluginEnd()
{
	ResetTimer();

	g_iPlayerSpawn = 0;

	for( int i = 1; i <= MaxClients; i++ )
	{
		RemoveSurvivorModelGlow(i);
		DeleteLight(i);
	}

	if (L4D2Version)
	{
		ResetConVar(FindConVar("survival_max_smokers"), true, true);
		ResetConVar(FindConVar("survival_max_boomers"), true, true);
		ResetConVar(FindConVar("survival_max_hunters"), true, true);
		ResetConVar(FindConVar("survival_max_spitters"), true, true);
		ResetConVar(FindConVar("survival_max_jockeys"), true, true);
		ResetConVar(FindConVar("survival_max_chargers"), true, true);
		ResetConVar(FindConVar("survival_max_specials"), true, true);
		ResetConVar(FindConVar("z_smoker_limit"), true, true);
		ResetConVar(FindConVar("z_boomer_limit"), true, true);
		ResetConVar(FindConVar("z_hunter_limit"), true, true);
		ResetConVar(FindConVar("z_spitter_limit"), true, true);
		ResetConVar(FindConVar("z_jockey_limit"), true, true);
		ResetConVar(FindConVar("z_charger_limit"), true, true);
		ResetConVar(FindConVar("z_jockey_leap_time"), true, true);
		ResetConVar(FindConVar("z_spitter_max_wait_time"), true, true);
	}
	else
	{
		ResetConVar(FindConVar("holdout_max_smokers"), true, true);
		ResetConVar(FindConVar("holdout_max_boomers"), true, true);
		ResetConVar(FindConVar("holdout_max_hunters"), true, true);
		ResetConVar(FindConVar("holdout_max_specials"), true, true);
		ResetConVar(FindConVar("z_gas_limit"), true, true);
		ResetConVar(FindConVar("z_exploding_limit"), true, true);
		ResetConVar(FindConVar("z_hunter_limit"), true, true);
	}
	ResetConVar(FindConVar("director_no_specials"), true, true);
	ResetConVar(FindConVar("hunter_leap_away_give_up_range"), true, true);
	ResetConVar(FindConVar("z_hunter_lunge_distance"), true, true);
	ResetConVar(FindConVar("hunter_pounce_ready_range"), true, true);
	ResetConVar(FindConVar("hunter_pounce_loft_rate"), true, true);
	ResetConVar(FindConVar("z_attack_flow_range"), true, true);
	ResetConVar(FindConVar("director_spectate_specials"), true, true);
	ResetConVar(FindConVar("z_spawn_safety_range"), true, true);
	ResetConVar(FindConVar("z_spawn_range"), true, true);
	ResetConVar(FindConVar("z_finale_spawn_safety_range"), true, true);
	if(L4D2Version)
	{
		ResetConVar(FindConVar("z_finale_spawn_tank_safety_range"), true, true);
		ResetConVar(FindConVar("z_finale_spawn_mob_safety_range"), true, true);
	}
	ResetConVar(FindConVar("z_spawn_flow_limit"), true, true);
	ResetConVar(FindConVar("z_tank_health"), true, true);
	ResetConVar(h_common_limit_cvar, true, true);
	ResetConVar(FindConVar("z_scrimmage_sphere"), true, true);
	ResetConVar(FindConVar("vs_max_team_switches"), true, true);
	if (!L4D2Version)
	{
		ResetConVar(FindConVar("sb_all_bot_team"), true, true);
	}
	else
	{
		ResetConVar(FindConVar("sb_all_bot_game"), true, true);
		ResetConVar(FindConVar("allow_all_bot_survivor_team"), true, true);
	}
	if(L4D2Version)
	{
		static char mode[64];
		h_GameMode.GetString(mode, sizeof(mode));
		for( int i = 1; i <= MaxClients; i++ )
			if(IsClientInGame(i) && !IsFakeClient(i)) SendConVarValue(i, h_GameMode, mode);
	}
	// Destroy the persistent storage for client HUD preferences
	delete usrHUDPref;
	
	#if DEBUG
	PrintToChatAll("\x01\x04[infhud]\x01 [%f] \x03Infected HUD\x01 stopped.", GetGameTime());
	#endif
}

public int Menu_InfHUDPanel(Menu menu, MenuAction action, int param1, int param2) { return; }

public Action TimerAnnounce(Handle timer, int client)
{
	if (IsClientInGame(client))
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			// Show welcoming instruction message to client
			PrintHintText(client, "%t","Hud INFO", PLUGIN_VERSION);
			
			// This client now knows about the mod, don't tell them again for the rest of the game.
			clientGreeted[client] = 1;
		}
	}
}

public Action TimerAnnounce2(Handle timer, int client)
{
	if (IsClientInGame(client))
	{
		if (GetClientTeam(client) == TEAM_INFECTED && IsPlayerAlive(client))
		{
			C_PrintToChat(client, "[{olive}TS{default}] %T","sm_zs",client);
		}
	}
}


public void cvarZombieHPChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	// Handle a sysadmin modifying the special infected max HP cvars
	char cvarStr[255],difficulty[100];
	convar.GetName(cvarStr, sizeof(cvarStr));
	h_Difficulty.GetString(difficulty, sizeof(difficulty));
	
	#if DEBUG
	PrintToChatAll("\x01\x04[infhud]\x01 [%f] cvarZombieHPChanged(): Infected HP cvar '%s' changed from '%s' to '%s'", GetGameTime(), cvarStr, oldValue, newValue);
	#endif
	
	if (StrEqual(cvarStr, "z_hunter_health", false))
	{
		zombieHP[0] = StringToInt(newValue);
	}
	else if (StrEqual(cvarStr, "z_smoker_health", false))
	{
		zombieHP[1] = StringToInt(newValue);
	}
	else if (StrEqual(cvarStr, "z_boomer_health", false))
	{
		zombieHP[2] = StringToInt(newValue);
	}
	else if (L4D2Version && StrEqual(cvarStr, "z_spitter_health", false))
	{
		zombieHP[3] = StringToInt(newValue);
	}
	else if (L4D2Version && StrEqual(cvarStr, "z_jockey_health", false))
	{
		zombieHP[4] = StringToInt(newValue);
	}
	else if (L4D2Version && StrEqual(cvarStr, "z_charger_health", false))
	{
		zombieHP[5] = StringToInt(newValue);
	}
	else if (StrEqual(cvarStr, "z_tank_health", false) && GameMode == 2)
	{
		zombieHP[6] = RoundToFloor(StringToInt(newValue) * 1.5);	// Tank health is multiplied by 1.5x in VS
	}
	else if (StrEqual(cvarStr, "z_tank_health", false) && GameMode != 2 && StrContains(difficulty, "Easy", false) != -1)
	{
		zombieHP[6] = RoundToFloor(StringToInt(newValue) * 0.75);
	}
	else if (StrEqual(cvarStr, "z_tank_health", false) && GameMode != 2 && StrContains(difficulty, "Normal", false) != -1)
	{
		zombieHP[6] = RoundToFloor(StringToInt(newValue) * 1.0);
	}
	else if (StrEqual(cvarStr, "z_tank_health", false) && GameMode != 2 && StrContains(difficulty, "Hard", false) != -1)
	{
		zombieHP[6] = RoundToFloor(StringToInt(newValue) * 2.0);
	}
	else if (StrEqual(cvarStr, "z_tank_health", false) && GameMode != 2 && StrContains(difficulty, "Impossible", false) != -1)
	{
		zombieHP[6] = RoundToFloor(StringToInt(newValue) * 2.0);
	}
}

public Action monitorRespawn(Handle timer)
{
	// Counts down any active respawn timers
	int foundActiveRTmr = false;
	
	// If round has ended then end timer gracefully
	if (!roundInProgress)
	{
		respawnTimer = null;
		return Plugin_Stop;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (respawnDelay[i] > 0)
		{
			//PrintToChatAll("respawnDelay[i]--");
			respawnDelay[i]--;
			foundActiveRTmr = true;
		}
	}
	
	if (!foundActiveRTmr && respawnTimer != null)
	{
		// Being a ghost doesn't trigger an event which we can hook (player_spawn fires when player actually spawns),
		// so as a nasty kludge after the respawn timer expires for at least one player we set a timer for 1 second 
		// to update the HUD so it says "SPAWNING"
		if (delayedDmgTimer == null)
		{
			delayedDmgTimer = CreateTimer(1.0, delayedDmgUpdate);
		}
		
		// We didn't decrement any of the player respawn times, therefore we don't 
		// need to run this timer anymore.
		respawnTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action delayedDmgUpdate(Handle timer) 
{
	delayedDmgTimer = null;
	ShowInfectedHUD(3);
}

public void queueHUDUpdate(int src)
{
	// queueHUDUpdate basically ensures that we're not constantly refreshing the HUD when there are one or more
	// timers active.  For example, if we have a respawn countdown timer (which is likely at any given time) then
	// there is no need to refresh 
	
	// Don't bother with infected HUD updates if the round has ended.
	if (!roundInProgress) return;
	
	if (respawnTimer == null)
	{
		ShowInfectedHUD(src);
		#if DEBUG
	}
	else
	{
		PrintToChatAll("\x01\x04[infhud]\x01 [%f] queueHUDUpdate(): Instant HUD update ignored, 1-sec timer active.", GetGameTime());
		#endif
	}	
}

public Action showInfHUD(Handle timer) 
{
	ShowInfectedHUD(1);
	return Plugin_Continue;
}

public Action Command_Say(int client, int args)
{
	char clientSteamID[32];
	//GetClientAuthString(client, clientSteamID, 32);
	
	if (g_bInfHUD)
	{
		if (!hudDisabled[client])
		{
			PrintToChat(client, "\x01\x04[infhud]\x01 %T","Hud Disable",client);
			SetTrieValue(usrHUDPref, clientSteamID, 1);
			hudDisabled[client] = 1;
		}
		else
		{
			PrintToChat(client, "\x01\x04[infhud]\x01 %T","Hud Enable",client);
			RemoveFromTrie(usrHUDPref, clientSteamID);
			hudDisabled[client] = 0;
		}
	}
	else
	{
		// Server admin has disabled Infected HUD server-wide
		PrintToChat(client, "\x01\x04[infhud]\x01 %T","Infected HUD is currently DISABLED",client);
	}	
	return Plugin_Handled;
}

public void ShowInfectedHUD(int src)
{
	if (!g_bInfHUD || IsVoteInProgress())
	{
		return;
	}
	
	// If no bots are alive, no point in showing the HUD
	if (GameMode == 2 && !BotsAlive())
	{
		return;
	}
	
	#if DEBUG
	char calledFunc[255];
	switch (src)
	{
		case 1: strcopy(calledFunc, sizeof(calledFunc), "showInfHUD");
		case 2: strcopy(calledFunc, sizeof(calledFunc), "monitorRespawn");
		case 3: strcopy(calledFunc, sizeof(calledFunc), "delayedDmgUpdate");
		case 4: strcopy(calledFunc, sizeof(calledFunc), "doomedTankCountdown");
		case 10: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - client join");
		case 11: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - team switch");
		case 12: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - spawn");
		case 13: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - death");
		case 14: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - menu closed");
		case 15: strcopy(calledFunc, sizeof(calledFunc), "queueHUDUpdate - player kicked");
		case 16: strcopy(calledFunc, sizeof(calledFunc), "evtRoundEnd");
		default: strcopy(calledFunc, sizeof(calledFunc), "UNKNOWN");
	}
	
	PrintToChatAll("\x01\x04[infhud]\x01 [%f] ShowInfectedHUD() called by [\x04%i\x01] '\x03%s\x01'", GetGameTime(), src, calledFunc);
	#endif 
	
	int i, iHP;
	char iClass[100],lineBuf[100],iStatus[25];
	
	// Display information panel to infected clients
	pInfHUD = new Panel(GetMenuStyleHandle(MenuStyle_Radio));
	char information[32];
	if (GameMode == 2)
		Format(information, sizeof(information), "INFECTED BOTS(%s):", PLUGIN_VERSION);
	else
		Format(information, sizeof(information), "INFECTED TEAM(%s):", PLUGIN_VERSION);

	pInfHUD.SetTitle(information);
	pInfHUD.DrawItem(" ",ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
	
	if (roundInProgress)
	{
		// Loop through infected players and show their status
		for (i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i)) continue;
			if (GetClientMenu(i) == MenuSource_RawPanel || GetClientMenu(i) == MenuSource_None)
			{
				if (GetClientTeam(i) == TEAM_INFECTED)
				{
					// Work out what they're playing as
					if (IsPlayerHunter(i))
					{
						strcopy(iClass, sizeof(iClass), "Hunter");
						iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[0]) * 100);
					}
					else if (IsPlayerSmoker(i))
					{
						strcopy(iClass, sizeof(iClass), "Smoker");
						iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[1]) * 100);
					}
					else if (IsPlayerBoomer(i))
					{
						strcopy(iClass, sizeof(iClass), "Boomer");
						iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[2]) * 100);
					}
					else if (L4D2Version && IsPlayerSpitter(i)) 
					{
						strcopy(iClass, sizeof(iClass), "Spitter");
						iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[3]) * 100);	
					}
					else if (L4D2Version && IsPlayerJockey(i)) 
					{
						strcopy(iClass, sizeof(iClass), "Jockey");
						iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[4]) * 100);	
					} 
					else if (L4D2Version && IsPlayerCharger(i)) 
					{
						strcopy(iClass, sizeof(iClass), "Charger");
						iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[5]) * 100);	
					} 
					else if (IsPlayerTank(i))
					{
						strcopy(iClass, sizeof(iClass), "Tank");
						iHP = RoundFloat((float(GetClientHealth(i)) / zombieHP[6]) * 100);
					}
					
					if (PlayerIsAlive(i))
					{
						// Check to see if they are a ghost or not
						if (IsPlayerGhost(i))
						{
							strcopy(iStatus, sizeof(iStatus), "GHOST");
						}
						else
						{
							if(IsPlayerTank(i) && !IsFakeClient(i)) Format(iStatus, sizeof(iStatus), "%i%% - %d%%", iHP,100-GetFrustration(i));
							else Format(iStatus, sizeof(iStatus), "%i%%", iHP);
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
						else if (respawnDelay[i] == 0 && GameMode != 2)
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
						pInfHUD.DrawItem(lineBuf);
					}
					else
					{
						Format(lineBuf, sizeof(lineBuf), "%N-%s-%s", i, iClass, iStatus);
						pInfHUD.DrawItem(lineBuf);
					}
				}
			}
			else
			{
				#if DEBUG
				PrintToChat(i, "x01\x04[infhud]\x01 [%f] Not showing infected HUD as vote/menu (%i) is active", GetClientMenu(i), GetGameTime());
				#endif
			}
		}
	}
	
	// Output the current team status to all infected clients
	// Technically the below is a bit of a kludge but we can't be 100% sure that a client status doesn't change
	// between building the panel and displaying it.
	for (i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if ( (GetClientTeam(i) == TEAM_INFECTED))
			{
				if(IsPlayerTank(i))
				{
					if(GetFrustration(i) >= 95 && GameMode != 2)
					{
						PrintHintText(i, "[TS] %T","You don't attack survivors",i);
						ForcePlayerSuicide(i);
						continue;
					}
				}
				
				if( hudDisabled[i] == 0 && (GetClientMenu(i) == MenuSource_RawPanel || GetClientMenu(i) == MenuSource_None))
				{	
					pInfHUD.Send(i, Menu_InfHUDPanel, 5);
				}
			}
		}
	}
	delete pInfHUD;
}

public Action evtTeamSwitch(Event event, const char[] name, bool dontBroadcast) 
{
	// Check to see if player joined infected team and if so refresh the HUD
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client)
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			queueHUDUpdate(11);
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

public Action evtInfectedSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	if(b_HasRoundStarted && g_iPlayerSpawn == 0)
	{
		CreateTimer(0.5, PluginStart);
	}
	g_iPlayerSpawn = 1;
	// Infected player spawned, so refresh the HUD
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client))
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			queueHUDUpdate(12); 
			// If player joins server and doesn't have to wait to spawn they might not see the announce
			// until they next die (and have to wait).  As a fallback we check when they spawn if they've 
			// already seen it or not.
			if (!clientGreeted[client] && g_bAnnounce)
			{		
				CreateTimer(3.0, TimerAnnounce, client);	
			}
			if(!IsFakeClient(client) && IsPlayerAlive(client))
			{
				CreateTimer(5.0, TimerAnnounce2, client);	
				fPlayerSpawnEngineTime[client] = GetEngineTime();
			}
		}
	}
}

public Action evtInfectedDeath(Event event, const char[] name, bool dontBroadcast) 
{
	// Infected player died, so refresh the HUD
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientConnected(client) && IsClientInGame(client))
	{
		if (GetClientTeam(client) == TEAM_INFECTED)
		{
			queueHUDUpdate(13);
		}
	}
}

public Action evtInfectedHurt(Event event, const char[] name, bool dontBroadcast) 
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
	FightOrDieTimer[client] = CreateTimer(g_fIdletime_b4slay, DisposeOfCowards, client);
	
	delete FightOrDieTimer[attacker];
	FightOrDieTimer[attacker] = CreateTimer(g_fIdletime_b4slay, DisposeOfCowards, attacker);
}

public Action evtInfectedWaitSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	// Don't bother with infected HUD update if the round has ended
	if (!roundInProgress) return;
	
	// Store this players respawn time in an array so we can present it to other clients
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client)
	{
		int timetowait;
		if (GameMode == 2 && !IsFakeClient(client))
		{	
			timetowait = event.GetInt("spawntime");
		}
		else if (GameMode != 2 && !IsFakeClient(client))
		{	
			//timetowait = GetSpawnTime[client];
			timetowait = g_iInfectedSpawnTimeMin - TrueNumberOfAliveSurvivors() * g_iReducedSpawnTimesOnPlayer + (HumansOnInfected() - 1) * 3;
			if(timetowait <= 8)
				timetowait = 8;

			//PrintToChatAll("evtInfectedWaitSpawn: %N - %d秒",client,timetowait);
		}
		else
		{	
			timetowait = GetSpawnTime[client];
		}
		
		respawnDelay[client] = timetowait;
		// Only start timer if we don't have one already going.
		if (respawnTimer == null) {
			// Note: If we have to start a int timer then there will be a 1 second delay before it starts, so 
			// subtract 1 from the pending spawn time
			respawnDelay[client] = (timetowait-1);
			respawnTimer = CreateTimer(1.0, monitorRespawn, _, TIMER_REPEAT);
		}
		// Send mod details/commands to the client, unless they have seen the announce already.
		// Note: We can't do this in OnClientPutInGame because the client may not be on the infected team
		// when they connect, and we can't put it in evtTeamSwitch because it won't register if the client
		// joins the server already on the Infected team.
		if (!clientGreeted[client] && g_bAnnounce)
		{
			CreateTimer(8.0, TimerAnnounce, client, TIMER_FLAG_NO_MAPCHANGE);	
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
	SetUserFlagBits(client, userFlags);
}


void TurnFlashlightOn(int client)
{
	if (GameMode == 2) return;
	if (!IsClientInGame(client)) return;
	if (GetClientTeam(client) != TEAM_INFECTED) return;
	if (!PlayerIsAlive(client)) return;
	if (IsFakeClient(client)) return;

	SetEntProp(client, Prop_Send, "m_iTeamNum", 2);
	SDKCall(hFlashLightTurnOn, client);
	SetEntProp(client, Prop_Send, "m_iTeamNum", 3);

	if(g_bCoopInfectedPlayerFlashLight)
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
	if( entity == -1)
	{
		LogError("Failed to create 'light_dynamic'");
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
	if (GameMode == 2) return;
	if (!IsClientInGame(client)) return;
	if (GetClientTeam(client) == 2) return;
	if (IsFakeClient(client)) return;
	
	int bot = FindBotToTakeOver();
	
	if (bot == 0)
	{
		PrintHintText(client, "No alive survivor bots to take over.");
		return;
	}
	SDKCall(hSpec, bot, client);
	SDKCall(hSwitch, client, true);
	return;
}

public bool IsInteger(char[] buffer)
{
    int len = strlen(buffer);
    for (int i = 0; i < len; i++)
    {
        if ( !IsCharNumeric(buffer[i]) )
            return false;
    }

    return true;    
}

bool IsPlayerGenericAdmin(int client)
{
    if (CheckCommandAccess(client, "generic_admin", ADMFLAG_GENERIC, false))
    {
        return true;
    }

    return false;
}  

int CheckAliveSurvivorPlayers_InSV()
{
	int iPlayersInAliveSurvivors=0;
	for (int i = 1; i < MaxClients+1; i++)
		if(IsClientConnected(i)&&IsClientInGame(i)&&GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i))
			iPlayersInAliveSurvivors++;
	return iPlayersInAliveSurvivors;
}

bool IsWitch(int entity)
{
    if (entity > 0 && IsValidEntity(entity) && IsValidEdict(entity))
    {
        char strClassName[64];
        GetEdictClassname(entity, strClassName, sizeof(strClassName));
        return StrEqual(strClassName, "witch");
    }
    return false;
}
// ====================================================================================================
//					SDKHOOKS TRANSMIT
// ====================================================================================================

void GetSpawnDisConvars()
{
	if(g_bMapStarted && L4D_IsMissionFinalMap())
	{	
		// Removes the boundaries for z_finale_spawn_safety_range and notify flag
		int flags = (FindConVar("z_finale_spawn_safety_range")).Flags;
		SetConVarBounds(FindConVar("z_finale_spawn_safety_range"), ConVarBound_Upper, false);
		SetConVarFlags(FindConVar("z_finale_spawn_safety_range"), flags & ~FCVAR_NOTIFY);
		SetConVarInt(FindConVar("z_finale_spawn_safety_range"),h_SpawnDistanceFinal.IntValue);
		
		if(L4D2Version)
		{
			// Removes the boundaries for z_finale_spawn_tank_safety_range and notify flag
			int flags2 = FindConVar("z_finale_spawn_tank_safety_range").Flags;
			SetConVarBounds(FindConVar("z_finale_spawn_tank_safety_range"), ConVarBound_Upper, false);
			SetConVarFlags(FindConVar("z_finale_spawn_tank_safety_range"), flags2 & ~FCVAR_NOTIFY);
			SetConVarInt(FindConVar("z_finale_spawn_tank_safety_range"),h_SpawnDistanceFinal.IntValue);

			// Add The last stand new convar "z_finale_spawn_mob_safety_range"
			int flags3 = FindConVar("z_finale_spawn_mob_safety_range").Flags;
			SetConVarBounds(FindConVar("z_finale_spawn_mob_safety_range"), ConVarBound_Upper, false);
			SetConVarFlags(FindConVar("z_finale_spawn_mob_safety_range"), flags3 & ~FCVAR_NOTIFY);
			SetConVarInt(FindConVar("z_finale_spawn_mob_safety_range"),h_SpawnDistanceFinal.IntValue);
		}
	}
	
	// Removes the boundaries for z_spawn_range and notify flag
	int flags3 = (FindConVar("z_spawn_range")).Flags;
	SetConVarBounds(FindConVar("z_spawn_range"), ConVarBound_Upper, false);
	SetConVarFlags(FindConVar("z_spawn_range"), flags3 & ~FCVAR_NOTIFY);
	
	// Removes the boundaries for z_spawn_safety_range and notify flag
	int flags4 = FindConVar("z_spawn_safety_range").Flags;
	SetConVarBounds(FindConVar("z_spawn_safety_range"), ConVarBound_Upper, false);
	SetConVarFlags(FindConVar("z_spawn_safety_range"), flags4 & ~FCVAR_NOTIFY);
	
	SetConVarInt(FindConVar("z_spawn_safety_range"),h_SpawnDistanceMin.IntValue);
	SetConVarInt(FindConVar("z_spawn_range"),h_SpawnDistanceMax.IntValue);
}

public Action SpawnWitchAuto(Handle timer)
{
	if( (FinaleStarted && h_WitchSpawnFinal.BoolValue == false) || b_HasRoundEnded) 
	{
		hSpawnWitchTimer = null;
		return;
	}
	
	float vecPos[3];
	int witches=0;
	int entity = -1;
	while ( ((entity = FindEntityByClassname(entity, "witch")) != -1) )
	{
		witches++;
	}

	int anyclient = GetRandomClient();
	if(anyclient == 0)
	{
		PrintToServer("[TS] Couldn't find a valid alive survivor to spawn witch at this moment.",ZOMBIESPAWN_Attempts);
	}
	else if (witches < h_WitchLimit.IntValue)
	{
		if(L4D_GetRandomPZSpawnPosition(anyclient,7,ZOMBIESPAWN_Attempts,vecPos) == true)
		{
			if( g_bSpawnWitchBride )
			{
				L4D2_SpawnWitchBride(vecPos,NULL_VECTOR);
			}
			else 
			{
				L4D2_SpawnWitch(vecPos,NULL_VECTOR);
			}
		}
		else
		{
			PrintToServer("[TS] Couldn't find a Witch Spawn position in %d tries", ZOMBIESPAWN_Attempts);
		}
	}

	int SpawnTime = GetRandomInt(g_iWitchPeriodMin, g_iWitchPeriodMax);
	hSpawnWitchTimer = CreateTimer(float(SpawnTime), SpawnWitchAuto);

	return;
}

int L4D2_GetSurvivorVictim(int client)
{
	int victim;

	if(L4D2Version)
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

public void L4D_OnEnterGhostState(int client)
{
	if(GameMode != 2)
	{
		DeleteLight(client);
		CreateTimer(0.2, Timer_InfectedKillSelf, client, TIMER_FLAG_NO_MAPCHANGE);
	}	
}

public bool ThereAreNoInfectedBotsRespawnDelay()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == TEAM_INFECTED && IsPlayerAlive(i) && GetEntProp(i,Prop_Send,"m_zombieClass") == ZOMBIECLASS_TANK && h_DisableSpawnsTank.BoolValue) 
		{
			if( (IsFakeClient(i) && GetEntProp(i, Prop_Send, "m_hasVisibleThreats")) || !IsFakeClient(i) )
				return false;
		}
		if(respawnDelay[i] > 0)
			return false;
	}
	return true;
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
	}

	delete hSpawnWitchTimer;
	delete PlayerLeftStartTimer;
	delete infHUDTimer;
	delete respawnTimer;
	delete delayedDmgTimer;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damageType)
{
	if(GameMode == 2 || victim <= 0 || victim > MaxClients || !IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Continue;
	if(attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker) || IsFakeClient(attacker)) return Plugin_Continue;

	if(attacker == victim && GetClientTeam(attacker) == TEAM_INFECTED && GetEntProp(attacker,Prop_Send,"m_zombieClass") != ZOMBIECLASS_TANK) 
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action tmrDelayCreateSurvivorGlow(Handle timer, any client)
{
	CreateSurvivorModelGlow(GetClientOfUserId(client));
}

public void CreateSurvivorModelGlow(int client)
{
	if (!L4D2Version ||
	!client || 
	!IsClientInGame(client) || 
	GetClientTeam(client) != TEAM_SURVIVORS || 
	!IsPlayerAlive(client) ||
	IsValidEntRef(g_iModelIndex[client]) == true ||
	GameMode == 2||
	g_bJoinableTeams == false ||
	bDisableSurvivorModelGlow == true ||
	b_HasRoundStarted == false) return;
	
	///////設定發光物件//////////
	// Get Client Model
	char sModelName[64];
	GetEntPropString(client, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
	
	// Spawn dynamic prop entity
	int entity = CreateEntityByName("prop_dynamic_ornament");
	if (entity == -1) return;

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
	AcceptEntityInput(entity, "SetAttached", client);
	///////發光物件完成//////////

	g_iModelIndex[client] = EntIndexToEntRef(entity);
		
	//model 只能給誰看?
	SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit);
}

public Action Hook_SetTransmit(int entity, int client)
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

int GetRandomClient()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
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

Handle hGameConf;
void GetGameData()
{
	hGameConf = LoadGameConfigFile("l4dinfectedbots");
	if( hGameConf != null )
	{
		PrepSDKCall();
	}
	else
	{
		SetFailState("Unable to find l4dinfectedbots.txt gamedata file.");
	}
	delete hGameConf;
}

void PrepSDKCall()
{
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "SetHumanSpec");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	hSpec = EndPrepSDKCall();
	if( hSpec == null)
		SetFailState("Could not prep the \"SetHumanSpec\" function.");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "TakeOverBot");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	hSwitch = EndPrepSDKCall();
	if( hSwitch == null)
		SetFailState("Could not prep the \"TakeOverBot\" function.");

	if(L4D2Version)
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "FlashLightTurnOn");
		hFlashLightTurnOn = EndPrepSDKCall();
	}
	else
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "FlashlightIsOn");
		hFlashLightTurnOn = EndPrepSDKCall();
	}
	if (hFlashLightTurnOn == null)
		SetFailState("FlashLightTurnOn Signature broken");
	
	//find create bot signature
	Address replaceWithBot = GameConfGetAddress(hGameConf, "NextBotCreatePlayerBot.jumptable");
	if (replaceWithBot != Address_Null && LoadFromAddress(replaceWithBot, NumberType_Int8) == 0x68) {
		// We're on L4D2 and linux
		PrepWindowsCreateBotCalls(replaceWithBot);
	}
	else
	{
		if (L4D2Version)
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
}

void PrepL4D2CreateBotCalls() {
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateSpitter))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateSpitter); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateSpitter = EndPrepSDKCall();
	if (hCreateSpitter == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateSpitter); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateJockey))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateJockey); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateJockey = EndPrepSDKCall();
	if (hCreateJockey == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateJockey); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateCharger))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateCharger); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateCharger = EndPrepSDKCall();
	if (hCreateCharger == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateCharger); return; }
}

void PrepL4D1CreateBotCalls() {
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateSmoker))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateSmoker); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateSmoker = EndPrepSDKCall();
	if (hCreateSmoker == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateSmoker); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateBoomer))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateBoomer); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateBoomer = EndPrepSDKCall();
	if (hCreateBoomer == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateBoomer); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateHunter))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateHunter); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateHunter = EndPrepSDKCall();
	if (hCreateHunter == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateHunter); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateTank))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateTank); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateTank = EndPrepSDKCall();
	if (hCreateTank == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateTank); return; }
}
///////////////////////////////////////////////////////////////////////////