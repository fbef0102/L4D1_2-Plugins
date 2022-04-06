
#define PLUGIN_VERSION 		"1.2"
#define PLUGIN_NAME			"[L4D1/2] Rescue vehicle leave timer"
#define PLUGIN_AUTHOR		"HarryPotter"
#define PLUGIN_DES			"When rescue vehicle arrived and a timer will display how many time left for vehicle leaving. If a player is not on rescue vehicle or zone, slay him"
#define PLUGIN_URL			"https://forums.alliedmods.net/showpost.php?p=2725525&postcount=7"

//======================================================================================*/

#pragma semicolon 1

#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <multicolors>

#define DEBUG 0

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVORS 		2
#define TEAM_INFECTED 		3

#define CONFIG_SPAWNS		"data/l4d_rescue_vehicle.cfg"
#define MAX_DATAS 10

#define CVAR_FLAGS			FCVAR_NOTIFY
#define SOUND_ESCAPE		"ambient/alarms/klaxon1.wav"

// Cvar Handles/Variables
ConVar g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarMapOff, g_hCvarAnnounceType;

// Plugin Variables
ConVar g_hCvarMPGameMode;
int g_iRoundStart, g_iPlayerSpawn, g_iCvarTime;
int iSystemTime, g_iData[MAX_DATAS];
bool g_bFinalVehicleReady, g_bFinalHasEscapeVehicle, g_bClientInVehicle[MAXPLAYERS+1];
Handle AntiPussyTimer, _AntiPussyTimer;

// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DES,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 && test != Engine_Left4Dead)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("l4d_rescue_vehicle_leave_timer.phrases");
	g_hCvarAllow =			CreateConVar(	"l4d_rescue_vehicle_leave_timer_allow",			"1",			"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarModes =			CreateConVar(	"l4d_rescue_vehicle_leave_timer_modes",			"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =		CreateConVar(	"l4d_rescue_vehicle_leave_timer_modes_off",		"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =		CreateConVar(	"l4d_rescue_vehicle_leave_timer_modes_tog",		"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hCvarMapOff =			CreateConVar(	"l4d_rescue_vehicle_leave_timer_map_off",		"c7m3_port", 	"Turn off the plugin in these maps, separate by commas (no spaces). (0=All maps, Empty = none).", CVAR_FLAGS );
	g_hCvarAnnounceType	= 	CreateConVar(	"l4d_rescue_vehicle_leave_timer_announce_type", "2", 			"Changes how count down tumer hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	CreateConVar(							"l4d_rescue_vehicle_leave_timer_version",		PLUGIN_VERSION,	"Rescue vehicle leave timer plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,					"l4d_rescue_vehicle_leave_timer");

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAnnounceType.AddChangeHook(ConVarChanged_Cvars);
}

public void OnPluginEnd()
{
	ResetPlugin();
}

bool g_bMapStarted, g_bValidMap;
public void OnMapStart()
{
	g_bMapStarted = true;
	g_bValidMap = true;

	char sCvar[512];
	g_hCvarMapOff.GetString(sCvar, sizeof(sCvar));

	if( sCvar[0] != '\0' )
	{
		if( strcmp(sCvar, "0") == 0 )
		{
			g_bValidMap = false;
		} else {
			char sMap[64];
			GetCurrentMap(sMap, sizeof(sMap));

			Format(sMap, sizeof(sMap), ",%s,", sMap);
			Format(sCvar, sizeof(sCvar), ",%s,", sCvar);

			if( StrContains(sCvar, sMap, false) != -1 )
				g_bValidMap = false;
		}
	}
	
	if(L4D_IsMissionFinalMap() == false) //not final map
	{
		g_bValidMap = false;
	}
	
	if(g_bValidMap)
	{
		PrecacheSound(SOUND_ESCAPE, true);
	}
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	g_bValidMap = false;
	ResetPlugin();
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

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

int g_iCvarAnnounceType;
void GetCvars()
{
	g_iCvarAnnounceType = g_hCvarAnnounceType.IntValue;
}

bool g_bCvarAllow;
void IsAllowed()
{
	GetCvars();
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true && g_bValidMap == true )
	{
		CreateTimer(0.1, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
		g_bCvarAllow = true;
		HookEvents();
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false || g_bValidMap == false) )
	{
		ResetPlugin();
		g_bCvarAllow = false;
		UnhookEvents();
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 )
	{
		if( g_bMapStarted == false )
			return false;

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
			AcceptEntityInput(entity, "PostSpawnActivate");
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
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
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
//					EVENTS
// ====================================================================================================
void HookEvents()
{
	HookEvent("round_start",			Event_RoundStart,	EventHookMode_PostNoCopy);
	HookEvent("player_spawn",			Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	HookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
	HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("finale_vehicle_ready", 	Finale_Vehicle_Ready);
}

void UnhookEvents()
{
	UnhookEvent("round_start",				Event_RoundStart,	EventHookMode_PostNoCopy);
	UnhookEvent("player_spawn",				Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	UnhookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
	UnhookEvent("map_transition", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	UnhookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	UnhookEvent("finale_vehicle_leaving", 	Event_RoundEnd,		EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
	UnhookEvent("finale_vehicle_ready", 	Finale_Vehicle_Ready);
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
	
	
	if (g_bFinalVehicleReady)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		g_bClientInVehicle[client] = false;
	}
}

public Action tmrStart(Handle timer)
{
	ResetPlugin();
	InitRescueEntity();
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

public void Finale_Vehicle_Ready(Event event, const char[] name, bool dontBroadcast)
{
	g_bFinalVehicleReady = true;
	
	if(g_bFinalHasEscapeVehicle)
	{
		iSystemTime = g_iCvarTime;
		if(AntiPussyTimer == null) AntiPussyTimer = CreateTimer(1.0, Timer_AntiPussy, _, TIMER_REPEAT);
	}
}

public Action Timer_AntiPussy(Handle timer)
{
	EmitSoundToAll(SOUND_ESCAPE, _, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_LOW, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	switch(g_iCvarAnnounceType)
	{
		case 0: {/*nothing*/}
		case 1: {
			CPrintToChatAll("[{olive}TS{default}] %t", "Escape in seconds", iSystemTime);
		}
		case 2: {
			PrintHintTextToAll("[TS] %t", "Escape in seconds", iSystemTime);
		}
		case 3: {
			PrintCenterTextAll("[TS] %t", "Escape in seconds", iSystemTime);
		}
	}

	if(iSystemTime <= 1)
	{
		CPrintToChatAll("{default}[{olive}TS{default}] %t", "Outside Slay");
		if(_AntiPussyTimer == null) _AntiPussyTimer = CreateTimer(1.5, _AntiPussy, _, TIMER_REPEAT);
		
		AntiPussyTimer = null;
		return Plugin_Stop;
	}
	
	iSystemTime --;
	return Plugin_Continue;
}

public Action _AntiPussy(Handle timer)
{
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if(IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i) && !IsInFinalRescueVehicle(i))
		{
			ForcePlayerSuicide(i);
			CPrintToChat(i, "{default}[{olive}TS{default}] %T", "You have been executed for not being on rescue vehicle or zone!", i);
		}
	}
	return Plugin_Continue;
}

//function
void InitRescueEntity()
{
	if(g_bFinalHasEscapeVehicle || g_bValidMap == false) return;
	
	if(LoadData() == true)
	{
		int entity = FindEntityByClassname(MaxClients + 1, "trigger_finale");
		if(entity > 0 && IsValidEntity(entity))
		{
			bool bIsSacrificeFinale = view_as<bool>(GetEntProp(entity, Prop_Data, "m_bIsSacrificeFinale"));
			if(bIsSacrificeFinale)
			{
				#if DEBUG
					LogMessage("\x05Map is sacrifice finale, disable the plugin");
				#endif
				
				return;
			}
		}
		
		entity = MaxClients + 1;
		int iHammerID;
		while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != -1)
		{
			if(GetEntProp(entity, Prop_Data, "m_iEntireTeam") != 2)
				continue;

			iHammerID = Entity_GetHammerId(entity);
			for(int i=0;i<MAX_DATAS;++i)
			{
				if( iHammerID == g_iData[i] )
				{
					HookSingleEntityOutput(entity, "OnStartTouch", OnStartTouch);
					HookSingleEntityOutput(entity, "OnEndTouch", OnEndTouch);
					g_bFinalHasEscapeVehicle = true;
					break;
				}
			}
		}

		#if DEBUG
			if(g_bFinalHasEscapeVehicle == false)
			{
				static char sMap[64];
				GetCurrentMap(sMap, sizeof(sMap));
				LogMessage("trigger_multiple not found in this map %s", sMap);
			}
		#endif
	}
}

public void OnStartTouch(const char[] output, int caller, int activator, float delay)
{
	if (g_bFinalVehicleReady && activator > 0 && activator <= MaxClients && IsClientInGame(activator))
	{
		#if DEBUG
			PrintToChatAll("OnStartTouch, caller: %d, activator: %d", caller, activator);
		#endif
		g_bClientInVehicle[activator] = true;
	}
}

public void OnEndTouch(const char[] output, int caller, int activator, float delay)
{
	if (g_bFinalVehicleReady && activator > 0 && activator <= MaxClients && IsClientInGame(activator))
	{
		#if DEBUG
			PrintToChatAll("OnEndTouch, caller: %d, activator: %d", caller, activator);
		#endif
		g_bClientInVehicle[activator] = false;
	}
}

bool LoadData()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), CONFIG_SPAWNS);
	if( !FileExists(sPath) )
		return false;

	// Load config
	KeyValues hFile = new KeyValues("rescue_vehicle");
	if( !hFile.ImportFromFile(sPath) )
	{
		delete hFile;
		return false;
	}

	// Check for current map in the config
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));

	if( !hFile.JumpToKey(sMap) )
	{
		delete hFile;
		return false;
	}

	// Retrieve how many rescue entities
	int iCount = hFile.GetNum("num", 0);
	if( iCount <= 0 )
	{
		delete hFile;
		return false;
	}
	
	// Retrieve rescue timer
	g_iCvarTime = hFile.GetNum("time", 60);
	if( g_iCvarTime <= 0 )
	{
		delete hFile;
		return false;
	}

	// check limit
	if( iCount > MAX_DATAS )
		iCount = MAX_DATAS;
		
	//get hammerid of each rescue entity
	char sTemp[4];
	for( int i = 1; i <= iCount; i++ )
	{
		IntToString(i, sTemp, sizeof(sTemp));

		if( hFile.JumpToKey(sTemp) )
		{
			g_iData[i-1] = hFile.GetNum("hammerid", 0);
			hFile.GoBack();
		}
	}

	delete hFile;
	return true;
}

void ResetPlugin()
{
	if( g_bFinalHasEscapeVehicle )
	{
		int entity = -1;
		while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != -1)
		{
			UnhookSingleEntityOutput(entity, "OnStartTouch", OnStartTouch);
			UnhookSingleEntityOutput(entity, "OnEndTouch", OnEndTouch);
		}
	}
	
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
	g_bFinalHasEscapeVehicle = false;
	g_bFinalVehicleReady = false;

	for( int i = 1; i <= MaxClients; i++ ) 
	{
		g_bClientInVehicle[i] = false;
	}
	for(int i=0;i<MAX_DATAS;++i)
	{
		g_iData[i] = 0;
	}
	delete AntiPussyTimer;
	delete _AntiPussyTimer;
}

bool IsInFinalRescueVehicle(int client)
{
	return g_bClientInVehicle[client];
}

stock int Entity_GetHammerId(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iHammerID");
}
