#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
//#include <left4dhooks>

#define PLUGIN_VERSION			"1.0-2025/9/24"
#define PLUGIN_NAME			    "l4d_minigun_fly_fix"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D1/2] l4d_minigun_fly_fix",
	author = "HarryPotter",
	description = "Fixes a glitch with a minigun that allows players to fly long distances (Hold SPACE and press E twice)",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1/2.");
        return APLRes_SilentFailure;
    }

    bLate = late;
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

    if(bLate)
    {
        LateLoad();
    }
}

void LateLoad()
{
    int entity;
    char classname[64];

    entity = INVALID_ENT_REFERENCE;
    // prop_minigun_l4d1
    // prop_minigun
    while ((entity = FindEntityByClassname(entity, "prop_minigun*")) != INVALID_ENT_REFERENCE)
    {
        if (!IsValidEntity(entity))
            continue;

        GetEntityClassname(entity, classname, sizeof(classname));
        OnEntityCreated(entity, classname);
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
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if(entity > 2048) return;

    switch (classname[0])
    {
        case 'p':
        {
            // prop_minigun_l4d1
            // prop_minigun
            if( strncmp(classname, "prop_minigun", 12, false) == 0 )
            {
                RequestFrame(OnNextFrame_minigun, EntIndexToEntRef(entity));
            }
            else if( strncmp(classname, "prop_mounted_machine_gun", 24, false) == 0 )
            {
                RequestFrame(OnNextFrame_minigun, EntIndexToEntRef(entity));
            }
        }
    }
}

void OnNextFrame_minigun(int entity)
{
    entity = EntRefToEntIndex(entity);
    if( entity == INVALID_ENT_REFERENCE ) return;

    SDKHook(entity, SDKHook_UsePost, OnUse);
}

void OnUse(int weapon, int client, int caller, UseType type, float value)
{
    if(!g_bCvarEnable) return;

    if(client && IsClientInGame(client))
    {
        SetEntPropFloat(client, Prop_Send, "m_jumpSupressedUntil",  GetGameTime() + 0.1); // release space key

        if(!(GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONGROUND))
        {
            float fVelocity[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
            fVelocity[0] = 0.0;
            fVelocity[1] = 0.0;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity); // prevent fly
        }
    }
}

// ====================================================================================================
// KEYBINDS
// ====================================================================================================
/*public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
    if( !g_bCvarEnable ) return Plugin_Continue;

    if( IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
    {
        if(!IsUsingMinigun(client)) return Plugin_Continue;

        SetEntPropFloat(client, Prop_Send, "m_jumpSupressedUntil",  GetGameTime() + 0.1); // release space key

        if(!(GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONGROUND))
        {
            float fVelocity[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
            fVelocity[0] = 0.0;
            fVelocity[1] = 0.0;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity); // prevent fly
        }
    }

    return Plugin_Continue;
}*/

/*public void OnPlayerRunCmdPost(int client, int buttons, int impulse, const float vel[3], const float angles[3], int weapon, int subtype, int cmdnum, int tickcount, int seed, const int mouse[2])
{
    if( !g_bCvarEnable ) return;

    if( IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
    {
        if(!IsUsingMinigun(client)) return;

        SetEntPropFloat(client, Prop_Send, "m_jumpSupressedUntil",  GetGameTime() + 0.1); // release space key

        if(!(GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONGROUND))
        {
            float fVelocity[3];
            GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
            fVelocity[0] = 0.0;
            fVelocity[1] = 0.0;
            TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity); // prevent fly
        }
    }
}
*/