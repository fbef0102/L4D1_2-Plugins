//防止地图自带的机关tank(commentary_zombie_spawner, info_zombie_spawn)因为槽位问题无法刷新而造成的机关卡关(如伦理机关克等)[绝境]

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>
#include <left4dhooks>
#include <spawn_infected_nolimit> //https://github.com/fbef0102/L4D1_2-Plugins/tree/master/spawn_infected_nolimit

#define DEBUG		   0
#define PLUGIN_VERSION "1.6-2026/10/25"

public Plugin myinfo =
{
	name		= "[L4D1/2] 地图机关tank生成修复",
	author		= "洛琪, Harry",
	description = "Fix issues where customized map tank(commentary_zombie_spawner, info_zombie_spawn) does not spawn, cause the map process break",
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
	g_eEntityType[MAXENTITIES+1];

bool	
	g_bInputAgain,
	g_bSpawnTankAlready[MAXENTITIES+1],
	g_bCurrentAcceptInput;

int 
	g_iCurrentSpawnTankEntRef,
	g_iTankToCommentaryZombieSpawnerRef[MAXPLAYERS+1];
 
float
	g_fProtectTime[MAXPLAYERS+1];

DynamicHook	
	g_hdAcceptInput_Pre, g_hdAcceptInput_Post;

public void OnPluginStart()
{
    GameData hGameData;
    if(g_bL4D2Version)
    {
        hGameData = LoadGameConfigFile("left4dhooks.l4d2");
    }
    else
    {
        hGameData = LoadGameConfigFile("left4dhooks.l4d1");
    }
     
    int offset = hGameData.GetOffset("CBaseEntity::AcceptInput");
    delete hGameData;

    if (offset == -1)
        SetFailState("Failed to get AcceptInput offset, please install left4dhooks gamedata");

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

	g_bSpawnTankAlready[entity] = false;

	switch (classname[0])
	{
		case 'c':
		{
			if (StrEqual(classname, "commentary_zombie_spawner"))
			{
				g_eEntityType[entity] = ecommentary_zombie_spawner;
				RequestFrame(NextFrame_commentary_zombie_spawner, EntIndexToEntRef(entity));
			}
		}
		case 'i':
		{
			if (StrEqual(classname, "info_zombie_spawn"))
			{
				g_eEntityType[entity] = einfo_zombie_spawn;
				RequestFrame(NextFrame_info_zombie_spawn, EntIndexToEntRef(entity));
			}
		}
	}
}

void NextFrame_commentary_zombie_spawner(int entity)
{
	entity = EntRefToEntIndex(entity);
	if(entity == INVALID_ENT_REFERENCE) return;

	DHookEntity(g_hdAcceptInput_Pre, false, entity);
	DHookEntity(g_hdAcceptInput_Post, true, entity);

	HookSingleEntityOutput(entity, "OnSpawnedZombieDeath", OnSpawnedZombieDeath);
	
}

void NextFrame_info_zombie_spawn(int entity)
{
	entity = EntRefToEntIndex(entity);
	if(entity == INVALID_ENT_REFERENCE) return;

	//static char propName[50];
	//GetEntPropString(entity, Prop_Data, "m_szPopulation", propName, sizeof(propName));
	//if (StrEqual(propName, "tank", false) || StrEqual(propName, "river_docks_trap", false) /*|| StrEqual(propName, "church", false)*/)
	//{
	DHookEntity(g_hdAcceptInput_Pre, false, entity);
	DHookEntity(g_hdAcceptInput_Post, true, entity);
	//}
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	delete g_aEntList;
	g_aEntList = new ArrayList();

	for(int i = 1; i <= MaxClients; i++)
	{
		g_iCurrentSpawnTankEntRef = INVALID_ENT_REFERENCE;
		g_iTankToCommentaryZombieSpawnerRef[i] = INVALID_ENT_REFERENCE;
	}
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
    int client = GetClientOfUserId(event.GetInt("userid"));

    if(client && IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_INFECTED && IsPlayerAlive(client)
		&& GetEntProp(client, Prop_Send, "m_zombieClass") == ZOMBIECLASS_TANK)
    {
		if(g_bCurrentAcceptInput || g_bInputAgain)
		{
			// 成功活tank
			// float fPos[3];
			// GetClientAbsOrigin(client, fPos);
			// LogError("New Tank Spawned by SpawnZombie - %.1f %.1f %.1f - %f", client, fPos[0], fPos[1], fPos[2], GetEngineTime());

			// 保護此tank不會被此插件踢
			g_fProtectTime[client] = GetEngineTime() + 10.0;

			int ent = EntRefToEntIndex(g_iCurrentSpawnTankEntRef);
			if(ent != INVALID_ENT_REFERENCE)
			{
				g_bSpawnTankAlready[ent] = true;
				if(g_eEntityType[ent] == ecommentary_zombie_spawner)
				{
					g_iTankToCommentaryZombieSpawnerRef[client] = g_iCurrentSpawnTankEntRef;
				}
			}

			RemoveValueFromList(g_iCurrentSpawnTankEntRef);
		}
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

// info_zombie_spawn 與 commentary_zombie_spawner 生成Tank順序: AcceptInput Pre -> L4D_OnSpawnTank -> "player_spawn" -> L4D_OnSpawnTank_Post -> AcceptInput Post
// (L4D1) 特感隊伍沒位置時: AcceptInput Pre -> L4D_OnSpawnTank -> "player_spawn" (但team是1) -> L4D_OnSpawnTank_Post -> AcceptInput Post
// 伺服器沒位置時: AcceptInput Pre -> L4D_OnSpawnTank -> AcceptInput Post
MRESReturn DHook_AcceptInput_Pre(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if (g_bTankFix == false || g_bInputAgain) return MRES_Ignored;
	// 在l4d1中, 如果特感隊伍已滿 (z_max_player_zombies+1), 無法生成tank
	//if (GetClientCount(false) < MaxClients) return MRES_Ignored;
	if(g_bSpawnTankAlready[pThis]) return MRES_Ignored;

	// https://developer.valvesoftware.com/wiki/Info_zombie_spawn
	if (g_eEntityType[pThis] == einfo_zombie_spawn)
	{
		//1=input的動作 (SpawnZombie, kill...), 2 = 觸發者 (activator), 3 = 物件本身 (filter_xxxxx entity), 4=餵給input動作參數 (tank, smoker...)
		static char sCommand[64];
		DHookGetParamString(hParams, 1, sCommand, sizeof(sCommand));
		if(strcmp(sCommand, "SpawnZombie", false) != 0) return MRES_Ignored;

		g_iCurrentSpawnTankEntRef = EntIndexToEntRef(pThis);
		g_bCurrentAcceptInput = true;
	}
	// https://developer.valvesoftware.com/wiki/Commentary_zombie_spawner
	else if (g_eEntityType[pThis] == ecommentary_zombie_spawner)
	{
		char result[64];
		DHookGetParamObjectPtrString(hParams, 4, 0, ObjectValueType_String, result, sizeof(result));
		if (strncmp(result, "tank", 4, false) != 0) return MRES_Ignored;

		g_iCurrentSpawnTankEntRef = EntIndexToEntRef(pThis);
		g_bCurrentAcceptInput = true;
	}

	return MRES_Ignored;
}

MRESReturn DHook_AcceptInput_Post(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if (g_bTankFix == false || g_bInputAgain) return MRES_Ignored;
	//if (g_bCurrentAcceptInput) LogError("DHook_AcceptInput_Post");

	g_bCurrentAcceptInput = false;

	return MRES_Ignored;
}

// left4dhooks API

public Action L4D_OnSpawnTank(const float vecPos[3], const float vecAng[3])
{
	if(!g_bCurrentAcceptInput) return Plugin_Continue;
	
	int ent = EntRefToEntIndex(g_iCurrentSpawnTankEntRef);
	if(ent == INVALID_ENT_REFERENCE) return Plugin_Continue;

	if (g_eEntityType[ent] == einfo_zombie_spawn)
	{
		PushValueInList(g_iCurrentSpawnTankEntRef);

		float vPos[3];
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", vPos);

		DataPack hPack;
		CreateDataTimer(0.1, CheckIfSpawnSucess, hPack);
		hPack.WriteCell(g_iCurrentSpawnTankEntRef);
		hPack.WriteFloatArray(vPos, sizeof vPos);

		//LogError("L4D_OnSpawnTank info_zombie_spawn spawn: %d, - %f %f %f, %f", ent, vPos[0], vPos[1], vPos[2], GetEngineTime());
	}
	// https://developer.valvesoftware.com/wiki/Commentary_zombie_spawner
	else if (g_eEntityType[ent] == ecommentary_zombie_spawner)
	{
		PushValueInList(g_iCurrentSpawnTankEntRef);

		float vPos[3];
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", vPos);

		DataPack hPack;
		CreateDataTimer(0.1, CheckIfSpawnSucess, hPack);
		hPack.WriteCell(g_iCurrentSpawnTankEntRef);
		hPack.WriteFloatArray(vPos, sizeof vPos);

		//LogError("L4D_OnSpawnTank commentary_zombie_spawner spawn: %d, - %f %f %f, %f", ent, vPos[0], vPos[1], vPos[2], GetEngineTime());
	}

	return Plugin_Continue;
}
/*
public void L4D_OnSpawnTank_Post(int client, const float vecPos[3], const float vecAng[3])
{
	LogError("L4D_OnSpawnTank_Post");
}
*/
public void L4D_OnSpawnTank_PostHandled(int client, const float vecPos[3], const float vecAng[3])
{
	if(!g_bCurrentAcceptInput) return;
	//LogError("L4D_OnSpawnTank_PostHandled");

	RemoveValueFromList(g_iCurrentSpawnTankEntRef);
}

Action CheckIfSpawnSucess(Handle timer, DataPack hPack)
{
	hPack.Reset();
	float vPos[3];
	int ref = hPack.ReadCell();
	hPack.ReadFloatArray(vPos, sizeof vPos);

	int index = g_aEntList.FindValue(ref);
	if(index < 0) return Plugin_Continue;

	TryReleaseSlotFromSpecial();

	DataPack hPack2;
	CreateDataTimer(0.1, LaterSpawnTank, hPack2);
	hPack2.WriteCell(ref);
	hPack2.WriteFloatArray(vPos, sizeof vPos);

	return Plugin_Continue;
}

int GiveHumanSpecialTank(float vPos[3])
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
		TeleportEntity(human, vPos, NULL_VECTOR, NULL_VECTOR);	
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
	//LogError("Start Release Slot From Special");

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
	float vPos[3];
	int ref = hPack.ReadCell();
	hPack.ReadFloatArray(vPos, sizeof vPos);

	//LogError("LaterSpawnTank");

	int ent = EntRefToEntIndex(ref);
	bool bHasTank;
	if(ent == INVALID_ENT_REFERENCE)
	{
		bHasTank = (GiveHumanSpecialTank(vPos) > 0);
		if(!bHasTank) bHasTank = (NoLimit_CreateInfected("tank", vPos, NULL_VECTOR) > 0);
	}
	else
	{
		GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", vPos);

		char classname[64];
		GetEntityClassname(ent, classname, sizeof(classname));
		if (g_eEntityType[ent] == einfo_zombie_spawn)
		{
			g_iCurrentSpawnTankEntRef = ref;
			g_bInputAgain = true;
			AcceptEntityInput(ent, "SpawnZombie"); //如果成功會觸發 "player_spawn"
			g_bInputAgain = false;

			if(g_aEntList.FindValue(ref) < 0)
			{
				//LogError("Spawn new Tank successful (input \"SpawnZombie\" again)");
				bHasTank = true;
				return Plugin_Continue;
			}

			if(!bHasTank) bHasTank = (GiveHumanSpecialTank(vPos) > 0);
			if(!bHasTank) bHasTank = (NoLimit_CreateInfected("tank", vPos, NULL_VECTOR) > 0);
		}
		else if (g_eEntityType[ent] == ecommentary_zombie_spawner)
		{
			g_iCurrentSpawnTankEntRef = ref;
			g_bInputAgain = true;
			SetVariantString("tank");
			AcceptEntityInput(ent, "SpawnZombie"); //如果成功會觸發 "player_spawn"
			g_bInputAgain = false;

			if(g_aEntList.FindValue(ref) < 0)
			{
				//LogError("Spawn new Tank successful (input \"SpawnZombie\" again)");
				bHasTank = true;
				return Plugin_Continue;
			}

			int tank;
			if(!bHasTank)
			{
				tank = GiveHumanSpecialTank(vPos);
				bHasTank = (tank > 0);
			}
			if(!bHasTank)
			{
				tank = NoLimit_CreateInfected("tank", vPos, NULL_VECTOR);
				bHasTank = (tank > 0);
			}

			if(bHasTank) g_iTankToCommentaryZombieSpawnerRef[tank] = ref;
		}

		// 白癡地圖在同一個entity重複生成Tank
		if(bHasTank) g_bSpawnTankAlready[ent] = true;
	}

	if(bHasTank)
	{
		//LogError("Spawn new Tank successful (GiveHumanSpecialTank or NoLimit_CreateInfected)");
		RemoveValueFromList(ref);
	}
	else
	{
		//LogError("Spawn new Tank failed");

		DataPack hPack2;
		CreateDataTimer(0.1, CheckIfSpawnSucess, hPack2);
		hPack2.WriteCell(ref);
		hPack2.WriteFloatArray(vPos, sizeof vPos);
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