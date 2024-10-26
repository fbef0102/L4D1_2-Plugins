#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <topmenus>
#include <adminmenu>
#include <left4dhooks>
#include <multicolors>

#pragma semicolon 1
#pragma newdecls required
#define PLUGIN_VERSION 			"4.1-2024/5/10"

public Plugin myinfo = 
{
    name 		= "[L4D1 AND L4D2] Survivor Respawn",
    author 		= "Mortiegama And Ernecio (Satanael) & HarryPotter",
    description = "When a Survivor dies, will respawn after a period of time.",
    version 	= PLUGIN_VERSION,
    url 		= "https://steamcommunity.com/profiles/76561198026784913"
}

bool bLate, g_bL4D2Version;
public APLRes AskPluginLoad2( Handle myself, bool late, char[] error, int err_max )
{	
	EngineVersion engine = GetEngineVersion();
	if ( engine != Engine_Left4Dead && engine != Engine_Left4Dead2 )
	{
		strcopy( error, err_max, "This plugin \"Survivor Respawn\" only runs in the \"Left 4 Dead 1/2\" Games!" );
		return APLRes_SilentFailure;
	}
	
	g_bL4D2Version = ( engine == Engine_Left4Dead2 );
	
	bLate = late;
	return APLRes_Success;
}

#define MAXENTITIES                   2048
#define ENTITY_SAFE_LIMIT 2000 //don't spawn boxes when it's index is above this

#define TEAM_SPECTATOR 	1
#define TEAM_SURVIVOR 	2

ConVar g_hCvarEnable, hCvar_EnableHuman, hCvar_EnableBots, hCvar_RespawnRespect, 
	hCvar_RespawnLimit, hCvar_RespawnTimeout, hCvar_RespawnHP, hCvar_RespawnBuffHP, hCvar_BotReplaced, 
	hCvar_InvincibleTime, hCvar_EscapeDisable, 
	FirstWeapon, SecondWeapon, ThirdWeapon, FourthWeapon, FifthWeapon;

bool g_bCvarEnable, g_bEnableHuman, g_bEnableBots, g_bEnablesRespawnLimit;
int g_iRespawnLimit, g_iRespawnTimeout,
	g_iFirstWeapon, g_iSecondWeapon, g_iThirdWeapon, g_iFourthWeapon, g_iFifthWeapon;
bool g_bEscapeDisable;
float g_fInvincibleTime, g_fRespawnTimeout;

bool bRescuable[ MAXPLAYERS + 1 ] = {false};
bool bFinaleEscapeStarted = false;
bool g_bRoundEnd = false;

TopMenu hTopMenu;

Handle RespawnTimer[ MAXPLAYERS + 1 ];
Handle CountTimer[ MAXPLAYERS + 1 ];
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
bool g_bIsOpenSafeRoom;

char 
    g_sMeleeClass[16][32];

int 
    g_iMeleeClassCount;

#define SOUND_RESPAWN "ui/helpful_event_1.wav"

public void OnPluginStart()
{
	LoadTranslations( "common.phrases" ); // SourceMod Native (Add native SourceMod translations to the menu).
	LoadTranslations( "Survivor_Respawn.phrases");
	
	CreateConVar( 						   "l4d_survivorrespawn_version", 				PLUGIN_VERSION, "Survivor Respawning Version", FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_NOTIFY);
	g_hCvarEnable 			= CreateConVar("l4d_survivorrespawn_enable", 				"1", 	"0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_EnableHuman 		= CreateConVar("l4d_survivorrespawn_human", 				"1", 	"If 1, Enables Human Survivors to respawn automatically when killed", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_EnableBots 		= CreateConVar("l4d_survivorrespawn_bot", 					"1", 	"If 1, Allows Bots to respawn automatically when killed", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_RespawnRespect 	= CreateConVar("l4d_survivorrespawn_limitenable", 			"1", 	"If 1, Enables the respawn limit for Survivors", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_RespawnLimit 		= CreateConVar("l4d_survivorrespawn_deathlimit", 			"3", 	"Amount of times a Survivor can respawn before permanently dying", FCVAR_NOTIFY, true, 0.0);
	hCvar_RespawnTimeout 	= CreateConVar("l4d_survivorrespawn_respawntimeout", 		"30", 	"How many seconds until the Survivor respawns", FCVAR_NOTIFY, true, 0.0);
	hCvar_RespawnHP 		= CreateConVar("l4d_survivorrespawn_respawnhp", 			"70", 	"Amount of HP a Survivor will respawn with", FCVAR_NOTIFY, true, 0.0);
	hCvar_RespawnBuffHP 	= CreateConVar("l4d_survivorrespawn_respawnbuffhp", 		"30", 	"Amount of buffer HP a Survivor will respawn with", FCVAR_NOTIFY, true, 0.0);
	hCvar_BotReplaced 		= CreateConVar("l4d_survivorrespawn_botreplaced", 			"1", 	"Respawn bots if is dead in case of using Take Over.",  FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_InvincibleTime 	= CreateConVar("l4d_survivorrespawn_invincibletime", 		"10.0", "Invincible time after survivor respawn.",  FCVAR_NOTIFY, true, 0.0);
	hCvar_EscapeDisable 	= CreateConVar("l4d_survivorrespawn_disable_rescue_escape", "1", 	"If 1, disable respawning while the final escape starts (rescue vehicle ready)",  FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	if ( g_bL4D2Version ) {
		FirstWeapon 		= CreateConVar("l4d_survivorrespawn_firstweapon", 		"1", 	"First slot weapon for repawn Survivor (1-Autoshot, 2-SPAS, 3-M16, 4-SCAR, 5-AK47, 6-SG552, 7-Mil Sniper, 8-AWP, 9-Scout, 10=Hunt Rif, 11=M60, 12=GL, 13-SMG, 14-Sil SMG, 15=MP5, 16-Pump Shot, 17=Chrome Shot, 18=Rand T1, 19=Rand T2, 20=Rand T3, 0=off)", FCVAR_NOTIFY, true, 0.0, true, 20.0);
		SecondWeapon 		= CreateConVar("l4d_survivorrespawn_secondweapon", 		"4", 	"Second slot weapon for repawn Survivor (1- Dual Pistol, 2-Magnum, 3-Chainsaw, 4=Melee weapon from map, 5=Random, 0=Only Pistol)", FCVAR_NOTIFY, true, 0.0, true, 5.0);
		ThirdWeapon 		= CreateConVar("l4d_survivorrespawn_thirdweapon", 		"4", 	"Third slot weapon for repawn Survivor (1 - Moltov, 2 - Pipe Bomb, 3 - Bile Jar, 4=Random, 0=off)", FCVAR_NOTIFY, true, 0.0, true, 4.0);
		FourthWeapon 		= CreateConVar("l4d_survivorrespawn_forthweapon", 		"1", 	"Fourth slot weapon for repawn Survivor (1 - Medkit, 2 - Defib, 3 - Incendiary Pack, 4 - Explosive Pack, 5=Random, 0=off)", FCVAR_NOTIFY, true, 0.0, true, 5.0);
		FifthWeapon 		= CreateConVar("l4d_survivorrespawn_fifthweapon", 		"2", 	"Fifth slot weapon for repawn Survivor (1 - Pills, 2 - Adrenaline, 3=Random, 0=off)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	} else {
		FirstWeapon 		= CreateConVar("l4d_survivorrespawn_firstweapon", 		"7", 	"First slot weapon for repawn Survivor (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - smg, 5 - shotgun, 6=Random T1, 7=Random T2, 0=off)", FCVAR_NOTIFY, true, 0.0, true, 7.0);
		SecondWeapon 		= CreateConVar("l4d_survivorrespawn_secondweapon", 		"1", 	"Second slot weapon for repawn Survivor (1 - Dual Pistol, 0=Only Pistol)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
		ThirdWeapon 		= CreateConVar("l4d_survivorrespawn_thirdweapon", 		"3", 	"Third slot weapon for repawn Survivor (1 - Moltov, 2 - Pipe Bomb, 3=Random, 0=off)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
		FourthWeapon 		= CreateConVar("l4d_survivorrespawn_forthweapon", 		"1", 	"Fourth slot weapon for repawn Survivor (1 - Medkit, 0=off)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
		FifthWeapon 		= CreateConVar("l4d_survivorrespawn_fifthweapon", 		"1", 	"Fifth slot weapon for repawn Survivor (1 - Pills, 0=off)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	}
	
	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	hCvar_EnableHuman.AddChangeHook(ConVarChanged_Cvars);
	hCvar_EnableBots.AddChangeHook(ConVarChanged_Cvars);
	hCvar_RespawnRespect.AddChangeHook(ConVarChanged_Cvars);
	hCvar_RespawnLimit.AddChangeHook(ConVarChanged_Cvars);
	hCvar_RespawnTimeout.AddChangeHook(ConVarChanged_Cvars);
	hCvar_InvincibleTime.AddChangeHook(ConVarChanged_Cvars);
	hCvar_EscapeDisable.AddChangeHook(ConVarChanged_Cvars);
	FirstWeapon.AddChangeHook(ConVarChanged_Cvars);
	SecondWeapon.AddChangeHook(ConVarChanged_Cvars);
	ThirdWeapon.AddChangeHook(ConVarChanged_Cvars);
	FourthWeapon.AddChangeHook(ConVarChanged_Cvars);
	FifthWeapon.AddChangeHook(ConVarChanged_Cvars);
	
	AutoExecConfig( true, "Survivor_Respawn" );
	
	HookEvent("player_bot_replace", OnBotSwap);
	HookEvent("bot_player_replace", OnBotSwap);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post );
	HookEvent("player_bot_replace", Event_BotReplace, EventHookMode_Post );
	HookEvent("bot_player_replace", Event_PlayerReplace );
	HookEvent("revive_success", Event_ReviveSuccess);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("map_transition", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("mission_lost", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("finale_vehicle_leaving", Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("finale_escape_start", Finale_Escape_Start);
	HookEvent("finale_vehicle_ready", Finale_Vehicle_Ready);
	
	RegAdminCmd("sm_respawnex", CMD_Respawn, ADMFLAG_BAN, "Respawn Target/s At Your Crosshair." );
	RegAdminCmd("sm_respawnexmenu", CMD_DisplayMenu, ADMFLAG_BAN, "Create A Menu Of Clients List And Respawn Targets At Your Crosshair." );
	
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
		delete CountTimer[client];
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
		delete CountTimer[client];
		delete HangingTimer[client];
		delete IncapTimer[client];
	}
}

public void OnConfigsExecuted()
{
	GetMeleeTable();
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bEnableHuman = hCvar_EnableHuman.BoolValue;
	g_bEnableBots = hCvar_EnableBots.BoolValue;
	g_bEnablesRespawnLimit = hCvar_RespawnRespect.BoolValue;
	g_iRespawnLimit = hCvar_RespawnLimit.IntValue;
	g_iRespawnTimeout = hCvar_RespawnTimeout.IntValue;
	g_fRespawnTimeout = hCvar_RespawnTimeout.FloatValue;
	g_fInvincibleTime = hCvar_InvincibleTime.FloatValue;
	g_bEscapeDisable = hCvar_EscapeDisable.BoolValue;

	g_iFirstWeapon = FirstWeapon.IntValue;
	g_iSecondWeapon = SecondWeapon.IntValue;
	g_iThirdWeapon = ThirdWeapon.IntValue;
	g_iFourthWeapon = FourthWeapon.IntValue;
	g_iFifthWeapon = FifthWeapon.IntValue;
}

void Event_RoundStart( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	g_bIsOpenSafeRoom = false;
	g_bRoundEnd = false;
	bFinaleEscapeStarted = false;
	for ( int client = 1; client <= MaxClients; client ++ )
	{
		RespawnLimit[client] = 0;
		clinetReSpawnTime[client] = 0.0;

		delete RespawnTimer[client];
		delete CountTimer[client];
		delete HangingTimer[client];
		delete IncapTimer[client];
	}
}

void Event_RoundEnd( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	for ( int client = 1; client <= MaxClients; client ++ )
	{
		bRescuable[client] = false;
		
		delete RespawnTimer[client];
		delete CountTimer[client];
		delete HangingTimer[client];
		delete IncapTimer[client];
	}

	g_bIsOpenSafeRoom = false;
	g_bRoundEnd = true;
}

void Finale_Escape_Start(Event event, const char[] name, bool dontBroadcast) 
{
	bFinaleEscapeStarted = true;
}

void Finale_Vehicle_Ready(Event event, const char[] name, bool dontBroadcast) 
{
	bFinaleEscapeStarted = true;
}

void OnBotSwap(Event event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(GetEventInt(event, "bot"));
	int player = GetClientOfUserId(GetEventInt(event, "player"));
	if (bot > 0 && bot <= MaxClients && player > 0 && player<= MaxClients) 
	{
		if (strcmp(name, "player_bot_replace") == 0)  // bot replace player
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

void Event_PlayerDeath( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	if(!g_bCvarEnable) return;

	int client = GetClientOfUserId( hEvent.GetInt( "userid" ) );

	if(!IsValidClient(client)) return;

	if (g_bRoundEnd) return;

	if (g_bIsOpenSafeRoom) 
	{
		PrintHintText( client, "%T", "Couldn't respawn after the saferoom door is open.", client );
		return;
	}
	if ( bFinaleEscapeStarted && g_bEscapeDisable)
	{
		PrintHintText( client, "%T", "Couldn't respawn when final vehicle is coming.", client );
		return;
	}

	if ( clinetReSpawnTime[client] > GetEngineTime() )
	{
		PrintHintText( client, "%T", "You will be respawned again.", client );
		
		CreateTimer( 3.0, RespawnAgain, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE );
		return;
	}

	if ( !g_bEnablesRespawnLimit )
	{
		delete RespawnTimer[client];
		RespawnTimer[client] = CreateTimer( g_fRespawnTimeout, Timer_Respawn, client ); 
		
		if(!IsFakeClient(client))
		{
			Seconds[client] = g_iRespawnTimeout;
			delete CountTimer[client];
			CountTimer[client] = CreateTimer( 1.0, TimerCount, client, TIMER_REPEAT);
		}
		
		SaveStats( client );
		
		bRescuable[client] = false;
	}
	else
	{
		if ( RespawnLimit[client] < g_iRespawnLimit )
		{
			delete RespawnTimer[client];
			RespawnTimer[client] = CreateTimer( g_fRespawnTimeout, Timer_Respawn, client); 

			if(!IsFakeClient(client))
			{
				delete CountTimer[client];
				CountTimer[client] = CreateTimer( 1.0, TimerCount, client, TIMER_REPEAT); 
			}
			
			SaveStats( client );
			
			Seconds[client] = g_iRespawnTimeout;
			bRescuable[client] = false;
		}
		else if ( RespawnLimit[client] >= g_iRespawnLimit )
		{
			PrintHintText( client, "%T", "Respawn Limit", client );
			bRescuable[client] = false;
		}
	}
}

void Event_BotReplace( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	if(!g_bCvarEnable) return;

	int bot = GetClientOfUserId( hEvent.GetInt( "bot" ) );
	
	if (!IsValidClient( bot ) || IsPlayerAlive(bot) || !hCvar_BotReplaced.BoolValue || g_bIsOpenSafeRoom || (bFinaleEscapeStarted && g_bEscapeDisable) || g_bRoundEnd ) return;

	if ( !g_bEnablesRespawnLimit)
	{
		delete RespawnTimer[bot];
		RespawnTimer[bot] = CreateTimer( g_fRespawnTimeout, Timer_Respawn, bot );
		bRescuable[bot] = false;
	}
	else
	{
		if ( RespawnLimit[bot] < g_iRespawnLimit )
		{
			delete RespawnTimer[bot];
			RespawnTimer[bot] = CreateTimer( g_fRespawnTimeout, Timer_Respawn, bot ); 
			bRescuable[bot] = false;
		}
		else if ( RespawnLimit[bot] >= g_iRespawnLimit )
			bRescuable[bot] = false;
	}
}

// bot死亡，其有閒置的玩家取代bot時不會觸發此事件，只觸發player_spawn與player_team
void Event_PlayerReplace( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	if(!g_bCvarEnable) return;

	int client = GetClientOfUserId( hEvent.GetInt( "player" ) );
	int bot = GetClientOfUserId( hEvent.GetInt( "bot" ) );
	if( !client || !IsClientInGame(client)) return;
	if( !bot || !IsClientInGame(bot)) return;

	delete RespawnTimer[client];
	if(GetClientTeam(client) == TEAM_SURVIVOR && !IsPlayerAlive(client) && g_bEnableHuman)
	{
		if ( g_bEnablesRespawnLimit)
		{
			if ( RespawnLimit[client] < g_iRespawnLimit )
			{
				delete RespawnTimer[client];
				RespawnTimer[client] = CreateTimer( g_fRespawnTimeout, Timer_Respawn, client); 
				
				if(!IsFakeClient(client))
				{
					delete CountTimer[client];
					CountTimer[client] = CreateTimer( 1.0, TimerCount, client, TIMER_REPEAT); 
				}
				
				Seconds[client] = g_iRespawnTimeout;
				bRescuable[client] = false;
			}
			else if ( RespawnLimit[client] >= g_iRespawnLimit )
			{
				PrintHintText( client, "%T", "Respawn Limit", client );
				bRescuable[client] = false;
			}
		}
		else
		{
			delete RespawnTimer[client];
			RespawnTimer[client] = CreateTimer( g_fRespawnTimeout, Timer_Respawn, client); 
			
			if(!IsFakeClient(client))
			{
				delete CountTimer[client];
				CountTimer[client] = CreateTimer( 1.0, TimerCount, client, TIMER_REPEAT); 
			}
			
			Seconds[client] = g_iRespawnTimeout;
			bRescuable[client] = false;
		}

		//PrintToChatAll( "\x03%N \x01has replaced dead \x04%N", client, bot ); // Test.
	}
}

void Event_PlayerSpawn( Event hEvent, const char[] sName, bool bDontBroadcast )
{	
	if(!g_bCvarEnable) return;

	int UserID = hEvent.GetInt( "userid" );
	int client = GetClientOfUserId(UserID);
	
	delete RespawnTimer[client];

	CreateTimer(0.1, Timer_Event_PlayerSpawn, UserID, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_Event_PlayerSpawn(Handle timer, int client)
{
	client = GetClientOfUserId(client);

	if ( !IsValidClient(client) || IsPlayerAlive(client) ) return Plugin_Continue;

	if ( !g_bEnablesRespawnLimit )
	{
		delete RespawnTimer[client];
		RespawnTimer[client] = CreateTimer( g_fRespawnTimeout, Timer_Respawn, client ); 
	
		if(!IsFakeClient(client))
		{
			Seconds[client] = g_iRespawnTimeout;
			delete CountTimer[client];
			CountTimer[client] = CreateTimer( 1.0, TimerCount, client, TIMER_REPEAT);
		}
		
		SaveStats( client );
		
		bRescuable[client] = false;
	}
	else
	{
		if ( RespawnLimit[client] < g_iRespawnLimit )
		{
			delete RespawnTimer[client];
			RespawnTimer[client] = CreateTimer( g_fRespawnTimeout, Timer_Respawn, client); 

			if(!IsFakeClient(client))
			{
				delete CountTimer[client];
				CountTimer[client] = CreateTimer( 1.0, TimerCount, client, TIMER_REPEAT ); 
			}
			
			SaveStats( client );
			
			Seconds[client] = g_iRespawnTimeout;
			bRescuable[client] = false;
		}
		else if ( RespawnLimit[client] >= g_iRespawnLimit )
		{
			PrintHintText( client, "%T", "Respawn Limit", client );
			bRescuable[client] = false;
		}
	}

	return Plugin_Continue;
}

void Event_ReviveSuccess( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	int client = GetClientOfUserId( hEvent.GetInt( "victim" ) );
	bRescuable[client] = false;
}

/******************************************************************************************************/

Action CMD_Respawn( int client, int args )
{
	if (client == 0)
	{
		PrintToServer("[TS] This command cannot be used by server.");
		return Plugin_Handled;
	}

	if (g_bCvarEnable == false)
	{
		ReplyToCommand(client, "This command is disable.");
		return Plugin_Handled;
	}

	if ( args < 1 )
	{
		ReplyToCommand( client, "%T", "CMD Respawn", client );
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
			CPrintToChat( client, "%T", "No Need To Respawn", client, iTargetList[i] );

	return Plugin_Handled;
}

Action CMD_DisplayMenu( int client, int args )
{
	if (client == 0)
	{
		PrintToServer("[TS] This command cannot be used by server.");
		return Plugin_Handled;
	}

	if (g_bCvarEnable == false)
	{
		ReplyToCommand(client, "This command is disable.");
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
	{
		CPrintToChat(client, "%T", "No Any Dead Survivor", client);
		delete hMenu;
	}
	else
	{
		hMenu.Display( client, MENU_TIME_FOREVER );
	}
}

int MenuHandler_Respawn( Menu hMenu, MenuAction hAction, int Param1, int Param2 )
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
			PrintToChat( Param1, "[SM] %T", "Player no longer available", Param1 ); // SourceMod Native.
		
		else if ( !CanUserTarget( Param1, Target ) )
			PrintToChat( Param1, "[SM] %T", "Unable to target", Param1 ); // SourceMod Native.
		
		else
		{
			char sName[MAX_NAME_LENGTH];
			GetClientName( Target, sName, sizeof( sName ) );
			
			if ( !IsPlayerAlive( Target ) )
				RespawnTarget_Crosshair( Param1, Target );
			else 
				CPrintToChat( Param1, "%T", "No Need To Respawn Menu", Param1, sName );
			
			ShowActivity2( Param1, "[SM] ", "Respawned Target '%s'", sName );
		}
		
		if ( IsClientInGame( Param1 ) && !IsClientInKickQueue( Param1 ) )  // Re-draw the menu if they're still valid
			DisplayRespawnMenu( Param1 );
	}
	
	return 0;
}

/******************************************************************************************************/

Action Timer_Respawn( Handle hTimer, any client )
{
	RespawnTimer[client] = null;
	if(!g_bCvarEnable)
	{
		return Plugin_Continue;
	}

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
			CPrintToChatAll( "%t", "Not Needed To Respawn", client );
	}
	
	return Plugin_Continue;
}
/***********************************************************/
Action TimerCount( Handle hTimer, int client )
{
	if(!g_bCvarEnable)
	{
		delete RespawnTimer[client];
		CountTimer[client] = null;
		return Plugin_Stop;
	}
	
	if( g_bRoundEnd || RespawnTimer[client] == null || Seconds[client]  <= 0 || !IsClientInGame( client ) || GetClientTeam(client) != TEAM_SURVIVOR || IsPlayerAlive( client ) || IsClientIdle( client )) 
	{
		delete RespawnTimer[client];
		CountTimer[client] = null;
		return Plugin_Stop;
	}
	
	if(g_bIsOpenSafeRoom) 
	{
		PrintHintText( client, "%T", "Couldn't respawn after the saferoom door is open.", client );
		delete RespawnTimer[client];
		CountTimer[client] = null;
		return Plugin_Stop;
	}

	if(bFinaleEscapeStarted && g_bEscapeDisable)
	{
		PrintHintText( client, "%T", "Couldn't respawn when final vehicle is coming.", client );
		delete RespawnTimer[client];
		CountTimer[client] = null;
		return Plugin_Stop;
	}

	Seconds[client] --;

	if(g_bEnablesRespawnLimit)
	{
		int left = g_iRespawnLimit - RespawnLimit[client];
		if(left == 1)
		{
			PrintHintText( client, "%T", "Seconds To Respawn limit (1)", client, Seconds[client] );
		}
		else
		{	
			PrintHintText( client, "%T", "Seconds To Respawn limit", client, Seconds[client], left );
		}
	}
	else
	{
		PrintHintText( client, "%T", "Seconds To Respawn", client, Seconds[client] );
	}

	return Plugin_Continue;
}

void RespawnTarget_Crosshair( int client, int target )
{
	float vec[3];
	bool bCanTeleport = GetSpawnEndPoint( client, vec);
	L4D_RespawnPlayer(target);
	CleanUpStateAndMusic(target);
	
	SetHealth( target );
	StripWeapons( target );
	GiveItems( target );
	RespawnLimit[target] += 1;
	
	char sPlayerName[64];
	GetClientName( target, sPlayerName, sizeof( sPlayerName ) );
	
	CreateTimer( 1.0, Timer_LoadStatDelayed, GetClientUserId( target ), TIMER_FLAG_NO_MAPCHANGE );
	
	CPrintToChatAll( "%t", "Respawned", sPlayerName );
	if(g_fInvincibleTime > 0.0)
	{
		clinetReSpawnTime[target] = GetEngineTime() + g_fInvincibleTime;
		if(g_bL4D2Version) L4D2_UseAdrenaline(target, g_fInvincibleTime, false);
	}
	
	if ( bCanTeleport )
	{
		vPerformTeleport( client, target, vec );
	}
	else
	{
		Teleport( target, client );
	}

	L4D_WarpToValidPositionIfStuck(target);
	
	delete RespawnTimer[target];
}

void RespawnTarget( int client )
{
	int anyclient = my_GetRandomClient();
	if(anyclient == 0)
	{
		CPrintToChat(client,"%T","Couldn't spawn at this moment.",client);
		return;
	}
	L4D_RespawnPlayer(client);
	CleanUpStateAndMusic(client);
	Teleport( client, anyclient);
	SetHealth( client );
	StripWeapons( client );
	GiveItems( client);
	L4D_WarpToValidPositionIfStuck(client);
	RespawnLimit[client] += 1;
	
	char sPlayerName[64];
	GetClientName( client, sPlayerName, sizeof( sPlayerName ) );
	
	CreateTimer( 1.0, Timer_LoadStatDelayed, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE );
	
	CPrintToChatAll( "%t", "Respawned", sPlayerName );
	if(g_fInvincibleTime > 0.0)
	{
		clinetReSpawnTime[client] = GetEngineTime() + g_fInvincibleTime;
		if(g_bL4D2Version) L4D2_UseAdrenaline(client, g_fInvincibleTime, false);
	}

	EmitSoundToAll(SOUND_RESPAWN, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_LOW, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);		
}

Action Timer_LoadStatDelayed( Handle hTimer, int UserId )
{
	if(!g_bCvarEnable) return Plugin_Continue;

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

void GiveItems(int client) // give client weapon
{
	int flags = GetCommandFlags("give");
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);
	
	int iRandom = g_iSecondWeapon;
	if(g_bL4D2Version && iRandom == 5) iRandom = GetRandomInt(1,4);
		
	switch ( iRandom )
	{
		case 1:
		{
			FakeClientCommand( client, "give pistol" );
			FakeClientCommand( client, "give pistol" );
		}
		case 2: FakeClientCommand(client, "give pistol_magnum");
		case 3: FakeClientCommand(client, "give chainsaw");
		case 4: 
		{
			int entity = CreateEntityByName("weapon_melee");
			if (CheckIfEntitySafe( entity ) == false)
				return;

			DispatchKeyValue(entity, "solid", "6");
			DispatchKeyValue(entity, "melee_script_name", g_sMeleeClass[GetRandomInt(0, g_iMeleeClassCount-1)]);
			DispatchSpawn(entity);
			EquipPlayerWeapon(client, entity);
		}
		default: {
			FakeClientCommand( client, "give pistol" );
		}
	}

	iRandom = g_iFirstWeapon;
	if(g_bL4D2Version)
	{
		if(g_iFirstWeapon == 18) iRandom = GetRandomInt(13,17);
		else if(g_iFirstWeapon == 19) iRandom = GetRandomInt(1,10);
		else if(g_iFirstWeapon == 20) iRandom = GetRandomInt(11,12);
		
		switch ( iRandom )
		{
			case 1: FakeClientCommand(client, "give autoshotgun");
			case 2: FakeClientCommand(client, "give shotgun_spas");
			case 3: FakeClientCommand(client, "give rifle");
			case 4: FakeClientCommand(client, "give rifle_desert");
			case 5: FakeClientCommand(client, "give rifle_ak47");
			case 6: FakeClientCommand(client, "give rifle_sg552");
			case 7: FakeClientCommand(client, "give sniper_military");
			case 8: FakeClientCommand(client, "give sniper_awp");
			case 9: FakeClientCommand(client, "give sniper_scout");
			case 10: FakeClientCommand(client, "give hunting_rifle");
			case 11: FakeClientCommand(client, "give rifle_m60");
			case 12: FakeClientCommand(client, "give grenade_launcher");
			case 13: FakeClientCommand(client, "give smg");
			case 14: FakeClientCommand(client, "give smg_silenced");
			case 15: FakeClientCommand(client, "give smg_mp5");
			case 16: FakeClientCommand(client, "give pumpshotgun");
			case 17: FakeClientCommand(client, "give shotgun_chrome");
			default: {}//nothing
		}
	}
	else
	{
		if(g_iFirstWeapon == 6) iRandom = GetRandomInt(4,5);
		else if(g_iFirstWeapon == 7) iRandom = GetRandomInt(1,3);
		
		switch ( iRandom )
		{
			case 1: FakeClientCommand( client, "give autoshotgun" );
			case 2: FakeClientCommand( client, "give rifle" );
			case 3: FakeClientCommand( client, "give hunting_rifle" );
			case 4: FakeClientCommand( client, "give smg" );
			case 5: FakeClientCommand( client, "give pumpshotgun" );
			default: {}//nothing
		}
	}
	
	iRandom = g_iThirdWeapon;
	if (g_bL4D2Version && iRandom == 4) iRandom = GetRandomInt(1,3);
	if (!g_bL4D2Version && iRandom == 3) iRandom = GetRandomInt(1,2);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give molotov" );
		case 2: FakeClientCommand( client, "give pipe_bomb" );
		case 3: FakeClientCommand( client, "give vomitjar" );
		default: {}//nothing
	}
	
	
	iRandom = g_iFourthWeapon;
	if(g_bL4D2Version && iRandom == 5) iRandom = GetRandomInt(1,4);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give first_aid_kit" );
		case 2: FakeClientCommand( client, "give defibrillator" );
		case 3: FakeClientCommand( client, "give weapon_upgradepack_incendiary" );
		case 4: FakeClientCommand( client, "give weapon_upgradepack_explosive" );
		default: {}//nothing
	}
	
	iRandom = g_iFifthWeapon;
	if(g_bL4D2Version && iRandom == 3) iRandom = GetRandomInt(1,2);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give pain_pills" );
		case 2: FakeClientCommand( client, "give adrenaline" );
		default: {}//nothing
	}
	
	SetCommandFlags( "give", flags);
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

bool GetSpawnEndPoint(int client, float vSpawnVec[3])
{
	if( !client )
	{
		return false;
	}
	float vEnd[3], vEye[3];
	if( GetDirectionEndPoint(client, vEnd) )
	{
		GetClientEyePosition(client, vEye);
		ScaleVectorDirection(vEye, vEnd, 0.1); // to allow collision to be happen
		
		if( GetNonCollideEndPoint(client, vEnd, vSpawnVec) )
		{
			return true;
		}
	}

	return false;
}

bool GetDirectionEndPoint(int client, float vEndPos[3])
{
	float vDir[3], vPos[3];
	GetClientEyePosition(client, vPos);
	GetClientEyeAngles(client, vDir);
	
	Handle hTrace = TR_TraceRayFilterEx(vPos, vDir, MASK_PLAYERSOLID, RayType_Infinite, bTraceEntityFilterPlayer, client);
	if( hTrace != INVALID_HANDLE )
	{
		if( TR_DidHit(hTrace) )
		{
			TR_GetEndPosition(vEndPos, hTrace);
			delete hTrace;
			return true;
		}
		delete hTrace;
	}
	return false;
}

bool GetNonCollideEndPoint(int client, float vEnd[3], float vEndNonCol[3])
{
	float vMin[3], vMax[3], vStart[3];
	GetClientEyePosition(client, vStart);
	GetClientMins(client, vMin);
	GetClientMaxs(client, vMax);
	vStart[2] += 20.0; // if nearby area is irregular
	Handle hTrace = TR_TraceHullFilterEx(vStart, vEnd, vMin, vMax, MASK_PLAYERSOLID, bTraceEntityFilterPlayer, client);
	if( hTrace != INVALID_HANDLE )
	{
		if( TR_DidHit(hTrace) )
		{
			TR_GetEndPosition(vEndNonCol, hTrace);
			delete hTrace;
			return true;
		}
		delete hTrace;
	}
	return false;
}

void ScaleVectorDirection(float vStart[3], float vEnd[3], float fMultiple)
{
    float dir[3];
    SubtractVectors(vEnd, vStart, dir);
    ScaleVector(dir, fMultiple);
    AddVectors(vEnd, dir, vEnd);
}

bool bTraceEntityFilterPlayer( int entity, int contentsMask )
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

bool IsValidClient( int client )
{
	if ( client == 0 || 
		!IsClientInGame( client ) || 
		GetClientTeam( client ) != 2 || 
		( IsFakeClient( client ) && !g_bEnableBots ) ||
		( !IsFakeClient( client ) && !g_bEnableHuman ))
		return false;
	
	return true;
}

void SaveStats( int client )
{
	fPlayerData[client][0] = GetEntPropFloat( client, Prop_Send, "m_maxDeadDuration" );
	fPlayerData[client][1] = GetEntPropFloat( client, Prop_Send, "m_totalDeadDuration" );
	
	for( int i = 0; i < sizeof( iPlayerData[] ); i++ )
		iPlayerData[client][i] = GetEntProp( client, Prop_Send, sPlayerSave[i] );
	
	if ( g_bL4D2Version )
		for( int i = 0; i < sizeof( iPlayerData_L4D2[] ); i++ )
			iPlayerData_L4D2[client][i] = GetEntProp( client, Prop_Send, sPlayerSave_L4D2[i] );
}

void LoadStats( int client )
{
	SetEntPropFloat( client, Prop_Send, "m_maxDeadDuration", fPlayerData[client][0] );
	SetEntPropFloat( client, Prop_Send, "m_totalDeadDuration", fPlayerData[client][1] );
 
	for( int i = 0; i < sizeof(iPlayerData[] ); i++ )
		SetEntProp( client, Prop_Send, sPlayerSave[i], iPlayerData[client][i] );
	
	if ( g_bL4D2Version )
		for( int i = 0; i < sizeof( iPlayerData_L4D2[] ); i++ )
			SetEntProp( client, Prop_Send, sPlayerSave_L4D2[i], iPlayerData_L4D2[client][i] );
}

int Custom_AddTargetsToMenu( Menu hMenu )
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
		Format( sDisplay, sizeof( sDisplay ), "%s", sName);
		hMenu.AddItem( sUser_ID, sDisplay );
		Num_Clients ++;
	}
	
	return Num_Clients;
}

bool IsClientIdle( int client )
{
	if ( !IsFakeClient(client) || GetClientTeam( client ) != TEAM_SPECTATOR )
		return false;
	
	for ( int i = 1; i <= MaxClients; i ++ )
		if ( IsClientInGame( i ) )
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
	if(!IsClientInGame(client))

	delete RespawnTimer[client];
	delete CountTimer[client];
	delete HangingTimer[client];
	delete IncapTimer[client];
}

Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damageType)
{
	if(!g_bCvarEnable || !IsValidEntity(inflictor) || damage <= 0.0) return Plugin_Continue;

	static char sClassname[64];
	GetEntityClassname(inflictor, sClassname, 64);
	if(victim > 0 && victim <= MaxClients && IsClientInGame(victim) && GetClientTeam(victim) == 2 && clinetReSpawnTime[victim] > GetEngineTime())
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

int my_GetRandomClient()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i) && !L4D_IsPlayerHangingFromLedge(i))
		{
			iClients[iClientCount++] = i;
		}
	}

	if(iClientCount == 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i))
			{
				iClients[iClientCount++] = i;
			}
		}
	}

	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

Action RespawnAgain( Handle hTimer, int UserID )
{
	if(!g_bCvarEnable) return Plugin_Continue;

	int client = GetClientOfUserId( UserID );
	if( client == 0 || IsPlayerAlive( client ) || !IsClientInGame( client ) || IsClientIdle( client ) || GetClientTeam(client) != TEAM_SURVIVOR) 
		return Plugin_Continue;

	RespawnTargeAgain(client);

	EmitSoundToAll(SOUND_RESPAWN, client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_LOW, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);		
	
	return Plugin_Continue;
}

void RespawnTargeAgain(int target)
{
	int anyclient = my_GetRandomClient();
	if(anyclient == 0)
	{
		CPrintToChat(target,"%T","Couldn't spawn at this moment.",target);
		return;
	}

	L4D_RespawnPlayer(target);
	CleanUpStateAndMusic(target);
	
	SetHealth( target );
	StripWeapons( target );
	GiveItems( target );

	Teleport( target, anyclient);
	L4D_WarpToValidPositionIfStuck(target);

	CreateTimer( 1.0, Timer_LoadStatDelayed, GetClientUserId( target ), TIMER_FLAG_NO_MAPCHANGE );

	delete RespawnTimer[target];
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

void GetMeleeTable()
{
    int table = FindStringTable("meleeweapons");
    if (table != INVALID_STRING_TABLE) 
    {
        g_iMeleeClassCount = GetStringTableNumStrings(table);

        for (int i = 0; i < g_iMeleeClassCount; i++) 
        {
            ReadStringTable(table, i, g_sMeleeClass[i], sizeof(g_sMeleeClass[]));
        }
    }
}

bool CheckIfEntitySafe(int entity)
{
	if(entity == -1) return false;

	if(	entity > ENTITY_SAFE_LIMIT)
	{
		RemoveEntity(entity);
		return false;
	}
	return true;
}

void CleanUpStateAndMusic(int client)
{
	if (!g_bL4D2Version)
	{
		L4D_StopMusic(client, "Event.SurvivorDeath");
	}
	else
	{
		L4D_StopMusic(client, "Event.SurvivorDeath");
	}
}


//-------------------------------lockdown_system-l4d2_b API Forward-------------------------------

public void L4DLockDownSystem_OnOpenDoorFinish(const char[] sKeyMan)
{
	g_bIsOpenSafeRoom = true;
}