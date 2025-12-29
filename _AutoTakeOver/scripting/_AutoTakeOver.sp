// 2017 @ Lux
// 2022 @ Harry

#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#define Plugin_Version "2.4"
#define CHAT_TAGS "\x04[AutoTakeOver]\x03"

ConVar g_hCvarEnable, g_hCvarCoopTakeOverMethod, g_hCvarTakeOverUponRandom, g_hCvarTakeOverUponDeath,
	g_hCvarTakeOverOnBotSpawnDead, g_hCvarTakeOverOnBotSpawnSpectator, g_hCvarTakeOverOnJoinServer;
ConVar g_hCvarMPGameMode;

bool g_bCvarEnable, g_bCvarCpTakeOverMethod, g_bCvarTakeOverUponRandom, g_bCvarTakeOverUponDeath,
	g_bCvarTakeOverOnBotSpawnDead, g_bCvarTakeOverOnBotSpawnSpectator, g_bCvarTakeOverOnJoinServer;
bool g_bCoop;

bool bTakeOverInprogress, g_bMapStarted, g_bRoundOver;
Handle TakeOverBotTimer[MAXPLAYERS+1] = {null};

public Plugin myinfo =
{
	name = "[L4D/L4D2]AutoTakeOver",
	author = "Lux, Harry",
	description = "Auto Takes Over an alive free bot UponDeath or OnBotSpawn or OnBotReplace in 5+ survivors",
	version = Plugin_Version,
	url = "https://forums.alliedmods.net/showthread.php?t=293770"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead && test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateConVar("auto_take_over", Plugin_Version, "Plugin_Version", FCVAR_DONTRECORD|FCVAR_NOTIFY|FCVAR_SPONLY);
	g_hCvarEnable 						= CreateConVar("AutoTakeOver_enabled", 							"1", "0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarCoopTakeOverMethod 			= CreateConVar("AutoTakeOver_coop_take_over_method", 			"0", "If 1, you will skip idle state in survival/coop/realism.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarTakeOverUponRandom 			= CreateConVar("AutoTakeOver_take_over_random", 				"0", "If 1, choose a random available bot. If 0, choose the best bot available. (not incapacitated and with highest HP)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarTakeOverUponDeath 			= CreateConVar("AutoTakeOver_take_over_UponDeath", 				"1", "If 1, when a survivor player dies, he will take over an alive free bot if any.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarTakeOverOnBotSpawnDead 		= CreateConVar("AutoTakeOver_take_over_OnBotSpawn_dead",		"1", "If 1, when a survivor bot spawns or replaces a player, any dead survivor player will take over bot. (Random choose dead survivor)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarTakeOverOnBotSpawnSpectator 	= CreateConVar("AutoTakeOver_take_over_OnBotSpawn_spectator", 	"0", "If 1, when a survivor bot spawns or replaces a player, any free spectator player will take over bot. (Random choose free spectator)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarTakeOverOnJoinServer 		= CreateConVar("AutoTakeOver_take_over_OnJoinServer", 			"1", "If 1, when a player joins server, he will take over an alive free bot if any. (Random choose bot)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig(true, "_AutoTakeOver");

	HookEvent("player_death", ePlayerDeath);
	HookEvent("player_team", eTeamChange);
	HookEvent("round_end", eRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("map_transition", eRoundEnd, EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (之後沒有觸發round_end)
	HookEvent("mission_lost", eRoundEnd, EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", eRoundEnd, EventHookMode_PostNoCopy); //救援載具離開之時 (之後沒有觸發round_end)

	HookEvent("round_start", eRoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn", ePlayerSpawn);

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarGameMode);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarCoopTakeOverMethod.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTakeOverUponDeath.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTakeOverUponRandom.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTakeOverOnBotSpawnDead.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTakeOverOnBotSpawnSpectator.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTakeOverOnJoinServer.AddChangeHook(ConVarChanged_Cvars);

	RegAdminCmd("sm_printbestavailablebots", CmdPrintBestAvailableBots, ADMFLAG_ROOT, "Lists all available survivor bots, ordered from best to worst.");
}

void ConVarGameMode(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();

	CheckGameMode();
}

void ConVarChanged_Cvars(Handle hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarCpTakeOverMethod = g_hCvarCoopTakeOverMethod.BoolValue;
	g_bCvarTakeOverUponRandom = g_hCvarTakeOverUponRandom.BoolValue;
	g_bCvarTakeOverUponDeath = g_hCvarTakeOverUponDeath.BoolValue;
	g_bCvarTakeOverOnBotSpawnDead = g_hCvarTakeOverOnBotSpawnDead.BoolValue;
	g_bCvarTakeOverOnBotSpawnSpectator = g_hCvarTakeOverOnBotSpawnSpectator.BoolValue;
	g_bCvarTakeOverOnJoinServer = g_hCvarTakeOverOnJoinServer.BoolValue;
}

void CheckGameMode()
{
	if( g_bMapStarted == false )
		return;

	if( g_hCvarMPGameMode == null )
		return;

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
	{
		g_bCoop = true;
	}
	else if( strcmp(output, "OnSurvival") == 0 )
	{
		g_bCoop = true;
	}
	else if( strcmp(output, "OnVersus") == 0 )
	{
		g_bCoop = false;
	}
	else if( strcmp(output, "OnScavenge") == 0 )
	{
		g_bCoop = false;
	}
	else
	{
		g_bCoop = false;
	}
}

public void OnMapStart()
{
	g_bMapStarted = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	ResetTimer();
}

public void OnConfigsExecuted()
{
	CheckGameMode();
}

public void OnClientPutInServer(int client)
{
	if(IsFakeClient(client) || !g_bCvarTakeOverOnJoinServer) return;

	delete TakeOverBotTimer[client];
	TakeOverBotTimer[client] = CreateTimer(5.0, Timer_TakeOverBot, client);
}

public void OnClientDisconnect(int client)
{
	if(!IsClientInGame(client)) return;

	delete TakeOverBotTimer[client];
}

public void ePlayerDeath(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	if(!g_bCvarEnable || g_bRoundOver || !g_bCvarTakeOverUponDeath)
		return;

	int client = GetClientOfUserId(hEvent.GetInt("userid"));

	if(!client || !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != L4D_TEAM_SURVIVOR)
		return;

	delete TakeOverBotTimer[client];
	TakeOverBotTimer[client] = CreateTimer(3.0, Timer_TakeOverBot, client);
}

public void eTeamChange(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	if(bTakeOverInprogress) return;

	int client = GetClientOfUserId(hEvent.GetInt("userid"));

	delete TakeOverBotTimer[client];
}

//playerspawn is triggered even when bot or human takes over each other (even they are already dead state) or a survivor is spawned
public void ePlayerSpawn(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int bot = GetClientOfUserId(hEvent.GetInt("userid"));

	if(!bot || !IsClientInGame(bot) || !IsFakeClient(bot) || GetClientTeam(bot) != L4D_TEAM_SURVIVOR)
		return;

	delete TakeOverBotTimer[bot];
	TakeOverBotTimer[bot] = CreateTimer(3.0, Timer_BotBeTakenOver, bot);
}

public void eRoundStart(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	g_bRoundOver = false;
}

public void eRoundEnd(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	g_bRoundOver = true;
	ResetTimer();
}

public Action Timer_TakeOverBot(Handle hTimer, int client)
{
	TakeOverBotTimer[client] = null;

	if(!g_bCvarEnable || g_bRoundOver) return Plugin_Continue;
	if(!client || !IsClientInGame(client) || IsFakeClient(client)) return Plugin_Continue;

	int team = GetClientTeam(client);
	if(team == L4D_TEAM_INFECTED) return Plugin_Continue;
	if(team == L4D_TEAM_SURVIVOR && IsPlayerAlive(client)) return Plugin_Continue;
	if(team == L4D_TEAM_SPECTATOR && IsClientIdle(client)) return Plugin_Continue;

	int iPotentialBot = 0;
	if (g_bCvarTakeOverUponRandom)
		iPotentialBot = GetRandomAvailableBot();
	else
		iPotentialBot = GetFirstBestAvailableBot();

	if(iPotentialBot == 0)
	{
		PrintToChat(client, "%s No Available Bots\n Awaiting Free Bot For \x04Hostle TakeOver", CHAT_TAGS);
		return Plugin_Continue;
	}

	AutoTakeOverBot(client, iPotentialBot);

	return Plugin_Continue;
}

public Action Timer_BotBeTakenOver(Handle hTimer, int bot)
{
	TakeOverBotTimer[bot] = null;

	if(!g_bCvarEnable || g_bRoundOver) return Plugin_Continue;
	if(!bot || !IsClientInGame(bot) || !IsFakeClient(bot)) return Plugin_Continue;
	if(GetClientTeam(bot) != L4D_TEAM_SURVIVOR || !IsPlayerAlive(bot)) return Plugin_Continue;
	if(HasIdlePlayer(bot) == true) return Plugin_Continue;

	//check if any dead survivors/spectators are waiting for a takeover
	int iClientCount, iClients[MAXPLAYERS+1];
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || IsFakeClient(i)) continue;

		if(g_bCvarTakeOverOnBotSpawnDead && GetClientTeam(i) == L4D_TEAM_SURVIVOR && !IsPlayerAlive(i))
		{
			iClients[iClientCount++] = i;
			continue;
		}

		if(g_bCvarTakeOverOnBotSpawnSpectator && GetClientTeam(i) == L4D_TEAM_SPECTATOR && !IsClientIdle(i))
		{
			iClients[iClientCount++] = i;
			continue;
		}
	}

	int iChosenClient = (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];

	if(iChosenClient == 0) return Plugin_Continue;

	AutoTakeOverBot(iChosenClient, bot);

	return Plugin_Continue;
}

int GetRandomAvailableBot()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && IsFakeClient(i))
			if(GetClientTeam(i) == L4D_TEAM_SURVIVOR && IsPlayerAlive(i))
				if(!HasIdlePlayer(i))
					iClients[iClientCount++] = i;

	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

bool HasIdlePlayer(int iBot)
{
	if( HasEntProp(iBot, Prop_Send, "m_humanSpectatorUserID"))
	{
		if(GetEntProp(iBot, Prop_Send, "m_humanSpectatorUserID") > 0)
		{
			return true;
		}
	}

	return false;
}

bool IsClientIdle(int client)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == L4D_TEAM_SPECTATOR && IsPlayerAlive(i))
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

void ResetTimer()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		delete TakeOverBotTimer[i];
	}
}

void AutoTakeOverBot(int client, int bot)
{
	bTakeOverInprogress = true;//this bool is to stop any code from being run on eChangeTeam hook on the stack to save cpu and any unintended bad effects

	ChangeClientTeam(client, L4D_TEAM_SPECTATOR);
	if(g_bCoop)
	{
		if(g_bCvarCpTakeOverMethod)
		{
			PrintToChat(client, "%s Take over an alive free bot", CHAT_TAGS);
			L4D_SetHumanSpec(bot, client);
			L4D_TakeOverBot(client);
		}
		else
		{
			PrintToChat(client, "%s Take over an alive free bot, please press left mouse to join", CHAT_TAGS);
			L4D_SetHumanSpec(bot, client);
			SetEntProp(client, Prop_Send, "m_iObserverMode", 5);
		}
	}
	else
	{
		PrintToChat(client, "%s Take over an alive free bot", CHAT_TAGS);
		L4D_SetHumanSpec(bot, client);
		L4D_TakeOverBot(client);
	}

	bTakeOverInprogress = false;
}

enum struct BotInfo
{
	int client;
	int isIncapacitated;
	int health;
}

int GetFirstBestAvailableBot()
{
	ArrayList alBots = GetBotsList();

	int iBot = 0;

	if (alBots.Length > 0)
	{
		BotInfo bot;
		alBots.GetArray(0, bot, sizeof(bot));
		iBot = bot.client;
	}

	delete alBots;

	return iBot;
}

Action CmdPrintBestAvailableBots(int client, int args)
{
	if (!client)
		return Plugin_Handled;

	int printTop;
	if (args > 0)
		printTop = GetCmdArgInt(1);

	ArrayList alBots = GetBotsList();

	if (alBots.Length > 0)
	{
		ReplySource replySource = GetCmdReplySource();

		for (int index = 0; index < alBots.Length; index++)
		{
			BotInfo bot;
			alBots.GetArray(index, bot, sizeof(bot));

			switch (replySource)
			{
				case SM_REPLY_TO_CONSOLE: PrintToConsole(client, "%2d. %12N = INCAP: %3s | HP: %3d", index+1, bot.client, bot.isIncapacitated ? "YES" : "NO", bot.health);
				case SM_REPLY_TO_CHAT: PrintToChat(client, "\x03%d. \x05%N\x01 = INCAP: \x04%s\x01 | HP: \x04%d\x01", index+1, bot.client, bot.isIncapacitated ? "YES" : "NO", bot.health);
			}

			if (printTop == index+1)
				break;
		}
	}

	delete alBots;

	return Plugin_Handled;
}

ArrayList GetBotsList()
{
	ArrayList alBots = new ArrayList(sizeof(BotInfo));

	for (int target = 1; target <= MaxClients; target++)
	{
		if (!IsClientInGame(target))
			continue;

		if (!IsFakeClient(target))
			continue;

		if (GetClientTeam(target) != L4D_TEAM_SURVIVOR)
			continue;

		if (!IsPlayerAlive(target))
			continue;

		if (HasIdlePlayer(target))
			continue;

		BotInfo bot;
		bot.client = target;
		bot.isIncapacitated = GetEntProp(target, Prop_Send, "m_isIncapacitated");
		bot.health = GetEntProp(target, Prop_Send, "m_iHealth") + GetClientTempHealth(target);
		alBots.PushArray(bot, sizeof(bot));
	}

	if (alBots.Length > 0)
		alBots.SortCustom(SortByBestDescending);

	return alBots;
}

public int SortByBestDescending(int index1, int index2, Handle array, Handle hndl)
{
	ArrayList list = view_as<ArrayList>(array);
	BotInfo bot1;
	BotInfo bot2;
	list.GetArray(index1, bot1, sizeof(bot1));
	list.GetArray(index2, bot2, sizeof(bot2));

	// First sort by isIncapacitated ascending (not incapacitateds on top)
	if (bot1.isIncapacitated < bot2.isIncapacitated)
		return -1;

	if (bot1.isIncapacitated > bot2.isIncapacitated)
		return 1;

	// Then sort by health descending
	if (bot1.health > bot2.health)
		return -1;

	if (bot1.health < bot2.health)
		return 1;

	// Then sort by client index ascending
	if (bot1.client < bot2.client)
		return -1;

	if (bot1.client > bot2.client)
		return 1;

	return 0;
}

int GetClientTempHealth(int client)
{
	int tempHealth = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * FindConVar("pain_pills_decay_rate").FloatValue));
	return tempHealth < 0 ? 0 : tempHealth;
}
