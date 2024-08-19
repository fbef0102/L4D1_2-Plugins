#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

public Plugin myinfo = 
{
    name = "[L4D2] AI Tank Attack On Spawn",
    author = "BHaType, XDglory, Harry Potter",
    description = "Forces AI tank to leave stasis and attack while spawn in coop/realism",
    version = "1.1h-2024/8/19",
    url = "https://forums.alliedmods.net/showthread.php?t=319342"
};

int ZOMBIECLASS_TANK;
bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead ) ZOMBIECLASS_TANK = 5;
	else if( test == Engine_Left4Dead2 ) ZOMBIECLASS_TANK = 8;
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	bLate = late;
	return APLRes_Success; 
}

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVORS 		2
#define TEAM_INFECTED 		3

ConVar g_hCvarEnable, g_hCvarSecond;
bool g_bCvarEnable;
float g_fCvarSecond;

bool 
	g_bHasLeftSafeArea;

public void OnPluginStart()
{
	g_hCvarEnable =	CreateConVar("l4d_tankAttackOnSpawn_enable",	 "1", 	"0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarSecond =	CreateConVar("l4d_tankAttackOnSpawn_seconds", 	 "3.0", "Tank chases survivors in seconds after tank spawns in coop", FCVAR_NOTIFY, true, 0.0);
	AutoExecConfig(true, "l4d_tankAttackOnSpawn");

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarSecond.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_start", Event_Round_Start);

	if(bLate)
	{
		LateLoad();
	}
}

void LateLoad()
{
	if(L4D_HasAnySurvivorLeftSafeArea())
	{
		g_bHasLeftSafeArea = true;
	}
}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_fCvarSecond = g_hCvarSecond.FloatValue;
}

// Event----

void Event_PlayerSpawn (Event event, const char[] name, bool dontbroadcast)
{
	if(!g_bCvarEnable || !g_bHasLeftSafeArea) return;

	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && IsFakeClient(client) && GetClientTeam(client) == TEAM_INFECTED && IsPlayerTank(client))
	{
		if(g_fCvarSecond > 0.0) CreateTimer(g_fCvarSecond, Timer_tLeaveStasis, userid, TIMER_FLAG_NO_MAPCHANGE);
		else ForceAITankAttack(client);
	}
}

void Event_Round_Start (Event event, const char[] name, bool dontbroadcast)
{
    g_bHasLeftSafeArea = false;
}

//Left4Dhooks API Forward-------------------------------

public void L4D_OnFirstSurvivorLeftSafeArea_Post(int client)
{
	g_bHasLeftSafeArea = true;

	if(g_bCvarEnable)
	{
		if(g_fCvarSecond == 0.0) 
		{
			for(int player = 1; player <= MaxClients; player++)
			{
				if(!IsClientInGame(player)) continue;
				if(!IsFakeClient(player)) continue;
				if(GetClientTeam(player) != TEAM_INFECTED) continue;
				if(!IsPlayerAlive(player)) continue;
				if(!IsPlayerTank(player)) continue;

				ForceAITankAttack(player);
			}
		}
		else
		{
			for(int player = 1; player <= MaxClients; player++)
			{
				if(!IsClientInGame(player)) continue;
				if(!IsFakeClient(player)) continue;
				if(GetClientTeam(player) != TEAM_INFECTED) continue;
				if(!IsPlayerAlive(player)) continue;
				if(!IsPlayerTank(player)) continue;

				CreateTimer(g_fCvarSecond, Timer_tLeaveStasis, GetClientUserId(player), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

//Timer-------------------------------

Action Timer_tLeaveStasis (Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!g_bCvarEnable || !client || !IsClientInGame(client) || !IsFakeClient(client) || GetClientTeam(client) != TEAM_INFECTED || !IsPlayerAlive(client) || !IsPlayerTank(client))
		return Plugin_Continue;

	ForceAITankAttack(client);
	return Plugin_Continue;
} 

// Other

void ForceAITankAttack(int tank)
{
	int survivor = GetAliveSurvivor();
	if(survivor > 0)
	{
		SetEntProp(tank, Prop_Send, "m_zombieState", 1);
		SetEntProp(tank, Prop_Send, "m_hasVisibleThreats", 1);
		SDKHooks_TakeDamage(tank, survivor, survivor, 1.0, DMG_BULLET);
	}
}

int GetAliveSurvivor() 
{
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if( IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) ) 
		{
			return i;
		}
	}

	return 0;
}


bool IsPlayerTank (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_TANK)
		return true;
	return false;
}