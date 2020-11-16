#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[L4D1/2] final rescue gravity",
	author = "Harry Potter",
	description = "Set client gravity after final rescue starts just for fun.",
	version = "1.3",
	url = "https://steamcommunity.com/id/TIGER_x_DRAGON/"
}

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVORS 		2
#define TEAM_INFECTED 		3
#define CVAR_FLAGS FCVAR_NOTIFY
#define DEBUG 0
//ConVar
ConVar g_hCvarAllow, g_hCvarMPGameMode, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarMapOff,
g_hCvarGravityValue,g_hCvarGravityEscapeDisable,g_hCvarGravityInfectedFlag,g_hCvarCheckInterval;

//value
bool g_bCvarAllow, g_bMapStarted, bL4D2Version, bFinalHasStart, g_bValidMap;
bool g_bGravityEscapeDisable;
float g_fGravityValue, g_fCheckInterval;
int g_iInfectedFlag;
static int ZOMBIECLASS_TANK;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead ) 
	{
		bL4D2Version = false;
		ZOMBIECLASS_TANK = 5;
	}
	else if( test == Engine_Left4Dead2 ) 
	{
		bL4D2Version = true;
		ZOMBIECLASS_TANK = 8;
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
	g_hCvarAllow =		CreateConVar(	"l4d_final_rescue_gravity_allow",			"1",			"0=Plugin off, 1=Plugin on.", CVAR_FLAGS,true,0.0,true,1.0 );
	g_hCvarModes =		CreateConVar(	"l4d_final_rescue_gravity_modes",			"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =	CreateConVar(	"l4d_final_rescue_gravity_modes_off",		"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =	CreateConVar(	"l4d_final_rescue_gravity_modes_tog",		"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hCvarGravityValue = CreateConVar(	"l4d_final_rescue_gravity_value", "0.25", "Set Gravity value. (1.0=Normal, >1.0=High, <1.0=Low)", CVAR_FLAGS,true,0.0 );
	g_hCvarGravityEscapeDisable = CreateConVar(	"l4d_final_rescue_gravity_escape_ready_off", "1", "If 1, change all clients' gravity to normal when finale vehicle is ready.", CVAR_FLAGS,true,0.0,true,1.0 );
	if(bL4D2Version) 
		g_hCvarGravityInfectedFlag = CreateConVar(	"l4d_final_rescue_gravity_infected_class", "127", 
		"Which zombie class can also obtain the gravity, 0=None, 1=Smoker, =Boomer, 4=Hunter, 8=Spitter, 16=Jockey, 32=Charger, 64=Tank. Add numbers together.", CVAR_FLAGS,true,0.0,true,127.0 );
	else
		g_hCvarGravityInfectedFlag = CreateConVar(	"l4d_final_rescue_gravity_infected_class", "15", 
		"Which zombie class can also obtain the gravity, 0=None, 1=Smoker, 2=Boomer, 4=Hunter, 8=Tank. Add numbers together.", CVAR_FLAGS,true,0.0,true,15.0 );

	g_hCvarMapOff =	CreateConVar("l4d_final_rescue_gravity_map_off",	"c5m5_bridge;c13m4_cutthroatcreek", "Turn off the plugin in these maps, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarCheckInterval =	CreateConVar("l4d_final_rescue_gravity_interval",	"2", "Interval (in sec.) to set gravity for client", CVAR_FLAGS,true,1.0);

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarGravityValue.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarGravityEscapeDisable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarGravityInfectedFlag.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarCheckInterval.AddChangeHook(ConVarChanged_Cvars);

	AutoExecConfig(true,"l4d_final_rescue_gravity");
}

public void OnMapStart()
{
	g_bMapStarted = true;

	g_bValidMap = true;

	char sCvar[256];
	g_hCvarMapOff.GetString(sCvar, sizeof(sCvar));

	if( sCvar[0] != '\0' )
	{
		char sMap[64];
		GetCurrentMap(sMap, sizeof(sMap));

		Format(sMap, sizeof(sMap), ",%s,", sMap);
		Format(sCvar, sizeof(sCvar), ",%s,", sCvar);

		if( StrContains(sCvar, sMap, false) != -1 )
			g_bValidMap = false;
	}
}

public void OnMapEnd()
{
	g_bMapStarted = false;
}

// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnConfigsExecuted()
{
	IsAllowed();
}

public void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_fGravityValue = g_hCvarGravityValue.FloatValue;
	g_bGravityEscapeDisable = g_hCvarGravityEscapeDisable.BoolValue;
	g_iInfectedFlag = g_hCvarGravityInfectedFlag.IntValue;
	g_fCheckInterval = g_hCvarCheckInterval.FloatValue;
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true && g_bValidMap == true)
	{
		g_bCvarAllow = true;
		HookEvent("round_start", 			Event_RoundStart);
		HookEvent("round_end", 				Event_RoundEnd); //回合結束之時(對抗模式回合結束會觸發)
		HookEvent("mission_lost", 			Event_RoundEnd); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
		HookEvent("finale_vehicle_leaving", Event_RoundEnd); //救援載具離開之時 (沒有觸發round_end)
		HookEvent("finale_start", OnFinaleStart_Event, EventHookMode_PostNoCopy);
		//HookEvent("finale_escape_start", Finale_Escape_Start);
		HookEvent("finale_vehicle_ready", Finale_Vehicle_Ready);
		HookEvent("player_spawn", Event_PlayerSpawn);
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false || g_bValidMap == false) )
	{
		g_bCvarAllow = false;
		UnhookEvent("round_start", 				Event_RoundStart);
		UnhookEvent("round_end", 				Event_RoundEnd); //回合結束之時
		UnhookEvent("mission_lost", 			Event_RoundEnd); //戰役滅團重來該關卡的時候
		UnhookEvent("finale_vehicle_leaving", 	Event_RoundEnd); //救援載具離開之時
		UnhookEvent("finale_start", OnFinaleStart_Event, EventHookMode_PostNoCopy);
		//UnhookEvent("finale_escape_start", Finale_Escape_Start);
		UnhookEvent("finale_vehicle_ready", Finale_Vehicle_Ready);
		UnhookEvent("player_spawn", Event_PlayerSpawn);
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

	if( g_bMapStarted == false )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 )
	{
		g_iCurrentMode = 0;

		int entity = CreateEntityByName("info_gamemode");
		if( IsValidEntity(entity) )
		{
			DispatchSpawn(entity);
			HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "PostSpawvate");
			if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
				RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
		}

		if( g_iCurrentMode == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentMode) )
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModes.GetString(sGameModes, sizeof(sGameModes));
	if( strcmp(sGameModes, "") )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( strcmp(sGameModes, "") )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

public void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 4;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 8;
}

// ====================================================================================================
//					Event
// ====================================================================================================

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	bFinalHasStart = false;
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	bFinalHasStart = false;
	ChangeAllClientGravityToNormal();
}

public Action OnFinaleStart_Event(Event event, const char[] name, bool dontBroadcast)
{
	bFinalHasStart = true;
	#if DEBUG
		PrintToChatAll("Final rescue starts");
	#endif
	CreateTimer(g_fCheckInterval, Timer_SetGravity, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || !IsClientInGame(client)) return;

	if (bFinalHasStart) ChangeClientGravity(client, g_fGravityValue);
}
/*
public Action Finale_Escape_Start(Event event, const char[] name, bool dontBroadcast) 
{
	#if DEBUG
		PrintToChatAll("Finale_Escape_Start");
	#endif
	if(g_bGravityEscapeDisable) 
	{
		ChangeAllClientGravityToNormal();
		bFinalHasStart = false;
	}

}
*/
public Action Finale_Vehicle_Ready(Event event, const char[] name, bool dontBroadcast) 
{
	#if DEBUG
		PrintToChatAll("Finale_Vehicle_Ready");
	#endif
	if(g_bGravityEscapeDisable) 
	{
		ChangeAllClientGravityToNormal();
		bFinalHasStart = false;
	}
}

void ChangeAllClientGravityToNormal()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) != TEAM_SPECTATOR)
		{
			PerformGravity(i, 1.0);
		}
	}
}

void ChangeAllClientGravity(float GravityValue)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) != TEAM_SPECTATOR)
		{
			ChangeClientGravity(i, GravityValue);
		}
	}
}

void ChangeClientGravity(int client, float GravityValue)
{
	int iTeam = GetClientTeam(client), class;
	if(iTeam == TEAM_SURVIVORS)
	{
		PerformGravity(client, GravityValue);
		return;
	}
	if(iTeam == TEAM_INFECTED)
	{
		class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if( (bL4D2Version && class == ZOMBIECLASS_TANK) || (!bL4D2Version && class == ZOMBIECLASS_TANK))  // tank
		{
			--class;
		}	
		if(class >=1 && class <=7 && ((1 << (class-1)) & g_iInfectedFlag))
		{
			PerformGravity(client, GravityValue);
			return;
		}
		else
		{
			PerformGravity(client, 1.0);
		}
	}
}

void PerformGravity(int client, float amount)
{
	SetEntityGravity(client, amount);
}

public Action Timer_SetGravity(Handle Timer, int client)
{
	if(!bFinalHasStart) return Plugin_Stop;

	ChangeAllClientGravity(g_fGravityValue);
	return Plugin_Continue;
}