/**
 * Newly-rescued Survivors start with 50 permanent health, a random tier 1 weapon, and a single P220 Pistol. 
 * Their primary tier 1 weapon is determined by what weapons you had when you died:
 * If you died with an assault rifle (Combat Rifle, AK-47, or M16 Assault Rifle) or a submachine gun (normal or silenced), you will respawn with a submachine gun (with a chance for a Silenced Submachine Gun instead in Left 4 Dead 2);
 * If you died with a shotgun (Chrome, Pump, Auto or Combat) or Grenade Launcher, you are given a Pump Shotgun (with a chance for a Chrome Shotgun instead in Left 4 Dead 2);
 * If you died with a Hunting or Sniper Rifle, you will have a 60% chance of getting a submachine gun and a 40% chance of a shotgun.
 * 
 * This plugin tries to fix the following situations
 * 1. If you died with M60, you will respawn with M60 full clip (This is bug)
 * 2. If you died with any weapons and mission lost in coop/realism, you will have T1 weapons after new round starts (Usually happen after changelevel map 2...)
 */

/**
 * L4D2 Windows/Linux
 * CTerrorPlayer,m_knockdownTimer + 100 = 死前所持主武器weapon ID
 * CTerrorPlayer,m_knockdownTimer + 104 = 死前所持主武器ammo
 * CTerrorPlayer,m_knockdownTimer + 108 = 死前所持副武器weapon ID
 * CTerrorPlayer,m_knockdownTimer + 112 = 死前所持副武器是否双持
 * CTerrorPlayer,m_knockdownTimer + 116 = 死前所持非手枪副武器EHandle
 */

/**
 * Related Official l4d2 cvars
 * survivor_respawn_with_guns               : 1        : , "sv", "launcher" : 0: Just a pistol, 1: Downgrade of last primary weapon, 2: Last primary weapon.
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <l4d2_weapons>
#define PLUGIN_VERSION			"1.1"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D/L4D2] Death Weapon Respawn Fix",
	author = "HarryPotter",
	description = "In coop/realism, if you died with primary weapon, you will respawn with T1 weapon. Delete datas if hold M60 or mission lost",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define TEAM_SURVIVOR                 2

ConVar g_hCvarEnable, g_hAmmoShotgun, g_hAmmoSmg, survivor_respawn_with_guns;
int g_iAmmoShotgun, g_iAmmoSmg, iOffiicalCvar_survivor_respawn_with_guns;
bool g_bCvarEnable;

static int iOffs_m_PrimaryWeaponIDPreDead = -1;
static int iOffs_m_PrimaryWeaponAmmo = -1;
bool g_bMissionLost;

public void OnPluginStart()
{
    iOffs_m_PrimaryWeaponIDPreDead  = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 100;
    iOffs_m_PrimaryWeaponAmmo       = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 104;

    g_hCvarEnable 		= CreateConVar("l4d_death_weapon_respawn_fix_enable",        "1",    "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                      "l4d_death_weapon_respawn_fix_version",       PLUGIN_VERSION, "l4d_death_weapon_respawn_fix Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,               "l4d_death_weapon_respawn_fix");

    survivor_respawn_with_guns = FindConVar("survivor_respawn_with_guns");
    g_hAmmoSmg =			FindConVar("ammo_smg_max");
    g_hAmmoShotgun =	    FindConVar("ammo_shotgun_max");

    GetCvars();
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
    survivor_respawn_with_guns.AddChangeHook(ConVarChanged_Cvars);
    g_hAmmoSmg.AddChangeHook(ConVarChanged_Cvars);
    g_hAmmoShotgun.AddChangeHook(ConVarChanged_Cvars);

    HookEvent("round_start",            Event_RoundStart);
    HookEvent("mission_lost", 			Event_MissionLost,		EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
    
    HookEvent("player_death",           Event_PlayerDeath);

    GetCvars();
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
}

public void ConVarChanged_Cvars(Handle hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarEnable = g_hCvarEnable.BoolValue;

    iOffiicalCvar_survivor_respawn_with_guns = survivor_respawn_with_guns.IntValue;
    g_iAmmoShotgun		= g_hAmmoShotgun.IntValue;
    g_iAmmoSmg			= g_hAmmoSmg.IntValue;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
    g_bMissionLost = false;
}

public void Event_MissionLost(Event event, const char[] name, bool dontBroadcast) 
{
    if(!g_bCvarEnable) return;

    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i))
        {
            SetPrimaryWeaponIDPreDead(i, 0);
        }
    }

    g_bMissionLost = true;
}

public void Event_PlayerDeath (Event event, const char[] name, bool dontBroadcast)
{
    if(!g_bCvarEnable) return;

    int victim = GetClientOfUserId(event.GetInt("userid"));
    if (!victim || !IsClientInGame(victim) || GetClientTeam(victim) != TEAM_SURVIVOR) return;

    int PrimaryWeaponIDPreDead = GetPrimaryWeaponIDPreDead(victim);
    DebugPrint("%N's primary weapon ID: %d, ammo: %d", victim, PrimaryWeaponIDPreDead, GetPrimaryWeaponAmmo(victim));
    if(g_bMissionLost)
    {
        SetPrimaryWeaponIDPreDead(victim, 0);
        return;
    }

    if(PrimaryWeaponIDPreDead == WEPID_RIFLE_M60)
    {
        if(iOffiicalCvar_survivor_respawn_with_guns == 0) // 0: Just a pistol
        {
            SetPrimaryWeaponIDPreDead(victim, 0);
        }
        else if(iOffiicalCvar_survivor_respawn_with_guns == 1) // 1: Downgrade of last primary weapon
        {
            switch(GetRandomInt(1,4))
            {
                case 1:
                {
                    SetPrimaryWeaponIDPreDead(victim, WEPID_SMG);
                    SetPrimaryWeaponAmmo(victim, g_iAmmoSmg);
                }
                case 2: 
                {
                    SetPrimaryWeaponIDPreDead(victim, WEPID_SMG_SILENCED);
                    SetPrimaryWeaponAmmo(victim, g_iAmmoSmg);
                }
                case 3:
                {
                    SetPrimaryWeaponIDPreDead(victim, WEPID_PUMPSHOTGUN);
                    SetPrimaryWeaponAmmo(victim, g_iAmmoShotgun);
                }
                case 4:
                {
                    SetPrimaryWeaponIDPreDead(victim, WEPID_SHOTGUN_CHROME);
                    SetPrimaryWeaponAmmo(victim, g_iAmmoShotgun);
                }
            }
        }
        else if(iOffiicalCvar_survivor_respawn_with_guns == 2) // 2: Last primary weapon.
        {
            //do nothing
        }
    }
}

int GetPrimaryWeaponIDPreDead(int client)
{
	return GetEntData(client, iOffs_m_PrimaryWeaponIDPreDead);
}

void SetPrimaryWeaponIDPreDead(int client, int weaponID)
{
	SetEntData(client, iOffs_m_PrimaryWeaponIDPreDead, weaponID);
}

int GetPrimaryWeaponAmmo(int client)
{
	return GetEntData(client, iOffs_m_PrimaryWeaponAmmo);
}

void SetPrimaryWeaponAmmo(int client, int ammo)
{
	SetEntData(client, iOffs_m_PrimaryWeaponAmmo, ammo);
}

stock void DebugPrint(const char[] Message, any ...)
{
    #if DEBUG
        char DebugBuff[128];
        VFormat(DebugBuff, sizeof(DebugBuff), Message, 2);
        PrintToChatAll("%s",DebugBuff);
        PrintToServer(DebugBuff);
        LogMessage(DebugBuff);
    #endif 
}
