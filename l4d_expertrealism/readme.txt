L4D1/2 Real Realism Mode (No Glow + No Hud)

-ChangeLog-
v1.2
-Remake code
-Control glow and hud flag
-Enable Hard Core Hud Mode
(hide HUD and Glow by default, Hud will show while survivors are in stillness or holding SLOW_WALK(Shift) or holding DUCK)

v1.0
-Expert Realism (Hide Glows) original post: https://forums.alliedmods.net/showthread.php?t=328015
-More Hard Core HUD Mode original post: https://forums.alliedmods.net/showthread.php?p=2750968

-ConVar-
cfg\sourcemod\l4d_expertrealism.cfg
// If 1, Enable Server Glows for survivor team. (0=Hide Glow)
l4d_survivor_glowenable "0"

// Changes how message displays for HardCore Mode. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
l4d_survivor_hardcore_announce_type "0"

// Hud will show while survivors 1: are in stillness, 2: holding SLOW_WALK(Shift), 4: holding DUCK, add numbers together (0: None).
l4d_survivor_hardcore_buttons "4"

// If 1, Enable HardCore Mode, hide HUD and Glow by default.
l4d_survivor_hardcore_enable "1"

// 0=Instant. Duration of Hud and Glow for HardCore Mode. How long to keep the hud and glow enabled.
l4d_survivor_hardcore_time "1"

// HUD hidden flag for survivor team. (1=weapon selection, 2=flashlight, 4=all, 8=health, 16=player dead, 32=needssuit, 64=misc, 128=chat, 256=crosshair, 512=vehicle crosshair, 1024=in vehicle)
l4d_survivor_hidehud "64"

// Turns on and off the terror glow highlight effects (Hidden Value Cvar)
sv_glowenable "1"

-Command-
** Hide one client glow (Admin Flag: ADMFLAG_BAN)
	sm_glowoff

** Show one client glow (Admin Flag: ADMFLAG_BAN)
	sm_glowon

** Hide your hud flag (Admin Flag: ADMFLAG_BAN)
	sm_hidehud
	sm_hud

