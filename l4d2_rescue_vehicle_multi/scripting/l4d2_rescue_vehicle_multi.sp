/**
 * Credit: 
 * 1. https://forums.alliedmods.net/showpost.php?p=2771140&postcount=49
 * 2. https://forums.alliedmods.net/showpost.php?p=2771588&postcount=53
 * 3. https://forums.alliedmods.net/showthread.php?t=350059
 * 4. https://forums.alliedmods.net/showthread.php?t=121945
 * 5. https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/finalefix.sp
 */


#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>
#include <left4dhooks>

#define PLUGIN_NAME			    "l4d2_rescue_vehicle_multi"
#define PLUGIN_VERSION 			"1.0h-2025/1/13"

public Plugin myinfo=
{
	name = "Finale rescue vehicle fix for 5+ survivors",
	author = "sorallll, edshot99, V10, CanadaRox, Harry",
	description = "Try to fix extra 5+ survivors bug after finale rescue leaving, such as: die, fall down, not count as alive, versus score bug",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

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
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define ENTITY_SAFE_LIMIT             2000 //don't spawn boxes when it's index is above this

bool
	g_bIsSacrificeFinale,
	g_bFinalLeaving;

int 
	g_iSurvivorCount;

public void OnPluginStart()
{
	if(g_bL4D2Version)
	{
		GameData hGamedata = new GameData(PLUGIN_NAME);

		if(hGamedata == null)
			SetFailState( "Can't load gamedata \"%s.txt\" or not found", PLUGIN_NAME);

		Handle hDetour = DHookCreateFromConf(hGamedata, "CTerrorGameRules::CalculateSurvivalMultiplier");
		if(!hDetour)
			SetFailState("Failed to find 'CTerrorGameRules::CalculateSurvivalMultiplier' signature");
		
		if(!DHookEnableDetour(hDetour, true, CalculateSurvivalMultiplier_Post))
			SetFailState("Failed to detour 'CTerrorGameRules::CalculateSurvivalMultiplier'");

		delete hDetour;

		delete hGamedata;
	}

	HookEvent("round_start",            Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("finale_vehicle_leaving", Event_FinaleVehicleLeaving, EventHookMode_Pre);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	switch (classname[0])
	{
		case 't':
		{
			if (strncmp(classname, "trigger_finale", 14) == 0) //late spawn
			{
				RequestFrame(OnNextFrame_trigger_finale, EntIndexToEntRef(entity));
			}
		}
	}
}

void OnNextFrame_trigger_finale(int entityRef)
{
	int entity = EntRefToEntIndex(entityRef);

	if (entity == INVALID_ENT_REFERENCE)
		return;

	HookSingleEntityOutput(entity, "FinaleEscapeStarted", OnFinaleEscapeStarted);
}

void OnFinaleEscapeStarted(const char[] output, int caller, int activator, float delay)
{
	g_bIsSacrificeFinale = view_as<bool>(GetEntProp(caller, Prop_Data, "m_bIsSacrificeFinale"));
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	g_bFinalLeaving = false;
	g_iSurvivorCount = 0;
	g_bIsSacrificeFinale = false;

	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
			continue;
			
		SDKUnhook(i, SDKHook_OnTakeDamage, SurvivorOnTakeDamage);
	}
}

void Event_FinaleVehicleLeaving(Event event, const char[] name, bool dontBroadcast)
{
	g_bFinalLeaving = true;

	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || GetClientTeam(i) != 2)
			continue;

		if(IsPlayerAlive(i))
		{
			if(IsPlayerIncapacitated(i) || IsPlayerHangingFromLedge(i))
			{
				// (Versus) Kills survivors before the score is calculated so you don't get full distance if you are incapped as the rescue vehicle leaves.
				if(L4D_HasPlayerControlledZombies()) ForcePlayerSuicide(i);

				continue;
			}
			g_iSurvivorCount ++;

			// give god mode
			if(!g_bIsSacrificeFinale) SDKHook(i, SDKHook_OnTakeDamage, SurvivorOnTakeDamage); //God mode
		}
	}

	// teleport + count alive on campaign credit (coop mode)
	int entity = FindEntityByClassname(MaxClients + 1, "info_survivor_position");
	if(IsValidEntity(entity))
	{
		float vOrigin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vOrigin);

		int iSurvivor = 0;
		static const char sOrder[][] = {"1", "2", "3", "4"};
		for(int i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i) || GetClientTeam(i) != 2)
				continue;
				
			if(++iSurvivor < 4)
				continue;
				
			entity = CreateEntityByName("info_survivor_position");
			if( !CheckIfEntitySafe(entity) ) break;

			DispatchKeyValue(entity, "Order", sOrder[iSurvivor - RoundToFloor(iSurvivor / 4.0) * 4]);
			TeleportEntity(entity, vOrigin, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(entity);
		}
	}
}

Action SurvivorOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!IsClientInGame(victim) || GetClientTeam(victim) != 2) return Plugin_Continue;

    return Plugin_Handled;
}

// (versus) fix score bug
MRESReturn CalculateSurvivalMultiplier_Post(Address pThis, Handle hParams)
{
	if(!g_bFinalLeaving) return MRES_Ignored;
	if(L4D_HasPlayerControlledZombies() == false) return MRES_Ignored;

	int iTeamFliped = GameRules_GetProp("m_bAreTeamsFlipped");
	int iOrininalSurvivorCount = GameRules_GetProp("m_iVersusSurvivalMultiplier", 4, iTeamFliped);
	//LogError("iOrininalSurvivorCount: %d, g_iSurvivorCount: %d", iOrininalSurvivorCount, g_iSurvivorCount);

	if(iOrininalSurvivorCount < g_iSurvivorCount)
	{
		GameRules_SetProp("m_iVersusSurvivalMultiplier", g_iSurvivorCount, 4, iTeamFliped, true);
	}

	return MRES_Ignored;
}

bool IsPlayerIncapacitated(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1));
}

bool IsPlayerHangingFromLedge(int client)
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