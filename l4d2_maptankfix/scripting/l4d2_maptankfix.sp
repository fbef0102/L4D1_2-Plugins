#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>
#include <left4dhooks>

#define DEBUG		   0
#define PLUGIN_VERSION "1.2-2024/12/30"
#define GAMEDATA	   "fix_maptank.games"

bool			 g_bTankFix;
ArrayList 		 g_aEntList;
ConVar			 g_Onoff;
bool	g_bBlockHook = true;
 

DynamicHook	g_hdAcceptInput;
DHookSetup	g_hSpecialSpawn;

public Plugin myinfo =
{
	name		= "[L4D2] 地图机关tank生成修复",
	author		= "洛琪, Harry",
	description = "防止地图自带的机关tank(commentary_zombie_spawner, info_zombie_spawn)因为槽位问题无法刷新而造成的机关卡关(如伦理机关克等)[绝境]",
	version		= PLUGIN_VERSION,
	url			= "https://steamcommunity.com/profiles/76561198812009299/"
};

int ZOMBIECLASS_TANK;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead2 )
	{
		ZOMBIECLASS_TANK = 8;
	}
	else
	{
		strcopy(error, err_max, "Only Support Left 4 Dead 2");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

public void OnPluginStart()
{
	g_aEntList = new ArrayList();

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/%s.txt", GAMEDATA);
	if (FileExists(sPath) == false) SetFailState("\n==========\nMissing required file: \"%s\".==========", sPath);

	GameData hGameData = new GameData(GAMEDATA);
	if (hGameData == null) SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);

	int offset = GameConfGetOffset(hGameData, "AcceptInput");
	if (offset == 0) SetFailState("Failed to load \"AcceptInput\", invalid offset.");

	g_hSpecialSpawn = DHookCreateFromConf(hGameData, "L4DD::ZombieManager::SpawnSpecial");
	if (!g_hSpecialSpawn) SetFailState("Failed to find \"L4DD::ZombieManager::SpawnSpecial\" offset.");
	if (!DHookEnableDetour(g_hSpecialSpawn, false, SpecialSpawnDetour)) SetFailState("Failed to detour \"L4DD::ZombieManager::SpawnSpecial\".");
	delete g_hSpecialSpawn;

	delete hGameData;
	g_hdAcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, AcceptInput);
	DHookAddParam(g_hdAcceptInput, HookParamType_CharPtr);
	DHookAddParam(g_hdAcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_hdAcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_hdAcceptInput, HookParamType_Object, 20, DHookPass_ByVal | DHookPass_ODTOR | DHookPass_OCTOR | DHookPass_OASSIGNOP);
	DHookAddParam(g_hdAcceptInput, HookParamType_Int);

	g_Onoff = CreateConVar("l4d2_tank_fix", "1", "是否开启tank修复. 1=开启，0=关闭.", FCVAR_NOTIFY);
	IsTankFix();
	g_Onoff.AddChangeHook(ConVarChanged);

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	// AutoExecConfig(true, "l4d2_maptankfix"); 生成cfg?
}

void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	IsTankFix();
}

void IsTankFix()
{
	g_bTankFix = g_Onoff.BoolValue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntityIndex(entity) || !g_bTankFix)
		return;

	switch (classname[0])
	{
		case 'c':
		{
			if (StrEqual(classname, "commentary_zombie_spawner"))
			{
				RequestFrame(NextFrame_commentary_zombie_spawner, EntIndexToEntRef(entity));
			}
		}
		case 'i':
		{
			if (StrEqual(classname, "info_zombie_spawn"))
			{
				RequestFrame(NextFrame_info_zombie_spawn, EntIndexToEntRef(entity));
			}
		}
	}
}

void NextFrame_commentary_zombie_spawner(int entity)
{
	entity = EntRefToEntIndex(entity);
	if(entity == INVALID_ENT_REFERENCE) return;

	DHookEntity(g_hdAcceptInput, false, entity);
}

void NextFrame_info_zombie_spawn(int entity)
{
	entity = EntRefToEntIndex(entity);
	if(entity == INVALID_ENT_REFERENCE) return;

	static char propName[50];
	GetEntPropString(entity, Prop_Data, "m_szPopulation", propName, sizeof(propName));
	if (StrEqual(propName, "tank", false) || StrEqual(propName, "river_docks_trap", false) || StrEqual(propName, "church", false))
	{
		#if DEBUG
			LogMessage("info_zombie_spawn Detour");
		#endif
		DHookEntity(g_hdAcceptInput, false, entity);
	}
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	delete g_aEntList;
	g_aEntList = new ArrayList();
}

// 如果输入符合
MRESReturn AcceptInput(int pThis, DHookReturn hReturn, DHookParam hParams)
{
#if DEBUG
	LogMessage("Detour Get Input");
#endif
	if (g_bTankFix == false || g_bBlockHook) return MRES_Ignored;
	//if (GetClientCount(false) < MaxClients) return MRES_Ignored;

#if DEBUG
	LogMessage("Detour Entity Input");
#endif

	char szEntityName[64];
	GetEntityClassname(pThis, szEntityName, sizeof(szEntityName));
	if (StrEqual(szEntityName, "info_zombie_spawn"))
	{
#if DEBUG
		LogMessage("Detour info_zombie_spawn Respawn");
#endif
		
		DataPack hPack;
		CreateTimer(0.1, CheckIfSpawnSucess, hPack);
		hPack.WriteCell(pThis);
		hPack.WriteCell(EntIndexToEntRef(pThis));
	}

	if (StrEqual(szEntityName, "commentary_zombie_spawner"))
	{
		char result[50];
		DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, result, sizeof(result));
		if (StrEqual(result, "tank", false) || StrEqual(result, "river_docks_trap", false) || StrEqual(result, "church", false))
		{
#if DEBUG
			LogMessage("Detour commentary_zombie_spawner Respawn");
#endif
			DataPack hPack;
			CreateTimer(0.1, CheckIfSpawnSucess, hPack);
			hPack.WriteCell(pThis);
			hPack.WriteCell(EntIndexToEntRef(pThis));
		}
	}
	return MRES_Ignored;
}

// tank重生期间禁止新特感刷新
MRESReturn SpecialSpawnDetour(DHookReturn hReturn, DHookParam hParams)
{
	if (g_bTankFix == false || IsListNull() || g_bBlockHook) return MRES_Ignored;
	int var1;
	var1 = DHookGetParam(hParams, 1);
	if (var1 != ZOMBIECLASS_TANK)
	{
#if DEBUG
		LogMessage("Prevent Special Spawn");
#endif
		hReturn.Value = -1;
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

Action CheckIfSpawnSucess(Handle timer, DataPack hPack)
{
	hPack.Reset();
	int iIndex = hPack.ReadCell();
	int iEnt = EntRefToEntIndex(hPack.ReadCell());

	if(iEnt == INVALID_ENT_REFERENCE)
	{
		RemoveValueFromList(iIndex);
		return Plugin_Continue;
	}

	int client = GetTankInGame();
	if(client > 0)
	{
		float vPos[3], cPos[3];
		GetEntPropVector(client, Prop_Send, "m_vecAbsOrigin", vPos);
		GetEntPropVector(iEnt, Prop_Send, "m_vecAbsOrigin", cPos);
		if (GetVectorDistance(vPos, cPos, true) <= 100.0 * 100.0)
		{
			RemoveValueFromList(iEnt);
			return Plugin_Continue;
		}
	}

	if(GiveHumanSpecialTank(iEnt) == true)
	{
		return Plugin_Continue;
	}

	PushValueInList(iEnt);
	TryReleaseSlotFromSpecial();

	DataPack hPack2;
	CreateDataTimer(0.1, LaterSpawnTank, hPack2);
	hPack2.WriteCell(iEnt);
	hPack2.WriteCell(EntIndexToEntRef(iEnt));

	return Plugin_Continue;
}

bool GiveHumanSpecialTank(int iEnt)
{
	// 隨機找到一個死亡的真人特感玩家，將他變成Tank
	float cPos[3];
	GetEntPropVector(iEnt, Prop_Send, "m_vecAbsOrigin", cPos);

	int iClientCount, iClients[MAXPLAYERS+1];
	for (int human = 1; human <= MaxClients; human++)
	{
		if (IsClientInGame(human) && GetClientTeam(human) == 3 && !IsFakeClient(human))
		{
			if (!IsPlayerAlive(human))
			{
				iClients[iClientCount++] = human;
			}
		}
	}

	if(iClientCount > 0)
	{
		int human = iClients[GetRandomInt(0, iClientCount - 1)];
		L4D_State_Transition(human, STATE_OBSERVER_MODE);
		L4D_BecomeGhost(human);
		L4D_SetClass(human, ZOMBIECLASS_TANK);
		TeleportEntity(human, cPos, NULL_VECTOR, NULL_VECTOR);	
		L4D_MaterializeFromGhost(human);
		if(IsPlayerAlive(human))
		{
			return true;
		}
	}

	return false;
}

// 腾出槽位
void TryReleaseSlotFromSpecial()
{
	bool g_bHasSlot = false;
	//PrintToChatAll("Start Release Slot From Special");

	// 隨機踢走一個死亡的AI特感 (spitter除外)
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidSpecialsBot(client))
		{
			int class = GetEntProp(client, Prop_Send, "m_zombieClass");
			if (class != 4 && !IsPlayerAlive(client))
			{
				KickClient(client);
				g_bHasSlot = true;
				break;
			}
		}
	}

	// 隨機踢走一個沒有控人的活著AI特感 (spitter與tank除外)
	if(g_bHasSlot == false)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsValidSpecialsBot(client))
			{
				int class = GetEntProp(client, Prop_Send, "m_zombieClass");
				if (class < ZOMBIECLASS_TANK && L4D_GetPinnedSurvivor(client) <= 0)
				{
					KickClient(client);
					g_bHasSlot = true;
					break;
				}
			}
		}
	}

	// 隨機踢走一個AI特感，無論死活 (tank除外)
	if(g_bHasSlot == false)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsValidSpecialsBot(client))
			{
				int class = GetEntProp(client, Prop_Send, "m_zombieClass");
				if (class < ZOMBIECLASS_TANK)
				{
					KickClient(client);
					g_bHasSlot = true;
					break;
				}
			}
		}
	}
}

// 刷克
Action LaterSpawnTank(Handle timer, DataPack hPack)
{
	hPack.Reset();
	int iIndex = hPack.ReadCell();
	int iEnt = EntRefToEntIndex(hPack.ReadCell());

	if(iEnt == INVALID_ENT_REFERENCE)
	{
		RemoveValueFromList(iIndex);
		return Plugin_Continue;
	}

	g_bBlockHook = true;

	char class[56];
	GetEntityClassname(iEnt, class, sizeof(class));
	if (StrEqual(class, "info_zombie_spawn"))
	{
		AcceptEntityInput(iEnt, "SpawnZombie");
	}
	else // if (StrEqual(class, "commentary_zombie_spawner"))
	{
		SetVariantString("tank");
		AcceptEntityInput(iEnt, "SpawnZombie");
	}
	#if DEBUG
		LogMessage("ResPawn Sucess");
	#endif

	DataPack hPack2;
	CreateTimer(0.1, CheckIfSpawnSucess, hPack2);
	hPack2.WriteCell(iEnt);
	hPack2.WriteCell(EntIndexToEntRef(iEnt));

	g_bBlockHook = false;
	return Plugin_Continue;
}

// 以下函数为一些内部使用函数
bool IsValidSpecialsBot(int client)
{
	return IsClientInGame(client) && GetClientTeam(client) == 3 && IsFakeClient(client);
}

void PushValueInList(int value)
{
	int index = g_aEntList.FindValue(value);
	if(index < 0) g_aEntList.Push(value);
}

void RemoveValueFromList(int value)
{
	int index = g_aEntList.FindValue(value);
	if(index >= 0) g_aEntList.Erase(index);
}

bool IsListNull()
{
	return g_aEntList.Length == 0;
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

int GetTankInGame()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) == 3 && IsPlayerAlive(client))
		{
			int class = GetEntProp(client, Prop_Send, "m_zombieClass");
			if (class == ZOMBIECLASS_TANK)
			{
				return client;
			}
		}
	}

	return 0;
}