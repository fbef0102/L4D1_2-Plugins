#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0"

public Plugin myinfo = 
{
	name = "l4d witch realism door fix",
	author = "HarryPotter",
	description = "Fixing witch can't break the door on Realism Normal、Advanced、Expert",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

ConVar g_hCvarMPGameMode;
ConVar g_hCvarZDifficulty;

public void OnPluginStart()
{
	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarZDifficulty = FindConVar("z_difficulty");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarZDifficulty.AddChangeHook(ConVarChanged_Allow);
}


bool g_bMapStarted;
public void OnMapStart()
{
	g_bMapStarted = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
}

public void OnConfigsExecuted()
{
	IsAllowed();
}

public void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

bool g_bCvarAllow;
void IsAllowed()
{
	bool bAllowDifficulty = IsAllowedDifficulty();
	bool bAllowMode = IsAllowedGameMode();

	if( g_bCvarAllow == false && bAllowDifficulty == true && bAllowMode == true)
	{
		CreateTimer(0.1, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
		g_bCvarAllow = true;
	}

	else if( g_bCvarAllow == true && (bAllowDifficulty == false || bAllowMode == false) )
	{
		g_bCvarAllow = false;
	}
}

bool IsAllowedDifficulty()
{
	static char difficulty[100];
	g_hCvarZDifficulty.GetString(difficulty, sizeof(difficulty));
	if (strcmp(difficulty, "easy", false) == 0)  
	{
		return false;
	}
	else if (strcmp(difficulty, "normal", false) == 0 || strcmp(difficulty, "hard", false) == 0 || strcmp(difficulty, "Impossible", false) == 0)
	{
		return true;
	}
	
	return false;
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

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

	if( g_iCurrentMode != 1 )
		return false;

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

Action tmrStart(Handle timer)
{
	int iDoorEnt = MaxClients +1;
	while ((iDoorEnt = FindEntityByClassname(iDoorEnt, "prop_door_rotating")) != -1)
	{
		if (!IsValidEntity(iDoorEnt))
		{
			continue;
		}

		SDKUnhook(iDoorEnt, SDKHook_OnTakeDamage, DoorOnTakeDamage);
		SDKHook(iDoorEnt, SDKHook_OnTakeDamage, DoorOnTakeDamage);
	}

	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!g_bCvarAllow || !IsValidEntityIndex(entity))
		return;

	switch (classname[0])
	{
		case 'p':
		{
			if (strcmp(classname, "prop_door_rotating", false) == 0)
			{
				SDKUnhook(entity, SDKHook_OnTakeDamage, DoorOnTakeDamage);
				SDKHook(entity, SDKHook_OnTakeDamage, DoorOnTakeDamage);
			}
		}
	}
}

public Action DoorOnTakeDamage(int ent, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(g_bCvarAllow == false) SDKUnhook(ent, SDKHook_OnTakeDamage, DoorOnTakeDamage);

	if(damage <= 0.0 || attacker == ent || inflictor < 0 || !IsValidEntity(inflictor)) return Plugin_Continue;

	if(IsWitch(attacker))
	{
		//PrintToChatAll("door: %d being attacked by %d, damage: %.1f, inflictor: %d, damagetype:%d", ent, attacker, damage, inflictor, damagetype);
		
		damagetype = DMG_SLASH;
		
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

bool IsWitch(int entity)
{
    if (entity > MaxClients && IsValidEntity(entity) && IsValidEdict(entity))
    {
        static char strClassName[64];
        GetEdictClassname(entity, strClassName, sizeof(strClassName));
        return strcmp(strClassName, "witch") == 0;
    }
    return false;
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}