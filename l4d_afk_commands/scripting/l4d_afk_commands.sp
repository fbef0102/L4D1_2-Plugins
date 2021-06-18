//本插件用來防止玩家換隊濫用的Bug
//禁止期間不能閒置、不能打指令換隊、亦不可按M換隊
//1.嚇了Witch或被Witch抓倒 期間禁止換隊 (防止Witch失去目標)
//2.被特感抓住期間 期間禁止換隊 (防止濫用特感控了無傷)
//3.人類玩家死亡 期間禁止換隊 (防止玩家故意死亡 然後跳隊裝B)
//4.換隊成功之後 必須等待數秒才能再換隊 (防止玩家頻繁換隊洗頻伺服器)
//5.出安全室之後 不得隨意換隊 (防止跳狗)
//6.玩家點燃火瓶、汽油或油桶期間禁止換隊 (防止友傷bug、防止Witch失去目標)
//7.玩家投擲火瓶、土製炸彈、膽汁期間禁止換隊 (防止Witch失去目標)
//8.管理員可以強制玩家更換隊伍 "sm_swapto <player> <team>"
/*
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
	"sm_js"
	
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


#define PLUGIN_VERSION 		"3.6"
#define PLUGIN_NAME			"[L4D(2)] AFK and Join Team Commands Improved"
#define PLUGIN_AUTHOR		"MasterMe & HarryPotter"
#define PLUGIN_DES			"Adds commands to let the player spectate and join team. (!afk, !survivors, !infected, etc.), but no change team abuse"
#define PLUGIN_URL			"https://steamcommunity.com/id/fbef0102/"

#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#undef REQUIRE_PLUGIN
#include <left4dhooks>
#define REQUIRE_PLUGIN

#define STEAMID_SIZE 		32
#define L4D_TEAM_NAME(%1) (%1 == 2 ? "Survivors" : (%1 == 3 ? "Infected" : (%1 == 1 ? "Spectators" : "Unknown")))
const int ARRAY_TEAM = 1;
const int ARRAY_COUNT = 2;
#define MODEL_CRATE				"models/props_junk/explosive_box001.mdl"
#define MODEL_GASCAN			"models/props_junk/gascan001a.mdl"
#define MODEL_BARREL			"models/props_industrial/barrel_fuel.mdl"

//convar
ConVar g_hCoolTime, g_hDeadSurvivorBlock, g_hGameTimeBlock, g_hSurvivorSuicideSeconds, 
	g_hInfectedAttackBlock, g_hWitchAttackBlock, g_hWPressMBlock, g_hImmueAccess,
	g_hTakeABreakBlock, g_hSpecCommandAccess, g_hInfCommandAccess, g_hSurCommandAccess,
	g_hObsCommandAccess,
	g_hTakeControlBlock, g_hBreakPropCooldown, g_hThrowableCooldown;
ConVar g_hGameMode, g_hZMaxPlayerZombies;

//value
char g_sImmueAcclvl[16], g_sSpecCommandAccesslvl[16], g_sInfCommandAccesslvl[16], 
	g_sSurCommandAccesslvl[16], g_sObsCommandAccesslvl[16];
bool g_bL4D2Version, g_bHasLeftSafeRoom, g_bMapStarted, g_bGameTeamSwitchBlock;
bool g_bDeadSurvivorBlock, g_bTakeControlBlock, g_bInfectedAttackBlock, 
	g_bWitchAttackBlock, g_bPressMBlock, g_bTakeABreakBlock;
float g_fBreakPropCooldown, g_fThrowableCooldown, g_fSurvivorSuicideSeconds;
int g_iCvarGameTimeBlock, g_iCountDownTime, g_iZMaxPlayerZombies;

//arraylist
ArrayList nClientSwitchTeam;
ArrayList nClientAttackedByWitch[MAXPLAYERS+1]; //每個玩家被多少個witch攻擊
//signature
Handle hSetHumanSpec, hTakeOver, hAFKSDKCall;
//timer
Handle PlayerLeftStartTimer = null, CountDownTimer = null;

bool InCoolDownTime[MAXPLAYERS+1] = false;//是否還有換隊冷卻時間
bool bClientJoinedTeam[MAXPLAYERS+1] = false; //在冷卻時間是否嘗試加入
float g_iSpectatePenaltTime[MAXPLAYERS+1] ;//各自的冷卻時間
float fBreakPropTime[MAXPLAYERS+1] ;//點燃火瓶、汽油或油桶的時間
float fThrowableTime[MAXPLAYERS+1] ;//投擲物品的時間
float ClientJoinSurvivorTime[MAXPLAYERS+1] ;//加入倖存者隊伍的時間
float fCoolTime;
int clientteam[MAXPLAYERS+1];//玩家換隊成功之後的隊伍
int iClientFlags[MAXPLAYERS+1];
int iGameMode;

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DES,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};

bool g_bLateLoad;
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

public void OnPluginStart()
{
	LoadTranslations("l4d_afk_commands.phrases");

	Handle hGameConf;	
	hGameConf = LoadGameConfigFile("l4d_afk_commands");
	if(hGameConf == null)
		SetFailState("Gamedata l4d_afk_commands.txt not found");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "SetHumanSpec");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	hSetHumanSpec = EndPrepSDKCall();
	if (hSetHumanSpec == null)
		SetFailState("Cant initialize SetHumanSpec SDKCall");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "TakeOverBot");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	hTakeOver = EndPrepSDKCall();
	if( hTakeOver == null)
		SetFailState("Could not prep the \"TakeOverBot\" function.");

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "CTerrorPlayer::GoAwayFromKeyboard");
	hAFKSDKCall = EndPrepSDKCall();
	if(hAFKSDKCall == null)
		SetFailState("Unable to prep SDKCall 'CTerrorPlayer::GoAwayFromKeyboard'");

	delete hGameConf;

	LoadTranslations("common.phrases");
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
	
	RegConsoleCmd("jointeam", WTF); // press M
	RegConsoleCmd("go_away_from_keyboard", WTF2); //esc -> take a break
	RegConsoleCmd("sb_takecontrol", WTF3);  //sb_takecontrol

	RegAdminCmd("sm_swapto", Command_SwapTo, ADMFLAG_BAN, "sm_swapto <player1> [player2] ... [playerN] <teamnum> - swap all listed players to <teamnum> (1,2, or 3)");
	RegConsoleCmd("sm_zs", ForceSurvivorSuicide, "Alive Survivor Suicide himself Command.");

	RegConsoleCmd("sm_observer", TurnClientToObserver, "Switch team to fully an observer.");
	RegConsoleCmd("sm_ob", TurnClientToObserver, "Switch team to fully an observer.");
	RegConsoleCmd("sm_observe", TurnClientToObserver, "Switch team to fully an observer.");

	g_hZMaxPlayerZombies = FindConVar("z_max_player_zombies");
	g_hCoolTime = CreateConVar("l4d_afk_commands_changeteam_cooltime_block", "10.0", "Cold Down Time in seconds a player can not change team again after he switches team. (0=off)", FCVAR_NOTIFY, true, 0.0);
	g_hDeadSurvivorBlock = CreateConVar("l4d_afk_commands_deadplayer_block", "1", "If 1, Dead Survivor player can not switch team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGameTimeBlock = CreateConVar("l4d_afk_commands_during_game_seconds_block", "0", "Player can switch team until players have left start safe area for at least x seconds (0=off).", FCVAR_NOTIFY, true, 0.0);
	g_hInfectedAttackBlock = CreateConVar("l4d_afk_commands_infected_attack_block", "1", "If 1, Player can not change team when he is capped by special infected.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hWitchAttackBlock = CreateConVar("l4d_afk_commands_witch_attack_block", "1", "If 1, Player can not change team when he startle witch or being attacked by witch.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSurvivorSuicideSeconds = CreateConVar("l4d_afk_commands_suicide_allow_second", "30.0", "Allow alive survivor player suicide by using '!zs' after joining survivor team for at least X seconds. (0=off)", FCVAR_NOTIFY, true, 0.0);

	g_hWPressMBlock = CreateConVar("l4d_afk_commands_pressM_block", "1", "If 1, Block player from using 'jointeam' command in console. (This also blocks player from switching team by choosing team menu)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hTakeABreakBlock = CreateConVar("l4d_afk_commands_takeabreak_block", "1", "If 1, Block player from using 'go_away_from_keyboard' command in console. (This also blocks player from going idle with 'esc->take a break')", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hTakeControlBlock = CreateConVar("l4d_afk_commands_takecontrol_block", "1", "If 1, Block player from using 'sb_takecontrol' command in console.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBreakPropCooldown = CreateConVar("l4d_afk_commands_igniteprop_cooltime_block", "15.0", "Cold Down Time in seconds a player can not change team after he ignites molotov, gas can, firework crate or barrel fuel. (0=off).", FCVAR_NOTIFY, true, 0.0);
	g_hThrowableCooldown = CreateConVar("l4d_afk_commands_throwable_cooltime_block", "10.0", "Cold Down Time in seconds a player can not change team after he throws molotov, pipe bomb or boomer juice. (0=off).", FCVAR_NOTIFY, true, 0.0);
	g_hImmueAccess = CreateConVar("l4d_afk_commands_immue_block_flag", "z", "Players with these flags have immune to all 'block' limit (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	g_hSpecCommandAccess = CreateConVar("l4d_afk_commands_spec_access_flag", "", "Players with these flags have access to use command to spectator team. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	g_hInfCommandAccess = CreateConVar("l4d_afk_commands_infected_access_flag", "", "Players with these flags have access to use command to infected team. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	g_hSurCommandAccess = CreateConVar("l4d_afk_commands_survivor_access_flag", "", "Players with these flags have access to use command to survivor team. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	g_hObsCommandAccess = CreateConVar("l4d_afk_commands_observer_access_flag", "z", "Players with these flags have access to use command to be an observer. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	
	GetCvars();
	g_hGameMode = FindConVar("mp_gamemode");
	g_hGameMode.AddChangeHook(ConVarChange_CvarGameMode);
	g_hCoolTime.AddChangeHook(ConVarChanged_Cvars);
	g_hDeadSurvivorBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hGameTimeBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedAttackBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hWitchAttackBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorSuicideSeconds.AddChangeHook(ConVarChanged_Cvars);
	g_hWPressMBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hTakeControlBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hTakeABreakBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hBreakPropCooldown.AddChangeHook(ConVarChanged_Cvars);
	g_hThrowableCooldown.AddChangeHook(ConVarChanged_Cvars);
	g_hImmueAccess.AddChangeHook(ConVarChanged_Cvars);
	g_hSpecCommandAccess.AddChangeHook(ConVarChanged_Cvars);
	g_hInfCommandAccess.AddChangeHook(ConVarChanged_Cvars);
	g_hSurCommandAccess.AddChangeHook(ConVarChanged_Cvars);
	g_hObsCommandAccess.AddChangeHook(ConVarChanged_Cvars);
	g_hZMaxPlayerZombies.AddChangeHook(ConVarChanged_Cvars);
	
	HookEvent("witch_harasser_set", OnWitchWokeup);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
	HookEvent("map_transition", Event_RoundEnd); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", Event_RoundEnd); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_team", Event_PlayerChangeTeam);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("break_prop",	Event_BreakProp,		EventHookMode_Pre);

	Clear();

	nClientSwitchTeam = new ArrayList(ByteCountToCells(STEAMID_SIZE));

	if(PlayerLeftStartTimer == null) PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);

	if( g_bLateLoad )
	{
		for( int i = 1; i <= MaxClients; i++ )
		{
			if( IsClientInGame(i) && !IsFakeClient(i))
			{
				OnClientPostAdminCheck(i);
			}
		}
	}

	AutoExecConfig(true, "l4d_afk_commands");
}

public void OnPluginEnd()
{
	Clear();
	ResetTimer();
}

public void OnMapStart()
{
	g_bMapStarted = true;
	nClientSwitchTeam.Clear();
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	Clear();
	ResetTimer();
}

public void OnConfigsExecuted()
{
	GameModeCheck();
}

void GameModeCheck()
{
	if(g_bMapStarted == false){
		iGameMode = 0;
		return;
	}
		
	int entity = CreateEntityByName("info_gamemode");
	if( IsValidEntity(entity) )
	{
		DispatchSpawn(entity);
		HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "PostSpawnActivate");
		if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
			RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
	}
}

public void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		iGameMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		iGameMode = 3;
	else if( strcmp(output, "OnVersus") == 0 )
		iGameMode = 2;
	else if( strcmp(output, "OnScavenge") == 0 )
		iGameMode = 2;
}

public Action Command_SwapTo(int client, int args)
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
	
	int player_id;

	char player[64];
	
	for(int i = 0; i < args - 1; i++)
	{
		GetCmdArg(i+1, player, sizeof(player));
		player_id = FindTarget(client, player, true /*nobots*/, false /*immunity*/);
		
		if(player_id == -1)
			continue;
		
		if(team == 1)
			ChangeClientTeam(player_id,1);
		else if(team == 2)
		{
			int bot = FindBotToTakeOver(true);
			if (bot==0)
			{
				bot = FindBotToTakeOver(false);
			}
			if (bot==0)
			{
				ChangeClientTeam(player_id,2);
				return Plugin_Handled;
			}

			SDKCall(hSetHumanSpec, bot, player_id);
			SDKCall(hTakeOver, player_id, true);
		}
		else if (team == 3)
			ChangeClientTeam(player_id,3);
			
		if(client != player_id) C_PrintToChatAll("[{olive}TS{default}] %t", "ADM Swap Player Team", client, player_id, L4D_TEAM_NAME(team));
	}
	
	return Plugin_Handled;
}

public Action ForceSurvivorSuicide(int client, int args)
{
	if (g_fSurvivorSuicideSeconds > 0.0 && client && GetClientTeam(client) == 2 && !IsFakeClient(client) && IsPlayerAlive(client))
	{
		if(g_bHasLeftSafeRoom == false)
		{
			PrintHintText(client, "[TS] %T","You wish!",client);
			return Plugin_Handled;
		}

		if(L4D2_GetInfectedAttacker(client) != -1)
		{
			PrintHintText(client, "[TS] %T","In your dreams!",client);
			return Plugin_Handled;
		}
		
		if( nClientAttackedByWitch[client].Length != 0 )
		{
			PrintHintText(client, "[TS] %T","Not on your life!",client);
			return Plugin_Handled;
		}

		if( GetEngineTime() - ClientJoinSurvivorTime[client] < g_fSurvivorSuicideSeconds)
		{
			PrintHintText(client, "[TS] %T","Not gonna happen!",client);
			return Plugin_Handled;
		}

		C_PrintToChatAll("[{olive}TS{default}] %T","Suicide",client,client);
		ForcePlayerSuicide(client);
	}
	return Plugin_Handled;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if(!victim || !IsClientAndInGame(victim)) return;
	ResetAttackedByWitch(victim);

	if((g_bGameTeamSwitchBlock == true && g_iCvarGameTimeBlock > 0) && IsClientInGame(victim) && !IsFakeClient(victim) && GetClientTeam(victim) == 2)
	{
		char steamID[STEAMID_SIZE];
		GetClientAuthId(victim, AuthId_Steam2,steamID, STEAMID_SIZE);
		int index = nClientSwitchTeam.FindString(steamID);
		if (index == -1) {
			nClientSwitchTeam.PushString(steamID);
			nClientSwitchTeam.Push(4);
		}
		else
		{
			nClientSwitchTeam.Set(index + ARRAY_TEAM, 4);
		}			
	}
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int player = GetClientOfUserId(userid);
	if(player > 0 && player <=MaxClients && IsClientInGame(player) && !IsFakeClient(player) && GetClientTeam(player) == 2)
	{
		CreateTimer(2.0,checksurvivorspawn, userid);
		ClientJoinSurvivorTime[player] = GetEngineTime();
	}
}

public void Event_BreakProp(Event event, const char[] name, bool dontBroadcast)
{
	char sTemp[42];
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!client || !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2) return;

	int entity = event.GetInt("entindex");
	GetEdictClassname(entity, sTemp, sizeof(sTemp));
	if( strcmp(sTemp, "prop_physics") == 0 || strcmp(sTemp, "prop_fuel_barrel") == 0)
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

public Action checksurvivorspawn(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(g_bGameTeamSwitchBlock == true && g_iCvarGameTimeBlock > 0 && client && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
	{
		char steamID[STEAMID_SIZE];
		GetClientAuthId(client, AuthId_Steam2,steamID, STEAMID_SIZE);
		int index = nClientSwitchTeam.FindString(steamID);
		if (index == -1) {
			nClientSwitchTeam.PushString(steamID);
			nClientSwitchTeam.Push(2);
		}
		else
		{
			nClientSwitchTeam.Set(index + ARRAY_TEAM, 2);
		}			
	}
}

public void OnClientPostAdminCheck(int client)
{
	if(!IsFakeClient(client)) iClientFlags[client] = GetUserFlagBits(client);
}
public void OnClientPutInServer(int client)
{
	Clear(client);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
	Clear(client);
}

public Action OnTakeDamage(int victim, int &attacker, int  &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
	if (!IsValidEdict(victim) || !IsValidEdict(attacker) || !IsValidEdict(inflictor) ) { return Plugin_Continue; }
	
	if(!IsClientAndInGame(victim) || GetClientTeam(victim) != 2) { return Plugin_Continue; }
	
	char sClassname[64];
	GetEntityClassname(inflictor, sClassname, 64);
	if(StrEqual(sClassname, "witch"))
	{
		AddWitchAttack(attacker, victim);
	}
	return Plugin_Continue;
}

public Action OnWitchWokeup(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	int witchid = event.GetInt("witchid");
	
	if(client > 0 && client <= MaxClients &&  IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		AddWitchAttack(witchid, client);
	}
	
}

public void OnEntityDestroyed(int entity)
{
	if( entity > 0 && IsValidEdict(entity) )
	{
		char strClassName[64];
		GetEdictClassname(entity, strClassName, sizeof(strClassName));
		if(StrEqual(strClassName, "witch"))	
		{
			RemoveWitchAttack(entity);
		}
	}
}

public Action Event_PlayerChangeTeam(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	CreateTimer(0.1, ClientReallyChangeTeam, client, _); // check delay

	ClientJoinSurvivorTime[client] = GetEngineTime();
}

public void ConVarChange_CvarGameMode(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GameModeCheck();
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
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
	g_hImmueAccess.GetString(g_sImmueAcclvl,sizeof(g_sImmueAcclvl));
	g_fSurvivorSuicideSeconds = g_hSurvivorSuicideSeconds.FloatValue;
	g_bPressMBlock = g_hWPressMBlock.BoolValue;
	g_bTakeABreakBlock = g_hTakeABreakBlock.BoolValue;
	g_bTakeControlBlock = g_hTakeControlBlock.BoolValue;
	fCoolTime = g_hCoolTime.FloatValue;
	g_fBreakPropCooldown = g_hBreakPropCooldown.FloatValue;
	g_fThrowableCooldown = g_hThrowableCooldown.FloatValue;
	g_iZMaxPlayerZombies = g_hZMaxPlayerZombies.IntValue;
	
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	ResetTimer();
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	for (int i = 0; i < (nClientSwitchTeam.Length / ARRAY_COUNT); i++) {
		nClientSwitchTeam.Set( (i * ARRAY_COUNT) + ARRAY_TEAM, 0);
	}
	
	Clear();
	if(PlayerLeftStartTimer == null) PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);
}

public Action Timer_PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea())
	{
		g_bHasLeftSafeRoom = true;
		g_iCountDownTime = g_iCvarGameTimeBlock;
		if(g_iCountDownTime > 0)
		{
			if(CountDownTimer == null) CountDownTimer = CreateTimer(1.0, Timer_CountDown, _, TIMER_REPEAT);
		}

		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue; 
}

public Action Timer_CountDown(Handle timer)
{
	if(g_iCountDownTime <= 0) 
	{
		g_bGameTeamSwitchBlock = true;
		CountDownTimer = null;
		return Plugin_Stop;
	}
	g_iCountDownTime--;
	return Plugin_Continue;
}

void Clear(int client = -1)
{
	if(client == -1)
	{
		for(int i = 1; i <= MaxClients; i++)
		{	
			InCoolDownTime[i] = false;
			bClientJoinedTeam[i] = false;
			clientteam[i] = 0;
			fBreakPropTime[i] = 0.0;
			fThrowableTime[i] = 0.0;
			ResetAttackedByWitch(i);
		}
		g_bHasLeftSafeRoom = false;
		g_bGameTeamSwitchBlock = false;
	}	
	else
	{
		InCoolDownTime[client] = false;
		bClientJoinedTeam[client] = false;
		clientteam[client] = 0;
		fBreakPropTime[client] = 0.0;
		fThrowableTime[client] = 0.0;
		ResetAttackedByWitch(client);
	}

}

public Action TurnClientToSpectate(int client, int argCount)
{
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}
	if(IsClientIdle(client))
	{
		PrintHintText(client, "[TS] %T","Idle",client);
		return Plugin_Handled;
	}
	if(HasAccess(client, g_sSpecCommandAccesslvl) == false)
	{
		PrintHintText(client, "[TS] %T","You don't have access to change team to spectator",client);
		return Plugin_Handled;
	}

	int iTeam = GetClientTeam(client);
	if(iTeam != 1)
	{
		if(CanClientChangeTeam(client,1) == false) return Plugin_Handled;
		
		if(iTeam == 2 && IsPlayerAlive(client) && iGameMode != 2) SDKCall(hAFKSDKCall, client);
		else ChangeClientTeam(client, 1);
		
		clientteam[client] = 1;
		StartChangeTeamCoolDown(client);
	}
	else
	{
		ChangeClientTeam(client, 3);
		CreateTimer(0.1, Timer_Respectate, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Handled;
}

public Action TurnClientToObserver(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}
	if(HasAccess(client, g_sObsCommandAccesslvl) == false)
	{
		PrintHintText(client, "[TS] %T","You don't have access to be an observer",client);
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
			SDKCall(hTakeOver, client, true);
			ChangeClientTeam(client, 1);
			return Plugin_Handled;
		}
		
		ChangeClientTeam(client, 3);
		CreateTimer(0.1, Timer_Respectate, client, TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Handled;
}

public Action Timer_Respectate(Handle timer, int client)
{
	ChangeClientTeam(client, 1);
}

public Action TurnClientToSurvivors(int client, int args)
{ 
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}
	if (GetClientTeam(client) == 2)			//if client is survivor
	{
		PrintHintText(client, "[TS] %T","You are already in survivor team.",client);
		return Plugin_Handled;
	}
	if (IsClientIdle(client))
	{
		PrintHintText(client, "[TS] %T","You are in idle, Press Left Mouse to play",client);
		return Plugin_Handled;
	}
	if(HasAccess(client, g_sSurCommandAccesslvl) == false)
	{
		PrintHintText(client, "[TS] %T.","You don't have access to change team to survivor",client);
		return Plugin_Handled;
	}

	if(CanClientChangeTeam(client,2) == false) return Plugin_Handled;
	
	int maxSurvivorSlots = GetTeamMaxSlots(2);
	int survivorUsedSlots = GetTeamHumanCount(2);
	int freeSurvivorSlots = (maxSurvivorSlots - survivorUsedSlots);

	//PrintToChatAll("Number of Survivor Slots %d.\nNumber of Survivor Players %d.\nNumber of Free Slots %d.", maxSurvivorSlots, survivorUsedSlots, freeSurvivorSlots);
	
	if (freeSurvivorSlots <= 0)
	{
		PrintHintText(client, "[TS] %T","Survivor team is full now.",client);
		return Plugin_Handled;
	}
	else
	{
		int bot = FindBotToTakeOver(true)	;
		if (bot==0)
		{
			bot = FindBotToTakeOver(false);
		}
		if (bot==0) return Plugin_Handled;
		
		if(iGameMode != 2) //coop/survival
		{
			if(GetClientTeam(client) == 3) ChangeClientTeam(client,1);

			if(IsPlayerAlive(bot))
			{
				SDKCall(hSetHumanSpec, bot, client);
				SetEntProp(client, Prop_Send, "m_iObserverMode", 5);
			}
			else
			{
				SDKCall(hSetHumanSpec, bot, client);
				SDKCall(hTakeOver, client, true);	
				clientteam[client] = 2;	
				StartChangeTeamCoolDown(client);
			}
		}
		else //versus
		{
			SDKCall(hSetHumanSpec, bot, client);
			SDKCall(hTakeOver, client, true);
			clientteam[client] = 2;	
			StartChangeTeamCoolDown(client);
		}
	}
	return Plugin_Handled;
}

public Action TurnClientToInfected(int client, int args)
{ 
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}
	if (GetClientTeam(client) == 3)			//if client is Infected
	{
		PrintHintText(client, "[TS] %T","You are already in infected team.",client);
		return Plugin_Handled;
	}
	if(HasAccess(client, g_sInfCommandAccesslvl) == false)
	{
		PrintHintText(client, "[TS] %T","You don't have access to change team to Infected",client);
		return Plugin_Handled;
	}

	if(CanClientChangeTeam(client,3) == false) return Plugin_Handled;

	int maxInfectedSlots = GetTeamMaxSlots(3);
	int infectedUsedSlots = GetTeamHumanCount(3);
	int freeInfectedSlots = (maxInfectedSlots - infectedUsedSlots);
	if (freeInfectedSlots <= 0)
	{
		PrintHintText(client, "[TS] %T","Infected team is full now.",client);
		return Plugin_Handled;
	}
	if(iGameMode != 2)
	{
		return Plugin_Handled;
	}
	
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
	
	int i;
	for(i = 1; i < (MaxClients + 1); i++)
	{
		if(IsClientInGameHuman(i) && GetClientTeam(i) == team)
		{
			humans++;
		}
	}
	
	return humans;
}
//client is in-game and not a bot and not spec
bool IsClientInGameHuman(int client)
{
	return IsClientInGame(client) && !IsFakeClient(client) && ((GetClientTeam(client) == 2 || GetClientTeam(client) == 3));
}

public bool IsInteger(char[] buffer)
{
    int len = strlen(buffer);
    for (int i = 0; i < len; i++)
    {
        if ( !IsCharNumeric(buffer[i]) )
            return false;
    }

    return true;    
}

public Action WTF(int client, int args) //press m (jointeam)
{
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}

	if(g_bHasLeftSafeRoom == false) return Plugin_Continue;

	if(args > 2) return Plugin_Handled;

	bool bHaveAccess = HasAccess(client, g_sImmueAcclvl);
	if(g_bPressMBlock == true && bHaveAccess == false) 
	{
		PrintHintText(client, "[TS] %T","This function has been blocked!",client);	
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

	return Plugin_Continue;
}

public Action WTF2(int client, int args) //esc->take a break (go_away_from_keyboard)
{
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}

	if(g_bHasLeftSafeRoom == false) return Plugin_Continue;

	if (GetClientTeam(client) == 3)			//if client is Infected
	{
		PrintHintText(client, "[TS] %T","Infected can't go idle",client);
		return Plugin_Handled;
	}
	if(IsClientIdle(client))
	{
		PrintHintText(client, "[TS] %T","Idle",client);
		return Plugin_Handled;
	}

	bool bHaveAccess = HasAccess(client, g_sImmueAcclvl);
	if(g_bTakeABreakBlock == true && bHaveAccess == false) 
	{
		PrintHintText(client, "[TS] %T","This function has been blocked!",client);	
		return Plugin_Handled;
	}

	if(CanClientChangeTeam(client, 1, bHaveAccess) == false) return Plugin_Handled;
	
	clientteam[client] = 1;
	StartChangeTeamCoolDown(client);
	return Plugin_Continue;
}

public Action WTF3(int client, int args) //sb_takecontrol
{
	if (client == 0)
	{
		PrintToServer("[TS] command cannot be used by server.");
		return Plugin_Handled;
	}

	if(g_bHasLeftSafeRoom == false) return Plugin_Continue;

	if(args > 1) return Plugin_Handled;

	bool bHaveAccess = HasAccess(client, g_sImmueAcclvl);
	if(g_bTakeControlBlock == true && bHaveAccess == false) 
	{
		ReplyToCommand(client, "[TS] %T","This function has been blocked!",client);	
		return Plugin_Handled;
	}

	if(CanClientChangeTeam(client, 2, bHaveAccess) == false) return Plugin_Handled;
	
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
			return Plugin_Continue;
		}
		ReplyToCommand(client, "Usage: sb_takecontrol <character_name>");	
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

bool IsClientAndInGame(int index)
{
	if (index > 0 && index < MaxClients)
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
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i)==2 && !HasIdlePlayer(i) && IsPlayerAlive(i) == alive)
		{
			return i;
		}
	}
	return 0;
}

bool HasIdlePlayer(int bot)
{
	if(IsClientInGame(bot) && IsFakeClient(bot) && GetClientTeam(bot) == 2 && IsPlayerAlive(bot))
	{
		if(HasEntProp(bot, Prop_Send, "m_humanSpectatorUserID"))
		{
			int client = GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"))	;		
			if(client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && IsClientObserver(client))
			{
				return true;
			}
		}
	}
	return false;
}

bool CanClientChangeTeam(int client, int changeteam = 0, bool bIsAdm = false)
{ 
	if(g_bHasLeftSafeRoom == false || bIsAdm || HasAccess(client, g_sImmueAcclvl)) return true;

	if ( L4D2_GetInfectedAttacker(client) != -1 && g_bInfectedAttackBlock == true)
	{
		PrintHintText(client, "[TS] %T","Infected Attack Block",client);
		return false;
	}	
	
	if( g_bWitchAttackBlock == true && nClientAttackedByWitch[client].Length != 0)
	{
		PrintHintText(client, "[TS] %T","Witch Attack Block",client);
		return false;
	}

	if( g_fBreakPropCooldown > 0.0 && (fBreakPropTime[client] - GetEngineTime() > 0.0) )
	{
		PrintHintText(client, "[TS] %T.", "Can not change team after ignite",client);
		return false;
	}

	if( g_fThrowableCooldown > 0.0 && (fThrowableTime[client] - GetEngineTime() > 0.0) )
	{
		PrintHintText(client, "[TS] %T","Can not change team after throw",client);
		return false;	
	}
	
	if(InCoolDownTime[client])
	{
		bClientJoinedTeam[client] = true;
		CPrintToChat(client, "[{olive}TS{default}] %T","Please wait",client, g_iSpectatePenaltTime[client]);
		return false;
	}

	if(GetClientTeam(client) == 2 && IsPlayerAlive(client) == false && g_bDeadSurvivorBlock == true)
	{
		PrintHintText(client, "[TS] %T","Can not change team as dead survivor",client);
		return false;
	}

	if((g_bGameTeamSwitchBlock == true && g_iCvarGameTimeBlock > 0) && g_bHasLeftSafeRoom && GetClientTeam(client) != 1 && changeteam != 1) 
	{
		CPrintToChat(client, "[{olive}TS{default}] %T","Can not change team during the game!!",client);
		return false;
	}
	
	return true;
}

void StartChangeTeamCoolDown(int client)
{
	if( InCoolDownTime[client] || g_bHasLeftSafeRoom == false || HasAccess(client, g_sImmueAcclvl)) return;
	if(fCoolTime > 0.0)
	{
		InCoolDownTime[client] = true;
		g_iSpectatePenaltTime[client] = fCoolTime;
		CreateTimer(0.25, Timer_CanJoin, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action ClientReallyChangeTeam(Handle timer, int client)
{
	if(!IsClientAndInGame(client) || IsFakeClient(client) || HasAccess(client, g_sImmueAcclvl)) return;

	if(g_bGameTeamSwitchBlock == true && g_iCvarGameTimeBlock > 0)
	{
		int newteam = GetClientTeam(client);
		if(newteam != 1)
		{
			char steamID[STEAMID_SIZE];
			GetClientAuthId(client, AuthId_Steam2, steamID, STEAMID_SIZE);
			int index = nClientSwitchTeam.FindString(steamID);
			if (index == -1) {
				nClientSwitchTeam.PushString(steamID);
				nClientSwitchTeam.Push(newteam);
			}
			else
			{
				int oldteam = nClientSwitchTeam.Get(index + ARRAY_TEAM);
				if(!g_bHasLeftSafeRoom || oldteam == 0)
					nClientSwitchTeam.Set(index + ARRAY_TEAM, newteam);
				else
				{
					//PrintToChatAll("%N newteam: %d, oldteam: %d",client,newteam,oldteam);
					if(newteam != oldteam)
					{
						if(oldteam == 4 && !(newteam == 2 && !IsPlayerAlive(client)) ) //player survivor death
						{
							ChangeClientTeam(client,1);
							CPrintToChat(client,"[{olive}TS{default}] %T","You are a dead survivor",client);
						}
						else if(oldteam != 4)
						{
							ChangeClientTeam(client,1);
							CPrintToChat(client,"[{olive}TS{default}] %T","Go Back Your Team",client,(oldteam == 2) ? "倖存者" : "特感");
						}
					}
				}
			}		
		}
	}
	
	if(g_bHasLeftSafeRoom && InCoolDownTime[client]) return;
	
	//PrintToChatAll("client: %N change Team: %d clientteam[client]:%d",client,GetClientTeam(client),clientteam[client]);
	if(GetClientTeam(client) != clientteam[client])
	{
		if(clientteam[client] != 0) StartChangeTeamCoolDown(client);
		clientteam[client] = GetClientTeam(client);		
	}
}

public Action Timer_CanJoin(Handle timer, int client)
{
	if (!InCoolDownTime[client] || 
	!IsClientInGame(client) || 
	IsFakeClient(client))//if client disconnected or is fake client or take a break on player bot
	{
		InCoolDownTime[client] = false;
		return Plugin_Stop;
	}

	
	if (g_iSpectatePenaltTime[client] != 0)
	{
		g_iSpectatePenaltTime[client]-=0.25;
		if(GetClientTeam(client)!=clientteam[client])
		{	
			bClientJoinedTeam[client] = true;
			CPrintToChat(client, "[{olive}TS{default}] %T","Please wait",client, g_iSpectatePenaltTime[client]);
			ChangeClientTeam(client, 1);clientteam[client]=1;
			return Plugin_Continue;
		}
	}
	else if (g_iSpectatePenaltTime[client] <= 0)
	{
		if(GetClientTeam(client)!=clientteam[client])
		{	
			bClientJoinedTeam[client] = true;
			CPrintToChat(client, "[{olive}TS{default}]] %T","Please wait",client, g_iSpectatePenaltTime[client]);
			ChangeClientTeam(client, 1);clientteam[client]=1;
		}
		if (bClientJoinedTeam[client])
		{
			PrintHintText(client, "[TS] %T","You can change team now.",client);	//only print this hint text to the spectator if he tried to join team, and got swapped before
		}
		InCoolDownTime[client] = false;
		bClientJoinedTeam[client] = false;
		g_iSpectatePenaltTime[client] = fCoolTime;
		return Plugin_Stop;
	}
	
	
	return Plugin_Continue;
}

int L4D2_GetInfectedAttacker(int client)
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

public bool HasAccess(int client, char[] g_sAcclvl)
{
	// no permissions set
	if (strlen(g_sAcclvl) == 0)
		return true;

	else if (StrEqual(g_sAcclvl, "-1"))
		return false;

	// check permissions
	if ( iClientFlags[client] & ReadFlagString(g_sAcclvl) )
	{
		return true;
	}

	return false;
}

void ResetAttackedByWitch(int client) {
	delete nClientAttackedByWitch[client];
	nClientAttackedByWitch[client] = new ArrayList();
}

void AddWitchAttack(int witchid, int client)
{
	if(nClientAttackedByWitch[client].FindValue(witchid) == -1)
	{
		nClientAttackedByWitch[client].Push(witchid);
	}
}

void RemoveWitchAttack(int witchid)
{
	int index;
	for (int client = 1; client <= MaxClients; client++) {
		if ( (index = nClientAttackedByWitch[client].FindValue(witchid)) != -1 ) {
			nClientAttackedByWitch[client].Erase(index);
		}
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(
		classname[0] == 'm' ||
		classname[0] == 'p' ||
		classname[0] == 'v' ||
		classname[0] == 'i'
	)
	{
		if(
			strncmp(classname, "molotov_projectile", 13) == 0 ||
			strncmp(classname, "pipe_bomb_projectile", 13) == 0 ||
			strncmp(classname, "inferno", 13) == 0 ||
			g_bL4D2Version && strncmp(classname, "vomitjar_projectile", 13) == 0
		)
		{
			SDKHook(entity, SDKHook_SpawnPost, SpawnPost);
			return;
		}
	}
}

public void SpawnPost(int entity)
{
	// 1 frame later required to get velocity
	RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
}

public void OnNextFrame(int entity)
{
	// Validate entity
	if( EntRefToEntIndex(entity) == INVALID_ENT_REFERENCE || !IsValidEntity(entity) )
		return;

	// Get Client
	int client;
	bool bThrowable;
	if(HasEntProp(entity, Prop_Send, "m_hThrower"))
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
		bThrowable = true;
	}
	else
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		bThrowable = false;
	}

	if( client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		if( bThrowable == true && g_fThrowableCooldown > 0.0) fThrowableTime[client] = GetEngineTime() + g_fThrowableCooldown;
		if( bThrowable == false && g_fBreakPropCooldown> 0.0) fBreakPropTime[client] = GetEngineTime() + g_fBreakPropCooldown;
	}
}

void ResetTimer()
{
	delete PlayerLeftStartTimer;
	delete CountDownTimer;
}