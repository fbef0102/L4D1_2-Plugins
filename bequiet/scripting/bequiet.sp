#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>

public Plugin myinfo = 
{
	name = "BeQuiet",
	author = "Sir & Harry Potter",
	description = "Please be Quiet! Block unnecessary chat or announcement",
	version = "1.6",
	url = "https://github.com/fbef0102/L4D1_2-Plugins/tree/master/bequiet"
}

UserMsg g_umSayText2;

public void OnPluginStart()
{
	AddCommandListener(Say_Callback, "say");
	AddCommandListener(TeamSay_Callback, "say_team");

	//Server CVar
	HookEvent("server_cvar", Event_ServerDontNeedPrint, EventHookMode_Pre);
	
	//change name
	g_umSayText2 = GetUserMessageId("SayText2");
	HookUserMessage(g_umSayText2, UserMessageHook, true);
}

public Action Say_Callback(int client, const char[] command, int argc)
{
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
	char sayWord[MAX_NAME_LENGTH];
	GetCmdArg(1, sayWord, sizeof(sayWord));
	
	if(sayWord[0] == '!' || sayWord[0] == '/')
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


public Action Event_ServerDontNeedPrint(Event event, const char[] name, bool dontBroadcast) 
{
    return Plugin_Handled;
}


public Action UserMessageHook(UserMsg msg_hd, Handle bf, const int [] players, int playersNum, bool reliable, bool init)
{
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