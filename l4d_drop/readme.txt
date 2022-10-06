Allows players to drop the weapon they are holding

-ChangeLog-
v1.9
-Can't drop weapons when survivor is hanging from ledge, incapacitated, or pinned by infected attacker
-Drop single pistol instead of dual pistols

v1.7
-Original Post by Machine&Shadowysn: https://forums.alliedmods.net/showpost.php?p=2763385&postcount=90

-How to use-
type !drop in chatbox or type sm_drop in console

-Convars-
cfg\sourcemod\l4d_drop.cfg
// Prevent players from dropping the M60? (Allows for better compatibility with certain plugins.)
sm_drop_block_m60 "0"

// Prevent players from dropping objects in between actions? (Fixes throwable cloning.) 1 = All weapons. 2 = Only throwables.
sm_drop_block_mid_action "1"

// Prevent players from dropping their secondaries? (Fixes bugs that can come with incapped weapons or A-Posing.)
sm_drop_block_secondary "0"

-Command-
** Drop weapon
	"sm_drop"
	"sm_g"


