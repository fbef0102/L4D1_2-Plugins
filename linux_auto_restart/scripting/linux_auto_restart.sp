#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <regex>
#define PLUGIN_VERSION			"3.3-2024/12/7"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D1/L4D2/Any] auto restart",
	author = "Harry Potter, HatsuneImagin",
	description = "make server restart (Force crash) when the last player disconnects from the server",
	version = PLUGIN_VERSION,
	url	= "https://steamcommunity.com/profiles/76561198026784913"
};

bool g_bGameL4D;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if(test == Engine_Left4Dead || test == Engine_Left4Dead2)
	{
		g_bGameL4D = true;
	}

	return APLRes_Success;
}

#define CVAR_FLAGS			FCVAR_NOTIFY

ConVar g_hConVarHibernate;
Handle COLD_DOWN_Timer;

bool 
	g_bNoOneInServer, 
	g_bFirstMap, 
	g_bCmdMap,
	g_bAnyoneConnectedBefore;

char
	g_sPath[256];

public void OnPluginStart()
{
	if(g_bGameL4D)
	{
		g_hConVarHibernate = FindConVar("sv_hibernate_when_empty");
		g_hConVarHibernate.AddChangeHook(ConVarChanged_Hibernate);
	}

	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);	

	RegAdminCmd("sm_crash", Cmd_RestartServer, ADMFLAG_ROOT, "sm_crash - manually force the server to crash");

	g_bFirstMap = true;
	AddCommandListener(ServerCmd_map, "map");

	BuildPath(Path_SM, g_sPath, sizeof(g_sPath), "logs/linux_auto_restart.log");
}

public void OnPluginEnd()
{
	delete COLD_DOWN_Timer;
}

void ConVarChanged_Hibernate(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	g_hConVarHibernate.SetBool(false);
}

public void OnMapStart()
{	
    #if DEBUG
		LogMessage("OnMapStart()");
    #endif
}

public void OnMapEnd()
{
	delete COLD_DOWN_Timer;
}

public void OnConfigsExecuted()
{
	#if DEBUG
		LogMessage("OnConfigsExecuted");
	#endif 

	if(g_bNoOneInServer || (!g_bFirstMap && g_bAnyoneConnectedBefore) || g_bCmdMap)
	{
		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(20.0, Timer_COLD_DOWN);
	}

	g_bFirstMap = false;
}

public void OnClientConnected(int client)
{
	if(IsFakeClient(client)) return;

	#if DEBUG
		LogMessage("OnClientConnected: %N", client);
	#endif 

	if(!g_bAnyoneConnectedBefore)
	{
		if(g_bGameL4D)
		{
			g_hConVarHibernate.SetBool(false);
		}
	}

	g_bAnyoneConnectedBefore = true;
}

Action Cmd_RestartServer(int client, int args)
{
	if(client > 0 && !IsFakeClient(client))
	{
		static char steamid[32];
		GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid), true);

		LogToFileEx(g_sPath, "Manually restarting server... by %N [%s]", client, steamid);
		PrintToServer("Manually restarting server in 5 seconds later... by %N", client);
		PrintToChatAll("Manually restarting server in 5 seconds later... by %N", client);
	}
	else
	{
		LogToFileEx(g_sPath, "Manually restarting server by server console...");
		PrintToServer("Manually restarting server in 5 seconds later...");
		PrintToChatAll("Manually restarting server in 5 seconds later...");
	}

	CreateTimer(5.0, Timer_Cmd_RestartServer);

	return Plugin_Continue;
}

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	// event.GetBool("bot") always return false in l4d1/2
	if(event.GetBool("bot")) return;

	static char networkid[32];
	event.GetString("networkid", networkid, sizeof(networkid));
	// "networkid" is "BOT" is fake client
	if(strcmp(networkid, "BOT", false) == 0) return;

	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(userid > 0 && client == 0 && !CheckPlayerInGame(0)) //player leaves during map change
	{
		g_bNoOneInServer = true;

		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(15.0, Timer_COLD_DOWN);
		return;
	}

	if(client && !IsFakeClient(client) && !CheckPlayerInGame(client)) //檢查是否還有玩家以外的人還在伺服器
	{
		g_bNoOneInServer = true;

		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(15.0, Timer_COLD_DOWN);
	}
}

Action Timer_COLD_DOWN(Handle timer, any client)
{
	COLD_DOWN_Timer = null;

	if(CheckPlayerInGame(0)) //有玩家在伺服器中
	{
		g_bNoOneInServer = false;
		return Plugin_Continue;
	}
	
	LogToFileEx(g_sPath, "Last one player left the server, Restart server now");
	PrintToServer("Last one player left the server, Restart server now");

	UnloadAccelerator();

	CreateTimer(0.1, Timer_RestartServer);

	return Plugin_Continue;
}

Action Timer_RestartServer(Handle timer)
{
	if(g_bGameL4D)
	{
		SetCommandFlags("crash", GetCommandFlags("crash") &~ FCVAR_CHEAT);
		ServerCommand("crash");
	}
	else
	{
		SetCommandFlags("crash", GetCommandFlags("crash") &~ FCVAR_CHEAT);
		ServerCommand("crash");

		SetCommandFlags("sv_crash", GetCommandFlags("sv_crash") &~ FCVAR_CHEAT);
		ServerCommand("sv_crash");

		ServerCommand("_restart");
	}

	return Plugin_Continue;
}

Action Timer_Cmd_RestartServer(Handle timer)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i)) continue;
		if(IsFakeClient(i)) continue;

		KickClient(i, "Server is restarting");
	}
	UnloadAccelerator();
	CreateTimer(0.2, Timer_RestartServer);

	return Plugin_Continue;
}

void UnloadAccelerator()
{
	/*if( g_iCvarUnloadExtNum )
	{
		ServerCommand("sm exts unload %i 0", g_iCvarUnloadExtNum);
	}*/

	char responseBuffer[4096];
	
	// fetch a list of sourcemod extensions
	ServerCommandEx(responseBuffer, sizeof(responseBuffer), "%s", "sm exts list");
	
	// matching ext name only should sufiice
	Regex regex = new Regex("\\[([0-9]+)\\] Accelerator");
	
	// actually matched?
	// CapcureCount == 2? (see @note of "Regex.GetSubString" in regex.inc)
	if (regex.Match(responseBuffer) > 0 && regex.CaptureCount() == 2)
	{
		char sAcceleratorExtNum[4];
		
		// 0 is the full string "[?] Accelerator"
		// 1 is the matched extension number
		regex.GetSubString(1, sAcceleratorExtNum, sizeof(sAcceleratorExtNum));
		
		// unload it
		ServerCommand("sm exts unload %s 0", sAcceleratorExtNum);
		ServerExecute();
	}
	
	delete regex;
}

bool CheckPlayerInGame(int client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i) && !IsFakeClient(i) && i!=client)
		{
			if(IsClientInGame(i))
			{
				return true;
			}
			else
			{
				// 幽靈人口: 有client, IsClientConnected: true, IsClientInGame: false, userid: -1
				// 幽靈人口常發生於換圖時離線，踢不掉，status看不到
				int userid = GetClientUserId(i);
				if(userid > 0) return true;
			}
		}
	}

	return false;
}

//從大廳匹配觸發map
Action ServerCmd_map(int client, const char[] command, int argc)
{
	if(!g_bGameL4D) return Plugin_Continue;

	g_bCmdMap = true;
	g_hConVarHibernate.SetBool(false);

	delete COLD_DOWN_Timer;
	return Plugin_Continue;
}