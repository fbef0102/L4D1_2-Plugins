#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <multicolors> 
#include <builtinvotes> //https://github.com/L4D-Community/builtinvotes/actions
#include <adminmenu>

#define PLUGIN_VERSION			"1.5-2024/8/25"
#define PLUGIN_NAME			    "match_vote"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "Match Vote",
	author = "HarryPotter",
	description = "Type !match/!load/!mode to vote a new mode",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

//bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead )
	{
		//g_bL4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		//g_bL4D2Version = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MATCHMODES_PATH		"configs/matchmodes.txt"

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

#define VOTE_TIME 20

ConVar g_hCvarEnable, g_hCvarVoteDealy, g_hCvarVoteRequired;
bool g_bCvarEnable;
int g_iCvarVoteDealy, g_iCvarVoteRequired;

Handle g_hMatchVote, VoteDelayTimer;
KeyValues g_hModesKV;
char g_sCfg[128];
int g_iLocalVoteDelay;

bool 
	g_bVoteInProgress,
	g_bAdminMenu[MAXPLAYERS+1];

TopMenu 
	g_hTopMenuHandle;

public void OnPluginStart()
{
	g_hCvarEnable 		    = CreateConVar( PLUGIN_NAME ... "_enable",       "1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarVoteDealy        = CreateConVar( PLUGIN_NAME ... "_delay",        "60",  "Delay to start another vote after vote ends.", CVAR_FLAGS, true, 1.0);
	g_hCvarVoteRequired     = CreateConVar( PLUGIN_NAME ... "_required",     "1",   "Numbers of real survivor and infected player required to start a match vote.", CVAR_FLAGS, true, 1.0);
	CreateConVar(                           PLUGIN_NAME ... "_version",      PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                    PLUGIN_NAME);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarVoteDealy.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarVoteRequired.AddChangeHook(ConVarChanged_Cvars);

	RegConsoleCmd("sm_match", MatchRequest);
	RegConsoleCmd("sm_load", MatchRequest);
	RegConsoleCmd("sm_mode", MatchRequest);

	TopMenu topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
		OnAdminMenuReady(topmenu);
}

public void OnPluginEnd()
{
	StopVote();
	delete VoteDelayTimer;
}

//Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_iCvarVoteDealy = g_hCvarVoteDealy.IntValue;
	g_iCvarVoteRequired = g_hCvarVoteRequired.IntValue;
}

// Admin Menu---------------

public void OnAdminMenuReady(Handle menu) 
{
	if (menu == g_hTopMenuHandle)
		return;

	g_hTopMenuHandle = view_as<TopMenu>(menu);
	TopMenuObject ServerCmdCategory = g_hTopMenuHandle.FindCategory(ADMINMENU_SERVERCOMMANDS);
	
	if (ServerCmdCategory != INVALID_TOPMENUOBJECT)
	{
		g_hTopMenuHandle.AddItem("sm_match", AdminMenu_MatchMode, ServerCmdCategory, "sm_match", ADMFLAG_ROOT);
	}
}

void AdminMenu_MatchMode(TopMenu Top_Menu, TopMenuAction action, TopMenuObject object_id, int client, char[] Buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: //在"伺服器指令"的選單名稱
		{
			FormatEx(Buffer, maxlength, "Match Mode");
		}
		case TopMenuAction_SelectOption:
		{
			g_bAdminMenu[client] = true;
			MatchModeMenu(client);
		}
	}
}

//Sourcemod API Forward-------------------------------

public void OnMapStart()
{
    StopVote();
    g_bVoteInProgress = false;
}

public void OnMapEnd()
{
	//g_iLocalVoteDelay = 0;
	//delete VoteDelayTimer;
}

public void OnConfigsExecuted()
{
	delete g_hModesKV;

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), MATCHMODES_PATH);
	if( !FileExists(sPath) )
	{
		SetFailState("File Not Found: %s", sPath);
		return;
	}
	
	g_hModesKV = new KeyValues("MatchModes");
	if ( !g_hModesKV.ImportFromFile(sPath) )
	{
		SetFailState("File Format Not Correct: %s", sPath);
		delete g_hModesKV;
		return;
	}
}

//Commands-------------------------------

Action MatchRequest(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[TS] This command cannot be used by server.");
		return Plugin_Handled;
	}

	if (g_bCvarEnable == false)
	{
		ReplyToCommand(client, "This command is disable.");
		return Plugin_Handled;
	}

	g_bAdminMenu[client] = false;
	MatchModeMenu(client);

	return Plugin_Handled;
}

//Menu-------------------------------

void MatchModeMenu(int client)
{
	if(g_hModesKV == null) return;
	g_hModesKV.Rewind();

	Menu hMenu = new Menu(MatchModeMenuHandler);
	hMenu.SetTitle("Select match mode:");
	static char sBuffer[64];
	if (g_hModesKV.GotoFirstSubKey())
	{
		do
		{
			g_hModesKV.GetSectionName(sBuffer, sizeof(sBuffer));
			hMenu.AddItem(sBuffer, sBuffer);
		} while (g_hModesKV.GotoNextKey());
	}
	if(g_bAdminMenu[client]) hMenu.ExitBackButton = true;
	hMenu.Display(client, 20);
}

int MatchModeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && g_hTopMenuHandle != null)
		{
			g_hTopMenuHandle.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		if(g_hModesKV == null) return 0;
		g_hModesKV.Rewind();
		
		static char sInfo[128], sBuffer[128];
		menu.GetItem(param2, sInfo, sizeof(sInfo));
		if (g_hModesKV.JumpToKey(sInfo) && g_hModesKV.GotoFirstSubKey())
		{
			Menu hMenu = new Menu(ConfigsMenuHandler);
			Format(sBuffer, sizeof(sBuffer), "Select %s config:", sInfo);
			hMenu.SetTitle(sBuffer);

			do
			{
				g_hModesKV.GetSectionName(sInfo, sizeof(sInfo));
				g_hModesKV.GetString("name", sBuffer, sizeof(sBuffer));
				hMenu.AddItem(sInfo, sBuffer);
			} while (g_hModesKV.GotoNextKey());

			hMenu.ExitBackButton = true;
			hMenu.Display(param1, 20);
		}
		else
		{
			CPrintToChat(param1, "[{olive}Matchvote{default}] No configs for such mode were found.");
			MatchModeMenu(param1);
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

int ConfigsMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		static char sInfo[128], sBuffer[64];
		menu.GetItem(param2, sInfo, sizeof(sInfo), _, sBuffer, sizeof(sBuffer));

		if(g_bAdminMenu[param1])
		{
			strcopy(g_sCfg, sizeof(g_sCfg), sInfo);
			CPrintToChatAll("[{olive}Matchvote{default}] Admin {lightgreen}%N{default} forced to change mode  {green}%s", param1, sBuffer);

			ServerCommand("exec %s", g_sCfg);

			return 0;
		}

		if (StartMatchVote(param1, sInfo, sBuffer))
		{
			strcopy(g_sCfg, sizeof(g_sCfg), sInfo);
			CPrintToChatAll("[{olive}Matchvote{default}] {lightgreen}%N{default} started a vote to change mode: {green}%s", param1, sBuffer);
			return 0;
		}

		MatchModeMenu(param1);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			MatchModeMenu(param1);
		}
	}

	return 0;
}

//Vote-------------------------------

bool StartMatchVote(int client, const char[] cfgpatch, const char[] cfgname)
{
	static char sBuffer[256];
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), "../../cfg/%s.cfg", cfgpatch);
	if (!FileExists(sBuffer))
	{
		CPrintToChat(client, "[{olive}Matchvote{default}] File {green}%s.cfg{default} does not exist!", sBuffer);
		return false;
	}

	if (GetClientTeam(client) == TEAM_SPECTATOR)
	{
		CPrintToChat(client, "[{olive}Matchvote{default}] Match voting isn't allowed for spectators.");
		return false;
	}

	if (g_bVoteInProgress || IsBuiltinVoteInProgress())
	{
		CPrintToChat(client, "[{olive}Matchvote{default}] You cannot start vote until current vote ends");
		return false;
	}

	if (VoteDelayTimer != null)
	{
		CPrintToChat(client, "[{olive}Matchvote{default}] You must wait {green}%d{default} seconds to start a new vote", g_iLocalVoteDelay);

		return false;
	}

	int iNumPlayers;
	int[] iPlayers = new int[MaxClients+1];
	//list of non-spectators players
	for (int i=1; i<=MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || (GetClientTeam(i) == TEAM_SPECTATOR))
		{
			continue;
		}

		iPlayers[iNumPlayers++] = i;
	}

	if (iNumPlayers < g_iCvarVoteRequired)
	{
		CPrintToChat(client, "[{olive}Matchvote{default}] Match vote cannot be started. Not enough {green}%d{default} players.", g_iCvarVoteRequired);
		return false;
	}

	g_hMatchVote = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);

	FormatEx(sBuffer, sizeof(sBuffer), "Change '%s' mode?", cfgname);
	SetBuiltinVoteArgument(g_hMatchVote, sBuffer);
	SetBuiltinVoteInitiator(g_hMatchVote, client);
	SetBuiltinVoteResultCallback(g_hMatchVote, VoteResultHandler);
	DisplayBuiltinVote(g_hMatchVote, iPlayers, iNumPlayers, VOTE_TIME);
	FakeClientCommand(client, "Vote Yes");

	return true;
}

int VoteActionHandler(Handle vote, BuiltinVoteAction action, int param1, int param2)
{
    switch (action)
    {
        case BuiltinVoteAction_End:
        {
            delete vote;
            g_hMatchVote = null;
            VoteEnd();
        }
        case BuiltinVoteAction_Cancel:
        {

        }
    }

    return 0;
}

void VoteResultHandler(Handle vote, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
    for (int i=0; i<num_items; i++)
    {
        if (item_info[i][BUILTINVOTEINFO_ITEM_INDEX] == BUILTINVOTES_VOTE_YES)
		{
			if (item_info[i][BUILTINVOTEINFO_ITEM_VOTES] > (num_votes / 2))
			{
				DisplayBuiltinVotePass(vote, "Confogl is loading...");
				CPrintToChatAll("[{olive}Match{default}] Change mode after {green}3{default} seconds");
				
				CreateTimer(3.0, Timer_VotePass, _, TIMER_FLAG_NO_MAPCHANGE);

				return;
			}
        }
    }

    DisplayBuiltinVoteFail(vote, BuiltinVoteFail_Loses);
}

Action Timer_VotePass(Handle timer, int client)
{
	ServerCommand("exec %s", g_sCfg);

	return Plugin_Continue;
}

Action Timer_VoteDelay(Handle timer, any client)
{
    g_iLocalVoteDelay--;

    if(g_iLocalVoteDelay<=0)
    {
        VoteDelayTimer = null;
        return Plugin_Stop;
    }

    return Plugin_Continue;
}

//Others-------------------------------

void StopVote()
{
    if(g_hMatchVote!=null)
    {
        CancelBuiltinVote();
    }

    g_bVoteInProgress = false;
}

void VoteEnd()
{
    g_iLocalVoteDelay = g_iCvarVoteDealy;
    delete VoteDelayTimer;
    VoteDelayTimer = CreateTimer(1.0, Timer_VoteDelay, _, TIMER_REPEAT);

    g_bVoteInProgress = false;
}