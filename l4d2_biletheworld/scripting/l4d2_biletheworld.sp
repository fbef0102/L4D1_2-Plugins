// AtomicStryker, foxhound27, HarryPotter @ 2010-2022

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#define PLUGIN_VERSION 	"1.0h-2024/2/24"
#define PLUGIN_NAME		"l4d2_biletheworld"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "L4D2 Bile the World",
	author = "AtomicStryker, HarryPotter",
	description = "Vomit Jars hit Survivors, Boomer Explosions slime Infected",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=1237748"
}

int ZC_TANK;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	ZC_TANK = 8;
	return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define MAXENTITIES                   2048

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

#define ZC_SMOKER		1
#define ZC_BOOMER		2
#define ZC_HUNTER		3
#define ZC_SPITTER		4
#define ZC_JOCKEY		5
#define ZC_CHARGER		6

#define CI (1<<0) // 1
#define SI (1<<1) // 2
#define WITCH (1<<2) // 4
#define TANK (1<<3) // 8

#define STRINGLENGTH_CLASSES 64
#define L4D2_WEPID_VOMITJAR           25
#define CLASSNAME_VOMITJAR            "vomitjar_projectile"

static const char INFECTED_NAME[]	= "infected";
static const char WITCH_NAME[]		= "witch";

float TRACE_TOLERANCE = 25.0;
float BILE_POS_HEIGHT_FIX = 70.0;

ConVar g_hCvarEnable, 
	g_hCvarBoomerDeathType, g_hCvarBoomerDeath_Radius, 
	g_hCvarVomitJarSelf, g_hCvarVomitJarTeammate, g_hCvarVomitJar_Radius, g_hCvarVomitJar_TeammateHp;
bool g_bCvarEnable, g_bCvarVomitJarSelf, g_bCvarVomitJarTeammate;
int g_iCvarBoomerDeathType;
float g_fCvarBoomerDeath_Radius, g_fCvarVomitJar_Radius, g_fCvarVomitJar_TeammateHp;

static int    ge_iType[MAXENTITIES+1];

public void OnPluginStart()
{
	g_hCvarEnable 				= CreateConVar( PLUGIN_NAME ... "_enable",        		"1",   	"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarBoomerDeathType 		= CreateConVar( PLUGIN_NAME ... "_boomer_death_apply", 	"15", 	"Turn on Bile the World on Boomer Death to, 1=Common Infected, 2=S.I., 4=Witch, 8=Tank. Add numbers together (0=Disabe, 15=All)", FCVAR_NOTIFY, true, 0.0, true, 15.0); 
	g_hCvarBoomerDeath_Radius 	= CreateConVar( PLUGIN_NAME ... "_boomer_death_radius", "250", 	"Bile Range on Boomer Death.", FCVAR_NOTIFY, true, 0.0); 
	g_hCvarVomitJarSelf 		= CreateConVar( PLUGIN_NAME ... "_vomit_jar_self", 		"1", 	"If 1, Turn on Bile the World on Vomit Jar to self.", FCVAR_NOTIFY, true, 0.0, true, 1.0); 
	g_hCvarVomitJarTeammate 	= CreateConVar( PLUGIN_NAME ... "_vomit_jar_teammate", 	"1", 	"If 1, Turn on Bile the World on Vomit Jar to teammate.", FCVAR_NOTIFY, true, 0.0, true, 1.0); 
	g_hCvarVomitJar_Radius 		= CreateConVar( PLUGIN_NAME ... "_vomit_jar_radius", 	"150", 	"Bile Range on Vomit Jar.", FCVAR_NOTIFY, true, 0.0); 
	g_hCvarVomitJar_TeammateHp 	= CreateConVar( PLUGIN_NAME ... "_vomit_teammate_hp", 	"30", 	"How much hp reduce, if player throws Vomit Jar to survivors. (0=off)", FCVAR_NOTIFY, true, 0.0); 
	AutoExecConfig(true,                PLUGIN_NAME);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarBoomerDeathType.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarBoomerDeath_Radius.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarVomitJarSelf.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarVomitJarTeammate.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarVomitJar_Radius.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarVomitJar_TeammateHp.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_death", event_PlayerDeath);
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_iCvarBoomerDeathType = g_hCvarBoomerDeathType.IntValue;
	g_fCvarBoomerDeath_Radius = g_hCvarBoomerDeath_Radius.FloatValue;
	g_bCvarVomitJarSelf = g_hCvarVomitJarSelf.BoolValue;
	g_bCvarVomitJarTeammate = g_hCvarVomitJarTeammate.BoolValue;
	g_fCvarVomitJar_Radius = g_hCvarVomitJar_Radius.FloatValue;
	g_fCvarVomitJar_TeammateHp = g_hCvarVomitJar_TeammateHp.FloatValue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntityIndex(entity))
		return;

	if(g_bCvarVomitJarSelf == false && g_bCvarVomitJarTeammate == false) return;

	if (StrEqual(classname, CLASSNAME_VOMITJAR))
	{
		SDKHook(entity, SDKHook_SpawnPost, OnSpawnPost);
	}
}

void event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_bCvarEnable || g_iCvarBoomerDeathType == 0) return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || !IsClientInGame(client) || GetClientTeam(client) != TEAM_INFECTED || GetZombieClass(client) != ZC_BOOMER)
	{
		return;
	}
	
	float pos[3];
	GetEntityAbsOrigin(client, pos);

	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if (attacker && IsClientInGame(attacker) && GetClientTeam(attacker) == TEAM_SURVIVOR)
	{
		VomitSplash(true, pos, attacker);
	}
	else
	{
		VomitSplash(true, pos, client);
	}
}

void HurtEntity(int victim, int client, float damage)
{
	SDKHooks_TakeDamage(victim, client, client, damage, DMG_SLASH);
}

void OnSpawnPost(int entity)
{
	if( !IsValidEntity(entity) ) return;
	 
	int client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");

	if(client <= 0 || !IsClientInGame(client)) 
		return;
		
	ge_iType[entity] = GetClientUserId(client);
	//PrintToChatAll("OnSpawnPost() %N throws a bilejar", client);
}

public void OnEntityDestroyed(int entity)
{
	if (!IsValidEntityIndex(entity)) return;

	if(g_bCvarVomitJarSelf == false && g_bCvarVomitJarTeammate == false) return;

	char class[STRINGLENGTH_CLASSES];
	GetEntityClassname(entity, class, sizeof(class));
	
	switch (class[0])
	{
		case 'v':
		{
			if (strcmp(class, CLASSNAME_VOMITJAR) == 0)
			{
				float pos[3];
				GetEntityAbsOrigin(entity, pos);
				pos[2] += BILE_POS_HEIGHT_FIX;
				
				int client = ge_iType[entity];
				ge_iType[entity] = 0;
				client = GetClientOfUserId(client);

				//PrintToChatAll("OnEntityDestroyed() %N throws a bilejar", client);
				VomitSplash(false, pos, client);
			}
		}
	}
}

void VomitSplash(bool BoomerDeath, float pos[3], int client)
{		
	float targetpos[3];
	if(client <= 0 || client > MaxClients || !IsClientInGame(client)) client = 0;
	
	if (BoomerDeath)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (!IsClientInGame(i) || GetClientTeam(i) != TEAM_INFECTED || 
				!IsPlayerAlive(i) || L4D_IsPlayerGhost(i))
			{
				continue;
			}

			int class = GetZombieClass(i);
			//PrintToChatAll("%d %d", class, g_iCvarBoomerDeathType);
			if(class == ZC_TANK)
			{
				if(!(g_iCvarBoomerDeathType & TANK)) continue;
			}
			else
			{
				if(!(g_iCvarBoomerDeathType & SI)) continue;
			}
			
			GetEntityAbsOrigin(i, targetpos);
			if (GetVectorDistance(pos, targetpos) > g_fCvarBoomerDeath_Radius || !IsVisibleTo(pos, targetpos))
			{
				continue;
			}
			
			L4D2_CTerrorPlayer_OnHitByVomitJar(i, (client == 0) ? i : client);
		}

		if(client == 0) return;

		if(g_iCvarBoomerDeathType & WITCH)
		{
			int witch = -1;
			while((witch = FindEntityByClassname(witch, WITCH_NAME)) != -1)
			{
				if (!IsValidEntity(witch))
					continue;	

				GetEntityAbsOrigin(witch, targetpos);
				if (GetVectorDistance(pos, targetpos) > g_fCvarBoomerDeath_Radius || !IsVisibleTo(pos, targetpos))
				{
					continue;
				}
				
				L4D2_Infected_OnHitByVomitJar(witch, client);
			}
		}

		if(g_iCvarBoomerDeathType & CI)
		{
			int common = -1;
			while((common = FindEntityByClassname(common, INFECTED_NAME)) != -1)
			{
				if (!IsValidEntity(common))
					continue;	

				GetEntityAbsOrigin(common, targetpos);
				if (GetVectorDistance(pos, targetpos) > g_fCvarBoomerDeath_Radius || !IsVisibleTo(pos, targetpos))
				{
					continue;
				}
				
				L4D2_Infected_OnHitByVomitJar(common, client);
			}
		}
	}
	else
	{
		if(g_bCvarVomitJarSelf && client > 0 && GetClientTeam(client) == TEAM_SURVIVOR)
		{
			GetEntityAbsOrigin(client, targetpos);
			if (GetVectorDistance(pos, targetpos) <= g_fCvarVomitJar_Radius && IsVisibleTo(pos, targetpos))
			{
				L4D_CTerrorPlayer_OnVomitedUpon(client, client);
			}
		}
		
		if(g_bCvarVomitJarTeammate)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (i == client || !IsClientInGame(i) || GetClientTeam(i) != TEAM_SURVIVOR || !IsPlayerAlive(i))
				{
					continue;
				}
				
				GetEntityAbsOrigin(i, targetpos);
				if (GetVectorDistance(pos, targetpos) > g_fCvarVomitJar_Radius || !IsVisibleTo(pos, targetpos))
				{
					continue;
				}
				
				L4D_CTerrorPlayer_OnVomitedUpon(i, (client == 0) ? i : client);
				if(client > 0 && GetClientTeam(client) == TEAM_SURVIVOR) HurtEntity(client, client, g_fCvarVomitJar_TeammateHp);
			}
		}
	}
}

bool IsVisibleTo(float position[3], float targetposition[3])
{
	float vAngles[3], vLookAt[3];
	
	MakeVectorFromPoints(position, targetposition, vLookAt); // compute vector from start to target
	GetVectorAngles(vLookAt, vAngles); // get angles from vector for trace
	
	// execute Trace
	Handle trace = TR_TraceRayFilterEx(position, vAngles, MASK_SHOT, RayType_Infinite, _TraceFilter);
	bool isVisible = false;
	if (TR_DidHit(trace))
	{
		float vStart[3];
		TR_GetEndPosition(vStart, trace); // retrieve our trace endpoint
		
		if ((GetVectorDistance(position, vStart, false) + TRACE_TOLERANCE) >= GetVectorDistance(position, targetposition))
		{
			isVisible = true; // if trace ray lenght plus tolerance equal or bigger absolute distance, you hit the target
		}
	}
	else
	{
		LogError("Tracer Bug: Player-Zombie Trace did not hit anything, WTF");
		isVisible = true;
	}
	delete trace;
	return isVisible;
}

public bool _TraceFilter(int entity, int contentsMask)
{
	if (!entity || !IsValidEntity(entity)) // dont let WORLD, or invalid entities be hit
	{
		return false;
	}
	
	return true;
}

//entity abs origin code from here
//http://forums.alliedmods.net/showpost.php?s=e5dce96f11b8e938274902a8ad8e75e9&p=885168&postcount=3
void GetEntityAbsOrigin(int entity, float origin[3])
{
	if (entity && IsValidEntity(entity) && (GetEntSendPropOffs(entity, "m_vecOrigin") != -1) && (GetEntSendPropOffs(entity, "m_vecMins") != -1) && (GetEntSendPropOffs(entity, "m_vecMaxs") != -1))
	{
		float mins[3], maxs[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
		GetEntPropVector(entity, Prop_Send, "m_vecMins", mins);
		GetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs);
		
		origin[0] += (mins[0] + maxs[0]) * 0.5;
		origin[1] += (mins[1] + maxs[1]) * 0.5;
		origin[2] += (mins[2] + maxs[2]) * 0.5;
	}
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

int GetZombieClass(int client) 
{
	return GetEntProp(client, Prop_Send, "m_zombieClass");
}