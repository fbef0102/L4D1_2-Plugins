#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod> 
#include <sdktools>

public Plugin myinfo = { 
    name = "[L4D, L4D2] No Death Check Until Dead", 
    author = "chinagreenelvis, Harry", 
    description = "Prevents mission loss until all players have died.", 
    version = "1.8", 
    url = "https://forums.alliedmods.net/showthread.php?t=142432" 
}; 

ConVar g_hCvarAllow = null;
ConVar deathcheck_bots = null;

ConVar director_no_death_check = null;
ConVar allow_all_bot_survivor_team = null;

bool g_bCvarAllow,g_bDeathcheck_bots, bLeftSafeRoom;
int g_iPlayerSpawn, g_iRoundStart;
Handle PlayerLeftStartTimer = null;

public void OnPluginStart()
{  
	g_hCvarAllow = CreateConVar("deathcheck", "1", "0: Disable plugin, 1: Enable plugin", FCVAR_NOTIFY);
	deathcheck_bots = CreateConVar("deathcheck_bots", "1", "0: Mission will be lost if all human players have died, 1: Bots will continue playing after all human players are dead and can rescue them", FCVAR_NOTIFY);
	
	director_no_death_check = FindConVar("director_no_death_check");
	allow_all_bot_survivor_team = FindConVar("allow_all_bot_survivor_team");
	
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	deathcheck_bots.AddChangeHook(ConVarChange_deathcheck_bots);

	AutoExecConfig(true, "cge_l4d2_deathcheck");
}

public void OnPluginEnd()
{
	ResetPlugin();
	ResetTimer();
	ResetConVar(director_no_death_check, true, true);
	ResetConVar(allow_all_bot_survivor_team, true, true);
}

public void OnConfigsExecuted()
{
	IsAllowed();
}

public void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	g_bDeathcheck_bots = deathcheck_bots.BoolValue;

	if( g_bCvarAllow == false && bCvarAllow == true)
	{
		CreateTimer(0.1, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
		g_bCvarAllow = true;
		HookEvent("player_spawn", Event_PlayerSpawn);
		HookEvent("round_start",		Event_RoundStart,	EventHookMode_PostNoCopy);
		HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
		HookEvent("map_transition", Event_RoundEnd); //戰役過關到下一關的時候 (沒有觸發round_end)
		HookEvent("mission_lost", Event_RoundEnd); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
		HookEvent("finale_vehicle_leaving", Event_RoundEnd); //救援載具離開之時  (沒有觸發round_end)
		HookEvent("player_bot_replace", Event_DeathCheck); 
		HookEvent("bot_player_replace", Event_DeathCheck); 
		HookEvent("player_team", Event_DeathCheck);
		HookEvent("player_death", Event_DeathCheck);
	}

	else if( g_bCvarAllow == true && bCvarAllow == false)
	{
		ResetPlugin();
		g_bCvarAllow = false;
		ResetConVar(director_no_death_check, true, true);
		ResetConVar(allow_all_bot_survivor_team, true, true);
		UnhookEvent("player_spawn", Event_PlayerSpawn);
		UnhookEvent("round_start",		Event_RoundStart,	EventHookMode_PostNoCopy);
		UnhookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
		UnhookEvent("map_transition", Event_RoundEnd); //戰役過關到下一關的時候 (沒有觸發round_end)
		UnhookEvent("mission_lost", Event_RoundEnd); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
		UnhookEvent("finale_vehicle_leaving", Event_RoundEnd); //救援載具離開之時  (沒有觸發round_end)
		UnhookEvent("player_bot_replace", Event_DeathCheck); 
		UnhookEvent("bot_player_replace", Event_DeathCheck); 
		UnhookEvent("player_team", Event_DeathCheck);
		UnhookEvent("player_death", Event_DeathCheck);
	}
}

public void ConVarChange_deathcheck_bots(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (g_bCvarAllow)
	{
		g_bDeathcheck_bots = deathcheck_bots.BoolValue;
		if (g_bDeathcheck_bots)
		{
			allow_all_bot_survivor_team.SetInt(1);
		}
		else
		{
			ResetConVar(allow_all_bot_survivor_team, true, true);
		}
	}
}

public void OnMapEnd()
{
	ResetPlugin();
	ResetTimer();
	bLeftSafeRoom = false;
	director_no_death_check.SetInt(0);
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	bLeftSafeRoom = false;
	director_no_death_check.SetInt(0);

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
	ResetPlugin();
	if(PlayerLeftStartTimer == null) PlayerLeftStartTimer = CreateTimer(1.0, PlayerLeftStart, _, TIMER_REPEAT);
}

public Action PlayerLeftStart(Handle timer)
{
	if (LeftStartArea() || bLeftSafeRoom)
	{
		director_no_death_check.SetInt(1);
		if (g_bDeathcheck_bots)
		{
			allow_all_bot_survivor_team.SetInt(1);
		}
		bLeftSafeRoom = true;
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)  
{
	ResetPlugin();
	ResetTimer();
	director_no_death_check.SetInt(0);
	bLeftSafeRoom = false;
}

public void Event_DeathCheck(Event event, const char[] name, bool dontBroadcast)
{  
	CreateTimer(3.0, Timer_DeathCheck);
}  

public Action Timer_DeathCheck(Handle timer)
{
	if (g_bCvarAllow && bLeftSafeRoom)
	{
		int survivors = 0;
		for (int i = 1; i <= MaxClients; i++) 
		{
			if (IsValidSurvivor(i))
			{
				survivors ++;
			}
		}
		
		if (survivors < 1)
		{
			int oldFlags = GetCommandFlags("scenario_end");
			SetCommandFlags("scenario_end", oldFlags & ~(FCVAR_CHEAT|FCVAR_DEVELOPMENTONLY));
			ServerCommand("scenario_end");
			ServerExecute();
			SetCommandFlags("scenario_end", oldFlags);
		}
	}
}

stock bool IsValidSurvivor(int client)
{
	if (!client) return false;
	if (!IsClientInGame(client)) return false;
	if (!g_bDeathcheck_bots)
	{
		if (IsFakeClient(client)) return false;
	}
	if (!IsPlayerAlive(client)) return false;
	if (GetClientTeam(client) != 2) return false;
	return true;
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

void ResetTimer()
{
	if(PlayerLeftStartTimer != null)
	{
		KillTimer(PlayerLeftStartTimer);
		PlayerLeftStartTimer = null;	
	}
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