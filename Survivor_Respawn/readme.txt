When a Survivor dies, is hanging, or is incapped, will respawn after a period of time.

-Changelog-
AlliedModders Post: https://forums.alliedmods.net/showpost.php?p=2770929&postcount=18
v3.5
- Remake Code
- Don't remove dead body
- If player replaces a dead bot, respawn player after a period of time.
- Invincible time after survivor respawn by this plugin.
- Respawn again if player dies within Invincible time.
- Disable respawning while the final escape starts (rescue vehicle ready)

v2.1
-Original Post: https://forums.alliedmods.net/showthread.php?t=323033

-Require-
1. left4dhooks: https://forums.alliedmods.net/showthread.php?p=2684862

-Convars-
cfg\sourcemod\SurvivorRespawn.cfg
// Respawn bots if is dead in case of using Take Over.
l4d_survivorrespawn_botreplaced "1"

// Amount of times a Survivor can respawn before permanently dying (Def 3)
l4d_survivorrespawn_deathlimit "3"

// If 1, disable respawning while the final escape starts (rescue vehicle ready)
l4d_survivorrespawn_disable_rescue_escape "1"

// Enables Human Survivors to respawn automatically when incapped and/or killed (Def 1)
l4d_survivorrespawn_enablehuman "1"

// Allows Bots to respawn automatically when incapped and/or killed (Def 1)
l4d_survivorrespawn_enablebot "1"

// How many seconds till the Survivor is killed while hanging (Def 25)
l4d_survivorrespawn_hangingdelay "25"

// How many seconds till the Survivor is killed after being incapacitated (Def 25)
l4d_survivorrespawn_incapdelay "25"

// Survivors will be killed when hanging and respawn afterwards (Def 0)
l4d_survivorrespawn_hanging "0"

// Survivors will be killed when incapped and respawn afterwards (Def 0)
l4d_survivorrespawn_incapped "0"

// Enables the respawn limit for Survivors (Def 1)
l4d_survivorrespawn_limitenable "1"

// Amount of buffer HP a Survivor will respawn with (Def 30)
l4d_survivorrespawn_respawnbuffhp "30"

// Amount of HP a Survivor will respawn with (Def 70)
l4d_survivorrespawn_respawnhp "70"

// How many seconds till the Survivor respawns (Def 30)
l4d_survivorrespawn_respawntimeout "30"

// Save player statistics if is have died.
l4d_survivorrespawn_savestats "1"

// (L4D2) Which is first slot weapon will be given to the Survivor (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - AK47 Assault Rifle, 5 - SCAR-L Desert Rifle,
// 6 - M60 Assault Rifle, 7 - Military Sniper Rifle, 8 - SPAS Shotgun, 9 - Chrome Shotgun, 10 - Smg, 0 - None.)
l4d_survivorrespawn_firstweapon "9"

// (L4D2) Which is second slot weapon will be given to the Survivor (1 - Dual Pistol, 2 - Bat, 3 - Magnum, 0 - Only Pistol)
l4d_survivorrespawn_secondweapon "1"

// (L4D2) Which is thrown weapon will be given to the Survivor (1 - Moltov, 2 - Pipe Bomb, 0 - Bile Jar, 0 - None)
l4d_survivorrespawn_thrownweapon "3"

// (L4D2) Which prime health unit will be given to the Survivor (1 - Medkit, 2 - Defib, 0 - None)
l4d_survivorrespawn_primehealth "1"

// (L4D2) Which secondary health unit will be given to the Survivor (1 - Pills, 2 - Adrenaline, 0 - None)
l4d_survivorrespawn_secondaryhealth "2"

// (L4D1) Which is first slot weapon will be given to the Survivor (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - Smg, 5 - Pumpshotgun, 0 - None.)
l4d_survivorrespawn_firstweapon "5"

// (L4D1) Which is second slot weapon will be given to the Survivor (1 - Dual Pistol, 0 - Only Pistol)
l4d_survivorrespawn_secondweapon "1"

// (L4D1) Which is thrown weapon will be given to the Survivor (1 - Moltov, 2 - Pipe Bomb, 0 - None)
l4d_survivorrespawn_thrownweapon "2"

// (L4D1) Which prime health unit will be given to the Survivor (1 - Medkit, 0 - None)
l4d_survivorrespawn_primehealth "1"

// (L4D1) Which secondary health unit will be given to the Survivor (1 - Pills, 0 - None)
l4d_survivorrespawn_secondaryhealth "1"

// Invincible time after survivor respawn
l4d_survivorrespawn_invincibletime "10.0"

-Command-
** Respawn Target/s At Your Crosshair. (Admin Access: ADMFLAG_BAN)
	sm_respawn < #UserID | Name >
	
** Create A Menu Of Clients List And Respawn Targets At Your Crosshair. (Admin Access: ADMFLAG_BAN)
	sm_respawnexmenu


