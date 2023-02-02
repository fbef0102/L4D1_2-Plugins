#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>

ConVar g_hLimitTank;
int g_iLimitTank;
static int ZOMBIECLASS_TANK;

public Plugin myinfo = 
{
	name = "L4D2 Limit Tank",
	author = "Harry Potter",
	description = "limit tank in server",
	version = "1.2",
	url = "https://steamcommunity.com/profiles/76561198026784913"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		ZOMBIECLASS_TANK = 5;
	}
	else if( test == Engine_Left4Dead2 )
	{
		ZOMBIECLASS_TANK = 8;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{
	g_hLimitTank= CreateConVar("z_tank_limit", "3", "Maximum of tanks in server.",FCVAR_NOTIFY);
	g_iLimitTank = g_hLimitTank.IntValue;
	HookConVarChange(g_hLimitTank, Limit_CvarChange);

	HookEvent("tank_spawn", PD_ev_TankSpawn);
	
	AutoExecConfig(true, "l4d_tanklimit");
}

public void PD_ev_TankSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!IsClientInGame(client) || !IsFakeClient(client)) return;
	
	
	if(g_iLimitTank >= 0)
	{
		CreateTimer(1.5, CheckAndKickTank,client);
	}
	
}
public Action CheckAndKickTank(Handle timer,any client)
{
	if(IsClientInGame(client)&&IsPlayerTank(client)&&IsFakeClient(client))
	{
		int tank_count = 0;
		for (int i=1;i<=MaxClients;i++)
			if(IsClientInGame(i) && GetClientTeam(i)==3 && IsPlayerTank(i) && IsPlayerAlive(i))
				tank_count++;
		
		//PrintToChatAll("tank_count: %d, g_iLimitTank: %d", tank_count,g_iLimitTank);		
		if(tank_count > g_iLimitTank)
		{
			TeleportEntity(client,
			view_as<float>({0.0, 0.0, 0.0}), // Teleport to map center
			NULL_VECTOR, 
			NULL_VECTOR);
			KickClient(client);
		}
	}

	return Plugin_Continue;
}
public void Limit_CvarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_iLimitTank = GetConVarInt(g_hLimitTank);
}

bool IsPlayerTank(int tank_index)
{
	return GetEntProp(tank_index, Prop_Send, "m_zombieClass") == ZOMBIECLASS_TANK;
}