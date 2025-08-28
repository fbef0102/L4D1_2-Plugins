/**
 * l4d2_blackscreen_fix 變體插件
 * 適用全模式，換圖時才會下載
 */

#pragma semicolon 1
#pragma newdecls required
 
#include <sourcemod>
#include <sdktools>
#include <stringtables_data> //https://forums.alliedmods.net/showthread.php?t=319828

#define Config		"data/l4d_fastdl_delay_downloader.cfg" // Get all exclude list from cfg which doesn't affect by this plugin.

ArrayList
	g_aItems,
	g_sRestricted;

int g_iItemsTotal;
bool g_bEmpty;

public Plugin myinfo =
{
	name = "[L4D & L4D2] Black Screen Fix",
	author = "BHaType, Dragokas, Harry",
	description = "Downloading custom files only when map change/transition",
	version = "1.0h-2024/12/31",
	url	= "https://forums.alliedmods.net/showthread.php?t=318739"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test == Engine_Left4Dead )
    {

    }
    else if( test == Engine_Left4Dead2 )
    {

    }
    else
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

public void OnPluginStart()
{
	RegAdminCmd("sm_get_exclude_items",	CMD_GetStringRestricted, 	ADMFLAG_ROOT, 	"Get all exclude list from data/l4d_fastdl_delay_downloader.cfg");
	RegAdminCmd("sm_restore_st",		CMD_RestoreDownloadables, 	ADMFLAG_ROOT, 	"Restore downloadables stringtable items");
	
	//HookEvent("player_disconnect", eDiconnect, EventHookMode_Pre);
	//HookEvent("map_transition", eStart, EventHookMode_Pre); //1. all survivors make it to saferoom in and server is about to change next level in coop mode (does not trigger round_end), 2. all survivors make it to saferoom in versus
	//HookEvent("finale_vehicle_leaving", eStart,		EventHookMode_PostNoCopy); //final map final rescue vehicle leaving  (does not trigger round_end)

	AddCommandListener(ServerCmd_changelevel, "changelevel");

	g_aItems = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
	g_sRestricted = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));
}

public void OnMapStart()
{
	CreateTimer(30.0, Timer_SaveDownloadables, _, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_SaveDownloadables(Handle timer)
{
	SaveDownloadables();

	return Plugin_Continue;
}

void SaveDownloadables()
{
	int iTable = FindStringTable("downloadables");
	if(iTable == INVALID_STRING_TABLE) 
	{
		LogError("Cannot find 'downloadables' string table!");
		return;
	}
	
	delete g_aItems;
	g_aItems = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

	int iNum = GetStringTableNumStrings(iTable);
 
	char sItems[PLATFORM_MAX_PATH];
	for (int i; i < iNum; i++)
	{
		ReadStringTable(iTable, i, sItems, sizeof(sItems));
		if(g_sRestricted.FindString(sItems) >= 0) continue;

		g_aItems.PushString(sItems);
	}
	
	INetworkStringTable table = INetworkStringTable(iTable);
	table.DeleteStrings();
	
	/*int index = ReadRestrictedFiles();
	if ( index != -1 )
	{
		char sRestricted[PLATFORM_MAX_PATH];
		int length = g_sRestricted.Length;
		for (int i = 0; i < length; i++)
		{
			g_sRestricted.GetString(i, sRestricted, sizeof(sRestricted));
			if ( strlen(sRestricted) > 0 )
			{
				AddFileToDownloadsTable(sRestricted);
			}
		}
	}*/

	PrintToServer("[FASTDL DOWNLOAD] All strings has been saved and deleted from downloadables stringtable");
}

/*void eStart(Event event, const char[] name, bool dontBroadcast)
{
	if (g_iItemsTotal == 0 || g_bEmpty)
		return;
	
	for (int i = 0; i < g_iItemsTotal; i++)
		if ( strlen(g_sItems[i]) )
			AddFileToDownloadsTable(g_sItems[i]);
	
	PrintToServer("[FASTDL DOWNLOAD] All strings has been restored to downloadables");
}*/

/**
 * 當控制台輸入changelevel時
 * 投票換圖或重新章節或通關換圖 也會有changelevel xxxxx (xxxxx is map name)
 * 管理員!admin->換圖 也會有changelevel xxxxx (xxxxx is map name)
 * 插件使用 ServerCommand("changelevel %s", ..... 也會有changelevel xxxxx (xxxxx is map name)
 * 插件使用 ForceChangeLevel("xxxxxx", ..... 也會有changelevel xxxxx (xxxxx is map name)
 * 指令通過前的一刻，因此還可以抓到玩家的狀態與所在的隊伍 (閒置也抓得到)
 */
Action ServerCmd_changelevel(int client, const char[] command, int argc)
{
	if (g_iItemsTotal == 0 || g_bEmpty)
		return Plugin_Continue;

	//if (!RealPlayerExist())
	//	return Plugin_Continue;
	
	int length = g_aItems.Length;
	char sItems[PLATFORM_MAX_PATH];
	for (int i = 0; i < length; i++)
	{
		g_aItems.GetString(i, sItems, sizeof(sItems));
		if ( strlen(sItems) > 0 )
			AddFileToDownloadsTable(sItems);
	}
	
	PrintToServer("[FASTDL DOWNLOAD] All strings has been restored to downloadables");

	return Plugin_Continue;
}

/*void eDiconnect (Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if ( (client == 0 || !IsFakeClient(client)) && !RealPlayerExist(client) ) 
		CreateTimer(6.3, tPlayers);
}

Action tPlayers(Handle timer)
{
	if ( !RealPlayerExist() )
	{
		g_bEmpty = true;
		
		INetworkStringTable table = INetworkStringTable(FindStringTable("downloadables"));
		table.DeleteStrings();
		
		int index = ReadRestrictedFiles();
			
		if ( index != -1 )
		{
			char sRestricted[PLATFORM_MAX_PATH];
			int length = g_sRestricted.Length;
			for (int i = 0; i < length; i++)
			{
				g_sRestricted.GetString(i, sRestricted, sizeof(sRestricted));
				if ( strlen(sRestricted) > 0 )
				{
					AddFileToDownloadsTable(sRestricted);
				}
			}
		}
	}

	return Plugin_Continue;
}
*/
Action CMD_RestoreDownloadables(int client, int args)
{
	if ( g_iItemsTotal == 0 ) 
	{
		ReplyToCommand(client, "Cannot restore. Downloadables string table is not saved");
		return Plugin_Handled;
	}
	
	int length = g_aItems.Length;
	char sItems[PLATFORM_MAX_PATH];
	for (int i = 0; i < length; i++)
	{
		g_aItems.GetString(i, sItems, sizeof(sItems));
		if ( strlen(sItems) > 0 )
			AddFileToDownloadsTable(sItems);
	}
			
	return Plugin_Handled;
}

Action CMD_GetStringRestricted (int client, int args)
{
	int index = ReadRestrictedFiles();
	
	if ( index == -1 )
	{
		ReplyToCommand(client, "No config \"%s\" has been found", Config);
		return Plugin_Handled;
	}
	
	char sRestricted[PLATFORM_MAX_PATH];
	int length = g_sRestricted.Length;
	for (int i = 0; i < length; i++)
	{
		g_sRestricted.GetString(i, sRestricted, sizeof(sRestricted));
		if ( strlen(sRestricted) > 0 )
			ReplyToCommand(client, "%i. %s", i, sRestricted);
	}
			
	return Plugin_Handled;
}

int ReadRestrictedFiles ()
{
	delete g_sRestricted;
	g_sRestricted = new ArrayList(ByteCountToCells(PLATFORM_MAX_PATH));

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), Config);
	
	if ( FileExists(sPath) )
	{
		int index = 0;
		
		char szBuffer[PLATFORM_MAX_PATH];
		File hFile = OpenFile(sPath, "r");
		
		while ( ReadFileLine(hFile, szBuffer, sizeof szBuffer) )
		{
			if(strncmp(szBuffer, "//", 2, false) == 0)
			{
				continue;
			}

			TrimString(szBuffer);
			
			char sRestricted[PLATFORM_MAX_PATH];
			FormatEx(sRestricted, sizeof(sRestricted), "%s", szBuffer);
			g_sRestricted.PushString(sRestricted);

			index++;
		}
		
		delete hFile;
		return index;
	}
	
	return -1;
}

stock bool RealPlayerExist (int iExclude = 0)
{
	for (int client = 1; client < MaxClients; client++)
	{
		if ( client != iExclude && IsClientConnected(client) && !IsFakeClient(client) )
		{
			if(IsClientInGame(client))
			{
				return true;
			}
			else
			{
				// 幽靈人口: 有client, IsClientConnected: true, IsClientInGame: false, userid: -1
				// 幽靈人口常發生於換圖時離線，踢不掉，status看不到
				int userid = GetClientUserId(client);
				if(userid > 0) return true;
			}
		}
	}

	return false;
}
