#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.8"

#define		DN_TAG		"[DHostName]"
#define		SYMBOL_LEFT		'('
#define		SYMBOL_RIGHT	')'

ConVar g_hHostName, g_hModeName, hostport;
char g_sModeName[64], sHostport[10];

public Plugin myinfo = 
{
	name = "L4D Dynamic Host Name",
	author = "Harry Potter",
	description = "Server name with txt file (Support any language)",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

public void OnPluginStart()
{
	g_hHostName	= FindConVar("hostname");

	hostport = FindConVar("hostport");
	g_hModeName = CreateConVar("l4d_current_mode", "", "League notice displayed on server name", FCVAR_SPONLY | FCVAR_NOTIFY);

	GetCvars();
	hostport.AddChangeHook(ConVarChanged_Cvars);
	g_hModeName.AddChangeHook(ConVarChanged_Cvars);

	ChangeServerName();
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();

	ChangeServerName();
}

void GetCvars()
{
	hostport.GetString(sHostport, sizeof(sHostport));
	g_hModeName.GetString(g_sModeName, sizeof(g_sModeName));
}

void ChangeServerName()
{
	static char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath),"configs/hostname/server_hostname_%s.txt", sHostport);
	
	static char readData[256];
	File file = OpenFile(sPath, "r");
	if(file == null)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath),"configs/hostname/server_hostname.txt", sHostport);
		file = OpenFile(sPath, "r");
		if(file == null)
		{
			LogError("File configs/hostname/server_hostname.txt doesn't exist!");
			return;
		}
		if(!IsEndOfFile(file)) ReadFileLine(file, readData, sizeof(readData));//讀一行
		file.Close();

		BuildPath(Path_SM, sPath, sizeof(sPath),"configs/hostname/server_hostname_%s.txt", sHostport);
		file = OpenFile(sPath, "a");
		file.WriteLine(readData);
		file.Close();
		
		file = OpenFile(sPath, "r");
	}

	if(!IsEndOfFile(file) && ReadFileLine(file, readData, sizeof(readData)))//讀一行
	{
		static char sNewName[128];
		if(strlen(g_sModeName) == 0)
			FormatEx(sNewName, sizeof(sNewName), "%s", readData);
		else
			FormatEx(sNewName, sizeof(sNewName), "%s%c%s%c", readData, SYMBOL_LEFT, g_sModeName, SYMBOL_RIGHT);
		
		g_hHostName.SetString(sNewName);
		LogMessage("%s New server name \"%s\"", DN_TAG, sNewName);
	}

	file.Close();
}
