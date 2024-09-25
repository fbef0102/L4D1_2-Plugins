#pragma semicolon 1
#pragma newdecls required;
#include <sourcemod>
#include <multicolors>

public Plugin myinfo =
{
	name = "Mathack Block",
	author = "Sir, Visor, NightTime & extrav3rt, Harry Potter",
	description = "Kicks out clients who are potentially attempting to enable mathack",
	version = "1.0h-2024/8/26",
	url = "http://steamcommunity.com/profiles/76561198026784913"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	CreateNative("MaterialHack_CheckClients", Native_CheckClients);
	return APLRes_Success;
}

static const float CLIENT_CHECK_INTERVAL = 3.5;

#define CONFIG_FILE		        "configs/l4d_texture_manager_block.cfg"
#define LOG_FILE		        "logs/l4d_texture_manager_block.log"

char g_sPath[256], g_sList[256];

#define CLS_CVAR_MAXLEN				128

enum /*CLSAction*/
{
	CLSA_Kick = 0,
	CLSA_Log  = 1,
};

enum struct CLSEntry
{
	char CLSE_cvar[CLS_CVAR_MAXLEN];
	bool CLSE_hasMin;
	float CLSE_min;
	bool CLSE_hasMax;
	float CLSE_max;
	int CLSE_action;
	char CLSE_Note[CLS_CVAR_MAXLEN];
}

ArrayList
	ClientSettingsArray;

Handle 
	ClientSettingsCheckTimer;

bool 
	g_bParseList;

public void OnPluginStart()
{
	BuildPath(Path_SM, g_sPath, sizeof(g_sPath), LOG_FILE);
	BuildPath(Path_SM, g_sList, sizeof(g_sList), CONFIG_FILE);

	RegServerCmd("list_clientsettings", 	ServerCMD_ClientSettings_Cmd, 	"List Client settings enforced by l4d_texture_manager_block");
	RegServerCmd("add_trackclientcvar", 	ServerCMD_TrackClientCvar_Cmd, 	"Add a Client CVar to be tracked and enforced by l4d_texture_manager_block");
	RegServerCmd("reload_trackclientcvar", 	ServerCMD_reloadWhiteList, 		"Reload the 'trackclientcvar' list");

	ClientSettingsArray = new ArrayList(sizeof(CLSEntry));
}

// Sourcemod API Forward-------------------------------

public void OnConfigsExecuted()
{
	g_bParseList = true;
	ParseList();
	RequestFrame(NextFrame_ParseList);

	delete ClientSettingsCheckTimer;
	ClientSettingsCheckTimer = CreateTimer(CLIENT_CHECK_INTERVAL, Timer_CheckClients, _, TIMER_REPEAT);
}

// Command-------------------------------

Action ServerCMD_ClientSettings_Cmd(int args)
{
	int iSize = ClientSettingsArray.Length;
	PrintToServer("Tracked Client CVars (Total %d)", iSize);

	CLSEntry clsetting;
	char message[256], shortbuf[64];
	for (int i = 0; i < iSize; i++) 
	{
		ClientSettingsArray.GetArray(i, clsetting, sizeof(clsetting));
		Format(message, sizeof(message), "Client CVar: %s ", clsetting.CLSE_cvar);

		if (clsetting.CLSE_hasMin) {
			Format(shortbuf, sizeof(shortbuf), "Min: %f ", clsetting.CLSE_min);
			StrCat(message, sizeof(message), shortbuf);
		}

		if (clsetting.CLSE_hasMax) {
			Format(shortbuf, sizeof(shortbuf), "Max: %f ", clsetting.CLSE_max);
			StrCat(message, sizeof(message), shortbuf);
		}

		switch (clsetting.CLSE_action) {
			case CLSA_Kick: {
				StrCat(message, sizeof(message), "Action: Kick");
			}
			case CLSA_Log: {
				StrCat(message, sizeof(message), "Action: Log");
			}
		}

		PrintToServer(message);
	}

	return Plugin_Handled;
}

Action ServerCMD_TrackClientCvar_Cmd(int args)
{
	if (args < 3 || args == 4) 
	{
		static char cmdbuf[128];
		GetCmdArgString(cmdbuf, sizeof(cmdbuf));
		if(g_bParseList)
		{
			LogError("Invalid track client cvar: %s", cmdbuf);
			LogError("Usage: <cvar> <hasMin> <min> <hasMax> <max> <action> [note]");
		}
		else
		{
			PrintToServer("Invalid track client cvar: %s", cmdbuf);
			PrintToServer("Usage: add_trackclientcvar <cvar> <hasMin> <min> <hasMax> <max> <action> [note]");
		}

		return Plugin_Handled;
	}

	char sBuffer[CLS_CVAR_MAXLEN], cvar[CLS_CVAR_MAXLEN], sNote[CLS_CVAR_MAXLEN];
	bool hasMax;
	float max;
	int action = CLSA_Kick;

	GetCmdArg(1, cvar, sizeof(cvar));

	if (strlen(cvar) == 0) 
	{
		if(g_bParseList)
		{
			LogError("Unreadable cvar: empty");
		}
		else
		{
			PrintToServer("Unreadable cvar: empty");
		}

		return Plugin_Handled;
	}

	GetCmdArg(2, sBuffer, sizeof(sBuffer));
	bool hasMin = view_as<bool>(StringToInt(sBuffer));

	GetCmdArg(3, sBuffer, sizeof(sBuffer));
	float min = StringToFloat(sBuffer);

	if (args >= 5) {
		GetCmdArg(4, sBuffer, sizeof(sBuffer));
		hasMax = view_as<bool>(StringToInt(sBuffer));

		GetCmdArg(5, sBuffer, sizeof(sBuffer));
		max = StringToFloat(sBuffer);
	}

	if (args >= 6) {
		GetCmdArg(6, sBuffer, sizeof(sBuffer));
		action = StringToInt(sBuffer);
	}

	sNote[0] = '\0';
	if (args >= 7) {
		GetCmdArg(7, sNote, sizeof(sNote));
	}

	_AddClientCvar(cvar, hasMin, min, hasMax, max, action, sNote);

	return Plugin_Handled;
}

Action ServerCMD_reloadWhiteList(int args)
{
	g_bParseList = true;
	ParseList();
	RequestFrame(NextFrame_ParseList);

	delete ClientSettingsCheckTimer;
	ClientSettingsCheckTimer = CreateTimer(CLIENT_CHECK_INTERVAL, Timer_CheckClients, _, TIMER_REPEAT);

	return Plugin_Handled;
}

//Timer-------------------------------

void NextFrame_ParseList()
{
	g_bParseList = false;
}

Action Timer_CheckClients(Handle timer)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			EnforceCliSettings(client);
		}
	}	

	return Plugin_Continue;
}

//Config-------------------------------

void ParseList()
{
	delete ClientSettingsArray;
	ClientSettingsArray = new ArrayList(sizeof(CLSEntry));

	File hFile = OpenFile(g_sList, "r");
	if(hFile == null)
	{
		LogError("%s not found", g_sList);
		return;
	}

	bool bDataStart = false;
	char sBuffer[256];
	while(!hFile.EndOfFile() && hFile.ReadLine(sBuffer, sizeof(sBuffer)))
	{
		if(StrContains(sBuffer, "Do not delete this line", false) != -1)
		{
			bDataStart = true;
			continue;
		}

		if(strncmp(sBuffer, "//", 2, false) == 0)
		{
			continue;
		}

		if(bDataStart)
		{
			TrimString(sBuffer);
			StripQuotes(sBuffer);

			if(strlen(sBuffer) <= 0) continue;

			ServerCommand("add_trackclientcvar %s", sBuffer);
		}
	}

	delete hFile;
}


// Function. Codes from Confogl: https://github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/confoglcompmod/ClientSettings.sp

void _AddClientCvar(const char[] cvar, bool hasMin, float min, bool hasMax, float max, int action, const char[] sNote)
{
	if (!(hasMin || hasMax)) 
	{
		if(g_bParseList)
		{
			LogError("Client CVar %s specified without max or min", cvar);
		}
		else
		{
			PrintToServer("Client CVar %s specified without max or min", cvar);
		}
		
		return;
	}

	if (hasMin && hasMax && max < min) 
	{
		if(g_bParseList)
		{
			LogError("Client CVar %s specified max < min (%f < %f)", cvar, max, min);
		}
		else
		{
			PrintToServer("Client CVar %s specified max < min (%f < %f)", cvar, max, min);
		}
		
		return;
	}

	if (strlen(cvar) >= CLS_CVAR_MAXLEN) 
	{
		if(g_bParseList)
		{
			LogError("CVar Specified (%s) is longer than max cvar length (%d)", cvar, CLS_CVAR_MAXLEN);
		}
		else
		{
			PrintToServer("CVar Specified (%s) is longer than max cvar length (%d)", cvar, CLS_CVAR_MAXLEN);
		}
		
		return;
	}

	int iSize = ClientSettingsArray.Length;

	CLSEntry newEntry;
	for (int i = 0; i < iSize; i++) 
	{
		ClientSettingsArray.GetArray(i, newEntry, sizeof(newEntry));

		if (strcmp(newEntry.CLSE_cvar, cvar, false) == 0) 
		{
			if(g_bParseList)
			{
				LogError("Attempt to track CVar %s, which is already being tracked !!", cvar);
			}
			else
			{
				PrintToServer("Attempt to track CVar %s, which is already being tracked !!", cvar);
			}
			
			return;
		}
	}

	strcopy(newEntry.CLSE_cvar, CLS_CVAR_MAXLEN, cvar);
	newEntry.CLSE_hasMin = hasMin;
	newEntry.CLSE_min = min;
	newEntry.CLSE_hasMax = hasMax;
	newEntry.CLSE_max = max;
	newEntry.CLSE_action = action;
	strcopy(newEntry.CLSE_Note, CLS_CVAR_MAXLEN, sNote);

	if(g_bParseList)
	{
		//LogError("Tracking Cvar '%s', Min(%d) %f Max(%d) %f, Action: %d", cvar, hasMin, min, hasMax, max, action);
	}
	else
	{
		PrintToServer("Tracking Cvar '%s', Min(%d) %f Max(%d) %f, Action: %d", cvar, hasMin, min, hasMax, max, action);
	}
	

	ClientSettingsArray.PushArray(newEntry, sizeof(newEntry));
}

void EnforceCliSettings(int client)
{
	int iSize = ClientSettingsArray.Length;
	CLSEntry clsetting;
	for (int i = 0; i < iSize; i++) 
	{
		ClientSettingsArray.GetArray(i, clsetting, sizeof(clsetting));

		QueryClientConVar(client, clsetting.CLSE_cvar, _EnforceCliSettings_QueryReply, i);
	}
}

void _EnforceCliSettings_QueryReply(QueryCookie cookie, int client, ConVarQueryResult result, \
												const char[] cvarName, const char[] cvarValue, any value)
{
	if (!IsClientInGame(client) || IsClientInKickQueue(client)) 
	{
		// Client disconnected or got kicked already
		return;
	}

	if(!IsClientInGame(client)) return;

	if (result) // not found
	{
		//LogToFileEx(g_sPath, "[Name: %N | STEAMID: %s | %s: Not Found]: Kicked from server, Couldn't retrieve cvar value", client, sSteamID64, cvarName);
		//KickClient(client, "Cvar '%s' protected/missing/invalid!", cvarName);

		return;
	}

	float fCvarVal = StringToFloat(cvarValue);
	int clsetting_index = value;
	CLSEntry clsetting;
	ClientSettingsArray.GetArray(clsetting_index, clsetting, sizeof(clsetting));

	if ((clsetting.CLSE_hasMin && fCvarVal < clsetting.CLSE_min)
		|| (clsetting.CLSE_hasMax && fCvarVal > clsetting.CLSE_max)
	) 
	{
		static char sSteamID64[32];
		GetClientAuthId(client, AuthId_SteamID64, sSteamID64, sizeof(sSteamID64));

		if (clsetting.CLSE_action <= CLSA_Kick) 
		{
			LogToFileEx(g_sPath, "[Name: %N | STEAMID: %s | %s: %f]: Kicked from server, bad cvar value. Min(%d): %f Max(%d): %f", \
								client, sSteamID64, cvarName, fCvarVal, clsetting.CLSE_hasMin, \
									clsetting.CLSE_min, clsetting.CLSE_hasMax, clsetting.CLSE_max);


			CPrintToChatAll("[{olive}TS{default}] {lightgreen}%N{default} was kicked for having an illegal value for '{green}%s{default}' ({green}%f{default})", \
								client, cvarName, fCvarVal);

			char kickMessage[CLS_CVAR_MAXLEN] = "Illegal Client Value for ";
			Format(kickMessage, sizeof(kickMessage), "%s%s (%.2f)", kickMessage, cvarName, fCvarVal);

			if (clsetting.CLSE_hasMin) {
				Format(kickMessage, sizeof(kickMessage), "%s, Min %.2f", kickMessage, clsetting.CLSE_min);
			}

			if (clsetting.CLSE_hasMax) {
				Format(kickMessage, sizeof(kickMessage), "%s, Max %.2f", kickMessage, clsetting.CLSE_max);
			}

			KickClient(client, "%s", kickMessage);
		}
		else if (clsetting.CLSE_action == CLSA_Log) 
		{

			LogToFileEx(g_sPath, "[Name: %N | STEAMID: %s | %s: %f]: Has bad cvar value. Min(%d): %f Max(%d): %f", \
								client, sSteamID64, cvarName, fCvarVal, clsetting.CLSE_hasMin, \
									clsetting.CLSE_min, clsetting.CLSE_hasMax, clsetting.CLSE_max);
		}
		else if (clsetting.CLSE_action > 1) 
		{
			LogToFileEx(g_sPath, "[Name: %N | STEAMID: %s | %s: %f]: Banned from server, bad cvar value. Min(%d): %f Max(%d): %f", \
								client, sSteamID64, cvarName, fCvarVal, clsetting.CLSE_hasMin, \
									clsetting.CLSE_min, clsetting.CLSE_hasMax, clsetting.CLSE_max);


			CPrintToChatAll("[{olive}TS{default}] {lightgreen}%N{default} was banned for having an illegal value for '{green}%s{default}' ({green}%f{default})", \
								client, cvarName, fCvarVal);

			char banMessage[CLS_CVAR_MAXLEN] = "Illegal Client Value for ";
			Format(banMessage, sizeof(banMessage), "%s%s (%.2f)", banMessage, cvarName, fCvarVal);

			if (clsetting.CLSE_hasMin) {
				Format(banMessage, sizeof(banMessage), "%s, Min %.2f", banMessage, clsetting.CLSE_min);
			}

			if (clsetting.CLSE_hasMax) {
				Format(banMessage, sizeof(banMessage), "%s, Max %.2f", banMessage, clsetting.CLSE_max);
			}

			BanClient(client, clsetting.CLSE_action, BANFLAG_AUTHID, banMessage, banMessage);

			// If using GagMuteBanEx.smx by Harry: github.com/fbef0102/L4D1_2-Plugins/tree/master/GagMuteBanEx
			ServerCommand("sm_exbanid %d \"%s\"", clsetting.CLSE_action, sSteamID64);
		}
	}
}

// native void MaterialHack_CheckClients()
int Native_CheckClients(Handle plugin, int numParams)
{
	CreateTimer(0.1, Timer_CheckClients);

	return 0;
}