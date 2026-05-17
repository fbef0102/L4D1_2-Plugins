#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

#define PLUGIN_VERSION			"1.0-2026/5/17"
#define PLUGIN_NAME			    "l4d_cutscene_nodamage"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D1/2] Cutscenes No Damage",
	author = "HarryPotter",
	description = "Survivors won't take any damage when server is playing map cutscenes",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    bLate = late;
    return APLRes_Success;
}

#define DATA_FILE		        "data/" ... PLUGIN_NAME ... ".cfg"
#define MAXENTITIES                   2048

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar g_hCvarEnable;
bool g_bCvarEnable;

bool 
    g_bRoundEnd,
    g_bMapEnable,
    g_bValidAttacker[MAXENTITIES+1],
    g_bValidCamera[MAXENTITIES+1];

float
    g_fGetProtectTime[MAXPLAYERS+1];

public void OnPluginStart()
{
    g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",        "1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                       PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                PLUGIN_NAME);

    GetCvars();
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);

    HookEvent("round_start",            Event_RoundStart, EventHookMode_PostNoCopy);
    HookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy); //trigger twice in versus/survival/scavenge mode, one when all survivors wipe out or make it to saferom, one when first round ends (second round_start begins).
    HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //1. all survivors make it to saferoom in and server is about to change next level in coop mode (does not trigger round_end), 2. all survivors make it to saferoom in versus
    HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
    HookEvent("finale_win", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //有三方圖不會用載具離開當結束 不觸發"finale_vehicle_leaving"

    if(bLate)
    {
        LateLoad();
    }
}


void LateLoad()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
            continue;

        OnClientPutInServer(client);
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

// Sourcemod API Forward-------------------------------

public void OnMapStart()
{
    LoadData();
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, SurvivorOnTakeDamage);
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if (!IsValidEntityIndex(entity))
        return;

    switch (classname[0])
    {
        case 'i':
        {
            if (StrEqual(classname, "infected"))
                g_bValidAttacker[entity] = true;
        }
        case 'w':
        {
            if (StrEqual(classname, "witch"))
                g_bValidAttacker[entity] = true;
        }
        case 'p':
        {
            if( strcmp(classname, "point_viewcontrol", false) == 0 
                || strcmp(classname, "point_viewcontrol_survivor", false) == 0
                || strcmp(classname, "point_viewcontrol_multiplayer", false) == 0  )
            {
                g_bValidCamera[entity] = true;
            }
        }
    }
}

public void OnEntityDestroyed(int entity)
{
    if (!IsValidEntityIndex(entity))
        return;

    g_bValidAttacker[entity] = false;
    g_bValidCamera[entity] = false;
}

// Data-----------

void LoadData()
{
    g_bMapEnable = false;

    char sPath[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, sPath, sizeof(sPath), DATA_FILE);
    if( !FileExists(sPath) )
    {
        SetFailState("File Not Found: %s", sPath);
        return;
    }

    // Load config
    KeyValues hFile = new KeyValues(PLUGIN_NAME);
    if( !hFile.ImportFromFile(sPath) )
    {
        SetFailState("File Format Not Correct: %s", sPath);
        delete hFile;
        return;
    }

    if( hFile.JumpToKey("Maps") )
    {
        if( hFile.JumpToKey("default") )
        {
            g_bMapEnable = view_as<bool>(hFile.GetNum("enable", g_bMapEnable));

            hFile.GoBack();
        }

        char sCurrentMap[64];
        GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));
        if( hFile.JumpToKey(sCurrentMap) )
        {
            g_bMapEnable = view_as<bool>(hFile.GetNum("enable", g_bMapEnable));

            hFile.GoBack();
        }

        hFile.GoBack();
    }
    else
    {
        SetFailState("File Format Not Correct: %s", sPath);
        delete hFile;
        return;
    }

    delete hFile;
}

// Event--

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
    for(int i = 1; i <= MaxClients; i++)
    {
        g_fGetProtectTime[i] = 0.0;
    }

    g_bRoundEnd = false;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
    g_bRoundEnd = true;
}

// SDKHooks-------------------------------

Action SurvivorOnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (!g_bCvarEnable || !g_bMapEnable)
    {
        SDKUnhook(victim, SDKHook_OnTakeDamage, SurvivorOnTakeDamage);
        return Plugin_Continue;
    }

    if (GetClientTeam(victim) != 2) return Plugin_Continue;

    if(!IsMapCameraProtectTime(victim)) return Plugin_Continue;

    if(attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
    {
        damage = 0.0;
        return Plugin_Handled;
    }
    else if(attacker > MaxClients && g_bValidAttacker[attacker])
    {
        damage = 0.0;
        return Plugin_Handled;
    }

    return Plugin_Continue;
}

//Left4Dhooks API Forward-------------------------------


//The Knockdown reason type. 1=Hunter lunge (可偵測), 2=Tank rock (可偵測), 3=Charger impact (無法偵測)
public Action L4D_OnKnockedDown(int client, int reason)
{
	if (!g_bCvarEnable || !g_bMapEnable) return Plugin_Continue;
	if(!client || !IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != L4D_TEAM_SURVIVOR) return Plugin_Continue;
	if(!IsMapCameraProtectTime(client)) return Plugin_Continue;

	return Plugin_Handled;
}

// Called when a Survivor player is about to be pounced on by a Hunter
public Action L4D_OnPouncedOnSurvivor(int victim, int attacker)
{
	if (!g_bCvarEnable || !g_bMapEnable) return Plugin_Continue;
	if(!victim || !IsClientInGame(victim) || IsFakeClient(victim) || GetClientTeam(victim) != L4D_TEAM_SURVIVOR) return Plugin_Continue;
	if(!IsMapCameraProtectTime(victim)) return Plugin_Continue;

	return Plugin_Handled;
}

// Called when a Survivor player is about to be grabbed by a Smoker
public Action L4D_OnGrabWithTongue(int victim, int attacker)
{
	if (!g_bCvarEnable || !g_bMapEnable) return Plugin_Continue;
	if(!victim || !IsClientInGame(victim) || IsFakeClient(victim) || GetClientTeam(victim) != L4D_TEAM_SURVIVOR) return Plugin_Continue;
	if(!IsMapCameraProtectTime(victim)) return Plugin_Continue;

	return Plugin_Handled;
}

// Called when a Survivor player is about to be ridden by a Jockey
public Action L4D2_OnJockeyRide(int victim, int attacker)
{
	if (!g_bCvarEnable || !g_bMapEnable) return Plugin_Continue;
	if(!victim || !IsClientInGame(victim) || IsFakeClient(victim) || GetClientTeam(victim) != L4D_TEAM_SURVIVOR) return Plugin_Continue;
	if(!IsMapCameraProtectTime(victim)) return Plugin_Continue;

    return Plugin_Handled;
}

// When a tank swings and punches a player
public Action L4D_TankClaw_OnPlayerHit_Pre(int tank, int claw, int player)
{
	if (!g_bCvarEnable || !g_bMapEnable) return Plugin_Continue;
	if(!player || !IsClientInGame(player) || IsFakeClient(player) || GetClientTeam(player) != L4D_TEAM_SURVIVOR) return Plugin_Continue;
	if(!IsMapCameraProtectTime(player)) return Plugin_Continue;

    return Plugin_Handled;
}

// 人類被Charger撞飛
public Action L4D2_OnThrowImpactedSurvivor(int attacker, int victim)
{
	if (!g_bCvarEnable || !g_bMapEnable) return Plugin_Continue;
	if(!victim || !IsClientInGame(victim) || IsFakeClient(victim) || GetClientTeam(victim) != L4D_TEAM_SURVIVOR) return Plugin_Continue;
	if(!IsMapCameraProtectTime(victim)) return Plugin_Continue;

    return Plugin_Handled;
}

// Called when a Survivor player is about to be carried by a Charger
public Action L4D2_OnStartCarryingVictim(int victim, int attacker)
{
	if (!g_bCvarEnable || !g_bMapEnable) return Plugin_Continue;
	if(!victim || !IsClientInGame(victim) || IsFakeClient(victim) || GetClientTeam(victim) != L4D_TEAM_SURVIVOR) return Plugin_Continue;
	if(!IsMapCameraProtectTime(victim)) return Plugin_Continue;

    return Plugin_Handled;
}

// 人類靠牆被抓又撞時, 不會觸發L4D2_OnStartCarryingVictim
public Action L4D2_OnSlammedSurvivor(int victim, int attacker, bool &bWallSlam, bool &bDeadlyCharge)
{
	if (!g_bCvarEnable || !g_bMapEnable) return Plugin_Continue;
	if(!victim || !IsClientInGame(victim) || IsFakeClient(victim) || GetClientTeam(victim) != L4D_TEAM_SURVIVOR) return Plugin_Continue;
	if(!IsMapCameraProtectTime(victim)) return Plugin_Continue;

    return Plugin_Handled;
}

// Other----

bool IsMapCameraProtectTime(int client)
{
    if(g_bRoundEnd) return false;
    
    float now = GetEngineTime();
    int iViewEntity = GetEntPropEnt(client, Prop_Send, "m_hViewEntity");
    if(iViewEntity > MaxClients && IsValidEntity(iViewEntity) )
    {
        if( g_bValidCamera[iViewEntity] )
        {
            g_fGetProtectTime[client] = now + 1.5;
            return true;
        }
    }

    if(g_fGetProtectTime[client] > now)
        return true;

    return false;
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}