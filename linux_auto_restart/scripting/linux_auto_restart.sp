#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>

#define CVAR_FLAGS			FCVAR_NOTIFY

ConVar g_ConVarHibernate, sb_all_bot_game, sb_all_bot_team, g_ConVarUnloadExtNum;
int g_iCvarUnloadExtNum;
Handle COLD_DOWN_Timer;

public Plugin myinfo =
{
	name = "L4D auto restart",
	author = "Harry Potter",
	description = "make server restart (Force crash) when the last player disconnects from the server",
	version = "2.3",
	url	= "https://steamcommunity.com/profiles/76561198026784913"
};

static bool Isl4d2;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead )
	{
		Isl4d2 = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		Isl4d2 = true;
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
	g_ConVarHibernate = FindConVar("sv_hibernate_when_empty");

	if(Isl4d2)
	{
		sb_all_bot_game = FindConVar("sb_all_bot_game");
	}
	else
	{
		sb_all_bot_team = FindConVar("sb_all_bot_team");
	}
	
	g_ConVarUnloadExtNum = CreateConVar("liunx_auto_restart_unload_ext_num", 			"0", 	"If you have Accelerator extension, you need specify here order number of this extension in the list: sm exts list", CVAR_FLAGS);
	
	GetCvars();
	g_ConVarUnloadExtNum.AddChangeHook(OnCvarChanged);
	AutoExecConfig(true, "linux_auto_restart");

	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);	
}

public void OnPluginEnd()
{
	delete COLD_DOWN_Timer;
}

public void OnCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iCvarUnloadExtNum = g_ConVarUnloadExtNum.IntValue;
}

public void OnMapEnd()
{
	delete COLD_DOWN_Timer;
}

public void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || IsFakeClient(client) || (IsClientConnected(client) && !IsClientInGame(client))) return; //連線中尚未進來的玩家離線
	if(client && !CheckPlayerInGame(client)) //檢查是否還有玩家以外的人還在伺服器
	{
		if(Isl4d2)
			sb_all_bot_game.SetInt(1);
		else
			sb_all_bot_team.SetInt(1);

		g_ConVarHibernate.SetInt(0);

		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(15.0, COLD_DOWN);
	}
}
public Action COLD_DOWN(Handle timer, any client)
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

	CreateTimer(0.1, Timer_RestartServer);

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

void UnloadAccelerator()
{
	if( g_iCvarUnloadExtNum )
	{
		ServerCommand("sm exts unload %i 0", g_iCvarUnloadExtNum);
	}
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