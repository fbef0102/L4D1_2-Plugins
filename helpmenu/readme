In-game Help Menu (Support Translation)

-Image-
see helpmenu.jpg

-Changelog-
v0.8
- Convert All codes to new syntax.
- Translation support.
- Add more convars
- Add more commands

v0.3
- Original Post: https://forums.alliedmods.net/showthread.php?p=637467

-Example-
in configs/helpmenu.cfg
"Help"
{
	"MENU1"
	{
		"title"		"MENU1"
		"type"		"text"      //<-- choose text or list
		"items"
		{
			""		"AAA"
			""		"BBB"
		}
	}
	"Chat Commands"
	{
		"title"		"Chat Commands"
		"type"		"list"       //<-- choose text or list
		"items"
		{
			  "say !help"		"Default Description"
		}
	}
}

in translations/helpmenu.phrases.txt
"Phrases"
{
	"MENU1"
	{
		"en"			"Write down translation for MENU1 Title"
	}
	"AAA"
	{
		"en"			"Write down translation for AAA description"
	}
	"BBB"
	{
		"en"			"Write down translation for BBB description"
	}
	"Chat Commands"
	{
		"en"			"Write down translation for Chat Commands Title"
	}
	"say !help"
	{
		"en"			"Write down translation for !help command description"
	}
}

-ConVar-
cfg\sourcemod\helpmenu.cfg
// Show a list of online admins in the menu.
sm_helpmenu_admins "1"

// Automatically reload the configuration file when changing the map.
sm_helpmenu_autoreload "1"

// Path to configuration file.
sm_helpmenu_config_path "configs/helpmenu.cfg"

// Show 'Don't display again' and 'Display again next time' item in the menu.
sm_helpmenu_do_not_display "1"

// Shows the map rotation in the menu.
sm_helpmenu_rotation "0"

// Show 'Join our steam group' item in the menu.
sm_helpmenu_steam_group "1"

// Show welcome message to newly connected users.
sm_helpmenu_welcome "1"

-Command-
**Everyone
	"sm_help"
	"sm_helpmenu"
	"sm_helpcommands"
	"sm_helpcomands"
	"sm_helpcommand"
	"sm_helpcomand"
	"sm_commands"
	"sm_comands"
	"sm_cmds"
	"sm_cmd"

**Reload the help menu configuration file (Adm require: ADMFLAG_ROOT)
	"helpmenu_reload"
	
**Disable the help menu forever.
	"sm_helpoff"
	
**Enable the help menu next time."
	"sm_helpon"