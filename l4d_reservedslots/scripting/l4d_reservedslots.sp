#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>

#define PLUGIN_VERSION        "1.8-2023/8/18"
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

#define TRANSLATION_FILE		PLUGIN_NAME ... ".phrases"

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar L4dtoolzExtension, sv_visiblemaxplayers;

ConVar g_hCvarReservedSlots, g_hAccess, g_hHideSlots;
int g_iCvarReservedSlots;
char g_sAccessAcclvl[AdminFlags_TOTAL];
bool g_bHideSlots;

bool 
    g_bHasAcces[MAXPLAYERS+1],
    g_bCvarHookBlocked;

int 
    g_iCfgMaxPlayers;

public void OnPluginStart()
{
    LoadTranslations(TRANSLATION_FILE);

    g_hCvarReservedSlots    = CreateConVar( PLUGIN_NAME ... "_adm",         "1", "Admin reserved slots. (0=Off)", CVAR_FLAGS, true, 0.0);
    g_hAccess               = CreateConVar( PLUGIN_NAME ... "_flag",        "z", "Players with these flags have access to use admin reserved slots. (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hHideSlots            = CreateConVar( PLUGIN_NAME ... "_hide",        "1", "If 1, display maxplayers only on server status (reserved slots will be hidden)\nIf 0, display maxplayers + reserved slots on server status", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                           PLUGIN_NAME ... "_version",     PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                    PLUGIN_NAME);

    GetCvars();
    g_hCvarReservedSlots.AddChangeHook(ConVarChanged_Cvars);
    g_hAccess.AddChangeHook(ConVarChanged_Cvars);
    g_hHideSlots.AddChangeHook(ConVarChanged_Cvars);

    HookEvent("player_connect", player_connect);
}

public void OnAllPluginsLoaded()
{
    L4dtoolzExtension = FindConVar("sv_maxplayers");
    if(L4dtoolzExtension == null)
        SetFailState("Could not find ConVar \"sv_maxplayers\". Go to install L4dtoolz: https://github.com/fbef0102/l4dtoolz");

    sv_visiblemaxplayers = FindConVar("sv_visiblemaxplayers");
    if(sv_visiblemaxplayers == null)
        SetFailState("Could not find ConVar \"sv_visiblemaxplayers\". Go to install L4dtoolz: https://github.com/fbef0102/l4dtoolz");

    g_iCfgMaxPlayers = L4dtoolzExtension.IntValue;
    L4dtoolzExtension.AddChangeHook(ConVarChanged_OfficialCvars);
}

bool bOnPluginEnd = false;
public void OnPluginEnd()
{
    bOnPluginEnd = true;
    //L4dtoolzExtension.SetInt(g_iCfgMaxPlayers);
    //sv_visiblemaxplayers.SetInt(g_iCfgMaxPlayers);
}

public void OnMapStart()
{
    SetHiddenSlots();
}

public void OnConfigsExecuted()
{ 
    SetHiddenSlots();	
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
    if(bOnPluginEnd) return;

    GetCvars();
    SetHiddenSlots();
}

void ConVarChanged_OfficialCvars(Handle convar, const char[] oldValue, const char[] newValue)
{
    if(bOnPluginEnd || g_bCvarHookBlocked) return;

    g_iCfgMaxPlayers = L4dtoolzExtension.IntValue;
    SetHiddenSlots();
}

void GetCvars()
{
    g_iCvarReservedSlots = g_hCvarReservedSlots.IntValue;
    g_hAccess.GetString(g_sAccessAcclvl, sizeof(g_sAccessAcclvl));
    g_bHideSlots = g_hHideSlots.BoolValue;
}

// 換圖會觸發
//public void OnClientConnected(int client)
//{
//    g_bHasAcces[client] = false;
//}

// 換圖會觸發
public void OnClientDisconnect_Post(int client)
{
    SetHiddenSlots();

    g_bHasAcces[client] = false;	
}

// 換圖不觸發
void player_connect(Event event, const char[] name, bool dontBroadcast) 
{
    int userid = event.GetInt("userid");

    CreateTimer(GetRandomFloat(2.0, 3.5), Timer_OnClientConnected, userid, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_OnClientConnected(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (!client || !IsClientConnected(client) || IsFakeClient(client)) return Plugin_Continue;
    //LogMessage("%N Timer_OnClientConnected", client);

    static char steamid[32];
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));

    if(g_bHasAcces[client] || HasAccess(steamid, g_sAccessAcclvl))
    {
        g_bHasAcces[client] = true;
        return Plugin_Continue;
    }

    if (IsServerFull(client))
    {
        CreateTimer(GetRandomFloat(0.1, 1.0), OnTimedKick, GetClientUserId(client));
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
    
    SetHiddenSlots();
    
    return Plugin_Handled;
}

bool IsServerFull(int client)
{
    int current = 1; //client
    int iAccessClient = 0;

    static char steamid[32];
    for (int i=1; i<=MaxClients; i++)
    {
        if (i==client) continue;
        if (!IsClientConnected(i)) continue;
        if (IsFakeClient(i)) continue;
        if (g_bHasAcces[i]) iAccessClient++;

        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        if(HasAccess(steamid, g_sAccessAcclvl))
        {
            g_bHasAcces[i] = true;
            iAccessClient++;
        }
         
        current++;
    }
    #if DEBUG
        LogMessage("Current: %d - ReservedSlots: %d - MaxPlayer: %d, iAccessClient: %d", current, g_iCvarReservedSlots, g_iCfgMaxPlayers, iAccessClient);
    #endif
    //if (iAccessClient >= g_iCvarReservedSlots) return false;
    if (current> g_iCfgMaxPlayers) return true;

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

void SetHiddenSlots()
{
    g_bCvarHookBlocked = true;

    if(g_iCfgMaxPlayers > 0 && g_iCvarReservedSlots > 0)
    {
        int iFinalSlot = (g_iCfgMaxPlayers + g_iCvarReservedSlots >= 31) ? 31 : g_iCfgMaxPlayers + g_iCvarReservedSlots;

        L4dtoolzExtension.SetInt( iFinalSlot );
        if (g_bHideSlots)
        {
            sv_visiblemaxplayers.SetInt( g_iCfgMaxPlayers );
        }
        else
        {
            sv_visiblemaxplayers.SetInt( iFinalSlot );
        }
    }

    g_bCvarHookBlocked = false;
}