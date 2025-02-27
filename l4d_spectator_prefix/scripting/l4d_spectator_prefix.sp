#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>

public Plugin myinfo = 
{
	name = "Spectator Prefix",
	author = "Nana & Harry Potter",
	description = "when player in spec team, add prefix",
	version = "1.4-2025/2/27",
	url = "https://steamcommunity.com/profiles/76561198026784913"
};

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead && test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	bLate = late;
	return APLRes_Success; 
}

#define TEAM_SPECTATOR 1
#define CVAR_FLAGS			FCVAR_NOTIFY


ConVar g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hPrefixType;
ConVar g_hCvarMPGameMode;
char g_sPrefixType[32];

bool 
	g_bCvarAllow, g_bMapStarted,
	g_bPostAdminCheck[MAXPLAYERS+1],
	g_bPlayerCanChangedName[MAXPLAYERS+1];

Handle 
	g_hCheckPlayersTimer,
	g_hPlayerChangedNameTimer[MAXPLAYERS+1];

public void OnPluginStart()
{
	g_hCvarAllow 	= CreateConVar(	"l4d_spectator_prefix_allow",			"1",	"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarModes 	= CreateConVar( "l4d_spectator_prefix_modes",			"",		"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff = CreateConVar( "l4d_spectator_prefix_modes_off",		"",		"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog = CreateConVar( "l4d_spectator_prefix_modes_tog",   	"0",	"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hPrefixType 	= CreateConVar( "l4d_spectator_prefix_type", 			"(S)",  "Determine your preferred type of Spectator Prefix", CVAR_FLAGS);

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hPrefixType.AddChangeHook(ConVarChanged_PrefixType);

	AutoExecConfig(true, "l4d_spectator_prefix");

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

        OnClientPostAdminCheck(client);
    }
}

public void OnPluginEnd()
{
	RemoveAllClientPrefix();
}

public void OnMapStart()
{
	g_bMapStarted = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	delete g_hCheckPlayersTimer;
}

public void OnClientPostAdminCheck(int client)
{
	if(IsFakeClient(client)) return;

	delete g_hPlayerChangedNameTimer[client];
	g_hPlayerChangedNameTimer[client] = CreateTimer(3.0, Timer_OnPostAdminCheck, client);
}

public void OnClientDisconnect(int client)
{
	if(IsFakeClient(client)) return;

	delete g_hPlayerChangedNameTimer[client];
	g_bPostAdminCheck[client] = false;
	g_bPlayerCanChangedName[client] = false;
}

public void OnConfigsExecuted()
{
	IsAllowed();

	if(g_bCvarAllow)
	{
		delete g_hCheckPlayersTimer;
		g_hCheckPlayersTimer = CreateTimer(1.0, Timer_CheckPlayers, _, TIMER_REPEAT);
	}
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_PrefixType(ConVar convar, const char[] oldValue, const char[] newValue)
{
	RemoveAllClientPrefix();
	GetCvars();
}

void GetCvars()
{
	g_hPrefixType.GetString(g_sPrefixType, sizeof(g_sPrefixType));
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		g_bCvarAllow = true;

		HookEvent("player_changename", Event_NameChanged_Post, EventHookMode_Post);

		delete g_hCheckPlayersTimer;
		g_hCheckPlayersTimer = CreateTimer(1.0, Timer_CheckPlayers, _, TIMER_REPEAT);
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		g_bCvarAllow = false;

		UnhookEvent("player_changename", Event_NameChanged_Post, EventHookMode_Post);

		delete g_hCheckPlayersTimer;

		RemoveAllClientPrefix();
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_bMapStarted == false )
		return false;

	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	g_iCurrentMode = 0;

	int entity = CreateEntityByName("info_gamemode");
	if( IsValidEntity(entity) )
	{
		DispatchSpawn(entity);
		HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "PostSpawnActivate");
		if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
			RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
	}

	if( iCvarModesTog != 0 )
	{
		if( g_iCurrentMode == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentMode) )
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModes.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 4;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 8;
}

//event
void Event_NameChanged_Post(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(!client || !IsClientInGame(client) || IsFakeClient(client)) return;
	if(!g_bPostAdminCheck[client]) return;

	char oldname[256];
	event.GetString("oldname", oldname, sizeof(oldname));
	char newname[256];
	event.GetString("newname", newname, sizeof(newname));

	if(strcmp(oldname, newname, false) == 0) return;

	g_bPlayerCanChangedName[client] = false;

	delete g_hPlayerChangedNameTimer[client];
	g_hPlayerChangedNameTimer[client] = CreateTimer(1.5, Timer_ChangedNameCheck, client);
}

//timer

Action Timer_OnPostAdminCheck(Handle timer, int client)
{
	g_hPlayerChangedNameTimer[client] = null;

	if(IsClientInGame(client) && !IsFakeClient(client))
	{
		g_bPostAdminCheck[client] = true;
		g_bPlayerCanChangedName[client] = true;
	}

	return Plugin_Continue;
}

Action Timer_ChangedNameCheck(Handle timer, int client)
{
	g_hPlayerChangedNameTimer[client] = null;

	if(IsClientInGame(client) && !IsFakeClient(client))
	{
		g_bPlayerCanChangedName[client] = true;
	}

	return Plugin_Continue;
}

Action Timer_CheckPlayers(Handle timer)
{
	char sOldname[256], sNewname[256];
	for(int player = 1; player <= MaxClients; player++)
	{
		if(!IsClientInGame(player)) continue;
		if(IsFakeClient(player)) continue;
		if(g_bPlayerCanChangedName[player] == false) continue;

		GetClientName(player, sOldname, sizeof(sOldname));
		if(GetClientTeam(player) == TEAM_SPECTATOR)
		{
			if(!CheckClientHasPreFix(sOldname))
			{
				Format(sNewname, sizeof(sNewname), "%s%s", g_sPrefixType, sOldname);
				CS_SetClientName(player, sNewname);
			}
		}
		else
		{
			if(CheckClientHasPreFix(sOldname))
			{
				ReplaceString(sOldname, sizeof(sOldname), g_sPrefixType, "", true);
				strcopy(sNewname,sizeof(sOldname),sOldname);
				CS_SetClientName(player, sNewname);
				
				//PrintToChatAll("sNewname: %s",sNewname);
			}
		}
	}

	return Plugin_Continue;
}

//function
stock bool IsClientAndInGame(int index)
{
	if (index > 0 && index <= MaxClients)
	{
		return IsClientInGame(index);
	}
	return false;
}

bool CheckClientHasPreFix(const char[] sOldname)
{
	return (strncmp(sOldname, g_sPrefixType, strlen(g_sPrefixType)) == 0);
}

void CS_SetClientName(int client, const char[] name)
{
    SetClientInfo(client, "name", name); //不會觸發 "player_changename"
    SetEntPropString(client, Prop_Data, "m_szNetname", name); //不會觸發 "player_changename"
}

void RemoveAllClientPrefix()
{
	char sOldname[256],sNewname[256];
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			GetClientName(i, sOldname, sizeof(sOldname));
			if(CheckClientHasPreFix(sOldname))
			{
				ReplaceString(sOldname, sizeof(sOldname), g_sPrefixType, "", true);
				strcopy(sNewname,sizeof(sOldname),sOldname);
				CS_SetClientName(i, sNewname);
			}
		}
	}
}