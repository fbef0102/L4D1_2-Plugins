#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <geoip>
#include <basecomm>

#define PLUGIN_VERSION "2.1-2024/4/25"

public Plugin myinfo = 
{
	name = "SaveChat",
	author = "citkabuto & Harry Potter",
	description = "Records player chat messages to a file",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=117116"
}

ConVar hostport;
char sHostport[10];

char chatFile[128];
Handle fileHandle       = null;
ConVar g_hCvarEnable, g_hCvarConsole;
bool g_bCvarEnable, g_bCvarConsole;

StringMap
	g_smIgnoreList;

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

	g_smIgnoreList = new StringMap();
	g_smIgnoreList.SetValue("spec_prev", true);
	g_smIgnoreList.SetValue("spec_next", true);
	g_smIgnoreList.SetValue("spec_mode", true);
	g_smIgnoreList.SetValue("skipouttro", true);
	g_smIgnoreList.SetValue("vocalize", true); // character vocalize
	g_smIgnoreList.SetValue("vmodenable", true); // join server check
	g_smIgnoreList.SetValue("achievement_earned", true); // achievement_earned x x
	g_smIgnoreList.SetValue("vban", true); // join server check
	g_smIgnoreList.SetValue("choose_closedoor", true); // close door
	g_smIgnoreList.SetValue("choose_opendoor", true); // open door
	g_smIgnoreList.SetValue("vote", true); // Vote Yes / Vote No
	g_smIgnoreList.SetValue("joingame", true);
	g_smIgnoreList.SetValue("demorestart", true);
	g_smIgnoreList.SetValue("menuselect", true); // menuselect 1~9

}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
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

	if (client > 0 && BaseComm_IsClientGagged(client) == true) //this client has been gagged
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

// 不會檢測到客戶端能執行的指令
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
	FormatTime(date, sizeof(date), "%Y_%m_%d", -1);
	Format(logFile, sizeof(logFile), "/logs/chat/server_%s_chat_%s.log", sHostport, date);
	BuildPath(Path_SM, chatFile, PLATFORM_MAX_PATH, logFile);

	FormatTime(time, sizeof(time), "%d/%m/%Y %H:%M:%S", -1);
	FormatEx(msg, sizeof(msg), "[%s] --- Map: %s ---", time, map);

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

	static char msg[2048];
	static char time[21];
	//static char country[3];
	static char steamID[64];
	static char playerIP[50];
	static char reason[128];
	event.GetString("reason", reason, sizeof(reason));
	
	if(client == 0 && strcmp(reason, "Connection closing", false) == 0)
	{
		static char playerName[128];
		event.GetString("name", playerName, sizeof(playerName));

		static char networkid[32];
		event.GetString("networkid", networkid, sizeof(networkid));

		FormatTime(time, sizeof(time), "%H:%M:%S", -1);
		FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) %-25s has left (%s).",
			time,
			networkid,
			"Unknown",
			playerName,
			reason);

		SaveMessage(msg);
		return;
	}
	
	if( client && !IsFakeClient(client) && !dontBroadcast )
	{
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
		
		if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
			//country   = "  "
		} else {
			//if(GeoipCode2(playerIP, country) == false) {
			//	//country = "  ";
			//}
		}
		
		FormatTime(time, sizeof(time), "%H:%M:%S", -1);
		FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) %-25N has left (%s).",
			time,
			steamID,
			playerIP,
			client,
			reason);

		SaveMessage(msg);
	}
}

void LogChat2(int client, const char[] sArgs, bool teamchat)
{
	static char Args[512];
	static char msg[2048];
	static char time[21];
	static char country[3];
	static char playerIP[50];
	static char teamName[20];
	static char steamID[128];
	
	if (client == 0 || !IsClientInGame(client)) {
		country[0] = '\0';
		teamName[0] = '\0';
		playerIP[0] = '\0';
		steamID[0] = '\0';
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
	FormatEx(Args, sizeof(Args), "%s", sArgs);
	ReplaceString(Args, sizeof(Args), "%", "%%");

	FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) [%s] %-25N : %s%s",
		time,
		steamID,
		playerIP,
		teamName,
		client,
		teamchat == true ? "(TEAM) " : "",
		Args);

	SaveMessage(msg);
}

stock void LogCommand(int client, int args)
{
	static char cmd[64];
	static char text[1024];

	GetCmdArg(0, cmd, sizeof(cmd));
	StringToLowerCase(cmd);
	bool bTemp;
	if( g_smIgnoreList.GetValue(cmd, bTemp) == true )
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
		country[0] = '\0';
		teamName[0] = '\0';
		playerIP[0] = '\0';
		steamID[0] = '\0';
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
	ReplaceString(text, sizeof(text), "%", "%%");

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
		CreateDirectory("/addons/sourcemod/logs/chat", 777);
		fileHandle = OpenFile(chatFile, "a"); //open again
		if(fileHandle == null)
		{
			LogError("Can not create chat file: %s", chatFile);
			return;
		}
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

void StringToLowerCase(char[] input)
{
    for (int i = 0; i < strlen(input); i++)
    {
        input[i] = CharToLower(input[i]);
    }
}