#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#define PLUGIN_VERSION "1.3"

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

bool L4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		L4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		L4D2Version = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{	
	cvarLoaderCfg = CreateConVar("server_loader", "server_startup.cfg", "Config that gets executed on server start. (Empty=Disable)");
	if(L4D2Version) FindConVar("sb_all_bot_game").SetInt(1);
	else FindConVar("sb_all_bot_team").SetInt(1);
	
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

