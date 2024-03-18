/**
 * 上一回合是旁觀者的玩家，在回合剛開始時繼續維持在旁觀隊伍
 */

#include <sourcemod>
#include <left4dhooks>

#pragma semicolon 1
#pragma newdecls required
#define PLUGIN_VERSION 	"1.0h-2024/2/19"

public Plugin myinfo =
{
    name = "Spectator stays spectator",
    author = "Die Teetasse, Harry",
    description = "Spectator will stay as spectators on mapchange/new round.",
    version = PLUGIN_VERSION,
    url = "https://steamcommunity.com/profiles/76561198026784913/"
};

#define ACTIVE_SECONDS 	120

#define MAX_SPECTATORS 	24
#define STEAMID_LENGTH 	32

float 
    lastTimestamp = 0.0;

Handle 
    spectatorTimer[MAXPLAYERS+1];

bool 
    g_bCheckStart,
    g_bRoundEnd;

int 
    g_iRoundStart, g_iPlayerSpawn;

StringMap
    g_smSpectatorList;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if (test != Engine_Left4Dead && test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success;
}

public void OnPluginStart() 
{
    HookEvent("round_start",            Event_RoundStart);
    HookEvent("player_spawn",           Event_PlayerSpawn);
    HookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy); //trigger twice in versus/survival/scavenge mode, one when all survivors wipe out or make it to saferom, one when first round ends (second round_start begins).
    HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //1. all survivors make it to saferoom in and server is about to change next level in coop mode (does not trigger round_end), 2. all survivors make it to saferoom in versus
    HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
    HookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy); //final map final rescue vehicle leaving  (does not trigger round_end)
    HookEvent("player_team",            Event_PlayerTeam);

    AddCommandListener(ServerCmd_changelevel, "changelevel");

    delete g_smSpectatorList;
    g_smSpectatorList = new StringMap();
}

//Sourcemod API Forward-------------------------------

public void OnClientPutInServer(int client)
{
    if(!g_bCheckStart) return;

    if (IsFakeClient(client)) return;

    float currentTimestamp = GetEngineTime();
    if (currentTimestamp - lastTimestamp > ACTIVE_SECONDS) return;
    
    delete spectatorTimer[client];
    spectatorTimer[client] = CreateTimer(1.0, Timer_MoveToSpec, client, TIMER_REPEAT);
}

public void OnClientDisconnect(int client)
{
    delete spectatorTimer[client];
} 

public void OnMapEnd()
{
    ClearDefault();
    ResetTimer();
    g_bCheckStart = false;
    g_bRoundEnd = false;
}

//Event-------------------------------

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
        CreateTimer(0.5, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
    g_iRoundStart = 1;

    g_bCheckStart = false;
    g_bRoundEnd = false;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
    if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
        CreateTimer(0.5, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
    g_iPlayerSpawn = 1;	
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
 {
    ClearDefault();
    ResetTimer();
    if(g_bRoundEnd) return;
    g_bRoundEnd = true;

    delete g_smSpectatorList;
    g_smSpectatorList = new StringMap();
    static char sSteamID[64];
    for(int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        if (IsFakeClient(i)) continue;

        GetClientAuthId(i, AuthId_SteamID64, sSteamID, sizeof(sSteamID));
        if (GetClientTeam(i) > 1)
        {
            g_smSpectatorList.SetValue(sSteamID, false);
        }
        else
        {
            g_smSpectatorList.SetValue(sSteamID, true);
        }
    }
}

void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast) 
{
    if(!g_bRoundEnd) return;

    int userid = event.GetInt("userid");
    CreateTimer(0.1, PlayerChangeTeamCheck, userid);//延遲一秒檢查
}

//Timer-------------------------------

Action Timer_PluginStart(Handle timer)
{
    ClearDefault();

    g_bCheckStart = true;
    lastTimestamp = GetEngineTime();

    for(int i = 1; i <= MaxClients; i++)
    {
        if (!IsClientInGame(i)) continue;
        if (IsFakeClient(i)) continue;

        delete spectatorTimer[i];
        spectatorTimer[i] = CreateTimer(1.0, Timer_MoveToSpec, i, TIMER_REPEAT);
    }

    return Plugin_Continue;
}

Action Timer_Respectate(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client && IsClientInGame(client))
		ChangeClientTeam(client, 1);

	return Plugin_Continue;
}

Action Timer_MoveToSpec(Handle timer, int client) 
{
    if (!IsClientInGame(client))
    {
        spectatorTimer[client] = null;
        return Plugin_Stop;
    }

    static char sSteamID[64];
    GetClientAuthId(client, AuthId_SteamID64, sSteamID, sizeof(sSteamID));
    
    bool bSpectator;
    if(g_smSpectatorList.GetValue(sSteamID, bSpectator) && bSpectator)
    {
        if (GetClientTeam(client) == 1)
        {
            CreateTimer(2.0, ReSpec, GetClientUserId(client));

            spectatorTimer[client] = null;
            return Plugin_Stop;
        }

        if(IsClientIdle(client))
        {
            L4D_TakeOverBot(client);
        }

        ChangeClientTeam(client, 1);
        CreateTimer(2.0, ReSpec, GetClientUserId(client));
        //PrintToChatAll("[SM] Found %s in %s team. Moved him back to spec team.", name, (team == 2) ? "survivor" : "infected"); 
    }

    return Plugin_Continue;
}

Action ReSpec(Handle timer, int userid)
{
    int client = GetClientOfUserId(userid);
    if (client && IsClientInGame(client) && GetClientTeam(client) == 1) 
    {
        if(IsClientIdle(client))
        {
            L4D_TakeOverBot(client);
            ChangeClientTeam(client, 1);
        }
        else
        {
            if(L4D_HasPlayerControlledZombies())
            {
                ChangeClientTeam(client, 3);
                CreateTimer(0.1, Timer_Respectate, userid, TIMER_FLAG_NO_MAPCHANGE);
            }
        }
    }

    return Plugin_Continue;
}

Action PlayerChangeTeamCheck(Handle timer, int userid)
{
    if(!g_bRoundEnd) return Plugin_Continue;

    int client = GetClientOfUserId(userid);
    if (client && IsClientInGame(client) && !IsFakeClient(client))
    {
        static char sSteamID[64];
        GetClientAuthId(client, AuthId_SteamID64, sSteamID, sizeof(sSteamID));
        if (GetClientTeam(client) > 1)
        {
            g_smSpectatorList.SetValue(sSteamID, false);
        }
        else
        {
            g_smSpectatorList.SetValue(sSteamID, true);
        }
    }

    return Plugin_Continue;
}

//Function-------------------------------

bool IsClientIdle(int client)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			if(HasEntProp(i, Prop_Send, "m_humanSpectatorUserID"))
			{
				if(GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID")) == client)
						return true;
			}
		}
	}

	return false;
}

void ClearDefault()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

void ResetTimer()
{
    for (int i = 1; i <= MaxClients; i++) 
    {
        delete spectatorTimer[i];
    }
}

/**
 * 當控制台輸入changelevel時
 * 投票換圖或重新章節 也會有changelevel xxxxx (xxxxx is map name)
 * 管理員!admin->換圖 也會有changelevel xxxxx (xxxxx is map name)
 * 插件使用 ServerCommand("changelevel %s", ..... 也會有changelevel xxxxx (xxxxx is map name)
 * 插件使用 ForceChangeLevel("xxxxxx", ..... 也會有changelevel xxxxx (xxxxx is map name)
 */
Action ServerCmd_changelevel(int client, const char[] command, int argc)
{
    if(client == 0)
    {
        delete g_smSpectatorList;
        g_smSpectatorList = new StringMap();

        static char sSteamID[64];
        for(int i = 1; i <= MaxClients; i++)
        {
            if (!IsClientInGame(i)) continue;
            if (IsFakeClient(i)) continue;

            GetClientAuthId(i, AuthId_SteamID64, sSteamID, sizeof(sSteamID));
            if (GetClientTeam(i) > 1)
            {
                g_smSpectatorList.SetValue(sSteamID, false);
            }
            else
            {
                g_smSpectatorList.SetValue(sSteamID, true);
            }
        }
    }

    return Plugin_Continue;
}