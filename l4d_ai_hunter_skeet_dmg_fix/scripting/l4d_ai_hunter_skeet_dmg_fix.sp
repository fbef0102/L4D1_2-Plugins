#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
    name = "Bot Hunter skeet damage fix",
    author = "Tabun, dcx2, Harry",
    description = "Makes AI Hunter take damage like human SI while pouncing.",
    version = "1.0h -2024/8/11",
    url = "https://steamcommunity.com/profiles/76561198026784913/"
}

bool bLateLoad;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    RegPluginLibrary("l4d_ai_hunter_skeet_dmg_fix");

    bLateLoad = late;
    return APLRes_Success;
}

#define TEAM_SURVIVOR           2
#define TEAM_INFECTED           3

#define ZC_HUNTER               3

ConVar z_pounce_damage_interrupt;
int g_iCvarPounceInterrupt;  

ConVar g_hCvarEnable;
bool g_bCvarEnable;

int 
    iHunterSkeetDamage[MAXPLAYERS+1];

public void OnPluginStart()
{
    z_pounce_damage_interrupt = FindConVar("z_pounce_damage_interrupt");
    g_iCvarPounceInterrupt = z_pounce_damage_interrupt.IntValue;
    z_pounce_damage_interrupt.AddChangeHook(ConVarChanged_Cvars);

    // find/create cvars, hook changes, cache current values
    g_hCvarEnable = CreateConVar(     "l4d_ai_hunter_skeet_dmg_fix_enable", "1", "0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    AutoExecConfig(true,              "l4d_ai_hunter_skeet_dmg_fix");

    g_bCvarEnable = g_hCvarEnable.BoolValue;
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);

    // events
    HookEvent("ability_use", Event_AbilityUse, EventHookMode_Post);
    
    // hook when loading late
    if (bLateLoad) {
        for (int i = 1; i <= MaxClients; i++) {
            if (IsClientAndInGame(i)) {
                OnClientPutInServer(i);
            }
        }
    }
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
    g_iCvarPounceInterrupt = z_pounce_damage_interrupt.IntValue;

    g_bCvarEnable = g_hCvarEnable.BoolValue;
}

public void OnClientPutInServer(int client)
{
    // hook bots spawning
    SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
    iHunterSkeetDamage[client] = 0;
}

Action OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3])
{
    // Must be enabled, victim and attacker must be ingame, damage must be greater than 0, victim must be AI infected
    if (g_bCvarEnable && IsClientAndInGame(victim) && IsClientAndInGame(attacker) && damage > 0.0 && GetClientTeam(victim) == TEAM_INFECTED && IsFakeClient(victim))
    {
        int zombieClass = GetEntProp(victim, Prop_Send, "m_zombieClass");

        // Is this AI hunter attempting to pounce?
        if (zombieClass == ZC_HUNTER && GetEntProp(victim, Prop_Send, "m_isAttemptingToPounce"))
        {
            iHunterSkeetDamage[victim] += RoundToFloor(damage);
            
            // have we skeeted it?
            if (iHunterSkeetDamage[victim] >= g_iCvarPounceInterrupt)
            {
                // Skeet the hunter
                iHunterSkeetDamage[victim] = 0;
                damage = float(GetClientHealth(victim));
                return Plugin_Changed;
            }
        }
    }
    
    return Plugin_Continue;
}

// hunters pouncing / tracking
void Event_AbilityUse(Event event, const char[] name, bool dontBroadcast)
{
    // track hunters pouncing
    int client = GetClientOfUserId(event.GetInt("userid"));
    char abilityName[64];
    
    if (!IsClientAndInGame(client) || GetClientTeam(client) != TEAM_INFECTED) { return; }
    
    event.GetString("ability", abilityName, sizeof(abilityName));
    
    if (strcmp(abilityName, "ability_lunge", false) == 0)
    {
        // Clear skeet tracking damage each time the hunter starts a pounce
        iHunterSkeetDamage[client] = 0;
    }
}

bool IsClientAndInGame(int index)
{
    return (index > 0 && index <= MaxClients && IsClientInGame(index));
}