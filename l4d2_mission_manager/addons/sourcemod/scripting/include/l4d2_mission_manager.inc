#if defined _l4d2_mission_manager_included_
 #endinput
#endif
#define _l4d2_mission_manager_included_

#define LEN_MISSION_NAME 64			// e.g. "Name" - L4D2C1
#define LEN_DISPLAYTITLE_NAME 256	// e.g. "DisplayTitle" - #L4D360UI_Campaign_Airport, 广西-南宁 V1.15.1
#define LEN_MAP_FILENAME 64			// e.g. "Map" - c1m1_hotel
#define LEN_MAP_DISPLAYNAME 256		// e.g. "DisplayName" - #L4D360UI_Chapter_Greenhouse, 2: 广场/Square
#define LEN_GAMEMODE_NAME 32		// e.g. "modes" supports - coop, versus, scavenge, survival
#define LEN_LOCALIZED_NAME 256

#define COUNT_LMM_GAMEMODE 4

enum LMM_GAMEMODE
{
	LMM_GAMEMODE_UNKNOWN = -1,
	LMM_GAMEMODE_COOP = 0,
	LMM_GAMEMODE_VERSUS = 1,
	LMM_GAMEMODE_SCAVENGE = 2,
	LMM_GAMEMODE_SURVIVAL = 3
};

/**
* Return game mode base of current game mode or current mutation mode
* 
* @return	coop, versus, survival, scavenge, unknown (see the "LMM_GAMEMODE_*" enums). Return LMM_GAMEMODE_UNKNOWN (-1) if gamemode is unknown
*/
native LMM_GAMEMODE LMM_GetCurrentGameMode();

/**
* Turn game mode or mutation mode string into the game mode base
*
* @param name	Game mode or mutation mode string, example: versus, mutation16, community6, gunbrain... 
*
* @return	coop, versus, survival, scavenge, unknown (see the "LMM_GAMEMODE_*" enums). Return LMM_GAMEMODE_UNKNOWN (-1) if gamemode is unknown
*/
native LMM_GAMEMODE LMM_StringToGamemode(const char[] name);

/**
* Turn "LMM_GAMEMODE_*" enums into the game mode base 
*
* @param gamemode	See the "LMM_GAMEMODE_*" enums
* @param name		Destination String to store game mode base (coop, versus, survival, scavenge)
* @param length		Size of destination string
*
* @noreturn
*/
native int LMM_GamemodeToString(LMM_GAMEMODE gamemode, char[] name, int length);

/**
* Get total number of mission (campaign)
* 
* @return	return the number, return -1 if error.
*/
native int LMM_GetNumberOfMissions(LMM_GAMEMODE gamemode);

/**
* Attempt to find mission index via mission name
* 
* @return	return mission index (>=0), -1 if not found or error
*/
native int LMM_FindMissionIndexByName(LMM_GAMEMODE gamemode, const char[] missionName);

/**
* Attempt to get mission name via mission index
* 
* @return	1 for success, -1 if not found or error
*/
native int LMM_GetMissionName(LMM_GAMEMODE gamemode, int missionIndex, char[] missionName, int length);

/**
* Attempt to localize the mission name via custom translation
* @Translate "Name" 經過自製的翻譯文件翻譯後的文字
* 
* @return	1 for success, 0 for no localization,  -1 for error.
*/
native int LMM_GetMissionLocalizedName(LMM_GAMEMODE gamemode, int missionIndex, char[] missionName, int length, int client);

/**
* Attempt to get the mission name without translation
* 
* @return	1 for success, 0 for no localization and -1 for error.
*/
native int LMM_GetMissionDisplayTitle(LMM_GAMEMODE gamemode, int missionIndex, char[] missionName, int length);

/**
* Attempt to localize the mission name via source game official translation and custom translation
* @Translate "DisplayTitle" 經過遊戲官方的翻譯與自製的翻譯文件翻譯後的文字
* 
* @return	1 for success, 0 for no localization and -1 for error.
*/
native int LMM_GetMissionLocalizedDisplayTitle(LMM_GAMEMODE gamemode, int missionIndex, char[] missionName, int length, int client);

/**
* Get total number of valid maps
* 
* @return	return th number, return -1 if error.
*/
native int LMM_GetNumberOfMaps(LMM_GAMEMODE gamemode, int missionIndex);

/**
* Attempt to find map index and mission index via map name
* 
* @param missionIndex		to store mission index
* 
* @return	return map index (>=0), -1 if not found or error
*/
native int LMM_FindMapIndexByName(LMM_GAMEMODE gamemode, int& missionIndex, const char[] mapName);

/**
* Attempt to get map name via mission index and map index
* 
* @return	1 for success, -1 if not found or error
*/
native int LMM_GetMapName(LMM_GAMEMODE gamemode, int missionIndex, int mapIndex, char[] mapName, int length);

/** 
* Attempt to localize the map name via custom translation
* @Note mapName will be converted to lower case internally. Entries in maps.phrases.txt can only have lower case English letters and numbers
* @Translate "Map" 經過自製的翻譯文件翻譯後的文字
* 
* @return	1 for success, 0 for no localization and -1 for error.
*/
native int LMM_GetMapLocalizedName(LMM_GAMEMODE gamemode, int missionIndex, int mapIndex, char[] mapName, int length, int client);

/** 
* Attempt to get the map name without translation
* 
* @return	0 for success, -1 for error.
*/
native int LMM_GetMapDisplayName(LMM_GAMEMODE gamemode, int missionIndex, int mapIndex, char[] mapName, int length);

/** 
* Attempt to localize the map display name via source game official translation and custom translation
* @Translate "DisplayName" 經過遊戲官方的翻譯與自製的翻譯文件翻譯後的文字
* 
* @return	1 for success, 0 for no localization and -1 for error.
*/
native int LMM_GetMapLocalizedDisplayName(LMM_GAMEMODE gamemode, int missionIndex, int mapIndex, char[] mapName, int length, int client);

/**
* Get the unique ID of the map via both missionIndex and mapIndex
*
* @return	return unique ID, -1 for error.
*/
native int LMM_GetMapUniqueID(LMM_GAMEMODE gamemode, int missionIndex, int mapIndex);

/**
* Decode the unique ID of the map, and return both missionIndex and mapIndex
* 
* @param missionIndex		to store mission index
*
* @return	return map index, -1 for error.
*/
native int LMM_DecodeMapUniqueID(LMM_GAMEMODE gamemode, int& missionIndex, int mapUID);

/**
* Get the number of maps for the given gamemode
* 
* @return	return the number, -1 for error.
*/
native int LMM_GetMapUniqueIDCount(LMM_GAMEMODE gamemode);

/**
* Get the number of invalid mission (campaign)
* 
* @return	return the number
*/
native int LMM_GetNumberOfInvalidMissions();

/**
* Get invalid mission name via mission index
* 
* @return	0 for success, -1 for error.
*/
native int LMM_GetInvalidMissionName(int missionIndex, char[] mapName, int length);


/**
* This forward is called during the OnPluginStart() phase.
* Do NOT use any LMM APIs in OnPluginStart, due to the chance that your plugin is loaded prior to LMM.
* LMM APIs become available in OnAllPluginsLoaded().
*/
forward void OnLMMUpdateList();


/**
* This can only work while a client is ingame.
* To call while no clients are not in game requires a signiture @CDirector
*   
* Call this before you force change level to close HSCRIPT.
* Any other way of level changing is fine e.g. level transition L4D "callvote missionchange" ect.
*/
stock void ShutDownScriptedMode()
{
	int iClient = 0;
	for(int i = 1; i <= MaxClients; i++) 
	{
		if(!IsClientInGame(i))
			continue;
		
		iClient = i;
		break;
	}
	
	if(iClient < 1)
		return;
	
	int iCmdFlags = GetCommandFlags("scripted_mode_shutdown");
	PrintToServer("[MissionManager] EndingScripted Mode.");
	SetCommandFlags("scripted_mode_shutdown", iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(iClient, "scripted_mode_shutdown");
	SetCommandFlags("scripted_mode_shutdown", iCmdFlags);
}

/**
* @return	Return 1 if the current map is the final of the campaign, return 0 if not.
* Same as L4D_IsMissionFinalMap() from left4dhooks
*/
#pragma deprecated Use L4D_IsMissionFinalMap() from left4dhooks
native int LMM_IsOnFinalMap();

public SharedPlugin __pl_l4d2_mission_manager =
{
	name = "l4d2_mission_manager",
	file = "l4d2_mission_manager.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_mission_manager_SetNTVOptional()
{
	MarkNativeAsOptional("LMM_GetCurrentGameMode");
	MarkNativeAsOptional("LMM_StringToGamemode");
	MarkNativeAsOptional("LMM_GamemodeToString");
	MarkNativeAsOptional("LMM_GetNumberOfMissions");
	MarkNativeAsOptional("LMM_FindMissionIndexByName");
	MarkNativeAsOptional("LMM_GetMissionName");
	MarkNativeAsOptional("LMM_GetMissionLocalizedName");
	MarkNativeAsOptional("LMM_GetMissionDisplayTitle");
	MarkNativeAsOptional("LMM_GetMissionLocalizedDisplayTitle");
	MarkNativeAsOptional("LMM_GetNumberOfMaps");
	MarkNativeAsOptional("LMM_FindMapIndexByName");
	MarkNativeAsOptional("LMM_GetMapName");
	MarkNativeAsOptional("LMM_GetMapLocalizedName");
	MarkNativeAsOptional("LMM_GetMapDisplayName");
	MarkNativeAsOptional("LMM_GetMapLocalizedDisplayName");
	MarkNativeAsOptional("LMM_GetMapUniqueID");
	MarkNativeAsOptional("LMM_DecodeMapUniqueID");
	MarkNativeAsOptional("LMM_GetMapUniqueIDCount");
	MarkNativeAsOptional("LMM_GetNumberOfInvalidMissions");
	MarkNativeAsOptional("LMM_GetInvalidMissionName");
	MarkNativeAsOptional("LMM_IsOnFinalMap");
}
#endif