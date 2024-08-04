#define TEAM_SPECTATOR 1
#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3

#define MAX_ENTITIES 2048

#define PLUGIN_VERSION "1.1h-2024/8/4"

#define PLUGIN_NAME "No Rushing"
#define PLUGIN_DESCRIPTION "Prevents Rushers From Rushing Then Teleports Them Back To Their Teammates."
#define CONFIG_FILE "configs/no-rushing.cfg"
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
	url = "https://steamcommunity.com/profiles/76561198026784913"
};

bool b_LeftSaveRoom = false;
bool DistanceWarning[MAXPLAYERS+1];
bool IsLagging[MAXPLAYERS+1];
int g_WarningCounter[MAXPLAYERS+1];

bool g_bEnable;
float g_NoticeDistance;
float g_WarningDistance;
float g_IgnoreDistance;
float g_MapFlowDistance;
float g_fRangeDistance;
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

public void OnPluginStart()
{
	h_InfractionLimit 		= CreateConVar("no-rushing_limit", 					"2", "Maximum rushing limits", FCVAR_NOTIFY);
	h_SurvivorsRequired 	= CreateConVar("no-rushing_require_survivors", 		"3", "Minimum number of alive survivors before No-Rushing function works. Must be 3 or greater.", FCVAR_NOTIFY, true, 3.0);
	h_IgnoreIncapacitated 	= CreateConVar("no-rushing_ignore_incapacitated", 	"0", "Ignore Incapacitated Survivors?", FCVAR_NOTIFY,true, 0.0, true, 1.0);
	h_IgnoreStraggler 		= CreateConVar("no-rushing_ignore_lagging", 		"0", "Ignore lagging or lost players behind?", FCVAR_NOTIFY,true, 0.0, true, 1.0);
	h_InfractionResult 		= CreateConVar("no-rushing_action_rushers", 		"1", "Modes: 0=Teleport only, 1=Teleport and kill after reaching limits, 2=Teleport and kick after reaching limits.", FCVAR_NOTIFY,true, 0.0, true, 2.0);
	CreateConVar("no-rushing_version", PLUGIN_VERSION, "No Rushing Version", FCVAR_NOTIFY);
	AutoExecConfig(true, 	"no-rushing");

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
	if(g_bL4D2Version) HookEvent("scavenge_round_finished", OnFunctionEnd);
	HookEvent("player_spawn",		Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	
	LoadTranslations("common.phrases");
	LoadTranslations("no-rushing.phrases");
	
	CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnPluginEnd()
{
	ResetPlugin();
	ResetTimer();
}

public void OnConfigsExecuted()
{
	if (L4D_GetGameModeType() != GAMEMODE_SURVIVAL)
	{
		g_NoticeDistance = 0.0;
		g_WarningDistance = 0.0;
		g_IgnoreDistance = 0.0;
		
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

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

void OnFunctionStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;

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

Action tmrStart(Handle timer)
{
	g_MapFlowDistance = L4D2Direct_GetMapMaxFlowDistance();
	ResetPlugin();
	if (L4D_GetGameModeType() != GAMEMODE_SURVIVAL)
	{
		delete PlayerLeftStartTimer;
		PlayerLeftStartTimer = CreateTimer(1.0, PlayerLeftStart, _, TIMER_REPEAT);
	}

	return Plugin_Continue;
}

void OnFunctionEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
	ResetTimer();

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

Action Timer_DistanceCheck(Handle timer)
{
	if (!g_bEnable || ActiveSurvivors() < i_SurvivorsRequired)
	{
		return Plugin_Continue;
	}

	int iAliveSur = ActiveSurvivors();
	if (iAliveSur < i_SurvivorsRequired)
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
					if(CheckIfLoner(i, iAliveSur) == false) continue;

					CPrintToChat(i, "%T", "Lagging Behind", i, white, green, white);
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
			
			if(g_PlayerDistance <= 0.0 || g_TeamDistance == -1.0) continue;
			if(g_PlayerDistance >= 1.0) g_PlayerDistance = 1.0;

			if (DistanceWarning[i] && g_TeamDistance + g_WarningDistance < g_PlayerDistance)
			{
				if(CheckIfLoner(i, iAliveSur) == false) continue;
				
				if (g_WarningCounter[i] + 1 < i_InfractionLimit)
				{
					g_WarningCounter[i]++;
					CPrintToChat(i, "%s %T", s_rup, "Rushing Warning", i, white, orange, green, white, green, g_WarningCounter[i], i_InfractionLimit);
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
						CPrintToChatAll("%s %t", s_rup, "Rushing Violation", blue, white, orange, nClient);
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
				CPrintToChat(i, "%s %T", s_rup, "Rushing Notice", i, white, orange);
			}
			else if (DistanceWarning[i] && g_TeamDistance + g_NoticeDistance > g_PlayerDistance)
			{
				DistanceWarning[i] = false;
			}
		}
	}
	return Plugin_Continue;
}

bool IsClientLaggingBehind(int client)
{
	float g_TeamDistance = CalculateTeamDistance(client);
	float g_PlayerDistance = (L4D2Direct_GetFlowDistance(client) / g_MapFlowDistance);

	//C_PrintToChatAll("%N: g_PlayerDistance %f,g_IgnoreDistance %f,g_TeamDistance %f",client,g_PlayerDistance,g_IgnoreDistance,g_TeamDistance);
	if(g_PlayerDistance <= 0.0 || g_TeamDistance == -1.0) return false;
	if(g_PlayerDistance >= 1.0) g_PlayerDistance = 1.0;
	
	if (g_IgnoreDistance == 0.0 || g_PlayerDistance + g_IgnoreDistance > g_TeamDistance)
	{
		return false;
	}
	return true;
}

int ActiveSurvivors()
{
	int count =	0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i))
		{
			count++;
		}
	}
	return count;
}

void TeleportLaggingPlayer(int client)
{
	float g_TargetDistance;
	float g_PlayerDistance;
	int target = -1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i) && i != client)
		{
			g_PlayerDistance = (L4D2Direct_GetFlowDistance(i) / g_MapFlowDistance);
			if(g_PlayerDistance <= 0.0) continue;
			if(g_PlayerDistance >= 1.0) g_PlayerDistance = 1.0;
			
			if (g_PlayerDistance > g_TargetDistance)
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

void TeleportRushingPlayer(int client)
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

float CalculateTeamDistance(int client)
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
				if(fPlayerflow <= 0.0) continue; //in case player out of map
				if(fPlayerflow >= 1.0) fPlayerflow = 1.0;
					
				g_TeamDistance += fPlayerflow;
				counter++;
			}
		}
	}
	if(counter > 1) g_TeamDistance /= counter;
	else g_TeamDistance = -1.0;
	return g_TeamDistance;
}

void ParseMapConfigs()
{
	char sPath[PLATFORM_MAX_PATH];
	char sMapName[64];
	GetCurrentMap(sMapName, sizeof(sMapName));
	BuildPath(Path_SM, sPath, sizeof(sPath), "%s", CONFIG_FILE);
	KeyValues hFile = new KeyValues("no-rushing");
	if (!hFile.ImportFromFile(sPath))
	{
		CloseHandle(hFile);
		SetFailState("Couldn't load %s", sPath);
		return;
	}
	
	if( !L4D_IsMissionFinalMap(true))
	{
		if(hFile.JumpToKey("default"))
		{
			g_bEnable = view_as<bool>(hFile.GetNum("Enable", 1));
			g_NoticeDistance = hFile.GetFloat("Notice_Rushing_Distance", 0.15);
			g_WarningDistance = hFile.GetFloat("Warning_Distance", 0.2);
			g_IgnoreDistance = hFile.GetFloat("Behind_Distance", 0.31);
			g_fRangeDistance = hFile.GetFloat("Range_Distance", 600.0);
			
			hFile.GoBack();
		}
	}
	else
	{
		if(hFile.JumpToKey("default_final"))
		{
			g_bEnable = view_as<bool>(hFile.GetNum("Enable", 1));
			g_NoticeDistance = hFile.GetFloat("Notice_Rushing_Distance", 0.8);
			g_WarningDistance = hFile.GetFloat("Warning_Distance", 0.7);
			g_IgnoreDistance = hFile.GetFloat("Behind_Distance", 0.91);
			g_fRangeDistance = hFile.GetFloat("Range_Distance", 1000.0);
			
			hFile.GoBack();
		}
	}

	if( hFile.JumpToKey(sMapName) )
	{
		g_bEnable = view_as<bool>(hFile.GetNum("Enable", g_bEnable));
		g_NoticeDistance = hFile.GetFloat("Notice_Rushing_Distance", g_NoticeDistance);
		g_WarningDistance = hFile.GetFloat("Warning_Distance", g_WarningDistance);
		g_IgnoreDistance = hFile.GetFloat("Behind_Distance", g_IgnoreDistance);
		g_fRangeDistance = hFile.GetFloat("Range_Distance", g_fRangeDistance);
		
		hFile.GoBack();
	}
	
	delete hFile;
}

bool IsClientDown(int client)
{
	if( GetEntProp(client, Prop_Send, "m_isIncapacitated", 1) ||
		GetEntProp(client, Prop_Send, "m_isHangingFromLedge", 1))
	return true;

	return false;
}

void ConVarInfractionLimit(ConVar convar, const char[] oldValue, const char[] newValue)
{
	i_InfractionLimit = h_InfractionLimit.IntValue;
}

void ConVarSurvivorsRequired(ConVar convar, const char[] oldValue, const char[] newValue)
{
	i_SurvivorsRequired = h_SurvivorsRequired.IntValue;
}

void ConVarIgnoreIncapacitated(ConVar convar, const char[] oldValue, const char[] newValue)
{
	i_IgnoreIncapacitated = h_IgnoreIncapacitated.IntValue;
}

void ConVarIgnoreStraggler(ConVar convar, const char[] oldValue, const char[] newValue)
{
	i_IgnoreStraggler = h_IgnoreStraggler.IntValue;
}

void ConVarInfractionResult(ConVar convar, const char[] oldValue, const char[] newValue)
{
	i_InfractionResult = h_InfractionResult.IntValue;
}

Action PlayerLeftStart(Handle Timer)
{
	if (LeftStartArea())
	{	
		if (!b_LeftSaveRoom)
		{
			b_LeftSaveRoom = true;
			delete DistanceCheckTimer;
			DistanceCheckTimer = CreateTimer(1.0, Timer_DistanceCheck, _, TIMER_REPEAT);
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
	delete PlayerLeftStartTimer;
	delete DistanceCheckTimer;
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
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

bool CheckIfLoner(int client, int iAliveSur)
{
	float playerPos[3];
	float pos[3];
	GetClientEyePosition(client, playerPos);
	int iCount = 0;
	for( int i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i)==2 && IsPlayerAlive(i))
		{
			if(i==client) continue;
			
			GetClientEyePosition(i, pos);
			float dis=GetVectorDistance(pos, playerPos);
			if(dis>g_fRangeDistance)
			{
				iCount++;				 
			}
		} 
	}

	if( ( iCount >= RoundToCeil(0.5 * iAliveSur) ) )
	{
		return true;
	}

	return false;
}