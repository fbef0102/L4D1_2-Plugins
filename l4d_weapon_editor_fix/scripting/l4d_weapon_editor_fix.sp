/**
 * 修復一些武器的weapon_*.txt參數沒有作用 (彌補l4d_info_editor插件無法修改的武器參數，檔案: data/l4d_info_editor_weapons.cfg)
 * -Weapons
 *  -CycleTime (Standing)
 *   1. dual pistol (plugin cvar)
 *   2. pump shotgun
 *   3. shotgun chrome
 *   4. autoshotgun
 *   5. shotgun spas
 *  
 *  -CycleTime (Incap) (wh_use_incap_cycle_cvar must be 1 from WeaponHandling)
 *   If weapon_*.txt "CycleTime" slower than official cvar "survivor_incapacitated_cycle_time", ignores the cvar and uses weapon_*.txt "CycleTime" for incap shooting cycle rate
 *   If weapon_*.txt "CycleTime" faster than official cvar "survivor_incapacitated_cycle_time", use "survivor_incapacitated_cycle_time" for incap shooting cycle rate
 *  
 *  -ReloadDuration
 *   1. dual pistol (plugin cvar)
 *   2. pump shotgun
 *   3. shotgun chrome
 *   4. autoshotgun
 *   5. shotgun spas
 * 
 *  -Fixed Reload playback when shove
 * 
 * -Melee
 *  -refire_delay (Standing)
 *   All Melee weapons including custom melee
 * 
 *  -refire_delay (Incap)
 *   Modify melee swinging rate multi when incapacitateAll (plugin cvar)
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>          // https://forums.alliedmods.net/showthread.php?t=321696
#include <WeaponHandling>       // https://forums.alliedmods.net/showthread.php?t=319947

#define PLUGIN_VERSION			"1.2-2024/6/25"
#define PLUGIN_NAME			    "l4d_weapon_editor_fix"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D2] l4d weapon editor fix",
	author = "HarryPotter",
	description = "Fix some Weapon attribute not exactly obey keyvalue in weapon_*.txt",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead )
	{
		g_bL4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		g_bL4D2Version = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}


#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

ConVar g_hCvar_IncapCycle; 
float g_fIncapCycle;

ConVar g_hCvarEnable, 
	g_hCvarDualPistol_CycleTime, g_hCvarDualPistol_ReloadDuration,
	g_hCvarShotGun_Fix_CycleTime, g_hCvarShotGun_Fix_ReloadDuration,
	g_hCvarWeaponIncap_Fix_CycleTime,
	g_hCvarMelee_Fix_Refire_Delay, g_hCvarMeleeIncap_Refire_Delay_Multi;
bool g_bCvarEnable,
	g_bCvarShotGun_Fix_CycleTime, g_bCvarShotGun_Fix_ReloadDuration,
	g_bCvarWeaponIncap_Fix_CycleTime,
	g_bCvarMelee_Fix_Refire_Delay;
float g_fCvarDualPistol_CycleTime, g_fCvarDualPistol_ReloadDuration, g_fCvarMeleeIncap_Refire_Delay_Multi;

float 
	g_fWeapon_CycleTime[view_as<int>(L4D2WeaponType_Gnome)+1],
	g_fWeapon_ReloadDuration[view_as<int>(L4D2WeaponType_Gnome)+1],
	g_fMelee_RefireDelay[16];
	//g_fATTACK2Timeout[MAXPLAYERS+1];

char 
    g_sMeleeClass[16][32];

int 
	g_iMeleeClassCount;

public void OnPluginStart()
{
	g_hCvar_IncapCycle = FindConVar("survivor_incapacitated_cycle_time");

	g_hCvarEnable 							= CreateConVar( PLUGIN_NAME ... "_enable",        				"1",   		"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarDualPistol_CycleTime 			= CreateConVar( PLUGIN_NAME ... "_dual_pistol_CycleTime",   	"0.1",   	"The dual pistol Cycle Time (fire rate, 0: keeps vanilla cycle rate of 0.075)", CVAR_FLAGS, true, 0.0);
	g_hCvarDualPistol_ReloadDuration 		= CreateConVar( PLUGIN_NAME ... "_dual_pistol_ReloadDuration",  "0",   		"The dual pistol Reload Duration (0: keeps vanilla reload duration of 2.333)", CVAR_FLAGS, true, 0.0);
	g_hCvarShotGun_Fix_CycleTime 			= CreateConVar( PLUGIN_NAME ... "_shotgun_fire_rate",  			"1",   		"If 1, Make shotgun fire rate obey \"CycleTime\" keyvalue in weapon_*.txt", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarShotGun_Fix_ReloadDuration 		= CreateConVar( PLUGIN_NAME ... "_shotgun_reload",  			"1",   		"If 1, Make shotgun reload duration obey \"ReloadDuration\" keyvalue in weapon_*.txt", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarWeaponIncap_Fix_CycleTime 		= CreateConVar( PLUGIN_NAME ... "_incap_fire_rate",  			"1",   		"If 1, Use weapon_*.txt \"CycleTime\" or official cvar \"survivor_incapacitated_cycle_time\" for incap shooting cycle rate, depends on which cycle rate is slower than another\n(\"wh_use_incap_cycle_cvar\" must be 1)", CVAR_FLAGS, true, 0.0, true, 1.0);
	if(g_bL4D2Version)
	{
		g_hCvarMelee_Fix_Refire_Delay			= CreateConVar( PLUGIN_NAME ... "_melee_swing",  				"1",   		"If 1, Make melee swing rate obey \"refire_delay\" keyvalue in melee\\*.txt", CVAR_FLAGS, true, 0.0, true, 1.0);
		g_hCvarMeleeIncap_Refire_Delay_Multi	= CreateConVar( PLUGIN_NAME ... "_melee_swing_incap_multi",  	"1.3",   	"0=Unchanged, Modify melee swinging rate multi when incapacitated, (ex. Use 'Incapped Weapons Patch by Silvers' to allow using melee while Incapped)", CVAR_FLAGS, true, 0.0);
	}
	CreateConVar(                       					PLUGIN_NAME ... "_version",       				PLUGIN_VERSION, PLUGIN_NAME ... 	" Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                					PLUGIN_NAME);

	GetCvars();
	g_hCvar_IncapCycle.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDualPistol_CycleTime.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDualPistol_ReloadDuration.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarShotGun_Fix_CycleTime.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarShotGun_Fix_ReloadDuration.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarWeaponIncap_Fix_CycleTime.AddChangeHook(ConVarChanged_Cvars);
	if(g_bL4D2Version)
	{
		g_hCvarMelee_Fix_Refire_Delay.AddChangeHook(ConVarChanged_Cvars);
		g_hCvarMeleeIncap_Refire_Delay_Multi.AddChangeHook(ConVarChanged_Cvars);
	}

	AddCommandListener(CmdListen_weapon_reparse_server, "weapon_reparse_server");
	if(g_bL4D2Version)
	{
		AddCommandListener(CmdListen_weapon_reparse_server, "melee_reload_info_server");
	}
}

ConVar g_hWeaponHandling_UseIncapCycle;
bool g_bWeaponHandling_UseIncapCycle;
public void OnAllPluginsLoaded()
{
	g_hWeaponHandling_UseIncapCycle = FindConVar("wh_use_incap_cycle_cvar");
	Get_incap_cycle();
	g_hWeaponHandling_UseIncapCycle.AddChangeHook(ConVarChanged_incap_cycle);
}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_fIncapCycle = g_hCvar_IncapCycle.FloatValue;

	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_fCvarDualPistol_CycleTime = g_hCvarDualPistol_CycleTime.FloatValue;
	g_fCvarDualPistol_ReloadDuration = g_hCvarDualPistol_ReloadDuration.FloatValue;
	g_bCvarShotGun_Fix_CycleTime = g_hCvarShotGun_Fix_CycleTime.BoolValue;
	g_bCvarShotGun_Fix_ReloadDuration = g_hCvarShotGun_Fix_ReloadDuration.BoolValue;
	g_bCvarWeaponIncap_Fix_CycleTime = g_hCvarWeaponIncap_Fix_CycleTime.BoolValue;
	if(g_bL4D2Version)
	{
		g_bCvarMelee_Fix_Refire_Delay = g_hCvarMelee_Fix_Refire_Delay.BoolValue;
		g_fCvarMeleeIncap_Refire_Delay_Multi = g_hCvarMeleeIncap_Refire_Delay_Multi.FloatValue;
	}
}

void ConVarChanged_incap_cycle(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	Get_incap_cycle();
}

void Get_incap_cycle()
{
	g_bWeaponHandling_UseIncapCycle = g_hWeaponHandling_UseIncapCycle.BoolValue;
}

// Sourcemod API Forward-------------------------------

public void OnConfigsExecuted()
{
	GetMeleeTable();
	GetWeaponDataInfo();
}

// Command-------------------------------

Action CmdListen_weapon_reparse_server(int client, const char[] command, int argc)
{
	RequestFrame(OnNextFrame_weapon_reparse_server);

	return Plugin_Continue;
}

void OnNextFrame_weapon_reparse_server()
{
	GetMeleeTable();
	GetWeaponDataInfo();
}

// WeaponHandling API-------------------------------

public void WH_OnGetRateOfFire(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	if(!g_bCvarEnable) return;

	DebugPrint("WH_OnGetRateOfFire %N - %.3f", client, speedmodifier);

	if(g_bCvarWeaponIncap_Fix_CycleTime && g_bWeaponHandling_UseIncapCycle && GetEntProp(client, Prop_Send, "m_isIncapacitated", 1))
	{
		switch(weapontype)
		{
			case L4D2WeaponType_Pistol:
			{
				if(GetEntProp(weapon, Prop_Send, "m_isDualWielding", 1))
				{
					if(g_fCvarDualPistol_CycleTime == 0.0) return;
					if(g_fCvarDualPistol_CycleTime <= g_fIncapCycle) return;

					speedmodifier = g_fIncapCycle *(1.0/g_fCvarDualPistol_CycleTime);
					return;
				}
			}
		}

		if( !g_bCvarShotGun_Fix_CycleTime &&
			(weapontype == L4D2WeaponType_Pumpshotgun) ||
			(weapontype == L4D2WeaponType_Pumpshotgun) || 
			(weapontype == L4D2WeaponType_Autoshotgun) ||
			(weapontype == L4D2WeaponType_AutoshotgunSpas) ) return;

		if(g_fWeapon_CycleTime[weapontype] <= g_fIncapCycle) return;

		speedmodifier = g_fIncapCycle *(1.0/g_fWeapon_CycleTime[weapontype]);
	}
	else
	{
		switch(weapontype)
		{
			case L4D2WeaponType_Pistol:
			{
				if(GetEntProp(weapon, Prop_Send, "m_isDualWielding", 1))
				{
					if(g_fCvarDualPistol_CycleTime == 0.0) return;

					speedmodifier = (GetEntProp(weapon, Prop_Send, "m_iClip1") <= 0) ? 0.075 * (1.0/0.2) : 0.075 *(1.0/g_fCvarDualPistol_CycleTime); // dual pistol "CycleTime" = 0.075 
				}
				/*else
				{
					speedmodifier = (GetEntProp(weapon, Prop_Send, "m_iClip1") <= 0) ? 0.175 * (1.0/0.2625) : 0.175 *(1.0/g_fWeapon_CycleTime[L4D2WeaponType_Pistol]); // single pistol "CycleTime" = 0.175 
				}*/
			}
			case L4D2WeaponType_Pumpshotgun:
			{
				if(!g_bCvarShotGun_Fix_CycleTime) return;
				if(g_fWeapon_CycleTime[L4D2WeaponType_Pumpshotgun] <= 0.0) return;

				speedmodifier = (GetEntProp(weapon, Prop_Send, "m_iClip1") <= 0) ? 1.0 : 0.875 *(1.0/g_fWeapon_CycleTime[L4D2WeaponType_Pumpshotgun]); // Pumpshotgun "CycleTime" = 0.875 
			}
			case L4D2WeaponType_PumpshotgunChrome:
			{
				if(!g_bCvarShotGun_Fix_CycleTime) return;
				if(g_fWeapon_CycleTime[L4D2WeaponType_PumpshotgunChrome] <= 0.0) return;

				speedmodifier = (GetEntProp(weapon, Prop_Send, "m_iClip1") <= 0) ? 1.0 : 0.875 *(1.0/g_fWeapon_CycleTime[L4D2WeaponType_PumpshotgunChrome]); // PumpshotgunChrome "CycleTime" = 0.875 
			}
			case L4D2WeaponType_Autoshotgun:
			{
				if(!g_bCvarShotGun_Fix_CycleTime) return;
				if(g_fWeapon_CycleTime[L4D2WeaponType_Autoshotgun] <= 0.0) return;

				speedmodifier = (GetEntProp(weapon, Prop_Send, "m_iClip1") <= 0) ? 1.0 : 0.250 *(1.0/g_fWeapon_CycleTime[L4D2WeaponType_Autoshotgun]); // Autoshotgun "CycleTime" = 0.250 
			}
			case L4D2WeaponType_AutoshotgunSpas:
			{
				if(!g_bCvarShotGun_Fix_CycleTime) return;
				if(g_fWeapon_CycleTime[L4D2WeaponType_AutoshotgunSpas] <= 0.0) return;

				speedmodifier = (GetEntProp(weapon, Prop_Send, "m_iClip1") <= 0) ? 1.0 : 0.250 *(1.0/g_fWeapon_CycleTime[L4D2WeaponType_AutoshotgunSpas]); // AutoshotgunSpas "CycleTime" = 0.250 
			}
		}
	}

	DebugPrint("WH_OnGetRateOfFire finish %N - %.3f", client, speedmodifier);
}

public void WH_OnReloadModifier(int client, int weapon, L4D2WeaponType weapontype, float &speedmodifier)
{
	if(!g_bCvarEnable) return;

	DebugPrint("WH_OnReloadModifier %N - %.3f", client, speedmodifier);
	switch(weapontype)
	{
		case L4D2WeaponType_Pistol:
		{
			if(GetEntProp(weapon, Prop_Send, "m_isDualWielding", 1))
			{
				if(g_fCvarDualPistol_ReloadDuration == 0.0) return;

				speedmodifier = 2.35 * (1.0/g_fCvarDualPistol_ReloadDuration); // dual pistol "ReloadDuration" = 2.333
			}
		}
		case L4D2WeaponType_Pumpshotgun:
		{
			if(!g_bCvarShotGun_Fix_ReloadDuration) return;
			if(g_fWeapon_ReloadDuration[L4D2WeaponType_Pumpshotgun] <= 0.0) return;

			speedmodifier = 0.525 *(1.0/g_fWeapon_ReloadDuration[L4D2WeaponType_Pumpshotgun]); // Pumpshotgun "CycleTime" = 0.525
		}
		case L4D2WeaponType_PumpshotgunChrome:
		{
			if(!g_bCvarShotGun_Fix_ReloadDuration) return;
			if(g_fWeapon_ReloadDuration[L4D2WeaponType_PumpshotgunChrome] <= 0.0) return;

			speedmodifier = 0.525 *(1.0/g_fWeapon_ReloadDuration[L4D2WeaponType_PumpshotgunChrome]); // PumpshotgunChrome "CycleTime" = 0.525
		}
		case L4D2WeaponType_Autoshotgun:
		{
			if(!g_bCvarShotGun_Fix_ReloadDuration) return;
			if(g_fWeapon_ReloadDuration[L4D2WeaponType_Autoshotgun] <= 0.0) return;

			speedmodifier = 0.400 *(1.0/g_fWeapon_ReloadDuration[L4D2WeaponType_Autoshotgun]); // Autoshotgun "CycleTime" = 0.400
		}
		case L4D2WeaponType_AutoshotgunSpas:
		{
			if(!g_bCvarShotGun_Fix_ReloadDuration) return;
			if(g_fWeapon_ReloadDuration[L4D2WeaponType_AutoshotgunSpas] <= 0.0) return;

			speedmodifier = 0.400 *(1.0/g_fWeapon_ReloadDuration[L4D2WeaponType_AutoshotgunSpas]); // AutoshotgunSpas "CycleTime" = 0.400
		}
	}
	DebugPrint("WH_OnReloadModifier finish %N - %.3f", client, speedmodifier);
}

public void WH_OnMeleeSwing(int client, int weapon, float &speedmodifier)
{
	if(!g_bCvarEnable) return;

	int meleeWeaponId = GetEntProp(weapon, Prop_Send, "m_hMeleeWeaponInfo");
	if (meleeWeaponId < 0 || meleeWeaponId >= g_iMeleeClassCount)
		return;

	float fRealDelay = GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") - GetGameTime();
	DebugPrint(" (%s) refire_delay: %.3f, fRealDelay: %.3f", g_sMeleeClass[meleeWeaponId], g_fMelee_RefireDelay[meleeWeaponId], fRealDelay);

	if(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1))
	{
		if(g_bCvarMelee_Fix_Refire_Delay)
		{
			if(g_fCvarMeleeIncap_Refire_Delay_Multi > 0.0)
			{
				speedmodifier = fRealDelay * (1/(g_fMelee_RefireDelay[meleeWeaponId]*g_fCvarMeleeIncap_Refire_Delay_Multi));
			}
			else
			{
				speedmodifier = fRealDelay * (1/g_fMelee_RefireDelay[meleeWeaponId]);
			}
		}
		else
		{
			if(g_fCvarMeleeIncap_Refire_Delay_Multi > 0.0)
			{
				speedmodifier = fRealDelay * (1/(fRealDelay*g_fCvarMeleeIncap_Refire_Delay_Multi));
			}
		}
	}
	else
	{
		if(!g_bCvarMelee_Fix_Refire_Delay) return;

		speedmodifier = fRealDelay * (1/g_fMelee_RefireDelay[meleeWeaponId]);
	}

	DebugPrint("WH_OnMeleeSwing finish - %.3f", client, speedmodifier);
}

// ====================================================================================================
// KEYBINDS
// ====================================================================================================
public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
	if (!(buttons & IN_ATTACK2)) {
		return;
	}
	
	if (!client || !IsClientInGame(client) || GetClientTeam(client) != TEAM_SURVIVOR || !IsPlayerAlive(client)) {
		return;
	}

	int ActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if( ActiveWeapon == -1 )
		return;

	if (HasEntProp(ActiveWeapon, Prop_Send, "m_bInReload") == false || GetEntProp(ActiveWeapon, Prop_Send, "m_bInReload") == 0)
		return;

	static char sClassname[64];
	GetClientWeapon(client, sClassname, sizeof(sClassname));

	L4D2WeaponType weapontype = GetWeaponTypeFromClassname(sClassname);
	if(weapontype == L4D2WeaponType_Unknown) return;

	/*float m_flPlaybackRate = GetEntPropFloat(ActiveWeapon, Prop_Send, "m_flPlaybackRate");
	PrintToChatAll("%d %s %f", weapontype, sClassname, m_flPlaybackRate);
	if(m_flPlaybackRate >= 1.0) //裝彈比原本快
	{
		if(g_fATTACK2Timeout[client] > GetEngineTime()) return; 

		g_fATTACK2Timeout[client] = GetEngineTime() + 3.8;
	}*/

	float playbackRate;
	int clip = GetEntProp(ActiveWeapon, Prop_Send, "m_iClip1");
	if(weapontype == L4D2WeaponType_Pistol)
	{
		if(GetEntProp(ActiveWeapon, Prop_Send, "m_isDualWielding", 1))
		{
			if(g_fCvarDualPistol_ReloadDuration == 0.0)
			{
				return;
			}
			else
			{
				if(clip <= 1) 
				{
					playbackRate = 2.516 / g_fCvarDualPistol_ReloadDuration;
				}
				else
				{
					playbackRate = 2.35 / g_fCvarDualPistol_ReloadDuration;
				}
			}
		}
		else
		{
			if(g_fWeapon_ReloadDuration[L4D2WeaponType_Pistol] <= 0.0)
			{
				DebugPrint("該武器沒設定裝彈時間: %s", sClassname);
				return;
			}

			if(clip == 0) 
			{
				playbackRate = 2.016 / g_fWeapon_ReloadDuration[L4D2WeaponType_Pistol];
			}
			else
			{
				playbackRate = 1.68 / g_fWeapon_ReloadDuration[L4D2WeaponType_Pistol];
			}
		}
	}
	else
	{
		if(g_fWeapon_ReloadDuration[weapontype] <= 0.0)
		{
			DebugPrint("該武器沒設定裝彈時間: %s", sClassname);
			return;
		}

		switch(weapontype)
		{
			case L4D2WeaponType_Pistol:
			{

			}
			case L4D2WeaponType_Magnum:
			{
				if(clip == 0) 
				{
					playbackRate = 2.016 / g_fWeapon_ReloadDuration[L4D2WeaponType_Pistol];
				}
				else
				{
					playbackRate = 1.65 / g_fWeapon_ReloadDuration[L4D2WeaponType_Pistol];
				}
			}
			case L4D2WeaponType_Rifle:
			{
				playbackRate = 2.216 / g_fWeapon_ReloadDuration[L4D2WeaponType_Rifle];
			}
			case L4D2WeaponType_RifleAk47:
			{
				playbackRate = 2.373 / g_fWeapon_ReloadDuration[L4D2WeaponType_RifleAk47];
			}
			case L4D2WeaponType_RifleDesert:
			{
				playbackRate = 3.316 / g_fWeapon_ReloadDuration[L4D2WeaponType_RifleDesert];
			}
			case L4D2WeaponType_RifleM60:
			{
				playbackRate = 2.4 / g_fWeapon_ReloadDuration[L4D2WeaponType_RifleM60];
			}
			case L4D2WeaponType_RifleSg552:
			{
				playbackRate = 3.433 / g_fWeapon_ReloadDuration[L4D2WeaponType_RifleSg552];
			}
			case L4D2WeaponType_HuntingRifle:
			{
				playbackRate = 3.14 / g_fWeapon_ReloadDuration[L4D2WeaponType_HuntingRifle];
			}
			case L4D2WeaponType_SniperAwp:
			{
				playbackRate = 3.66 / g_fWeapon_ReloadDuration[L4D2WeaponType_SniperAwp];
			}
			case L4D2WeaponType_SniperMilitary:
			{
				playbackRate = 3.35 / g_fWeapon_ReloadDuration[L4D2WeaponType_SniperMilitary];
			}
			case L4D2WeaponType_SniperScout:
			{
				playbackRate = 2.916 / g_fWeapon_ReloadDuration[L4D2WeaponType_SniperScout];
			}
			case L4D2WeaponType_SMG:
			{
				playbackRate = 2.251 / g_fWeapon_ReloadDuration[L4D2WeaponType_SMG];
			}
			case L4D2WeaponType_SMGSilenced:
			{
				playbackRate = 2.251 / g_fWeapon_ReloadDuration[L4D2WeaponType_SMGSilenced];
			}
			case L4D2WeaponType_SMGMp5:
			{
				playbackRate = 3.069 / g_fWeapon_ReloadDuration[L4D2WeaponType_Magnum];
			}
			case L4D2WeaponType_GrenadeLauncher:
			{
				playbackRate = 3.35 / g_fWeapon_ReloadDuration[L4D2WeaponType_GrenadeLauncher];
			}
			default:
			{
				return;
			}
		}
	}

	//PrintToChatAll("playbackRate %f", playbackRate);
	SetEntPropFloat(ActiveWeapon, Prop_Send, "m_flPlaybackRate", playbackRate);
}

// Function-------------------------------

void GetWeaponDataInfo()
{
	g_fWeapon_CycleTime[L4D2WeaponType_Pistol] = L4D2_GetFloatWeaponAttribute("weapon_pistol", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_Magnum] = L4D2_GetFloatWeaponAttribute("weapon_pistol_magnum", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_Rifle] = L4D2_GetFloatWeaponAttribute("weapon_rifle", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_RifleAk47] = L4D2_GetFloatWeaponAttribute("weapon_rifle_ak47", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_RifleDesert] = L4D2_GetFloatWeaponAttribute("weapon_rifle_desert", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_RifleM60] = L4D2_GetFloatWeaponAttribute("weapon_rifle_m60", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_RifleSg552] = L4D2_GetFloatWeaponAttribute("weapon_rifle_sg552", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_HuntingRifle] = L4D2_GetFloatWeaponAttribute("weapon_hunting_rifle", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_SniperAwp] = L4D2_GetFloatWeaponAttribute("weapon_sniper_awp", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_SniperMilitary] = L4D2_GetFloatWeaponAttribute("weapon_sniper_military", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_SniperScout] = L4D2_GetFloatWeaponAttribute("weapon_sniper_scout", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_SMG] = L4D2_GetFloatWeaponAttribute("weapon_smg", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_SMGSilenced] = L4D2_GetFloatWeaponAttribute("weapon_smg_silenced", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_SMGMp5] = L4D2_GetFloatWeaponAttribute("weapon_smg_mp5", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_Autoshotgun] = L4D2_GetFloatWeaponAttribute("weapon_autoshotgun", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_AutoshotgunSpas] = L4D2_GetFloatWeaponAttribute("weapon_shotgun_spas", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_Pumpshotgun] = L4D2_GetFloatWeaponAttribute("weapon_pumpshotgun", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_PumpshotgunChrome] = L4D2_GetFloatWeaponAttribute("weapon_shotgun_chrome", L4D2FWA_CycleTime);
	g_fWeapon_CycleTime[L4D2WeaponType_GrenadeLauncher] = L4D2_GetFloatWeaponAttribute("weapon_grenade_launcher", L4D2FWA_CycleTime);
	
	g_fWeapon_ReloadDuration[L4D2WeaponType_Pistol] = L4D2_GetFloatWeaponAttribute("weapon_pistol", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_Magnum] = L4D2_GetFloatWeaponAttribute("weapon_pistol_magnum", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_Rifle] = L4D2_GetFloatWeaponAttribute("weapon_rifle", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_RifleAk47] = L4D2_GetFloatWeaponAttribute("weapon_rifle_ak47", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_RifleDesert] = L4D2_GetFloatWeaponAttribute("weapon_rifle_desert", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_RifleM60] = L4D2_GetFloatWeaponAttribute("weapon_rifle_m60", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_RifleSg552] = L4D2_GetFloatWeaponAttribute("weapon_rifle_sg552", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_HuntingRifle] = L4D2_GetFloatWeaponAttribute("weapon_hunting_rifle", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_SniperAwp] = L4D2_GetFloatWeaponAttribute("weapon_sniper_awp", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_SniperMilitary] = L4D2_GetFloatWeaponAttribute("weapon_sniper_military", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_SniperScout] = L4D2_GetFloatWeaponAttribute("weapon_sniper_scout", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_SMG] = L4D2_GetFloatWeaponAttribute("weapon_smg", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_SMGSilenced] = L4D2_GetFloatWeaponAttribute("weapon_smg_silenced", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_SMGMp5] = L4D2_GetFloatWeaponAttribute("weapon_smg_mp5", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_Autoshotgun] = L4D2_GetFloatWeaponAttribute("weapon_autoshotgun", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_AutoshotgunSpas] = L4D2_GetFloatWeaponAttribute("weapon_shotgun_spas", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_Pumpshotgun] = L4D2_GetFloatWeaponAttribute("weapon_pumpshotgun", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_PumpshotgunChrome] = L4D2_GetFloatWeaponAttribute("weapon_shotgun_chrome", L4D2FWA_ReloadDuration);
	g_fWeapon_ReloadDuration[L4D2WeaponType_GrenadeLauncher] = L4D2_GetFloatWeaponAttribute("weapon_grenade_launcher", L4D2FWA_ReloadDuration);

	for (int meleeWeaponId = 0; meleeWeaponId < g_iMeleeClassCount; meleeWeaponId++) 
	{
		g_fMelee_RefireDelay[meleeWeaponId] = L4D2_GetFloatMeleeAttribute(meleeWeaponId, L4D2FMWA_RefireDelay);
	}
}

void GetMeleeTable()
{
    int table = FindStringTable("meleeweapons");
    if (table != INVALID_STRING_TABLE) 
    {
        g_iMeleeClassCount = GetStringTableNumStrings(table);

        for (int i = 0; i < g_iMeleeClassCount; i++) 
        {
            ReadStringTable(table, i, g_sMeleeClass[i], sizeof(g_sMeleeClass[]));
        }
    }
}

/* Debug */
stock void DebugPrint(const char[] Message, any ...)
{
    #if DEBUG
        char DebugBuff[256];
        VFormat(DebugBuff, sizeof(DebugBuff), Message, 2);
        PrintToChatAll("%s",DebugBuff);
        PrintToServer(DebugBuff);
    #endif 
}
