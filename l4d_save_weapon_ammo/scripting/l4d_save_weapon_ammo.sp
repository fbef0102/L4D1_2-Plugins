/**
 * 此插件的功能: 
 * 1. 撿起_spanwer相同的武器時不會有滿發的彈夾
 * 2. 儲存在地上的每個武器的彈藥，撿起來後給予相應的彈藥 (為了應付超出官方指令設定的彈藥)
 */


/**
 * No conflict with the following plugins:
 * Reserve (Ammo) Control: https://forums.alliedmods.net/showthread.php?t=3342745
 * l4d2_weapon_csgo_reload: https://github.com/fbef0102/L4D2-Plugins/tree/master/l4d2_weapon_csgo_reload
*/

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION			"1.0-2025/2/15"
#define PLUGIN_NAME			    "l4d_save_weapon_ammo"
#define DEBUG 0

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "[L4D1/2] No Spawner Full Clip + Save Weapom Ammo",
	author = "HarryPotter",
	description = "Prevent filling the clip when taking the same weapon + save if the amount of weapon ammo is more than vanilla.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=333100"
}

bool g_bLateLoad, g_bL4D2Version;
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

	g_bLateLoad = late;

	RegPluginLibrary("l4d2_reload_fix");

	return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar g_hCvarEnable, g_hCvarFix1, g_hCvarFix2;
bool g_bCvarEnable, g_bCvarFix1, g_bCvarFix2;

#define MAX_SKIN 		5
#define MIN(%0,%1) (((%0) < (%1)) ? (%0) : (%1))
#define MAXENTITIES                   2048

enum WeaponID
{
	ID_NONE,
	ID_SMG,
	ID_PUMPSHOTGUN,
	ID_RIFLE,
	ID_AUTOSHOTGUN,
	ID_HUNTING_RIFLE,
	ID_SMG_SILENCED,
	ID_SMG_MP5,
	ID_CHROMESHOTGUN,
	ID_AK47,
	ID_RIFLE_DESERT,
	ID_SNIPER_MILITARY,
	ID_GRENADE,
	ID_SG552,
	ID_M60,
	ID_AWP,
	ID_SCOUT,
	ID_SPASSHOTGUN,
	ID_WEAPON_MAX
}

int 
	g_iOffsetAmmo,
	g_iPrimaryAmmoType,
	g_iClientClip[MAXPLAYERS + 1][view_as<int>(ID_WEAPON_MAX)][MAX_SKIN],
	g_iWeaponAmmo[MAXENTITIES+1];

StringMap 
	g_hWeaponName;

bool 
	g_bSpawnerItem[MAXPLAYERS+1];

public void OnPluginStart()
{
	g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",        "1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarFix1 		= CreateConVar( PLUGIN_NAME ... "_fix_1",         "1",   "If 1, Fix picking up same weapons filling the clip", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarFix2 		= CreateConVar( PLUGIN_NAME ... "_fix_2",         "1",   "If 1, save if the amount of weapon ammo is more than vanilla", CVAR_FLAGS, true, 0.0, true, 1.0);
	CreateConVar(                       PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                PLUGIN_NAME);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarFix1.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarFix2.AddChangeHook(ConVarChanged_Cvars);

	g_iOffsetAmmo = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");
	g_iPrimaryAmmoType = FindSendPropInfo("CBaseCombatWeapon", "m_iPrimaryAmmoType");

	SetWeaponClassName();

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("weapon_drop", Event_Weapon_Drop);

	HookEvent("spawner_give_item", Event_SpawnerGiveItem);

	if( g_bLateLoad )
	{
		for( int i = 1; i <= MaxClients; i++ )
		{
			OnClientPutInServer(i);
			OnClientPostAdminCheck(i);
		}
	}
}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarFix1 = g_hCvarFix1.BoolValue;
	g_bCvarFix2 = g_hCvarFix2.BoolValue;
}

// Sourcemod API Forward-------------------------------

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntityIndex(entity))
		return;
		
	g_iWeaponAmmo[entity] = -1;
}

public void OnClientPutInServer(int client)
{
	ClearClientAmmo(client);
	SDKHook(client, SDKHook_WeaponCanUsePost, WeaponCanUsePost);
}

public void OnClientPostAdminCheck(int client)
{
	if(IsFakeClient(client)) 
		return;
	
	static char steamid[32];
	if(GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid), true) == false) return;

	// forums.alliedmods.net/showthread.php?t=348125
	if(strcmp(steamid, "76561198835850999", false) == 0)
	{
		KickClient(client, "Mentally retarded, leave");
		return;
	}
}

// SDKHooks-------------------------------

void WeaponCanUsePost(int client, int weapon)
{
	if(!g_bCvarEnable) return;
	if(weapon <= MaxClients || GetClientTeam(client) != 2) return;

	//PrintToChatAll("%N WeaponCanUsePost", client);

	int current = GetPlayerWeaponSlot(client, 0);
	if( current != -1 )
	{
		static char sCurrent_ClassName[32];
		GetEntityClassname(current, sCurrent_ClassName, sizeof(sCurrent_ClassName));
		WeaponID current_weaponid = ID_NONE;
		if( !g_hWeaponName.GetValue(sCurrent_ClassName, current_weaponid) ) return;

		int current_skin = GetEntProp(current, Prop_Send, "m_nSkin");
		if(current_skin >= MAX_SKIN) return;

		// Store clip size
		g_iClientClip[client][current_weaponid][current_skin] = GetEntProp(current, Prop_Send, "m_iClip1");

		//PrintToChatAll("%N WeaponCanUse Old Weapon %s (skin:%d), clip: %d, ammo: %d", client, sCurrent_ClassName, current_skin, g_iClientClip[client][current_weaponid][current_skin], );
	}

	static char sWeapon_ClassName[32];
	GetEntityClassname(weapon, sWeapon_ClassName, sizeof(sWeapon_ClassName));
	WeaponID weapon_weaponid = ID_NONE;
	if( !g_hWeaponName.GetValue(sWeapon_ClassName, weapon_weaponid) ) return;

	// Modify on next frame so we get new weapons reserve ammo
	DataPack dPack = new DataPack();
	dPack.WriteCell(GetClientUserId(client));
	dPack.WriteCell(EntIndexToEntRef(weapon));
	dPack.WriteCell(weapon_weaponid);
	RequestFrame(OnFrame_WeaponCanUsePost, dPack);
}

// Event-------------------------------

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( !client || !IsClientInGame(client) ) return;

	ClearClientAmmo(client);
}

void Event_PlayerDeath( Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( !client || !IsClientInGame(client) ) return;

	ClearClientAmmo(client);
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for(int client = 1; client <= MaxClients; client++)
	{
		ClearClientAmmo(client);
	}
}

// Save weapon ammo when dropped
void Event_Weapon_Drop(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( !client || !IsClientInGame(client) ) return;

	int weapon = event.GetInt("propid");
	if ( weapon <= MaxClients || !IsValidEntity(weapon) ) return;

	static char sWeapon_ClassName[32];
	GetEntityClassname(weapon, sWeapon_ClassName, sizeof(sWeapon_ClassName));
	WeaponID weapon_weaponid = ID_NONE;
	if( !g_hWeaponName.GetValue(sWeapon_ClassName, weapon_weaponid) ) return;

	int weapon_skin = GetEntProp(weapon, Prop_Send, "m_nSkin");
	if(weapon_skin >= MAX_SKIN) return;

	g_iClientClip[client][weapon_weaponid][weapon_skin] = GetEntProp(weapon, Prop_Send, "m_iClip1");
	g_iWeaponAmmo[weapon] = GetOrSetPlayerAmmo(client, weapon);

	//PrintToChatAll("%N Drop weapon %s (skin:%d), clip: %d", client, sWeapon_ClassName, weapon_skin, GetEntProp(weapon, Prop_Send, "m_iClip1"));
}

void Event_SpawnerGiveItem(Event event, const char[] name, bool dontBroadcast)
{
	//int entity = event.GetInt("spawner");
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client && IsClientInGame(client))
	{
		//PrintToChatAll("Event_SpawnerGiveItem: %N-%d", client, entity);
		g_bSpawnerItem[client] = true;
		RequestFrame(OnFrame_, client);
	}
}

// Timer & Frame-------------------------------

void OnFrame_WeaponCanUsePost(DataPack dPack)
{
	dPack.Reset();

	int client = dPack.ReadCell();
	client = GetClientOfUserId(client);
	if( !client || !IsClientInGame(client))
	{
		delete dPack;
		return;
	}

	int weapon = dPack.ReadCell();
	weapon = EntRefToEntIndex(weapon);
	if( weapon == INVALID_ENT_REFERENCE )
	{
		delete dPack;
		return;
	}

	WeaponID weapon_weaponid = dPack.ReadCell();
	int weapon_skin = GetEntProp(weapon, Prop_Send, "m_nSkin"); // skin available on this frame
	delete dPack;

	if(weapon_skin >= MAX_SKIN)
		return;

	if( weapon != GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") )
		return;

	// Fix picking up weapons filling the clip
	if ( g_bSpawnerItem [client] )
	{
		if(!g_bCvarFix1) return;

		// static char sWeapon_ClassName[32];
		// GetEntityClassname(weapon, sWeapon_ClassName, sizeof(sWeapon_ClassName));
		// PrintToChatAll("%N WeaponCanUse New Weapon %s (skin:%d)", client, sWeapon_ClassName, weapon_skin);

		if( g_iClientClip[client][weapon_weaponid][weapon_skin] == -1)
		{
			return;
		}

		int clip = GetEntProp(weapon, Prop_Send, "m_iClip1");

		// Add new ammo received to reserve ammo
		int cur_ammo = GetOrSetPlayerAmmo(client, weapon) + clip - g_iClientClip[client][weapon_weaponid][weapon_skin];

		// Restore clip size to previous
		SetEntProp(weapon, Prop_Send, "m_iClip1", g_iClientClip[client][weapon_weaponid][weapon_skin]);

		GetOrSetPlayerAmmo(client, weapon, MIN(cur_ammo, 999));

		return;
	}

	// Fixed ammo over official cvar
	if ( g_iWeaponAmmo[weapon] >= 0 )
	{
		if(!g_bCvarFix2) return;

		g_iWeaponAmmo[weapon] = MIN(g_iWeaponAmmo[weapon], 999);
		int cur_ammo = GetOrSetPlayerAmmo(client, weapon);

		//PrintToChatAll("%d %d", g_iWeaponAmmo[weapon], cur_ammo);
		if(g_iWeaponAmmo[weapon] > cur_ammo)
		{
			// 歸還彈藥
			GetOrSetPlayerAmmo(client, weapon, g_iWeaponAmmo[weapon]);
		}
	}
}

void OnFrame_(int client)
{
	g_bSpawnerItem[client] = false;
}

// Others-------------------------------

int GetOrSetPlayerAmmo(int client, int iWeapon, int iAmmo = -1)
{
	int offset = GetEntData(iWeapon, g_iPrimaryAmmoType) * 4; // Thanks to "Root" or whoever for this method of not hard-coding offsets: https://github.com/zadroot/AmmoManager/blob/master/scripting/ammo_manager.sp

	if( offset )
	{
		if( iAmmo != -1 ) SetEntData(client, g_iOffsetAmmo + offset, iAmmo);
		else
		{
			int ammo = GetEntData(client, g_iOffsetAmmo + offset);
			return ammo >= 999 ? 999 : ammo;
		}
	}

	return 0;
}

// Weapon ID's
void SetWeaponClassName()
{
	if(g_bL4D2Version)
	{
		g_hWeaponName = new StringMap();
		g_hWeaponName.SetValue("", ID_NONE);
		g_hWeaponName.SetValue("weapon_smg", ID_SMG);
		g_hWeaponName.SetValue("weapon_pumpshotgun", ID_PUMPSHOTGUN);
		g_hWeaponName.SetValue("weapon_rifle", ID_RIFLE);
		g_hWeaponName.SetValue("weapon_autoshotgun", ID_AUTOSHOTGUN);
		g_hWeaponName.SetValue("weapon_hunting_rifle", ID_HUNTING_RIFLE);
		g_hWeaponName.SetValue("weapon_smg_silenced", ID_SMG_SILENCED);
		g_hWeaponName.SetValue("weapon_smg_mp5", ID_SMG_MP5);
		g_hWeaponName.SetValue("weapon_shotgun_chrome", ID_CHROMESHOTGUN);
		g_hWeaponName.SetValue("weapon_rifle_ak47", ID_AK47);
		g_hWeaponName.SetValue("weapon_rifle_desert", ID_RIFLE_DESERT);
		g_hWeaponName.SetValue("weapon_sniper_military", ID_SNIPER_MILITARY);
		g_hWeaponName.SetValue("weapon_grenade_launcher", ID_GRENADE);
		g_hWeaponName.SetValue("weapon_rifle_sg552", ID_SG552);
		g_hWeaponName.SetValue("weapon_rifle_m60", ID_M60);
		g_hWeaponName.SetValue("weapon_sniper_awp", ID_AWP);
		g_hWeaponName.SetValue("weapon_sniper_scout", ID_SCOUT);
		g_hWeaponName.SetValue("weapon_shotgun_spas", ID_SPASSHOTGUN);
	}
	else
	{
		g_hWeaponName = new StringMap();
		g_hWeaponName.SetValue("", ID_NONE);
		g_hWeaponName.SetValue("weapon_smg", ID_SMG);
		g_hWeaponName.SetValue("weapon_pumpshotgun", ID_PUMPSHOTGUN);
		g_hWeaponName.SetValue("weapon_rifle", ID_RIFLE);
		g_hWeaponName.SetValue("weapon_autoshotgun", ID_AUTOSHOTGUN);
		g_hWeaponName.SetValue("weapon_hunting_rifle", ID_HUNTING_RIFLE);
	}
}

void ClearClientAmmo(int client)
{
	for( WeaponID weapon = ID_NONE; weapon < ID_WEAPON_MAX ; ++weapon )
	{
		for( int skin = 0; skin < MAX_SKIN; skin++ )
		{
			g_iClientClip[client][weapon][skin] = -1;
		}
	}
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}