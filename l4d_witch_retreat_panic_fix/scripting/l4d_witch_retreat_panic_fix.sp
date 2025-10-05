#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <actions>

#define PLUGIN_VERSION			"1.0-2025/10/5"
#define PLUGIN_NAME			    "l4d_witch_retreat_panic_fix"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D1/2] l4d_witch_retreat_panic_fix",
	author = "HarryPotter, forgetest",
	description = "Fixed the bug that witch cancels retreat and comes back to chase survivor again if game starts panic event",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar g_hCvarEnable;
bool g_bCvarEnable;

public void OnPluginStart()
{
    g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",        "1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                       PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                PLUGIN_NAME);

    GetCvars();
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);

}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarEnable = g_hCvarEnable.BoolValue;
}

// API---------------

// ACTIONS EXTENSION ====================================================================================================

public void OnActionCreated(BehaviorAction action, int actor, const char[] name)
{
    if(!g_bCvarEnable) return;

    if (name[0] == 'W' && strcmp(name, "WitchRetreat") == 0)
        action.OnCommandAttack = OnCommandAttack;
}

Action OnCommandAttack(BehaviorAction action, int actor, int entity, ActionDesiredResult result)
{
	result.type = SUSTAIN;
	return Plugin_Handled;
}
