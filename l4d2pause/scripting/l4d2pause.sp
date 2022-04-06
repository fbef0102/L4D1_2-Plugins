#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <basecomm>
#include <multicolors>
#define PLUGIN_VERSION "1.3"

#define	PRIVAT_TRIGGER	"/"

ConVar g_hForceOnly;
ConVar g_hPausable;
bool g_bIsPaused = false;
bool g_bIsUnpausing = false;
bool g_bAllowPause = false;
bool g_bAllowUnpause = false;
bool g_bPauseRequest[2] = { false, false };

public Plugin myinfo =
{
	name = "L4D2 Pause",
	author = "pvtschlag, Harry",
	description = "Allows admins to force the game to pause, only adm can unpause the game.",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?p=997585"
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

public void OnPluginStart()
{
	g_hForceOnly = CreateConVar("l4d2pause_forceonly", "1", "Only allow the game to be paused by the forcepause command(Admin only).", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	AutoExecConfig(true, "l4d2pause"); //Create and/or load the plugin config

	g_hPausable = FindConVar("sv_pausable");
	
	SetConVarInt(g_hPausable, 0);

	RegConsoleCmd("pause", Command_Pause);
	RegConsoleCmd("setpause", Command_Setpause);
	RegConsoleCmd("unpause", Command_Unpause);
	
	RegAdminCmd("sm_forcepause", Command_SMForcePause, ADMFLAG_ROOT, "Adm forces the game to pause/unpause");

	AddCommandListener(Say_Command, "say");
	AddCommandListener(SayTeam_Command, "say_team");
}

ConVar g_hNoTeamSayPlugin = null;
public void OnAllPluginsLoaded()
{
	// lfd_noTeamSay
	g_hNoTeamSayPlugin = FindConVar("noteamsay_ignorelist");
}

public void OnMapStart()
{
	g_bIsPaused = false;
}

public void OnMapEnd()
{
	ResetPauseRequest(); //Reset any pause requests
}

public Action Command_Pause(int client, int args)
{
	return Plugin_Handled; //We don't want the pause command doing anything
}

public Action Command_Setpause(int client, int args)
{
	if (g_bAllowPause) //Only allow the command to go through if we have said it could previously
	{
		g_bIsPaused = true; //Game is now paused
		g_bIsUnpausing = false; //Game was just paused and can no longer be unpausing if it was
		g_bAllowPause = false; //Don't allow this command to be used again untill we say
		return Plugin_Continue;
	}
	return Plugin_Handled;
}

public Action Command_Unpause(int client, int args)
{
	if (g_bAllowUnpause) //Only allow the command to go through if we have said it could previously
	{
		g_bIsPaused = false; //Game is now active
		g_bIsUnpausing = false; //Game is active so it is no longer in the unpausing state
		g_bAllowUnpause = false; //Don't allow this command to be used again untill we say
		return Plugin_Continue;
	}
	return Plugin_Handled;
}


public Action Command_SMForcePause(int client, int args)
{
	if(g_hForceOnly.BoolValue == false) return Plugin_Handled;

	if (g_bIsPaused && !g_bIsUnpausing) //Is paused and not currently unpausing
	{
		PrintToChatAll("\x01[\x05TS\x01] The game has been unpaused by an admin: \x03%N\x01.",client);
		g_bIsUnpausing = true; //Set unpausing state
		CreateTimer(1.0, UnpauseCountdown, client, TIMER_REPEAT); //Start unpause countdown
	}
	else if (!g_bIsPaused) //Is not paused
	{
		PrintToChatAll("\x01[\x05TS\x01] The game has been paused by an admin: \x03%N\x01.",client);
		PrintToChatAll("\x01To unpause the game, use \x04!forcepause\x01, admin only.");
		Pause(client);
	}
	return Plugin_Handled;
}

public Action Say_Command(int client, const char[] command, int args)
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

public Action SayTeam_Command(int client, const char[] command, int args)
{
	if (!g_bIsPaused || client == 0 || BaseComm_IsClientGagged(client) == true ) return Plugin_Continue;
	if(g_hNoTeamSayPlugin != null) return Plugin_Continue;

	char buffer[256];
	GetCmdArg(1, buffer, sizeof(buffer));
	if (IsSayCommandPrivate(buffer)) return Plugin_Continue; // If its a private chat trigger, return continue
	
	int teamIndex = GetClientTeam(client);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != teamIndex) continue;
		if(teamIndex == 1)
			CPrintToChat(i, "{default}(Spec) {default}%N{default} : %s", client, buffer);
		else if(teamIndex == 2)
			CPrintToChat(i, "{default}(Sur) {blue}%N{default} : %s", client, buffer);
		else if(teamIndex == 3)
			CPrintToChat(i, "{default}(Inf) {red}%N{default} : %s", client, buffer);
	}
		
	return Plugin_Handled;

}

public Action UnpauseCountdown(Handle timer, any client)
{
	if (!g_bIsUnpausing) //Server was repaused/unpaused before the countdown finished
	{
		return Plugin_Stop;
	}
	static int iCountdown = 5;
	if(iCountdown == 0) //Resume game when countdown hits 0
	{
		PrintHintTextToAll("Game is Live!");
		Unpause(client);
		iCountdown = 5;
		return Plugin_Stop;
	}
	else if (iCountdown == 5) //Start of countdown
	{
		PrintToChatAll("Game will resume in %d...", iCountdown);
		iCountdown--;
		return Plugin_Continue;
	}
	else //Countdown progress
	{
		PrintToChatAll("%d...", iCountdown);
		iCountdown--;
		return Plugin_Continue;
	}
}

void Pause(int client)
{
	ResetPauseRequest(); //Reset all pause requests since we are now pausing the game
	g_bAllowPause = true; //Allow the next setpause command to go through
	SetConVarInt(g_hPausable, 1); //Ensure sv_pausable is set to 1
	FakeClientCommand(client, "setpause"); //Send pause command
	SetConVarInt(g_hPausable, 0); //Rest sv_pausable back to 0
}

void Unpause(int client)
{
	ResetPauseRequest(); //Reset all pause requests since we are now pausing the game
	g_bAllowUnpause = true; //Allow the next unpause command to go through
	SetConVarInt(g_hPausable, 1); //Ensure sv_pausable is set to 1
	FakeClientCommand(client, "unpause"); //Send unpause command
	SetConVarInt(g_hPausable, 0); //Rest sv_pausable back to 0
}

void ResetPauseRequest()
{
	g_bPauseRequest[0] = false; //Survivors request
	g_bPauseRequest[1] = false; //Infected request
}

stock bool IsSayCommandPrivate(const char[] command)
{
	if (StrContains(command, PRIVAT_TRIGGER) == 0) return true;
	return false;
}