#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#define PLUGIN_VERSION			"1.0"
#define PLUGIN_NAME			    "tank_witch_spawn_notify"
#define DEBUG 0

public Plugin myinfo =
{
    name        = "Tank/Witch Spawn Announcement with sound",
    author      = "HarryPotter",
    description = "When the tank and witch spawns, it announces itself in chat by making a sound",
    version     = PLUGIN_VERSION,
    url         = "https://steamcommunity.com/profiles/76561198026784913/"
}

static int    g_iTankClass;
static bool   g_bL4D2;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion engine = GetEngineVersion();

    if (engine != Engine_Left4Dead && engine != Engine_Left4Dead2)
    {
        strcopy(error, err_max, "This plugin only runs in \"Left 4 Dead\" and \"Left 4 Dead 2\" game");
        return APLRes_SilentFailure;
    }

    g_bL4D2 = (engine == Engine_Left4Dead2);
    g_iTankClass = (g_bL4D2 ? 8 : 5);

    return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define TRANSLATION_FILE		PLUGIN_NAME ... ".phrases"

#define SOUND                         "ui/pickup_secret01.wav"

#define TEAM_INFECTED                 3

ConVar g_hCvarTankAnnounce, g_hCvarTankSound,
    g_hCvarWitchAnnounce, g_hCvarWitchSound;
bool g_bCvarTankAnnounce, g_bCvarWitchAnnounce;
char g_sCvarTankSound[PLATFORM_MAX_PATH], g_sCvarWitchSound[PLATFORM_MAX_PATH];

bool g_bAliveTank, g_bMapStarted;
public void OnPluginStart()
{
    LoadTranslations(TRANSLATION_FILE);

    g_hCvarTankAnnounce     = CreateConVar(PLUGIN_NAME ... "_tank_announce",       "1",   "If 1, announce chat when tank spawns", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarWitchAnnounce    = CreateConVar(PLUGIN_NAME ... "_witch_announce",      "1",   "If 1, announce chat when witch spawns", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarTankSound        = CreateConVar(PLUGIN_NAME ... "_tank_sound_file",     "ui/pickup_secret01.wav",   "Tank sound file (relative to to sound/, empty=Disable)", CVAR_FLAGS);
    g_hCvarWitchSound       = CreateConVar(PLUGIN_NAME ... "_witch_sound_file",    "ui/pickup_secret01.wav",   "Witch sound file (relative to to sound/, empty=Disable)", CVAR_FLAGS);
    CreateConVar(                          PLUGIN_NAME ... "_version",             PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                   PLUGIN_NAME);

    GetCvars();
    g_hCvarTankAnnounce.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarWitchAnnounce.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarTankSound.AddChangeHook(ConVarChanged_SoundCvars);
    g_hCvarWitchSound.AddChangeHook(ConVarChanged_SoundCvars);

    HookEvent("tank_spawn", Event_TankSpawn);
    HookEvent("witch_spawn", Event_WitchSpawn);

    CreateTimer(1.0, tmrAliveTankCheck, _, TIMER_REPEAT);
}

//-------------------------------Cvars-------------------------------

public void ConVarChanged_Cvars(Handle hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

public void ConVarChanged_SoundCvars(Handle hCvar, const char[] sOldVal, const char[] sNewVal)
{
    GetCvars();

    if(g_bMapStarted)
    {
        if (strlen(g_sCvarTankSound) > 0) PrecacheSound(g_sCvarTankSound);
        if (strlen(g_sCvarWitchSound) > 0) PrecacheSound(g_sCvarWitchSound);
    }
}

void GetCvars()
{
    g_bCvarTankAnnounce = g_hCvarTankAnnounce.BoolValue;
    g_bCvarWitchAnnounce = g_hCvarWitchAnnounce.BoolValue;

    g_hCvarTankSound.GetString(g_sCvarTankSound, sizeof(g_sCvarTankSound));
    g_hCvarWitchSound.GetString(g_sCvarWitchSound, sizeof(g_sCvarWitchSound));
}

//-------------------------------Sourcemod API Forward-------------------------------

public void OnMapStart()
{
    g_bMapStarted = true;
}

public void OnMapEnd()
{
    g_bMapStarted = false;
}

public void OnConfigsExecuted()
{
    GetCvars();
    if (strlen(g_sCvarTankSound) > 0) PrecacheSound(g_sCvarTankSound);
    if (strlen(g_sCvarWitchSound) > 0) PrecacheSound(g_sCvarWitchSound);
}

public void Event_TankSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (g_bAliveTank)
        return;

    if (strlen(g_sCvarTankSound) > 0) EmitSoundToAll(g_sCvarTankSound);
    if (g_bCvarTankAnnounce) CPrintToChatAll("%t", "Tank");

    g_bAliveTank = true;
}

public void Event_WitchSpawn(Event event, const char[] name, bool dontBroadcast)
{
    if (strlen(g_sCvarWitchSound) > 0) EmitSoundToAll(g_sCvarWitchSound);
    if (g_bCvarWitchAnnounce) CPrintToChatAll("%t", "Witch");
}

public Action tmrAliveTankCheck(Handle timer)
{
    if (!g_bAliveTank)
        return Plugin_Continue;

    g_bAliveTank = HasAnyTankAlive();

    return Plugin_Continue;
}

bool IsValidClientIndex(int client)
{
    return (1 <= client <= MaxClients);
}

bool IsValidClient(int client)
{
    return (IsValidClientIndex(client) && IsClientInGame(client));
}

int GetZombieClass(int client)
{
    return (GetEntProp(client, Prop_Send, "m_zombieClass"));
}


bool IsPlayerGhost(int client)
{
    return (GetEntProp(client, Prop_Send, "m_isGhost") == 1);
}

bool IsPlayerIncapacitated(int client)
{
    return (GetEntProp(client, Prop_Send, "m_isIncapacitated") == 1);
}

bool IsPlayerTank(int client)
{
    if (!IsValidClient(client))
        return false;

    if (GetClientTeam(client) != TEAM_INFECTED)
        return false;

    if (GetZombieClass(client) != g_iTankClass)
        return false;

    if (!IsPlayerAlive(client))
        return false;

    if (IsPlayerGhost(client))
        return false;

    return true;
}

bool HasAnyTankAlive()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsPlayerTank(client))
            continue;

        if (IsPlayerIncapacitated(client))
            continue;

        return true;
    }

    return false;
}