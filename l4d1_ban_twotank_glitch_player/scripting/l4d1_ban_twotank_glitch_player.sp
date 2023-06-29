#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
    name = "[L4D1] Ban tank player glitch",
    author = "Harry Potter",
    description = "Ban player who uses L4D1 / Split tank glitch",
    version = "1.1",
    url = "https://forums.alliedmods.net/showthread.php?t=326023"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if(test != Engine_Left4Dead)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success; 
}

ConVar g_hCvarAllow, g_hCvarBanTime, g_hCvarKillTank;
static int ZOMBIECLASS_TANK = 5;

public void OnPluginStart()
{
	g_hCvarAllow =		CreateConVar("l4d1_ban_twotank_glitch_player_enable",		"1", "0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarBanTime =	CreateConVar("l4d1_ban_twotank_glitch_player_ban_time",		"5", "Ban how many mins.", FCVAR_NOTIFY, true, 1.0);
	g_hCvarKillTank =	CreateConVar("l4d1_ban_twotank_glitch_player_kill_tank",	"1", "Kill Tank who's Frustration is 100% a player leaves.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AutoExecConfig(true, "l4d1_ban_twotank_glitch_player");
}

public void OnClientDisconnect(int client)
{
	if(g_hCvarAllow.BoolValue)
	{
		if(client && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 3 && IsPlayerAlive(client) && IsPlayerTank(client))
		{
			int frus = GetFrustration(client);
			if(frus == 100)
			{
				if(g_hCvarKillTank.BoolValue) ForcePlayerSuicide(client);
				PrintToChatAll("[\x05TS\x01] \x04%N \x01tries to use \x03two tank glitch\x01 and leaves the game as alive tank player.",client);
				BanClient(client, g_hCvarBanTime.IntValue, BANFLAG_AUTHID, "use two tank glitch", "Nice Try! Dumbass!");
			}
		}
	}
}

bool IsPlayerTank (int client)
{
    return (GetEntProp(client, Prop_Send, "m_zombieClass") == ZOMBIECLASS_TANK);
}

int GetFrustration(int tank_index)
{
	return GetEntProp(tank_index, Prop_Send, "m_frustration");
}
