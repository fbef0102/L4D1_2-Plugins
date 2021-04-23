#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>

#define CLASSNAME_WEAPON_GNOME        "weapon_gnome"
#define CLASSNAME_WEAPON_COLA         "weapon_cola_bottles"
#define CVAR_FLAGS			FCVAR_NOTIFY

ConVar g_hCvar_ClearWeaponTime, g_hCvar_ClearUpradeGroundPackTime, g_hCvar_ClearGnome, g_hCvar_ClearCola;

Handle g_ItemDeleteTimer[2048];
int g_iClearWeaponTime, g_iUpradeGroundPack_Time;
bool g_bL4D2Version, g_bClearGnome, g_bClearCola;

static char upgradegroundpack[][] =
{
	"models/props/terror/incendiary_ammo.mdl",
	"models/props/terror/exploding_ammo.mdl"
};

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
	//"weapon_gascan",
	"weapon_fireworkcrate",
	"weapon_propanetank",
	"weapon_oxygentank"
};

public Plugin myinfo = 
{
	name = "Remove drop weapon + remove upgradepack when used",
	author = "AK978 & HarryPotter",
	version = "2.5"
}

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
	return APLRes_Success; 
}

public int Native_Timer_Delete_Weapon(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	SetTimer_DeleteWeapon(entity);
	return;
}

public void OnPluginStart()
{
	g_hCvar_ClearWeaponTime = CreateConVar("sm_drop_clear_weapon_time", "60", "Time in seconds  to remove weapon after drops. (0=off)", CVAR_FLAGS, true, 0.0);
	if (g_bL4D2Version){
		g_hCvar_ClearUpradeGroundPackTime = CreateConVar("sm_drop_clear_ground_upgrade_pack_time", "60", "Time in seconds to remove upgradepack on the ground after used. (0=off)", CVAR_FLAGS, true, 0.0);
		g_hCvar_ClearGnome = CreateConVar("sm_drop_clear_weapon_gnome", "0", "If 1, remove gnome after drops.", CVAR_FLAGS, true, 0.0);
		g_hCvar_ClearCola = CreateConVar("sm_drop_clear_weapon_cola_bottles", "0", "If 1, remove cola bottles after drops.", CVAR_FLAGS, true, 0.0);
	}
	
	GetCvars();
	g_hCvar_ClearWeaponTime.AddChangeHook(ConVarChanged_Cvars);
	if(g_bL4D2Version)
	{
		g_hCvar_ClearUpradeGroundPackTime.AddChangeHook(ConVarChanged_Cvars);
		g_hCvar_ClearGnome.AddChangeHook(ConVarChanged_Cvars);
		g_hCvar_ClearCola.AddChangeHook(ConVarChanged_Cvars);
	}
	
	HookEvent("weapon_drop", Event_Weapon_Drop);
	HookEvent("round_end", Event_Round_End);
	HookEvent("map_transition", Event_Round_End); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", Event_Round_End); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_Round_End); //救援載具離開之時  (沒有觸發round_end)

	if (g_bL4D2Version){
		HookEvent ("upgrade_pack_used",	Event_UpgradePack);
	}
	
	AutoExecConfig(true, "clear_weapon_drop");
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iClearWeaponTime = g_hCvar_ClearWeaponTime.IntValue;
	if(g_bL4D2Version)
	{
		g_iUpradeGroundPack_Time = g_hCvar_ClearUpradeGroundPackTime.IntValue;
		g_bClearGnome = g_hCvar_ClearGnome.BoolValue;
		g_bClearCola = g_hCvar_ClearCola.BoolValue;
	}
}

public void OnMapEnd()
{
	ResetTimer();
}

public void OnPluginEnd()
{
	ResetTimer();
}

bool g_bConfigLoaded = false;
public void OnConfigsExecuted()
{
    g_bConfigLoaded = true;
}

public Action Event_Round_End(Event event, const char[] name, bool dontBroadcast)
{
	ResetTimer();
}

public void OnEntityDestroyed(int entity)
{
	if (!g_bConfigLoaded)
		return;
		
	if (!IsValidEntityIndex(entity))
		return;

	delete g_ItemDeleteTimer[entity];
}

public Action Event_Weapon_Drop(Event event, const char[] name, bool dontBroadcast)
{
	if (g_iClearWeaponTime == 0) return;
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!IsValidClient(client) || !IsPlayerAlive(client)) return;
		
	int entity = event.GetInt("propid");	
	SetTimer_DeleteWeapon(entity);
}

public void Event_UpgradePack(Event event, const char[] name, bool dontBroadcast)
{
	if (g_iUpradeGroundPack_Time == 0) return;
	
	int entity = event.GetInt("upgradeid");
	if (!IsValidEntityIndex(entity)) return;

	if(Is_UpgradeGroundPack(entity, upgradegroundpack, sizeof(upgradegroundpack)))
	{	
		delete g_ItemDeleteTimer[entity];
		g_ItemDeleteTimer[entity] = CreateTimer(float(g_iUpradeGroundPack_Time), Timer_KillGroundPackEntity, EntIndexToEntRef(entity));
	}
}

public Action Timer_KillWeapon(Handle timer, int entRef)
{
	int entity;
	if(entRef && (entity = EntRefToEntIndex(entRef)) != INVALID_ENT_REFERENCE)
	{
		g_ItemDeleteTimer[entity] = null;
		if(IsValidEntityIndex(entity) && IsInUse(entity) == false )
		{
			RemoveEntity(entity);
		}
	}
}

public Action Timer_KillGroundPackEntity(Handle timer, int ref)
{
	int entity;
	if(ref && (entity = EntRefToEntIndex(ref)) != INVALID_ENT_REFERENCE)
	{
		SetEntityRenderFx(ref, RENDERFX_FADE_FAST); //RENDERFX_FADE_SLOW 3.5
		CreateTimer(1.5, KillEntity, ref, TIMER_FLAG_NO_MAPCHANGE);
		g_ItemDeleteTimer[entity] = null;
	}
}

public Action KillEntity(Handle timer, int ref)
{
	if(ref && EntRefToEntIndex(ref) != INVALID_ENT_REFERENCE)
	{
		RemoveEntity(ref);
	}
}

bool IsInUse(int entity)
{	
	int client;
	if(HasEntProp(entity, Prop_Data, "m_hOwner"))
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hOwner");
		if (IsValidClient(client))
			return true;
	}
	
	if(HasEntProp(entity, Prop_Data, "m_hOwnerEntity"))
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		if (IsValidClient(client))
			return true;
	}

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
		return false;
	}
	
	return weapon;
}

bool IsValidClient(int client) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) return false;      
    return true; 
}

bool Is_UpgradeGroundPack(int entity, char [][] array, int size)
{
	char sModelName[256];
	GetEntPropString(entity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));

	for (int i = 0; i < size; i++)
	{
		if (StrEqual(sModelName, array[i]))
		{
			return true;
		}
	}

	return false;
}

void SetTimer_DeleteWeapon(int entity)
{
	if (!IsValidEntityIndex(entity)) return;

	char item[32];
	GetEdictClassname(entity, item, sizeof(item));
	//PrintToChatAll("%d - %s",entity,item);

	if( strcmp(item,"prop_physics") == 0 )
	{
		static char m_ModelName[PLATFORM_MAX_PATH];
		GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
		//PrintToChatAll("m_ModelName - %s", m_ModelName);
		if(strcmp(m_ModelName,"models/props_equipment/oxygentank01.mdl") == 0 ||
			strcmp(m_ModelName,"models/props_junk/explosive_box001.mdl") == 0 ||
			strcmp(m_ModelName,"models/props_junk/propanecanister001a.mdl") == 0 )
		{
			delete g_ItemDeleteTimer[entity];
			g_ItemDeleteTimer[entity] = CreateTimer(float(g_iClearWeaponTime), Timer_KillWeapon, EntIndexToEntRef(entity));
			return;
		}

	}

	for(int j=0; j < sizeof(ItemDeleteList); j++)
	{
		if (StrContains(item, ItemDeleteList[j], false) != -1)
		{
			delete g_ItemDeleteTimer[entity];
			g_ItemDeleteTimer[entity] = CreateTimer(float(g_iClearWeaponTime), Timer_KillWeapon, EntIndexToEntRef(entity));
			return;
		}
	}
	
	if( (g_bClearGnome && strcmp(item, CLASSNAME_WEAPON_GNOME) == 0) ||
		(g_bClearCola && strcmp(item, CLASSNAME_WEAPON_COLA) == 0) )
	{
		delete g_ItemDeleteTimer[entity];
		g_ItemDeleteTimer[entity] = CreateTimer(float(g_iClearWeaponTime), Timer_KillWeapon, EntIndexToEntRef(entity));
	}
}

void ResetTimer()
{
	for (int entity = 1; entity < 2048; entity++)
	{
		delete g_ItemDeleteTimer[entity];
	}
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}