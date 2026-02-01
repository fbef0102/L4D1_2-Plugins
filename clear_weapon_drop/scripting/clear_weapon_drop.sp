#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#define PLUGIN_VERSION			"3.3-2026-2-1"
#define PLUGIN_NAME			    "clear_weapon_drop"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "[L4D1/L4D2]Remove weapon drop",
	author = "AK978, HarryPotter",
	description = "Remove weapon dropped by survivor or uncommon infected + remove upgrade pack when deployed",
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
	
	CreateNative("L4D_RemoveWeaponOnGround", Native_L4D_RemoveWeaponOnGround);

	bLate = late;
	return APLRes_Success; 
}

int Native_L4D_RemoveWeaponOnGround(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	float time = GetNativeCell(2);
	SetTimer_DeleteWeapon(entity, time);

	return 0;
}

#define DATA_CONFIG		"data/" ... PLUGIN_NAME ... ".cfg"

#define MAXENTITIES                   2048
#define CLASSNAME_WEAPON_GNOME        		"weapon_gnome"
#define CLASSNAME_WEAPON_COLA         		"weapon_cola_bottles"
#define CLASSNAME_WEAPON_GASCAN       		"weapon_gascan"
#define CLASSNAME_WEAPON_FIREWORKCRATE      "weapon_fireworkcrate"
#define CLASSNAME_WEAPON_PROTANK      		"weapon_propanetank"
#define CLASSNAME_WEAPON_OXYTANK      		"weapon_oxygentank"

#define MODEL_GNOME                 	"models/props_junk/gnome.mdl"
#define MODEL_GASCAN                  	"models/props_junk/gascan001a.mdl"
#define MODEL_PROPANECANISTER         	"models/props_junk/propanecanister001a.mdl"
#define MODEL_OXYGENTANK              	"models/props_equipment/oxygentank01.mdl"
#define MODEL_FIREWORKS_CRATE         	"models/props_junk/explosive_box001.mdl"

#define MODEL_FIRE_AMMO               	"models/props/terror/incendiary_ammo.mdl"
#define MODEL_EXPLODE_AMMO         	  	"models/props/terror/exploding_ammo.mdl"

#define MODEL_TONFA 				  	"models/weapons/melee/w_tonfa.mdl"

static int    	g_iModel_Gnome = -1;
static int    	g_iModel_Gascan = -1;
static int    	g_iModel_PropaneCanister = -1;
static int    	g_iModel_OxygenTank = -1;
static int    	g_iModel_FireworksCrate = -1;
static int    	g_iModel_FireAmmo = -1;
static int    	g_iModel_ExplodeAmmo = -1;

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar g_hCvarEnable, g_hCvarSurDeathNot;
bool g_bCvarEnable, g_bCvarSurDeathNot;

Handle g_ItemDeleteTimer[MAXENTITIES+1];

static char g_sItemDeleteList[][] =
{
	"weapon_smg_mp5",
	"weapon_smg",
	"weapon_smg_silenced",
	"weapon_shotgun_chrome",
	"weapon_pumpshotgun",
	"weapon_hunting_rifle",
	"weapon_pistol",
	"weapon_rifle_m60",
	"weapon_first_aid_kit",
	"weapon_autoshotgun",
	"weapon_shotgun_spas",
	"weapon_sniper_military",
	"weapon_rifle",
	"weapon_rifle_ak47",
	"weapon_rifle_desert",
	"weapon_sniper_awp",
	"weapon_rifle_sg552",
	"weapon_sniper_scout",
	"weapon_grenade_launcher",
	"weapon_pistol_magnum",
	"weapon_molotov",
	"weapon_pipe_bomb",
	"weapon_vomitjar",
	"weapon_defibrillator",
	"weapon_pain_pills",
	"weapon_adrenaline",
	"weapon_melee",
	"weapon_chainsaw",
	"weapon_upgradepack_incendiary",
	"weapon_upgradepack_explosive",
	CLASSNAME_WEAPON_GASCAN, //does not remove scavenge gascan
	CLASSNAME_WEAPON_FIREWORKCRATE,
	CLASSNAME_WEAPON_PROTANK,
	CLASSNAME_WEAPON_OXYTANK,
	CLASSNAME_WEAPON_GNOME,
	CLASSNAME_WEAPON_COLA,
	"upgrade_ammo_explosive",
	"upgrade_ammo_incendiary"
};

StringMap 
	g_smWeaponDeleteTime,
	g_smUnCommonDeleteTime;

bool 
	g_bDeathFrame[MAXPLAYERS+1];

int 
	g_iDeathWeapons[MAXPLAYERS+1][6];

public void OnPluginStart()
{
	g_hCvarEnable 			= CreateConVar( PLUGIN_NAME ... "_enable",        	"1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarSurDeathNot 		= CreateConVar( PLUGIN_NAME ... "_death_not", 		"1",   "1=Do not remove weapons if dropped when player death\n0=Remove", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarEnable 			= CreateConVar( PLUGIN_NAME ... "_enable",        	"1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	CreateConVar(                       	PLUGIN_NAME ... "_version",       	PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                	PLUGIN_NAME);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarSurDeathNot.AddChangeHook(ConVarChanged_Cvars);
	AutoExecConfig(true, "clear_weapon_drop");

	HookEvent("weapon_drop", Event_WeaponDrop);

	if (g_bL4D2Version){
		HookEvent ("upgrade_pack_used",	Event_UpgradePack);
	}

	g_smWeaponDeleteTime = new StringMap();
	g_smUnCommonDeleteTime = new StringMap();
	
	if (bLate)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarSurDeathNot = g_hCvarSurDeathNot.BoolValue;
}

public void OnMapStart()
{	
	g_iModel_Gascan = PrecacheModel(MODEL_GASCAN, true);
	g_iModel_PropaneCanister = PrecacheModel(MODEL_PROPANECANISTER, true);
	g_iModel_OxygenTank = PrecacheModel(MODEL_OXYGENTANK, true);
	if (g_bL4D2Version)
	{
		g_iModel_Gnome = PrecacheModel(MODEL_GNOME, true);
		g_iModel_FireworksCrate = PrecacheModel(MODEL_FIREWORKS_CRATE, true);
		g_iModel_FireAmmo = PrecacheModel(MODEL_FIRE_AMMO, true);
		g_iModel_ExplodeAmmo = PrecacheModel(MODEL_EXPLODE_AMMO, true);
	}
}

bool g_bConfigLoaded;
public void OnMapEnd()
{
	g_bConfigLoaded = false;
}

public void OnConfigsExecuted()
{
	g_bConfigLoaded = true;

	LoadData();
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!g_bCvarEnable) 
		return;

	if (!g_bConfigLoaded)
		return;

	if (!IsValidEntityIndex(entity))
		return;

	//LogError("OnEntityCreated %d-%s", entity, classname);

	if(g_bL4D2Version)
	{
		switch (classname[0])
		{
			case 'w':
			{
				if ( (StrEqual(classname, "weapon_molotov") && g_smUnCommonDeleteTime.ContainsKey("weapon_molotov")) ||
					(StrEqual(classname, "weapon_pipe_bomb") && g_smUnCommonDeleteTime.ContainsKey("weapon_pipe_bomb")) ||
					(StrEqual(classname, "weapon_vomitjar") && g_smUnCommonDeleteTime.ContainsKey("weapon_vomitjar")) ||
					(StrEqual(classname, "weapon_pain_pills") && g_smUnCommonDeleteTime.ContainsKey("weapon_pain_pills")) ||
					(StrEqual(classname, "weapon_adrenaline") && g_smUnCommonDeleteTime.ContainsKey("weapon_adrenaline")) ||
					(StrEqual(classname, "weapon_first_aid_kit") && g_smUnCommonDeleteTime.ContainsKey("weapon_first_aid_kit")) ||
					(StrEqual(classname, "weapon_melee") && g_smUnCommonDeleteTime.ContainsKey("weapon_melee")) )
				{
					SDKHook(entity, SDKHook_SpawnPost, OnSpawnPost_ByInfected);
				}
			}
		}
	}

	switch (classname[0])
	{
		case 'p':
		{
			if ( strncmp(classname, "physics_prop", 12, false) == 0 || strncmp(classname, "prop_physics", 12, false) == 0)
			{
				SDKHook(entity, SDKHook_SpawnPost, OnSpawnPost_BySurvivior);
			}
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if (!IsValidEntityIndex(entity))
		return;

	delete g_ItemDeleteTimer[entity];
}

void Event_WeaponDrop(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bCvarEnable) return;

	int entity = event.GetInt("propid");	
	if(entity <= MaxClients) return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsValidClient(client) && GetClientTeam(client) == 2 && g_bDeathFrame[client]) //人類死亡時掉的武器
	{
		//PrintToChatAll("Event_WeaponDrop %N-%d", client, entity);

		if(g_bCvarSurDeathNot) return;
	}
	
	SetTimer_DeleteWeapon(entity);
}

void Event_UpgradePack(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bCvarEnable) return;
	
	int entity = event.GetInt("upgradeid");
	if (!IsValidEntityIndex(entity)) return;
	

	float fTime = 0.0;
	int modelIndex = GetEntProp(entity, Prop_Send, "m_nModelIndex");
	if( modelIndex == g_iModel_FireAmmo)
	{
		g_smWeaponDeleteTime.GetValue("upgrade_ammo_incendiary", fTime);
	}
	else if(modelIndex == g_iModel_ExplodeAmmo)
	{
		g_smWeaponDeleteTime.GetValue("upgrade_ammo_explosive", fTime);
	}

	if(fTime <= 0.0) return;
	delete g_ItemDeleteTimer[entity];
	DataPack hPack;
	g_ItemDeleteTimer[entity] = CreateDataTimer(fTime, Timer_KillGroundPackEntity, hPack);
	hPack.WriteCell(entity);
	hPack.WriteCell(EntIndexToEntRef(entity));
}

void OnWeaponEquipPost(int client, int weapon)
{
	if (client <= 0 || client > MaxClients || !IsClientInGame(client))
		return;

	if (!IsValidEntity(weapon))
		return;

	//LogError("%N OnWeaponEquipPost %d", client, weapon);
	delete g_ItemDeleteTimer[weapon];
}

void OnSpawnPost_ByInfected(int entity)
{
    if ( entity <= MaxClients || !IsValidEntity(entity) ) return;

    RequestFrame(OnNextFrame_ByInfected, EntIndexToEntRef(entity));
}

void OnNextFrame_ByInfected(int entityRef)
{
	int weapon = EntRefToEntIndex(entityRef);

	if (weapon == INVALID_ENT_REFERENCE)
		return;

	if (HasEntProp(weapon, Prop_Send, "m_DroppedByInfectedGender"))
	{
		if(GetEntProp(weapon, Prop_Send, "m_DroppedByInfectedGender") > 0) //Dropped By Uncommon Infected
		{
			float fTime = 0.0;
			static char sClassName[64];
			GetEntityClassname(weapon, sClassName, sizeof(sClassName));

			g_smUnCommonDeleteTime.GetValue(sClassName, fTime);
			
			if(fTime <= 0.0) return; 
			
			delete g_ItemDeleteTimer[weapon];

			DataPack hPack;
			g_ItemDeleteTimer[weapon] = CreateDataTimer(fTime, Timer_KillWeapon, hPack);
			hPack.WriteCell(weapon);
			hPack.WriteCell(EntIndexToEntRef(weapon));
			return;
		}
	}

	/*int modelIndex = GetEntProp(weapon, Prop_Send, "m_nModelIndex");
	if(modelIndex == g_iModel_Tonfa) //從警察身上掉落的警棍抓不到m_DroppedByInfectedGender
	{
		
	}*/
}

void OnSpawnPost_BySurvivior(int entity)
{
    if ( entity <= MaxClients || !IsValidEntity(entity) ) return;

    RequestFrame(OnNextFrame_BySurvivior, EntIndexToEntRef(entity));
}

void OnNextFrame_BySurvivior(int entityRef)
{
	int weapon = EntRefToEntIndex(entityRef);

	if (weapon == INVALID_ENT_REFERENCE)
		return;

	if (GetEntProp(weapon, Prop_Data, "m_iHammerID") == -1) // Ignore entities with hammerid -1
		return;

	if (GetEntPropEnt(weapon, Prop_Data, "m_hOwnerEntity") <= 0) //prop_physics物品從人類身上掉落或丟出去時這個值會變成1 (瓦斯桶, 氧氣罐, 煙火盒, 精靈小矮人)
		return;

	
	int modelIndex = GetEntProp(weapon, Prop_Send, "m_nModelIndex");
	if(modelIndex == g_iModel_Gascan && IsScavengeGascan(weapon)) return;

	float fTime = 0.0;
	if( (modelIndex == g_iModel_Gascan && g_smWeaponDeleteTime.GetValue(CLASSNAME_WEAPON_GASCAN, fTime)) ||
		(modelIndex == g_iModel_PropaneCanister && g_smWeaponDeleteTime.GetValue(CLASSNAME_WEAPON_OXYTANK, fTime)) || 
		(modelIndex == g_iModel_OxygenTank && g_smWeaponDeleteTime.GetValue(CLASSNAME_WEAPON_PROTANK, fTime)) || 
		(g_bL4D2Version && modelIndex == g_iModel_FireworksCrate && g_smWeaponDeleteTime.GetValue(CLASSNAME_WEAPON_FIREWORKCRATE, fTime)) ||
		(g_bL4D2Version && modelIndex == g_iModel_Gnome && g_smWeaponDeleteTime.GetValue(CLASSNAME_WEAPON_GNOME, fTime)) )
	{
		if(fTime <= 0.0) return;

		delete g_ItemDeleteTimer[weapon];

		DataPack hPack;
		g_ItemDeleteTimer[weapon] = CreateDataTimer(fTime, Timer_KillWeapon, hPack);
		hPack.WriteCell(weapon);
		hPack.WriteCell(EntIndexToEntRef(weapon));
	}
}

Action Timer_KillGroundPackEntity(Handle timer, DataPack hPack)
{
	hPack.Reset();
	int index = hPack.ReadCell();
	g_ItemDeleteTimer[index] = null;

	int entity = EntRefToEntIndex(hPack.ReadCell());
	if(entity == INVALID_ENT_REFERENCE) return Plugin_Continue;

	SetEntityRenderFx(entity, RENDERFX_FADE_FAST); //RENDERFX_FADE_SLOW 3.5
	CreateTimer(1.5, KillEntity, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

Action Timer_KillWeapon(Handle timer, DataPack hPack)
{
	hPack.Reset();
	int index = hPack.ReadCell();
	g_ItemDeleteTimer[index] = null;

	int entity = EntRefToEntIndex(hPack.ReadCell());
	if(entity == INVALID_ENT_REFERENCE) return Plugin_Continue;

	if(IsInUse(entity) == false )
	{
		RemoveEntity(entity);
	}

	return Plugin_Continue;
}

Action KillEntity(Handle timer, int ref)
{
	if(ref && EntRefToEntIndex(ref) != INVALID_ENT_REFERENCE)
	{
		RemoveEntity(ref);
	}

	return Plugin_Continue;
}

void SetTimer_DeleteWeapon(int entity, float fSetTime = -1.0)
{
	if (!IsValidEntityIndex(entity) || !IsValidEntity(entity)) return;

	static char sClassName[64];
	GetEntityClassname(entity, sClassName, sizeof(sClassName));
	//LogError("SetTimer_DeleteWeapon %d - %s",entity, sClassName);

	if(fSetTime >= 0.0)
	{
		if( strncmp(sClassName, "prop_physics", 12, false) == 0 || strncmp(sClassName, "physics_prop", 12, false) == 0)
		{
			int modelIndex = GetEntProp(entity, Prop_Send, "m_nModelIndex");
			//LogError("modelIndex - %d", modelIndex);
			if(modelIndex == g_iModel_Gascan && IsScavengeGascan(entity)) return;

			if( modelIndex == g_iModel_Gascan ||
				modelIndex == g_iModel_PropaneCanister ||
				modelIndex == g_iModel_OxygenTank ||
				(g_bL4D2Version && modelIndex == g_iModel_FireworksCrate) ||
				(g_bL4D2Version && modelIndex == g_iModel_Gnome)
			)
			{
				//nothing
			}
			else
			{
				return;
			}
		}
		else if(g_smWeaponDeleteTime.ContainsKey(sClassName))
		{
			if(strcmp(sClassName, CLASSNAME_WEAPON_GASCAN, false) == 0 && IsScavengeGascan(entity)) return;
		}
		else
		{
			return;
		}

		delete g_ItemDeleteTimer[entity];

		DataPack hPack;
		g_ItemDeleteTimer[entity] = CreateDataTimer(fSetTime, Timer_KillWeapon, hPack);
		hPack.WriteCell(entity);
		hPack.WriteCell(EntIndexToEntRef(entity));
	}
	else
	{
		float fTime = 0.0;
		if( strncmp(sClassName, "prop_physics", 12, false) == 0 || strncmp(sClassName, "physics_prop", 12, false) == 0)
		{
			int modelIndex = GetEntProp(entity, Prop_Send, "m_nModelIndex");
			//LogError("modelIndex - %d", modelIndex);
			if(modelIndex == g_iModel_Gascan && IsScavengeGascan(entity)) return;

			if( (modelIndex == g_iModel_Gascan && g_smWeaponDeleteTime.GetValue(CLASSNAME_WEAPON_GASCAN, fTime)) ||
				(modelIndex == g_iModel_PropaneCanister && g_smWeaponDeleteTime.GetValue(CLASSNAME_WEAPON_OXYTANK, fTime)) || 
				(modelIndex == g_iModel_OxygenTank && g_smWeaponDeleteTime.GetValue(CLASSNAME_WEAPON_PROTANK, fTime)) || 
				(g_bL4D2Version && modelIndex == g_iModel_FireworksCrate && g_smWeaponDeleteTime.GetValue(CLASSNAME_WEAPON_FIREWORKCRATE, fTime)) ||
				(g_bL4D2Version && modelIndex == g_iModel_Gnome && g_smWeaponDeleteTime.GetValue(CLASSNAME_WEAPON_GNOME, fTime)) )
			{
				//nothing
			}
			else
			{
				return;
			}
		}
		else if(g_smWeaponDeleteTime.GetValue(sClassName, fTime))
		{
			if(strcmp(sClassName, CLASSNAME_WEAPON_GASCAN, false) == 0 && IsScavengeGascan(entity)) return;
		}
		else
		{
			return;
		}

		if(fTime <= 0.0) return;
		delete g_ItemDeleteTimer[entity];

		DataPack hPack;
		g_ItemDeleteTimer[entity] = CreateDataTimer(fTime, Timer_KillWeapon, hPack);
		hPack.WriteCell(entity);
		hPack.WriteCell(EntIndexToEntRef(entity));
	}
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

bool IsScavengeGascan(int entity)
{
	if(!g_bL4D2Version) return false;

	int skin = GetEntProp(entity, Prop_Send, "m_nSkin");

	return skin > 0;
}

bool IsInUse(int entity)
{	
	int client;
	//武器被裝備的時候才會有這個值
	if(HasEntProp(entity, Prop_Data, "m_hOwner"))
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hOwner"); 
		if (IsValidClient(client))
			return true;
	}
	
	/*
	//prop_physics物品從人類身上掉落或丟出去時這個值會變成1 (瓦斯桶, 氧氣罐, 煙火盒, 精靈小矮人)
	if(HasEntProp(entity, Prop_Data, "m_hOwnerEntity"))
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity"); 
		if (IsValidClient(client))
			return true;
	}*/

	for (int i = 1; i <= MaxClients; i++) 
	{
		if (IsValidClient(i) && GetActiveWeapon(i) == entity)
			return true;
	}

	return false;
}

int GetActiveWeapon(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (!IsValidEntityIndex(weapon)) 
	{
		return 0;
	}
	
	return weapon;
}

bool IsValidClient(int client) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) return false;      
    return true; 
}


void LoadData()
{
	delete g_smWeaponDeleteTime;
	g_smWeaponDeleteTime = new StringMap();

	delete g_smUnCommonDeleteTime;
	g_smUnCommonDeleteTime = new StringMap();

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), DATA_CONFIG);
	if( !FileExists(sPath) )
	{
		SetFailState("File Not Found: %s", sPath);
		return;
	}

	// Load config
	KeyValues hFile = new KeyValues(PLUGIN_NAME);
	if( !hFile.ImportFromFile(sPath) )
	{
		SetFailState("File Format Not Correct: %s", sPath);
		delete hFile;
		return;
	}

	char sMainKey[12];
	sMainKey = g_bL4D2Version ? "Left4Dead2" : "Left4Dead1";
	if(!hFile.JumpToKey(sMainKey))
	{
		SetFailState("keyvalue '%s' Not found: %s", sMainKey, sPath);
		delete hFile;
		return;
	}


	float fDeleteSeconds;
	if(hFile.JumpToKey("survivor"))
	{
		for(int i = 0; i < sizeof(g_sItemDeleteList); i++)
		{
			fDeleteSeconds = hFile.GetFloat(g_sItemDeleteList[i], 0.0);
			g_smWeaponDeleteTime.SetValue(g_sItemDeleteList[i], fDeleteSeconds);
		}

		hFile.GoBack();
	}
	else
	{
		SetFailState("keyvalue '%s' Not found: %s", "survivor", sPath);
		delete hFile;
		return;
	}

	if(g_bL4D2Version && hFile.JumpToKey("uncommon"))
	{
		for(int i = 0; i < sizeof(g_sItemDeleteList); i++)
		{
			fDeleteSeconds = hFile.GetFloat(g_sItemDeleteList[i], 0.0);
			g_smUnCommonDeleteTime.SetValue(g_sItemDeleteList[i], fDeleteSeconds);
		}

		hFile.GoBack();
	}
	else
	{
		SetFailState("keyvalue '%s' Not found: %s", "uncommon", sPath);
		delete hFile;
		return;
	}

	delete hFile;
}

// (二代) bot取代玩家時 -> 玩家觸發
// (二代) 玩家取代bot時 -> bot觸發
// 死前觸發 (L4D_OnDeathDroppedWeapons -> "weapon_drop" -> "player_death" pre -> "player_death" post )
// bot被踢出遊戲前觸發 (OnClientDisconnect() -> L4D_OnDeathDroppedWeapons -> "weapon_drop")
public void L4D_OnDeathDroppedWeapons(int client, int weapons[6])
{
	g_bDeathFrame[client] = true;
	g_iDeathWeapons[client][0] = weapons[0];
	g_iDeathWeapons[client][1] = weapons[1];
	g_iDeathWeapons[client][2] = weapons[2];
	g_iDeathWeapons[client][3] = weapons[3];
	g_iDeathWeapons[client][4] = weapons[4];
	g_iDeathWeapons[client][5] = weapons[5];
	RequestFrame(NextFrame_L4D_OnDeathDroppedWeapons, client);
}

void NextFrame_L4D_OnDeathDroppedWeapons(int client)
{
	g_bDeathFrame[client] = false;
}