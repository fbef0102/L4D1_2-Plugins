/************************************************
* Plugin name:		[L4D(2)] MultiSlots
* Plugin author:	SwiftReal, MI 5, ururu, KhMaIBQ, HarryPotter
* 
* Based upon:
* - (L4D) Zombie Havoc by Bigbuck
* - (L4D2) Bebop by frool
************************************************/
#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <left4dhooks>
#undef REQUIRE_PLUGIN
#include <CreateSurvivorBot>

#define PLUGIN_VERSION 				"3.9"
#define CVAR_FLAGS					FCVAR_NOTIFY
#define DELAY_KICK_FAKECLIENT 		0.1
#define DELAY_KICK_NONEEDBOT 		5.0
#define DELAY_KICK_NONEEDBOT_SAFE   25.0
#define DELAY_CHANGETEAM_NEWPLAYER 	3.0

#define TEAM_SPECTATORS 			1
#define TEAM_SURVIVORS 				2
#define TEAM_INFECTED				3

#define DAMAGE_EVENTS_ONLY			1
#define	DAMAGE_YES					2
#define	DAMAGE_NO					0

//ConVar
ConVar hMaxSurvivors, hDeadBotTime, hSpecCheckInterval, 
	hFirstWeapon, hSecondWeapon, hThirdWeapon, hFourthWeapon, hFifthWeapon,
	hRespawnHP, hRespawnBuffHP, hStripBotWeapons, hSpawnSurvivorsAtStart;

//value
int iMaxSurvivors, iDeadBotTime, g_iFirstWeapon, g_iSecondWeapon, g_iThirdWeapon, g_iFourthWeapon, g_iFifthWeapon,
	iRespawnHP, iRespawnBuffHP;
static Handle hSetHumanSpec, hTakeOver;
int g_iRoundStart, g_iPlayerSpawn, BufferHP = -1;
bool bKill, bLeftSafeRoom, bStripBotWeapons, bSpawnSurvivorsAtStart;
float fSpecCheckInterval;
Handle SpecCheckTimer = null, PlayerLeftStartTimer = null, CountDownTimer = null;

public Plugin myinfo = 
{
	name 			= "[L4D(2)] MultiSlots Improved",
	author 			= "SwiftReal, MI 5, ururu, KhMaIBQ, HarryPotter",
	description 	= "Allows additional survivor players in coop/survival/realism when 5+ player joins the server",
	version 		= PLUGIN_VERSION,
	url 			= "https://steamcommunity.com/id/TIGER_x_DRAGON/"
}

bool bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead ) bL4D2Version = false;
	else if( test == Engine_Left4Dead2 ) bL4D2Version = true;
	else {
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success; 
}

public void OnPluginStart()
{
	// Load translation
	LoadTranslations("l4dmultislots.phrases");
	
	//store PropInfo
	BufferHP = FindSendPropInfo( "CTerrorPlayer", "m_healthBuffer" );
	
	// Register commands
	RegAdminCmd("sm_muladdbot", AddBot, ADMFLAG_KICK, "Attempt to add a survivor bot");
	RegConsoleCmd("sm_join", JoinTeam, "Attempt to join Survivors");
	RegConsoleCmd("sm_js", JoinTeam, "Attempt to join Survivors");
	
	// Register cvars
	hMaxSurvivors	= CreateConVar("l4d_multislots_max_survivors", "4", "Kick AI Survivor bots if numbers of survivors has exceeded the certain value. (does not kick real player, minimum is 4)", CVAR_FLAGS, true, 4.0, true, 32.0);
	hStripBotWeapons = CreateConVar("l4d_multislots_bot_items_delete", "1", "Delete all items form survivor bots when they got kicked by this plugin. (0=off)", CVAR_FLAGS, true, 0.0, true, 1.0);
	hDeadBotTime = CreateConVar("l4d_multislots_alive_bot_time", "100", "When 5+ new player joins the server but no any bot can be taken over, the player will appear as a dead survivor if survivors have left start safe area for at least X seconds. (0=Always spawn alive bot for new player)", CVAR_FLAGS, true, 0.0);
	hSpecCheckInterval = CreateConVar("l4d_multislots_spec_message_interval", "20", "Setup time interval the instruction message to spectator.(0=off)", CVAR_FLAGS, true, 0.0);
	hRespawnHP 		= CreateConVar("l4d_multislots_respawnhp", 		"80", 	"Amount of HP a new 5+ Survivor will spawn with (Def 80)", CVAR_FLAGS, true, 0.0, true, 100.0);
	hRespawnBuffHP 	= CreateConVar("l4d_multislots_respawnbuffhp", 	"20", 	"Amount of buffer HP a new 5+ Survivor will spawn with (Def 20)", CVAR_FLAGS, true, 0.0, true, 100.0);
	hSpawnSurvivorsAtStart = CreateConVar("l4d_multislots_spawn_survivors_roundstart", "0", "If 1, Spawn numbers of survivor bots when round starts. (Numbers depends on Convar l4d_multislots_max_survivors)", CVAR_FLAGS, true, 0.0, true, 1.0);
	
	if ( bL4D2Version ) {
		hFirstWeapon 		= CreateConVar("l4d_multislots_firstweapon", 		"10", 	"First slot weapon given to new 5+ Survivor (1-Autoshotgun, 2-SPAS Shotgun, 3-M16, 4-AK47, 5-Desert Rifle, 6-HuntingRifle, 7-Military Sniper, 8-Chrome Shotgun, 9-Silenced Smg, 10=Random T1, 11=Random T2, 0=off)", CVAR_FLAGS, true, 0.0, true, 11.0);
		hSecondWeapon 		= CreateConVar("l4d_multislots_secondweapon", 		"5", 	"Second slot weapon given to new 5+ Survivor (1 - Dual Pistol, 2 - Bat, 3 - Magnum, 4 - Chainsaw, 5=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 5.0);
		hThirdWeapon 		= CreateConVar("l4d_multislots_thirdweapon", 		"4", 	"Third slot weapon given to new 5+ Survivor (1 - Moltov, 2 - Pipe Bomb, 3 - Bile Jar, 4=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 4.0);
		hFourthWeapon 		= CreateConVar("l4d_multislots_forthweapon", 		"1", 	"Fourth slot weapon given to new 5+ Survivor (1 - Medkit, 2 - Defib, 3 - Incendiary Pack, 4 - Explosive Pack, 5=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 5.0);
		hFifthWeapon 		= CreateConVar("l4d_multislots_fifthweapon", 		"0", 	"Fifth slot weapon given to new 5+ Survivor (1 - Pills, 2 - Adrenaline, 3=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 3.0);
	} else {
		hFirstWeapon 		= CreateConVar("l4d_multislots_firstweapon", 		"6", 	"First slot weapon given to new 5+ Survivor (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - smg, 5 - shotgun, 6=Random T1, 7=Random T2, 0=off)", CVAR_FLAGS, true, 0.0, true, 7.0);
		hSecondWeapon 		= CreateConVar("l4d_multislots_secondweapon", 		"1", 	"Second slot weapon given to new 5+ Survivor (1 - Dual Pistol, 0=off)", CVAR_FLAGS, true, 0.0, true, 1.0);
		hThirdWeapon 		= CreateConVar("l4d_multislots_thirdweapon", 		"3", 	"Third slot weapon given to new 5+ SSurvivor (1 - Moltov, 2 - Pipe Bomb, 3=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 3.0);
		hFourthWeapon 		= CreateConVar("l4d_multislots_forthweapon", 		"1", 	"Fourth slot weapon given to new 5+ SSurvivor (1 - Medkit, 0=off)", CVAR_FLAGS, true, 0.0, true, 1.0);
		hFifthWeapon 		= CreateConVar("l4d_multislots_fifthweapon", 		"0", 	"Fifth slot weapon given to new 5+ Survivor (1 - Pills, 0=off)", CVAR_FLAGS, true, 0.0, true, 1.0);
	}
	
	GetCvars();
	hMaxSurvivors.AddChangeHook(ConVarChanged_Cvars);
	hStripBotWeapons.AddChangeHook(ConVarChanged_Cvars);
	hDeadBotTime.AddChangeHook(ConVarChanged_Cvars);
	hSpecCheckInterval.AddChangeHook(ConVarChanged_Cvars);
	hRespawnHP.AddChangeHook(ConVarChanged_Cvars);
	hRespawnBuffHP.AddChangeHook(ConVarChanged_Cvars);
	hFirstWeapon.AddChangeHook(ConVarChanged_Cvars);
	hSecondWeapon.AddChangeHook(ConVarChanged_Cvars);
	hThirdWeapon.AddChangeHook(ConVarChanged_Cvars);
	hFourthWeapon.AddChangeHook(ConVarChanged_Cvars);
	hFifthWeapon.AddChangeHook(ConVarChanged_Cvars);
	hSpawnSurvivorsAtStart.AddChangeHook(ConVarChanged_Cvars);
	
	// Hook events

	HookEvent("survivor_rescued", evtSurvivorRescued);
	HookEvent("player_bot_replace", evtBotReplacedPlayer);
	HookEvent("player_team", evtPlayerTeam, EventHookMode_Pre);
	HookEvent("player_spawn", evtPlayerSpawn);
	HookEvent("player_death", evtPlayerDeath);
	HookEvent("round_start", 		Event_RoundStart);
	HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
	HookEvent("map_transition", Event_RoundEnd); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", Event_RoundEnd); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd); //救援載具離開之時  (沒有觸發round_end)

	// ======================================
	// Prep SDK Calls
	// ======================================

	Handle hGameConf = LoadGameConfigFile("l4dmultislots");
	if(hGameConf == null)
	{
		SetFailState("Gamedata l4dmultislots.txt not found");
		return;
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "SetHumanSpec");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	hSetHumanSpec = EndPrepSDKCall();
	if (hSetHumanSpec == null)
	{
		SetFailState("Cant initialize SetHumanSpec SDKCall");
		return;
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "TakeOverBot");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	hTakeOver = EndPrepSDKCall();
	if( hTakeOver == null)
	{
		SetFailState("Could not prep the \"TakeOverBot\" function.");
		return;
	}
	delete hGameConf;
	
	// Create or execute plugin configuration file
	AutoExecConfig(true, "l4dmultislots");
}

public void OnPluginEnd()
{
	ClearDefault();
	ResetTimer();
}

public void OnMapStart()
{
	TweakSettings();
}

public void OnMapEnd()
{
	ClearDefault();
	ResetTimer();
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	iMaxSurvivors = hMaxSurvivors.IntValue;
	bStripBotWeapons = hStripBotWeapons.BoolValue;
	iDeadBotTime = hDeadBotTime.IntValue;
	fSpecCheckInterval = hSpecCheckInterval.FloatValue;
	bSpawnSurvivorsAtStart = hSpawnSurvivorsAtStart.BoolValue;
	
	iRespawnHP = hRespawnHP.IntValue;
	iRespawnBuffHP = hRespawnBuffHP.IntValue;
	
	g_iFirstWeapon = hFirstWeapon.IntValue;
	g_iSecondWeapon = hSecondWeapon.IntValue;
	g_iThirdWeapon = hThirdWeapon.IntValue;
	g_iFourthWeapon = hFourthWeapon.IntValue;
	g_iFifthWeapon = hFifthWeapon.IntValue;
}

////////////////////////////////////
// Callbacks
////////////////////////////////////
public Action AddBot(int client, int args)
{
	if(client == 0)
		return Plugin_Continue;
	
	if(SpawnFakeClient() == true)
		PrintToChat(client, "%T", "A surviving Bot was added.", client);
	else
		PrintToChat(client, "%T", "Impossible to generate a bot at the moment.", client);
	
	return Plugin_Handled;
}


public Action JoinTeam(int client,int args)
{
	if(!client || !IsClientInGame(client))
		return Plugin_Handled;

	CreateTimer(0.15, JoinTeam_ColdDown, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

////////////////////////////////////
// Events
////////////////////////////////////
public void OnClientPutInServer(int client)
{
	if(client && IsClientInGame(client) && !IsFakeClient(client))
	{
		CreateTimer(DELAY_CHANGETEAM_NEWPLAYER, Timer_AutoJoinTeam, GetClientUserId(client));
	}
}

public void evtPlayerTeam(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	int oldteam = event.GetInt("oldteam");
	
	if(oldteam == 1 || event.GetBool("disconnect"))
	{
		if(client && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == TEAM_SPECTATORS)
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsAlive(i))
				{
					if(HasEntProp(i, Prop_Send, "m_humanSpectatorUserID"))
					{
						if(GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID")) == client)
						{
							//LogMessage("afk player %N changes team or leaves the game, his bot is %N",client,i);
							if(!bLeftSafeRoom)
								CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, GetClientUserId(i));
							else
								CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, GetClientUserId(i));
								
							break;
						}
					}
				}
			}
		}
	}
}

public void evtSurvivorRescued(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("victim"));
	if(client && IsClientInGame(client))
	{	
		GiveRandomT1Weapon(client);
	}
}

public void evtBotReplacedPlayer(Event event, const char[] name, bool dontBroadcast) 
{
	int fakebotid = event.GetInt("bot");
	int fakebot = GetClientOfUserId(fakebotid);
	if(fakebot && IsClientInGame(fakebot) && GetClientTeam(fakebot) == TEAM_SURVIVORS && IsFakeClient(fakebot))
	{
		if(!bLeftSafeRoom)
			CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, fakebotid);
		else
			CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, fakebotid);
	}
}

public void evtPlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS)
	{
		if(IsFakeClient(client))
		{
			if(!bLeftSafeRoom)
				CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, userid);
			else
				CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, userid);
		}
		else
		{
			if(bSpawnSurvivorsAtStart)
				CreateTimer(0.2, Timer_KickNoNeededBot2);
		}
	}

	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, PluginStart);
	g_iPlayerSpawn = 1;	
}

public void evtPlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsFakeClient(client))
	{
		if(!bLeftSafeRoom)
			CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, userid);
		else
			CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, userid);
	}	
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ClearDefault();
	ResetTimer();
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, PluginStart);
	g_iRoundStart = 1;
}
////////////////////////////////////
// timers
////////////////////////////////////
public Action JoinTeam_ColdDown(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client))
	{
		if(GetClientTeam(client) == TEAM_INFECTED)
		{
			ChangeClientTeam(client, TEAM_SPECTATORS);
			CreateTimer(0.5, Timer_AutoJoinTeam, GetClientUserId(client));	
		}
		else if(GetClientTeam(client) == TEAM_SURVIVORS)
		{	
			if(DispatchKeyValue(client, "classname", "player") == true)
			{
				//PrintHintText(client, "%T", "You are already on the team of survivors.", client);
			}
			else if((DispatchKeyValue(client, "classname", "info_survivor_position") == true) && !IsAlive(client))
			{
				PrintHintText(client, "%T", "Please wait to be revived or rescued", client);
			}
		}
		else if(IsClientIdle(client))
		{
			PrintHintText(client, "%T", "You are idle. press the left mouse button to join the survivors!", client); 
		}
		else
		{			
			if(TotalAliveFreeBots() == 0)
			{
				if(SpawnFakeClient() == true)
				{
					if(bKill && iDeadBotTime > 0) CreateTimer(0.5, Timer_TakeOverBotAndDie, userid, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					else CreateTimer(0.5, Timer_AutoJoinTeam, userid);	
				}
				else
				{
					PrintHintText(client, "%T", "Impossible to generate a bot at the moment.", client);
				}
			}
			else
			{
				TakeOverBot(client);
			}
		}
	}
}

int iCountDownTime;
public Action PluginStart(Handle timer)
{
	ClearDefault();
	if(bSpawnSurvivorsAtStart) CreateTimer(0.25, Timer_SpawnSurvivorWhenRoundStarts, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	if(PlayerLeftStartTimer == null) PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);
	if(SpecCheckTimer == null && fSpecCheckInterval > 0.0) SpecCheckTimer = CreateTimer(fSpecCheckInterval, Timer_SpecCheck, _, TIMER_REPEAT)	;
}

public Action Timer_SpecCheck(Handle timer)
{
	if(fSpecCheckInterval == 0.0)
	{
		SpecCheckTimer = null;
		return Plugin_Stop;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if((GetClientTeam(i) == TEAM_SPECTATORS) && !IsFakeClient(i))
			{
				if(!IsClientIdle(i))
				{
					static char PlayerName[100];
					GetClientName(i, PlayerName, sizeof(PlayerName))		;
					CPrintToChat(i, "{default}[{green}MultiSlots{default}] %s, %T", PlayerName, "Type in chat !join To join the survivors", i);
				}
			}
		}
	}	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))		
		{
			if((GetClientTeam(i) == TEAM_SURVIVORS) && !IsFakeClient(i) && !IsAlive(i))
			{
				static char PlayerName[100];
				GetClientName(i, PlayerName, sizeof(PlayerName));
				PrintToChat(i, "\x01[\x04MultiSlots\x01] %s, %T", PlayerName, "Please wait to be revived or rescued", i);
			}
		}
	}	
	return Plugin_Continue;
}

public Action Timer_KillSurvivor(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsPlayerAlive(client))
	{
		StripWeapons(client);
		ForcePlayerSuicide(client);
		PrintHintText(client, "%T", "The survivors has started the game, please wait to be resurrected or rescued", client);
	}
}

public Action Timer_TakeOverBotAndDie(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) return Plugin_Stop;

	int team = GetClientTeam(client);
	if(team == TEAM_SPECTATORS)
	{
		if(IsClientIdle(client))
		{
			SDKCall(hTakeOver, client, true);
		}
		else
		{
			int fakebot = FindBotToTakeOver(true);
			if (fakebot == 0)
			{
				PrintHintText(client, "%T", "No Bots for replacement.", client);
				return Plugin_Stop;
			}

			SDKCall(hSetHumanSpec, fakebot, client);
			SDKCall(hTakeOver, client, true);
		}

		CreateTimer(0.1, Timer_KillSurvivor, userid);
	}
	else if (team == TEAM_SURVIVORS)
	{
		if(IsPlayerAlive(client))
		{
			CreateTimer(0.1, Timer_KillSurvivor, userid);
		}
		else
		{
			return Plugin_Stop;
		}
	}
	else if (team == TEAM_INFECTED)
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action Timer_AutoJoinTeam(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(!client || !IsClientInGame(client))
		return;
	
	if(GetClientTeam(client) == TEAM_SURVIVORS)
		return;
	
	if(IsClientIdle(client))
		return;

	CreateTimer(0.1, JoinTeam_ColdDown, userid, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_KickNoNeededBot(Handle timer, int botid)
{
	int botclient = GetClientOfUserId(botid);

	if((TotalSurvivors() <= iMaxSurvivors))
		return Plugin_Handled;
	
	if(botclient && IsClientInGame(botclient) && IsFakeClient(botclient) && GetClientTeam(botclient) == TEAM_SURVIVORS)
	{
		if(!IsAlive(botclient) || !HasIdlePlayer(botclient))
		{
			if(bStripBotWeapons) StripWeapons(botclient);
			KickClient(botclient, "Kicking No Needed Bot");
		}
	}	
	return Plugin_Handled;
}

public Action Timer_KickNoNeededBot2(Handle timer)
{
	if((TotalSurvivors() <= iMaxSurvivors))
		return Plugin_Continue;

	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i)==TEAM_SURVIVORS && !HasIdlePlayer(i))
		{
			if(bStripBotWeapons) StripWeapons(i);
			KickClient(i, "Kicking No Needed Bot");
			return Plugin_Continue;
		}
	}

	return Plugin_Continue;
}

public Action Timer_SpawnSurvivorWhenRoundStarts(Handle timer, int client)
{
	int team_count = TotalAliveSurvivors();
	if(team_count < 4) return Plugin_Continue;

	//LogMessage("Spawn Timer_SpawnSurvivorWhenRoundStarts: %d, %d", team_count, iMaxSurvivors);
	if(team_count < iMaxSurvivors)
	{
		SpawnFakeClient();
		return Plugin_Continue;
	}

	return Plugin_Stop;
}
////////////////////////////////////
// stocks
////////////////////////////////////
void ClearDefault()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
	bKill = false;
	bLeftSafeRoom = false;
}


void TweakSettings()
{
	Handle hMaxSurvivorsLimitCvar = FindConVar("survivor_limit");
	SetConVarBounds(hMaxSurvivorsLimitCvar,  ConVarBound_Lower, true, 4.0);
	SetConVarBounds(hMaxSurvivorsLimitCvar, ConVarBound_Upper, true, 32.0);
	SetConVarInt(hMaxSurvivorsLimitCvar, iMaxSurvivors);
	
	SetConVarInt(FindConVar("z_spawn_flow_limit"), 50000) ;// allow spawning bots at any time
}

void TakeOverBot(int client)
{
	if (!IsClientInGame(client)) return;
	if (GetClientTeam(client) == TEAM_SURVIVORS) return;
	if (IsFakeClient(client)) return;

	int fakebot = FindBotToTakeOver(true);
	if (fakebot == 0)
	{
		PrintHintText(client, "%T", "No Bots for replacement.", client);
		return;
	}

	if(IsPlayerAlive(fakebot))
	{
		SDKCall(hSetHumanSpec, fakebot, client);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 5);
	}

	return;
}

int FindBotToTakeOver(bool alive)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if (IsFakeClient(i) && GetClientTeam(i)==TEAM_SURVIVORS && !HasIdlePlayer(i) && IsPlayerAlive(i) == alive)
				return i;
		}
	}
	return 0;
}

void BypassAndExecuteCommand(int client, char[] strCommand, char[] strParam1)
{
	int flags = GetCommandFlags(strCommand);
	SetCommandFlags(strCommand, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", strCommand, strParam1);
	SetCommandFlags(strCommand, flags);
}

void StripWeapons(int client) // strip all items from client
{
	int itemIdx;
	for (int x = 0; x <= 4; x++)
	{
		if((itemIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{  
			RemovePlayerItem(client, itemIdx);
			AcceptEntityInput(itemIdx, "Kill");
		}
	}
}

void GiveRandomT1Weapon(int client) // give client random weapon
{
	if(GetPlayerWeaponSlot(client, 1) != -1)
	{
		int random;
		if(bL4D2Version) random = GetRandomInt(1,4);
		else random = GetRandomInt(1,2);
		switch(random)
		{
			case 1: BypassAndExecuteCommand(client, "give", "smg");
			case 2: BypassAndExecuteCommand(client, "give", "pumpshotgun");
			case 3: BypassAndExecuteCommand(client, "give", "smg_silenced");
			case 4: BypassAndExecuteCommand(client, "give", "shotgun_chrome");
		}
	}
}

int TotalSurvivors() // total bots, including players
{
	int kk = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && (GetClientTeam(i) == TEAM_SURVIVORS))
			kk++;
	}
	return kk;
}

int TotalAliveFreeBots() // total bots (excl. IDLE players)
{
	int kk = 0;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i)==TEAM_SURVIVORS && IsAlive(i))
		{
			if(!HasIdlePlayer(i))
				kk++;
		}
	}
	return kk;
}

int TotalAliveSurvivors() // total alive survivors, including players
{
	int kk = 0;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i)==TEAM_SURVIVORS && IsAlive(i))
		{
			kk++;
		}
	}
	return kk;
}

void ResetTimer()
{
	delete SpecCheckTimer;
	delete PlayerLeftStartTimer;
	delete CountDownTimer;
}


//try to spawn survivor
bool SpawnFakeClient()
{
	//check if there are any alive survivor in server
	int iAliveSurvivor = GetRandomClient();
	if(iAliveSurvivor == 0)
		return false;
		
	// create fakeclient
	int fakeclient = CreateSurvivorBot();
	
	// if entity is valid
	if(fakeclient > 0 && IsClientInGame(fakeclient))
	{
		float teleportOrigin[3];
		GetClientAbsOrigin(iAliveSurvivor, teleportOrigin)	;
		DataPack hPack = new DataPack();
		hPack.WriteCell(GetClientUserId(fakeclient));
		hPack.WriteFloat(teleportOrigin[0]);
		hPack.WriteFloat(teleportOrigin[1]);
		hPack.WriteFloat(teleportOrigin[2]);
		
		RequestFrame(OnNextFrame, hPack);
		
		return true;
	}
	
	return false;
}

public void OnNextFrame(DataPack hPack)
{
	float nPos[3];
	hPack.Reset();
	int fakeclient = GetClientOfUserId(hPack.ReadCell());
	nPos[0] = hPack.ReadFloat();
	nPos[1] = hPack.ReadFloat();
	nPos[2] = hPack.ReadFloat();
	delete hPack;

	if(!fakeclient || !IsClientInGame(fakeclient)) return;
	
	TeleportEntity( fakeclient, nPos, NULL_VECTOR, NULL_VECTOR);

	if ( !(bKill && iDeadBotTime > 0) )
	{
		StripWeapons( fakeclient );
		SetHealth( fakeclient );
		GiveItems( fakeclient );
	}
}

bool HasIdlePlayer(int bot)
{
	if(HasEntProp(bot, Prop_Send, "m_humanSpectatorUserID"))
	{
		int client = GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));		
		if(client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && IsClientObserver(client))
		{
			return true;
		}
	}
	
	return false;
}

bool IsClientIdle(int client)
{
	if(GetClientTeam(client) != TEAM_SPECTATORS)
		return false;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsAlive(i))
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

bool IsAlive(int client)
{
	if(!GetEntProp(client, Prop_Send, "m_lifeState"))
		return true;
	
	return false;
}

public Action Timer_PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea())
	{	
		bLeftSafeRoom = true;
		iCountDownTime = iDeadBotTime;
		if(iCountDownTime > 0)
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
	if(iCountDownTime <= 0) 
	{
		bKill = true;
		CountDownTimer = null;
		return Plugin_Stop;
	}
	iCountDownTime--;
	return Plugin_Continue;
}


int GetRandomClient()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i))
		{
			iClients[iClientCount++] = i;
		}
	}
	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

void SetHealth( int client )
{
	float Buff = GetEntDataFloat( client, BufferHP );

	SetEntProp( client, Prop_Send, "m_iHealth", iRespawnHP, 1 );
	SetEntDataFloat( client, BufferHP, Buff + iRespawnBuffHP, true );
}

void GiveItems(int client) // give client weapon
{
	int flags = GetCommandFlags("give");
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);
	
	int iRandom = g_iFirstWeapon;
	if(bL4D2Version)
	{
		if(g_iFirstWeapon == 10) iRandom = GetRandomInt(8,9);
		else if(g_iFirstWeapon == 11) iRandom = GetRandomInt(1,7);
		
		switch ( iRandom )
		{
			case 1: FakeClientCommand( client, "give autoshotgun" );
			case 2: FakeClientCommand( client, "give shotgun_spas" );
			case 3: FakeClientCommand( client, "give rifle" );
			case 4: FakeClientCommand( client, "give rifle_ak47" );
			case 5: FakeClientCommand( client, "give rifle_desert" );
			case 6: FakeClientCommand( client, "give hunting_rifle" );
			case 7: FakeClientCommand( client, "give sniper_military" );
			case 8: FakeClientCommand( client, "give shotgun_chrome" );
			case 9: FakeClientCommand( client, "give smg_silenced" );
			default: {}//nothing
		}
	}
	else
	{
		if(g_iFirstWeapon == 6) iRandom = GetRandomInt(4,5);
		else if(g_iFirstWeapon == 7) iRandom = GetRandomInt(1,3);
		
		switch ( iRandom )
		{
			case 1: FakeClientCommand( client, "give autoshotgun" );
			case 2: FakeClientCommand( client, "give rifle" );
			case 3: FakeClientCommand( client, "give hunting_rifle" );
			case 4: FakeClientCommand( client, "give smg" );
			case 5: FakeClientCommand( client, "give pumpshotgun" );
			default: {}//nothing
		}
	}
	
	
	iRandom = g_iSecondWeapon;
	if(bL4D2Version && iRandom == 5) iRandom = GetRandomInt(1,4);
		
	switch ( iRandom )
	{
		case 1:
		{
			FakeClientCommand( client, "give pistol" );
			FakeClientCommand( client, "give pistol" );
		}
		case 2: FakeClientCommand( client, "give baseball_bat" );
		case 3: FakeClientCommand( client, "give pistol_magnum" );
		case 4: FakeClientCommand( client, "give chainsaw" );
		default: {}//nothing
	}
	
	iRandom = g_iThirdWeapon;
	if (bL4D2Version && iRandom == 4) iRandom = GetRandomInt(1,3);
	if (!bL4D2Version && iRandom == 3) iRandom = GetRandomInt(1,2);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give molotov" );
		case 2: FakeClientCommand( client, "give pipe_bomb" );
		case 3: FakeClientCommand( client, "give vomitjar" );
		default: {}//nothing
	}
	
	
	iRandom = g_iFourthWeapon;
	if(bL4D2Version && iRandom == 5) iRandom = GetRandomInt(1,4);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give first_aid_kit" );
		case 2: FakeClientCommand( client, "give defibrillator" );
		case 3: FakeClientCommand( client, "give weapon_upgradepack_incendiary" );
		case 4: FakeClientCommand( client, "give weapon_upgradepack_explosive" );
		default: {}//nothing
	}
	
	iRandom = g_iFifthWeapon;
	if(bL4D2Version && iRandom == 3) iRandom = GetRandomInt(1,2);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give pain_pills" );
		case 2: FakeClientCommand( client, "give adrenaline" );
		default: {}//nothing
	}
	
	SetCommandFlags( "give", flags);
}