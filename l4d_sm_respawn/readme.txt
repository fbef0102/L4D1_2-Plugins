Allows players to be respawned at one's crosshair.

-ChangeLog-
-v2.7
-fixed stuck ceiling when player respawns
-delete unuseful gamedata
-Only respawn Dead Survivor

v2.1
-original post by Dragokas: https://forums.alliedmods.net/showthread.php?p=2693455

-Require-
1. left4dhooks: https://forums.alliedmods.net/showthread.php?p=2684862

-Convars-
cfg\sourcemod\l4d_sm_respawn.cfg
// Add 'Respawn player' item in admin menu under 'Player commands' category? (0 - No, 1 - Yes)
l4d_sm_respawn_adminmenu "1"

// After respawn player, teleport player to 0=Crosshair, 1=Self (You must be alive).
l4d_sm_respawn_destination "0"

// Respawn players with this loadout
l4d_sm_respawn_loadout "smg"

// Notify in chat and log action about respawn? (0 - No, 1 - Yes)
l4d_sm_respawn_showaction "1"

-Command-
** <opt.target> Respawn a player at your crosshair. Without argument - opens menu to select players (Adm required: ADMFLAG_BAN)
	"sm_respawn"
