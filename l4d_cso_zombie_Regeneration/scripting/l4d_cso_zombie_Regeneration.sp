#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.1"
#define DEBUG 0

#define TEAM_INFECTED 		3

#define ZC_SMOKER	1
#define ZC_BOOMER	2
#define ZC_HUNTER	3
#define ZC_SPITTER	4
#define ZC_JOCKEY	5
#define ZC_CHARGER	6
#define CVAR_FLAGS			FCVAR_NOTIFY

ConVar g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarMapOff, g_hCvarMPGameMode, g_hDifficulty,
		g_hCvarWaitTime, g_hCvarSmokerHeal, g_hCvarBoomerHeal, g_hCvarHunterHeal, g_hCvarSpitterHeal,
		g_hCvarJockeyHeal, g_hCvarChargerHeal, g_hCvarTankHeal, g_hCvarZombieHP[7], g_hSoundFile;
ConVar versus_tank_bonus_health;

bool g_bCvarAllow;
float g_fClientStandStill[MAXPLAYERS+1], g_fCvarWaitTime;
int g_iRoundStart, g_iPlayerSpawn, zombieHP[7], g_iCvarSmokerHeal, g_iCvarHunterHeal, g_iCvarBoomerHeal, g_iCvarSpitterHeal,
		g_iCvarJockeyHeal, g_iCvarChargerHeal, g_iCvarTankHeal, g_iCurrentMode, g_iMaxHealth[MAXPLAYERS + 1], g_iAddHP[MAXPLAYERS + 1];
Handle hClientHealTimer[MAXPLAYERS+1];
char g_sCvarSoundFile[PLATFORM_MAX_PATH];

public Plugin myinfo = 
{
	name = "Cso zombie mode Regeneration.",
	author = "HarryPotter",
	description = "The zombies have grown stronger, now they are able to heal their injuries by standing still without receiving any damage.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/HarryPotter_TW"
};

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
	g_hDifficulty = FindConVar("z_difficulty");
	if(!L4D2Version) versus_tank_bonus_health = FindConVar("versus_tank_bonus_health");
	g_hCvarZombieHP[0] = FindConVar("z_gas_health");
	g_hCvarZombieHP[1] = FindConVar("z_hunter_health");
	g_hCvarZombieHP[2] = FindConVar("z_exploding_health");
	if (L4D2Version)
	{
		g_hCvarZombieHP[3] = FindConVar("z_spitter_health");
		g_hCvarZombieHP[4] = FindConVar("z_jockey_health");
		g_hCvarZombieHP[5] = FindConVar("z_charger_health");
	}
	g_hCvarZombieHP[6] = FindConVar("z_tank_health");
	
	g_hCvarAllow =			CreateConVar( "l4d_cso_zombie_regeneration_allow", "1", "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarModes =			CreateConVar( "l4d_cso_zombie_regeneration_modes",			"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =		CreateConVar( "l4d_cso_zombie_regeneration_modes_off",		"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =		CreateConVar( "l4d_cso_zombie_regeneration_modes_tog",		"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hCvarMapOff =			CreateConVar( "l4d_cso_zombie_regeneration_map_off",		"",				"Turn off the plugin in these maps, separate by commas (no spaces). (0=All maps, Empty = none).", CVAR_FLAGS );
	g_hCvarWaitTime =		CreateConVar( "l4d_cso_zombie_regeneration_wait_time", "4", "Seconds needed to stand still before health recovering.", CVAR_FLAGS, true, 1.0);
	g_hCvarSmokerHeal =		CreateConVar( "l4d_cso_zombie_regeneration_smoker_hp", "10", "Smoker recover hp per second. (0=off)", CVAR_FLAGS, true, 0.0);
	g_hCvarBoomerHeal =		CreateConVar( "l4d_cso_zombie_regeneration_boomer_hp", "10", "Boomer recover hp per second. (0=off)", CVAR_FLAGS, true, 0.0);
	g_hCvarHunterHeal =		CreateConVar( "l4d_cso_zombie_regeneration_hunter_hp", "40", "Hunter recover hp per second. (0=off)", CVAR_FLAGS, true, 0.0);
	
	if(L4D2Version)
	{
		g_hCvarSpitterHeal =	CreateConVar( "l4d_cso_zombie_regeneration_spitter_hp", "5", "Spitter recover hp per second. (0=off)", CVAR_FLAGS, true, 0.0);
		g_hCvarJockeyHeal =		CreateConVar( "l4d_cso_zombie_regeneration_jockey_hp", "50", "Jockey recover hp per second. (0=off)", CVAR_FLAGS, true, 0.0);
		g_hCvarChargerHeal =	CreateConVar( "l4d_cso_zombie_regeneration_charger_hp", "80", "Charger recover hp per second. (0=off)", CVAR_FLAGS, true, 0.0);
	}
	
	g_hCvarTankHeal =	CreateConVar( "l4d_cso_zombie_regeneration_tank_hp", "200", "Tank recover hp per second. (0=off)", CVAR_FLAGS, true, 0.0);
	g_hSoundFile = CreateConVar("l4d_cso_zombie_regeneration_soundfile", "ui/beep07.wav", "CSO Zombie Regeneration - Self Healing file (relative to to sound/, empty=disable)", CVAR_FLAGS);
	AutoExecConfig(true,			"l4d_cso_zombie_regeneration");
	
	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarSmokerHeal.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarBoomerHeal.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHunterHeal.AddChangeHook(ConVarChanged_Cvars);
	if(L4D2Version)
	{
		g_hCvarSpitterHeal.AddChangeHook(ConVarChanged_Cvars);
		g_hCvarJockeyHeal.AddChangeHook(ConVarChanged_Cvars);
		g_hCvarChargerHeal.AddChangeHook(ConVarChanged_Cvars);
		g_hCvarTankHeal.AddChangeHook(ConVarChanged_Cvars);
	}
	g_hSoundFile.AddChangeHook(ConVarChanged_Cvars);

	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_ZombieCvars);
	if(!L4D2Version) versus_tank_bonus_health.AddChangeHook(ConVarChanged_ZombieCvars);
	g_hDifficulty.AddChangeHook(ConVarChanged_ZombieCvars);
	g_hCvarZombieHP[0].AddChangeHook(ConVarChanged_ZombieCvars);
	g_hCvarZombieHP[1].AddChangeHook(ConVarChanged_ZombieCvars);
	g_hCvarZombieHP[2].AddChangeHook(ConVarChanged_ZombieCvars);
	if (L4D2Version)
	{
		g_hCvarZombieHP[3].AddChangeHook(ConVarChanged_ZombieCvars);
		g_hCvarZombieHP[4].AddChangeHook(ConVarChanged_ZombieCvars);
		g_hCvarZombieHP[5].AddChangeHook(ConVarChanged_ZombieCvars);
	}
	g_hCvarZombieHP[6].AddChangeHook(ConVarChanged_ZombieCvars);
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

	if(g_bValidMap)
	{
		g_hSoundFile.GetString(g_sCvarSoundFile, sizeof(g_sCvarSoundFile));
		if (strlen(g_sCvarSoundFile) > 0) PrecacheSound(g_sCvarSoundFile);
	}
}

bool g_bIsLoading;
public void OnMapEnd()
{
	g_bMapStarted = false;
	ResetPlugin();
	g_bIsLoading = true;
}

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

public void ConVarChanged_ZombieCvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	HealthCheck();
}

void GetCvars()
{
	g_fCvarWaitTime = g_hCvarWaitTime.FloatValue;
	g_iCvarSmokerHeal = g_hCvarSmokerHeal.IntValue;
	g_iCvarBoomerHeal = g_hCvarBoomerHeal.IntValue;
	g_iCvarHunterHeal = g_hCvarHunterHeal.IntValue;
	if (L4D2Version)
	{
		g_iCvarSpitterHeal = g_hCvarSpitterHeal.IntValue;
		g_iCvarJockeyHeal = g_hCvarJockeyHeal.IntValue;
		g_iCvarChargerHeal = g_hCvarChargerHeal.IntValue;
	}
	g_iCvarTankHeal = g_hCvarTankHeal.IntValue;
	g_hSoundFile.GetString(g_sCvarSoundFile, sizeof(g_sCvarSoundFile));
	if (g_bMapStarted && g_bValidMap)
	{
		if (strlen(g_sCvarSoundFile) > 0)
		{
			PrecacheSound(g_sCvarSoundFile);
		}
	}
}

void HealthCheck()
{
	static char difficulty[32];
	g_hDifficulty.GetString(difficulty, sizeof(difficulty));
	
	zombieHP[0] = g_hCvarZombieHP[0].IntValue; 
	zombieHP[1] = g_hCvarZombieHP[1].IntValue; 
	zombieHP[2] = g_hCvarZombieHP[2].IntValue;
	
	if(L4D2Version)
	{
		zombieHP[3] = g_hCvarZombieHP[3].IntValue;
		zombieHP[4] = g_hCvarZombieHP[4].IntValue;
		zombieHP[5] = g_hCvarZombieHP[5].IntValue;
	}
	
	if (g_iCurrentMode == 4)
	{
		if(L4D2Version)
			zombieHP[6] = RoundToFloor(zombieHP[6] * 1.5);	// Tank health is multiplied by 1.5x in VS	
		else
			zombieHP[6] = RoundToFloor(zombieHP[6] * versus_tank_bonus_health.FloatValue);	// Tank health is multiplied by 1.5x in VS
	}
	else if (StrContains(difficulty, "Easy", false) != -1)  
	{
		zombieHP[6] = RoundToFloor(g_hCvarZombieHP[6].IntValue * 0.75);
	}
	else if (StrContains(difficulty, "Normal", false) != -1)
	{
		zombieHP[6] = g_hCvarZombieHP[6].IntValue;
	}
	else if (StrContains(difficulty, "Hard", false) != -1 || StrContains(difficulty, "Impossible", false) != -1)
	{
		zombieHP[6] = RoundToFloor(g_hCvarZombieHP[6].IntValue * 2.0);
	}	
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();
	HealthCheck();

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

bool IsAllowedGameMode()
{
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

	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 )
	{
		if( g_bMapStarted == false )
			return false;

		g_iCurrentMode = 0;

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

void HookEvents()
{
	HookEvent("round_start",			Event_RoundStart,	EventHookMode_PostNoCopy);
	HookEvent("player_spawn",			Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	HookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
	HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("ability_use", Event_AbilityUse);
}

void UnhookEvents()
{
	UnhookEvent("round_start",			Event_RoundStart,	EventHookMode_PostNoCopy);
	UnhookEvent("player_spawn",			Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	UnhookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
	UnhookEvent("map_transition", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	UnhookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	UnhookEvent("finale_vehicle_leaving", 	Event_RoundEnd,		EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
	UnhookEvent("player_team", Event_PlayerTeam);
	UnhookEvent("player_hurt",Event_PlayerHurt);
	UnhookEvent("ability_use", Event_AbilityUse);
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
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && GetClientTeam(client) == TEAM_INFECTED && IsPlayerAlive(client) && !IsPlayerGhost(client))
    {
		int zombeclass = GetEntProp(client, Prop_Send, "m_zombieClass");
		if(L4D2Version)
		{
			switch(zombeclass)
			{
				case ZC_SMOKER: 	{g_iMaxHealth[client] = zombieHP[0]; g_iAddHP[client] = g_iCvarSmokerHeal;}
				case ZC_HUNTER: 	{g_iMaxHealth[client] = zombieHP[1]; g_iAddHP[client] = g_iCvarHunterHeal;}
				case ZC_BOOMER: 	{g_iMaxHealth[client] = zombieHP[2]; g_iAddHP[client] = g_iCvarBoomerHeal;}
				case ZC_SPITTER: 	{g_iMaxHealth[client] = zombieHP[3]; g_iAddHP[client] = g_iCvarSpitterHeal;}
				case ZC_JOCKEY: 	{g_iMaxHealth[client] = zombieHP[4]; g_iAddHP[client] = g_iCvarJockeyHeal;}
				case ZC_CHARGER: 	{g_iMaxHealth[client] = zombieHP[5]; g_iAddHP[client] = g_iCvarChargerHeal;}
				case 8: 	{g_iMaxHealth[client] = zombieHP[6]; g_iAddHP[client] = g_iCvarTankHeal;}
				default: {g_iMaxHealth[client] = g_iAddHP[client] = 0;}
			}
		}
		else
		{
			switch(zombeclass)
			{
				case ZC_SMOKER: 	{g_iMaxHealth[client] = zombieHP[0]; g_iAddHP[client] = g_iCvarSmokerHeal;}
				case ZC_HUNTER: 	{g_iMaxHealth[client] = zombieHP[1]; g_iAddHP[client] = g_iCvarHunterHeal;}
				case ZC_BOOMER: 	{g_iMaxHealth[client] = zombieHP[2]; g_iAddHP[client] = g_iCvarBoomerHeal;}
				case 5: 	{g_iMaxHealth[client] = zombieHP[6]; g_iAddHP[client] = g_iCvarTankHeal;}
				default: {g_iMaxHealth[client] = g_iAddHP[client] = 0;}
			}	
		}
	}
}

public Action tmrStart(Handle timer)
{
	ResetPlugin();
	g_bIsLoading = false;

	return Plugin_Continue;
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	StopRegeneration(client);
}

public void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && GetClientTeam(client) == TEAM_INFECTED)
	{
		StopRegeneration(client);
	}
	client = GetClientOfUserId(event.GetInt("attacker"));
	if (client && IsClientInGame(client) && GetClientTeam(client) == TEAM_INFECTED)
	{
		StopRegeneration(client);
	}
}

public void Event_AbilityUse(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && GetClientTeam(client) == TEAM_INFECTED)
 	{
		StopRegeneration(client);
	}
}

public void OnClientDisconnect(int client)
{
	StopRegeneration(client);
}

float Now_time;
int iClient;
float flVel[3];
public void OnGameFrame()
{
	//If frames aren't being processed, don't bother.
	//Otherwise we get LAG or even disconnects on map changes, etc...
	if (g_bCvarAllow == false || IsServerProcessing() == false || g_bIsLoading == true)
	{
		return;
	}
	else
	{
		Now_time = GetEngineTime();
		for (iClient = 1; iClient <= MaxClients; iClient++)
		{
			if(IsClientInGame(iClient) && GetClientTeam(iClient) == TEAM_INFECTED && IsPlayerAlive(iClient) && !IsPlayerGhost(iClient))
			{
				GetEntPropVector(iClient, Prop_Data, "m_vecAbsVelocity", flVel);
				if(flVel[0] == 0.0 && flVel[1] == 0.0 && flVel[2] == 0.0)
				{
					if( g_fClientStandStill[iClient] > 0 && (Now_time - g_fClientStandStill[iClient] >= g_fCvarWaitTime) && hClientHealTimer[iClient] == null)
					{
						hClientHealTimer[iClient] = CreateTimer(1.0, Timer_Regeneration, iClient ,TIMER_REPEAT);
					}
				}
				else
				{
					StopRegeneration(iClient);
				}
			}
		}
	}
}

public Action Timer_Regeneration(Handle timer, int client)
{
	if(!IsClientInGame(client) 
	|| GetClientTeam(client) != TEAM_INFECTED 
	|| !IsPlayerAlive(client) 
	|| IsPlayerGhost(client) 
	|| CSO_ZOMBIE_Regeneration(client) == false)
	{
		g_fClientStandStill[client] = 0.0;
		hClientHealTimer[client] = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

void StopRegeneration(int client)
{
	g_fClientStandStill[client] = GetEngineTime();
	if(hClientHealTimer[client] != null) delete hClientHealTimer[client];
}

bool CSO_ZOMBIE_Regeneration(int client)
{
	int CurrentHealth = GetClientHealth(client);
	bool bHealAgain = false;
	#if DEBUG
		PrintToChatAll("%N: health: %d, max health: %d, addhp: %d",client, CurrentHealth, g_iMaxHealth[client], g_iAddHP[client]);
	#endif
	if(CurrentHealth < g_iMaxHealth[client] && g_iAddHP[client] > 0)
	{
		if(CurrentHealth + g_iAddHP[client] > g_iMaxHealth[client]) 
		{
			SetEntityHealth(client, g_iMaxHealth[client]);
		}
		else
		{
			SetEntityHealth(client, CurrentHealth + g_iAddHP[client]);
			bHealAgain = true;
		}

		#if DEBUG
			PrintToChatAll("%N is self healing",client);
		#endif

		if (strlen(g_sCvarSoundFile) > 0) EmitSoundToClient(client, g_sCvarSoundFile, _, SNDCHAN_AUTO, SNDLEVEL_CONVO, _, SNDVOL_NORMAL, _, _, _, _, _, _ );
	}
	return bHealAgain;
}

bool IsPlayerGhost (int client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost"))
		return true;
	return false;
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		StopRegeneration(i);
	}
}