#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#include <l4d2_mission_manager>
#include <localizer>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
	name = "L4D2 Mission Manager",
	author = "Rikka0w0, Harry",
	description = "Mission manager for L4D2, provide information about map orders for other plugins",
	version = "v1.1h - 2026/1/20",
	url = "https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d2_mission_manager"
}


ConVar mp_gamemode;
char g_sFile[128];
StringMap g_hMissionsMap;

Localizer loc;
public void OnPluginStart()
{
	loc = new Localizer(LC_INSTALL_MODE_FULLCACHE); 
	mp_gamemode = FindConVar("mp_gamemode");

	BuildPath(Path_SM, g_sFile, PLATFORM_MAX_PATH, "/logs/l4d2_mission_manager.log");
	g_hMissionsMap = new StringMap();

	CacheMissions();
	LMM_InitLists();
	ParseMissions();
	LoadTranslations("missions.phrases");
	LoadTranslations("maps.phrases");
	
	FireEvent_OnLMMUpdateList();
		
	RegConsoleCmd("sm_lmm_list", Command_List, "Usage: sm_lmm_list [<coop|versus|scavenge|survival|invalid>]");
}

public void OnPluginEnd() {
	LMM_FreeLists();
	delete g_hMissionsMap;
}

Action Command_List(int iClient, int args) {
	if (args < 1) {
		for (int i=0; i<4; i++) {
			LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(i);
			DumpMissionInfo(iClient, gamemode);
		}
	} else {
		char gamemodeName[LEN_GAMEMODE_NAME];
		GetCmdArg(1, gamemodeName, sizeof(gamemodeName));
		
		if (StrEqual("invalid", gamemodeName, false)) {
			int missionCount = LMM_GetNumberOfInvalidMissions();
			ReplyToCommand(iClient, "Invalid missions (count:%d):", missionCount);
			for (int iMission=0; iMission<missionCount; iMission++) {
				char missionName[LEN_MISSION_NAME];
				LMM_GetInvalidMissionName(iMission, missionName, sizeof(missionName));
				ReplyToCommand(iClient, ", %s", missionName);
			}
		} else {
			LMM_GAMEMODE gamemode = LMM_StringToGamemode(gamemodeName);
			if(gamemode == LMM_GAMEMODE_UNKNOWN) return Plugin_Handled;
			
			DumpMissionInfo(iClient, gamemode);
		}
	}
	return Plugin_Handled;
}

void DumpMissionInfo(int client, LMM_GAMEMODE gamemode) {
	char gamemodeName[LEN_GAMEMODE_NAME];
	LMM_GamemodeToString(gamemode, gamemodeName, sizeof(gamemodeName));

	int missionCount = LMM_GetNumberOfMissions(gamemode);
	char missionName[LEN_MISSION_NAME];
	char mapName[LEN_MAP_FILENAME];
	char localizedName[LEN_LOCALIZED_NAME];
	
	if(client > 0) ReplyToCommand(client, "Gamemode = %s (%d missions)", gamemodeName, missionCount);

	for (int iMission=0; iMission<missionCount; iMission++) {
		LMM_GetMissionName(gamemode, iMission, missionName, sizeof(missionName));
		int mapCount = LMM_GetNumberOfMaps(gamemode, iMission);
		if (LMM_GetMissionLocalizedName(gamemode, iMission, localizedName, sizeof(localizedName), LANG_SERVER) > 0) {
			ReplyToCommand(client, "%d. %s <%s> %d maps", iMission+1, missionName, localizedName, mapCount);
		} else {
			ReplyToCommand(client, "%d. !! <%s> (%d maps)", iMission+1, missionName, mapCount);
		}
		
		for (int iMap=0; iMap<mapCount; iMap++) {
			LMM_GetMapName(gamemode, iMission, iMap, mapName, sizeof(mapName));
			if (LMM_GetMapLocalizedName(gamemode, iMission, iMap, localizedName, sizeof(localizedName), LANG_SERVER) > 0) {
				ReplyToCommand(client, "> %d. %s <%s>", iMap+1, localizedName, mapName);
			} else {
				ReplyToCommand(client, "> %d. !! <%s>", iMap+1, mapName);
			}
		}
	}
	if(client > 0) ReplyToCommand(client, "-------------------");
}


int Native_IsOnFinalMap(Handle plugin, int numParams){
  return L4D_IsMissionFinalMap(true);
}

/* ========== Register Native APIs ========== */
Handle g_hForward_OnLMMUpdateList;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {

	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	
	if( !IsDedicatedServer() )
	{
		strcopy(error, err_max, "Get a dedicated server. This plugin does not work on Listen servers.");
		return APLRes_SilentFailure;
	}
	
	CreateNative("LMM_GetCurrentGameMode", Native_GetCurrentGameMode);
	CreateNative("LMM_StringToGamemode", Native_StringToGamemode);
	CreateNative("LMM_GamemodeToString", Native_GamemodeToString);

	CreateNative("LMM_GetNumberOfMissions", Native_GetNumberOfMissions);
	CreateNative("LMM_FindMissionIndexByName", Native_FindMissionIndexByName);
	CreateNative("LMM_GetMissionName", Native_GetMissionName);
	CreateNative("LMM_GetMissionLocalizedName", Native_GetMissionLocalizedName);

	CreateNative("LMM_GetMissionDisplayTitle", Native_GetMissionDisplayTitle);
	CreateNative("LMM_GetMissionLocalizedDisplayTitle", Native_GetMissionLocalizedDisplayTitle);

	CreateNative("LMM_GetNumberOfMaps", Native_GetNumberOfMaps);
	CreateNative("LMM_FindMapIndexByName", Native_FindMapIndexByName);
	CreateNative("LMM_GetMapName", Native_GetMapName);
	CreateNative("LMM_GetMapLocalizedName", Native_GetMapLocalizedName);

	CreateNative("LMM_GetMapDisplayName", Native_GetMapDisplayName);
	CreateNative("LMM_GetMapLocalizedDisplayName", Native_GetMapLocalizedDisplayName);

	CreateNative("LMM_GetMapUniqueID", Native_GetMapUniqueID);
	CreateNative("LMM_DecodeMapUniqueID", Native_DecodeMapUniqueID);	
	CreateNative("LMM_GetMapUniqueIDCount", Native_GetMapUniqueIDCount);

	CreateNative("LMM_GetNumberOfInvalidMissions", Native_GetNumberOfInvalidMissions);
	CreateNative("LMM_GetInvalidMissionName", Native_GetInvalidMissionName);

	CreateNative("LMM_IsOnFinalMap", Native_IsOnFinalMap);

	g_hForward_OnLMMUpdateList = CreateGlobalForward("OnLMMUpdateList", ET_Ignore);
	RegPluginLibrary("l4d2_mission_manager");

	return APLRes_Success;
}

void FireEvent_OnLMMUpdateList() {
	Call_StartForward(g_hForward_OnLMMUpdateList);
	Call_Finish();
}

int Native_GetCurrentGameMode(Handle plugin, int numParams) {
	LMM_GAMEMODE gamemode;
	//Get the gamemode string from the game
	char strGameMode[20];
	mp_gamemode.GetString(strGameMode, sizeof(strGameMode));
	
	//Set the global gamemode int for this plugin
	if(StrEqual(strGameMode, "coop", false))
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "realism", false))
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode,"versus", false))
		gamemode = LMM_GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "teamversus", false))
		gamemode = LMM_GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "scavenge", false))
		gamemode = LMM_GAMEMODE_SCAVENGE;
	else if(StrEqual(strGameMode, "teamscavenge", false))
		gamemode = LMM_GAMEMODE_SCAVENGE;
	else if(StrEqual(strGameMode, "survival", false))
		gamemode = LMM_GAMEMODE_SURVIVAL;
	else if(StrEqual(strGameMode, "mutation1", false))		//Last Man On Earth
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation2", false))		//Headshot!
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation3", false))		//Bleed Out
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation4", false))		//Hard Eight
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation5", false))		//Four Swordsmen
		gamemode = LMM_GAMEMODE_COOP;
	//else if(StrEqual(strGameMode, "mutation6", false))	//Nothing here
	//	gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation7", false))		//Chainsaw Massacre
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation8", false))		//Ironman
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation9", false))		//Last Gnome On Earth
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation10", false))	//Room For One
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation11", false))	//Healthpackalypse!
		gamemode = LMM_GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "mutation12", false))	//Realism Versus
		gamemode = LMM_GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "mutation13", false))	//Follow the Liter
		gamemode = LMM_GAMEMODE_SCAVENGE;
	else if(StrEqual(strGameMode, "mutation14", false))	//Gib Fest
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation15", false))	//Versus Survival
		gamemode = LMM_GAMEMODE_SURVIVAL;
	else if(StrEqual(strGameMode, "mutation16", false))	//Hunting Party
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation17", false))	//Lone Gunman
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "mutation18", false))	//Bleed Out Versus
		gamemode = LMM_GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "mutation19", false))	//Taaannnkk!
		gamemode = LMM_GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "mutation20", false))	//Healing Gnome
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "community1", false))	//Special Delivery
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "community2", false))	//Flu Season
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "community3", false))	//Riding My Survivor
		gamemode = LMM_GAMEMODE_VERSUS;
	else if(StrEqual(strGameMode, "community4", false))	//Nightmare
		gamemode = LMM_GAMEMODE_SURVIVAL;
	else if(StrEqual(strGameMode, "community5", false))	//Death's Door
		gamemode = LMM_GAMEMODE_COOP;
	else if(StrEqual(strGameMode, "nightmaredifficulty", false))	//Nightmare Difficulty
		gamemode = LMM_GAMEMODE_COOP;
	else
	{
		if(L4D_IsCoopMode() || L4D2_IsRealismMode()) gamemode = LMM_GAMEMODE_COOP;
		else if(L4D_IsVersusMode()) gamemode = LMM_GAMEMODE_VERSUS;
		else if(L4D_IsSurvivalMode()) gamemode = LMM_GAMEMODE_SURVIVAL;
		else if(L4D2_IsScavengeMode()) gamemode = LMM_GAMEMODE_SCAVENGE;
		else gamemode = LMM_GAMEMODE_UNKNOWN;
	}
		
	return view_as<int>(gamemode);
}

int Native_StringToGamemode(Handle plugin, int numParams) {
	if (numParams < 1)
		return -1;
	
	// Get parameters
	int length;
	GetNativeStringLength(1, length);
	char[] gamemodeName = new char[length+1];
	GetNativeString(1, gamemodeName, length+1);
	
	if(StrEqual("coop", gamemodeName, false)) {
		return view_as<int>(LMM_GAMEMODE_COOP);
	} else if (StrEqual("versus", gamemodeName, false)) {
		return view_as<int>(LMM_GAMEMODE_VERSUS);
	} else if(StrEqual("scavenge", gamemodeName, false)) {
		return view_as<int>(LMM_GAMEMODE_SCAVENGE);
	} else if (StrEqual("survival", gamemodeName, false)) {
		return view_as<int>(LMM_GAMEMODE_SURVIVAL);
	}
	
	return view_as<int>(LMM_GAMEMODE_UNKNOWN);
}

int Native_GamemodeToString(Handle plugin, int numParams) {
	if (numParams < 1)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int length = GetNativeCell(3);
	char gamemodeName[LEN_GAMEMODE_NAME];

	switch (gamemode) {
		case LMM_GAMEMODE_COOP: {
			strcopy(gamemodeName, sizeof(gamemodeName), "coop");
		}
		case LMM_GAMEMODE_VERSUS: {
			strcopy(gamemodeName, sizeof(gamemodeName), "versus");
		}
		case LMM_GAMEMODE_SCAVENGE: {
			strcopy(gamemodeName, sizeof(gamemodeName), "scavenge");
		}
		case LMM_GAMEMODE_SURVIVAL: {
			strcopy(gamemodeName, sizeof(gamemodeName), "survival");
		}
		default: {
			strcopy(gamemodeName, sizeof(gamemodeName), "unknown");
		}
	}
	
	if (SetNativeString(2, gamemodeName, length, false) != SP_ERROR_NONE)
		return -1;
		
	return 0;
}

/* ========== Mission Parser Outputs ========== */
ArrayList 
	g_hStr_InvalidMissionNames,
	g_hStr_MissionNames[COUNT_LMM_GAMEMODE],	// g_hStr_CoopMissionNames.Length = Number of Coop Missions
	g_hStr_MissionDisplayTitles[COUNT_LMM_GAMEMODE],
	g_hInt_Entries[COUNT_LMM_GAMEMODE],		// g_hInt_CoopEntries.Length = Number of Coop Missions + 1
	g_hStr_Maps[COUNT_LMM_GAMEMODE],			// The value of nth element in g_hInt_CoopEntries is the offset of nth mission's first map 
	g_hStr_MapDisplayNames[COUNT_LMM_GAMEMODE];

void LMM_InitLists() {
	delete g_hStr_InvalidMissionNames;
	g_hStr_InvalidMissionNames = new ArrayList(LEN_MISSION_NAME);

	for (int i=0; i<COUNT_LMM_GAMEMODE; i++) {
		delete g_hStr_MissionNames[i];
		g_hStr_MissionNames[i] = new ArrayList(LEN_MISSION_NAME);

		delete g_hStr_MissionDisplayTitles[i];
		g_hStr_MissionDisplayTitles[i] = new ArrayList(LEN_DISPLAYTITLE_NAME);

		delete g_hInt_Entries[i];
		g_hInt_Entries[i] = new ArrayList(1);
		g_hInt_Entries[i].Push(0);

		delete g_hStr_Maps[i];
		g_hStr_Maps[i] = new ArrayList(LEN_MAP_FILENAME);

		delete g_hStr_MapDisplayNames[i];
		g_hStr_MapDisplayNames[i] = new ArrayList(LEN_MAP_DISPLAYNAME);
	}
}

void LMM_FreeLists() {
	delete g_hStr_InvalidMissionNames;

	for (int i=0; i<COUNT_LMM_GAMEMODE; i++) {
		delete g_hStr_MissionNames[i];
		delete g_hStr_MissionDisplayTitles[i];
		delete g_hInt_Entries[i];
		delete g_hStr_Maps[i];
		delete g_hStr_MapDisplayNames[i];
	}
}

ArrayList LMM_GetMissionNameList(LMM_GAMEMODE gamemode) {
	return g_hStr_MissionNames[view_as<int>(gamemode)];
}

ArrayList LMM_GetMissionDisplayTitleList(LMM_GAMEMODE gamemode) {
	return g_hStr_MissionDisplayTitles[view_as<int>(gamemode)];
}

ArrayList LMM_GetEntryList(LMM_GAMEMODE gamemode) {
	return g_hInt_Entries[view_as<int>(gamemode)];
}

ArrayList LMM_GetMapList(LMM_GAMEMODE gamemode) {
	return g_hStr_Maps[view_as<int>(gamemode)];
}

ArrayList LMM_GetMapDisplayNameList(LMM_GAMEMODE gamemode) {
	return g_hStr_MapDisplayNames[view_as<int>(gamemode)];
}

int Native_GetNumberOfMissions(Handle plugin, int numParams) {
	if (numParams < 1)
		return -1;
	
	int gamemode = GetNativeCell(1);
	if (gamemode < 0 || gamemode >= COUNT_LMM_GAMEMODE)
		return -1;
	
	return g_hStr_MissionNames[gamemode].Length;	
}

int Native_FindMissionIndexByName(Handle plugin, int numParams) {
	if (numParams < 2)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int length;
	GetNativeStringLength(2, length);
	char[] missionName = new char[length+1];
	GetNativeString(2, missionName, length+1);
	
	ArrayList missionNameList = LMM_GetMissionNameList(gamemode);
	if (missionNameList == null)
		return -1;
	
	return missionNameList.FindString(missionName);
}

/*int Native_FindMissionIndexByDisplayTitle(Handle plugin, int numParams) {
	if (numParams < 2)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int length;
	GetNativeStringLength(2, length);
	char[] displayTitleName = new char[length+1];
	GetNativeString(2, displayTitleName, length+1);
	
	ArrayList missionDisplayTitleList = LMM_GetMissionDisplayTitleList(gamemode);
	if (missionDisplayTitleList == null)
		return -1;
	
	return missionDisplayTitleList.FindString(displayTitleName);
}*/

int Native_GetMissionName(Handle plugin, int numParams) {
	if (numParams < 4)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int missionIndex = GetNativeCell(2);
	int length = GetNativeCell(4);
	
	ArrayList missionNameList = LMM_GetMissionNameList(gamemode);
	if (missionNameList == null)
		return -1;
	
	
	char missionName[LEN_MISSION_NAME];
	missionNameList.GetString(missionIndex, missionName, sizeof(missionName));
	
	if (SetNativeString(3, missionName, length, false) != SP_ERROR_NONE)
		return -1;
		
	return 0;
}

int Native_GetMissionDisplayTitle(Handle plugin, int numParams) {
	if (numParams < 4)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int missionIndex = GetNativeCell(2);
	int length = GetNativeCell(4);
	
	ArrayList missionDisplayTitleList = LMM_GetMissionDisplayTitleList(gamemode);
	if (missionDisplayTitleList == null)
		return -1;
	
	char displayTitleName[LEN_DISPLAYTITLE_NAME];
	missionDisplayTitleList.GetString(missionIndex, displayTitleName, sizeof(displayTitleName));
	
	if (SetNativeString(3, displayTitleName, length, false) != SP_ERROR_NONE)
		return -1;
		
	return 0;
}

int Native_GetMissionLocalizedDisplayTitle(Handle plugin, int numParams) {
	if (numParams < 4)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int missionIndex = GetNativeCell(2);
	int length = GetNativeCell(4);
	int client = GetNativeCell(5);
	
	ArrayList missionDisplayTitleList = LMM_GetMissionDisplayTitleList(gamemode);
	if (missionDisplayTitleList == null)
		return -1;
	
	char displayTitleName[LEN_DISPLAYTITLE_NAME];
	missionDisplayTitleList.GetString(missionIndex, displayTitleName, sizeof(displayTitleName));
	
	char localizedName[LEN_LOCALIZED_NAME];

	if(displayTitleName[0] != '#' || loc.PhraseTranslateToLang(displayTitleName, localizedName, sizeof(localizedName), client, _, _, displayTitleName) == false)
	{
		if(TranslationPhraseExists(displayTitleName))
		{
			Format(localizedName, sizeof(localizedName), "%T", displayTitleName, client);
		}
		else
		{
			if (SetNativeString(3, displayTitleName, length, false) != SP_ERROR_NONE)
				return -1;
			return 0;
		}
	}

	if (SetNativeString(3, localizedName, length, false) != SP_ERROR_NONE)
		return -1;
		
	return 1;
}

int Native_GetMissionLocalizedName(Handle plugin, int numParams) {
	if (numParams < 4)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int missionIndex = GetNativeCell(2);
	int length = GetNativeCell(4);
	int client = GetNativeCell(5);
	
	ArrayList missionNameList = LMM_GetMissionNameList(gamemode);
	if (missionNameList == null)
		return -1;
	
	
	char missionName[LEN_MISSION_NAME];
	missionNameList.GetString(missionIndex, missionName, sizeof(missionName));
	
	char localizedName[LEN_LOCALIZED_NAME];
	if(TranslationPhraseExists(missionName))
	{
		Format(localizedName, sizeof(localizedName), "%T", missionName, client);
	}
	else
	{
		if (SetNativeString(3, missionName, length, false) != SP_ERROR_NONE)
			return -1;

		return 0;
	}

	if (SetNativeString(3, localizedName, length, false) != SP_ERROR_NONE)
		return -1;

	return 1;
}

int Native_GetNumberOfMaps(Handle plugin, int numParams) {
	if (numParams < 2)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int missionIndex = GetNativeCell(2);
	
	ArrayList entryList = LMM_GetEntryList(gamemode);
	if (entryList == null)
		return -1;
		
	if (missionIndex > entryList.Length - 1)
		return -1;
		
	int startMapIndex = entryList.Get(missionIndex);
	int endMapIndex = entryList.Get(missionIndex + 1);
		
	return endMapIndex - startMapIndex;
}

int Native_FindMapIndexByName(Handle plugin, int numParams) {
	if (numParams < 3)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int length;
	GetNativeStringLength(3, length);
	char[] mapName = new char[length+1];
	GetNativeString(3, mapName, length+1);
	
	// Ignore case, all to lower case
	String_ToLower(mapName, mapName, length+1);
	
	ArrayList mapList = LMM_GetMapList(gamemode);
	if (mapList == null)
		return -1;
	
	ArrayList entryList = LMM_GetEntryList(gamemode);
	
	int mapPos = mapList.FindString(mapName);
	if (mapPos < 0)
		return -1;
	
	int startMapIndex = 0;
	for (int nextMissionIndex=1; nextMissionIndex<mapList.Length+1; nextMissionIndex++){
		int nextStartMapIndex = entryList.Get(nextMissionIndex);
		
		if (startMapIndex <= mapPos && mapPos < nextStartMapIndex) {
			SetNativeCellRef(2, nextMissionIndex-1);
			return mapPos - startMapIndex;
		}
		
		startMapIndex = nextStartMapIndex;
	}
	
	return -1;
}

int Native_GetMapName(Handle plugin, int numParams) {
	if (numParams < 5)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int missionIndex = GetNativeCell(2);
	int mapIndex = GetNativeCell(3);
	int length = GetNativeCell(5);
	
	ArrayList entryList = LMM_GetEntryList(gamemode);
	if (entryList == null)
		return -1;
		
	if (missionIndex > entryList.Length - 1)
		return -1;
		
	int mapIndexOffset = entryList.Get(missionIndex);
	ArrayList mapList = LMM_GetMapList(gamemode);
	
	char mapName[LEN_MAP_FILENAME];
	mapList.GetString(mapIndexOffset+mapIndex, mapName, sizeof(mapName));
	
	if (SetNativeString(4, mapName, length, false) != SP_ERROR_NONE)
		return -1;
		
	return 0;
}

int Native_GetMapDisplayName(Handle plugin, int numParams) {
	if (numParams < 5)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int missionIndex = GetNativeCell(2);
	int mapIndex = GetNativeCell(3);
	int length = GetNativeCell(5);
	
	ArrayList entryList = LMM_GetEntryList(gamemode);
	if (entryList == null)
		return -1;
		
	if (missionIndex > entryList.Length - 1)
		return -1;
		
	int mapIndexOffset = entryList.Get(missionIndex);
	ArrayList mapDisplayNameList = LMM_GetMapDisplayNameList(gamemode);
	
	char mapDisplayName[LEN_MAP_DISPLAYNAME];
	mapDisplayNameList.GetString(mapIndexOffset+mapIndex, mapDisplayName, sizeof(mapDisplayName));
	
	if (SetNativeString(4, mapDisplayName, length, false) != SP_ERROR_NONE)
		return -1;
		
	return 0;
}

int Native_GetMapLocalizedName(Handle plugin, int numParams) {
	if (numParams < 4)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int missionIndex = GetNativeCell(2);
	int mapIndex = GetNativeCell(3);
	int length = GetNativeCell(5);
	int client = GetNativeCell(6);
	
	ArrayList entryList = LMM_GetEntryList(gamemode);
	if (entryList == null)
		return -1;
	
	
	ArrayList mapList = LMM_GetMapList(gamemode);
	char mapFileName[LEN_MAP_FILENAME];
	int offset = entryList.Get(missionIndex);
	mapList.GetString(offset + mapIndex, mapFileName, sizeof(mapFileName));
	
	if (TranslationPhraseExists(mapFileName)) {
		char localizedName[LEN_LOCALIZED_NAME];
		Format(localizedName, sizeof(localizedName), "%T", mapFileName, client);
		if (SetNativeString(4, localizedName, length, false) != SP_ERROR_NONE)
			return -1;
		return 1;
	} else {
		if (SetNativeString(4, mapFileName, length, false) != SP_ERROR_NONE)
			return -1;
		return 0;
	}
}

int Native_GetMapLocalizedDisplayName(Handle plugin, int numParams) {
	if (numParams < 4)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int missionIndex = GetNativeCell(2);
	int mapIndex = GetNativeCell(3);
	int length = GetNativeCell(5);
	int client = GetNativeCell(6);
	
	ArrayList entryList = LMM_GetEntryList(gamemode);
	if (entryList == null)
		return -1;
	
	
	ArrayList mapDisplayNameList = LMM_GetMapDisplayNameList(gamemode);
	char mapDisplayName[LEN_MAP_DISPLAYNAME];
	int offset = entryList.Get(missionIndex);
	mapDisplayNameList.GetString(offset + mapIndex, mapDisplayName, sizeof(mapDisplayName));

	char localizedName[LEN_LOCALIZED_NAME];

	if(mapDisplayName[0] != '#' || loc.PhraseTranslateToLang(mapDisplayName, localizedName, sizeof(localizedName), client, _, _, mapDisplayName) == false)
	{
		if(TranslationPhraseExists(mapDisplayName))
		{
			Format(localizedName, sizeof(localizedName), "%T", mapDisplayName, client);
		}
		else
		{
			if (SetNativeString(4, mapDisplayName, length, false) != SP_ERROR_NONE)
				return -1;
			return 0;
		}
	}

	if (SetNativeString(4, localizedName, length, false) != SP_ERROR_NONE)
		return -1;

	return 1;
}

int Native_GetMapUniqueID(Handle plugin, int numParams) {
	if (numParams < 3)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int missionIndex = GetNativeCell(2);
	int mapIndex = GetNativeCell(3);
	
	if (missionIndex < 0)
		return -1;
	
	ArrayList entryList = LMM_GetEntryList(gamemode);
	if (entryList == null)
		return -1;
		
	if (missionIndex > entryList.Length - 2)
		return -1;
		
	int offset = entryList.Get(missionIndex);
	return offset + mapIndex;
}

int Native_DecodeMapUniqueID(Handle plugin, int numParams) {
	if (numParams < 3)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	int mapPos = GetNativeCell(3);
		
	ArrayList mapList = LMM_GetMapList(gamemode);
	if (mapList == null)
		return -1;
	
	ArrayList entryList = LMM_GetEntryList(gamemode);
	
	int startMapIndex = 0;
	for (int nextMissionIndex=1; nextMissionIndex<mapList.Length+1; nextMissionIndex++){
		int nextStartMapIndex = entryList.Get(nextMissionIndex);
		
		if (startMapIndex <= mapPos && mapPos < nextStartMapIndex) {
			SetNativeCellRef(2, nextMissionIndex-1);
			return mapPos - startMapIndex;
		}
		
		startMapIndex = nextStartMapIndex;
	}
	
	return -1;
}

int Native_GetMapUniqueIDCount(Handle plugin, int numParams) {
	if (numParams < 1)
		return -1;
	
	// Get parameters
	LMM_GAMEMODE gamemode = view_as<LMM_GAMEMODE>(GetNativeCell(1));
	
	ArrayList mapList = LMM_GetMapList(gamemode);
	if (mapList == null)
		return -1;
		
	return mapList.Length;
}

int Native_GetNumberOfInvalidMissions(Handle plugin, int numParams) {
	return g_hStr_InvalidMissionNames.Length;
}

int Native_GetInvalidMissionName(Handle plugin, int numParams) {
	if (numParams < 2)
		return -1;
	
	int missionIndex = GetNativeCell(1);
	int length = GetNativeCell(3);
	
	char missionName[LEN_MISSION_NAME];
	g_hStr_InvalidMissionNames.GetString(missionIndex, missionName, sizeof(missionName));
	
	if (SetNativeString(2, missionName, length, false) != SP_ERROR_NONE)
		return -1;
		
	return 0;
}

/* ========== Mission Parser ========== */
// MissionParser state variables
int g_MissionParser_UnknownCurLayer;
int g_MissionParser_UnknownPreState;
int g_MissionParser_State;

enum 
{
	MPS_UNKNOWN = -1,
	MPS_ROOT = 0,
	MPS_MISSION,
	MPS_MODES,
	MPS_GAMEMODE,
	MPS_MAP,
}

LMM_GAMEMODE g_MissionParser_CurGameMode;
char g_MissionParser_MissionName[LEN_MISSION_NAME],
	g_MissionParser_DisplayTitle[LEN_DISPLAYTITLE_NAME];
int g_MissionParser_CurMapID;
ArrayList 
	g_hIntMap_Index,
	g_hStrMap_FileName,
	g_hStrMap_DisplayName;

SMCResult MissionParser_NewSection(SMCParser smc, const char[] name, bool opt_quotes) {
	switch (g_MissionParser_State) {
		case MPS_ROOT: {
			if(strcmp("mission", name, false)==0) {
				g_MissionParser_State = MPS_MISSION;
			} else {
				g_MissionParser_UnknownPreState = g_MissionParser_State;
				g_MissionParser_UnknownCurLayer = 1;
				g_MissionParser_State = MPS_UNKNOWN;
				// PrintToServer("MissionParser_NewSection found an unknown structure: %s",name);
			}
		}
		case MPS_MISSION: {
			if(StrEqual("modes", name, false)) {
				g_MissionParser_State = MPS_MODES;
				// PrintToServer("Entering modes section");
			} else {
				g_MissionParser_UnknownPreState = g_MissionParser_State;
				g_MissionParser_UnknownCurLayer = 1;
				g_MissionParser_State = MPS_UNKNOWN;
				// PrintToServer("MissionParser_NewSection found an unknown structure: %s",name);
			}
		}
		case MPS_MODES: {
			g_MissionParser_CurGameMode = LMM_StringToGamemode(name);
			if (g_MissionParser_CurGameMode == LMM_GAMEMODE_UNKNOWN) {
				g_MissionParser_UnknownPreState = g_MissionParser_State;
				g_MissionParser_UnknownCurLayer = 1;
				g_MissionParser_State = MPS_UNKNOWN;
				// PrintToServer("MissionParser_NewSection found an unknown structure: %s",name);
			} else {
				delete g_hIntMap_Index;
				delete g_hStrMap_FileName;
				delete g_hStrMap_DisplayName;
				g_hIntMap_Index = new ArrayList(1);
				g_hStrMap_FileName = new ArrayList(LEN_MAP_FILENAME);
				g_hStrMap_DisplayName = new ArrayList(LEN_MAP_DISPLAYNAME);

				g_MissionParser_State = MPS_GAMEMODE;
			}
			
			// PrintToServer("Enter gamemode: %d (%s)", g_MissionParser_CurGameMode, name);
		}
		case MPS_GAMEMODE: {
			int mapID = StringToInt(name);
			if (mapID > 0) {	// Valid map section
				g_MissionParser_State = MPS_MAP;
				g_MissionParser_CurMapID = mapID;
			} else {
				// Skip invalid sections
				g_MissionParser_UnknownPreState = g_MissionParser_State;
				g_MissionParser_UnknownCurLayer = 1;
				g_MissionParser_State = MPS_UNKNOWN;
				//PrintToServer("MissionParser_NewSection found an unknown structure: %s",name);
			}
		}
		case MPS_MAP: {
			// Do not traverse further
			g_MissionParser_UnknownPreState = g_MissionParser_State;
			g_MissionParser_UnknownCurLayer = 1;
			g_MissionParser_State = MPS_UNKNOWN;
			//PrintToServer("MissionParser_NewSection found an unknown structure: %s",name);
		}
		
		case MPS_UNKNOWN: { // Traverse through unknown structures
			g_MissionParser_UnknownCurLayer++;
		}
	}
	
	return SMCParse_Continue;
}

SMCResult MissionParser_KeyValue(SMCParser smc, const char[] key, const char[] value, bool key_quotes, bool value_quotes) {
	switch (g_MissionParser_State) {
		case MPS_MISSION: {
			if (strcmp("Name", key, false)==0) {
				strcopy(g_MissionParser_MissionName, LEN_MISSION_NAME, value);
			}
			else if (strcmp("DisplayTitle", key, false)==0) {
				strcopy(g_MissionParser_DisplayTitle, LEN_DISPLAYTITLE_NAME, value);
			}
		}
		case MPS_MAP: {
			if (StrEqual("Map", key, false)) {
				g_hIntMap_Index.Push(g_MissionParser_CurMapID);
				char mapFileName[LEN_MAP_FILENAME];
				String_ToLower(value, mapFileName, sizeof(mapFileName));
				g_hStrMap_FileName.PushString(mapFileName);
				// PrintToServer("Map %d: %s", g_MissionParser_CurMapID, value);
			}
			else if (strcmp("DisplayName", key, false)==0) {
				char mapDisplayName[LEN_MAP_FILENAME];
				FormatEx(mapDisplayName, LEN_MAP_DISPLAYNAME, value);
				g_hStrMap_DisplayName.PushString(mapDisplayName);
			}
		}
	}
	
	return SMCParse_Continue;
}

SMCResult MissionParser_EndSection(SMCParser smc) {
	switch (g_MissionParser_State) {
		case MPS_MISSION: {
			g_MissionParser_State = MPS_ROOT;
		}
		
		case MPS_MODES: {
			// PrintToServer("Leaving modes section");
			g_MissionParser_State = MPS_MISSION;
		}
		
		case MPS_GAMEMODE: {
			// PrintToServer("Leaving gamemode: %d", g_MissionParser_CurGameMode);
			g_MissionParser_State = MPS_MODES;
			
			int numOfValidMaps = 0;
			char mapFile[LEN_MAP_FILENAME];
			// Make sure that all map indexes are consecutive and start from 1
			// And validate maps
			for (int iMap=1; iMap<=g_hIntMap_Index.Length; iMap++) {
				int index = g_hIntMap_Index.FindValue(iMap);
				if (index < 0) {
					char gamemodeName[LEN_GAMEMODE_NAME];
					LMM_GamemodeToString(g_MissionParser_CurGameMode, gamemodeName, sizeof(gamemodeName));
					if (g_hStr_InvalidMissionNames.FindString(g_MissionParser_MissionName) < 0) {
						g_hStr_InvalidMissionNames.PushString(g_MissionParser_MissionName);
					}
					SaveMessage("Mission %s contains invalid \"%s\" section", g_MissionParser_MissionName, gamemodeName);
					continue;
					//return SMCParse_HaltFail;
				}
				
				g_hStrMap_FileName.GetString(index, mapFile, sizeof(mapFile));
				if (!IsMapValid(mapFile)) {
					char gamemodeName[LEN_GAMEMODE_NAME];
					LMM_GamemodeToString(g_MissionParser_CurGameMode, gamemodeName, sizeof(gamemodeName));
					if (g_hStr_InvalidMissionNames.FindString(g_MissionParser_MissionName) < 0) {
						g_hStr_InvalidMissionNames.PushString(g_MissionParser_MissionName);
					}
					SaveMessage("Mission %s contains invalid map: \"%s\", gamemode: \"%s\"", g_MissionParser_MissionName, mapFile, gamemodeName);
					continue;
					//return SMCParse_HaltFail;
				}
				else
				{
					numOfValidMaps++;
				}
			}
			
			if (numOfValidMaps < 1) {
				char gamemodeName[LEN_GAMEMODE_NAME];
				LMM_GamemodeToString(g_MissionParser_CurGameMode, gamemodeName, sizeof(gamemodeName));
				SaveMessage("Mission %s does not contain any valid map in gamemode: \"%s\"", g_MissionParser_MissionName, gamemodeName);
				return SMCParse_Continue;
			}
			
			// Add them to corresponding map lists
			// Add them to corresponding map display name lists
			ArrayList mapList = LMM_GetMapList(g_MissionParser_CurGameMode);
			ArrayList mapDisplayNameList = LMM_GetMapDisplayNameList(g_MissionParser_CurGameMode);
			char mapDisplayName[LEN_MAP_DISPLAYNAME];
			
			for (int iMap=1; iMap<=g_hIntMap_Index.Length; iMap++) {
				int index = g_hIntMap_Index.FindValue(iMap);
				
				g_hStrMap_FileName.GetString(index, mapFile, sizeof(mapFile));
				mapList.PushString(mapFile);

				g_hStrMap_DisplayName.GetString(index, mapDisplayName, sizeof(mapDisplayName));
				mapDisplayNameList.PushString(mapDisplayName);
			}
			
			// Add a new entry
			ArrayList entryList = LMM_GetEntryList(g_MissionParser_CurGameMode);
			int lastOffset = entryList.Get(entryList.Length-1);
			entryList.Push(lastOffset+g_hIntMap_Index.Length);
			
			// Add to mission name list
			ArrayList missionName = LMM_GetMissionNameList(g_MissionParser_CurGameMode);
			missionName.PushString(g_MissionParser_MissionName);

			// Add to display title list
			ArrayList missionDisplayTitleList = LMM_GetMissionDisplayTitleList(g_MissionParser_CurGameMode);
			missionDisplayTitleList.PushString(g_MissionParser_DisplayTitle);
		}
		
		case MPS_MAP: {
			g_MissionParser_State = MPS_GAMEMODE;
		}
		
		case MPS_UNKNOWN: { // Traverse through unknown structures
			g_MissionParser_UnknownCurLayer--;
			if (g_MissionParser_UnknownCurLayer == 0) {
				g_MissionParser_State = g_MissionParser_UnknownPreState;
			}
		}
	}
	
	return SMCParse_Continue;
}

void CopyFile(const char[] src, const char[] target) {
	File fileSrc;
	fileSrc = OpenFile(src, "rb", true, NULL_STRING);
	if (fileSrc != null) {
		File fileTarget;
		fileTarget = OpenFile(target, "wb", true, NULL_STRING);
		if (fileTarget != null) {
			int buffer[256]; // 256Bytes each time
			int numOfElementRead;
			while (!fileSrc.EndOfFile()){
				numOfElementRead = fileSrc.Read(buffer, 256, 1);
				fileTarget.Write(buffer, numOfElementRead, 1);
			}
			FlushFile(fileTarget);
			fileTarget.Close();
		}
		fileSrc.Close();
	}
}

void CacheMissions() {
	DirectoryListing dirList;
	dirList = OpenDirectory("missions", true, NULL_STRING);

	if (dirList == null) {
        SaveMessage("[SM] Plugin is not running! Could not locate mission folder");
        SetFailState("Could not locate mission folder");
	} else {	
		if (!DirExists("missions.cache")) {
			CreateDirectory("missions.cache", 511);
		}
		
		char missionFileName[PLATFORM_MAX_PATH];
		FileType fileType;
		while(dirList.GetNext(missionFileName, PLATFORM_MAX_PATH, fileType)) {
			if (fileType == FileType_File &&
			strcmp("credits.txt", missionFileName, false) != 0
			) {
				char missionSrc[PLATFORM_MAX_PATH];
				char missionCache[PLATFORM_MAX_PATH];
				missionSrc = "missions/";

				Format(missionSrc, PLATFORM_MAX_PATH, "missions/%s", missionFileName);
				Format(missionCache, PLATFORM_MAX_PATH, "missions.cache/%s", missionFileName);
				// PrintToServer("Cached mission file %s", missionFileName);
				
				if (!FileExists(missionCache, true, NULL_STRING)) {
					CopyFile(missionSrc, missionCache);
				}

				g_hMissionsMap.SetValue(missionFileName, true);
			}
			
		}
		
		delete dirList;
	}
}

void ParseMissions() {
	DirectoryListing dirList;
	dirList = OpenDirectory("missions.cache", true, NULL_STRING);
	
	if (dirList == null) {
		SaveMessage("The \"missions.cache\" folder was not found!");
	} else {
		// Create the parser
		SMCParser parser = SMC_CreateParser();
		parser.OnEnterSection = MissionParser_NewSection;
		parser.OnLeaveSection = MissionParser_EndSection;
		parser.OnKeyValue = MissionParser_KeyValue;
		
		delete g_hIntMap_Index;
		g_hIntMap_Index = new ArrayList(1);
		
		delete g_hStrMap_FileName;
		g_hStrMap_FileName = new ArrayList(LEN_MAP_FILENAME);
	
		char missionCache[PLATFORM_MAX_PATH];
		char missionFileName[PLATFORM_MAX_PATH];
		FileType fileType;
		bool bTemp;
		while(dirList.GetNext(missionFileName, PLATFORM_MAX_PATH, fileType)) {
			if (fileType == FileType_File) {
				if(g_hMissionsMap.GetValue(missionFileName, bTemp) == false) continue;

				Format(missionCache, PLATFORM_MAX_PATH, "missions.cache/%s", missionFileName);
				
				// Process the mission file				
				g_MissionParser_State = MPS_ROOT;
				SMCError err = parser.ParseFile(missionCache);
				if (err != SMCError_Okay) {
					g_hStr_InvalidMissionNames.PushString(missionCache);
					SaveMessage("An error occured while parsing %s, code:%d", missionCache, err);
				}
			}
		}
		
		delete g_hIntMap_Index;
		delete g_hStrMap_FileName;
		delete dirList;	
		delete parser;
	}
}

/* ========== Utils ========== */
int String_ToLower(const char[] input, char[] output, int size) {
	size--;
	int x = 0;
	while (input[x] != '\0' && x < size) {
		output[x] = CharToLower(input[x]);
		x++;
	}
	output[x] = '\0';
	
	return x+1;
}

/* int FindStringInArrayEx(Handle array, const char[] item, bool caseSensitive = false, int lastFound = 0) {
	int maxLength = strlen(item)+1;
	char[] buffer = new char[maxLength];
	int arrayLength = GetArraySize(array);
	for (int curIndex=lastFound; curIndex<arrayLength; curIndex++) {
		GetArrayString(array, curIndex, buffer, maxLength);
		
		if (StrEqual(buffer, item, caseSensitive)) {
			return curIndex;
		}
	}
	
	return -1;
} */


void SaveMessage(const char[] message, any ...)
{
	static char DebugBuff[256];
	VFormat(DebugBuff, sizeof(DebugBuff), message, 2);

	static char time[32];
	FormatTime(time, sizeof(time), "%Y-%m-%d %H:%M:%S", -1);

	Format(DebugBuff, sizeof(DebugBuff), "[%s] %s", time, DebugBuff);
		
	Handle fileHandle = OpenFile(g_sFile, "a");  /* Append */
	if(fileHandle == null)
	{
		return;
	}

	WriteFileLine(fileHandle, DebugBuff);
	delete fileHandle;
}