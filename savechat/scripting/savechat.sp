#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <geoip>
#include <string>

#define PLUGIN_VERSION "SaveChat_1.6"

char chatFile[128];
Handle fileHandle       = null;
ConVar sc_record_detail = null;
ConVar hostport = null;


bool bRecord_detail;
char sHostport[10];

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
	char date[21];
	char logFile[100];

	/* Register CVars */
	CreateConVar("sm_savechat_version", PLUGIN_VERSION, "Save Player Chat Messages Plugin", 
		FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_REPLICATED);

	sc_record_detail = CreateConVar("sc_record_detail", "1", 
		"Record player Steam ID and IP address",
		FCVAR_NOTIFY, true, 0.0,true, 1.0); 

	bRecord_detail = sc_record_detail.BoolValue;
	sc_record_detail.AddChangeHook(ConVarChanged_Cvars);

	hostport = FindConVar("hostport");
	hostport.GetString(sHostport, sizeof(sHostport));
	hostport.AddChangeHook(ConVarChanged_Cvars);

	/* Say commands */
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_SayTeam);

	/* Format date for log filename */
	FormatTime(date, sizeof(date), "%d%m%y", -1);

	/* Create name of logfile to use */
	Format(logFile, sizeof(logFile), "/logs/chat%s.log", date);
	BuildPath(Path_SM, chatFile, PLATFORM_MAX_PATH, logFile);
	
	HookEvent("player_disconnect", event_PlayerDisconnect, EventHookMode_Pre);

	//Autoconfig for plugin
	AutoExecConfig(true, "savechat");
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	bRecord_detail = sc_record_detail.BoolValue;
	hostport.GetString(sHostport, sizeof(sHostport));
}

/*
 * Capture player chat and record to file
 */
public Action Command_Say(int client, int args)
{
	LogChat(client, args, false);
	return Plugin_Continue;
}

/*
 * Capture player team chat and record to file
 */
public Action Command_SayTeam(int client, int args)
{
	LogChat(client, args, true);
	return Plugin_Continue;
}

public void OnClientPostAdminCheck(int client)
{
	/* Only record player detail if CVAR set */
	if(bRecord_detail == false)
		return;

	if(IsFakeClient(client)) 
		return;

	char msg[2048];
	char time[21];
	char steamID[128];
	char playerIP[50];
	
	GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));

	/* Get 2 digit country code for current player */
	
	GetClientIP(client, playerIP, sizeof(playerIP), true);
	
	FormatTime(time, sizeof(time), "%H:%M:%S", -1);
	Format(msg, sizeof(msg), "[%s] (%s | %s) %-25N has joined",
		time,
		steamID,
		playerIP,
		client);

	SaveMessage(msg);
}

public void event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if( client && !IsFakeClient(client) && !dontBroadcast )
	{
		char msg[2048];
		char time[21];
		//char country[3];
		char steamID[128];
		char playerIP[50];
		
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));

		/* Get 2 digit country code for current player */
		
		if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
			//country   = "  "
		} else {
			//if(GeoipCode2(playerIP, country) == false) {
				//country = "  ";
			//}
		}
		
		FormatTime(time, sizeof(time), "%H:%M:%S", -1);
		Format(msg, sizeof(msg), "[%s] (%s | %s) %-25N has left",
			time,
			steamID,
			playerIP,
			client);

		SaveMessage(msg);
	}
}

/*
 * Extract all relevant information and format 
 */
public void LogChat(int client, int args, bool teamchat)
{
	char msg[2048];
	char time[21];
	char text[1024];
	char country[3];
	char playerIP[50];
	char teamName[20];

	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);

	char steamID[128];
	
	if (client == 0 || !IsClientInGame(client)) {
		/* Don't try and obtain client country/team if this is a console message */
		Format(country, sizeof(country), "  ");
		Format(teamName, sizeof(teamName), "");
	} else {
		/* Get 2 digit country code for current player */
		if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
			country   = "  ";
		} else {
			if(GeoipCode2(playerIP, country) == false) {
				country = "  ";
			}
		}
		GetTeamName(GetClientTeam(client), teamName, sizeof(teamName));
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	}
	FormatTime(time, sizeof(time), "%H:%M:%S", -1);

	if(bRecord_detail) {
		Format(msg, sizeof(msg), "[%s] (%s | %-9s) [%s%s] %-25N : %s",
			time,
			steamID,
			playerIP,
			teamName,
			teamchat == true ? " (TEAM)" : "",
			client,
			text);
	} else {
		Format(msg, sizeof(msg), "[%s] (%s) [%s%s] %-25N : %s",
			time,
			steamID,
			teamName,
			teamchat == true ? " (TEAM)" : "",
			client,
			text);
	}

	SaveMessage(msg);
}

/*
 * Log a map transition
 */
public void OnMapStart(){
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

/*
 * Log the message to file
 */
public void SaveMessage(const char[] message)
{
	fileHandle = OpenFile(chatFile, "a");  /* Append */
	if(fileHandle == null)
	{
		CreateDirectory("/addons/sourcemod/logs/chat", 0);
		fileHandle = OpenFile(chatFile, "a"); //open again
	}
	WriteFileLine(fileHandle, message);
	delete fileHandle;
}

