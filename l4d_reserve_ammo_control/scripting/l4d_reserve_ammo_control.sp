#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>
#include <l4d_transition_entity> //https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_transition_entity

#define PLUGIN_VERSION			"1.1h-2026/5/18"
#define PLUGIN_NAME			    "l4d_reserve_ammo_control"
#define DEBUG 0

bool g_bLateLoad;
public Plugin myinfo = 
{
	name = "[L4D/L4D2] Reserve Control",
	author = "Orin, Psykotikism [Signatures], Harry [Remake]",
	description = "Individually control weapon reserve independant of 'ammo_*' cvars.",
	version = PLUGIN_VERSION,
	url = "https://github.com/fbef0102/L4D1_2-Plugins"
};

bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead && test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	g_bL4D2Version = (test == Engine_Left4Dead2);

	g_bLateLoad = late;
	return APLRes_Success;
}

#define GAMEDATA_FILE           PLUGIN_NAME
#define DATA_FILE		        "data/" ... PLUGIN_NAME ... ".cfg"

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define MAXENTITIES                   2048

ConVar g_hAmmoAutoShot, g_hAmmoChainsaw, g_hAmmoGL, g_hAmmoHunting, g_hAmmoM60, g_hAmmoRifle, g_hAmmoShotgun, g_hAmmoSmg, g_hAmmoSniper;
int g_iAmmoAutoShot, g_iAmmoChainsaw, g_iAmmoGL, g_iAmmoHunting, g_iAmmoM60, g_iAmmoRifle, g_iAmmoShotgun, g_iAmmoSmg, g_iAmmoSniper;

StringMap 
	g_smReserveData;

bool 
	//g_bWeaponSpawn, g_bWeaponAmmoSpawn,
	g_bWeaponAlreadySetAmmo[MAXENTITIES+1],
	g_bIsEntityTransitioned[MAXENTITIES+1];

public void OnPluginStart()
{
	LoadGameData();

	g_hAmmoRifle =			FindConVar("ammo_assaultrifle_max");
	g_hAmmoShotgun =		g_bL4D2Version ? FindConVar("ammo_shotgun_max") : FindConVar("ammo_buckshot_max");
	g_hAmmoSmg =			FindConVar("ammo_smg_max");
	g_hAmmoHunting =		FindConVar("ammo_huntingrifle_max");
	if( g_bL4D2Version )
	{
		g_hAmmoGL =			FindConVar("ammo_grenadelauncher_max");
		g_hAmmoChainsaw =	FindConVar("ammo_chainsaw_max");
		g_hAmmoAutoShot =	FindConVar("ammo_autoshotgun_max");
		g_hAmmoM60 =		FindConVar("ammo_m60_max");
		g_hAmmoSniper =		FindConVar("ammo_sniperrifle_max");
	}

	GetCvars();
	g_hAmmoRifle.AddChangeHook(ConVarChanged_Cvars);
	g_hAmmoShotgun.AddChangeHook(ConVarChanged_Cvars);
	g_hAmmoSmg.AddChangeHook(ConVarChanged_Cvars);
	g_hAmmoHunting.AddChangeHook(ConVarChanged_Cvars);
	if( g_bL4D2Version )
	{
		g_hAmmoGL.AddChangeHook(ConVarChanged_Cvars);
		g_hAmmoChainsaw.AddChangeHook(ConVarChanged_Cvars);
		g_hAmmoAutoShot.AddChangeHook(ConVarChanged_Cvars);
		g_hAmmoM60.AddChangeHook(ConVarChanged_Cvars);
		g_hAmmoSniper.AddChangeHook(ConVarChanged_Cvars);
	}

	CreateConVar(                       	PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	RegAdminCmd("sm_reserve_ammo_reload", 	CmdReserveReload, ADMFLAG_ROOT, "Reload the reserve ammo data.");

	g_smReserveData = new StringMap();

	if( g_bLateLoad )
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if (!IsClientInGame(client))
				continue;

			OnClientPutInServer(client);
		}
	}
}

// GameData------------
void LoadGameData()
{
	GameData hGameData = new GameData(GAMEDATA_FILE);
	if( !hGameData ) SetFailState("Failed to find \"%s.txt\" gamedata!", GAMEDATA_FILE);

	// This: RAW (?)
	// Params: INT [AmmoIndex], CBaseCombatCharacter const*
	// Return: INT
	DynamicDetour g_dynAmmoDefMaxCarry = DynamicDetour.FromConf(hGameData, "CAmmoDef::MaxCarry");
	if( !g_dynAmmoDefMaxCarry )
		SetFailState("Failed to setup dhook for CAmmoDef::MaxCarry!");
	if( !g_dynAmmoDefMaxCarry.Enable(Hook_Pre, Detour_AmmoDefMaxCarry_Pre) )
		SetFailState("Failed to enable pre detour for CAmmoDef::MaxCarry!");
	delete g_dynAmmoDefMaxCarry;

	DynamicDetour g_dynCWeaponSpawnUse = DynamicDetour.FromConf(hGameData, "CWeaponSpawn::Use");
	if( !g_dynCWeaponSpawnUse )
		SetFailState("Failed to setup dhook for CWeaponSpawn::Use!");
	//if( !g_dynCWeaponSpawnUse.Enable(Hook_Pre, Detour_CWeaponSpawnUse_Pre) )
	//	SetFailState("Failed to enable pre detour for CWeaponSpawn::Use!");
	//if( !g_dynCWeaponSpawnUse.Enable(Hook_Post, Detour_CWeaponSpawnUse_Post) )
	//	SetFailState("Failed to enable post detour for CWeaponSpawn::Use!");
	delete g_dynCWeaponSpawnUse;

	DynamicDetour g_dynCWeaponAmmoSpawnUse = DynamicDetour.FromConf(hGameData, "CWeaponAmmoSpawn::Use");
	if( !g_dynCWeaponAmmoSpawnUse )
		SetFailState("Failed to setup dhook for CWeaponAmmoSpawn::Use!");
	//if( !g_dynCWeaponAmmoSpawnUse.Enable(Hook_Pre, Detour_CWeaponAmmoSpawnUse_Pre) )
	//	SetFailState("Failed to enable pre detour for CWeaponAmmoSpawn::Use!");
	//if( !g_dynCWeaponAmmoSpawnUse.Enable(Hook_Post, Detour_CWeaponAmmoSpawnUse_Post) )
	//	SetFailState("Failed to enable dpost etour for CWeaponAmmoSpawn::Use!");
	delete g_dynCWeaponAmmoSpawnUse;

	delete hGameData;
}

// Cvars---

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iAmmoRifle			= g_hAmmoRifle.IntValue;
	g_iAmmoShotgun			= g_hAmmoShotgun.IntValue;
	g_iAmmoSmg				= g_hAmmoSmg.IntValue;
	g_iAmmoHunting			= g_hAmmoHunting.IntValue;

	if( g_bL4D2Version )
	{
		g_iAmmoGL			= g_hAmmoGL.IntValue;
		g_iAmmoChainsaw		= g_hAmmoChainsaw.IntValue;
		g_iAmmoAutoShot		= g_hAmmoAutoShot.IntValue;
		g_iAmmoM60			= g_hAmmoM60.IntValue;
		g_iAmmoSniper		= g_hAmmoSniper.IntValue;
	}
}

//Sourcemod API Forward-------------------------------

public void OnMapStart()
{	
	delete g_smReserveData;
	g_smReserveData = new StringMap();

	LoadConfigSMC();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
}

public void OnEntityCreated(int entity, const char[] sWeapon)
{
	if (!IsValidEntityIndex(entity))
		return;
		
	g_bWeaponAlreadySetAmmo[entity] = false;
	g_bIsEntityTransitioned[entity] = false;
}

// Config---
void LoadConfigSMC()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), DATA_FILE);

	if( FileExists(sPath) )
	{
		SMCParser parser = new SMCParser();
		parser.OnKeyValue = SMC_OnKeyValue;

		// Setup error logging
		char sError[128];
		int iLine, iCol;
		SMCError result = parser.ParseFile(sPath, iLine, iCol);
		if( result != SMCError_Okay )
		{
			if( parser.GetErrorString(result, sError, sizeof(sError)) )
			{
				SetFailState("CONFIG ERROR ID: #%d, %s. (line %d, column %d) [FILE: %s]", result, sError, iLine, iCol, sPath);
			}
			else
			{
				SetFailState("Unable to load config. Bad format? Check for missing { } etc.");
			}
		}

		delete parser;
		return;
	}
	else
	{
		SetFailState("Could not load CFG '%s'! Plugin aborted.", sPath);
	}
}

SMCResult SMC_OnKeyValue(Handle smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes)
{
	g_smReserveData.SetValue(key, StringToInt(value));
	#if DEBUG
	PrintToServer("SMC: %s and %s", key, value);
	#endif

	// FYI: If you don't return, its this anyways
	return SMCParse_Continue;
}

// ------------
// Commands
Action CmdReserveReload(int client, int args)
{
	delete g_smReserveData;
	g_smReserveData = new StringMap();

	LoadConfigSMC();
	ReplyToCommand(client, "\x05[Reserve Control] \x01Reloaded the config!");

	return Plugin_Handled;
}

// ++ Hooks ++
// -----------
// DHooks
MRESReturn Detour_AmmoDefMaxCarry_Pre(DHookReturn hReturn, DHookParam hParams)
{
	//if (g_bWeaponAmmoSpawn || g_bWeaponSpawn)
	//{
	int ammoindex	= hParams.Get(1);
	int client		= hParams.Get(2); // Its not like NPCs with guns exist in L4D
	if(client <= 0 || client > MaxClients || !IsClientInGame(client)) return MRES_Ignored;

	int iWeapon = GetPlayerWeaponSlot(client, 0);
	if( iWeapon <= MaxClients || !IsValidEntity(iWeapon) )
		return MRES_Ignored;

	int iPrimaryAmmoType = GetEntProp(iWeapon, Prop_Data, "m_iPrimaryAmmoType");
	if( ammoindex == iPrimaryAmmoType )
	{
		char sWeapon[32];
		GetEntityClassname(iWeapon, sWeapon, sizeof(sWeapon));

		int iConfigReserve;
		if( g_smReserveData.GetValue(sWeapon, iConfigReserve) )
		{
			hReturn.Value = iConfigReserve;
			return MRES_Supercede;
		}
	}
	//}

	return MRES_Ignored;
}

/*MRESReturn Detour_CWeaponSpawnUse_Pre()
{
    PrintToChatAll("[Max Ammo] CWeaponSpawn::Use_Pre called");
    g_bWeaponSpawn = true;
    return MRES_Ignored;
}

MRESReturn Detour_CWeaponSpawnUse_Post()
{
    PrintToChatAll("[Max Ammo] CWeaponSpawn::Use_Post called");
    g_bWeaponSpawn = false;
    return MRES_Ignored;
}

MRESReturn Detour_CWeaponAmmoSpawnUse_Pre()
{
    PrintToChatAll("[Max Ammo] CWeaponAmmoSpawn::Use_Pre called");
    g_bWeaponAmmoSpawn = true;
    return MRES_Ignored;
}

MRESReturn Detour_CWeaponAmmoSpawnUse_Post()
{
    PrintToChatAll("[Max Ammo] CWeaponAmmoSpawn::Use_Post called");
    g_bWeaponAmmoSpawn = false;
    return MRES_Ignored;
}*/

// SDKHooks-----------

// Change ammo when pick up weapon first time
//撿起地上的新武器並裝備時觸發
//滾輪切換已有的武器不會觸發
//(l4d_multiple_equipment) 切換副裝備會觸發
// 從weapon_xxx_spawner撿起相同武器時也會觸發: WeaponCanUse -> WeaponCanUsePost -> "weapon_drop" -> OnWeaponEquip -> WeaponEquipPost -> "spawner_give_item"
// @note: 此插件從weapon_xxx_spawner撿起武器之後會給予此插件設置的彈藥數量, 但是如果用Give則依然是給予官方指令設置的彈藥數量
// @note: 因此需要在OnWeaponEquipPost修改
// @important: 重新撿起掉在地上的武器時, 彈藥會跑掉, 需安裝https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d_save_weapon_ammo
void OnWeaponEquipPost(int client, int weapon)
{
	if (client <= 0)
		return;

    if (!IsClientInGame(client) || GetClientTeam(client) != 2)
        return;

	if (!IsValidEntity(weapon))
		return;

	if(g_bWeaponAlreadySetAmmo[weapon] || g_bIsEntityTransitioned[weapon])
		return;

	char sWeapon[24];
	GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));

	int iConfigReserveAmmo;
	if( g_smReserveData.GetValue(sWeapon, iConfigReserveAmmo) == false) return;
	
	int iOfficialAmmo;
	if( strcmp(sWeapon[7], "smg") == 0 )
		iOfficialAmmo = g_iAmmoSmg;
	else if( strcmp(sWeapon[7], "rifle") == 0 )
		iOfficialAmmo = g_iAmmoRifle;
	else if( strcmp(sWeapon[7], "pumpshotgun") == 0 )
		iOfficialAmmo = g_iAmmoShotgun;
	else if( strcmp(sWeapon[7], "autoshotgun") == 0 )
		iOfficialAmmo = g_iAmmoAutoShot;
	else if( strcmp(sWeapon[7], "hunting_rifle") == 0 )
		iOfficialAmmo = g_iAmmoHunting;
	else if( g_bL4D2Version )
	{
		if( strcmp(sWeapon[7], "smg_mp5") == 0 || strcmp(sWeapon[7], "smg_silenced") == 0 )
			iOfficialAmmo = g_iAmmoSmg;
		else if( strcmp(sWeapon[7], "rifle_desert") == 0 || strcmp(sWeapon[7], "rifle_ak47") == 0 || strcmp(sWeapon[7], "rifle_sg552") == 0 )
			iOfficialAmmo = g_iAmmoRifle;
		else if( strcmp(sWeapon[7], "shotgun_chrome") == 0 )
			iOfficialAmmo = g_iAmmoShotgun;
		else if( strcmp(sWeapon[7], "shotgun_spas") == 0 )
			iOfficialAmmo = g_iAmmoAutoShot;
		else if( strcmp(sWeapon[7], "grenade_launcher") == 0 )
			iOfficialAmmo = g_iAmmoGL;
		else if( strcmp(sWeapon[7], "rifle_m60") == 0 )
			iOfficialAmmo = g_iAmmoM60;
		else if( strcmp(sWeapon[7], "chainsaw") == 0 )
			iOfficialAmmo = g_iAmmoChainsaw;
		else if( strcmp(sWeapon[7], "sniper_awp") == 0 || strcmp(sWeapon[7], "sniper_military") == 0 || strcmp(sWeapon[7], "sniper_scout") == 0 )
			iOfficialAmmo = g_iAmmoSniper;
	}

	int iReserveAmmo = GetEntProp(weapon, Prop_Data, "m_iExtraPrimaryAmmo");
	if(iReserveAmmo == iOfficialAmmo)
	{
		//PrintToChatAll("(OnWeaponEquipPost) \x01%N got %s [%i] \x05(Fixed %i --> %i max reserve)", client, sWeapon, weapon, iReserveAmmo, iConfigReserveAmmo);
			
		SetEntProp(weapon, Prop_Send, "m_iExtraPrimaryAmmo", iConfigReserveAmmo);
		//GetOrSetPlayerAmmo(client, weapon, iConfigReserveAmmo);
	}

	g_bWeaponAlreadySetAmmo[weapon] = true;
}

//Other----

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

stock int GetOrSetPlayerAmmo(int client, int iWeapon, int iAmmo = -1)
{
	static int iOffsetPrimaryAmmoType = -1;
	if(iOffsetPrimaryAmmoType == -1)
	{
		iOffsetPrimaryAmmoType = FindSendPropInfo("CBaseCombatWeapon", "m_iPrimaryAmmoType");
	}

	static int iOffsetAmmo = -1;
	if(iOffsetAmmo == -1)
	{
		iOffsetAmmo = FindSendPropInfo("CCSPlayer", "m_iAmmo");
	}

	int offset = GetEntData(iWeapon, iOffsetPrimaryAmmoType) * 4; // Thanks to "Root" or whoever for this method of not hard-coding offsets: https://github.com/zadroot/AmmoManager/blob/master/scripting/ammo_manager.sp

	if( offset )
	{
		if( iAmmo != -1 ) SetEntData(client, iOffsetAmmo + offset, iAmmo);
		else
		{
			int ammo = GetEntData(client, iOffsetAmmo + offset);
			return ammo;
		}
	}

	return 0;
}

// Other API---

public void L4D_OnEntityTransitioned(int entity, int oldindex)
{
	g_bIsEntityTransitioned[entity] = true;
}

public void L4D_OnPlayerItemTransitioned(int client, int weapon, int oldindex)
{
	g_bIsEntityTransitioned[weapon] = true;
}