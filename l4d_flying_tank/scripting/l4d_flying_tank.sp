#pragma newdecls required
#pragma semicolon 1

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define PLUGIN_NAME		"l4d_flying_tank"
#define PLUGIN_VERSION 	"1.0h-2023/12/8"

public Plugin myinfo = 
{
	name 		= "[L4D1 AND L4D2] Flying Tank",
	author 		= "Panxiaohai And Ernecio (Satanael), HarryPotter",
	description = "Provides the ability to fly to Tanks and special effects.",
	version 	= PLUGIN_VERSION,
	url 		= "https://steamcommunity.com/profiles/76561198026784913"
}

bool g_bL4D2Version;
int ZC_TANK;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test == Engine_Left4Dead )
    {
        ZC_TANK = 5;
        g_bL4D2Version = false;
    }
    else if( test == Engine_Left4Dead2 )
    {
        ZC_TANK = 8;
        g_bL4D2Version = true;
    }
    else
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

#define TRANSLATION_FILE		PLUGIN_NAME ... ".phrases"

#define CHAT_TAG "\x04➛\x01Flying Tank\x04➛\x01"
#define HINT_TAG "➛Flying Tank➛"

#define FilterSelf 					0
#define FilterSelfAndPlayer 		1
#define FilterSelfAndSurvivor 		2
#define FilterSelfAndInfected 		3
#define FilterSelfAndPlayerAndCI 	4

#define STATE_NONE 	0
#define STATE_START 1
#define STATE_FLY 	2
#define NULL 		0

#define MAXENTITIES                   2048
#define ENTITY_SAFE_LIMIT             2000 //don't spawn boxes when it's index is above this

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar hCvar_MPGameMode;
ConVar hCvar_FlyingInfected_Enabled;
ConVar hCvar_FlyingInfected_FinaleOnly;

ConVar hCvar_FlyingInfected_GameModesOn;
ConVar hCvar_FlyingInfected_GameModesOff;
ConVar hCvar_FlyingInfected_GameModesToggle;
ConVar hCvar_FlyingInfected_MapsOn;
ConVar hCvar_FlyingInfected_MapsOff;

ConVar hCvar_FlyingInfected_Chance_Throw_AI;
ConVar hCvar_FlyingInfected_Chance_Tankclaw_AI;
ConVar hCvar_FlyingInfected_Chance_Tankjump;
ConVar hCvar_FlyingInfected_Chance_Tankjump_AI;

ConVar hCvar_FlyingInfected_Speed;
ConVar hCvar_FlyingInfected_Speed_AI; 
ConVar hCvar_FlyingInfected_Maxtime;
ConVar hCvar_FlyingInfected_Maxtime_AI;

ConVar hCvar_FlyingInfected_glow, hCvar_FlyingInfected_Crown, hCvar_FlyingInfected_JetPack_Light, hCvar_FlyingInfected_Ads;

/**********************************/
int iCvar_GameModesToggle;
int iCvar_CurrentMode;

char sCvar_MPGameMode[16];
char sCvar_GameModesOn[256];
char sCvar_GameModesOff[256];

char sCurrentMap[256];
char sCvar_MapsOn[256];
char sCvar_MapsOff[256];
/**********************************/

float fCvar_FlyingInfected_Chance_Throw_AI;
float fCvar_FlyingInfected_Chance_Tankclaw_AI;
float fCvar_FlyingInfected_Chance_Tankjump;
float fCvar_FlyingInfected_Chance_Tankjump_AI;
float fCvar_FlyingInfected_Speed;
float fCvar_FlyingInfected_Speed_AI;
float fCvar_FlyingInfected_Maxtime;
float fCvar_FlyingInfected_Maxtime_AI;

bool bCvar_FlyingInfected_Enabled;
bool bCvar_FlyingInfected_glow, bCvar_FlyingInfected_Crown, bCvar_FlyingInfected_JetPack_Light, bCvar_FlyingInfected_Ads;
bool bCvar_FlyingInfected_FinaleOnly;

bool bMapStarted;
bool bFinalEvent;

int vOffsetVelocity;

int iArrayStatus[MAXPLAYERS+1];
int iArraySounds[MAXPLAYERS+1];
int iArrayTarget[MAXPLAYERS+1];

float ClientVelocity[MAXPLAYERS+1][3];
float LastTime[MAXPLAYERS+1]; 
float FireTime[MAXPLAYERS+1]; 
float StartTime[MAXPLAYERS+1];
float ScanTime[MAXPLAYERS+1];

int 
	g_iModelRef[MAXPLAYERS+1][2],
	g_iFlameRef[MAXPLAYERS+1][2],
	g_iCrownRef[MAXPLAYERS+1][6],
	g_iLightRef[MAXPLAYERS+1];

public void OnPluginStart()
{
	LoadTranslations(TRANSLATION_FILE);

	hCvar_MPGameMode 						= FindConVar("mp_gamemode");

	hCvar_FlyingInfected_Enabled 			= CreateConVar( PLUGIN_NAME ... "_enable", 				"1", 		"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	hCvar_FlyingInfected_FinaleOnly 		= CreateConVar( PLUGIN_NAME ... "_finale_only", 		"0", 		"If 1, Enable the ability to fly for Tanks only in final.", CVAR_FLAGS, true, 0.0, true, 1.0);
	
	hCvar_FlyingInfected_GameModesOn 		= CreateConVar( PLUGIN_NAME ... "_gamemodes_on",  		"",   		"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	hCvar_FlyingInfected_GameModesOff 		= CreateConVar( PLUGIN_NAME ... "_gamemodes_off", 		"",   		"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	hCvar_FlyingInfected_GameModesToggle 	= CreateConVar( PLUGIN_NAME ... "_gamemodes_toggle", 	"0", 		"Turn on the plugin in these game modes.\n0 = All, 1 = Coop, 2 = Survival, 4 = Versus, 8 = Scavenge.\nAdd numbers together.", CVAR_FLAGS, true, 0.0, true, 15.0 );
	hCvar_FlyingInfected_MapsOn 			= CreateConVar( PLUGIN_NAME ... "_maps_on", 			"", 		"Allow the plugin being loaded on these maps, separate by commas (no spaces). Empty = all.\nExample: \"l4d_hospital01_apartment,c1m1_hotel\"", CVAR_FLAGS);
	hCvar_FlyingInfected_MapsOff 			= CreateConVar( PLUGIN_NAME ... "_maps_off", 			"", 		"Prevent the plugin being loaded on these maps, separate by commas (no spaces). Empty = none.\nExample: \"l4d_hospital01_apartment,c1m1_hotel\"", CVAR_FLAGS);
	
	hCvar_FlyingInfected_Chance_Throw_AI 	= CreateConVar( PLUGIN_NAME ... "_chance_throw_ai", 	"40.0", 	"Probability of flying when the AI Tank throws a rock.", CVAR_FLAGS, true, 0.0, true, 100.0);
	hCvar_FlyingInfected_Chance_Tankclaw_AI = CreateConVar( PLUGIN_NAME ... "_chance_claw_ai", 		"50.0", 	"Probability of flying when the AI Tank hits.", CVAR_FLAGS, true, 0.0, true, 100.0);
 	hCvar_FlyingInfected_Chance_Tankjump 	= CreateConVar( PLUGIN_NAME ... "_chance_jump_real", 	"100.0", 	"Probability of flying when the Tank Player jumps.", CVAR_FLAGS, true, 0.0, true, 100.0);
	hCvar_FlyingInfected_Chance_Tankjump_AI = CreateConVar( PLUGIN_NAME ... "_chance_jump_ai", 		"40.0", 	"Probability of flying when the AI Tank jumps.", CVAR_FLAGS, true, 0.0, true, 100.0);
	
	hCvar_FlyingInfected_Speed 				= CreateConVar( PLUGIN_NAME ... "_speed_real", 			"150.0", 	"Set the speed of the Tank player when him is flying.", CVAR_FLAGS, true, 100.0, true, 450.0);
	hCvar_FlyingInfected_Speed_AI 			= CreateConVar( PLUGIN_NAME ... "_speed_ai", 			"200.0", 	"Set the speed of the AI Tank when him is flying.", CVAR_FLAGS, true, 100.0, true, 450.0);
 	hCvar_FlyingInfected_Maxtime 			= CreateConVar( PLUGIN_NAME ... "_maxtime_real", 		"10.0", 	"Set the max flight time for Tank player.", CVAR_FLAGS, true, 3.0, true, 1000.0);
	hCvar_FlyingInfected_Maxtime_AI 		= CreateConVar( PLUGIN_NAME ... "_maxtime_ai", 			"20.0", 	"Set the max flight time for AI tank.", CVAR_FLAGS, true, 3.0, true, 1000.0);
	
	hCvar_FlyingInfected_glow 				= CreateConVar( PLUGIN_NAME ... "_glow", 				"1", 		"(L4D2) Enable the glow when Tank is flying.\n0 = Glow OFF\n1 = Glow ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
	hCvar_FlyingInfected_Crown 				= CreateConVar( PLUGIN_NAME ... "_crown", 				"1", 		"Enable the crown when Tank is fliying.\n0 = Crown of light OFF.\n1 = Crown of light ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
	hCvar_FlyingInfected_JetPack_Light 		= CreateConVar( PLUGIN_NAME ... "_light_system", 		"1", 		"Enable the light effect of the jetpack when the Tank is flying.\n0 = JetPack Light OFF.\n1 = JetPack Light ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
	hCvar_FlyingInfected_Ads 				= CreateConVar( PLUGIN_NAME ... "_ads", 				"1", 		"Enable the Message to Tank player.\n0 = Message OFF\n1 = Message ON.", CVAR_FLAGS, true, 0.0, true, 1.0);
	CreateConVar(                       					PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig( true, PLUGIN_NAME );

	hCvar_MPGameMode.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Enabled.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_FinaleOnly.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_GameModesOn.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_GameModesOff.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_GameModesToggle.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_MapsOn.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_MapsOff.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Chance_Throw_AI.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Chance_Tankclaw_AI.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Chance_Tankjump.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Chance_Tankjump_AI.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Speed.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Speed_AI.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Maxtime.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Maxtime_AI.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_glow.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Crown.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_JetPack_Light.AddChangeHook( Event_ConVarChanged );
	hCvar_FlyingInfected_Ads.AddChangeHook( Event_ConVarChanged );
	
	HookEvent("finale_start", 			Event_FinaleStarted, EventHookMode_PostNoCopy); //final starts, some of final maps won't trigger
	HookEvent("finale_radio_start", 	Event_FinaleStarted, EventHookMode_PostNoCopy); //final starts, all final maps trigger
	if(g_bL4D2Version) HookEvent("gauntlet_finale_start", 	Event_FinaleStarted, EventHookMode_PostNoCopy); //final starts, only rushing maps trigger (C5M5, C13M4)
	HookEvent("round_start", 	Event_RoundStarted, EventHookMode_Post);
	HookEvent("round_end", 		Event_RoundStarted, EventHookMode_Pre );
	HookEvent("finale_win", 	Event_RoundStarted, EventHookMode_Pre );
	HookEvent("mission_lost", 	Event_RoundStarted, EventHookMode_Pre );
	HookEvent("map_transition", Event_RoundStarted, EventHookMode_Pre );	
	HookEvent("weapon_fire", 	Event_WeaponFire, 	EventHookMode_Post);
	HookEvent("ability_use", 	Event_AbilityUse, 	EventHookMode_Post);
	HookEvent("player_jump", 	Event_PlayerJump, 	EventHookMode_Post);
	HookEvent("player_hurt", 	Event_PlayerHurt);
	HookEvent("player_death", 	Event_PlayerDeath, 	EventHookMode_Pre );
//	HookEvent("player_spawn", 	Event_PlayerSpawn, 	EventHookMode_Post);
//	HookEvent("player_team",	Event_PlayerTeam);
	HookEvent("player_bot_replace",Event_BotReplace,EventHookMode_Post);
	HookEvent("bot_player_replace", Event_PlayerReplace );	
	
	vOffsetVelocity = FindSendPropInfo( "CBasePlayer", "m_vecVelocity[0]" );
}

public void OnConfigsExecuted()
{
	GetCvars();
}

void Event_ConVarChanged( Handle hCvar, const char[] sOldVal, const char[] sNewVal )
{
	GetCvars();
}

void GetCvars()
{
	GetCurrentMap( sCurrentMap, sizeof( sCurrentMap ) );
	
	hCvar_MPGameMode.GetString( sCvar_MPGameMode, sizeof( sCvar_MPGameMode ) );
	TrimString( sCvar_MPGameMode );
	
	bCvar_FlyingInfected_Enabled = hCvar_FlyingInfected_Enabled.BoolValue;
	bCvar_FlyingInfected_FinaleOnly = hCvar_FlyingInfected_FinaleOnly.BoolValue;
	iCvar_GameModesToggle = hCvar_FlyingInfected_GameModesToggle.IntValue;
	fCvar_FlyingInfected_Chance_Throw_AI = hCvar_FlyingInfected_Chance_Throw_AI.FloatValue;
	fCvar_FlyingInfected_Chance_Tankclaw_AI = hCvar_FlyingInfected_Chance_Tankclaw_AI.FloatValue;
	fCvar_FlyingInfected_Chance_Tankjump = hCvar_FlyingInfected_Chance_Tankjump.FloatValue;
	fCvar_FlyingInfected_Chance_Tankjump_AI = hCvar_FlyingInfected_Chance_Tankjump_AI.FloatValue;
	fCvar_FlyingInfected_Speed = hCvar_FlyingInfected_Speed.FloatValue;
	fCvar_FlyingInfected_Speed_AI = hCvar_FlyingInfected_Speed_AI.FloatValue;
	fCvar_FlyingInfected_Maxtime = hCvar_FlyingInfected_Maxtime.FloatValue;
	fCvar_FlyingInfected_Maxtime_AI = hCvar_FlyingInfected_Maxtime_AI.FloatValue;
	bCvar_FlyingInfected_glow = hCvar_FlyingInfected_glow.BoolValue;
	bCvar_FlyingInfected_Crown = hCvar_FlyingInfected_Crown.BoolValue;
	bCvar_FlyingInfected_JetPack_Light = hCvar_FlyingInfected_JetPack_Light.BoolValue;
	bCvar_FlyingInfected_Ads = hCvar_FlyingInfected_Ads.BoolValue;
	
	hCvar_FlyingInfected_GameModesOn.GetString( sCvar_GameModesOn, sizeof( sCvar_GameModesOn ) );
//	TrimString( sCvar_GameModesOn ); 													// Removes whitespace characters from the beginning and end of a string.
	ReplaceString( sCvar_GameModesOn, sizeof( sCvar_GameModesOn ), " ", "", false ); 	// Remove spaces in any section of the string.
	hCvar_FlyingInfected_GameModesOff.GetString( sCvar_GameModesOff, sizeof( sCvar_GameModesOff ) );
//	TrimString( sCvar_GameModesOff );
	ReplaceString( sCvar_GameModesOff, sizeof( sCvar_GameModesOff ), " ", "", false );
	
	hCvar_FlyingInfected_MapsOn.GetString( sCvar_MapsOn, sizeof( sCvar_MapsOn ) );
	ReplaceString( sCvar_MapsOn, sizeof( sCvar_MapsOn ), " ", "", false );
	
	hCvar_FlyingInfected_MapsOff.GetString( sCvar_MapsOff, sizeof( sCvar_MapsOff ) );
	ReplaceString( sCvar_MapsOff, sizeof( sCvar_MapsOff ), " ", "", false );
}

public void OnMapStart()
{
	PrecacheModel("models/props_equipment/oxygentank01.mdl", true);
	PrecacheSound("ambient/Spacial_Loops/CarFire_Loop.wav", true );
	
	bMapStarted = true;
}

public void OnMapEnd()
{
	bMapStarted = false;
}

void Event_RoundStarted( Event hEvent, const char[] sName, bool bDontBroadcast )
{	
	for( int i = 1; i <= MaxClients; i ++ )
	{
		if( !IsValidClient( i ) )
			continue;
			
		StopFly( i );
		iArrayStatus[i] = STATE_NONE;
		FireTime[i] = 0.0;
		SDKUnhook(i, SDKHook_PreThink, PreThink); 
		SDKUnhook(i, SDKHook_StartTouch, FlyTouch);
	}
	
	bFinalEvent = false;
}

void Event_FinaleStarted( Event hEvent, const char[] sName, bool bDontBroadcast )
{	
	bFinalEvent = true;
}

void Event_WeaponFire( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	if( !IsAllowedPlugin() ) return;
	
	int client = GetClientOfUserId( hEvent.GetInt( "userid" ) );
	if( IsTank( client ) && IsPlayerAlive( client ) ) 
	{
		if( FireTime[client] + 1.0 < GetEngineTime())
			FireTime[client] = GetEngineTime();
		else
			return; // Prevents over-creation of timers.
		
		if( iArrayStatus[client] == STATE_NONE )
		{ 
			if(IsFakeClient(client))
			{
				if( GetRandomFloat( 1.0, 100.0 ) <= fCvar_FlyingInfected_Chance_Tankclaw_AI )
				{
					iArrayStatus[client] = STATE_START;
					CreateTimer( 3.0, StartTimer, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE );
				}
			}
			/*else
			{
				if( GetRandomFloat( 1.0, 100.0 ) <= fCvar_FlyingInfected_Chance_Tankclaw )
				{
					iArrayStatus[client] = STATE_START;
					CreateTimer( 3.0, StartTimer, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE );
				}	
			}*/
		}
	}
}

void Event_PlayerHurt( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	if( !IsAllowedPlugin() ) return;
	
	int attacker = GetClientOfUserId( hEvent.GetInt( "attacker" ) );
	if( attacker > 0 && iArrayStatus[attacker] == STATE_FLY )
	{
		char sBuffer[32];	
		hEvent.GetString( "weapon", sBuffer, sizeof( sBuffer ) );
		
	 	if( StrEqual( sBuffer, "tank_claw" ) )
			StopFly( attacker );
	}
}

void Event_PlayerJump( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	if( !IsAllowedPlugin() ) return;
	
	int client = GetClientOfUserId( hEvent.GetInt( "userid" ) );
	if( IsTank( client ) && iArrayStatus[client] == STATE_NONE )
	{
		if(IsFakeClient(client))
		{
			if( GetRandomFloat( 1.0, 100.0 ) <= fCvar_FlyingInfected_Chance_Tankjump_AI )
			{
				iArrayStatus[client] = STATE_START;
				StartTimer( INVALID_HANDLE, GetClientUserId( client ) );
			}
		}
		else
		{
			if( GetRandomFloat( 1.0, 100.0 ) <= fCvar_FlyingInfected_Chance_Tankjump )
			{
				iArrayStatus[client] = STATE_START;
				StartTimer( INVALID_HANDLE, GetClientUserId( client ) );
			}
		}
	}
}

void Event_PlayerDeath( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	if( !IsAllowedPlugin() ) return;
	
	int client = GetClientOfUserId( hEvent.GetInt( "userid" ) );
	if( IsTank( client ) && iArrayStatus[client] == STATE_FLY ) 
		StopFly( client );
}

void Event_AbilityUse( Event hEvent, const char[] sName, bool bDontBroadcast )
{	
	if( !IsAllowedPlugin() ) return;
	
	int client = GetClientOfUserId( hEvent.GetInt( "userid" ) );
	if( iArrayStatus[client] == STATE_NONE ) 
	{
		char sBuffer[32];	
		hEvent.GetString( "ability", sBuffer, sizeof( sBuffer ) );
		if( StrEqual( sBuffer, "ability_throw", true ) )
		{
			if(IsFakeClient(client))
			{
				if( GetRandomFloat( 1.0, 100.0 ) <= fCvar_FlyingInfected_Chance_Throw_AI )
				{
					iArrayStatus[client] = STATE_START;
					CreateTimer( 3.0, StartTimer, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE );
				}
			}
			/*else
			{
				if( GetRandomFloat( 1.0, 100.0 ) <= fCvar_FlyingInfected_Chance_Throw )
				{
					iArrayStatus[client] = STATE_START;
					CreateTimer( 3.0, StartTimer, GetClientUserId( client ), TIMER_FLAG_NO_MAPCHANGE );
				}
			}*/		
		}
	}
}

void Event_BotReplace( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	if( !bCvar_FlyingInfected_Enabled ) return;
	
 	int client = GetClientOfUserId( hEvent.GetInt( "player" ) );
	int bot = GetClientOfUserId( hEvent.GetInt( "bot" ) );   
	
	if( client ) StopFly( client );
	if( bot ) StopFly( bot );
}

void Event_PlayerReplace( Event hEvent, const char[] sName, bool bDontBroadcast )
{
	if( !bCvar_FlyingInfected_Enabled ) return;
	
 	int client = GetClientOfUserId( hEvent.GetInt( "player" ) );
	int bot = GetClientOfUserId( hEvent.GetInt( "bot" ) );   
	
	if( bot ) StopFly( bot );
	if( client ) StopFly( client );
}

Action StartTimer( Handle hTimer, any UserID )
{
	int client = GetClientOfUserId( UserID );
	if( IsTank( client ) && iArrayStatus[client] != STATE_FLY && IsPlayerAlive( client ) && !IsPlayerIncapped( client ) ) 
	{
		StartFly( client );
		if(!IsFakeClient(client) && bCvar_FlyingInfected_Ads)
		{
			PrintHintText(client, "%T", "How to control", client);
		}
	}
	if( iArrayStatus[client] != STATE_FLY ) 
		iArrayStatus[client] = STATE_NONE;

	return Plugin_Continue;
}

void StartFly( int client )
{   
	if( iArrayStatus[client] == STATE_FLY )
		StopFly( client );
	
	iArrayStatus[client] = STATE_NONE;

	float vOrigin[3], vPos[3], vAngles[3], vEyeAngles[3];
	vAngles[0] = - 89.0;
	GetClientEyePosition( client, vOrigin );
	Handle hTrace = TR_TraceRayFilterEx( vOrigin, vAngles, MASK_ALL, RayType_Infinite, DontHitSelf, client );
	
	bool bNarrow = false;
	if( TR_DidHit( hTrace ) )
	{
		TR_GetEndPosition( vPos, hTrace ); 
		if( GetVectorDistance( vPos, vOrigin ) <= 100.0 )
		{
			bNarrow = true;
			
			if( !IsFakeClient( client ) && bCvar_FlyingInfected_Ads)
				PrintCenterText( client, "%T", "narrow", client );
		}
	}
	
	delete hTrace;
	if( bNarrow ) return;
	
	iArrayStatus[client] = STATE_FLY;
	
//	GetEntPropVector( client, Prop_Send, "m_vecOrigin", vOrigin );
	GetEntPropVector( client, Prop_Data, "m_vecAbsOrigin", vOrigin );
	GetClientEyeAngles( client, vEyeAngles ); 								// Crosshair angles.
	vOrigin[2] += 5.0; 														// Initial elevation from the ground.
	vEyeAngles[2] = 30.0; 													// Initial elevation angle.
	GetAngleVectors( vEyeAngles, vEyeAngles, NULL_VECTOR, NULL_VECTOR );
	NormalizeVector( vEyeAngles, vEyeAngles );
	ScaleVector( vEyeAngles, 55.0 );
	TeleportEntity( client, vOrigin, NULL_VECTOR, vEyeAngles );
	vCopyVector( vEyeAngles, ClientVelocity[client] );
	
	LastTime[client] = GetEngineTime() - 0.01;
	StartTime[client] = GetEngineTime();
	ScanTime[client] = GetEngineTime() - 0.0;
	
	iArrayTarget[client] = NULL;
	
	SDKUnhook( client, SDKHook_PreThink, PreThink );
	SDKHook( client, SDKHook_PreThink, PreThink );
	SDKUnhook( client, SDKHook_StartTouch, FlyTouch );
	SDKHook( client, SDKHook_StartTouch, FlyTouch );
	
	SetParentModel( client );
	SetParentFlame( client );
	SetParentLight( client );
	SetParentCrown( client );
	StartGlowing( client );
	
	CreateTimer( 0.5, Timer_Others, GetClientUserId( client ), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE );
} 

Action FlyTouch( int client, int other )
{
	StopFly( client ); 

	return Plugin_Continue;
}

Action PreThink( int client )
{
	if( IsValidClient( client ) && IsPlayerAlive( client ) && !IsPlayerIncapped( client ) )
	{ 
		float fTime = GetEngineTime();
		float fIntervual = fTime - LastTime[client]; 
		int CurrentButton = GetClientButtons( client );
		
		LastTime[client] = fTime;
		TraceFly( client, CurrentButton, fTime, fIntervual );
	}
	else 
	{
		SDKUnhook( client, SDKHook_PreThink, PreThink );
	}

	return Plugin_Continue;
}

Action Timer_Others( Handle hTimer, any UserID )
{
	int client = GetClientOfUserId( UserID );
	if( !IsTank( client ) || !IsPlayerAlive( client ) || IsPlayerIncapped( client ) || iArrayStatus[client] != STATE_FLY )
		return Plugin_Stop;
	
	float vPos[3];
	GetClientAbsOrigin( client, vPos );
	
	PlaySound( client, vPos );
	
	return Plugin_Continue;
}

void TraceFly( int client, int CurrentButton, float fTime, float fDuration )
{
	if( IsFakeClient( client ) )
	{
		if( fTime - StartTime[client] > fCvar_FlyingInfected_Maxtime_AI )
		{
			StopFly( client );
			return;
		}
	}
	else
	{
		if( fTime - StartTime[client] > fCvar_FlyingInfected_Maxtime )
		{
			StopFly( client );
			if(bCvar_FlyingInfected_Ads) PrintHintText( client, "%T", "long", client);
			return;
		}
	}	
	
	if( !IsFakeClient( client ) && IsClientInGame( client ) )
	{		
		if( CurrentButton & IN_USE )
		{
			float vFallGravity; 													// Default gravity.
			
			if( CurrentButton & IN_SPEED )
				vFallGravity = 0.75; 												// Seventy-five percent gravity.
			else if( CurrentButton & IN_DUCK )
				vFallGravity = 0.5; 												// Fifty percent gravity.
			else
				vFallGravity = 1.0;
			
			SetEntityGravity( client, vFallGravity );
//			PrintHintText( client, "%s %N You are descending!", HINT_TAG, client );
			return;
		}
		
		SetEntityMoveType( client, MOVETYPE_FLYGRAVITY ); 
		
		float vEyeAngles[3], vAbsOrigin[3], vTemp[3], vSpeedIndex[3], vPushingForce[3]; 
		float vLifForce = 50.0, vGravity = 0.001, vNormalGravity = 0.01;
		float vSpeedLimit = IsFakeClient(client) ? fCvar_FlyingInfected_Speed_AI : fCvar_FlyingInfected_Speed;
		float vVariableSpeed;
		
		GetEntDataVector( client, vOffsetVelocity, vSpeedIndex );
		GetClientEyeAngles( client, vEyeAngles );
		GetClientAbsOrigin( client, vAbsOrigin );
//		vEyeAngles[0] = 0.0; 														// Crosshair angle offers greater jetpack control, zero array corresponds Up, Down.
		
		bool bJumping = false;
		
		if( CurrentButton & IN_JUMP ) 
		{
			bJumping = true;
			vEyeAngles[0] = -50.0; 													// Elevation Angle.
			GetAngleVectors( vEyeAngles, vEyeAngles, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector( vEyeAngles, vEyeAngles );
			ScaleVector( vEyeAngles, vSpeedLimit );
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vEyeAngles );
//			PrintHintText( client, "%s %N You are rising!", HINT_TAG, client );
			return;
		}
		
		if((CurrentButton & IN_SPEED) && !bJumping )
		{
			vVariableSpeed = vSpeedLimit * 75.0 / 100.0; 							// Seventy-five percent of max speed.
			
			if( CurrentButton & IN_FORWARD )
				vVariableSpeed = vSpeedLimit; 										// Max allowed speed
			
			GetAngleVectors( vEyeAngles, vEyeAngles, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector( vEyeAngles, vEyeAngles );
//			ScaleVector( vEyeAngles, vSpeedLimit );
			ScaleVector( vEyeAngles, vVariableSpeed );
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vEyeAngles );
//			PrintHintText( client, "%s %N Your current speed is[%f]", HINT_TAG, client, vVariableSpeed ); // Test.
//			PrintHintText( client, "%s %N You move at max speed!", HINT_TAG, client );
			return;
		}
		else if( !(CurrentButton & IN_SPEED) && (CurrentButton & IN_DUCK) && !bJumping )
		{
			vVariableSpeed = vSpeedLimit * 33.33 / 100.0; 							// Thirty-three percent of max speed.
			
			if( CurrentButton & IN_FORWARD )
				vVariableSpeed = vSpeedLimit * 50.0 / 100.0; 						// Fifty percent of max speed.
			
			GetAngleVectors( vEyeAngles, vEyeAngles, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector( vEyeAngles, vEyeAngles );
			ScaleVector( vEyeAngles, vVariableSpeed );
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vEyeAngles );
//			PrintHintText( client, "%s %N Your current speed is[%f]", HINT_TAG, client, vVariableSpeed ); // Test.
//			PrintHintText( client, "%s %N You move at the min speed!", HINT_TAG, client );
			return;
		}
		
		if( CurrentButton & IN_FORWARD )
		{ 
			GetAngleVectors( vEyeAngles, vTemp, NULL_VECTOR, NULL_VECTOR );
			NormalizeVector( vTemp, vTemp );
			AddVectors( vPushingForce, vTemp, vPushingForce );
//			PrintHintText( client, "%s %N You move forward!", HINT_TAG, client );
		}
		else if( CurrentButton & IN_BACK )
		{
			GetAngleVectors( vEyeAngles, vTemp, NULL_VECTOR, NULL_VECTOR );
			NormalizeVector( vTemp, vTemp ); 
			SubtractVectors( vPushingForce, vTemp, vPushingForce ); 
//			PrintHintText( client, "%s %N You move backwards!", HINT_TAG, client );
		}
		
		if( CurrentButton & IN_MOVELEFT )
		{ 
			GetAngleVectors( vEyeAngles, NULL_VECTOR, vTemp, NULL_VECTOR );
			NormalizeVector( vTemp, vTemp); 
			SubtractVectors( vPushingForce, vTemp, vPushingForce );
//			PrintHintText( client, "%s %N You move to the left!", HINT_TAG, client );
		}
		else if( CurrentButton & IN_MOVERIGHT )
		{
			GetAngleVectors( vEyeAngles, NULL_VECTOR, vTemp, NULL_VECTOR );
			NormalizeVector( vTemp, vTemp ); 
			AddVectors( vPushingForce, vTemp, vPushingForce );
//			PrintHintText( client, "%s %N You move to the right!", HINT_TAG, client );
		}
		
		NormalizeVector( vPushingForce, vPushingForce );
		ScaleVector( vPushingForce, vLifForce * fDuration );
		
		if( FloatAbs( vSpeedIndex[2] ) > 40.0 )
			vGravity = vSpeedIndex[2] * fDuration;
		else
			vGravity = vNormalGravity;
		
		float vCurrentSpeed = GetVectorLength( vSpeedIndex );
		
		if( vGravity > 0.5 ) vGravity = 0.5;
		if( vGravity < - 0.5 ) vGravity = - 0.5; 
		
		if( vCurrentSpeed > vSpeedLimit )
		{
			NormalizeVector( vSpeedIndex, vSpeedIndex );
			ScaleVector( vSpeedIndex, vSpeedLimit );
			TeleportEntity( client, NULL_VECTOR, NULL_VECTOR, vSpeedIndex );
			vGravity = vNormalGravity;
		}
		
		SetEntityGravity( client, vGravity );
		return; // From here the control is automatic.
	}
	
	float vOrigin[3];
	float vVelocity[3];
	
	GetClientAbsOrigin( client, vOrigin );
	GetEntDataVector( client, vOffsetVelocity, vVelocity );
	vOrigin[2] += 30.0;
	
	vCopyVector(ClientVelocity[client], vVelocity );	
	if( GetVectorLength( vVelocity ) < 10.0 ) return;
	NormalizeVector( vVelocity, vVelocity );
	
 	int iTarget = iArrayTarget[client];
	if( ScanTime[client] + 1.0 <= fTime )
	{
		ScanTime[client] = fTime;
		if( IsFakeClient( client ) )
		{
			iTarget = GetEnemy( vOrigin, vVelocity );
		}
		else 
		{
			float vLookDir[3];
			GetClientEyeAngles( client, vLookDir );
			GetAngleVectors( vLookDir, vLookDir, NULL_VECTOR, NULL_VECTOR ); 
			NormalizeVector( vLookDir, vLookDir );
			iTarget = GetEnemy( vOrigin, vLookDir );
		}
	}
	
	if( iTarget > 0 && IsClientInGame( iTarget ) && GetClientTeam(iTarget) == 2 && IsPlayerAlive( iTarget ) )
	{
		iArrayTarget[client] = iTarget;
	}
	else
	{
		iTarget = NULL;
		iArrayTarget[client] = iTarget;
	}
	
	float velocityenemy[3], vtrace[3];
	
	bool bVisible = false;
	float ENEMY_DISTANCE = 1000.0;
	if( iTarget )
	{
		float Objective[3];
		GetClientEyePosition( iTarget, Objective );
		ENEMY_DISTANCE = GetVectorDistance( vOrigin, Objective );
		bVisible = IfTwoPosVisible( vOrigin, Objective, client );
		GetEntDataVector( iTarget, vOffsetVelocity, velocityenemy );
		ScaleVector( velocityenemy, fDuration );
		AddVectors( Objective, velocityenemy, Objective );
		MakeVectorFromPoints(vOrigin, Objective, vtrace );
		
		//if( iTarget && !IsFakeClient( iTarget ) && IsClientInGame( client ) && bCvar_FlyingInfected_Mssage )
		//	PrintHintText( iTarget, "Warning! You are in %N's sights, Distance[%d]", client, RoundFloat( ENEMY_DISTANCE ) );
	}
	
	float vleft[3], vright[3], vup[3], vdown[3], vfront[3], vv1[3], vv2[3], vv3[3], vv4[3], vv5[3], vv6[3], vv7[3], vv8[3];
	
	float factor1 = 0.2; 
	float factor2 = 0.5;
	float base1 = 1500.0;
	float base2 = 10.0;
	float vAngles[3];
	float t;
	
	GetVectorAngles( vVelocity, vAngles );
	
	float front = GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, 0.0,   0.0, vfront, client, FilterSelfAndSurvivor);
	float down 	= GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, 90.0,  0.0, vdown, client, FilterSelfAndSurvivor );
	float up 	= GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, -90.0, 0.0, vup, client );
	float left 	= GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, 0.0,  90.0, vleft, client, FilterSelfAndSurvivor );
	float right = GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, 0.0, -90.0, vright, client, FilterSelfAndSurvivor);
	
	float f1 = GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, 30.0,  0.0,   vv1, client, FilterSelfAndSurvivor );
	float f2 = GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, 30.0,  45.0,  vv2, client, FilterSelfAndSurvivor );
	float f3 = GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, 0.0,   45.0,  vv3, client, FilterSelfAndSurvivor );
	float f4 = GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, -30.0, 45.0,  vv4, client, FilterSelfAndSurvivor );
	float f5 = GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, -30.0, 0.0,   vv5, client, FilterSelfAndSurvivor );
	float f6 = GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, -30.0, -45.0, vv6, client, FilterSelfAndSurvivor );	
	float f7 = GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, 0.0,   -45.0, vv7, client, FilterSelfAndSurvivor );
	float f8 = GetDistanceVectorsPhysicsObjects( vOrigin, vAngles, 30.0,  -45.0, vv8, client, FilterSelfAndSurvivor );
	
	NormalizeVector( vfront, vfront );
	NormalizeVector( vup, vup );
	NormalizeVector( vdown, vdown );
	NormalizeVector( vleft, vleft );
	NormalizeVector( vright, vright );
	NormalizeVector( vtrace, vtrace );
	NormalizeVector( vv1, vv1 );
	NormalizeVector( vv2, vv2 );
	NormalizeVector( vv3, vv3 );
	NormalizeVector( vv4, vv4 );
	NormalizeVector( vv5, vv5 );
	NormalizeVector( vv6, vv6 );
	NormalizeVector( vv7, vv7 );
	NormalizeVector( vv8, vv8 );
	
	if( bVisible ) base1 = 80.0;
	if( front > base1 ) front 	= base1;
	if( up 	  > base1 ) up 		= base1;
	if( down  > base1 ) down 	= base1;
	if( left  > base1 ) left 	= base1;
	if( right > base1 ) right 	= base1;
	if( f1 > base1 ) f1 = base1;
	if( f2 > base1 ) f2 = base1;
	if( f3 > base1 ) f3 = base1;	
	if( f4 > base1 ) f4 = base1;
	if( f5 > base1 ) f5 = base1;
	if( f6 > base1 ) f6 = base1;
	if( f7 > base1 ) f7 = base1;
	if( f8 > base1 ) f8 = base1;
	
	if( front < base2 ) front 	= base2;
	if( up    < base2 ) up 		= base2;
	if( down  < base2 ) down 	= base2;
	if( left  < base2 ) left 	= base2;
	if( right < base2 ) right 	= base2;
	if( f1 < base2 ) f1 = base2;
	if( f2 < base2 ) f2 = base2;	
	if( f3 < base2 ) f3 = base2;
	if( f4 < base2 ) f4 = base2;
	if( f5 < base2 ) f5 = base2;
	if( f6 < base2 ) f6 = base2;
	if( f7 < base2 ) f7 = base2;
	if( f8 < base2 ) f8 = base2;
	
	t = - 1.0 * factor1 * ( base1 - front ) / base1;
	ScaleVector( vfront, t );
	t = - 1.0 * factor1 * ( base1 - up ) / base1;
	ScaleVector( vup, t );
	t = - 1.0 * factor1 * ( base1 - down ) / base1;
	ScaleVector( vdown, t );
	t = - 1.0 * factor1 * ( base1 - left ) / base1;
	ScaleVector( vleft, t );
	t = - 1.0 * factor1 * ( base1 - right ) / base1;
	ScaleVector( vright, t );
	t = - 1.0 * factor1 * ( base1 - f1 ) / f1;
	ScaleVector( vv1, t );
	t = - 1.0 * factor1 * ( base1 - f2 ) / f2;
	ScaleVector( vv2, t );
	t = - 1.0 * factor1 * ( base1 - f3 ) / f3;
	ScaleVector( vv3, t );
	t = - 1.0 * factor1 * ( base1 - f4 ) / f4;
	ScaleVector( vv4, t );
	t = - 1.0 * factor1 * ( base1 - f5 ) / f5;
	ScaleVector( vv5, t );
	t = - 1.0 * factor1 * ( base1 - f6 ) / f6;
	ScaleVector( vv6, t );
	t = - 1.0 * factor1 * ( base1 - f7 ) / f7;
	ScaleVector( vv7, t );
	t = - 1.0 * factor1 * ( base1 - f8 ) / f8;
	ScaleVector( vv8, t );
	
	if( ENEMY_DISTANCE >= 500.0 ) ENEMY_DISTANCE = 500.0;
	t = 1.0 * factor2 * ( 1000.0 - ENEMY_DISTANCE ) / 500.0;
	ScaleVector( vtrace, t );

	AddVectors( vfront, vup, vfront );
	AddVectors( vfront, vdown, vfront );
	AddVectors( vfront, vleft, vfront );
	AddVectors( vfront, vright, vfront );
	AddVectors( vfront, vv1, vfront );
	AddVectors( vfront, vv2, vfront );
	AddVectors( vfront, vv3, vfront );
	AddVectors( vfront, vv4, vfront );
	AddVectors( vfront, vv5, vfront );
	AddVectors( vfront, vv6, vfront );
	AddVectors( vfront, vv7, vfront );
	AddVectors( vfront, vv8, vfront );
	AddVectors( vfront, vtrace, vfront );	
	NormalizeVector( vfront, vfront );
	
	ScaleVector( vfront, 3.141592 * fDuration * 2.0 );
	
	float vNewVelocity[3];
	AddVectors( vVelocity, vfront, vNewVelocity );
	
	float Speed = IsFakeClient(client) ? fCvar_FlyingInfected_Speed_AI : fCvar_FlyingInfected_Speed;
	if( Speed < 60.0 ) 
		Speed = 60.0;
	
	NormalizeVector( vNewVelocity, vNewVelocity );
	ScaleVector( vNewVelocity, Speed);   
	
	SetEntityMoveType( client, MOVETYPE_FLY );
//	SetEntityGravity( client, 0.01 );
	vCopyVector( vNewVelocity, ClientVelocity[client] );
	
	TeleportEntity( client, NULL_VECTOR, NULL_VECTOR , vNewVelocity );
}

int GetEnemy( float vPos[3], float vAngles[3] )
{
	float vMinAngle = 4.0, vIncapMinAngle = 4.0;
	float vPosition[3];
	int   iIndex = 0, iIncapTarget = 0;
	
	for( int i = 1; i <= MaxClients; i ++ )
	{
		if( IsClientInGame( i ) && GetClientTeam( i ) == 2 && IsPlayerAlive( i ) && !IsHandingFromLedge( i ))
		{
			if(IsPlayerIncapped( i ))
			{
				GetClientEyePosition( i, vPosition );
				MakeVectorFromPoints( vPos, vPosition, vPosition );
				if( GetAngle( vAngles, vPosition ) <= vIncapMinAngle )
				{
					vIncapMinAngle = GetAngle( vAngles, vPosition );
					iIncapTarget = i;
				}
			}

			GetClientEyePosition( i, vPosition );
			MakeVectorFromPoints( vPos, vPosition, vPosition );
			if( GetAngle( vAngles, vPosition ) <= vMinAngle )
			{
				vMinAngle = GetAngle( vAngles, vPosition );
				iIndex = i;
			}
		}
	}

	if (iIndex == 0) iIndex = iIncapTarget;
	
	return iIndex;
}

bool IfTwoPosVisible( float vAngles[3], float vOrigins[3], int iSelf )
{
	bool bR = true;
	Handle hTrace = TR_TraceRayFilterEx( vOrigins, vAngles, MASK_SOLID, RayType_EndPoint, DontHitSelfAndSurvivor, iSelf );
	if( TR_DidHit( hTrace ) ) 
		bR = false;
	
	delete hTrace;
	return bR;
}

float GetDistanceVectorsPhysicsObjects( float vOrigin[3], float vAngle[3], float vOffset1, float vOffset2, float vForce[3], int iEntity, int iFlag = FilterSelf )
{
	float vAngles[3];
	vCopyVector( vAngle, vAngles );
	vAngles[0] += vOffset1;
	vAngles[1] += vOffset2;
	GetAngleVectors( vAngles, vForce, NULL_VECTOR,NULL_VECTOR ) ;
	float vDistance = GetRayDistance( vOrigin, vAngles, iEntity, iFlag ); 
	return vDistance; 
}

float GetAngle( float vX1[3], float vX2[3] )
{
	return ArcCosine( GetVectorDotProduct( vX1, vX2 ) / ( GetVectorLength( vX1 ) * GetVectorLength( vX2 ) ) );
}

bool DontHitSelf( int entity, int mask, any data )
{
	if( entity == data )
		return false;
	
	return true;
}

bool DontHitSelfAndPlayer( int entity, int mask, any data )
{
	if( entity == data )
		return false;
	else if( entity > 0 && entity <= MaxClients ) 
		if ( IsClientInGame( entity ) )
			return false;
		
	return true;
}

bool DontHitSelfAndSurvivor( int entity, int mask, any data )
{
	if( entity == data )
		return false; 
	else if( entity > 0 && entity <= MaxClients ) 
		if ( IsClientInGame( entity ) && GetClientTeam( entity ) == 2 )
			return false;
		
	return true;
}

bool DontHitSelfAndInfected( int entity, int mask, any data )
{
	if( entity == data ) 
		return false;
	else if( entity > 0 && entity <= MaxClients ) 
		if ( IsClientInGame(entity) && GetClientTeam(entity) == 3 )
			return false;
		
	return true;
}

bool DontHitSelfAndPlayerAndCI( int entity, int mask, any data )
{
	if( entity == data ) 
		return false;
	else if( entity > 0 && entity <= MaxClients )
	{
		if( IsClientInGame( entity ) )
			return false;
	}
	else
	{
		if( IsValidEntity( entity ) && IsValidEdict( entity ) )
		{
			char sEdictName[128];
			GetEdictClassname( entity, sEdictName, sizeof( sEdictName ) );
			if( StrContains( sEdictName, "infected") >= 0 )
				return false;
		}
	}
	return true;
}

float GetRayDistance( float vOrigin[3], float vAngles[3], int iSelf, int iFlag )
{
	float vHitPos[3];
	GetRayHitPos( vOrigin, vAngles, vHitPos, iSelf, iFlag );
	return GetVectorDistance( vOrigin, vHitPos );
}

int GetRayHitPos( float vOrigin[3], float vAngles[3], float vHitPos[3], int iSelf, int iFlag )
{
	Handle hTrace;
	int iHit = NULL;
	
	if( iFlag == FilterSelf ) 						hTrace = TR_TraceRayFilterEx( vOrigin, vAngles, MASK_SOLID, RayType_Infinite, DontHitSelf, iSelf );
	else if( iFlag == FilterSelfAndPlayer ) 		hTrace = TR_TraceRayFilterEx( vOrigin, vAngles, MASK_SOLID, RayType_Infinite, DontHitSelfAndPlayer, iSelf );
	else if( iFlag == FilterSelfAndSurvivor ) 		hTrace = TR_TraceRayFilterEx( vOrigin, vAngles, MASK_SOLID, RayType_Infinite, DontHitSelfAndSurvivor, iSelf );
	else if( iFlag == FilterSelfAndInfected ) 		hTrace = TR_TraceRayFilterEx( vOrigin, vAngles, MASK_SOLID, RayType_Infinite, DontHitSelfAndInfected, iSelf );
	else if( iFlag == FilterSelfAndPlayerAndCI ) 	hTrace = TR_TraceRayFilterEx( vOrigin, vAngles, MASK_SOLID, RayType_Infinite, DontHitSelfAndPlayerAndCI, iSelf );
	if( TR_DidHit( hTrace ) )
	{	
		TR_GetEndPosition( vHitPos, hTrace);
		iHit = TR_GetEntityIndex( hTrace );
	}
	
	delete hTrace;
	return iHit;
}

void SetParentModel( int client )
{
	RemoveModel(client);

	float vOrigin[3], vAngles[3];
	int RenderRGB[4], iEntity;
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", vOrigin);
	GetEntPropVector(client, Prop_Send, "m_angRotation", vAngles);
	GetEntityRenderColor(client, RenderRGB[0], RenderRGB[1], RenderRGB[2], RenderRGB[3]);
	
	for( int iCount = 0; iCount <= 1; iCount ++ )
	{
		iEntity = CreateEntityByName( "prop_dynamic_override" );
		if( CheckIfEntitySafe( iEntity ) )
		{
			char sName[64];
			Format(sName, sizeof(sName), "Tank%d", client);
			DispatchKeyValue(client, "targetname", sName);
			GetEntPropString(client, Prop_Data, "m_iName", sName, sizeof(sName));
			
			DispatchKeyValue(iEntity, "model", "models/props_equipment/oxygentank01.mdl");
			SetEntityRenderColor(iEntity, RenderRGB[0], RenderRGB[1], RenderRGB[2], RenderRGB[3]);
			DispatchKeyValue(iEntity, "targetname", "PropaneTankEntity");
			DispatchKeyValue(iEntity, "parentname", sName);
			DispatchKeyValueVector(iEntity, "origin", vOrigin);
			DispatchKeyValueVector(iEntity, "angles", vAngles);
			DispatchSpawn(iEntity);
			SetVariantString(sName);
			AcceptEntityInput(iEntity, "SetParent", iEntity, iEntity);
			switch(iCount)
			{
				case 0:{ SetVariantString("rfoot"); vOrigin = view_as<float>({0.0, 30.0,  8.0}); }
				case 1:{ SetVariantString("lfoot"); vOrigin = view_as<float>({0.0, 30.0, -8.0}); }
			}
			AcceptEntityInput(iEntity, "SetParentAttachment");
			AcceptEntityInput(iEntity, "Enable");
			AcceptEntityInput(iEntity, "DisableCollision");
			SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);
			
			vAngles = view_as<float>({0.0, 0.0, 90.0});
			
			TeleportEntity(iEntity, vOrigin, vAngles, NULL_VECTOR);
			
			StartGlowing( iEntity );
			
			SDKUnhook(iEntity, SDKHook_SetTransmit, SetTransmit);
			SDKHook(iEntity, SDKHook_SetTransmit, SetTransmit);

			g_iModelRef[client][iCount] = EntIndexToEntRef(iEntity);
		}
	}
}

void RemoveModel(int client)
{
	int entity; 
	
	for( int iCount = 0; iCount <= 1; iCount ++ )
	{
		entity= g_iModelRef[client][iCount];
		g_iModelRef[client][iCount] = 0;
		if( IsValidEntRef(entity) )
			RemoveEntity(entity);
	}
}

void SetParentFlame( int client )
{
	RemoveFlame(client);

	float vOrigin[3], vAngles[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", vOrigin);
	//GetEntPropVector(client, Prop_Send, "m_angRotation", vAngles);
	int iEntity;
	
	for( int iCount = 0; iCount <= 1; iCount ++ )
	{
		iEntity = CreateEntityByName("env_steam");
		if( CheckIfEntitySafe( iEntity ) )
		{
			char sName[64];
			Format(sName, sizeof(sName), "Tank%d", client);
			DispatchKeyValue(client, "targetname", sName);
			GetEntPropString(client, Prop_Data, "m_iName", sName, sizeof(sName));
			
			DispatchKeyValue(iEntity, "targetname", "SteamEntity");
			DispatchKeyValue(iEntity, "parentname", sName);
			DispatchKeyValueVector(iEntity, "origin", vOrigin);
			//DispatchKeyValueVector(iEntity, "angles", vAngles);
			DispatchKeyValue(iEntity, "SpawnFlags", "1");
			DispatchKeyValue(iEntity, "Type", "0");
			DispatchKeyValue(iEntity, "InitialState", "1");
			DispatchKeyValue(iEntity, "Spreadspeed", "1");
			DispatchKeyValue(iEntity, "Speed", "250");
			DispatchKeyValue(iEntity, "Startsize", "6");
			DispatchKeyValue(iEntity, "EndSize", "8");
			DispatchKeyValue(iEntity, "Rate", "555");
			DispatchKeyValue(iEntity, "RenderColor", "255 100 10 41");
			DispatchKeyValue(iEntity, "JetLength", "40"); 
			DispatchKeyValue(iEntity, "RenderAmt", "180");
			DispatchSpawn(iEntity);
			SetVariantString(sName);
			AcceptEntityInput(iEntity, "SetParent", iEntity, iEntity );
			switch( iCount )
			{
				case 0:{ SetVariantString("rfoot"); vOrigin = view_as<float>({0.0, 0.0,  8.0}); }
				case 1:{ SetVariantString("lfoot"); vOrigin = view_as<float>({0.0, 0.0, -8.0}); }
			}
			AcceptEntityInput(iEntity, "SetParentAttachment");
			AcceptEntityInput(iEntity, "TurnOn");
			AcceptEntityInput(iEntity, "DisableCollision");
			SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);
			
			vAngles = view_as<float>({0.0, -180.0, 0.0});
			
			GetVectorAngles(vAngles, vAngles);
			
			TeleportEntity(iEntity, vOrigin, vAngles, NULL_VECTOR);
			
			SDKUnhook(iEntity, SDKHook_SetTransmit, SetTransmit);
			SDKHook(iEntity, SDKHook_SetTransmit, SetTransmit);

			g_iFlameRef[client][iCount] = EntIndexToEntRef(iEntity);
		}
	}
}

void RemoveFlame(int client)
{
	int entity; 
	
	for( int iCount = 0; iCount <= 1; iCount ++ )
	{
		entity= g_iFlameRef[client][iCount];
		g_iFlameRef[client][iCount] = 0;
		if( IsValidEntRef(entity) )
			RemoveEntity(entity);
	}
}

void PlaySound( int client, const float vPos[3] )
{
	StopSound( iArraySounds[client], SNDCHAN_WEAPON, "ambient/Spacial_Loops/CarFire_Loop.wav" );
	EmitSoundToAll( "ambient/Spacial_Loops/CarFire_Loop.wav", iArraySounds[client], SNDCHAN_WEAPON, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, vPos, NULL_VECTOR, true, 0.0 );
}

void SetParentCrown( int client )
{
	if( !bCvar_FlyingInfected_Crown ) 
		return;

	RemoveCrown(client);
	
	float vOrigin[3];
	float vAngles[3];
	
	char sColor[16];
	sColor = GetRandomClors();
	
	int iColor;
	iColor = GetColor( sColor );
	
	int iEntity;
	for( int iCount = 0; iCount <= 5; iCount ++ )
	{
		iEntity = CreateEntityByName("beam_spotlight");
		if( CheckIfEntitySafe( iEntity ) )
		{
			DispatchKeyValue(iEntity, "spawnflags", "3");
			DispatchKeyValue(iEntity, "HaloScale", "100"); 			// Tamaño de la aureola
			DispatchKeyValue(iEntity, "SpotlightWidth", "10");  	// Ancho de la luz
			DispatchKeyValue(iEntity, "SpotlightLength", "50"); 	// Longitud de la luz
			DispatchKeyValue(iEntity, "renderamt", "125");
			DispatchKeyValueFloat(iEntity, "HDRColorScale", 0.7);
			SetEntProp(iEntity, Prop_Send, "m_clrRender", iColor);
			
			DispatchSpawn(iEntity);
			
			SetVariantString("!activator");
			AcceptEntityInput(iEntity, "SetParent", client);
	
			switch( iCount )
			{				
				case 0: vAngles = view_as<float>({ -45.0, 60.0,  0.0 });
				case 1: vAngles = view_as<float>({ -45.0, 120.0, 0.0 });
				case 2: vAngles = view_as<float>({ -45.0, 180.0, 0.0 });
				case 3: vAngles = view_as<float>({ -45.0, 240.0, 0.0 });
				case 4: vAngles = view_as<float>({ -45.0, 300.0, 0.0 });
				case 5: vAngles = view_as<float>({ -45.0, 360.0, 0.0 });
			}
			
			vOrigin[2] = 95.0; 											// Altura
			
			AcceptEntityInput(iEntity, "Enable"); 				// No esencial
			AcceptEntityInput(iEntity, "DisableCollision"); 	// No esencial
			SetEntProp(iEntity, Prop_Send, "m_hOwnerEntity", client);
			
			AcceptEntityInput(iEntity, "TurnOn");
			
			TeleportEntity(iEntity, vOrigin, vAngles, NULL_VECTOR);

			g_iCrownRef[client][iCount] = EntIndexToEntRef(iEntity);
		}
	}
}

void RemoveCrown( int client )
{
	int entity; 
	
	for( int iCount = 0; iCount <= 5; iCount ++ )
	{
		entity= g_iCrownRef[client][iCount];
		g_iCrownRef[client][iCount] = 0;
		if( IsValidEntRef(entity) )
			RemoveEntity(entity);
	}
}

void SetParentLight( int client )
{
	if( !bCvar_FlyingInfected_JetPack_Light ) 
		return;

	RemoveLight(client);
	
	int iEntity = CreateEntityByName("light_dynamic");	
	if( CheckIfEntitySafe( iEntity ) )
	{
		DispatchKeyValue(iEntity, "inner_cone", "0");
		DispatchKeyValue(iEntity, "cone", "80");
		DispatchKeyValue(iEntity, "brightness", "6");
		DispatchKeyValueFloat(iEntity, "spotlight_radius", 240.0);
		DispatchKeyValueFloat(iEntity, "distance", 250.0);
		DispatchKeyValue(iEntity, "_light", "255 100 10 41"); // Orange
		DispatchKeyValue(iEntity, "pitch", "-90");
		DispatchKeyValue(iEntity, "style", "5");
		DispatchSpawn(iEntity);
		
		float vPosition[3], vAngleA[3], vAngleB[3], vForward[3], vOrigin[3];
		
		GetClientEyePosition( client, vPosition );
		GetClientEyeAngles( client, vAngleA );
		GetClientEyeAngles( client, vAngleB );

		vAngleB[0] = 0.0;
		vAngleB[2] = 0.0;
		GetAngleVectors( vAngleB, vForward, NULL_VECTOR, NULL_VECTOR );
		ScaleVector( vForward, -50.0 );
		vForward[2] = 0.0;
		AddVectors( vPosition, vForward, vOrigin );

		vAngleA[0] += 90.0;
		vOrigin[2] -= 120.0;
		TeleportEntity(iEntity, vOrigin, vAngleA, NULL_VECTOR);

		char sName[32];
		Format(sName, sizeof(sName), "Tank%d", client);
		DispatchKeyValue(client, "targetname", sName);
		
		DispatchKeyValue(iEntity, "parentname", sName);
		SetVariantString("!activator");
		AcceptEntityInput(iEntity, "SetParent", client );
		AcceptEntityInput(iEntity, "TurnOn");
		SetEntProp(iEntity, Prop_Send, "m_hOwnerEntity", client);

		g_iLightRef[client] = EntIndexToEntRef(iEntity);
	}
}

void RemoveLight( int client )
{
	int entity = g_iLightRef[client];
	g_iLightRef[client] = 0;
	if( IsValidEntRef(entity) )
		RemoveEntity(entity);
}

void StartGlowing( int entity )
{
	if( !entity || !g_bL4D2Version || !bCvar_FlyingInfected_glow ) 
		return;
	
	int RenderRGB[4];
	GetEntityRenderColor( entity, RenderRGB[0], RenderRGB[1], RenderRGB[2], RenderRGB[3] );
	
	SetEntProp( entity, Prop_Send, "m_iGlowType", 2 ); // 2 = Brillo visible solo si el objeto es visible, 3 = Brillo visible a traves de objetos.
	SetEntProp( entity, Prop_Send, "m_bFlashing", 1 );
	SetEntProp( entity, Prop_Send, "m_nGlowRange", 10000 );
	SetEntProp( entity, Prop_Send, "m_nGlowRangeMin", 100);
	SetEntProp( entity, Prop_Send, "m_glowColorOverride", RenderRGB[0] + ( RenderRGB[1] * 256 ) + ( RenderRGB[2] * 65536 ) );
//	AcceptEntityInput( entity, "StartGlowing" );
}

void StopGlowing( int entity )
{
	if( !entity || !g_bL4D2Version )
		return;
	
	SetEntProp( entity, Prop_Send, "m_iGlowType", 0 );
	SetEntProp( entity, Prop_Send, "m_bFlashing", 0 );
	SetEntProp( entity, Prop_Send, "m_nGlowRange",0 );
	SetEntProp( entity, Prop_Send, "m_glowColorOverride", 0 );
}

char[] GetRandomClors()
{
	char sColor[16];
	switch( GetRandomInt( 1, 12 ) ) // Best color selection.
	{
		case 1: Format( sColor, sizeof( sColor ), "255 0 0 255" ); 		// Red
		case 2: Format( sColor, sizeof( sColor ), "0 255 0 255" ); 		// Green
		case 3: Format( sColor, sizeof( sColor ), "0 0 255 255" ); 		// Blue
		case 4: Format( sColor, sizeof( sColor ), "100 0 150 255" ); 	// Purple
		case 5: Format( sColor, sizeof( sColor ), "255 155 0 255" ); 	// Orange
		case 6: Format( sColor, sizeof( sColor ), "255 255 0 255" ); 	// Yellow
		case 7: Format( sColor, sizeof( sColor ), "-1 -1 -1 255" ); 	// White
		case 8: Format( sColor, sizeof( sColor ), "255 0 150 255" ); 	// Pink
		case 9: Format( sColor, sizeof( sColor ), "0 255 255 255" ); 	// Cyan
		case 10:Format( sColor, sizeof( sColor ), "128 255 0 255" ); 	// Lime
		case 11:Format( sColor, sizeof( sColor ), "0 128 128 255" ); 	// Teal
		case 12:Format( sColor, sizeof( sColor ), "50 50 50 255" ); 	// Grey
	}
	
	return sColor; // Format( sColor, sizeof( sColor ), "%i %i %i 255", GetRandomInt( 0, 255 ), GetRandomInt( 0, 255 ), GetRandomInt( 0, 255 ) );
}

int GetColor( char[] sTemp ) // Converts an array to an integer value.
{
	char sColors[4][4];
	ExplodeString(sTemp, " ", sColors, sizeof sColors, sizeof sColors[]);

	int iColor;
	iColor = StringToInt(sColors[0]);
	iColor += 256 * StringToInt(sColors[1]);
	iColor += 65536 * StringToInt(sColors[2]);
	return iColor;
}

Action SetTransmit( int entity, int client )
{
	if( !IsValidClient( client ) )
		return Plugin_Stop;
	
	int iOwner = GetEntPropEnt( entity, Prop_Send, "m_hOwnerEntity" );
	if( iOwner == client && !IsTankThirdPerson( client ) && !IsFakeClient( client ) )
		return Plugin_Handled;

	return Plugin_Continue;
}

bool IsTankThirdPerson( int client )// from Mutan Tanks by Crasher_3637
{
	if( IsPlayerIncapped( client ) )
		return true;
	
	if((g_bL4D2Version && GetEntPropFloat(client, Prop_Send, "m_TimeForceExternalView" ) > GetGameTime() ) || 
	GetEntPropFloat( client, Prop_Send, "m_staggerTimer", 1 ) > -1.0 || 
	GetEntPropEnt( client, Prop_Send, "m_hViewEntity" ) > 0 )
		return true;

	if( IsTank( client ) )
	{
		switch( GetEntProp( client, Prop_Send, "m_nSequence" ) )
		{
			case 28, 29, 30, 31, 47, 48, 49, 50, 51, 73, 74, 75, 76, 77: return true;
		}
	}

	return false;
}

bool IsTank( int client )
{
	if( client > 0 && client <= MaxClients && IsClientInGame( client ) && GetClientTeam( client ) == 3 )
		if( GetEntProp( client, Prop_Send, "m_zombieClass" ) == ZC_TANK )
			return true;
	
	return false;
}

bool IsValidClient( int client )
{
	return client > 0 && client <= MaxClients && IsClientInGame( client ) && !IsClientInKickQueue( client );
}

bool IsAllowedPlugin()
{
	if( !bCvar_FlyingInfected_Enabled || !IsAllowedGameMode() || !IsAllowedMap() || !IsFinale() ) 
		return false;
	
	return true;
}

bool IsFinale()
{
	if( !bCvar_FlyingInfected_FinaleOnly || ( bCvar_FlyingInfected_FinaleOnly && bFinalEvent ) )
		return true;
	
	return false;
}

bool IsPlayerIncapped( int client )
{
	if( GetEntProp( client, Prop_Send, "m_isIncapacitated", 1 ) ) 
		return true;
		
	return false;
}

bool IsAllowedGameMode()
{
	if( hCvar_MPGameMode == null )
		return false;
	
	if( iCvar_GameModesToggle != 0 )
	{
		if( bMapStarted == false )
			return false;

		iCvar_CurrentMode = 0;

		int entity = CreateEntityByName("info_gamemode");
		if( CheckIfEntitySafe(entity) )
		{
			DispatchSpawn(entity);
			HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "PostSpawnActivate");
			if( IsValidEntity(entity) ) 	// Because sometimes "PostSpawnActivate" seems to kill the ent.
				RemoveEdict(entity); 		// Because multiple plugins creating at once, avoid too many duplicate ents in the same frame.
		}

		if( iCvar_CurrentMode == 0 )
			return false;

		if( !(iCvar_GameModesToggle & iCvar_CurrentMode) )
			return false;
	}
	
	char sGameMode[256], sGameModes[256];
	Format(sGameMode, sizeof(sGameMode), ",%s,", sCvar_MPGameMode);
	
	strcopy(sGameModes, sizeof(sCvar_GameModesOn), sCvar_GameModesOn);
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}
	
	strcopy(sGameModes, sizeof(sCvar_GameModesOff), sCvar_GameModesOff);
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

void OnGamemode(const char[] sOutput, int iCaller, int iActivator, float fDelay)
{
	if( strcmp(sOutput, "OnCoop") == 0 )
		iCvar_CurrentMode = 1;
	else if( strcmp(sOutput, "OnSurvival") == 0 )
		iCvar_CurrentMode = 2;
	else if( strcmp(sOutput, "OnVersus") == 0 )
		iCvar_CurrentMode = 4;
	else if( strcmp(sOutput, "OnScavenge") == 0 )
		iCvar_CurrentMode = 8;
}


bool IsAllowedMap()
{
	char sMap[256], sMaps[256];
	Format(sMap, sizeof(sMap), ",%s,", sCurrentMap);
	
	strcopy( sMaps, sizeof( sMaps ), sCvar_MapsOn );
	if( !StrEqual( sMaps, "", false ) )
	{
		Format( sMaps, sizeof( sMaps ), ",%s,", sMaps );
		if( StrContains( sMaps, sMap, false ) == -1 )
			return false;
	}
	
	strcopy( sMaps, sizeof( sMaps ), sCvar_MapsOff );
	if( !StrEqual( sMaps, "", false ) )
	{
		Format( sMaps, sizeof( sMaps ), ",%s,", sMaps );
		if( StrContains(sMaps, sMap, false) != -1 )
			return false;
	}
	
	return true;
}

void vCopyVector( const float vSource[3], float vTarget[3] )
{
	vTarget[0] = vSource[0];
	vTarget[1] = vSource[1];
	vTarget[2] = vSource[2];
}

void StopFly( int client )
{
	if( iArrayStatus[client] != STATE_FLY )
		return;
	
	iArrayStatus[client] = STATE_NONE;
	
	StopSound( iArraySounds[client], SNDCHAN_WEAPON, "ambient/Spacial_Loops/CarFire_Loop.wav" );
	
	SDKUnhook(client, SDKHook_PreThink, PreThink); 
	SDKUnhook(client, SDKHook_StartTouch, FlyTouch);
	
	SetEntityMoveType( client, MOVETYPE_WALK );
	SetEntityGravity( client, 1.0 );
	
	StopGlowing( client );
	RemoveModel( client );
	RemoveCrown( client );
	RemoveFlame( client );
	RemoveLight( client );
}

bool IsHandingFromLedge(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isHangingFromLedge") || GetEntProp(client, Prop_Send, "m_isFallingFromLedge"));
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

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}