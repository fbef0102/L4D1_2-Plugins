#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION			"1.0h-2024/3/3"
#define PLUGIN_NAME			    "bequiet"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "BeQuiet",
	author = "Sir & Harry Potter",
	description = "Please be Quiet! Block unnecessary chat or announcement",
	version = PLUGIN_VERSION,
	url = "https://github.com/fbef0102/L4D1_2-Plugins/tree/master/bequiet"
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar g_hCvarEnable, g_hCvarChange, g_hCvarNameChange, g_hCvarChatChange;
bool g_bCvarEnable, g_bCvarChange, g_bCvarNameChange, g_bCvarChatChange;

UserMsg g_umSayText2;

public void OnPluginStart()
{
	//Cvars
	g_hCvarEnable		= CreateConVar( PLUGIN_NAME ... "_enable",       					"1",   	"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarChange 		= CreateConVar( PLUGIN_NAME ... "_cvar_change_suppress", 			"1", 	"If 1, Silence Server Cvars announcement.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarNameChange 	= CreateConVar( PLUGIN_NAME ... "_name_change_player_suppress", 	"1", 	"If 1, Silence Player name Changes announcement including spectators.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarChatChange 	= CreateConVar( PLUGIN_NAME ... "_chatbox_cmd_suppress", 			"1", 	"If 1, Silence chat with '!' or '/'", CVAR_FLAGS, true, 0.0, true, 1.0);
	CreateConVar(                       PLUGIN_NAME ... "_version",       					PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                PLUGIN_NAME);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarChange.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarNameChange.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarChatChange.AddChangeHook(ConVarChanged_Cvars);

	AddCommandListener(Say_Callback, "say");
	AddCommandListener(TeamSay_Callback, "say_team");

	//Server CVar
	HookEvent("server_cvar", Event_ServerDontNeedPrint, EventHookMode_Pre);

	//change name
	g_umSayText2 = GetUserMessageId("SayText2");
	HookUserMessage(g_umSayText2, UserMessageHook, true);
}

//Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarChange = g_hCvarChange.BoolValue;
	g_bCvarNameChange = g_hCvarNameChange.BoolValue;
	g_bCvarChatChange = g_hCvarChatChange.BoolValue;
}

public Action Say_Callback(int client, const char[] command, int argc)
{
	if(!g_bCvarEnable || !g_bCvarChatChange) return Plugin_Continue;

	char sayWord[MAX_NAME_LENGTH];
	GetCmdArg(1, sayWord, sizeof(sayWord));
	
	if(sayWord[0] == '!' || sayWord[0] == '/')
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action TeamSay_Callback(int client, const char[] command, int argc)
{
	if(!g_bCvarEnable || !g_bCvarChatChange) return Plugin_Continue;

	char sayWord[MAX_NAME_LENGTH];
	GetCmdArg(1, sayWord, sizeof(sayWord));
	
	if(sayWord[0] == '!' || sayWord[0] == '/')
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


Action Event_ServerDontNeedPrint(Event event, const char[] name, bool dontBroadcast) 
{
	if (!g_bCvarEnable || !g_bCvarChange) return Plugin_Continue;

	return Plugin_Handled;
}


Action UserMessageHook(UserMsg msg_hd, Handle bf, const int [] players, int playersNum, bool reliable, bool init)
{
	if(!g_bCvarEnable || !g_bCvarNameChange) return Plugin_Continue;

	char _sMessage[96];
	
	// Skip the first two bytes 
	BfReadByte(bf); 
	BfReadByte(bf);
	
	// Read the message 
	BfReadString(bf, _sMessage, sizeof(_sMessage), true); 

	if(StrContains(_sMessage, "Cstrike_Name_Change") != -1)
	{
		for(int i = 1; i <= MaxClients; i++)
			if(IsClientInGame(i))
				return Plugin_Handled;
	}

	return Plugin_Continue;
}