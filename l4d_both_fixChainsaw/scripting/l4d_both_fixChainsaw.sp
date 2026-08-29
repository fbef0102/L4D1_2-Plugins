#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>

public Plugin myinfo =
{
	name = "Chainsaw Revive Abuse Fix",
	author = "bullet28, Harry",
	description = "Making impossible to use chainsaw while reviving a teammate",
	version = "1.0h-2026/8/29",
	url = ""
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_Left4Dead2 )
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

bool 
	bIsReviving[MAXPLAYERS+1];

int 
	g_iOffsetNextPrimaryAttack,
	g_iOffsetActive,
	g_iPerfAllowedWeapon[MAXPLAYERS+1] = {0, ...}, // [0 = Nothing | 1 = True | 2 = False]
	g_iPerfActiveWeapon[MAXPLAYERS+1] = {-1, ...}; // Previous Active Weapons

public void OnPluginStart() 
{
	g_iOffsetNextPrimaryAttack 	= FindSendPropInfo("CBaseCombatWeapon", "m_flNextPrimaryAttack");
	g_iOffsetActive 			= FindSendPropInfo("CBaseCombatCharacter","m_hActiveWeapon");
	
	HookEvent("round_start", eventRoundStart);
	HookEvent("revive_begin", eventReviveBegin);
	HookEvent("revive_success", eventReviveEnd);
	HookEvent("player_spawn", eventReviveEnd);
	HookEvent("revive_end", eventReviveEnd);
}

void eventRoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	for (int i = 1; i <= MaxClients; i++) bIsReviving[i] = false;
}

void eventReviveBegin(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (isPlayerValid(client))
	{
		bIsReviving[client] = true;
		g_iPerfAllowedWeapon[client] = 0;
	}
}

void eventReviveEnd(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (isPlayerValid(client))
	{
		bIsReviving[client] = false;
		g_iPerfAllowedWeapon[client] = 0;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons) 
{
	if (!(buttons & IN_ATTACK)) return Plugin_Continue;
	if (!isPlayerRealAliveSurvivor(client)) return Plugin_Continue;

	if (GetEntProp(client, Prop_Send, "m_reviveTarget") <= 0) {
		bIsReviving[client] = false;
		return Plugin_Continue;
	}

	int iActiveWeapon = GetEntDataEnt2(client, g_iOffsetActive);
	if(iActiveWeapon <= MaxClients || !IsValidEntity(iActiveWeapon)) return Plugin_Continue;

	bool bWeaponChanged = ((iActiveWeapon != g_iPerfActiveWeapon[client]) || (g_iPerfActiveWeapon[client] == -1));
	g_iPerfActiveWeapon[client] = iActiveWeapon;

	if(bWeaponChanged) // weapons changed
	{
		g_iPerfAllowedWeapon[client] = 0;
	}

	if(!IsWeaponChainsaw(client, iActiveWeapon))
		return Plugin_Continue;

	//ClientCommand(client, "lastinv");
	SetEntDataFloat(iActiveWeapon, g_iOffsetNextPrimaryAttack, GetGameTime() + 0.1, true);

	return Plugin_Continue;
}

bool IsWeaponChainsaw(int client, int weapon)
{
    if(g_iPerfAllowedWeapon[client] == 1) return true;
    else if(g_iPerfAllowedWeapon[client] == 2) return false;

    static char sCurrentWeaponName[32];
    GetEntityClassname(weapon, sCurrentWeaponName, sizeof(sCurrentWeaponName));
    if(strcmp(sCurrentWeaponName, "weapon_chainsaw", false) == 0)
    {
        g_iPerfAllowedWeapon[client] = 1;
        return true;
    }

    g_iPerfAllowedWeapon[client] = 2;
    return false;
}

bool isPlayerValid(int client) 
{
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}

bool isPlayerRealAliveSurvivor(int client) 
{
	return isPlayerValid(client) && !IsFakeClient(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client);
}