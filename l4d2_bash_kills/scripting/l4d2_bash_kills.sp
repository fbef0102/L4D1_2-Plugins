#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION			"1.0h-2024/4/29"
#define PLUGIN_NAME			    "l4d2_bash_kills"
#define DEBUG 0

#define ZOMBIECLASS_SMOKER	1
#define ZOMBIECLASS_BOOMER	2
#define ZOMBIECLASS_HUNTER	3
#define ZOMBIECLASS_SPITTER	4
#define ZOMBIECLASS_JOCKEY	5
#define ZOMBIECLASS_CHARGER	6

bool bLateLoad;
ConVar g_hCvarEnable,
	g_hCvarbashKillHunter, g_hCvarbashKillSmoker, g_hCvarbashKillBoomer, g_hCvarbashKillSpitter, g_hCvarbashKillJockey;
bool g_bCvarEnable,
	g_bCvarbashKillHunter, g_bCvarbashKillSmoker, g_bCvarbashKillBoomer, g_bCvarbashKillSpitter, g_bCvarbashKillJockey;

public Plugin myinfo =
{
    name        = "L4D Bash Kills",
    author      = "Jahze,Harry Potter",
    version     = PLUGIN_VERSION,
    description = "Stop special infected getting bashed to death"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart() 
{
	g_hCvarEnable 			= CreateConVar( PLUGIN_NAME ... "_enable",      "1", "0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarbashKillSmoker 	= CreateConVar( PLUGIN_NAME ... "_smoker", 		"1", "Prevent smoker from getting bashed to death", FCVAR_NOTIFY);
	g_hCvarbashKillBoomer 	= CreateConVar( PLUGIN_NAME ... "_boomer", 		"0", "Prevent boomer from getting bashed to death", FCVAR_NOTIFY);
	g_hCvarbashKillHunter 	= CreateConVar( PLUGIN_NAME ... "_hunter", 		"1", "Prevent hunter from getting bashed to death", FCVAR_NOTIFY);
	g_hCvarbashKillSpitter 	= CreateConVar( PLUGIN_NAME ... "_spitter", 	"0", "Prevent spitter from getting bashed to death", FCVAR_NOTIFY);
	g_hCvarbashKillJockey 	= CreateConVar( PLUGIN_NAME ... "_jockey", 		"1", "Prevent jockey from getting bashed to death", FCVAR_NOTIFY);
	AutoExecConfig(true, 					PLUGIN_NAME);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarbashKillHunter.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarbashKillSmoker.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarbashKillBoomer.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarbashKillSpitter.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarbashKillJockey.AddChangeHook(ConVarChanged_Cvars);

	if ( bLateLoad ) {
		for ( int i = 1; i <= MaxClients; i++ ) {
			if ( IsClientInGame(i) ) {
				SDKHook(i, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
			}
		}
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
	g_bCvarbashKillHunter = g_hCvarbashKillHunter.BoolValue;
	g_bCvarbashKillSmoker = g_hCvarbashKillSmoker.BoolValue;
	g_bCvarbashKillBoomer = g_hCvarbashKillBoomer.BoolValue;
	g_bCvarbashKillSpitter = g_hCvarbashKillSpitter.BoolValue;
	g_bCvarbashKillJockey = g_hCvarbashKillJockey.BoolValue;
}

public void OnClientPutInServer( int client ) {
    SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}


Action Hook_OnTakeDamage(int iVictim, int& iAttacker, int& iInflictor, float& fDamage, \
									int& iDamageType, int& iWeapon, float fDamageForce[3], float fDamagePosition[3])
{
	if (!g_bCvarEnable) {
		return Plugin_Continue;
	}

	//PrintToChatAll("damage is %d ,damageType is %d,weapon is %d",damage, damageType,weapon);
	if (iDamageType == DMG_CLUB && iWeapon == -1 && fDamage == 250.0) 
	{
		if (IsSurvivor(iAttacker) && IsSI(iVictim)) 
		{
			int zombieclass = GetEntProp(iVictim, Prop_Send, "m_zombieClass");
			if(zombieclass == ZOMBIECLASS_BOOMER && g_bCvarbashKillBoomer == false)
			{
				return Plugin_Continue;
			}
			else if(zombieclass == ZOMBIECLASS_SMOKER && g_bCvarbashKillSmoker == false)
			{
				return Plugin_Continue;
			}
			else if(zombieclass == ZOMBIECLASS_HUNTER && g_bCvarbashKillHunter == false)
			{
				return Plugin_Continue;
			}
			else if(zombieclass == ZOMBIECLASS_SPITTER && g_bCvarbashKillSpitter == false)
			{
				return Plugin_Continue;
			}
			else if(zombieclass == ZOMBIECLASS_JOCKEY && g_bCvarbashKillJockey == false)
			{
				return Plugin_Continue;
			}

			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}


bool IsSI( int client ) {
    if ( !IsClientInGame(client) || GetClientTeam(client) != 3 || !IsPlayerAlive(client) ) {
        return false;
    }
    
    return true;
}

bool IsSurvivor( int client ) {
    if ( client <= 0
    || client > MaxClients
    || !IsClientConnected(client)
    || !IsClientInGame(client)
    || GetClientTeam(client) != 2
    || !IsPlayerAlive(client) ) {
        return false;
    }
    
    return true;
}