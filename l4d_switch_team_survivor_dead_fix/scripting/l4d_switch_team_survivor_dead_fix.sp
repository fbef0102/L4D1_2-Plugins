#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3
#define GOD_TIME 0.05

float g_fProtectDamageTime[MAXPLAYERS + 1] = {0.0};

public Plugin myinfo =
{
	name = "[L4D & L4D2] Fix Team Switch Dead/Incap",
	author = "HarryPotter",
	description = "Fixed a bug sometimes infected player switchs team to survivor, the survivor gets incapped/killed instantly",
	version = "1.0",
	url = "http://steamcommunity.com/profiles/76561198026784913"
}

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1/2.");
		return APLRes_SilentFailure;
	}

	bLate = late;
	return APLRes_Success; 
}
public void OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	HookEvent("bot_player_replace", Event_BotPlayerReplace);

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

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, SurvivorOnTakeDamage);
}

public Action SurvivorOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	//PrintToChatAll("%d hurt %N (Team: %d, God: %.2f), damage: %.2f, inflictor: %d, damageType: %d, Time: %.2f",attacker, victim, GetClientTeam(victim), g_fProtectDamageTime[victim], damage, inflictor, damagetype, GetEngineTime() );
	if(g_fProtectDamageTime[victim] > GetEngineTime() && !IsFakeClient(victim) && GetClientTeam(victim) == TEAM_SURVIVOR && IsPlayerAlive(victim))
	{
		if(damagetype & DMG_FALL)
		{
			g_fProtectDamageTime[victim] = 0.0;
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public void Event_BotPlayerReplace(Event event, const char[] name, bool dontBroadcast) 
{
	int player = GetClientOfUserId(GetEventInt(event, "player"));
	if(player && IsClientInGame(player) && !IsFakeClient(player) && GetClientTeam(player) == TEAM_SURVIVOR && IsPlayerAlive(player))
	{
		//PrintToChatAll("%N replace Bot, time: %.2f", player, GetEngineTime());
		g_fProtectDamageTime[player] = GetEngineTime() + GOD_TIME;
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	for(int i = 1; i <= MaxClients; i++)
	{
		g_fProtectDamageTime[i] = 0.0;
	}
}