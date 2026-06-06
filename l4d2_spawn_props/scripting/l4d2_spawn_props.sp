#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <adminmenu>
#include <left4dhooks>
#include <multicolors>
#define DEBUG 0
#define GETVERSION "4.4-2026/6/6"

public Plugin myinfo = 
{
	name = "[L4D1/2] Objects Spawner Menu",
	author = "honorcode23 & $atanic $pirit & HarryPotter",
	description = "Let admins spawn any kind of objects and save with stripper cfg",
	version = GETVERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=127418"
}

bool g_bLeft4Dead2;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		g_bLeft4Dead2 = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		g_bLeft4Dead2 = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define MAX_ENTITY 2048
#define MAX_PATHS 20

#define DESIRED_ADM_FLAGS ADMFLAG_UNBAN //Edit here the flags to fit your needs!

#define RouteType_Easy		0
#define	RouteType_Medium	1
#define RouteType_Hard		2

#define	MAX_WEAPONS_L4D1		10
#define	MAX_WEAPONS_L4D2		29

char FolderNames[][] = {
	"addons/stripper",
	"addons/stripper/maps",
};

static char g_sWeaponNames_L4D1[MAX_WEAPONS_L4D1][] =
{
	"Rifle",//0
	"Autoshotgun",
	"Hunting Rifle",
	"Smg",
	"Pumpshotgun",
	"Pistol",//5
	"Molotov",
	"Pipe Bomb",
	"First Aid Kit",
	"Pain Pill"
};
static char g_sWeaponSpawn_L4D1[MAX_WEAPONS_L4D1][] =
{
	"weapon_rifle_spawn",
	"weapon_autoshotgun_spawn",
	"weapon_hunting_rifle_spawn",
	"weapon_smg_spawn",
	"weapon_pumpshotgun_spawn",
	"weapon_pistol_spawn",
	"weapon_molotov_spawn",
	"weapon_pipe_bomb_spawn",
	"weapon_first_aid_kit_spawn",
	"weapon_pain_pills_spawn"
};
static char g_sWeaponModels_L4D1[MAX_WEAPONS_L4D1][] =
{
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/Weapons/w_smg_uzi.mdl",
	"models/w_models/Weapons/w_shotgun.mdl",
	"models/w_models/weapons/w_pistol_1911.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_Medkit.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl"
};

static char g_sWeaponNames_L4D2[MAX_WEAPONS_L4D2][] =
{
	"Pistol", //0
	"Magnum",
	"Rifle",
	"AK47",
	"SG552",
	"Desert Rifle",//5
	"Autoshotgun",
	"Spas Shotgun",
	"Pumpshotgun",
	"Chrome Shotgun",
	"Smg",//10
	"Silenced Smg",
	"MP5",
	"Hunting Rifle",
	"AWP",
	"Military Sniper",//15
	"SCOUT",
	"M60 Machine Gun",
	"Grenade Launcher",
	"chainsaw",
	"Molotov",//20
	"Pipe Bomb",
	"Vomitjar",
	"Pain Pill",
	"Adrenaline",
	"First Aid Kit",//25
	"Defibrillator",
	"Explosive Pack",
	"Incendiary Pack"
};

static char g_sWeaponSpawn_L4D2[MAX_WEAPONS_L4D2][] =
{
	"weapon_pistol_spawn",
	"weapon_pistol_magnum_spawn",
	"weapon_rifle_spawn",
	"weapon_rifle_ak47_spawn",
	"weapon_rifle_sg552_spawn",
	"weapon_rifle_desert_spawn",
	"weapon_autoshotgun_spawn",
	"weapon_shotgun_spas_spawn",
	"weapon_pumpshotgun_spawn",
	"weapon_shotgun_chrome_spawn",
	"weapon_smg_spawn",
	"weapon_smg_silenced_spawn",
	"weapon_smg_mp5_spawn",
	"weapon_hunting_rifle_spawn",
	"weapon_sniper_awp_spawn",
	"weapon_sniper_military_spawn",
	"weapon_sniper_scout_spawn",
	"weapon_rifle_m60_spawn",
	"weapon_grenade_launcher_spawn",
	"weapon_chainsaw_spawn",
	"weapon_molotov_spawn",
	"weapon_pipe_bomb_spawn",
	"weapon_vomitjar_spawn",
	"weapon_pain_pills_spawn",
	"weapon_adrenaline_spawn",
	"weapon_first_aid_kit_spawn",
	"weapon_defibrillator_spawn",
	"weapon_upgradepack_explosive_spawn",
	"weapon_upgradepack_incendiary_spawn"
};

static char g_sWeaponModels_L4D2[MAX_WEAPONS_L4D2][] =
{
	"models/w_models/weapons/w_pistol_B.mdl",
	"models/w_models/weapons/w_desert_eagle.mdl",
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_rifle_ak47.mdl",
	"models/w_models/weapons/w_rifle_sg552.mdl",
	"models/w_models/weapons/w_desert_rifle.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_shotgun_spas.mdl",
	"models/w_models/weapons/w_shotgun.mdl",
	"models/w_models/weapons/w_pumpshotgun_A.mdl",
	"models/w_models/weapons/w_smg_uzi.mdl",
	"models/w_models/weapons/w_smg_a.mdl",
	"models/w_models/weapons/w_smg_mp5.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/weapons/w_sniper_awp.mdl",
	"models/w_models/weapons/w_sniper_military.mdl",
	"models/w_models/weapons/w_sniper_scout.mdl",
	"models/w_models/weapons/w_m60.mdl",
	"models/w_models/weapons/w_grenade_launcher.mdl",
	"models/weapons/melee/w_chainsaw.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_bile_flask.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl",
	"models/w_models/weapons/w_eq_adrenaline.mdl",
	"models/w_models/weapons/w_eq_Medkit.mdl",
	"models/w_models/weapons/w_eq_defibrillator.mdl",
	"models/w_models/weapons/w_eq_explosive_ammopack.mdl",
	"models/w_models/weapons/w_eq_incendiary_ammopack.mdl",
};

#define MODEL_AMMO_L4D			"models/props_unique/spawn_apartment/coffeeammo.mdl"
#define MODEL_AMMO_L4D2			"models/props/terror/ammo_stack.mdl"
#define MODEL_AMMO_L4D3			"models/props/de_prodigy/ammo_can_02.mdl"
#define MODEL_LASER				"models/w_models/Weapons/w_laser_sights.mdl"


static char g_sOtherNames_L4D1[][] =
{
	"Ammo (L4D1 model)",//0
	"Ammo (L4D2 model)",
	"Ammo (Box model)",
};
static char g_sOthers_L4D1[][] =
{
	"weapon_ammo_spawn",
	"weapon_ammo_spawn",
	"weapon_ammo_spawn",
};
static char g_sOtherModels_L4D1[][] =
{
	MODEL_AMMO_L4D,
	MODEL_AMMO_L4D2,
	MODEL_AMMO_L4D3,
};

static char g_sOtherNames_L4D2[][] =
{
	"Ammo (L4D1 model)",//0
	"Ammo (L4D2 model)",
	"Ammo (Box model)",
	"Laser Sight"
};
static char g_sOthers_L4D2[][] =
{
	"weapon_ammo_spawn",
	"weapon_ammo_spawn",
	"weapon_ammo_spawn",
	"upgrade_laser_sight"
};
static char g_sOtherModels_L4D2[][] =
{
	MODEL_AMMO_L4D,
	MODEL_AMMO_L4D2,
	MODEL_AMMO_L4D3,
	MODEL_LASER,
};

StringMap g_smModelCount;

TopMenu g_TopMenuHandle;

int g_iMoveCategory[MAXPLAYERS+1]			= {0};
int g_iLastObject[MAXPLAYERS+1]				= {INVALID_ENT_REFERENCE};
int g_iLockObject[MAXPLAYERS+1]				= {INVALID_ENT_REFERENCE};

bool g_bSpawned[MAX_ENTITY]				= {false};
bool g_bUnsolid[MAX_ENTITY]				= {false};

// Global variables to hold menu position
int g_iRotateMenuPosition[MAXPLAYERS+1]			= {0};
int g_iMoveMenuPosition[MAXPLAYERS+1]			= {0};

int g_iMeleesMenuPosition[MAXPLAYERS+1]		= {0};
int g_iItemsMenuPosition[MAXPLAYERS+1]		= {0};
int g_iOthersMenuPosition[MAXPLAYERS+1]		= {0};

ConVar stripper_cfg_path, mp_gamemode;
char g_sCvar_stripper_cfg_path[128];

ConVar g_cvarPhysics,
	g_cvarDynamic,
	g_cvarStatic, g_cvarItem,
	g_cvarLog, g_cvarModelFile, g_cvarAutoload, g_cvarGlow;
bool g_bCvarPhysics,
	g_bCvarDynamic,
	g_bCvarStatic, g_bCvarItem,
	g_bCvarLog, g_bCvarAutoload, g_bCvarGlow;
char g_sCvarModelFile[256];

enum ESpawnCategory
{
	SpawnCategory_None,
	SpawnCategory_Physics_Crosshair,
	SpawnCategory_Physics_Body,
	SpawnCategory_NoSolid_Crosshair,
	SpawnCategory_NoSolid_Body,
	SpawnCategory_Solid_Crosshair,
	SpawnCategory_Solid_Body,
	SpawnCategory_Item_Crosshair,
	SpawnCategory_Item_Body,
}
ESpawnCategory 
	g_eSpawnCategory[MAXPLAYERS+1];

enum EWeaponItemCategory
{
	WeaponItemCategory_None,
	WeaponItemCategory_GunsMain,
	WeaponItemCategory_GunsRifle,
	WeaponItemCategory_GunsSniper,
	WeaponItemCategory_GunsShotguns,
	WeaponItemCategory_GunsSMG,
	WeaponItemCategory_GunsPistol,
	WeaponItemCategory_Melees,
	WeaponItemCategory_Items,
	WeaponItemCategory_Others,
}
EWeaponItemCategory
	g_eWeaponItemCategory[MAXPLAYERS+1];

char
	g_sObjectCategory[MAXPLAYERS+1][5][PLATFORM_MAX_PATH];

int 
	g_iCategoryLevel[MAXPLAYERS+1],
	g_iCategoryPos[MAXPLAYERS+1],
	LOCK_COLORS[3] = {255, 140, 0};

ArrayList
	g_aMeleeScripts;

KeyValues	
	g_hData;

public void OnPluginStart()
{	
	mp_gamemode = FindConVar("mp_gamemode");

	LoadTranslations("l4d2_spawn_props.phrases");

	g_cvarPhysics 		= CreateConVar("l4d2_spawn_props_physics", 				"1", "If 1, Enable the Physics Objects in the menu", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarDynamic 		= CreateConVar("l4d2_spawn_props_dynamic",				"1", "If 1, Enable the Dynamic (Non-solid) Objects in the menu", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarStatic 		= CreateConVar("l4d2_spawn_props_static",				"1", "If 1, Enable the Static (Solid) Objects in the menu", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarItem 			= CreateConVar("l4d2_spawn_props_items",				"1", "If 1, Enable the Items & Weapons Objects in the menu", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarLog 			= CreateConVar("l4d2_spawn_props_log_actions", 			"0", "If 1, Log if an admin spawns an object?", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarModelFile 	= CreateConVar("l4d2_spawn_props_model_file", 			"data/l4d2_spawn_props/model_english.cfg", "Model file to read, default: data/l4d2_spawn_props/model_english.cfg", CVAR_FLAGS);
	g_cvarAutoload 		= CreateConVar("l4d2_spawn_props_autoload_random_path", "0", "Enable the plugin to auto load data/l4d2_spawn_props/random_path.cfg?", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_cvarGlow			= CreateConVar("l4d2_spawn_props_glow", 				"1", "If 1, make object glow on last placed objects or last locking object", CVAR_FLAGS, true, 0.0, true, 1.0);

	CreateConVar("l4d2_spawn_props_version", GETVERSION, "Version of the Plugin", CVAR_FLAGS_PLUGIN_VERSION); 
	AutoExecConfig(true, "l4d2_spawn_props");

	GetCvars();
	g_cvarPhysics.AddChangeHook(ConVarChanged_Cvars);
	g_cvarDynamic.AddChangeHook(ConVarChanged_Cvars);
	g_cvarStatic.AddChangeHook(ConVarChanged_Cvars);
	g_cvarItem.AddChangeHook(ConVarChanged_Cvars);
	g_cvarLog.AddChangeHook(ConVarChanged_Cvars);
	g_cvarModelFile.AddChangeHook(ConVarChanged_Cvars);
	g_cvarAutoload.AddChangeHook(ConVarChanged_Cvars);
	g_cvarGlow.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy); //trigger twice in versus/survival/scavenge mode, one when all survivors wipe out or make it to saferom, one when first round ends (second round_start begins).
	HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //1. all survivors make it to saferoom in and server is about to change next level in coop mode (does not trigger round_end), 2. all survivors make it to saferoom in versus
	HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
	HookEvent("finale_win", 			Event_RoundEnd,		EventHookMode_PostNoCopy);


	RegAdminCmd("sm_spawnprop", CmdSpawnProp, DESIRED_ADM_FLAGS, "Spawns an object with the given information, sm_spawnprop <model> [static | dynamic | physics] [cursor | origin]");
	RegAdminCmd("sm_savemap", CmdSaveMap, DESIRED_ADM_FLAGS, "Save all the spawned object in a stripper file, path: addons/stripper/maps/XXXX.cfg (XXXX is map name)");

	RegAdminCmd("sm_prop_rotate", CmdRotate, DESIRED_ADM_FLAGS, "Rotates the looking spawned object with the desired angles, Usage: sm_prop_rotate <axys> <angles> [e.g.: !prop_rotate x 30]");
	RegAdminCmd("sm_prop_removelast", CmdRemoveLast, DESIRED_ADM_FLAGS, "Remove last spawned object");
	RegAdminCmd("sm_prop_removelook", CmdRemoveLook, DESIRED_ADM_FLAGS, "Remove the looking object");
	RegAdminCmd("sm_prop_removeall", CmdRemoveAll, DESIRED_ADM_FLAGS, "Remove all spawned objects");
	RegAdminCmd("sm_prop_move", CmdMove, DESIRED_ADM_FLAGS, "Move the looking spawned object with the desired movement type, Usage: sm_prop_move <axys> <distance> [e.g.: !prop_move x 30]");
	RegAdminCmd("sm_prop_setang", CmdSetAngles, DESIRED_ADM_FLAGS, "Forces the looking spawned object angles, Usage: sm_prop_setang <X Y Z> [e.g.: !prop_setang 30 0 34]");
	RegAdminCmd("sm_prop_setpos", CmdSetPosition, DESIRED_ADM_FLAGS, "Sets the looking spawned object position, Usage: sm_prop_setpos <X Y Z> [e.g.: !prop_setpos 505 -34 17]");
	RegAdminCmd("sm_prop_lock", CmdLock, DESIRED_ADM_FLAGS, "Locks the looking spawned object, Use for move and rotate");
	RegAdminCmd("sm_prop_clone", CmdClone, DESIRED_ADM_FLAGS, "Clone the last spawned object");
	RegAdminCmd("sm_prop_print", CmdDebugProp, DESIRED_ADM_FLAGS, "Print the looking object information");

	AddCommandListener(ServerCmd_changelevel, "changelevel");

	TopMenu topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(topmenu);
	}


	//Create required folders
	BuildFileDirectories();

	CreateStringMap();

	g_aMeleeScripts = new ArrayList(ByteCountToCells(64));
}

public void OnPluginEnd()
{
	delete g_smModelCount;
}

public void OnAllPluginsLoaded()
{
	// stripper extension
	if( FindConVar("stripper_version") == null )
	{
		SetFailState("\n==========\nWarning: You should install \"Stripper:Source\" to spawn objects permanently to the map: https://www.bailopan.net/stripper/snapshots/1.2/\n==========\n");
	}

	stripper_cfg_path = FindConVar("stripper_cfg_path");
	if(stripper_cfg_path == null)
	{
		SetFailState("\n==========\nWarning: You should install \"stripper-1.2.2-git141-xxxxx.zip\": https://www.bailopan.net/stripper/snapshots/1.2/\n==========\n");
	}


	GetOtherCvars();
	stripper_cfg_path.AddChangeHook(ConVarChanged_OtherCvars);
}

//-------------------------------Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void ConVarChanged_OtherCvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetOtherCvars();
}

void GetOtherCvars()
{
	stripper_cfg_path.GetString(g_sCvar_stripper_cfg_path, sizeof(g_sCvar_stripper_cfg_path));
}

void GetCvars()
{
	g_bCvarPhysics = g_cvarPhysics.BoolValue;
	g_bCvarDynamic = g_cvarDynamic.BoolValue;
	g_bCvarStatic = g_cvarStatic.BoolValue;
	g_bCvarItem = g_cvarItem.BoolValue;
	g_bCvarLog = g_cvarLog.BoolValue;
	g_cvarModelFile.GetString(g_sCvarModelFile, sizeof(g_sCvarModelFile));
	g_bCvarAutoload = g_cvarAutoload.BoolValue;
	g_bCvarGlow = g_cvarGlow.BoolValue;
}

//地圖開始載入時就會觸發
// 晚載入不會觸發
public void OnMapInit(const char[] mapName)
{
	if(!g_bCvarAutoload) return;

	//在此時修改stripper_cfg_path會生效

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "data/l4d2_spawn_props/random_path.cfg");
	if( !FileExists(sPath) )
	{
		SetFailState("File Not Found: %s", sPath);
		return;
	}

	// Load config
	KeyValues hData = new KeyValues("l4d2_spawn_props");
	if( !hData.ImportFromFile(sPath) )
	{
		SetFailState("File Format Not Correct: %s", sPath);
		delete hData;
		return;
	}

	char sMpGameMode[64], StripperCfgPath[PLATFORM_MAX_PATH];
	mp_gamemode.GetString(sMpGameMode, sizeof sMpGameMode);
	//LogError("sMpGameMode: %s", sMpGameMode);

	int total;
	char sNumber[4];
	hData.GetString("stripper_cfg_path_default", StripperCfgPath, sizeof StripperCfgPath);

	if( hData.JumpToKey("default") )
	{
		if( strlen(sMpGameMode) > 0 && hData.JumpToKey(sMpGameMode) )
		{
			total = hData.GetNum("total", 0);
			if(total > 0)
			{
				FormatEx(sNumber, sizeof sNumber, "%d", GetRandomInt(1, total));
				hData.GetString(sNumber, StripperCfgPath, sizeof StripperCfgPath, StripperCfgPath);
			}

			hData.GoBack();
		}

		hData.GoBack();
	}

	if( hData.JumpToKey(mapName) )
	{
		if( strlen(sMpGameMode) > 0 && hData.JumpToKey(sMpGameMode) )
		{
			total = hData.GetNum("total", 0);
			if(total > 0)
			{
				FormatEx(sNumber, sizeof sNumber, "%d", GetRandomInt(1, total));
				hData.GetString(sNumber, StripperCfgPath, sizeof StripperCfgPath, StripperCfgPath);
			}

			hData.GoBack();
		}

		hData.GoBack();
	}

	stripper_cfg_path.SetString(StripperCfgPath);

	delete hData;
}

public void OnMapStart()
{
	for(int i=MaxClients; i < MAX_ENTITY; i++)
	{
		g_bSpawned[i] = false;
		g_bUnsolid[i] = false;
	}

	int max = MAX_WEAPONS_L4D1;
	if( g_bLeft4Dead2 ) max = MAX_WEAPONS_L4D2;
	for( int i = 0; i < max; i++ )
	{
		PrecacheModel(g_bLeft4Dead2 ? g_sWeaponModels_L4D2[i] : g_sWeaponModels_L4D1[i], true);
	}

	PrecacheModel(MODEL_AMMO_L4D, true);
	PrecacheModel(MODEL_AMMO_L4D2, true);
	PrecacheModel(MODEL_AMMO_L4D3, true);
	if( g_bLeft4Dead2 ) PrecacheModel(MODEL_LASER, true);

	if( g_bLeft4Dead2 )
	{
		PrecacheModel("models/weapons/melee/v_bat.mdl", true);
		PrecacheModel("models/weapons/melee/v_cricket_bat.mdl", true);
		PrecacheModel("models/weapons/melee/v_crowbar.mdl", true);
		PrecacheModel("models/weapons/melee/v_electric_guitar.mdl", true);
		PrecacheModel("models/weapons/melee/v_fireaxe.mdl", true);
		PrecacheModel("models/weapons/melee/v_frying_pan.mdl", true);
		PrecacheModel("models/weapons/melee/v_golfclub.mdl", true);
		PrecacheModel("models/weapons/melee/v_katana.mdl", true);
		PrecacheModel("models/weapons/melee/v_machete.mdl", true);
		PrecacheModel("models/weapons/melee/v_tonfa.mdl", true);
		PrecacheModel("models/weapons/melee/v_pitchfork.mdl", true);
		PrecacheModel("models/weapons/melee/v_shovel.mdl", true);

		PrecacheModel("models/weapons/melee/w_bat.mdl", true);
		PrecacheModel("models/weapons/melee/w_cricket_bat.mdl", true);
		PrecacheModel("models/weapons/melee/w_crowbar.mdl", true);
		PrecacheModel("models/weapons/melee/w_electric_guitar.mdl", true);
		PrecacheModel("models/weapons/melee/w_fireaxe.mdl", true);
		PrecacheModel("models/weapons/melee/w_frying_pan.mdl", true);
		PrecacheModel("models/weapons/melee/w_golfclub.mdl", true);
		PrecacheModel("models/weapons/melee/w_katana.mdl", true);
		PrecacheModel("models/weapons/melee/w_machete.mdl", true);
		PrecacheModel("models/weapons/melee/w_tonfa.mdl", true);
		PrecacheModel("models/weapons/melee/w_pitchfork.mdl", true);
		PrecacheModel("models/weapons/melee/w_shovel.mdl", true);

		PrecacheGeneric("scripts/melee/baseball_bat.txt", true);
		PrecacheGeneric("scripts/melee/cricket_bat.txt", true);
		PrecacheGeneric("scripts/melee/crowbar.txt", true);
		PrecacheGeneric("scripts/melee/electric_guitar.txt", true);
		PrecacheGeneric("scripts/melee/fireaxe.txt", true);
		PrecacheGeneric("scripts/melee/frying_pan.txt", true);
		PrecacheGeneric("scripts/melee/golfclub.txt", true);
		PrecacheGeneric("scripts/melee/katana.txt", true);
		PrecacheGeneric("scripts/melee/machete.txt", true);
		PrecacheGeneric("scripts/melee/tonfa.txt", true);
		PrecacheGeneric("scripts/melee/pitchfork.txt", true);
		PrecacheGeneric("scripts/melee/shovel.txt", true);
	}

	CreateTimer(1.0, Timer_GetMeleeTable, _, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_GetMeleeTable(Handle timer)
{
	delete g_aMeleeScripts;
	g_aMeleeScripts = new ArrayList(ByteCountToCells(64));
	int table = FindStringTable("meleeweapons");
	if (table != INVALID_STRING_TABLE) {
		int num = GetStringTableNumStrings(table);
		char melee[64];
		for (int i; i < num; i++) {
			ReadStringTable(table, i, melee, sizeof melee);
			g_aMeleeScripts.PushString(melee);
		}
	}
	return Plugin_Continue;
}

public void OnConfigsExecuted()
{
	GetCvars();
	LoadData();
}

void LoadData()
{
    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), g_sCvarModelFile);
    if( !FileExists(sPath) )
    {
        SetFailState("File Not Found: %s", sPath);
        return;
    }

    // Load config
	delete g_hData;
    g_hData = new KeyValues("l4d2_spawn_props");
    if( !g_hData.ImportFromFile(sPath) )
    {
        SetFailState("File Format Not Correct: %s", sPath);
        delete g_hData;
        return;
    }
}

Action CmdDebugProp(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	
	//int Object = g_iLastObject[client];
	int Object = FindObjectYouAreLooking(client, false); 
	if(Object <= MaxClients || !IsValidEntity(Object))
	{
		CPrintToChat(client, "[TS] %T","You are not looking at a valid object", client);
		return Plugin_Handled;
	}

	static char m_ModelName[PLATFORM_MAX_PATH];
	GetEntPropString(Object, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
	CPrintToChat(client, "[TS] %T", "Object Model", client, Object, m_ModelName);

	static char name[256];
	GetEntPropString(Object, Prop_Data, "m_iName", name, sizeof(name));
	CPrintToChat(client, "[TS] %T", "Object Targetname", client, name);

	static float position[3];
	GetEntPropVector(Object, Prop_Send, "m_vecOrigin", position);
	CPrintToChat(client, "[TS] %T", "Object Position", client, position[0], position[1], position[2]);

	static float angle[3];
	GetEntPropVector(Object, Prop_Data, "m_angRotation", angle);
	CPrintToChat(client, "[TS] %T", "Object Angle", client, angle[0], angle[1], angle[2]);

	return Plugin_Handled;
}

Action CmdSpawnProp(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	if(args < 3)
	{
		CPrintToChat(client, "[TS] Usage: sm_spawnprop <model> [static | dynamic | physics] [cursor | origin]");
		return Plugin_Handled;
	}
	char arg1[256];
	char arg2[256];
	char arg3[256];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	char model[256];
	strcopy(model, sizeof(model), arg1);
	if(!IsModelPrecached(model))
	{
		if(PrecacheModel(model) <= 0)
		{
			CPrintToChat(client, "[TS] There was a problem spawning the selected model [ERROR: Invalid Model]");
			return Plugin_Handled;
		}
	}

	if(strcmp(arg2, "static", false) == 0)
	{
		float VecOrigin[3];
		float VecAngles[3];
		int prop = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(prop, "model", model);
		DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
		if(strcmp(arg3, "cursor") == 0)
		{
			GetClientEyePosition(client, VecOrigin);
			GetClientEyeAngles(client, VecAngles);
			TR_TraceRayFilter(VecOrigin, VecAngles, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitSelf, client);
			if(TR_DidHit(null))
			{
				TR_GetEndPosition(VecOrigin);
			}
			else
			{
				CPrintToChat(client, "[TS] Vector out of world geometry. Spawning on current position instead");
			}
		}
		else if(strcmp(arg3, "origin") == 0)
		{
			GetClientEyePosition(client, VecOrigin);
			GetClientEyeAngles(client, VecAngles);
		}
		else
		{
			CPrintToChat(client, "[TS] Invalid spawn method specified. Use: [cursor | origin]");
			return Plugin_Handled;
		}
		VecAngles[0] = 0.0;
		VecAngles[2] = 0.0;
		DispatchKeyValueVector(prop, "angles", VecAngles);
		TeleportEntity(prop, VecOrigin, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(prop);

		SetEntProp(prop, Prop_Send, "m_nSolidType", 6);
		g_bSpawned[prop] = true;
		g_bUnsolid[prop] = false;

		LockGlow(client, prop);
		g_iLastObject[client] = EntIndexToEntRef(prop);
		g_iLockObject[client] = EntIndexToEntRef(prop);

		LogSpawn("%N spawned a static object with model <%s>", client, model);
	}
	else if(strcmp(arg2, "dynamic", false) == 0)
	{
		float VecOrigin[3];
		float VecAngles[3];
		int prop = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(prop, "model", model);
		DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
		if(strcmp(arg3, "cursor") == 0 )
		{
			GetClientEyePosition(client, VecOrigin);
			GetClientEyeAngles(client, VecAngles);
			TR_TraceRayFilter(VecOrigin, VecAngles, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitSelf, client);
			if(TR_DidHit(null))
			{
				TR_GetEndPosition(VecOrigin);
			}
			else
			{
				CPrintToChat(client, "[TS] Vector out of world geometry. Spawning on current position instead");
			}
		}
		else if(strcmp(arg3, "origin")== 0)
		{
			GetClientEyePosition(client, VecOrigin);
			GetClientEyeAngles(client, VecAngles);
		}
		else
		{
			CPrintToChat(client, "[TS] Invalid spawn method specified. Use: [cursor | origin]");
			return Plugin_Handled;
		}
		VecAngles[0] = 0.0;
		VecAngles[2] = 0.0;
		DispatchKeyValueVector(prop, "angles", VecAngles);
		TeleportEntity(prop, VecOrigin, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(prop);

		SetEntProp(prop, Prop_Send, "m_nSolidType", 1);
		g_bSpawned[prop] = true;
		g_bUnsolid[prop] = true;

		LockGlow(client, prop);
		g_iLastObject[client] = EntIndexToEntRef(prop);
		g_iLockObject[client] = EntIndexToEntRef(prop);

		LogSpawn("%N spawned a dynamic object with model <%s>", client, model);
	}
	else if(strcmp(arg2, "physics", false) == 0)
	{
		float VecOrigin[3];
		float VecAngles[3];
		int prop = CreateEntityByName("prop_physics_override");
		DispatchKeyValue(prop, "model", model);
		DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
		if(strcmp(arg3, "cursor")== 0)
		{
			GetClientEyePosition(client, VecOrigin);
			GetClientEyeAngles(client, VecAngles);
			TR_TraceRayFilter(VecOrigin, VecAngles, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitSelf, client);
			if(TR_DidHit(null))
			{
				TR_GetEndPosition(VecOrigin);
			}
			else
			{
				CPrintToChat(client, "[TS] Vector out of world geometry. Spawning on current position instead");
			}
		}
		else if(strcmp(arg3, "origin")== 0)
		{
			GetClientEyePosition(client, VecOrigin);
			GetClientEyeAngles(client, VecAngles);
		}
		else
		{
			CPrintToChat(client, "[TS] Invalid spawn method specified. Use: [cursor | origin]");
			return Plugin_Handled;
		}
		VecAngles[0] = 0.0;
		VecAngles[2] = 0.0;
		DispatchKeyValueVector(prop, "angles", VecAngles);
		TeleportEntity(prop, VecOrigin, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(prop);

		g_bSpawned[prop] = true;

		LockGlow(client, prop);
		g_iLastObject[client] = EntIndexToEntRef(prop);
		g_iLockObject[client] = EntIndexToEntRef(prop);

		LogSpawn("%N spawned a physics object with model <%s>", client, model);
	}
	else
	{
		CPrintToChat(client, "[TS] Invalid render mode. Use: [static | dynamic | physics]");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

//Admin Menu ready
public void OnAdminMenuReady(Handle topmenu)
{
	if (topmenu == g_TopMenuHandle)
	{
		return;
	}
	g_TopMenuHandle = view_as<TopMenu>(topmenu);
	TopMenuObject menu_category_prop = g_TopMenuHandle.AddCategory("Object Spawner", Category_Handler);
	
	if (menu_category_prop != INVALID_TOPMENUOBJECT)
    {
		g_TopMenuHandle.AddItem("sm_spdelete", AdminMenu_Delete, menu_category_prop, "sm_spdelete", DESIRED_ADM_FLAGS); //Delete
		g_TopMenuHandle.AddItem("sm_spedit", AdminMenu_Edit, menu_category_prop, "sm_spedit", DESIRED_ADM_FLAGS); //Edit
		g_TopMenuHandle.AddItem("sm_spspawn", AdminMenu_Spawn, menu_category_prop, "sm_spspawn", DESIRED_ADM_FLAGS); //Spawn
		g_TopMenuHandle.AddItem("sm_spsave", AdminMenu_Save, menu_category_prop, "sm_spsave", DESIRED_ADM_FLAGS); //Save
	}
}

//Admin Category Name
void Category_Handler(TopMenu topmenu, TopMenuAction action, TopMenuObject topobj_id, int param, char[] buffer, int maxlength)
{
	if(action == TopMenuAction_DisplayTitle)
	{
		Format(buffer, maxlength, Translate(param, "%t", "Select a task:"));
	}
	else if(action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, Translate(param, "%t", "Spawn Objects"));
	}
}
/*
////////////////////////////////////////////////////////////////////////////|
						D E L E T E        M E N U							|
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
*/

void AdminMenu_Delete(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if(action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, Translate(param, "%t", "Delete Object"));
	}
	else if(action == TopMenuAction_SelectOption)
	{
		BuildDeleteMenu(param);
	}
}

void BuildDeleteMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Delete);
	menu.SetTitle("%T", "Select the delete task", client);
	menu.AddItem("sm_spdeleteall", Translate(client, "%t", "Delete All Objects"));
	menu.AddItem("sm_spdeletelook", Translate(client, "%t", "Delete Looking Object"));
	menu.AddItem("sm_spdeletelast", Translate(client, "%t", "Delete Last Object"));
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

void BuildDeleteAllAskMenu(int client)
{
	Menu menu = new Menu(MenuHandler_DA_Ask);
	menu.SetTitle("%T", "Are you sure(Delete All)?", client);	
	menu.AddItem("sm_spyes", Translate(client, "%t",  "Yes"));
	menu.AddItem("sm_spno", Translate(client, "%t", "No"));
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int MenuHandler_DA_Ask(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));
			if(strcmp(menucmd, "sm_spyes")== 0)
			{
				DeleteAllProps();
				CPrintToChat(param1, "[TS] %T", "Successfully deleted all spawned objects", param1);
			}
			else
			{
				CPrintToChat(param1, "[TS] %T", "Canceled", param1);
			}
			BuildDeleteMenu(param1);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack && g_TopMenuHandle != null)
			{
				g_TopMenuHandle.Display(param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

int MenuHandler_Delete(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));
			if(strcmp(menucmd, "sm_spdeleteall")== 0)
			{
				BuildDeleteAllAskMenu(param1);
				CPrintToChat(param1, "[TS] %T", "delete all the spawned objects?", param1);
			}
			else if(strcmp(menucmd, "sm_spdeletelook")== 0)
			{
				DeleteLookingEntity(param1);
				BuildDeleteMenu(param1);
			}
			else if(strcmp(menucmd, "sm_spdeletelast")== 0)
			{
				DeleteLastProp(param1);
				BuildDeleteMenu(param1);
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack && g_TopMenuHandle != null)
			{
				g_TopMenuHandle.Display(param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

/*
////////////////////////////////////////////////////////////////////////////|
						E D I T        M E N U							    |
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
*/

void AdminMenu_Edit(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if(action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, Translate(param, "%t", "Edit Object"));
	}
	else if(action == TopMenuAction_SelectOption)
	{
		BuildEditPropMenu(param);
	}
}

/*
////////////////////////////////////////////////////////////////////////////|
						S P A W N        M E N U							|
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
*/

void AdminMenu_Spawn(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if(action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, Translate(param, "%t", "Spawn Objects"));
	}
	else if(action == TopMenuAction_SelectOption)
	{
		BuildSpawnMenu(param);
	}
}

void BuildSpawnMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Spawn);
	menu.SetTitle("%T", "Select the spawn method", client);
	
	if(g_bCvarPhysics)
	{
		menu.AddItem("sm_spawnpc", Translate(client, "%t", "Spawn Physics On Cursor"));
		menu.AddItem("sm_spawnpo", Translate(client, "%t", "Spawn Physics On Origin"));
	}
	if(g_bCvarDynamic)
	{
		menu.AddItem("sm_spawndc", Translate(client, "%t", "Spawn Non-solid On Cursor"));
		menu.AddItem("sm_spawndo", Translate(client, "%t", "Spawn Non-solid On Origin"));
	}
	if(g_bCvarStatic)
	{
		menu.AddItem("sm_spawnsc", Translate(client, "%t", "Spawn Solid On Cursor"));
		menu.AddItem("sm_spawnso", Translate(client, "%t", "Spawn Solid On Origin"));
	}
	if(g_bCvarItem)
	{
		menu.AddItem("sm_spawnic", Translate(client, "%t", "Spawn Items On Cursor"));
		menu.AddItem("sm_spawnio", Translate(client, "%t", "Spawn Items On Origin"));
	}
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int MenuHandler_Spawn(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));
			if(strcmp(menucmd, "sm_spawnpc")== 0)
			{
				g_eSpawnCategory[param1] = SpawnCategory_Physics_Crosshair;
				BuildMenuMainCategories(param1);
			}
			else if(strcmp(menucmd, "sm_spawnpo")== 0)
			{
				g_eSpawnCategory[param1] = SpawnCategory_Physics_Body;
				BuildMenuMainCategories(param1);
			}
			else if(strcmp(menucmd, "sm_spawndc")== 0)
			{
				g_eSpawnCategory[param1] = SpawnCategory_NoSolid_Crosshair;
				BuildMenuMainCategories(param1);
			}
			else if(strcmp(menucmd, "sm_spawndo")== 0)
			{
				g_eSpawnCategory[param1] = SpawnCategory_NoSolid_Body;
				BuildMenuMainCategories(param1);
			}
			else if(strcmp(menucmd, "sm_spawnsc")== 0)
			{
				g_eSpawnCategory[param1] = SpawnCategory_Solid_Crosshair;
				BuildMenuMainCategories(param1);
			}
			else if(strcmp(menucmd, "sm_spawnso")== 0)
			{
				g_eSpawnCategory[param1] = SpawnCategory_Solid_Body;
				BuildMenuMainCategories(param1);
			}
			else if(strcmp(menucmd, "sm_spawnic")== 0)
			{
				g_eSpawnCategory[param1] = SpawnCategory_Item_Crosshair;
				BuildMenuMainCategories(param1);
			}
			else if(strcmp(menucmd, "sm_spawnio")== 0)
			{
				g_eSpawnCategory[param1] = SpawnCategory_Item_Body;
				BuildMenuMainCategories(param1);
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack && g_TopMenuHandle != null)
			{
				g_TopMenuHandle.Display(param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

/*
////////////////////////////////////////////////////////////////////////////|
						S A V E       M E N U							    |
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
*/

void AdminMenu_Save(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if(action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, Translate(param, "%t", "Save Objects"));
	}
	else if(action == TopMenuAction_SelectOption)
	{
		BuildSaveMenu(param);
	}
}

void BuildSaveMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Save);
	menu.SetTitle("%T", "Select The Save Method", client);
	menu.AddItem("sm_spsavestripper", Translate(client, "%t", "Save Stripper File (Default Path)"));
	menu.AddItem("sm_spsaveplugin", Translate(client, "%t", "Save Stripper File (Random Path)"));
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int MenuHandler_Save(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));
			if(strcmp(menucmd, "sm_spsavestripper")== 0)
			{
				SaveMapStripper(param1);
				BuildSaveMenu(param1);
				DeleteAllProps(false);
			}
			else if(strcmp(menucmd, "sm_spsaveplugin")== 0)
			{
				SaveMapStripperCustom(param1);
				BuildSaveMenu(param1);
				DeleteAllProps(false);
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack && g_TopMenuHandle != null)
			{
				g_TopMenuHandle.Display(param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

/*
////////////////////////////////////////////////////////////////////////////|
						Build Secondary Menus							    |
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
*/
void BuildMenuMainCategories(int client, int menu_pos = 0)
{
	g_iCategoryLevel[client] = 0;
	g_iCategoryPos[client] = 0;

	Menu menu = null;
	switch(g_eSpawnCategory[client])
	{
		case SpawnCategory_Physics_Crosshair, SpawnCategory_Physics_Body, 
		SpawnCategory_NoSolid_Crosshair, SpawnCategory_NoSolid_Body, 
		SpawnCategory_Solid_Crosshair, SpawnCategory_Solid_Body:
		{
			menu = new Menu(MenuHandler_MainCategory);
		}
		case SpawnCategory_Item_Crosshair:
		{
			menu = new Menu(MenuHandler_ItemCursor);
		}
		case SpawnCategory_Item_Body:
		{
			menu = new Menu(MenuHandler_ItemPosition);
		}
	}
	menu.SetTitle("%T", "Object Spawner", client);
	
	switch(g_eSpawnCategory[client])
	{
		case SpawnCategory_Physics_Crosshair,SpawnCategory_Physics_Body,
			SpawnCategory_NoSolid_Crosshair,SpawnCategory_NoSolid_Body,
			SpawnCategory_Solid_Crosshair,SpawnCategory_Solid_Body:
		{
			g_hData.Rewind();

			// true = 只走 Section ({})
			// false = Section + KeyValue
			if (g_hData.GotoFirstSubKey(true))
			{
				do
				{
					char Selection[PLATFORM_MAX_PATH];
					char Categor_Name[PLATFORM_MAX_PATH];

					g_hData.GetSectionName(Selection, sizeof(Selection));
					g_hData.GetString("menu_category", Categor_Name, sizeof Categor_Name, Selection);
					menu.AddItem(Selection, Categor_Name);

				} while (g_hData.GotoNextKey(true));
			}	
		}
		case SpawnCategory_Item_Crosshair, SpawnCategory_Item_Body:
		{
			ItemCategories(menu, client);
		}
	}

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.DisplayAt(client, menu_pos, MENU_TIME_FOREVER);	
}

void ItemCategories(Menu menu, int client)
{	
	menu.AddItem("Weapons", Translate(client, "%t", "Weapons"));
	if( g_bLeft4Dead2 ) menu.AddItem("Melees", Translate(client, "%t", "Melees"));
	menu.AddItem("Items", Translate(client, "%t", "Items"));
	menu.AddItem("Others", Translate(client, "%t", "Others"));
}

void BuildEditPropMenu(int client)
{
	Menu menu = new Menu(MenuHandler_EditProp);
	menu.SetTitle("%T", "Select an action:", client);
	menu.AddItem("rotate", Translate(client, "%t", "Rotate"));
	menu.AddItem("move", Translate(client, "%t", "Move"));
	menu.AddItem("lock", Translate(client, "%t", "Lock"));
	menu.AddItem("clone", Translate(client, "%t", "Clone"));
	menu.AddItem("info", Translate(client, "%t", "Info"));
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int MenuHandler_CategoryList(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			g_iCategoryLevel[param1]++;

			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));

			int iCategoryPos = g_iCategoryLevel[param1];
			FormatEx(g_sObjectCategory[param1][iCategoryPos], sizeof g_sObjectCategory[][], "%s", menucmd);
			DisplayNextObjectMenu(param1, iCategoryPos);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				GoBackObjectMenu(param1);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

int MenuHandler_ModelList(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			//g_iCategoryLevel[param1]++;
			g_iCategoryPos[param1] = menu.Selection;

			char model[256];
			GetMenuItem(menu, param2, model, sizeof(model));
			if(!IsModelPrecached(model))
			{
				PrecacheModel(model);
			}
			if(g_eSpawnCategory[param1] == SpawnCategory_Physics_Crosshair)
			{
				float VecOrigin[3];
				float VecAngles[3];
				int prop = CreateEntityByName("prop_physics_override");
				DispatchKeyValue(prop, "model", model);
				DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
				GetClientEyePosition(param1, VecOrigin);
				GetClientEyeAngles(param1, VecAngles);
				
				TR_TraceRayFilter(VecOrigin, VecAngles, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitSelf, param1);
				if(TR_DidHit(null))
				{
					TR_GetEndPosition(VecOrigin);
				}
				else
				{
					CPrintToChat(param1, "[TS] Vector out of world geometry. Spawning on current position instead");
				}
				VecAngles[0] = 0.0;
				VecAngles[2] = 0.0;
				DispatchKeyValueVector(prop, "angles", VecAngles);
				TeleportEntity(prop, VecOrigin, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(prop);

				g_bSpawned[prop] = true;

				LockGlow(param1, prop);
				g_iLastObject[param1] = EntIndexToEntRef(prop);
				g_iLockObject[param1] = EntIndexToEntRef(prop);

				LogSpawn("%N spawned a physics object with model <%s>", param1, model);
			}
			else if(g_eSpawnCategory[param1] == SpawnCategory_Physics_Body)
			{
				float VecOrigin[3];
				float VecAngles[3];
				int prop = CreateEntityByName("prop_physics_override");
				DispatchKeyValue(prop, "model", model);
				DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
				GetClientAbsOrigin(param1, VecOrigin);
				GetClientEyeAngles(param1, VecAngles);
				VecAngles[0] = 0.0;
				VecAngles[2] = 0.0;
				DispatchKeyValueVector(prop, "angles", VecAngles);
				TeleportEntity(prop, VecOrigin, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(prop);

				g_bSpawned[prop] = true;

				LockGlow(param1, prop);
				g_iLastObject[param1] = EntIndexToEntRef(prop);
				g_iLockObject[param1] = EntIndexToEntRef(prop);

				LogSpawn("%N spawned a physics object with model <%s>", param1, model);
			}
			else if(g_eSpawnCategory[param1] == SpawnCategory_NoSolid_Crosshair)
			{
				float VecOrigin[3];
				float VecAngles[3];
				int prop = CreateEntityByName("prop_dynamic_override");
				DispatchKeyValue(prop, "model", model);
				DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
				GetClientEyePosition(param1, VecOrigin);
				GetClientEyeAngles(param1, VecAngles);
				
				TR_TraceRayFilter(VecOrigin, VecAngles, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitSelf, param1);
				if(TR_DidHit(null))
				{
					TR_GetEndPosition(VecOrigin);
				}
				else
				{
					CPrintToChat(param1, "[TS] Vector out of world geometry. Spawning on current position instead");
				}
				VecAngles[0] = 0.0;
				VecAngles[2] = 0.0;
				DispatchKeyValueVector(prop, "angles", VecAngles);
				TeleportEntity(prop, VecOrigin, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(prop);

				SetEntProp(prop, Prop_Send, "m_nSolidType", 1);
				g_bSpawned[prop] = true;
				g_bUnsolid[prop] = true;

				LockGlow(param1, prop);
				g_iLastObject[param1] = EntIndexToEntRef(prop);
				g_iLockObject[param1] = EntIndexToEntRef(prop);

				LogSpawn("%N spawned a dynamic object with model <%s>", param1, model);
			}
			else if(g_eSpawnCategory[param1] == SpawnCategory_NoSolid_Body)
			{
				float VecOrigin[3];
				float VecAngles[3];
				int prop = CreateEntityByName("prop_dynamic_override");
				DispatchKeyValue(prop, "model", model);
				DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
				GetClientAbsOrigin(param1, VecOrigin);
				GetClientEyeAngles(param1, VecAngles);
				VecAngles[0] = 0.0;
				VecAngles[2] = 0.0;
				DispatchKeyValueVector(prop, "angles", VecAngles);
				TeleportEntity(prop, VecOrigin, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(prop);

				SetEntProp(prop, Prop_Send, "m_nSolidType", 1);
				g_bSpawned[prop] = true;
				g_bUnsolid[prop] = true;

				LockGlow(param1, prop);
				g_iLastObject[param1] = EntIndexToEntRef(prop);
				g_iLockObject[param1] = EntIndexToEntRef(prop);

				LogSpawn("%N spawned a dynamic object with model <%s>", param1, model);
			}
			else if(g_eSpawnCategory[param1] == SpawnCategory_Solid_Crosshair)
			{
				float VecOrigin[3];
				float VecAngles[3];
				int prop = CreateEntityByName("prop_dynamic_override");
				DispatchKeyValue(prop, "model", model);
				DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
				GetClientEyePosition(param1, VecOrigin);
				GetClientEyeAngles(param1, VecAngles);
				
				TR_TraceRayFilter(VecOrigin, VecAngles, MASK_SHOT, RayType_Infinite, _TraceFilter);
				if(TR_DidHit(null))
				{
					TR_GetEndPosition(VecOrigin);
				}
				else
				{
					CPrintToChat(param1, "[TS] Vector out of world geometry. Spawning on current position instead");
				}
				VecAngles[0] = 0.0;
				VecAngles[2] = 0.0;

				DispatchKeyValueVector(prop, "angles", VecAngles);
				TeleportEntity(prop, VecOrigin, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(prop);

				SetEntProp(prop, Prop_Send, "m_nSolidType", 6);
				g_bSpawned[prop] = true;

				LockGlow(param1, prop);
				g_iLastObject[param1] = EntIndexToEntRef(prop);
				g_iLockObject[param1] = EntIndexToEntRef(prop);

				LogSpawn("%N spawned a static object with model <%s>", param1, model);
			}
			else if(g_eSpawnCategory[param1] == SpawnCategory_Solid_Body)
			{
				float VecOrigin[3];
				float VecAngles[3];
				int prop = CreateEntityByName("prop_dynamic_override");
				DispatchKeyValue(prop, "model", model);
				DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
				
				GetClientAbsOrigin(param1, VecOrigin);
				GetClientEyeAngles(param1, VecAngles);
				VecAngles[0] = 0.0;
				VecAngles[2] = 0.0;
				DispatchKeyValueVector(prop, "angles", VecAngles);
				TeleportEntity(prop, VecOrigin, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(prop);

				SetEntProp(prop, Prop_Send, "m_nSolidType", 6);
				g_bSpawned[prop] = true;

				LockGlow(param1, prop);
				g_iLastObject[param1] = EntIndexToEntRef(prop);
				g_iLockObject[param1] = EntIndexToEntRef(prop);

				LogSpawn("%N spawned a static object with model <%s>", param1, model);
			}

			DisplayNextObjectMenu(param1, g_iCategoryLevel[param1], g_iCategoryPos[param1]);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				GoBackObjectMenu(param1);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

int MenuHandler_MainCategory(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			g_iCategoryLevel[param1] = 1;

			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));

			int iCategoryPos = g_iCategoryLevel[param1];
			FormatEx(g_sObjectCategory[param1][iCategoryPos], sizeof g_sObjectCategory[][], "%s", menucmd);
			DisplayNextObjectMenu(param1, iCategoryPos);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack && g_TopMenuHandle != null)
			{
				g_TopMenuHandle.Display(param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

int MenuHandler_ItemCursor(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			g_eSpawnCategory[param1] = SpawnCategory_Item_Crosshair;
			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));
			if(strcmp(menucmd, "Weapons")== 0)
			{
				DisplayWeaponsMenu(param1, WeaponItemCategory_GunsMain);
			}
			else if(strcmp(menucmd, "Melees")== 0)
			{
				DisplayMeleesMenu(param1);
			}
			else if(strcmp(menucmd, "Items")== 0)
			{
				DisplayItemsMenu(param1);
			}
			else if(strcmp(menucmd, "Others")== 0)
			{
				DisplayOthersMenu(param1);
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack && g_TopMenuHandle != null)
			{
				g_TopMenuHandle.Display(param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;

}

int MenuHandler_ItemPosition(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			g_eSpawnCategory[param1] = SpawnCategory_Item_Body;
			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));
			if(strcmp(menucmd, "Weapons")== 0)
			{
				DisplayWeaponsMenu(param1, WeaponItemCategory_GunsMain);
			}
			else if(strcmp(menucmd, "Melees")== 0)
			{
				DisplayMeleesMenu(param1);
			}
			else if(strcmp(menucmd, "Items")== 0)
			{
				DisplayItemsMenu(param1);
			}
			else if(strcmp(menucmd, "Others")== 0)
			{
				DisplayOthersMenu(param1);
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack && g_TopMenuHandle != null)
			{
				g_TopMenuHandle.Display(param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;

}

int MenuHandler_EditProp(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));
			if(strcmp(menucmd, "rotate")== 0)
			{
				DisplayRotateMenu(param1);
			}
			else if(strcmp(menucmd, "move")== 0)
			{
				DisplayMoveMenu(param1);
			}
			else if(strcmp(menucmd, "lock")== 0)
			{
				CmdLock(param1, 0);

				BuildEditPropMenu(param1);
			}
			else if(strcmp(menucmd, "clone")== 0)
			{
				CmdClone(param1, 0);

				BuildEditPropMenu(param1);
			}
			else if(strcmp(menucmd, "info")== 0)
			{
				CmdDebugProp(param1, 0);

				BuildEditPropMenu(param1);
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack && g_TopMenuHandle != null)
			{
				g_TopMenuHandle.Display(param1, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

void DisplayNextObjectMenu(int client, int iFinalCategoryPos, int menu_pos = 0)
{
	g_hData.Rewind();

	char sMainCategoryName[PLATFORM_MAX_PATH];
	int iLoopCategoryPos = 1;
	while(iLoopCategoryPos <= iFinalCategoryPos)
	{
		if (g_hData.JumpToKey(g_sObjectCategory[client][iLoopCategoryPos]))
		{
			if(iLoopCategoryPos == 1)
			{
				g_hData.GetString("menu_category", sMainCategoryName, sizeof sMainCategoryName, g_sObjectCategory[client][1]);
			}
		}
		else
		{
			PrintToChat(client, "[Object Spawner] Error! %s not found in file", g_sObjectCategory[client][iLoopCategoryPos]);
			return;
		}

		if(iLoopCategoryPos >= iFinalCategoryPos) break;
		iLoopCategoryPos++;
	}

	int menu_type = g_hData.GetNum("menu_type");

	Menu menu = null;

	if(menu_type == 0)
	{
		menu = new Menu(MenuHandler_CategoryList);
		menu.SetTitle("%T (%s)", "Object Spawner", client, sMainCategoryName);
		if (g_hData.GotoFirstSubKey(true))
		{
			do
			{
				char Selection[PLATFORM_MAX_PATH];
				char Categor_Name[PLATFORM_MAX_PATH];

				g_hData.GetSectionName(Selection, sizeof(Selection));
				g_hData.GetString("menu_category", Categor_Name, sizeof Categor_Name, Selection);
				menu.AddItem(Selection, Categor_Name);

			} while (g_hData.GotoNextKey(true));
		}
		else
		{
			PrintToChat(client, "[Object Spawner] Error! No any categories in %s", g_sObjectCategory[client][iLoopCategoryPos]);
			delete menu;
			return;
		}
	}
	else
	{
		menu = new Menu(MenuHandler_ModelList);
		menu.SetTitle("%T (%s)", "Object Spawner", client, sMainCategoryName);

		g_hData.GotoFirstSubKey(false); //"menu_category"	"x"
		g_hData.GotoNextKey(false); //"menu_type"	"x"

		if (g_hData.GotoNextKey(false))
		{
			do
			{
				char Model[PLATFORM_MAX_PATH];
				char Name[PLATFORM_MAX_PATH];

				g_hData.GetSectionName(Model, sizeof(Model));
				g_hData.GetString(NULL_STRING, Name, sizeof Name, Model);
				menu.AddItem(Model, Name);

			} while (g_hData.GotoNextKey(false));
		}
		else
		{
			PrintToChat(client, "[Object Spawner] Error! No any models in %s", g_sObjectCategory[client][iLoopCategoryPos]);
			delete menu;
			return;
		}
	}

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.DisplayAt(client, menu_pos, MENU_TIME_FOREVER);	
}

void GoBackObjectMenu(int client)
{
	g_iCategoryLevel[client]--;
	if(g_iCategoryLevel[client] < 0)
	{
		if(g_TopMenuHandle != null)
		{
			g_TopMenuHandle.Display(client, TopMenuPosition_LastCategory);
		}
	}
	else if(g_iCategoryLevel[client] == 0)
	{
		BuildMenuMainCategories(client);
	}
	else
	{
		DisplayNextObjectMenu(client, g_iCategoryLevel[client]);
	}
}

void DisplayWeaponsMenu(int client, EWeaponItemCategory eWeaponItemCategory)
{
	g_eWeaponItemCategory[client] = eWeaponItemCategory;

	Menu menu = null;
	switch(eWeaponItemCategory)
	{
		case WeaponItemCategory_GunsMain:
		{
			menu = new Menu(MenuHandler_GunsMain);
			menu.SetTitle("%T", "Weapons", client);
			if( g_bLeft4Dead2 )
			{
				menu.AddItem("rifles", Translate(client, "%t", "rifles"));
				menu.AddItem("snipers", Translate(client, "%t", "snipers"));
				menu.AddItem("shotguns", Translate(client, "%t", "shotguns"));
				menu.AddItem("SMGs", Translate(client, "%t", "SMGs"));
				menu.AddItem("pistols", Translate(client, "%t", "pistols"));
				menu.AddItem("Grenade Launcher", Translate(client, "%t", "Grenade Launcher"));
			}
			else
			{
				menu.AddItem("Pistol", Translate(client, "%t", "Pistol"));
				menu.AddItem("Smg", Translate(client, "%t", "Smg"));
				menu.AddItem("Pumpshotgun", Translate(client, "%t", "Pumpshotgun"));
				menu.AddItem("Rifle", Translate(client, "%t", "Rifle"));
				menu.AddItem("Hunting Rifle", Translate(client, "%t", "Hunting Rifle"));
				menu.AddItem("Autoshotgun", Translate(client, "%t", "Autoshotgun"));
			}
		}
		case WeaponItemCategory_GunsRifle:
		{
			menu = new Menu(MenuHandler_Rifles);
			menu.SetTitle("%T", "rifles", client);
			menu.AddItem("Rifle", Translate(client, "%t", "Rifle"));
			menu.AddItem("AK47", Translate(client, "%t", "AK47"));
			menu.AddItem("Desert Rifle", Translate(client, "%t", "Desert Rifle"));
			menu.AddItem("SG552", Translate(client, "%t", "SG552"));
			menu.AddItem("M60 Machine Gun", Translate(client, "%t", "M60 Machine Gun"));
		}
		case WeaponItemCategory_GunsSniper:
		{
			menu = new Menu(MenuHandler_Snipers);
			menu.SetTitle("%T", "snipers", client);
			menu.AddItem("Hunting Rifle", Translate(client, "%t", "Hunting Rifle"));
			menu.AddItem("Military Sniper", Translate(client, "%t", "Military Sniper"));
			menu.AddItem("SCOUT", Translate(client, "%t", "SCOUT"));
			menu.AddItem("AWP", Translate(client, "%t", "AWP"));
		}
		case WeaponItemCategory_GunsShotguns:
		{
			menu = new Menu(MenuHandler_Shotguns);
			menu.SetTitle("%T", "shotguns", client);
			menu.AddItem("Pumpshotgun", Translate(client, "%t", "Pumpshotgun"));
			menu.AddItem("Chrome Shotgun", Translate(client, "%t", "Chrome Shotgun"));
			menu.AddItem("Spas Shotgun", Translate(client, "%t", "Spas Shotgun"));
			menu.AddItem("Autoshotgun", Translate(client, "%t", "Autoshotgun"));
		}
		case WeaponItemCategory_GunsSMG:
		{
			menu = new Menu(MenuHandler_SMGs);
			menu.SetTitle("%T", "SMGs", client);
			menu.AddItem("Smg", Translate(client, "%t", "Smg"));
			menu.AddItem("Silenced Smg", Translate(client, "%t", "Silenced Smg"));
			menu.AddItem("MP5", Translate(client, "%t", "MP5"));
		}
		case WeaponItemCategory_GunsPistol:
		{
			menu = new Menu(MenuHandler_Pistols);
			menu.SetTitle("%T", "pistols", client);
			menu.AddItem("Pistol", Translate(client, "%t", "Pistol"));
			menu.AddItem("Magnum", Translate(client, "%t", "Magnum"));
		}
	}

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.DisplayAt(client, 0, MENU_TIME_FOREVER);
}

void DisplayMeleesMenu(int client)
{
	g_eWeaponItemCategory[client] = WeaponItemCategory_Melees;
	Menu menu = new Menu(MenuHandler_DoAction);

	menu.AddItem("chainsaw", Translate(client, "%t", "chainsaw"));
	
	char melee[64];
	char sItem[4];
	int count = g_aMeleeScripts.Length;
	for (int i = 0; i < count; i++) 
	{
		FormatEx(sItem, sizeof sItem, "%d", i);
		g_aMeleeScripts.GetString(i, melee, sizeof melee);

		if(TranslationPhraseExists(melee))
		{
			menu.AddItem(sItem, Translate(client, "%t", melee));
		}
		else
		{
			menu.AddItem(sItem, melee);
		}
	}

	menu.SetTitle("%T", "Melees", client);
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.DisplayAt(client, g_iMeleesMenuPosition[client], MENU_TIME_FOREVER);
}

void DisplayItemsMenu(int client)
{
	g_eWeaponItemCategory[client] = WeaponItemCategory_Items;
	Menu menu = new Menu(MenuHandler_DoAction);
	menu.SetTitle("%T", "Items", client);

	char sItem[4];
	if(g_bLeft4Dead2)
	{
		for( int i = 20; i < MAX_WEAPONS_L4D2; i++ )
		{
			FormatEx(sItem, sizeof sItem, "%d", i);
			menu.AddItem(sItem, Translate(client, "%t", g_sWeaponNames_L4D2[i]));
		}
	}
	else
	{
		for( int i = 6; i < MAX_WEAPONS_L4D1; i++ )
		{
			FormatEx(sItem, sizeof sItem, "%d", i);
			menu.AddItem(sItem, Translate(client, "%t", g_sWeaponNames_L4D1[i]));
		}
	}

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.DisplayAt(client, g_iItemsMenuPosition[client], MENU_TIME_FOREVER);
}

void DisplayOthersMenu(int client)
{
	g_eWeaponItemCategory[client] = WeaponItemCategory_Others;
	Menu menu = new Menu(MenuHandler_DoAction);
	menu.SetTitle("%T", "Others", client);

	char sItem[4];
	if(g_bLeft4Dead2)
	{
		for( int i = 0; i < sizeof g_sOtherNames_L4D2; i++ )
		{
			FormatEx(sItem, sizeof sItem, "%d", i);
			menu.AddItem(sItem, Translate(client, "%t", g_sOtherNames_L4D2[i]));
		}
	}
	else
	{
		for( int i = 0; i < sizeof g_sOtherNames_L4D1; i++ )
		{
			FormatEx(sItem, sizeof sItem, "%d", i);
			menu.AddItem(sItem, Translate(client, "%t", g_sOtherNames_L4D1[i]));
		}
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.DisplayAt(client, g_iOthersMenuPosition[client], MENU_TIME_FOREVER);
}

void DisplayRotateMenu(int client)
{
	g_iMoveCategory[client] = 1;
	Menu menu = new Menu(MenuHandler_PropPosition);
	menu.SetTitle("%T", "Rotate", client);
	menu.AddItem("rotate0_1x", Translate(client, "%t", "Rotate 0.1 degree (X axys)"));
	menu.AddItem("rotate1x", Translate(client, "%t", "Rotate 1 degree (X axys)"));
	menu.AddItem("rotate-0_1x", Translate(client, "%t", "Back 0.1 degree (X axys)"));
	menu.AddItem("rotate-1x", Translate(client, "%t", "Back 1 degree (X axys)"));
	menu.AddItem("rotate10x", Translate(client, "%t", "Rotate 10 degree (X axys)"));
	menu.AddItem("rotate-10x", Translate(client, "%t", "Back 10 degree (X axys)"));
	menu.AddItem("rotate15x", Translate(client, "%t", "Rotate 15 degree (X axys)"));
	menu.AddItem("rotate-15x", Translate(client, "%t", "Back 15 degree (X axys)"));
	menu.AddItem("rotate45x", Translate(client, "%t", "Rotate 45 degree (X axys)"));
	menu.AddItem("rotate90x", Translate(client, "%t", "Rotate 90 degree (X axys)"));
	menu.AddItem("rotate180x", Translate(client, "%t", "Rotate 180 degree (X axys)"));
	menu.AddItem("rotate0_1y", Translate(client, "%t", "Rotate 0.1 degree (Y axys)"));
	menu.AddItem("rotate1y", Translate(client, "%t", "Rotate 1 degree (Y axys)"));
	menu.AddItem("rotate-0_1y", Translate(client, "%t", "Back 0.1 degree (Y axys)"));
	menu.AddItem("rotate-1y", Translate(client, "%t", "Back 1 degree (Y axys)"));
	menu.AddItem("rotate10y", Translate(client, "%t", "Rotate 10 degree (Y axys)"));
	menu.AddItem("rotate-10y", Translate(client, "%t", "Back 10 degree (Y axys)"));
	menu.AddItem("rotate15y", Translate(client, "%t", "Rotate 15 degree (Y axys)"));
	menu.AddItem("rotate-15y", Translate(client, "%t", "Back 15 degree (Y axys)"));
	menu.AddItem("rotate45y", Translate(client, "%t", "Rotate 45 degree (Y axys)"));
	menu.AddItem("rotate90y", Translate(client, "%t", "Rotate 90 degree (Y axys)"));
	menu.AddItem("rotate180y", Translate(client, "%t", "Rotate 180 degree (Y axys)"));
	menu.AddItem("rotate0_1z", Translate(client, "%t", "Rotate 0.1 degree (Z axys)"));
	menu.AddItem("rotate1z", Translate(client, "%t", "Rotate 1 degree (Z axys)"));
	menu.AddItem("rotate-0_1z", Translate(client, "%t", "Back 0.1 degree (Z axys)"));
	menu.AddItem("rotate-1z", Translate(client, "%t", "Back 1 degree (Z axys)"));
	menu.AddItem("rotate10z", Translate(client, "%t", "Rotate 10 degree (Z axys)"));
	menu.AddItem("rotate-10z", Translate(client, "%t", "Back 10 degree (Z axys)"));
	menu.AddItem("rotate15z", Translate(client, "%t", "Rotate 15 degree (Z axys)"));
	menu.AddItem("rotate-15z", Translate(client, "%t", "Back 15 degree (Z axys)"));
	menu.AddItem("rotate45z", Translate(client, "%t", "Rotate 45 degree (Z axys)"));
	menu.AddItem("rotate90z", Translate(client, "%t", "Rotate 90 degree (Z axys)"));
	menu.AddItem("rotate180z", Translate(client, "%t", "Rotate 180 degree (Z axys)"));
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.DisplayAt(client, g_iRotateMenuPosition[client], MENU_TIME_FOREVER);
}

void DisplayMoveMenu(int client)
{
	g_iMoveCategory[client] = 2;
	Menu menu = new Menu(MenuHandler_PropPosition);
	menu.SetTitle("%T", "Move", client);
	menu.AddItem("moveup0_1", Translate(client, "%t", "Move Up 0.1 Unit"));
	menu.AddItem("moveup1", Translate(client, "%t", "Move Up 1 Unit"));
	menu.AddItem("moveup10", Translate(client, "%t", "Move Up 10 Unit"));
	menu.AddItem("moveup30", Translate(client, "%t", "Move Up 30 Unit"));
	menu.AddItem("movedown0_1", Translate(client, "%t", "Move Down 0.1 Unit"));
	menu.AddItem("movedown1", Translate(client, "%t", "Move Down 1 Unit"));
	menu.AddItem("movedown10", Translate(client, "%t", "Move Down 10 Unit"));
	menu.AddItem("movedown30", Translate(client, "%t", "Move Down 30 Unit"));
	menu.AddItem("moveright0_1", Translate(client, "%t", "Move Right 0.1 Unit"));
	menu.AddItem("moveright1", Translate(client, "%t", "Move Right 1 Unit"));
	menu.AddItem("moveright10", Translate(client, "%t", "Move Right 10 Unit"));
	menu.AddItem("moveright30", Translate(client, "%t", "Move Right 30 Unit"));
	menu.AddItem("moveleft0_1", Translate(client, "%t", "Move Left 0.1 Unit"));
	menu.AddItem("moveleft1", Translate(client, "%t", "Move Left 1 Unit"));
	menu.AddItem("moveleft10", Translate(client, "%t", "Move Left 10 Unit"));
	menu.AddItem("moveleft30", Translate(client, "%t", "Move Left 30 Unit"));
	menu.AddItem("moveforward0_1", Translate(client, "%t", "Move Forward 0.1 Unit"));
	menu.AddItem("moveforward1", Translate(client, "%t", "Move Forward 1 Unit"));
	menu.AddItem("moveforward10", Translate(client, "%t", "Move Forward 10 Unit"));
	menu.AddItem("moveforward30", Translate(client, "%t", "Move Forward 30 Unit"));
	menu.AddItem("movebackward0_1", Translate(client, "%t", "Move Backward 0.1 Unit"));
	menu.AddItem("movebackward1", Translate(client, "%t", "Move Backward 1 Unit"));
	menu.AddItem("movebackward10", Translate(client, "%t", "Move Backward 10 Unit"));
	menu.AddItem("movebackward30", Translate(client, "%t", "Move Backward 30 Unit"));
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.DisplayAt(client, g_iMoveMenuPosition[client], MENU_TIME_FOREVER);
}

int MenuHandler_DoAction(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[256];
			GetMenuItem(menu, param2, item, sizeof(item));
			int id;

			if(g_eWeaponItemCategory[param1] == WeaponItemCategory_Items)
			{
				g_iItemsMenuPosition[param1] = menu.Selection;
				id = StringToInt(item);
				SpawnWeaponOrItem(param1, id);
				DisplayItemsMenu(param1);
			}
			else if(g_eWeaponItemCategory[param1] == WeaponItemCategory_Melees)
			{
				g_iMeleesMenuPosition[param1] = menu.Selection;
				if(strcmp(item, "chainsaw", false) == 0)
				{
					SpawnWeaponOrItem(param1, 19);
				}
				else
				{
					id = StringToInt(item);
					SpawnWeaponOrItem(param1, id);
				}
				
				DisplayMeleesMenu(param1);
			}
			else if(g_eWeaponItemCategory[param1] == WeaponItemCategory_Others)
			{
				g_iOthersMenuPosition[param1] = menu.Selection;
				id = StringToInt(item);
				SpawnWeaponOrItem(param1, id);
				DisplayOthersMenu(param1);
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				BuildMenuMainCategories(param1);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

void SpawnWeaponOrItem(int client, int weapon_melee_id)
{
	if(g_eSpawnCategory[client] == SpawnCategory_Item_Crosshair)
	{
		float vPos[3], vAng[3];

		if(g_eWeaponItemCategory[client] == WeaponItemCategory_GunsMain
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_GunsRifle
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_GunsSniper
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_GunsShotguns
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_GunsSMG
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_GunsPistol
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_Items
			|| weapon_melee_id == 19) //chainsaw
		{
			if( !SetTeleportEndPoint(client, vPos, vAng, 1) )
			{
				CPrintToChat(client, "[TS] Vector out of world geometry. Spawning on current position instead");
				GetClientEyePosition(client, vPos);
				GetClientEyeAngles(client, vAng);
			}

			if( g_bLeft4Dead2 && weapon_melee_id == 17 ) // M60
			{
				vAng[2] += 180.0;
			}
			else if( g_bLeft4Dead2 && weapon_melee_id == 19 ) // Chainsaw
			{
				vPos[2] += 3.0;
			}
			else if( weapon_melee_id == (g_bLeft4Dead2 ? 20 : 6) ) // Molotov
			{
				vAng[2] += 90.0;
				vPos[2] += 4.0;
			}
			else if( weapon_melee_id == (g_bLeft4Dead2 ? 21 : 7) ) // Pipe Bomb
			{
				vAng[2] += 90.0;
				vPos[2] += 4.0;
			}
			else if( g_bLeft4Dead2 && weapon_melee_id == 22 ) // VomitJar
			{
				vAng[2] += 90.0;
				vPos[2] += 4.0;
			}
			else if( weapon_melee_id == (g_bLeft4Dead2 ? 23 : 9) ) // Pain Pills
			{
				vAng[2] += 90.0;
			}
			else if( weapon_melee_id == (g_bLeft4Dead2 ? 25 : 8) ) // First aid
			{
				vAng[0] += 90.0;
				vPos[2] += 1.0;
			}
			else if( g_bLeft4Dead2 && weapon_melee_id == 24 ) // Adrenaline
			{
				vAng[1] -= 90.0;
				vAng[2] -= 90.0;
				vPos[2] += 1.0;
			}
			else if( g_bLeft4Dead2 && (weapon_melee_id == 26 || weapon_melee_id == 27 || weapon_melee_id == 28 )) // Defib + Upgrades
			{
				vAng[1] -= 90.0;
				vAng[2] += 90.0;
			}

			char classname[64];
			strcopy(classname, sizeof(classname), g_bLeft4Dead2 ? g_sWeaponSpawn_L4D2[weapon_melee_id] : g_sWeaponSpawn_L4D1[weapon_melee_id]);

			int entity_weapon = CreateEntityByName(classname);
			if( entity_weapon == -1 )
				ThrowError("Failed to create entity '%s'", classname);

			char sModel[64];
			strcopy(sModel, sizeof(sModel), g_bLeft4Dead2 ? g_sWeaponModels_L4D2[weapon_melee_id] : g_sWeaponModels_L4D1[weapon_melee_id]);
			DispatchKeyValue(entity_weapon, "solid", "6");
			DispatchKeyValue(entity_weapon, "model", sModel);
			DispatchKeyValue(entity_weapon, "rendermode", "3");
			DispatchKeyValue(entity_weapon, "disableshadows", "1");
			DispatchKeyValue(entity_weapon, "targetname", "l4d2_spawn_props_object");

			int count;
			char sCount[5];
			StringToLowerCase(sModel);
			if(g_bLeft4Dead2 && g_smModelCount.GetValue(sModel, count) && count > 0)
			{
				IntToString(count, sCount, sizeof(sCount));
				DispatchKeyValue(entity_weapon, "count", sCount);
			}
			else if(!g_bLeft4Dead2 && g_smModelCount.GetValue(sModel, count) && count > 0)
			{
				IntToString(count, sCount, sizeof(sCount));
				DispatchKeyValue(entity_weapon, "count", sCount);
			}

			DispatchKeyValueVector(entity_weapon, "angles", vAng);
			TeleportEntity(entity_weapon, vPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(entity_weapon);

			LockGlow(client, entity_weapon);
			g_iLastObject[client] = EntIndexToEntRef(entity_weapon);
			g_iLockObject[client] = EntIndexToEntRef(entity_weapon);
			g_bSpawned[entity_weapon] = true;

			LogSpawn("%N spawned a weapon object with model <%s>", client, g_bLeft4Dead2 ? g_sWeaponModels_L4D2[weapon_melee_id] : g_sWeaponModels_L4D1[weapon_melee_id]);
		}
		else if(g_eWeaponItemCategory[client] == WeaponItemCategory_Melees)
		{
			if( !SetTeleportEndPoint(client, vPos, vAng, 2) )
			{
				CPrintToChat(client, "[TS] Vector out of world geometry. Spawning on current position instead");
				GetClientEyePosition(client, vPos);
				GetClientEyeAngles(client, vAng);
			}

			int entity_weapon = CreateEntityByName("weapon_melee");
			if( entity_weapon == -1 )
				ThrowError("Failed to create entity 'weapon_melee'");

			char melee[64];
			g_aMeleeScripts.GetString(weapon_melee_id, melee, sizeof melee);

			DispatchKeyValue(entity_weapon, "solid", "6");
			DispatchKeyValue(entity_weapon, "melee_script_name", melee);
			DispatchKeyValue(entity_weapon, "targetname", "l4d2_spawn_props_object");

			//DispatchKeyValue(entity_weapon, "count", "1");

			DispatchKeyValueVector(entity_weapon, "angles", vAng);
			TeleportEntity(entity_weapon, vPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(entity_weapon);
			SetEntityMoveType(entity_weapon, MOVETYPE_NONE);

			LockGlow(client, entity_weapon);
			g_iLastObject[client] = EntIndexToEntRef(entity_weapon);
			g_iLockObject[client] = EntIndexToEntRef(entity_weapon);
			g_bSpawned[entity_weapon] = true;

			LogSpawn("%N spawned a melee object with script <%s>", client, melee);
		}
		else if(g_eWeaponItemCategory[client] == WeaponItemCategory_Others)
		{
			if( !SetTeleportEndPoint(client, vPos, vAng, 3) )
			{
				CPrintToChat(client, "[TS] Vector out of world geometry. Spawning on current position instead");
				GetClientEyePosition(client, vPos);
				GetClientEyeAngles(client, vAng);
			}

			char classname[64];
			strcopy(classname, sizeof(classname), g_bLeft4Dead2 ? g_sOthers_L4D2[weapon_melee_id] : g_sOthers_L4D1[weapon_melee_id]);

			int entity_weapon = CreateEntityByName(classname);
			if( entity_weapon == -1 )
				ThrowError("Failed to create entity '%s'", classname);

			char sModel[64];
			strcopy(sModel, sizeof(sModel), g_bLeft4Dead2 ? g_sOtherModels_L4D2[weapon_melee_id] : g_sOtherModels_L4D1[weapon_melee_id]);
			SetEntityModel(entity_weapon, sModel);

			int count;
			char sCount[5];
			StringToLowerCase(sModel);
			if(g_bLeft4Dead2 && g_smModelCount.GetValue(sModel, count) && count > 0)
			{
				IntToString(count, sCount, sizeof(sCount));
				DispatchKeyValue(entity_weapon, "count", sCount);
			}
			else if(!g_bLeft4Dead2 && g_smModelCount.GetValue(sModel, count) && count > 0)
			{
				IntToString(count, sCount, sizeof(sCount));
				DispatchKeyValue(entity_weapon, "count", sCount);
			}

			DispatchKeyValueVector(entity_weapon, "angles", vAng);
			DispatchKeyValue(entity_weapon, "targetname", "l4d2_spawn_props_object");
			TeleportEntity(entity_weapon, vPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(entity_weapon);

			LockGlow(client, entity_weapon);
			g_iLastObject[client] = EntIndexToEntRef(entity_weapon);
			g_iLockObject[client] = EntIndexToEntRef(entity_weapon);
			g_bSpawned[entity_weapon] = true;

			LogSpawn("%N spawned an item object with model <%s>", client, g_bLeft4Dead2 ? g_sOtherModels_L4D2[weapon_melee_id] : g_sOtherModels_L4D1[weapon_melee_id]);
		}
	}
	else if(g_eSpawnCategory[client] == SpawnCategory_Item_Body)
	{
		if(g_eWeaponItemCategory[client] == WeaponItemCategory_GunsMain
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_GunsRifle
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_GunsSniper
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_GunsShotguns
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_GunsSMG
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_GunsPistol
			|| g_eWeaponItemCategory[client] == WeaponItemCategory_Items
			|| weapon_melee_id == 19) //chainsaw
		{
			char classname[64];
			strcopy(classname, sizeof(classname), g_bLeft4Dead2 ? g_sWeaponSpawn_L4D2[weapon_melee_id] : g_sWeaponSpawn_L4D1[weapon_melee_id]);

			int entity_weapon = CreateEntityByName(classname);
			if( entity_weapon == -1 )
				ThrowError("Failed to create entity '%s'", classname);

			char sModel[64];
			strcopy(sModel, sizeof(sModel), g_bLeft4Dead2 ? g_sWeaponModels_L4D2[weapon_melee_id] : g_sWeaponModels_L4D1[weapon_melee_id]);
			DispatchKeyValue(entity_weapon, "solid", "6");
			DispatchKeyValue(entity_weapon, "model", sModel);
			DispatchKeyValue(entity_weapon, "rendermode", "3");
			DispatchKeyValue(entity_weapon, "disableshadows", "1");
			DispatchKeyValue(entity_weapon, "targetname", "l4d2_spawn_props_object");

			int count;
			char sCount[5];
			StringToLowerCase(sModel);
			if(g_bLeft4Dead2 && g_smModelCount.GetValue(sModel, count) && count > 0)
			{
				IntToString(count, sCount, sizeof(sCount));
				DispatchKeyValue(entity_weapon, "count", sCount);
			}
			else if(!g_bLeft4Dead2 && g_smModelCount.GetValue(sModel, count) && count > 0)
			{
				IntToString(count, sCount, sizeof(sCount));
				DispatchKeyValue(entity_weapon, "count", sCount);
			}

			float VecOrigin[3];
			float VecAngles[3];
			GetClientEyePosition(client, VecOrigin);
			GetClientEyeAngles(client, VecAngles);
			VecAngles[0] = 0.0;
			VecAngles[2] = 0.0;
			DispatchKeyValueVector(entity_weapon, "angles", VecAngles);
			TeleportEntity(entity_weapon, VecOrigin, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(entity_weapon);

			LockGlow(client, entity_weapon);
			g_iLastObject[client] = EntIndexToEntRef(entity_weapon);
			g_iLockObject[client] = EntIndexToEntRef(entity_weapon);
			g_bSpawned[entity_weapon] = true;

			LogSpawn("%N spawned a weapon object with model <%s>", client, g_bLeft4Dead2 ? g_sWeaponModels_L4D2[weapon_melee_id] : g_sWeaponModels_L4D1[weapon_melee_id]);
		}
		else if(g_eWeaponItemCategory[client] == WeaponItemCategory_Melees)
		{
			int entity_weapon = CreateEntityByName("weapon_melee");
			if( entity_weapon == -1 )
				ThrowError("Failed to create entity 'weapon_melee'");

			char melee[64];
			g_aMeleeScripts.GetString(weapon_melee_id, melee, sizeof melee);

			DispatchKeyValue(entity_weapon, "solid", "6");
			DispatchKeyValue(entity_weapon, "melee_script_name", melee);
			DispatchKeyValue(entity_weapon, "targetname", "l4d2_spawn_props_object");

			//DispatchKeyValue(entity_weapon, "count", "1");

			float VecOrigin[3];
			float VecAngles[3];
			GetClientEyePosition(client, VecOrigin);
			GetClientEyeAngles(client, VecAngles);
			VecAngles[0] = 0.0;
			VecAngles[2] = 0.0;
			DispatchKeyValueVector(entity_weapon, "angles", VecAngles);
			TeleportEntity(entity_weapon, VecOrigin, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(entity_weapon);
			SetEntityMoveType(entity_weapon, MOVETYPE_NONE);

			LockGlow(client, entity_weapon);
			g_iLastObject[client] = EntIndexToEntRef(entity_weapon);
			g_iLockObject[client] = EntIndexToEntRef(entity_weapon);
			g_bSpawned[entity_weapon] = true;

			LogSpawn("%N spawned a melee object with script <%s>", client, melee);
		}
		else if(g_eWeaponItemCategory[client] == WeaponItemCategory_Others)
		{
			char classname[64];
			strcopy(classname, sizeof(classname), g_bLeft4Dead2 ? g_sOthers_L4D2[weapon_melee_id] : g_sOthers_L4D1[weapon_melee_id]);

			int entity_weapon = CreateEntityByName(classname);
			if( entity_weapon == -1 )
				ThrowError("Failed to create entity '%s'", classname);

			char sModel[64];
			strcopy(sModel, sizeof(sModel), g_bLeft4Dead2 ? g_sOtherModels_L4D2[weapon_melee_id] : g_sOtherModels_L4D1[weapon_melee_id]);
			SetEntityModel(entity_weapon, sModel);

			int count;
			char sCount[5];
			StringToLowerCase(sModel);
			if(g_bLeft4Dead2 && g_smModelCount.GetValue(sModel, count) && count > 0)
			{
				IntToString(count, sCount, sizeof(sCount));
				DispatchKeyValue(entity_weapon, "count", sCount);
			}
			else if(!g_bLeft4Dead2 && g_smModelCount.GetValue(sModel, count) && count > 0)
			{
				IntToString(count, sCount, sizeof(sCount));
				DispatchKeyValue(entity_weapon, "count", sCount);
			}

			float VecOrigin[3];
			float VecAngles[3];
			GetClientEyePosition(client, VecOrigin);
			GetClientEyeAngles(client, VecAngles);
			VecAngles[0] = 0.0;
			VecAngles[2] = 0.0;
			
			DispatchKeyValueVector(entity_weapon, "angles", VecAngles);
			DispatchKeyValue(entity_weapon, "targetname", "l4d2_spawn_props_object");
			TeleportEntity(entity_weapon, VecOrigin, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(entity_weapon);

			LockGlow(client, entity_weapon);
			g_iLastObject[client] = EntIndexToEntRef(entity_weapon);
			g_iLockObject[client] = EntIndexToEntRef(entity_weapon);
			g_bSpawned[entity_weapon] = true;

			LogSpawn("%N spawned an item object with model <%s>", client, g_bLeft4Dead2 ? g_sOtherModels_L4D2[weapon_melee_id] : g_sOtherModels_L4D1[weapon_melee_id]);
		}
	}
}

int MenuHandler_PropPosition(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));
			switch(g_iMoveCategory[param1])
			{
				case 1:
				{
					int Object = EntRefToEntIndex(g_iLockObject[param1]);
					if(Object == INVALID_ENT_REFERENCE)
					{
						CPrintToChat(param1, "[TS] %T","You haven't locked anything yet", param1);
						g_iRotateMenuPosition[param1] = menu.Selection;
						DisplayRotateMenu(param1);
						return 0;
					}

					float vecAngles[3];
					GetEntPropVector(Object, Prop_Send, "m_angRotation", vecAngles);
					
					if(strcmp(menucmd, "rotate0_1x")== 0)
					{
						vecAngles[0] += 0.1;
					}
					else if(strcmp(menucmd, "rotate1x")== 0)
					{
						vecAngles[0] += 1;
					}
					else if(strcmp(menucmd, "rotate-1x")== 0)
					{
						vecAngles[0] -= 1;
					}
					else if(strcmp(menucmd, "rotate-0_1x")== 0)
					{
						vecAngles[0] -= 0.1;
					}
					else if(strcmp(menucmd, "rotate10x")== 0)
					{
						vecAngles[0] += 10;
					}
					else if(strcmp(menucmd, "rotate-10x")== 0)
					{
						vecAngles[0] -= 10;
					}
					else if(strcmp(menucmd, "rotate15x")== 0)
					{
						vecAngles[0] += 15;
					}
					else if(strcmp(menucmd, "rotate-15x")== 0)
					{
						vecAngles[0] -= 15;
					}
					else if(strcmp(menucmd, "rotate45x")== 0)
					{
						vecAngles[0] += 45;
					}
					else if(strcmp(menucmd, "rotate90x")== 0)
					{
						vecAngles[0] += 90;
					}
					else if(strcmp(menucmd, "rotate180x")== 0)
					{
						vecAngles[0] += 180;
					}
					else if(strcmp(menucmd, "rotate0_1y")== 0)
					{
						vecAngles[1] += 0.1;
					}
					else if(strcmp(menucmd, "rotate1y")== 0)
					{
						vecAngles[1] += 1;
					}
					else if(strcmp(menucmd, "rotate-0_1y")== 0)
					{
						vecAngles[1] -= 0.1;
					}
					else if(strcmp(menucmd, "rotate-1y")== 0)
					{
						vecAngles[1] -= 1;
					}
					else if(strcmp(menucmd, "rotate10y")== 0)
					{
						vecAngles[1] += 10;
					}
					else if(strcmp(menucmd, "rotate-10y")== 0)
					{
						vecAngles[1] -= 10;
					}
					else if(strcmp(menucmd, "rotate15y")== 0)
					{
						vecAngles[1] += 15;
					}
					else if(strcmp(menucmd, "rotate-15y")== 0)
					{
						vecAngles[1] -= 15;
					}
					else if(strcmp(menucmd, "rotate45y")== 0)
					{
						vecAngles[1] += 45;
					}
					else if(strcmp(menucmd, "rotate90y")== 0)
					{
						vecAngles[1] += 90;
					}
					else if(strcmp(menucmd, "rotate180y")== 0)
					{
						vecAngles[1] += 180;
					}
					else if(strcmp(menucmd, "rotate0_1z")== 0)
					{
						vecAngles[2] += 0.1;
					}
					else if(strcmp(menucmd, "rotate1z")== 0)
					{
						vecAngles[2] += 1;
					}
					else if(strcmp(menucmd, "rotate-0_1z")== 0)
					{
						vecAngles[2] -= 0.1;
					}
					else if(strcmp(menucmd, "rotate-1z")== 0)
					{
						vecAngles[2] -= 1;
					}
					else if(strcmp(menucmd, "rotate10z")== 0)
					{
						vecAngles[2] += 10;
					}
					else if(strcmp(menucmd, "rotate-10z")== 0)
					{
						vecAngles[2] -= 10;
					}
					else if(strcmp(menucmd, "rotate15z")== 0)
					{
						vecAngles[2] += 15;
					}
					else if(strcmp(menucmd, "rotate-15z")== 0)
					{
						vecAngles[2] -= 15;
					}
					else if(strcmp(menucmd, "rotate45z")== 0)
					{
						vecAngles[2] += 45;
					}
					else if(strcmp(menucmd, "rotate90z")== 0)
					{
						vecAngles[2] += 90;
					}
					else if(strcmp(menucmd, "rotate180z")== 0)
					{
						vecAngles[2] += 180;
					}
					
					TeleportEntity(Object, NULL_VECTOR, vecAngles, NULL_VECTOR);
					
					g_iRotateMenuPosition[param1] = menu.Selection;
					DisplayRotateMenu(param1);
				}
				case 2:
				{
					int Object = EntRefToEntIndex(g_iLockObject[param1]);
					if(Object == INVALID_ENT_REFERENCE)
					{
						CPrintToChat(param1, "[TS] %T","You haven't locked anything yet", param1);
						g_iMoveMenuPosition[param1] = menu.Selection; 
						DisplayMoveMenu(param1);
						return 0;
					}
					
					float vecOrigin[3];
					GetEntPropVector(Object, Prop_Data, "m_vecOrigin", vecOrigin);
					
					if(strcmp(menucmd, "moveup0_1")== 0)
					{
						vecOrigin[2]+= 0.1;
					}
					else if(strcmp(menucmd, "moveup1")== 0)
					{
						vecOrigin[2]+= 1;
					}
					else if(strcmp(menucmd, "moveup10")== 0)
					{
						vecOrigin[2]+= 10;
					}
					else if(strcmp(menucmd, "moveup30")== 0)
					{
						vecOrigin[2]+= 30;
					}
					else if(strcmp(menucmd, "movedown0_1")== 0)
					{
						vecOrigin[2]-= 0.1;
					}
					else if(strcmp(menucmd, "movedown1")== 0)
					{
						vecOrigin[2]-= 1;
					}
					else if(strcmp(menucmd, "movedown10")== 0)
					{
						vecOrigin[2]-= 10;
					}
					else if(strcmp(menucmd, "movedown30")== 0)
					{
						vecOrigin[2]-= 30;
					}
					else if(strcmp(menucmd, "moveright0_1")== 0)
					{
						vecOrigin[1]+= 0.1;
					}
					else if(strcmp(menucmd, "moveright1")== 0)
					{
						vecOrigin[1]+= 1;
					}
					else if(strcmp(menucmd, "moveright10")== 0)
					{
						vecOrigin[1]+= 10;
					}
					else if(strcmp(menucmd, "moveright30")== 0)
					{
						vecOrigin[1]+= 30;
					}
					else if(strcmp(menucmd, "moveleft0_1")== 0)
					{
						vecOrigin[1]-= 0.1;
					}
					else if(strcmp(menucmd, "moveleft1")== 0)
					{
						vecOrigin[1]-= 1;
					}
					else if(strcmp(menucmd, "moveleft10")== 0)
					{
						vecOrigin[1]-= 10;
					}
					else if(strcmp(menucmd, "moveleft30")== 0)
					{
						vecOrigin[1]-= 30;
					}
					else if(strcmp(menucmd, "moveforward0_1")== 0)
					{
						vecOrigin[0]+= 0.1;
					}
					else if(strcmp(menucmd, "moveforward1")== 0)
					{
						vecOrigin[0]+= 1;
					}
					else if(strcmp(menucmd, "moveforward10")== 0)
					{
						vecOrigin[0]+= 10;
					}
					else if(strcmp(menucmd, "moveforward30")== 0)
					{
						vecOrigin[0]+= 30;
					}
					else if(strcmp(menucmd, "movebackward0_1")== 0)
					{
						vecOrigin[0]-= 0.1;
					}
					else if(strcmp(menucmd, "movebackward1")== 0)
					{
						vecOrigin[0]-= 1;
					}
					else if(strcmp(menucmd, "movebackward10")== 0)
					{
						vecOrigin[0]-= 10;
					}
					else if(strcmp(menucmd, "movebackward30")== 0)
					{
						vecOrigin[0]-= 30;
					}
					TeleportEntity(Object, vecOrigin, NULL_VECTOR, NULL_VECTOR);
					
					g_iMoveMenuPosition[param1] = menu.Selection; 
					DisplayMoveMenu(param1);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				BuildEditPropMenu(param1);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

int MenuHandler_GunsMain(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[256];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			if( g_bLeft4Dead2 )
			{
				if(strcmp(item, "rifles", false) == 0)
				{
					DisplayWeaponsMenu(param1, WeaponItemCategory_GunsRifle);
				}
				else if(strcmp(item, "snipers", false) == 0)
				{
					DisplayWeaponsMenu(param1, WeaponItemCategory_GunsSniper);
				}
				else if(strcmp(item, "shotguns", false) == 0)
				{
					DisplayWeaponsMenu(param1, WeaponItemCategory_GunsShotguns);
				}
				else if(strcmp(item, "SMGs", false) == 0)
				{
					DisplayWeaponsMenu(param1, WeaponItemCategory_GunsSMG);
				}
				else if(strcmp(item, "pistols", false) == 0)
				{
					DisplayWeaponsMenu(param1, WeaponItemCategory_GunsPistol);
				}
				else if(strcmp(item, "Grenade Launcher", false) == 0)
				{
					SpawnWeaponOrItem(param1, 18);
					DisplayWeaponsMenu(param1, WeaponItemCategory_GunsMain);
				}
			}
			else
			{
				if(strcmp(item, "Pistol", false) == 0)
				{
					SpawnWeaponOrItem(param1, 5);
				}
				else if(strcmp(item, "Smg", false) == 0)
				{
					SpawnWeaponOrItem(param1, 3);
				}
				else if(strcmp(item, "Pumpshotgun", false) == 0)
				{
					SpawnWeaponOrItem(param1, 4);
				}
				else if(strcmp(item, "Rifle", false) == 0)
				{
					SpawnWeaponOrItem(param1, 0);
				}
				else if(strcmp(item, "Hunting Rifle", false) == 0)
				{
					SpawnWeaponOrItem(param1, 2);
				}
				else if(strcmp(item, "Autoshotgun", false) == 0)
				{
					SpawnWeaponOrItem(param1, 1);
				}
				DisplayWeaponsMenu(param1, WeaponItemCategory_GunsMain);
			}
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				BuildMenuMainCategories(param1);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

int MenuHandler_Rifles(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[256];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			if(strcmp(item, "Rifle", false) == 0)
			{
				SpawnWeaponOrItem(param1, 2);
			}
			else if(strcmp(item, "AK47", false) == 0)
			{
				SpawnWeaponOrItem(param1, 3);
			}
			else if(strcmp(item, "Desert Rifle", false) == 0)
			{
				SpawnWeaponOrItem(param1, 5);
			}
			else if(strcmp(item, "SG552", false) == 0)
			{
				SpawnWeaponOrItem(param1, 4);
			}
			else if(strcmp(item, "M60 Machine Gun", false) == 0)
			{
				SpawnWeaponOrItem(param1, 17);
			}
			DisplayWeaponsMenu(param1, WeaponItemCategory_GunsRifle);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				DisplayWeaponsMenu(param1, WeaponItemCategory_GunsMain);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

int MenuHandler_Snipers(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[256];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			if(strcmp(item, "Hunting Rifle", false) == 0)
			{
				SpawnWeaponOrItem(param1, 13);
			}
			else if(strcmp(item, "Military Sniper", false) == 0)
			{
				SpawnWeaponOrItem(param1, 15);
			}
			else if(strcmp(item, "SCOUT", false) == 0)
			{
				SpawnWeaponOrItem(param1, 16);
			}
			else if(strcmp(item, "AWP", false) == 0)
			{
				SpawnWeaponOrItem(param1, 14);
			}
			DisplayWeaponsMenu(param1, WeaponItemCategory_GunsSniper);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				DisplayWeaponsMenu(param1, WeaponItemCategory_GunsMain);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

int MenuHandler_Shotguns(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[256];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			if(strcmp(item, "Pumpshotgun", false) == 0)
			{
				SpawnWeaponOrItem(param1, 8);
			}
			else if(strcmp(item, "Chrome Shotgun", false) == 0)
			{
				SpawnWeaponOrItem(param1, 9);
			}
			else if(strcmp(item, "Spas Shotgun", false) == 0)
			{
				SpawnWeaponOrItem(param1, 7);
			}
			else if(strcmp(item, "Autoshotgun", false) == 0)
			{
				SpawnWeaponOrItem(param1, 6);
			}
			DisplayWeaponsMenu(param1, WeaponItemCategory_GunsShotguns);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				DisplayWeaponsMenu(param1, WeaponItemCategory_GunsMain);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

int MenuHandler_SMGs(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[256];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			if(strcmp(item, "Smg", false) == 0)
			{
				SpawnWeaponOrItem(param1, 10);
			}
			else if(strcmp(item, "Silenced Smg", false) == 0)
			{
				SpawnWeaponOrItem(param1, 11);
			}
			else if(strcmp(item, "MP5", false) == 0)
			{
				SpawnWeaponOrItem(param1, 12);
			}
			DisplayWeaponsMenu(param1, WeaponItemCategory_GunsSMG);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				DisplayWeaponsMenu(param1, WeaponItemCategory_GunsMain);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

int MenuHandler_Pistols(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char item[256];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			if(strcmp(item, "Pistol", false) == 0)
			{
				SpawnWeaponOrItem(param1, 0);
			}
			else if(strcmp(item, "Magnum", false) == 0)
			{
				SpawnWeaponOrItem(param1, 1);
			}
			DisplayWeaponsMenu(param1, WeaponItemCategory_GunsPistol);
		}
		case MenuAction_Cancel:
		{
			if(param2 == MenuCancel_ExitBack)
			{
				DisplayWeaponsMenu(param1, WeaponItemCategory_GunsMain);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	if(entity == data) // Check if the TraceRay hit the itself.
	{
		return false; // Don't let the entity be hit
	}
	return true; // It didn't hit itself
}

void DeleteLookingEntity(int client)
{
	int Object = FindObjectYouAreLooking(client, false); 
	if(Object <= MaxClients || !IsValidEntity(Object))
	{
		CPrintToChat(client, "[TS] %T","You are not looking at a valid object", client);
		return;
	}

	g_bSpawned[Object] = false;
	g_bUnsolid[Object] = false;

	static char m_ModelName[PLATFORM_MAX_PATH];
	GetEntPropString(Object, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
	CPrintToChat(client, "[TS] %T", "Object Model", client, Object, m_ModelName);

	static char name[256];
	GetEntPropString(Object, Prop_Data, "m_iName", name, sizeof(name));
	CPrintToChat(client, "[TS] %T", "Object Targetname", client, name);

	static float position[3];
	GetEntPropVector(Object, Prop_Send, "m_vecOrigin", position);
	CPrintToChat(client, "[TS] %T", "Object Position", client, position[0], position[1], position[2]);

	static float angle[3];
	GetEntPropVector(Object, Prop_Data, "m_angRotation", angle);
	CPrintToChat(client, "[TS] %T", "Object Angle", client, angle[0], angle[1], angle[2]);

	AcceptEntityInput(Object, "KillHierarchy");
	CPrintToChat(client, "[TS] %T", "Successfully removed an object", client, Object);
	if(Object == EntRefToEntIndex(g_iLastObject[client]))
	{
		g_iLastObject[client] = INVALID_ENT_REFERENCE;
	}
	
	if(Object == EntRefToEntIndex(g_iLockObject[client]))
	{
		g_iLockObject[client] = INVALID_ENT_REFERENCE;
	}
}

void DeleteAllProps(bool bRemoveObjects = true)
{
	CheatCommand(_, "ent_fire", "l4d2_spawn_props_prop KillHierarchy");
	int lastlockobject;
	for(int i=1; i<=MaxClients; i++)
	{
		lastlockobject = EntRefToEntIndex(g_iLockObject[i]);
		if(lastlockobject != INVALID_ENT_REFERENCE)
		{
			if(g_bLeft4Dead2)
			{
				L4D2_RemoveEntityGlow(lastlockobject);
			}
			SetEntityRenderMode(lastlockobject, RENDER_NORMAL);
		}

		g_iLockObject[i] = INVALID_ENT_REFERENCE;
		g_iLastObject[i] = INVALID_ENT_REFERENCE;
	}

	for(int i=MaxClients; i < MAX_ENTITY; i++)
	{
		if(g_bSpawned[i])
		{
			g_bSpawned[i] = false;
			g_bUnsolid[i] = false;
			if(bRemoveObjects && IsValidEntity(i))
			{
				AcceptEntityInput(i, "Kill");
			}
		}
	}
}

void CheatCommand(int client = 0, char[] command, char[] arguments="")
{
	if (!client || !IsClientInGame(client))
	{
		for (int target = 1; target <= MaxClients; target++)
		{
			if (IsClientInGame(target))
			{
				client = target;
				break;
			}
		}
		
		if (!client || !IsClientInGame(client)) return;
	}
	
	int userflags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userflags);
}

void DeleteLastProp(int client)
{
	if(g_iLastObject[client] == INVALID_ENT_REFERENCE)
	{
		CPrintToChat(client, "[TS] %T", "You haven't spawned anything yet", client);
		return;
	}

	int Object = EntRefToEntIndex(g_iLastObject[client]);
	if(Object != INVALID_ENT_REFERENCE)
	{
		static char class[256];
		GetEntityClassname(Object, class, sizeof(class));
		if(strncmp(class, "prop_physics", 12, false) == 0
		|| strncmp(class, "prop_dynamic", 12, false) == 0
		|| strncmp(class, "weapon_", 7, false) == 0
		|| strcmp(class, "upgrade_laser_sight", false) == 0)
		{
			AcceptEntityInput(g_iLastObject[client], "KillHierarchy");
			CPrintToChat(client, "[TS] %T","Succesfully deleted the last spawned object",client);
			g_iLastObject[client] = INVALID_ENT_REFERENCE;
			g_bSpawned[Object] = false;
			g_bUnsolid[Object] = false;

			if(Object == EntRefToEntIndex(g_iLockObject[client]))
			{
				g_iLockObject[client] = INVALID_ENT_REFERENCE;
			}
			return;
		}
		else
		{
			CPrintToChat(client, "[TS] %T", "The last spawned object index is not an object anymore!", client, Object);
			g_iLastObject[client] = INVALID_ENT_REFERENCE;
			g_bSpawned[Object] = false;
			g_bUnsolid[Object] = false;
		}
	}
	else
	{
		CPrintToChat(client, "[TS] %T","The last object is not valid anymore",client);
	}
}

void LogSpawn(const char[] format, any ...)
{
	if(!g_bCvarLog)
	{
		return;
	}
	char buffer[512];
	VFormat(buffer, sizeof(buffer), format, 2);
	File file;
	char FileName[256];
	char sTime[256];
	FormatTime(sTime, sizeof(sTime), "%Y%m%d");
	BuildPath(Path_SM, FileName, sizeof(FileName), "logs/objects_%s.log", sTime);
	file = OpenFile(FileName, "a+");
	FormatTime(sTime, sizeof(sTime), "%b %d |%H:%M:%S| %Y");
	file.WriteLine("%s: %s", sTime, buffer);
	FlushFile(file);
	CloseHandle(file);
}

Action CmdSaveMap(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	SaveMapStripper(client);
	DeleteAllProps(false);
	return Plugin_Handled;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	SaveMapStripper(0);
}

Action ServerCmd_changelevel(int client2, const char[] command, int argc)
{
	SaveMapStripper(0);

	return Plugin_Continue;
}

void SaveMapStripper(int client)
{
	if(client > 0) LogSpawn("%N saved the objects for this map on a 'Stripper' file format", client);

	char FileName[256];
	char map[256];
	char classname[256];
	File file;
	GetCurrentMap(map, sizeof(map));
	BuildPath(Path_SM, FileName, sizeof(FileName), "../../%s/maps/%s.cfg", g_sCvar_stripper_cfg_path, map);
	
	float vecOrigin[3];
	float vecAngles[3];
	char sModel[256];
	char sTime[256];
	int count;
	char melee_name[32];
	FormatTime(sTime, sizeof(sTime), "%Y-%m-%d_%H-%M");

	bool bHasObjectNotSavedYet = false;
	if(client > 0)
	{
		if(FileExists(FileName)) PrintHintText(client, "%T", "The file already exists.", client);

		file = OpenFile(FileName, "a+");
		if(file == null)
		{
			if(client > 0)
			{
				CPrintToChat(client, "{green}[TS] Failed to create or overwrite the map file");
				PrintHintText(client, "[TS] Failed to create or overwrite the map file");
				PrintToConsole(client, "[TS] Failed to create or overwrite the map file");
				PrintCenterText(client, "[TS] Failed to create or overwrite the map file");
			}
			return;
		}

		CPrintToChat(client, "{green}[TS] %T", "Saving the content. Please Wait", client);

		file.WriteLine(";----------FILE MODIFICATION [%s] ---------------||", sTime);
		file.WriteLine(";----------BY: %N----------------------||", client);
		file.WriteLine("");
		file.WriteLine("add:");

		bHasObjectNotSavedYet = true;
	}

	for(int entity=MaxClients; entity < MAX_ENTITY; entity++)
	{
		if(g_bSpawned[entity] && IsValidEntity(entity))
		{
			if(client == 0 && !bHasObjectNotSavedYet)
			{
				LogSpawn("!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				CPrintToChatAll("{red}!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				CPrintToChatAll("{red}!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				CPrintToChatAll("{red}!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				PrintToServer("!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				PrintToServer("!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				PrintToServer("!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");

				file = OpenFile(FileName, "a+");
				if(file == null)
				{
					if(client > 0)
					{
						CPrintToChat(client, "{green}[TS] Failed to create or overwrite the map file");
						PrintHintText(client, "[TS] Failed to create or overwrite the map file");
						PrintToConsole(client, "[TS] Failed to create or overwrite the map file");
						PrintCenterText(client, "[TS] Failed to create or overwrite the map file");
					}
					return;
				}

				file.WriteLine(";----------FILE MODIFICATION [%s] ---------------||", sTime);
				file.WriteLine(";----------BY: Server Console Auto Save----------------------||");
				file.WriteLine("");
				file.WriteLine("add:");

				bHasObjectNotSavedYet = true;
			}

			GetEntityClassname(entity, classname, sizeof(classname));
			if(strncmp(classname, "prop_dynamic", 12, false) == 0 || strncmp(classname, "prop_physics", 12, false) == 0)
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecOrigin);
				GetEntPropVector(entity, Prop_Send, "m_angRotation", vecAngles);
				GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

				file.WriteLine("{");
				file.WriteLine("	\"targetname\" \"l4d2_spawn_props_object_%s\"", sTime);
				if(strncmp(classname, "prop_dynamic_", 12, false) == 0)
				{
					if(g_bUnsolid[entity])
					{
						file.WriteLine("	\"solid\" \"1\"");
					}
					else
					{
						file.WriteLine("	\"solid\" \"6\"");
					}
				}
				file.WriteLine("	\"origin\" \"%.2f %.2f %.2f\"", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
				file.WriteLine("	\"angles\" \"%.2f %.2f %.2f\"", vecAngles[0], vecAngles[1], vecAngles[2]);
				file.WriteLine("	\"model\"	 \"%s\"", sModel);
				if(strncmp(classname, "prop_dynamic", 12, false) == 0) file.WriteLine("	\"classname\"	\"prop_dynamic_override\"");
				else file.WriteLine("	\"classname\"	\"prop_physics_override\"");
				file.WriteLine("}");
				file.WriteLine("");
			}
			else if(strcmp(classname, "weapon_melee", false) == 0)
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecOrigin);
				GetEntPropVector(entity, Prop_Send, "m_angRotation", vecAngles);
				//GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

				file.WriteLine("{");
				file.WriteLine("	\"targetname\" \"l4d2_spawn_props_object_%s\"", sTime);
				file.WriteLine("	\"solid\" \"6\"");
				file.WriteLine("	\"classname\"	\"weapon_melee_spawn\"");
				file.WriteLine("	\"origin\" \"%.2f %.2f %.2f\"", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
				file.WriteLine("	\"angles\" \"%.2f %.2f %.2f\"", vecAngles[0], vecAngles[1], vecAngles[2]);
				file.WriteLine("	\"spawnflags\"	\"2\"");
				file.WriteLine("	\"disableshadows\"	\"1\"");

				if (HasEntProp(entity, Prop_Data, "m_strMapSetScriptName")) //support custom melee
				{
					GetEntPropString(entity, Prop_Data, "m_strMapSetScriptName", melee_name, sizeof(melee_name));
					file.WriteLine("	\"melee_weapon\"	\"%s\"", melee_name);
				}

				file.WriteLine("	\"spawn_without_director\"	\"1\"");
				file.WriteLine("	\"count\"	\"1\"");
				
				file.WriteLine("}");
				file.WriteLine("");
			}
			else if(strncmp(classname, "weapon_", 7, false) == 0 || strcmp(classname, "upgrade_laser_sight", false) == 0)
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecOrigin);
				GetEntPropVector(entity, Prop_Send, "m_angRotation", vecAngles);
				GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

				file.WriteLine("{");
				file.WriteLine("	\"targetname\" \"l4d2_spawn_props_object_%s\"", sTime);
				file.WriteLine("	\"solid\" \"6\"");
				file.WriteLine("	\"classname\"	\"%s\"", classname);
				file.WriteLine("	\"origin\" \"%.2f %.2f %.2f\"", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
				file.WriteLine("	\"angles\" \"%.2f %.2f %.2f\"", vecAngles[0], vecAngles[1], vecAngles[2]);
				file.WriteLine("	\"spawnflags\"	\"2\"");
				file.WriteLine("	\"disableshadows\"	\"1\"");

				if(strcmp(classname,"weapon_ammo_spawn") == 0) 
					file.WriteLine("	\"model\"	 \"%s\"", sModel);

				StringToLowerCase(sModel);
				if(g_smModelCount.GetValue(sModel, count) && count > 0)
					file.WriteLine("	\"count\"	\"%i\"", count);
				
				file.WriteLine("}");
				file.WriteLine("");
			}
		}
	}

	if(!bHasObjectNotSavedYet) return;
	
	FlushFile(file);
	CloseHandle(file);
	if(client > 0) CPrintToChat(client, "{lightgreen}[TS] %T (%s/maps/%s.cfg)", "Succesfully saved the map data", client, g_sCvar_stripper_cfg_path, map); 
}

void SaveMapStripperCustom(int client)
{
	if(client > 0) LogSpawn("%N saved the objects for this map on a 'Stripper' file format", client);

	char sMpGameMode[64], sNewPath[64], FolderName[PLATFORM_MAX_PATH];
	mp_gamemode.GetString(sMpGameMode, sizeof sMpGameMode);
	for(int i = 1; ; i++)
	{
		FormatEx(sNewPath, sizeof sNewPath, "%s_%i", sMpGameMode, i);
		FormatEx(FolderName, sizeof(FolderName), "addons/stripper/%s/maps", sNewPath);
		if(DirExists(FolderName))
		{
			continue;
		}
		else
		{
			if(CreateDirectory(FolderName, 511, true) == false)
			{
				if(client > 0)
				{
					CPrintToChat(client, "{green}[TS] Failed to create folder: addons/stripper/%s/maps", sNewPath); 
					PrintHintText(client, "[TS] Failed to create folder: addons/stripper/%s/maps", sNewPath); 
					PrintToConsole(client, "[TS] Failed to create folder: addons/stripper/%s/maps", sNewPath); 
					PrintCenterText(client, "[TS] Failed to create folder: addons/stripper/%s/maps", sNewPath); 
					return;
				}
			}
			break;
		}
	}

	char FileName[PLATFORM_MAX_PATH];
	char map[256];
	char classname[256];
	File file;
	GetCurrentMap(map, sizeof(map));
	BuildPath(Path_SM, FileName, sizeof(FileName), "../../addons/stripper/%s/maps/%s.cfg", sNewPath, map);
	
	float vecOrigin[3];
	float vecAngles[3];
	char sModel[256];
	char sTime[256];
	int count;
	char melee_name[32];
	FormatTime(sTime, sizeof(sTime), "%Y-%m-%d_%H-%M");

	bool bHasObjectNotSavedYet = false;
	if(client > 0)
	{
		if(FileExists(FileName)) PrintHintText(client, "%T", "The file already exists.", client);

		file = OpenFile(FileName, "a+");
		if(file == null)
		{
			if(client > 0)
			{
				CPrintToChat(client, "{green}[TS] Failed to create or overwrite the map file: addons/stripper/%s/maps/%s.cfg", sNewPath, map); 
				PrintHintText(client, "[TS] Failed to create or overwrite the map file: addons/stripper/%s/maps/%s.cfg", sNewPath, map); 
				PrintToConsole(client, "[TS] Failed to create or overwrite the map file: addons/stripper/%s/maps/%s.cfg", sNewPath, map); 
				PrintCenterText(client, "[TS] Failed to create or overwrite the map file: addons/stripper/%s/maps/%s.cfg", sNewPath, map); 
			}
			return;
		}

		CPrintToChat(client, "{green}[TS] %T", "Saving the content. Please Wait", client);

		file.WriteLine(";----------FILE MODIFICATION [%s] ---------------||", sTime);
		file.WriteLine(";----------BY: %N----------------------||", client);
		file.WriteLine("");
		file.WriteLine("add:");

		bHasObjectNotSavedYet = true;
	}

	for(int entity=MaxClients; entity < MAX_ENTITY; entity++)
	{
		if(g_bSpawned[entity] && IsValidEntity(entity))
		{
			if(client == 0 && !bHasObjectNotSavedYet)
			{
				LogSpawn("!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				CPrintToChatAll("{red}!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				CPrintToChatAll("{red}!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				CPrintToChatAll("{red}!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				PrintToServer("!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				PrintToServer("!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");
				PrintToServer("!!Detect objects not saved!! Auto save the objects on a 'Stripper' file");

				file = OpenFile(FileName, "a+");
				if(file == null)
				{
					if(client > 0)
					{
						CPrintToChat(client, "{green}[TS] Failed to create or overwrite the map file");
						PrintHintText(client, "[TS] Failed to create or overwrite the map file");
						PrintToConsole(client, "[TS] Failed to create or overwrite the map file");
						PrintCenterText(client, "[TS] Failed to create or overwrite the map file");
					}
					return;
				}

				file.WriteLine(";----------FILE MODIFICATION [%s] ---------------||", sTime);
				file.WriteLine(";----------BY: Server Console Auto Save----------------------||");
				file.WriteLine("");
				file.WriteLine("add:");

				bHasObjectNotSavedYet = true;
			}

			GetEntityClassname(entity, classname, sizeof(classname));
			if(strncmp(classname, "prop_dynamic", 12, false) == 0 || strncmp(classname, "prop_physics", 12, false) == 0)
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecOrigin);
				GetEntPropVector(entity, Prop_Send, "m_angRotation", vecAngles);
				GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

				file.WriteLine("{");
				file.WriteLine("	\"targetname\" \"l4d2_spawn_props_object_%s\"", sTime);
				if(strncmp(classname, "prop_dynamic_", 12, false) == 0)
				{
					if(g_bUnsolid[entity])
					{
						file.WriteLine("	\"solid\" \"1\"");
					}
					else
					{
						file.WriteLine("	\"solid\" \"6\"");
					}
				}
				file.WriteLine("	\"origin\" \"%.2f %.2f %.2f\"", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
				file.WriteLine("	\"angles\" \"%.2f %.2f %.2f\"", vecAngles[0], vecAngles[1], vecAngles[2]);
				file.WriteLine("	\"model\"	 \"%s\"", sModel);
				if(strncmp(classname, "prop_dynamic", 12, false) == 0) file.WriteLine("	\"classname\"	\"prop_dynamic_override\"");
				else file.WriteLine("	\"classname\"	\"prop_physics_override\"");
				file.WriteLine("}");
				file.WriteLine("");
			}
			else if(strcmp(classname, "weapon_melee", false) == 0)
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecOrigin);
				GetEntPropVector(entity, Prop_Send, "m_angRotation", vecAngles);
				//GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

				file.WriteLine("{");
				file.WriteLine("	\"targetname\" \"l4d2_spawn_props_object_%s\"", sTime);
				file.WriteLine("	\"solid\" \"6\"");
				file.WriteLine("	\"classname\"	\"weapon_melee_spawn\"");
				file.WriteLine("	\"origin\" \"%.2f %.2f %.2f\"", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
				file.WriteLine("	\"angles\" \"%.2f %.2f %.2f\"", vecAngles[0], vecAngles[1], vecAngles[2]);
				file.WriteLine("	\"spawnflags\"	\"2\"");
				file.WriteLine("	\"disableshadows\"	\"1\"");

				if (HasEntProp(entity, Prop_Data, "m_strMapSetScriptName")) //support custom melee
				{
					GetEntPropString(entity, Prop_Data, "m_strMapSetScriptName", melee_name, sizeof(melee_name));
					file.WriteLine("	\"melee_weapon\"	\"%s\"", melee_name);
				}

				file.WriteLine("	\"spawn_without_director\"	\"1\"");
				file.WriteLine("	\"count\"	\"1\"");
				
				file.WriteLine("}");
				file.WriteLine("");
			}
			else if(strncmp(classname, "weapon_", 7, false) == 0 || strcmp(classname, "upgrade_laser_sight", false) == 0)
			{
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vecOrigin);
				GetEntPropVector(entity, Prop_Send, "m_angRotation", vecAngles);
				GetEntPropString(entity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

				file.WriteLine("{");
				file.WriteLine("	\"targetname\" \"l4d2_spawn_props_object_%s\"", sTime);
				file.WriteLine("	\"solid\" \"6\"");
				file.WriteLine("	\"classname\"	\"%s\"", classname);
				file.WriteLine("	\"origin\" \"%.2f %.2f %.2f\"", vecOrigin[0], vecOrigin[1], vecOrigin[2]);
				file.WriteLine("	\"angles\" \"%.2f %.2f %.2f\"", vecAngles[0], vecAngles[1], vecAngles[2]);
				file.WriteLine("	\"spawnflags\"	\"2\"");
				file.WriteLine("	\"disableshadows\"	\"1\"");

				if(strcmp(classname,"weapon_ammo_spawn") == 0) 
					file.WriteLine("	\"model\"	 \"%s\"", sModel);

				StringToLowerCase(sModel);
				if(g_smModelCount.GetValue(sModel, count) && count > 0)
					file.WriteLine("	\"count\"	\"%i\"", count);
				
				file.WriteLine("}");
				file.WriteLine("");
			}
		}
	}

	if(!bHasObjectNotSavedYet) return;
	
	FlushFile(file);
	CloseHandle(file);
	if(client > 0) CPrintToChat(client, "{lightgreen}[TS] %T (addons/stripper/%s/maps/%s.cfg)", "Succesfully saved the map data", client, sNewPath, map); 
}

Action CmdRotate(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	if(args < 2)
	{
		CPrintToChat(client, "[TS] Usage: sm_prop_rotate <axys> <angles> [EX: !prop_rotate x 30]");
		return Plugin_Handled;
	}
	//int Object = g_iLastObject[client];
	int Object = FindObjectYouAreLooking(client); 
	if(Object <= MaxClients || !IsValidEntity(Object))
	{
		CPrintToChat(client, "[TS] %T","You are not looking at a spawned object", client);
		return Plugin_Handled;
	}

	char arg1[16];
	char arg2[16];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	float vecAngles[3];
	GetEntPropVector(Object, Prop_Send, "m_angRotation", vecAngles);
	float fAngles = StringToFloat(arg2);
	if(strcmp(arg1, "x")== 0)
	{
		vecAngles[0] += fAngles;
	}
	else if(strcmp(arg1, "y")== 0)
	{
		vecAngles[1] += fAngles;
	}
	else if(strcmp(arg1, "z")== 0)
	{
		vecAngles[2] += fAngles;
	}
	else
	{
		CPrintToChat(client, "[TS] Invalid Axys (x,y,z are allowed)");
	}
	TeleportEntity(Object, NULL_VECTOR, vecAngles, NULL_VECTOR);

	return Plugin_Handled;
}

Action CmdRemoveLast(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	DeleteLastProp(client);
	return Plugin_Handled;
}

Action CmdRemoveLook(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	DeleteLookingEntity(client);
	return Plugin_Handled;
}

Action CmdRemoveAll(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	CPrintToChat(client, "{green}[TS] %T","Are you sure(Delete All)?",client);
	BuildDeleteAllCmd(client);
	return Plugin_Handled;
}

void BuildDeleteAllCmd(int client)
{
	Menu menu = new Menu(MenuHandler_cmd_Ask);
	menu.SetTitle("%T", "Are you sure?", client);
	menu.AddItem("sm_spyes", Translate(client, "%t", "Yes"));
	menu.AddItem("sm_spno", Translate(client, "%t", "No"));
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

int MenuHandler_cmd_Ask(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char menucmd[256];
			GetMenuItem(menu, param2, menucmd, sizeof(menucmd));
			if(strcmp(menucmd, "sm_spyes")== 0)
			{
				DeleteAllProps();
				CPrintToChat(param1, "[TS] %T", "Successfully deleted all spawned objects", param1);
			}
			else
			{
				CPrintToChat(param1, "[TS] %T", "Canceled", param1);
			}
		}
		case MenuAction_Cancel:
		{
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

Action CmdMove(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	if(args < 2)
	{
		CPrintToChat(client, "[TS] Usage: sm_prop_move <axys> <distance> [EX: !prop_move x 30]");
		return Plugin_Handled;
	}

	//int Object = g_iLastObject[client];
	int Object = FindObjectYouAreLooking(client); 
	if(Object <= MaxClients || !IsValidEntity(Object))
	{
		CPrintToChat(client, "[TS] %T","You are not looking at a spawned object", client);
		return Plugin_Handled;
	}

	char arg1[16];
	char arg2[16];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	float vecPosition[3];
	GetEntPropVector(Object, Prop_Data, "m_vecOrigin", vecPosition);
	float flPosition = StringToFloat(arg2);
	if(strcmp(arg1, "x")== 0)
	{
		vecPosition[0] += flPosition;
	}
	else if(strcmp(arg1, "y")== 0)
	{
		vecPosition[1] += flPosition;
	}
	else if(strcmp(arg1, "z")== 0)
	{
		vecPosition[2] += flPosition;
	}
	else
	{
		CPrintToChat(client, "[TS] Invalid Axys (x,y,z are allowed)");
	}

	TeleportEntity(Object, vecPosition, NULL_VECTOR, NULL_VECTOR);
	return Plugin_Handled;
}

Action CmdSetAngles(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	if(args < 3)
	{
		CPrintToChat(client, "[TS] Usage: sm_prop_setang <X Y Z> [EX: !prop_setang 30 0 34]");
		return Plugin_Handled;
	}

	//int Object = g_iLastObject[client];
	int Object = FindObjectYouAreLooking(client); 
	if(Object <= MaxClients || !IsValidEntity(Object))
	{
		CPrintToChat(client, "[TS] %T","You are not looking at a spawned object", client);
		return Plugin_Handled;
	}

	char arg1[16];
	char arg2[16];
	char arg3[16];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	float vecAngles[3];
	
	vecAngles[0] = StringToFloat(arg1);
	vecAngles[1] = StringToFloat(arg2);
	vecAngles[2] = StringToFloat(arg3);
	
	TeleportEntity(Object, NULL_VECTOR, vecAngles, NULL_VECTOR);
	return Plugin_Handled;
}

Action CmdSetPosition(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	if(args < 3)
	{
		CPrintToChat(client, "[TS] Usage: sm_prop_setpos <X Y Z> [EX: !prop_setpos 505 -34 17");
		return Plugin_Handled;
	}

	//int Object = g_iLastObject[client];
	int Object = FindObjectYouAreLooking(client); 
	if(Object <= MaxClients || !IsValidEntity(Object))
	{
		CPrintToChat(client, "[TS] %T","You are not looking at a spawned object", client);
		return Plugin_Handled;
	}

	char arg1[16];
	char arg2[16];
	char arg3[16];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	float vecPosition[3];
	
	vecPosition[0] = StringToFloat(arg1);
	vecPosition[1] = StringToFloat(arg2);
	vecPosition[2] = StringToFloat(arg3);
	TeleportEntity(Object, vecPosition, NULL_VECTOR, NULL_VECTOR);
	return Plugin_Handled;
}

Action CmdLock(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	int Object = FindObjectYouAreLooking(client, true); 
	if(Object <= MaxClients || !IsValidEntity(Object))
	{
		CPrintToChat(client, "[TS] %T","You are not looking at a spawned object", client);
		return Plugin_Handled;
	}

	
	LockGlow(client, Object);
	g_iLockObject[client] = EntIndexToEntRef(Object);

	CPrintToChat(client, "[TS] %T", "Succesfully locked spawned object", client, Object);

	return Plugin_Handled;
}

Action CmdClone(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	int Object = EntRefToEntIndex(g_iLockObject[client]);
	if(Object == INVALID_ENT_REFERENCE)
	{
		CPrintToChat(client, "[TS] %T", "You haven't locked anything yet", client);
		return Plugin_Handled;
	}

	float vecOrigin[3];
	float vecAngles[3];
	char sModel[256];
	char classname[256];
	char sMeleeName[64];
	GetEntityClassname(Object, classname, sizeof(classname));
	if(strncmp(classname, "prop_dynamic", 12, false) == 0)
	{
		GetEntPropVector(Object, Prop_Send, "m_vecOrigin", vecOrigin);
		GetEntPropVector(Object, Prop_Send, "m_angRotation", vecAngles);
		GetEntPropString(Object, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

		int prop = CreateEntityByName("prop_dynamic_override");
		DispatchKeyValue(prop, "model", sModel);
		DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
		vecOrigin[0] += 30;
		vecOrigin[1] += 30;
		TeleportEntity(prop, vecOrigin, vecAngles, NULL_VECTOR);
		DispatchSpawn(prop);

		if(g_bUnsolid[Object])
		{
			SetEntProp(prop, Prop_Send, "m_nSolidType", 1);
			g_bSpawned[prop] = true;
			g_bUnsolid[prop] = true;
		}
		else
		{
			SetEntProp(prop, Prop_Send, "m_nSolidType", 6);
			g_bSpawned[prop] = true;
			g_bUnsolid[prop] = false;
		}

		LockGlow(client, prop);
		g_iLastObject[client] = EntIndexToEntRef(prop);
		g_iLockObject[client] = EntIndexToEntRef(prop);
		g_bSpawned[prop] = true;

		LogSpawn("%N spawned a dynamic object with model <%s>", client, sModel);
	}
	else if(strncmp(classname, "prop_physics", 12, false) == 0)
	{
		GetEntPropVector(Object, Prop_Send, "m_vecOrigin", vecOrigin);
		GetEntPropVector(Object, Prop_Send, "m_angRotation", vecAngles);
		GetEntPropString(Object, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

		int prop = CreateEntityByName("prop_physics_override");
		DispatchKeyValue(prop, "model", sModel);
		DispatchKeyValue(prop, "targetname", "l4d2_spawn_props_object");
		vecOrigin[0] += 30;
		vecOrigin[1] += 30;
		TeleportEntity(prop, vecOrigin, vecAngles, NULL_VECTOR);
		DispatchSpawn(prop);

		LockGlow(client, prop);
		g_iLastObject[client] = EntIndexToEntRef(prop);
		g_iLockObject[client] = EntIndexToEntRef(prop);
		g_bSpawned[prop] = true;

		LogSpawn("%N spawned a physics object with model <%s>", client, sModel);
	}
	else if(strcmp(classname, "weapon_melee", false) == 0)
	{
		GetEntPropVector(Object, Prop_Send, "m_vecOrigin", vecOrigin);
		GetEntPropVector(Object, Prop_Send, "m_angRotation", vecAngles);
		if (HasEntProp(Object, Prop_Data, "m_strMapSetScriptName")) //support custom melee
		{
			GetEntPropString(Object, Prop_Data, "m_strMapSetScriptName", sMeleeName, sizeof(sMeleeName));
		}

		int entity_weapon = CreateEntityByName("weapon_melee");
		if( entity_weapon == -1 )
			ThrowError("Failed to create entity 'weapon_melee'");

		DispatchKeyValue(entity_weapon, "solid", "6");
		DispatchKeyValue(entity_weapon, "melee_script_name", sMeleeName);
		vecOrigin[0] += 30;
		vecOrigin[1] += 30;
		TeleportEntity(entity_weapon, vecOrigin, vecAngles, NULL_VECTOR);
		DispatchSpawn(entity_weapon);

		LockGlow(client, entity_weapon);
		g_iLastObject[client] = EntIndexToEntRef(entity_weapon);
		g_iLockObject[client] = EntIndexToEntRef(entity_weapon);
		g_bSpawned[entity_weapon] = true;

		LogSpawn("%N spawned a melee object with script <%s>", client, sMeleeName);
	}
	else if(strncmp(classname, "weapon_", 7, false) == 0 || strcmp(classname, "upgrade_laser_sight", false) == 0)
	{
		GetEntPropVector(Object, Prop_Send, "m_vecOrigin", vecOrigin);
		GetEntPropVector(Object, Prop_Send, "m_angRotation", vecAngles);
		GetEntPropString(Object, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

		int entity_weapon = CreateEntityByName(classname);
		if( entity_weapon == -1 )
			ThrowError("Failed to create entity '%s'", classname);

		DispatchKeyValue(entity_weapon, "solid", "6");
		DispatchKeyValue(entity_weapon, "model", sModel);
		DispatchKeyValue(entity_weapon, "rendermode", "3");
		DispatchKeyValue(entity_weapon, "disableshadows", "1");
		DispatchKeyValue(entity_weapon, "targetname", "l4d2_spawn_props_object");

		int count;
		char sCount[5];
		StringToLowerCase(sModel);
		if(g_bLeft4Dead2 && g_smModelCount.GetValue(sModel, count) && count > 0)
		{
			IntToString(count, sCount, sizeof(sCount));
			DispatchKeyValue(entity_weapon, "count", sCount);
		}
		else if(!g_bLeft4Dead2 && g_smModelCount.GetValue(sModel, count) && count > 0)
		{
			IntToString(count, sCount, sizeof(sCount));
			DispatchKeyValue(entity_weapon, "count", sCount);
		}

		vecOrigin[0] += 30;
		vecOrigin[1] += 30;
		TeleportEntity(entity_weapon, vecOrigin, vecAngles, NULL_VECTOR);
		DispatchSpawn(entity_weapon);

		LockGlow(client, entity_weapon);
		g_iLastObject[client] = EntIndexToEntRef(entity_weapon);
		g_iLockObject[client] = EntIndexToEntRef(entity_weapon);
		g_bSpawned[entity_weapon] = true;
	}

	return Plugin_Handled;
}

/*
////////////////////////////////////////////////////////////////////////////|
						Build File Directories							    |
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\|
*/

void BuildFileDirectories()
{
	for(int Num; Num < sizeof(FolderNames); Num++)
	{
		if(!DirExists(FolderNames[Num]))
		{
			CreateDirectory(FolderNames[Num], 511);
		}
	}
}

stock char[] Translate(int client, const char[] format, any ...)
{
	char buffer[192];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);
	return buffer;
}

public void OnEntityDestroyed(int entity)
{
	if (entity < 0 || entity > MAX_ENTITY)
		return;

	g_bSpawned[entity] = false;
	g_bUnsolid[entity] = false;

	for(int i=1; i<=MaxClients; i++)
	{
		if(entity == EntRefToEntIndex(g_iLockObject[i]))
		{
			g_iLockObject[i] = INVALID_ENT_REFERENCE;
			g_iLastObject[i] = INVALID_ENT_REFERENCE;
		}
	}
}

// Taken from "[L4D2] Weapon/Zombie Spawner"
// By "Zuko & McFlurry"
bool SetTeleportEndPoint(int client, float vPos[3], float vAng[3], int type)
{
	GetClientEyePosition(client, vPos);
	GetClientEyeAngles(client, vAng);

	Handle trace = TR_TraceRayFilterEx(vPos, vAng, MASK_SHOT, RayType_Infinite, _TraceFilter);

	if( TR_DidHit(trace) )
	{
		if(type == 1 || type == 2)
		{
			float vNorm[3];
			float degrees = vAng[1];
			TR_GetEndPosition(vPos, trace);

			GetGroundHeight(vPos);
			vPos[2] += 1.0;

			TR_GetPlaneNormal(trace, vNorm);
			GetVectorAngles(vNorm, vAng);

			if( vNorm[2] == 1.0 )
			{
				vAng[0] = 0.0;
				vAng[1] = degrees + 180;
			}
			else
			{
				if( degrees > vAng[1] )
					degrees = vAng[1] - degrees;
				else
					degrees = degrees - vAng[1];
				vAng[0] += 90.0;
				RotateYaw(vAng, degrees + 180);
			}
		}
		else if(type == 3)
		{
			float vNorm[3];
			TR_GetEndPosition(vPos, trace);
			TR_GetPlaneNormal(trace, vNorm);
			float angle = vAng[1];
			GetVectorAngles(vNorm, vAng);

			if( vNorm[2] == 1.0 )
			{
				vAng[0] = 0.0;
				vAng[1] += angle;
			}
			else
			{
				vAng[0] = 0.0;
				vAng[1] += angle - 90.0;
			}
		}
	}
	else
	{
		delete trace;
		return false;
	}

	if(type == 1 || type == 2)
	{
		vAng[1] += 90.0;
		vAng[2] -= 90.0;
	}

	delete trace;
	return true;
}

bool _TraceFilter(int entity, int contentsMask)
{
	return entity > MaxClients || !entity;
}

//---------------------------------------------------------
// do a specific rotation on the given angles
//---------------------------------------------------------
void RotateYaw(float angles[3], float degree)
{
	float direction[3], normal[3];
	GetAngleVectors( angles, direction, NULL_VECTOR, normal );

	float sin = Sine( degree * 0.01745328 );	 // Pi/180
	float cos = Cosine( degree * 0.01745328 );
	float a = normal[0] * sin;
	float b = normal[1] * sin;
	float c = normal[2] * sin;
	float x = direction[2] * b + direction[0] * cos - direction[1] * c;
	float y = direction[0] * c + direction[1] * cos - direction[2] * a;
	float z = direction[1] * a + direction[2] * cos - direction[0] * b;
	direction[0] = x;
	direction[1] = y;
	direction[2] = z;

	GetVectorAngles( direction, angles );

	float up[3];
	GetVectorVectors( direction, NULL_VECTOR, up );

	float roll = GetAngleBetweenVectors( up, normal, direction );
	angles[2] += roll;
}

float GetGroundHeight(float vPos[3])
{
	float vAng[3];
	Handle trace = TR_TraceRayFilterEx(vPos, view_as<float>({ 90.0, 0.0, 0.0 }), MASK_ALL, RayType_Infinite, _TraceFilter);
	if( TR_DidHit(trace) )
		TR_GetEndPosition(vAng, trace);

	delete trace;
	return vAng[2];
}

//---------------------------------------------------------
// calculate the angle between 2 vectors
// the direction will be used to determine the sign of angle (right hand rule)
// all of the 3 vectors have to be normalized
//---------------------------------------------------------
float GetAngleBetweenVectors(const float vector1[3], const float vector2[3], const float direction[3])
{
	float vector1_n[3], vector2_n[3], direction_n[3], cross[3];
	NormalizeVector( direction, direction_n );
	NormalizeVector( vector1, vector1_n );
	NormalizeVector( vector2, vector2_n );
	float degree = ArcCosine( GetVectorDotProduct( vector1_n, vector2_n ) ) * 57.29577951;   // 180/Pi
	GetVectorCrossProduct( vector1_n, vector2_n, cross );

	if( GetVectorDotProduct( cross, direction_n ) < 0.0 )
		degree *= -1.0;

	return degree;
}

void CreateStringMap()
{
	g_smModelCount = CreateTrie();
	g_smModelCount.SetValue("models/w_models/weapons/w_eq_medkit.mdl", 0);
	g_smModelCount.SetValue("models/w_models/weapons/w_eq_defibrillator.mdl", 0);
	g_smModelCount.SetValue("models/w_models/weapons/w_eq_painpills.mdl", 0);
	g_smModelCount.SetValue("models/w_models/weapons/w_eq_adrenaline.mdl", 0);
	g_smModelCount.SetValue("models/w_models/weapons/w_eq_bile_flask.mdl", 1);
	g_smModelCount.SetValue("models/w_models/weapons/w_eq_molotov.mdl", 1);
	g_smModelCount.SetValue("models/w_models/weapons/w_eq_pipebomb.mdl", 1);
	g_smModelCount.SetValue("models/w_models/weapons/w_eq_incendiary_ammopack.mdl", 0);
	g_smModelCount.SetValue("models/w_models/weapons/w_eq_explosive_ammopack.mdl", 0);

	g_smModelCount.SetValue("models/weapons/melee/w_chainsaw.mdl", 1);
	if(g_bLeft4Dead2) 
	{
		g_smModelCount.SetValue("models/w_models/weapons/w_pistol_b.mdl", 1);
		g_smModelCount.SetValue("models/w_models/weapons/w_pistol_a.mdl", 1);
	}
	else
	{
		g_smModelCount.SetValue("models/w_models/weapons/w_pistol_1911.mdl", 1);
	}
	g_smModelCount.SetValue("models/w_models/weapons/w_desert_eagle.mdl", 1);
	g_smModelCount.SetValue("models/w_models/weapons/w_shotgun.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_pumpshotgun_a.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_smg_uzi.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_smg_a.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_smg_mp5.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_rifle_m16a2.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_rifle_sg552.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_rifle_ak47.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_desert_rifle.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_shotgun_spas.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_autoshot_m4super.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_sniper_mini14.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_sniper_military.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_sniper_scout.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_sniper_awp.mdl", 5);
	g_smModelCount.SetValue("models/w_models/weapons/w_grenade_launcher.mdl", 1);
	g_smModelCount.SetValue("models/w_models/weapons/w_m60.mdl", 1);

	g_smModelCount.SetValue(MODEL_AMMO_L4D, 5);
	g_smModelCount.SetValue(MODEL_AMMO_L4D2, 5);
	g_smModelCount.SetValue(MODEL_AMMO_L4D3, 5);
	g_smModelCount.SetValue(MODEL_LASER, 0);
}

void StringToLowerCase(char[] input)
{
    for (int i = 0; i < strlen(input); i++)
    {
        input[i] = CharToLower(input[i]);
    }
}

int FindObjectYouAreLooking(int client, bool bSpawned = true)
{
	float VecOrigin[3];
	float VecAngles[3];
	GetClientEyePosition(client, VecOrigin);
	GetClientEyeAngles(client, VecAngles);
	if(bSpawned)
	{
		TR_TraceRayFilter(VecOrigin, VecAngles, MASK_ALL, RayType_Infinite, TracesSpawnedObjectFilter, client);
		if (TR_DidHit(null))
		{
			return TR_GetEntityIndex(null);
		}
	}
	else
	{
		TR_TraceRayFilter(VecOrigin, VecAngles, MASK_ALL, RayType_Infinite, TracesObjectFilter, client);
		if (TR_DidHit(null))
		{
			return TR_GetEntityIndex(null);
		}
	}

	return 0;
}

bool TracesSpawnedObjectFilter(int entity, int contentsMask, int client)
{
	if(entity == client) // Check if the TraceRay hit the itself.
	{
		return false; // Don't let the entity be hit
	}

	if (entity > MaxClients && IsValidEntity(entity) && g_bSpawned[entity])
	{
		static char entName[64];
		GetEntPropString(entity, Prop_Data, "m_iName", entName, sizeof(entName));
		if(strcmp(entName,"l4d2_spawn_props_object") == 0)
		{
			return true;
		}
	}

	return false;
}

bool TracesObjectFilter(int entity, int contentsMask, int client)
{
	if(entity == client) // Check if the TraceRay hit the itself.
	{
		return false; // Don't let the entity be hit
	}

	if (entity > MaxClients && IsValidEntity(entity))
	{
		static char class[256];
		GetEntityClassname(entity, class, sizeof(class));
		if(strncmp(class, "prop_physics", 12, false) == 0
		|| strncmp(class, "prop_dynamic", 12, false) == 0
		|| strncmp(class, "weapon_", 7, false) == 0
		|| strcmp(class, "upgrade_laser_sight", false) == 0)
		{
			return true;
		}
	}

	return false;
}

void LockGlow(int client, int Object)
{
	if(!g_bCvarGlow) return;
	
	int lastlockobject = EntRefToEntIndex(g_iLockObject[client]);
	if(lastlockobject != INVALID_ENT_REFERENCE)
	{
		if(g_bLeft4Dead2)
		{
			L4D2_RemoveEntityGlow(lastlockobject);
		}
		SetEntityRenderMode(lastlockobject, RENDER_NORMAL);
	}

	if(g_bLeft4Dead2) L4D2_SetEntityGlow(Object, L4D2Glow_Constant, 0, 0, LOCK_COLORS, true);

	SetEntityRenderMode(Object, RENDER_TRANSCOLOR);
	SetEntityRenderColor(Object, 255, 255, 255, 220);
}