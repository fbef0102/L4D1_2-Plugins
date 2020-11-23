#define PLUGIN_VERSION "1.2"

#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#define ADD_BOT		"sb_add"
#define DELAY_BOT_CLIENT_Check		1.0

public Plugin myinfo =
{
	name = "Kick Bots Fix",
	author = "raziEiL [disawar1],modify by Harry",
	description = "Fixed no Survivor bots issue or too many Survivor bots issue after map loading.",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/raziEiL"
}

ConVar g_hSurvivorLimit;
int g_iCvarSurvLimit;
static bool bTempBlock;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 && test != Engine_Left4Dead )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{
	g_hSurvivorLimit = FindConVar("survivor_limit");
	SetConVarBounds(g_hSurvivorLimit, ConVarBound_Upper, true, 32.0);

	g_iCvarSurvLimit = g_hSurvivorLimit.IntValue;
	g_hSurvivorLimit.AddChangeHook(OnCvarChange_SurvivorLimit);

	HookEvent("player_team", SF_ev_PlayerTeam);
	HookEvent("round_start", event_RoundStart, EventHookMode_PostNoCopy);//每回合開始就發生的event
	
	RegAdminCmd("sm_botfix", CmdBotFix, ADMFLAG_ROOT);
}

public Action CmdBotFix(int client, int args)
{
	SF_Fix();
	ReplyToCommand(client, "Checking complete.");
	return Plugin_Handled;
}

public void event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++)
		if(IsClientConnected(i)&&IsClientInGame(i)&&!IsFakeClient(i))
		{
			CreateTimer(DELAY_BOT_CLIENT_Check, SF_t_CheckBots);
			break;
		}
}


public void OnMapStart()
{
	bTempBlock = false;
}


public Action SF_ev_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	if (bTempBlock) return;

	int client = GetClientOfUserId(event.GetInt("userid"));

	if (client && !IsFakeClient(client)){

		if (event.GetBool("disconnect") == false && event.GetInt("team") == 1){

			bTempBlock = true;
			CreateTimer(1.0, SF_t_CheckBots);
		}
	}
}


public Action SF_t_CheckBots(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
		if(IsClientConnected(i)&&IsClientInGame(i)&&!IsFakeClient(i))
		{
			SF_Fix();
			break;
		}
}

void SF_Fix()
{
	int iSurvivorCount;
	bool SurFakeClient; 

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && GetClientTeam(i) == 2)
			iSurvivorCount++;
	if(iSurvivorCount == g_iCvarSurvLimit)
		return;
		
	if (iSurvivorCount < g_iCvarSurvLimit){

		static int iFlag;

		if (!iFlag)
			iFlag = GetCommandFlags(ADD_BOT);

		SetCommandFlags(ADD_BOT, iFlag & ~FCVAR_CHEAT);

		while (iSurvivorCount != g_iCvarSurvLimit){
			LogMessage("Bug detected. Trying to add a bot %d/%d", iSurvivorCount, g_iCvarSurvLimit);
			ServerCommand(ADD_BOT);
			iSurvivorCount++;
		}

		SetCommandFlags(ADD_BOT, iFlag);
	}
	
	if (iSurvivorCount > g_iCvarSurvLimit){
		while (iSurvivorCount != g_iCvarSurvLimit){
			LogMessage("Bug detected. Trying to kick a bot %d/%d", iSurvivorCount, g_iCvarSurvLimit);
			SurFakeClient = false;
			for (int i = 1; i <= MaxClients; i++)
				if(IsClientInGame(i) && GetClientTeam(i) == 2 && IsFakeClient(i))
				{
					KickClient(i, "client_is_1vHunters_fakeclient");
					iSurvivorCount--;
					SurFakeClient = true;
					break;
				}
			if(!SurFakeClient)
				for (int i = 1; i <= MaxClients; i++)
					if (IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i))
					{
						ChangeClientTeam(i, 3);
						break;
					}
		}
		CreateTimer(DELAY_BOT_CLIENT_Check, SF_t_CheckBots);
	}
}

public void OnCvarChange_SurvivorLimit(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_iCvarSurvLimit = g_hSurvivorLimit.IntValue;
}
