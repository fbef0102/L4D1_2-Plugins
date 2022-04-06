#define TEAM_SPECTATOR 1
#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3

#define MAX_ENTITIES 2048

#define PLUGIN_VERSION "1.6"

#define PLUGIN_NAME "Ready Up Module: No Rushing"
#define PLUGIN_DESCRIPTION "Prevents Rushers From Rushing Then Teleports Them Back To Their Teammates."
#define CONFIG_MAPS "configs/norushing"
#define CVAR_SHOW FCVAR_NOTIFY

#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <left4dhooks>

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "cravenge & Harry",
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/fbef0102/"
};

int GameMode; //1:coop/realism, 2:versus, 3:survival

bool b_LeftSaveRoom = false;
bool DistanceWarning[MAXPLAYERS+1];
bool IsLagging[MAXPLAYERS+1];
int g_WarningCounter[MAXPLAYERS+1];

float g_NoticeDistance;
float g_WarningDistance;
float g_IgnoreDistance;
float g_MapFlowDistance;
char white[10];
char blue[10];
char orange[10];
char green[10];
char s_rup[32];

ConVar h_InfractionLimit;
ConVar h_SurvivorsRequired;
ConVar h_IgnoreIncapacitated;
ConVar h_IgnoreStraggler;
ConVar h_InfractionResult;
int i_InfractionLimit;
int i_SurvivorsRequired;
int i_IgnoreIncapacitated;
int i_IgnoreStraggler;
int i_InfractionResult;
int g_iPlayerSpawn, g_iRoundStart;
Handle PlayerLeftStartTimer = null;
Handle DistanceCheckTimer = null;
bool bL4D2Version;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		bL4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		bL4D2Version = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{
	GameCheck();
	
	CreateConVar("no-rushing_version", PLUGIN_VERSION, "No Rushing Version", FCVAR_SPONLY);
	h_InfractionLimit = CreateConVar("l4d_rushing_limit", "2", "Maximum rushing limits", FCVAR_SPONLY);
	h_SurvivorsRequired = CreateConVar("l4d_rushing_require_survivors", "3", "Minimum number of alive survivors before No-Rushing function works. Must be 3 or greater.", FCVAR_SPONLY);
	h_IgnoreIncapacitated = CreateConVar("l4d_rushing_ignore_incapacitated", "0", "Ignore Incapacitated Survivors?", FCVAR_SPONLY,true, 0.0, true, 1.0);
	h_IgnoreStraggler = CreateConVar("l4d_rushing_ignore_lagging", "0", "Ignore lagging or lost players behind?", FCVAR_SPONLY,true, 0.0, true, 1.0);
	h_InfractionResult = CreateConVar("l4d_rushing_action_rushers", "1", "Modes: 0=Teleport only, 1=Teleport and kill after reaching limits, 2=Teleport and kick after reaching limits.", FCVAR_SPONLY,true, 0.0, true, 2.0);
	i_InfractionLimit = h_InfractionLimit.IntValue;
	i_SurvivorsRequired = h_SurvivorsRequired.IntValue;
	i_IgnoreIncapacitated = h_IgnoreIncapacitated.IntValue;
	i_IgnoreStraggler = h_IgnoreStraggler.IntValue;
	i_InfractionResult = h_InfractionResult.IntValue;
	h_InfractionLimit.AddChangeHook(ConVarInfractionLimit);
	h_SurvivorsRequired.AddChangeHook(ConVarSurvivorsRequired);
	h_IgnoreIncapacitated.AddChangeHook(ConVarIgnoreIncapacitated);
	h_IgnoreStraggler.AddChangeHook(ConVarIgnoreStraggler);
	h_InfractionResult.AddChangeHook(ConVarInfractionResult);
	
	Format(white, sizeof(white), "{default}");
	Format(blue, sizeof(blue), "{blue}");
	Format(orange, sizeof(orange), "{green}");
	Format(green, sizeof(green), "{olive}");
	
	HookEvent("round_start", OnFunctionStart);
	HookEvent("round_end", OnFunctionEnd);
	HookEvent("map_transition", OnFunctionEnd);
	HookEvent("mission_lost", OnFunctionEnd);
	HookEvent("finale_win", OnFunctionEnd);
	HookEvent("scavenge_round_finished", OnFunctionEnd);
	HookEvent("player_spawn",		Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	
	LoadTranslations("common.phrases");
	LoadTranslations("norushing.phrases");
	
	CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	
	AutoExecConfig(true, "no-rushing");
}

public void OnPluginEnd()
{
	ResetPlugin();
	ResetTimer();
}

void GameCheck()
{
	char gameMode[16];
	GetConVarString(FindConVar("mp_gamemode"), gameMode, sizeof(gameMode));
	if (StrEqual(gameMode, "survival", false))
	{
		GameMode = 3;
	}
	else if (StrEqual(gameMode, "versus", false) || StrEqual(gameMode, "teamversus", false) || StrEqual(gameMode, "scavenge", false) || StrEqual(gameMode, "teamscavenge", false))
	{
		GameMode = 2;
	}
	else if (StrEqual(gameMode, "coop", false) || StrEqual(gameMode, "realism", false))
	{
		GameMode = 1;
	}
	else
	{
		GameMode = 0;
 	}
}

public void OnConfigsExecuted()
{
	if (GameMode != 3)
	{
		g_NoticeDistance = 0.0;
		g_WarningDistance = 0.0;
		g_IgnoreDistance = 0.0;
		
		char s_Path[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, s_Path, sizeof(s_Path), "%s", CONFIG_MAPS);
		if (!DirExists(s_Path))
		{
			CreateDirectory(s_Path, 511);
		}
		
		ParseMapConfigs();
	}
}

public void OnClientPutInServer(int client)
{
	if (IsClientInGame(client))
	{
		DistanceWarning[client] = false;
		g_WarningCounter[client] = 0;
		IsLagging[client] = false;
	}
}

public void OnMapStart()
{
	b_LeftSaveRoom	= false;
}

public void OnMapEnd()
{
	ResetPlugin();
	ResetTimer();
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

public Action OnFunctionStart(Event event, const char[] name, bool dontBroadcast)
{
	b_LeftSaveRoom = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i))
		{
			DistanceWarning[i] = false;
			g_WarningCounter[i] = 0;
			IsLagging[i] = false;
		}
	}
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

public Action tmrStart(Handle timer)
{
	g_MapFlowDistance = L4D2Direct_GetMapMaxFlowDistance();
	ResetPlugin();
	if (GameMode != 3)
	{
		if(PlayerLeftStartTimer == null) CreateTimer(1.0, PlayerLeftStart, _, TIMER_REPEAT);
	}
}

public Action OnFunctionEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
	ResetTimer();
	if (GameMode != 3)
	{
		b_LeftSaveRoom = false;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientConnected(i) && IsClientInGame(i))
			{
				DistanceWarning[i] = false;
				g_WarningCounter[i] = 0;
				IsLagging[i] = false;
			}
		}
	}
}

public Action Timer_DistanceCheck(Handle timer)
{
	if (!b_LeftSaveRoom)
	{
		DistanceCheckTimer = null;
		return Plugin_Stop;
	}

	if (ActiveSurvivors() < i_SurvivorsRequired)
	{
		return Plugin_Continue;
	}
	
	float g_TeamDistance = 0.0;
	float g_PlayerDistance = 0.0;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i))
		{
			if (GetInfectedAttacker(i) != -1 || IsClientDown(i))
			{
				continue;
			}
			
			if (IsClientLaggingBehind(i))
			{
				if (!i_IgnoreStraggler)
				{
					C_PrintToChat(i, "%T", "Lagging Behind", i, white, green, white);
					TeleportLaggingPlayer(i);
					IsLagging[i] = true;
					continue;
				}
			}
			else
			{
				IsLagging[i] = false;
			}

			g_TeamDistance = CalculateTeamDistance(i);
			g_PlayerDistance = (L4D2Direct_GetFlowDistance(i) / g_MapFlowDistance);
			
			if(g_PlayerDistance < 0.0 || g_PlayerDistance > 1.0 || g_TeamDistance == -1.0) continue;

			if (DistanceWarning[i] && g_TeamDistance + g_WarningDistance < g_PlayerDistance)
			{
				if (g_WarningCounter[i] + 1 < i_InfractionLimit)
				{
					g_WarningCounter[i]++;
					C_PrintToChat(i, "%s %T", s_rup, "Rushing Warning", i, white, orange, green, white, green, g_WarningCounter[i], i_InfractionLimit);
					TeleportRushingPlayer(i);
				}
				else
				{
					char nClient[MAX_NAME_LENGTH];
					char AuthId[MAX_NAME_LENGTH];
					GetClientName(i, nClient, sizeof(nClient));
					GetClientAuthId(i, AuthId_Steam2, AuthId, sizeof(AuthId));
					if (i_InfractionResult > 0)
					{
						C_PrintToChatAll("%s %t", s_rup, "Rushing Violation", blue, white, orange, nClient);
						if (i_InfractionResult == 1)
						{
							ForcePlayerSuicide(i);
							DistanceWarning[i] = false;
							g_WarningCounter[i] = 0;
							IsLagging[i] = false;
						}
						else if (i_InfractionResult == 2)
						{
							KickClient(i);
						}
					}
					DistanceWarning[i] = false;
				}
			}
			else if (!DistanceWarning[i] && g_TeamDistance + g_NoticeDistance < g_PlayerDistance)
			{
				DistanceWarning[i] = true;
				C_PrintToChat(i, "%s %T", s_rup, "Rushing Notice", i, white, orange);
			}
			else if (DistanceWarning[i] && g_TeamDistance + g_NoticeDistance > g_PlayerDistance)
			{
				DistanceWarning[i] = false;
			}
		}
	}
	return Plugin_Continue;
}

stock bool IsClientLaggingBehind(int client)
{
	float g_TeamDistance = CalculateTeamDistance(client);
	float g_PlayerDistance = (L4D2Direct_GetFlowDistance(client) / g_MapFlowDistance);

	//C_PrintToChatAll("%N: g_PlayerDistance %f,g_IgnoreDistance %f,g_TeamDistance %f",client,g_PlayerDistance,g_IgnoreDistance,g_TeamDistance);
	if(g_PlayerDistance < 0.0 || g_PlayerDistance > 1.0 || g_TeamDistance == -1.0) return false;
	if (g_IgnoreDistance == 0.0 || g_PlayerDistance + g_IgnoreDistance > g_TeamDistance || IsClientDown(client))
	{
		return false;
	}
	return true;
}

stock int ActiveSurvivors()
{
	int count =	0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i))
		{
			count++;
		}
	}
	return count;
}

stock void TeleportLaggingPlayer(int client)
{
	float g_TargetDistance;
	float g_PlayerDistance;
	int target = -1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i) && i != client)
		{
			g_PlayerDistance = (L4D2Direct_GetFlowDistance(i) / g_MapFlowDistance);
			
			if (g_PlayerDistance > 0.0 && g_PlayerDistance < 1.0 && g_PlayerDistance > g_TargetDistance)
			{
				g_TargetDistance = g_PlayerDistance;
				target = i;
			}
		}
	}
	if (target > 0)
	{
		float g_Origin[3];
		GetClientAbsOrigin(target, g_Origin);
		TeleportEntity(client, g_Origin, NULL_VECTOR, NULL_VECTOR);
		DistanceWarning[client] = false;
	}
}

stock void TeleportRushingPlayer(int client)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i) && !DistanceWarning[i] && i != client)
		{
			float g_Origin[3];
			GetClientAbsOrigin(i, g_Origin);
			TeleportEntity(client, g_Origin, NULL_VECTOR, NULL_VECTOR);
			DistanceWarning[client] = false;
			break;
		}
	}
}

stock float CalculateTeamDistance(int client)
{
	float g_TeamDistance = 0.0;
	int counter = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR /*&& !IsFakeClient(i)*/ && IsPlayerAlive(i) && i != client && !IsLagging[i])
		{
			if (i_IgnoreIncapacitated && !IsClientDown(i) || !i_IgnoreIncapacitated)
			{
				float fPlayerflow = L4D2Direct_GetFlowDistance(i) / g_MapFlowDistance;
				if(fPlayerflow > 0.0 && fPlayerflow < 1.0)//in case player out of map
				{
					g_TeamDistance += fPlayerflow;
					counter++;
				}
			}
		}
	}
	if(counter > 1) g_TeamDistance /= counter;
	else g_TeamDistance = -1.0;
	return g_TeamDistance;
}

stock void ParseMapConfigs()
{
	
	char Path[PLATFORM_MAX_PATH];
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	Format(mapname, sizeof(mapname), "%s", mapname);
	BuildPath(Path_SM, Path, sizeof(Path), "%s/%s.cfg", CONFIG_MAPS,mapname);
	Handle h_MapFile = CreateKeyValues(mapname);
	if (!FileToKeyValues(h_MapFile, Path))
	{
		CloseHandle(h_MapFile);
		SetFailState("Couldn't load %s",Path);
		return;
	}
	
	char s_value[32];
	KvRewind(h_MapFile);
	
	
	KvGetString(h_MapFile, "Notice Rushing Distance", s_value, sizeof(s_value));
	g_NoticeDistance = StringToFloat(s_value);
	
	KvGetString(h_MapFile, "Warning Distance", s_value, sizeof(s_value));
	g_WarningDistance = StringToFloat(s_value);
	
	KvGetString(h_MapFile, "Behind Distance", s_value, sizeof(s_value));
	g_IgnoreDistance = StringToFloat(s_value);
	
	CloseHandle(h_MapFile);
}

stock bool IsSurvival()
{
	char GameType[128];
	GetConVarString(FindConVar("mp_gamemode"), GameType, 128);
	if (StrEqual(GameType, "survival"))
	{
		return true;
	}
	return false;
}

bool IsClientDown(int client)
{
	if( GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) ||
		GetEntProp(client, Prop_Send, "m_isHangingFromLedge", 1))
	return true;

	return false;
}

public ConVarInfractionLimit(ConVar convar, const char[] oldValue, const char[] newValue)
{
	i_InfractionLimit = h_InfractionLimit.IntValue;
}

public ConVarSurvivorsRequired(ConVar convar, const char[] oldValue, const char[] newValue)
{
	i_SurvivorsRequired = h_SurvivorsRequired.IntValue;
}

public ConVarIgnoreIncapacitated(ConVar convar, const char[] oldValue, const char[] newValue)
{
	i_IgnoreIncapacitated = h_IgnoreIncapacitated.IntValue;
}

public ConVarIgnoreStraggler(ConVar convar, const char[] oldValue, const char[] newValue)
{
	i_IgnoreStraggler = h_IgnoreStraggler.IntValue;
}

public ConVarInfractionResult(ConVar convar, const char[] oldValue, const char[] newValue)
{
	i_InfractionResult = h_InfractionResult.IntValue;
}

public Action PlayerLeftStart(Handle Timer)
{
	if (LeftStartArea())
	{	
		if (!b_LeftSaveRoom)
		{
			b_LeftSaveRoom = true;
			if(DistanceCheckTimer == null) CreateTimer(1.0, Timer_DistanceCheck, _, TIMER_REPEAT);
			PlayerLeftStartTimer = null;
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

bool LeftStartArea()
{
	int ent = -1, maxents = GetMaxEntities();
	for (int i = MaxClients+1; i <= maxents; i++)
	{
		if (IsValidEntity(i))
		{
			char netclass[64];
			GetEntityNetClass(i, netclass, sizeof(netclass));
			
			if (StrEqual(netclass, "CTerrorPlayerResource"))
			{
				ent = i;
				break;
			}
		}
	}
	
	if (ent > -1)
	{
		if (GetEntProp(ent, Prop_Send, "m_hasAnySurvivorLeftSafeArea"))
		{
			return true;
		}
	}
	return false;
}

void ResetTimer()
{
	if(PlayerLeftStartTimer != null) 
	{
		KillTimer(PlayerLeftStartTimer);
		PlayerLeftStartTimer = null;
	}
	if(DistanceCheckTimer != null)
	{
		KillTimer(DistanceCheckTimer);
		DistanceCheckTimer = null;
	}
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}


stock int GetInfectedAttacker(int client)
{
	int attacker;

	if(bL4D2Version)
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