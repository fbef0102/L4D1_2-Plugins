
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <multicolors>

#define PLUGIN_VERSION 		"2.3-2026/2/14"
#define PLUGIN_NAME			"l4d_rescue_vehicle_leave_timer"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D1/2] Rescue vehicle leave timer",
	author = "HarryPotter",
	description = "When rescue vehicle arrived and a timer will display how many time left before vehicle leaving. If a player is not on rescue vehicle or zone, slay him.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	g_bL4D2Version = (test == Engine_Left4Dead2);

	return APLRes_Success;
}

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVORS 		2
#define TEAM_INFECTED 		3

#define CVAR_FLAGS			FCVAR_NOTIFY
#define SOUND_ESCAPE		"ambient/alarms/klaxon1.wav"

#define EXPLOSION_SOUND 	"ambient/explosions/explode_1.wav"
#define NUKE_SOUND_L4D2 "animation/overpass_jets.wav"
#define EXPLOSION_DEBRIS_L4D2 "animation/plantation_exlposion.wav"
#define FIRE_PARTICLE "gas_explosion_ground_fire"
#define EXPLOSION_PARTICLE_L4D2 "FluidExplosion_fps"

#define FFADE_IN            0x0001
#define FFADE_OUT           0x0002
#define FFADE_MODULATE      0x0004
#define FFADE_STAYOUT       0x0008
#define FFADE_PURGE         0x0010

#define MAX_ENTITIES		8

#define GAMEDATA_FILE           PLUGIN_NAME
#define DATA_FILE		        "data/" ... PLUGIN_NAME ... ".cfg"
#define TRANSLATION_FILE		PLUGIN_NAME ... ".phrases"

/* =============================================================================================================== *
 *                                				F18_Sounds & g_sVocalize										   *
 *================================================================================================================ */
static int g_iEntities[MAX_ENTITIES];

char F18_Sounds[6][128] =
{
	"animation/jets/jet_by_01_lr.wav",
	"animation/jets/jet_by_02_lr.wav",
	"animation/jets/jet_by_03_lr.wav",
	"animation/jets/jet_by_04_lr.wav",
	"animation/jets/jet_by_05_lr.wav",
	"animation/jets/jet_by_05_rl.wav"
};

static const char g_sVocalize[][] =
{
	"scenes/Coach/WorldC5M4B04.vcd",		//Damn! That one was close!
	"scenes/Coach/WorldC5M4B05.vcd",		//Shit. Damn, that one was close!
	"scenes/Coach/WorldC5M4B02.vcd",		//STOP BOMBING US.
	"scenes/Gambler/WorldC5M4B09.vcd",		//Well, it's official: They're trying to kill US now.
	"scenes/Gambler/WorldC5M4B05.vcd",		//Christ, those guys are such assholes.
	"scenes/Gambler/World220.vcd",			//WHAT THE HELL ARE THEY DOING?  (reaction to bombing)
	"scenes/Gambler/WorldC5M4B03.vcd",		//STOP BOMBING US!
	"scenes/Mechanic/WorldC5M4B02.vcd",		//They nailed that.
	"scenes/Mechanic/WorldC5M4B03.vcd",		//What are they even aiming at?
	"scenes/Mechanic/WorldC5M4B04.vcd",		//We need to get the hell out of here.
	"scenes/Mechanic/WorldC5M4B05.vcd",		//They must not see us.
	"scenes/Mechanic/WorldC5M103.vcd",		//HEY, STOP WITH THE BOMBING!
	"scenes/Mechanic/WorldC5M104.vcd",		//PLEASE DO NOT BOMB US
	"scenes/Producer/WorldC5M4B04.vcd",		//Something tells me they're not checking for survivors anymore.
	"scenes/Producer/WorldC5M4B01.vcd",		//We need to keep moving.
	"scenes/Producer/WorldC5M4B03.vcd"		//That was close.
};

ConVar g_hCvarMPGameMode;

// Cvar Handles/Variables
ConVar g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarAnnounceType, g_hCvarEscapeTime, g_hCvarAirStrike;
int g_iRoundStart, g_iPlayerSpawn, g_iEscapeTime, g_iCvarEscapeTime;

int iSystemTime;
int g_iRescueVehicle;
bool g_bFinalHasTrigger_Multiple, g_bFinalVehicleLeaving, g_bCvarAirStrike;
bool g_bMapStarted, g_bValidMap, g_bHookStart;
Handle AntiPussyTimer, _AntiPussyTimer, AirstrikeTimer;

Address TheNavMesh;
int g_iOffs_m_pRescueVehicleDepthArea = -1;
Handle g_hSDK_CBaseTrigger_IsTouching;

public void OnPluginStart()
{
	GameData hGameData = new GameData(GAMEDATA_FILE);
	if (!hGameData)
		SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA_FILE);

	g_iOffs_m_pRescueVehicleDepthArea = hGameData.GetOffset("TerrorNavMesh::m_pRescueVehicleDepthArea");

	StartPrepSDKCall(SDKCall_Entity);
	if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CBaseTrigger::IsTouching"))
		SetFailState("Failed to find signature: CBaseTrigger::IsTouching");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	if (!(g_hSDK_CBaseTrigger_IsTouching = EndPrepSDKCall()))
		SetFailState("Failed to create SDKCall: CBaseTrigger::IsTouching");

	delete hGameData;

	LoadTranslations(TRANSLATION_FILE);
	
	g_hCvarAllow =			CreateConVar(	"l4d_rescue_vehicle_leave_timer_allow",					"1",			"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarModes =			CreateConVar(	"l4d_rescue_vehicle_leave_timer_modes",					"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =		CreateConVar(	"l4d_rescue_vehicle_leave_timer_modes_off",				"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =		CreateConVar(	"l4d_rescue_vehicle_leave_timer_modes_tog",				"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hCvarAnnounceType	= 	CreateConVar(	"l4d_rescue_vehicle_leave_timer_announce_type", 		"2", 			"Changes how count down tumer hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hCvarEscapeTime	= 	CreateConVar(	"l4d_rescue_vehicle_leave_timer_escape_time_default", 	"60", 			"Default time to escape.", FCVAR_NOTIFY, true, 1.0);
	g_hCvarAirStrike	= 	CreateConVar(	"l4d_rescue_vehicle_leave_timer_airstrike_enable", 		"1", 			"(L4D2) If 1, Enable AirStrike (explosion, missile, jets, fire)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateConVar(							"l4d_rescue_vehicle_leave_timer_version",		PLUGIN_VERSION,	"Rescue vehicle leave timer plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,					"l4d_rescue_vehicle_leave_timer");

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);

	GetCvars();
	g_hCvarAnnounceType.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarEscapeTime.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarAirStrike.AddChangeHook(ConVarChanged_Cvars);
}

public void OnPluginEnd()
{
	ResetPlugin();
}

public void OnMapStart()
{
	TheNavMesh = L4D_GetPointer(POINTER_NAVMESH);

	g_bMapStarted = true;
	g_bValidMap = true;
	
	if(L4D_IsMissionFinalMap(true) == false) //not final map
	{
		g_bValidMap = false;
	}
	
	if(g_bValidMap)
	{
		PrecacheSound(SOUND_ESCAPE, true);
		PrecacheSound(EXPLOSION_SOUND);
		if(g_bL4D2Version)
		{
			PrecacheSound(NUKE_SOUND_L4D2);
			PrecacheSound(EXPLOSION_DEBRIS_L4D2);
			PrecacheParticle(EXPLOSION_PARTICLE_L4D2);
			for(int i = 0; i < 6; i++)
			{
				PrecacheSound(F18_Sounds[i], true);
			}

			PrecacheModel("models/f18/f18_sb.mdl", true);
			PrecacheModel("models/missiles/f18_agm65maverick.mdl", true);

			PrecacheParticle(FIRE_PARTICLE);
		}
	}
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	g_bValidMap = false;
	g_bHookStart = false;

	ResetPlugin();
}

public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

int g_iCvarAnnounceType;
void GetCvars()
{
	g_iCvarAnnounceType = g_hCvarAnnounceType.IntValue;
	g_iCvarEscapeTime = g_hCvarEscapeTime.IntValue;
	g_bCvarAirStrike = g_hCvarAirStrike.BoolValue;
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

void OnGamemode(const char[] output, int caller, int activator, float delay)
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


public void OnEntityCreated(int entity, const char[] classname)
{
	if(g_bCvarAllow == false || g_bHookStart == false) return;

	switch (classname[0])
	{
		case 't':
		{
			if (strcmp(classname, "trigger_finale") == 0) //late spawn
			{
				RequestFrame(OnNextFrame_trigger_finale, EntIndexToEntRef(entity));
			}
			// (L4D1) trigger_finale_dlc3 
			else if (!g_bL4D2Version && strcmp(classname, "trigger_finale_dlc3") == 0) 
			{
				RequestFrame(OnNextFrame_trigger_finale_dlc3, EntIndexToEntRef(entity));
			}
			else if (strncmp(classname, "trigger_multiple", 16) == 0) //late spawn
			{
				RequestFrame(OnNextFrame_trigger_multiple, EntIndexToEntRef(entity));
			}
		}
	}
}

void OnNextFrame_trigger_finale(int entityRef)
{
	int entity = EntRefToEntIndex(entityRef);
	
	if (entity == INVALID_ENT_REFERENCE)
		return;

	#if DEBUG
		LogMessage("\x05trigger_finale late spawn here");
	#endif

	if(g_bValidMap == false) return;
	if(g_iEscapeTime == 0) return;

	if(g_bL4D2Version)
	{
		if(view_as<bool>(GetEntProp(entity, Prop_Data, "m_bIsSacrificeFinale")))
		{
			#if DEBUG
				LogMessage("\x05Map is sacrifice finale, disable the plugin");
			#endif

			return;
		}
	}

	entity = MaxClients + 1;
	while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != -1)
	{
		if( !IsValidEntity(entity) )
			continue;

		if( GetEntProp(entity, Prop_Data, "m_iEntireTeam") != 2 )
			continue;

		if( !(GetEntProp(entity, Prop_Data, "m_spawnflags") & 1) )
			continue;

		g_bFinalHasTrigger_Multiple = true;
		break;
	}
}

void OnNextFrame_trigger_finale_dlc3(int entityRef)
{
	int entity = EntRefToEntIndex(entityRef);
	
	if (entity == INVALID_ENT_REFERENCE)
		return;

	#if DEBUG
		LogMessage("\x05trigger_finale late spawn here");
	#endif

	if(g_bValidMap == false) return;
	if(g_iEscapeTime == 0) return;

	#if DEBUG
		LogMessage("\x05Map is sacrifice finale in l4d1, disable the plugin");
	#endif

	g_bFinalHasTrigger_Multiple = false;
}

void OnNextFrame_trigger_multiple(int entityRef)
{
	int entity = EntRefToEntIndex(entityRef);
	
	if (entity == INVALID_ENT_REFERENCE)
		return;

	if(g_bValidMap == false) return;
	if(g_iEscapeTime == 0) return;

	if( GetEntProp(entity, Prop_Data, "m_iEntireTeam") != 2 )
		return;

	if( !(GetEntProp(entity, Prop_Data, "m_spawnflags") & 1) )
		return;

	#if DEBUG
		LogMessage("trigger_multiple %d HookSingleEntityOutput", entity);
	#endif

	g_bFinalHasTrigger_Multiple = true;
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
	HookEvent("finale_vehicle_leaving", Finale_Vehicle_Leaving,		EventHookMode_PostNoCopy);
	HookEvent("finale_vehicle_ready", 	Finale_Vehicle_Ready,		EventHookMode_PostNoCopy);
}

void UnhookEvents()
{
	UnhookEvent("round_start",				Event_RoundStart,	EventHookMode_PostNoCopy);
	UnhookEvent("player_spawn",				Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	UnhookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
	UnhookEvent("map_transition", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	UnhookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	UnhookEvent("finale_vehicle_leaving", 	Event_RoundEnd,		EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
	UnhookEvent("finale_vehicle_leaving", 	Finale_Vehicle_Leaving,		EventHookMode_PostNoCopy);
	UnhookEvent("finale_vehicle_ready", 	Finale_Vehicle_Ready,		EventHookMode_PostNoCopy);
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bFinalVehicleLeaving = false;
	g_bHookStart = false;
	g_iEscapeTime = 0;
	g_iRescueVehicle = 0;

	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;

}

Action tmrStart(Handle timer)
{
	ResetPlugin();
	InitRescueEntity();
	g_bHookStart = true;

	return Plugin_Continue;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

void Finale_Vehicle_Leaving(Event event, const char[] name, bool dontBroadcast)
{
	g_bFinalVehicleLeaving = true;
}

void Finale_Vehicle_Ready(Event event, const char[] name, bool dontBroadcast)
{
	//if(g_bIsSacrificeFinale || g_iEscapeTime == 0) return;

	if(!g_bFinalHasTrigger_Multiple) return;
	
	iSystemTime = g_iEscapeTime;
	delete AntiPussyTimer;
	AntiPussyTimer = CreateTimer(1.0, Timer_AntiPussy, _, TIMER_REPEAT);

	if(g_bL4D2Version && g_bCvarAirStrike)
	{
		delete AirstrikeTimer;
		AirstrikeTimer = CreateTimer(2.5, Timer_StartAirstrike, _, TIMER_REPEAT);
	}
}

Action Timer_AntiPussy(Handle timer)
{
	if(!g_bCvarAllow)
	{
		delete AirstrikeTimer;
		AntiPussyTimer = null;
		return Plugin_Stop;
	}

	switch(g_iCvarAnnounceType)
	{
		case 0: {/*nothing*/}
		case 1: {
			CPrintToChatAll("[{olive}TS{default}] %t", "Escape in seconds", iSystemTime);
		}
		case 2: {
			PrintHintTextToAll("%t", "Escape in seconds", iSystemTime);
		}
		case 3: {
			PrintCenterTextAll("%t", "Escape in seconds", iSystemTime);
		}
	}

	if(iSystemTime <= 1)
	{
		int iRescueVehicle = FindRescueAreaTrigger();
		if(iRescueVehicle > MaxClients)
		{
			g_iRescueVehicle = EntIndexToEntRef(iRescueVehicle);
		}

		if(g_bL4D2Version && g_bCvarAirStrike) EmitSoundToAll(NUKE_SOUND_L4D2);

		CPrintToChatAll("{default}[{olive}TS{default}] %t", "Outside Slay");
		delete _AntiPussyTimer;
		_AntiPussyTimer = CreateTimer(2.0, Timer_Strike);
		
		delete AirstrikeTimer;
		AntiPussyTimer = null;
		return Plugin_Stop;
	}
	
	EmitSoundToAll(SOUND_ESCAPE, _, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_LOW, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	iSystemTime --;

	return Plugin_Continue;
}

Action Timer_Strike(Handle timer)
{
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if(IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i))
		{
			if(IsInFinalRescueVehicle(i)) continue;
			
			if(g_bL4D2Version && g_bCvarAirStrike) 
			{
				//explosion effect and fade
				CreateTimer(GetRandomFloat(0.0, 0.5), Timer_Explode, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
				
				//slay
				CreateTimer(2.0, Timer_SlayPlayer, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				CreateTimer(0.1, Timer_SlayPlayer, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}

	_AntiPussyTimer = CreateTimer(3.5, Timer_Strike);
	return Plugin_Continue;
}

bool LoadData()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), DATA_FILE);
	if( !FileExists(sPath) )
	{
		SetFailState("File Not Found: %s", sPath);
		return false;
	}

	// Load config
	KeyValues hFile = new KeyValues("rescue_vehicle");
	if( !hFile.ImportFromFile(sPath) )
	{
		SetFailState("File Format Not Correct: %s", sPath);
		delete hFile;
		return false;
	}

	// Check for current map in the config
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	//StringToLowerCase(sMap);

	if( !hFile.JumpToKey(sMap) )
	{
		g_iEscapeTime = g_iCvarEscapeTime;
		delete hFile;
		return false;
	}
	
	// Retrieve rescue timer
	g_iEscapeTime = hFile.GetNum("time", g_iCvarEscapeTime);

	delete hFile;
	return true;
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
	g_bFinalHasTrigger_Multiple = false;

	delete AntiPussyTimer;
	delete _AntiPussyTimer;
	delete AirstrikeTimer;
}

bool IsInFinalRescueVehicle(int client)
{
	if(IsValidEntRef(g_iRescueVehicle))
	{
		//PrintToChatAll("%N- %d", client, SDKCall(g_hSDK_CBaseTrigger_IsTouching, g_iRescueVehicle, client));
		return SDKCall(g_hSDK_CBaseTrigger_IsTouching, g_iRescueVehicle, client);
	}

	return false;
}

void PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if ( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}
	if ( FindStringIndex(table, sEffectName) == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
	}
}


Action Timer_FadeIn(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && !g_bFinalVehicleLeaving)
	{
		CreateFade(FFADE_IN, client);
	}

	return Plugin_Continue;
}


void CreateFade(int type, int target)
{
	Handle hFadeClient = StartMessageOne("Fade", target);
	BfWriteShort(hFadeClient, 800);
	BfWriteShort(hFadeClient, 800);
	BfWriteShort(hFadeClient, (FFADE_PURGE|type|FFADE_STAYOUT));
	BfWriteByte(hFadeClient, 255);
	BfWriteByte(hFadeClient, 255);
	BfWriteByte(hFadeClient, 255);
	BfWriteByte(hFadeClient, 255);
	EndMessage();
}

void CreateExplosion(const float pos[3], const float duration = 30.0)
{
	static char buffer[32];

	int ent = CreateEntityByName("info_particle_system");
	if(ent != -1)
	{
		DispatchKeyValue(ent, "effect_name", FIRE_PARTICLE);
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(ent);
		ActivateEntity(ent);

		AcceptEntityInput(ent, "Start");
		FormatEx(buffer, sizeof(buffer), "OnUser1 !self:Stop::%f:1", duration);
		SetVariantString(buffer);
		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser1");
	}
	FormatEx(buffer, sizeof(buffer), "OnUser1 !self:Kill::%f:1", duration+1.5);

	if((ent = CreateEntityByName("info_particle_system")) != -1)
	{
		DispatchKeyValue(ent, "effect_name", EXPLOSION_PARTICLE_L4D2);
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(ent);
		ActivateEntity(ent);

		AcceptEntityInput(ent, "Start");
		SetVariantString(buffer);
		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser1");
	}

	EmitAmbientSound(EXPLOSION_SOUND, pos);
	EmitAmbientSound(EXPLOSION_DEBRIS_L4D2, pos);
}

Action Timer_Explode(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsPlayerAlive(client))
	{
		CreateFade(FFADE_OUT, client);
		CreateTimer(4.0, Timer_FadeIn, userid, TIMER_FLAG_NO_MAPCHANGE);

		float radius, pos[3];
		GetClientAbsOrigin(client, pos);
		pos[0] += GetRandomFloat(radius*-1, radius);
		pos[1] += GetRandomFloat(radius*-1, radius);
		CreateExplosion(pos);
	}

	return Plugin_Continue;
}

Action Timer_SlayPlayer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsPlayerAlive(client))
	{
		if(IsInFinalRescueVehicle(client)) return Plugin_Continue;

		ForcePlayerSuicide(client);
		//hint
		CPrintToChat(client, "{default}[{olive}TS{default}] %T", "You have been executed for not being on rescue vehicle or zone!", client);
	}

	return Plugin_Continue;
}

void InitRescueEntity()
{
	if(g_bValidMap == false) return;
	if(LoadData() == false) return;
	if(g_iEscapeTime == 0) return;

	int entity;
	if(g_bL4D2Version)
	{
	 	entity = FindEntityByClassname(MaxClients + 1, "trigger_finale");
		if(entity > MaxClients && IsValidEntity(entity))
		{
			if(view_as<bool>(GetEntProp(entity, Prop_Data, "m_bIsSacrificeFinale")))
			{
				#if DEBUG
					LogMessage("\x05Map is sacrifice finale in l4d2, disable the plugin");
				#endif

				return;
			}
		}
		else
		{
			return;
		}
	}
	else
	{
		entity = FindEntityByClassname(MaxClients + 1, "trigger_finale_dlc3");
		if(entity > MaxClients && IsValidEntity(entity))
		{
			#if DEBUG
				LogMessage("\x05Map is sacrifice finale in l4d1, disable the plugin");
			#endif
			
			return;
		}
	}

	entity = MaxClients + 1;
	while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != -1)
	{
		if(!IsValidEntity(entity)) continue;

		g_bFinalHasTrigger_Multiple = true;
		break;
	}
}

/* =============================================================================================================== *
 *               Silvers AirStrike Plugin Edited By SupermenCJ, and Adjusted To Rescue Leav Timer Plugin			*
 *================================================================================================================ */

Action Timer_StartAirstrike(Handle timer)
{
	if(!g_bCvarAllow)
	{
		return Plugin_Stop;
	}

	int client = my_GetRandomClient();
	if(client == 0) return Plugin_Continue;

	float g_pos[3];
	float vAng[3];
	GetClientAbsOrigin(client, g_pos);
	GetClientEyeAngles(client, vAng);
	
	DataPack h;
	CreateDataTimer(0.5, UpdateAirstrike, h, TIMER_FLAG_NO_MAPCHANGE);
	h.WriteFloat(g_pos[0]);
	h.WriteFloat(g_pos[1]);
	h.WriteFloat(g_pos[2]);
	h.WriteFloat(vAng[1]);

	return Plugin_Continue;
}

int my_GetRandomClient()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			iClients[iClientCount++] = i;
		}
	}
	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

Action UpdateAirstrike(Handle timer, DataPack h)
{  
	h.Reset();
	float g_pos[3];
	float vAng[3];
	g_pos[0] = h.ReadFloat();
	g_pos[1] = h.ReadFloat();
	g_pos[2] = h.ReadFloat();
	vAng[1] = h.ReadFloat();
	
	g_pos[2] += 1.0;
	float radius = 1200.0;
	g_pos[0] += GetRandomFloat(radius*-1, radius);
	g_pos[1] += GetRandomFloat(radius*-1, radius);
	vAng[1] += GetRandomFloat(radius*-1, radius);
	ShowAirstrike(g_pos, vAng[1]);
	
	return Plugin_Continue;
}

void ShowAirstrike(float vPos[3], float direction)
{
	int index = -1;
	for (int i = 0; i < MAX_ENTITIES; i++)
	{
		if (!IsValidEntRef(g_iEntities[i]))
		{
			index = i;
			break;
		}
	}

	if (index == -1) return;

	float vAng[3];
	float vSkybox[3];
	vAng[0] = 0.0;
	vAng[1] = direction;
	vAng[2] = 0.0;

	GetEntPropVector(0, Prop_Data, "m_WorldMaxs", vSkybox);

	int entity = CreateEntityByName("prop_dynamic_override");
	if(entity == -1) return;

	g_iEntities[index] = EntIndexToEntRef(entity);
	DispatchKeyValue(entity, "targetname", "silver_f18_model");
	DispatchKeyValue(entity, "disableshadows", "1");
	DispatchKeyValue(entity, "model", "models/f18/f18_sb.mdl");
	DispatchSpawn(entity);
	SetEntProp(entity, Prop_Data, "m_iHammerID", RoundToNearest(vPos[2]));
	float height = vPos[2] + 1000.0;
	if (height > vSkybox[2] - 200)
		vPos[2] = vSkybox[2] - 200;
	else
		vPos[2] = height;
	TeleportEntity(entity, vPos, vAng, NULL_VECTOR);

	SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 5.0);

	int random = GetRandomInt(1, 5);
	if (random == 1)
		SetVariantString("flyby1");
	else if (random == 2)
		SetVariantString("flyby2");
	else if (random == 3)
		SetVariantString("flyby3");
	else if (random == 4)
		SetVariantString("flyby4");
	else if (random == 5)
		SetVariantString("flyby5");
	AcceptEntityInput(entity, "SetAnimation");
	AcceptEntityInput(entity, "Enable");
	
	SetVariantString("OnUser1 !self:Kill::6.5.0:1");
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser1");
	
	CreateTimer(1.5, tmrDrop, EntIndexToEntRef(entity));
}

Action tmrDrop(Handle timer, any f18)
{
	if (IsValidEntRef(f18))
	{
		float g_cvarRadiusF18 = 950.0;
		float vPos[3];
		float vAng[3];
		float vVec[3];
		GetEntPropVector(f18, Prop_Data, "m_vecAbsOrigin", vPos);
		GetEntPropVector(f18, Prop_Data, "m_angRotation", vAng);

		int entity = CreateEntityByName("grenade_launcher_projectile");
		if(entity == -1) return Plugin_Continue;

		DispatchSpawn(entity);
		SetEntityModel(entity, "models/missiles/f18_agm65maverick.mdl");

		SetEntityMoveType(entity, MOVETYPE_NOCLIP);
		CreateTimer(0.9, TimerGrav, EntIndexToEntRef(entity));

		GetAngleVectors(vAng, vVec, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vVec, vVec);
		ScaleVector(vVec, -800.0);
		
		MoveForward(vPos, vAng, vPos, 2400.0);

		vPos[0] += GetRandomFloat(-1.0 * g_cvarRadiusF18, g_cvarRadiusF18);
		vPos[1] += GetRandomFloat(-1.0 * g_cvarRadiusF18, g_cvarRadiusF18);
		TeleportEntity(entity, vPos, vAng, vVec);
		
		SDKHook(entity, SDKHook_Touch, OnBombTouch);
		
		SetVariantString("OnUser1 !self:Kill::10.0:1");
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");

		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", 0.3);

		int projectile = entity;
		// BLUE FLAMES
		entity = CreateEntityByName("info_particle_system");
		if (entity != -1)
		{
			DispatchKeyValue(entity, "effect_name", "flame_blue");
			DispatchSpawn(entity);
			ActivateEntity(entity);
			TeleportEntity(entity, vPos, vAng, NULL_VECTOR);
			
			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", projectile);

			SetVariantString("OnUser4 !self:Kill::10.0:1");
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser4");
			AcceptEntityInput(entity, "Start");
		}
		// FLAMES
		entity = CreateEntityByName("info_particle_system");
		if (entity != -1)
		{
			DispatchKeyValue(entity, "effect_name", "fire_medium_01");
			DispatchSpawn(entity);
			ActivateEntity(entity);
			TeleportEntity(entity, vPos, vAng, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", projectile);

			SetVariantString("OnUser4 !self:Kill::10.0:1");
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser4");
			AcceptEntityInput(entity, "Start");
		}

		// SPARKS
		entity = CreateEntityByName("info_particle_system");
		if (entity != -1)
		{
			DispatchKeyValue(entity, "effect_name", "fireworks_sparkshower_01e");
			DispatchSpawn(entity);
			ActivateEntity(entity);
			TeleportEntity(entity, vPos, vAng, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", projectile);

			SetVariantString("OnUser4 !self:Kill::10.0:1");
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser4");
			AcceptEntityInput(entity, "Start");
		}

		// RPG SMOKE
		entity = CreateEntityByName("info_particle_system");
		if (entity != -1)
		{
			DispatchKeyValue(entity, "effect_name", "rpg_smoke");
			DispatchSpawn(entity);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "start");
			TeleportEntity(entity, vPos, vAng, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", projectile);

			SetVariantString("OnUser3 !self:Kill::10.0:1");
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser3");

			// Refire
			SetVariantString("OnUser1 !self:Stop::0.65:-1");
			AcceptEntityInput(entity, "AddOutput");
			SetVariantString("OnUser1 !self:FireUser2::0.7:-1");
			AcceptEntityInput(entity, "AddOutput");
			AcceptEntityInput(entity, "FireUser1");

			SetVariantString("OnUser2 !self:Start::0:-1");
			AcceptEntityInput(entity, "AddOutput");
			SetVariantString("OnUser2 !self:FireUser1::0:-1");
			AcceptEntityInput(entity, "AddOutput");
		}

		// SOUND	
		EmitSoundToAll(F18_Sounds[GetRandomInt(0, 5)], entity, SNDCHAN_AUTO, SNDLEVEL_HELICOPTER);
	}

	return Plugin_Continue;
}

Action TimerGrav(Handle timer, any entity)
{
	if (IsValidEntRef(entity)) CreateTimer(0.1, TimerGravity, entity, TIMER_REPEAT);

	return Plugin_Continue;
}

Action TimerGravity(Handle timer, any entity)
{
	if (IsValidEntRef(entity))
	{
		int tick = GetEntProp(entity, Prop_Data, "m_iHammerID");
		if (tick > 10)
		{
			SetEntityMoveType(entity, MOVETYPE_FLYGRAVITY);
			return Plugin_Stop;
		}
		else
		{
			SetEntProp(entity, Prop_Data, "m_iHammerID", tick + 1);

			float vAng[3];
			GetEntPropVector(entity, Prop_Data, "m_vecVelocity", vAng);
			vAng[2] -= 50.0;
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, vAng);
			return Plugin_Continue;
		}
	}
	
	return Plugin_Stop;
}

Action OnBombTouch(int entity, int activator)
{
	char sTemp[64];
	GetEdictClassname(activator, sTemp, sizeof(sTemp));

	if (strcmp(sTemp, "trigger_multiple") && strcmp(sTemp, "trigger_hurt"))
	{
		SDKUnhook(entity, SDKHook_Touch, OnBombTouch);

		CreateTimer(0.1, TimerBombTouch, EntIndexToEntRef(entity));
	}

	return Plugin_Continue;
}

Action TimerBombTouch(Handle timer, any entity)
{
	if (EntRefToEntIndex(entity) == INVALID_ENT_REFERENCE)
		return Plugin_Continue;

	float vPos[3];
	char sTemp[64];
	int g_iCvarDamage = 80;
	int g_iCvarDistance = 400;
	int g_iCvarShake = 1000;
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", vPos);
	AcceptEntityInput(entity, "Kill");

	entity = CreateEntityByName("env_explosion");
	if(entity != -1)
	{
		DispatchKeyValue(entity, "spawnflags", "1916");
		IntToString(g_iCvarDamage, sTemp, sizeof(sTemp));
		DispatchKeyValue(entity, "iMagnitude", sTemp);
		IntToString(g_iCvarDistance, sTemp, sizeof(sTemp));
		DispatchKeyValue(entity, "iRadiusOverride", sTemp);
		DispatchSpawn(entity);
		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entity, "Explode");
	}

	int shake  = CreateEntityByName("env_shake");
	if (shake != -1)
	{
		DispatchKeyValue(shake, "spawnflags", "8");
		DispatchKeyValue(shake, "amplitude", "16.0");
		DispatchKeyValue(shake, "frequency", "1.5");
		DispatchKeyValue(shake, "duration", "0.9");
		IntToString(g_iCvarShake, sTemp, sizeof(sTemp));
		DispatchKeyValue(shake, "radius", sTemp);
		DispatchSpawn(shake);
		ActivateEntity(shake);
		AcceptEntityInput(shake, "Enable");

		TeleportEntity(shake, vPos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(shake, "StartShake");

		SetVariantString("OnUser1 !self:Kill::1.1:1");
		AcceptEntityInput(shake, "AddOutput");
		AcceptEntityInput(shake, "FireUser1");
	}

	int client;
	float fDistance;
	float fNearest = 1500.0;
	float vPos2[3];

	int i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			GetClientAbsOrigin(i, vPos2);
			fDistance = GetVectorDistance(vPos, vPos2);

			if (fDistance <= fNearest)
			{
				client = i;
				fNearest = fDistance;
			}
		}
		i += 1;
	}

	if (client)
		Vocalize(client);

	entity = CreateEntityByName("info_particle_system");
	if (entity != -1)
	{
		int random = GetRandomInt(1, 4);
		if (random == 1)
			DispatchKeyValue(entity, "effect_name", EXPLOSION_PARTICLE_L4D2);
		else if (random == 2)
			DispatchKeyValue(entity, "effect_name", "missile_hit1");
		else if (random == 3)
			DispatchKeyValue(entity, "effect_name", "gas_explosion_main");
		else if (random == 4)
			DispatchKeyValue(entity, "effect_name", "explosion_huge");

		if (random == 1)
			vPos[2] += 175.0;
		else if (random == 2)
			vPos[2] += 100.0;
		else if (random == 4)
			vPos[2] += 25.0;

		DispatchSpawn(entity);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "start");

		TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

		SetVariantString("OnUser1 !self:Kill::1.0:1");
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}

	int random = GetRandomInt(0, 2);
	if (random == 0)
		EmitSoundToAll("weapons/hegrenade/explode3.wav", entity, SNDCHAN_AUTO, SNDLEVEL_HELICOPTER);
	else if (random == 1)
		EmitSoundToAll("weapons/hegrenade/explode4.wav", entity, SNDCHAN_AUTO, SNDLEVEL_HELICOPTER);
	else if (random == 2)
		EmitSoundToAll("weapons/hegrenade/explode5.wav", entity, SNDCHAN_AUTO, SNDLEVEL_HELICOPTER);

	return Plugin_Continue;
}

void Vocalize(int client)
{
	if (GetRandomInt(1, 100) > 70)
		return;

	char sTemp[64];
	GetEntPropString(client, Prop_Data, "m_ModelName", sTemp, 64);

	int random;
	if (sTemp[26] == 'c')							// c = Coach
		random = GetRandomInt(0, 2);
	else if (sTemp[26] == 'g')						// g = Gambler
		random = GetRandomInt(3, 6);
	else if (sTemp[26] == 'm' && sTemp[27] == 'e')	// me = Mechanic
		random = GetRandomInt(7, 12);
	else if (sTemp[26] == 'p')						// p = Producer
		random = GetRandomInt(13, 15);
	else
		return;

	int entity = CreateEntityByName("instanced_scripted_scene");
	if(entity!=-1)
	{
		DispatchKeyValue(entity, "SceneFile", g_sVocalize[random]);
		DispatchSpawn(entity);
		SetEntPropEnt(entity, Prop_Data, "m_hOwner", client);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "Start", client, client);
	}
}

bool IsValidEntRef(int entity)
{
	if (entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE) return true;

	return false;
}

void MoveForward(const float vPos[3], const float vAng[3], float vReturn[3], float fDistance)
{
	float vDir[3];
	GetAngleVectors(vAng, vDir, NULL_VECTOR, NULL_VECTOR);
	vReturn = vPos;
	vReturn[0] += vDir[0] * fDistance;
	vReturn[1] += vDir[1] * fDistance;
	vReturn[2] += vDir[2] * fDistance;
}

int FindRescueAreaTrigger()
{
	Address pArea = LoadFromAddress(TheNavMesh + view_as<Address>(g_iOffs_m_pRescueVehicleDepthArea), NumberType_Int32);
	if (pArea == Address_Null)
		return -1;
	
	float vecAreaCenter[3];
	L4D_GetNavAreaCenter(pArea, vecAreaCenter);

	float pos[3], mins[3], maxs[3];
	int entity = MaxClients+1;

	while ((entity = FindEntityByClassname(entity, "trigger_multiple")) != INVALID_ENT_REFERENCE)
	{
		if( !IsValidEntity(entity) )
			continue;

		if( GetEntProp(entity, Prop_Data, "m_iEntireTeam") != 2 )
			continue;

		if( !(GetEntProp(entity, Prop_Data, "m_spawnflags") & 1) )
			continue;

		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);
		GetEntPropVector(entity, Prop_Data, "m_vecMins", mins);
		GetEntPropVector(entity, Prop_Data, "m_vecMaxs", maxs);

		AddVectors(pos, mins, mins);
		AddVectors(pos, maxs, maxs);

		if (mins[0] <= vecAreaCenter[0] && vecAreaCenter[0] <= maxs[0]
		 && mins[1] <= vecAreaCenter[1] && vecAreaCenter[1] <= maxs[1]
		 && vecAreaCenter[2] <= pos[2])
		{
			return entity;
		}
	}

	return -1;
}