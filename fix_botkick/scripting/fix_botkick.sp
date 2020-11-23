#define PLUGIN_VERSION "1.3"

#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#define ADD_BOT		"sb_add"
#define DELAY_BOT_CLIENT_Check		1.0

public Plugin myinfo =
{
	name = "Kick Bots Fix",
	author = "raziEiL [disawar1] & HarryPotter",
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
	SetConVarBounds(g_hSurvivorLimit, ConVarBound_Lower, true, 1.0);

	g_iCvarSurvLimit = g_hSurvivorLimit.IntValue;
	g_hSurvivorLimit.AddChangeHook(OnCvarChange_SurvivorLimit);

	HookEvent("player_team", SF_ev_PlayerTeam);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);//每回合開始就發生的event
	HookEvent("player_spawn",Event_PlayerSpawn,	EventHookMode_PostNoCopy);

	RegAdminCmd("sm_botfix", CmdBotFix, ADMFLAG_ROOT);
}

public void OnMapStart()
{
	bTempBlock = false;
	SetConVarBounds(g_hSurvivorLimit, ConVarBound_Upper, true, 32.0);
	SetConVarBounds(g_hSurvivorLimit, ConVarBound_Lower, true, 1.0);
}

public Action CmdBotFix(int client, int args)
{
	SF_Fix();
	ReplyToCommand(client, "Checking complete.");
	return Plugin_Handled;
}

int g_iPlayerSpawn, g_iRoundStart;
public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

public Action tmrStart(Handle timer)
{
	g_iPlayerSpawn = 0;
	g_iRoundStart = 0;
	bTempBlock = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i)&&IsClientInGame(i)&&!IsFakeClient(i))
		{
			CreateTimer(DELAY_BOT_CLIENT_Check, SF_t_CheckBots);
			break;
		}
	}
}

public Action SF_ev_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	if (bTempBlock) return;

	int client = GetClientOfUserId(event.GetInt("userid"));

	if (client && !IsFakeClient(client))
	{
		if (event.GetBool("disconnect") == false){
			bTempBlock = true;
			CreateTimer(1.0, SF_t_CheckBots);
		}
	}
}


public Action SF_t_CheckBots(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i)&&IsClientInGame(i)&&!IsFakeClient(i))
		{
			SF_Fix();
			break;
		}
	}
}

void SF_Fix()
{
	int iSurvivorCount;
	bool bKickFakeClient; 

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
			bKickFakeClient = false;
			for (int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && GetClientTeam(i) == 2 && IsFakeClient(i))
				{
					KickClient(i, "bots > survivor_limit");
					iSurvivorCount--;
					bKickFakeClient = true;
					break;
				}
			}
			
			if(!bKickFakeClient)
			{
				for (int i = 1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i))
					{
						ChangeClientTeam(i, 1);
						break;
					}
				}
			}			
		}
		CreateTimer(DELAY_BOT_CLIENT_Check, SF_t_CheckBots);
	}
}

public void OnCvarChange_SurvivorLimit(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_iCvarSurvLimit = g_hSurvivorLimit.IntValue;
}
