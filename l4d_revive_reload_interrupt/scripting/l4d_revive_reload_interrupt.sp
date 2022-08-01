//Harry @ 2022
//解決裝子彈的時候拯救隊友會卡彈的問題

#define PLUGIN_VERSION 		"1.0"
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[L4D & L4D2] Revive Reload Interrupt",
	author = "HarryPotter",
	description = "Reviving cancels reloading to fix that weapon has jammed and misfired (stupid bug exists for more than 10 years)",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/profiles/76561198026784913"
}

bool g_bLeft4Dead2;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead ) g_bLeft4Dead2 = false;
	else if( test == Engine_Left4Dead2 ) g_bLeft4Dead2 = true;
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

StringMap g_hWeaponIdleLayer;
public void OnPluginStart()
{	
	g_hWeaponIdleLayer = new StringMap();

	if( g_bLeft4Dead2 )
	{
		g_hWeaponIdleLayer.SetValue("weapon_pistol",			19);
		g_hWeaponIdleLayer.SetValue("weapon_pistol_dual",		25);	
		g_hWeaponIdleLayer.SetValue("weapon_smg",				16);
		g_hWeaponIdleLayer.SetValue("weapon_pumpshotgun",		20);
		g_hWeaponIdleLayer.SetValue("weapon_rifle",				16);
		g_hWeaponIdleLayer.SetValue("weapon_autoshotgun",		20);
		g_hWeaponIdleLayer.SetValue("weapon_hunting_rifle",		35);
		g_hWeaponIdleLayer.SetValue("weapon_pistol_magnum",		19);
		g_hWeaponIdleLayer.SetValue("weapon_rifle_ak47",		16);
		g_hWeaponIdleLayer.SetValue("weapon_rifle_desert",		14);
		g_hWeaponIdleLayer.SetValue("weapon_rifle_sg552",		20);
		g_hWeaponIdleLayer.SetValue("weapon_smg_silenced",		16);
		g_hWeaponIdleLayer.SetValue("weapon_smg_mp5",			20);
		g_hWeaponIdleLayer.SetValue("weapon_shotgun_spas",		20);
		g_hWeaponIdleLayer.SetValue("weapon_shotgun_chrome",	20);
		g_hWeaponIdleLayer.SetValue("weapon_sniper_awp",		16);
		g_hWeaponIdleLayer.SetValue("weapon_sniper_military",	12);
		g_hWeaponIdleLayer.SetValue("weapon_sniper_scout",		16);
		g_hWeaponIdleLayer.SetValue("weapon_grenade_launcher",	16);
		g_hWeaponIdleLayer.SetValue("weapon_rifle_m60",			16);
	}
	else
	{
		g_hWeaponIdleLayer.SetValue("weapon_pistol",			31);
		g_hWeaponIdleLayer.SetValue("weapon_pistol_dual",		44);	
		g_hWeaponIdleLayer.SetValue("weapon_smg",				37);
		g_hWeaponIdleLayer.SetValue("weapon_pumpshotgun",		38);
		g_hWeaponIdleLayer.SetValue("weapon_rifle",				42);
		g_hWeaponIdleLayer.SetValue("weapon_autoshotgun",		37);
		g_hWeaponIdleLayer.SetValue("weapon_hunting_rifle",		37);
	}

	CreateConVar("l4d_revive_reload_interrupt_version",			PLUGIN_VERSION,		"Reload Interrupt plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	HookEvent("revive_begin", Event_ReviveBegin);

}

public void Event_ReviveBegin(Event event, const char[] name, bool dontBroadcast)
{ 
	int client = GetClientOfUserId(event.GetInt("userid"));

	if( client && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
	{
		int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if (iActiveWeapon <= MaxClients || !IsValidEntity(iActiveWeapon)) {
			return;
		}

		if(GetEntProp(iActiveWeapon, Prop_Send, "m_bInReload")) //Survivor Reviving while reloading
		{
			// PrintToChatAll("%N is reviving teammate while reloading, weapon is %d, now: %.2f", 
			// 	client, 
			// 	iActiveWeapon, 
			// 	GetGameTime()
			// 	);

			// stop reloading
			float time = GetGameTime();
			SetEntProp(iActiveWeapon, Prop_Send, "m_bInReload", 0);
			SetEntPropFloat(client, Prop_Send, "m_flNextAttack", time);
			SetEntPropFloat(iActiveWeapon, Prop_Send, "m_flNextPrimaryAttack", time);

			if(IsFakeClient(client)) return;

			int iViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
			if(iViewModel <= MaxClients || !IsValidEntity(iViewModel))
				return; 

			static char weapon_name[32];
			GetClientWeapon(client, weapon_name, sizeof(weapon_name));
			
			int nIdleLayerSequence;
			if (strcmp(weapon_name, "weapon_pistol") == 0 && GetEntProp(iActiveWeapon, Prop_Send, "m_isDualWielding") > 0)
			{
				if( !g_hWeaponIdleLayer.GetValue("weapon_pistol_dual", nIdleLayerSequence) )
					return;
			}
			else if( !g_hWeaponIdleLayer.GetValue(weapon_name, nIdleLayerSequence) )
				return;

			SetEntProp(iViewModel, Prop_Send, "m_nLayerSequence", nIdleLayerSequence);
			SetEntPropFloat(iViewModel, Prop_Send, "m_flLayerStartTime", GetGameTime());
		}
	}
}
/*
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if( IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
	{
		int iViewModel = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
		if(iViewModel <= MaxClients || !IsValidEntity(iViewModel))
			return Plugin_Continue;

		if(IsFakeClient(client)) return Plugin_Continue;

		static char weapon_name[64];
		GetClientWeapon(client, weapon_name, sizeof(weapon_name));
		PrintToChatAll("%N weapon: %s, layer: %d", client, weapon_name, GetEntProp(iViewModel, Prop_Send, "m_nLayerSequence"));
	}

	return Plugin_Continue;
}
*/