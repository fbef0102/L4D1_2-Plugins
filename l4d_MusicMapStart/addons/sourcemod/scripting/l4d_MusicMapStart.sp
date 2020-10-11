#define PLUGIN_VERSION		"0.5"

/*
	ChangeLog:
	0.5 (16-6-2019)
	 - say !mp3off or !mp3on to turn off/on music
	
	0.4 (15-6-2019)
	 - playing music to all client when first round and second round start.
	 - delete auto exec config (some people prefer that, but I don't like it)
	
	0.3 (24-Mar-2019)
	 - Little optimizations.
	 - Added "Next track" menu in debug mode.
	
	0.2 (09-Mar-2019)
	 - Added external file list config.
	 - Added batch file to simplify file list preparation.
	 - Extended debug-mode. Command: sm_music -1 to play (test) next sound.
	 - Added ConVars.
	
	0.1 (14-Feb-2019)
	 - First alpha release
	 
	TODO:
	 
	 Add cookie for:
	  - Volume level
	  - Show this menu on start
	  - Play music on start
	 
	Description:
	 
	 This plugin is intended to play one random music on each new map start (the same one music will be played on round re-start).
	 Only one song will be downloaded to client each map start, so it will reduce client connection delay.
	 In this way, you can install infinite number of music tracks on your server without sacrificing connection speed.
	 
	Required:
	 - music in 44100 Hz sample rate (e.g.: use https://www.inspire-soft.net/software/mp3-quality-modifier tool).
	 - content-server with uploaded tracks.
	 - run sound/valentine/create_list.bat file to create the list.
	 - ConVars in your server.cfg:
	 1. sm_cvar sv_allowdownload "1"
	 2. sm_cvar sv_downloadurl "http://your-content-server.com/game/left4dead/" <= here is your sound/valentine/ *.mp3
	 - don't forget to edit translations/MusicMapStart.phrases.txt greetings and congratulations.
	 - set #define DEBUG 1, compile plugin and test it with sm_music -1 to check every track is correctly played.
	 
	Commands:
	 
	 sm_music - open music menu
	 sm_music <arg> - play specific music by id, where arg should be 0 .. to max or -1 to play next index (Use together with #DEBUG 1 mode only!)
	 sm_music_update - populate music list from config (use, if you replaced config file without server/plugin restart).
	
	Known bugs:
	 - sometimes "PlayAgain" button is not working. You need to press it several times.
	 - some map start game sounds interrupt music sound, so you need to set large enough value for "l4d_music_mapstart_delay" ConVar (like > 10, by default == 17)
	
	Thanks to:
	 
	 - Lux - for some suggestions on sound channel
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
    name = "Round start music",
    author = "Dragokasm & HarryPotter",
    description = "Download and play one random music on map start/round start",
    version = PLUGIN_VERSION,
    url = "https://github.com/dragokas/hijackthis"
}

#define DEBUG 0

#if DEBUG
	#define CACHE_ALL_SOUNDS 1
#else
	#define CACHE_ALL_SOUNDS 0
#endif

#define CVAR_FLAGS		FCVAR_NOTIFY
#define SNDCHAN_DEFAULT SNDCHAN_STATIC // SNDCHAN_AUTO

EngineVersion g_Engine;

ArrayList g_SoundPath;

int g_iSndIdx;

float g_fSoundVolume[MAXPLAYERS+1];

char g_sListPath[PLATFORM_MAX_PATH];

ConVar g_hCvarEnable;
ConVar g_hCvarDelay;
ConVar g_hCvarShowMenu;
bool g_bEnabled;
static bool IsClientMuteMp3[MAXPLAYERS+1];

public void OnPluginStart()
{
	LoadTranslations("MusicMapStart.phrases");
	
	g_Engine = GetEngineVersion();
	
	CreateConVar(							"l4d_music_mapstart_version",				PLUGIN_VERSION,	"Plugin version", FCVAR_DONTRECORD );
	g_hCvarEnable = CreateConVar(			"l4d_music_mapstart_enable",				"1",			"Enable plugin (1 - On / 0 - Off)", CVAR_FLAGS );
	g_hCvarDelay = CreateConVar(			"l4d_music_mapstart_delay",					"1.0",			"Delay (in sec.) after round starts or player join server playing the music", CVAR_FLAGS );
	g_hCvarShowMenu = CreateConVar(			"l4d_music_mapstart_showmenu",				"0",			"Show !music menu on round start? (1 - Yes, 0 - No)", CVAR_FLAGS );
	
	RegConsoleCmd("sm_music", 			Cmd_Music, 			"Player menu");
	RegConsoleCmd("sm_music_update", 	Cmd_MusicUpdate, 	"Populate music list from config");
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say);

	g_SoundPath = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	
	BuildPath(Path_SM, g_sListPath, sizeof(g_sListPath), "data/music_mapstart.txt");
	
	if (!UpdateList())
		SetFailState("Cannot open config file \"%s\"!", g_sListPath);
	
	HookConVarChange(g_hCvarEnable,				ConVarChanged);
	GetCvars();
	
	for (int j = 1; j <= MaxClients; j++)
	{
		g_fSoundVolume[j] = 1.0;
		IsClientMuteMp3[j] = false;
	}
		
	SetRandomSeed(GetTime());
	
	if(g_Engine == Engine_Left4Dead)
		OnMapStart();
}

public Action Command_Say(int client, int args)
{
	if(args < 1)
	{
		return Plugin_Continue;
	}
	char sayWord[MAX_NAME_LENGTH];
	GetCmdArg(1, sayWord, sizeof(sayWord));
	
	if(StrEqual(sayWord, "!mp3off", true)||StrEqual(sayWord, "/mp3off", true))
	{
		IsClientMuteMp3[client] = true;
		PrintToChat(client,Translate(client, "%t", "UnMute"));
		return Plugin_Handled;
	}
	
	if(StrEqual(sayWord, "!mp3on", true)||StrEqual(sayWord, "/mp3on", true))
	{
		IsClientMuteMp3[client] = false;
		PrintToChat(client,Translate(client, "%t", "Mute"));
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	InitHook();
}

void GetCvars()
{
	g_bEnabled = g_hCvarEnable.BoolValue;
	InitHook();
}

void InitHook()
{
	static bool bHooked;
	
	if (g_bEnabled) {
		if (!bHooked) {
			HookEvent("round_start", 			Event_RoundStart,	EventHookMode_PostNoCopy);
			HookEvent("player_disconnect", 		Event_PlayerDisconnect,		EventHookMode_Pre);
			bHooked = true;
		}
	} else {
		if (bHooked) {
			UnhookEvent("round_start", 			Event_RoundStart,	EventHookMode_PostNoCopy);
			UnhookEvent("player_disconnect", 	Event_PlayerDisconnect,		EventHookMode_Pre);
			bHooked = false;
		}
	}
}

public Action Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_fSoundVolume[client] = 1.0; // restore defaults.
	return Plugin_Continue;
}

public Action Cmd_MusicUpdate(int client, int args)
{
	UpdateList(client);
	return Plugin_Handled;
}

bool UpdateList(int client = 0)
{
	char sLine[PLATFORM_MAX_PATH];
	File hFile = OpenFile(g_sListPath, "r");
	if( hFile == null )
	{
		if (client != 0)
			PrintToChat(client, "Cannot open config file \"%s\"!", g_sListPath);
		return false;
	}
	g_SoundPath.Clear();
	while( !hFile.EndOfFile() && hFile.ReadLine(sLine, sizeof(sLine)) )
	{
		int len = strlen(sLine);
		if (sLine[len-1] == '\n')
			sLine[--len] = '\0';
			
		if (client != 0)
			PrintToChat(client, "Added: %s", sLine);
		
		TrimString(sLine); // walkaround against line break bug
		g_SoundPath.PushString(sLine);
	}
	return true;
}

public Action Cmd_Music(int client, int args)
{
	
	ShowMusicMenu(client);
	
	#if DEBUG
	if (args > 0)
	{
		char sIdx[10];
		int iIdx;
		GetCmdArgString(sIdx, sizeof(sIdx));
		iIdx = StringToInt(sIdx);
		
		char sPath[PLATFORM_MAX_PATH];
		g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
		StopSound(client, SNDCHAN_DEFAULT, sPath);
		PrintToChat(client, "stop - %i - %s", g_iSndIdx, sPath);
		
		if (iIdx == -1) { // play next
			iIdx = g_iSndIdx + 1;
			if (iIdx >= g_SoundPath.Length)
				iIdx = 0;
		}
		
		g_SoundPath.GetString(iIdx, sPath, sizeof(sPath));
		EmitSoundCustom(client, sPath);
		PrintToChat(client, "play - %i - %s", iIdx, sPath);
		
		g_iSndIdx = iIdx;
	}
	#endif
	return Plugin_Handled;
}

public Action Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	CreateTimer(g_hCvarDelay.FloatValue, Timer_PlayMusic, TIMER_FLAG_NO_MAPCHANGE);	
}

public Action Timer_PlayMusic(Handle timer)
{
	
	char sPath[PLATFORM_MAX_PATH];
	g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
	for (int j = 1; j <= MaxClients; j++) 
		if (IsClientConnected(j)&&IsClientInGame(j)&&!IsFakeClient(j)&&!IsClientMuteMp3[j])
		{
			EmitSoundCustom(j, sPath);
			PrintToChat(j,Translate(j, "%t", "Mute"));
			if (g_hCvarShowMenu.BoolValue)
				ShowMusicMenu(j);
		}
}
public Action Timer_PlayMusicCleint(Handle timer,int client)
{
	
	if (IsClientConnected(client)&&IsClientInGame(client)&&!IsFakeClient(client)&&!IsClientMuteMp3[client])
	{
		char sPath[PLATFORM_MAX_PATH];
		g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
		EmitSoundCustom(client, sPath);
		if (g_hCvarShowMenu.BoolValue)
			ShowMusicMenu(client);
	}
}

void ShowMusicMenu(int client)
{
	Menu menu = new Menu(MenuHandler_MenuMusic, MENU_ACTIONS_DEFAULT);	
	menu.SetTitle("!music");
	menu.AddItem("1", Translate(client, "%t", "StopMusic"));
	menu.AddItem("2", Translate(client, "%t", "PlayAgain"));
	menu.AddItem("3", Translate(client, "%t", "Volume"));
	#if (DEBUG)
		menu.AddItem("4", Translate(client, "%t", "GoNext"));
	#endif
	
	menu.Pagination = MENU_NO_PAGINATION;
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
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
			
			char sItem[30];
			char sPath[PLATFORM_MAX_PATH];
			menu.GetItem(ItemIndex, sItem, sizeof(sItem));
			
			switch(StringToInt(sItem)) {
				case 1: {
					g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
					StopSound(client, SNDCHAN_DEFAULT, sPath);
				}
				case 2: {
					g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
					StopSound(client, SNDCHAN_DEFAULT, sPath);
					EmitSoundCustom(client, sPath);
				}
				case 3: {
					ShowVolumeMenu(client);
					return;
				}
				case 4: {
					ClientCommand(client, "sm_music -1");
					return;
				}
			}
			ShowMusicMenu(client);
		}
	}
}

void ShowVolumeMenu(int client)
{
	Menu menu = new Menu(MenuHandler_MenuVolume, MENU_ACTIONS_DEFAULT);	
	menu.SetTitle("%t", "NextVolume", client);
	menu.AddItem("0.2", "0.2");
	menu.AddItem("0.4", "0.4");
	menu.AddItem("0.6", "0.6");
	menu.AddItem("0.8", "0.8");
	menu.AddItem("1.0", "1.0");
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
			
			char sItem[30];
			char sPath[PLATFORM_MAX_PATH];
			menu.GetItem(ItemIndex, sItem, sizeof(sItem));
			
			g_fSoundVolume[client] = StringToFloat(sItem);
			g_SoundPath.GetString(g_iSndIdx, sPath, sizeof(sPath));
			StopSound(client, SNDCHAN_DEFAULT, sPath);
			EmitSoundCustom(client, sPath);
			
			ShowMusicMenu(client);
		}
	}
}

stock char[] Translate(int client, const char[] format, any ...)
{
	char buffer[192];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);
	return buffer;
}

public void OnMapStart()
{
	if (g_SoundPath.Length == 0)
		return;

	g_iSndIdx = GetRandomInt(0, g_SoundPath.Length - 1);
	
	char sSoundPath[PLATFORM_MAX_PATH];
	char sDLPath[PLATFORM_MAX_PATH];
	
	#if CACHE_ALL_SOUNDS
		for (int i = 0; i < g_SoundPath.Length; i++) {
			g_SoundPath.GetString(i, sSoundPath, sizeof(sSoundPath));
			Format(sDLPath, sizeof(sDLPath), "sound/%s", sSoundPath);
			AddFileToDownloadsTable(sDLPath);
			#if (DEBUG)
				PrintToChatAll("added to downloads: %s", sDLPath);
			#endif
			PrecacheSound(sSoundPath);
		}
	#else
		g_SoundPath.GetString(g_iSndIdx, sSoundPath, sizeof(sSoundPath));
		Format(sDLPath, sizeof(sDLPath), "sound/%s", sSoundPath);
		AddFileToDownloadsTable(sDLPath);
		PrecacheSound(sSoundPath);
	#endif
}

// Custom EmitSound to allow compatibility with all game engines
void EmitSoundCustom(
	int client, 
	const char[] sound, 
	int entity = SOUND_FROM_PLAYER,
	int channel = SNDCHAN_DEFAULT,
	int level = SNDLEVEL_NORMAL,
	int flags = SND_NOFLAGS,
	float volume = SNDVOL_NORMAL,
	int pitch = SNDPITCH_NORMAL,
	int speakerentity = -1,
	const float origin[3] = NULL_VECTOR,
	const float dir[3] = NULL_VECTOR,
	bool updatePos = true,
	float soundtime = 0.0)
{
	int clients[1];
	clients[0] = client;
	
	if (g_Engine == Engine_Left4Dead || g_Engine == Engine_Left4Dead2)
		level = SNDLEVEL_GUNFIRE;
	
	volume = g_fSoundVolume[client];
	
	EmitSound(clients, 1, sound, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
}

public void OnClientPutInServer(int client)
{
	CreateTimer(g_hCvarDelay.FloatValue, Timer_PlayMusicCleint,client);
}

public void OnClientConnected(int client)
{
  
  if(IsClientConnected(client)&&!IsClientInGame(client)&&!IsFakeClient(client))
	CreateTimer(6.0,TimerShowMessage,client);
}

public Action TimerShowMessage(Handle timer,int client)
{
  if((IsClientConnected(client)&&IsClientInGame(client)&&!IsFakeClient(client))||!IsClientConnected(client))
	return Plugin_Handled;
  ReplyToCommand(client,"===========================================");
  ReplyToCommand(client,"=   服务器下载需要的文件，请耐心等待...   =");
  ReplyToCommand(client,"=   Downloading files，please wait...     =");
  ReplyToCommand(client,"===========================================");
  
  CreateTimer(3.0,TimerShowMessage2,client,TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
  return Plugin_Handled;

}

public Action TimerShowMessage2(Handle timer,int client)
{
  if(!IsClientConnected(client))
	return Plugin_Stop;
  if(IsClientConnected(client)&&IsClientInGame(client)&&!IsFakeClient(client))
  {
	ReplyToCommand(client,"===========================================");
	ReplyToCommand(client,"=   服务器下载完成，正在進入伺服器...     =");
	ReplyToCommand(client,"=   Downloading finished，conneting...    =");
	ReplyToCommand(client,"===========================================");
	return Plugin_Stop;
  }

  ReplyToCommand(client,"===========================================");
  ReplyToCommand(client,"=   服务器下载需要的文件，请耐心等待...   =");
  ReplyToCommand(client,"=   Downloading files，please wait...     =");
  ReplyToCommand(client,"===========================================");
  
  return Plugin_Continue;
}