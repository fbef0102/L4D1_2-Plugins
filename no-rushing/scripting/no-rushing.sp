#define TEAM_SPECTATOR 1
#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3

#define MAX_ENTITIES 2048

#define PLUGIN_VERSION "1.1h-2024/9/15"

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

bool DistanceWarning[MAXPLAYERS+1];
bool g_IsBehind[MAXPLAYERS+1];
int g_WarningCounter[MAXPLAYERS+1];

bool g_bEnable;
float g_fNoticeDistance;
float g_fForwardDistance;
float g_fBehindDistance;
float g_fMapFlowDistance;
float g_fRangeDistance;

ConVar h_InfractionLimit;
ConVar h_SurvivorsRequired;
ConVar h_IgnoreIncapacitated;
ConVar h_InfractionResult;
int i_InfractionLimit;
int i_SurvivorsRequired;
bool b_IgnoreIncapacitated;
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
	h_InfractionResult 		= CreateConVar("no-rushing_action_rushers", 		"1", "Modes: 0=Teleport only, 1=Teleport and kill after reaching limits, 2=Teleport and kick after reaching limits.", FCVAR_NOTIFY,true, 0.0, true, 2.0);
	CreateConVar("no-rushing_version", PLUGIN_VERSION, "No Rushing Version", FCVAR_NOTIFY);
	AutoExecConfig(true, 	"no-rushing");

	GetCvars();
	h_InfractionLimit.AddChangeHook(ConVarChanged_Cvars);
	h_SurvivorsRequired.AddChangeHook(ConVarChanged_Cvars);
	h_IgnoreIncapacitated.AddChangeHook(ConVarChanged_Cvars);
	h_InfractionResult.AddChangeHook(ConVarChanged_Cvars);

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

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	i_InfractionLimit = h_InfractionLimit.IntValue;
	i_SurvivorsRequired = h_SurvivorsRequired.IntValue;
	b_IgnoreIncapacitated = h_IgnoreIncapacitated.BoolValue;
	i_InfractionResult = h_InfractionResult.IntValue;
}

public void OnConfigsExecuted()
{
	if (L4D_GetGameModeType() != GAMEMODE_SURVIVAL)
	{
		g_fNoticeDistance = 0.0;
		g_fForwardDistance = 0.0;
		g_fBehindDistance = 0.0;
		
		ParseMapConfigs();
	}
}

public void OnClientPutInServer(int client)
{
	if (IsClientInGame(client))
	{
		DistanceWarning[client] = false;
		g_WarningCounter[client] = 0;
		g_IsBehind[client] = false;
	}
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

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			DistanceWarning[i] = false;
			g_WarningCounter[i] = 0;
			g_IsBehind[i] = false;
		}
	}
}

Action tmrStart(Handle timer)
{
	g_fMapFlowDistance = L4D2Direct_GetMapMaxFlowDistance();
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

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			DistanceWarning[i] = false;
			g_WarningCounter[i] = 0;
			g_IsBehind[i] = false;
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
	
	float g_fTeamDistance = 0.0;
	float g_fPlayerDistance = 0.0;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i))
		{
			if (GetInfectedAttacker(i) != -1 || IsClientDown(i))
			{
				continue;
			}
			
			if (IsClientLaggingBehind(i))
			{
				if (g_fBehindDistance > 0.0)
				{
					if(CheckIfLoner(i, iAliveSur) == false) continue;

					CPrintToChat(i, "%T", "Lagging Behind", i);
					TeleportLaggingPlayer(i);
				}

				g_IsBehind[i] = true;
				continue;
			}
			else
			{
				g_IsBehind[i] = false;
			}

			g_fTeamDistance = CalculateTeamDistance(i);
			g_fPlayerDistance = (L4D2Direct_GetFlowDistance(i) / g_fMapFlowDistance);
			
			if(g_fPlayerDistance <= 0.0 || g_fTeamDistance == -1.0) continue;
			if(g_fPlayerDistance >= 1.0) g_fPlayerDistance = 1.0;

			if (DistanceWarning[i] && g_fForwardDistance > 0.0 && g_fTeamDistance + g_fForwardDistance < g_fPlayerDistance)
			{
				if(CheckIfLoner(i, iAliveSur) == false) continue;
				
				if (g_WarningCounter[i] + 1 < i_InfractionLimit)
				{
					g_WarningCounter[i]++;
					CPrintToChat(i, "%T", "Rushing Warning", i, g_WarningCounter[i], i_InfractionLimit);
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
						CPrintToChatAll("%t", "Rushing Violation", nClient);
						if (i_InfractionResult == 1)
						{
							ForcePlayerSuicide(i);
							DistanceWarning[i] = false;
							g_WarningCounter[i] = 0;
							g_IsBehind[i] = false;
						}
						else if (i_InfractionResult == 2)
						{
							KickClient(i);
						}
					}
					DistanceWarning[i] = false;
				}
			}
			else
			{
				if(g_fNoticeDistance <= 0.0)
				{
					DistanceWarning[i] = true;
				}
				else
				{
					if (!DistanceWarning[i] && g_fTeamDistance + g_fNoticeDistance < g_fPlayerDistance)
					{
						DistanceWarning[i] = true;
						CPrintToChat(i, "%T", "Rushing Notice", i);
					}
					else if (DistanceWarning[i] && g_fTeamDistance + g_fNoticeDistance > g_fPlayerDistance)
					{
						DistanceWarning[i] = false;
					}	
				}
			}
		}
	}
	return Plugin_Continue;
}

bool IsClientLaggingBehind(int client)
{
	float g_fTeamDistance = CalculateTeamDistance(client);
	float g_fPlayerDistance = (L4D2Direct_GetFlowDistance(client) / g_fMapFlowDistance);

	//C_PrintToChatAll("%N: g_fPlayerDistance %f,g_fBehindDistance %f,g_fTeamDistance %f",client,g_fPlayerDistance,g_fBehindDistance,g_fTeamDistance);
	if(g_fPlayerDistance <= 0.0 || g_fTeamDistance == -1.0) return false;
	if(g_fPlayerDistance >= 1.0) g_fPlayerDistance = 1.0;
	
	if (g_fBehindDistance <= 0.0)
	{
		if (g_fPlayerDistance + 0.31 > g_fTeamDistance)
		{
			return false;
		}
	}
	else
	{
		if (g_fPlayerDistance + g_fBehindDistance > g_fTeamDistance)
		{
			return false;
		}
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
	float g_fPlayerDistance;
	int target = -1;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i) && i != client)
		{
			g_fPlayerDistance = (L4D2Direct_GetFlowDistance(i) / g_fMapFlowDistance);
			if(g_fPlayerDistance <= 0.0) continue;
			if(g_fPlayerDistance >= 1.0) g_fPlayerDistance = 1.0;
			
			if (g_fPlayerDistance > g_TargetDistance)
			{
				g_TargetDistance = g_fPlayerDistance;
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
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR && IsPlayerAlive(i) && !DistanceWarning[i] && i != client)
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
	float g_fTeamDistance = 0.0;
	int counter = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVOR /*&& !IsFakeClient(i)*/ && IsPlayerAlive(i) && i != client && !g_IsBehind[i])
		{
			if (b_IgnoreIncapacitated && !IsClientDown(i) || !b_IgnoreIncapacitated)
			{
				float fPlayerflow = L4D2Direct_GetFlowDistance(i) / g_fMapFlowDistance;
				if(fPlayerflow <= 0.0) continue; //in case player out of map
				if(fPlayerflow >= 1.0) fPlayerflow = 1.0;
					
				g_fTeamDistance += fPlayerflow;
				counter++;
			}
		}
	}
	if(counter > 1) g_fTeamDistance /= counter;
	else g_fTeamDistance = -1.0;
	return g_fTeamDistance;
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
			g_fNoticeDistance = hFile.GetFloat("Notice_Rushing_Distance", 0.15);
			g_fForwardDistance = hFile.GetFloat("Teleport_Rushing_Distance", 0.2);
			g_fBehindDistance = hFile.GetFloat("Teleport_Behind_Distance", 0.31);
			g_fRangeDistance = hFile.GetFloat("Range_Distance", 600.0);
			
			hFile.GoBack();
		}
		else
		{
			delete hFile;
			SetFailState("Keyvalue 'default' not found in %s", sPath);
			return;
		}
	}
	else
	{
		if(hFile.JumpToKey("default_final"))
		{
			g_bEnable = view_as<bool>(hFile.GetNum("Enable", 1));
			g_fNoticeDistance = hFile.GetFloat("Notice_Rushing_Distance", 0.8);
			g_fForwardDistance = hFile.GetFloat("Teleport_Rushing_Distance", 0.7);
			g_fBehindDistance = hFile.GetFloat("Teleport_Behind_Distance", 0.91);
			g_fRangeDistance = hFile.GetFloat("Range_Distance", 1000.0);
			
			hFile.GoBack();
		}
		else
		{
			delete hFile;
			SetFailState("Keyvalue 'default_final' not found in %s", sPath);
			return;
		}
	}

	if( hFile.JumpToKey(sMapName) )
	{
		g_bEnable = view_as<bool>(hFile.GetNum("Enable", g_bEnable));
		g_fNoticeDistance = hFile.GetFloat("Notice_Rushing_Distance", g_fNoticeDistance);
		g_fForwardDistance = hFile.GetFloat("Teleport_Rushing_Distance", g_fForwardDistance);
		g_fBehindDistance = hFile.GetFloat("Teleport_Behind_Distance", g_fBehindDistance);
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

Action PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea())
	{	
		delete DistanceCheckTimer;
		DistanceCheckTimer = CreateTimer(1.0, Timer_DistanceCheck, _, TIMER_REPEAT);
		
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
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