#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION			"1.0"
#define PLUGIN_NAME			    "jockey_ride_team_switch_teleport_fix"
#define DEBUG 0

public Plugin myinfo =
{
	name = "Jockey Ride Team Switch Teleport Fix",
	author = "HarryPotter",
	description = "Fixed Teleport bug if jockey player switches team while ridding the survivor",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
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

#define TEAM_INFECTED		3

#define ZC_JOCKEY		5

public void OnPluginStart()
{
    HookEvent("player_bot_replace",        Event_BotReplacePlayer);
}

public void Event_BotReplacePlayer(Event event, const char[] name, bool dontBroadcast) 
{
    int player = GetClientOfUserId(GetEventInt(event, "player"));

    if(player && IsClientInGame(player) && !IsFakeClient(player) && GetClientTeam(player) == TEAM_INFECTED && IsPlayerAlive(player))
    {
        if (GetEntProp(player, Prop_Send, "m_zombieClass") == ZC_JOCKEY)
        {
            ForcePlayerSuicide(player);
        }
    }
}
