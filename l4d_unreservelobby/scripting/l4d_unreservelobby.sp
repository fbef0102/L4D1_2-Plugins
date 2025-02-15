#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#define PLUGIN_VERSION			"1.5h-2025/2/15"
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

#define L4D_MAXHUMANS_LOBBY_VERSUS 8
#define L4D_MAXHUMANS_LOBBY_OTHER 4

ConVar sv_allow_lobby_connect_only;
int sv_allow_lobby_connect_only_default;

ConVar g_hCvarUnreserveFull, g_hCvarUnreserveRestore, g_hCvarUnreserveTrigger;
bool g_bCvarUnreserveFull, g_bCvarUnreserveRestore;
int g_iCvarUnreserveTrigger;

bool 
	g_bFirstMap,
	g_bFirstLoadedConfigs,
	g_bIsServerUnreserved;

Handle
	COLD_DOWN_Timer;

char
	g_sTemporaryReservationID[20]; //長度被left4dhooks綁死

public void OnPluginStart()
{
	sv_allow_lobby_connect_only = FindConVar("sv_allow_lobby_connect_only")
	sv_allow_lobby_connect_only.AddChangeHook(ConVarChanged_sv_allow_lobby_connect_only);

	g_hCvarUnreserveFull 	= CreateConVar( PLUGIN_NAME ... "_full",		"1", "Automatically unreserve server after server lobby reserved and full in gamemode (8 in versus/scavenge, 4 in coop/survival/realism)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarUnreserveRestore = CreateConVar( PLUGIN_NAME ... "_restore",		"0", "Automatically restores the lobby reservation when there is a vacancy", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarUnreserveTrigger = CreateConVar( PLUGIN_NAME ... "_trigger", 	"0", "When player number reaches the following number, the server unreserves.\n0 = 8 in versus/scavenge, 4 in coop/survival/realism.\n>0 = Any number greater than zero.", CVAR_FLAGS, true, 0.0, true, 8.0);
	CreateConVar(           			    PLUGIN_NAME ... "_version",     PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true, PLUGIN_NAME);

	GetCvars();
	g_hCvarUnreserveFull.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarUnreserveRestore.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarUnreserveTrigger.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_disconnect", 		Event_PlayerDisconnect);

	RegAdminCmd("sm_unreserve", Command_Unreserve, ADMFLAG_ROOT, "sm_unreserve - manually force removes the lobby reservation");

	g_bFirstMap = true;
	g_bFirstLoadedConfigs = true;
	
}

// Cvars-------------------------------

void ConVarChanged_sv_allow_lobby_connect_only(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	if(g_bIsServerUnreserved)
	{
		if(!L4D_LobbyIsReserved())
		{
			//大廳狀態: unreserved, 須將sv_allow_lobby_connect_only設置為0
			SetAllowLobby(0);
		}
		else
		{
			g_bIsServerUnreserved = false;
		}
	}
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarUnreserveFull = g_hCvarUnreserveFull.BoolValue;
	g_bCvarUnreserveRestore = g_hCvarUnreserveRestore.BoolValue;
	g_iCvarUnreserveTrigger = g_hCvarUnreserveTrigger.IntValue;
}

// Sourcemod API Forward-------------------------------

public void OnMapEnd()
{
	delete COLD_DOWN_Timer;
}

public void OnConfigsExecuted()
{
	if(g_bFirstLoadedConfigs)
	{
		sv_allow_lobby_connect_only_default = sv_allow_lobby_connect_only.IntValue;
		g_bFirstLoadedConfigs = false;
	}

	if(!g_bFirstMap)
	{
		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(10.0, Timer_COLD_DOWN);
	}

	g_bFirstMap = false;
}

public void OnClientConnected(int client)
{
	if(IsFakeClient(client)) return;

	if(g_bCvarUnreserveFull && L4D_LobbyIsReserved() && IsServerLobbyFull())
	{
		//PrintToChatAll("[SM] Lobby reservation has been removed by l4dunreservelobby.smx (Full)");
		//PrintToServer("[SM] Lobby reservation has been removed by l4dunreservelobby.smx (Full)");

		L4D_GetLobbyReservation(g_sTemporaryReservationID, sizeof g_sTemporaryReservationID);
		L4D_LobbyUnreserve();
		SetAllowLobby(0);
		g_bIsServerUnreserved = true;
	}
}

// Event-------------------------------

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
	if(userid > 0 && client == 0) //player leaves during map change, 此時抓不到任何玩家在連線中, 最好等待數秒後再確定一次
	{
		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(3.0, Timer_COLD_DOWN);
	}

	if(client && !IsFakeClient(client)) //檢查是否還有玩家以外的人還在伺服器
	{
		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(3.0, Timer_COLD_DOWN);
	}
}

// Command-------------------------------

Action Command_Unreserve(int client, int args)
{
	if(!L4D_LobbyIsReserved())
	{
		if(strlen(g_sTemporaryReservationID) == 0)
		{
			ReplyToCommand(client, "[SM] Server is already unreserved.");
			return Plugin_Handled;
		}
	}
	else
	{
		L4D_LobbyUnreserve();
		SetAllowLobby(0);
	}

	PrintToChatAll("[SM] Lobby reservation has been removed by l4dunreservelobby.smx (sm_unreserve)");
	PrintToServer("[SM] Lobby reservation has been removed by l4dunreservelobby.smx (sm_unreserve)");

	g_sTemporaryReservationID = "";
	g_bIsServerUnreserved = true;

	return Plugin_Handled;
}

// Timer-------------------------------

Action Timer_COLD_DOWN(Handle timer, any client)
{
	COLD_DOWN_Timer = null;

	if(CheckIfPlayerInServer(0)) //有玩家在伺服器中
	{
		if(g_bCvarUnreserveRestore && g_sTemporaryReservationID[0] && !L4D_LobbyIsReserved() && !IsServerLobbyFull()) //有空位
		{
			//PrintToServer("[SM] Lobby reservation has been restored by l4dunreservelobby.smx (Has slot)");
			L4D_SetLobbyReservation(g_sTemporaryReservationID);
			g_bIsServerUnreserved = false;
			ServerCommand("heartbeat");
		}

		return Plugin_Continue;
	}

	if(L4D_LobbyIsReserved())
	{
		PrintToServer("[SM] Lobby reservation has been removed by l4dunreservelobby.smx (Empty)");
		L4D_LobbyUnreserve();
	}

	g_sTemporaryReservationID = "";
	g_bIsServerUnreserved = false;
	SetAllowLobby(sv_allow_lobby_connect_only_default);

	return Plugin_Continue;
}

// Others-------------------------------

void SetAllowLobby(int value) 
{
	sv_allow_lobby_connect_only.IntValue = value;
}

int IsServerLobbyFull()
{
	int humans = GetHumanCount();
	if(g_iCvarUnreserveTrigger > 0)
	{
		return humans >= g_iCvarUnreserveTrigger;
	}

	if(L4D_HasPlayerControlledZombies())
	{
		return humans >= L4D_MAXHUMANS_LOBBY_VERSUS;
	}

	return humans >= L4D_MAXHUMANS_LOBBY_OTHER;
}

int GetHumanCount()
{
	int humans = 0;

	int i;
	for(i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i) && !IsFakeClient(i))
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

	return humans;
}

bool CheckIfPlayerInServer(int client)
{
	for (int i = 1; i <= MaxClients; i++)
		if(IsClientConnected(i) && !IsFakeClient(i) && i!=client)
			return true;

	return false;
}