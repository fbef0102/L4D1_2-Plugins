
#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <left4dhooks>

public Plugin myinfo = 
{
	name = "Meteor Hunter",
	author = "Spirit, Harry",
	description = "high pounces cause meteor strike",
	version = "1.5",
	url = "https://forums.alliedmods.net/showthread.php?p=2712447"
}

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

#define MODEL_CONCRETE_CHUNK         "models/props_debris/concrete_chunk01a.mdl"
#define EXPLOSION_PARTICLE "gas_explosion_initialburst_smoke"
#define EXPLOSION_PARTICLE2 "gas_explosion_chunks_02"
#define EXPLOSION_PARTICLE3 "weapon_grenade_explosion"
#define CVAR_FLAGS			FCVAR_NOTIFY
#define CLASSNAME_LENGTH 	64

ConVar g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarDistance, g_hCvarRange, g_hCvarDamage,
	g_hCvarPower, g_hCvarZMult;
ConVar g_hCvarMPGameMode;

bool g_bCvarAllow, g_bMapStarted;
float g_fRange, g_fDamage, g_fDistance, g_fCvarPower, g_fCvarZMult;
static const float L4D_Z_MULT = 1.6;

public void OnPluginStart()
{
	g_hCvarAllow = CreateConVar("l4d_meteor_hunter_allow", "1", "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarModes =	CreateConVar("l4d_meteor_hunter_modes",	"",	"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff = CreateConVar("l4d_meteor_hunter_modes_off",	"",	"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog = CreateConVar("l4d_meteor_hunter_modes_tog",   "0", "Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hCvarDistance  = CreateConVar("l4d_meteor_hunter_distance", "800", "Hunter Pounce Distance needed to trigger meteor strike.", CVAR_FLAGS, true, 0.0);
	g_hCvarRange = CreateConVar("l4d_meteor_hunter_range", "200", "Hunter meteor strike range.", CVAR_FLAGS, true, 0.0);
	g_hCvarDamage = CreateConVar("l4d_meteor_hunter_damage", "15.0", "Damage caused by meteor strike.", CVAR_FLAGS, true, 0.0);
	g_hCvarPower = CreateConVar("l4d_meteor_hunter_power", "300", "How much force is applied to the survivor (meteor strike).", FCVAR_NOTIFY, true, 0.0);
	g_hCvarZMult = CreateConVar("l4d_meteor_hunter_vertical_mult", "1.5", "Vertical force multiplier (meteor strike).", FCVAR_NOTIFY, true, 0.0);

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarDistance.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarRange.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDamage.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarPower.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarZMult.AddChangeHook(ConVarChanged_Cvars);

	//Autoconfig for plugin
	AutoExecConfig(true, "l4d_meteor_hunter");
}

public void OnMapStart()
{
	g_bMapStarted = true;

	PrecacheParticle(EXPLOSION_PARTICLE);
	PrecacheParticle(EXPLOSION_PARTICLE2);
	PrecacheParticle(EXPLOSION_PARTICLE3);

	PrecacheSound("ambient/explosions/explode_1.wav", true);
	PrecacheSound("ambient/explosions/explode_2.wav", true);
	PrecacheSound("ambient/explosions/explode_3.wav", true);
	PrecacheSound("weapons/hegrenade/explode3.wav", true);
	PrecacheSound("weapons/hegrenade/explode5.wav", true);
}

public void OnMapEnd()
{
	g_bMapStarted = false;
}

// ====================================================================================================
//					CVARS
// ====================================================================================================
public void ConVarChanged_Allow(ConVar convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_fDistance = g_hCvarDistance.FloatValue;
	g_fRange = g_hCvarRange.FloatValue;
	g_fDamage = g_hCvarDamage.FloatValue;
	g_fCvarPower = g_hCvarPower.FloatValue;
	g_fCvarZMult = g_hCvarZMult.FloatValue;
}
public void OnConfigsExecuted()
{
	IsAllowed();
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		g_bCvarAllow = true;
		HookEvent("lunge_pounce", Event_LandedPounce);
	}
	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		g_bCvarAllow = false;
		UnhookEvent("lunge_pounce", Event_LandedPounce);
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_bMapStarted == false )
		return false;

	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
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

	if( iCvarModesTog != 0 )
	{
		if( g_iCurrentMode == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentMode) )
			return false;
	}

	char sGameModes[CLASSNAME_LENGTH], sGameMode[CLASSNAME_LENGTH];
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

// Event
public void Event_LandedPounce(Event hEvent, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	float distance = hEvent.GetFloat("distance");
	int victim = GetClientOfUserId(hEvent.GetInt("victim"));
	if(client > 0 && IsClientInGame(client))
	{
		if(distance > g_fDistance)
		{
			CreateHit(client);
			CreateForces(client, victim);
			CPrintToChatAll("[{olive}TS{default}] {red}%N{default}'s {green}high pounce{default} causes meteor impacts!!!", client);
		}
	}
}

//function
void CreateHit(int client)
{	
	float pos[3];
	GetClientAbsOrigin(client,pos);

	CreateParticles(pos);
	
	DataPack hbPack;
	CreateDataTimer(0.5, CreateRing, hbPack,TIMER_FLAG_NO_MAPCHANGE);
	WritePackFloat(hbPack, 120.0);
	WritePackFloat(hbPack, pos[0]);
	WritePackFloat(hbPack, pos[1]);
	WritePackFloat(hbPack, pos[2]);
}

void CreateParticles(float pos[3])
{
	int exParticle = CreateEntityByName("info_particle_system");
	if (IsValidEntity(exParticle) )
	{
		DispatchKeyValue(exParticle, "effect_name", EXPLOSION_PARTICLE);
		DispatchSpawn(exParticle);
		ActivateEntity(exParticle);
		TeleportEntity(exParticle, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(exParticle, "Start");
		CreateTimer(3.0, TimerDeleteRock, EntIndexToEntRef(exParticle), TIMER_FLAG_NO_MAPCHANGE);
	}
		
	int exParticle2 = CreateEntityByName("info_particle_system");
	if (IsValidEntity(exParticle2) )
	{
		DispatchKeyValue(exParticle2, "effect_name", EXPLOSION_PARTICLE2);
		DispatchSpawn(exParticle2);
		ActivateEntity(exParticle2);
		TeleportEntity(exParticle2, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(exParticle2, "Start");
		CreateTimer(3.0, TimerDeleteRock, EntIndexToEntRef(exParticle2), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	int exParticle3 = CreateEntityByName("info_particle_system");
	if (IsValidEntity(exParticle3) )
	{
		DispatchKeyValue(exParticle3, "effect_name", EXPLOSION_PARTICLE);
		DispatchSpawn(exParticle3);
		ActivateEntity(exParticle3);
		TeleportEntity(exParticle3, pos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(exParticle3, "Start");
		CreateTimer(3.0, TimerDeleteRock, EntIndexToEntRef(exParticle3), TIMER_FLAG_NO_MAPCHANGE);
	}
}	

public Action CreateRing(Handle hTimer,Handle hPack)
{
	float nPos[3];
	float rad;
	
	ResetPack(hPack);
	rad = ReadPackFloat(hPack);
	nPos[0] = ReadPackFloat(hPack);
	nPos[1] = ReadPackFloat(hPack);
	nPos[2] = ReadPackFloat(hPack);

	float direction[3];
	float Ang[3] = {0.0};
	float rockpos[3];	
	
	for (int i = 1; i <= 10; i++)
	{
		Ang[1] = Ang[1]+(i*36);

		GetAngleVectors(Ang, direction, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(direction, rad);
		AddVectors(nPos, direction, rockpos);
		CreateRock(rockpos);
	}

	return Plugin_Continue;
}

public Action TimerDeleteRock(Handle hTimer, int ref)
{	
	if(ref && EntRefToEntIndex(ref) != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(ref, "kill");
	}

	return Plugin_Continue;
}

void CreateRock(float Rpos[3])
{
	int rock = -1;
	rock = CreateEntityByName ("prop_dynamic"); 
	if(rock == -1)
		return;

	SetEntityModel (rock,MODEL_CONCRETE_CHUNK);
	DispatchSpawn(rock);
	float ang[3];
	ang[0] = float(GetRandomInt(0,360));
	ang[1] = float(GetRandomInt(0,360));
	ang[2] = float(GetRandomInt(0,360));
	TeleportEntity(rock, Rpos, ang, NULL_VECTOR);
	CreateTimer(5.0, TimerDeleteRock, EntIndexToEntRef(rock), TIMER_FLAG_NO_MAPCHANGE);
}

public bool TraceFilter(int entity, int contentsMask, any client)
{
	if( entity == client )return false;
	return true;
}
stock bool IsHunter(int client)
{
    if (GetEntProp(client, Prop_Send, "m_zombieClass") == 3) return true;
    return false;
}

void CreateForces(int client, int victim)
{
	char sound[64];
	switch(GetRandomInt(1, 5))
	{
		case 1 : Format(sound, sizeof(sound), "ambient/explosions/explode_1.wav");
		case 2 : Format(sound, sizeof(sound), "ambient/explosions/explode_2.wav");
		case 3 : Format(sound, sizeof(sound), "ambient/explosions/explode_3.wav");
		case 4 : Format(sound, sizeof(sound), "weapons/hegrenade/explode3.wav");
		case 5 : Format(sound, sizeof(sound), "weapons/hegrenade/explode5.wav");
	}
	EmitSoundToClient(client,sound, client, 3);
	EmitSoundToClient(victim,sound, victim, 3);

	float hunterPos[3], targetpos[3], dist, HeadingVector[3], resulting[3];
	GetClientAbsOrigin(client, hunterPos);
	for (int i = 1; i <= MaxClients; i++)//for each client
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 && i != victim && IsSurvivorPinned(i) == false)
		{
			GetClientAbsOrigin(i, targetpos);
			
			dist = GetVectorDistance(hunterPos, targetpos);
			if ( dist <= g_fRange )
			{
				GetClientEyeAngles(client, HeadingVector);
				GetEntPropVector(i, Prop_Data, "m_vecVelocity", resulting);

				resulting[0] += Cosine(DegToRad(HeadingVector[1])) * g_fCvarPower;
				resulting[1] += Sine(DegToRad(HeadingVector[1])) * g_fCvarPower;
				resulting[2] = g_fCvarPower * g_fCvarZMult;

				if (L4D2Version == false){
					resulting[2] *= L4D_Z_MULT;
					TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, resulting);
				}
				else {
					L4D2_CTerrorPlayer_Fling(i, client, resulting);
				}
				HurtEntity(i, client, g_fDamage);
				EmitSoundToClient(i,sound, i, 3);
			}
		}
	}
}


int PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}

	int index = FindStringIndex(table, sEffectName);
	if( index == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
		index = FindStringIndex(table, sEffectName);
	}

	return index;
}

stock void HurtEntity(int victim, int client, float damage)
{
	SDKHooks_TakeDamage(victim, client, client, damage, DMG_SLASH);
}

bool IsSurvivorPinned(int client)
{
	int attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
	int attacker2 = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
	int attacker3 = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
	int attacker4 = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
	int attacker5 = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
	if ((attacker > 0 && attacker != client) || (attacker2 > 0 && attacker2 != client) || (attacker3 > 0 && attacker3 != client) || (attacker4 > 0 && attacker4 != client) || (attacker5 > 0 && attacker5 != client))
	{
		return true;
	}
	return false;
}