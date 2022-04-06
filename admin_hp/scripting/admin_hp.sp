#include <sourcemod>
#include <adminmenu>
#include <sdktools>
#define PLUGIN_VERSION "2.6"

enum
{
	L4D_TEAM_SPECTATE = 1,
	L4D_TEAM_SURVIVOR = 2,
	L4D_TEAM_INFECTED = 3,
}

public Plugin myinfo =
{
	name = "Adm Give full health",
	author = "Harry Potter",
	description = "Adm type !givehp to set survivor team full health",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/AkemiHomuraGoddess/"
}

bool L4D2Version = false;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		L4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		L4D2Version = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart(){
	RegAdminCmd("sm_hp", restore_hp, ADMFLAG_ROOT, "Restore all survivors full hp");
	RegAdminCmd("sm_givehp", restore_hp, ADMFLAG_ROOT, "Restore all survivors full hp");
}

public Action restore_hp(int client, int args){
	if (client == 0)
	{
		PrintToServer("[TS] \"Restore_hp\" cannot be used by server.");
		return Plugin_Handled;
	}
	
	for( int i = 1; i < MaxClients; i++ ) {
		if (IsClientInGame(i) && GetClientTeam(i)==L4D_TEAM_SURVIVOR && IsPlayerAlive(i))
			CheatCommand(i);
	}
	
	PrintToChatAll("\x01[\x05TS\x01] Adm \x03%N \x01restores \x05all survivors \x04FULL HP", client);
	LogMessage("[TS] Adm %N restores all survivors FULL HP", client);
	
	return Plugin_Handled;
}

void CheatCommand(int client)
{
	int give_flags = GetCommandFlags("give");
	SetCommandFlags("give", give_flags & ~FCVAR_CHEAT);
	if (GetEntProp(client, Prop_Send, "m_isHangingFromLedge"))//懸掛
	{
		FakeClientCommand(client, "give health");
	}
	else if (IsIncapacitated(client))//倒地
	{
		if(GetInfectedAttacker(client) < 0)
		{
			FakeClientCommand(client, "give health");
			SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
			SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
		}
	}
	else if(GetClientHealth(client)<100) //血量低於100
	{
		FakeClientCommand(client, "give health");
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
		SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
	}
	
	SetCommandFlags("give", give_flags);
}

bool IsIncapacitated(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated"));
}

int GetInfectedAttacker(int client)
{
	int attacker;

	if(L4D2Version)
	{
		/* Charger */
		attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
		if (attacker > 0)
		{
			return attacker;
		}

		attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
		if (attacker > 0)
		{
			return attacker;
		}
		/* Jockey */
		attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
		if (attacker > 0)
		{
			return attacker;
		}
	}

	/* Hunter */
	attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
	if (attacker > 0)
	{
		return attacker;
	}

	/* Smoker */
	attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
	if (attacker > 0)
	{
		return attacker;
	}

	return -1;
}