#include <sourcemod>
#include <adminmenu>
#include <sdktools>
#define PLUGIN_VERSION "2.5"

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
	
	for( int i = 1; i < GetMaxClients(); i++ ) {
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
		FakeClientCommand(client, "give health");
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
		SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
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
	return GetEntProp(client, Prop_Send, "m_isIncapacitated");
}