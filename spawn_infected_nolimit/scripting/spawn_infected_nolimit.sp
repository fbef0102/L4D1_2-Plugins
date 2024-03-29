#define PLUGIN_NAME "[L4D1/2] Manual-Spawn Special Infected"
#define PLUGIN_AUTHOR "Shadowysn, ProdigySim (Major Windows Fix), Harry"
#define PLUGIN_DESC "Spawn special infected without the director limits!"
#define PLUGIN_VERSION "1.3h-2024/3/15"
#define PLUGIN_NAME_SHORT "Manual-Spawn Special Infected"
#define PLUGIN_NAME_TECH "spawn_infected_nolimit"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <adminmenu>
#include <left4dhooks>

public Plugin myinfo = 
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESC,
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

bool g_bLeft4Dead2;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if(GetEngineVersion() == Engine_Left4Dead2)
	{
		g_bLeft4Dead2 = true;
	}
	else if(GetEngineVersion() == Engine_Left4Dead)
	{
		g_bLeft4Dead2 = false;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead and Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	CreateNative("NoLimit_CreateInfected", Native_CreateInfected);
	RegPluginLibrary("spawn_infected_nolimit");
	return APLRes_Success;
}

TopMenu hTopMenu;

// Infected models
#define MODEL_SMOKER           		"models/infected/smoker.mdl"
#define MODEL_SMOKER_L4D1           "models/infected/smoker_l4d1.mdl"

#define MODEL_BOOMER           		"models/infected/boomer.mdl"
#define MODEL_BOOMER_L4D1           "models/infected/boomer_l4d1.mdl"
#define MODEL_BOOMER_BOOMETTE       "models/infected/boomette.mdl"

#define MODEL_HUNTER           		"models/infected/hunter.mdl"
#define MODEL_HUNTER_L4D1           "models/infected/hunter_l4d1.mdl"

#define MODEL_EXPLODED              "models/infected/limbs/exploded_boomer.mdl"
#define MODEL_EXPLODED_BOOMETTE     "models/infected/limbs/exploded_boomette.mdl"

#define MODEL_SPITTER 	"models/infected/spitter.mdl"
#define MODEL_JOCKEY 	"models/infected/jockey.mdl"
#define MODEL_CHARGER 	"models/infected/charger.mdl"

#define MODEL_TANK             		"models/infected/hulk.mdl"
#define MODEL_TANK_DLC              "models/infected/hulk_dlc3.mdl"
#define MODEL_TANK_L4D1             "models/infected/hulk_l4d1.mdl"

#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl"

#define TEAM_SURVIVORS 2
#define TEAM_INFECTED 3

#define L4D_MAX_PLAYERS 31

#define GAMEDATA "spawn_infected_nolimit"

#define DIRECTOR_CLASS "info_director"
#define DIRECTOR_ENT "plugin_director_ent_do_not_use"

GameData hConf = null;

static Handle hCreateSmoker = null;
#define NAME_CreateSmoker "NextBotCreatePlayerBot<Smoker>"
#define NAME_CreateSmoker_L4D1 "reloffs_NextBotCreatePlayerBot<Smoker>"
#define SIG_CreateSmoker_LINUX "@_Z22NextBotCreatePlayerBotI6SmokerEPT_PKc"
static Handle hCreateBoomer = null;
#define NAME_CreateBoomer "NextBotCreatePlayerBot<Boomer>"
#define NAME_CreateBoomer_L4D1 "reloffs_NextBotCreatePlayerBot<Boomer>"
#define SIG_CreateBoomer_LINUX "@_Z22NextBotCreatePlayerBotI6BoomerEPT_PKc"
static Handle hCreateHunter = null;
#define NAME_CreateHunter "NextBotCreatePlayerBot<Hunter>"
#define NAME_CreateHunter_L4D1 "reloffs_NextBotCreatePlayerBot<Hunter>"
#define SIG_CreateHunter_LINUX "@_Z22NextBotCreatePlayerBotI6HunterEPT_PKc"
static Handle hCreateSpitter = null;
#define NAME_CreateSpitter "NextBotCreatePlayerBot<Spitter>"
#define SIG_CreateSpitter_LINUX "@_Z22NextBotCreatePlayerBotI7SpitterEPT_PKc"
static Handle hCreateJockey = null;
#define NAME_CreateJockey "NextBotCreatePlayerBot<Jockey>"
#define SIG_CreateJockey_LINUX "@_Z22NextBotCreatePlayerBotI6JockeyEPT_PKc"
static Handle hCreateCharger = null;
#define NAME_CreateCharger "NextBotCreatePlayerBot<Charger>"
#define SIG_CreateCharger_LINUX "@_Z22NextBotCreatePlayerBotI7ChargerEPT_PKc"
static Handle hCreateTank = null;
#define NAME_CreateTank "NextBotCreatePlayerBot<Tank>"
#define NAME_CreateTank_L4D1 "reloffs_NextBotCreatePlayerBot<Tank>"
#define SIG_CreateTank_LINUX "@_Z22NextBotCreatePlayerBotI4TankEPT_PKc"

#define ADDRESS_NAME "NextBotCreatePlayerBot.jumptable"
#define ADDRESS_SIG_NAME "CTerrorPlayer::ReplaceWithBot.jumptable"
#define ADDRESS_OFFSET 7
#define ADDRESS_SIG "\\xFF\\x24\\x85\\x2A\\x2A\\x2A\\x2A\\x68\\x2A\\x2A\\x2A\\x2A\\xE8\\x2A\\x2A\\x2A\\x2A\\xEB\\x2A\\x68\\x2A\\x2A\\x2A\\x2A\\xE8\\x2A\\x2A\\x2A\\x2A\\xEB\\x2A\\x68\\x2A\\x2A\\x2A\\x2A\\xE8\\x2A\\x2A\\x2A\\x2A\\xEB\\x2A\\x68\\x2A\\x2A\\x2A\\x2A\\xE8\\x2A\\x2A\\x2A\\x2A\\xEB\\x2A\\x68\\x2A\\x2A\\x2A\\x2A\\xE8\\x2A\\x2A\\x2A\\x2A\\xEB\\x2A\\x68\\x2A\\x2A\\x2A\\x2A\\xE8\\x2A\\x2A\\x2A\\x2A\\xEB\\x2A\\x68\\x2A\\x2A\\x2A\\x2A\\xE8"
#define ADDRESS_SIG_RAW "FF 24 85 ? ? ? ? 68 ? ? ? ? E8 ? ? ? ? EB ? 68 ? ? ? ? E8 ? ? ? ? EB ? 68 ? ? ? ? E8 ? ? ? ? EB ? 68 ? ? ? ? E8 ? ? ? ? EB ? 68 ? ? ? ? E8 ? ? ? ? EB ? 68 ? ? ? ? E8 ? ? ? ? EB ? 68 ? ? ? ? E8"

#define SIG_L4D1CreateSmoker_WINDOWS "\\x83\\x2A\\x2A\\x56\\x57\\x68\\x20\\xED"
#define SIG_L4D1CreateBoomer_WINDOWS "\\x83\\x2A\\x2A\\x56\\x57\\x68\\x10"
#define SIG_L4D1CreateHunter_WINDOWS "\\x83\\x2A\\x2A\\x56\\x57\\x68\\x20\\x35"
#define SIG_L4D1CreateTank_WINDOWS "\\x83\\x2A\\x2A\\x56\\x57\\x68\\x80"


static Handle hInfectedAttackSurvivorTeam = null;
#define NAME_InfectedAttackSurvivorTeam "Infected::AttackSurvivorTeam"
#define SIG_InfectedAttackSurvivorTeam_LINUX "@_ZN8Infected18AttackSurvivorTeamEv"
#define SIG_InfectedAttackSurvivorTeam_WINDOWS "\\x56\\x8B\\x2A\\x80\\xBE\\xC1\\x1C\\x00\\x00\\x01\\x74\\x2A\\x80"

#define SIG_L4D1InfectedAttackSurvivorTeam_WINDOWS "\\x80\\xB9\\x99"

ConVar version_cvar;


#define MAXENTITIES                   2048
#define ENTITY_SAFE_LIMIT 2000 //don't spawn boxes when it's index is above this

/**
* @brief 			   Spawn special infected without the director limits!
*
* @param zomb          	S.I. Name: 
*                             (L4D2) "tank", "smoker", "hunter", "boomer"," jockey", "charger", "spitter", "witch"
*                             (L4D1) "tank", "smoker", "hunter", "boomer", "witch"
* @param vecPos        	Vector coordinate where the special will be spawned
* @param vecAng        	QAngle where special will be facing
* @param variantModel  	The zombie variant model 
*                             (L4D2) Smoker: 	1=L4D2 Model, 2=L4D1 Model, 0=Random
*                             (L4D2) Boomer: 	1=L4D2 Model, 2=L4D1 Model, 3=Female Boomer, 0=Random
*                             (L4D2) Hunter: 	1=L4D2 Model, 2=L4D1 Model, 0=Random
*                             (L4D2) Tank: 		1=L4D2 Model, 2=DLC Model, 3=L4D1 Model, 0=Random
*                             (L4D1) Tank: 		1=L4D1 Model, 2=DLC Model, 0=Random
*
* @return               client index of the spawned special infected, -1 if fail to spawn
*/
//native int NoLimit_CreateInfected(const char[] zomb, const float vecPos[3], const float vecAng[3], int variantModel = 1);

int Native_CreateInfected(Handle plugin, int numParams)
{
	char zomb[10];
	GetNativeString(1, zomb, sizeof(zomb));

	float vPos[3], vAng[3];
	GetNativeArray(2, vPos, sizeof(vPos));
	GetNativeArray(3, vAng, sizeof(vAng));

	int bot;
	if(numParams >= 4)
	{
		bot = CreateInfected(zomb, vPos, vAng, GetNativeCell(4));
	}
	else
	{
		bot = CreateInfected(zomb, vPos, vAng);
	}

	return bot;
}

public void OnPluginStart()
{
	static char desc_str[64];
	Format(desc_str, sizeof(desc_str), "%s version.", PLUGIN_NAME_SHORT);
	static char cmd_str[64];
	Format(cmd_str, sizeof(cmd_str), "sm_%s_version", PLUGIN_NAME_TECH);
	version_cvar = CreateConVar(cmd_str, PLUGIN_VERSION, desc_str, FCVAR_NONE|FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_DONTRECORD);
	if (version_cvar != null)
		SetConVarString(version_cvar, PLUGIN_VERSION);
	
	GetGamedata();
	
	RegAdminCmd("sm_dzspawn", Command_Spawn, ADMFLAG_ROOT, "sm_dzspawn <zombie> <number> <mode> - Spawn a special infected, bypassing the limit enforced by the game.");
	RegAdminCmd("sm_mdzs", Command_SpawnMenu, ADMFLAG_ROOT, "Open a menu to spawn a special infected, bypassing the limit enforced by the game.");
}

public void OnMapStart()
{
	PrecacheModel(MODEL_SMOKER, true);
	PrecacheModel(MODEL_BOOMER, true);
	PrecacheModel(MODEL_EXPLODED, true); // Prevents server crash when a Boomer dies.
	PrecacheModel(MODEL_HUNTER, true);
	
	PrecacheModel(MODEL_TANK);
	PrecacheModel(MODEL_WITCH);

	if (g_bLeft4Dead2)
	{
		PrecacheModel(MODEL_SMOKER_L4D1, true);
		PrecacheModel(MODEL_BOOMER_L4D1, true);
		PrecacheModel(MODEL_BOOMER_BOOMETTE, true);
		PrecacheModel(MODEL_EXPLODED_BOOMETTE, true); // Prevents server crash when a Boomette dies.
		PrecacheModel(MODEL_HUNTER_L4D1, true);

		PrecacheModel(MODEL_SPITTER, true);
		PrecacheModel(MODEL_JOCKEY, true);
		PrecacheModel(MODEL_CHARGER, true);

		PrecacheModel(MODEL_TANK_DLC);
		PrecacheModel(MODEL_TANK_L4D1);
		PrecacheModel(MODEL_WITCHBRIDE);
	}

}

Action Command_SpawnMenu(int client, any args)
{
	if (client == 0)  
	{ 
		ReplyToCommand(client, "[SIN] Menu is in-game only."); 
		return Plugin_Handled; 
	}
	
	Handle menu = CreateMenu(SpawnMenu_Handler);
	SetMenuTitle(menu, "Direct ZSpawn Menu");
	AddMenuItem(menu, "Smoker", "Smoker");
	AddMenuItem(menu, "Boomer", "Boomer");
	AddMenuItem(menu, "Hunter", "Hunter");
	if (g_bLeft4Dead2)
	{
		AddMenuItem(menu, "Jockey", "Jockey");
		AddMenuItem(menu, "Spitter", "Spitter");
		AddMenuItem(menu, "Charger", "Charger");
	}
	AddMenuItem(menu, "Tank", "Tank");
	AddMenuItem(menu, "Witch", "Witch");
	if (g_bLeft4Dead2)
	{ AddMenuItem(menu, "witch_bride", "Bride Witch"); }
	AddMenuItem(menu, "", "Common");
	AddMenuItem(menu, "chase", "Chasing Common");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

int SpawnMenu_Handler(Handle menu, MenuAction action, int client, int param) 
{
	switch (action)
	{
		case MenuAction_Select:
		{
			static char zombie[12];
			GetMenuItem(menu, param, zombie, sizeof(zombie));
			
			CreateInfectedWithParams(client, zombie);
			Command_SpawnMenu(client, 0);
		}
		case MenuAction_Cancel:
		{
			if (param == MenuCancel_ExitBack && hTopMenu != INVALID_HANDLE)
			{
				DisplayTopMenu(hTopMenu, client, TopMenuPosition_LastCategory);
			}
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}

	return 0;
}

Action Command_Spawn(int client, any args)
{
	if (!IsValidClient(client))
	{
		ReplyToCommand(client, "[SIN] Invalid client! Unable to get position and angles!");
		return Plugin_Handled;
	}
	if (args > 4)
	{
		ReplyToCommand(client, "sm_dzspawn <zombie> <number> <mode> - Spawn a special infected, bypassing the limit enforced by the game.");
		return Plugin_Handled;
	}
	
	static char zomb[128], number[4], mode[2];
	GetCmdArg(1, zomb, sizeof(zomb));
	GetCmdArg(2, number, sizeof(number));
	GetCmdArg(3, mode, sizeof(mode));
	int mode_int = StringToInt(mode);
	int number_int = StringToInt(number);
	if (number_int < 1)
	{ number_int = 1; }
	
	if (GetClientCount(false) > L4D_MAX_PLAYERS - number_int)
	{
		ReplyToCommand(client, "[SIN] Not enough player slots");
		return Plugin_Handled;
    }
	
	CreateInfectedWithParams(client, zomb, mode_int, number_int);

	return Plugin_Handled;
}

void CreateInfectedWithParams(int client, const char[] zomb, int mode = 0, int number = 1)
{
	float pos[3];
	float ang[3];
	GetClientAbsOrigin(client, pos);
	GetClientAbsAngles(client, ang);
	if (mode <= 0)
	{
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);
		TR_TraceRayFilter(pos, ang, MASK_OPAQUE, RayType_Infinite, TraceRayDontHitPlayers, client);
		if (TR_DidHit(null))
		{
			TR_GetEndPosition(pos);
		}
		else
		{
			PrintToChat(client, "[SIN] Vector out of world geometry. Teleporting on origin instead");
		}
	}
	ang[0] = 0.0;ang[2] = 0.0;
	int failed_Count = 0;
	for (int i = 0;i < number;i++)
	{
		int infected = CreateInfected(zomb, pos, ang);
		if (!RealValidEntity(infected))
		{ failed_Count += 1; }
	}
	if (failed_Count > 1)
	{ PrintToChat(client, "[SIN] Failed to spawn %i %s infected!", failed_Count, zomb); }
	else if (failed_Count > 0)
	{ PrintToChat(client, "[SIN] Failed to spawn %s infected!", zomb); }
}
bool TraceRayDontHitPlayers(int entity, int mask, any data)
{
	if (IsValidClient(data))
	{
		return false;
	}
	return true;
}

int CreateInfected(const char[] zomb, const float pos[3], const float ang[3], int variantModel = 1)
{
	if (GetClientCount(false) >= L4D_MAX_PLAYERS)
	{
		PrintToServer("[SIN] Not enough player slots");
		return 0;
	}

	int bot = -1;
	static char sModel[64];
	sModel[0] = '\0';

	if (strncmp(zomb, "witch", 5, false) == 0 || (g_bLeft4Dead2 && strncmp(zomb, "witch_bride", 11, false) == 0))
	{
		int witch = L4D2_SpawnWitch(pos, ang);

		return witch;
	}
	else if(g_bLeft4Dead2 && strncmp(zomb, "witch_bride", 11, false) == 0)
	{
		int witch = L4D2_SpawnWitchBride(pos, ang);

		return witch;
	}
	else if (strncmp(zomb, "smoker", 6, false) == 0)
	{
		bot = SDKCall(hCreateSmoker, "Smoker");
		if(g_bLeft4Dead2)
		{
			variantModel = (variantModel == 0) ? GetRandomInt(1, 2) : variantModel;

			switch(variantModel)
			{
				case 1: FormatEx(sModel, sizeof(sModel), "%s", MODEL_SMOKER);
				case 2: FormatEx(sModel, sizeof(sModel), "%s", MODEL_SMOKER_L4D1);
				default: FormatEx(sModel, sizeof(sModel), "%s", MODEL_SMOKER);
			}
		}
		else
		{
			FormatEx(sModel, sizeof(sModel), "%s", MODEL_SMOKER);
		}
	}
	else if (strncmp(zomb, "boomer", 6, false) == 0)
	{
		bot = SDKCall(hCreateBoomer, "Boomer");
		if(g_bLeft4Dead2)
		{
			variantModel = (variantModel == 0) ? GetRandomInt(1, 3) : variantModel;

			switch(variantModel)
			{
				case 1: FormatEx(sModel, sizeof(sModel), "%s", MODEL_BOOMER);
				case 2: FormatEx(sModel, sizeof(sModel), "%s", MODEL_BOOMER_L4D1);
				case 3: FormatEx(sModel, sizeof(sModel), "%s", MODEL_BOOMER_BOOMETTE);
				default: FormatEx(sModel, sizeof(sModel), "%s", MODEL_BOOMER);
			}
		}
		else
		{
			FormatEx(sModel, sizeof(sModel), "%s", MODEL_BOOMER);
		}
	}
	else if (strncmp(zomb, "hunter", 6, false) == 0)
	{
		bot = SDKCall(hCreateHunter, "Hunter");
		if(g_bLeft4Dead2)
		{
			variantModel = (variantModel == 0) ? GetRandomInt(1, 2) : variantModel;

			switch(variantModel)
			{
				case 1: FormatEx(sModel, sizeof(sModel), "%s", MODEL_HUNTER);
				case 2: FormatEx(sModel, sizeof(sModel), "%s", MODEL_HUNTER_L4D1);
				default: FormatEx(sModel, sizeof(sModel), "%s", MODEL_HUNTER);
			}
		}
		else
		{
			FormatEx(sModel, sizeof(sModel), "%s", MODEL_HUNTER);
		}
	}
	else if (strncmp(zomb, "spitter", 7, false) == 0 && g_bLeft4Dead2)
	{
		bot = SDKCall(hCreateSpitter, "Spitter");
		FormatEx(sModel, sizeof(sModel), "%s", MODEL_SPITTER);
	}
	else if (strncmp(zomb, "jockey", 6, false) == 0 && g_bLeft4Dead2)
	{
		bot = SDKCall(hCreateJockey, "Jockey");
		FormatEx(sModel, sizeof(sModel), "%s", MODEL_JOCKEY);
	}
	else if (strncmp(zomb, "charger", 7, false) == 0 && g_bLeft4Dead2)
	{
		bot = SDKCall(hCreateCharger, "Charger");
		FormatEx(sModel, sizeof(sModel), "%s", MODEL_CHARGER);
	}
	else if (strncmp(zomb, "tank", 4, false) == 0)
	{
		bot = SDKCall(hCreateTank, "Tank");
		if(g_bLeft4Dead2)
		{
			variantModel = (variantModel == 0) ? GetRandomInt(1, 3) : variantModel;

			switch(variantModel)
			{
				case 1: FormatEx(sModel, sizeof(sModel), "%s", MODEL_TANK);
				case 2: FormatEx(sModel, sizeof(sModel), "%s", MODEL_TANK_DLC);
				case 3: FormatEx(sModel, sizeof(sModel), "%s", MODEL_TANK_L4D1);
				default: FormatEx(sModel, sizeof(sModel), "%s", MODEL_TANK);
			}
		}
		else
		{
			variantModel = (variantModel == 0) ? GetRandomInt(1, 2) : variantModel;

			switch(variantModel)
			{
				case 1: FormatEx(sModel, sizeof(sModel), "%s", MODEL_TANK);
				case 2: FormatEx(sModel, sizeof(sModel), "%s", MODEL_TANK_DLC);
				default: FormatEx(sModel, sizeof(sModel), "%s", MODEL_TANK);
			}
		}
	}
	else
	{
		int infected = CreateEntityByName("infected");
		if(CheckIfEntitySafe(infected) == false) return -1;

		TeleportEntity(infected, pos, ang, NULL_VECTOR);
		DispatchSpawn(infected);
		ActivateEntity(infected);
		if (hInfectedAttackSurvivorTeam != null && StrContains(zomb, "chase", false) > -1)
		{ CreateTimer(0.4, Timer_Chase, EntIndexToEntRef(infected)); }
		
		return infected;
	}
	
	if (IsValidClient(bot))
	{
		ChangeClientTeam(bot, 3);
		SetEntProp(bot, Prop_Send, "m_usSolidFlags", 16);
		SetEntProp(bot, Prop_Send, "movetype", 2);
		SetEntProp(bot, Prop_Send, "deadflag", 0);
		SetEntProp(bot, Prop_Send, "m_lifeState", 0);
		//SetEntProp(bot, Prop_Send, "m_fFlags", 129);
		SetEntProp(bot, Prop_Send, "m_iObserverMode", 0);
		SetEntProp(bot, Prop_Send, "m_iPlayerState", 0);
		SetEntProp(bot, Prop_Send, "m_zombieState", 0);
		DispatchSpawn(bot);
		ActivateEntity(bot);
		if(strlen(sModel) > 0) SetEntityModel(bot, sModel);
		
		DataPack data = new DataPack();
		data.WriteFloat(pos[0]);
		data.WriteFloat(pos[1]);
		data.WriteFloat(pos[2]);
		data.WriteFloat(ang[1]);
		data.WriteCell(GetClientUserId(bot));
		RequestFrame(RequestFrame_SetPos, data);
	}
	else
	{
		return -1;
	}
	
	return bot;
}

/*void AssignPanicToWitch(int witch)
{
//	Logic_RunScript("Msg(\"Bride Witch spawned by DZS\\n\")\;
//	function OnGameEvent_witch_harasser_set( params )
//	{
//		if (!(\"witchid\" in params)) { return\; }
//		local witch = EntIndexToHScript(params[\"witchid\"])\;
//		
//		if (\"userid\" in params)
//		{ local client = GetPlayerFromUserID(params[\"userid\"])\; }
//		
//		if (self && self.IsValid() && witch && witch.IsValid() && witch == self)
//		{ DoEntFire(FindByClassname(null, \"info_director\"), \"ForcePanicEvent\", \"\", 0.0, null, witch)\; }
//	}
//	__CollectEventCallbacks(this, \"OnGameEvent_\", \"GameEventCallbacks\", RegisterScriptGameEventListener)\;");

//	SetVariantString("Msg(\"Bride Witch spawned by DZS\\n\"); function OnGameEvent_witch_harasser_set( params ) { if (!(\"witchid\" in params)) { return; } local witch = EntIndexToHScript(params[\"witchid\"]); if (\"userid\" in params) { local client = GetPlayerFromUserID(params[\"userid\"]); } if (self && self.IsValid() && witch && witch.IsValid() && witch == self) { DoEntFire(FindByClassname(null, \"info_director\"), \"ForcePanicEvent\", \"\", 0.0, client, witch); } } __CollectEventCallbacks(this, \"OnGameEvent_\", \"GameEventCallbacks\", RegisterScriptGameEventListener);");
//	SetVariantString("function OnGameEvent_witch_harasser_set( params ) { if (!(\"witchid\" in params)) { return; } local witch = EntIndexToHScript(params[\"witchid\"]); if (self && self.IsValid() && witch && witch.IsValid() && witch == self) { DoEntFire(FindByClassname(null, \"info_director\"), \"ForcePanicEvent\", \"\", 0.0, client, witch); } } __CollectEventCallbacks(this, \"OnGameEvent_\", \"GameEventCallbacks\", RegisterScriptGameEventListener);");
//	AcceptEntityInput(witch, "RunScriptCode");
	SetVariantString("OnStartled info_director:ForcePanicEvent::0.0:1");
	AcceptEntityInput(witch, "AddOutput");
}*/

/*#define PLUGIN_SCRIPTLOGIC "plugin_scripting_logic_entity"

static int g_iScriptLogic = 0;

void Logic_RunScript(const char[] sCode, any ...) 
{
	int iScriptLogic = 0;
	if (!RealValidEntity(g_iScriptLogic))
	{
		iScriptLogic = FindEntityByTargetname(-1, PLUGIN_SCRIPTLOGIC);
		if (!RealValidEntity(iScriptLogic))
		{
			iScriptLogic = CreateEntityByName("logic_script");
			DispatchKeyValue(iScriptLogic, "targetname", PLUGIN_SCRIPTLOGIC);
			DispatchSpawn(iScriptLogic);
			g_iScriptLogic = iScriptLogic;
		}
	}
	else
	{
		iScriptLogic = g_iScriptLogic;
	}
	
	static char sBuffer[512]; 
	VFormat(sBuffer, sizeof(sBuffer), sCode, 2); 
	
	SetVariantString(sBuffer); 
	AcceptEntityInput(iScriptLogic, "RunScriptCode");
}

int FindEntityByTargetname(int index, const char[] findname, bool onlyNetworked = false)
{
	for (int i = index; i < (onlyNetworked ? GetMaxEntities() : (GetMaxEntities()*2)); i++) {
		if (!RealValidEntity(i)) continue;
		static char name[128];
		GetEntPropString(i, Prop_Data, "m_iName", name, sizeof(name));
		if (strcmp(name, findname, false) != 0) continue;
		return i;
	}
	return -1;
}*/

Action Timer_Chase(Handle timer, int inf_ref)
{
	int infected = EntRefToEntIndex(inf_ref);
	if (!RealValidEntity(infected)) return Plugin_Continue;
	static char class[9];
	GetEntityClassname(infected, class, sizeof(class));
	if (strcmp(class, "infected", false) != 0) return Plugin_Continue;
	
	SDKCall(hInfectedAttackSurvivorTeam, infected);
	return Plugin_Continue;
}

void RequestFrame_SetPos(DataPack data)
{
	data.Reset();
	float pos0 = data.ReadFloat();
	float pos1 = data.ReadFloat();
	float pos2 = data.ReadFloat();
	float ang1 = data.ReadFloat();
	int bot = GetClientOfUserId(data.ReadCell());
	delete data;
	if(!bot || !IsClientInGame(bot)) return;
	
	float pos[3];pos[0]=pos0;pos[1]=pos1;pos[2]=pos2;
	float ang[3];ang[0]=0.0;ang[1]=ang1;ang[2]=0.0;
	
	TeleportEntity(bot, pos, ang, NULL_VECTOR);
}

void GetGamedata()
{
	static char filePath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, filePath, sizeof(filePath), "gamedata/%s.txt", GAMEDATA);
	if ( FileExists(filePath) )
	{
		hConf = LoadGameConfigFile(GAMEDATA); // For some reason this doesn't return null even for invalid files, so check they exist first.
	}
	else
	{
		SetFailState("[SIN] Unable to get %s.txt gamedata file", GAMEDATA);
	}

	PrepSDKCall();

	delete hConf;
}

void LoadStringFromAdddress(Address addr, char[] buffer, int maxlength) {
	int i = 0;
	while(i < maxlength) {
		char val = LoadFromAddress(addr + view_as<Address>(i), NumberType_Int8);
		if(val == 0) {
			buffer[i] = 0;
			break;
		}
		buffer[i] = val;
		i++;
	}
	buffer[maxlength - 1] = 0;
}

Handle PrepCreateBotCallFromAddress(Handle hSiFuncTrie, const char[] siName) {
	Address addr;
	StartPrepSDKCall(SDKCall_Static);
	if (!GetTrieValue(hSiFuncTrie, siName, addr) || !PrepSDKCall_SetAddress(addr))
	{
		SetFailState("Unable to find NextBotCreatePlayer<%s> address in memory.", siName);
		return null;
	}
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	return EndPrepSDKCall();	
}

void PrepWindowsCreateBotCalls(Address jumpTableAddr) {
	Handle hInfectedFuncs = CreateTrie();
	// We have the address of the jump table, starting at the first PUSH instruction of the
	// PUSH mem32 (5 bytes)
	// CALL rel32 (5 bytes)
	// JUMP rel8 (2 bytes)
	// repeated pattern.
	
	// Each push is pushing the address of a string onto the stack. Let's grab these strings to identify each case.
	// "Hunter" / "Smoker" / etc.
	for(int i = 0; i < 7; i++) {
		// 12 bytes in PUSH32, CALL32, JMP8.
		Address caseBase = jumpTableAddr + view_as<Address>(i * 12);
		Address siStringAddr = view_as<Address>(LoadFromAddress(caseBase + view_as<Address>(1), NumberType_Int32));
		static char siName[32];
		LoadStringFromAdddress(siStringAddr, siName, sizeof(siName));

		Address funcRefAddr = caseBase + view_as<Address>(6); // 2nd byte of call, 5+1 byte offset.
		int funcRelOffset = LoadFromAddress(funcRefAddr, NumberType_Int32);
		Address callOffsetBase = caseBase + view_as<Address>(10); // first byte of next instruction after the CALL instruction
		Address nextBotCreatePlayerBotTAddr = callOffsetBase + view_as<Address>(funcRelOffset);
		//PrintToServer("Found NextBotCreatePlayerBot<%s>() @ %08x", siName, nextBotCreatePlayerBotTAddr);
		SetTrieValue(hInfectedFuncs, siName, nextBotCreatePlayerBotTAddr);
	}

	hCreateSmoker = PrepCreateBotCallFromAddress(hInfectedFuncs, "Smoker");
	if (hCreateSmoker == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateSmoker); return; }

	hCreateBoomer = PrepCreateBotCallFromAddress(hInfectedFuncs, "Boomer");
	if (hCreateBoomer == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateBoomer); return; }

	hCreateHunter = PrepCreateBotCallFromAddress(hInfectedFuncs, "Hunter");
	if (hCreateHunter == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateHunter); return; }

	hCreateTank = PrepCreateBotCallFromAddress(hInfectedFuncs, "Tank");
	if (hCreateTank == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateTank); return; }
	
	hCreateSpitter = PrepCreateBotCallFromAddress(hInfectedFuncs, "Spitter");
	if (hCreateSpitter == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateSpitter); return; }
	
	hCreateJockey = PrepCreateBotCallFromAddress(hInfectedFuncs, "Jockey");
	if (hCreateJockey == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateJockey); return; }

	hCreateCharger = PrepCreateBotCallFromAddress(hInfectedFuncs, "Charger");
	if (hCreateCharger == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateCharger); return; }

	delete hInfectedFuncs;
}

void PrepL4D2CreateBotCalls() {
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, NAME_CreateSpitter))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateSpitter); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateSpitter = EndPrepSDKCall();
	if (hCreateSpitter == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateSpitter); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, NAME_CreateJockey))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateJockey); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateJockey = EndPrepSDKCall();
	if (hCreateJockey == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateJockey); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, NAME_CreateCharger))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateCharger); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateCharger = EndPrepSDKCall();
	if (hCreateCharger == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateCharger); return; }
}

void PrepL4D1CreateBotCalls() 
{
	bool bLinuxOS = hConf.GetOffset("OS") != 0;
	if(bLinuxOS)
	{
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, NAME_CreateSmoker))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateSmoker); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateSmoker = EndPrepSDKCall();
		if (hCreateSmoker == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateSmoker); return; }

		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, NAME_CreateBoomer))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateBoomer); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateBoomer = EndPrepSDKCall();
		if (hCreateBoomer == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateBoomer); return; }

		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, NAME_CreateHunter))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateHunter); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateHunter = EndPrepSDKCall();
		if (hCreateHunter == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateHunter); return; }

		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, NAME_CreateTank))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateTank); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateTank = EndPrepSDKCall();
		if (hCreateTank == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateTank); return; }
	}
	else
	{
		Address addr;

		addr = RelativeJumpDestination(hConf.GetAddress(NAME_CreateSmoker_L4D1));
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetAddress(addr))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateSmoker_L4D1); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateSmoker = EndPrepSDKCall();
		if(hCreateSmoker == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateSmoker_L4D1); return; }

		addr = RelativeJumpDestination(hConf.GetAddress(NAME_CreateBoomer_L4D1));
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetAddress(addr))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateBoomer_L4D1); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateBoomer = EndPrepSDKCall();
		if(hCreateSmoker == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateBoomer_L4D1); return; }

		addr = RelativeJumpDestination(hConf.GetAddress(NAME_CreateHunter_L4D1));
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetAddress(addr))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateHunter_L4D1); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateHunter = EndPrepSDKCall();
		if(hCreateHunter == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateHunter_L4D1); return; }

		addr = RelativeJumpDestination(hConf.GetAddress(NAME_CreateTank_L4D1));
		StartPrepSDKCall(SDKCall_Static);
		if (!PrepSDKCall_SetAddress(addr))
		{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateTank_L4D1); return; }
		PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
		PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
		hCreateTank = EndPrepSDKCall();
		if(hCreateTank == null)
		{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateTank_L4D1); return; }
	}
}

Address RelativeJumpDestination(Address p)
{
	int offset = LoadFromAddress(p, NumberType_Int32);
	return p + view_as<Address>(offset + 4);
}

void PrepSDKCall()
{
	if (hConf == null)
	{ SetFailState("Unable to find %s.txt gamedata.", GAMEDATA); return; }
	
	Address replaceWithBot = GameConfGetAddress(hConf, ADDRESS_NAME);
	
	if (replaceWithBot != Address_Null && LoadFromAddress(replaceWithBot, NumberType_Int8) == 0x68) {
		// We're on L4D2 and linux
		PrepWindowsCreateBotCalls(replaceWithBot);
	}
	else
	{
		if (g_bLeft4Dead2)
		{
			PrepL4D2CreateBotCalls();
		}
		else
		{ delete hCreateSpitter; delete hCreateJockey; delete hCreateCharger; }
	
		PrepL4D1CreateBotCalls();
	}
	
	StartPrepSDKCall(SDKCall_Entity);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, NAME_InfectedAttackSurvivorTeam);
	hInfectedAttackSurvivorTeam = EndPrepSDKCall();
	if (hInfectedAttackSurvivorTeam == null)
	{ PrintToServer("WARNING: Cannot initialize %s SDKCall, signature is broken. Chase infected spawn is disabled.", NAME_InfectedAttackSurvivorTeam); }
}

bool IsValidClient(int client, bool replaycheck = true)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	//if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	if (replaycheck)
	{
		if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	}
	return true;
}

bool RealValidEntity(int entity)
{ return (entity > 0 && IsValidEntity(entity)); }

bool CheckIfEntitySafe(int entity)
{
	if(entity == -1) return false;

	if(	entity > ENTITY_SAFE_LIMIT)
	{
		RemoveEntity(entity);
		return false;
	}
	return true;
}