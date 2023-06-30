#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>

#define PLUGIN_VERSION        "1.5-2023/7/1"
#define PLUGIN_NAME			  "l4d_reservedslots"
#define DEBUG 0

public Plugin myinfo =
{
    name = "[L4D1/L4D2] Admin Reserved Slots",
    author = "HarryPotter",
    description = "As the name says, you dumb fuck!",
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

#define TRANSLATION_FILE		PLUGIN_NAME ... ".phrases"

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

int g_iCvarReservedSlots, g_iMaxplayers;
ConVar L4dtoolzExtension, sv_visiblemaxplayers, g_hCvarReservedSlots, g_hAccess, g_hHideSlots;
char g_sAccessAcclvl[16];
bool g_bHideSlots;
bool g_bHasAcces[MAXPLAYERS+1];

public void OnPluginStart()
{
    LoadTranslations(TRANSLATION_FILE);

    g_hCvarReservedSlots    = CreateConVar( PLUGIN_NAME ... "_adm",         "1", "Reserved how many slots for Admin. (0=Off)", CVAR_FLAGS, true, 0.0);
    g_hAccess               = CreateConVar( PLUGIN_NAME ... "_flag",        "z", "Players with these flags have access to use admin reserved slots. (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hHideSlots            = CreateConVar( PLUGIN_NAME ... "_hide",        "0", "If set to 1, reserved slots will be hidden (slot display = sv_maxplayers - l4d_reservedslots_adm)", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                           PLUGIN_NAME ... "_version",     PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                    PLUGIN_NAME);

    GetCvars();
    g_hCvarReservedSlots.AddChangeHook(ConVarChanged_Cvars);
    g_hAccess.AddChangeHook(ConVarChanged_Cvars);
    g_hHideSlots.AddChangeHook(ConVarChanged_Cvars);

    if (bLate && g_iCvarReservedSlots > 0)
    {
        char steamid[32];
        for (int i = 1; i <= MaxClients; i++)
        {
            if (IsClientConnected(i) && !IsFakeClient(i))
            {
                if(GetClientAuthId(i, AuthId_Steam2, steamid, sizeof(steamid)) == false) continue;
                
                if(HasAccess(steamid, g_sAccessAcclvl)) g_bHasAcces[i] = true;
            }
        }
    }
}

public void OnAllPluginsLoaded()
{
    L4dtoolzExtension = FindConVar("sv_maxplayers");
    if(L4dtoolzExtension == null)
            SetFailState("Could not find ConVar \"sv_maxplayers\". Go to install L4dtoolz: https://github.com/Accelerator74/l4dtoolz/releases");

    sv_visiblemaxplayers = FindConVar("sv_visiblemaxplayers");
    if(sv_visiblemaxplayers == null)
            SetFailState("Could not find ConVar \"sv_visiblemaxplayers\".");

    GetOfficialCvars();
    L4dtoolzExtension.AddChangeHook(ConVarChanged_OfficialCvars);
    sv_visiblemaxplayers.AddChangeHook(ConVarChanged_OfficialCvars);
}

bool bOnPluginEnd = false;
public void OnPluginEnd()
{
    bOnPluginEnd = true;
    sv_visiblemaxplayers.RestoreDefault();
}

public void OnMapStart()
{
    CheckHiddenSlots();
}

public void OnConfigsExecuted()
{ 
    CheckHiddenSlots();	
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
    if(bOnPluginEnd) return;

    GetCvars();
    CheckHiddenSlots();
}

void ConVarChanged_OfficialCvars(Handle convar, const char[] oldValue, const char[] newValue)
{
    if(bOnPluginEnd) return;

    GetOfficialCvars();
    CheckHiddenSlots();
}

void GetCvars()
{
    g_iCvarReservedSlots = g_hCvarReservedSlots.IntValue;
    g_hAccess.GetString(g_sAccessAcclvl, sizeof(g_sAccessAcclvl));
    g_bHideSlots = g_hHideSlots.BoolValue;
}

void GetOfficialCvars()
{
    g_iMaxplayers = L4dtoolzExtension.IntValue;
}

public void OnClientDisconnect_Post(int client)
{
    CheckHiddenSlots();

    g_bHasAcces[client] = false;	
}

public void OnClientConnected(int client)
{
    if (g_iCvarReservedSlots == 0)
        return;

    CreateTimer(3.0, Timer_OnClientConnected, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_OnClientConnected(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (!client || !IsClientConnected(client) || IsFakeClient(client)) return Plugin_Continue;

    static char steamid[32];
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

    if(HasAccess(steamid, g_sAccessAcclvl))
    {
        g_bHasAcces[client] = true;
        return Plugin_Continue;
    }

    if (IsServerFull(client))
    {
        CreateTimer(0.1, OnTimedKick, GetClientUserId(client));
    }

    return Plugin_Continue;
}

Action OnTimedKick(Handle timer, any userid)
{	
    int client = GetClientOfUserId(userid);

    if (!client || !IsClientConnected(client) || IsFakeClient(client)) return Plugin_Continue;
    
    char sMessage[64];
    FormatEx(sMessage, sizeof(sMessage), "%T", "Message", client);
    KickClient(client, sMessage);
    
    CheckHiddenSlots();
    
    return Plugin_Handled;
}

bool IsServerFull(int client)
{
    int current = 0;
    int iAccessClient = 0;

    for (int i=1; i<=MaxClients; i++)
    {
        if (i==client) continue;
        if (!IsClientConnected(i)) continue;
        if (IsFakeClient(i)) continue;
        if (g_bHasAcces[i]) iAccessClient++;
        
        current++;
    }
    #if DEBUG
        LogMessage("Current: %d - ReservedSlots: %d - MaxPlayer: %d, iAccessClient: %d", current, g_iCvarReservedSlots, g_iMaxplayers, iAccessClient);
    #endif
    if (iAccessClient >= g_iCvarReservedSlots) return false;
    if (current + g_iCvarReservedSlots >= g_iMaxplayers) return true;

    return false;
}

bool HasAccess(char[] steamid, char[] g_sAcclvl)
{
	// no permissions set
	if (strlen(g_sAcclvl) == 0)
		return true;

	else if (StrEqual(g_sAcclvl, "-1"))
		return false;

	// check permissions
	AdminId id = FindAdminByIdentity(AUTHMETHOD_STEAM, steamid);
	if(id == INVALID_ADMIN_ID) return false;

	int flag = id.GetFlags(Access_Real);
	if ( flag & ReadFlagString(g_sAcclvl) || flag & ADMFLAG_ROOT)
	{
		return true;
	}

	return false;
}

void CheckHiddenSlots()
{
    if (g_bHideSlots)
    {
        if(g_iMaxplayers > 0 && g_iCvarReservedSlots > 0) sv_visiblemaxplayers.SetInt(g_iMaxplayers - g_iCvarReservedSlots);
    }
    else
    {
        ResetVisibleMax();
    }
}

void ResetVisibleMax()
{
    sv_visiblemaxplayers.SetInt(-1);
}