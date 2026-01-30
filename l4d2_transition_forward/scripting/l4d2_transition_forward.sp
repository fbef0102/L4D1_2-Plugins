#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

public Plugin myinfo =
{
	name = "[L4D2] Transition Forward",
	author = "BHaType, Harry",
	description = "Provides forward to determine player inventory transitioned entities between map",
	version = "1.1h-2026/1/30"
};

GlobalForward 
	g_fwdOnEntityTransitioning,
	g_fwdOnEntityTransitioned;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{	
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	g_fwdOnEntityTransitioning 	= new GlobalForward("L4D2_OnInventoryWeaponTransitioning", ET_Ignore, Param_Cell, Param_Cell);
	g_fwdOnEntityTransitioned 	= new GlobalForward("L4D2_OnInventoryWeaponTransitioned", ET_Ignore, Param_Cell, Param_Cell);

	RegPluginLibrary("l4d2_transition_forward");

	return APLRes_Success;
}

int 
	m_nSkin,
	g_iActiveWeapon[MAXPLAYERS+1];

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
 * Called before the event "map_transition"
*/
// L4D1 only
/*public Action L4D1_OnSavingEntities(int info_changelevel, Address Kv)
{
	// 一代覆蓋m_nskin沒效
	// 一代在安全室過關時會
	// 1.保存玩家的裝備
	// 2.地上的weapon_物品如武器, 藥丸, 治療包, 土製炸彈, 燃燒彈

	// 不會保存
	// 地上prop_物品如汽油桶 瓦斯 (除非拿在手上變成weapon_)
	// prop_minigun
	// prop_mounted_machine_gun
	SaveWeapons();

	return Plugin_Continue;
}*/

/**
 * Called before the event "map_transition"
*/
// L4D2 only
public void L4D2_OnSavingEntities_Post(int info_changelevel)
{
	// 二代不會保存
	// prop_minigun
	// prop_minigun_l4d1
	SaveWeapons();
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
	//if (HasEntProp(entity, Prop_Data, "m_nWeaponSkin")) // _spawn 才有這個屬性
	//	skin = GetEntProp(entity, Prop_Data, "m_nWeaponSkin");
	
	int oldindex = skin >> 16;
	if ( oldindex <= 0 )
		return;
		
	CallOnEntityTransitioned(entity, oldindex);
	
	SetEntData(entity, m_nSkin, skin & 0xFFFF); //0xFFFF = 1111 1111 1111 1111
	//if (HasEntProp(entity, Prop_Data, "m_nWeaponSkin"))
	//	SetEntProp(entity, Prop_Data, "m_nWeaponSkin", skin & 0xFFFF);
}

void SaveWeapons()
{	
	for (int i = 1; i <= MaxClients; i++) 
	{
		g_iActiveWeapon[i] = -1;
		if (!IsClientInGame(i)) continue;

		if (!IsPlayerAlive(i)) continue;

		if (GetClientTeam(i) != L4D_TEAM_SURVIVOR) continue;

		g_iActiveWeapon[i] = GetEntPropEnt(i, Prop_Data, "m_hActiveWeapon");
	}

	int entity = MaxClients + 1, player;
	
	while ( (entity = FindEntityByClassname(entity, "weapon_*")) && IsValidEntity(entity) )
	{
		player = InUseClient(entity);
		if(player > 0)
		{
			SetEntData(entity, m_nSkin, (entity << 16) | GetEntData(entity, m_nSkin));
			//if (g_bL4D2 && HasEntProp(entity, Prop_Data, "m_nWeaponSkin")) // _spawn 才有這個屬性
			//	skin = GetEntProp(entity, Prop_Data, "m_nWeaponSkin");

			CallOnEntityTransitioning(player, entity);
		}
	}
}

void CallOnEntityTransitioning(int player, int entity)
{
	if (g_fwdOnEntityTransitioning.FunctionCount == 0)
		return;
	
	Call_StartForward(g_fwdOnEntityTransitioning);
	Call_PushCell(player);
	Call_PushCell(entity);
	Call_Finish();
}

void CallOnEntityTransitioned(int entity, int oldindex)
{
	if (g_fwdOnEntityTransitioned.FunctionCount == 0)
		return;
	
	Call_StartForward(g_fwdOnEntityTransitioned);
	Call_PushCell(entity);
	Call_PushCell(oldindex);
	Call_Finish();
}

int InUseClient(int entity)
{	
	int client = 0;
	//武器被裝備的時候才會有這個值
	if(HasEntProp(entity, Prop_Data, "m_hOwner"))
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hOwner"); 
		if (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_SURVIVOR && IsPlayerAlive(client))
			return client;
	}

	for (int i = 1; i <= MaxClients; i++) 
	{
		if (g_iActiveWeapon[i] == entity)
			return i;
	}

	return client;
}