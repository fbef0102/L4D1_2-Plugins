#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

public Plugin myinfo =
{
	name = "[L4D1/2] Transition Forward",
	author = "BHaType, Harry",
	description = "Provides forward to determine transitioned entities between map",
	version = "1.0h-2026/1/27"
};

GlobalForward g_hTransition;
bool g_bL4D2Version;
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
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1/2.");
		return APLRes_SilentFailure;
	}

	g_hTransition = new GlobalForward ("OnEntityTransitioned", ET_Ignore, Param_Cell, Param_Cell);

	RegPluginLibrary("l4d_transition_forward");

	return APLRes_Success;
}

int m_nSkin;
public void OnPluginStart()
{
	m_nSkin = FindSendPropInfo("CBaseAnimating", "m_nSkin");
	
	//HookEvent("map_transition", map_transition, EventHookMode_PostNoCopy);
}

/*void map_transition (Event event, const char[] name, bool dontbroadcast)
{
	SaveWeapons();
}*/

/**
 * @brief Called whenever InfoChangelevel::SaveEntities() is invoked
 * @brief Called when a map has been finished, and is about to save the entities in the saferoom
 * @remarks Called before the event "map_transition"
 * @remarks Won't be called if Director::AreHumanZombiesAllowed() returns true, which refers to the versus gamemode, or this entity name is "info_solo_changelevel"
 * 
 * @param info_changelevel	The entity index of "info_changelevel"
 * @param Kv				A KeyValue pointer Address. Null_Address will be returned if the pointer is null
 * 
 * @return					Plugin_Handled to prevent saving entities, Plugin_Continue otherwise
*/
// L4D1 only
public Action L4D1_OnSavingEntities(int info_changelevel, Address Kv)
{
	SaveWeapons();

	return Plugin_Continue;
}

/**
 * @brief Called whenever InfoChangelevel::SaveEntities() is invoked
 * @brief Called when a map has been finished, and is about to save the entities in the saferoom (usually props or items brought into the saferoom.)
 * @remarks Called before the event "map_transition"
 * @remarks Won't be called if CTerrorGameRules::HasPlayerControlledZombies() returns true, which refers to the versus/scavenge related pvp gamemode
 * 
 * @param info_changelevel	The entity index of "info_changelevel"
 * 
 * @return					Plugin_Handled to prevent saving entities, Plugin_Continue otherwise
*/
// L4D2 only
public Action L4D2_OnSavingEntities(int info_changelevel)
{
	SaveWeapons();

	return Plugin_Continue;
}

public void OnEntityCreated (int entity, const char[] name)
{
	if ( entity <= MaxClients || !IsValidEntity(entity) )
		return;

	if (
		strncmp(name, "weapon_", 7, false) == 0
		)
	{
		SDKHook(entity, SDKHook_SpawnPost, OnEntitySpawnedSH);
	}
}

void OnEntitySpawnedSH (int entity) 
{ 
	RequestFrame(NextFrame, EntIndexToEntRef(entity)); 
}

void NextFrame (int entity)
{
	if ( (entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE )
		return;
		
	int skin = GetEntData(entity, m_nSkin);
	if (g_bL4D2Version && HasEntProp(entity, Prop_Data, "m_nWeaponSkin")) // _spawn 才有這個屬性
		skin = GetEntProp(entity, Prop_Data, "m_nWeaponSkin");
	
	if ( skin >> 16 <= 0 )
		return;
		
	Call_StartForward(g_hTransition);
	Call_PushCell(skin >> 16);
	Call_PushCell(entity);
	Call_Finish();
	
	SetEntData(entity, m_nSkin, skin & 0xFFFF); //0xFFFF = 1111 1111 1111 1111
	if (g_bL4D2Version && HasEntProp(entity, Prop_Data, "m_nWeaponSkin"))
		SetEntProp(entity, Prop_Data, "m_nWeaponSkin", skin & 0xFFFF);
}

void SaveWeapons()
{	
	int entity = MaxClients + 1;
	
	while ( (entity = FindEntityByClassname(entity, "weapon_*")) && IsValidEntity(entity) )
	{
		SetEntData(entity, m_nSkin, (entity << 16) | GetEntData(entity, m_nSkin));
		if (g_bL4D2Version && HasEntProp(entity, Prop_Data, "m_nWeaponSkin"))
			SetEntProp(entity, Prop_Data, "m_nWeaponSkin", (entity << 16) | GetEntProp(entity, Prop_Data, "m_nWeaponSkin"));
	}

	/**
	 * 以下這四個classname, 不會保存m_nskin, 需另尋他法
	 * upgrade_ammo_explosive
	 * upgrade_ammo_incendiary
	 * upgrade_laser_sight
	 * prop_physics (瓦斯桶, 氧氣灌, 煙火盒, 精靈小矮人)
	 * 
	 * 不會保存
	 * prop_minigun
	 * (L4D2) prop_minigun_l4d1
	 * (L4D1) prop_mounted_machine_gun
	 */
}