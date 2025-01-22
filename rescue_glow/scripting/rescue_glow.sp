#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION	"1.0h-2024/8/15"
#define PLUGIN_NAME		"rescue_glow"
#define DEBUG 0

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "little_froy, Harry",
	description = "Fixed sometimes glow is invisible when dead survivors appears in rescue closet",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=348762"
};

GlobalForward Forward_OnAdded;
GlobalForward Forward_OnRemoved;

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int err_max)
{
    if(GetEngineVersion() != Engine_Left4Dead2)
    {
        strcopy(error, err_max, "this plugin only runs in \"Left 4 Dead 2\"");
        return APLRes_SilentFailure;
    }

    Forward_OnAdded = new GlobalForward("RescueGlow_OnAdded", ET_Ignore, Param_Cell);
    Forward_OnRemoved = new GlobalForward("RescueGlow_OnRemoved", ET_Ignore, Param_Cell);
    CreateNative("RescueGlow_HasGlow", native_RescueGlow_HasGlow);
    RegPluginLibrary(PLUGIN_NAME);

    return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define ENTITY_SAFE_LIMIT 2000

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

ConVar g_hCvarEnable, g_hCvarColor, g_hCvarFlash;
bool g_bCvarEnable, g_bCvarFlash;
int g_iCvarColor;

bool 
    g_bAdded[MAXPLAYERS+1];

int 
    g_iRescueEntityRef[MAXPLAYERS+1];

//Handle
//   g_hCheckTimer[MAXPLAYERS+1];

public void OnPluginStart()
{
    g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",          "1",            "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarColor        = CreateConVar( PLUGIN_NAME ... "_color",           "255 102 0",    "Color of survivor glow in rescue closet, Three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue.", CVAR_FLAGS);
    g_hCvarFlash        = CreateConVar( PLUGIN_NAME ... "_flash",           "1",            "If 1, Glow will be flashing", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                       PLUGIN_NAME ... "_version",         PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                PLUGIN_NAME);

    GetCvars();
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarColor.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarFlash.AddChangeHook(ConVarChanged_Cvars);

    HookEvent("player_spawn", event_player_spawn);
    HookEvent("player_team", event_player_team);
    HookEvent("player_death", event_player_death);
    HookEvent("round_start", event_round_start);
    HookEvent("survivor_call_for_help", survivor_call_for_help);
    HookEvent("survivor_rescue_abandoned", survivor_rescue_abandoned);
}

public void OnPluginEnd()
{
    ResetAllGlow();
}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarEnable = g_hCvarEnable.BoolValue;

    char sColor[16];
    g_hCvarColor.GetString(sColor, sizeof(sColor));
    g_iCvarColor = GetColor(sColor);
    g_bCvarFlash = g_hCvarFlash.BoolValue;
}

//Sourcemod API Forward-------------------------------

public void OnMapEnd()
{
    ResetAllGlow();
}
/*
public void OnClientDisconnect(int client)
{
    if(!IsClientInGame(client)) return;

    delete g_hCheckTimer[client];
} 
*/
// Event-------------------------------

void survivor_call_for_help(Event event, const char[] name, bool dontBroadcast)
{
    if(!g_bCvarEnable) return;

    int client = GetClientOfUserId(event.GetInt("userid"));
    if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVOR && !IsPlayerAlive(client))
    {
        int info_survivor_rescue = event.GetInt("subject");
        if(GetEntPropEnt(info_survivor_rescue, Prop_Send, "m_survivor") != client) return;
        //PrintToChatAll("survivor_call_for_help: %N,  info_survivor_rescue: %d", client, info_survivor_rescue);

        if(!g_bAdded[client])
        {
            g_bAdded[client] = true;
            set_glow(client, 3, g_iCvarColor, _, _, g_bCvarFlash);

            Call_StartForward(Forward_OnAdded);
            Call_PushCell(client);
            Call_Finish();
        }

        g_iRescueEntityRef[client] = EntIndexToEntRef(info_survivor_rescue);

        /*delete g_hCheckTimer[client];
        DataPack hPack;
        g_hCheckTimer[client] = CreateDataTimer(1.0, Timer_CheckIfSurInRescue, hPack, TIMER_REPEAT);
        hPack.WriteCell(event.GetInt("userid"));
        hPack.WriteCell(client);
        hPack.WriteCell(EntIndexToEntRef(info_survivor_rescue));*/
    }
}

void survivor_rescue_abandoned(Event event, const char[] name, bool dontBroadcast)
{
    if(!g_bCvarEnable) return;

    //PrintToChatAll("survivor_rescue_abandoned");
    
    RequestFrame(NextFrame_survivor_rescue_abandoned);
}

void event_player_spawn(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(event.GetInt("userid"));
    if(client)
    {
        //delete g_hCheckTimer[client];
        RemoveModelGlow(client);
    }
}

void event_player_team(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client)
	{
        //delete g_hCheckTimer[client];
        RemoveModelGlow(client);
	}
}

void event_player_death(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client)
	{
        //delete g_hCheckTimer[client];
        RemoveModelGlow(client);
	}
}

void event_round_start(Event event, const char[] name, bool dontBroadcast)
{
    ResetAllGlow();
}

any native_RescueGlow_HasGlow(Handle plugin, int numParams)
{
    return g_bAdded[GetNativeCell(1)];
}

// Timer-----------

void NextFrame_survivor_rescue_abandoned()
{
    int info_survivor_rescue;
    for(int player = 1; player <= MaxClients; player++)
    {
        if(IsClientInGame(player) && g_iRescueEntityRef[player] && (info_survivor_rescue = EntRefToEntIndex(g_iRescueEntityRef[player])) != INVALID_ENT_REFERENCE)
        {
            if(GetEntPropEnt(info_survivor_rescue, Prop_Send, "m_survivor") == player) continue;
        }

        //delete g_hCheckTimer[player];
        RemoveModelGlow(player);
    }
}

/*Action Timer_CheckIfSurInRescue(Handle timer, DataPack hPack)
{
    hPack.Reset();
    int client = GetClientOfUserId(hPack.ReadCell());
    int index = hPack.ReadCell();
    int info_survivor_rescue = EntRefToEntIndex(hPack.ReadCell());

    if( info_survivor_rescue != INVALID_ENT_REFERENCE 
        && GetEntPropEnt(info_survivor_rescue, Prop_Send, "m_survivor") == client
        && client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVOR && !IsPlayerAlive(client))
    {
        return Plugin_Continue;
    }

    RemoveModelGlow(index);
    g_hCheckTimer[index] = null;
    return Plugin_Stop;
}*/

// Others-------------------------------

/*bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE)
		return true;
	return false;
}*/

void RemoveModelGlow(int client)
{
    g_iRescueEntityRef[client] = 0;
    if(g_bAdded[client] && IsClientInGame(client))
    {
        set_glow(client);

        Call_StartForward(Forward_OnRemoved);
        Call_PushCell(client);
        Call_Finish();
    }

    g_bAdded[client] = false;
}

void set_glow(int entity, int type = 0, const int color = 0, int range = 0, int range_min = 0, bool flash = false)
{
    SetEntProp(entity, Prop_Send, "m_iGlowType", type);
    SetEntProp(entity, Prop_Send, "m_glowColorOverride", color);
    SetEntProp(entity, Prop_Send, "m_nGlowRange", range);
    SetEntProp(entity, Prop_Send, "m_nGlowRangeMin", range_min);
    SetEntProp(entity, Prop_Send, "m_bFlashing", flash);
}

void ResetAllGlow()
{
    for(int i = 1; i <= MaxClients; i++)
    {
        //delete g_hCheckTimer[i];
        RemoveModelGlow(i);
    }
}

int GetColor(char[] sTemp)
{
	if( StrEqual(sTemp, "") )
		return 0;

	char sColors[3][4];
	int color = ExplodeString(sTemp, " ", sColors, 3, 4);

	if( color != 3 )
		return 0;

	color = StringToInt(sColors[0]);
	color += 256 * StringToInt(sColors[1]);
	color += 65536 * StringToInt(sColors[2]);

	return color;
}