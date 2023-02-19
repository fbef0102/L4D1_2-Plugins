/*
 * In-game Help Menu
 * Written by chundo (chundo@mefightclub.com)
 * v0.4 Edit by emsit -> Transitional Syntax, added command sm_commands, added command sm_helpmenu_reload, added cvar sm_helpmenu_autoreload, added cvar sm_helpmenu_config_path, added panel/PrintToChat when command does not exist or item value is text
 * v0.5 Edit by JoinedSenses -> Additional syntax updating, bug fixes, and an additional CommandExists check for the custom menu handler.
 * Licensed under the GPL version 2 or above
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <clientprefs>
#include <multicolors>
#undef REQUIRE_PLUGIN
#tryinclude <readyup>

#define PLUGIN_VERSION "0.8"

enum HelpMenuType {
	HelpMenuType_List,
	HelpMenuType_Text
}

enum struct HelpMenu {
	char name[32];
	char title[128];
	HelpMenuType type;
	DataPack items;
	int itemCount;
}

// CVars
ConVar
	  g_cvarWelcome
	, g_cvarAdmins
	, g_cvarRotation
	, g_cvarReload
	, g_cvarConfigPath
	, g_cvarSteamGroup
	, g_cvarDoNotDisplay;

// Help menus
ArrayList g_helpMenus;

// Map cache
ArrayList g_mapArray;
int g_mapSerial = -1;

// Config parsing
int g_configLevel = -1;

public Plugin myinfo = {
	name = "In-game Help Menu",
	author = "chundo, emsit, joinedsenses, HarryPotter",
	description = "Display a help menu to users",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=637467"
};

Handle g_hCookieMenu;

bool g_bShow[MAXPLAYERS + 1];

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	bLate = late;
	return APLRes_Success; 
}

public void OnPluginStart() 
{
	LoadTranslations("helpmenu.phrases");

	g_hCookieMenu = RegClientCookie("l4d2_help_menu", "Future", CookieAccess_Protected);
			
	CreateConVar("sm_helpmenu_version", PLUGIN_VERSION, "Help menu version", FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_NOTIFY).SetString(PLUGIN_VERSION);
	g_cvarWelcome = CreateConVar("sm_helpmenu_welcome", "1", "Show welcome message and help menu to newly connected users.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarAdmins = CreateConVar("sm_helpmenu_admins", "1", "Show a list of online admins in the menu.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarRotation = CreateConVar("sm_helpmenu_rotation", "0", "Shows the map rotation in the menu.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarReload = CreateConVar("sm_helpmenu_autoreload", "1", "Automatically reload the configuration file when changing the map.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarConfigPath = CreateConVar("sm_helpmenu_config_path", "configs/helpmenu.cfg", "Path to configuration file.");
	g_cvarSteamGroup = CreateConVar("sm_helpmenu_steam_group", "1", "Show 'Join our steam group' item in the menu.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvarDoNotDisplay = CreateConVar("sm_helpmenu_do_not_display", "1", "Show 'Don't display again' and 'Display again next time' item in the menu.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	RegConsoleCmd("sm_help", Command_HelpMenu, "Display the help menu.");
	RegConsoleCmd("sm_helpmenu", Command_HelpMenu, "Display the help menu.");
	RegConsoleCmd("sm_helpcommands", Command_HelpMenu, "Display the help menu.");
	RegConsoleCmd("sm_helpcomands", Command_HelpMenu, "Display the help menu.");
	RegConsoleCmd("sm_helpcommand", Command_HelpMenu, "Display the help menu.");
	RegConsoleCmd("sm_helpcomand", Command_HelpMenu, "Display the help menu.");
	RegConsoleCmd("sm_commands", Command_HelpMenu, "Display the help menu.");
	RegConsoleCmd("sm_comands", Command_HelpMenu, "Display the help menu.");
	RegConsoleCmd("sm_cmds", Command_HelpMenu, "Display the help menu.");
	RegConsoleCmd("sm_cmd", Command_HelpMenu, "Display the help menu.");
	RegConsoleCmd("sm_helpoff", Command_HelpMenuOff, "Disable the help menu forever.");
	RegConsoleCmd("sm_helpon", Command_HelpMenuOn, "Enable the help menu next time.");
	RegAdminCmd("sm_helpmenu_reload", Command_HelpMenuReload, ADMFLAG_ROOT, "Reload the help menu configuration file");

	g_mapArray = new ArrayList(ByteCountToCells(80));
	g_helpMenus = new ArrayList(sizeof(HelpMenu));

	char hc[PLATFORM_MAX_PATH];
	char buffer[PLATFORM_MAX_PATH];

	g_cvarConfigPath.GetString(buffer, sizeof(buffer));
	BuildPath(Path_SM, hc, sizeof(hc), "%s", buffer);
	ParseConfigFile(hc);

	AutoExecConfig(true, "helpmenu");

	if (bLate)
	{
		for ( int i = 1; i <= MaxClients; i++ )
		{
			if ( IsClientInGame(i) )
			{
				OnClientPutInServer(i);
			}
		}
	}
}

bool g_ReadyUpAvailable;
public void OnAllPluginsLoaded()
{
	g_ReadyUpAvailable = LibraryExists("readyup");
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "readyup") == 0) g_ReadyUpAvailable = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "readyup")) g_ReadyUpAvailable = true;
}

public void OnClientCookiesCached(int iClient)
{
	char szValue[4];
	
	GetClientCookie(iClient, g_hCookieMenu, szValue, sizeof szValue);

	if(szValue[0])
	{
		g_bShow[iClient] = view_as<bool>(StringToInt(szValue));
	}
	else
	{
		g_bShow[iClient] = true;
	}
}

public void OnClientDisconnect(int client)
{
	if(!IsFakeClient(client))
	{
		char szValue[4];
		IntToString(view_as<int>(g_bShow[client]), szValue, 4);
		SetClientCookie(client, g_hCookieMenu, szValue);
	}
}

public void OnMapStart() 
{
	if (g_cvarReload.BoolValue) 
	{
		char hc[PLATFORM_MAX_PATH];
		char buffer[PLATFORM_MAX_PATH];

		g_cvarConfigPath.GetString(buffer, sizeof(buffer));
		BuildPath(Path_SM, hc, sizeof(hc), "%s", buffer);
		ParseConfigFile(hc);
	}
}

public void OnClientPutInServer(int client)
{
	OnClientCookiesCached(client);
	CreateTimer(5.0, Timer_WelcomeMessage, GetClientUserId(client));
}

public Action Timer_WelcomeMessage(Handle timer, int userid) {
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && !IsFakeClient(client)) {
		if(g_cvarWelcome.BoolValue)
		{
			CPrintToChat(client, "%T", "WelcomeMessage", client);
			if(g_bShow[client])
			{
				Help_ShowMainMenu(client);
				if(g_ReadyUpAvailable)
				{
					ToggleReadyPanel(false, client);
					CreateTimer(30.0, Timer_ToggleReadyPanel, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}

	return Plugin_Continue;
}

bool ParseConfigFile(const char[] file) {
	int msize = g_helpMenus.Length;
	if(msize > 0)
	{
		HelpMenu hmenu;
		g_helpMenus.GetArray(msize-1, hmenu);
		delete hmenu.items;
	}
	g_helpMenus.Clear();

	SMCParser parser = new SMCParser();
	parser.OnEnterSection = Config_NewSection;
	parser.OnLeaveSection = Config_EndSection;
	parser.OnKeyValue = Config_KeyValue;
	parser.OnEnd = Config_End;

	int line = 0;
	int col = 0;
	char error[128];
	SMCError result = parser.ParseFile(file, line, col);
	if (result != SMCError_Okay) {
		parser.GetErrorString(result, error, sizeof(error));
		LogError("%s on line %d, col %d of %s", error, line, col, file);
	}
	delete parser;
	return (result == SMCError_Okay);
}

public SMCResult Config_NewSection(SMCParser parser, const char[] section, bool quotes) {
	++g_configLevel;
	if (g_configLevel == 1) {
		HelpMenu hmenu;
		strcopy(hmenu.name, sizeof(HelpMenu::name), section);
		hmenu.items = new DataPack();
		hmenu.itemCount = 0;
		if (g_helpMenus == null) {
			g_helpMenus = new ArrayList(sizeof(HelpMenu));
		}
		g_helpMenus.PushArray(hmenu);
	}

	return SMCParse_Continue;
}

public SMCResult Config_KeyValue(SMCParser parser, const char[] key, const char[] value, bool key_quotes, bool value_quotes) {
	int msize = g_helpMenus.Length;
	HelpMenu hmenu;
	g_helpMenus.GetArray(msize-1, hmenu);
	switch (g_configLevel) {
		case 1: {
			if (strcmp(key, "title", false) == 0) {
				strcopy(hmenu.title, sizeof(HelpMenu::title), value);
			}
			if (strcmp(key, "type", false) == 0) {
				if (strcmp(value, "text", false) == 0) {
					hmenu.type = HelpMenuType_Text;
				}
				else {
					hmenu.type = HelpMenuType_List;
				}
			}
		}
		case 2: {
			hmenu.items.WriteString(key);
			hmenu.items.WriteString(value);
			++hmenu.itemCount;
		}
	}
	g_helpMenus.SetArray(msize-1, hmenu);

	return SMCParse_Continue;
}
public SMCResult Config_EndSection(SMCParser parser) {
	--g_configLevel;
	
	if (g_configLevel == 1) {
		HelpMenu hmenu;
		int msize = g_helpMenus.Length;
		g_helpMenus.GetArray(msize-1, hmenu);
		hmenu.items.Reset();
	}

	return SMCParse_Continue;
}

public void Config_End(SMCParser parser, bool halted, bool failed) {
	if (failed) {
		SetFailState("Plugin configuration error");
	}
}

public Action Command_HelpMenu(int client, int args) {
	if (client == 0)
	{
		PrintToServer("[SM] This Command cannot be used by server.");
		return Plugin_Handled;
	}

	Help_ShowMainMenu(client);
	return Plugin_Handled;
}

public Action Command_HelpMenuReload(int client, int args) {
	char hc[PLATFORM_MAX_PATH];
	char buffer[PLATFORM_MAX_PATH];

	g_cvarConfigPath.GetString(buffer, sizeof(buffer));
	BuildPath(Path_SM, hc, sizeof(hc), "%s", buffer);
	ParseConfigFile(hc);

	if( client && IsClientInGame(client)) CPrintToChat(client, "%T", "Configuration file has been reloaded",client);

	return Plugin_Handled;
}

public Action Command_HelpMenuOff(int client, int args) {
	if (client == 0)
	{
		PrintToServer("[SM] This Command cannot be used by server.");
		return Plugin_Handled;
	}

	g_bShow[client] = false;

	CPrintToChat(client, "%T", "Auto menu", client, g_bShow[client] ? "enabled" : "disabled" , client);
	return Plugin_Handled;
}

public Action Command_HelpMenuOn(int client, int args) {
	if (client == 0)
	{
		PrintToServer("[SM] This Command cannot be used by server.");
		return Plugin_Handled;
	}

	g_bShow[client] = true;

	CPrintToChat(client, "%T", "Auto menu", client, g_bShow[client] ? "enabled" : "disabled" , client);
	return Plugin_Handled;
}

void Help_ShowMainMenu(int client) {
	Menu menu = new Menu(Help_MainMenuHandler);
	static char Info[256];
	FormatEx(Info, sizeof(Info), "%T\n ", "Welcome to Official Instructions", client);
	menu.SetTitle(Info);

	int msize = g_helpMenus.Length;
	HelpMenu hmenu;
	static char menuid[10];
	
	for (int i = 0; i < msize; ++i) {
		Format(menuid, sizeof(menuid), "helpmenu_%d", i);
		g_helpMenus.GetArray(i, hmenu);

		FormatEx(Info, sizeof(Info), "%T", hmenu.name, client);
		menu.AddItem(menuid, Info);
	}

	if (g_cvarRotation.BoolValue) {
		FormatEx(Info, sizeof(Info), "%T","Map Rotation", client);
		menu.AddItem("maplist", Info);
	}
	if (g_cvarAdmins.BoolValue) {
		FormatEx(Info, sizeof(Info), "%T","List Online Admins", client);
		menu.AddItem("admins", Info);
	}
	if(g_cvarSteamGroup.BoolValue)
	{
		FormatEx(Info, sizeof(Info), "%T","Join our steam group", client);
		menu.AddItem("steam_group", Info);
	}
	if(g_cvarDoNotDisplay.BoolValue)
	{
		if(g_bShow[client]) FormatEx(Info, sizeof(Info), "%T","Don't display again", client);
		else FormatEx(Info, sizeof(Info), "%T","Display again next time", client);
		menu.AddItem("showinfuture", Info);
	}
	menu.ExitBackButton = false;
	menu.Display(client, 30);
}

int Help_MainMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	switch(action) {
		case MenuAction_Select: {
			
			static char szItem[36];
			GetMenuItem(menu, param2, szItem, sizeof szItem);
			static char buf[256];

			if (strcmp(szItem, "showinfuture") == 0)
			{
				g_bShow[param1] = !g_bShow[param1];

				CPrintToChat(param1, "%T", "Auto menu", param1, g_bShow[param1] ? "enabled" : "disabled" , param1);
				Help_ShowMainMenu(param1);
				return 0;
			}
			else if (strcmp(szItem, "steam_group") == 0)
			{
				ShowMOTDPanel(param1, "", "", MOTDPANEL_TYPE_URL);
				return 0;
			}
			else if (strcmp(szItem, "admins") == 0)
			{
				Menu adminMenu = new Menu(Help_MenuHandler);
				adminMenu.ExitBackButton = true;
				FormatEx(buf, sizeof(buf), "%T\n ", "List Online Admins", param1);
				adminMenu.SetTitle(buf);
				static char aname[64];

				for (int i = 1; i <= MaxClients; ++i) {
					// override helpmenu_admin to change who shows in menu
					if (Client_IsValidHuman(i, true, false, true) && CheckCommandAccess(i, "helpmenu_admin", ADMFLAG_KICK)) {
						GetClientName(i, aname, sizeof(aname));
						adminMenu.AddItem(aname, aname, ITEMDRAW_DISABLED);
					}
				}
				adminMenu.Display(param1, MENU_TIME_FOREVER);
				return 0;
			}

			int msize = g_helpMenus.Length;
			if (param2 == msize) { // Maps
				Menu mapMenu = new Menu(Help_MenuHandler);
				mapMenu.ExitBackButton = true;
				ReadMapList(g_mapArray, g_mapSerial, "default");
				FormatEx(buf, sizeof(buf), "%T\n", "Current Rotation", param1, g_helpMenus.Length);
				mapMenu.SetTitle(buf);

				if (g_mapArray != null) {
					int mapct = g_mapArray.Length;
					static char mapname[64];
					for (int i = 0; i < mapct; ++i) {
						g_mapArray.GetString(i, mapname, sizeof(mapname));
						mapMenu.AddItem(mapname, mapname, ITEMDRAW_DISABLED);
					}
				}
				mapMenu.Display(param1, MENU_TIME_FOREVER);
			}
			else { // Menu from config file
				if (param2 <= msize) {
					HelpMenu hmenu;
					g_helpMenus.GetArray(param2, hmenu);
					char mtitle[512];
					if(TranslationPhraseExists(hmenu.title))
					{
						FormatEx(mtitle, sizeof(mtitle), "%T\n ", hmenu.title, param1);
					}
					else
					{
						FormatEx(mtitle, sizeof(mtitle), "%s\n ", hmenu.title);
					}
					if (hmenu.type == HelpMenuType_Text) {
						Menu menu2 = new Menu(Help_MenuHandler);
						menu2.SetTitle(mtitle);
						char text[128];
						char junk[128];

						int count = hmenu.itemCount;
						for (int i = 0; i < count; ++i) {
							hmenu.items.ReadString(junk, sizeof(junk));
							hmenu.items.ReadString(text, sizeof(text));
							if(TranslationPhraseExists(text))
							{
								FormatEx(buf, sizeof(buf), "%T", text, param1);
								menu2.AddItem("",buf);
							}
							else
							{
								menu2.AddItem("",text);
							}
						}

						menu2.ExitBackButton = true;
						menu2.Display(param1, MENU_TIME_FOREVER);
						hmenu.items.Reset();
					}
					else {
						Menu cmenu = new Menu(Help_CustomMenuHandler);
						cmenu.ExitBackButton = true;
						cmenu.SetTitle(mtitle);
						char cmd[128];
						char desc[128];

						int count = hmenu.itemCount;
						for (int i = 0; i < count; ++i) {
							hmenu.items.ReadString(cmd, sizeof(cmd));
							hmenu.items.ReadString(desc, sizeof(desc));
							int drawstyle = ITEMDRAW_DEFAULT;
							if (strlen(cmd) == 0) {
								drawstyle = ITEMDRAW_DISABLED;
							}
							if(TranslationPhraseExists(cmd))
							{
								FormatEx(buf, sizeof(buf), "%T", cmd, param1);
								cmenu.AddItem(cmd, buf, drawstyle);
							}
							else
							{
								//PrintToChatAll("here2: cmd - %s, desc - %s", cmd, desc);
								cmenu.AddItem(cmd, desc, drawstyle);
							}
						}

						hmenu.items.Reset();
						cmenu.Display(param1, MENU_TIME_FOREVER);
					}
				}
			}
		}
		case MenuAction_Cancel: {
			if (param2 == MenuCancel_ExitBack) {
				Help_ShowMainMenu(param1);
			}
		}
		case MenuAction_End: {
			delete menu;
		}
	}

	return 0;
}

int Help_MenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	switch(action) {
		case MenuAction_Select: {
			if (menu == null && param2 == 8) {
				Help_ShowMainMenu(param1);
			}
		}
		case MenuAction_Cancel: {
			if (param2 == MenuCancel_ExitBack) {
				Help_ShowMainMenu(param1);
			}
		}
		case MenuAction_End: {
			delete menu;
		}
	}

	return 0;
}

int Help_CustomMenuHandler(Menu menu, MenuAction action, int param1, int param2) {
	switch(action) {
		case MenuAction_Select: {
			char itemval[128];
			menu.GetItem(param2, itemval, sizeof(itemval));
			if (strlen(itemval) > 0) {
				char command[64];
				SplitString(itemval, " ", command, sizeof(command));

				if (CommandExist(command, sizeof(command)) || CommandExist(itemval, sizeof(itemval))) {
					FakeClientCommand(param1, itemval);
					//DisplayMenuAtItem(menu, param1, GetMenuSelectionPosition(), 200);
				}
				else {
					static char Info[256];
					Panel panel = new Panel();
					FormatEx(Info, sizeof(Info), "%T\n ", "Description", param1);
					panel.SetTitle(Info);

					panel.DrawText(itemval);

					panel.DrawText(" ");
					panel.DrawItem("Back", ITEMDRAW_CONTROL);
					panel.DrawItem(" ", ITEMDRAW_NOTEXT);
					panel.DrawText(" ");
					panel.DrawItem("Exit", ITEMDRAW_CONTROL);
					panel.Send(param1, Help_MenuHandler, MENU_TIME_FOREVER);
					delete panel;

					PrintToChat(param1, "{green}[SM] {default}%s", itemval);
				}
			}
		}
		case MenuAction_Cancel: {
			if (param2 == MenuCancel_ExitBack) {
				Help_ShowMainMenu(param1);
			}
		}
		case MenuAction_End: {
			delete menu;
		}
	}

	return 0;
}


bool Client_IsValidHuman(int client, bool connected = true, bool nobots = true, bool InGame = false) {
	if (!Client_IsValid(client, connected)) {
		return false;
	}

	if (nobots && IsFakeClient(client)) {
		return false;
	}

	if (InGame) {
		return IsClientInGame(client);
	}

	return true;
}

bool Client_IsValid(int client, bool checkConnected = true) {
	if (client > 4096) {
		client = EntRefToEntIndex(client);
	}

	if (client < 1 || client > MaxClients) {
		return false;
	}

	if (checkConnected && !IsClientConnected(client)) {
		return false;
	}

	return true;
}

stock bool CommandExist(char[] command, int commandLen) {
	//remove the character '!' from the beginning of the command
	if (command[0] == '!') {
		strcopy(command, commandLen, command[1]);
	}

	if (CommandExists(command)) {
		return true;
	}

	//if the command does not exist and has a prefix 'sm_'
	if (!strncmp(command, "sm_", 3)) {
		return false;
	}

	//add the prefix 'sm_' to the beginning of the command
	Format(command, commandLen, "sm_%s", command);

	return CommandExists(command);
}

Action Timer_ToggleReadyPanel(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client && IsClientInGame(client))
	{
		ToggleReadyPanel(true, client);
	}

	return Plugin_Continue;
}