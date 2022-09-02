Displays the TF2 trophy when a player 
1. unlocks an achievement.
2. vomit a survivor
3. kill a tank
4. kill a witch

-ChangeLog-
v2.7
-Displays the TF2 trophy when a player when vomit a survivor or kill a tank or kill a witch

v2.6
-Original Post: https://forums.alliedmods.net/showthread.php?p=1279984

-Convars-
// 0=Plugin off, 1=Plugin on.
l4d_trophy_allow "1"

// Which effects to display. 1=Trophy, 2=Fireworks, 3=Both.
l4d_trophy_effects "3"

// Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).
l4d_trophy_modes ""

// Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).
l4d_trophy_modes_off ""

// Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.
l4d_trophy_modes_tog "0"

// 0=Off. 1=Play sound when using the command. 2=When achievement is earned (not required for L4D1). 3=Both.
l4d_trophy_sound "3"

// 0.0=Off. How long to put the player into thirdperson view.
l4d_trophy_third "4.0"

// Remove the particle effects after this many seconds. Increase time to make the effect loop.
l4d_trophy_time "3.5"

// Replay the particles after this many seconds.
l4d_trophy_wait "3.5"

-commands-
"sm_trophy", "Display the achievement trophy on yourself."