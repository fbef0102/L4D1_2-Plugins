Prevents Rushers From Rushing Then Teleports Them Back To Their Teammates.

-Changelog-
v1.6
-Remake code
-Replace l4d2direct with left4dhooks
-remove l4d_stock.inc

v1.0
-Original Post: https://forums.alliedmods.net/showthread.php?p=2411516

-Require
1. sourcemod 1.10 or above
2. left4dhooks: https://forums.alliedmods.net/showthread.php?p=2684862

-Convar-
cfg\sourcemod\no-rushing.cfg
// Modes: 0=Teleport only, 1=Teleport and kill after reaching limits, 2=Teleport and kick after reaching limits.
l4d_rushing_action_rushers "1"

// Ignore Incapacitated Survivors?
l4d_rushing_ignore_incapacitated "0"

// Ignore lagging or lost players?
l4d_rushing_ignore_lagging "0"

// Maximum rushing limits
l4d_rushing_limit "2"

// Minimum number of alive survivors before No-Rushing function works. Must be 3 or greater.
l4d_rushing_require_survivors "3"
