//BHaType @ 2019~2022
//Shadowysn @ 2022 - No Gamedata Required
//Harry @ 2022-2024 - Can't use attack1 and attack2 for short time after release victim!!

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>

#define PLUGIN_VERSION			"1.4h-2025/1/13"
#define PLUGIN_NAME			    "l4d2_release_victim"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "[L4D1/2] Release Victim Extended version",
	author = "BHaType, HarryPotter",
	description = "Allow to release victim",
	version = PLUGIN_VERSION
};

bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead )
	{
		g_bL4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		g_bL4D2Version = true;
	}
	else
	{
		Format(error, err_max, "Plugin only supports Left4Dead 2.");
		return APLRes_Failure;
	}
	

	return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

bool g_bReset, g_bEffect;
int g_iZombieClass, g_iVelocity;

ConVar z_charge_interval, z_jockey_leap_again_timer, tongue_hit_delay;
float g_flCharger, g_flSmoker, g_flJockey;

ConVar g_hCvarEnable, g_hCvarFly, sm_release_distance, sm_release_height, sm_release_ability_reset, sm_release_effect,
	g_hCvarJockeyRelease, g_hCvarHunterRelease, g_hCvarChargerRelease, g_hCvarSmokerRelease,
	g_hCvarJockeyAttackDelay, g_hCvarHunterAttackDelay, g_hCvarChargerAttackDelay, g_hCvarSmokerAttackDelay,
	g_hCvarReleaseDelay, g_hCvarAnnounceType;
bool g_bCvarEnable, g_bCvarFly,
	g_bCvarJockeyRelease, g_bCvarHunterRelease, g_bCvarChargerRelease, g_bCvarSmokerRelease;
float g_flDistance, g_flHeight,
	g_fJockeyAttackDelay, g_fHunterAttackDelay, g_fChargerAttackDelay, g_fSmokerAttackDelay,
	g_fConVar_ReleaseDelay;

int g_iCvarAnnounceType;

float 
	g_fButtonDelay[MAXPLAYERS+1],
	g_fReleaseDelay[MAXPLAYERS+1];

#define ZC_SMOKER		1
#define ZC_BOOMER		2
#define ZC_HUNTER		3
#define ZC_SPITTER		4
#define ZC_JOCKEY		5
#define ZC_CHARGER		6

public void OnPluginStart()
{
	LoadTranslations("l4d2_release_victim.phrases");

	if(g_bL4D2Version)
	{
		z_charge_interval = FindConVar("z_charge_interval");
		z_jockey_leap_again_timer = FindConVar("z_jockey_leap_again_timer");
	}
	tongue_hit_delay = FindConVar("tongue_hit_delay");

	GetOfficialCvars();
	if(g_bL4D2Version)
	{
		z_charge_interval.AddChangeHook(OnConVarChanged_Official);
		z_jockey_leap_again_timer.AddChangeHook(OnConVarChanged_Official);
	}
	tongue_hit_delay.AddChangeHook(OnConVarChanged_Official);

	g_hCvarEnable 					= CreateConVar( PLUGIN_NAME ... "_enable",        		"1",   		"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarFly						= CreateConVar( PLUGIN_NAME ... "_fly",        			"1",   		"If 1, Infected player fly away when release victim", CVAR_FLAGS, true, 0.0, true, 1.0);
	sm_release_distance 			= CreateConVar( PLUGIN_NAME ... "_distance", 			"900.0", 	"Release distance", CVAR_FLAGS, true, 0.0);
	sm_release_height 				= CreateConVar( PLUGIN_NAME ... "_height", 				"600.0", 	"Release height", CVAR_FLAGS, true, 0.0);
	sm_release_ability_reset 		= CreateConVar( PLUGIN_NAME ... "_ability_reset", 		"1", 		"If 1, Reset ability", CVAR_FLAGS, true, 0.0, true, 1.0);
	if(g_bL4D2Version)
	{
		sm_release_effect 				= CreateConVar( PLUGIN_NAME ... "_effect", 				"1", 		"If 1, Show effect after release", CVAR_FLAGS, true, 0.0, true, 1.0);
		g_hCvarJockeyRelease			= CreateConVar( PLUGIN_NAME ... "_jockey_yes", 				"1", 		"If 1, Jockey can release victim (0=Can't)", CVAR_FLAGS, true, 0.0, true, 1.0);
		g_hCvarChargerRelease			= CreateConVar( PLUGIN_NAME ... "_charger_yes", 			"1", 		"If 1, Charger can release victim (0=Can't)", CVAR_FLAGS, true, 0.0, true, 1.0);
		g_hCvarJockeyAttackDelay 		= CreateConVar( PLUGIN_NAME ... "_jockey_attack_delay", 	"6.0", 		"After dismounting with the jockey, how long the player can not use attack1/attack2 (0=Off)", CVAR_FLAGS, true, 0.0);
		g_hCvarChargerAttackDelay 		= CreateConVar( PLUGIN_NAME ... "_charger_attack_delay", 	"6.0", 		"After dismounting with the charger, how long the player can not use attack1/attack2 (0=Off)", CVAR_FLAGS, true, 0.0);
	}
	g_hCvarHunterRelease			= CreateConVar( PLUGIN_NAME ... "_hunter_yes", 				"1", 		"If 1, Hunter can release victim (0=Can't)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarSmokerRelease			= CreateConVar( PLUGIN_NAME ... "_smoker_yes", 				"1", 		"If 1, Smoker can release victim (0=Can't)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarHunterAttackDelay 		= CreateConVar( PLUGIN_NAME ... "_hunter_attack_delay", 	"6.0", 		"After dismounting with the hunter, how long the player can not use attack1/attack2 (0=Off)", CVAR_FLAGS, true, 0.0);
	g_hCvarSmokerAttackDelay 		= CreateConVar( PLUGIN_NAME ... "_smoker_attack_delay", 	"10.0", 	"After dismounting with the smoker, how long the player can not use attack1/attack2 (0=Off)", CVAR_FLAGS, true, 0.0);
	g_hCvarReleaseDelay 			= CreateConVar( PLUGIN_NAME ... "_release_delay", 			"1.5", 		"How long can the infected player releases victim after pinned the survivor", CVAR_FLAGS, true, 0.0);
	g_hCvarAnnounceType 			= CreateConVar( PLUGIN_NAME ... "_announce_type", 			"1", 		"Changes how message displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", CVAR_FLAGS, true, 0.0, true, 3.0);
	CreateConVar(                       			PLUGIN_NAME ... "_version",       			PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true, 							PLUGIN_NAME);
	
	GetCvars();
	g_hCvarEnable.AddChangeHook(OnConVarChanged);
	g_hCvarFly.AddChangeHook(OnConVarChanged);
	sm_release_ability_reset.AddChangeHook(OnConVarChanged);
	sm_release_distance.AddChangeHook(OnConVarChanged);
	sm_release_height.AddChangeHook(OnConVarChanged);
	if(g_bL4D2Version)
	{
		sm_release_effect.AddChangeHook(OnConVarChanged);
		g_hCvarJockeyRelease.AddChangeHook(OnConVarChanged);
		g_hCvarChargerRelease.AddChangeHook(OnConVarChanged);
		g_hCvarJockeyAttackDelay.AddChangeHook(OnConVarChanged);
		g_hCvarChargerAttackDelay.AddChangeHook(OnConVarChanged);
	}
	g_hCvarHunterRelease.AddChangeHook(OnConVarChanged);
	g_hCvarSmokerRelease.AddChangeHook(OnConVarChanged);
	g_hCvarHunterAttackDelay.AddChangeHook(OnConVarChanged);
	g_hCvarSmokerAttackDelay.AddChangeHook(OnConVarChanged);
	g_hCvarReleaseDelay.AddChangeHook(OnConVarChanged);
	g_hCvarAnnounceType.AddChangeHook(OnConVarChanged);
	
	g_iZombieClass = FindSendPropInfo("CTerrorPlayer", "m_zombieClass");
	g_iVelocity = FindSendPropInfo("CBasePlayer", "m_vecVelocity[0]");
	
	HookEvent("round_start", 			evtRoundStart);
	HookEvent("jockey_ride", 			Infected_Capped);
	HookEvent("charger_pummel_start", 	Infected_Capped);
	HookEvent("lunge_pounce", 			Infected_Capped);
	HookEvent("tongue_grab", 			Infected_Capped);
	HookEvent("player_spawn",           Event_PlayerSpawn);
}

public void OnMapStart()
{
	if(g_bL4D2Version) PrecacheParticle("gen_hit1_c");
}

void OnConVarChanged_Official(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetOfficialCvars();
}

void OnConVarChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetOfficialCvars()
{
	if(g_bL4D2Version)
	{
		g_flCharger = z_charge_interval.FloatValue;
		g_flJockey = z_jockey_leap_again_timer.FloatValue;
	}

	g_flSmoker = tongue_hit_delay.FloatValue;
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarFly = g_hCvarFly.BoolValue;
	g_flDistance = sm_release_distance.FloatValue;
	g_flHeight = sm_release_height.FloatValue;
	g_bReset = sm_release_ability_reset.BoolValue;

	if(g_bL4D2Version)
	{
		g_bEffect = sm_release_effect.BoolValue;
		g_bCvarJockeyRelease = g_hCvarJockeyRelease.BoolValue;
		g_bCvarChargerRelease = g_hCvarChargerRelease.BoolValue;
		g_fJockeyAttackDelay = g_hCvarJockeyAttackDelay.FloatValue;
		g_fChargerAttackDelay = g_hCvarChargerAttackDelay.FloatValue;
	}
	g_bCvarHunterRelease = g_hCvarHunterRelease.BoolValue;
	g_bCvarSmokerRelease = g_hCvarSmokerRelease.BoolValue;
	g_fHunterAttackDelay = g_hCvarHunterAttackDelay.FloatValue;
	g_fSmokerAttackDelay = g_hCvarSmokerAttackDelay.FloatValue;
	g_fConVar_ReleaseDelay = g_hCvarReleaseDelay.FloatValue;
	g_iCvarAnnounceType = g_hCvarAnnounceType.IntValue;
}

void evtRoundStart(Event event, const char[] name, bool dontbroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		g_fButtonDelay[i] = 0.0;
	}
}

void Infected_Capped(Event event, const char[] name, bool dontbroadcast)
{
	int attacker = GetClientOfUserId(event.GetInt("userid"));
	if(attacker && IsClientInGame(attacker)) 
		g_fReleaseDelay[attacker] = GetEngineTime() + g_fConVar_ReleaseDelay;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client && IsClientInGame(client)) 
		g_fButtonDelay[client] = 0.0;
}

public Action OnPlayerRunCmd (int client, int &buttons)
{
	if (!g_bCvarEnable)
		return Plugin_Continue;

	if (IsFakeClient(client) || GetClientTeam(client) != 3 || !IsPlayerAlive(client))
		return Plugin_Continue;

	if(g_fReleaseDelay[client] > GetEngineTime())
		return Plugin_Continue;

	if(g_fButtonDelay[client] - GetEngineTime() > 0.0)
	{
		if (buttons & IN_ATTACK) buttons &= ~IN_ATTACK;
		if (buttons & IN_ATTACK2) buttons &= ~IN_ATTACK2;
		if (buttons & IN_USE) buttons &= ~IN_USE;
		return Plugin_Continue;
	}

	if(!(buttons & IN_ATTACK2)) return Plugin_Continue;
	
	int iClass = GetEntData(client, g_iZombieClass), victim;
	
	if(g_bL4D2Version)
	{
		switch (iClass)
		{
			case ZC_CHARGER: 
			{
				if(g_bCvarChargerRelease == false) return Plugin_Continue;

				victim = L4D_GetVictimCharger(client);
			}
			case ZC_HUNTER: 
			{
				if(g_bCvarHunterRelease == false) return Plugin_Continue;

				victim = L4D_GetVictimHunter(client);
			}
			case ZC_JOCKEY:
			{
				if(g_bCvarJockeyRelease == false) return Plugin_Continue;

				victim = L4D_GetVictimJockey(client);
			}
			case ZC_SMOKER: 
			{
				if(g_bCvarSmokerRelease == false) return Plugin_Continue;

				victim = L4D_GetVictimSmoker(client);
			}
			default:
			{
				return Plugin_Continue;
			}
		}
	}
	else
	{
		switch (iClass)
		{
			case ZC_HUNTER: 
			{
				if(g_bCvarHunterRelease == false) return Plugin_Continue;

				victim = L4D_GetVictimHunter(client);
			}
			case ZC_SMOKER: 
			{
				if(g_bCvarSmokerRelease == false) return Plugin_Continue;

				victim = L4D_GetVictimSmoker(client);
			}
			default:
			{
				return Plugin_Continue;
			}
		}
	}

	if(victim <= 0) return Plugin_Continue;
	
	Release(client, victim, iClass);

	if (buttons & IN_ATTACK) buttons &= ~IN_ATTACK;
	if (buttons & IN_ATTACK2) buttons &= ~IN_ATTACK2;
	if (buttons & IN_USE) buttons &= ~IN_USE;

	return Plugin_Continue;
}

void Release (int client, int victim, int iClass)
{
	if(g_bL4D2Version)
	{
		switch (iClass)
		{
			case ZC_CHARGER: 
			{
				L4D2_Charger_EndPummel(victim, client);
				L4D_StopMusic(client, "Event.ChargerSlam");

				// left4dhooks error bug
				SetEntPropEnt(client, Prop_Send, "m_pummelVictim", -1);
				SetEntPropEnt(victim, Prop_Send, "m_pummelAttacker", -1);
			}
			case ZC_HUNTER:
			{
				L4D_Hunter_ReleaseVictim(victim, client);
			}
			case ZC_JOCKEY:
			{
				L4D2_Jockey_EndRide(victim, client);
			}
			case ZC_SMOKER: 
			{
				L4D_Smoker_ReleaseVictim(victim, client);
			}
			default:
			{
				return;
			}
		}
	}
	else
	{
		switch (iClass)
		{
			case ZC_HUNTER:
			{
				L4D_Hunter_ReleaseVictim(victim, client);
			}
			case ZC_SMOKER: 
			{
				L4D_Smoker_ReleaseVictim(victim, client);
			}
			default:
			{
				return;
			}
		}
	}
	
	float vOrigin[3];
	GetClientAbsOrigin(client, vOrigin);
	vOrigin[2] += 5.0;
	
	if ( g_bL4D2Version && g_bEffect )
		SpoofEffect(vOrigin);
	
	if ( g_bCvarFly && (g_flDistance > 0 || g_flHeight > 0) )
		CreateTimer(0.05, tFly, GetClientUserId(client));
		
	CreateTimer(0.2, tReset, GetClientUserId(client)); 

	float fDelay = 0.0;
	if(g_bL4D2Version)
	{
		switch (iClass)
		{
			case ZC_CHARGER:
			{
				fDelay = g_fChargerAttackDelay;
			}
			case ZC_HUNTER: 
			{
				fDelay = g_fHunterAttackDelay;
			}
			case ZC_JOCKEY: 
			{
				fDelay = g_fJockeyAttackDelay;
			}
			case ZC_SMOKER: 
			{
				fDelay = g_fSmokerAttackDelay;
			}
		}
	}
	else
	{
		switch (iClass)
		{
			case ZC_HUNTER: 
			{
				fDelay = g_fHunterAttackDelay;
			}
			case ZC_SMOKER: 
			{
				fDelay = g_fSmokerAttackDelay;
			}
		}
	}

	if(fDelay > 0.0)
	{
		g_fButtonDelay[client] = GetEngineTime() + fDelay;
		switch(g_iCvarAnnounceType)
		{
			case 1:{
				CPrintToChat(client, "%T", "Release (C)", client, fDelay);
			}
			case 2:{
				PrintHintText(client, "%T", "Release", client, fDelay);
			}
			case 3:{
				PrintCenterText(client, "%T", "Release", client, fDelay);
			}
		}
	}
}

Action tFly (Handle timer, int client)
{
	if ((client = GetClientOfUserId(client)) == 0 || !IsClientInGame(client))
		return Plugin_Continue;
	
	float vAngles[3], vDirection[3], vCurrent[3], vResult[3];
	
	GetClientEyeAngles(client, vAngles);
	
	GetAngleVectors(vAngles, vDirection, NULL_VECTOR, NULL_VECTOR);
	ScaleVector(vDirection, g_flDistance);
	GetEntDataVector(client, g_iVelocity, vCurrent);
	
	vResult[0] = vCurrent[0] + vDirection[0];
	vResult[1] = vCurrent[1] + vDirection[1];
	vResult[2] = g_flHeight;
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vResult);
	
	CreateTimer(0.2, tReset, GetClientUserId(client));
	return Plugin_Continue;
}

Action tReset (Handle timer, int client)
{
	if ((client = GetClientOfUserId(client)) == 0 || !IsClientInGame(client))
		return Plugin_Continue;
	
	if (g_bReset)
	{
		int iEntity = GetEntPropEnt(client, Prop_Send, "m_customAbility");
		
		if (iEntity > MaxClients)
		{
			if(g_bL4D2Version)
			{
				switch (GetEntData(client, g_iZombieClass))
				{
					case ZC_CHARGER: SetDTCountdownTimer(iEntity, g_flCharger);
					case ZC_JOCKEY: SetDTCountdownTimer(iEntity, g_flJockey);
					case ZC_SMOKER: SetDTCountdownTimer(iEntity, g_flSmoker);
				}
			}	
			else
			{
				switch (GetEntData(client, g_iZombieClass))
				{
					case ZC_SMOKER: SetDTCountdownTimer(iEntity, g_flSmoker);
				}
			}
		}
	}
	return Plugin_Continue;
}

void SetDTCountdownTimer(int entity, float duration)
{
	SetEntPropFloat(entity, Prop_Send, "m_nextActivationTimer", duration, 0);
	SetEntPropFloat(entity, Prop_Send, "m_nextActivationTimer", GetGameTime()+duration, 1);
}

void SpoofEffect(float vOrigin[3])
{
	int entity = CreateEntityByName("info_particle_system");
	
	if (entity == -1)
	{
		LogError("Invalid entity");
		return;
	}
	
	DispatchKeyValue(entity, "effect_name", "gen_hit1_c");
	//fireworks_flare_trail_01
	TeleportEntity(entity, vOrigin, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(entity);
	ActivateEntity(entity);

	AcceptEntityInput(entity, "start");
	
	SetVariantString("OnUser1 !self:Kill::4.0:1");
	AcceptEntityInput(entity, "AddOutput");
	AcceptEntityInput(entity, "FireUser1");
}

void PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}

	if( FindStringIndex(table, sEffectName) == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
	}
}