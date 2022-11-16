#define PLUGIN_VERSION		"1.4h"

/*
	Credit to:
	 - Dragokasm - Original Plugin
	 - Lux - for some suggestions on sound channel
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <multicolors>

public Plugin myinfo =
{
    name = "Round start music",
    author = "Dragokasm & HarryPotter",
    description = "Download and play custom music in game",
    version = PLUGIN_VERSION,
    url = "https://forums.alliedmods.net/showthread.php?p=2644771"
}

#define CVAR_FLAGS		FCVAR_NOTIFY

ConVar g_hCvarEnable, g_hCvarPlay, g_hCvarDelay, g_hCvarShowMenu, g_hCvarPlay2,
	g_hCvarDelay2, g_hCvarShowMenu2, g_hCvarDownloadMusicNumber,
	g_hCvarPlayMusicCoolDown, g_hCvarPlayMusicAccess;
int g_iRoundStart, g_iPlayerSpawn, g_iDownloadMusicNumber;
bool g_bEnabled, g_bPlay, g_bShowMenu, g_bPlay2, g_bShowMenu2;
float g_fDelay, g_fDelay2, g_fCvarPlayMusicCoolDown;
char g_sAccesslvl[16];

ArrayList g_aFileSoundPath;
ArrayList g_aSoundPath;
ArrayList g_aFileNameTag;
ArrayList g_aNameTag;

int g_iGlobalPlayMusicIndex = -1;
char g_sListPath[PLATFORM_MAX_PATH];
static bool IsClientMuteMp3[MAXPLAYERS+1];
int g_iMenuPosition[MAXPLAYERS+1] = {0};
int g_iClientIdx[MAXPLAYERS+1] = {0};
float g_fSoundVolume[MAXPLAYERS+1];
float g_fPlayMusicTime;


public void OnPluginStart()
{
	LoadTranslations("MusicMapStart.phrases");
	
	CreateConVar(								"l4d_music_mapstart_version",				PLUGIN_VERSION,	"Plugin version", FCVAR_DONTRECORD);
	g_hCvarEnable = CreateConVar(				"l4d_music_mapstart_enable",				"1",			"Enable plugin. (1 - On / 0 - Off)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarPlay = CreateConVar(					"l4d_music_mapstart_play_roundstart",		"1",			"Play the music to everyone on round starts. (1 - Yes, 0 - No)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarDelay = CreateConVar(				"l4d_music_mapstart_delay_roundstart",		"1.0",			"Delay (in sec.) playing the music on round starts.", CVAR_FLAGS, true, 0.0);
	g_hCvarShowMenu = CreateConVar(				"l4d_music_mapstart_showmenu_roundstart",	"1",			"Show !music menu on round start? (1 - Yes, 0 - No)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarPlay2 = CreateConVar(				"l4d_music_mapstart_play_joinserver",		"1",			"Play the music to client after player joins server? (1 - Yes, 0 - No)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarDelay2 = CreateConVar(				"l4d_music_mapstart_delay_joinserver",		"3.0",			"Delay (in sec.) playing the music to client after player joins server.", CVAR_FLAGS, true, 0.0);
	g_hCvarShowMenu2 = CreateConVar(			"l4d_music_mapstart_showmenu_joinserver",	"0",			"Show !music menu after player joins server? (1 - Yes, 0 - No)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarDownloadMusicNumber = CreateConVar(	"l4d_music_mapstart_download_number",		"3",			"How many random music files to download from 'data/music_mapstart.txt' each map. [0 - all at once]", CVAR_FLAGS, true, 0.0);
	g_hCvarPlayMusicCoolDown = CreateConVar(	"l4d_music_mapstart_playmusic_cooldown",	"3.0",			"Time in seconds all players can not play music everyone can hear agagin from !music menu. (0=off)", CVAR_FLAGS, true, 0.0);
	g_hCvarPlayMusicAccess = CreateConVar(		"l4d_music_mapstart_playmusic_access_flag", "", 			"Players with these flags have access to play music that everyone can hear. (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
	
	AutoExecConfig(true, "l4d_MusicMapStart");

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged);
	g_hCvarPlay.AddChangeHook(ConVarChanged);
	g_hCvarDelay.AddChangeHook(ConVarChanged);
	g_hCvarShowMenu.AddChangeHook(ConVarChanged);
	g_hCvarPlay2.AddChangeHook(ConVarChanged);
	g_hCvarDelay2.AddChangeHook(ConVarChanged);
	g_hCvarShowMenu2.AddChangeHook(ConVarChanged);
	g_hCvarDownloadMusicNumber.AddChangeHook(ConVarChanged);
	g_hCvarPlayMusicCoolDown.AddChangeHook(ConVarChanged);
	g_hCvarPlayMusicAccess.AddChangeHook(ConVarChanged);


	RegConsoleCmd("sm_music", 			Cmd_Music, 			"Music menu");
	RegAdminCmd("sm_music_update", 	Cmd_MusicUpdate, ADMFLAG_BAN, "Update music list from config");
	RegConsoleCmd("mp3off", Cmd_MusicOff, "Turn off music when round start/join server");
	RegConsoleCmd("mp3on", Cmd_MusicOn, "Turn on music when round start/join server");

	g_aFileSoundPath = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_aSoundPath = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_aFileNameTag = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_aNameTag = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	
	BuildPath(Path_SM, g_sListPath, sizeof(g_sListPath), "data/music_mapstart.txt");
	
	if (!FileExists(g_sListPath))
		SetFailState("Cannot open config file \"%s\"!", g_sListPath);

	HookEvent("round_start", 			Event_RoundStart,	EventHookMode_PostNoCopy);
	HookEvent("player_spawn", Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("mission_lost", Event_RoundEnd); //wipe out
	HookEvent("map_transition", Event_RoundEnd); //mission complete
	HookEvent("player_disconnect", 		Event_PlayerDisconnect,		EventHookMode_Pre);

	for (int j = 1; j <= MaxClients; j++)
	{
		g_fSoundVolume[j] = 1.0;
		IsClientMuteMp3[j] = false;
	}
		
	SetRandomSeed(GetTime());

	//OnMapStart();
}

public void OnPluginEnd()
{
	ResetPlugin();
	delete g_aFileSoundPath;
	delete g_aSoundPath;
	delete g_aFileNameTag;
	delete g_aNameTag;
}

public void OnConfigsExecuted()
{
	UpdateList();

	if (g_aFileSoundPath.Length == 0)
		return;
	
	char sSoundPath[PLATFORM_MAX_PATH], sNameTag[PLATFORM_MAX_PATH];
	char sDLPath[PLATFORM_MAX_PATH];
	
	g_aSoundPath.Clear();
	g_aNameTag.Clear();
	int iChosenIndex, temp, iRand = -1, iTotalMusicsInFile = g_aFileSoundPath.Length;
	
	bool bDownloadAll;
	if (g_iDownloadMusicNumber == 0 || iTotalMusicsInFile <= g_iDownloadMusicNumber)
	{
		bDownloadAll = true;
	}
	else
	{
		bDownloadAll = false;
	}
	
	if(bDownloadAll)
	{
		g_aSoundPath = g_aFileSoundPath.Clone();
		g_aNameTag = g_aFileNameTag.Clone();
	}
	else
	{
		int[] iArray = new int[iTotalMusicsInFile];
		for (int i = 0; i < iTotalMusicsInFile; ++i)
			iArray[i] = i;
		
		for (int i = 0; i < g_iDownloadMusicNumber; i++) //for example, We need 2 random musics from music list
		{
			iRand = GetRandomInt(0, iTotalMusicsInFile-1); //Generate random number
			iChosenIndex = iArray[iRand];
			/*swap*/
			temp = iArray[iTotalMusicsInFile-1];
			iArray[iTotalMusicsInFile-1] = iArray[iRand];
			iArray[iRand] = temp;
			iTotalMusicsInFile-- ;
			/**/
			g_aFileSoundPath.GetString(iChosenIndex, sSoundPath, sizeof(sSoundPath));
			g_aSoundPath.PushString(sSoundPath);

			g_aFileNameTag.GetString(iChosenIndex, sNameTag, sizeof(sNameTag));
			g_aNameTag.PushString(sNameTag);
		}
	}
					
	
	for (int i = 0; i < g_aSoundPath.Length; i++) {
		g_aSoundPath.GetString(i, sSoundPath, sizeof(sSoundPath));
		Format(sDLPath, sizeof(sDLPath), "sound/%s", sSoundPath);
		AddFileToDownloadsTable(sDLPath);
		PrecacheSound(sSoundPath);
		//LogMessage("added to downloads: %s", sDLPath);
	}
	
	int i;
	for(i = sizeof(sSoundPath) -1 ; i >= 0; --i )
	{
		if(sSoundPath[i] == '/') break;
	}
	
	g_iGlobalPlayMusicIndex = -1;
}

public void OnClientPutInServer(int client)
{
	if(!IsClientInGame(client) || IsFakeClient (client) || !g_bEnabled || !g_bPlay2) return;

	g_fPlayMusicTime = 0.0;
	CreateTimer(g_fDelay2, Timer_PlayMusicNewPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
}


public void OnMapEnd()
{
	ResetPlugin();
}

public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bEnabled = g_hCvarEnable.BoolValue;
	g_bPlay = g_hCvarPlay.BoolValue;
	g_fDelay = g_hCvarDelay.FloatValue;
	g_bShowMenu = g_hCvarShowMenu.BoolValue;
	g_bPlay2 = g_hCvarPlay2.BoolValue;
	g_fDelay2 = g_hCvarDelay2.FloatValue;
	g_bShowMenu2 = g_hCvarShowMenu2.BoolValue;
	g_iDownloadMusicNumber = g_hCvarDownloadMusicNumber.IntValue;
	g_fCvarPlayMusicCoolDown = g_hCvarPlayMusicCoolDown.FloatValue;
	g_hCvarPlayMusicAccess.GetString(g_sAccesslvl,sizeof(g_sAccesslvl));
}

public Action Cmd_MusicOff(int client, int args)
{
	IsClientMuteMp3[client] = true;
	PrintToChat(client, "%T", "UnMute", client);
	return Plugin_Handled;
}

public Action Cmd_MusicOn(int client, int args)
{
	IsClientMuteMp3[client] = false;
	PrintToChat(client, "%T", "Mute", client);
	return Plugin_Handled;
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_fSoundVolume[client] = 1.0; // restore defaults.
	g_iClientIdx[client] = 0;
	g_iMenuPosition[client] = 0;
	return Plugin_Continue;
}

public Action Cmd_MusicUpdate(int client, int args)
{
	UpdateList(client);
	return Plugin_Handled;
}

bool UpdateList(int client = 0)
{
	char sSoundPath[PLATFORM_MAX_PATH];
	char buffer[PLATFORM_MAX_PATH];
	File hFile = OpenFile(g_sListPath, "r");
	if( hFile == null )
	{
		if (client != 0)
			PrintToChat(client, "Cannot open config file \"%s\"!", g_sListPath);

		delete hFile;
		return false;
	}

	g_aFileSoundPath.Clear();
	g_aFileNameTag.Clear();
	while( !hFile.EndOfFile() && hFile.ReadLine(buffer, sizeof(buffer)) )
	{
		int len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';
		
		TrimString(buffer); // walkaround against line break bug

		SplitString(buffer, " TAG-", sSoundPath, sizeof(sSoundPath));
		g_aFileSoundPath.PushString(sSoundPath);
		
		ReplaceString(buffer, sizeof(buffer), sSoundPath, "", false);
		ReplaceString(buffer, sizeof(buffer), " TAG- ", "", false);

		g_aFileNameTag.PushString(buffer);

		if (client != 0)
			PrintToChat(client, "Added: %s - %s", sSoundPath, buffer);
	}

	if(g_aFileSoundPath.Length == 0)
	{
		if (client != 0) PrintToChat(client, "Why No Any Music? You Fool!!!");
	}

	delete hFile;
	return true;
}

public Action Cmd_Music(int client, int args)
{
	if(g_bEnabled)
	{
		ShowMusicMenu(client);
	}
	return Plugin_Handled;
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_fPlayMusicTime = 0.0;

	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

public Action tmrStart(Handle timer)
{
	if(g_bEnabled && g_bPlay)
	{
		CreateTimer(g_fDelay, Timer_PlayMusicRoundStart, TIMER_FLAG_NO_MAPCHANGE);	
	}
	ResetPlugin();

	return Plugin_Continue;
}

public Action Timer_PlayMusicRoundStart(Handle timer)
{
	char sPath[PLATFORM_MAX_PATH];

	int iRandomIdx = GetRandomInt(0, g_aSoundPath.Length - 1);
	g_aSoundPath.GetString(iRandomIdx, sPath, sizeof(sPath));
	for (int j = 1; j <= MaxClients; j++) g_iClientIdx[j] = iRandomIdx;

	for (int j = 1; j <= MaxClients; j++) 
	{
		if (IsClientInGame(j) && !IsFakeClient(j))
		{
			StopSoundCustom(j);
			
			if(!IsClientMuteMp3[j])
			{
				EmitSoundCustom(j, sPath);
				PrintToChat(j, "%T", "Mute", j);
				if (g_bShowMenu)
					ShowMusicMenu(j, false);
			}
		}
	}

	return Plugin_Continue;
}

public Action Timer_PlayMusicNewPlayer(Handle timer, int client)
{
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		char sPath[PLATFORM_MAX_PATH];
		
		int iRandomIdx = GetRandomInt(0, g_aSoundPath.Length - 1);
		g_aSoundPath.GetString(iRandomIdx, sPath, sizeof(sPath));
		g_iClientIdx[client] = iRandomIdx;

		StopSoundCustom(client);
		
		if(!IsClientMuteMp3[client])
		{
			
			EmitSoundCustom(client, sPath);
			if (g_bShowMenu2)
				ShowMusicMenu(client, false);
		}
	}

	return Plugin_Continue;
}

void ShowMusicMenu(int client, bool forever = true)
{
	Menu menu = new Menu(MenuHandler_MenuMusic, MENU_ACTIONS_DEFAULT);	
	menu.SetTitle("%T", "Music Menu", client);
	menu.AddItem("1", Translate(client, "%t", "StopMusic"));
	menu.AddItem("2", Translate(client, "%t", "PlayAgain"));
	menu.AddItem("3", Translate(client, "%t", "Volume"));
	menu.AddItem("4", Translate(client, "%t", "ChooseMusic"));
	
	if(HasAccess(client, g_sAccesslvl))
		menu.AddItem("5", Translate(client, "%t", "PlayMusic"));
	
	menu.Pagination = MENU_NO_PAGINATION;
	menu.ExitButton = true;
	if (forever) menu.Display(client, MENU_TIME_FOREVER);
	else menu.Display(client, 20);
}

public int MenuHandler_MenuMusic(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Select:
		{
			int client = param1;
			int ItemIndex = param2;
			
			char sItem[32];
			char sPath[PLATFORM_MAX_PATH];
			menu.GetItem(ItemIndex, sItem, sizeof(sItem));
			
			switch(StringToInt(sItem)) {
				case 1: {
					StopSoundCustom(client);
				}
				case 2: {
					StopSoundCustom(client);

					g_aSoundPath.GetString(g_iClientIdx[client], sPath, sizeof(sPath));
					EmitSoundCustom(client, sPath);
				}
				case 3: {
					ShowVolumeMenu(client);
					return 0;
				}
				case 4: {
					ShowAllMenu(client, false);
					return 0;
				}
				case 5: {
					ShowAllMenu(client, true);
					return 0;
				}
			}
			ShowMusicMenu(client);
		}
	}

	return 0;
}

void ShowVolumeMenu(int client)
{
	Menu menu = new Menu(MenuHandler_MenuVolume, MENU_ACTIONS_DEFAULT);	
	menu.SetTitle("%T", "NextVolume", client);
	menu.AddItem("0.2", "0.2");
	menu.AddItem("0.4", "0.4");
	menu.AddItem("0.6", "0.6");
	menu.AddItem("0.8", "0.8");
	menu.AddItem("1.0", "1.0");

	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int MenuHandler_MenuVolume(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Cancel:
			if (param2 == MenuCancel_ExitBack)
				ShowMusicMenu(param1);
		
		case MenuAction_Select:
		{
			int client = param1;
			int ItemIndex = param2;
			
			char sItem[32];
			char sPath[PLATFORM_MAX_PATH];
			
			StopSoundCustom(client);
			
			menu.GetItem(ItemIndex, sItem, sizeof(sItem));
			g_fSoundVolume[client] = StringToFloat(sItem);
			g_aSoundPath.GetString(g_iClientIdx[client], sPath, sizeof(sPath));
			EmitSoundCustom(client, sPath);
			
			ShowMusicMenu(client);
		}
	}

	return 0;
}

void ShowAllMenu(int client, bool music_type)
{
	Menu menu = null;	
	char index[4];
	if(music_type)
	{
		menu = new Menu(MenuHandler_MenuPlayMusic, MENU_ACTIONS_DEFAULT);
		menu.SetTitle("%T", "PlayMusic", client);
	}
	else
	{
		menu = new Menu(MenuHandler_MenuChooseMusic, MENU_ACTIONS_DEFAULT);
		menu.SetTitle("%T", "ChooseMusic", client);
	}
	

	char sName[PLATFORM_MAX_PATH];
	for (int i = 0; i < g_aSoundPath.Length; i++) {
		IntToString(i, index, sizeof(index));
		g_aNameTag.GetString(i, sName, sizeof(sName));
		menu.AddItem(index, sName);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = true;
	menu.DisplayAt(client, g_iMenuPosition[client], MENU_TIME_FOREVER);
}

public int MenuHandler_MenuPlayMusic(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Cancel:
			if (param2 == MenuCancel_ExitBack)
				ShowMusicMenu(param1);
		
		case MenuAction_Select:
		{
			int client = param1;
			if(g_fPlayMusicTime < GetEngineTime())
			{
				char sItem[32];
				char sPath[PLATFORM_MAX_PATH];
				menu.GetItem(param2, sItem, sizeof(sItem));
				int MusicIndex = StringToInt(sItem);
				
				g_aSoundPath.GetString(MusicIndex, sPath, sizeof(sPath));
		
				char sName[PLATFORM_MAX_PATH];
				g_aNameTag.GetString(MusicIndex, sName, sizeof(sName));
				for (int j = 1; j <= MaxClients; j++) 
				{
					if (!IsClientInGame(j) || IsFakeClient(j)) continue;

					StopSoundCustom(j);
					StopSound(j, SNDCHAN_AUTO, sPath);
					if(!IsClientMuteMp3[j])
					{
						EmitSoundCustom(j, sPath);
					}

					CPrintToChat(j, "%T", "Request Song", j, client, sName);
					g_fPlayMusicTime = GetEngineTime() + g_fCvarPlayMusicCoolDown;
				}
				
				g_iGlobalPlayMusicIndex = MusicIndex;
			}
			else
			{
				CPrintToChat(client, "%T", "Too quickly", client, g_fCvarPlayMusicCoolDown);
			}

			g_iMenuPosition[client] = menu.Selection; 
			ShowAllMenu(client, true);
		}
	}

	return 0;
}


public int MenuHandler_MenuChooseMusic(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Cancel:
			if (param2 == MenuCancel_ExitBack)
				ShowMusicMenu(param1);
		
		case MenuAction_Select:
		{
			int client = param1;

			char sItem[32];
			char sPath[PLATFORM_MAX_PATH];
			menu.GetItem(param2, sItem, sizeof(sItem));
			int MusicIndex = StringToInt(sItem);
			
			StopSoundCustom(client);

			g_aSoundPath.GetString(MusicIndex, sPath, sizeof(sPath));
			g_iClientIdx[client] = MusicIndex;
	
			StopSound(client, SNDCHAN_AUTO, sPath);
			EmitSoundCustom(client, sPath);

			g_iMenuPosition[client] = menu.Selection; 
			ShowAllMenu(client, false);
		}
	}

	return 0;
}


stock char[] Translate(int client, const char[] format, any ...)
{
	char buffer[192];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);
	return buffer;
}

void EmitSoundCustom(int client, const char[] sound)
{
	float volume = g_fSoundVolume[client];
	EmitSoundToClient(client, sound, _, SNDCHAN_AUTO, SNDLEVEL_CONVO, _, volume, _, _, _, _, _, _);
}

void StopSoundCustom(int client)
{
	static char sPath[PLATFORM_MAX_PATH];
	if(g_iGlobalPlayMusicIndex >= 0)
	{
		g_aSoundPath.GetString(g_iGlobalPlayMusicIndex, sPath, sizeof(sPath));
		StopSound(client, SNDCHAN_AUTO, sPath);
	}
	
	g_aSoundPath.GetString(g_iClientIdx[client], sPath, sizeof(sPath));
	StopSound(client, SNDCHAN_AUTO, sPath);
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

public bool HasAccess(int client, char[] g_sAcclvl)
{
	// no permissions set
	if (strlen(g_sAcclvl) == 0)
		return true;

	else if (StrEqual(g_sAcclvl, "-1"))
		return false;

	// check permissions
	if ( GetUserFlagBits(client) & ReadFlagString(g_sAcclvl) )
	{
		return true;
	}

	return false;
}