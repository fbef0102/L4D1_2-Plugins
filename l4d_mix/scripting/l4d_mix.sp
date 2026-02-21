#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>
#undef REQUIRE_PLUGIN
#tryinclude <readyup>

#define PLUGIN_VERSION		"1.2h-2026/2/20"

public Plugin myinfo = 
{
	name = "Left 4 Dead 1/2 Mix",
	author = "HarryPotter",
	description = "L4D1/2 Mix",
	version = PLUGIN_VERSION,
	url = "https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d_mix"
};

bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test == Engine_Left4Dead )
    {
        g_bL4D2Version = false;
    }
    else if( test == Engine_Left4Dead2 )
    {
        g_bL4D2Version = true;
    }
    else
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

#define G_flTickInterval 0.25

ConVar g_CvarSurvLimit, g_CvarMaxPlayerZombies;

bool g_bTeamRequested[4];
int g_iPlayerSelectOrder;

ConVar g_hPlayerSelectOrder,
	g_hCvarSpectatorVote, g_hCvarVoteSpectator, g_hCvarChooseCaptain;

bool g_bCvarSpectatorVote, g_bCvarVoteSpectator;
int g_iMixCurStatus, g_iCvarChooseCaptain;

bool g_bSelectToggle;
int g_SelectToggleNum;
bool g_bHasVoted[MAXPLAYERS+1];
bool g_bHasOneVoted;
bool g_bHasBeenChosen[MAXPLAYERS+1];
bool g_lock;
int g_iSurvivorCaptain, g_iInfectedCaptain;
int g_iVotesSurvivorCaptain[MAXPLAYERS+1], g_iVotesInfectedCaptain[MAXPLAYERS+1];
int g_iDesignatedTeam[MAXPLAYERS+1];
int g_iSelectedPlayers[MAXPLAYERS+1];
char teamName[64] ;
char oppositeTeamName[64] ;

bool g_bGameStart;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");

	g_CvarSurvLimit = FindConVar("survivor_limit");
	g_CvarMaxPlayerZombies = FindConVar("z_max_player_zombies");

	g_hPlayerSelectOrder 	= CreateConVar( "l4d_mix_select_order", 	"1", "How captain choose the member, 0 = ABABAB | 1 = ABBAAB | 2 = ABBABA", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	g_hCvarSpectatorVote 	= CreateConVar(	"l4d_mix_spectator_vote", 	"1", "If 1, specators can vote to choose the captain", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarVoteSpectator 	= CreateConVar(	"l4d_mix_vote_spectator", 	"1", "If 1, players can vote the spectators to be the captain + captains can choose spectators", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarChooseCaptain	= CreateConVar(	"l4d_mix_choose_captain", 	"0", "How to select captain ? 0=Vote, 1=Random choose from survivor team and infected team", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateConVar(                      		"l4d_mix_version",       	PLUGIN_VERSION, "l4d_trade_player Plugin Version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	AutoExecConfig(true,               		"l4d_mix");

	RegConsoleCmd("sm_mix", Command_Captainvote, "Initiate a player mix.");
	RegAdminCmd("sm_forcemix", Command_ForceCaptainvote, ADMFLAG_ROOT, "Initiate a player mix. Admins only.");
	
	MixStatus_Changed(0);

	GetCvars();
	g_hPlayerSelectOrder.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarSpectatorVote.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarVoteSpectator.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarChooseCaptain.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("round_start", Event_RoundStart);
	if(g_bL4D2Version) 
	{
		HookEvent("survival_round_start",   Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //生存模式之下計時開始之時 (一代沒有此事件)
		HookEvent("scavenge_round_start",   Event_ScavengeRoundStart,		EventHookMode_PostNoCopy); //清道夫模式之下計時開始之時 (一代沒有清道夫模式)
	}
	else
	{
		HookEvent("create_panic_event" , Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //一代生存模式之下計時開始觸發屍潮
	}
	HookEvent("round_end", Event_RoundEnd);
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_iPlayerSelectOrder = g_hPlayerSelectOrder.IntValue;
	g_bCvarSpectatorVote = g_hCvarSpectatorVote.BoolValue;
	g_bCvarVoteSpectator = g_hCvarVoteSpectator.BoolValue;
	g_iCvarChooseCaptain = g_hCvarChooseCaptain.IntValue;
}

public void OnMapStart()
{
	MixStatus_Changed(0);
}

public void OnMapEnd()
{
	MixStatus_Changed(0);
}

void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	g_lock = false;
	g_bGameStart = false;
	MixStatus_Changed(0);
}

void Event_SurvivalRoundStart(Event event, const char[] name, bool dontBroadcast) 
{
    if(g_bGameStart || L4D_GetGameModeType() != GAMEMODE_SURVIVAL) return;

    g_bGameStart = true;
}

void Event_ScavengeRoundStart(Event event, const char[] name, bool dontBroadcast) 
{
    g_bGameStart = true;
}

void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	MixStatus_Changed(0);
}

Action Command_Captainvote(int client, int args)
{
	if(client == 0)
    {
        PrintToServer("[TS] This command cannot be used by server.");
        return Plugin_Handled;
    }

	if(g_bGameStart)
	{
		CPrintToChat(client,"[{olive}Mix{default}] Can't start a mix, the game has started!");
		return Plugin_Handled;
	}

	char CommandArgs[128];
	GetCmdArgString(CommandArgs, 128);
	
	int surfreeslots = GetTeamMaxHumans(2);
	int inffreeslots = GetTeamMaxHumans(3);
	int freeslots =  surfreeslots+inffreeslots;
	int real_players = checkrealplayerinSV(true);

	if(freeslots > real_players)
	{
		CPrintToChat(client,"[{olive}Mix{default}] Can't start a mix, not enough players ({red}%d{default}/{green}%d{default}).", real_players,freeslots);
		return Plugin_Handled;
	}
	if(surfreeslots == 1 && inffreeslots == 1)
	{
		CPrintToChat(client,"[{olive}Mix{default}] Why you two start a mix in 1v1 ? Joke Game.");
		return Plugin_Handled;
	}	
	if(surfreeslots == 1 || inffreeslots == 1)
	{
		CPrintToChat(client,"[{olive}Mix{default}] Can't start a mix, not enough game slots({green}%d{default}-{green}%d{default})",surfreeslots,inffreeslots);
		return Plugin_Handled;
	}
	
	if (0 < args)
	{
		GetCmdArgString(CommandArgs, 128);
		if (g_iMixCurStatus && g_bTeamRequested[2] && g_bTeamRequested[3])
		{
			if (GetClientTeam(client) == L4D_TEAM_SURVIVOR || GetClientTeam(client) == L4D_TEAM_INFECTED)
			{
				if (StrEqual(CommandArgs, "cancel", true))
				{
					MixStatus_Changed(5);
				}
				CPrintToChatAll("[{olive}Mix{default}] {lightgreen}%N {olive}cancelled the mix request.", client);
			}
			else
			{
				CPrintToChat(client, "[{olive}Mix{default}] Spectators cannot cancel a mix.");
			}
		}
		else
		{
			CPrintToChat(client, "[{olive}Mix{default}] Nothing to cancel.");
		}
		return Plugin_Handled;
	}
	if (g_iMixCurStatus > 0)
	{
		CPrintToChat(client, "[{olive}Mix{default}] A mix is already in process, you dumb fuck.");
		return Plugin_Handled;
	}
	if (GetClientTeam(client) == L4D_TEAM_SPECTATOR)
	{
		CPrintToChat(client, "[{olive}Mix{default}] Spectators cannot start a mix.");
		return Plugin_Handled;
	}
	
	int TeamID = GetClientTeam(client);
	if(g_lock == false)
	{	
		if (TeamID == 2)
		{
			teamName = "{blue}Survivors{default}";
			oppositeTeamName = "{red}Infected{default}";
		}
		if (TeamID == 3)
		{
			teamName = "{red}Infected{default}";
			oppositeTeamName = "{blue}Survivors{default}";
		}
	}
	if (g_bTeamRequested[TeamID])
	{
		CPrintToChat(client, "[{olive}Mix{default}] Your team already requested a mix.");
		return Plugin_Handled;
	}
	g_bTeamRequested[TeamID] = true;
	if (g_bTeamRequested[2] && g_bTeamRequested[3])
	{
		CPrintToChatAll("[{olive}Mix{default}] The %s have agreed to start the mix.", oppositeTeamName);

		MixStatus_Changed(0);
		MixStatus_Changed(1);
		
		if(g_iCvarChooseCaptain == 0)
		{
			DisplayVoteMenuCaptainSurvivor();
		}
		else
		{
			RandomChooseCaptain();
		}

		return Plugin_Handled;
	}
	CPrintToChatAll("[{olive}Mix{default}] The %s have requested to start a mix.", teamName);
	CPrintToChatAll("{default}The %s must agree by typing {green}!mix.", oppositeTeamName);
	g_lock = true;
	CreateTimer(10.0, Timer_LoadMix);
	return Plugin_Handled;
}

Action Command_ForceCaptainvote (int client, int args)
{
	if(client == 0)
	{
		PrintToServer("[TS] This command cannot be used by server.");
		return Plugin_Handled;
	}

	if(g_bGameStart)
	{
		CPrintToChat(client,"[{olive}Mix{default}] Can't start a mix, the game has started!");
		return Plugin_Handled;
	}

	int surfreeslots = GetTeamMaxHumans(2);
	int inffreeslots = GetTeamMaxHumans(3);
	int freeslots =  surfreeslots+inffreeslots;
	int real_players = checkrealplayerinSV(true);

	if(freeslots > real_players)
	{
		CPrintToChat(client,"[{olive}Mix{default}] Can't start a mix, not enough players ({red}%d{default}/{green}%d{default}).", real_players,freeslots);
		return Plugin_Handled;
	}
	if(surfreeslots == 1 && inffreeslots == 1)
	{
		CPrintToChat(client,"[{olive}Mix{default}] Why you two start a mix in 1v1 ? Joke Game.");
		return Plugin_Handled;
	}	
	if(surfreeslots == 1 || inffreeslots == 1)
	{
		CPrintToChat(client,"[{olive}Mix{default}] Can't start a mix, not enough game slots({green}%d{default}-{green}%d{default})",surfreeslots,inffreeslots);
		return Plugin_Handled;
	}
		
	CPrintToChatAll("[{olive}Mix{default}] Admin %N forces to start a mix!", client);

	g_lock = false;
	MixStatus_Changed(0);
	MixStatus_Changed(1);

	if(g_iCvarChooseCaptain == 0)
	{
		DisplayVoteMenuCaptainSurvivor();
	}
	else
	{
		RandomChooseCaptain();
	}

	return Plugin_Handled;
}

Action Timer_LoadMix(Handle timer)
{
	if (g_iMixCurStatus > 0) return Plugin_Handled;
	g_bTeamRequested[2] = false;
	g_bTeamRequested[3] = false;
	if(g_lock)
	{
		CPrintToChatAll("[{olive}Mix{default}] Mix request timed out.");
		g_lock = false;
	}
	return Plugin_Handled;
}

void DisplayVoteMenuCaptainSurvivor()
{
	if (g_iMixCurStatus > 0)
	{
		MixStatus_Changed(2);
		Menu SurvivorCaptainMenu = new Menu(Handler_SurvivorCaptainCallback, MENU_ACTIONS_DEFAULT);
		SurvivorCaptainMenu.SetTitle("選隊長#1(Choose Survivor Captain):");
		int players;
		g_bHasOneVoted = false;
		char name[32];
		char number[12];
		for(int i = 1; i <= MaxClients; i++) 
		{
			if (IsClientInGame(i)&&!IsFakeClient(i))
			{
				if(!g_bCvarVoteSpectator && GetClientTeam(i) <= L4D_TEAM_SPECTATOR) continue;

				Format(name, 32, "%N", i);
				Format(number, 10, "%i", i);
				SurvivorCaptainMenu.AddItem(number, name, 0);
				players++;
			}
		}
		SurvivorCaptainMenu.ExitButton = true;

		for(int i = 1; i <= MaxClients; i++) 
		{
			if (IsClientInGame(i)&&!IsFakeClient(i))
			{
				if(!g_bCvarSpectatorVote && GetClientTeam(i) <= L4D_TEAM_SPECTATOR) continue;

				SurvivorCaptainMenu.Display(i, 10);
			}
		}

		CreateTimer(10.1, TimerCheckSurvivorCaptainVote);
	}
}

Action TimerCheckSurvivorCaptainVote(Handle timer)
{
	if (g_iMixCurStatus > 0)
	{
		if (!g_bHasOneVoted)
		{
			//ResetSelectedPlayers();
			//ResetTeams();
			//ResetCaptains();
			//ResetAllVotes();
			//ResetHasVoted();
			DisplayVoteMenuCaptainSurvivor();
		}
		else
		{
			CalculateSurvivorCaptain();
			if (!IsValidClient(g_iSurvivorCaptain))
			{
				CPrintToChatAll("[{olive}Mix{default}] Surprise! First Chosen Captain left the server, stopped the mix process.");
				MixStatus_Changed(5);
				return Plugin_Handled;
			}
			CPrintToChatAll("[{olive}Mix{default}] First captain: {lightgreen}%N{default} With {green}%i {default}votes.", g_iSurvivorCaptain, g_iVotesSurvivorCaptain[g_iSurvivorCaptain]);
			DisplayVoteMenuCaptainInfected();
		}
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

int Handler_SurvivorCaptainCallback(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char item[16];
			menu.GetItem(param2, item, 16);
			int target = StringToInt(item, 10);
			if (IsClientInGame(target) && !IsFakeClient(target))
			{
				g_iVotesSurvivorCaptain[target]++;
				g_bHasOneVoted = true;
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

void DisplayVoteMenuPlayerSelect()
{
	if (g_iMixCurStatus > 0)
	{
		MixStatus_Changed(3);
		Menu PlayerSelectMenu = new Menu(Handler_PlayerSelectionCallback, MENU_ACTIONS_DEFAULT);
		PlayerSelectMenu.SetTitle("選隊員(Choose wisely...)");
		char name[32];
		char number[12];
		for(int i = 1; i <= MaxClients; i++) 
		{
			if ( IsClientInGame(i) && !IsFakeClient(i) && !g_bHasBeenChosen[i] && i != g_iSurvivorCaptain && i != g_iInfectedCaptain )
			{
				if(!g_bCvarVoteSpectator && GetClientTeam(i) <= L4D_TEAM_SPECTATOR) continue;

				Format(name, 32, "%N", i);
				Format(number, 10, "%i", i);
				PlayerSelectMenu.AddItem(number, name, 0);
			}
		}
		PlayerSelectMenu.ExitButton = true;
		if (!IsValidClient(g_iSurvivorCaptain))
		{
			CPrintToChatAll("[{olive}Mix{default}] Surprise! First Captain left the server, stopped the mix process.");
			MixStatus_Changed(5);
			return;
		}
		if (!IsValidClient(g_iInfectedCaptain))
		{
			CPrintToChatAll("[{olive}Mix{default}] Surprise! Second Captain left the server, stopped the mix process.");
			MixStatus_Changed(5);
			return;
		}
		
		if (IsValidClient(g_iSurvivorCaptain) && IsValidClient(g_iInfectedCaptain))
		{
			if (!g_bSelectToggle)
			{
				PlayerSelectMenu.Display(g_iSurvivorCaptain, 1);
			}
			if (g_bSelectToggle)
			{
				PlayerSelectMenu.Display(g_iInfectedCaptain, 1);
			}
		}
		CreateTimer(1.1, Timer_PlayerSelection);
	}
}

int Handler_PlayerSelectionCallback(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char item[16];
			menu.GetItem(param2, item, 16);
			int target = StringToInt(item, 10);
			if (IsClientInGame(target) && !IsFakeClient(target))
			{
				g_bHasBeenChosen[target] = true;
				if (!g_bSelectToggle)
				{
					g_iDesignatedTeam[target] = 2;
					CPrintToChatAll("[{olive}Mix{default}] {blue}%N {default}selected: {green}%N", g_iSurvivorCaptain, target);
					g_iSelectedPlayers[g_iSurvivorCaptain]++;
				}
				else
				{
					g_iDesignatedTeam[target] = 3;
					CPrintToChatAll("[{olive}Mix{default}] {red}%N {default}selected: {green}%N", g_iInfectedCaptain, target);
					g_iSelectedPlayers[g_iInfectedCaptain]++;
				}
				
				g_SelectToggleNum++;
				switch(g_iPlayerSelectOrder)
				{
					case 0: // ABABAB
						g_bSelectToggle = !g_bSelectToggle;
					case 1: // ABBAAB
					{
						if(g_SelectToggleNum%2 == 0)
							g_bSelectToggle = !g_bSelectToggle;
					}
					case 2: // ABBABA
					{
						if(g_SelectToggleNum >= 5)
							g_bSelectToggle = !g_bSelectToggle;
						else if(g_SelectToggleNum%2 == 0)
							g_bSelectToggle = !g_bSelectToggle;
					}
				}
			}
			else
			{
				CPrintToChat(param1,"[{olive}Mix{default}] This player has left the server, choose again!");
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

Action Timer_PlayerSelection(Handle timer)
{
	if (g_iMixCurStatus > 0)
	{
		int SurvivorLimit = g_CvarSurvLimit.IntValue;
		int InfectedLimit = g_CvarMaxPlayerZombies.IntValue;
		if (g_iSelectedPlayers[g_iSurvivorCaptain] >= SurvivorLimit -1 && g_iSelectedPlayers[g_iInfectedCaptain] >= InfectedLimit -1)
		{
			MixStatus_Changed(4);
			return Plugin_Stop;
		}
		
		int freeslots =  SurvivorLimit + InfectedLimit;
		int real_players = checkrealplayerinSV();
		if(freeslots > real_players)
		{
			CPrintToChatAll("[{olive}Mix{default}] Not enough players in server({red}%d{default}/{green}%d{default}), stopped the mix process.", real_players,freeslots);
			MixStatus_Changed(5);
			return Plugin_Handled;
		}
	
		DisplayVoteMenuPlayerSelect();
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

void DisplayVoteMenuCaptainInfected()
{
	Menu InfectedCaptainMenu = new Menu(Handler_InfectedCaptainCallback, MENU_ACTIONS_DEFAULT);
	InfectedCaptainMenu.SetTitle("選隊長#2(Choose Infected Captain):");
	int players;
	g_bHasOneVoted = false;
	char name[32];
	char number[12];
	for(int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if(i == g_iSurvivorCaptain) continue;
			if(!g_bCvarVoteSpectator && GetClientTeam(i) <= L4D_TEAM_SPECTATOR) continue;
			
			Format(name, 32, "%N", i);
			Format(number, 10, "%i", i);
			InfectedCaptainMenu.AddItem(number, name, 0);
			players++;
		}
	}
	InfectedCaptainMenu.ExitButton = true;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			InfectedCaptainMenu.Display(i, 10);
		}
	}
			
	CreateTimer(10.1, TimerCheckInfectedCaptainVote);
}

Action TimerCheckInfectedCaptainVote(Handle timer)
{
	if (g_iMixCurStatus > 0)
	{
		if (!g_bHasOneVoted)
		{
			DisplayVoteMenuCaptainInfected();
		}
		else
		{
			CalculateInfectedCaptain();
			if (!IsValidClient(g_iInfectedCaptain))
			{
				CPrintToChatAll("[{olive}Mix{default}] Surprise! Second Chosen Captain left the server, stopped the mix process.");
				MixStatus_Changed(5);
				return Plugin_Handled;
			}
			CPrintToChatAll("[{olive}Mix{default}] Second captain: {lightgreen}%N{default} With {green}%i {default}votes.", g_iInfectedCaptain, g_iVotesInfectedCaptain[g_iInfectedCaptain]);
			MixStatus_Changed(3);
		}
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

int Handler_InfectedCaptainCallback(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char item[16];
			menu.GetItem(param2, item, 16);
			int target = StringToInt(item, 10);
			if (IsClientInGame(target) && !IsFakeClient(target))
			{
				g_iVotesInfectedCaptain[target]++;
				g_bHasOneVoted = true;
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}

	return 0;
}

void ResetCaptains()
{
	g_iSurvivorCaptain = 0;
	g_iInfectedCaptain = 0;
}

void ResetAllVotes()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		g_iVotesSurvivorCaptain[i] = 0;
		g_iVotesInfectedCaptain[i] = 0;
	}
}

void ResetTeams()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		g_iDesignatedTeam[i] = 1;
	}
}

void ResetSelectedPlayers()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		g_iSelectedPlayers[i] = 0;
		g_bHasBeenChosen[i] = false;
	}
}

void CalculateSurvivorCaptain()
{
	int highestvotes;
	for(int i = 1; i <= MaxClients; i++)
	{
		if (g_iVotesSurvivorCaptain[i] > highestvotes)
		{
			highestvotes = g_iVotesSurvivorCaptain[i];
			g_iSurvivorCaptain = i;
			g_iDesignatedTeam[i] = 2;
		}
	}
}

void CalculateInfectedCaptain()
{
	int highestvotes;
	for(int i = 1; i <= MaxClients; i++)
	{
		if (g_iVotesInfectedCaptain[i] > highestvotes)
		{
			highestvotes = g_iVotesInfectedCaptain[i];
			g_iInfectedCaptain = i;
			g_iDesignatedTeam[i] = 3;
		}
	}
}

void ResetHasVoted()
{
	g_bHasOneVoted = false;
	for(int i = 1; i <= MaxClients; i++) 
	{
		g_bHasVoted[i] = false;
	}
}

void SwapPlayersToDesignatedTeams()
{
	g_iDesignatedTeam[g_iSurvivorCaptain] = L4D_TEAM_SURVIVOR;
	g_iDesignatedTeam[g_iInfectedCaptain] = L4D_TEAM_INFECTED;
	for(int i = 1; i <= MaxClients; i++) 
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != L4D_TEAM_SPECTATOR)
			ChangeClientTeam(i, L4D_TEAM_SPECTATOR);
	
	for(int i = 1; i <= MaxClients; i++) 
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			if (g_iDesignatedTeam[i] == L4D_TEAM_SURVIVOR)
			{
				CreateTimer(G_flTickInterval, MoveToSurvivor, i, TIMER_FLAG_NO_MAPCHANGE);
			}
			if (g_iDesignatedTeam[i] == L4D_TEAM_INFECTED)
			{
				CreateTimer(G_flTickInterval, MoveToInfected, i, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	MixStatus_Changed(0);
}

Action MoveToSurvivor(Handle timer, any targetplayer)
{
	if(!targetplayer || !IsClientInGame(targetplayer)) return Plugin_Continue;

	int bot = FindBotToTakeOver(true);
	if (bot==0)
	{
		bot = FindBotToTakeOver(false);
	}
	if (bot>0)
	{
		L4D_SetHumanSpec(bot, targetplayer);
		L4D_TakeOverBot(targetplayer);
	}

	return Plugin_Continue;
}

Action MoveToInfected(Handle timer, any targetplayer)
{
	if(!targetplayer || !IsClientInGame(targetplayer)) return Plugin_Continue;

	ChangeClientTeam(targetplayer, L4D_TEAM_INFECTED);

	return Plugin_Continue;
}

bool IsValidClient(int client)
{
	if (client < 1 || client > MaxClients) return false;
	return IsClientInGame(client);
}

int GetTeamMaxHumans(int team)
{
	if(team == 2)
	{
		return g_CvarSurvLimit.IntValue;
	}
	else if(team == 3)
	{
		return g_CvarMaxPlayerZombies.IntValue;
	}
	
	return -1;
}

int checkrealplayerinSV(bool bGame = false)
{
	int players = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			if(bGame && GetClientTeam(i) <= 1) continue;

			players++;
		}
	}
		
	return players;
}

int FindBotToTakeOver(bool alive)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i)==L4D_TEAM_SURVIVOR && !HasIdlePlayer(i) && IsPlayerAlive(i) == alive)
		{
			return i;
		}
	}
	return 0;
}

bool HasIdlePlayer(int bot)
{
	if(HasEntProp(bot, Prop_Send, "m_humanSpectatorUserID"))
	{
		if(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID") > 0)
		{
			return true;
		}
	}
	
	return false;
}

void RandomChooseCaptain()
{
	g_iSurvivorCaptain = GetRandomCaptain(true);
	g_iInfectedCaptain = GetRandomCaptain(false);
	if(g_iSurvivorCaptain == 0 || g_iInfectedCaptain == 0)
	{
		CPrintToChatAll("[{olive}Mix{default}] Unable to randomly select captain in survivor/infected team.");
		MixStatus_Changed(5);
		return;
	}

	MixStatus_Changed(3);
}

int GetRandomCaptain(bool bSurvivorTeam)
{
	int iClientCount, iClients[MAXPLAYERS+1];
	if(bSurvivorTeam)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == L4D_TEAM_SURVIVOR)
			{
				iClients[iClientCount++] = i;
			}
		}
	}
	else
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == L4D_TEAM_INFECTED)
			{
				iClients[iClientCount++] = i;
			}
		}
	}

	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

// 0=重置
// 1=選隊長1
// 2=選隊長2
// 3=隊長開始選人
// 4=隊長都選好了, 設置隊員
// 5=Mix被終止
void MixStatus_Changed(int iMixCurStatus)
{
	g_iMixCurStatus = iMixCurStatus;
	
	if (iMixCurStatus == 0)
	{
		ResetSelectedPlayers();
		ResetTeams();
		ResetCaptains();
		ResetAllVotes();
		ResetHasVoted();
		g_bTeamRequested[2] = false;
		g_bTeamRequested[3] = false;
	}
	else if (iMixCurStatus == 1)
	{
		//for(int i = 1; i <= MaxClients; i++) 
		//	if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != L4D_TEAM_SPECTATOR)
		//		ChangeClientTeam(i, L4D_TEAM_SPECTATOR);
	}
	else if (iMixCurStatus == 2)
	{
		//nothing
	}
	else if (iMixCurStatus == 3)
	{
		g_bSelectToggle = false;
		g_SelectToggleNum = 1;
		switch(g_iPlayerSelectOrder)
		{
			case 0:
				CPrintToChatAll("[{olive}Mix{default}] Captains will now begin to choose players(A-B-A-B-A-B).");
			case 1:
				CPrintToChatAll("[{olive}Mix{default}] Captains will now begin to choose players(A-BB-AA-B).");
			case 2:
				CPrintToChatAll("[{olive}Mix{default}] Captains will now begin to choose players(A-BB-A-B-A).");
		}

		//for(int i = 1; i <= MaxClients; i++) 
		//	if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != L4D_TEAM_SPECTATOR)
		//		ChangeClientTeam(i, L4D_TEAM_SPECTATOR);
			
		DisplayVoteMenuPlayerSelect();
	}
	else if (iMixCurStatus == 4)
	{
		CPrintToChatAll("[{olive}Mix{default}] Teams set, let the mix begin!");
		SwapPlayersToDesignatedTeams();
		MixStatus_Changed(0);
	}
	else
	{
		MixStatus_Changed(0);
	}
	
}

//Left4Dhooks API-------------------------------

public void L4D_OnFirstSurvivorLeftSafeArea_Post(int client)
{
	if(L4D_GetGameModeType() != GAMEMODE_SURVIVAL && L4D_GetGameModeType() != GAMEMODE_SCAVENGE)
	{
		g_bGameStart = true;
	}
}

//ReadyUp API-------------------------------

public void OnRoundIsLive() 
{
	g_bGameStart = true;
}