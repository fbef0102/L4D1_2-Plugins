#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>
#include <left4dhooks>
#include <spawn_infected_nolimit> //https://github.com/fbef0102/L4D1_2-Plugins/tree/master/spawn_infected_nolimit

#define DEBUG		   0
#define PLUGIN_VERSION "1.5-2025/2/13"
#define GAMEDATA	   "l4d2_maptankfix"

public Plugin myinfo =
{
	name		= "[L4D1/2] 地图机关tank生成修复",
	author		= "洛琪, Harry",
	description = "防止地图自带的机关tank(commentary_zombie_spawner, info_zombie_spawn)因为槽位问题无法刷新而造成的机关卡关(如伦理机关克等)[绝境]",
	version		= PLUGIN_VERSION,
	url			= "https://steamcommunity.com/profiles/76561198812009299/"
};

int ZOMBIECLASS_TANK;
bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead )
	{
		g_bL4D2Version = false;
		ZOMBIECLASS_TANK = 5;
	}
	else if( test == Engine_Left4Dead2 )
	{
		g_bL4D2Version = true;
		ZOMBIECLASS_TANK = 8;
	}
	else
	{
		strcopy(error, err_max, "Only Support Left 4 Dead 2");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MAXENTITIES                   2048

ConVar			 g_Onoff;
bool			 g_bTankFix;

ArrayList 		
	g_aEntList;

enum ESpawnType
{
	eNone,
	einfo_zombie_spawn,
	ecommentary_zombie_spawner,
	eMax
}

ESpawnType
	g_eTankSpawnType;

bool	
	g_bBlockHook,
	g_bDuplicate[MAXENTITIES+1];

int 
	g_iCurrentEntRef,
	g_iTankToCommentaryZombieSpawnerRef[MAXPLAYERS+1];
 
float
	g_fProtectTime[MAXPLAYERS+1];

DynamicHook	
	g_hdAcceptInput_Pre, g_hdAcceptInput_Post;

//DHookSetup	
//	g_hSpecialSpawn;

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

	/*if(g_bL4D2Version)
	{
		g_hSpecialSpawn = DHookCreateFromConf(hGameData, "L4DD::ZombieManager::SpawnSpecial");
		if (!g_hSpecialSpawn) SetFailState("Failed to find \"L4DD::ZombieManager::SpawnSpecial\" offset.");
		if (!DHookEnableDetour(g_hSpecialSpawn, false, SpecialSpawnDetour)) SetFailState("Failed to detour \"L4DD::ZombieManager::SpawnSpecial\".");
		delete g_hSpecialSpawn;
	}*/

	delete hGameData;
	g_hdAcceptInput_Pre = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, DHook_AcceptInput_Pre);
	DHookAddParam(g_hdAcceptInput_Pre, HookParamType_CharPtr);
	DHookAddParam(g_hdAcceptInput_Pre, HookParamType_CBaseEntity);
	DHookAddParam(g_hdAcceptInput_Pre, HookParamType_CBaseEntity);
	DHookAddParam(g_hdAcceptInput_Pre, HookParamType_Object, 20, DHookPass_ByVal | DHookPass_ODTOR | DHookPass_OCTOR | DHookPass_OASSIGNOP);
	DHookAddParam(g_hdAcceptInput_Pre, HookParamType_Int);

	g_hdAcceptInput_Post = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, DHook_AcceptInput_Post);
	DHookAddParam(g_hdAcceptInput_Post, HookParamType_CharPtr);
	DHookAddParam(g_hdAcceptInput_Post, HookParamType_CBaseEntity);
	DHookAddParam(g_hdAcceptInput_Post, HookParamType_CBaseEntity);
	DHookAddParam(g_hdAcceptInput_Post, HookParamType_Object, 20, DHookPass_ByVal | DHookPass_ODTOR | DHookPass_OCTOR | DHookPass_OASSIGNOP);
	DHookAddParam(g_hdAcceptInput_Post, HookParamType_Int);

	g_Onoff 				= CreateConVar( "l4d2_maptankfix_enable", "1", "0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY);
	AutoExecConfig(true,                	"l4d2_maptankfix");
	
	GetCvars();
	g_Onoff.AddChangeHook(ConVarChanged);

	HookEvent("round_start", 	Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn",	Event_PlayerSpawn);
	HookEvent("player_team",    Event_PlayerTeam);
	HookEvent("player_death",   Event_PlayerDeath);
}

public void OnAllPluginsLoaded()
{
	if(MaxClients < 31)
	{
		LogError("\n==========\nWarning: Your maxplayers is not 31, please go install L4dtoolz: https://github.com/lakwsh/l4dtoolz/releases, and set launch parameter: +sv_setmax 31 -maxplayers 31\n==========\n");
		return;
	}

	if(MaxClients > 31)
	{
		LogError("\n==========\nMaxplayers can not be set over 31, please set launch parameter: +sv_setmax 31 -maxplayers 31\n==========\n");
		return;
	}
}

void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bTankFix = g_Onoff.BoolValue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntityIndex(entity) || !g_bTankFix)
		return;

	g_bDuplicate[entity] = false;

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

	#if DEBUG
		LogError("commentary_zombie_spawner Detour: %d", entity);
	#endif

	DHookEntity(g_hdAcceptInput_Pre, false, entity);
	DHookEntity(g_hdAcceptInput_Post, true, entity);

	HookSingleEntityOutput(entity, "OnSpawnedZombieDeath", OnSpawnedZombieDeath);
	
}

void NextFrame_info_zombie_spawn(int entity)
{
	entity = EntRefToEntIndex(entity);
	if(entity == INVALID_ENT_REFERENCE) return;

	static char propName[50];
	GetEntPropString(entity, Prop_Data, "m_szPopulation", propName, sizeof(propName));
	if (StrEqual(propName, "tank", false) || StrEqual(propName, "river_docks_trap", false) /*|| StrEqual(propName, "church", false)*/)
	{
		#if DEBUG
			LogError("info_zombie_spawn Detour: %d", entity);
		#endif

		DHookEntity(g_hdAcceptInput_Pre, false, entity);
		DHookEntity(g_hdAcceptInput_Post, true, entity);
	}
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	delete g_aEntList;
	g_aEntList = new ArrayList();

	g_eTankSpawnType = eNone;
	for(int i = 1; i <= MaxClients; i++)
	{
		g_iCurrentEntRef = INVALID_ENT_REFERENCE;
		g_iTankToCommentaryZombieSpawnerRef[i] = INVALID_ENT_REFERENCE;
	}
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
    int client = GetClientOfUserId(event.GetInt("userid"));

    if(client && IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_INFECTED && IsPlayerAlive(client)
		&& GetEntProp(client, Prop_Send, "m_zombieClass") == ZOMBIECLASS_TANK)
    {
		if(g_eTankSpawnType > eNone)
		{
			// 成功活tank
			#if DEBUG
				float fPos[3];
				GetClientAbsOrigin(client, fPos);
				LogError("New Tank Spawned by SpawnZombie - %.1f %.1f %.1f - %f", client, fPos[0], fPos[1], fPos[2], GetEngineTime());
			#endif	

			// 保護此tank不會被此插件踢
			g_fProtectTime[client] = GetEngineTime() + 10.0;

			if(g_eTankSpawnType == ecommentary_zombie_spawner && g_iCurrentEntRef != INVALID_ENT_REFERENCE)
			{
				int ent = EntRefToEntIndex(g_iCurrentEntRef);
				if(ent != INVALID_ENT_REFERENCE) g_bDuplicate[ent] = true;
				
				g_iTankToCommentaryZombieSpawnerRef[client] = g_iCurrentEntRef;
			}

			RemoveValueFromList(g_iCurrentEntRef);
		}

		g_eTankSpawnType = eNone;
	}
}

void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int oldteam = event.GetInt("oldteam");

	if(client && IsClientInGame(client) && oldteam == 3 && GetEntProp(client, Prop_Send, "m_zombieClass") == ZOMBIECLASS_TANK)
	{
		int ent = EntRefToEntIndex(g_iTankToCommentaryZombieSpawnerRef[client]);
		if(ent != INVALID_ENT_REFERENCE)
		{
			FireEntityOutput(ent, "OnSpawnedZombieDeath", client, 0.0);

			#if DEBUG
				LogError("fire OnSpawnedZombieDeath on entity %d when %N changed team", ent, client);
			#endif
		}

		g_iTankToCommentaryZombieSpawnerRef[client] = INVALID_ENT_REFERENCE;
	}
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if(client && IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_INFECTED && GetEntProp(client, Prop_Send, "m_zombieClass") == ZOMBIECLASS_TANK)
	{
		RequestFrame(NextFrame_Event_PlayerDeath, client);
	}
}

void NextFrame_Event_PlayerDeath(int tank)
{
	int ent = EntRefToEntIndex(g_iTankToCommentaryZombieSpawnerRef[tank]);
	if(ent != INVALID_ENT_REFERENCE)
	{
		FireEntityOutput(ent, "OnSpawnedZombieDeath", tank, 0.0);

		#if DEBUG
			LogError("fire OnSpawnedZombieDeath on entity %d when %d's death", ent, tank);
		#endif
	}

	g_iTankToCommentaryZombieSpawnerRef[tank] = INVALID_ENT_REFERENCE;
}

void OnSpawnedZombieDeath(const char[] output, int caller, int activator, float delay)
{
	// caller = 物件本身, activator = client index, 也可能是entity index, 死掉的Tank
	if(activator > 0 && activator <= MaxClients) g_iTankToCommentaryZombieSpawnerRef[activator] = INVALID_ENT_REFERENCE; 
}

// 如果输入符合
MRESReturn DHook_AcceptInput_Pre(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if (g_bTankFix == false || g_bBlockHook) return MRES_Ignored;
	// 在l4d1中, 如果特感隊伍已滿 (z_max_player_zombies+1), 無法生成tank
	//if (GetClientCount(false) < MaxClients) return MRES_Ignored;
	if(g_bDuplicate[pThis]) return MRES_Ignored;

	static char sCommand[64], szEntityName[64];
	GetEntityClassname(pThis, szEntityName, sizeof(szEntityName));
	// https://developer.valvesoftware.com/wiki/Info_zombie_spawn
	if (StrEqual(szEntityName, "info_zombie_spawn"))
	{
		//1=input的動作 (SpawnZombie, kill...), 2 = 觸發者 (activator), 3 = 物件本身 (filter_xxxxx entity), 4=餵給input動作參數 (tank, smoker...)
		DHookGetParamString(hParams, 1, sCommand, sizeof(sCommand));
		if(strcmp(sCommand, "SpawnZombie", false) != 0) return MRES_Ignored;

		g_eTankSpawnType = einfo_zombie_spawn;

		g_iCurrentEntRef = EntIndexToEntRef(pThis);
		PushValueInList(g_iCurrentEntRef);
		float ePos[3];
		GetEntPropVector(pThis, Prop_Data, "m_vecAbsOrigin", ePos);

		DataPack hPack;
		CreateDataTimer(0.1, CheckIfSpawnSucess, hPack);
		hPack.WriteCell(g_iCurrentEntRef);
		hPack.WriteFloatArray(ePos, sizeof ePos);

		#if DEBUG
			LogError("Detour_Pre info_zombie_spawn spawn: %d, - %f %f %f, %f", pThis, ePos[0], ePos[1], ePos[2], GetEngineTime());
		#endif
	}
	// https://developer.valvesoftware.com/wiki/Commentary_zombie_spawner
	else if (StrEqual(szEntityName, "commentary_zombie_spawner"))
	{
		DHookGetParamString(hParams, 1, sCommand, sizeof(sCommand));
		if(strcmp(sCommand, "SpawnZombie", false) != 0) return MRES_Ignored;

		char result[64];
		DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, result, sizeof(result));
		if (strncmp(result, "tank", 4, false) != 0) return MRES_Ignored;

		g_eTankSpawnType = ecommentary_zombie_spawner;
		
		g_iCurrentEntRef = EntIndexToEntRef(pThis);
		PushValueInList(g_iCurrentEntRef);
		float ePos[3];
		GetEntPropVector(pThis, Prop_Data, "m_vecAbsOrigin", ePos);

		DataPack hPack;
		CreateDataTimer(0.1, CheckIfSpawnSucess, hPack);
		hPack.WriteCell(g_iCurrentEntRef);
		hPack.WriteFloatArray(ePos, sizeof ePos);

		#if DEBUG
			LogError("Detour_Pre commentary_zombie_spawner spawn: %d, - %f %f %f, %f", pThis, ePos[0], ePos[1], ePos[2], GetEngineTime());
		#endif
	}

	return MRES_Ignored;
}

MRESReturn DHook_AcceptInput_Post(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if (g_bTankFix == false || g_bBlockHook) return MRES_Ignored;

	g_eTankSpawnType = eNone;

	return MRES_Ignored;
}

// tank重生期间禁止新特感刷新
/*
MRESReturn SpecialSpawnDetour(DHookReturn hReturn, DHookParam hParams)
{
	if (g_bTankFix == false || IsListNull() || g_bBlockHook) return MRES_Ignored;
	int var1;
	var1 = DHookGetParam(hParams, 1);
	if (var1 != ZOMBIECLASS_TANK)
	{
#if DEBUG
		LogError("Prevent Special Spawn");
#endif
		hReturn.Value = -1;
		return MRES_Supercede;
	}

	return MRES_Ignored;
}
*/
Action CheckIfSpawnSucess(Handle timer, DataPack hPack)
{
	hPack.Reset();
	float ePos[3];
	int ref = hPack.ReadCell();
	hPack.ReadFloatArray(ePos, sizeof ePos);

	int index = g_aEntList.FindValue(ref);
	if(index < 0) return Plugin_Continue;

	TryReleaseSlotFromSpecial();

	DataPack hPack2;
	CreateDataTimer(0.1, LaterSpawnTank, hPack2);
	hPack2.WriteCell(ref);
	hPack2.WriteFloatArray(ePos, sizeof ePos);

	return Plugin_Continue;
}

int GiveHumanSpecialTank(float ePos[3])
{
	// 隨機找到一個死亡的真人特感玩家，將他變成Tank
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int human = 1; human <= MaxClients; human++)
	{
		if (IsClientInGame(human) && GetClientTeam(human) == L4D_TEAM_INFECTED && !IsFakeClient(human) && !IsClientInKickQueue(human))
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
		TeleportEntity(human, ePos, NULL_VECTOR, NULL_VECTOR);	
		L4D_MaterializeFromGhost(human);
		if(IsPlayerAlive(human))
		{
			#if DEBUG
				LogError("GiveHumanSpecialTank: %N", human);
			#endif	
			return human;
		}
	}

	return 0;
}

// 腾出槽位
void TryReleaseSlotFromSpecial()
{
	bool g_bHasSlot = false;
	//PrintToChatAll("Start Release Slot From Special");

	int class;
	// 隨機踢走一個死亡的AI特感 (spitter除外)
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidSpecialsBot(client) && !IsPlayerAlive(client) && !IsClientInKickQueue(client))
		{
			class = GetEntProp(client, Prop_Send, "m_zombieClass");
			if(g_bL4D2Version)
			{
				if ( class == 4 )
				{
					continue;
				}
			}

			#if DEBUG
				LogError("Kick: %N", client);
			#endif

			KickClient(client);
			g_bHasSlot = true;
			break;
		}
	}

	// 隨機處死並踢走一個沒有控人的活著AI特感 (tank除外)
	if(g_bHasSlot == false)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsValidSpecialsBot(client) && !IsClientInKickQueue(client)
				&& GetEntProp(client, Prop_Send, "m_zombieClass") < ZOMBIECLASS_TANK 
				&& L4D_GetPinnedSurvivor(client) <= 0)
			{
				#if DEBUG
					LogError("Kick: %N", client);
				#endif

				ForcePlayerSuicide(client);
				KickClient(client);
				g_bHasSlot = true;
				break;
			}
		}
	}

	// 隨機處死並踢走一個AI特感，無論死活 (tank除外)
	if(g_bHasSlot == false)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsValidSpecialsBot(client) && !IsClientInKickQueue(client)
				&& GetEntProp(client, Prop_Send, "m_zombieClass") < ZOMBIECLASS_TANK)
			{
				if(g_bL4D2Version)
				{
					int jockey = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
					if(jockey != -1)
						vCheatCommand(jockey, "dismount");
				}

				#if DEBUG
					LogError("Kick: %N", client);
				#endif

				ForcePlayerSuicide(client);
				KickClient(client);
				g_bHasSlot = true;
				break;
			}
		}
	}

	// 隨機處死並踢走一個AI tank
	if(g_bHasSlot == false)
	{
		float now = GetEngineTime();
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsValidSpecialsBot(client) && !IsClientInKickQueue(client)
				&& GetEntProp(client, Prop_Send, "m_zombieClass") == ZOMBIECLASS_TANK)
			{
				if(g_fProtectTime[client] > now) continue;
				
				#if DEBUG
					LogError("Kick: %N", client);
				#endif

				ForcePlayerSuicide(client);
				KickClient(client, "for l4d2_maptankfix");
				g_bHasSlot = true;
				break;
			}
		}
	}
}

// 刷克
Action LaterSpawnTank(Handle timer, DataPack hPack)
{
	hPack.Reset();
	float ePos[3];
	int ref = hPack.ReadCell();
	hPack.ReadFloatArray(ePos, sizeof ePos);

	g_bBlockHook = true;

	#if DEBUG
		LogError("LaterSpawnTank");
	#endif

	int ent = EntRefToEntIndex(ref);
	bool bHasTank;
	if(ent == INVALID_ENT_REFERENCE)
	{
		bHasTank = (GiveHumanSpecialTank(ePos) > 0);
		if(!bHasTank) bHasTank = (NoLimit_CreateInfected("tank", ePos, NULL_VECTOR) > 0);
	}
	else
	{
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", ePos);

		char classname[64];
		GetEntityClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "info_zombie_spawn"))
		{
			g_eTankSpawnType = einfo_zombie_spawn;
			g_iCurrentEntRef = ref;
			AcceptEntityInput(ent, "SpawnZombie");
			g_eTankSpawnType = eNone;

			if(g_aEntList.FindValue(ref) < 0) bHasTank = true;

			if(!bHasTank) bHasTank = (GiveHumanSpecialTank(ePos) > 0);
			if(!bHasTank) bHasTank = (NoLimit_CreateInfected("tank", ePos, NULL_VECTOR) > 0);
		}
		else if (StrEqual(classname, "commentary_zombie_spawner"))
		{
			g_eTankSpawnType = ecommentary_zombie_spawner;
			g_iCurrentEntRef = ref;
			SetVariantString("tank");
			AcceptEntityInput(ent, "SpawnZombie");
			g_eTankSpawnType = eNone;

			if(g_aEntList.FindValue(ref) < 0) bHasTank = true;

			int tank;
			if(!bHasTank)
			{
				tank = GiveHumanSpecialTank(ePos);
				bHasTank = (tank > 0);
			}
			if(!bHasTank)
			{
				tank = NoLimit_CreateInfected("tank", ePos, NULL_VECTOR);
				bHasTank = (tank > 0);
			}

			g_iTankToCommentaryZombieSpawnerRef[tank] = ref;
		}
		else
		{
			RemoveValueFromList(ref);

			g_bBlockHook = false;
			return Plugin_Continue;
		}
	}

	g_bBlockHook = false;

	if(bHasTank)
	{
		#if DEBUG
			LogError("Spawn new Tank successful");
		#endif
		RemoveValueFromList(ref);

		// 白癡地圖在同一個entity重複生成特感
		if(ent != INVALID_ENT_REFERENCE)
		{
			g_bDuplicate[ent] = true;
		}
	}
	else
	{
		#if DEBUG
			LogError("Spawn new Tank failed");
		#endif

		DataPack hPack2;
		CreateDataTimer(0.1, CheckIfSpawnSucess, hPack2);
		hPack2.WriteCell(ref);
		hPack2.WriteFloatArray(ePos, sizeof ePos);
	}

	return Plugin_Continue;
}

// 以下函数为一些内部使用函数
bool IsValidSpecialsBot(int client)
{
	return IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_INFECTED && IsFakeClient(client);
}

void PushValueInList(int value)
{
	if(g_aEntList.FindValue(value) < 0) g_aEntList.Push(value);
}

void RemoveValueFromList(int value)
{
	int index = g_aEntList.FindValue(value);
	if(index >= 0) g_aEntList.Erase(index);
}

stock bool IsListNull()
{
	return g_aEntList.Length == 0;
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

void vCheatCommand(int client, const char[] sCommand)
{
	int iFlagBits, iCmdFlags;
	iFlagBits = GetUserFlagBits(client);
	iCmdFlags = GetCommandFlags(sCommand);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	SetCommandFlags(sCommand, iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s", sCommand);
	if(IsClientConnected(client)) SetUserFlagBits(client, iFlagBits);
	SetCommandFlags(sCommand, iCmdFlags);
}