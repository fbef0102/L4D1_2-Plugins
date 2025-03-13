#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define PLUGIN_VERSION			"3.2-2025-1-30"
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
	
	CreateNative("Timer_Delete_Weapon", Native_Timer_Delete_Weapon);
	bLate = late;
	return APLRes_Success; 
}

// native void Timer_Delete_Weapon(int weapon);
int Native_Timer_Delete_Weapon(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	SetTimer_DeleteWeapon(entity);

	return 0;
}

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
static int 		g_iModel_Tonfa;

#define CVAR_FLAGS			FCVAR_NOTIFY

ConVar g_hCvar_ClearSurvivorWeaponTime, g_hCvar_ClearInfectedWeaponTime,
	g_hCvar_ClearUpradeGroundPackTime, g_hCvar_ClearGnome, g_hCvar_ClearCola;

Handle g_ItemDeleteTimer[MAXENTITIES+1];
float g_fClearSurvivorWeaponTime, g_fClearInfectedWeaponTime;
float g_fUpradeGroundPack_Time;
bool g_bClearGnome, g_bClearCola;

static char ItemDeleteList[][] =
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
	CLASSNAME_WEAPON_OXYTANK
};

StringMap g_smItemDeleteList;

public void OnPluginStart()
{
	g_hCvar_ClearSurvivorWeaponTime = CreateConVar("sm_drop_clear_survivor_weapon_time", "60", "Time in seconds to remove weapon after dropped by survivor. (0=off)", CVAR_FLAGS, true, 0.0);
	if (g_bL4D2Version){
		g_hCvar_ClearInfectedWeaponTime = CreateConVar("sm_drop_clear_infected_weapon_time", "180", "Time in seconds to remove weapon after dropped by uncommon infected. (0=off)", CVAR_FLAGS, true, 0.0);
		g_hCvar_ClearUpradeGroundPackTime = CreateConVar("sm_drop_clear_ground_upgrade_pack_time", "60", "Time in seconds to remove upgrade pack after deployed on the ground. (0=off)", CVAR_FLAGS, true, 0.0);
		g_hCvar_ClearGnome = CreateConVar("sm_drop_clear_survivor_weapon_gnome", "0", "If 1, remove gnome after dropped by survivor.", CVAR_FLAGS, true, 0.0);
		g_hCvar_ClearCola = CreateConVar("sm_drop_clear_survivor_weapon_cola_bottles", "0", "If 1, remove cola bottles after dropped by survivor.", CVAR_FLAGS, true, 0.0);
	}
	
	GetCvars();
	g_hCvar_ClearSurvivorWeaponTime.AddChangeHook(ConVarChanged_Cvars);
	if(g_bL4D2Version)
	{
		g_hCvar_ClearInfectedWeaponTime.AddChangeHook(ConVarChanged_Cvars);
		g_hCvar_ClearUpradeGroundPackTime.AddChangeHook(ConVarChanged_Cvars);
		g_hCvar_ClearGnome.AddChangeHook(ConVarChanged_Cvars);
		g_hCvar_ClearCola.AddChangeHook(ConVarChanged_Cvars);
	}
	AutoExecConfig(true, "clear_weapon_drop");
	
	HookEvent("weapon_drop", Event_Weapon_Drop);
	
	if (g_bL4D2Version){
		HookEvent ("upgrade_pack_used",	Event_UpgradePack);
	}

	g_smItemDeleteList = CreateTrie();
	for(int i = 0; i < sizeof(ItemDeleteList); i++)
	{
		g_smItemDeleteList.SetValue(ItemDeleteList[i], true);
	}
	
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
	g_fClearSurvivorWeaponTime = g_hCvar_ClearSurvivorWeaponTime.FloatValue;
	if(g_bL4D2Version)
	{
		g_fClearInfectedWeaponTime = g_hCvar_ClearInfectedWeaponTime.FloatValue;
		g_fUpradeGroundPack_Time = g_hCvar_ClearUpradeGroundPackTime.FloatValue;
		g_bClearGnome = g_hCvar_ClearGnome.BoolValue;
		g_bClearCola = g_hCvar_ClearCola.BoolValue;
	}
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

		g_iModel_Tonfa = PrecacheModel(MODEL_TONFA, true);
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
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!g_bConfigLoaded)
		return;

	if (!IsValidEntityIndex(entity))
		return;

	//LogError("OnEntityCreated %d-%s", entity, classname);

	bool bTemp;
	if(g_bL4D2Version && g_fClearInfectedWeaponTime > 0.0)
	{
		switch (classname[0])
		{
			case 'w':
			{
				if ( (StrEqual(classname, "weapon_molotov") && g_smItemDeleteList.GetValue("weapon_molotov", bTemp)) ||
					(StrEqual(classname, "weapon_pipe_bomb") && g_smItemDeleteList.GetValue("weapon_pipe_bomb", bTemp)) ||
					(StrEqual(classname, "weapon_vomitjar") && g_smItemDeleteList.GetValue("weapon_vomitjar", bTemp)) ||
					(StrEqual(classname, "weapon_pain_pills") && g_smItemDeleteList.GetValue("weapon_pain_pills", bTemp)) ||
					(StrEqual(classname, "weapon_adrenaline") && g_smItemDeleteList.GetValue("weapon_adrenaline", bTemp)) ||
					(StrEqual(classname, "weapon_first_aid_kit") && g_smItemDeleteList.GetValue("weapon_first_aid_kit", bTemp)) ||
					(StrEqual(classname, "weapon_melee") && g_smItemDeleteList.GetValue("weapon_melee", bTemp)) )
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
			if ( strncmp(classname, "physics_prop", 12, false) == 0 || strncmp(classname, "prop_physics", 12, false) == 0) //從人類手上丟出去的汽油桶, 瓦斯桶, 氧氣罐, 煙火盒, 精靈小矮人，classname變成physics_prop
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

void Event_Weapon_Drop(Event event, const char[] name, bool dontBroadcast)
{
	if (g_fClearSurvivorWeaponTime == 0.0) return;
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!IsValidClient(client) || GetClientTeam(client) != 2) return;
		
	int entity = event.GetInt("propid");	
	SetTimer_DeleteWeapon(entity);
}

void Event_UpgradePack(Event event, const char[] name, bool dontBroadcast)
{
	if (g_fUpradeGroundPack_Time == 0.0) return;
	
	int entity = event.GetInt("upgradeid");
	if (!IsValidEntityIndex(entity)) return;

	if(Is_UpgradeGroundPack(entity))
	{	
		delete g_ItemDeleteTimer[entity];

		DataPack hPack;
		g_ItemDeleteTimer[entity] = CreateDataTimer(g_fUpradeGroundPack_Time, Timer_KillGroundPackEntity, hPack);
		hPack.WriteCell(entity);
		hPack.WriteCell(EntIndexToEntRef(entity));
	}
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
			delete g_ItemDeleteTimer[weapon];

			DataPack hPack;
			g_ItemDeleteTimer[weapon] = CreateDataTimer(g_fClearInfectedWeaponTime, Timer_KillWeapon, hPack);
			hPack.WriteCell(weapon);
			hPack.WriteCell(EntIndexToEntRef(weapon));
			return;
		}
	}

	int modelIndex = GetEntProp(weapon, Prop_Send, "m_nModelIndex");
	if(modelIndex == g_iModel_Tonfa) //警棍
	{
		delete g_ItemDeleteTimer[weapon];

		DataPack hPack;
		g_ItemDeleteTimer[weapon] = CreateDataTimer(g_fClearInfectedWeaponTime, Timer_KillWeapon, hPack);
		hPack.WriteCell(weapon);
		hPack.WriteCell(EntIndexToEntRef(weapon));
	}
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

	if (GetEntPropEnt(weapon, Prop_Data, "m_hOwnerEntity") <= 0) //prop_physics物品從人類身上掉落或丟出去時這個值會變成1 (汽油桶, 瓦斯桶, 氧氣罐, 煙火盒, 精靈小矮人)
		return;

	bool bTemp;
	int modelIndex = GetEntProp(weapon, Prop_Send, "m_nModelIndex");
	if( (modelIndex == g_iModel_Gascan && g_smItemDeleteList.GetValue(CLASSNAME_WEAPON_GASCAN, bTemp)) ||
		(modelIndex == g_iModel_PropaneCanister && g_smItemDeleteList.GetValue(CLASSNAME_WEAPON_OXYTANK, bTemp)) || 
		(modelIndex == g_iModel_OxygenTank && g_smItemDeleteList.GetValue(CLASSNAME_WEAPON_PROTANK, bTemp)) || 
		(g_bL4D2Version && modelIndex == g_iModel_FireworksCrate && g_smItemDeleteList.GetValue(CLASSNAME_WEAPON_FIREWORKCRATE, bTemp)) ||
		(g_bL4D2Version && modelIndex == g_iModel_Gnome && g_bClearGnome))
	{
		delete g_ItemDeleteTimer[weapon];

		DataPack hPack;
		g_ItemDeleteTimer[weapon] = CreateDataTimer(g_fClearSurvivorWeaponTime, Timer_KillWeapon, hPack);
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

void SetTimer_DeleteWeapon(int entity)
{
	if (!IsValidEntityIndex(entity) || !IsValidEntity(entity)) return;

	static char sClassName[64];
	bool bTemp;
	GetEntityClassname(entity, sClassName, sizeof(sClassName));
	//LogError("SetTimer_DeleteWeapon %d - %s",entity, sClassName);

	if( strncmp(sClassName, "prop_physics", 12, false) == 0 || strncmp(sClassName, "physics_prop", 12, false) == 0)
	{
		int modelIndex = GetEntProp(entity, Prop_Send, "m_nModelIndex");
		//LogError("modelIndex - %d", modelIndex);
		if( (modelIndex == g_iModel_Gascan && g_smItemDeleteList.GetValue(CLASSNAME_WEAPON_GASCAN, bTemp)) ||
			(modelIndex == g_iModel_PropaneCanister && g_smItemDeleteList.GetValue(CLASSNAME_WEAPON_OXYTANK, bTemp)) || 
			(modelIndex == g_iModel_OxygenTank && g_smItemDeleteList.GetValue(CLASSNAME_WEAPON_PROTANK, bTemp)) || 
			(g_bL4D2Version && modelIndex == g_iModel_FireworksCrate && g_smItemDeleteList.GetValue(CLASSNAME_WEAPON_FIREWORKCRATE, bTemp)) ||
			(g_bL4D2Version && modelIndex == g_iModel_Gnome && g_bClearGnome))
		{
			if(modelIndex == g_iModel_Gascan && IsScavengeGascan(entity)) return;

			delete g_ItemDeleteTimer[entity];

			DataPack hPack;
			g_ItemDeleteTimer[entity] = CreateDataTimer(g_fClearSurvivorWeaponTime, Timer_KillWeapon, hPack);
			hPack.WriteCell(entity);
			hPack.WriteCell(EntIndexToEntRef(entity));
		}
	}
	else if(g_smItemDeleteList.GetValue(sClassName, bTemp) == true)
	{
		if(strcmp(sClassName, CLASSNAME_WEAPON_GASCAN, false) == 0 && IsScavengeGascan(entity)) return;

		DataPack hPack;
		g_ItemDeleteTimer[entity] = CreateDataTimer(g_fClearSurvivorWeaponTime, Timer_KillWeapon, hPack);
		hPack.WriteCell(entity);
		hPack.WriteCell(EntIndexToEntRef(entity));
	}
	else if( (g_bClearGnome && strcmp(sClassName, CLASSNAME_WEAPON_GNOME) == 0) ||
		(g_bClearCola && strcmp(sClassName, CLASSNAME_WEAPON_COLA) == 0) )
	{
		DataPack hPack;
		g_ItemDeleteTimer[entity] = CreateDataTimer(g_fClearSurvivorWeaponTime, Timer_KillWeapon, hPack);
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
	if(HasEntProp(entity, Prop_Data, "m_hOwner"))
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hOwner"); //武器被裝備的時候才會有這個值
		if (IsValidClient(client))
			return true;
	}
	
	/*if(HasEntProp(entity, Prop_Data, "m_hOwnerEntity"))
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity"); //prop_physics物品從人類身上掉落或丟出去時這個值會變成1 (汽油桶, 瓦斯桶, 氧氣罐, 煙火盒, 精靈小矮人)
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

bool Is_UpgradeGroundPack(int entity)
{
	int modelIndex = GetEntProp(entity, Prop_Send, "m_nModelIndex");

	if( modelIndex == g_iModel_FireAmmo || modelIndex == g_iModel_ExplodeAmmo)
		return true;

	return false;
}