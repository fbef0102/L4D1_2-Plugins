
#define PLUGIN_VERSION 		"1.4"
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

#define NUKE_SOUND_L4D2 "animation/overpass_jets.wav"
#define NUKE_SOUND_L4D1 "animation/gas_station_explosion.wav"
#define EXPLOSION_SOUND_L4D2 "ambient/explosions/explode_1.wav"
#define EXPLOSION_SOUND_L4D1 "ambient/explosions/explode_3.wav"
#define EXPLOSION_DEBRIS_L4D2 "animation/plantation_exlposion.wav"
#define FIRE_PARTICLE "gas_explosion_ground_fire"
#define EXPLOSION_PARTICLE_L4D2 "FluidExplosion_fps"
#define SPRITE_MODEL "sprites/muzzleflash4.vmt"

#define FFADE_IN            0x0001
#define FFADE_OUT           0x0002
#define FFADE_MODULATE      0x0004
#define FFADE_STAYOUT       0x0008
#define FFADE_PURGE         0x0010

#define MAX_ENTITIES		8

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

// Cvar Handles/Variables
ConVar g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarMapOff, g_hCvarAnnounceType;

// Plugin Variables
ConVar g_hCvarMPGameMode;
int g_iRoundStart, g_iPlayerSpawn, g_iCvarTime;
int iSystemTime, g_iData[MAX_DATAS];
bool g_bFinalVehicleReady, g_bFinalHasEscapeVehicle, g_bFinalVehicleLeaving;
bool g_bClientInVehicle[MAXPLAYERS+1];
Handle AntiPussyTimer, _AntiPussyTimer, AirstrikeTimer;

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

bool g_bLeft4Dead2;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead2)
	{
		g_bLeft4Dead2 = true;
	}
	else if( test == Engine_Left4Dead)
	{
		g_bLeft4Dead2 = false;
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

		if(g_bLeft4Dead2)
		{
			PrecacheSound(NUKE_SOUND_L4D2);
			PrecacheSound(EXPLOSION_SOUND_L4D2);
			PrecacheSound(EXPLOSION_DEBRIS_L4D2);
			PrecacheParticle(EXPLOSION_PARTICLE_L4D2);
			for(int i = 0; i < 6; i++)
			{
				PrecacheSound(F18_Sounds[i], true);
			}

			PrecacheModel("models/f18/f18_sb.mdl", true);
			PrecacheModel("models/missiles/f18_agm65maverick.mdl", true);
		}
		else
		{
			PrecacheSound(NUKE_SOUND_L4D1);
			PrecacheSound(EXPLOSION_SOUND_L4D1);
		}
		PrecacheParticle(FIRE_PARTICLE);
		PrecacheModel(SPRITE_MODEL, true);
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

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bFinalVehicleLeaving = false;

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

	return Plugin_Continue;
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

public void Finale_Vehicle_Leaving(Event event, const char[] name, bool dontBroadcast)
{
	g_bFinalVehicleLeaving = true;
}

public void Finale_Vehicle_Ready(Event event, const char[] name, bool dontBroadcast)
{
	g_bFinalVehicleReady = true;
	
	if(g_bFinalHasEscapeVehicle)
	{
		iSystemTime = g_iCvarTime;
		delete AntiPussyTimer;
		AntiPussyTimer = CreateTimer(1.0, Timer_AntiPussy, _, TIMER_REPEAT);

		if(g_bLeft4Dead2) 
		{
			delete AirstrikeTimer;
			AirstrikeTimer = CreateTimer(2.5, Timer_StartAirstrike, _, TIMER_REPEAT);
		}
	}
}

public Action Timer_AntiPussy(Handle timer)
{
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
		if(g_bLeft4Dead2)
		{
			EmitSoundToAll(NUKE_SOUND_L4D2);
		}
		else
		{
			EmitSoundToAll(NUKE_SOUND_L4D1);
		}

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

public Action Timer_Strike(Handle timer)
{
	float radius = 1.0, pos[3];
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if(IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i))
		{
			//fade
			CreateTimer(0.1, Timer_FadeOut, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);

			if(IsInFinalRescueVehicle(i)) continue;
			
			//explosion effect
			GetClientAbsOrigin(i, pos);
			pos[0] += GetRandomFloat(radius*-1, radius);
			pos[1] += GetRandomFloat(radius*-1, radius);
			CreateExplosion(pos);

			//slay
			CreateTimer(2.2, Timer_SlayPlayer, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);

			//hint
			CPrintToChat(i, "{default}[{olive}TS{default}] %T", "You have been executed for not being on rescue vehicle or zone!", i);
		}
	}

	_AntiPussyTimer = CreateTimer(3.0, Timer_Strike);
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
	delete AirstrikeTimer;
}

bool IsInFinalRescueVehicle(int client)
{
	return g_bClientInVehicle[client];
}

stock int Entity_GetHammerId(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iHammerID");
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

Action Timer_FadeOut(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client))
	{
		CreateFade(FFADE_OUT, client);
		CreateTimer(4.0, Timer_FadeIn, userid, TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Continue;
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

	if(g_bLeft4Dead2)
	{
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
	}
	if((ent = CreateEntityByName("env_explosion")) != -1)
	{
		DispatchKeyValue(ent, "fireballsprite", SPRITE_MODEL);
		DispatchKeyValue(ent, "iMagnitude", "1");
		DispatchKeyValue(ent, "iRadiusOverride", "1");
		DispatchKeyValue(ent, "spawnflags", "828");
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(ent);

		AcceptEntityInput(ent, "Explode");
		SetVariantString(buffer);
		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser1");
	}
	if((ent = CreateEntityByName("env_physexplosion")) != -1)
	{
		DispatchKeyValue(ent, "radius", "1");
		DispatchKeyValue(ent, "magnitude", "1");
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(ent);

		AcceptEntityInput(ent, "Explode");
		SetVariantString(buffer);
		AcceptEntityInput(ent, "AddOutput");
		AcceptEntityInput(ent, "FireUser1");
	}

	if(g_bLeft4Dead2)
	{
		EmitAmbientSound(EXPLOSION_SOUND_L4D2, pos);
		EmitAmbientSound(EXPLOSION_DEBRIS_L4D2, pos);
	}
	else
	{
		EmitAmbientSound(EXPLOSION_SOUND_L4D1, pos);
	}
}

Action Timer_SlayPlayer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && IsPlayerAlive(client))
	{
		ForcePlayerSuicide(client);
	}

	return Plugin_Continue;
}


/* =============================================================================================================== *
 *               Silvers AirStrike Plugin Edited By SupermenCJ, and Adjusted To Rescue Leav Timer Plugin			*
 *================================================================================================================ */

Action Timer_StartAirstrike(Handle timer)
{
	int client = my_GetRandomClient();
	if(client == 0) return Plugin_Continue;

	float g_pos[3];
	float vAng[3];
	GetClientAbsOrigin(client, g_pos);
	GetClientEyeAngles(client, vAng);
	
	DataPack h = new DataPack();
	h.WriteFloat(g_pos[0]);
	h.WriteFloat(g_pos[1]);
	h.WriteFloat(g_pos[2]);
	h.WriteFloat(vAng[1]);

	CreateTimer(0.5, UpdateAirstrike, h, TIMER_FLAG_NO_MAPCHANGE);

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

public Action OnBombTouch(int entity, int activator)
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
	IntToString(g_iCvarDamage, sTemp, sizeof(sTemp));

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