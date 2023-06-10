Announces hunter pounces to the entire server, and save record to data/pounce_database.txt

-Changelog-
v1.2

-Convar-
cfg\sourcemod\pounce_database.cfg
// Announces the pounce in chatbox.
pounce_database_announce "0"

// Enable this plugin?
pounce_database_enable "1"

// The minimum amount of damage required to record the pounce
pounce_database_minimum "25"

// Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus. Add numbers together.
pounce_database_modes_tog "4"

// Numbers of Survivors required at least to enable this plugin
pounce_database_survivors_required "4"

-Command-
** Show your current pounce statistics and rank.
	"sm_pounces"
	
** Show TOP 5 pounce players in statistics.
	"sm_pounce5"
