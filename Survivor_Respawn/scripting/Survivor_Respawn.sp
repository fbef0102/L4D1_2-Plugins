#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <topmenus>
#include <adminmenu>
#include <left4dhooks>

#pragma semicolon 1
#pragma newdecls required

/* Definition Strings */
#define PLUGIN_VERSION 			"3.3"
#define TRANSLATION_FILENAME 	"SurvivorRespawn.phrases"

/* Definition Integers */
#define TEAM_SPECTATOR 	1
#define TEAM_SURVIVOR 	2

/* Booleans */
bool bRespawn = false;
bool bIncludeBots = false;
bool bRespawnIncapped = false;
bool bIncludeHanging = false;
bool bEnablesRespawnLimit = false;
bool bRescuable[ MAXPLAYERS + 1 ] = {false};
bool bFinaleEscapeStarted = false;
bool g_bRoundEnd = false;
static bool bL4D2;

/* ConVars */
ConVar hCvar_Enable;
ConVar hCvar_IncludeBots;
ConVar hCvar_RespawnHanging;
ConVar hCvar_RespawnIncapped;
ConVar hCvar_RespawnRespect;
ConVar hCvar_RespawnLimit;
ConVar hCvar_RespawnTimeout;
ConVar hCvar_RespawnHP;
ConVar hCvar_RespawnBuffHP;
ConVar hCvar_IncapDelay;
ConVar hCvar_HangingDelay;
ConVar hCvar_SaveStats;
ConVar hCvar_BotReplaced;
ConVar hCvar_InvincibleTime;
ConVar hCvar_EscapeDisable;

ConVar FirstWeapon;
ConVar SecondWeapon;
ConVar ThrownWeapon;
ConVar PrimeHealth;
ConVar SecondaryHealth;

int g_iRespawnLimit, g_iRespawnTimeout;
bool g_bSaveStats, g_bEscapeDisable;
float g_fInvincibleTime;

/* Handler Menu */
TopMenu hTopMenu;

/* Timer Handles With Arrays */
Handle RespawnTimer[ MAXPLAYERS + 1 ];
Handle HangingTimer[ MAXPLAYERS + 1 ];
Handle IncapTimer[ MAXPLAYERS + 1 ];

int RespawnLimit[ MAXPLAYERS + 1 ] = {0};
int BufferHP = -1;

/* Arrays */
char sPlayerSave[45][] =
{
    "m_checkpointAwardCounts",
    "m_missionAwardCounts",
    "m_checkpointZombieKills",
    "m_missionZombieKills",
    "m_checkpointSurvivorDamage",
    "m_missionSurvivorDamage",
    "m_classSpawnCount",
    "m_checkpointMedkitsUsed",
    "m_checkpointPillsUsed",
    "m_missionMedkitsUsed",
    "m_checkpointMolotovsUsed",
    "m_missionMolotovsUsed",
    "m_checkpointPipebombsUsed",
    "m_missionPipebombsUsed",
    "m_missionPillsUsed",
    "m_checkpointDamageTaken",
    "m_missionDamageTaken",
    "m_checkpointReviveOtherCount",
    "m_missionReviveOtherCount",
    "m_checkpointFirstAidShared",
    "m_missionFirstAidShared",
    "m_checkpointIncaps",
    "m_missionIncaps",
    "m_checkpointDamageToTank",
    "m_checkpointDamageToWitch",
    "m_missionAccuracy",
    "m_checkpointHeadshots",
    "m_checkpointHeadshotAccuracy",
    "m_missionHeadshotAccuracy",
    "m_checkpointDeaths",
    "m_missionDeaths",
    "m_checkpointPZIncaps",
    "m_checkpointPZTankDamage",
    "m_checkpointPZHunterDamage",
    "m_checkpointPZSmokerDamage",
    "m_checkpointPZBoomerDamage",
    "m_checkpointPZKills",
    "m_checkpointPZPounces",
    "m_checkpointPZPushes",
    "m_checkpointPZTankPunches",
    "m_checkpointPZTankThrows",
    "m_checkpointPZHung",
    "m_checkpointPZPulled",
    "m_checkpointPZBombed",
    "m_checkpointPZVomited"
};

char sPlayerSave_L4D2[15][] =
{
    "m_checkpointBoomerBilesUsed",
    "m_missionBoomerBilesUsed",
    "m_checkpointAdrenalinesUsed",
    "m_missionAdrenalinesUsed",
    "m_checkpointDefibrillatorsUsed",
    "m_missionDefibrillatorsUsed",
    "m_checkpointMeleeKills",
    "m_missionMeleeKills",
    "m_checkpointPZJockeyDamage",
    "m_checkpointPZSpitterDamage",
    "m_checkpointPZChargerDamage",    
	"m_checkpointPZHighestDmgPounce",
    "m_checkpointPZLongestSmokerGrab",
    "m_checkpointPZLongestJockeyRide",
    "m_checkpointPZNumChargeVictims"
};

int iPlayerData[ MAXPLAYERS + 1 ][ sizeof( sPlayerSave ) ];
int iPlayerData_L4D2[ MAXPLAYERS + 1 ][ sizeof( sPlayerSave_L4D2 ) ];
float fPlayerData[ MAXPLAYERS + 1 ][ 2 ];
int Seconds[ MAXPLAYERS + 1 ];
float clinetReSpawnTime[ MAXPLAYERS + 1 ];

/* Float Coordinates */
float vsrPos[3];

bool g_bIsOpenSafeRoom;

#define SOUND_RESPAWN "ui/helpful_event_1.wav"

public Plugin myinfo = 
{
    name 		= "[L4D1 AND L4D2] Survivor Respawn",
    author 		= "Mortiegama And Ernecio (Satanael) & HarryPotter",
    description = "When a Survivor dies, is hanging, or is incapped, will respawn after a period of time.",
    version 	= PLUGIN_VERSION,
    url 		= "https://steamcommunity.com/profiles/76561198404709570/"
}


bool bLate;
public APLRes AskPluginLoad2( Handle myself, bool late, char[] error, int err_max )
{	
	EngineVersion engine = GetEngineVersion();
	if ( engine != Engine_Left4Dead && engine != Engine_Left4Dead2 )
	{
		strcopy( error, err_max, "This plugin \"Survivor Respawn\" only runs in the \"Left 4 Dead 1/2\" Games!" );
		return APLRes_SilentFailure;
	}
	
	bL4D2 = ( engine == Engine_Left4Dead2 );
	
	bLate = late;
	return APLRes_Success;
}

void Load_Translations()
{
	LoadTranslations( "common.phrases" ); // SourceMod Native (Add native SourceMod translations to the menu).
	
	char sPath[PLATFORM_MAX_PATH];
	BuildPath( Path_SM, sPath, PLATFORM_MAX_PATH, "translations/%s.txt", TRANSLATION_FILENAME );
	if (FileExists( sPath ) )
		LoadTranslations( TRANSLATION_FILENAME);
	else
		SetFailState( "Missing required translation file on \"translations/%s.txt\", please re-download.", TRANSLATION_FILENAME );
}

public void OnPluginStart()
{
	Load_Translations();
	
	CreateConVar( 						   "l4d_survivorrespawn_version", 	PLUGIN_VERSION, "Survivor Respawning Version", FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_NOTIFY);
	hCvar_Enable 			= CreateConVar("l4d_survivorrespawn_enable", 			"1", 	"Enables Survivors to respawn automatically when incapped and/or killed (Def 1)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_IncludeBots 		= CreateConVar("l4d_survivorrespawn_enablebot", 		"1", 	"Allows Bots to respawn automatically when incapped and/or killed (Def 1)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_RespawnHanging 	= CreateConVar("l4d_survivorrespawn_hanging", 			"0", 	"Survivors will be killed when hanging and respawn afterwards (Def 0)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_RespawnIncapped 	= CreateConVar("l4d_survivorrespawn_incapped", 			"0", 	"Survivors will be killed when incapped and respawn afterwards (Def 0)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_RespawnRespect 	= CreateConVar("l4d_survivorrespawn_limitenable", 		"1", 	"Enables the respawn limit for Survivors (Def 1)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_RespawnLimit 		= CreateConVar("l4d_survivorrespawn_deathlimit", 		"3", 	"Amount of times a Survivor can respawn before permanently dying (Def 3)", FCVAR_NOTIFY, true, 0.0, false, _);
	hCvar_RespawnTimeout 	= CreateConVar("l4d_survivorrespawn_respawntimeout", 	"30", 	"How many seconds till the Survivor respawns (Def 30)", FCVAR_NOTIFY, true, 0.0, false, _);
	hCvar_IncapDelay 		= CreateConVar("l4d_survivorrespawn_incapdelay", 		"25", 	"How many seconds till the Survivor is killed after being incapacitated (Def 25)", FCVAR_NOTIFY, true, 0.0, false, _);
	hCvar_HangingDelay 		= CreateConVar("l4d_survivorrespawn_hangingdelay", 		"25", 	"How many seconds till the Survivor is killed while hanging (Def 25)", FCVAR_NOTIFY, true, 0.0, false, _);
	hCvar_RespawnHP 		= CreateConVar("l4d_survivorrespawn_respawnhp", 		"70", 	"Amount of HP a Survivor will respawn with (Def 70)", FCVAR_NOTIFY, true, 0.0, false, _);
	hCvar_RespawnBuffHP 	= CreateConVar("l4d_survivorrespawn_respawnbuffhp", 	"30", 	"Amount of buffer HP a Survivor will respawn with (Def 30)", FCVAR_NOTIFY, true, 0.0, false, _);
	hCvar_SaveStats 		= CreateConVar("l4d_survivorrespawn_savestats", 		"1", 	"Save player statistics if is have died.",  FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_BotReplaced 		= CreateConVar("l4d_survivorrespawn_botreplaced", 		"1", 	"Respawn bots if is dead in case of using Take Over.",  FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_InvincibleTime 	= CreateConVar("l4d_survivorrespawn_invincibletime", 	"10.0", "Invincible time after survivor respawn.",  FCVAR_NOTIFY, true, 0.0);
	hCvar_EscapeDisable 	= CreateConVar("l4d_survivorrespawn_disable_rescue_escape", "1", "If 1, disable respawning while the final escape starts (rescue vehicle ready)",  FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	if ( bL4D2 ) {
		FirstWeapon 		= CreateConVar("l4d_survivorrespawn_firstweapon", 		"9", 	"Which is first slot weapon will be given to the Survivor (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - AK47 Assault Rifle, 5 - SCAR-L Desert Rifle,\n6 - M60 Assault Rifle, 7 - Military Sniper Rifle, 8 - SPAS Shotgun, 9 - Chrome Shotgun, 10 - Smg, 0 - None.)", FCVAR_NOTIFY, true, 0.0, true, 10.0);
		SecondWeapon 		= CreateConVar("l4d_survivorrespawn_secondweapon", 		"1", 	"Which is second slot weapon will be given to the Survivor (1 - Dual Pistol, 2 - Bat, 3 - Magnum, 0 - Only Pistol)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
		ThrownWeapon 		= CreateConVar("l4d_survivorrespawn_thrownweapon", 		"3", 	"Which is thrown weapon will be given to the Survivor (1 - Moltov, 2 - Pipe Bomb, 3 - Bile Jar, 0 - None)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
		PrimeHealth 		= CreateConVar("l4d_survivorrespawn_primehealth", 		"1", 	"Which prime health unit will be given to the Survivor (1 - Medkit, 2 - Defib, 0 - None)", FCVAR_NOTIFY, true, 0.0, true, 2.0);
		SecondaryHealth 	= CreateConVar("l4d_survivorrespawn_secondaryhealth", 	"2", 	"Which secondary health unit will be given to the Survivor (1 - Pills, 2 - Adrenaline, 0 - None)", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	} else {
		FirstWeapon 		= CreateConVar("l4d_survivorrespawn_firstweapon", 		"5", 	"Which is first slot weapon will be given to the Survivor (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - Smg, 5 - Pumpshotgun, 0 - None.)", FCVAR_NOTIFY, true, 0.0, true, 5.0);
		SecondWeapon 		= CreateConVar("l4d_survivorrespawn_secondweapon", 		"1", 	"Which is second slot weapon will be given to the Survivor (1 - Dual Pistol, 0 - Only Pistol)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
		ThrownWeapon 		= CreateConVar("l4d_survivorrespawn_thrownweapon", 		"2", 	"Which is thrown weapon will be given to the Survivor (1 - Moltov, 2 - Pipe Bomb, 0 - None)", FCVAR_NOTIFY, true, 0.0, true, 2.0);
		PrimeHealth 		= CreateConVar("l4d_survivorrespawn_primehealth", 		"1", 	"Which prime health unit will be given to the Survivor (1 - Medkit, 0 - None)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
		SecondaryHealth 	= CreateConVar("l4d_survivorrespawn_secondaryhealth", 	"1", 	"Which secondary health unit will be given to the Survivor (1 - Pills, 0 - None)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	}
	
	GetCvars();
	hCvar_Enable.AddChangeHook(ConVarChanged_Cvars);
	hCvar_IncludeBots.AddChangeHook(ConVarChanged_Cvars);
	hCvar_RespawnHanging.AddChangeHook(ConVarChanged_Cvars);
	hCvar_RespawnIncapped.AddChangeHook(ConVarChanged_Cvars);
	hCvar_RespawnRespect.AddChangeHook(ConVarChanged_Cvars);
	hCvar_RespawnLimit.AddChangeHook(ConVarChanged_Cvars);
	hCvar_RespawnTimeout.AddChangeHook(ConVarChanged_Cvars);
	hCvar_SaveStats.AddChangeHook(ConVarChanged_Cvars);
	hCvar_InvincibleTime.AddChangeHook(ConVarChanged_Cvars);
	hCvar_EscapeDisable.AddChangeHook(ConVarChanged_Cvars);
	
	AutoExecConfig( true, "SurvivorRespawn" );
	
	HookEvent("player_bot_replace", OnBotSwap);
	HookEvent("bot_player_replace", OnBotSwap);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post );
	HookEvent("player_bot_replace", Event_BotReplace, EventHookMode_Post );
	HookEvent("bot_player_replace", Event_PlayerReplace );
	HookEvent("player_ledge_grab", Event_PlayerLedgeGrab);
	HookEvent("revive_success", Event_ReviveSuccess);
	HookEvent("player_incapacitated", Event_PlayerIncapped);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("map_transition", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("mission_lost", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("finale_vehicle_leaving", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("finale_escape_start", Finale_Escape_Start);
	HookEvent("finale_vehicle_ready", Finale_Vehicle_Ready);
	
	RegAdminCmd( "sm_respawnex", CMD_Respawn, ADMFLAG_BAN, "Respawn Target/s At Your Crosshair." );
	RegAdminCmd( "sm_respawnexmenu", CMD_DisplayMenu, ADMFLAG_BAN, "Create A Menu Of Clients List And Respawn Targets At Your Crosshair." );
	
	BufferHP = FindSendPropInfo( "CTerrorPlayer", "m_healthBuffer" );
	
	if (bLate)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
}

public void OnPluginEnd()
{
	for ( int client = 1; client <= MaxClients; client ++ )
	{
		RespawnLimit[client] = 0;
		clinetReSpawnTime[client] = 0.0;

		delete RespawnTimer[client];
		delete HangingTimer[client];
		delete IncapTimer[client];
	}
}

public void OnMapStart()
{
	PrecacheSound(SOUND_RESPAWN);
}

public void OnMapEnd()
{
	for ( int client = 1; client <= MaxClients; client ++ )
	{
		RespawnLimit[client] = 0;
		clinetReSpawnTime[client] = 0.0;

		delete RespawnTimer[client];
		delete HangingTimer[client];
		delete IncapTimer[client];
	}
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	bRespawn = hCvar_Enable.BoolValue;
	bIncludeBots = hCvar_IncludeBots.BoolValue;
	bIncludeHanging = hCvar_RespawnHanging.BoolValue;
	bRespawnIncapped = hCvar_RespawnIncapped.BoolValue;
	bEnablesRespawnLimit = hCvar_RespawnRespect.BoolValue;
	g_iRespawnLimit = hCvar_RespawnLimit.IntValue;
	g_iRespawnTimeout = hCvar_RespawnTimeout.IntValue;
	g_bSaveStats = hCvar_SaveStats.BoolValue;
	g_fInvincibleTime = hCvar_InvincibleTime.FloatValue;
	g_bEscapeDisable = hCvar_EscapeDisable.BoolValue;
}

public void Event_RoundStart( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	g_bIsOpenSafeRoom = false;
	g_bRoundEnd = false;
	bFinaleEscapeStarted = false;
	for ( int client = 1; client <= MaxClients; client ++ )
	{
		RespawnLimit[client] = 0;
		clinetReSpawnTime[client] = 0.0;

		delete RespawnTimer[client];
		delete HangingTimer[client];
		delete IncapTimer[client];
	}
}

public void Event_RoundEnd( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	for ( int client = 1; client <= MaxClients; client ++ )
	{
		bRescuable[client] = false;
		
		delete RespawnTimer[client];
		delete HangingTimer[client];
		delete IncapTimer[client];
	}

	g_bIsOpenSafeRoom = false;
	g_bRoundEnd = true;
}

public void Finale_Escape_Start(Event event, const char[] name, bool dontBroadcast) 
{
	bFinaleEscapeStarted = true;
}

public void Finale_Vehicle_Ready(Event event, const char[] name, bool dontBroadcast) 
{
	bFinaleEscapeStarted = true;
}

public void Event_PlayerLedgeGrab( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId( hEvent.GetInt( "userid" ) );

	if ( bRespawn && bIncludeHanging && IsValidClient( client ) )
	{
		HangingTimer[client] = CreateTimer( hCvar_HangingDelay.FloatValue, Timer_HangingRespawn, client ); 
		bRescuable[client] = true;
	}
}

public Action Timer_HangingRespawn( Handle hTimer, any client)
{
	if (IsValidClient(client) && bRescuable[client] && IsPlayerHanging(client))
	{
		if ( RespawnLimit[client] < g_iRespawnLimit )
		{
			ForcePlayerSuicide(client);
			bRescuable[client] = false;
		}
		else if ( RespawnLimit[client] >= g_iRespawnLimit )
		{
			PrintHintText( client, "%t", "Respawn Limit" );
			bRescuable[client] = false;
		}
	}
	
	if (IsValidClient(client) && IsPlayerAlive(client))
		bRescuable[client] = false;
	
	HangingTimer[client] = null;
	return Plugin_Stop;
}

public void Event_PlayerIncapped( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId( hEvent.GetInt( "userid" ) );

	if (bRespawn && bRespawnIncapped && IsValidClient(client))
	{
		IncapTimer[client] = CreateTimer( hCvar_IncapDelay.FloatValue, Timer_IncapRespawn, client ); 
		bRescuable[client] = true;
	}
}

public Action Timer_IncapRespawn( Handle hTimer, any client)
{
	if (IsValidClient(client) && bRescuable[client] && IsPlayerIncapped(client))
	{
		if ( RespawnLimit[client] < g_iRespawnLimit )
			ForcePlayerSuicide(client);
		else if ( RespawnLimit[client] >= g_iRespawnLimit )
			PrintHintText( client, "%t", "Respawn Limit" );
	}

	if (IsValidClient(client) && IsPlayerAlive(client))
		bRescuable[client] = false;
	
	IncapTimer[client] = null;
	
	return Plugin_Continue;
}

public void OnBotSwap(Event event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(GetEventInt(event, "bot"));
	int player = GetClientOfUserId(GetEventInt(event, "player"));
	if (bot > 0 && bot <= MaxClients && player > 0 && player<= MaxClients) 
	{
		if (strcmp(name, "player_bot_replace") == 0) 
		{
			clinetReSpawnTime[bot] = clinetReSpawnTime[player];
			clinetReSpawnTime[player] = 0.0;	
		}
		else 
		{
			clinetReSpawnTime[player] = clinetReSpawnTime[bot];
			clinetReSpawnTime[bot] = 0.0;	
		}
	}
}

public void Event_PlayerDeath( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId( hEvent.GetInt( "userid" ) );

	if(!IsValidClient(client)) return;

	if (g_bRoundEnd) return;

	if(g_bIsOpenSafeRoom) 
	{
		PrintHintText( client, "%T", "Couldn't respawn after the saferoom door is open.", client );
		return;
	}
	if(bFinaleEscapeStarted && g_bEscapeDisable)
	{
		PrintHintText( client, "%T", "Couldn't respawn when final vehicle is coming.", client );
		return;
	}

	if ( bRespawn && clinetReSpawnTime[client] > GetEngineTime() )
	{
		PrintHintText( client, "%T", "You will be respawned again.", client );
		
		CreateTimer( 3.0, RespawnAgain, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE );
		return;
	}

	if ( bRespawn && !bEnablesRespawnLimit)
	{
		RespawnTimer[client] = CreateTimer( float(g_iRespawnTimeout), Timer_Respawn, client ); 
		
		Seconds[client] = g_iRespawnTimeout;
		CreateTimer( 1.0, TimerCount, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
		
		if ( g_bSaveStats )
			SaveStats( client );
		
		bRescuable[client] = false;
	}

	if ( bRespawn && bEnablesRespawnLimit)
	{
		if ( RespawnLimit[client] < g_iRespawnLimit )
		{
			RespawnTimer[client] = CreateTimer( float(g_iRespawnTimeout), Timer_Respawn, client); 
			
			CreateTimer( 1.0, TimerCount, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE ); 
			
			if ( g_bSaveStats )
				SaveStats( client );
			
			Seconds[client] = g_iRespawnTimeout;
			bRescuable[client] = false;
		}
		else if ( RespawnLimit[client] >= g_iRespawnLimit )
		{
			PrintHintText( client, "%t", "Respawn Limit" );
			bRescuable[client] = false;
		}
	}
}

public void Event_BotReplace( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int bot = GetClientOfUserId( hEvent.GetInt( "bot" ) );
	
	if ( IsPlayerAlive( bot ) || !IsValidClient( bot ) || !IsFakeClient( bot ) || !hCvar_BotReplaced.BoolValue || g_bIsOpenSafeRoom || (bFinaleEscapeStarted && g_bEscapeDisable) || g_bRoundEnd ) return;

	if ( bRespawn && !bEnablesRespawnLimit)
	{
		RespawnTimer[bot] = CreateTimer( float(g_iRespawnTimeout), Timer_Respawn, bot );
		bRescuable[bot] = false;

	}

	if ( bRespawn && bEnablesRespawnLimit)
	{
		if ( RespawnLimit[bot] < g_iRespawnLimit )
		{
			RespawnTimer[bot] = CreateTimer( float(g_iRespawnTimeout), Timer_Respawn, bot ); 
			bRescuable[bot] = false;
		}
		else if ( RespawnLimit[bot] >= g_iRespawnLimit )
			bRescuable[bot] = false;
	}
}

public void Event_PlayerReplace( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId( hEvent.GetInt( "player" ) );
	int bot = GetClientOfUserId( hEvent.GetInt( "bot" ) );
	if( !client || !IsClientInGame(client)) return;
	if( !bot || !IsClientInGame(bot)) return;

	delete RespawnTimer[client];
	if(GetClientTeam(client) == TEAM_SURVIVOR && !IsPlayerAlive(client))
	{
		if ( bRespawn && bEnablesRespawnLimit)
		{
			if ( RespawnLimit[client] < g_iRespawnLimit )
			{
				RespawnTimer[client] = CreateTimer( float(g_iRespawnTimeout), Timer_Respawn, client); 
				
				CreateTimer( 1.0, TimerCount, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE ); 
				
				Seconds[client] = g_iRespawnTimeout;
				bRescuable[client] = false;
			}
			else if ( RespawnLimit[client] >= g_iRespawnLimit )
			{
				PrintHintText( client, "%t", "Respawn Limit" );
				bRescuable[client] = false;
			}
		}

		//PrintToChatAll( "\x03%N \x01has replaced dead \x04%N", client, bot ); // Test.
	}
}

public void Event_PlayerSpawn( Event hEvent, const char[] sName, bool bDontBroadcast )
{	
	int UserID = hEvent.GetInt( "userid" );
	int client = GetClientOfUserId(UserID);
	
	delete RespawnTimer[client];
}

public void Event_ReviveSuccess( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId( hEvent.GetInt( "victim" ) );
	bRescuable[client] = false;
}

/******************************************************************************************************/

public Action CMD_Respawn( int client, int args )
{
	if ( args < 1 )
	{
		ReplyToCommand( client, "\x04[\x01SM\x04] %t", "CMD Respawn" );
		return Plugin_Handled;
	}
	
	char sArgs[MAX_TARGET_LENGTH];
	char sTargetName[MAX_TARGET_LENGTH];
	int  iTargetList[MAXPLAYERS];
	int  iTargetCount;
	bool bTN_IS_ML;
	
	GetCmdArg( 1, sArgs, sizeof( sArgs ) );
	
	if ( ( iTargetCount = ProcessTargetString( sArgs, client, iTargetList, MAXPLAYERS, 0, sTargetName, sizeof( sTargetName ), bTN_IS_ML ) ) <= 0 )
	{
		ReplyToTargetError( client, iTargetCount ); // Create an error report if there are two targets with the same name.
		return Plugin_Handled;
	}
	
	for ( int i = 0; i < iTargetCount; i ++ )
		if ( IsValidClient( iTargetList[i] ) && !IsPlayerAlive( iTargetList[i] ) )
			RespawnTarget_Crosshair( client, iTargetList[i] );
		else if ( IsValidClient( iTargetList[i] ) )
			PrintToChat( client, "%t", "No Need To Respawn", iTargetList[i] );
	
	return Plugin_Handled;
}

public Action CMD_DisplayMenu( int client, int args )
{
	if ( client == 0 )
	{
		ReplyToCommand( client, "[SM] %t", "Command is in-game only" ); // SourceMod Native.
		return Plugin_Handled;
	}
	
	DisplayRespawnMenu( client );
	return Plugin_Handled;
}
/***********************************************************************************************************/
void DisplayRespawnMenu( int client )
{
	Menu hMenu = new Menu( MenuHandler_Respawn );
	
	char sTitle[100];
	Format( sTitle, sizeof( sTitle ), "%T", "Respawn Menu", client );
	hMenu.SetTitle( sTitle );
	
	if (Custom_AddTargetsToMenu( hMenu ) == 0)
		delete hMenu;
	else
		hMenu.Display( client, MENU_TIME_FOREVER );
}

public int MenuHandler_Respawn( Menu hMenu, MenuAction hAction, int Param1, int Param2 )
{
	if ( hAction == MenuAction_End )
		delete hMenu;
	
	else if ( hAction == MenuAction_Cancel )
	{
		if ( Param2 == MenuCancel_ExitBack && hTopMenu )
			hTopMenu.Display( Param1, TopMenuPosition_LastCategory );
	}
	else if ( hAction == MenuAction_Select )
	{
		char sInfo[32];
		int UserID, Target;
		
		hMenu.GetItem( Param2, sInfo, sizeof( sInfo ) );
		UserID = StringToInt( sInfo );
		
		if ( ( Target = GetClientOfUserId( UserID ) ) == 0 )
			PrintToChat( Param1, "[SM] %t", "Player no longer available" ); // SourceMod Native.
		
		else if ( !CanUserTarget( Param1, Target ) )
			PrintToChat( Param1, "[SM] %t", "Unable to target" ); // SourceMod Native.
		
		else
		{
			char sName[MAX_NAME_LENGTH];
			GetClientName( Target, sName, sizeof( sName ) );
			
			if ( !IsPlayerAlive( Target ) )
				RespawnTarget_Crosshair( Param1, Target );
			else 
				PrintToChat( Param1, "%t", "No Need To Respawn Menu", sName );
			
			ShowActivity2( Param1, "[SM] ", "Respawned Target '%s'", sName );
		}
		
		if ( IsClientInGame( Param1 ) && !IsClientInKickQueue( Param1 ) )  // Re-draw the menu if they're still valid
			DisplayRespawnMenu( Param1 );
	}
	
	return 0;
}

/******************************************************************************************************/

public Action Timer_Respawn( Handle hTimer, any client )
{
	RespawnTimer[client] = null;
	if(g_bIsOpenSafeRoom || g_bRoundEnd) 
	{
		return Plugin_Continue;
	}

	if(bFinaleEscapeStarted && g_bEscapeDisable)
	{
		return Plugin_Continue;
	}

	if ( IsValidClient( client ) )
	{
		if(!IsPlayerAlive( client ))
			RespawnTarget( client );
		else
			PrintToChatAll( "%t", "Not Needed To Respawn", client );
	}
	
	return Plugin_Continue;
}
/***********************************************************/
public Action TimerCount( Handle hTimer, int client )
{
	if( g_bRoundEnd || RespawnTimer[client] == null || Seconds[client]  <= 0 || !IsClientInGame( client ) || IsFakeClient( client ) || GetClientTeam(client) != TEAM_SURVIVOR || IsPlayerAlive( client ) || IsClientIdle( client )) 
	{
		delete RespawnTimer[client];
		return Plugin_Stop;
	}
	
	if(g_bIsOpenSafeRoom) 
	{
		PrintHintText( client, "%T", "Couldn't respawn after the saferoom door is open.", client );
		delete RespawnTimer[client];
		return Plugin_Stop;
	}

	if(bFinaleEscapeStarted && g_bEscapeDisable)
	{
		PrintHintText( client, "%T", "Couldn't respawn when final vehicle is coming.", client );
		delete RespawnTimer[client];
		return Plugin_Stop;
	}

	Seconds[client] --;

	PrintHintText( client, "%t", "Seconds To Respawn", Seconds[client] );

	return Plugin_Continue;
}

void RespawnTarget_Crosshair( int client, int target )
{
	bool bCanTeleport = bSetTeleportEndPoint( client );
	L4D_RespawnPlayer(target);
	
	SetHealth( target );
	StripWeapons( target );
	GiveItems( target );
	RespawnLimit[target] += 1;
	
	char sPlayerName[64];
	GetClientName( target, sPlayerName, sizeof( sPlayerName ) );
	
	if ( g_bSaveStats )
		CreateTimer( 1.0, Timer_LoadStatDelayed, GetClientUserId( target ), TIMER_FLAG_NO_MAPCHANGE );
	
	PrintToChatAll( "%t", "Respawned", sPlayerName );
	clinetReSpawnTime[target] = GetEngineTime() + g_fInvincibleTime;
	
	if ( bCanTeleport )
		vPerformTeleport( client, target, vsrPos );
	
	delete RespawnTimer[target];
}

void RespawnTarget( int client )
{
	int anyclient = GetRandomClient();
	if(anyclient == 0)
	{
		PrintToChat(client,"%T","Couldn't spawn at this moment.",client);
		return;
	}
	L4D_RespawnPlayer(client);
	
	SetHealth( client );
	StripWeapons( client );
	GiveItems( client);
	Teleport( client, anyclient);
	RespawnLimit[client] += 1;
	
	char sPlayerName[64];
	GetClientName( client, sPlayerName, sizeof( sPlayerName ) );
	
	if ( g_bSaveStats )
		CreateTimer( 1.0, Timer_LoadStatDelayed, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE );
	
	PrintToChatAll( "%t", "Respawned", sPlayerName );
	clinetReSpawnTime[client] = GetEngineTime() + g_fInvincibleTime;

	EmitSoundToAll(SOUND_RESPAWN, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_LOW, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);		
}

public Action Timer_LoadStatDelayed( Handle hTimer, int UserId )
{
	int client = GetClientOfUserId( UserId );
	if( client > 0 && IsClientInGame( client ) )
		if ( IsPlayerAlive( client ) ) 			// Not died in 1.0 sec after spawn?
			LoadStats(client);
			
	return Plugin_Continue;
}
/***********************************************************/
void SetHealth( int client )
{
	float Buff = GetEntDataFloat( client, BufferHP );
	int BonusHP = hCvar_RespawnHP.IntValue;
	int BuffHP = hCvar_RespawnBuffHP.IntValue;

	SetEntProp( client, Prop_Send, "m_iHealth", BonusHP, 1 );
	SetEntDataFloat( client, BufferHP, Buff + BuffHP, true );
}

void GiveItems( int client )
{
	int Flags = GetCommandFlags( "give" );
	SetCommandFlags( "give", Flags & ~FCVAR_CHEAT );
	
	switch ( SecondWeapon.IntValue )
	{
		case 0: FakeClientCommand( client, "give pistol" );
		case 1:
		{
				FakeClientCommand( client, "give pistol" );
				FakeClientCommand( client, "give pistol" );
		}
		case 2: FakeClientCommand( client, "give baseball_bat" );
		case 3: FakeClientCommand( client, "give pistol_magnum" );
	}

	if(bL4D2)
	{
		switch ( FirstWeapon.IntValue )
		{
			case 1: FakeClientCommand( client, "give autoshotgun" );
			case 2: FakeClientCommand( client, "give rifle" );
			case 3: FakeClientCommand( client, "give hunting_rifle" );
			case 4: FakeClientCommand( client, "give rifle_ak47" );
			case 5: FakeClientCommand( client, "give rifle_desert" );
			case 6: FakeClientCommand( client, "give rifle_m60" );
			case 7: FakeClientCommand( client, "give sniper_military" );
			case 8: FakeClientCommand( client, "give shotgun_spas" );
			case 9: FakeClientCommand( client, "give shotgun_chrome" );
			case 10: FakeClientCommand( client, "give smg" );
		}
	}
	else
	{
		switch ( FirstWeapon.IntValue )
		{
			case 1: FakeClientCommand( client, "give autoshotgun" );
			case 2: FakeClientCommand( client, "give rifle" );
			case 3: FakeClientCommand( client, "give hunting_rifle" );
			case 4: FakeClientCommand( client, "give smg" );
			case 5: FakeClientCommand( client, "give pumpshotgun" );
		}
	}

	switch ( ThrownWeapon.IntValue )
	{
		case 1: FakeClientCommand( client, "give molotov" );
		case 2: FakeClientCommand( client, "give pipe_bomb" );
		case 3: FakeClientCommand( client, "give vomitjar" );
	}
	switch ( PrimeHealth.IntValue )
	{
		case 1: FakeClientCommand( client, "give first_aid_kit" );
		case 2: FakeClientCommand( client, "give defibrillator" );
	}
	switch ( SecondaryHealth.IntValue )
	{
		case 1: FakeClientCommand( client, "give pain_pills" );
		case 2: FakeClientCommand( client, "give adrenaline" );
	}
	
	SetCommandFlags( "give", Flags|FCVAR_CHEAT );
}

void Teleport( int client, int telcient) // Get the position coordinates of any active living player
{
	if(telcient > 0)
	{
		float Coordinates[3];
		GetClientAbsOrigin( telcient, Coordinates );
		TeleportEntity( client, Coordinates, NULL_VECTOR, NULL_VECTOR );
	}
}
/******************************************************************************************************/

bool bSetTeleportEndPoint( int client )
{
	float vAngles[3];
	float vOrigin[3];
	
	GetClientEyePosition( client,vOrigin );
	GetClientEyeAngles( client, vAngles );
	Handle hTrace = TR_TraceRayFilterEx( vOrigin, vAngles, MASK_SHOT, RayType_Infinite, bTraceEntityFilterPlayer );
	
	if ( TR_DidHit( hTrace ) )
	{
		float vBuffer[3];
		float vStart[3];
		float vDistance = -35.0;
		
		TR_GetEndPosition( vStart, hTrace );
		GetVectorDistance( vOrigin, vStart, false );
		GetAngleVectors( vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR );
		
		vsrPos[0] = vStart[0] + ( vBuffer[0] * vDistance );
		vsrPos[1] = vStart[1] + ( vBuffer[1] * vDistance );
		vsrPos[2] = vStart[2] + ( vBuffer[2] * vDistance );
	}
	else
	{
		PrintToChat( client, "\x04[\x01SM\x04]\x01 %t", "Couldn't Teleport" );
		
		delete hTrace;
		return false;
	}
	
	delete hTrace;
	return true;
}

public bool bTraceEntityFilterPlayer( int entity, int contentsMask )
{
	return ( entity > MaxClients || !entity );
}

void vPerformTeleport( int client, int target, float vCoordinates[3] )
{
	vCoordinates[2] += 40.0;
	TeleportEntity( target, vCoordinates, NULL_VECTOR, NULL_VECTOR );
	LogAction( client, target, "\"%L\" Teleported \"%L\" After Respawning Him/Her" , client, target );
//	PrintToChatAll( "\x03\"%L\" \x01Teleported \x04\"%L\" \x01After Respawning Him/Her" , client, target ); // Test.
}
/******************************************************************************************************/

/**************************************/
/* 				STOCKs 				  */
/**************************************/

stock bool IsValidClient( int client )
{
	if ( client == 0 || !IsClientInGame( client ) || GetClientTeam( client ) != 2 || ( IsFakeClient( client ) && !bIncludeBots ) )
		return false;
	
	return true;
}

stock bool IsPlayerIncapped( int client )
{
	if ( GetEntProp( client, Prop_Send, "m_isIncapacitated", 1 ) ) 
		return true;
		
	return false;
}

stock bool IsPlayerHanging( int client )
{
	if ( GetEntProp( client, Prop_Send, "m_isHangingFromLedge", 1 ) ) 
		return true;
		
	return false;
}

stock void SaveStats( int client )
{
	fPlayerData[client][0] = GetEntPropFloat( client, Prop_Send, "m_maxDeadDuration" );
	fPlayerData[client][1] = GetEntPropFloat( client, Prop_Send, "m_totalDeadDuration" );
	
	for( int i = 0; i < sizeof( iPlayerData[] ); i++ )
		iPlayerData[client][i] = GetEntProp( client, Prop_Send, sPlayerSave[i] );
	
	if ( bL4D2 )
		for( int i = 0; i < sizeof( iPlayerData_L4D2[] ); i++ )
			iPlayerData_L4D2[client][i] = GetEntProp( client, Prop_Send, sPlayerSave_L4D2[i] );
}

stock void LoadStats( int client )
{
	SetEntPropFloat( client, Prop_Send, "m_maxDeadDuration", fPlayerData[client][0] );
	SetEntPropFloat( client, Prop_Send, "m_totalDeadDuration", fPlayerData[client][1] );
 
	for( int i = 0; i < sizeof(iPlayerData[] ); i++ )
		SetEntProp( client, Prop_Send, sPlayerSave[i], iPlayerData[client][i] );
	
	if ( bL4D2 )
		for( int i = 0; i < sizeof( iPlayerData_L4D2[] ); i++ )
			SetEntProp( client, Prop_Send, sPlayerSave_L4D2[i], iPlayerData_L4D2[client][i] );
}

/**
 * @note Adds targets to an admin menu.
 *
 * Each client is displayed as: name (userid)
 * Each item contains the userid as a string for its info.
 *
 * @param menu 			Menu Handle.
 * @return 				Returns the number of players depending on whether it is valid or not.
 */
stock int Custom_AddTargetsToMenu( Menu hMenu )
{
	char sUser_ID[12];
	char sName[MAX_NAME_LENGTH];
	char sDisplay[MAX_NAME_LENGTH+12];
	int  Num_Clients;
	
	for ( int i = 1; i <= MaxClients; i ++ )
	{
		if ( !IsValidClient( i ) )
			continue;
		
		if ( IsPlayerAlive( i ) )
			continue;
		
		IntToString( GetClientUserId( i ), sUser_ID, sizeof( sUser_ID ) );
		GetClientName( i, sName, sizeof( sName ) );
		Format( sDisplay, sizeof( sDisplay ), "%s (%s)", sName, sUser_ID );
		hMenu.AddItem( sUser_ID, sDisplay );
		Num_Clients ++;
	}
	
	return Num_Clients;
}

stock bool IsClientIdle( int client )
{
	if ( GetClientTeam( client ) != TEAM_SPECTATOR )
		return false;
	
	for ( int i = 1; i <= MaxClients; i ++ )
		if ( IsClientConnected( i ) && IsClientInGame( i ) )
			if ( ( GetClientTeam( i ) == TEAM_SURVIVOR ) && IsAlive( i ) )
				if ( IsFakeClient( i ) )
					if ( GetClientOfUserId( GetEntProp( i, Prop_Send, "m_humanSpectatorUserID" ) ) == client )
						return true;
					
	return false;
}

bool IsAlive( int client )
{
	if ( !GetEntProp( client, Prop_Send, "m_lifeState" ) )
		return true;
	
	return false;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
	delete RespawnTimer[client];
	delete HangingTimer[client];
	delete IncapTimer[client];
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damageType)
{
	if(!IsValidEntity(inflictor) || damage <= 0.0) return Plugin_Continue;

	static char sClassname[64];
	GetEntityClassname(inflictor, sClassname, 64);
	if(victim > 0 && victim < MaxClients && IsClientInGame(victim) && GetClientTeam(victim) == 2 && clinetReSpawnTime[victim] > GetEngineTime())
	{
		if( (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) != 1) ||
			strcmp(sClassname, "infected") == 0 || 
			strcmp(sClassname, "witch") == 0)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

int GetRandomClient()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i))
		{
			iClients[iClientCount++] = i;
		}
	}
	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

public Action RespawnAgain( Handle hTimer, int UserID )
{
	int client = GetClientOfUserId( UserID );
	if( client == 0 || IsPlayerAlive( client ) || !IsClientInGame( client ) || IsClientIdle( client ) || GetClientTeam(client) != TEAM_SURVIVOR) 
		return Plugin_Continue;

	RespawnTargeAgain(client);

	EmitSoundToAll(SOUND_RESPAWN, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_LOW, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);		
	
	return Plugin_Continue;
}

void RespawnTargeAgain(int target)
{
	int anyclient = GetRandomClient();
	if(anyclient == 0)
	{
		PrintToChat(target,"%T","Couldn't spawn at this moment.",target);
		return;
	}

	L4D_RespawnPlayer(target);
	
	SetHealth( target );
	StripWeapons( target );
	GiveItems( target );

	Teleport( target, anyclient);

	if ( g_bSaveStats )
		CreateTimer( 1.0, Timer_LoadStatDelayed, GetClientUserId( target ), TIMER_FLAG_NO_MAPCHANGE );

	delete RespawnTimer[target];
}

public void L4D2_OnLockDownOpenDoorFinish(const char[] sKeyMan)
{
	g_bIsOpenSafeRoom = true;
}

void StripWeapons(int client) // strip all items from client
{
	int itemIdx;
	for (int x = 0; x <= 4; x++)
	{
		if((itemIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{  
			RemovePlayerItem(client, itemIdx);
			AcceptEntityInput(itemIdx, "Kill");
		}
	}
}