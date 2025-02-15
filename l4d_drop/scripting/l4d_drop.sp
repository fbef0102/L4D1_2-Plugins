#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#undef REQUIRE_PLUGIN
#tryinclude <miuwiki_autoscar>

#if !defined _miuwiki_autoscar_included_
	native bool miuwiki_IsClientHoldAutoScar(int client);
	native float miuwiki_GetAutoScarSwitchTime(int client);
	native float miuwiki_GetAutoScarReloadTime(int client);
	native float miuwiki_GetAutoPrimaryAttackTime(int client);
	native float miuwiki_GetAutoSecondaryAttackTime(int client);
#endif

#define PLUGIN_NAME "[L4D1/2] Weapon Drop"
#define PLUGIN_AUTHOR "Machine, dcx2, Electr000999 /z, Senip, Shao, NoroHime, HarryPotter"
#define PLUGIN_DESC "Allows players to drop the weapon they are holding"
#define PLUGIN_VERSION "1.13-2024/2/15"
#define PLUGIN_URL "https://steamcommunity.com/profiles/76561198026784913/"

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESC,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}

GlobalForward OnWeaponDrop; // Called whenever weapon prepared to drop by plugin l4d_drop

bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() == Engine_Left4Dead)
	{
		g_bL4D2Version = false;
	}
	else if (GetEngineVersion() == Engine_Left4Dead2)
	{
		g_bL4D2Version = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead and Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	RegPluginLibrary("l4d_drop");
	OnWeaponDrop = CreateGlobalForward("OnWeaponDrop", ET_Event, Param_Cell, Param_CellByRef);

	MarkNativeAsOptional("miuwiki_IsClientHoldAutoScar");
	MarkNativeAsOptional("miuwiki_GetAutoScarSwitchTime");
	MarkNativeAsOptional("miuwiki_GetAutoScarReloadTime");
	MarkNativeAsOptional("miuwiki_GetAutoPrimaryAttackTime");
	MarkNativeAsOptional("miuwiki_GetAutoSecondaryAttackTime");
	
	return APLRes_Success;
}

ConVar BlockSecondaryDrop;
ConVar BlockM60Drop;
ConVar BlockDropMidAction;
ConVar g_hCvarDropSoundFile;
bool g_bBlockSecondaryDrop;
bool g_bBlockM60Drop;
int g_iBlockDropMidAction;
char g_sCvarDropSoundFile[PLATFORM_MAX_PATH];

bool g_bValidMap;

int g_iOffsetAmmo, g_iPrimaryAmmoType;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");

	g_iOffsetAmmo = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");
	g_iPrimaryAmmoType = FindSendPropInfo("CBaseCombatWeapon", "m_iPrimaryAmmoType");

	BlockSecondaryDrop = CreateConVar("sm_drop_block_secondary", "0", "Prevent players from dropping their secondaries? (Fixes bugs that can come with incapped weapons or A-Posing.)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	BlockDropMidAction = CreateConVar("sm_drop_block_mid_action", "1", "Prevent players from dropping objects in between actions? (Fixes throwable cloning.) 1 = All weapons. 2 = Only throwables.", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	if (g_bL4D2Version)
	{
		BlockM60Drop = CreateConVar("sm_drop_block_m60", "0", "Prevent players from dropping the M60? (Allows for better compatibility with certain plugins.)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
		g_hCvarDropSoundFile  = 	    CreateConVar(  "sm_drop_soundfile", 	"ui/gift_pickup.wav", 			"Drop - sound file (relative to to sound/, empty=disable)", FCVAR_NOTIFY);
	}
	else
	{
		g_hCvarDropSoundFile  = 	    CreateConVar(  "sm_drop_soundfile", 	"items/itempickup.wav", 		"Drop - sound file (relative to to sound/, empty=disable)", FCVAR_NOTIFY);
	}
	CreateConVar("sm_drop_version", PLUGIN_VERSION, "Weapon Drop version.", FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_DONTRECORD);

	GetCvars();
	BlockSecondaryDrop.AddChangeHook(ConVarChanged_Cvars);
	BlockDropMidAction.AddChangeHook(ConVarChanged_Cvars);
	if (g_bL4D2Version)
	{
		BlockM60Drop.AddChangeHook(ConVarChanged_Cvars);
	}
	g_hCvarDropSoundFile.AddChangeHook(ConVarChanged_Cvars);

	AutoExecConfig(true, "l4d_drop");
	GetCvars();

	RegConsoleCmd("sm_drop", Command_Drop);
	RegConsoleCmd("sm_g", Command_Drop);
}

bool g_bAvailable_miuwiki_autoscar;
public void OnAllPluginsLoaded()
{
	g_bAvailable_miuwiki_autoscar = LibraryExists("miuwiki_autoscar");
}

public void OnLibraryAdded(const char[] name)
{
	g_bAvailable_miuwiki_autoscar = LibraryExists("miuwiki_autoscar");
}

public void OnLibraryRemoved(const char[] name)
{
	g_bAvailable_miuwiki_autoscar = LibraryExists("miuwiki_autoscar");
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{ 
	GetCvars(); 
}

void GetCvars()
{
	g_bBlockSecondaryDrop = BlockSecondaryDrop.BoolValue;
	g_iBlockDropMidAction = BlockDropMidAction.IntValue;
	if (g_bL4D2Version) 
	{ 
		g_bBlockM60Drop = BlockM60Drop.BoolValue; 
	}

	g_hCvarDropSoundFile.GetString(g_sCvarDropSoundFile, sizeof(g_sCvarDropSoundFile));
	if (g_bValidMap) 
	{
		if(strlen(g_sCvarDropSoundFile) > 0) PrecacheSound(g_sCvarDropSoundFile);
	}
}

public void OnMapStart()
{
    g_bValidMap = true;
}

public void OnMapEnd()
{
    g_bValidMap = false;
}

public void OnConfigsExecuted()
{
    GetCvars();
}

Action Command_Drop(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[TS] This command cannot be used by server.");
		return Plugin_Handled;
	}

	if (args > 2)
	{
		if (GetAdminFlag(GetUserAdmin(client), Admin_Root))
			ReplyToCommand(client, "[SM] Usage: sm_drop <#userid|name> <slot to drop>");
	}
	else if (args == 0)
	{
		DropActiveWeapon(client);
	}
	else if (args > 0)
	{
		if (GetAdminFlag(GetUserAdmin(client), Admin_Root))
		{
			static char target[MAX_TARGET_LENGTH], arg[8];
			GetCmdArg(1, target, sizeof(target));
			GetCmdArg(2, arg, sizeof(arg));
			int slot = StringToInt(arg);

			static char target_name[MAX_TARGET_LENGTH]; target_name[0] = '\0';
			int target_list[MAXPLAYERS], target_count; 
			bool tn_is_ml;

			if ((target_count = ProcessTargetString(
				target,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_ALIVE,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
			{
				ReplyToTargetError(client, target_count);
				return Plugin_Handled;
			}
			for (int i = 0; i < target_count; i++)
			{
				if (!IsValidClient(target_list[i])) continue;
				
				if (slot > 0)
					DropSlot(target_list[i], slot);
				else
					DropActiveWeapon(target_list[i]);
			}
		}
	}

	return Plugin_Handled;
}

//#define tester_wep_slot 2

void DropSlot(int client, int slot)
{
	if (!IsValidClient(client) || !IsSurvivor(client) || !IsPlayerAlive(client) || IsplayerIncap(client) || GetInfectedAttacker(client) != -1) return;
	if (IsUsingMinigun(client)) return;
	
	//static char classname[64];
	//GetEntityClassname(GetPlayerWeaponSlot(client, tester_wep_slot), classname, sizeof(classname));
	//PrintToChatAll("slot: %s", classname);
	
	slot--;
	int weapon = GetPlayerWeaponSlot(client, slot);
	if (RealValidEntity(weapon) && DropBlocker(client, weapon))
	{
		DropWeapon(client, weapon);
	}
}

void DropActiveWeapon(int client)
{
	if (!IsValidClient(client) || !IsSurvivor(client) || !IsPlayerAlive(client) || IsplayerIncap(client) || GetInfectedAttacker(client) != -1) return;
	if (IsUsingMinigun(client)) return;
	
	//static char classname[64];
	//GetEntityClassname(GetPlayerWeaponSlot(client, tester_wep_slot), classname, sizeof(classname));
	//PrintToChatAll("slot: %s", classname);
	
	int weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (RealValidEntity(weapon) && DropBlocker(client, weapon))
		DropWeapon(client, weapon);
}

int DropBlocker(int client, int weapon)
{
	int wep_Secondary = GetPlayerWeaponSlot(client, 1);
	
	// Secondary check
	if (g_bBlockSecondaryDrop && wep_Secondary == weapon) return false;

	// M60 check
	if(g_bL4D2Version)
	{
		static char classname[32];
		GetEntityClassname(weapon, classname, sizeof(classname));
		
		if(g_bBlockM60Drop && StrEqual(classname, "weapon_rifle_m60", false))
			return false;
	}

	
	return true;
}

void DropWeapon(int client, int weapon)
{
	int slot0 = GetPlayerWeaponSlot(client, 0);
	int slot2 = GetPlayerWeaponSlot(client, 2);
	float fNow = GetGameTime();
	if ( g_iBlockDropMidAction == 1 && 
	GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon") == weapon)
	{
		if(slot2 == weapon && g_iBlockDropMidAction == 2)
		{
			if(GetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack") >= fNow)
			{
				return;
			}
		}
		else if(slot0 == weapon )
		{
			if(g_bL4D2Version && g_bAvailable_miuwiki_autoscar && miuwiki_IsClientHoldAutoScar(client))
			{
				float fTime;
				fTime = miuwiki_GetAutoScarSwitchTime(client);
				if(fTime > fNow) return;
				fTime = miuwiki_GetAutoScarReloadTime(client);
				if(fTime > fNow) return;
				fTime = miuwiki_GetAutoPrimaryAttackTime(client);
				if(fTime > fNow) return;
				fTime = miuwiki_GetAutoSecondaryAttackTime(client);
				if(fTime > fNow) return;
			}
			else
			{
				if(GetEntPropFloat(weapon, Prop_Data, "m_flNextPrimaryAttack") >= fNow)
				{
					return;
				}
			}
		}
	}

	// throwable is already thrown
	if ( slot2 == weapon && 
		GetOrSetPlayerAmmo(client, weapon) == 0) return;

	int owner = GetEntPropEnt(weapon, Prop_Data, "m_hOwner");
	//PrintToChatAll("owner: %d, client: %d", owner, client);
	if(owner != client) return;

	Action actResult = Plugin_Continue;
	Call_StartForward(OnWeaponDrop);
	Call_PushCell(client);
	Call_PushCellRef(weapon);
	Call_Finish(actResult);
	switch (actResult) {
		case Plugin_Continue :
		{
			//nothing
		}
		case Plugin_Changed:
		{
			if(!RealValidEntity(weapon)) return;
		}
		default:
		{
			PrintToChat(client, "Third-Party plugin prevents you from weapon dropping");
			return;
		}
	}

	static char classname[32];
	GetEntityClassname(weapon, classname, sizeof(classname));
	if (strcmp(classname, "weapon_pistol") == 0 && GetEntProp(weapon, Prop_Send, "m_isDualWielding") > 0)
	{
		int clip = GetEntProp(weapon, Prop_Send, "m_iClip1");
		int second_clip = 0;
		if(clip % 2 == 0)
		{
			second_clip = clip / 2;
			clip = clip / 2;
		}
		else
		{
			second_clip = clip / 2 + 1;
			clip = clip / 2;
		}
		
		RemovePlayerItem(client, weapon);
		RemoveEntity(weapon);

		int single_pistol = CreateEntityByName("weapon_pistol");
		if(single_pistol <= MaxClients) return;

		DispatchSpawn(single_pistol);
		EquipPlayerWeapon(client, single_pistol);
		SDKHooks_DropWeapon(client, single_pistol);
		if (strlen(g_sCvarDropSoundFile) > 0) PlaySoundAroundClient(client, g_sCvarDropSoundFile);
		SetEntProp(single_pistol, Prop_Send, "m_iClip1", clip);

		single_pistol = CreateEntityByName("weapon_pistol");
		if(single_pistol <= MaxClients) return;

		DispatchSpawn(single_pistol);
		EquipPlayerWeapon(client, single_pistol);
		SetEntProp(single_pistol, Prop_Send, "m_iClip1", second_clip);

		return;	
	}
	
	int ammo = GetPlayerReserveAmmo(client, weapon);

	SDKHooks_DropWeapon(client, weapon);
	if (strlen(g_sCvarDropSoundFile) > 0) PlaySoundAroundClient(client, g_sCvarDropSoundFile);
	SetPlayerReserveAmmo(client, weapon, 0);
	SetEntProp(weapon, Prop_Send, "m_iExtraPrimaryAmmo", ammo);

	if (!g_bL4D2Version) return;

	if (strcmp(classname, "weapon_defibrillator") == 0)
	{
		int modelindex = GetEntProp(weapon, Prop_Data, "m_nModelIndex");
		SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", modelindex);
	}
}

//https://forums.alliedmods.net/showthread.php?t=260445
void SetPlayerReserveAmmo(int client, int weapon, int ammo)
{
	int ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (ammotype >= 0 )
	{
		SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammotype);
		ChangeEdictState(client, FindDataMapInfo(client, "m_iAmmo"));
	}
}

int GetPlayerReserveAmmo(int client, int weapon)
{
	int ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
	if (ammotype >= 0)
	{
		return GetEntProp(client, Prop_Send, "m_iAmmo", _, ammotype);
	}
	return 0;
}

bool IsSurvivor(int client)
{ 
	return (GetClientTeam(client) == 2 || GetClientTeam(client) == 4); 
}

bool IsValidClient(int client, bool replaycheck = true)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		if (replaycheck)
		{
			if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
		}
		return true;
	}
	return false;
}

bool RealValidEntity(int entity)
{ 
	return (entity > MaxClients && IsValidEntity(entity)); 
}

bool IsplayerIncap(int client)
{
	if(GetEntProp(client, Prop_Send, "m_isHangingFromLedge") || GetEntProp(client, Prop_Send, "m_isIncapacitated"))
		return true;

	return false;
}

int GetInfectedAttacker(int client)
{
	int attacker;

	if(g_bL4D2Version)
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

void PlaySoundAroundClient(int client, char[] sSoundName)
{
	EmitSoundToAll(sSoundName, client, SNDCHAN_AUTO, SNDLEVEL_AIRCRAFT, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
}

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

bool IsUsingMinigun(int client)
{
	return ((GetEntProp(client, Prop_Send, "m_usingMountedWeapon") > 0) || (GetEntProp(client, Prop_Send, g_bL4D2Version ? "m_usingMountedGun" : "m_usingMinigun") > 0));
}