#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <actions>
#include <l4d_change_witch_victim>

#define PLUGIN_VERSION "1.0-2025/12/31"

public Plugin myinfo = 
{
	name = "l4d_witch_bash_wandering",
	author = "HarryPotter",
	description = "Fixed that survivors can bash wandering witch without witch being startled",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

#define MAXENTITIES                   2048

public void OnPluginStart()
{
}

// Actions

public void OnActionCreated(BehaviorAction action, int actor, const char[] name)
{
	// wandering witch
	if (name[0] == 'W' && strcmp(name, "WitchWander") == 0)
	{
		action.OnShoved = WitchAttack__OnShoved;
	}
}

Action WitchAttack__OnShoved(any action, int actor, int entity, ActionDesiredResult result)
{
	if(entity > 0 && entity <= MaxClients && IsClientInGame(entity) && GetClientTeam(entity) == 2)
	{
		// 站立witch準備雙手攻擊的動作
		if(GetEntProp(actor, Prop_Send, "m_nSequence") == 30) return Plugin_Continue;

		//PrintToChatAll("WitchAttack__OnShoved actor: %d, entity: %d", actor, entity);

		ChangeWitchTarget(actor, entity);

		return Plugin_Continue;
	}

	return Plugin_Continue;
}