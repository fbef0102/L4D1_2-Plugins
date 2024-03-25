#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sourcescramble>	
#define PLUGIN_VERSION			"1.0"
#define PLUGIN_NAME			    "gametype_description"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "Change Game type in server list",
	author = "Harry Potter",
	description = "Allows changing of displayed game type in server browser",
	version = "1.0-2024/3/25",
	url = "http://steamcommunity.com/profiles/76561198026784913"
}

bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test == Engine_Left4Dead )
    {
        g_bL4D2Version = false;
    }
    else if( test == Engine_Left4Dead2 )
    {
        g_bL4D2Version = true;
    }
    else
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

#define GAMEDATA_FILE           PLUGIN_NAME
#define DATA_FILE		        "configs/" ... PLUGIN_NAME ... ".cfg"

MemoryPatch
	g_mGameDesPatch;

bool 
	g_bOnMapStart;

char 
	g_sGameDes[64];

int 
	g_iGameOS;

public void OnPluginStart()
{
	if(g_bL4D2Version)
	{
		GameData hGameData = new GameData(GAMEDATA_FILE);
		if (!hGameData)
			SetFailState("[A2S_EDIT] Failed to load \"%s.txt\" gamedata.", GAMEDATA_FILE);

		g_iGameOS = hGameData.GetOffset("OS") ? 4 : 1;
		g_mGameDesPatch = MemoryPatch.CreateFromConf(hGameData, "GameDescription");
		if (!g_mGameDesPatch.Validate())
			SetFailState("Failed to verify patch: \"GameDescription\"");
		else if (g_mGameDesPatch.Enable()) {
			//StoreToAddress(g_mGameDesPatch.Address + view_as<Address>(g_iGameOS), view_as<int>(GetAddressOfString(g_sGameDes)), NumberType_Int32);
		}

		delete hGameData;
	}
}

//Sourcemod API Forward-------------------------------

public Action OnGetGameDescription(char gameDesc[64])
{
	if (!g_bL4D2Version && g_bOnMapStart)
	{
		strcopy(gameDesc, sizeof(gameDesc), g_sGameDes); // edit and change
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public void OnMapStart()
{
	LoadData();
	g_bOnMapStart = true;
}

public void OnMapEnd()
{
	g_bOnMapStart = false;
}

//Data-------------------------------

void LoadData()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), DATA_FILE);
	if( !FileExists(sPath) )
	{
		SetFailState("File Not Found: %s", sPath);
		return;
	}

	File file = OpenFile(sPath, "r");
	if(file == null)
	{
		BuildPath(Path_SM, sPath, sizeof(sPath), DATA_FILE);
		file = OpenFile(sPath, "r");
		if(file == null)
		{
			LogError("File %s doesn't exist!", DATA_FILE);
			delete file;
			return;
		}
	}

	if(!IsEndOfFile(file) && ReadFileLine(file, g_sGameDes, sizeof(g_sGameDes)))//讀一行
	{
		if(g_bL4D2Version) 
		{
			StoreToAddress(g_mGameDesPatch.Address + view_as<Address>(g_iGameOS), view_as<int>(GetAddressOfString(g_sGameDes)), NumberType_Int32);
		}
	}

	delete file;
}


