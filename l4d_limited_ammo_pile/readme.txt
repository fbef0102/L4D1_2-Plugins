Once everyone has used the same ammo pile at least once, it is removed.

-ChangeLog-
v1.4
-Remake Code
-Add more convars
-Translation Support
-Deny Sound
-Provide a better method to check if player does fill a weapon fully from ammo pile
-Compatible with [M60_GrenadeLauncher_patches](https://forums.alliedmods.net/showthread.php?t=323408)

v1.2
-original Post: http://forums.alliedmods.net/showthread.php?t=115898

-ConVar-
cfg\sourcemod\l4d_limited_ammo_pile.cfg
// Changes how message displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)
l4d_limited_ammo_pile_announce_type "2"

// If 1, Play sound when ammo already used.
l4d_limited_ammo_pile_denied_sound "1"

// If 1, Each player has only one chance to pick up ammo from each ammo pile. (0=No limit until ammo pile removed)
l4d_limited_ammo_pile_one_time "1"



