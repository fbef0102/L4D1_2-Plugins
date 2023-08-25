#include <sourcemod>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[L4D & L4D2] Gamemode-based configs",
	author = "HarryPotter",
	version = "1.0",
	description = "Allows for custom settings for each gamemode and mutatuion.",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

ConVar g_hCvarMPGameMode;
char g_sCvarMPGameMode[32];

public void OnPluginStart()
{
	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.GetString(g_sCvarMPGameMode, sizeof(g_sCvarMPGameMode));
	g_hCvarMPGameMode.AddChangeHook(ConVarGameMode);
}

void ConVarGameMode(ConVar convar, const char[] oldValue, const char[] newValue)
{
	char sGameMode[32];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	if(strcmp(g_sCvarMPGameMode, sGameMode, false) == 0) return;

	g_hCvarMPGameMode.GetString(g_sCvarMPGameMode, sizeof(g_sCvarMPGameMode));
	//LogMessage("ConVarGameMode: %s", g_sCvarMPGameMode);
	ExecuteGamemodeCfg();
}

public void OnConfigsExecuted() //execute on late load
{
	g_hCvarMPGameMode.GetString(g_sCvarMPGameMode, sizeof(g_sCvarMPGameMode));
	ExecuteGamemodeCfg();
}

void ExecuteGamemodeCfg()
{
	char sGamemodeConfig[128];
	GetCurrentMap(sGamemodeConfig, sizeof(sGamemodeConfig));
	Format(sGamemodeConfig, sizeof(sGamemodeConfig), "cfg/sourcemod/gamemode_cvars/%s.cfg", g_sCvarMPGameMode);
	if (FileExists(sGamemodeConfig, true))
	{
		strcopy(sGamemodeConfig, sizeof(sGamemodeConfig), sGamemodeConfig[4]);
		ServerCommand("exec \"%s\"", sGamemodeConfig);
		PrintToServer("Server executes \"%s\"", sGamemodeConfig);
	}
	else
	{
		File fileTemp = OpenFile(sGamemodeConfig, "w");
		if (fileTemp == null)
		{
			SetFailState("Something went wrong while creating the file: %s!", sGamemodeConfig);
			delete fileTemp;
			return;
		}

		char sInfo[128];
		FormatEx(sInfo, sizeof(sInfo), "// This is for gamemode: %s", g_sCvarMPGameMode);
		fileTemp.WriteLine(sInfo);

		delete fileTemp;
	}
}