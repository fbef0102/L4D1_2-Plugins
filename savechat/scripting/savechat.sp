#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <geoip>
#include <basecomm>

#define PLUGIN_VERSION "2.0-2023/10/29"

ConVar hostport;
char sHostport[10];

char chatFile[128];
Handle fileHandle       = null;
ConVar g_hCvarEnable, g_hCvarConsole;
bool g_bCvarEnable, g_bCvarConsole;

public Plugin myinfo = 
{
	name = "SaveChat",
	author = "citkabuto & Harry Potter",
	description = "Records player chat messages to a file",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=117116"
}

public void OnPluginStart()
{

	hostport = FindConVar("hostport");

	g_hCvarEnable = 	CreateConVar("savechat_enable", 			"1", "0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY, true, 0.0, true, 1.0); 
	g_hCvarConsole = 	CreateConVar("savechat_cosole_command", 	"1", "If 1, Record and save console commands.", FCVAR_NOTIFY, true, 0.0, true, 1.0); 
	CreateConVar("sm_savechat_version", PLUGIN_VERSION, "Save Player Chat Messages Plugin",  FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	AutoExecConfig(true, "savechat");
	
	GetCvars();
	hostport.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarConsole.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_disconnect", 	event_PlayerDisconnect);
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarConsole = g_hCvarConsole.BoolValue;
	hostport.GetString(sHostport, sizeof(sHostport));
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if(g_bCvarEnable == false)
		return Plugin_Continue;

	if(client < 0 || client > MaxClients)
		return Plugin_Continue;

	if (BaseComm_IsClientGagged(client) == true) //this client has been gagged
		return Plugin_Continue;	

	if (strcmp(command, "say_team") == 0)
	{
		LogChat2(client, sArgs, true);
	}
	else
	{
		LogChat2(client, sArgs, false);
	}

	return Plugin_Continue;
}

public Action OnClientCommand(int client, int args) 
{
	if(g_bCvarEnable == false || g_bCvarConsole == false)
		return Plugin_Continue;

	if(client < 0 || client > MaxClients)
		return Plugin_Continue;

	LogCommand(client, args);
	return Plugin_Continue;
}

public void OnMapStart(){
	if(g_bCvarEnable == false)
		return;

	char map[128];
	char msg[1024];
	char date[21];
	char time[21];
	char logFile[100];

	GetCurrentMap(map, sizeof(map));

	/* The date may have rolled over, so update the logfile name here */
	FormatTime(date, sizeof(date), "%y_%m_%d", -1);
	Format(logFile, sizeof(logFile), "/logs/chat/server_%s_chat_%s.log", sHostport, date);
	BuildPath(Path_SM, chatFile, PLATFORM_MAX_PATH, logFile);

	FormatTime(time, sizeof(time), "%d/%m/%Y %H:%M:%S", -1);
	Format(msg, sizeof(msg), "[%s] --- Map: %s ---", time, map);

	SaveMessage("--=================================================================--");
	SaveMessage(msg);
	SaveMessage("--=================================================================--");
}


public void OnClientPostAdminCheck(int client)
{
	if(g_bCvarEnable == false)
		return;

	if(IsFakeClient(client)) 
		return;

	static char msg[2048];
	static char time[21];
	static char country[3];
	static char steamID[128];
	static char playerIP[50];
	
	GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	
	if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
		//country   = "  "
	} else {
		if(GeoipCode2(playerIP, country) == false) {
			//country = "  ";
		}
	}
	
	FormatTime(time, sizeof(time), "%H:%M:%S", -1);
	FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) %-25N has joined.",
		time,
		steamID,
		playerIP,
		client);

	SaveMessage(msg);
}

void event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast) 
{
	if(g_bCvarEnable == false)
		return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if( client && !IsFakeClient(client) && !dontBroadcast )
	{
		static char msg[2048];
		static char time[21];
		static char country[3];
		static char steamID[128];
		static char playerIP[50];
		
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
		
		if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
			//country   = "  "
		} else {
			if(GeoipCode2(playerIP, country) == false) {
				//country = "  ";
			}
		}
		
		FormatTime(time, sizeof(time), "%H:%M:%S", -1);
		FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) %-25N has left.",
			time,
			steamID,
			playerIP,
			client);

		SaveMessage(msg);
	}
}
/*
void LogChat(int client, int args, bool teamchat)
{
	static char msg[2048];
	static char time[21];
	static char text[1024];
	static char country[3];
	static char playerIP[50];
	static char teamName[20];
	static char steamID[128];

	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);
	
	if (client == 0 || !IsClientInGame(client)) {
		//FormatEx(country, sizeof(country), "  ");
		FormatEx(teamName, sizeof(teamName), "");
	} else {
		if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
			//country   = "  ";
		} else {
			if(GeoipCode2(playerIP, country) == false) {
				//country = "  ";
			}
		}
		my_GetTeamName(GetClientTeam(client), teamName, sizeof(teamName));
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	}
	FormatTime(time, sizeof(time), "%H:%M:%S", -1);

	FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) [%s] %-25N : %s%s",
		time,
		steamID,
		playerIP,
		teamName,
		client,
		teamchat == true ? "(TEAM) " : "",
		text);

	SaveMessage(msg);
}
*/

void LogChat2(int client, const char[] sArgs, bool teamchat)
{
	static char msg[2048];
	static char time[21];
	static char country[3];
	static char playerIP[50];
	static char teamName[20];
	static char steamID[128];
	
	if (client == 0 || !IsClientInGame(client)) {
		//FormatEx(country, sizeof(country), "  ");
		FormatEx(teamName, sizeof(teamName), "");
	} else {
		if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
			//country   = "  ";
		} else {
			if(GeoipCode2(playerIP, country) == false) {
				//country = "  ";
			}
		}
		my_GetTeamName(GetClientTeam(client), teamName, sizeof(teamName));
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	}
	FormatTime(time, sizeof(time), "%H:%M:%S", -1);

	FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) [%s] %-25N : %s%s",
		time,
		steamID,
		playerIP,
		teamName,
		client,
		teamchat == true ? "(TEAM) " : "",
		sArgs);

	SaveMessage(msg);
}


stock void LogCommand(int client, int args)
{
	static char cmd[64];
	static char text[1024];

	GetCmdArg(0, cmd, sizeof(cmd));
	if( strncmp(cmd, "spec_", 5, false) == 0 || // spec_prev / spec_next
		strncmp(cmd, "vocalize", 8, false) == 0 || // vocalize
		strncmp(cmd, "VModEnable", 10, false) == 0 || // join server check
		strncmp(cmd, "vban", 4, false) == 0 || // join server check
		strncmp(cmd, "choose_", 7, false) == 0 || // choose_opendoor / choose_closedoor
		strncmp(cmd, "Vote", 4, false) == 0 || // Vote Yes / Vote No
		strncmp(cmd, "achievement_", 12, false) == 0 || // achievement_earned x x
		strncmp(cmd, "joingame", 8, false) == 0 || // joingame
		strncmp(cmd, "demo", 4, false) == 0 || // demorestart
		strncmp(cmd, "menuselect", 10, false) == 0 ) //menuselect 1~9
	{
		return;
	}
	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);

	static char country[3];
	static char playerIP[50];
	static char teamName[20];
	static char msg[2048];
	static char time[21];
	static char steamID[128];
	
	if (client == 0 || !IsClientInGame(client)) {
		/* Don't try and obtain client country/team if this is a console message */
		//FormatEx(country, sizeof(country), "  ");
		FormatEx(teamName, sizeof(teamName), "");
	} else {
		/* Get 2 digit country code for current player */
		if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
			//country   = "  ";
		} else {
			if(GeoipCode2(playerIP, country) == false) {
				//country = "  ";
			}
		}
		my_GetTeamName(GetClientTeam(client), teamName, sizeof(teamName));
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	}
	FormatTime(time, sizeof(time), "%H:%M:%S", -1);

	FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) [%s] %-25N : (CMD) %s %s",
		time,
		steamID,
		playerIP,
		teamName,
		client,
		cmd,
		text);

	SaveMessage(msg);
}

void SaveMessage(const char[] message)
{
	fileHandle = OpenFile(chatFile, "a");  /* Append */
	if(fileHandle == null)
	{
		CreateDirectory("/addons/sourcemod/logs/chat", 511);
		fileHandle = OpenFile(chatFile, "a"); //open again
	}
	WriteFileLine(fileHandle, message);
	delete fileHandle;
}

void my_GetTeamName(int team, char[] sTeamName, int size)
{
	switch(team)
	{
		case 1:
		{
			FormatEx(sTeamName, size, "Spe");
		}
		case 2:
		{
			FormatEx(sTeamName, size, "Sur");
		}
		case 3:
		{
			FormatEx(sTeamName, size, "Inf");
		}
		case 4:
		{
			FormatEx(sTeamName, size, "NPC");
		}
		default:
		{
			FormatEx(sTeamName, size, "Unknown");
		}
	}
}

