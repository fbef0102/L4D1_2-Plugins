Create a survivor bot in game + Teleport player

-Changelog-
v1.5
-Add 'Teleport player' item in admin menu under 'Player commands' category.
-Add Teleport destination menu

v1.2
-Remake code

-ConVar-
cfg\sourcemod\l4d_wind.cfg
// If 1, Adm can use command to add a survivor bot
l4d_wind_add_bot_enable "1"

// Add 'Teleport player' item in admin menu under 'Player commands' category? (0 - No, 1 - Yes)
l4d_wind_teleport_adminmenu "1"

// If 1, Adm can teleport special infected
l4d_wind_teleport_infected_enable "1"

-Command-
** Add a survivor bot (Adm required: ADMFLAG_BAN)
	"sm_addbot"
	"sm_createbot"
	 
** Open 'Teleport player' menu (Adm required: ADMFLAG_BAN)
	"sm_teleport"
	"sm_tp"