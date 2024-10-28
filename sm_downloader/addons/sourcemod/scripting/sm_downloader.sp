
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define SM_DOWNLOADER_VERSION		"2.1-2024/10/28"
#define CVAR_FLAGS                    FCVAR_NOTIFY

ConVar g_enabled=null;
ConVar g_simple=null;
ConVar g_normal=null;
ConVar g_file=null;
ConVar g_file_simple=null;

int downloadtype;

public Plugin myinfo = 
{
	name = "SM File/Folder Downloader and Precacher",
	author = "SWAT_88, HarryPotter",
	description = "Downloads and Precaches Files",
	version = SM_DOWNLOADER_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

public void OnPluginStart()
{
	g_enabled 		= CreateConVar("sm_downloader_enabled", 		"1", "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_normal 		= CreateConVar("sm_downloader_normal_enable", 	"1", "If 1, Enable normal downloader file. (Download & Precache)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_simple 		= CreateConVar("sm_downloader_simple_enable", 	"0", "If 1, Enable simple downloader file. (Download Only No Precache)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_file 			= CreateConVar("sm_downloader_normal_config", 	"configs/sm_downloader/downloads_normal.ini", 	"(Download & Precache) Full path of the normal downloader configuration to load. \nIE: configs/sm_downloader/downloads.ini", CVAR_FLAGS);
	g_file_simple 	= CreateConVar("sm_downloader_simple_config", 	"configs/sm_downloader/downloads_simple.ini", 	"(Download Only No Precache) Full path of the simple downloader configuration to load. \nIE: configs/sm_downloader/downloads_simple.ini", CVAR_FLAGS);
	AutoExecConfig(true, "sm_downloader");
	
	g_file.AddChangeHook(OnCvarFileChange_control);
	g_file_simple.AddChangeHook(OnCvarFileSimpleChange_control);

}

void OnCvarFileChange_control(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(g_enabled.BoolValue)
	{
		if(g_normal.BoolValue) ReadDownloadsNormal();
	}
}

void OnCvarFileSimpleChange_control(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if(g_enabled.BoolValue)
	{
		if(g_simple.BoolValue) ReadDownloadsSimple();
	}
}

bool g_bMapStarted;
public void OnMapStart() 
{
	g_bMapStarted = true;
	//if(g_enabled.BoolValue){
	//	if(g_normal.BoolValue) ReadDownloadsNormal();
	//	if(g_simple.BoolValue) ReadDownloadsSimple();
	//}
}

public void OnMapEnd()
{
	g_bMapStarted = false;
}

public void OnConfigsExecuted()
{	
	if(g_enabled.BoolValue)
	{
		if(g_normal.BoolValue) ReadDownloadsNormal();
		if(g_simple.BoolValue) ReadDownloadsSimple();
	}
}

void ReadFileFolder(char[] path){
	Handle dirh = null;
	char buffer[256];
	char tmp_path[256];
	FileType type = FileType_Unknown;
	int len;
	
	len = strlen(path);
	if (path[len-1] == '\n')
		path[--len] = '\0';

	TrimString(path);
	
	if(DirExists(path)){
		dirh = OpenDirectory(path);
		while(ReadDirEntry(dirh,buffer,sizeof(buffer),type)){
			len = strlen(buffer);
			if (buffer[len-1] == '\n')
				buffer[--len] = '\0';

			TrimString(buffer);

			if (strcmp(buffer,"",false) != 0 && strcmp(buffer,".",false) != 0 && strcmp(buffer,"..",false) != 0){
				strcopy(tmp_path,255,path);
				StrCat(tmp_path,255,"/");
				StrCat(tmp_path,255,buffer);
				if(type == FileType_File){
					if(downloadtype == 1){
						ReadItemNormal(tmp_path);
					}
					else if(downloadtype == 2){
						ReadItemSimple(tmp_path);
					}
				}
				else{
					ReadFileFolder(tmp_path);
				}
			}
		}
	}
	else{
		if(downloadtype == 1){
			ReadItemNormal(path);
		}
		else if(downloadtype == 2){
			ReadItemSimple(path);
		}
	}

	delete dirh;
}

void ReadDownloadsNormal()
{
	if(!g_bMapStarted) return;

	char sConVarPath[PLATFORM_MAX_PATH];
	g_file.GetString(sConVarPath, sizeof(sConVarPath));

	char file[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, file, sizeof(file), sConVarPath);

	if (!FileExists(file)) {
		SetFailState("Normal Downloader Configuration Not Found: %s", file);
		return;
	}

	Handle fileh = OpenFile(file, "r");
	if(fileh == null) return;
	char buffer[256];
	downloadtype = 1;
	int len;

	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{	
		len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';

		TrimString(buffer);

		if(strlen(buffer) > 0)
			ReadFileFolder(buffer);
		
		if (IsEndOfFile(fileh))
			break;
	}

	delete fileh;
}

void ReadItemNormal(char[] buffer){
	int len = strlen(buffer);
	if (buffer[len-1] == '\n')
		buffer[--len] = '\0';
	
	char mediatype[256];
	bool downloadfiles;

	TrimString(buffer);
	if(StrContains(buffer,"//Files (Download Only No Precache)",true) >= 0){
		mediatype = "File";
		downloadfiles=true;
	}
	else if(StrContains(buffer,"//Decal Files (Download and Precache)",true) >= 0){
		mediatype = "Decal";
		downloadfiles=true;
	}
	else if(StrContains(buffer,"//Sound Files (Download and Precache)",true) >= 0){
		mediatype = "Sound";
		downloadfiles=true;
	}
	else if(StrContains(buffer,"//Model Files (Download and Precache)",true) >= 0){
		mediatype = "Model";
		downloadfiles=true;
	}
	else if(strlen(buffer) == 0 || strncmp(buffer, "//", 2, false) == 0)
	{
		//Comment
	}
	else if (FileExists(buffer))
	{
		if(downloadfiles){
			AddFileToDownloadsTable(buffer);
			
			if(strncmp(mediatype,"Decal", 5, false) == 0)
			{
				PrecacheDecal(buffer,true);
			}
			else if(strncmp(mediatype,"Sound", 5, false) == 0)
			{
				ReplaceStringEx(buffer, len, "sound/", "", -1, -1, false);
				PrecacheSound(buffer,true);
			}
			else if(strncmp(mediatype,"Model", 5, false) == 0)
			{
				PrecacheModel(buffer,true);
			}
		}
	}
}

void ReadDownloadsSimple()
{
	if(!g_bMapStarted) return;

	char sConVarPath[PLATFORM_MAX_PATH];
	g_file_simple.GetString(sConVarPath, sizeof(sConVarPath));
	
	char file[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, file, sizeof(file), sConVarPath);
	
	if (!FileExists(file)) {
		SetFailState("Simple Downloader Configuration Not Found: %s", file);
		return;
	}

	Handle fileh = OpenFile(file, "r");
	if(fileh == null) return;

	char buffer[256];
	downloadtype = 2;
	int len;

	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{
		len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';

		TrimString(buffer);

		if( strlen(buffer) > 0)
			ReadFileFolder(buffer);
		
		if (IsEndOfFile(fileh))
			break;
	}

	delete fileh;
}

void ReadItemSimple(char[] buffer){
	int len = strlen(buffer);
	if (buffer[len-1] == '\n')
		buffer[--len] = '\0';
	
	TrimString(buffer);

	if(strlen(buffer) == 0 || strncmp(buffer, "//", 2, false) == 0)
	{
		//Comment
	}
	else if (FileExists(buffer))
	{
		AddFileToDownloadsTable(buffer);
	}
}

/*
public void OnClientConnected(int client)
{  
  if(IsClientConnected(client)&&!IsClientInGame(client)&&!IsFakeClient(client))
 	CreateTimer(6.0,TimerShowMessage,client);
}

Action TimerShowMessage(Handle timer, any client)
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

Action TimerShowMessage2(Handle timer,any client)
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
*/