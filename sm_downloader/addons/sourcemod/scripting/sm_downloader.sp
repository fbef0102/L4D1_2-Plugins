
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define SM_DOWNLOADER_VERSION		"2.2-2024/11/21"
#define CVAR_FLAGS                    FCVAR_NOTIFY

ConVar g_enabled=null;
ConVar g_simple=null;
ConVar g_normal=null;
ConVar g_file=null;
ConVar g_file_simple=null;

enum EDownloadType
{
	eNormal = 1,
	eSimple = 2,
}

EDownloadType g_eDownloadType;

enum EMediaFile
{
	eUnknown 	= 0,
	eFile 		= 1,
	eDecal 		= 2,
	eSound 		= 3,
	eModel 		= 4,
}
EMediaFile g_eMediaFile;

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
	g_normal 		= CreateConVar("sm_downloader_normal_enable", 	"0", "If 1, Enable normal downloader file. (Download & Precache)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_simple 		= CreateConVar("sm_downloader_simple_enable", 	"1", "If 1, Enable simple downloader file. (Download Only No Precache)", CVAR_FLAGS, true, 0.0, true, 1.0);
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
					if(g_eDownloadType == eNormal){
						ReadItemNormal(tmp_path);
					}
					else if(g_eDownloadType == eSimple){
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
		if(g_eDownloadType == eNormal){
			ReadItemNormal(path);
		}
		else if(g_eDownloadType == eSimple){
			ReadItemSimple(path);
		}
	}

	delete dirh;
}

void ReadDownloadsNormal()
{
	if(!g_bMapStarted) return;

	g_eMediaFile = eUnknown;

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
	g_eDownloadType = eNormal;
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

	TrimString(buffer);
	if(StrContains(buffer,"//Files (Download Only No Precache)",true) >= 0){
		g_eMediaFile = eFile;
	}
	else if(StrContains(buffer,"//Decal Files (Download and Precache)",true) >= 0){
		g_eMediaFile = eDecal;
	}
	else if(StrContains(buffer,"//Sound Files (Download and Precache)",true) >= 0){
		g_eMediaFile = eSound;
	}
	else if(StrContains(buffer,"//Model Files (Download and Precache)",true) >= 0){
		g_eMediaFile = eModel;
	}
	else if(strlen(buffer) == 0 || strncmp(buffer, "//", 2, false) == 0)
	{
		//Comment
	}
	else if (FileExists(buffer))
	{
		if(g_eMediaFile != eUnknown)
		{
			AddFileToDownloadsTable(buffer);
			
			if(g_eMediaFile == eDecal)
			{
				PrecacheDecal(buffer,true);
			}
			else if(g_eMediaFile == eSound)
			{
				ReplaceStringEx(buffer, len, "sound/", "", -1, -1, false);
				PrecacheSound(buffer,true);
			}
			else if(g_eMediaFile == eModel)
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
	g_eDownloadType = eSimple;
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