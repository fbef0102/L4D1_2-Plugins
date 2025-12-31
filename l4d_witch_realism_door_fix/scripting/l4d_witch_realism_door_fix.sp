#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

#define PLUGIN_VERSION "1.1-2025/12/31"

public Plugin myinfo = 
{
	name = "l4d witch realism door fix",
	author = "HarryPotter",
	description = "Fixing witch can't break the door on Realism mode",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

bool 
	g_bMapStarted, g_bCvarAllow;

public void OnPluginStart()
{
}

public void OnMapEnd()
{
	g_bMapStarted = false;
}

public void OnConfigsExecuted()
{
	CreateTimer(1.0, Timer_MapChange, _, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_MapChange(Handle timer)
{
	g_bMapStarted = true;
	if(L4D2_IsRealismMode())
	{
		HookDoors(true);
		g_bCvarAllow = true;
	}
	else
	{
		g_bCvarAllow = false;
	}

	return Plugin_Continue;
}

public void L4D_OnGameModeChange(int gamemode)
{
	if(g_bMapStarted)
	{
		if(L4D2_IsRealismMode())
		{
			HookDoors(true);
			g_bCvarAllow = true;
		}
		else
		{
			HookDoors(false);
			g_bCvarAllow = false;
		}
	}
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
				SDKHook(entity, SDKHook_OnTakeDamage, DoorOnTakeDamage);
			}
		}
	}
}

Action DoorOnTakeDamage(int door, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(damage <= 0.0 || attacker == door || attacker != inflictor) return Plugin_Continue;

	if(IsWitch(attacker))
	{
		//PrintToChatAll("door: %d, attacker: %d, damage: %.1f, inflictor: %d, damagetype:%d", door, attacker, damage, inflictor, damagetype);
		//realism: DMG_PARALYZE + DMG_SLASH, other mode: DMG_SLASH

		damagetype = DMG_SLASH;
		
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

void HookDoors(bool bHook)
{
	int iDoorEnt = MaxClients +1;
	while ((iDoorEnt = FindEntityByClassname(iDoorEnt, "prop_door_rotating")) != -1)
	{
		if (!IsValidEntity(iDoorEnt))
		{
			continue;
		}

		SDKUnhook(iDoorEnt, SDKHook_OnTakeDamage, DoorOnTakeDamage);
		if(bHook) SDKHook(iDoorEnt, SDKHook_OnTakeDamage, DoorOnTakeDamage);
	}
}

bool IsWitch(int entity)
{
    if (entity > MaxClients && IsValidEntity(entity))
    {
        static char strClassName[64];
        GetEntityClassname(entity, strClassName, sizeof(strClassName));
        return strcmp(strClassName, "witch") == 0;
    }
    return false;
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}