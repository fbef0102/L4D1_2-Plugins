#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.3-2023/7/27"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "l4d2 melee weapons swing",
	author = "HarryPotter",
	description = "Adjustable melee swing rate for each melee weapon.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=332737"
};

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	bLate = late;
	return APLRes_Success;
}

#define CVAR_FLAGS			FCVAR_NOTIFY
#define	MAX_MELEE			14
#define TEAM_SURVIVORS 		2

//convar
ConVar g_hCvarAllow, g_hCvarRate[MAX_MELEE], g_hCvarInapRate;
float g_fCvarRate[MAX_MELEE];

//value
int g_iMAEntid[MAXPLAYERS+1];
float g_flMANextTime[MAXPLAYERS+1];
float melee_speed[MAXPLAYERS+1];
float g_fCvarInapRate;

//offeset
int g_iNextPAttO, g_ActiveWeaponOffset;
StringMap g_hScripts;

public void OnPluginStart()
{
	//get offsets
	g_iNextPAttO		=	FindSendPropInfo("CBaseCombatWeapon","m_flNextPrimaryAttack");
	g_ActiveWeaponOffset = 	FindSendPropInfo("CBasePlayer", "m_hActiveWeapon");
	
	g_hScripts = CreateTrie();
	g_hScripts.SetValue("baseball_bat",		0);
	g_hScripts.SetValue("cricket_bat",		1);
	g_hScripts.SetValue("crowbar",			2);
	g_hScripts.SetValue("electric_guitar",	3);
	g_hScripts.SetValue("fireaxe",			4);
	g_hScripts.SetValue("frying_pan",		5);
	g_hScripts.SetValue("golfclub",			6);
	g_hScripts.SetValue("katana",			7);
	g_hScripts.SetValue("knife",			8);
	g_hScripts.SetValue("machete",			9);
	g_hScripts.SetValue("tonfa",			10);
	g_hScripts.SetValue("pitchfork",		11);
	g_hScripts.SetValue("shovel",			12);
	
	g_hCvarAllow =	 CreateConVar(		"l4d2_melee_swing_allow",	"1",	"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[0] = CreateConVar(		"l4d2_melee_swing_baseball_bat_rate",	"0.75",			"0=Value Default, The interval for swinging Baseball Bat. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[1] = CreateConVar(		"l4d2_melee_swing_cricket_bat_rate",	"0.8",			"0=Value Default, The interval for swinging Cricket Bat.(clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[2] = CreateConVar(		"l4d2_melee_swing_crowbar_rate",		"0.8",			"0=Value Default, The interval for swinging Crowbar. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[3] = CreateConVar(		"l4d2_melee_swing_electric_guitar_rate","1.0",			"0=Value Default, The interval for swinging Electric Guitar.(clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[4] = CreateConVar(		"l4d2_melee_swing_fireaxe_rate",		"1.0",			"0=Value Default, The interval for swinging Fire Axe. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[5] = CreateConVar(		"l4d2_melee_swing_frying_pan_rate",		"0.75",			"0=Value Default, The interval for swinging Frying Pan. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[6] = CreateConVar(		"l4d2_melee_swing_golfclub_rate",		"0.75",			"0=Value Default, The interval for swinging Golf Club. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[7] = CreateConVar(		"l4d2_melee_swing_katana_rate",			"0.8",			"0=Value Default, The interval for swinging Katana. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[8] = CreateConVar(		"l4d2_melee_swing_knife_rate",			"0.8",			"0=Value Default, The interval for swinging Knife. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[9] = CreateConVar(		"l4d2_melee_swing_machete_rate",		"0.8",			"0=Value Default, The interval for swinging Machete.(clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[10] = CreateConVar(		"l4d2_melee_swing_tonfa_rate",			"0.75",			"0=Value Default, The interval for swinging Tonfa. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[11] = CreateConVar(		"l4d2_melee_swing_pitchfork_rate",		"0.88",			"0=Value Default, The interval for swinging Pitchfork. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[12] = CreateConVar(		"l4d2_melee_swing_shovel_rate",			"1.0",			"0=Value Default, The interval for swinging shovel. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarRate[13] = CreateConVar(		"l4d2_melee_swing_unknown_rate",		"0.0",			"0=Value Default, Custom Third Party Melee, The interval for swinging unknown melee weapon. (clamped between 0.2 and 1.0)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarInapRate = CreateConVar(		"l4d2_melee_swing_incapacitated_multi_rate",	"2.0",			"0=Value Default, 1=Each melee rate unchanged, modify melee swinging rate multi when incapacitated. (ex. Use 'Incapped Weapons Patch by Silvers' to allow using Weapons while Incapped)", CVAR_FLAGS, true, 0.0);
	
	AutoExecConfig(true,				"l4d2_melee_swing");
	
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	for( int i = 0; i < MAX_MELEE; i++ )
		g_hCvarRate[i].AddChangeHook(ConVarChanged_Cvars);
	g_hCvarInapRate.AddChangeHook(ConVarChanged_Cvars);
	
	if (bLate)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
}

bool g_bIsLoading;
public void OnMapEnd()
{
	g_bIsLoading = true;
}

// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
	for (int i = 1; i <= MaxClients; i++)
	{
		g_iMAEntid[i] = 0;
	}
}

void GetCvars()
{
	for( int i = 0; i < MAX_MELEE; i++ )
		g_fCvarRate[i] = g_hCvarRate[i].FloatValue;
	
	g_fCvarInapRate = g_hCvarInapRate.FloatValue;
}

bool g_bCvarAllow;
void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true )
	{
		g_bCvarAllow = true;
		HookEvents();

		g_bIsLoading = false;
		for (int i = 1; i <= MaxClients; i++)
		{
			melee_speed[i] = 0.0;
			g_iMAEntid[i] = 0;
			g_flMANextTime[i] = 0.0;
		}
	}

	else if( g_bCvarAllow == true && bCvarAllow == false )
	{
		g_bCvarAllow = false;
		UnhookEvents();
	}
}

// ====================================================================================================
//					EVENTS
// ====================================================================================================
void HookEvents()
{
	HookEvent("round_start",  Event_RoundStart,	 EventHookMode_PostNoCopy);
	HookEvent("weapon_fire", Event_WeaponFire);
	HookEvent("player_team", evtPlayerTeam);
}

void UnhookEvents()
{
	UnhookEvent("round_start",	Event_RoundStart,	EventHookMode_PostNoCopy);
	UnhookEvent("weapon_fire", Event_WeaponFire);
	UnhookEvent("player_team", evtPlayerTeam);
}

void evtPlayerTeam(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	melee_speed[client] = 0.0;
	g_iMAEntid[client] = 0;
	g_flMANextTime[client] = 0.0;
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bIsLoading = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		melee_speed[i] = 0.0;
		g_iMAEntid[i] = 0;
		g_flMANextTime[i] = 0.0;
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitched);
	melee_speed[client] = 0.0;
	g_iMAEntid[client] = 0;
	g_flMANextTime[client] = 0.0;
}

public void OnGameFrame()
{
	if (g_bCvarAllow == false || g_bIsLoading == true || IsServerProcessing() == false)
	{
		return;
	}
	else
	{
		Melee_OnGameFrame();
	}
}


int index;
int iEntid;
float flNextTime_calc;
float flNextTime_ret;
float flGameTime;
void Melee_OnGameFrame()
{
	flGameTime = GetGameTime();
	
	for (int i=1; i<=MaxClients; i++)
	{
		if(!IsClientInGame(i)) continue;
		if(!IsPlayerAlive(i)) continue;
		if(GetClientTeam(i) != TEAM_SURVIVORS) continue;
		
		iEntid = GetEntDataEnt2(i, g_ActiveWeaponOffset);
		if (iEntid == -1 || g_iMAEntid[i] == 0) continue;

		flNextTime_ret = GetEntDataFloat(iEntid, g_iNextPAttO);
		
		if (g_iMAEntid[i] == iEntid)
		{
			if(g_flMANextTime[i]>=flNextTime_ret || melee_speed[i] < 0.2)
			{
				continue;
			}
			else
			{
				#if DEBUG
					PrintToChatAll("OnGameFrame() %N - addspeed: %f", i, melee_speed[i]);
				#endif
				if(IsPlayerIncap(i)) //incap
				{
					if(g_fCvarInapRate == 0.0) continue;
					
					flNextTime_calc = flGameTime + melee_speed[i] * g_fCvarInapRate;
				}
				else
				{
					flNextTime_calc = flGameTime + melee_speed[i];
				}
				g_flMANextTime[i] = flNextTime_calc;
				SetEntDataFloat(iEntid, g_iNextPAttO, flNextTime_calc, true);
				continue;	
			}
		}
	}
}

void Event_WeaponFire(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS)
	{
		int iWeapon = GetEntDataEnt2(client, g_ActiveWeaponOffset);
		if (iWeapon == -1 || iWeapon == g_iMAEntid[client]) return;

		char sBuffer[8];
		event.GetString("weapon", sBuffer, sizeof(sBuffer));
		if (strcmp(sBuffer, "melee") == 0 && HasEntProp(iWeapon, Prop_Data, "m_strMapSetScriptName"))
		{
			if (g_iMAEntid[client] != iWeapon)
			{
				char sTemp[16];
				GetEntPropString(iWeapon, Prop_Data, "m_strMapSetScriptName", sTemp, sizeof(sTemp));
				if( g_hScripts.GetValue(sTemp, index) )
				{
					melee_speed[client] = g_fCvarRate[index];
					#if DEBUG
						PrintToChatAll("Event_WeaponFire %N - hold %s - addspeed: %f", client, sTemp, melee_speed[client]);
					#endif
				}
				else // Custom Third Party Melee
				{
					melee_speed[client] = g_fCvarRate[MAX_MELEE - 1];
				}
				
				g_iMAEntid[client]=iWeapon;
				g_flMANextTime[client]= GetEntDataFloat(iWeapon, g_iNextPAttO);
			}
		}
		else 
		{
			//if no, then store in known-non-melee var
			g_iMAEntid[client] = 0;
		}
	}
}

void OnWeaponSwitched(int client, int weapon)
{
	if (GetClientTeam(client) == TEAM_SURVIVORS && weapon > 0 && IsValidEntity(weapon))
	{
		char sBuffer[16];
		GetEntityClassname(weapon, sBuffer, sizeof(sBuffer));
		if (strcmp(sBuffer, "weapon_melee") == 0)
		{
			g_iMAEntid[client]=0;
		}
	}
}

bool IsPlayerIncap(int client)
{
	if(GetEntProp(client, Prop_Send, "m_isHangingFromLedge") || GetEntProp(client, Prop_Send, "m_isIncapacitated"))
		return true;

	return false;
}