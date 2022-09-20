Tanks throw special infected instead of rock


-ChangeLog-
AlliedModders Post: https://forums.alliedmods.net/showthread.php?p=2771705#post2771705
//Pan Xiaohai & Dragokas & HarryPotter @ 2010-2022
v1.7
-Remake Code
-Removed rock thrown sound (it's looping)
-Throw Witch flying
-Separate chance for Real Tank player and AI Tank
-ConVar to set infected limit
-Create special infected without being limit by director

v1.0
-Original Post: https://forums.alliedmods.net/showthread.php?t=140254

-Require-
1. left4dhooks: https://forums.alliedmods.net/showthread.php?p=2684862
2. Actions: https://forums.alliedmods.net/showthread.php?t=336374

-Related Plugin: 
l4d_tracerock: https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d_tracerock

-Convar-
cfg/sourcemod/l4d_tankhelper.cfg
// Weight of helper Boomer[0.0, 10.0]
l4d_tank_throw_boomer "2.0"

// Boomer Limit on the field[1 ~ 5] (if limit reached, throw Boomer teammate)
l4d_tank_throw_boomer_limit "2"

// Weight of helper Charger [0.0, 10.0]
l4d_tank_throw_charger "2.0"

// Charger Limit on the field[1 ~ 5] (if limit reached, throw Charger teammate, if all chargers busy, throw Tank self)
l4d_tank_throw_charger_limit "2"

// Weight of helper Hunter[0.0, 10.0]
l4d_tank_throw_hunter "2.0"

// Hunter Limit on the field[1 ~ 5] (if limit reached, throw Hunter teammate, if all hunters busy, throw Tank self)
l4d_tank_throw_hunter_limit "2"

// Weight of helper Jockey [0.0, 10.0]
l4d_tank_throw_jockey "2.0"

// Jockey Limit on the field[1 ~ 5] (if limit reached, throw Jockey teammate, if all jockeys busy, throw Tank self)
l4d_tank_throw_jockey_limit "2"

// Weight of throwing Tank self[0.0, 10.0]
l4d_tank_throw_self "10.0"

// AI Tank throws helper special infected chance [0.0, 100.0]
l4d_tank_throw_si_ai "100.0"

// Real Tank Player throws helper special infected chance [0.0, 100.0]
l4d_tank_throw_si_player "70.0"

// Weight of helper Smoker[0.0, 10.0]
l4d_tank_throw_smoker "2.0"

// Smoker Limit on the field[1 ~ 5] (if limit reached, throw Smoker teammate, if all smokers busy, throw Tank self)
l4d_tank_throw_smoker_limit "2"

// Weight of helper Spitter [0.0, 10.0]
l4d_tank_throw_spitter "2.0"

// Spitter Limit on the field[1 ~ 5] (if limit reached, throw Spitter teammate)
l4d_tank_throw_spitter_limit "1"

// Weight of helper Tank[0.0, 10.0]
l4d_tank_throw_tank "2.0"

// Helper Tank bot health
l4d_tank_throw_tank_health "750"

// Tank Limit on the field[1 ~ 10] (if limit reached, throw Tank teammate or yourself)
l4d_tank_throw_tank_limit "3"

// Weight of helper Witch[0.0, 10.0]
l4d_tank_throw_witch "2.0"

// Helper Witch health
l4d_tank_throw_witch_health "250"

// Amount of seconds before a helper witch is kicked. (only remove witches spawned by this plugin)
l4d_tank_throw_witch_lifespan "30"

// Witch Limit on the field[1 ~ 10] (if limit reached, throw Tank self)
l4d_tank_throw_witch_limit "3"

-Command-
None