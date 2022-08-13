#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>

#define  PLUGIN_VERSION        "1.4"
#define CVAR_FLAGS FCVAR_NOTIFY
#define DEBUG 0

public Plugin myinfo =
{
        name = "L4D(2) Admin Reserved Slots",
        author = "fenghf & HarryPotter",
        description = "As the name says, you dumb fuck!",
        version = PLUGIN_VERSION,
        url = "https://steamcommunity.com/profiles/76561198026784913/"
};

static char MSG_KICK_REASON[] = "剩餘位子只限管理員.. Sorry, Reserverd Slots for Admin..";

int g_iCvarReservedSlots, g_iMaxplayers;
ConVar L4dtoolzExtension, sv_visiblemaxplayers, g_hCvarReservedSlots, g_hAccess, g_hHideSlots;
char g_sAccessAcclvl[16];
bool g_bHideSlots;
bool g_bHasAcces[MAXPLAYERS+1];

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

public void OnPluginStart()
{
        g_hCvarReservedSlots = CreateConVar("l4d_reservedslots_adm", "1", "Reserved how many slots for Admin. 預留多少位置給管理員加入. (0=關閉 Off)", CVAR_FLAGS, true, 0.0);
        g_hAccess = CreateConVar("l4d_reservedslots_flag", "z", "Players with these flags have access to use admin reserved slots. (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
        g_hHideSlots = CreateConVar("l4d_reservedslots_hide", "1", "If set to 1, reserved slots will hidden (subtracted 'l4d_reservedslots_adm' from the max slot 'sv_maxplayers')", CVAR_FLAGS, true, 0.0, true, 1.0);

        GetCvars();
        g_hCvarReservedSlots.AddChangeHook(ConVarChanged_Cvars);
        g_hAccess.AddChangeHook(ConVarChanged_Cvars);
        g_hHideSlots.AddChangeHook(ConVarChanged_Cvars);

        AutoExecConfig(true, "l4d_reservedslots");

        if (bLate)
        {
                for (int i = 1; i <= MaxClients; i++)
                {
                        if (IsClientInGame(i) && !IsFakeClient(i) && g_iCvarReservedSlots > 0)
                        {
                                if(HasAccess(i, g_sAccessAcclvl)) g_bHasAcces[i] = true;
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

        GetCvars2();
        L4dtoolzExtension.AddChangeHook(ConVarChanged_Cvars2);
        sv_visiblemaxplayers.AddChangeHook(ConVarChanged_Cvars2);
}

public void OnPluginEnd()
{
	/* 	If the plugin has been unloaded, reset visiblemaxplayers. In the case of the server shutting down this effect will not be visible */
	ResetVisibleMax();
}

public void OnMapStart()
{
        CheckHiddenSlots();
}

public void OnConfigsExecuted()
{ 
        CheckHiddenSlots();	
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
        GetCvars();
}

void GetCvars()
{
        g_iCvarReservedSlots = g_hCvarReservedSlots.IntValue;
        g_hAccess.GetString(g_sAccessAcclvl, sizeof(g_sAccessAcclvl));
        g_bHideSlots = g_hHideSlots.BoolValue;
}

public void ConVarChanged_Cvars2(Handle convar, const char[] oldValue, const char[] newValue)
{
        GetCvars();

        CheckHiddenSlots();
}

void GetCvars2()
{
        g_iMaxplayers = L4dtoolzExtension.IntValue;
}

public void OnClientDisconnect_Post(int client)
{
	CheckHiddenSlots();

	g_bHasAcces[client] = false;	
}

public void OnClientPostAdminCheck(int client)
{
        if (IsFakeClient(client) || g_iCvarReservedSlots == 0)
                return;
        
        if(HasAccess(client, g_sAccessAcclvl))
        {
                g_bHasAcces[client] = true;
                return;
        }

        if (IsServerFull(client))
        {
                CreateTimer(0.1, OnTimedKick, client);
        }
}

public Action OnTimedKick(Handle timer, any client)
{	
	if (!client || !IsClientInGame(client))
	{
		return Plugin_Handled;
	}
	
	KickClient(client, MSG_KICK_REASON);
	
	CheckHiddenSlots();
	
	return Plugin_Handled;
}

public bool IsServerFull(int client)
{
        int current = 0;
        int iAccessClient = 0;

        for (int i=1; i<=MaxClients; i++)
        {
                if (i==client) continue;
                if (!IsClientConnected(i)) continue;
                if (!IsClientInGame(i)) continue;
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

public bool HasAccess(int client, const char[] g_sAcclvl)
{
        // no permissions set
        if (strlen(g_sAcclvl) == 0)
                return true;

        else if (StrEqual(g_sAcclvl, "-1"))
                return false;
                
        int iFlag = GetUserFlagBits(client);
        // check permissions
        if ( iFlag & ReadFlagString(g_sAcclvl) || ( iFlag & ADMFLAG_ROOT) )
        {
                #if DEBUG
                        LogMessage("HasAccess %N iFlag: %d, g_sAcclvl: %d, ADMFLAG_ROOT: %d", client, iFlag, ReadFlagString(g_sAcclvl), ADMFLAG_ROOT);
                #endif
                return true;
        }

        return false;
}

void CheckHiddenSlots()
{
        if (g_bHideSlots)
        {
                if(g_iMaxplayers > 0 && g_iCvarReservedSlots > 0) sv_visiblemaxplayers.IntValue = g_iMaxplayers - g_iCvarReservedSlots;
        }
        else
        {
                ResetVisibleMax();
        }
}

void ResetVisibleMax()
{
	sv_visiblemaxplayers.IntValue = -1;
}