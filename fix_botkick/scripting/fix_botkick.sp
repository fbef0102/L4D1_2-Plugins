#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#define PLUGIN_VERSION "1.0h-2023/11/2"

public Plugin myinfo =
{
	name = "Kick Bots Fix",
	author = "HarryPotter",
	description = "Fixed no Survivor bots issue or too many Survivor bots issue after map loading.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

#define DELAY_BOT_CLIENT_Check		1.0

ConVar g_hSurvivorLimit;
int g_iCvarSurvLimit;
static bool bTempBlock;

int g_iPlayerSpawn, g_iRoundStart;

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

	g_iCvarSurvLimit = g_hSurvivorLimit.IntValue;
	g_hSurvivorLimit.AddChangeHook(OnCvarChange_SurvivorLimit);

	HookEvent("player_team", SF_ev_PlayerTeam);
	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);//每回合開始就發生的event
	HookEvent("player_spawn",Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	HookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy); //trigger twice in versus/survival/scavenge mode, one when all survivors wipe out or make it to saferom, one when first round ends (second round_start begins).
	HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //all survivors make it to saferoom, and server is about to change next level in coop mode (does not trigger round_end) 
	HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy); //final map final rescue vehicle leaving  (does not trigger round_end)

	RegAdminCmd("sm_botfix", CmdBotFix, ADMFLAG_ROOT);
}

void OnCvarChange_SurvivorLimit(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_iCvarSurvLimit = g_hSurvivorLimit.IntValue;
}

public void OnMapStart()
{
	bTempBlock = false;
}

public void OnMapEnd()
{
    ClearDefault();
}

Action CmdBotFix(int client, int args)
{
	SF_Fix();
	ReplyToCommand(client, "Checking complete.");
	return Plugin_Handled;
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	ClearDefault();
}

Action tmrStart(Handle timer)
{
	ClearDefault();

	bTempBlock = false;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i)&&IsClientInGame(i)&&!IsFakeClient(i))
		{
			CreateTimer(DELAY_BOT_CLIENT_Check, SF_t_CheckBots);
			break;
		}
	}

	return Plugin_Continue;
}

void SF_ev_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	if (bTempBlock) return;

	int client = GetClientOfUserId(event.GetInt("userid"));

	if (client && !IsFakeClient(client))
	{
		if (event.GetBool("disconnect") == false){
			bTempBlock = true;
			CreateTimer(DELAY_BOT_CLIENT_Check, SF_t_CheckBots);
		}
	}
}

Action SF_t_CheckBots(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SF_Fix();
			break;
		}
	}

	return Plugin_Continue;
}

void SF_Fix()
{
	int iSurvivorCount;

	for (int i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && GetClientTeam(i) == 2)
			iSurvivorCount++;

	if(iSurvivorCount == g_iCvarSurvLimit)
		return;
		
	if (iSurvivorCount < g_iCvarSurvLimit){

		static int iFlag;

		if (!iFlag)
			iFlag = GetCommandFlags("sb_add");

		SetCommandFlags("sb_add", iFlag & ~FCVAR_CHEAT);

		while (iSurvivorCount < g_iCvarSurvLimit){
			LogMessage("Bug detected. Trying to add a bot %d/%d", iSurvivorCount, g_iCvarSurvLimit);
			ServerCommand("sb_add");
			iSurvivorCount++;
		}

		SetCommandFlags("sb_add", iFlag);

		CreateTimer(DELAY_BOT_CLIENT_Check, SF_t_CheckBots);

		return;
	}
	
	/*if (iSurvivorCount > g_iCvarSurvLimit){
		while (iSurvivorCount > g_iCvarSurvLimit){
			LogMessage("Bug detected. Trying to kick a bot %d/%d", iSurvivorCount, g_iCvarSurvLimit);
			bool bKickFakeClient = false;
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
	}*/
}

void ClearDefault()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}