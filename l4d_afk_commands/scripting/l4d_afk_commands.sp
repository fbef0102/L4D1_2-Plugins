/*本插件用來防止玩家換隊濫用的Bug (離開安全區域才會生效)
* 禁止期間不能閒置、不能打指令換隊、亦不可按M換隊
* 有以下情況不能使用命令換隊，否則強制旁觀
* 1.嚇了Witch或被Witch抓倒期間禁止換隊 (防止Witch失去目標)
* 2.被特感抓住期間期間禁止換隊 (防止濫用特感控了無傷)
* 3.人類玩家死亡期間禁止換隊 (防止玩家故意死亡 然後跳隊裝B)
* 4.換隊成功之後，必須等待數秒才能再換隊 (防止玩家頻繁換隊洗頻伺服器)
* 5.離開安全區域或是生存模式計時開始一段時間之後，不得隨意換隊 (防止跳狗)
* 6.玩家點燃火瓶、汽油或油桶期間禁止換隊 (防止友傷bug、防止Witch失去目標)
* 7.玩家投擲火瓶、土製炸彈、膽汁期間禁止換隊 (防止友傷bug、防止Witch失去目標)
* 8.玩家武器裝彈期間禁止換隊 (防止快速隊伍切換省略裝彈時間)
* 9.特感玩家剛復活的期間禁止換隊 (防止切換特感)
* 10.特感玩家抓住了人類 (防止Jockey瞬移與Ghost Charger的爭議)
* 11.對抗/清道夫模式下檢查雙方隊伍的玩家數量，隊伍不平衡則不能換隊 (防止一方的玩家數量過多)
* 12.起身或硬直狀態中禁止換隊 (防止略過硬直狀態)
* 13.玩家發射榴彈期間禁止換隊 (防止友傷bug、防止Witch失去目標)
*
* Admin 功能
* 1.管理員可以強制玩家更換隊伍 "sm_swapto <player> <team>"
* 
**Change team to Spectate
	"sm_afk"
	"sm_s"
	"sm_away"
	"sm_idle"
	"sm_spectate"
	"sm_spec"
	"sm_spectators"
	"sm_joinspectators"
	"sm_joinspectator"
	"sm_jointeam1"
	
**Change team to Survivor
	"sm_join"
	"sm_bot"
	"sm_jointeam"
	"sm_survivors"
	"sm_survivor"
	"sm_sur"
	"sm_joinsurvivors"
	"sm_joinsurvivor"
	"sm_jointeam2"
	"sm_jg"
	"sm_takebot"
	"sm_takeover"
	
**Change team to Infected
	"sm_infected"
	"sm_inf"
	"sm_joininfected"
	"sm_joininfecteds"
	"sm_jointeam3"
	"sm_zombie"
	
**Switch team to fully an observer
	"sm_observer"
	"sm_ob"
	"sm_observe"

**Adm force player to change team
	"sm_swapto", "sm_swapto <player1> [player2] ... [playerN] <teamnum> - swap all listed players to <teamnum> (1,2, or 3)"
*/

/* Idiot - SilentBr (https://forums.alliedmods.net/member.php?u=46991)
* Finish the plugin request and then disappear, kept saying I'm busy and did not pay money
* spit this guy
* evidence: https://i.imgur.com/aLECLqz.jpg
*/

#define PLUGIN_VERSION 		"5.3-2024/10/9"
#define PLUGIN_NAME			"[L4D(2)] AFK and Join Team Commands Improved"
#define PLUGIN_AUTHOR		"MasterMe & HarryPotter"
#define PLUGIN_DES			"Adds commands to let the player spectate and join team. (!afk, !survivors, !infected, etc.), but no change team abuse"
#define PLUGIN_URL			"https://steamcommunity.com/profiles/76561198026784913"

#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <left4dhooks>

#undef REQUIRE_PLUGIN
#tryinclude <unscramble> //https://github.com/fbef0102/Game-Private_Plugin/tree/main/Plugin_%E6%8F%92%E4%BB%B6/Server_%E4%BC%BA%E6%9C%8D%E5%99%A8/l4d_team_unscramble/scripting/include/unscramble.inc

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DES,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

bool g_bLateLoad, g_bL4D2Version, g_Use_r2comp_unscramble = false;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	if( test == Engine_Left4Dead)
		g_bL4D2Version = false;
	else if (test == Engine_Left4Dead2 )
		g_bL4D2Version = true;
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;
	return APLRes_Success;
}

static const char WITCH_NAME[]		= "witch";

#define L4D_TEAM_NAME(%1) (%1 == 2 ? "Survivors" : (%1 == 3 ? "Infected" : (%1 == 1 ? "Spectators" : "Unknown")))
#define MODEL_CRATE				"models/props_junk/explosive_box001.mdl"
#define MODEL_GASCAN			"models/props_junk/gascan001a.mdl"
#define MODEL_BARREL			"models/props_industrial/barrel_fuel.mdl"

ConVar g_hZMaxPlayerZombies;

ConVar g_hCoolTime, g_hDeadSurvivorBlock, g_hGameTimeBlock, g_hSurvivorSuicideSeconds, g_hWeaponReloadBlock, g_hGetUpStaggerBlock, 
	g_hInfectedCapBlock, g_hInfectedAttackBlock, g_hWitchAttackBlock, g_hWPressMBlock, g_hImmuneAccess,
	g_hTakeABreakBlock, g_hSpecCommandAccess, g_hInfCommandAccess, g_hSurCommandAccess,
	g_hObsCommandAccess,
	g_hTakeControlBlock, g_hBreakPropCooldown, g_hThrowableBlock, g_hGrenadeBlock, g_hInfectedSpawnCooldown,
	g_hVSCommandBalance, g_hVSUnBalanceLimit;

//value
char g_sImmuneAcclvl[AdminFlags_TOTAL], g_sSpecCommandAccesslvl[AdminFlags_TOTAL], g_sInfCommandAccesslvl[AdminFlags_TOTAL], 
	g_sSurCommandAccesslvl[AdminFlags_TOTAL], g_sObsCommandAccesslvl[AdminFlags_TOTAL];
bool g_bDeadSurvivorBlock, g_bTakeControlBlock, g_bWeaponReloadBlock, g_bGetUpStaggerBlock, g_bThrowableBlock, g_bGrenadeBlock,
	g_bInfectedAttackBlock, g_bInfectedCapBlock,
	g_bWitchAttackBlock, g_bPressMBlock, g_bTakeABreakBlock, g_bVSCommandBalance;
float g_fBreakPropCooldown, g_fSurvivorSuicideSeconds, g_fInfectedSpawnCooldown;
int g_iCvarGameTimeBlock, g_iCountDownTime, g_iZMaxPlayerZombies, g_iVSUnBalanceLimit;

bool g_bHasLeftSafeRoom, g_bGameTeamSwitchBlock;

//arraylist
ArrayList 
	g_alClientAttackedByWitch[MAXPLAYERS+1], 	//每個玩家被多少個witch攻擊
	g_alClientThrowable[MAXPLAYERS+1], 			//每個玩家所投擲的投擲物entity
	g_alClientGrenade[MAXPLAYERS+1]; 			//每個玩家所發射的榴彈entity

StringMap
	g_smClientSwitchTeam; 			//玩家曾經待的隊伍 (1: 旁觀者, 2: 活著的倖存者, 3: 感染者)

//timer
int g_iRoundStart, g_iPlayerSpawn;
Handle PlayerLeftStartTimer, CountDownTimer,
	g_hInCoolDownTimer[MAXPLAYERS+1];//是否還有換隊冷卻時間

bool bClientJoinedTeam[MAXPLAYERS+1] = {false}; //在冷卻時間是否嘗試加入
float g_iSpectatePenaltTime[MAXPLAYERS+1] ;//各自的冷卻時間
float fBreakPropTime[MAXPLAYERS+1] ;//點燃火瓶、汽油或油桶的時間
//float fThrowableTime[MAXPLAYERS+1] ;//投擲物品的時間
float fInfectedSpawnTime[MAXPLAYERS+1] ;//特感重生復活的時間
float ClientJoinSurvivorTime[MAXPLAYERS+1] ;//加入倖存者隊伍的時間
float g_fCoolTime;
int clientteam[MAXPLAYERS+1];//玩家換隊成功之後的隊伍

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("l4d_afk_commands.phrases");

	RegConsoleCmd("sm_afk", TurnClientToSpectate);
	RegConsoleCmd("sm_s", TurnClientToSpectate);
	RegConsoleCmd("sm_away", TurnClientToSpectate);
	RegConsoleCmd("sm_idle", TurnClientToSpectate);
	RegConsoleCmd("sm_spectate", TurnClientToSpectate);
	RegConsoleCmd("sm_spec", TurnClientToSpectate);
	RegConsoleCmd("sm_spectators", TurnClientToSpectate);
	RegConsoleCmd("sm_joinspectators", TurnClientToSpectate);
	RegConsoleCmd("sm_joinspectator", TurnClientToSpectate);
	RegConsoleCmd("sm_jointeam1", TurnClientToSpectate);
	
	RegConsoleCmd("sm_jg", TurnClientToSurvivors);
	RegConsoleCmd("sm_join", TurnClientToSurvivors);
	RegConsoleCmd("sm_bot", TurnClientToSurvivors);
	RegConsoleCmd("sm_jointeam", TurnClientToSurvivors);
	RegConsoleCmd("sm_survivors", TurnClientToSurvivors);
	RegConsoleCmd("sm_survivor", TurnClientToSurvivors);
	RegConsoleCmd("sm_sur", TurnClientToSurvivors);
	RegConsoleCmd("sm_joinsurvivors", TurnClientToSurvivors);
	RegConsoleCmd("sm_joinsurvivor", TurnClientToSurvivors);
	RegConsoleCmd("sm_jointeam2", TurnClientToSurvivors);
	RegConsoleCmd("sm_takebot", TurnClientToSurvivors);
	RegConsoleCmd("sm_takeover", TurnClientToSurvivors);
	
	RegConsoleCmd("sm_infected", TurnClientToInfected);
	RegConsoleCmd("sm_infecteds", TurnClientToInfected);
	RegConsoleCmd("sm_inf", TurnClientToInfected);
	RegConsoleCmd("sm_joininfected", TurnClientToInfected);
	RegConsoleCmd("sm_jointeam3", TurnClientToInfected);
	RegConsoleCmd("sm_zombie", TurnClientToInfected);
	
	RegConsoleCmd("jointeam", jointeam); // press M
	AddCommandListener(go_away_from_keyboard, "go_away_from_keyboard"); //esc -> take a break
	RegConsoleCmd("sb_takecontrol", sb_takecontrol);  //sb_takecontrol

	AddCommandListener(CommandListener_SpecNext, "spec_next"); //監聽旁觀者的滑鼠左鍵.

	RegAdminCmd("sm_swapto", Command_SwapTo, ADMFLAG_BAN, "sm_swapto <player1> [player2] ... [playerN] <teamnum> - swap all listed players to <teamnum> (1,2, or 3)");
	RegConsoleCmd("sm_zs", ForceSurvivorSuicide, "Alive Survivor Suicide himself Command.");

	RegConsoleCmd("sm_observer", TurnClientToObserver, "Switch team to fully an observer.");
	RegConsoleCmd("sm_ob", TurnClientToObserver, "Switch team to fully an observer.");
	RegConsoleCmd("sm_observe", TurnClientToObserver, "Switch team to fully an observer.");

	g_hZMaxPlayerZombies = 		FindConVar("z_max_player_zombies");
	g_hCoolTime = 				CreateConVar("l4d_afk_commands_changeteam_cooltime_block", 		"10.0", "Cold Down Time in seconds a player can not change team again after he switches team. (0=off)", FCVAR_NOTIFY, true, 0.0);
	g_hDeadSurvivorBlock = 		CreateConVar("l4d_afk_commands_deadplayer_block", 				"1", 	"If 1, Dead Survivor player can not switch team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGameTimeBlock = 			CreateConVar("l4d_afk_commands_during_game_seconds_block", 		"0", 	"Player can not switch team after players have left start safe area for at least x seconds (0=off).", FCVAR_NOTIFY, true, 0.0);
	g_hInfectedAttackBlock = 	CreateConVar("l4d_afk_commands_infected_attack_block", 			"1", 	"If 1, Player can not change team when he is capped by special infected.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hWitchAttackBlock = 		CreateConVar("l4d_afk_commands_witch_attack_block", 			"1", 	"If 1, Player can not change team when he startle witch or being attacked by witch.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSurvivorSuicideSeconds = CreateConVar("l4d_afk_commands_suicide_allow_second", 			"30.0", "Allow alive survivor player suicide by using '!zs' after joining survivor team for at least X seconds.\n0=Disable !zs", FCVAR_NOTIFY, true, 0.0);
	g_hWeaponReloadBlock = 		CreateConVar("l4d_afk_commands_weapon_reload_block", 			"1", 	"If 1, Player can not change team when he is reloading the weapon.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGetUpStaggerBlock = 		CreateConVar("l4d_afk_commands_getup_stagger_block", 			"1", 	"If 1, Player can not change team while he is getting up or staggering.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hThrowableBlock = 		CreateConVar("l4d_afk_commands_throwable_block", 				"1", 	"If 1, Player can not change team after throwing molotov, pipe bomb or boomer juice. (0=off).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGrenadeBlock = 			CreateConVar("l4d_afk_commands_grenade_block", 					"1", 	"(L4D2) If 1, Player can not change team after firing the grenade launcher (0=off).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBreakPropCooldown = 		CreateConVar("l4d_afk_commands_igniteprop_cooltime_block", 		"15.0", "Cold Down Time in seconds a player can not change team after ignites molotov, gas can, firework crate or barrel fuel. (0=off).", FCVAR_NOTIFY, true, 0.0);
	g_hWPressMBlock = 			CreateConVar("l4d_afk_commands_pressM_block", 					"1", 	"If 1, Block player from using 'jointeam' command in console. (This also blocks player from switching team by choosing team menu)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hTakeABreakBlock = 		CreateConVar("l4d_afk_commands_takeabreak_block", 				"0", 	"If 1, Block player from using 'go_away_from_keyboard' command in console. (This also blocks player from going idle with 'esc->take a break')", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hTakeControlBlock = 		CreateConVar("l4d_afk_commands_takecontrol_block", 				"1", 	"If 1, Block player from using 'sb_takecontrol' command in console.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hInfectedCapBlock = 		CreateConVar("l4d_afk_commands_infected_cap_block", 			"1", 	"If 1, Infected player can not change team when he has pounced/ridden/charged/smoked a survivor.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hInfectedSpawnCooldown = 	CreateConVar("l4d_afk_commands_infected_spawn_cooltime_block", 	"10.0", "Cold Down Time in seconds an infected player can not change team after he is spawned as a special infected. (0=off).", FCVAR_NOTIFY, true, 0.0);
	g_hImmuneAccess = 			CreateConVar("l4d_afk_commands_immune_block_flag", 				"-1", 	"Players with these flags have immune to all 'block' limit (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	g_hSpecCommandAccess = 		CreateConVar("l4d_afk_commands_spec_access_flag", 				"", 	"Players with these flags have access to use command to spectator team. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	g_hInfCommandAccess = 		CreateConVar("l4d_afk_commands_infected_access_flag", 			"", 	"Players with these flags have access to use command to infected team. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	g_hSurCommandAccess = 		CreateConVar("l4d_afk_commands_survivor_access_flag", 			"", 	"Players with these flags have access to use command to survivor team. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	g_hObsCommandAccess = 		CreateConVar("l4d_afk_commands_observer_access_flag", 			"z", 	"Players with these flags have access to use command to be an observer. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	g_hVSCommandBalance = 		CreateConVar("l4d_afk_commands_versus_teams_balance_enable", 	"1", 	"If 1, Check team balance when player tries to use command to join survivor/infected team in versus/scavenge.\nIf team is unbanlance, will fail to join team!", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hVSUnBalanceLimit = 		CreateConVar("l4d_afk_commands_versus_teams_unbalance_limit", 	"2", 	"Teams are unbalanced when one team has this many more players than the other team in versus/scavenge.", FCVAR_NOTIFY, true, 1.0);
	AutoExecConfig(true, "l4d_afk_commands");

	GetCvars();
	g_hCoolTime.AddChangeHook(ConVarChanged_Cvars);
	g_hDeadSurvivorBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hGameTimeBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedAttackBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hWitchAttackBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorSuicideSeconds.AddChangeHook(ConVarChanged_Cvars);
	g_hWeaponReloadBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hGetUpStaggerBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedCapBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hWPressMBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hTakeControlBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hTakeABreakBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hBreakPropCooldown.AddChangeHook(ConVarChanged_Cvars);
	g_hThrowableBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hGrenadeBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedSpawnCooldown.AddChangeHook(ConVarChanged_Cvars);
	g_hImmuneAccess.AddChangeHook(ConVarChanged_Cvars);
	g_hSpecCommandAccess.AddChangeHook(ConVarChanged_Cvars);
	g_hInfCommandAccess.AddChangeHook(ConVarChanged_Cvars);
	g_hSurCommandAccess.AddChangeHook(ConVarChanged_Cvars);
	g_hObsCommandAccess.AddChangeHook(ConVarChanged_Cvars);
	g_hZMaxPlayerZombies.AddChangeHook(ConVarChanged_Cvars);
	g_hVSCommandBalance.AddChangeHook(ConVarChanged_Cvars);
	g_hVSUnBalanceLimit.AddChangeHook(ConVarChanged_Cvars);
	
	HookEvent("witch_harasser_set", OnWitchWokeup);
	HookEvent("round_start", Event_RoundStart);
	if(g_bL4D2Version) HookEvent("survival_round_start", Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //生存模式之下計時開始之時 (一代沒有此事件)
	else HookEvent("create_panic_event" , Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //一代生存模式之下計時開始觸發屍潮
	HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
	HookEvent("map_transition", Event_RoundEnd); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", Event_RoundEnd); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_team", Event_PlayerChangeTeam);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("break_prop",	Event_BreakProp,		EventHookMode_Pre);

	g_smClientSwitchTeam = new StringMap();

	for (int i = 1; i <= MaxClients; i++)
	{
		g_alClientAttackedByWitch[i] = new ArrayList();
		g_alClientThrowable[i] = new ArrayList();
		g_alClientGrenade[i] = new ArrayList();
	}

	if( g_bLateLoad )
	{
		for( int i = 1; i <= MaxClients; i++ )
		{
			if( IsClientInGame(i) && !IsFakeClient(i))
			{
				OnClientPutInServer(i);
			}
		}

		CreateTimer(0.5, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnAllPluginsLoaded()
{
	g_Use_r2comp_unscramble = LibraryExists("r2comp_unscramble");

}

public void OnPluginEnd()
{
	ResetClient();
	ResetTimer();
	ClearDefault();
	
	delete g_smClientSwitchTeam;
	for (int i = 1; i <= MaxClients; i++)
	{
		delete g_alClientAttackedByWitch[i];
		delete g_alClientThrowable[i];
		delete g_alClientGrenade[i];
	}
}

public void OnLibraryAdded(const char[] name)
{
	if(StrEqual(name, "r2comp_unscramble"))
		g_Use_r2comp_unscramble = true;
}

public void OnLibraryRemoved(const char[] name)
{
	if(StrEqual(name, "r2comp_unscramble"))
		g_Use_r2comp_unscramble = false;
}

public void OnMapStart()
{

}

public void OnMapEnd()
{
	ResetClient();
	ResetTimer();
	ClearDefault();

	g_smClientSwitchTeam.Clear();
}

Action Command_SwapTo(int client, int args)
{
	if (args < 2)
	{
		ReplyToCommand(client, "[SM] %T", "Usage: sm_swapto", client);
		return Plugin_Handled;
	}
	
	char teamStr[64];
	GetCmdArg(args, teamStr, sizeof(teamStr));
	int team = StringToInt(teamStr);
	if(0>=team||team>=4)
	{
		ReplyToCommand(client, "[SM] %T", "Invalid team Number", client, teamStr);
		return Plugin_Handled;
	}
	
	int player_id, player_team;

	char player[64];
	
	for(int i = 0; i < args - 1; i++)
	{
		GetCmdArg(i+1, player, sizeof(player));
		player_id = FindTarget(client, player, true /*nobots*/, false /*immunity*/);
		
		if(player_id == -1)
			continue;

		player_team = GetClientTeam(player_id);
		
		if(team == 1)
		{
			ChangeClientTeam(player_id, 1);
		}
		else if(team == 2)
		{
			if(player_team == 3) ChangeClientTeam(player_id, 1);
			else if(player_team == 2) continue;
			else if(player_team == 1 && IsClientIdle(player_id))
			{
				L4D_TakeOverBot(player_id);
				continue;
			}

			int bot = FindBotToTakeOver(true);
			if (bot==0)
			{
				bot = FindBotToTakeOver(false);
			}
			if (bot==0)
			{
				//ChangeClientTeam(player_id, 2);
				continue;
			}

			L4D_SetHumanSpec(bot, player_id);
			L4D_TakeOverBot(player_id);
		}
		else if (team == 3)
		{
			if(player_team == 3) continue;

			ChangeClientTeam(player_id, 3);
		}

			
		if(client != player_id) CPrintToChatAll("[{olive}TS{default}] %t", "ADM Swap Player Team", client, player_id, L4D_TEAM_NAME(team));
	}
	
	return Plugin_Handled;
}

Action ForceSurvivorSuicide(int client, int args)
{
	if (g_fSurvivorSuicideSeconds > 0.0 && client && GetClientTeam(client) == 2 && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		if(g_bHasLeftSafeRoom == false)
		{
			PrintHintText(client, "%T","You wish!",client);
			return Plugin_Handled;
		}

		if(GetInfectedAttacker(client) != -1)
		{
			PrintHintText(client, "%T","In your dreams!",client);
			return Plugin_Handled;
		}
		
		if( g_alClientAttackedByWitch[client].Length != 0 )
		{
			PrintHintText(client, "%T","Not on your life!",client);
			return Plugin_Handled;
		}

		if( GetEngineTime() - ClientJoinSurvivorTime[client] < g_fSurvivorSuicideSeconds)
		{
			PrintHintText(client, "%T","Not gonna happen!",client);
			return Plugin_Handled;
		}

		CPrintToChatAll("[{olive}TS{default}] %t","Suicide",client);
		ForcePlayerSuicide(client);
	}
	return Plugin_Handled;
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if(!victim || !IsClientAndInGame(victim)) return;

	delete g_alClientAttackedByWitch[victim];
	delete g_alClientThrowable[victim];
	delete g_alClientGrenade[victim];

	g_alClientAttackedByWitch[victim] = new ArrayList();
	g_alClientThrowable[victim] = new ArrayList();
	g_alClientGrenade[victim] = new ArrayList();
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;	

	int userid = event.GetInt("userid");
	int player = GetClientOfUserId(userid);
	if(player > 0 && player <= MaxClients && IsClientInGame(player) && !IsFakeClient(player))
	{
		if (GetClientTeam(player) == 2)
		{
			ClientJoinSurvivorTime[player] = GetEngineTime();
		}
		else if (GetClientTeam(player) == 3)
		{
			fInfectedSpawnTime[player] = GetEngineTime() + g_fInfectedSpawnCooldown;
		}
	}
}

void Event_BreakProp(Event event, const char[] name, bool dontBroadcast)
{
	char sTemp[42];
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!client || !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2) return;

	int entity = event.GetInt("entindex");
	GetEntityClassname(entity, sTemp, sizeof(sTemp));
	if( strncmp(sTemp, "prop_physics", 12) == 0 || strncmp(sTemp, "prop_fuel_barrel", 16) == 0)
	{
		GetEntPropString(entity, Prop_Data, "m_ModelName", sTemp, sizeof(sTemp));
		if( strcmp(sTemp, MODEL_CRATE) == 0 ||
			strcmp(sTemp, MODEL_GASCAN) == 0  || // only trigger gas can when not picked up yet
			strcmp(sTemp, MODEL_BARREL) == 0 )
		{
			if(g_fBreakPropCooldown > 0.0) fBreakPropTime[client] = GetEngineTime() + g_fBreakPropCooldown;
		}
	}
}

public void OnClientPutInServer(int client)
{
	ResetClient(client);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
	ResetClient(client);
}

Action OnTakeDamage(int victim, int &attacker, int  &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if(!IsClientAndInGame(victim) || GetClientTeam(victim) != 2) { return Plugin_Continue; }
	if(!IsWitch(attacker)) { return Plugin_Continue; }
	
	AddWitchAttack(attacker, victim);
	
	return Plugin_Continue;
}

void OnTakeDamageWitchPost(int witch, int attacker, int inflictor, float damage, int damagetype)
{
	if(attacker > 0 && attacker <= MaxClients && 
		IsClientInGame(attacker) && 
		!IsFakeClient(attacker) &&
		GetClientTeam(attacker) == 2 && 
		IsPlayerAlive(attacker))
	{
		if( damagetype & DMG_BLAST )
		{
			AddWitchAttack(witch, attacker);
		}
	}
}

void OnWitchWokeup(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	int witchid = event.GetInt("witchid");
	
	if(client > 0 && client <= MaxClients &&  IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2)
	{
		AddWitchAttack(witchid, client);
	}
}

public void OnEntityDestroyed(int entity)
{
	if(entity <= MaxClients || !IsValidEntity(entity))
		return;

	static char strClassName[64];
	GetEntityClassname(entity, strClassName, sizeof(strClassName));
	int index, ref = EntIndexToEntRef(entity);

	if(
		strClassName[0] == 'm' ||
		strClassName[0] == 'p' ||
		strClassName[0] == 'v' ||
		strClassName[0] == 'g'
	)
	{
		if(
			strncmp(strClassName, "molotov_projectile", 18) == 0 ||
			strncmp(strClassName, "pipe_bomb_projectile", 20) == 0 ||
			(g_bL4D2Version && strncmp(strClassName, "vomitjar_projectile", 19) == 0)
		)
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if( (index = g_alClientThrowable[client].FindValue(ref)) != -1)
				{
					g_alClientThrowable[client].Erase(index);
	
					break;
				}
			}
		}
		else if(g_bL4D2Version && strncmp(strClassName, "grenade_launcher_projectile", 27) == 0)
		{
			for(int client = 1; client <= MaxClients; client++)
			{
				if( (index = g_alClientGrenade[client].FindValue(ref)) != -1)
				{
					g_alClientGrenade[client].Erase(index);

					break;
				}
			}
		}
	}
	else if(strClassName[0] == 'w')
	{
		if(strcmp(strClassName, WITCH_NAME, false) == 0)
		{
			RemoveWitchAttack(entity);
		}
	}
}

void Event_PlayerChangeTeam(Event event, const char[] name, bool dontBroadcast) 
{
	CreateTimer(0.1, ClientReallyChangeTeam, event.GetInt("userid"), TIMER_FLAG_NO_MAPCHANGE); // check delay
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bDeadSurvivorBlock = g_hDeadSurvivorBlock.BoolValue;
	g_iCvarGameTimeBlock = g_hGameTimeBlock.IntValue;
	g_bInfectedAttackBlock = g_hInfectedAttackBlock.BoolValue;
	g_bWitchAttackBlock = g_hWitchAttackBlock.BoolValue;
	g_hSpecCommandAccess.GetString(g_sSpecCommandAccesslvl,sizeof(g_sSpecCommandAccesslvl));
	g_hInfCommandAccess.GetString(g_sInfCommandAccesslvl,sizeof(g_sInfCommandAccesslvl));
	g_hSurCommandAccess.GetString(g_sSurCommandAccesslvl,sizeof(g_sSurCommandAccesslvl));
	g_hObsCommandAccess.GetString(g_sObsCommandAccesslvl,sizeof(g_sObsCommandAccesslvl));
	g_hImmuneAccess.GetString(g_sImmuneAcclvl,sizeof(g_sImmuneAcclvl));
	g_fSurvivorSuicideSeconds = g_hSurvivorSuicideSeconds.FloatValue;
	g_bWeaponReloadBlock = g_hWeaponReloadBlock.BoolValue;
	g_bGetUpStaggerBlock = g_hGetUpStaggerBlock.BoolValue;
	g_bInfectedCapBlock = g_hInfectedCapBlock.BoolValue;
	g_bPressMBlock = g_hWPressMBlock.BoolValue;
	g_bTakeABreakBlock = g_hTakeABreakBlock.BoolValue;
	g_bTakeControlBlock = g_hTakeControlBlock.BoolValue;
	g_fCoolTime = g_hCoolTime.FloatValue;
	g_fBreakPropCooldown = g_hBreakPropCooldown.FloatValue;
	g_bThrowableBlock = g_hThrowableBlock.BoolValue;
	g_bGrenadeBlock = g_hGrenadeBlock.BoolValue;
	g_fInfectedSpawnCooldown = g_hInfectedSpawnCooldown.FloatValue;
	g_iZMaxPlayerZombies = g_hZMaxPlayerZombies.IntValue;
	g_bVSCommandBalance = g_hVSCommandBalance.BoolValue;
	g_iVSUnBalanceLimit = g_hVSUnBalanceLimit.IntValue;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	ResetTimer();
	ClearDefault();
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	delete g_smClientSwitchTeam;
	g_smClientSwitchTeam = new StringMap();
	
	ResetClient();

	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

void Event_SurvivalRoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	if(g_bHasLeftSafeRoom == true || L4D_GetGameModeType() != GAMEMODE_SURVIVAL) return;
	
	GameStart();
}

Action Timer_PluginStart(Handle timer)
{
	ClearDefault();

	if(L4D_GetGameModeType() != GAMEMODE_SURVIVAL)
	{
		delete PlayerLeftStartTimer;
		PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);
	}

	return Plugin_Continue;
}

Action Timer_PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea())
	{
		GameStart();

		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue; 
}

void GameStart()
{
	g_bHasLeftSafeRoom = true;
	g_iCountDownTime = g_iCvarGameTimeBlock;
	if(g_iCountDownTime > 0)
	{
		delete CountDownTimer;
		CountDownTimer = CreateTimer(1.0, Timer_CountDown, _, TIMER_REPEAT);
	}
}

Action Timer_CountDown(Handle timer)
{
	if(g_iCountDownTime <= 0) 
	{
		g_bGameTeamSwitchBlock = true;

		static char steamID[32];
		for(int client = 1; client <= MaxClients; client++)
		{
			if(!IsClientInGame(client)) continue;
			if(IsFakeClient(client)) continue;
			if(GetClientTeam(client) <= 1) continue;

			GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));
			g_smClientSwitchTeam.SetValue(steamID, GetClientTeam(client));
		}

		CountDownTimer = null;
		return Plugin_Stop;
	}

	g_iCountDownTime--;
	return Plugin_Continue;
}

void ResetClient(int client = -1)
{
	if(client == -1)
	{
		for(int i = 1; i <= MaxClients; i++)
		{	
			delete g_hInCoolDownTimer[i];
			bClientJoinedTeam[i] = false;
			clientteam[i] = 0;
			fBreakPropTime[i] = 0.0;
			//fThrowableTime[i] = 0.0;
			fInfectedSpawnTime[i] = 0.0;

			delete g_alClientAttackedByWitch[i];
			delete g_alClientThrowable[i];
			delete g_alClientGrenade[i];

			g_alClientAttackedByWitch[i] = new ArrayList();
			g_alClientThrowable[i] = new ArrayList();
			g_alClientGrenade[i] = new ArrayList();
		}
		g_bHasLeftSafeRoom = false;
		g_bGameTeamSwitchBlock = false;
	}	
	else
	{
		delete g_hInCoolDownTimer[client];
		bClientJoinedTeam[client] = false;
		clientteam[client] = 0;
		fBreakPropTime[client] = 0.0;
		//fThrowableTime[client] = 0.0;
		fInfectedSpawnTime[client] = 0.0;

		delete g_alClientAttackedByWitch[client];
		delete g_alClientThrowable[client];
		delete g_alClientGrenade[client];

		g_alClientAttackedByWitch[client] = new ArrayList();
		g_alClientThrowable[client] = new ArrayList();
		g_alClientGrenade[client] = new ArrayList();
	}

}

Action TurnClientToSpectate(int client, int argCount)
{
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}
	
	int iTeam = GetClientTeam(client);
	if (iTeam == 1 && IsClientIdle(client))
	{
		PrintHintText(client, "%T","Idle",client);
		return Plugin_Handled;
	}
	
	if(Is_AFK_COMMAND_Block()) return Plugin_Handled;
	
	if(HasAccess(client, g_sSpecCommandAccesslvl) == false)
	{
		PrintHintText(client, "%T","You don't have access to change team to spectator",client);
		return Plugin_Handled;
	}

	if(iTeam != 1)
	{
		if(CanClientChangeTeam(client,1) == false) return Plugin_Handled;
		
		if(iTeam == 2 && L4D_HasPlayerControlledZombies() == false)
		{
			if(IsPlayerAlive(client)) 
			{
				L4D_GoAwayFromKeyboard(client);
				clientteam[client] = 1;
				StartChangeTeamCoolDown(client);
				return Plugin_Handled;
			}
			else
			{
				ChangeClientTeam(client, 1);
			}
		}
		else ChangeClientTeam(client, 1);
		
		clientteam[client] = 1;
		StartChangeTeamCoolDown(client);
	}
	else
	{
		if(L4D_HasPlayerControlledZombies())
		{
			ChangeClientTeam(client, 3);
			CreateTimer(0.1, Timer_Respectate, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	return Plugin_Handled;
}

Action TurnClientToObserver(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}
	
	if(Is_AFK_COMMAND_Block()) return Plugin_Handled;
	
	if(HasAccess(client, g_sObsCommandAccesslvl) == false)
	{
		PrintHintText(client, "%T","You don't have access to be an observer",client);
		return Plugin_Handled;
	}

	if(GetClientTeam(client) != 1)
	{
		if(CanClientChangeTeam(client,1) == false) return Plugin_Handled;

		ChangeClientTeam(client, 1);
	}
	else
	{
		if(IsClientIdle(client))
		{
			L4D_TakeOverBot(client);
			ChangeClientTeam(client, 1);
			return Plugin_Handled;
		}
		
		ChangeClientTeam(client, 3);
		CreateTimer(0.1, Timer_Respectate, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Handled;
}

Action Timer_Respectate(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client && IsClientInGame(client))
		ChangeClientTeam(client, 1);

	return Plugin_Continue;
}

Action TurnClientToSurvivors(int client, int args)
{ 
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}

	int team = GetClientTeam(client);
	if (team == 2)			//if client is survivor
	{
		PrintHintText(client, "%T","You are already in survivor team.",client);
		return Plugin_Handled;
	}
	if (team == 1 && IsClientIdle(client))
	{
		PrintHintText(client, "%T","You are in idle, Press Left Mouse to play",client);
		return Plugin_Handled;
	}
	
	if(Is_AFK_COMMAND_Block()) return Plugin_Handled;
	
	if(HasAccess(client, g_sSurCommandAccesslvl) == false)
	{
		PrintHintText(client, "%T.","You don't have access to change team to survivor",client);
		return Plugin_Handled;
	}

	if(CanClientChangeTeam(client, 2) == false) return Plugin_Handled;
	
	int maxSurvivorSlots = GetTeamMaxSlots(2);
	int survivorUsedSlots = GetTeamHumanCount(2);
	int freeSurvivorSlots = (maxSurvivorSlots - survivorUsedSlots);
	int maxInfectedSlots = GetTeamMaxSlots(3);
	int infectedUsedSlots = GetTeamHumanCount(3);
	int freeInfectedSlots = (maxInfectedSlots - infectedUsedSlots);
	//PrintToChatAll("Number of Survivor Slots %d.\nNumber of Survivor Players %d.\nNumber of Free Slots %d.", maxSurvivorSlots, survivorUsedSlots, freeSurvivorSlots);
	
	//檢查平衡
	if(g_bVSCommandBalance && L4D_HasPlayerControlledZombies())
	{
		if(team <= 1)
		{
			if(survivorUsedSlots >= infectedUsedSlots + g_iVSUnBalanceLimit ) //特感比較少人
			{
				if(freeInfectedSlots > 0) //特感還有位子
				{
					PrintHintText(client, "%T", "Too many survivors, unbalance", client); 
					return Plugin_Handled;
				}
			}
			else if(survivorUsedSlots + g_iVSUnBalanceLimit <= infectedUsedSlots) //人類比較少人
			{
				//嘗試跳隊到倖存者
			}
			else //雙方隊伍數量相等
			{
				//嘗試跳隊到倖存者
			}
		}
		else
		{
			if(survivorUsedSlots >= infectedUsedSlots + g_iVSUnBalanceLimit ) //特感比較少人
			{
				PrintHintText(client, "%T", "Too many survivors, unbalance", client); 
				return Plugin_Handled;
			}
			else if(survivorUsedSlots + g_iVSUnBalanceLimit <= infectedUsedSlots) //人類比較少人
			{
				//嘗試跳隊到倖存者
			}
			else //雙方隊伍數量相等
			{
				//嘗試跳隊到倖存者
			}
		}
	}

	if (freeSurvivorSlots <= 0)
	{
		PrintHintText(client, "%T","Survivor team is full now.",client);
		return Plugin_Handled;
	}
	else
	{
		int bot = FindBotToTakeOver(true);
		if (bot==0)
		{
			bot = FindBotToTakeOver(false);
		}
		if (bot==0) return Plugin_Handled;
		
		if(L4D_HasPlayerControlledZombies() == false) //coop/survival
		{
			if(team == 3) ChangeClientTeam(client,1);

			if(IsPlayerAlive(bot))
			{
				L4D_SetHumanSpec(bot, client);
				SetEntProp(client, Prop_Send, "m_iObserverMode", 5);
			}
			else
			{
				L4D_SetHumanSpec(bot, client);
				L4D_TakeOverBot(client);	
				clientteam[client] = 2;	
				StartChangeTeamCoolDown(client);
			}
		}
		else //versus
		{
			if(team == 3) ChangeClientTeam(client,1);

			L4D_SetHumanSpec(bot, client);
			L4D_TakeOverBot(client);	
			clientteam[client] = 2;	
			StartChangeTeamCoolDown(client);
		}
	}
	return Plugin_Handled;
}

Action TurnClientToInfected(int client, int args)
{ 
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}

	if(L4D_HasPlayerControlledZombies() == false)
	{
		return Plugin_Handled;
	}

	int team = GetClientTeam(client);
	if (team == 3)			//if client is Infected
	{
		PrintHintText(client, "%T","You are already in infected team.",client);
		return Plugin_Handled;
	}
	
	if(Is_AFK_COMMAND_Block()) return Plugin_Handled;
	
	if(HasAccess(client, g_sInfCommandAccesslvl) == false)
	{
		PrintHintText(client, "%T","You don't have access to change team to Infected",client);
		return Plugin_Handled;
	}

	if(CanClientChangeTeam(client, 3) == false) return Plugin_Handled;

	int maxSurvivorSlots = GetTeamMaxSlots(2);
	int survivorUsedSlots = GetTeamHumanCount(2);
	int freeSurvivorSlots = (maxSurvivorSlots - survivorUsedSlots);
	int maxInfectedSlots = GetTeamMaxSlots(3);
	int infectedUsedSlots = GetTeamHumanCount(3);
	int freeInfectedSlots = (maxInfectedSlots - infectedUsedSlots);

	//檢查平衡
	if(g_bVSCommandBalance && L4D_HasPlayerControlledZombies())
	{
		if(team <= 1)
		{
			if(survivorUsedSlots >= infectedUsedSlots + g_iVSUnBalanceLimit ) //特感比較少人
			{
				//嘗試跳隊到特感
			}
			else if(survivorUsedSlots + g_iVSUnBalanceLimit <= infectedUsedSlots) //人類比較少人
			{
				if(freeSurvivorSlots > 0) //人類還有位子
				{
					PrintHintText(client, "%T", "Too many infected, unbalance", client); 
					return Plugin_Handled;
				}
			}
			else //雙方隊伍數量相等
			{
				//嘗試跳隊到特感
			}
		}
		else
		{
			if(survivorUsedSlots >= infectedUsedSlots + g_iVSUnBalanceLimit ) //特感比較少人
			{
				//嘗試跳隊到特感
			}
			else if(survivorUsedSlots + g_iVSUnBalanceLimit <= infectedUsedSlots) //人類比較少人
			{
				PrintHintText(client, "%T", "Too many infected, unbalance", client); 
				return Plugin_Handled;
			}
			else //雙方隊伍數量相等
			{
				//嘗試跳隊到特感
			}
		}
	}

	if (freeInfectedSlots <= 0)
	{
		PrintHintText(client, "%T","Infected team is full now.",client);
		return Plugin_Handled;
	}

	if(team == 2) ChangeClientTeam(client, 1);

	ChangeClientTeam(client, 3);
	clientteam[client] = 3;
	
	StartChangeTeamCoolDown(client);
	
	return Plugin_Handled;
}

int GetTeamMaxSlots(int team)
{
	int teammaxslots = 0;
	if(team == 2)
	{
		for(int i = 1; i < (MaxClients + 1); i++)
		{
			if(IsClientInGame(i) && GetClientTeam(i) == team)
			{
				teammaxslots++;
			}
		}
	}
	else if (team == 3)
	{
		return g_iZMaxPlayerZombies;
	}
	
	return teammaxslots;
}
int GetTeamHumanCount(int team)
{
	int humans = 0;
	int iTeam;
	for(int i = 1; i < (MaxClients + 1); i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			iTeam = GetClientTeam(i);
			if(iTeam == 1 && team == 2)
			{
				if(IsClientIdle(i)) humans++;
			}
			else if (iTeam == team)
			{
				humans++;
			}
		}
	}
	
	return humans;
}


bool IsInteger(char[] buffer)
{
    int len = strlen(buffer);
    for (int i = 0; i < len; i++)
    {
        if ( !IsCharNumeric(buffer[i]) )
            return false;
    }

    return true;    
}

Action jointeam(int client, int args) //press m (jointeam)
{
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}

	if(!IsClientInGame(client)) return Plugin_Continue;
	if(Is_AFK_COMMAND_Block()) return Plugin_Handled;

	if(args > 2) return Plugin_Handled;

	bool bHaveAccess = HasAccess(client, g_sImmuneAcclvl);
	if(g_bPressMBlock == true && bHaveAccess == false) 
	{
		PrintHintText(client, "%T","This function has been blocked!",client);	
		return Plugin_Handled;
	}

	if(args == 2)
	{
		char arg1[64];
		GetCmdArg(1, arg1, 64);
		char arg2[64];
		GetCmdArg(2, arg2, 64);
		if(StrEqual(arg1,"2") &&
			(StrEqual(arg2,"Nick") ||
			 StrEqual(arg2,"Ellis") ||
			 StrEqual(arg2,"Rochelle") ||
			 StrEqual(arg2,"Coach") ||
			 StrEqual(arg2,"Bill") ||
			 StrEqual(arg2,"Zoey") ||
			 StrEqual(arg2,"Francis") ||
			 StrEqual(arg2,"Louis") 
			)
		)
		{	
			if(g_bHasLeftSafeRoom == false) return Plugin_Continue;
			if(CanClientChangeTeam(client, 2, bHaveAccess)  == false) return Plugin_Handled;
			return Plugin_Continue;
		}
		ReplyToCommand(client, "Usage: jointeam 2 <character_name>");	
		return Plugin_Handled;
	}
	
	char arg1[64];
	GetCmdArg(1, arg1, 64);
	if(IsInteger(arg1))
	{
		int iteam = StringToInt(arg1);
		if(iteam == 2)
		{
			TurnClientToSurvivors(client,0);
			return Plugin_Handled;
		}
		else if(iteam == 3)
		{
			TurnClientToInfected(client,0);
			return Plugin_Handled;
		}
		else if(iteam == 1)
		{
			TurnClientToSpectate(client,0);
			return Plugin_Handled;
		}
		ReplyToCommand(client, "Usage: jointeam <1,2,3>");
		return Plugin_Handled;
	}
	else
	{
		if(strcmp(arg1, "Survivor", false) == 0)
		{
			TurnClientToSurvivors(client,0);
			return Plugin_Handled;
		}
		else if(strcmp(arg1, "Infected", false) == 0)
		{
			TurnClientToInfected(client,0);
			return Plugin_Handled;
		}

		ReplyToCommand(client, "Usage: jointeam <Survivor|Infected>");
		return Plugin_Handled;
	}
}

Action go_away_from_keyboard(int client, const char[] command, int args) //esc->take a break (go_away_from_keyboard)
{
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}

	if(!IsClientInGame(client)) return Plugin_Continue;

	if (GetClientTeam(client) == 1)
	{
		if(IsClientIdle(client))
		{
			PrintHintText(client, "%T","Idle",client);
		}
		
		return Plugin_Handled;
	}

	if (GetClientTeam(client) == 3)			//if client is Infected
	{
		PrintHintText(client, "%T","Infected can't go idle",client);
		return Plugin_Handled;
	}
	
	if(Is_AFK_COMMAND_Block()) return Plugin_Handled;
	
	bool bHaveAccess = HasAccess(client, g_sImmuneAcclvl);
	if(g_bTakeABreakBlock == true && bHaveAccess == false) 
	{
		PrintHintText(client, "%T","This function has been blocked!",client);	
		return Plugin_Handled;
	}

	if(g_bHasLeftSafeRoom == false) return Plugin_Continue;
	if(CanClientChangeTeam(client, 1, bHaveAccess) == false) return Plugin_Handled;
	
	CreateTimer(0.1, Time_go_away_from_keyboard, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

Action Time_go_away_from_keyboard(Handle timer, any iUserID)
{
	int client = GetClientOfUserId(iUserID);
	
	if(!client || !IsClientInGame(client) || IsFakeClient(client))
		return Plugin_Continue;

	if(GetClientTeam(client) == 1)
	{
		if(IsClientIdle(client))
		{
			clientteam[client] = 1;
			StartChangeTeamCoolDown(client);
		}
		else
		{
			clientteam[client] = 1;
			StartChangeTeamCoolDown(client);
		}
	}	

	return Plugin_Continue;
}

Action sb_takecontrol(int client, int args) //sb_takecontrol
{
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}

	if(!IsClientInGame(client)) return Plugin_Continue;
	if(Is_AFK_COMMAND_Block()) return Plugin_Handled;

	if(args > 1) return Plugin_Handled;

	bool bHaveAccess = HasAccess(client, g_sImmuneAcclvl);
	if(g_bTakeControlBlock == true && bHaveAccess == false) 
	{
		ReplyToCommand(client, "[TS] %T","This function has been blocked!",client);	
		return Plugin_Handled;
	}

	if(args == 1)
	{
		char arg1[64];
		GetCmdArg(1, arg1, 64);
		if(StrEqual(arg1,"Nick") ||
			 StrEqual(arg1,"Ellis") ||
			 StrEqual(arg1,"Rochelle") ||
			 StrEqual(arg1,"Coach") ||
			 StrEqual(arg1,"Bill") ||
			 StrEqual(arg1,"Zoey") ||
			 StrEqual(arg1,"Francis") ||
			 StrEqual(arg1,"Louis") 
		)
		{
			if(CanClientChangeTeam(client, 2, bHaveAccess) == false) return Plugin_Handled;
			return Plugin_Continue;
		}
		ReplyToCommand(client, "Usage: sb_takecontrol <character_name>");	
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

//閒置狀態按下滑鼠左鍵準備取代bot遊玩
Action CommandListener_SpecNext(int client, char[] command, int argc)
{
	if(client && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 1)
	{
		if(IsClientIdle(client))
		{
			if(HasAccess(client, g_sImmuneAcclvl))return Plugin_Continue;

			if(g_hInCoolDownTimer[client] != null)
			{
				bClientJoinedTeam[client] = true;
				PrintHintText(client, "%T", "Idle Wait" , client, g_iSpectatePenaltTime[client]);
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

bool IsClientAndInGame(int index)
{
	if (index > 0 && index <= MaxClients)
	{
		return IsClientInGame(index);
	}
	return false;
}

bool IsClientIdle(int client)
{
	if(GetClientTeam(client) != 1)
		return false;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			if(HasEntProp(i, Prop_Send, "m_humanSpectatorUserID"))
			{
				if(GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID")) == client)
					return true;
			}
		}
	}
	return false;
}

int FindBotToTakeOver(bool alive)
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i)==2 && !HasIdlePlayer(i) && IsPlayerAlive(i) == alive)
		{
			iClients[iClientCount++] = i;
		}
	}

	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

bool HasIdlePlayer(int bot)
{
	if(IsClientInGame(bot) && IsFakeClient(bot) && GetClientTeam(bot) == 2 && IsPlayerAlive(bot))
	{
		if(HasEntProp(bot, Prop_Send, "m_humanSpectatorUserID"))
		{
			if(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID") > 0)
			{
				return true;
			}
		}
	}
	return false;
}

bool CanClientChangeTeam(int client, int changeteam = 0, bool bIsAdm = false)
{ 
	if(g_bHasLeftSafeRoom == false || bIsAdm || HasAccess(client, g_sImmuneAcclvl)) return true;

	int team = GetClientTeam(client);

	if(g_hInCoolDownTimer[client] != null)
	{
		bClientJoinedTeam[client] = true;
		CPrintToChat(client, "[{olive}TS{default}] %T","Please wait",client, g_iSpectatePenaltTime[client]);
		return false;
	}

	if((g_bGameTeamSwitchBlock == true && g_iCvarGameTimeBlock > 0) && g_bHasLeftSafeRoom && GetClientTeam(client) != 1 && changeteam != 1) 
	{
		CPrintToChat(client, "[{olive}TS{default}] %T","Can not change team during the game!!",client);
		return false;
	}

	if(team == 2)
	{
		if ( GetInfectedAttacker(client) != -1 && g_bInfectedAttackBlock == true)
		{
			PrintHintText(client, "%T","Infected Attack Block",client);
			return false;
		}	
		
		if( g_bWitchAttackBlock == true && g_alClientAttackedByWitch[client].Length > 0)
		{
			PrintHintText(client, "%T","Witch Attack Block",client);
			return false;
		}

		if( g_fBreakPropCooldown > 0.0 && (fBreakPropTime[client] - GetEngineTime() > 0.0) )
		{
			PrintHintText(client, "%T", "Can not change team after ignite",client);
			return false;
		}

		if( g_bThrowableBlock && g_alClientThrowable[client].Length > 0 )
		{
			PrintHintText(client, "%T","Can not change team after throw",client);
			return false;	
		}

		if( g_bL4D2Version && g_bGrenadeBlock && g_alClientGrenade[client].Length > 0 )
		{
			PrintHintText(client, "%T","Can not change team after grenade",client);
			return false;	
		}

		if(g_bDeadSurvivorBlock == true && IsPlayerAlive(client) == false)
		{
			PrintHintText(client, "%T","Can not change team as dead survivor",client);
			return false;
		}
		
		if(g_bWeaponReloadBlock == true && IsPlayerAlive(client))
		{
			int iActiveWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if (iActiveWeapon > MaxClients && IsValidEntity(iActiveWeapon)) {
				if(GetEntProp(iActiveWeapon, Prop_Send, "m_bInReload")) //Survivor reloading
				{
					PrintHintText(client, "%T","Can not change team while reloading weapon",client);
					return false;
				}
			}
		}

		if ( g_bGetUpStaggerBlock && IsPlayerAlive(client) && (IsGettingUpOrStumble(client) || L4D_IsPlayerStaggering(client)) )
		{
			PrintHintText(client, "%T", "Get Up Stagger Block", client);
			return false;
		}
	}
	else if(team == 3)
	{
		if(GetSurvivorVictim(client)!= -1 && g_bInfectedCapBlock == true)
		{
			PrintHintText(client, "%T","Infected Cap Block",client);
			return false;
		}

		if( g_fInfectedSpawnCooldown > 0.0 && (fInfectedSpawnTime[client] - GetEngineTime() > 0.0) && IsPlayerAlive(client) && !IsPlayerGhost(client))
		{
			PrintHintText(client, "%T","Can not change team after Spawn as a special infected",client);
			return false;	
		}
	}
	
	return true;
}

void StartChangeTeamCoolDown(int client)
{
	if( IsFakeClient(client) 
	|| g_bHasLeftSafeRoom == false 
	|| g_hInCoolDownTimer[client] != null
	|| HasAccess(client, g_sImmuneAcclvl)) return;
	
	if(g_fCoolTime > 0.0)
	{
		g_iSpectatePenaltTime[client] = g_fCoolTime;
		delete g_hInCoolDownTimer[client];
		g_hInCoolDownTimer[client] = CreateTimer(0.25, Timer_CanJoin, client, TIMER_REPEAT);
	}
}

Action ClientReallyChangeTeam(Handle timer, int usrid)
{
	int client = GetClientOfUserId(usrid);
	if(!IsClientAndInGame(client) || IsFakeClient(client)) return Plugin_Continue;

	int newteam = GetClientTeam(client);
	bool bIdle = IsClientIdle(client);
	switch(newteam)
	{
		case 1:
		{
			if(!bIdle) CleanUpStateAndMusic(client);
		}
		case 2:
		{
			ClientJoinSurvivorTime[client] = GetEngineTime();
		}
	}

	if(HasAccess(client, g_sImmuneAcclvl)) return Plugin_Continue;

	if(g_bGameTeamSwitchBlock == true && g_iCvarGameTimeBlock > 0)
	{
		if(newteam >= 2)
		{
			static char steamID[32];
			GetClientAuthId(client, AuthId_SteamID64, steamID, sizeof(steamID));

			int oldteam;
			if(g_smClientSwitchTeam.GetValue(steamID, oldteam) == true)
			{
				//PrintToChatAll("%N newteam: %d, oldteam: %d",client,newteam,oldteam);
				if(newteam != oldteam)
				{
					ChangeClientTeam(client,1);
					CPrintToChat(client,"[{olive}TS{default}] %T","Go Back Your Team",client,(oldteam == 3) ? "Infected" : "Survivor");
					
					return Plugin_Continue;
				}
			}

			g_smClientSwitchTeam.SetValue(steamID, newteam);
		}
	}
	
	if(g_bHasLeftSafeRoom && g_hInCoolDownTimer[client] != null) return Plugin_Continue;
	
	//PrintToChatAll("client: %N change Team: %d newteam:%d",client,newteam,clientteam[client]);
	if(newteam != clientteam[client])
	{ 
		if(newteam == 1 && bIdle) return Plugin_Continue;

		if(clientteam[client] != 0) StartChangeTeamCoolDown(client);
		clientteam[client] = newteam;		
	}

	return Plugin_Continue;
}

Action Timer_CanJoin(Handle timer, int client)
{
	if (!IsClientInGame(client))
	{
		g_hInCoolDownTimer[client] = null;
		return Plugin_Stop;
	}

	int team = GetClientTeam(client);
	
	if (g_iSpectatePenaltTime[client] != 0)
	{
		g_iSpectatePenaltTime[client]-=0.25;
		if(team >= 2 && team != clientteam[client])
		{	
			bClientJoinedTeam[client] = true;
			CPrintToChat(client, "[{olive}TS{default}] %T","Please wait",client, g_iSpectatePenaltTime[client]);
			ChangeClientTeam(client, 1);clientteam[client]=1;
			return Plugin_Continue;
		}
	}
	else if (g_iSpectatePenaltTime[client] <= 0)
	{
		if(team >= 2 && team != clientteam[client])
		{	
			bClientJoinedTeam[client] = true;
			CPrintToChat(client, "[{olive}TS{default}]] %T","Please wait",client, g_iSpectatePenaltTime[client]);
			ChangeClientTeam(client, 1); clientteam[client]=1;
		}
		if (bClientJoinedTeam[client])
		{
			PrintHintText(client, "%T","You can change team now.",client);	//only print this hint text to the spectator if he tried to join team, and got swapped before
		}

		bClientJoinedTeam[client] = false;
		g_iSpectatePenaltTime[client] = g_fCoolTime;
		g_hInCoolDownTimer[client] = null;
		return Plugin_Stop;
	}
	
	
	return Plugin_Continue;
}

int GetInfectedAttacker(int client)
{
	int attacker;

	if(g_bL4D2Version)
	{
		/* Charger */
		attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
		if (attacker > 0)
		{
			return attacker;
		}

		attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
		if (attacker > 0)
		{
			return attacker;
		}

		attacker = L4D2_GetQueuedPummelAttacker(client);
		if(attacker > 0)
		{
			return attacker;
		}

		/* Jockey */
		attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
		if (attacker > 0)
		{
			return attacker;
		}
	}

	/* Hunter */
	attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
	if (attacker > 0)
	{
		return attacker;
	}

	/* Smoker */
	attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
	if (attacker > 0)
	{
		return attacker;
	}

	return -1;
}

int GetSurvivorVictim(int client)
{
	int victim;

	if(g_bL4D2Version)
	{
		/* Charger */
		victim = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
		if (victim > 0)
		{
			return victim;
		}

		victim = GetEntPropEnt(client, Prop_Send, "m_carryVictim");
		if (victim > 0)
		{
			return victim;
		}

		victim = L4D2_GetQueuedPummelVictim(client);
		if (victim > 0)
		{
			return victim;
		}

		/* Jockey */
		victim = GetEntPropEnt(client, Prop_Send, "m_jockeyVictim");
		if (victim > 0)
		{
			return victim;
		}
	}

    /* Hunter */
	victim = GetEntPropEnt(client, Prop_Send, "m_pounceVictim");
	if (victim > 0)
	{
		return victim;
 	}

    /* Smoker */
 	victim = GetEntPropEnt(client, Prop_Send, "m_tongueVictim");
	if (victim > 0)
	{
		return victim;	
	}

	return -1;
}

bool HasAccess(int client, char[] sAcclvl)
{
	// no permissions set
	if (strlen(sAcclvl) == 0)
		return true;

	else if (StrEqual(sAcclvl, "-1"))
		return false;

	// check permissions
	int flag = GetUserFlagBits(client);
	if ( flag & ReadFlagString(sAcclvl) || flag & ADMFLAG_ROOT )
	{
		return true;
	}

	return false;
}

void AddWitchAttack(int witchid, int client)
{
	int ref = EntIndexToEntRef(witchid);
	if(g_alClientAttackedByWitch[client].FindValue(ref) == -1)
	{
		g_alClientAttackedByWitch[client].Push(ref);
	}
}

void RemoveWitchAttack(int witchid)
{
	int index, ref = EntIndexToEntRef(witchid);
	for (int client = 1; client <= MaxClients; client++) {
		if ( (index = g_alClientAttackedByWitch[client].FindValue(ref)) != -1 ) {
			g_alClientAttackedByWitch[client].Erase(index);
		}
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(
		classname[0] == 'm' ||
		classname[0] == 'p' ||
		classname[0] == 'v' ||
		classname[0] == 'i' ||
		classname[0] == 'g'
	)
	{
		if(
			strncmp(classname, "molotov_projectile", 18) == 0 ||
			strncmp(classname, "pipe_bomb_projectile", 20) == 0 ||
			strncmp(classname, "inferno", 7) == 0 ||
			(g_bL4D2Version && strncmp(classname, "vomitjar_projectile", 19) == 0) ||
			(g_bL4D2Version && strncmp(classname, "grenade_launcher_projectile", 27) == 0)
		)
		{
			RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
			return;
		}
	}
	else if(
		classname[0] == 'w'
	)
	{
		if(strcmp(classname, WITCH_NAME, false) == 0)
		{
			SDKHook(entity, SDKHook_OnTakeDamageAlivePost, OnTakeDamageWitchPost);
		}
	}
}

void OnNextFrame(int entRef)
{
	int entity = EntRefToEntIndex(entRef);

	if( entity == INVALID_ENT_REFERENCE )
		return;

	static char sClassname[64];
	GetEntityClassname(entity, sClassname, sizeof(sClassname));
	
	int client;
	if(
		strncmp(sClassname, "molotov_projectile", 18) == 0 ||
		strncmp(sClassname, "pipe_bomb_projectile", 20) == 0 ||
		(g_bL4D2Version && strncmp(sClassname, "vomitjar_projectile", 19) == 0)
	)
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hThrower");

		if( client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2)
		{
			g_alClientThrowable[client].Push(entRef);
		}
	}
	else if(g_bL4D2Version && strncmp(sClassname, "grenade_launcher_projectile", 27) == 0)
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hThrower");

		if( client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2)
		{
			g_alClientGrenade[client].Push(entRef);
		}
	}
	else if(strncmp(sClassname, "inferno", 7) == 0) //火瓶燃燒時
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");

		if( client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2)
		{
			if(g_fBreakPropCooldown> 0.0) fBreakPropTime[client] = GetEngineTime() + g_fBreakPropCooldown;
		}
	}
}

void ResetTimer()
{
	delete PlayerLeftStartTimer;
	delete CountDownTimer;
}

bool IsPlayerGhost (int client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost"))
		return true;
	return false;
}

bool Is_AFK_COMMAND_Block()
{
	if(g_Use_r2comp_unscramble == true && R2comp_IsUnscrambled() == false) return true;
	
	return false;
}

void CleanUpStateAndMusic(int client)
{
	// Resets a players state equivalent to when they die
	// does stuff like removing any pounces, stops reviving, stops healing, resets hang lighting, resets heartbeat and other sounds.
	L4D_CleanupPlayerState(client);

	// This fixes the music glitch thats been bothering me and many players for a long time. The music keeps playing over and over when it shouldn't. Doesn't execute
	// on versus.
	if(L4D_HasPlayerControlledZombies() == false)
	{
		if (!g_bL4D2Version)
		{
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Hospital");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Airport");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Farm");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Small_Town");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Garage");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Hospital");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Airport");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Small_Town");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Farm");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Garage");
			L4D_StopMusic(client, "Event.Zombat");
			L4D_StopMusic(client, "Event.Zombat_A2");
			L4D_StopMusic(client, "Event.Zombat_A3");
			L4D_StopMusic(client, "Event.Tank");
			L4D_StopMusic(client, "Event.TankMidpoint");
			L4D_StopMusic(client, "Event.TankMidpoint_Metal");
			L4D_StopMusic(client, "Event.TankBrothers");
			L4D_StopMusic(client, "Event.WitchAttack");
			L4D_StopMusic(client, "Event.WitchBurning");
			L4D_StopMusic(client, "Event.WitchRage");
			L4D_StopMusic(client, "Event.HunterPounce");
			L4D_StopMusic(client, "Event.SmokerChoke");
			L4D_StopMusic(client, "Event.SmokerDrag");
			L4D_StopMusic(client, "Event.VomitInTheFace");
			L4D_StopMusic(client, "Event.LedgeHangTwoHands");
			L4D_StopMusic(client, "Event.LedgeHangOneHand");
			L4D_StopMusic(client, "Event.LedgeHangFingers");
			L4D_StopMusic(client, "Event.LedgeHangAboutToFall");
			L4D_StopMusic(client, "Event.LedgeHangFalling");
			L4D_StopMusic(client, "Event.Down");
			L4D_StopMusic(client, "Event.BleedingOut");
			L4D_StopMusic(client, "Event.SurvivorDeath");
			L4D_StopMusic(client, "Event.ScenarioLose");
		}
		else
		{
			// Music when Mission Starts
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Mall");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Fairgrounds");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Plankcountry");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_Milltown");
			L4D_StopMusic(client, "Event.MissionStart_BaseLoop_BigEasy");
			
			// Checkpoints
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Mall");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Fairgrounds");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Plankcountry");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_Milltown");
			L4D_StopMusic(client, "Event.CheckPointBaseLoop_BigEasy");
			
			// Zombat
			L4D_StopMusic(client, "Event.Zombat_1");
			L4D_StopMusic(client, "Event.Zombat_A_1");
			L4D_StopMusic(client, "Event.Zombat_B_1");
			L4D_StopMusic(client, "Event.Zombat_2");
			L4D_StopMusic(client, "Event.Zombat_A_2");
			L4D_StopMusic(client, "Event.Zombat_B_2");
			L4D_StopMusic(client, "Event.Zombat_3");
			L4D_StopMusic(client, "Event.Zombat_A_3");
			L4D_StopMusic(client, "Event.Zombat_B_3");
			L4D_StopMusic(client, "Event.Zombat_4");
			L4D_StopMusic(client, "Event.Zombat_A_4");
			L4D_StopMusic(client, "Event.Zombat_B_4");
			L4D_StopMusic(client, "Event.Zombat_5");
			L4D_StopMusic(client, "Event.Zombat_A_5");
			L4D_StopMusic(client, "Event.Zombat_B_5");
			L4D_StopMusic(client, "Event.Zombat_6");
			L4D_StopMusic(client, "Event.Zombat_A_6");
			L4D_StopMusic(client, "Event.Zombat_B_6");
			L4D_StopMusic(client, "Event.Zombat_7");
			L4D_StopMusic(client, "Event.Zombat_A_7");
			L4D_StopMusic(client, "Event.Zombat_B_7");
			L4D_StopMusic(client, "Event.Zombat_8");
			L4D_StopMusic(client, "Event.Zombat_A_8");
			L4D_StopMusic(client, "Event.Zombat_B_8");
			L4D_StopMusic(client, "Event.Zombat_9");
			L4D_StopMusic(client, "Event.Zombat_A_9");
			L4D_StopMusic(client, "Event.Zombat_B_9");
			L4D_StopMusic(client, "Event.Zombat_10");
			L4D_StopMusic(client, "Event.Zombat_A_10");
			L4D_StopMusic(client, "Event.Zombat_B_10");
			L4D_StopMusic(client, "Event.Zombat_11");
			L4D_StopMusic(client, "Event.Zombat_A_11");
			L4D_StopMusic(client, "Event.Zombat_B_11");
			
			// Zombat specific maps
			
			// C1 Mall
			L4D_StopMusic(client, "Event.Zombat2_Intro_Mall");
			L4D_StopMusic(client, "Event.Zombat3_Intro_Mall");
			L4D_StopMusic(client, "Event.Zombat3_A_Mall");
			L4D_StopMusic(client, "Event.Zombat3_B_Mall");
			
			// A2 Fairgrounds
			L4D_StopMusic(client, "Event.Zombat_Intro_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat_A_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat_B_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat_B_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat2_Intro_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat3_Intro_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat3_A_Fairgrounds");
			L4D_StopMusic(client, "Event.Zombat3_B_Fairgrounds");
			
			// C3 Plankcountry
			L4D_StopMusic(client, "Event.Zombat_PlankCountry");
			L4D_StopMusic(client, "Event.Zombat_A_PlankCountry");
			L4D_StopMusic(client, "Event.Zombat_B_PlankCountry");
			L4D_StopMusic(client, "Event.Zombat2_Intro_Plankcountry");
			L4D_StopMusic(client, "Event.Zombat3_Intro_Plankcountry");
			L4D_StopMusic(client, "Event.Zombat3_A_Plankcountry");
			L4D_StopMusic(client, "Event.Zombat3_B_Plankcountry");
			
			// A2 Milltown
			L4D_StopMusic(client, "Event.Zombat2_Intro_Milltown");
			L4D_StopMusic(client, "Event.Zombat3_Intro_Milltown");
			L4D_StopMusic(client, "Event.Zombat3_A_Milltown");
			L4D_StopMusic(client, "Event.Zombat3_B_Milltown");
			
			// C5 BigEasy
			L4D_StopMusic(client, "Event.Zombat2_Intro_BigEasy");
			L4D_StopMusic(client, "Event.Zombat3_Intro_BigEasy");
			L4D_StopMusic(client, "Event.Zombat3_A_BigEasy");
			L4D_StopMusic(client, "Event.Zombat3_B_BigEasy");
			
			// A2 Clown
			L4D_StopMusic(client, "Event.Zombat3_Intro_Clown");
			
			// Death
			
			// ledge hang
			L4D_StopMusic(client, "Event.LedgeHangTwoHands");
			L4D_StopMusic(client, "Event.LedgeHangOneHand");
			L4D_StopMusic(client, "Event.LedgeHangFingers");
			L4D_StopMusic(client, "Event.LedgeHangAboutToFall");
			L4D_StopMusic(client, "Event.LedgeHangFalling");
			
			// Down
			// Survivor is down and being beaten by infected
			
			L4D_StopMusic(client, "Event.Down");
			L4D_StopMusic(client, "Event.BleedingOut");
			
			// Survivor death
			// This is for the death of an individual survivor to be played after the health meter has reached zero
			
			L4D_StopMusic(client, "Event.SurvivorDeath");
			L4D_StopMusic(client, "Event.ScenarioLose");
			
			// Bosses
			
			// Tank
			L4D_StopMusic(client, "Event.Tank");
			L4D_StopMusic(client, "Event.TankMidpoint");
			L4D_StopMusic(client, "Event.TankMidpoint_Metal");
			L4D_StopMusic(client, "Event.TankBrothers");
			L4D_StopMusic(client, "C2M5.RidinTank1");
			L4D_StopMusic(client, "C2M5.RidinTank2");
			L4D_StopMusic(client, "C2M5.BadManTank1");
			L4D_StopMusic(client, "C2M5.BadManTank2");
			
			// Witch
			L4D_StopMusic(client, "Event.WitchAttack");
			L4D_StopMusic(client, "Event.WitchBurning");
			L4D_StopMusic(client, "Event.WitchRage");
			L4D_StopMusic(client, "Event.WitchDead");
			
			// mobbed
			L4D_StopMusic(client, "Event.Mobbed");
			
			// Hunter
			L4D_StopMusic(client, "Event.HunterPounce");
			
			// Smoker
			L4D_StopMusic(client, "Event.SmokerChoke");
			L4D_StopMusic(client, "Event.SmokerDrag");
			
			// Boomer
			L4D_StopMusic(client, "Event.VomitInTheFace");
			
			// Charger
			L4D_StopMusic(client, "Event.ChargerSlam");
			
			// Jockey
			L4D_StopMusic(client, "Event.JockeyRide");
			
			// Spitter
			L4D_StopMusic(client, "Event.SpitterSpit");
			L4D_StopMusic(client, "Event.SpitterBurn");
		}
	}
}

void ClearDefault()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

bool IsGettingUpOrStumble(int client) {
	int Activity;

	if(g_bL4D2Version)
	{
		Activity = PlayerAnimState.FromPlayer(client).GetMainActivity();

		switch (Activity) 
		{
			case L4D2_ACT_TERROR_SHOVED_FORWARD_MELEE, // 633, 634, 635, 636: stumble
				L4D2_ACT_TERROR_SHOVED_BACKWARD_MELEE,
				L4D2_ACT_TERROR_SHOVED_LEFTWARD_MELEE,
				L4D2_ACT_TERROR_SHOVED_RIGHTWARD_MELEE: 
					return true;

			case L4D2_ACT_TERROR_POUNCED_TO_STAND: // 771: get up from hunter
				return true;

			case L4D2_ACT_TERROR_HIT_BY_TANKPUNCH, // 521, 522, 523: HIT BY TANK PUNCH
				L4D2_ACT_TERROR_IDLE_FALL_FROM_TANKPUNCH,
				L4D2_ACT_TERROR_TANKPUNCH_LAND:
				return true;

			case L4D2_ACT_TERROR_CHARGERHIT_LAND_SLOW: // 526: get up from charger
				return true;

			case L4D2_ACT_TERROR_HIT_BY_CHARGER, // 524, 525, 526: flung by a nearby Charger impact
				L4D2_ACT_TERROR_IDLE_FALL_FROM_CHARGERHIT: 
				return true;
		}
	}
	else
	{
		Activity = L4D1_GetMainActivity(client);

		switch (Activity) 
		{
			case L4D1_ACT_TERROR_SHOVED_FORWARD, // 1145, 1146, 1147, 1148: stumble
				L4D1_ACT_TERROR_SHOVED_BACKWARD,
				L4D1_ACT_TERROR_SHOVED_LEFTWARD,
				L4D1_ACT_TERROR_SHOVED_RIGHTWARD: 
					return true;

			case L4D1_ACT_TERROR_POUNCED_TO_STAND: // 1263: get up from hunter
				return true;

			case L4D1_ACT_TERROR_HIT_BY_TANKPUNCH, // 1077, 1078, 1079: HIT BY TANK PUNCH
				L4D1_ACT_TERROR_IDLE_FALL_FROM_TANKPUNCH,
				L4D1_ACT_TERROR_TANKPUNCH_LAND:
				return true;
		}
	}

	return false;
}

public void L4D2_OnStagger_Post(int client, int source)
{
	if(!client || !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2) return;
	if(!IsWitch(source)) return;

	AddWitchAttack(source, client);
}

bool IsWitch(int entity)
{
    if (entity > MaxClients && IsValidEntity(entity))
    {
        char strClassName[64];
        GetEntityClassname(entity, strClassName, sizeof(strClassName));
        return strcmp(strClassName, WITCH_NAME, false) == 0;
    }

    return false;
}