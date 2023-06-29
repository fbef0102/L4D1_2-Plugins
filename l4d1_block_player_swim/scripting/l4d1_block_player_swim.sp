#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

ConVar g_hCvarAllow;
bool g_bCvarAllow;

public Plugin myinfo =
{
    name = "L4D / Disable Jumps in deep water",
    author = "Harry Potter",
    description = "Disable the 'water hopping' spam in l4d1.",
    version = "1.0",
    url = "https://forums.alliedmods.net/showthread.php?t=326618"
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

public void OnPluginStart()
{
	g_hCvarAllow =	CreateConVar("l4d1_block_player_swim_allow",	"1", "0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bCvarAllow = g_hCvarAllow.BoolValue;
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);

	AutoExecConfig(true, "l4d1_block_player_swim");
}

public void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_bCvarAllow = g_hCvarAllow.BoolValue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse)
{
	if( g_bCvarAllow && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsFakeClient(client))
	{
		int iWaterLevel = GetEntProp(client, Prop_Send, "m_nWaterLevel"); // detect how much of client body is under water.
		int iOnTheGround = GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONGROUND; // detect client is on the ground or not.
		//PrintToChatAll("client %N, m_nWaterLevel %d, OnTheGround %d", client, iWaterLevel, iOnTheGround);
		if( iWaterLevel >= 1) // 0: no water, 1: a little, 2: half body, 3: full body under water
		{
			if(iOnTheGround == 0) // 1: on the ground, 0: not on the ground
			{
				if( buttons & IN_JUMP ) // player uses jump key
				{
					buttons &= ~IN_JUMP; //block jump key
				}
			}
		}
	}
	return Plugin_Continue;
}