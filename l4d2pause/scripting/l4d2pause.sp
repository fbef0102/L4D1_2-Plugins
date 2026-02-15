#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <basecomm>
#include <multicolors>
#define PLUGIN_VERSION "1.7-2025/9/11"

public Plugin myinfo =
{
	name = "[L4D1/2] Admin Force Pause",
	author = "pvtschlag, Harry",
	description = "Allows admins to force the game to pause, only adm can unpause the game.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if(test != Engine_Left4Dead2 && test != Engine_Left4Dead)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

#define	PRIVAT_TRIGGER	"/"

ConVar g_hForceOnly;
ConVar g_hPausable;
bool g_bIsPaused = false;
bool g_bIsUnpausing = false;
bool g_bPauseRequest[2] = { false, false };
int g_iPauseAdmin;

public void OnPluginStart()
{
	LoadTranslations("l4d2pause.phrases");
	g_hForceOnly = CreateConVar("l4d2pause_forceonly", "1", "Only allow the game to be paused by the forcepause command(Admin only).", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig(true, "l4d2pause"); //Create and/or load the plugin config

	g_hPausable = FindConVar("sv_pausable");
	SetConVarInt(g_hPausable, 0);

	HookEvent("player_disconnect", Event_PlayerDisconnect);
	HookEvent("player_say", Event_PlayerSay, EventHookMode_Post);

	RegConsoleCmd("unpause", Command_Unpause);
	RegAdminCmd("sm_forcepause", Command_SMForcePause, ADMFLAG_ROOT, "Adm forces the game to pause/unpause");

	//AddCommandListener(Say_Command, "say");
	//AddCommandListener(SayTeam_Command, "say_team");

}

//ConVar g_hNoTeamSayPlugin = null;
//public void OnAllPluginsLoaded()
//{
//	// lfd_noTeamSay
//	g_hNoTeamSayPlugin = FindConVar("noteamsay_ignorelist");
//}

public void OnMapStart()
{
	g_bIsPaused = false;
}

public void OnMapEnd()
{
	ResetPauseRequest(); //Reset any pause requests
}

public void OnClientPutInServer(int client)
{
	if (g_bIsPaused)
	{
		if (!IsFakeClient(client))
		{
			CPrintToChatAll("%t", "Pause_1", client);
			SetEntPropFloat(client, Prop_Data, "m_fLastPlayerTalkTime", 0.0);
		}
	}
}

Action Command_Unpause(int client, int args)
{
	if (g_bIsPaused)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

Action Command_SMForcePause(int client, int args)
{
	if(g_hForceOnly.BoolValue == false) return Plugin_Handled;

	if (g_bIsPaused && !g_bIsUnpausing) //Is paused and not currently unpausing
	{
		if(client == 0)
		{
			CPrintToChatAll("[{olive}TS{default}] The game has been unpaused by Server.");
			PrintToServer("The game has been unpaused by Server.");
		}
		else
		{
			CPrintToChatAll("[{olive}TS{default}] The game has been unpaused by an admin: {lightgreen}%N{default}.",client);
		}

		g_bIsUnpausing = true; //Set unpausing state
		if(client == 0) CreateTimer(1.0, UnpauseCountdown, 0, TIMER_REPEAT); //Start unpause countdown
		else CreateTimer(1.0, UnpauseCountdown, GetClientUserId(client), TIMER_REPEAT); //Start unpause countdown
		g_iPauseAdmin = 0;
	}
	else if (!g_bIsPaused) //Is not paused
	{
		if(client == 0) 
		{
			CPrintToChatAll("[{olive}TS{default}] The game has been paused by Server");
			CPrintToChatAll("To unpause the game, use \x04!forcepause{default}, admin only.");
			PrintToServer("The game has been paused by Server");
			PrintToServer("To unpause the game, use sm_forcepause");
			g_iPauseAdmin = 0;
		}
		else
		{
			CPrintToChatAll("[{olive}TS{default}] The game has been paused by an admin: {lightgreen}%N{default}.",client);
			CPrintToChatAll("To unpause the game, use \x04!forcepause{default}, admin only.");
			g_iPauseAdmin = client;
		}
		
		Pause(client);
	}
	return Plugin_Handled;
}

/*Action Say_Command(int client, const char[] command, int args)
{
	if (!g_bIsPaused || client == 0 || BaseComm_IsClientGagged(client) == true) return Plugin_Continue;

	char buffer[256];
	GetCmdArg(1, buffer, sizeof(buffer));
	if (IsSayCommandPrivate(buffer)) return Plugin_Continue; // If its a private chat trigger, return continue

	int team = GetClientTeam(client);
	if(team == 1)
		CPrintToChatAll("(Spec) {lightgreen}%N{default} : %s", client, buffer);
	else if(team == 2)
		CPrintToChatAll("(Sur) {lightgreen}%N{default} : %s", client, buffer);
	else if(team == 3)
		CPrintToChatAll("(Inf) {lightgreen}%N{default} : %s", client, buffer);
		
	return Plugin_Handled;
}

Action SayTeam_Command(int client, const char[] command, int args)
{
	if (!g_bIsPaused || client == 0 || BaseComm_IsClientGagged(client) == true ) return Plugin_Continue;
	if(g_hNoTeamSayPlugin != null) return Plugin_Continue;

	char buffer[256];
	GetCmdArg(1, buffer, sizeof(buffer));
	if (IsSayCommandPrivate(buffer)) return Plugin_Continue; // If its a private chat trigger, return continue
	
	int team = GetClientTeam(client);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != team) continue;
		if(team == 1)
			CPrintToChat(i, "{default}(Spec)(team) {default}%N{default} : %s", client, buffer);
		else if(team == 2)
			CPrintToChat(i, "{default}(Sur)(team) {blue}%N{default} : %s", client, buffer);
		else if(team == 3)
			CPrintToChat(i, "{default}(Inf)(team) {red}%N{default} : %s", client, buffer);
	}
		
	return Plugin_Handled;

}*/

Action UnpauseCountdown(Handle timer, any client)
{
	if (!g_bIsUnpausing) //Server was repaused/unpaused before the countdown finished
	{
		return Plugin_Stop;
	}
	static int iCountdown = 5;
	if(iCountdown == 0) //Resume game when countdown hits 0
	{
		PrintHintTextToAll("Game is Live!");
		client = GetClientOfUserId(client);
		Unpause(client);
		iCountdown = 5;
		return Plugin_Stop;
	}
	else if (iCountdown == 5) //Start of countdown
	{
		CPrintToChatAll("Game will resume in %d...", iCountdown);
		iCountdown--;
		return Plugin_Continue;
	}
	else //Countdown progress
	{
		CPrintToChatAll("%d...", iCountdown);
		iCountdown--;
		return Plugin_Continue;
	}
}

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if( !client || !IsClientInGame(client)) return;

	if(client == g_iPauseAdmin)
	{
		CPrintToChatAll("[{olive}TS{default}] The game has been unpaused due to admin disconnecting: {lightgreen}%N{default}.", client);
		g_bIsUnpausing = true; //Set unpausing state
		PrintHintTextToAll("Game is Live!");
		Unpause(client);
		g_iPauseAdmin = 0;
	}
}

void Event_PlayerSay(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
    int iUserId = hEvent.GetInt("userid");
    RequestFrame(FrameDelay_PlayerSay, iUserId);
}

void FrameDelay_PlayerSay(int iUserId)
{
	int iClient = GetClientOfUserId(iUserId);
	if (iClient < 1 || !g_bIsPaused) {
		return;
	}

	// During a pause the time (gpGlobals->curtime) does not change.
	// Let's reset this property for the chat to work.
	SetEntPropFloat(iClient, Prop_Data, "m_fLastPlayerTalkTime", 0.0);
}

void Pause(int client)
{
	ResetPauseRequest(); 

	if(client == 0)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				g_bIsPaused = true; 
				SetConVarInt(g_hPausable, 1);
				FakeClientCommand(i, "setpause"); 
				SetConVarInt(g_hPausable, 0);
				break;
			}
		}
	}
	else
	{
		g_bIsPaused = true; 
		SetConVarInt(g_hPausable, 1);
		FakeClientCommand(client, "setpause"); 
		SetConVarInt(g_hPausable, 0);
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{

			SetEntPropFloat(i, Prop_Data, "m_fLastPlayerTalkTime", 0.0);

		}
	}

	g_bIsUnpausing = false; //Game was just paused and can no longer be unpausing if it was
}

void Unpause(int client)
{
	ResetPauseRequest(); 

	if(client == 0)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				g_bIsPaused = false; 
				SetConVarInt(g_hPausable, 1); 
				FakeClientCommand(i, "unpause");
				SetConVarInt(g_hPausable, 0);
				break;
			}
		}
	}
	else
	{
		g_bIsPaused = false; 
		SetConVarInt(g_hPausable, 1);
		FakeClientCommand(client, "unpause"); 
		SetConVarInt(g_hPausable, 0);
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			SetEntPropFloat(i, Prop_Data, "m_fLastPlayerTalkTime", 0.0);
		}
	}

	g_bIsUnpausing = false; //Game is active so it is no longer in the unpausing state
}

void ResetPauseRequest()
{
	g_bPauseRequest[0] = false; //Survivors request
	g_bPauseRequest[1] = false; //Infected request
}

/*bool IsSayCommandPrivate(const char[] command)
{
	if (StrContains(command, PRIVAT_TRIGGER) == 0) return true;
	return false;
}*/