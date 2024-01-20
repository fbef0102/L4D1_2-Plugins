#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <regex>

public Plugin myinfo =
{
	name = "L4D auto restart",
	author = "Harry Potter, HatsuneImagine",
	description = "make server restart (Force crash) when the last player disconnects from the server",
	version = "2.7d",
	url	= "https://steamcommunity.com/profiles/76561198026784913"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead )
	{
		
	}
	else if( test == Engine_Left4Dead2 )
	{
		
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define CVAR_FLAGS FCVAR_NOTIFY

Handle COLD_DOWN_Timer;
bool g_bFirstMap, g_bCmdMap;

public void OnPluginStart()
{
	RegAdminCmd("sm_crash", Cmd_RestartServer, ADMFLAG_ROOT, "sm_crash - manually force the server to crash");

	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);	

	g_bFirstMap = true;
	g_bCmdMap = false;
	AddCommandListener(ServerCmd_map, "map");
}

public void OnPluginEnd()
{
	delete COLD_DOWN_Timer;
}

public void OnMapStart()
{
	if(g_bCmdMap || (!CheckPlayerInGame(0) && !g_bFirstMap))
	{
		SetConVarInt(FindConVar("sb_all_bot_game"), 1);
		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(20.0, COLD_DOWN);
	}

	g_bFirstMap = false;
	g_bCmdMap = false;
}

public void OnMapEnd()
{
	delete COLD_DOWN_Timer;
}

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || IsFakeClient(client) /*|| (IsClientConnected(client) && !IsClientInGame(client))*/) return;
	if(!CheckPlayerInGame(client)) //檢查是否還有玩家以外的人還在伺服器
	{
		SetConVarInt(FindConVar("sb_all_bot_game"), 1);
		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(15.0, COLD_DOWN);
	}
}

Action COLD_DOWN(Handle timer, any client)
{
	if(CheckPlayerInGame(0)) //有玩家在伺服器中
	{
		COLD_DOWN_Timer = null;
		return Plugin_Continue;
	}
	
	if(CheckPlayerConnectingSV()) //沒有玩家在伺服器但是有玩家正在連線
	{
		COLD_DOWN_Timer = CreateTimer(20.0, COLD_DOWN); //重新計時
		return Plugin_Continue;
	}
	
	LogMessage("Last one player left the server, Restart server now");
	PrintToServer("Last one player left the server, Restart server now");

	UnloadAccelerator();

	CreateTimer(5.0, Timer_RestartServer);

	COLD_DOWN_Timer = null;
	return Plugin_Continue;
}

Action Timer_RestartServer(Handle timer)
{
	SetCommandFlags("crash", GetCommandFlags("crash") &~ FCVAR_CHEAT);
	ServerCommand("crash");

	//SetCommandFlags("sv_crash", GetCommandFlags("sv_crash") &~ FCVAR_CHEAT);
	//ServerCommand("sv_crash");//crash server, make linux auto restart server

	return Plugin_Continue;
}

Action Cmd_RestartServer(int client, int args)
{
	SetConVarInt(FindConVar("sb_all_bot_game"), 1);

	LogMessage("Manually restarting server...");
	PrintToServer("Manually restarting server...");
	PrintToChatAll("Manually restarting server...");

	UnloadAccelerator();
	CreateTimer(5.0, Timer_RestartServer);

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
	for (int i = 1; i < MaxClients+1; i++)
		if(IsClientInGame(i) && !IsFakeClient(i) && i!=client)
			return true;

	return false;
}

bool CheckPlayerConnectingSV()
{
	for (int i = 1; i < MaxClients+1; i++)
		if(IsClientConnected(i) && !IsClientInGame(i) && !IsFakeClient(i))
			return true;

	return false;
}

//從大廳匹配觸發map
Action ServerCmd_map(int client, const char[] command, int argc)
{
	g_bCmdMap = true;
	return Plugin_Continue;
}
