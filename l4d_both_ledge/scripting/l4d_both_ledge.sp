#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <left4dhooks>

#define PLUGIN_VERSION			"1.0h-2026/8/29"
#define PLUGIN_NAME			    "l4d_both_ledge"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D1/2] Health Ledge Fix (Ledge Hang)",
	author = "bullet28, Harry",
	description = "When revived from a ledge, you recover the health you had before hanging the ledge",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

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

int g_iLastPerHealth[MAXPLAYERS+1];
float g_fLastTempHealth[MAXPLAYERS+1] = {-1.0, ...};

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar g_hCvarEnable, g_hCvarPerHeath, g_hCvarTempHeath, g_hCvarAbuseFix;
bool g_bCvarEnable, g_bCvarPerHeath, g_bCvarTempHeath, g_bCvarAbuseFix;

public void OnPluginStart() 
{
	g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",        "1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarPerHeath 	= CreateConVar( PLUGIN_NAME ... "_permanent_hp",  "1",   "If 1, Restore perment health survivors had before grabbing the ledge", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarTempHeath 	= CreateConVar( PLUGIN_NAME ... "_temp_hp",  	  "1",   "If 1, Restore temporary health survivors had before grabbing the ledge", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarAbuseFix 	= CreateConVar( PLUGIN_NAME ... "_abuse_fix",  	  "1",   "If 1, Disabling abuse method of receiving free health\nFall from ledge having 1 HP and 0 Temp HP -> revived -> get 30 free temp health", CVAR_FLAGS, true, 0.0, true, 1.0);
	CreateConVar(                       PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                PLUGIN_NAME);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarPerHeath.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTempHeath.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarAbuseFix.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("revive_success", Event_ReviveSucess);
	HookEvent("player_spawn",   Event_PlayerSpawn);
}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarPerHeath = g_hCvarPerHeath.BoolValue;
	g_bCvarTempHeath = g_hCvarTempHeath.BoolValue;
	g_bCvarAbuseFix = g_hCvarAbuseFix.BoolValue;
}

// Left4dhooks API----

public Action L4D_OnLedgeGrabbed(int client)
{
	if (isPlayerAliveSurvivor(client)) 
	{
		g_iLastPerHealth[client] = GetEntProp(client, Prop_Data, "m_iHealth");
		g_fLastTempHealth[client] = L4D_GetTempHealth(client);
	}
}

public void L4D_OnLedgeGrabbed_PostHandled(int client)
{
	g_iLastPerHealth[client] = 0;
	g_fLastTempHealth[client] = -1.0;
}

// Event---

void Event_ReviveSucess(Event event, const char[] name, bool dontBroadcast) 
{
	if(!g_bCvarEnable) return;

	if (!event.GetBool("ledge_hang")) return;
	
	int userid = event.GetInt("subject");
	int client = GetClientOfUserId(userid);
	if(!client || !IsClientInGame(client)) return;

	if (g_iLastPerHealth[client] <= 0 || g_fLastTempHealth[client] < 0.0) return;

	RequestFrame(NextFrame_ReviveSuccess, userid);
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_iLastPerHealth[client] = 0;
	g_fLastTempHealth[client] = -1.0;
}

// Frame----

void NextFrame_ReviveSuccess(int client) 
{
	client = GetClientOfUserId(client);
	if (!isPlayerAliveSurvivor(client)) return;

	int health = GetEntProp(client, Prop_Data, "m_iHealth");

	if(g_bCvarPerHeath && health > 1) // 非1滴血的緩慢走路
	{
		SetEntityHealth(client, g_iLastPerHealth[client]);
	}

	if(g_bCvarTempHeath && g_fLastTempHealth[client] >= 0.0)
	{
		L4D_SetTempHealth(client, g_fLastTempHealth[client]);
	}

	if(g_bCvarAbuseFix && health == 1) //有沒有倒地過都不重要，剩餘一滴實血被救起來會觸發30虛血的bug
	{
		float tempHealth = L4D_GetTempHealth(client);
		if (g_fLastTempHealth[client] > 3.0 && tempHealth <= g_fLastTempHealth[client]) return;
		
		L4D_SetTempHealth(client, 0.0);
	}
}

// Other----

bool isPlayerAliveSurvivor(int client) 
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client);
}