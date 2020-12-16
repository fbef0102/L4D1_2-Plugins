#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#define PLUGIN_VERSION "1.2"

public Plugin myinfo = 
{
	name		= "serverLoader (l4d1/2)",
	author		= "archer & HarryPotter",
	description	= "executes cfg file on server startup",
	version		= PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/HarryPotter_TW/"
}

ConVar cvarLoaderCfg;
int serverLoaderCounter = 0;

public void OnPluginStart()
{	
	cvarLoaderCfg = CreateConVar("server_loader", "server_startup.cfg", "Config that gets executed on server start. (Empty=Disable)");
	FindConVar("sb_all_bot_game").SetInt(1);

	
	CreateTimer(5.0, execConfig, TIMER_FLAG_NO_MAPCHANGE);
}

public Action execConfig(Handle timer)
{
	if (serverLoaderCounter < 1)
	{
		static char loaderCfgString[128];
		GetConVarString(cvarLoaderCfg, loaderCfgString, 128);
		if (strlen(loaderCfgString) > 4)
		{
			ServerCommand("exec %s", loaderCfgString);
			LogMessage("executed %s", loaderCfgString);
			serverLoaderCounter++;
		}
		else
		{
			LogMessage("no config or invalid config specified, no configs were loaded.");
			serverLoaderCounter++;
		}
	}
}

