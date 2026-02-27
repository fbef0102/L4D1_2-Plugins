#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>

public Plugin myinfo = 
{
	name = "Kill stats (!kills)",
	author = "Harry Potter",
	description = "Show statistics of surviviors(kill S.I, C.I. and FF) on round end",
	version = "1.8-2026/2/27",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

#define L4D_TEAM_INFECTED 3
#define L4D_TEAM_SURVIVOR 2
#define L4D_TEAM_SPECTATOR 1

int g_iSIKills[MAXPLAYERS+1];
int g_iCIKills[MAXPLAYERS+1];
int g_iFFDmg[MAXPLAYERS+1];
int g_iCIHeadShots[MAXPLAYERS+1];
int g_iSIHeadShots[MAXPLAYERS+1];
bool HasRoundEndedPrinted;

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar g_hCvarDisplayInterVal, g_hCvarDisplayMVP;
float g_fCvarDisplayInterVal;
bool g_bCvarDisplayMVP;

Handle 
	g_hDisplayTimer;

public void OnPluginStart()   
{
	LoadTranslations("kills.phrases");

	g_hCvarDisplayInterVal 	= CreateConVar( "kills_display_interval", 	"0",   "Interval to display kills statistics on chatbox after new round starts (0=Off)", CVAR_FLAGS, true, 0.0);
	g_hCvarDisplayMVP 		= CreateConVar( "kills_display_mvp", 		"1",   "If 1, display ff mvp, si kill mvp, ci kill mvp", CVAR_FLAGS, true, 0.0);
	AutoExecConfig(true,                	"kills");

	GetCvars();
	g_hCvarDisplayInterVal.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDisplayMVP.AddChangeHook(ConVarChanged_Cvars);


	RegConsoleCmd("sm_kills", Command_kill);

	HookEvent("player_death", 			Event_PlayerDeath);
	HookEvent("infected_death", 		Event_InfectedDeath);
	HookEvent("round_start", 			Event_RoundStart);
	HookEvent("player_hurt", 			Event_PlayerHurt);
	HookEvent("player_incapacitated_start", Event_IncapacitatedStart);
	HookEvent("round_end", 				Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("map_transition", 		Event_RoundEnd, EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (之後沒有觸發round_end)
	HookEvent("mission_lost", 			Event_RoundEnd, EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd, EventHookMode_PostNoCopy); //救援載具離開之時  (之後沒有觸發round_end)
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_fCvarDisplayInterVal = g_hCvarDisplayInterVal.FloatValue;
	g_bCvarDisplayMVP = g_hCvarDisplayMVP.BoolValue;
}

public void OnMapStart() 
{ 
	HasRoundEndedPrinted = false;  
	Clear_PlayerData();
}

Action KillPinfected_dis(Handle timer)
{
	displaykillinfected(0);

	return Plugin_Continue;
}

Action Command_kill(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[TS] This command cannot be used by server.");
		return Plugin_Handled;
	}

	displaykillinfected(client);

	return Plugin_Handled;
}

void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) 
{
	int victimId = event.GetInt("userid");
	int victim = GetClientOfUserId(victimId);
	int attackerId = event.GetInt("attacker");
	int attacker = GetClientOfUserId(attackerId);
	int damageDone = event.GetInt("dmg_health");

	if(victim == attacker || damageDone <= 0) return;

	if (attacker && victim && IsClientInGame(attacker) && GetClientTeam(attacker) == L4D_TEAM_SURVIVOR && IsClientInGame(victim) && GetClientTeam(victim) == L4D_TEAM_SURVIVOR)
	{
		g_iFFDmg[attacker] += damageDone;
	}
}

void Event_IncapacitatedStart(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));

	if (
	attacker == victim ||
	attacker > MaxClients || victim > MaxClients ||
	attacker <= 0 || victim <= 0 ||
	!IsClientInGame(attacker) || 
	IsFakeClient(attacker) || 
	GetClientTeam(attacker) != L4D_TEAM_SURVIVOR || 
	!IsClientInGame(victim) || 
	GetClientTeam(victim) != L4D_TEAM_SURVIVOR)
		return;  

	int damageDone = GetClientHealth(victim) + L4D_GetPlayerTempHealth(victim);
	g_iFFDmg[attacker] += damageDone;
}

void Event_InfectedDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int killer = GetClientOfUserId(event.GetInt("attacker"));
	
	if (!killer || !IsClientInGame(killer))
        return;

	if(GetClientTeam(killer) == L4D_TEAM_SURVIVOR)
	{
		g_iCIKills[killer] += 1;
		bool headshot=event.GetBool("headshot");
		if(headshot) g_iCIHeadShots[killer] += 1;
	}
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int killer = GetClientOfUserId(event.GetInt("attacker"));
	int deadbody = GetClientOfUserId(event.GetInt("userid"));
	if (killer && IsClientInGame(killer) && GetClientTeam(killer) == L4D_TEAM_SURVIVOR && deadbody && IsClientInGame(deadbody) && GetClientTeam(deadbody) == L4D_TEAM_INFECTED)
	{
		g_iSIKills[killer] += 1;
		bool headshot = event.GetBool("headshot");
		if(headshot) g_iSIHeadShots[killer] += 1;
	}
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	if(!HasRoundEndedPrinted)
	{
		CreateTimer(0.0, KillPinfected_dis);
		HasRoundEndedPrinted = true;
	}

	delete g_hDisplayTimer;
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	HasRoundEndedPrinted = false;
	Clear_PlayerData();

	if(g_fCvarDisplayInterVal > 0.0)
	{
		delete g_hDisplayTimer;
		g_hDisplayTimer = CreateTimer(g_fCvarDisplayInterVal, Timer_DisplayKills, _, TIMER_REPEAT);
	}
}

Action Timer_DisplayKills(Handle timer)
{
	displaykillinfected(0);

	return Plugin_Continue;
}

void displaykillinfected(int target)
{	
	int client;
	int players = 0;
	int[] players_clients = new int[MaxClients+1];
	int KillSI, KillCI, KillCIHeadShots,FFDmg,KillSIHeadShots;
	for (client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || GetClientTeam(client) != L4D_TEAM_SURVIVOR) continue;
		players_clients[players] = client;
		players++;
	}

	SortCustom1D(players_clients, players, SortBySIKillsDesc);
	
	for (int i = 0 ; i < players; i++)
	{
		client = players_clients[i];
		KillSI = g_iSIKills[client];
		KillCI = g_iCIKills[client];
		KillCIHeadShots = g_iCIHeadShots[client];
		KillSIHeadShots = g_iSIHeadShots[client];
		FFDmg = g_iFFDmg[client];
		
		if(target == 0)
		{
			CPrintToChatAll("%t", "kills_1", KillSI, KillSIHeadShots, KillCI, KillCIHeadShots, FFDmg, client);
		}
		else
		{
			CPrintToChat(target, "%T", "kills_1", target, KillSI, KillSIHeadShots, KillCI, KillCIHeadShots, FFDmg, client);
		}
	}

	
	if(g_bCvarDisplayMVP)
	{
		SortCustom1D(players_clients, players, SortBySIKillsDesc);

		int MVP_Client = players_clients[0];
		int MVP_SIKILL = g_iSIKills[MVP_Client];
		if(MVP_SIKILL > 0)
		{
			if(target == 0)
			{
				CPrintToChatAll("%t", "SIKILL_MVP", MVP_Client, MVP_SIKILL);
			}
			else
			{
				CPrintToChat(target, "%T", "SIKILL_MVP", target, MVP_Client, MVP_SIKILL);
			}
		}

		SortCustom1D(players_clients, players, SortByCIKillsDesc);

		MVP_Client = players_clients[0];
		int MVP_CIKILL = g_iCIKills[MVP_Client];
		if(MVP_CIKILL > 0)
		{
			if(target == 0)
			{
				CPrintToChatAll("%t", "CIKILL_MVP", MVP_Client, MVP_CIKILL);
			}
			else
			{
				CPrintToChat(target, "%T", "CIKILL_MVP", target, MVP_Client, MVP_CIKILL);
			}
		}

		SortCustom1D(players_clients, players, SortByFFDesc);

		MVP_Client = players_clients[0];
		int MVP_FFDmg = g_iFFDmg[MVP_Client];
		if(MVP_FFDmg > 0)
		{
			if(target == 0)
			{
				CPrintToChatAll("%t", "FF_MVP", MVP_Client, MVP_FFDmg);
			}
			else
			{
				CPrintToChat(target, "%T", "FF_MVP", target, MVP_Client, MVP_FFDmg);
			}
		}
	}
}	
	
int SortBySIKillsDesc(int elem1, int elem2, const int[] array, Handle hndl)
{
	if (g_iSIKills[elem1] > g_iSIKills[elem2]) return -1;
	else if (g_iSIKills[elem2] > g_iSIKills[elem1]) return 1;
	else if (elem1 > elem2) return -1;
	else if (elem2 > elem1) return 1;
	return 0;
}
	
int SortByCIKillsDesc(int elem1, int elem2, const int[] array, Handle hndl)
{
	if (g_iCIKills[elem1] > g_iCIKills[elem2]) return -1;
	else if (g_iCIKills[elem2] > g_iCIKills[elem1]) return 1;
	else if (elem1 > elem2) return -1;
	else if (elem2 > elem1) return 1;
	return 0;
}

int SortByFFDesc(int elem1, int elem2, const int[] array, Handle hndl)
{
	if (g_iFFDmg[elem1] > g_iFFDmg[elem2]) return -1;
	else if (g_iFFDmg[elem2] > g_iFFDmg[elem1]) return 1;
	else if (elem1 > elem2) return -1;
	else if (elem2 > elem1) return 1;
	return 0;
}

void Clear_PlayerData()
{
	for (int i = 1; i <= MaxClients; i++)
	{ 
		g_iSIKills[i] = 0; 
		g_iCIKills[i] = 0; 
		g_iCIHeadShots[i] = 0;
		g_iSIHeadShots[i] = 0;
		g_iFFDmg[i] = 0;
	}
}