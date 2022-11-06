Locks Saferoom Door Until Someone Opens It.

-Changelog-
v5.2
AlliedModders post: https://forums.alliedmods.net/showpost.php?p=2712869&postcount=54
- Remake Code
- ProdigySim's method for indirectly getting signatures added, created the whole code for indirectly getting signatures so the plugin can now withstand most updates to L4D2!
 (Thanks to Shadowysn: https://forums.alliedmods.net/showthread.php?t=320849 and ProdigySim: https://github.com/ProdigySim/DirectInfectedSpawn)
- Update L4D2 "The Last Stand" gamedata
- Translation support
- Workng in L4D2 "The Last Stand" Map
- Replace Left 4 Downtown 2 extension with Left 4 DHooks Direct
- Remove Convar "Lockdown_system-l4d(2)_menu".
- fixed plugin not working in versus.
- Percentage of the ALIVE survivors must assemble near the saferoom door before open. (prevent rushing players)
- display who open/close the door
- spawn a tank before door open
- spawn multi tanks after door open
- keep spawning a tank when door is opening (players will not feel boring)
- display a message showing who opened or closed the saferoom door. (everyone will know who spamming the door)
- after Safe room door is opened, set a timer to count down. Slay players who still are not inside the saferoom. (prevent cowards)
- when door is opening, if any common or infected spawns inside the saferoom, teleport them outside. (prevent being stuck inside the saferoom)
- stop AI survivor from opening and closing the door. (prevent stupid bots from spamming the door)
- Set the door glow color
- Seconds to lock door after opening and closing the saferoom door.
- after saferoom door is opened, how many chance can the survivors open the door. (stop noobs from playing the doors)
- Made compatible with the "Saferoom Lock: Scavenge" plugin version 1.2.2+ by Earendil.

v1.7
-Original Post: https://forums.alliedmods.net/showthread.php?t=281305

-Require-
1. "Left4DHooks" plugin version 1.101 or newer: https://forums.alliedmods.net/showthread.php?p=2684862
2. [INC] Multi Colors: https://forums.alliedmods.net/showthread.php?t=247770

-Related Plugin-
1. antisaferoomdooropen: https://github.com/fbef0102/Game-Private_Plugin/tree/main/antisaferoomdooropen
Start Saferoom door anti open + teleport survivor back to safe area when leaving out saferoom until certain time pass

2. Saferoom Lock Scavenge: https://forums.alliedmods.net/showthread.php?t=333086
Players must complete a small scavenge event to unlock the saferoom

-Convars-
cfg/sourcemod/lockdown_system-l4d2.cfg
// If 1, Enable saferoom door status Announcements
lockdown_system-l4d2_announce "1"

// Duration Of Anti-Farm
lockdown_system-l4d2_anti-farm_duration "50"

// Change how Count Down Timer Hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
lockdown_system-l4d2_count_hint_type "2"

// Duration Of Lockdown
lockdown_system-l4d2_duration "100"

// (L4D2) The default value for saferoom door glow range.
lockdown_system-l4d2_glow_range "550"

// (L4D2) The default glow color for saferoom door when lock. Three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue.
lockdown_system-l4d2_lock_glow_color "255 0 0"

// Turn off the plugin in these maps, separate by commas (no spaces). (0=All maps, Empty = none).
lockdown_system-l4d2_map_off "c10m3_ranchhouse,l4d_reverse_hos03_sewers,l4d2_stadium4_city2,l4d_fairview10_church,l4d2_wanli01,l4d_smalltown03_ranchhouse,l4d_vs_smalltown03_ranchhouse"

// Number Of Mobs To Spawn
lockdown_system-l4d2_mobs "5"

// After saferoom door is opened, how many chance can the survivors open the door. (0=Can't open door after close, -1=No limit)
lockdown_system-l4d2_open_chance "2"

// Time Interval to spawn a tank when door is opening (0=off)
lockdown_system-l4d2_opening_tank_interval "50"

// Two tanks during opening door in these maps, separate by commas (no spaces). (0=All maps, Empty = none).
lockdown_system-l4d2_map_two_Tank "c1m3_mall"

// After saferoom door is opened, slay players who are not inside saferoom in seconds. (0=off)
lockdown_system-l4d2_outside_slay_duration "60"

// What percentage of the ALIVE survivors must assemble near the saferoom door before open. (0=off)
lockdown_system-l4d2_percentage_survivors_near_saferoom "50"

// How many seconds to lock after opening and closing the saferoom door.
lockdown_system-l4d2_prevent_spam_duration "3.0"

// If 1, prevent AI survivor from opening and closing the door.
lockdown_system-l4d2_spam_bot_disable "1"

// 0=Off. 1=Display a message showing who opened or closed the saferoom door.
lockdown_system-l4d2_spam_hint "1"

// If 1, Enable Tank Demolition, server will spawn tank after door open 
lockdown_system-l4d2_tank_demolition_after "1"

// If 1, Enable Tank Demolition, server will spawn tank before door open 
lockdown_system-l4d2_tank_demolition_before "1"

// 0=Off. 1=Teleport common, special infected, and witch if they touch the door inside saferoom when door is opening. (prevent spawning and be stuck inside the saferoom, only works if Lockdown Type is 2)
lockdown_system-l4d2_teleport "1"

// Lockdown Type: 0=Random, 1=Improved (opening slowly), 2=Default
lockdown_system-l4d2_type "0"

// (L4D2) The default glow color for saferoom door when unlock. Three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue.
lockdown_system-l4d2_unlock_glow_color "200 200 200"

-Command-
None

-Natives & Forwards API-
/**
 * @brief Called when saferoom door is completely opened
 *
 * @param sKeyMan    who opened the saferoom door.
 *
 * @noreturn
 */
forward void L4D2_OnLockDownOpenDoorFinish(const char[] sKeyMan);
