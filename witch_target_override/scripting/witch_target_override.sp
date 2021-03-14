#define PLUGIN_VERSION "1.1"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define DEBUG 0
#define L4D_TEAM_SPECTATOR        1
#define L4D_TEAM_SURVIVORS         2
#define L4D_TEAM_INFECTED         3

public Plugin myinfo = 
{
    name = "Witch Target Override",
    author = "xZk, BHaType, HarryPotter",
    description = "witch target override in better way.",
    version = PLUGIN_VERSION,
    url = "https://steamcommunity.com/id/HarryPotter_TW/"
};

ConVar g_hCvarAllow, g_hCvarIncapOverride, g_hCvarKillOverride,
    g_hCvarIncapOverrideHealth, g_hCvarKillOverrideHealth, g_hRequiredRange;
int g_iCvarIncapOverrideHealth, g_iCvarKillOverrideHealth;
bool g_bCvarAllow, g_bCvarIncapOverride, g_bCvarKillOverride;
float g_fRequiredRange;

public void OnPluginStart()
{
    g_hCvarAllow = CreateConVar("witch_target_override_on", "1", "1=Plugin On. 0=Plugin Off", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_hCvarIncapOverride = CreateConVar("witch_target_override_incap", "1", "If 1, allow witch to chased another target after she incapacitated a survivor.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_hCvarKillOverride = CreateConVar("witch_target_override_kill", "1", "If 1, allow witch to chased another target after she killed a survivor.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_hCvarIncapOverrideHealth = CreateConVar("witch_target_override_incap_health", "0", "Set witch health if she is allowed to chased another target after she incapacitated a survivor. (0=Off)", FCVAR_NOTIFY, true, 0.0, true, 9999.0);
    g_hCvarKillOverrideHealth = CreateConVar("witch_target_override_kill_health", "1000", "Set witch health if she is allowed to chased chased another target after she killed a survivor. (0=Off)", FCVAR_NOTIFY, true, 0.0, true, 9999.0);
    g_hRequiredRange = CreateConVar("witch_target_override_range", "9999", "This controls the range for witch to reacquire another target. (If no targets within range, witch default behavior)", FCVAR_NOTIFY, true, 0.0, true, 9999.0);

    GetCvars();
    g_hCvarAllow.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarIncapOverride.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarKillOverride.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarIncapOverrideHealth.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarKillOverrideHealth.AddChangeHook(ConVarChanged_Cvars);
    g_hRequiredRange.AddChangeHook(ConVarChanged_Cvars);

    #if DEBUG
        RegConsoleCmd("sm_test", sm_insult);
    #endif

    HookEvent("player_incapacitated", Player_Incapacitated);
    HookEvent("player_death", Player_Death);

    //Autoconfig for plugin
    AutoExecConfig(true, "witch_target_override");
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
    GetCvars();
}

void GetCvars()
{
    g_bCvarAllow = g_hCvarAllow.BoolValue;
    g_bCvarIncapOverride = g_hCvarIncapOverride.BoolValue;
    g_bCvarKillOverride = g_hCvarKillOverride.BoolValue;
    g_iCvarIncapOverrideHealth = g_hCvarIncapOverrideHealth.IntValue;
    g_iCvarKillOverrideHealth = g_hCvarKillOverrideHealth.IntValue;
    g_fRequiredRange = g_hRequiredRange.FloatValue;
}

public Action sm_insult ( int client, int args )
{
    if(client == 0 || g_bCvarAllow == false) return Plugin_Handled;

    int target = GetClientAimTarget(client);
    
    if ( target == -1 )
        return Plugin_Handled;

    int witch = MaxClients + 1;

    while ( (witch = FindEntityByClassname(witch, "witch")) && IsValidEntity(witch) )
    {
        WitchAttackTarget(witch, target, 0);
    }

    return Plugin_Handled;
}

public Action Player_Incapacitated(Event event, const char[] event_name, bool dontBroadcast)
{
    if(g_bCvarAllow == false || g_bCvarIncapOverride == false) return;

    int victim = GetClientOfUserId(event.GetInt("userid"));
    int entity = event.GetInt("attackerentid");
    if (IsWitch(entity) && victim > 0 && victim <= MaxClients && IsSurvivor(victim))
    {
        int target = GetNearestSurvivorDist(entity);
        if(target == 0) return;

        WitchAttackTarget(entity, target, g_iCvarIncapOverrideHealth);
    }
}

public Action Player_Death(Event event, const char[] event_name, bool dontBroadcast)
{
    if(g_bCvarAllow == false || g_bCvarKillOverride == false ) return;

    int victim = GetClientOfUserId(event.GetInt("userid"));
    int entity = event.GetInt("attackerentid");
    if (IsWitch(entity) && victim > 0 && victim <= MaxClients && IsSurvivor(victim))
    {
        int target = GetNearestSurvivorDist(entity);
        if(target == 0) return;

        WitchAttackTarget(entity, target, g_iCvarKillOverrideHealth);
    }
}

stock void WitchAttackTarget(int witch, int target, int newHealth)
{

    if(GetEntProp(witch, Prop_Data, "m_iHealth") < 0) return;
    #if DEBUG
        PrintToChatAll("witch attacking new target %N, her max health: %d, now health: %d", target, GetEntProp(witch, Prop_Data, "m_iMaxHealth"), GetEntProp(witch, Prop_Data, "m_iHealth"));
    #endif

    if(newHealth > 0) SetEntProp(witch, Prop_Data, "m_iHealth", newHealth);

    if(GetEntProp(witch, Prop_Send, "m_bIsBurning") == 1)
    {
        ExtinguishEntity(witch);
        int flame = GetEntPropEnt(witch, Prop_Send, "m_hEffectEntity");
        if( flame != -1 )
        {
            AcceptEntityInput(flame, "Kill");
        }

        SDKHooks_TakeDamage(witch, target, target, 0.0, DMG_BURN);
    }
    else
    {
        int anim = GetEntProp(witch, Prop_Send, "m_nSequence");
        SDKHooks_TakeDamage(witch, target, target, 0.0, DMG_BURN);
        SetEntProp(witch, Prop_Send, "m_nSequence", anim);
        SetEntProp(witch, Prop_Send, "m_bIsBurning", 0);
        SDKHook(witch, SDKHook_ThinkPost, PostThink);
    }
}

public void PostThink(int witch)
{
    SDKUnhook(witch, SDKHook_ThinkPost, PostThink);

    ExtinguishEntity(witch);

    int flame = GetEntPropEnt(witch, Prop_Send, "m_hEffectEntity");
    if( flame != -1 )
    {
        AcceptEntityInput(flame, "Kill");
    }
}

int GetNearestSurvivorDist(int entity)
{
    int target = 0, IncapTarget= 0;
    float s_fRequiredRange = Pow (g_fRequiredRange, 2.0);
    float Origin[3], TOrigin[3], distance = 0.0;
    float fMinDistance = 0.0, fMinIncapDistance = 0.0;
    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Origin);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsSurvivor(i) && IsPlayerAlive(i))
        {
            GetEntPropVector(i, Prop_Send, "m_vecOrigin", TOrigin);
            distance = GetVectorDistance(Origin, TOrigin, true);
            if (s_fRequiredRange >= distance)
            {
                if(IsPlayerIncapOrHanging(i))
                {
                    if (fMinIncapDistance == 0.0 || fMinIncapDistance > distance)
                    {
                        fMinIncapDistance = distance;
                        IncapTarget = i;
                    } 
                }
                else
                {
                    if (fMinDistance == 0.0 || fMinDistance > distance)
                    {
                        fMinDistance = distance;
                        target = i;
                    } 
                }
            }
        }
    }

    if(target == 0) return IncapTarget;

    return target;
}

bool IsWitch(int entity)
{
    if (entity > MaxClients && IsValidEntity(entity))
    {
        static char classname[16];
        GetEdictClassname(entity, classname, sizeof(classname));
        if (strcmp(classname, "witch", false) == 0)
            return true;
    }
    return false;
}

bool IsSurvivor(int client)
{
    if (IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_SURVIVORS)
    {
        return true;
    }
    return false;   
}


bool IsPlayerIncapOrHanging(int client)
{
    if (GetEntProp(client, Prop_Send, "m_isIncapacitated")) 
        return true;
    if (GetEntProp(client, Prop_Send, "m_isHangingFromLedge"))
        return true;

    return false;
} 