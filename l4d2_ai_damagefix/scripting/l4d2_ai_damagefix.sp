#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define TEAM_SURVIVOR           2
#define TEAM_INFECTED           3

#define ZC_SMOKER               1
#define ZC_BOOMER               2
#define ZC_HUNTER               3
#define ZC_SPITTER              4
#define ZC_JOCKEY               5
#define ZC_CHARGER              6

// Bit flags to enable individual features of the plugin
#define SKEET_POUNCING_AI       (0x01)
#define DEBUFF_CHARGING_AI      (0x02)
#define ALL_FEATURES            (SKEET_POUNCING_AI | DEBUFF_CHARGING_AI)

// Globals
bool bLateLoad = false;

// CVars
int iEnabled                                                = ALL_FEATURES;         // Enables individual features of the plugin
int iPounceInterrupt                                        = 150;                  // Caches pounce interrupt cvar's value
int iHunterSkeetDamage[MAXPLAYERS+1]                        = { 0, ... };           // How much damage done in a single hunter leap so far
bool g_bHunterAttemptingToPounce[MAXPLAYERS+1]               = { false, ... };

public Plugin myinfo =
{
    name = "Bot SI skeet/level damage fix",
    author = "Tabun, dcx2, Harry",
    description = "Makes AI SI take (and do) damage like human SI.",
    version = "1.1h -2024/8/6",
    url = "https://steamcommunity.com/profiles/76561198026784913/"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    RegPluginLibrary("l4d2_ai_damagefix");

    bLateLoad = late;
    return APLRes_Success;
}

public void OnPluginStart()
{
    ConVar hCvarPounceInterrupt = FindConVar("z_pounce_damage_interrupt");
    iPounceInterrupt = hCvarPounceInterrupt.IntValue;
    hCvarPounceInterrupt.AddChangeHook(OnPounceInterruptChanged);

    // find/create cvars, hook changes, cache current values
    ConVar hCvarEnabled = CreateConVar("l4d2_ai_damagefix_enable", "3", "Bit flag: Enables plugin features (add together): 1=Skeet pouncing AI hunter, 2=Debuff charging AI charger, 3=Both, 0=off", FCVAR_NOTIFY, true, 0.0, true, 3.0);
    AutoExecConfig(true,               "l4d2_ai_damagefix");

    iEnabled = hCvarEnabled.IntValue;
    hCvarEnabled.AddChangeHook(OnAIDamageFixEnableChanged);

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

bool g_bMeleeModfiyDamage;
ConVar l4d2_melee_modify_damage_enable;
int g_bl4d2_melee_modify_damage_enable;
public void OnAllPluginsLoaded()
{
    g_bMeleeModfiyDamage = LibraryExists("l4d2_melee_modify_damage");
    ConVar convar;
    convar = FindConVar("l4d2_melee_modify_damage_enable");
    if (convar != null && l4d2_melee_modify_damage_enable != convar)
    {
        l4d2_melee_modify_damage_enable = convar;
        GetOtherPluginsCvars();
        l4d2_melee_modify_damage_enable.AddChangeHook(ConVarChanged_l4d2_melee_modify_damage_enable);
    }
}

public void OnLibraryAdded(const char[] name)
{
    g_bMeleeModfiyDamage = LibraryExists("l4d2_melee_modify_damage");
    ConVar convar;
    convar = FindConVar("l4d2_melee_modify_damage_enable");
    if (convar != null && l4d2_melee_modify_damage_enable != convar)
    {
        l4d2_melee_modify_damage_enable = convar;
        GetOtherPluginsCvars();
        l4d2_melee_modify_damage_enable.AddChangeHook(ConVarChanged_l4d2_melee_modify_damage_enable);
    }
}

public void OnLibraryRemoved(const char[] name)
{
    g_bMeleeModfiyDamage = LibraryExists("l4d2_melee_modify_damage");
    ConVar convar;
    convar = FindConVar("l4d2_melee_modify_damage_enable");
    if (convar != null && l4d2_melee_modify_damage_enable != convar)
    {
        l4d2_melee_modify_damage_enable = convar;
        GetOtherPluginsCvars();
        l4d2_melee_modify_damage_enable.AddChangeHook(ConVarChanged_l4d2_melee_modify_damage_enable);
    }
}

void ConVarChanged_l4d2_melee_modify_damage_enable(ConVar convar, const char[] oldValue, const char[] newValue)
{
    GetOtherPluginsCvars();
}

void GetOtherPluginsCvars()
{
    g_bl4d2_melee_modify_damage_enable = l4d2_melee_modify_damage_enable.BoolValue; 
}

void OnPounceInterruptChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    iPounceInterrupt = StringToInt(newValue);
}

void OnAIDamageFixEnableChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    iEnabled = StringToInt(newValue);
}

public void OnClientPutInServer(int client)
{
    // hook bots spawning
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
    iHunterSkeetDamage[client] = 0;
}

Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if(g_bMeleeModfiyDamage && g_bl4d2_melee_modify_damage_enable) return Plugin_Continue;

    // Must be enabled, victim and attacker must be ingame, damage must be greater than 0, victim must be AI infected
    if (iEnabled && IsClientAndInGame(victim) && IsClientAndInGame(attacker) && damage > 0.0 && GetClientTeam(victim) == TEAM_INFECTED && IsFakeClient(victim))
    {
        int zombieClass = GetEntProp(victim, Prop_Send, "m_zombieClass");

        // Is this AI hunter attempting to pounce?
        if (zombieClass == ZC_HUNTER && (iEnabled & SKEET_POUNCING_AI) && GetEntProp(victim, Prop_Send, "m_isAttemptingToPounce"))
        {
            iHunterSkeetDamage[victim] += RoundToFloor(damage);
            
            // have we skeeted it?
            if (iHunterSkeetDamage[victim] >= iPounceInterrupt)
            {
                // Skeet the hunter
                iHunterSkeetDamage[victim] = 0;
                damage = float(GetClientHealth(victim));
                return Plugin_Changed;
            }
            else
            {
                if(damagetype & DMG_CLUB || damagetype & DMG_SLASH)
                {
                    g_bHunterAttemptingToPounce[victim] = true;
                    SetEntProp(victim, Prop_Send, "m_isAttemptingToPounce", 0);
                }
            }
        }
        else if (zombieClass == ZC_CHARGER && (iEnabled & DEBUFF_CHARGING_AI))
        {
            // Is this AI charger charging?
            int abilityEnt = GetEntPropEnt(victim, Prop_Send, "m_customAbility");
            if (IsValidEntity(abilityEnt) && GetEntProp(abilityEnt, Prop_Send, "m_isCharging") > 0)
            {
                // Game does Floor(Floor(damage) / 3 - 1) to charging AI chargers, so multiply Floor(damage)+1 by 3
                damage = (damage - FloatFraction(damage) + 1.0) * 3.0;
                return Plugin_Changed;
            }
        }
    }
    
    return Plugin_Continue;
}

void OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
    if (iEnabled && IsClientAndInGame(victim) && GetClientTeam(victim) == TEAM_INFECTED && IsFakeClient(victim))
    {
        if(GetEntProp(victim, Prop_Send, "m_zombieClass") == ZC_HUNTER && g_bHunterAttemptingToPounce[victim]) 
        {
            SetEntProp(victim, Prop_Send, "m_isAttemptingToPounce", 1);
        }

        g_bHunterAttemptingToPounce[victim] = false;
    }
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