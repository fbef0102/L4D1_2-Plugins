#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.7"

#define		DN_TAG		"[DHostName]"
#define		SYMBOL_LEFT		'('
#define		SYMBOL_RIGHT	')'

ConVar g_hHostName, g_hReadyUp;
char g_sDefaultN[68];

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
	g_hReadyUp = CreateConVar("l4d_current_mode", "", "League notice displayed on server name", FCVAR_SPONLY | FCVAR_NOTIFY);
	g_hHostName	= FindConVar("hostname");

	g_hHostName.GetString(g_sDefaultN, sizeof(g_sDefaultN));
	if (strlen(g_sDefaultN))//strlen():回傳字串的長度
		ChangeServerName();
}

public void OnConfigsExecuted()
{		
	if (!strlen(g_sDefaultN)) return;
	
	if (g_hReadyUp == INVALID_HANDLE){
	
		ChangeServerName();
		LogMessage("l4d_current_mode no found!");
	}
	else {
	
		char sReadyUpCfgName[128];
		GetConVarString(g_hReadyUp, sReadyUpCfgName, 128);

		ChangeServerName(sReadyUpCfgName);
	}
	
}

void ChangeServerName(char[] sReadyUpCfgName = "")
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath),"configs/hostname/server_hostname.txt");//檔案路徑設定
	
	Handle file = OpenFile(sPath, "r");//讀取檔案
	if(file == INVALID_HANDLE)
	{
		LogMessage("file configs/hostname/server_hostname.txt doesn't exist!");
		CloseHandle(file);
		return;
	}
	
	char readData[256];
	if(!IsEndOfFile(file) && ReadFileLine(file, readData, sizeof(readData)))//讀一行
	{
		char sNewName[128];
		if(strlen(sReadyUpCfgName) == 0)
			Format(sNewName, sizeof(sNewName), "%s", readData);
		else
			Format(sNewName, sizeof(sNewName), "%s%c%s%c", readData, SYMBOL_LEFT, sReadyUpCfgName, SYMBOL_RIGHT);
		
		SetConVarString(g_hHostName,sNewName);
		LogMessage("%s New server name \"%s\"", DN_TAG, sNewName);
		
		Format(g_sDefaultN,sizeof(g_sDefaultN),"%s",sNewName);
	}
	CloseHandle(file);
}
