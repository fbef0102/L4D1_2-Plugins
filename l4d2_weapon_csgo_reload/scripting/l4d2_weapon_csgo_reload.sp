#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <left4dhooks>
#define PLUGIN_VERSION	"2.3"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "L4D2 weapon csgo reload",
	author = "Harry Potter",
	description = "reload like csgo weapon",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

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
#define PISTOL_RELOAD_INCAP_MULTIPLY 1.25

StringMap g_smWeaponNameID;
int WeaponAmmoOffest[view_as<int>(ID_WEAPON_MAX)];
int WeaponMaxClip[view_as<int>(ID_WEAPON_MAX)];

ConVar g_hAmmoGL, g_hAmmoHunting, g_hAmmoM60, g_hAmmoRifle, g_hAmmoSmg, g_hAmmoSniper;
int g_iAmmoGL, g_iAmmoHunting, g_iAmmoM60, g_iAmmoRifle, g_iAmmoSmg, g_iAmmoSniper;

ConVar hEnable, hEnableClipRecoverCvar, hSmgTimeCvar, hRifleTimeCvar, hHuntingRifleTimeCvar,
	hPistolTimeCvar, hDualPistolTimeCvar, hSmgSilencedTimeCvar, hSmgMP5TimeCvar, hAK47TimeCvar, hRifleDesertTimeCvar,
	hSniperMilitaryTimeCvar, hGrenadeTimeCvar, hSG552TimeCvar, hAWPTimeCvar, hScoutTimeCvar, hMangumTimeCvar, hM60TimeCvar;

bool g_bEnable;
bool g_EnableClipRecoverCvar;
float g_SmgTimeCvar;
float g_RifleTimeCvar;
float g_HuntingRifleTimeCvar;
float g_PistolTimeCvar;
float g_DualPistolTimeCvar;
float g_SmgSilencedTimeCvar;
float g_SmgMP5TimeCvar;
float g_AK47TimeCvar;
float g_RifleDesertTimeCvar;
float g_SniperMilitaryTimeCvar;
float g_GrenadeTimeCvar;
float g_SG552TimeCvar;
float g_AWPTimeCvar;
float g_ScoutTimeCvar;
float g_MangumTimeCvar;
float g_M60TimeCvar;

//value
float g_hClientReload_Time[MAXPLAYERS+1]	= {0.0};	

//offest
int ammoOffset;		

public void OnPluginStart()
{
	ammoOffset = FindSendPropInfo("CCSPlayer", "m_iAmmo");

	g_hAmmoRifle =		FindConVar("ammo_assaultrifle_max");
	g_hAmmoSmg =		FindConVar("ammo_smg_max");
	g_hAmmoHunting =	FindConVar("ammo_huntingrifle_max");
	g_hAmmoGL =			FindConVar("ammo_grenadelauncher_max");
	g_hAmmoM60 =		FindConVar("ammo_m60_max");
	g_hAmmoSniper =		FindConVar("ammo_sniperrifle_max");

	GetAmmoCvars();
	g_hAmmoRifle.AddChangeHook(ConVarChanged_AmmoCvars);
	g_hAmmoSmg.AddChangeHook(ConVarChanged_AmmoCvars);
	g_hAmmoHunting.AddChangeHook(ConVarChanged_AmmoCvars);
	g_hAmmoGL.AddChangeHook(ConVarChanged_AmmoCvars);
	g_hAmmoM60.AddChangeHook(ConVarChanged_AmmoCvars);
	g_hAmmoSniper.AddChangeHook(ConVarChanged_AmmoCvars);

	hEnable					= CreateConVar("l4d2_weapon_csgo_reload_allow", 		"1", 	"0=off plugin, 1=on plugin" 			  , FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hEnableClipRecoverCvar	= CreateConVar("l4d2_weapon_csgo_reload_clip_recover", 	"1", 	"enable previous clip recover?"			  , FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hSmgTimeCvar			= CreateConVar("l4d2_smg_reload_clip_time", 			"1.04", "reload time for smg clip"				  , FCVAR_NOTIFY, true, 0.0);
	hRifleTimeCvar			= CreateConVar("l4d2_rifle_reload_clip_time", 			"1.2",  "reload time for rifle clip"			  , FCVAR_NOTIFY, true, 0.0);
	hHuntingRifleTimeCvar   = CreateConVar("l4d2_huntingrifle_reload_clip_time", 	"2.6",  "reload time for hunting rifle clip"	  , FCVAR_NOTIFY, true, 0.0);
	hPistolTimeCvar 		= CreateConVar("l4d2_pistol_reload_clip_time", 			"1.2",  "reload time for pistol clip"		      , FCVAR_NOTIFY, true, 0.0);
	hDualPistolTimeCvar 	= CreateConVar("l4d2_dualpistol_reload_clip_time", 		"1.75", "reload time for dual pistol clip"        , FCVAR_NOTIFY, true, 0.0);
	hSmgSilencedTimeCvar	= CreateConVar("l4d2_smgsilenced_reload_clip_time", 	"1.05", "reload time for smg silenced clip"       , FCVAR_NOTIFY, true, 0.0);
	hSmgMP5TimeCvar			= CreateConVar("l4d2_smgmp5_reload_clip_time", 			"1.7",  "reload time for smg mp5 clip"      	  , FCVAR_NOTIFY, true, 0.0);
	hAK47TimeCvar			= CreateConVar("l4d2_ak47_reload_clip_time", 			"1.2",  "reload time for ak47 clip"      		  , FCVAR_NOTIFY, true, 0.0);
	hRifleDesertTimeCvar	= CreateConVar("l4d2_desertrifle_reload_clip_time", 	"1.8",  "reload time for desert rifle clip"       , FCVAR_NOTIFY, true, 0.0);
	hSniperMilitaryTimeCvar	= CreateConVar("l4d2_snipermilitary_reload_clip_time", 	"1.8",  "reload time for sniper military clip"    , FCVAR_NOTIFY, true, 0.0);
	hGrenadeTimeCvar		= CreateConVar("l4d2_grenade_reload_clip_time", 		"2.5",  "reload time for grenade clip"  		  , FCVAR_NOTIFY, true, 0.0);
	hSG552TimeCvar			= CreateConVar("l4d2_sg552_reload_clip_time", 			"1.6",  "reload time for sg552 clip" 			  , FCVAR_NOTIFY, true, 0.0);
	hAWPTimeCvar			= CreateConVar("l4d2_awp_reload_clip_time", 			"2.0",  "reload time for awp clip" 				  , FCVAR_NOTIFY, true, 0.0);
	hScoutTimeCvar			= CreateConVar("l4d2_scout_reload_clip_time", 			"1.45", "reload time for scout clip"  			  , FCVAR_NOTIFY, true, 0.0);
	hMangumTimeCvar			= CreateConVar("l4d2_mangum_reload_clip_time", 			"1.18", "reload time for mangum clip"  			  , FCVAR_NOTIFY, true, 0.0);
	hM60TimeCvar			= CreateConVar("l4d2_m60_reload_clip_time", 			"1.2",  "reload time for m60 clip"  			  , FCVAR_NOTIFY, true, 0.0);
	AutoExecConfig(true, "l4d2_weapon_csgo_reload");

	GetCvars();
	hEnable.AddChangeHook(ConVarChange_CvarChanged);
	hEnableClipRecoverCvar.AddChangeHook(ConVarChange_CvarChanged);
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

	HookEvent("weapon_reload", OnWeaponReload_Event, EventHookMode_Post);
	HookEvent("round_start", RoundStart_Event);
	AddCommandListener(CmdListen_weapon_reparse_server, "weapon_reparse_server");

	SetWeaponNameId();

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
}

void ConVarChanged_AmmoCvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetAmmoCvars();
}

void GetAmmoCvars()
{
	g_iAmmoRifle		= g_hAmmoRifle.IntValue;
	g_iAmmoSmg			= g_hAmmoSmg.IntValue;
	g_iAmmoHunting		= g_hAmmoHunting.IntValue;

	g_iAmmoGL			= g_hAmmoGL.IntValue;
	g_iAmmoM60			= g_hAmmoM60.IntValue;
	g_iAmmoSniper		= g_hAmmoSniper.IntValue;
}

void ConVarChange_CvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bEnable  = hEnable.BoolValue;
	g_EnableClipRecoverCvar = hEnableClipRecoverCvar.BoolValue;
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

void SetWeaponNameId()
{
	g_smWeaponNameID = new StringMap ();
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
	
	WeaponAmmoOffest[ID_NONE] = 0;
	WeaponAmmoOffest[ID_PISTOL] = 0;
	WeaponAmmoOffest[ID_DUAL_PISTOL] = 0;
	WeaponAmmoOffest[ID_SMG] = 5;
	//WeaponAmmoOffest[ID_PUMPSHOTGUN] = 7;
	WeaponAmmoOffest[ID_RIFLE] = 3;
	//WeaponAmmoOffest[ID_AUTOSHOTGUN] = 8;
	WeaponAmmoOffest[ID_HUNTING_RIFLE] = 9;
	WeaponAmmoOffest[ID_SMG_SILENCED] = 5;
	WeaponAmmoOffest[ID_SMG_MP5] = 5;
	//WeaponAmmoOffest[ID_CHROMESHOTGUN] = 7;
	WeaponAmmoOffest[ID_MAGNUM] = 0;
	WeaponAmmoOffest[ID_AK47] = 3;
	WeaponAmmoOffest[ID_RIFLE_DESERT] = 3;
	WeaponAmmoOffest[ID_SNIPER_MILITARY] = 10;
	WeaponAmmoOffest[ID_GRENADE] = 17;
	WeaponAmmoOffest[ID_SG552] = 3;
	WeaponAmmoOffest[ID_M60] = 6;
	WeaponAmmoOffest[ID_AWP] = 10;
	WeaponAmmoOffest[ID_SCOUT] = 10;
	//WeaponAmmoOffest[ID_SPASSHOTGUN] = 8;
}

void SetWeaponMaxClip()
{
	WeaponMaxClip[ID_NONE] = 0;
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

public void OnConfigsExecuted()
{
	GetAmmoCvars();
	GetCvars();
	SetWeaponMaxClip();
}

public void OnEntityCreated(int entity, const char[] classname)
{
	switch (classname[0])
	{
		case 'w':
		{
			if(GetWeaponID(entity, classname) != ID_NONE)
			{
				RequestFrame(OnNextFrameWeapon, EntIndexToEntRef(entity));
			}
		}
	}
}

Action CmdListen_weapon_reparse_server(int client, const char[] command, int argc)
{
	RequestFrame(OnNextFrame_weapon_reparse_server);

	return Plugin_Continue;
}

void OnNextFrame_weapon_reparse_server()
{
	SetWeaponMaxClip();
}

void RoundStart_Event(Event event, const char[] name, bool dontBroadcast) 
{
	for(int i = 1; i <= MaxClients; i++)
	{
		g_hClientReload_Time[i] = 0.0;
	}
}

void OnWeaponReload_Event(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!IsValidAliveSurvivor(client) || g_bEnable == false)
		return;
		
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); //抓人類目前裝彈的武器
	if (weapon <= 0 || !IsValidEntity(weapon))
	{
		return;
	}
	
	g_hClientReload_Time[client] = GetEngineTime();
	
	static char sWeaponName[32];
	GetEntityClassname(weapon, sWeaponName, sizeof(sWeaponName));
	WeaponID weaponid = GetWeaponID(weapon, sWeaponName);
	#if DEBUG
		PrintToChatAll("OnWeaponReload_Event %N - (%d)%s - weaponid: %d",client,weapon,sWeaponName,weaponid);
		for (int i = 0; i < 32; i++)
		{
			PrintToConsole(client, "Offset: %i - Count: %i", i, GetEntData(client, ammoOffset+(i*4)));
		} 
	#endif
	
	DataPack pack = null;
	switch(weaponid)
	{
		case ID_SMG: CreateDataTimer(g_SmgTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_RIFLE: CreateDataTimer(g_RifleTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_HUNTING_RIFLE: CreateDataTimer(g_HuntingRifleTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_PISTOL: 
		{
			if(IsIncapacitated(client))
				CreateDataTimer(g_PistolTimeCvar * PISTOL_RELOAD_INCAP_MULTIPLY, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			else
				CreateDataTimer(g_PistolTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		}
		case ID_DUAL_PISTOL:
		{
			if(IsIncapacitated(client))
				CreateDataTimer(g_DualPistolTimeCvar * PISTOL_RELOAD_INCAP_MULTIPLY, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			else
				CreateDataTimer(g_DualPistolTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		}
		case ID_SMG_SILENCED: CreateDataTimer(g_SmgSilencedTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_SMG_MP5: CreateDataTimer(g_SmgMP5TimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_AK47: CreateDataTimer(g_AK47TimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_RIFLE_DESERT: CreateDataTimer(g_RifleDesertTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_AWP: CreateDataTimer(g_AWPTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_SCOUT: CreateDataTimer(g_ScoutTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_GRENADE: CreateDataTimer(g_GrenadeTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_SG552: CreateDataTimer(g_SG552TimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_SNIPER_MILITARY: CreateDataTimer(g_SniperMilitaryTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_M60: CreateDataTimer(g_M60TimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		case ID_MAGNUM:
		{
			if(IsIncapacitated(client))
				CreateDataTimer(g_MangumTimeCvar * PISTOL_RELOAD_INCAP_MULTIPLY, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
			else
				CreateDataTimer(g_MangumTimeCvar, WeaponReloadClip, pack, TIMER_FLAG_NO_MAPCHANGE);
		}
		default:
		{
			delete pack;
			return;
		}
	}
	
	pack.WriteCell(GetClientUserId(client));
	pack.WriteCell(EntIndexToEntRef(weapon));
	pack.WriteCell(weaponid);
	pack.WriteCell(g_hClientReload_Time[client]);
}

Action OnWeaponReload_Pre(int weapon)
{
	if(g_bEnable == false || g_EnableClipRecoverCvar == false) return Plugin_Continue;

	int client = InUseClient(weapon);
	if ( client != -1)
	{
		static char sWeaponName[32];
		GetEntityClassname(weapon, sWeaponName, sizeof(sWeaponName));
		WeaponID weaponid = GetWeaponID(weapon,sWeaponName);
		int MaxClip = WeaponMaxClip[weaponid];
			
		switch(weaponid)
		{
			case ID_SMG,ID_RIFLE,ID_HUNTING_RIFLE,ID_SMG_SILENCED,ID_SMG_MP5,
			ID_AK47,ID_RIFLE_DESERT,ID_AWP,ID_GRENADE,ID_SCOUT,ID_SG552,
			ID_SNIPER_MILITARY, ID_M60:
			{
				int previousclip = GetWeaponClip(weapon);
				if (0 < previousclip && previousclip < MaxClip)	//If his current mag equals the maximum allowed, remove reload from buttons
				{
					#if DEBUG
						PrintToChatAll("OnWeaponReload_Pre client: %N, sWeaponName: (%d)%s, previousclip: %d", client, weapon, sWeaponName, previousclip);
					#endif
					DataPack data = new DataPack();
					data.WriteCell(GetClientUserId(client));
					data.WriteCell(EntIndexToEntRef(weapon));
					data.WriteCell(previousclip);
					data.WriteCell(weaponid);
					RequestFrame(RecoverWeaponClip, data);
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

void OnNextFrameWeapon(int entityRef)
{
	int weapon = EntRefToEntIndex(entityRef);

	if (weapon == INVALID_ENT_REFERENCE)
		return;

	// Use SDKHookEx in case if not weapon was passed
	SDKHook(weapon, SDKHook_Reload, OnWeaponReload_Pre);
}

void RecoverWeaponClip(DataPack data) { 
	data.Reset();
	int client = GetClientOfUserId(data.ReadCell());
	int CurrentWeapon = EntRefToEntIndex(data.ReadCell());
	int previousclip = data.ReadCell();
	WeaponID weaponid = data.ReadCell();
	delete data;
	int nowweaponclip;
	
	if (!IsValidAliveSurvivor(client) || //client wrong
		CurrentWeapon == INVALID_ENT_REFERENCE || //weapon entity wrong
		(nowweaponclip = GetWeaponClip(CurrentWeapon)) >= WeaponMaxClip[weaponid] || //CurrentWeapon complete reload finished
		nowweaponclip == previousclip //CurrentWeapon clip has been recovered
	)
	{
		return;
	}

	#if DEBUG
		PrintToChatAll("CurrentWeapon clip recovered");
	#endif

	switch(weaponid)
	{
		case ID_SMG, ID_SMG_SILENCED, ID_SMG_MP5:
		{
			if(g_iAmmoSmg == -2) return;
		}
		case ID_RIFLE, ID_AK47, ID_RIFLE_DESERT, ID_SG552:
		{
			if(g_iAmmoRifle == -2) return;
		}
		case ID_HUNTING_RIFLE:
		{
			if(g_iAmmoHunting == -2) return;
		}
		case ID_AWP, ID_SCOUT, ID_SNIPER_MILITARY:
		{
			if(g_iAmmoSniper == -2) return;
		}
		case ID_M60:
		{
			if(g_iAmmoM60 == -2) return;
		}
		case ID_GRENADE:
		{
			if(g_iAmmoGL == -2) return;
		}
	}
	
	int ammo = GetWeaponAmmo(client, WeaponAmmoOffest[weaponid]);
	ammo -= previousclip;
	SetWeaponAmmo(client,WeaponAmmoOffest[weaponid],ammo);
	SetWeaponClip(CurrentWeapon, previousclip);
} 

Action WeaponReloadClip(Handle timer, DataPack pack)
{
	pack.Reset();
	int client = GetClientOfUserId(pack.ReadCell());
	int CurrentWeapon = EntRefToEntIndex(pack.ReadCell());
	WeaponID weaponid = pack.ReadCell();
	float reloadtime = pack.ReadCell();
	int clip;
	
	if ( reloadtime != g_hClientReload_Time[client] || //裝彈時間被刷新
		!IsValidAliveSurvivor(client) || //client wrong
		CurrentWeapon == INVALID_ENT_REFERENCE || //weapon entity wrong
		HasEntProp(CurrentWeapon, Prop_Send, "m_bInReload") == false || GetEntProp(CurrentWeapon, Prop_Send, "m_bInReload") == 0 || //reload interrupted
		(clip = GetWeaponClip(CurrentWeapon)) >= WeaponMaxClip[weaponid] //CurrentWeapon complete reload finished
	)
	{
		return Plugin_Continue;
	}

	bool bIsInfiniteAmmo;
	switch(weaponid)
	{
		case ID_SMG, ID_SMG_SILENCED, ID_SMG_MP5:
		{
			if(g_iAmmoSmg == -2) bIsInfiniteAmmo = true;
		}
		case ID_RIFLE, ID_AK47, ID_RIFLE_DESERT, ID_SG552:
		{
			if(g_iAmmoRifle == -2) bIsInfiniteAmmo = true;
		}
		case ID_HUNTING_RIFLE:
		{
			if(g_iAmmoHunting == -2) bIsInfiniteAmmo = true;
		}
		case ID_AWP, ID_SCOUT, ID_SNIPER_MILITARY:
		{
			if(g_iAmmoSniper == -2) bIsInfiniteAmmo = true;
		}
		case ID_M60:
		{
			if(g_iAmmoM60 == -2) bIsInfiniteAmmo = true;
		}
		case ID_GRENADE:
		{
			if(g_iAmmoGL == -2) bIsInfiniteAmmo = true;
		}
		case ID_PISTOL, ID_DUAL_PISTOL, ID_MAGNUM:
		{
			bIsInfiniteAmmo = true;
		}
	}
	
	if (bIsInfiniteAmmo == false)
	{
		int ammo = GetWeaponAmmo(client, WeaponAmmoOffest[weaponid]);
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

		#if DEBUG
			PrintToChatAll("WeaponReloadClip, client: %N, ammo: %d, clip: %d", client, ammo, clip);
		#endif

		SetWeaponAmmo(client, WeaponAmmoOffest[weaponid],ammo);
		SetWeaponClip(CurrentWeapon, clip);
	}
	else
	{
		SetWeaponClip(CurrentWeapon, WeaponMaxClip[weaponid]);
	}

	return Plugin_Continue;
}

int GetWeaponAmmo(int client, int offest)
{
    return GetEntData(client, ammoOffset+(offest*4));
} 

int GetWeaponClip(int weapon)
{
    return GetEntProp(weapon, Prop_Send, "m_iClip1");
} 

void SetWeaponAmmo(int client, int offest, int ammo)
{
    SetEntData(client, ammoOffset+(offest*4), ammo);
} 
void SetWeaponClip(int weapon, int clip)
{
	SetEntProp(weapon, Prop_Send, "m_iClip1", clip);
} 

bool IsIncapacitated(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated"));
}

WeaponID GetWeaponID(int weapon, const char[] weapon_name)
{
	WeaponID index = ID_NONE;

	if ( g_smWeaponNameID.GetValue(weapon_name, index) )
	{
		if(index == ID_PISTOL)
		{
			if( GetEntProp(weapon, Prop_Send, "m_isDualWielding") > 0) //dual pistol
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