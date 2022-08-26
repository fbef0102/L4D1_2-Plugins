#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.3"

public Plugin myinfo =
{
	name = "Block Rocket Jump Exploit",
	author = "DJ_WEST, HarryPotter",
	description = "Block rocket jump exploit (with grenade launcher/vomitjar/pipebomb/molotov/common/spit/rock/witch)",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=122371"
}

bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	if( test == Engine_Left4Dead)
		g_bL4D2Version = false;
	else if (test == Engine_Left4Dead2 )
		g_bL4D2Version = true;
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("block_rocketjump_version", PLUGIN_VERSION, "Block Rocket Jump Exploit version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
}

bool g_bConfigLoaded;
public void OnMapEnd()
{
    g_bConfigLoaded = false;
}

public void OnConfigsExecuted()
{
    g_bConfigLoaded = true;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!g_bConfigLoaded)
		return;

	if (!IsValidEntityIndex(entity))
		return;

	switch (classname[0])
	{
		case 'i', // infected
				'm', // molotov_projectile
				'p', // pipe_bomb_projectile
				't', // tank_rock
				'v', // vomitjar_projectile
				'g', // grenade_launcher_projectile
				's', // spitter_projectile
				'w': // witch
		{
			if (strcmp(classname, "infected") == 0 ||
				strcmp(classname, "molotov_projectile") == 0 ||
				strcmp(classname, "pipe_bomb_projectile") == 0 ||
				strcmp(classname, "tank_rock") == 0 ||
				strcmp(classname, "witch") == 0 ||
				(g_bL4D2Version && (strcmp(classname, "vomitjar_projectile") == 0 ||
									strcmp(classname, "grenade_launcher_projectile") == 0 ||
									strcmp(classname, "spitter_projectile") == 0)) )
			{
				SDKHook(entity, SDKHook_SpawnPost, SpawnPost);
			}						
		}
	}
}

public void SpawnPost(int entity)
{
    RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
}

public void OnNextFrame(int entityRef)
{
	int entity = EntRefToEntIndex(entityRef);

	if (entity == INVALID_ENT_REFERENCE)
		return;

	SDKHook(entity, SDKHook_TouchPost, OnEntityTouchPost);
}

float f_Velocity[3];
public void OnEntityTouchPost(int entity, int i_Touched)
{
	if (1 <= i_Touched <= MaxClients && IsClientInGame(i_Touched) && IsPlayerAlive(i_Touched))
	{
		if (GetEntPropEnt(i_Touched, Prop_Data, "m_hGroundEntity") == entity)
		{
			RequestFrame(OnNextSurvivorFrame, GetClientUserId(i_Touched));
		}
	}
}

public void OnNextSurvivorFrame(int userid)
{
	int client = GetClientOfUserId(userid);

	if (!client || !IsClientInGame(client))
		return;

	GetEntPropVector(client, Prop_Data, "m_vecVelocity", f_Velocity);
	f_Velocity[2] = 0.0;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, f_Velocity);
	//PrintToChatAll("%N touch entity jump", client);
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}