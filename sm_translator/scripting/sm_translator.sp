/*  SM Translator
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1
#pragma newdecls required

#include <sdktools>
#include <SteamWorks>
#include <multicolors>
#include <json> //https://github.com/clugg/sm-json

#define PLUGIN_VERSION 			"1.4h-2024/9/22"
#define PLUGIN_NAME			    "sm_translator"
#define DEBUG 0

public Plugin myinfo =
{
	name = "SM Translator",
	description = "Translate chat messages",
	author = "Franc1sco franug, HarryPotter",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	bLate = late;
	return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar g_hCvarEnable, g_hCvarDefault;
bool g_bCvarEnable, g_bCvarDefault;

char ServerLang[8];
char ServerCompleteLang[32];

bool 
	g_bTranslator[MAXPLAYERS + 1],
	g_bHasSelectMenu[MAXPLAYERS+1];

StringMap 
	g_smCodeToGoogle;

public void OnPluginStart()
{
	GetLanguageInfo(GetServerLanguage(), ServerLang, sizeof(ServerLang), ServerCompleteLang, sizeof(ServerCompleteLang));

	LoadTranslations("sm_translator.phrases.txt");

	g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",        "1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarDefault 		= CreateConVar( PLUGIN_NAME ... "_default",       "0",   "When new player connects, 0=Display menu to ask if player 'yes' or 'no', 1=Auto enable translator for player + Don't display menu", CVAR_FLAGS, true, 0.0, true, 1.0);
	CreateConVar(                       PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                PLUGIN_NAME);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDefault.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_connect", 		Event_PlayerConnect); //換圖不會觸發該事件

	RegConsoleCmd("sm_translator", Command_Translator, "");

	g_smCodeToGoogle = new StringMap();
	g_smCodeToGoogle.SetString("zho", "zh-TW");
	g_smCodeToGoogle.SetString("chi", "zh-CN");
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

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarDefault = g_hCvarDefault.BoolValue;
}

// Sourcemod API Forward-------------------------------

bool g_bFirst = true;
public void OnConfigsExecuted()
{
	GetCvars();
	if(g_bFirst)
	{
		g_bFirst = false;
		if(bLate)
		{
			LateLoad();
		}

		for(int i = 0; i <= MaxClients; i++)
		{
			g_bTranslator[i] = g_bCvarDefault;
			g_bHasSelectMenu[i] = false;
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	if(g_bHasSelectMenu[client]) return;
	if(IsFakeClient(client)) return;
	if(g_bCvarDefault) return;

	CreateTimer(4.0, Timer_ShowMenu, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientSayCommand_Post(int client, const char[] command, const char[] sArgs)
{
	if (!g_bCvarEnable) return;
	if (!IsValidClient(client)) return;
	if (!g_bTranslator[client]) return;

	if (sArgs[0] == '!' || sArgs[0] == '/') return;
	if (CommandExists(sArgs)) return;
	
	static char buffer[255];
	FormatEx(buffer,sizeof(buffer),"%s",sArgs);
	StripQuotes(buffer);

	if (strlen(buffer) <= 0) return;

	bool bTeamChat = false;
	if (strcmp(command, "say_team") == 0)
	{
		bTeamChat = true;
	}
	int iClientTeam = GetClientTeam(client);
	
	int iClientLanguage, iTargetLanguage, iServerLanguage;
	iClientLanguage = GetClientLanguage(client);
	static char sServerLanguage[8], sSourceLanguage[8], sTargetLanguage[8];
	iServerLanguage = GetServerLanguage();
	GetLanguageInfo(iServerLanguage, sServerLanguage, sizeof(sServerLanguage)); // get Server language
	GetLanguageInfo(iClientLanguage, sSourceLanguage, sizeof(sSourceLanguage)); // get client language
	
	// Foreign language
	if(iServerLanguage != iClientLanguage)
	{
		Handle request = CreateRequest(sSourceLanguage, sServerLanguage, buffer, client, 0, bTeamChat);
		SteamWorks_SendHTTPRequest(request);
		
		for(int player = 1; player <= MaxClients; player++)
		{
			if(player == client) continue;
			if(!IsClientInGame(player)) continue;
			if(IsFakeClient(player)) continue;
			if(bTeamChat && GetClientTeam(player) != iClientTeam) continue;

			iTargetLanguage = GetClientLanguage(player);
			if(iClientLanguage == iTargetLanguage) continue;

			GetLanguageInfo(iTargetLanguage, sTargetLanguage, sizeof(sTargetLanguage)); // get Target language
			Handle request2 = CreateRequest(sSourceLanguage, sTargetLanguage, buffer, player, client, bTeamChat); // Translate Foreign msg to other player
			SteamWorks_SendHTTPRequest(request2);
		}
	}
	else // Match server language
	{
		if(bTeamChat)
		{
			C_PrintToChatEx(client, client, "(%T) {teamcolor}%N {%T}{default}: %s", "Team", client, client, "translated for others", client, buffer);
		}
		else
		{
			C_PrintToChatEx(client, client, "{teamcolor}%N {%T}{default}: %s", client, "translated for others", client, buffer);
		}

		for(int player = 1; player <= MaxClients; player++)
		{
			if(player == client) continue;
			if(!IsClientInGame(player)) continue;
			if(IsFakeClient(player)) continue;
			if(bTeamChat && GetClientTeam(player) != iClientTeam) continue;
			iTargetLanguage = GetClientLanguage(player);

			if(iClientLanguage == iTargetLanguage) continue;

			GetLanguageInfo(iTargetLanguage, sTargetLanguage, sizeof(sTargetLanguage)); // get Target language
			Handle request = CreateRequest(sServerLanguage, sTargetLanguage, buffer, player, client, bTeamChat); // Translate msg to other player
			SteamWorks_SendHTTPRequest(request);
		}
	}
}

// Command-------------------------------

Action Command_Translator(int client, int args)
{
	DoMenu(client);

	return Plugin_Handled;
}

// Event-------------------------------

void Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(2.0, Timer_OnClientConnected, event.GetInt("userid"), TIMER_FLAG_NO_MAPCHANGE);
}

// Timer-------------------------------

Action Timer_OnClientConnected(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientConnected(client) || IsFakeClient(client)) return Plugin_Continue;

	g_bTranslator[client] = g_bCvarDefault;
	g_bHasSelectMenu[client] = false;
	return Plugin_Continue;
}

Action Timer_ShowMenu(Handle timer, int userid)
{
	if(!g_bCvarEnable) return Plugin_Continue;

	int client = GetClientOfUserId(userid);

	if (!client || !IsClientInGame(client)) return Plugin_Continue;

	//if (GetServerLanguage() == GetClientLanguage(client)) return Plugin_Continue;

	DoMenu(client);

	return Plugin_Continue;
}

// Menu-------------------------------

void DoMenu(int client)
{
	static char temp[128], clientLang[8], clientLangFull[128];
	
	Menu menu = new Menu(Menu_select);
	menu.SetTitle("%T", "This server have a translation plugin so you can talk in your own language and it will be translated to others.Use translator?",client);
	
	GetLanguageInfo(GetClientLanguage(client), clientLang, sizeof(clientLang), clientLangFull, sizeof(clientLangFull));
	Format(temp, sizeof(temp), "%T (%s)", "Yes, translate my word to other players", client, clientLangFull);
	menu.AddItem("yes", temp);
	
	Format(temp, sizeof(temp), "%T (%s)","No, I want to use chat in the official server language by my own", client, ServerCompleteLang);
	menu.AddItem("no", temp);
	menu.Display(client, MENU_TIME_FOREVER);
}

int Menu_select(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char selection[128];
		menu.GetItem(param, selection, sizeof(selection));
		
		if (StrEqual(selection, "yes")) g_bTranslator[client] = true;
		else g_bTranslator[client] = false;

		g_bHasSelectMenu[client] = true;
		CPrintToChat(client, "{lightgreen}[TRANSLATOR]{green} %T", "Type in chat !translator for open again this menu", client);
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

// HTTP-------------------------------

Handle CreateRequest(const char source[8], const char target[8], const char input[255], int client, int other = 0, bool bTeamChat = false)
{
	static char GoogleSourceCode[8], GoogleTargetCode[8];
	if(g_smCodeToGoogle.ContainsKey(source))
	{
		g_smCodeToGoogle.GetString(source, GoogleSourceCode, sizeof(GoogleSourceCode));
	}
	else
	{
		FormatEx(GoogleSourceCode, sizeof(GoogleSourceCode), "%s", source);
	}

	if(g_smCodeToGoogle.ContainsKey(target))
	{
		g_smCodeToGoogle.GetString(target, GoogleTargetCode, sizeof(GoogleTargetCode));
	}
	else
	{
		FormatEx(GoogleTargetCode, sizeof(GoogleTargetCode), "%s", target);
	}

	/*Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, "http://www.headlinedev.xyz/translate/translate.php");
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "input", input);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "target", target);*/

	//PrintToChatAll("原始語言=%s, 翻譯成語言=%s", source, target);

	Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, "http://translate.googleapis.com/translate_a/single");
	SteamWorks_SetHTTPCallbacks(request, Callback_OnHTTPResponse);
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "client", "gtx");
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "dt", "t");    
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "sl", GoogleSourceCode);//from en default, so you might wanna add this param too to modify.
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "tl", GoogleTargetCode);//to desired.. target language
	SteamWorks_SetHTTPRequestGetOrPostParameter(request, "q", input);//input text
	//final url would be something like this  https://translate.googleapis.com/translate_a/single?client=gtx&dt=t&sl=en&tl=es&q=hello
	//response example [[["Hola","hello",null,null,10]],null,"en",null,null,null,null,[]]  so we need to parse json on Callback_OnHTTPResponse >  JSON.parse(response)[0][0][0] = Hola

	DataPack hPack = new DataPack();
	hPack.WriteCell( other>0 ? GetClientUserId(other) : 0);
	hPack.WriteCell(bTeamChat);
	SteamWorks_SetHTTPRequestContextValue(request, GetClientUserId(client), hPack);
	return request;
}

void Callback_OnHTTPResponse(Handle request, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, int userid, DataPack hPack)
{
	if (!bRequestSuccessful || eStatusCode != k_EHTTPStatusCode200OK)
	{        
		delete request;
		delete hPack;
		return;
	}

	int iBufferSize;
	SteamWorks_GetHTTPResponseBodySize(request, iBufferSize);

	char[] result = new char[iBufferSize];
	SteamWorks_GetHTTPResponseBodyData(request, result, iBufferSize);
	delete request;

	hPack.Reset();
	int other = hPack.ReadCell();
	bool bTeamChat = hPack.ReadCell();
	delete hPack;

	static char strval[512];

	JSON_Array arr = view_as<JSON_Array>(json_decode(result));
	if(arr == null)
	{
		return;
	}

	JSON_Array arr2 = view_as<JSON_Array>(arr.GetObject(0));
	if(arr2 == null)
	{
		json_cleanup_and_delete(arr);
		return;
	}

	JSON_Array arr3 = view_as<JSON_Array>(arr2.GetObject(0));
	if(arr3 == null)
	{
		json_cleanup_and_delete(arr);
		return;
	}
	
	arr3.GetString(0, strval, sizeof(strval));

	// fixed memory leak ( Warning: plugin sm_translator.smx is using more than 100000 handles!)
	json_cleanup_and_delete(arr);
	

	int client = GetClientOfUserId(userid);

	if (!client || !IsClientInGame(client)) 
	{
		return;
	}

	if(other == 0)
	{
		//PrintToChatAll("To Server Language: %s", strval);
		if(bTeamChat)
		{
			C_PrintToChatEx(client, client, "(%T) {teamcolor}%N {%T}{default}: %s", "Team", client, client, "translated for others", client, strval);
		}
		else
		{
			C_PrintToChatEx(client, client, "{teamcolor}%N {%T}{default}: %s", client, "translated for others", client, strval);
		}
	}
	else
	{
		//PrintToChatAll("To Other Player %N Language: %s", client, strval);

		int source = GetClientOfUserId(other);

		if (!source || !IsClientInGame(source))
		{
			return;
		}
		
		if(bTeamChat)
		{
			C_PrintToChatEx(client, source, "(%T) {teamcolor}%N {%T}{default}: %s", "Team", client, source, "translated for you", client, strval);
		}
		else
		{	
			C_PrintToChatEx(client, source, "{teamcolor}%N {%T}{default}: %s", source, "translated for you", client, strval);
		}
	}
}  

bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true)
{
	if (!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}