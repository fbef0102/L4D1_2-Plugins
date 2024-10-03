#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#define PLUGIN_VERSION			"1.0h-2024/10/3"
#define PLUGIN_NAME			    "l4d_unreservelobby"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "L4D1/2 Remove Lobby Reservation",
	author = "Downtown1, Harry",
	description = "Removes lobby reservation when server is full or empty",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=94415"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	if( !IsDedicatedServer() )
	{
		strcopy(error, err_max, "Get a dedicated server. This plugin does not work on Listen servers.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define CVAR_FLAGS			FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define UNRESERVE_DEBUG 0
#define UNRESERVE_DEBUG_LOG 0

#define L4D_MAXCLIENTS MaxClients
#define L4D_MAXCLIENTS_PLUS1 (L4D_MAXCLIENTS + 1)

#define L4D_MAXHUMANS_LOBBY_VERSUS 8
#define L4D_MAXHUMANS_LOBBY_OTHER 4

ConVar g_hCvarUnreserveFull, g_hCvarUnreserveEmpty;
bool g_bCvarUnreserveFull, g_bCvarUnreserveEmpty;


Handle COLD_DOWN_Timer;

bool g_bCmdMap;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");

	g_hCvarUnreserveFull 	= CreateConVar( PLUGIN_NAME ... "_full",		"1", "Automatically unreserve server after server lobby reserved and full in gamemode (8 in versus/scavenge, 4 in coop/survival/realism)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarUnreserveEmpty 	= CreateConVar( PLUGIN_NAME ... "_empty", 		"1", "Automatically unreserve server after all playes have disconnected", CVAR_FLAGS, true, 0.0, true, 1.0);
	CreateConVar(           			    PLUGIN_NAME ... "_version",     PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true, PLUGIN_NAME);

	GetCvars();
	g_hCvarUnreserveFull.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarUnreserveEmpty.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_disconnect", Event_PlayerDisconnect);

	RegAdminCmd("sm_unreserve", Command_Unreserve, ADMFLAG_ROOT, "sm_unreserve - manually force removes the lobby reservation");

	AddCommandListener(ServerCmd_map, "map");
}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarUnreserveFull = g_hCvarUnreserveFull.BoolValue;
    g_bCvarUnreserveEmpty = g_hCvarUnreserveEmpty.BoolValue;
}

// Sourcemod API Forward-------------------------------

public void OnMapEnd()
{
	delete COLD_DOWN_Timer;
}

public void OnConfigsExecuted()
{
	GetCvars();

	if(!g_bCmdMap) return;

	if(CheckIfPlayerInServer(0) == false) //沒有玩家在伺服器中
	{
		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(15.0, Timer_COLD_DOWN);
	}
}

public void OnClientPutInServer(int client)
{
	if(IsFakeClient(client)) return;
	delete COLD_DOWN_Timer;

	if(g_bCvarUnreserveFull && L4D_LobbyIsReserved() && IsServerLobbyFull())
	{
		PrintToChatAll("[SM] Lobby reservation has been removed by l4dunreservelobby.smx(Full)");
		PrintToServer("[SM] Lobby reservation has been removed by l4dunreservelobby.smx(Full)");
		L4D_LobbyUnreserve();
	}
}

// Event-------------------------------

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || IsFakeClient(client)) return;

	if(!CheckIfPlayerInServer(client)) //檢查是否還有玩家以外的人還在伺服器
	{
		if(L4D_LobbyIsReserved())
		{
			//PrintToServer("[SM] Lobby reservation has been removed by l4dunreservelobby.smx(Empty)");
			L4D_LobbyUnreserve();
		}
	}
}

// Command-------------------------------

Action Command_Unreserve(int client, int args)
{
	if(!L4D_LobbyIsReserved())
	{
		ReplyToCommand(client, "[SM] Server is already unreserved.");
	}

	L4D_LobbyUnreserve();
	PrintToChatAll("[SM] Lobby reservation has been removed by l4dunreservelobby.smx(sm_unreserve)");
	PrintToServer("[SM] Lobby reservation has been removed by l4dunreservelobby.smx(sm_unreserve)");

	return Plugin_Handled;
}

// Timer-------------------------------

Action Timer_COLD_DOWN(Handle timer, any client)
{
	COLD_DOWN_Timer = null;

	if(!g_bCvarUnreserveEmpty)
	{
		return Plugin_Continue;
	}

	if(CheckIfPlayerInServer(0)) //有玩家在伺服器中
	{
		return Plugin_Continue;
	}

	if(L4D_LobbyIsReserved())
	{
		//PrintToServer("[SM] Lobby reservation has been removed by l4dunreservelobby.smx(Empty)");
		L4D_LobbyUnreserve();
	}

	return Plugin_Continue;
}

// Others-------------------------------

int IsServerLobbyFull()
{
	int humans = GetHumanCount();

	if(L4D_HasPlayerControlledZombies())
	{
		return humans >= L4D_MAXHUMANS_LOBBY_VERSUS;
	}

	return humans >= L4D_MAXHUMANS_LOBBY_OTHER;
}

//client is in-game and not a bot
bool IsClientInGameHuman(int client)
{
	return IsClientInGame(client) && !IsFakeClient(client);
}

int GetHumanCount()
{
	int humans = 0;

	int i;
	for(i = 1; i < L4D_MAXCLIENTS_PLUS1; i++)
	{
		if(IsClientInGameHuman(i))
		{
			humans++
		}
	}

	return humans;
}

bool CheckIfPlayerInServer(int client)
{
	for (int i = 1; i <= MaxClients; i++)
		if(IsClientConnected(i) && !IsFakeClient(i) && i!=client)
			return true;

	return false;
}

//從大廳匹配觸發map
Action ServerCmd_map(int client, const char[] command, int argc)
{
	g_bCmdMap = true;

	delete COLD_DOWN_Timer;
	return Plugin_Continue;
}