#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>

#define DEBUG		   0
#define PLUGIN_VERSION "1.2-2024/12/30"
#define GAMEDATA	   "fix_maptank.games"

bool			 g_bTankFix;
ArrayList 		 g_aEntList;
ConVar			 g_Onoff;

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
static char sSpawnCommand[32];
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead2 )
	{
		ZOMBIECLASS_TANK = 8;
		sSpawnCommand = "z_spawn_old";
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
	if (g_bTankFix == false || FindValueInList(pThis)) return MRES_Ignored;
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
		//PushValueInList(pThis);
		//ReleaseSlotFromSpecial(pThis);
		CreateTimer(0.1, CheckIfSpawnSucess, EntIndexToEntRef(pThis));
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
			//PushValueInList(pThis);
			//ReleaseSlotFromSpecial(pThis);
			CreateTimer(0.1, CheckIfSpawnSucess, EntIndexToEntRef(pThis));
		}
	}
	return MRES_Ignored;
}

// tank重生期间禁止新特感刷新
MRESReturn SpecialSpawnDetour(DHookReturn hReturn, DHookParam hParams)
{
	if (g_bTankFix == false || IsListNull()) return MRES_Ignored;
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

Action CheckIfSpawnSucess(Handle timer, int iEnt)
{
	iEnt = EntRefToEntIndex(iEnt);
	if(iEnt == INVALID_ENT_REFERENCE) return Plugin_Continue;

	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) == 3 && IsPlayerAlive(client))
		{
			int class = GetEntProp(client, Prop_Send, "m_zombieClass");
			if (class == ZOMBIECLASS_TANK)
			{
				float vPos[3], cPos[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", vPos);
				GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", cPos);
				if (GetVectorDistance(vPos, cPos, true) <= 100.0 * 100.0)
				{
					CreateTimer(0.1, LaterRemoveArray, iEnt);
					return Plugin_Continue;
				}
			}
		}
	}

	PushValueInList(iEnt);
	ReleaseSlotFromSpecial(iEnt);
	CreateTimer(0.1, LaterSpawnTank, EntIndexToEntRef(iEnt));
	return Plugin_Continue;
}

// 刷克
Action LaterSpawnTank(Handle timer, int iEnt)
{
	iEnt = EntRefToEntIndex(iEnt);
	if(iEnt == INVALID_ENT_REFERENCE) return Plugin_Continue;

	char class[56];
	GetEntityClassname(iEnt, class, sizeof(class));
	if (StrEqual(class, "info_zombie_spawn"))
	{
		AcceptEntityInput(iEnt, "SpawnZombie");
	}
	else
	{
		SetVariantString("tank");
		AcceptEntityInput(iEnt, "SpawnZombie");
	}
	#if DEBUG
		LogMessage("ResPawn Sucess");
	#endif

	CreateTimer(0.1, CheckIfSpawnSucess, EntIndexToEntRef(iEnt));
	return Plugin_Continue;
}

// 解除刷特封锁
Action LaterRemoveArray(Handle timer, int iEnt)
{
#if DEBUG
	LogMessage("Plugins Process End");
#endif
	RemoveValueFromList(iEnt);
	return Plugin_Continue;
}

// 腾出槽位
void ReleaseSlotFromSpecial(int iEnt)
{
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
				return;
			}
		}
	}

	// 隨機找到一個死亡的真人特感玩家，將他變成Tank

	float cPos[3];
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", cPos);
	bool bHasSlot = false;
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && GetClientTeam(client) == 3 && !IsFakeClient(client))
		{
			if (!IsPlayerAlive(client))
			{
				CheatCommand(client, sSpawnCommand, "Tank", "auto");

				for(int i = 1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && GetClientTeam(i) == 3 && !IsFakeClient(i)
						&& IsPlayerAlive(i) && GetEntProp(i, Prop_Send, "m_zombieClass") == ZOMBIECLASS_TANK)
					{
						TeleportEntity(i, cPos);
						bHasSlot = true;
						break;
					}
				}

				break;
			}
		}
	}

	if(bHasSlot) return;

	// 隨機踢走一個沒有控人的活著AI特感 (spitter與tank除外)
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidSpecialsBot(client))
		{
			int class = GetEntProp(client, Prop_Send, "m_zombieClass");
			if (class < ZOMBIECLASS_TANK && L4D_GetPinnedSurvivor(client) <= 0)
			{
				KickClient(client);
				return;
			}
		}
	}

	// 隨機踢走一個AI特感，無論死活 (tank除外)
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidSpecialsBot(client))
		{
			int class = GetEntProp(client, Prop_Send, "m_zombieClass");
			if (class < ZOMBIECLASS_TANK)
			{
				KickClient(client);
				return;
			}
		}
	}
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

bool FindValueInList(int value)
{
	return g_aEntList.FindValue(value) >= 0;
}

bool IsListNull()
{
	return g_aEntList.Length == 0;
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

int L4D_GetPinnedSurvivor(int client)
{
	int class = GetEntProp(client, Prop_Send, "m_zombieClass");
	int victim;

	switch( class )
	{
		case 1:		victim = GetEntPropEnt(client, Prop_Send, "m_tongueVictim");
		case 3:		victim = GetEntPropEnt(client, Prop_Send, "m_pounceVictim");
		case 5:		victim = GetEntPropEnt(client, Prop_Send, "m_jockeyVictim");
		case 6:
		{
			victim = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
			if( victim < 1 ) victim = GetEntPropEnt(client, Prop_Send, "m_carryVictim");
		}
	}

	if( victim > 0 )
		return victim;

	return 0;
}

void CheatCommand(int client, const char[] command, const char[] arguments = "", const char[] param2 = "")
{
	if(client == 0) return;

	int userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s", command, arguments, param2);
	SetCommandFlags(command, flags);
	if(IsClientInGame(client)) SetUserFlagBits(client, userFlags);
}