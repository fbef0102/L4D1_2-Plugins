#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <dhooks>
#include <left4dhooks>
#include <sendproxy>  //https://github.com/jensewe/Left4SendProxy/releases

#define PLUGIN_VERSION	"2.7-2026/6/26"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "[L4D1/2] weapon cs2 reload",
	author = "Harry Potter",
	description = "(CSGO or CS2 Reload Mechanism) Modern weapon reload + Abandon magazine when reload in L4D1/2",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

bool bLate, g_bL4D2Version;
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
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	bLate = late;
	return APLRes_Success;
}

#define GAMEDATA_FILE           	 "l4d2_weapon_csgo_reload"
#define MAXENTITIES                   2048
#define PISTOL_RELOAD_INCAP_MULTIPLY_L4D2 1.25
#define PISTOL_RELOAD_INCAP_MULTIPLY_L4D1 1.3

ConVar g_hAmmoGL, g_hAmmoHunting, g_hAmmoM60, g_hAmmoRifle, g_hAmmoSmg, g_hAmmoSniper;
int g_iAmmoGL, g_iAmmoHunting, g_iAmmoM60, g_iAmmoRifle, g_iAmmoSmg, g_iAmmoSniper;

ConVar g_hCvarEnable, g_hCvarMagazineReloadType, hSmgTimeCvar, hRifleTimeCvar, hHuntingRifleTimeCvar,
	hPistolTimeCvar, hDualPistolTimeCvar, hSmgSilencedTimeCvar, hSmgMP5TimeCvar, hAK47TimeCvar, hRifleDesertTimeCvar,
	hSniperMilitaryTimeCvar, hGrenadeTimeCvar, hSG552TimeCvar, hAWPTimeCvar, hScoutTimeCvar, hMangumTimeCvar, hM60TimeCvar;

bool g_bCvarEnable;
int g_iCvarMagazineReloadType;
float g_SmgTimeCvar, g_RifleTimeCvar, g_HuntingRifleTimeCvar, g_PistolTimeCvar,
	g_DualPistolTimeCvar, g_SmgSilencedTimeCvar, g_SmgMP5TimeCvar, g_AK47TimeCvar, g_RifleDesertTimeCvar,
	g_SniperMilitaryTimeCvar, g_GrenadeTimeCvar, g_SG552TimeCvar, g_AWPTimeCvar, g_ScoutTimeCvar, g_MangumTimeCvar,
	g_M60TimeCvar;

enum WeaponID
{
	ID_NONE,
	ID_PISTOL,
	ID_DUAL_PISTOL,
	ID_SMG,
	//ID_PUMPSHOTGUN,
	ID_RIFLE,
	//ID_AUTOSHOTGUN,
	ID_HUNTING_RIFLE,
	ID_SMG_SILENCED,
	ID_SMG_MP5,
	//ID_CHROMESHOTGUN,
	ID_MAGNUM,
	ID_AK47,
	ID_RIFLE_DESERT,
	ID_SNIPER_MILITARY,
	ID_GRENADE,
	ID_SG552,
	ID_M60,
	ID_AWP,
	ID_SCOUT,
	//ID_SPASSHOTGUN,
	ID_WEAPON_MAX
}

WeaponID
	g_iGlobalWeaponId[MAXENTITIES+1];

enum L4D2_AmmoType
{
	L4D2_AmmoType_Null = -1,
	L4D2_AmmoType_None = 0,

	L4D2_AmmoType_AssaultRifle = 3,
	L4D2_AmmoType_Minigun,
	L4D2_AmmoType_Smg, //5
	L4D2_AmmoType_M60,
	L4D2_AmmoType_Shotgun,
	L4D2_AmmoType_Autoshotgun,
	L4D2_AmmoType_HuntingRifle,
	L4D2_AmmoType_SniperRifle, //10
	L4D2_AmmoType_Turret,
	L4D2_AmmoType_PipeBomb,
	L4D2_AmmoType_Molotov,
	L4D2_AmmoType_VomitJar,
	L4D2_AmmoType_PainPills, //15
	L4D2_AmmoType_FirstAid,
	L4D2_AmmoType_GrenadeLauncher,
	L4D2_AmmoType_Adrenaline,
	L4D2_AmmoType_Chainsaw,
	L4D2_AmmoType_CarriedItem, //20

	L4D2_AmmoType_MAX = 32
};

enum L4D1_AmmoType
{
	L4D1_AmmoType_Null = -1,
	L4D1_AmmoType_None = 0,

	L4D1_AmmoType_HuntingRifle = 2,
	L4D1_AmmoType_AssaultRifle = 3,

	L4D1_AmmoType_Smg = 5,
	L4D1_AmmoType_Shotgun = 6,

	L4D1_AmmoType_MAX = 32
};

StringMap 
	g_smWeaponNameID;

float 
	g_fClientReload_Time[MAXPLAYERS+1]	= {0.0};

int 
	WeaponMaxClip[view_as<int>(ID_WEAPON_MAX)],
	g_iGlobalWeapon_FakeMagazineLeft[MAXENTITIES+1],
	g_iOffsetActive,
	g_iOffsetClip,
	g_iOffsetPrimaryAmmoType,
	g_iOffsetInReload,
	g_iOffsetAmmo,
	g_iOffset_PistolisDualWielding;

public void OnPluginStart()
{
	g_iOffsetActive 				= FindSendPropInfo("CBaseCombatCharacter","m_hActiveWeapon");
	g_iOffsetClip					= FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	g_iOffsetPrimaryAmmoType 		= FindSendPropInfo("CBaseCombatWeapon", "m_iPrimaryAmmoType");
	g_iOffsetInReload 				= FindSendPropInfo("CBaseCombatWeapon", "m_bInReload");
	g_iOffsetAmmo 					= FindSendPropInfo("CCSPlayer", "m_iAmmo");
	g_iOffset_PistolisDualWielding 	= FindSendPropInfo("CPistol", "m_isDualWielding");

	if(!g_bL4D2Version)
	{
		GameData hGameData = new GameData(GAMEDATA_FILE);
		if( hGameData == null ) SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA_FILE);

		Handle hDetour = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Bool, ThisPointer_CBaseEntity);
		if( !hDetour )
			SetFailState("Failed to setup detour handle: CTerrorGun::Reload");

		if( !DHookSetFromConf(hDetour, hGameData, SDKConf_Signature, "CTerrorGun::Reload") )
			SetFailState("Failed to find signature: CTerrorGun::Reload");

		if( !DHookEnableDetour(hDetour, false, L4D1_OnGunReload_Pre) )
			SetFailState("Failed to detour: CTerrorGun::Reload");

		delete hDetour;
		delete hGameData;
	}

	g_hAmmoRifle =		FindConVar("ammo_assaultrifle_max");
	g_hAmmoSmg =		FindConVar("ammo_smg_max");
	g_hAmmoHunting =	FindConVar("ammo_huntingrifle_max");
	if(g_bL4D2Version)
	{
		g_hAmmoGL =			FindConVar("ammo_grenadelauncher_max");
		g_hAmmoM60 =		FindConVar("ammo_m60_max");
		g_hAmmoSniper =		FindConVar("ammo_sniperrifle_max");
	}

	GetAmmoCvars();
	g_hAmmoRifle.AddChangeHook(ConVarChanged_AmmoCvars);
	g_hAmmoSmg.AddChangeHook(ConVarChanged_AmmoCvars);
	g_hAmmoHunting.AddChangeHook(ConVarChanged_AmmoCvars);
	if(g_bL4D2Version)
	{
		g_hAmmoGL.AddChangeHook(ConVarChanged_AmmoCvars);
		g_hAmmoM60.AddChangeHook(ConVarChanged_AmmoCvars);
		g_hAmmoSniper.AddChangeHook(ConVarChanged_AmmoCvars);
	}

	g_hCvarEnable				= CreateConVar("l4d2_weapon_csgo_reload_allow", 			"1", 	"0=Plugin off, 1=Plugin on." 			  , FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarMagazineReloadType	= CreateConVar("l4d2_weapon_csgo_reload_magazine_type", 	"1", 	"Choose weapon reload method\n0=CSGO style: Don't drop the entire magazine\n1=CS2 style: Drop the entire magazine when finish reloading, reserve ammo is displayed as exact magazines instead of total bullets.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	if(g_bL4D2Version)
	{
		hSmgTimeCvar			= CreateConVar("l4d2_smg_reload_clip_time", 			"1.04", "(L4D2) reload time for smg clip"				  , FCVAR_NOTIFY, true, 0.0);
		hRifleTimeCvar			= CreateConVar("l4d2_rifle_reload_clip_time", 			"1.2",  "(L4D2) reload time for rifle clip"			  , FCVAR_NOTIFY, true, 0.0);
		hHuntingRifleTimeCvar   = CreateConVar("l4d2_huntingrifle_reload_clip_time", 	"2.6",  "(L4D2) reload time for hunting rifle clip"	  , FCVAR_NOTIFY, true, 0.0);
		hPistolTimeCvar 		= CreateConVar("l4d2_pistol_reload_clip_time", 			"1.2",  "(L4D2) reload time for pistol clip"		      , FCVAR_NOTIFY, true, 0.0);
		hDualPistolTimeCvar 	= CreateConVar("l4d2_dualpistol_reload_clip_time", 		"1.75", "(L4D2) reload time for dual pistol clip"        , FCVAR_NOTIFY, true, 0.0);
		hSmgSilencedTimeCvar	= CreateConVar("l4d2_smgsilenced_reload_clip_time", 	"1.05", "(L4D2) reload time for smg silenced clip"       , FCVAR_NOTIFY, true, 0.0);
		hSmgMP5TimeCvar			= CreateConVar("l4d2_smgmp5_reload_clip_time", 			"1.7",  "(L4D2) reload time for smg mp5 clip"      	  , FCVAR_NOTIFY, true, 0.0);
		hAK47TimeCvar			= CreateConVar("l4d2_ak47_reload_clip_time", 			"1.2",  "(L4D2) reload time for ak47 clip"      		  , FCVAR_NOTIFY, true, 0.0);
		hRifleDesertTimeCvar	= CreateConVar("l4d2_desertrifle_reload_clip_time", 	"1.8",  "(L4D2) reload time for desert rifle clip"       , FCVAR_NOTIFY, true, 0.0);
		hSniperMilitaryTimeCvar	= CreateConVar("l4d2_snipermilitary_reload_clip_time", 	"1.8",  "(L4D2) reload time for sniper military clip"    , FCVAR_NOTIFY, true, 0.0);
		hGrenadeTimeCvar		= CreateConVar("l4d2_grenade_reload_clip_time", 		"2.5",  "(L4D2) reload time for grenade clip"  		  , FCVAR_NOTIFY, true, 0.0);
		hSG552TimeCvar			= CreateConVar("l4d2_sg552_reload_clip_time", 			"1.6",  "(L4D2) reload time for sg552 clip" 			  , FCVAR_NOTIFY, true, 0.0);
		hAWPTimeCvar			= CreateConVar("l4d2_awp_reload_clip_time", 			"2.0",  "(L4D2) reload time for awp clip" 				  , FCVAR_NOTIFY, true, 0.0);
		hScoutTimeCvar			= CreateConVar("l4d2_scout_reload_clip_time", 			"1.45", "(L4D2) reload time for scout clip"  			  , FCVAR_NOTIFY, true, 0.0);
		hMangumTimeCvar			= CreateConVar("l4d2_mangum_reload_clip_time", 			"1.18", "(L4D2) reload time for mangum clip"  			  , FCVAR_NOTIFY, true, 0.0);
		hM60TimeCvar			= CreateConVar("l4d2_m60_reload_clip_time", 			"1.2",  "(L4D2) reload time for m60 clip"  			  , FCVAR_NOTIFY, true, 0.0);
	}
	else
	{
		hSmgTimeCvar			= CreateConVar("l4d_smg_reload_clip_time", 				"1.65", "(L4D1) reload time for smg clip"				 , FCVAR_NOTIFY, true, 0.0);
		hRifleTimeCvar			= CreateConVar("l4d_rifle_reload_clip_time", 			"1.2",  "(L4D1) reload time for rifle clip"			 , FCVAR_NOTIFY, true, 0.0);
		hHuntingRifleTimeCvar   = CreateConVar("l4d_huntingrifle_reload_clip_time", 	"2.6",  "(L4D1) reload time for hunting rifle clip"	 , FCVAR_NOTIFY, true, 0.0);
		hPistolTimeCvar 		= CreateConVar("l4d_pistol_reload_clip_time", 			"1.5",  "(L4D1) reload time for pistol clip"		     , FCVAR_NOTIFY, true, 0.0);
		hDualPistolTimeCvar 	= CreateConVar("l4d_dualpistol_reload_clip_time", 		"2.1",  "(L4D1) reload time for dual pistol clip"       , FCVAR_NOTIFY, true, 0.0);
	}
	AutoExecConfig(true, "l4d2_weapon_csgo_reload");

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChange_CvarChanged);
	g_hCvarMagazineReloadType.AddChangeHook(ConVarChange_CvarChanged);
	if(g_bL4D2Version)
	{
		hSmgTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hRifleTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hHuntingRifleTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hPistolTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hDualPistolTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hSmgSilencedTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hSmgMP5TimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hAK47TimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hRifleDesertTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hSniperMilitaryTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hGrenadeTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hSG552TimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hAWPTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hScoutTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hMangumTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hM60TimeCvar.AddChangeHook(ConVarChange_CvarChanged);
	}
	else
	{
		hSmgTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hRifleTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hHuntingRifleTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hPistolTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
		hDualPistolTimeCvar.AddChangeHook(ConVarChange_CvarChanged);
	}

	HookEvent("round_start", RoundStart_Event);
	HookEvent("weapon_reload", OnWeaponReload_Event, EventHookMode_Post);
	
	AddCommandListener(CmdListen_weapon_reparse_server, "weapon_reparse_server");

	SetWeaponData();

	if(bLate)
	{
		LateLoad();
	}
}

void LateLoad()
{
    int entity;
    char classname[36];

    entity = INVALID_ENT_REFERENCE;
    while ((entity = FindEntityByClassname(entity, "weapon_*")) != INVALID_ENT_REFERENCE)
    {
        if (!IsValidEntity(entity))
            continue;

        GetEntityClassname(entity, classname, sizeof(classname));
        OnEntityCreated(entity, classname);
    }

    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
            continue;

        OnClientPutInServer(client);
    }
}

// Cvars-------------------------------

void ConVarChanged_AmmoCvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetAmmoCvars();
}

void GetAmmoCvars()
{
	g_iAmmoRifle		= g_hAmmoRifle.IntValue;
	g_iAmmoSmg			= g_hAmmoSmg.IntValue;
	g_iAmmoHunting		= g_hAmmoHunting.IntValue;

	if(g_bL4D2Version)
	{
		g_iAmmoGL			= g_hAmmoGL.IntValue;
		g_iAmmoM60			= g_hAmmoM60.IntValue;
		g_iAmmoSniper		= g_hAmmoSniper.IntValue;
	}
}

void ConVarChange_CvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable  = g_hCvarEnable.BoolValue;
	g_iCvarMagazineReloadType = g_hCvarMagazineReloadType.IntValue;
	if(g_bL4D2Version)
	{
		g_SmgTimeCvar 			= hSmgTimeCvar.FloatValue;
		g_RifleTimeCvar 		= hRifleTimeCvar.FloatValue;
		g_HuntingRifleTimeCvar	= hHuntingRifleTimeCvar.FloatValue;
		g_PistolTimeCvar 		= hPistolTimeCvar.FloatValue;
		g_DualPistolTimeCvar 	= hDualPistolTimeCvar.FloatValue;
		g_SmgSilencedTimeCvar	= hSmgSilencedTimeCvar.FloatValue;
		g_SmgMP5TimeCvar		= hSmgMP5TimeCvar.FloatValue;
		g_AK47TimeCvar			= hAK47TimeCvar.FloatValue;
		g_RifleDesertTimeCvar	= hRifleDesertTimeCvar.FloatValue;
		g_SniperMilitaryTimeCvar= hSniperMilitaryTimeCvar.FloatValue;
		g_GrenadeTimeCvar		= hGrenadeTimeCvar.FloatValue;
		g_SG552TimeCvar			= hSG552TimeCvar.FloatValue;
		g_AWPTimeCvar			= hAWPTimeCvar.FloatValue;
		g_ScoutTimeCvar			= hScoutTimeCvar.FloatValue;
		g_MangumTimeCvar		= hMangumTimeCvar.FloatValue;
		g_M60TimeCvar			= hM60TimeCvar.FloatValue;
	}
	else
	{
		g_SmgTimeCvar 			= hSmgTimeCvar.FloatValue;
		g_RifleTimeCvar 		= hRifleTimeCvar.FloatValue;
		g_HuntingRifleTimeCvar	= hHuntingRifleTimeCvar.FloatValue;
		g_PistolTimeCvar 		= hPistolTimeCvar.FloatValue;
		g_DualPistolTimeCvar 	= hDualPistolTimeCvar.FloatValue;
	}
}

// Sourcemod API Forward-------------------------------

public void OnConfigsExecuted()
{
	GetAmmoCvars();
	GetCvars();
	SetWeaponMaxClip();
}

public void OnClientPutInServer(int iClient)
{
	if (IsFakeClient(iClient))
		return;

	if(g_bL4D2Version)
	{
		SendProxy_HookEntity(iClient, "m_iAmmo", Prop_Int, OnSendAmmoDisplay, L4D2_AmmoType_AssaultRifle);
		SendProxy_HookEntity(iClient, "m_iAmmo", Prop_Int, OnSendAmmoDisplay, L4D2_AmmoType_Smg);
		SendProxy_HookEntity(iClient, "m_iAmmo", Prop_Int, OnSendAmmoDisplay, L4D2_AmmoType_M60);
		SendProxy_HookEntity(iClient, "m_iAmmo", Prop_Int, OnSendAmmoDisplay, L4D2_AmmoType_HuntingRifle);
		SendProxy_HookEntity(iClient, "m_iAmmo", Prop_Int, OnSendAmmoDisplay, L4D2_AmmoType_SniperRifle);
		SendProxy_HookEntity(iClient, "m_iAmmo", Prop_Int, OnSendAmmoDisplay, L4D2_AmmoType_GrenadeLauncher);
	}
	else
	{
		SendProxy_HookEntity(iClient, "m_iAmmo", Prop_Int, OnSendAmmoDisplay, L4D1_AmmoType_HuntingRifle);
		SendProxy_HookEntity(iClient, "m_iAmmo", Prop_Int, OnSendAmmoDisplay, L4D1_AmmoType_AssaultRifle);
		SendProxy_HookEntity(iClient, "m_iAmmo", Prop_Int, OnSendAmmoDisplay, L4D1_AmmoType_Smg);
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!g_bCvarEnable || !IsValidEntityIndex(entity))
		return;
		
	g_iGlobalWeaponId[entity] = ID_NONE;

	switch (classname[0])
	{
		case 'w':
		{
			WeaponID weaponid = GetWeaponID(entity, classname);
			if(weaponid == ID_NONE) return;
			
			g_iGlobalWeaponId[entity] = weaponid;
			RequestFrame(OnNextFrameWeapon, EntIndexToEntRef(entity));
		}
	}
}

// Command----

Action CmdListen_weapon_reparse_server(int client, const char[] command, int argc)
{
	RequestFrame(OnNextFrame_weapon_reparse_server);

	return Plugin_Continue;
}

// Event------

void RoundStart_Event(Event event, const char[] name, bool dontBroadcast) 
{
	for(int i = 1; i <= MaxClients; i++)
	{
		g_fClientReload_Time[i] = 0.0;
	}
}

void OnWeaponReload_Event(Event event, const char[] name, bool dontBroadcast) 
{
	if(!g_bCvarEnable) return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!IsValidAliveSurvivor(client))
		return;
		
	int weapon = GetEntDataEnt2(client, g_iOffsetActive); //抓人類目前裝彈的武器
	if (weapon <= 0 || !IsValidEntity(weapon))
	{
		return;
	}
	
	g_fClientReload_Time[client] = GetEngineTime();
	
	WeaponID weaponid = g_iGlobalWeaponId[weapon];
	if(weaponid == ID_PISTOL)
	{
		if( GetEntData(weapon, g_iOffset_PistolisDualWielding, 1) > 0) //dual pistol
		{
			g_iGlobalWeaponId[weapon] = ID_DUAL_PISTOL;
			weaponid = ID_DUAL_PISTOL;
		}
	}
	
	DataPack pack = null;
	if(g_bL4D2Version)
	{
		switch(weaponid)
		{
			case ID_SMG: CreateDataTimer(g_SmgTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_RIFLE: CreateDataTimer(g_RifleTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_HUNTING_RIFLE: CreateDataTimer(g_HuntingRifleTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_PISTOL: 
			{
				if(L4D_IsPlayerIncapacitated(client))
					CreateDataTimer(g_PistolTimeCvar * PISTOL_RELOAD_INCAP_MULTIPLY_L4D2, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
				else
					CreateDataTimer(g_PistolTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			}
			case ID_DUAL_PISTOL:
			{
				if(L4D_IsPlayerIncapacitated(client))
					CreateDataTimer(g_DualPistolTimeCvar * PISTOL_RELOAD_INCAP_MULTIPLY_L4D2, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
				else
					CreateDataTimer(g_DualPistolTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			}
			case ID_SMG_SILENCED: CreateDataTimer(g_SmgSilencedTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_SMG_MP5: CreateDataTimer(g_SmgMP5TimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_AK47: CreateDataTimer(g_AK47TimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_RIFLE_DESERT: CreateDataTimer(g_RifleDesertTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_AWP: CreateDataTimer(g_AWPTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_SCOUT: CreateDataTimer(g_ScoutTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_GRENADE: CreateDataTimer(g_GrenadeTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_SG552: CreateDataTimer(g_SG552TimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_SNIPER_MILITARY: CreateDataTimer(g_SniperMilitaryTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_M60: CreateDataTimer(g_M60TimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_MAGNUM:
			{
				if(L4D_IsPlayerIncapacitated(client))
					CreateDataTimer(g_MangumTimeCvar * PISTOL_RELOAD_INCAP_MULTIPLY_L4D2, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
				else
					CreateDataTimer(g_MangumTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			}
			default:
			{
				delete pack;
				return;
			}
		}
	}
	else
	{
		switch(weaponid)
		{
			case ID_SMG: CreateDataTimer(g_SmgTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_RIFLE: CreateDataTimer(g_RifleTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			case ID_HUNTING_RIFLE: CreateDataTimer(g_HuntingRifleTimeCvar, Timer_WeaponReloadClip, pack,TIMER_FLAG_NO_MAPCHANGE);
			case ID_PISTOL: 
			{
				if(L4D_IsPlayerIncapacitated(client))
					CreateDataTimer(g_PistolTimeCvar * PISTOL_RELOAD_INCAP_MULTIPLY_L4D1, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
				else
				{
					CreateDataTimer(g_PistolTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			case ID_DUAL_PISTOL:
			{
				if(L4D_IsPlayerIncapacitated(client))
					CreateDataTimer(g_DualPistolTimeCvar * PISTOL_RELOAD_INCAP_MULTIPLY_L4D1, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
				else
					CreateDataTimer(g_DualPistolTimeCvar, Timer_WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			}
			default: 
			{
				delete pack;
				return;
			}
		}
	}
	
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(weaponid);
	pack.WriteCell(g_fClientReload_Time[client]);
}

// SDKHooks-----

Action L4D2_OnWeaponReload_Pre(int weapon)
{
	if(g_bCvarEnable == false) return Plugin_Continue;

	int client = InUseClient(weapon);
	if ( client != -1)
	{
		WeaponID weaponid = g_iGlobalWeaponId[weapon];
		if(weaponid == ID_PISTOL)
		{
			if( GetEntData(weapon, g_iOffset_PistolisDualWielding, 1) > 0) //dual pistol
			{
				g_iGlobalWeaponId[weapon] = ID_DUAL_PISTOL;
				weaponid = ID_DUAL_PISTOL;
			}
		}

		int MaxClip = WeaponMaxClip[weaponid];
		int previousclip = GetWeaponClip(weapon);

		// 官方無限子彈時, 不會清除clip
		if(IsInifiniteAmmo(weaponid)) return Plugin_Continue;

		switch(weaponid)
		{
			case ID_SMG,ID_RIFLE,ID_HUNTING_RIFLE,ID_SMG_SILENCED,ID_SMG_MP5,
			ID_AK47,ID_RIFLE_DESERT,ID_AWP,ID_GRENADE,ID_SCOUT,ID_SG552,
			ID_SNIPER_MILITARY, ID_M60:
			{
				if (0 < previousclip && previousclip < MaxClip)	//If his current mag equals the maximum allowed, remove reload from buttons
				{
					#if DEBUG
						PrintToChatAll("L4D2_OnWeaponReload_Pre client: %N, Weapon: %d, previousclip: %d", client, weapon, previousclip);
					#endif
					DataPack data = new DataPack();
					data.WriteCell(GetClientUserId(client));
					data.WriteCell(EntIndexToEntRef(weapon));
					data.WriteCell(previousclip);
					data.WriteCell(weaponid);
					RequestFrame(OnNextFrame_RecoverWeaponClip, data);
				}
			}
			default:
			{
				return Plugin_Continue;
			}
		}
	}

	return Plugin_Continue;
} 

// Dhooks---

MRESReturn L4D1_OnGunReload_Pre(int pThis, Handle hReturn, Handle hParams)
{
	// Validate weapon
	if( pThis > MaxClients )
	{
		int client = GetEntPropEnt(pThis, Prop_Send, "m_hOwnerEntity");

		// Validate weapon owner
		if( client > 0 && client <= MaxClients && !IsFakeClient(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) )
		{
			// Validate weapon in hand
			int weapon = GetEntDataEnt2(client, g_iOffsetActive);
			if( weapon > MaxClients && pThis == weapon )
			{
				WeaponID weaponid = g_iGlobalWeaponId[weapon];
				if(weaponid == ID_PISTOL)
				{
					if( GetEntData(weapon, g_iOffset_PistolisDualWielding, 1) > 0) //dual pistol
					{
						g_iGlobalWeaponId[weapon] = ID_DUAL_PISTOL;
						weaponid = ID_DUAL_PISTOL;
					}
				}

				int MaxClip = WeaponMaxClip[weaponid];
				int previousclip = GetWeaponClip(weapon);

				// 官方無限子彈時, 不會清除clip
				if(IsInifiniteAmmo(weaponid)) return MRES_Ignored;

				switch(weaponid)
				{
					case ID_SMG,ID_RIFLE,ID_HUNTING_RIFLE:
					{
						if (0 < previousclip && previousclip < MaxClip)	//If his current mag equals the maximum allowed, remove reload from buttons
						{
							//PrintToChatAll("L4D1_OnGunReload_Pre client: %N, weapon: %d, previousclip: %d", client, weapon, previousclip);
							DataPack data = new DataPack();
							data.WriteCell(GetClientUserId(client));
							data.WriteCell(EntIndexToEntRef(weapon));
							data.WriteCell(previousclip);
							data.WriteCell(weaponid);
							RequestFrame(OnNextFrame_RecoverWeaponClip, data);
						}
					}
					default:
					{
						return MRES_Ignored;
					}
				}
			}
		}
	}

	return MRES_Ignored;
}

// Timer & Frame----

void OnNextFrame_weapon_reparse_server()
{
	SetWeaponMaxClip();
}

void OnNextFrame_RecoverWeaponClip(DataPack data) 
{ 
	data.Reset();
	int client = GetClientOfUserId(data.ReadCell());
	int CurrentWeapon = EntRefToEntIndex(data.ReadCell());
	int previousclip = data.ReadCell();
	WeaponID weaponid = data.ReadCell();
	delete data;
	int nowweaponclip;
	
	if (!IsValidAliveSurvivor(client) || //client wrong
		CurrentWeapon == INVALID_ENT_REFERENCE || //weapon entity wrong
		CurrentWeapon != GetEntDataEnt2(client, g_iOffsetActive) ||
		(nowweaponclip = GetWeaponClip(CurrentWeapon)) >= WeaponMaxClip[weaponid] || //CurrentWeapon complete reload finished
		nowweaponclip == previousclip //CurrentWeapon clip has been recovered
	)
	{
		return;
	}

	int ammo = GetOrSetPlayerAmmo(client, CurrentWeapon);
	ammo -= previousclip;
	GetOrSetPlayerAmmo(client, CurrentWeapon, ammo);
	SetWeaponClip(CurrentWeapon, previousclip);
}

Action Timer_WeaponReloadClip(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int CurrentWeapon = EntRefToEntIndex(pack.ReadCell());
	WeaponID weaponid = pack.ReadCell();
	float reloadtime = pack.ReadCell();
	int clip;
	
	if ( reloadtime != g_fClientReload_Time[client] || //裝彈時間被刷新
		!IsValidAliveSurvivor(client) || //client wrong
		CurrentWeapon == INVALID_ENT_REFERENCE || //weapon entity wrong
		HasEntProp(CurrentWeapon, Prop_Send, "m_bInReload") == false || GetEntData(CurrentWeapon, g_iOffsetInReload, 1) == 0 || //reload interrupted
		(clip = GetWeaponClip(CurrentWeapon)) >= WeaponMaxClip[weaponid] //CurrentWeapon complete reload finished
	)
	{
		return Plugin_Continue;
	}

	bool bIsInfiniteAmmo = IsInifiniteAmmo(weaponid);
	
	if (bIsInfiniteAmmo == false)
	{
		int ammo = GetOrSetPlayerAmmo(client, CurrentWeapon);
		if(g_iCvarMagazineReloadType == 1)
		{
			if(g_iGlobalWeapon_FakeMagazineLeft[CurrentWeapon] == 1)
			{
				clip = WeaponMaxClip[weaponid];
				ammo = 0;
			}
			else
			{
				clip = WeaponMaxClip[weaponid];
				ammo = ammo - WeaponMaxClip[weaponid];
			}
		}
		else
		{
			if( (ammo - (WeaponMaxClip[weaponid] - clip)) <= 0)
			{
				clip = clip + ammo;
				ammo = 0;
			}
			else
			{
				ammo = ammo - (WeaponMaxClip[weaponid] - clip);
				clip = WeaponMaxClip[weaponid];
			}
		}


		#if DEBUG
			PrintToChatAll("Timer_WeaponReloadClip, client: %N, ammo: %d, clip: %d", client, ammo, clip);
		#endif

		GetOrSetPlayerAmmo(client, CurrentWeapon, ammo);
		SetWeaponClip(CurrentWeapon, clip);
	}
	else
	{
		SetWeaponClip(CurrentWeapon, WeaponMaxClip[weaponid]);
	}

	return Plugin_Continue;
}

void OnNextFrameWeapon(int entityRef)
{
	int weapon = EntRefToEntIndex(entityRef);

	if (weapon == INVALID_ENT_REFERENCE)
		return;

	if(g_bL4D2Version) SDKHook(weapon, SDKHook_Reload, L4D2_OnWeaponReload_Pre);
}

// SendProxy ----

//玩家死亡還是會繼續傳送
//玩家在旁觀者或特感還是會繼續傳送
Action OnSendAmmoDisplay(int client, const char[] sProp, int &iValue, int iElement, int iSendClient)
{
	if(!g_bCvarEnable || g_iCvarMagazineReloadType == 0) return Plugin_Continue;

	if (client != iSendClient
		|| iValue <= 0
		|| GetClientTeam(client) != 2
		|| !IsPlayerAlive(client))
		return Plugin_Continue;

	int ammoType = iElement;
	int iWeapon = GetPlayerWeaponSlot(client, 0);
	if (iWeapon == -1 || GetEntData(iWeapon, g_iOffsetPrimaryAmmoType) != ammoType)
		return Plugin_Continue;

	WeaponID weaponid = g_iGlobalWeaponId[iWeapon];

	if(IsInifiniteAmmo(weaponid)) 
		return Plugin_Continue;

	int iMagazineMax = WeaponMaxClip[weaponid];
	if (iMagazineMax <= 0)
		return Plugin_Continue;

	int current_ammo = GetOrSetPlayerAmmo(client, iWeapon);

	int new_ammo_display = 0;
	if(current_ammo != 0)
	{
		new_ammo_display = current_ammo/iMagazineMax;
		if(current_ammo % iMagazineMax != 0) new_ammo_display++;
	}

	g_iGlobalWeapon_FakeMagazineLeft[iWeapon] = new_ammo_display;
	iValue = new_ammo_display;
	return Plugin_Changed;
}

// others

int GetWeaponClip(int weapon)
{
    return GetEntData(weapon, g_iOffsetClip);
} 

void SetWeaponClip(int weapon, int clip)
{
	SetEntData(weapon, g_iOffsetClip, clip);
} 

int GetOrSetPlayerAmmo(int client, int iWeapon, int iAmmo = -1)
{
	int offset = GetEntData(iWeapon, g_iOffsetPrimaryAmmoType) * 4; // Thanks to "Root" or whoever for this method of not hard-coding offsets: https://github.com/zadroot/AmmoManager/blob/master/scripting/ammo_manager.sp

	if( offset )
	{
		if( iAmmo != -1 ) SetEntData(client, g_iOffsetAmmo + offset, iAmmo);
		else
		{
			int ammo = GetEntData(client, g_iOffsetAmmo + offset);
			return ammo;
		}
	}

	return 0;
}

WeaponID GetWeaponID(int weapon, const char[] weapon_name)
{
	WeaponID index = ID_NONE;

	if ( g_smWeaponNameID.GetValue(weapon_name, index) )
	{
		if(index == ID_PISTOL)
		{
			if( GetEntData(weapon, g_iOffset_PistolisDualWielding, 1) > 0) //dual pistol
			{
				return ID_DUAL_PISTOL;
			}

			return ID_PISTOL;
		}

		return index;
	}

	return index;
}

int InUseClient(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if (IsValidAliveSurvivor(client)) return client;

	return -1;
}

bool IsValidAliveSurvivor(int client) 
{
    if ( 1 <= client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client)) 
		return true;      
    return false; 
}

bool IsInifiniteAmmo(WeaponID weaponid)
{
	if(g_bL4D2Version)
	{
		switch(weaponid)
		{
			case ID_SMG, ID_SMG_SILENCED, ID_SMG_MP5:
			{
				if(g_iAmmoSmg == -2) return true;
			}
			case ID_RIFLE, ID_AK47, ID_RIFLE_DESERT, ID_SG552:
			{
				if(g_iAmmoRifle == -2) return true;
			}
			case ID_HUNTING_RIFLE:
			{
				if(g_iAmmoHunting == -2) return true;
			}
			case ID_AWP, ID_SCOUT, ID_SNIPER_MILITARY:
			{
				if(g_iAmmoSniper == -2) return true;
			}
			case ID_M60:
			{
				if(g_iAmmoM60 == -2) return true;
			}
			case ID_GRENADE:
			{
				if(g_iAmmoGL == -2) return true;
			}
			case ID_PISTOL, ID_DUAL_PISTOL, ID_MAGNUM:
			{
				return true;
			}
		}
	}
	else
	{
		switch(weaponid)
		{
			case ID_SMG:
			{
				if(g_iAmmoSmg == -2) return true;
			}
			case ID_RIFLE:
			{
				if(g_iAmmoRifle == -2) return true;
			}
			case ID_HUNTING_RIFLE:
			{
				if(g_iAmmoHunting == -2) return true;
			}
			case ID_PISTOL, ID_DUAL_PISTOL:
			{
				return true;
			}
		}
	}

	return false;
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

void SetWeaponData()
{
	g_smWeaponNameID = new StringMap ();

	if(g_bL4D2Version)
	{
		g_smWeaponNameID.SetValue("", ID_NONE);
		g_smWeaponNameID.SetValue("weapon_pistol", ID_PISTOL);
		g_smWeaponNameID.SetValue("weapon_smg", ID_SMG);
		//g_smWeaponNameID.SetValue("weapon_pumpshotgun", ID_PUMPSHOTGUN);
		g_smWeaponNameID.SetValue("weapon_rifle", ID_RIFLE);
		//g_smWeaponNameID.SetValue("weapon_autoshotgun", ID_AUTOSHOTGUN);
		g_smWeaponNameID.SetValue("weapon_hunting_rifle", ID_HUNTING_RIFLE);
		g_smWeaponNameID.SetValue("weapon_smg_silenced", ID_SMG_SILENCED);
		g_smWeaponNameID.SetValue("weapon_smg_mp5", ID_SMG_MP5);
		//g_smWeaponNameID.SetValue("weapon_shotgun_chrome", ID_CHROMESHOTGUN);
		g_smWeaponNameID.SetValue("weapon_pistol_magnum", ID_MAGNUM);
		g_smWeaponNameID.SetValue("weapon_rifle_ak47", ID_AK47);
		g_smWeaponNameID.SetValue("weapon_rifle_desert", ID_RIFLE_DESERT);
		g_smWeaponNameID.SetValue("weapon_sniper_military", ID_SNIPER_MILITARY);
		g_smWeaponNameID.SetValue("weapon_grenade_launcher", ID_GRENADE);
		g_smWeaponNameID.SetValue("weapon_rifle_sg552", ID_SG552);
		g_smWeaponNameID.SetValue("weapon_rifle_m60", ID_M60);
		g_smWeaponNameID.SetValue("weapon_sniper_awp", ID_AWP);
		g_smWeaponNameID.SetValue("weapon_sniper_scout", ID_SCOUT);
		//g_smWeaponNameID.SetValue("weapon_shotgun_spas", ID_SPASSHOTGUN);
	}
	else
	{
		g_smWeaponNameID = new StringMap ();
		g_smWeaponNameID.SetValue("", ID_NONE);
		g_smWeaponNameID.SetValue("weapon_pistol", ID_PISTOL);
		g_smWeaponNameID.SetValue("weapon_smg", ID_SMG);
		//g_smWeaponNameID.SetValue("weapon_pumpshotgun", ID_PUMPSHOTGUN);
		g_smWeaponNameID.SetValue("weapon_rifle", ID_RIFLE);
		//g_smWeaponNameID.SetValue("weapon_autoshotgun", ID_AUTOSHOTGUN);
		g_smWeaponNameID.SetValue("weapon_hunting_rifle", ID_HUNTING_RIFLE);
	}
}

void SetWeaponMaxClip()
{
	WeaponMaxClip[ID_NONE] = 0;
	if(g_bL4D2Version)
	{
		WeaponMaxClip[ID_PISTOL] = L4D2_GetIntWeaponAttribute("weapon_pistol", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_DUAL_PISTOL] = L4D2_GetIntWeaponAttribute("weapon_pistol", L4D2IWA_ClipSize)*2;
		WeaponMaxClip[ID_SMG] = L4D2_GetIntWeaponAttribute("weapon_smg", L4D2IWA_ClipSize);
		//WeaponMaxClip[ID_PUMPSHOTGUN] = L4D2_GetIntWeaponAttribute("weapon_pumpshotgun", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_RIFLE] = L4D2_GetIntWeaponAttribute("weapon_rifle", L4D2IWA_ClipSize);
		//WeaponMaxClip[ID_AUTOSHOTGUN] = L4D2_GetIntWeaponAttribute("weapon_autoshotgun", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_HUNTING_RIFLE] = L4D2_GetIntWeaponAttribute("weapon_hunting_rifle", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_SMG_SILENCED] = L4D2_GetIntWeaponAttribute("weapon_smg_silenced", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_SMG_MP5] = L4D2_GetIntWeaponAttribute("weapon_smg_mp5", L4D2IWA_ClipSize);
		//WeaponMaxClip[ID_CHROMESHOTGUN] = L4D2_GetIntWeaponAttribute("weapon_shotgun_chrome", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_MAGNUM] = L4D2_GetIntWeaponAttribute("weapon_pistol_magnum", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_AK47] = L4D2_GetIntWeaponAttribute("weapon_rifle_ak47", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_RIFLE_DESERT] = L4D2_GetIntWeaponAttribute("weapon_rifle_desert", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_SNIPER_MILITARY] = L4D2_GetIntWeaponAttribute("weapon_sniper_military", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_GRENADE] = L4D2_GetIntWeaponAttribute("weapon_grenade_launcher", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_SG552] = L4D2_GetIntWeaponAttribute("weapon_rifle_sg552", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_M60] = L4D2_GetIntWeaponAttribute("weapon_rifle_m60", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_AWP] = L4D2_GetIntWeaponAttribute("weapon_sniper_awp", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_SCOUT] = L4D2_GetIntWeaponAttribute("weapon_sniper_scout", L4D2IWA_ClipSize);
		//WeaponMaxClip[ID_SPASSHOTGUN] = L4D2_GetIntWeaponAttribute("weapon_shotgun_spas", L4D2IWA_ClipSize);
	}
	else
	{
		WeaponMaxClip[ID_NONE] = 0;
		WeaponMaxClip[ID_PISTOL] = L4D2_GetIntWeaponAttribute("weapon_pistol", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_DUAL_PISTOL] = L4D2_GetIntWeaponAttribute("weapon_pistol", L4D2IWA_ClipSize)*2;
		WeaponMaxClip[ID_SMG] = L4D2_GetIntWeaponAttribute("weapon_smg", L4D2IWA_ClipSize);
		//WeaponMaxClip[ID_PUMPSHOTGUN] = L4D2_GetIntWeaponAttribute("weapon_pumpshotgun", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_RIFLE] = L4D2_GetIntWeaponAttribute("weapon_rifle", L4D2IWA_ClipSize);
		//WeaponMaxClip[ID_AUTOSHOTGUN] = L4D2_GetIntWeaponAttribute("weapon_autoshotgun", L4D2IWA_ClipSize);
		WeaponMaxClip[ID_HUNTING_RIFLE] = L4D2_GetIntWeaponAttribute("weapon_hunting_rifle", L4D2IWA_ClipSize);
	}
}