Kicks Clients that get stuck in server connecting state

-Changelog-
v1.2
-Remake code

v1.0
-Original post: http://forums.alliedmods.net/showthread.php?t=103203

-ConVar-
cfg/sourcemod/l4d_kickloadstuckers.cfg
// How long before a connected but not ingame player is kicked. (default 60) 
l4d_kickloadstuckers_duration "90"

-Command-
** Kicks everyone Connected but not ingame (Admin Flag: ADMFLAG_KICK)
	sm_kickloading
	sm_kickloader