/*
 *	v1.0.0
 *
 *	1:初始版本发布.
 *
 *	v1.0.1
 *
 *	1:优化了一些代码.
 *
 *	v1.0.2
 *
 *	1:修复了一些问题.
 *
 *	v1.0.3
 *
 *	1:更改最大血量cvar后立即设置全部生还者最大血量.
 *	2:止痛药使用血量限制同步更改(设置的最大血量减1).
 *
 *	v1.1.4
 *
 *	1:精简一些无用代码.
 *	2:适配官方虚血模式.
 *
 *	v1.2.4
 *
 *	1:新增修复某些情况下禁止打包.
 *
 *	v1.3.4
 *
 *	1:优化了一些代码.
 *	2:新生还者加入设置血量和上限更改为给予物品时设置.
 *
 *	v1.4.4
 *
 *	1:添加cvar方便萌新使用此插件.
 *
 *	v1.5.5
 *
 *	1:修复忽略选项设置无效的问题.
 *	2:添加参数设置医疗包恢复百分比.
 *
 */
#pragma semicolon 1
//強制1.7以後的新語法
#pragma newdecls required
#include <sourcemod>
#include <dhooks>
#include <sdkhooks>

#define DEBUG		0		//0=禁用调试信息,1=显示调试信息.
#define GAMEDATA			"l4d2_max_health"
#define PLUGIN_VERSION		"1.5.5"
#define MAX_PLAYERS			32
#define CVAR_FLAGS			FCVAR_NOTIFY

ConVar 
	g_hAidHealPercent,
	g_hAdrenalineHealth, 
	g_hAidKitMaxHeal, 
	g_hPainPillsHealth, 
	g_hRespawnHealth,
	g_hReviveHealth, 
	g_hSurvivorPercent,
	g_hSurvivorBuffer,
	g_hSurvivorMaxHeal,
	g_hSurvivorPainPills,
	g_hSurvivorRespawn,
	g_hSurvivorRevive,
	g_hSurvivorThreshold;

bool 
	g_bStartRestore,
	g_bSpectator[MAX_PLAYERS+1],
	g_bMaxHealth[MAX_PLAYERS+1],
	g_bDataRestore[MAX_PLAYERS+1],
	g_bOnTakeOverBot[MAX_PLAYERS+1],
	g_bOnSetHumanSpectator[MAX_PLAYERS+1];

//定义插件信息.
public Plugin myinfo =  
{
	name = "l4d2_max_health",
	author = "豆瓣酱な",
	description = "自定义生还者最大血量",
	version = PLUGIN_VERSION,
	url = "N/A"
};
//插件开始时.
public void OnPluginStart()
{
	LoadingGameData();

	g_hSurvivorPercent = FindConVar("first_aid_heal_percent");//医疗包恢复百分比(默认:0.8).
	g_hSurvivorBuffer = FindConVar("adrenaline_health_buffer");//肾上腺素获得多少临时血量(默认值:25).
	g_hSurvivorMaxHeal = FindConVar("first_aid_kit_max_heal");//生还者最大血量上限(默认:100).
	g_hSurvivorPainPills = FindConVar("pain_pills_health_value");//止痛药获得多少临时血量(默认值:50).
	g_hSurvivorRespawn = FindConVar("z_survivor_respawn_health");//电击器或营救门复活血量(默认:50).
	g_hSurvivorRevive = FindConVar("survivor_revive_health");//生还者被救起后恢复的临时血量(默认:50).
	g_hSurvivorThreshold = FindConVar("pain_pills_health_threshold");//使用止痛药的血量限制(默认值:99).
	g_hSurvivorMaxHeal.AddChangeHook(ConVarMaxHealChanged);

	HookEvent("player_bot_replace", Event_PlayerBotReplace, EventHookMode_Pre);//电脑生还者替换玩家生还者.
	HookEvent("defibrillator_used", Event_DefibrillatorUsed, EventHookMode_Pre);//幸存者使用电击器救活队友.
	HookEvent("survivor_rescued", 	Event_SurvivorRescued, EventHookMode_Pre);//幸存者在营救门复活.

	g_hAidHealPercent = CreateConVar("l4d2_first_aid_heal_percent", 		"0.8", 	"Percent of injuries to heal with a first aid kit (def: 0.8, 0=Game default)", CVAR_FLAGS);
	g_hAdrenalineHealth = CreateConVar("l4d2_adrenaline_health_buffer", 	"50", 	"Temporary health with an adrenaline shot (def: 25, 0=Game default)", CVAR_FLAGS);
	g_hAidKitMaxHeal = CreateConVar("l4d2_first_aid_kit_max_heal", 			"300", 	"Max. survivor health set (def: 100, 0=Game default)", CVAR_FLAGS);
	g_hPainPillsHealth = CreateConVar("l4d2_pain_pills_health_value",	 	"100", 	"Temporary health with a pain pill (def: 50, 0=Game default)", CVAR_FLAGS);
	g_hRespawnHealth = CreateConVar("l4d2_z_survivor_respawn_health", 		"100", 	"How much health does a respawned survivor get if revived by a defibrillator or rescued in the closet (def: 50, 0=Game default)", CVAR_FLAGS);
	g_hReviveHealth = CreateConVar("l4d2_survivor_revive_health", 			"60", 	"How much temp health you get if revived from incapacitated. (def: 30, 0=Game default)", CVAR_FLAGS);
	
	g_hAidHealPercent.AddChangeHook(ConVarChangedAidHealPercent);
	g_hAdrenalineHealth.AddChangeHook(ConVarChangedSprayBigLotto);
	g_hAidKitMaxHeal.AddChangeHook(ConVarChangedAidKitMaxHeal);
	g_hPainPillsHealth.AddChangeHook(ConVarChangedPainPillsHealth);
	g_hReviveHealth.AddChangeHook(ConVarChangedReviveHealth);
	g_hRespawnHealth.AddChangeHook(ConVarChangedRespawnHealth);

	AutoExecConfig(true, "l4d2_max_health");//生成指定文件名的CFG.
}
//指定cvar更改时触发的回调.
public void ConVarMaxHealChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (strcmp(oldValue, newValue) != 0)
	{
		for (int i = 1; i <= MaxClients; i++)
			if (IsClientInGame(i) && GetClientTeam(i) == 2)
				SetEntProp(i, Prop_Data, "m_iMaxHealth", StringToInt(newValue));

		SetConVarInt(g_hSurvivorThreshold, StringToInt(newValue) - 1, false, false);//设置新的止痛药血量使用限制.
	}
		
	#if DEBUG
	PrintToChatAll("\x04[提示]\x03旧血量上限(%s),新血量上限(%s).", oldValue, newValue);//聊天窗提示.
	#endif
}
public void OnConfigsExecuted()
{
	if (g_hAidHealPercent.FloatValue != 0)
		g_hSurvivorPercent.FloatValue = g_hAidHealPercent.FloatValue;
	if (g_hAdrenalineHealth.IntValue != 0)
		g_hSurvivorBuffer.IntValue = g_hAdrenalineHealth.IntValue;
	if (g_hAidKitMaxHeal.IntValue != 0)
		g_hSurvivorMaxHeal.IntValue = g_hAidKitMaxHeal.IntValue;
	if (g_hPainPillsHealth.IntValue != 0)
		g_hSurvivorPainPills.IntValue = g_hPainPillsHealth.IntValue;
	if (g_hRespawnHealth.IntValue != 0)
		g_hSurvivorRespawn.IntValue = g_hRespawnHealth.IntValue;
	if (g_hReviveHealth.IntValue != 0)
		g_hSurvivorRevive.IntValue = g_hReviveHealth.IntValue;
}
//参数改变回调.
public void ConVarChangedAidHealPercent(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (g_hAidHealPercent.FloatValue != 0)
		g_hSurvivorPercent.FloatValue = g_hAidHealPercent.FloatValue;
}
//参数改变回调.
public void ConVarChangedSprayBigLotto(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (g_hAdrenalineHealth.IntValue != 0)
		g_hSurvivorBuffer.IntValue = g_hAdrenalineHealth.IntValue;
}
//参数改变回调.
public void ConVarChangedAidKitMaxHeal(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (g_hAidKitMaxHeal.IntValue != 0)
		g_hSurvivorMaxHeal.IntValue = g_hAidKitMaxHeal.IntValue;
}
//参数改变回调.
public void ConVarChangedPainPillsHealth(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (g_hPainPillsHealth.IntValue != 0)
		g_hSurvivorPainPills.IntValue = g_hPainPillsHealth.IntValue;
}
//参数改变回调.
public void ConVarChangedReviveHealth(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (g_hRespawnHealth.IntValue != 0)
		g_hSurvivorRespawn.IntValue = g_hRespawnHealth.IntValue;
}
//参数改变回调.
public void ConVarChangedRespawnHealth(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (g_hReviveHealth.IntValue != 0)
		g_hSurvivorRevive.IntValue = g_hReviveHealth.IntValue;
}
//加载签名文件.
void LoadingGameData()
{
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof buffer, "gamedata/%s.txt", GAMEDATA);
	if (!FileExists(buffer))
		SetFailState("\n==========\nMissing required file: \"%s\".\n==========", buffer);

	GameData hGameData = new GameData(GAMEDATA);
	if (!hGameData)
		SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);

	CreateDetour(hGameData, OnGoAwayFromKeyboard_Pre, "CTerrorPlayer::GoAwayFromKeyboard", false);
	CreateDetour(hGameData, OnGoAwayFromKeyboard_Post, "CTerrorPlayer::GoAwayFromKeyboard", true);

	CreateDetour(hGameData, OnSetHumanSpectator_Pre, "SurvivorBot::SetHumanSpectator", false);
	CreateDetour(hGameData, OnSetHumanSpectator_Post, "SurvivorBot::SetHumanSpectator", true);

	CreateDetour(hGameData, OnTakeOverBot_Pre, "CTerrorPlayer::TakeOverBot", false);
	CreateDetour(hGameData, OnTakeOverBot_Post, "CTerrorPlayer::TakeOverBot", true);

	CreateDetour(hGameData, OnPlayerSaveDataRestore_Pre, "PlayerSaveData::Restore", false);
	CreateDetour(hGameData, OnPlayerSaveDataRestore_Post, "PlayerSaveData::Restore", true);

	CreateDetour(hGameData, OnCDirectorRestart_Pre, "CDirector::Restart", false);
	CreateDetour(hGameData, OnCDirectorRestart_Post, "CDirector::Restart", true);

	CreateDetour(hGameData, OnCTerrorPlayerRoundRespawn_Post, "CTerrorPlayer::RoundRespawn", true);

	CreateDetour(hGameData,	OnTransitionRestore_Pre,	"CTerrorPlayer::TransitionRestore", false);
	CreateDetour(hGameData,	OnTransitionRestore_Post,	"CTerrorPlayer::TransitionRestore", true);

	CreateDetour(hGameData, MedStartAct_Pre,	"CFirstAidKit::ShouldStartAction",	false);
	//CreateDetour(hGameData, MedStartAct_Post,	"CFirstAidKit::ShouldStartAction",	true);

	CreateDetour(hGameData,	GiveDefaultItems_Pre,	"DD::CTerrorPlayer::GiveDefaultItems", false);
	//CreateDetour(hGameData,	GiveDefaultItems_Post,	"DD::CTerrorPlayer::GiveDefaultItems", true);

	//CreateDetour(hGameData, OnNextBotCreatePlayerBot_Pre, "NextBotCreatePlayerBot<SurvivorBot>", false);
	//CreateDetour(hGameData, OnNextBotCreatePlayerBot_Post, "NextBotCreatePlayerBot<SurvivorBot>", true);

	delete hGameData;
}
void CreateDetour(Handle gameData, DHookCallback CallBack, const char[] sName, const bool post)
{
	Handle hDetour = DHookCreateFromConf(gameData, sName);
	if(!hDetour)
		SetFailState("Failed to find \"%s\" signature.", sName);
		
	if(!DHookEnableDetour(hDetour, post, CallBack))
		SetFailState("Failed to detour \"%s\".", sName);
		
	delete hDetour;
}
public void OnMapStart() 
{
	for (int i = 1; i <= MaxClients; i++)
		ResetPlayerVariables(i);
}
//营救门复活队友.
void Event_SurvivorRescued(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("victim"));

	if(IsValidClient(client) && GetClientTeam(client) == 2)
	{
		SetPlayerHealth(client, GetConVarInt(g_hSurvivorRespawn));
		SetEntProp(client, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);

		#if DEBUG
		int iHealth = GetEntProp(client, Prop_Data, "m_iHealth");
		int iMaxHealth = GetEntProp(client, Prop_Data, "m_iMaxHealth");
		PrintToChatAll("\x04[营救门]\x05(%d)(%d/%d)(%N).", 
		client, iHealth, iMaxHealth, client);
		#endif
	}
}
//电击器救活队友.
void Event_DefibrillatorUsed(Event event, const char[] name, bool dontBroadcast)
{
	int subject = GetClientOfUserId(event.GetInt("subject"));

	if(IsValidClient(subject) && GetClientTeam(subject) == 2)
	{
		SetPlayerHealth(subject, GetConVarInt(g_hSurvivorRespawn));
		SetEntProp(subject, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);

		#if DEBUG
		int iHealth = GetEntProp(subject, Prop_Data, "m_iHealth");
		int iMaxHealth = GetEntProp(subject, Prop_Data, "m_iMaxHealth");
		PrintToChatAll("\x04[电击器]\x05(%d)(%d/%d)(%N).", 
		subject, iHealth, iMaxHealth, subject);
		#endif
	}
}
//即将创建电脑生还者时.
//MRESReturn OnNextBotCreatePlayerBot_Pre(DHookReturn hReturn, DHookParam hParams)
//{
//	return MRES_Ignored;//这个触发太早.
//}
//完成创建电脑生还者时.
//MRESReturn OnNextBotCreatePlayerBot_Post(DHookReturn hReturn, DHookParam hParams)
//{
//	int client = hReturn.Value;
//	return MRES_Ignored;//这个不能设置血量或上限.
//}
//给予玩家物品.
MRESReturn GiveDefaultItems_Pre(int pThis) 
{
	if(g_bStartRestore == true)//非还原数据时.
		return MRES_Ignored;
	
	if (pThis < 1 || pThis > MaxClients || !IsClientInGame(pThis))
		return MRES_Ignored;

	if (GetClientTeam(pThis) != 2 || !IsPlayerAlive(pThis) || ShouldIgnore(pThis))
		return MRES_Ignored;

	SetPlayerHealth(pThis, g_hSurvivorMaxHeal.IntValue);//闲置或加入旁观不影响.
	SetEntProp(pThis, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);

	#if DEBUG
	int iHealth = GetEntProp(pThis, Prop_Data, "m_iHealth");
	int iMaxHealth = GetEntProp(pThis, Prop_Data, "m_iMaxHealth");
	PrintToChatAll("\x04[给予Pre]\x05(%d)(%d/%d)(%N).", pThis, iHealth, iMaxHealth, pThis);
	#endif
	return MRES_Ignored;
}/*
//给予玩家物品.
MRESReturn GiveDefaultItems_Post(int pThis) 
{
	if(g_bStartRestore == true)
		return MRES_Ignored;
	
	if (pThis < 1 || pThis > MaxClients || !IsClientInGame(pThis))
		return MRES_Ignored;

	if (GetClientTeam(pThis) != 2 || !IsPlayerAlive(pThis) || ShouldIgnore(pThis))
		return MRES_Ignored;

	//SetPlayerHealth(pThis, g_hSurvivorMaxHeal.IntValue);
	//SetEntProp(pThis, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);

	#if DEBUG
	int iHealth = GetEntProp(pThis, Prop_Data, "m_iHealth");
	int iMaxHealth = GetEntProp(pThis, Prop_Data, "m_iMaxHealth");
	PrintToChatAll("\x04[给予Post]\x05(%d)(%d/%d)(%N).", pThis, iHealth, iMaxHealth, pThis);
	#endif
	return MRES_Ignored;
}*/
//玩家复活.
MRESReturn OnCTerrorPlayerRoundRespawn_Post(int pThis, DHookReturn hReturn) 
{
	if(g_bStartRestore == false)//非还原数据时.
	{
		SetPlayerHealth(pThis, g_hSurvivorMaxHeal.IntValue);
		SetEntProp(pThis, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);
	
		#if DEBUG
		PrintToChatAll("\x04[提示Post]\x03玩家复活(%d)(%N).", pThis, pThis);//聊天窗提示.
		#endif
	}
	return MRES_Ignored;
}
//任务失败开始还原数据时.
MRESReturn OnCDirectorRestart_Pre(Address pThis, DHookReturn hReturn) 
{
	g_bStartRestore = true;
	
	for (int i = 1; i <= MaxClients; i++)
		ResetPlayerVariables(i);

	#if DEBUG
	PrintToChatAll("\x04[重开Pre]\x03开始还原.");//聊天窗提示.
	#endif
	return MRES_Ignored;
}
//任务失败完成还原数据时.
MRESReturn OnCDirectorRestart_Post(Address pThis, DHookReturn hReturn) 
{
	g_bStartRestore = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == 2)
		{
			if(g_bMaxHealth[i] == false)
			{
				SetPlayerHealth(i, g_hSurvivorMaxHeal.IntValue);
				SetEntProp(i, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);

				#if DEBUG
				PrintToChatAll("\x04[重开Pre]\x05(%s)索引(%d)名称(%N)值(%s)没有数据.", IsFakeClient(i) ? "假" : "真", i, i, g_bMaxHealth[i] ? "true" : "false");
				#endif
			}
		}
	}

	#if DEBUG
	PrintToChatAll("\x04[重开Post]\x03完成还原.");//聊天窗提示.
	#endif
	return MRES_Ignored;
}
//真玩家数据开始还原.
MRESReturn OnTransitionRestore_Pre(int pThis, DHookReturn hReturn) 
{
	if(IsFakeClient(pThis))
		return MRES_Ignored;
	
	g_bMaxHealth[pThis] = true;
	g_bDataRestore[pThis] = true;

	#if DEBUG
	int iHealth = GetEntProp(pThis, Prop_Data, "m_iHealth");
	int iMaxHealth = GetEntProp(pThis, Prop_Data, "m_iMaxHealth");
	PrintToChatAll("\x04[还原Pre]\x05团队(%d)(%s)索引(%d)(%N)(%d/%d)(%s)开始还原.", GetClientTeam(pThis), IsFakeClient(pThis) ? "假" : "真", 
	pThis, pThis, iHealth, iMaxHealth, g_bMaxHealth[pThis] ? "true" : "false");
	#endif
	return MRES_Ignored;
}
//真玩家数据完成还原.
MRESReturn OnTransitionRestore_Post(int pThis, DHookReturn hReturn) 
{
	if(IsFakeClient(pThis))
		return MRES_Ignored;

	g_bDataRestore[pThis] = false;
	
	if(GetClientTeam(pThis) == 2)
		SetEntProp(pThis, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);//设置最大上限.
	
	#if DEBUG
	int iHealth = GetEntProp(pThis, Prop_Data, "m_iHealth");
	int iMaxHealth = GetEntProp(pThis, Prop_Data, "m_iMaxHealth");
	PrintToChatAll("\x04[还原Post]\x05团队(%d)(%s)索引(%d)(%N)(%d/%d)(%s)完成还原.", GetClientTeam(pThis), IsFakeClient(pThis) ? "假" : "真", 
	pThis, pThis, iHealth, iMaxHealth, g_bMaxHealth[pThis] ? "true" : "false");
	#endif
	return MRES_Ignored;
}
//假玩家过关后开始还原数据时.
MRESReturn OnPlayerSaveDataRestore_Pre(Address pThis, DHookParam hParams)
{
	int player = hParams.Get(1);
	if(!IsFakeClient(player))
		return MRES_Ignored;

	g_bMaxHealth[player] = true;
	g_bDataRestore[player] = true;

	#if DEBUG
	int iHealth = GetEntProp(player, Prop_Data, "m_iHealth");
	int iMaxHealth = GetEntProp(player, Prop_Data, "m_iMaxHealth");
	PrintToChatAll("\x04[还原Pre]\x05团队(%d)(%s)索引(%d)(%N)(%d/%d)(%s)开始还原.", GetClientTeam(player), IsFakeClient(player) ? "假" : "真", 
	player, player, iHealth, iMaxHealth, g_bMaxHealth[player] ? "true" : "false");
	#endif
	return MRES_Ignored;
}
//假玩家过关后完成还原数据时.
MRESReturn OnPlayerSaveDataRestore_Post(Address pThis, DHookParam hParams)
{
	int player = hParams.Get(1);
	if(!IsFakeClient(player))
		return MRES_Ignored;

	g_bDataRestore[player] = false;

	if(GetClientTeam(player) == 2)
		SetEntProp(player, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);//设置最大上限.
		
	#if DEBUG
	int iHealth = GetEntProp(player, Prop_Data, "m_iHealth");
	int iMaxHealth = GetEntProp(player, Prop_Data, "m_iMaxHealth");
	PrintToChatAll("\x04[还原Post]\x05团队(%d)(%s)索引(%d)(%N)(%d/%d)(%s)完成还原.", GetClientTeam(player), IsFakeClient(player) ? "假" : "真", 
	player, player, iHealth, iMaxHealth, g_bMaxHealth[player] ? "true" : "false");
	#endif
	return MRES_Ignored;
}
//玩家开始闲置.
MRESReturn OnGoAwayFromKeyboard_Pre(int pThis, DHookReturn hReturn)
{
	g_bSpectator[pThis] = true;//玩家开始闲置.
	#if DEBUG
	PrintToChatAll("\x04[提示Pre]\x05(%d)(%N)闲置.", pThis, pThis);
	#endif
	return MRES_Ignored;
}
//玩家完成闲置.
MRESReturn OnGoAwayFromKeyboard_Post(int pThis, DHookReturn hReturn) 
{
	g_bSpectator[pThis] = false;//玩家完成闲置.
	int iBot = iGetBotOfIdlePlayer(pThis);//闲置也能触发.
	if(iBot != 0)
		SetEntProp(iBot, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);
	
	#if DEBUG
	int iHealth = GetEntProp(iBot, Prop_Data, "m_iHealth");
	int iMaxHealth = GetEntProp(iBot, Prop_Data, "m_iMaxHealth");
	PrintToChatAll("\x04[闲置Post]\x05(%d)(%d)(%d)(%d/%d)(%N)(%N).", 
	GetClientTeam(pThis), pThis, iBot != 0 ? iBot : pThis, iHealth, iMaxHealth, pThis, iBot != 0 ? iBot : pThis);
	#endif
	return MRES_Ignored;
}
//电脑生还者接管玩家.
void Event_PlayerBotReplace(Event event, char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(event.GetInt("bot"));
	int player = GetClientOfUserId(event.GetInt("player"));
	if(IsValidClient(bot) && GetClientTeam(bot) == 2)
	{
		if(IsValidClient(player) && GetClientTeam(player) == 2)
		{
			if(g_bSpectator[player] == false)
			{
				SetEntProp(bot, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);

				#if DEBUG
				int iHealth = GetEntProp(bot, Prop_Data, "m_iHealth");
				int iMaxHealth = GetEntProp(bot, Prop_Data, "m_iMaxHealth");
				PrintToChatAll("\x04[替换]\x03索引(%d)(%d)(%d/%d)(%N)(%N)\x05电脑→玩家.", 
				bot, player, iHealth, iMaxHealth, bot, player);//聊天窗提示.
				#endif
			}
		}
	}
}
//接管电脑生还者.
MRESReturn OnSetHumanSpectator_Pre(int pThis, DHookParam hParams) 
{
	int iBot = IsClientIdle(pThis);//闲置也能触发.
	if(iBot != 0 && g_bOnTakeOverBot[iBot] == false && g_bDataRestore[iBot] == false && g_bSpectator[iBot] == false)
	{
		g_bOnSetHumanSpectator[iBot] = true;
		SetEntProp(pThis, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);//设置电脑生还者最大血量.

		#if DEBUG
		int iHealth = GetEntProp(pThis, Prop_Data, "m_iHealth");
		int iMaxHealth = GetEntProp(pThis, Prop_Data, "m_iMaxHealth");
		PrintToChatAll("\x04[接管Pre]\x05(%d)(%d)(%d/%d)(%N)(%N)值(%s)(%s).", 
		pThis, iBot, iHealth, iMaxHealth, pThis, iBot, g_bMaxHealth[pThis] ? "true" : "false", g_bMaxHealth[iBot] ? "true" : "false");
		#endif
	}
	return MRES_Ignored;
}
//接管电脑生还者.
MRESReturn OnSetHumanSpectator_Post(int pThis, DHookParam hParams) 
{
	int iBot = IsClientIdle(pThis);//闲置也能触发.
	if(iBot != 0 && g_bOnTakeOverBot[iBot] == false && g_bDataRestore[iBot] == false && g_bSpectator[iBot] == false)//还原数据和闲置时不执行. && iBot != pThis
	{
		if(g_bOnSetHumanSpectator[iBot] == false)
		{
			SetEntProp(pThis, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);//设置电脑生还者最大血量.

			#if DEBUG
			int iHealth = GetEntProp(pThis, Prop_Data, "m_iHealth");
			int iMaxHealth = GetEntProp(pThis, Prop_Data, "m_iMaxHealth");
			PrintToChatAll("\x04[接管Post]\x05(%d)(%d)(%d/%d)(%N)(%N)值(%s)(%s).", 
			pThis, iBot, iHealth, iMaxHealth, pThis, iBot, g_bMaxHealth[pThis] ? "true" : "false", g_bMaxHealth[iBot] ? "true" : "false");
			#endif
		}
		g_bOnSetHumanSpectator[iBot] = false;
	}
	return MRES_Ignored;
}
//加入生还者队伍.
MRESReturn OnTakeOverBot_Pre(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	int iBot = iGetBotOfIdlePlayer(pThis);//闲置也能触发.
	if(iBot != 0 && g_bDataRestore[iBot] == false && g_bSpectator[iBot] == false)//还原数据和闲置时不执行.
	{
		g_bOnTakeOverBot[pThis] = true;
		
		#if DEBUG
		int iHealth = GetEntProp(iBot, Prop_Data, "m_iHealth");
		int iMaxHealth = GetEntProp(iBot, Prop_Data, "m_iMaxHealth");
		PrintToChatAll("\x04[加入Pre]\x05团队(%d)(%d)名称(%N)(%N)索引(%d)(%d)血量(%d/%d)值(%s).", 
		GetClientTeam(iBot), GetClientTeam(pThis), iBot, pThis, iBot, pThis, iHealth, iMaxHealth, g_bMaxHealth[pThis] ? "true" : "false");
		#endif
	}
	return MRES_Ignored;
}
//加入生还者队伍.
MRESReturn OnTakeOverBot_Post(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if(GetClientTeam(pThis) == 2 && IsPlayerAlive(pThis) && g_bOnTakeOverBot[pThis] == true && g_bDataRestore[pThis] == false && g_bSpectator[pThis] == false)//还原数据和闲置时不执行.
	{
		SetEntProp(pThis, Prop_Data, "m_iMaxHealth", g_hSurvivorMaxHeal.IntValue);
		
		#if DEBUG
		int iHealth = GetEntProp(pThis, Prop_Data, "m_iHealth");
		int iMaxHealth = GetEntProp(pThis, Prop_Data, "m_iMaxHealth");
		PrintToChatAll("\x04[加入Post]\x05团队(%d)(%s)索引(%d)血量(%d/%d)名称(%N)值(%s).", 
		GetClientTeam(pThis), IsPlayerAlive(pThis) ? "活" : "死", pThis, iHealth, iMaxHealth, pThis, g_bMaxHealth[pThis] ? "true" : "false");
		#endif
	}
	g_bOnTakeOverBot[pThis] = false;
	return MRES_Ignored;
}
//开始治疗.
MRESReturn MedStartAct_Pre(Handle hReturn, Handle hParams)
{
	//int client = DHookGetParam(hParams, 2);//治愈者.
	int target = DHookGetParam(hParams, 3);//被治愈者.
	if( target > MaxClients || GetClientTeam(target) != 2 )	// Because shoving common infected or specials triggers this function
		return MRES_Ignored;
	
	if(!IsSurvivorsHealingStatus(target))
	{
		DHookSetReturn(hReturn, 0);
		#if DEBUG
		PrintToChatAll("\x04[治疗Pre]\x05(%N)阻止打包3.", target);
		#endif
		return MRES_Supercede;
	}
	if(!IsSurvivorsHealthStatus(target))
	{
		#if DEBUG
		PrintToChatAll("\x04[治疗Pre]\x05(%N)无需打包4.", target);
		#endif
		return MRES_Ignored;
	}
	return MRES_Ignored;
}
//判断生还者是否需要被治疗.
stock bool IsSurvivorsHealingStatus(int client)
{
	int iHealth = GetEntProp(client, Prop_Data, "m_iHealth");
	int iMaxHealth = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	
	int   iFirstAidKitMaxHeal 	= g_hSurvivorMaxHeal.IntValue;//最大血量上限.
	float fFirstAidHealPercent 	= g_hSurvivorPercent.FloatValue;//医疗包恢复比例.

	if (iFirstAidKitMaxHeal > iMaxHealth)
	{
		if (iHealth >= iMaxHealth)
		{
			#if DEBUG
			PrintToChatAll("\x04[治疗Pre]\x05(%N)(%d)(%d)(%d)血量大于上限(无需治疗).", client, iHealth, iMaxHealth, iFirstAidKitMaxHeal);
			#endif
			return false;
		}
		if (fFirstAidHealPercent < 1.0)
		{
			if(iHealth >= iMaxHealth - 1)
			{
				#if DEBUG
				PrintToChatAll("\x04[治疗Pre]\x05(%N)(%d)(%d)(%d)血量比例上限(无需治疗)(比例值<1).", client, iHealth, iMaxHealth, iFirstAidKitMaxHeal);
				#endif
				return false;
			}
		}
		else
		{
			if(iHealth >= iMaxHealth)
			{
				#if DEBUG
				PrintToChatAll("\x04[治疗Pre]\x05(%N)(%d)(%d)(%d)血量比例上限(无需治疗)(比例值=1).", client, iHealth, iMaxHealth, iFirstAidKitMaxHeal);
				#endif
				return false;
			}
		}
	}
	
	return true;
}
//获取生还者健康状态.
stock bool IsSurvivorsHealthStatus(int client)
{
	int iHealth = GetEntProp(client, Prop_Data, "m_iHealth");
	int iMaxHealth = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	
	int   iFirstAidKitMaxHeal 	= GetConVarInt(FindConVar("first_aid_kit_max_heal"));//最大血量上限.
	float fFirstAidHealPercent 	= GetConVarFloat(FindConVar("first_aid_heal_percent"));//医疗包恢复比例.

	if (iHealth > iFirstAidKitMaxHeal)
	{
		#if DEBUG
		PrintToChatAll("\x04[治疗Pre]\x05(%N)(%d)(%d)(%d)血量大于上限.", client, iHealth, iMaxHealth, iFirstAidKitMaxHeal);
		#endif
		return false;
	}
	if (iMaxHealth > iFirstAidKitMaxHeal)
		iMaxHealth = iFirstAidKitMaxHeal;

	if (fFirstAidHealPercent < 1.0)
	{
		if(iHealth >= iMaxHealth - 1)
		{
			#if DEBUG
			PrintToChatAll("\x04[治疗Pre]\x05(%N)(%d)(%d)(%d)血量等于属性上限(比例小于1.0).", client, iHealth, iMaxHealth, iFirstAidKitMaxHeal);
			#endif
			return false;
		}
	}
	else
	{
		if(iHealth >= iMaxHealth)
		{
			#if DEBUG
			PrintToChatAll("\x04[治疗Pre]\x05(%N)(%d)(%d)(%d)血量等于属性上限(比例等于1.0).", client, iHealth, iMaxHealth, iFirstAidKitMaxHeal);
			#endif
			return false;
		}
	}
	return true;
}
//过滤闲置时给予的准备和物品.
stock bool ShouldIgnore(int client) 
{
	if (IsFakeClient(client))
		return !!IsClientIdle(client);

	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientInGame(i) || !IsFakeClient(i) || GetClientTeam(i) != 1)
			continue;

		if (GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iTeam", _, i) == 2 && IsClientIdle(i) == client)
			return true;
	}

	return false;
}
//返回闲置玩家对应的电脑.
stock int iGetBotOfIdlePlayer(int client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == 2 && IsClientIdle(i) == client)
			return i;
	}
	return 0;
}
//返回电脑幸存者对应的玩家.
stock int IsClientIdle(int client)
{
	if (!HasEntProp(client, Prop_Send, "m_humanSpectatorUserID"))
		return 0;

	return GetClientOfUserId(GetEntProp(client, Prop_Send, "m_humanSpectatorUserID"));
}
//判断玩家有效.
stock bool IsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}
//重置玩家变量.
stock void ResetPlayerVariables(int client)
{
	g_bSpectator[client] = false;
	g_bMaxHealth[client] = false;
	g_bDataRestore[client] = false;
}
//设置生还者血量.
stock void SetPlayerHealth(int client, int health) 
{
	if(strcmp(GetGameModeName(), "mutation3", false) == 0)
	{
		SetPlayerTempHealth(client, 0); //防止有虚血时give health会超过上限的问题.
		SetPlayerTempHealth(client, health - GetEntProp(client, Prop_Data, "m_iHealth")); //防止有虚血时give health会超过上限的问题.
	}
	else
	{
		SetEntProp(client, Prop_Data, "m_iHealth", health);
		SetPlayerTempHealth(client, 0); //防止有虚血时give health会超过上限的问题.
	}
}
//设置虚血血量.
stock void SetPlayerTempHealth(int client, int tempHealth)
{
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", float(tempHealth));
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
}
//获取游戏模式名称.
stock char[] GetGameModeName()
{
	char sName[32];
	GetConVarString(FindConVar("mp_gamemode"), sName, sizeof(sName));
	return sName;
}