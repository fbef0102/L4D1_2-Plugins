#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#define TEAM_SPECTATOR		1
#define TEAM_SURVIVORS 		2
#define TEAM_INFECTED 		3

ConVar g_hCvarAllow, g_hCvarSecond, g_hCvarMPGameMode;
bool g_bMapStarted, g_bCvarAllow, bHasLeftSafeArea;
static int ZOMBIECLASS_TANK;

public Plugin myinfo = 
{
    name = "[L4D2] Coop Tank Stasis",
    author = "BHaType, XDglory, Harry Potter",
    description = "Forces AI tank to leave stasis and attack while spawn in coop/realism",
    version = "1.0h-2023/7/27",
    url = "https://forums.alliedmods.net/showthread.php?t=319342"
};

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
	
	return APLRes_Success; 
}

public void OnPluginStart()
{
    g_hCvarAllow =	CreateConVar("l4d_tankAttackOnSpawn_allow",	 "1", "0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_hCvarSecond =	CreateConVar("l4d_tankAttackOnSpawn_seconds", "3.0", "Tank chases survivors in seconds after tank spawns in coop", FCVAR_NOTIFY, true, 1.0);

    g_hCvarMPGameMode = FindConVar("mp_gamemode");
    g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
    g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);

    AutoExecConfig(true, "l4d_tankAttackOnSpawn");
}

public void OnMapStart()
{
	g_bMapStarted = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
}

// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		g_bCvarAllow = true;
		HookEvent("tank_spawn", eSpawn);
		HookEvent("round_start", Event_Round_Start);
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		g_bCvarAllow = false;
		UnhookEvent("tank_spawn", eSpawn);
		UnhookEvent("round_start", Event_Round_Start);
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_bMapStarted == false )
		return false;

	if( g_hCvarMPGameMode == null )
		return false;

	g_iCurrentMode = 0;

	int entity = CreateEntityByName("info_gamemode");
	if( IsValidEntity(entity) )
	{
		DispatchSpawn(entity);
		HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "PostSpawnActivate");
		if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
			RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
	}

	if( g_iCurrentMode == 0 ) //can't get gamemode 
		return false;

	if( g_iCurrentMode != 1) //not coop
		return false;

	return true;
}

void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 4;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 8;
}

// ====================================================================================================
//					EVENTS
// ====================================================================================================
void eSpawn (Event event, const char[] name, bool dontbroadcast)
{
    //PrintToChatAll("tank sapwns");
    CreateTimer(g_hCvarSecond.FloatValue, tLeaveStasis, event.GetInt("userid"));
}

void Event_Round_Start (Event event, const char[] name, bool dontbroadcast)
{
    bHasLeftSafeArea = false;
}
// ====================================================================================================
//					FUNCTIONS
// ====================================================================================================
Action tLeaveStasis (Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!g_bCvarAllow || !client || !IsClientInGame(client) || !IsFakeClient(client) || GetClientTeam(client) != TEAM_INFECTED || !IsPlayerAlive(client) || !IsPlayerTank(client))
		return Plugin_Continue;

	if ( bHasLeftSafeArea || LeftStartArea()) 
	{
		SendTank(client);
		return Plugin_Continue;
	}

	CreateTimer(g_hCvarSecond.FloatValue, tLeaveStasis, userid);

	return Plugin_Continue;
} 

void SendTank(int client)
{
	//PrintToChatAll("tank %N chase", client);
	SetEntProp(client, Prop_Send, "m_zombieState", 1);
	SetEntProp(client, Prop_Send, "m_hasVisibleThreats", 1);
	DealDamage(client, 0, GetRandomSurvivor(), DMG_BULLET, "weapon_smg");
}

void DealDamage(int victim, int damage, int attacker = 0, int dmg_type = DMG_GENERIC, char[] weapon = "") {
	if(victim>0 && IsValidEdict(victim) && IsClientInGame(victim) && IsPlayerAlive(victim)) {
		char dmg_str[16];
		IntToString(damage,dmg_str,16);
		char dmg_type_str[32];
		IntToString(dmg_type,dmg_type_str,32);
		int pointHurt=CreateEntityByName("point_hurt");
		if (pointHurt) {
			DispatchKeyValue(victim,"targetname","war3_hurtme");
			DispatchKeyValue(pointHurt,"DamageTarget","war3_hurtme");
			DispatchKeyValue(pointHurt,"Damage",dmg_str);
			DispatchKeyValue(pointHurt,"DamageType",dmg_type_str);
			
			if(!StrEqual(weapon,"")) {
				DispatchKeyValue(pointHurt,"classname",weapon);
			}
			DispatchSpawn(pointHurt);
			AcceptEntityInput(pointHurt,"Hurt",(attacker>0)?attacker:-1);
			DispatchKeyValue(pointHurt,"classname","point_hurt");
			DispatchKeyValue(victim,"targetname","war3_donthurtme");
			RemoveEdict(pointHurt);
		}
	}
}

bool IsPlayerTank (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZOMBIECLASS_TANK)
		return true;
	return false;
}

bool LeftStartArea()
{
	if(L4D_HasAnySurvivorLeftSafeArea())
	{
		bHasLeftSafeArea = true;
		return true;
	}

	return false;
}