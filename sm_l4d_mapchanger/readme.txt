Force change to next mission when current mission(final stage) end.

-ChangeLog-
//Dionys @ 2008~2009
//Harry @ 2019~2022
AlliedModders Post: https://forums.alliedmods.net/showpost.php?p=2728817&postcount=676
v2.4
-Remake Code
-Translation Support
-Support L4D2 coop/versus/realism/survival mode
-Support normal stage and final stage
-After several round end events(tries) survivors wipe out, force server to change map (next level or next map).

v1.4
-Original Post by Dionys: https://forums.alliedmods.net/showthread.php?t=81982

-Require-
1. Left 4 DHooks Direct: https://forums.alliedmods.net/showthread.php?t=321696
2. [INC] Multi Colors: https://forums.alliedmods.net/showthread.php?t=247770

-Example Config-
data\sm_l4d_mapchanger.txt
"ForceMissionChangerSettings"
{
    "c1m4_atrium"   // current map
    {
        "next mission map" "c2m1_highway"   					// <-- new map in coop/versus/realism
        "next mission name" "黑色嘉年華 Dark Carnival (5 Maps)" // <-- map name whatever
    }
	"c8m5_rooftop" // current map
	{
		"next mission map" "c9m2_lots"   				// <-- new map in coop/versus/realism
		"next mission name" "Crash Course (2 Maps)"  	// <-- map name whatever
		
		"survival_nextmap" "c1m2_streets"			 	// <-- new map in survival mode
		"survival_nextname" "Dead Center - Streets" 	// <-- map name whatever
	}
} 

-ConVar-
cfg\sourcemod\sm_l4d_mapchanger.cfg
// Enables next mission and how many chances left to advertise to players.
sm_l4d_fmc_announce "1"

// Quantity of rounds (tries) events survivors wipe out before force of changelevel on final maps in coop/realism (0=off)
sm_l4d_fmc_crec_coop_final "3"

// Quantity of rounds (tries) events survivors wipe out before force of changelevel on non-final maps in coop/realism (0=off)
sm_l4d_fmc_crec_coop_map "3"

// Quantity of rounds (tries) events survivors wipe out before force of changelevel in survival. (0=off)
sm_l4d_fmc_crec_survival_map "5"

// Mission for change by default on final map in coop/realism. (Empty=Don't Change Map by default)
sm_l4d_fmc_def_coop "c2m1_highway"

// Mission for change by default in survival. (Empty=Don't Change Map by default)
sm_l4d_fmc_def_survival ""

// Mission for change by default on final map in versus. (Empty=Don't Change Map by default)
sm_l4d_fmc_def_versus "c8m1_apartment"

// After final rescue vehicle leaving, delay before force of changelevel in coop/realism. (0=off)
sm_l4d_fmc_delay_coop_final "15.0"

// After round ends, delay before force of changelevel in versus. (0=off)
sm_l4d_fmc_delay_survival "15.0"

// After final map finishes, delay before force of changelevel in versus. (0=off)
sm_l4d_fmc_delay_vs "13.0"

-Command-
** Display Next Map
	* sm_fmc_nextmap
	* sm_fmc
