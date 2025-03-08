/**
 * 來源: https://gitee.com/honghl5/open-source-plug-in/tree/main/l4d2_mixmap
 * 別人寫的插件: 輸入!mixmap可以投票，通過後隨機切換五個關卡
 * 1. 可適用於戰役模式
 * 2. 支援L4D1
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <multicolors>
#include <builtinvotes> //https://github.com/fbef0102/Game-Private_Plugin/releases/tag/builtinvotes
#undef REQUIRE_PLUGIN
#tryinclude <readyup>
#tryinclude <l4d2_map_transitions>

#if !defined _readyup_included_
	native bool EditFooterStringAtIndex(int index, const char[] string);
	native int AddStringToReadyFooter(const char[] footer);
#endif


public Plugin myinfo =
{
	name = "[L4D1/L4D2] Mix Map",
	author = "Bred, Harry",
	description = "Randomly select five maps for versus/coop/realism. Adding for fun",
	version = "1.3h-2025/3/8",
	url = "https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d2_mixmap"
};

Handle g_hForwardStart;
Handle g_hForwardLoaded;
Handle g_hForwardEnd;

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

	MarkNativeAsOptional("EditFooterStringAtIndex");
	MarkNativeAsOptional("AddStringToReadyFooter");

	CreateNative("l4d2_mixmap_IsActive",	Native_IsActive);
	CreateNative("l4d2_mixmap_GetNextMap",	Native_GetNextMap);

	// Right before loading first map; params: 1 = maplist size; 2 = name of first map
	g_hForwardStart = CreateGlobalForward("OnCMTStart", ET_Ignore, Param_Cell, Param_String );
	// After loading a map (to let other plugins know what the next map will be ahead of time); 1 = name of next map
	g_hForwardLoaded = CreateGlobalForward("OnCMTLoaded", ET_Ignore, Param_String );
	// After last map is played; no params
	g_hForwardEnd = CreateGlobalForward("OnCMTEnd", ET_Ignore );

	RegPluginLibrary("l4d2_mixmap");

	return APLRes_Success;
}

#define SECTION_NAME "CTerrorGameRules::SetCampaignScores"
#define LEFT4FRAMEWORK_GAMEDATA_L4D2 "left4dhooks.l4d2"
#define LEFT4FRAMEWORK_GAMEDATA_L4D1 "left4dhooks.l4d1"

#define DIR_CFGS_L4D2 		"l4d2_mixmap/l4d2/"
#define DIR_CFGS_L4D1 		"l4d2_mixmap/l4d1/"
#define PATH_KV  			"mapnames.txt"
#define CFG_DEFAULT			"default"
#define CFG_DODEFAULT		"disorderdefault"
#define CFG_DODEFAULT_ST	"do"
#define CFG_ALLOF			"official"
#define CFG_ALLOF_ST		"of"
#define	CFG_DOALLOF			"disorderofficial"
#define	CFG_DOALLOF_ST		"doof"
#define	CFG_UNOF			"unofficial"
#define	CFG_UNOF_ST			"uof"
#define	CFG_DOUNOF			"disorderunofficial"
#define	CFG_DOUNOF_ST		"douof"
#define BUF_SZ   			128

ConVar 	g_cvNextMapPrint,
		g_cvMaxMapsNum;
		//g_cvFinaleEndCoop,
		//g_cvFinaleEndVersus;

char cfg_exec[BUF_SZ];

//与随机抽签相关的变量
ArrayList g_hArrayTags;				// Stores tags for indexing g_hTriePools 存放地图池标签
StringMap g_hTriePools;				// Stores pool array handles by tag name 存放由标签分类的地图, tag - ArrayList
ArrayList g_hArrayTagOrder;			// Stores tags by rank 存放标签顺序
ArrayList g_hArrayMapOrder;			// Stores finalised map list in order 存放抽取完成后的地图顺序
KeyValues g_hKvMapNames;

bool 
	g_bServerForceStart,
	g_bRoundIsLive, 
	g_bReadyUpFooterAdded,
	g_bMaplistFinalized,
	g_bMapsetInitialized;

Handle 
	g_hCountDownTimer,
	g_hUpdateFooterTimer,
	g_hDifferAbortTimer;

char 
	g_slandmarkName[BUF_SZ],
	g_sNextMixMap[BUF_SZ];

int 
	g_iReadyUpFooterIndex,
    g_iRoundStart, 
    g_iPlayerSpawn,
	g_iMapsPlayed, 
	g_iMapCount;

public void OnPluginStart() 
{
	LoadTranslations("l4d2_mixmap.phrases");

	g_cvNextMapPrint		= CreateConVar("l4d2mm_nextmap_print",		"1",	"If 1, show what the next map will be", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_cvMaxMapsNum			= CreateConVar("l4d2mm_max_maps_num",		"2",	"Determine how many maps of one campaign can be selected; 0 = no limits;", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	//g_cvFinaleEndCoop		= CreateConVar("l4d2mm_finale_end_coop",	"0",	"If 1, auto force start mixmap in the end of finale in coop/realism mode (When mixmap is alreaedy on)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	//g_cvFinaleEndVersus	= CreateConVar("l4d2mm_finale_end_verus",	"0",	"If 1, auto force start mixmap in the end of finale in versus mode (When mixmap is alreaedy on)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig(true, 			   	   "l4d2_mixmap");

	//Servercmd 服务器指令（用于cfg文件）
	RegServerCmd( "sm_addmap", AddMap, "Add a chatper and tag 新增關卡名稱與標記, Usage: sm_addmap <map_name> <tag>");
	RegServerCmd( "sm_tagrank", TagRank, "Define <tag> map order 決定標記的地圖順序, Usage: sm_addmap <tag> <number>, number starting from 0");

	//Start/Stop 启用/中止指令
	RegAdminCmd( "sm_manualmixmap", ManualMixmap, ADMFLAG_ROOT, "Start mixmap with specified maps 启用mixmap加载特定地图顺序的地图组");
	RegAdminCmd( "sm_fmixmap", ForceMixmap, ADMFLAG_ROOT, "Force start mixmap (arg1 empty for 'default' maps pool) 强制启用mixmap（随机官方地图）");
	RegConsoleCmd( "sm_mixmap", Mixmap_Cmd, "Vote to start a mixmap (arg1 empty for 'default' maps pool);通过投票启用Mixmap，并可加载特定的地图池；无参数则启用官图顺序随机");
	RegConsoleCmd( "sm_stopmixmap",	StopMixmap_Cmd, "Vote to Stop a mixmap;中止mixmap，并初始化地图列表");
	RegAdminCmd( "sm_fstopmixmap",	StopMixmap, ADMFLAG_ROOT, "Force stop a mixmap ;强制中止mixmap，并初始化地图列表");

	//Midcommand 插件启用后可使用的指令
	RegConsoleCmd( "sm_mixmaplist", MixMaplist, "Show the mix map list; 展示mixmap最终抽取出的地图列表");
	//RegAdminCmd( "sm_allmap", ShowAllMaps, ADMFLAG_ROOT, "Show all official maps code; 展示所有官方地图的地图代码");
	//RegAdminCmd( "sm_allmaps", ShowAllMaps, ADMFLAG_ROOT, "Show all official maps code; 展示所有官方地图的地图代码");

	HookEvent("round_start", Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn",           Event_PlayerSpawn);
	HookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy); //trigger twice in versus/survival/scavenge mode, one when all survivors wipe out or make it to saferom, one when first round ends (second round_start begins).
	HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //1. all survivors make it to saferoom in and server is about to change next level in coop mode (does not trigger round_end), 2. all survivors make it to saferoom in versus
	HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy); //final map final rescue vehicle leaving  (does not trigger round_end)

	HookEvent("map_transition", 			map_transition,		EventHookMode_PostNoCopy); //1. all survivors make it to saferoom in and server is about to change next level in coop mode (does not trigger round_end), 2. all survivors make it to saferoom in versus
	HookEvent("finale_win", 				finale_win);

	PluginStartInit();
	
}

bool g_ReadyUpAvailable;
public void OnAllPluginsLoaded()
{
	g_ReadyUpAvailable = LibraryExists("readyup");
}

public void OnLibraryRemoved(const char[] name)
{
	g_ReadyUpAvailable = LibraryExists("readyup");
}

public void OnLibraryAdded(const char[] name)
{
	g_ReadyUpAvailable = LibraryExists("readyup");
}

// Otherwise nextmap would be stuck and people wouldn't be able to play normal campaigns without the plugin 结束后初始化sm_nextmap的值
public void OnPluginEnd() 
{
	ServerCommand("sm_nextmap \"\"");
	ClearDefault();
}

// Sourcemod API Forward-------------------------------

public void OnMapStart() 
{
	g_sNextMixMap[0] = '\0'; 

	delete g_hKvMapNames;
	g_hKvMapNames = new KeyValues("Mixmap Map Names");
	char sbuffer[BUF_SZ];
	if(g_bL4D2Version) Format(sbuffer, sizeof(sbuffer), "cfg/%s%s", DIR_CFGS_L4D2, PATH_KV);
	else Format(sbuffer, sizeof(sbuffer), "cfg/%s%s", DIR_CFGS_L4D1, PATH_KV);

	if (!FileToKeyValues(g_hKvMapNames, sbuffer)) 
	{
		LogError("Couldn't create KV for map names: %s", sbuffer);
		g_hKvMapNames = null;
		return;
	}

	if(!g_bL4D2Version)
	{
		PrecacheSound("ui/menu_enter05.wav");
		PrecacheSound("ui/beep_synthtone01.wav");
		PrecacheSound("ui/beep_error01.wav");
	}

	ServerCommand("sm_nextmap \"\"");

	char buffer[BUF_SZ];

	//判断currentmap与预计的map的name是否一致，如果不一致就stopmixmap
	if (g_bMapsetInitialized)
	{
		if(g_iMapsPlayed >= g_iMapCount)
		{
			PluginStartInit();
			return;
		}

		char OriginalSetMapName[BUF_SZ];
		GetCurrentMap(buffer, BUF_SZ);
		g_hArrayMapOrder.GetString(g_iMapsPlayed, OriginalSetMapName, BUF_SZ);

		if (!StrEqual(buffer,OriginalSetMapName) && g_bMaplistFinalized)
		{
			PluginStartInit();
			
			delete g_hDifferAbortTimer;
			g_hDifferAbortTimer = CreateTimer(60.0, Timer_DifferAbort);
			return;
		}
	}
	else
	{
		return;
	}

	// let other plugins know what the map *after* this one will be (empty if it is the last map)
	if (g_iMapsPlayed >= g_iMapCount-1) 
	{
		g_sNextMixMap[0] = '\0'; 
		Call_StartForward(g_hForwardLoaded);
		Call_PushString(g_sNextMixMap);
		Call_Finish();
		return;
	}

	g_hArrayMapOrder.GetString(g_iMapsPlayed+1, g_sNextMixMap, BUF_SZ);

	//CreateTimer(5.0, Timer_FindInfoChangelevel, _, TIMER_FLAG_NO_MAPCHANGE);

	Call_StartForward(g_hForwardLoaded);
	Call_PushString(g_sNextMixMap);
	Call_Finish();
}

public void OnMapEnd()
{
	delete g_hUpdateFooterTimer;
	delete g_hDifferAbortTimer;

	ClearDefault();
}

public void OnClientPutInServer(int client)
{	
	if(IsFakeClient(client)) return;

	CreateTimer(10.0, Timer_ShowMaplist, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);//玩家加入服务器后，10s后提示正在使用mixmap插件。
}

/*public void OnEntityCreated(int entity, const char[] classname)
{
	if (!g_bMapsetInitialized || !IsValidEntityIndex(entity))
		return;

	switch (classname[0])
	{
		case 'i':
		{
			if (StrEqual(classname, "info_landmark"))
			{
				RemoveEntity(entity);
			}
		}
	}
}*/

// Command-------------------------------

Action Timer_ShowMaplist(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if (client && IsClientInGame(client))
	{
		if(g_hDifferAbortTimer != null)
		{
			CPrintToChat(client, "%T", "Differ_Abort", client);
		}
		else if(g_bMapsetInitialized)
		{
			CPrintToChat(client, "%T", "Auto_Show_Maplist", client);
		}
	}
	
	return Plugin_Handled;
}

// Loads a specified set of maps
Action ForceMixmap(int client, int args) 
{
	Format(cfg_exec, sizeof(cfg_exec), CFG_DEFAULT);
	
	if (args >=1)
	{
		char sbuffer[BUF_SZ];
		char arg[BUF_SZ];
		GetCmdArg(1, arg, BUF_SZ);
		if(g_bL4D2Version) Format(sbuffer, sizeof(sbuffer), "cfg/%s%s.cfg", DIR_CFGS_L4D2, arg);
		else Format(sbuffer, sizeof(sbuffer), "cfg/%s%s.cfg", DIR_CFGS_L4D1, arg);
		if (FileExists(sbuffer)) Format(cfg_exec, sizeof(cfg_exec), arg);
		else
		{
			if (StrEqual(arg,CFG_DODEFAULT_ST))
				Format(cfg_exec, sizeof(cfg_exec), CFG_DODEFAULT);
			else if (StrEqual(arg, CFG_ALLOF_ST))
				Format(cfg_exec, sizeof(cfg_exec), CFG_ALLOF);
			else if (StrEqual(arg, CFG_DOALLOF_ST))
				Format(cfg_exec, sizeof(cfg_exec), CFG_DOALLOF);
			else if (StrEqual(arg, CFG_UNOF_ST))
					Format(cfg_exec, sizeof(cfg_exec), CFG_UNOF);
			else if (StrEqual(arg, CFG_DOUNOF_ST))
				Format(cfg_exec, sizeof(cfg_exec), CFG_DOUNOF);
			else
			{
				CReplyToCommand(client, "%T", "Invalid_Cfg", client);
				return Plugin_Handled;
			}
		}
	}
	if (client) CPrintToChatAllEx(client, "%t", "Force_Start", client, cfg_exec);
	PluginStartInit();
	if (client == 0) g_bServerForceStart = true;
	if(g_bL4D2Version) ServerCommand("exec %s%s.cfg", DIR_CFGS_L4D2, cfg_exec);
	else ServerCommand("exec %s%s.cfg", DIR_CFGS_L4D1, cfg_exec);
	
	g_bMapsetInitialized = true;
	CreateTimer(0.1, Timed_PostMapSet, _, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Handled;
}

// Load a specified set of maps
Action ManualMixmap(int client, int args) 
{
	if (args < 1) 
	{
		CPrintToChat(client, "%T", "Manualmixmap_Syntax", client);
	}
	
	PluginStartInit();

	char map[BUF_SZ];
	for (int i = 1; i <= args; i++) 
	{
		GetCmdArg(i, map, BUF_SZ);
		ServerCommand("sm_addmap %s %d", map, i);
		ServerCommand("sm_tagrank %d %d", i, i-1);
	}
	g_bMapsetInitialized = true;
	CreateTimer(0.1, Timed_PostMapSet, _, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Handled;
}
/*
Action ShowAllMaps(int client, int Args)
{
	CPrintToChat(client, "%T", "AllMaps_Official", client);

	if(g_bL4D2Version)
	{
		CPrintToChat(client, "c1m1_hotel,c1m2_streets,c1m3_mall,c1m4_atrium");
		CPrintToChat(client, "c2m1_highway,c2m2_fairgrounds,c2m3_coaster,c2m4_barns,c2m5_concert");
		CPrintToChat(client, "c3m1_plankcountry,c3m2_swamp,c3m3_shantytown,c3m4_plantation");
		CPrintToChat(client, "c4m1_milltown_a,c4m2_sugarmill_a,c4m3_sugarmill_b,c4m4_milltown_b,c4m5_milltown_escape");
		CPrintToChat(client, "c5m1_waterfront,c5m2_park,c5m3_cemetery,c5m4_quarter,c5m5_bridge");
		CPrintToChat(client, "c6m1_riverbank,c6m2_bedlam,c7m1_docks,c7m2_barge,c7m3_port");
		CPrintToChat(client, "c8m1_apartment,c8m2_subway,c8m3_sewers,c8m4_interior,c8m5_rooftop");
		CPrintToChat(client, "c9m1_alleys,c9m2_lots,c14m1_junkyard,c14m2_lighthouse");
		CPrintToChat(client, "c10m1_caves,c10m2_drainage,c10m3_ranchhouse,c10m4_mainstreet,c10m5_houseboat");
		CPrintToChat(client, "c11m1_greenhouse,c11m2_offices,c11m3_garage,c11m4_terminal,c11m5_runway");
		CPrintToChat(client, "c12m1_hilltop,c12m2_traintunnel,c12m3_bridge,c12m4_barn,c12m5_cornfield");
		CPrintToChat(client, "c13m1_alpinecreek,c13m2_southpinestream,c13m3_memorialbridge,c13m4_cutthroatcreek");
	}
	else
	{
		CPrintToChat(client, "l4d_vs_hospital01_apartment,l4d_vs_hospital02_subway,l4d_vs_hospital03_sewers,l4d_vs_hospital04_interior,l4d_vs_hospital05_rooftop");
		CPrintToChat(client, "l4d_vs_smalltown01_caves,l4d_vs_smalltown02_drainage,l4d_vs_smalltown03_ranchhouse,l4d_vs_smalltown04_mainstreet,l4d_vs_smalltown05_houseboat");
		CPrintToChat(client, "l4d_vs_airport01_greenhouse,l4d_vs_airport02_offices,l4d_vs_airport03_garage,l4d_vs_airport04_terminal,l4d_vs_airport05_runway");
		CPrintToChat(client, "l4d_vs_farm01_hilltop,l4d_vs_farm02_traintunnel,l4d_vs_farm03_bridge,l4d_vs_farm04_barn,l4d_vs_farm05_cornfield");
		CPrintToChat(client, "l4d_garage01_alleys,l4d_garage02_lots");
		CPrintToChat(client, "l4d_river01_docks,l4d_river02_barge,l4d_river03_port");
	}

	CPrintToChat(client, "%T", "AllMaps_Usage", client);
	
	return Plugin_Handled;
}
*/

Action Mixmap_Cmd(int client, int args) 
{
	if (IsClientAndInGame(client))
	{
		if(L4D_IsSurvivalMode() || (g_bL4D2Version && L4D2_IsScavengeMode()))
		{
			CPrintToChat(client, "%T", "Mode not support", client);
			return Plugin_Handled;
		}

		if(g_ReadyUpAvailable && g_bRoundIsLive)
		{
			CPrintToChat(client, "%T", "Round is live", client);
			return Plugin_Handled;
		}
		
		if(GetClientTeam(client) <= 1)
		{
			CPrintToChat(client, "%T", "Spectator Blocked", client);
			return Plugin_Handled;
		}

		if (!IsBuiltinVoteInProgress())
		{
			Format(cfg_exec, sizeof(cfg_exec), CFG_DEFAULT);
	
			if (args >=1)
			{
				char sbuffer[BUF_SZ];
				char arg[BUF_SZ];
				GetCmdArg(1, arg, BUF_SZ);
				if(g_bL4D2Version) Format(sbuffer, sizeof(sbuffer), "cfg/%s%s.cfg", DIR_CFGS_L4D2, arg);
				else Format(sbuffer, sizeof(sbuffer), "cfg/%s%s.cfg", DIR_CFGS_L4D1, arg);
				if (FileExists(sbuffer)) Format(cfg_exec, sizeof(cfg_exec), arg);
				else
				{
					if (StrEqual(arg,CFG_DODEFAULT_ST))
						Format(cfg_exec, sizeof(cfg_exec), CFG_DODEFAULT);
					else if (StrEqual(arg, CFG_ALLOF_ST))
						Format(cfg_exec, sizeof(cfg_exec), CFG_ALLOF);
					else if (StrEqual(arg, CFG_DOALLOF_ST))
						Format(cfg_exec, sizeof(cfg_exec), CFG_DOALLOF);
					else if (StrEqual(arg, CFG_UNOF_ST))
							Format(cfg_exec, sizeof(cfg_exec), CFG_UNOF);
					else if (StrEqual(arg, CFG_DOUNOF_ST))
						Format(cfg_exec, sizeof(cfg_exec), CFG_DOUNOF);
					else
					{
						CPrintToChat(client, "%T", "Invalid_Cfg", client);
						return Plugin_Handled;
					}
				}
			}
			
			int iNumPlayers;
			int[] iPlayers = new int[MaxClients];
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientAndInGame(i) || (GetClientTeam(i) == 1))
				{
					continue;
				}
				iPlayers[iNumPlayers++] = i;
			}
			
			char cVoteTitle[64];
			Format(cVoteTitle, sizeof(cVoteTitle), "%T", "Cvote_Title", LANG_SERVER, cfg_exec);

			Handle hVote = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);

			SetBuiltinVoteArgument(hVote, cVoteTitle);
			SetBuiltinVoteInitiator(hVote, client);
			SetBuiltinVoteResultCallback(hVote, VoteMixmapResultHandler);
			DisplayBuiltinVote(hVote, iPlayers, iNumPlayers, 20);

			CPrintToChatAllEx(client, "%t", "Start_Mixmap", client, cfg_exec);
			if(g_bL4D2Version) FakeClientCommand(client, "Vote Yes");
			if(!g_bL4D2Version) EmitSoundToAll("ui/beep_synthtone01.wav");
		}
		else
		{
			CPrintToChat(client, "%T", "Vote_Blocked", client);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

// Specifiy a rank for a given tag
Action TagRank(int args) 
{
	if (args < 2) 
	{
		ReplyToCommand(0, "Syntax: sm_tagrank <tag> <map number>");
		ReplyToCommand(0, "Sets tag <tag> as the tag to be used to fetch maps for map <map number> in the map list.");
		ReplyToCommand(0, "Rank 0 is map 1, rank 1 is map 2, etc.");

		return Plugin_Handled;
	}

	char buffer[BUF_SZ];
	GetCmdArg(2, buffer, BUF_SZ);
	int index = StringToInt(buffer);

	GetCmdArg(1, buffer, BUF_SZ);

	if (index >= g_hArrayTagOrder.Length) 
	{
		g_hArrayTagOrder.Resize(index + 1);
	}

	g_iMapCount++;
	g_hArrayTagOrder.SetString(index, buffer);
	if (g_hArrayTags.FindString(buffer) < 0) 
	{
		g_hArrayTags.PushString(buffer);
	}

	return Plugin_Handled;
}

// Add a map to the maplist under specified tags
Action AddMap(int args) 
{
	if (args < 2) 
	{
		ReplyToCommand(0, "Syntax: sm_addmap <mapname> <tag1> <tag2> <...>");
		ReplyToCommand(0, "Adds <mapname> to the map selection and tags it with every mentioned tag.");

		return Plugin_Handled;
	}

	char map[BUF_SZ];
	GetCmdArg(1, map, BUF_SZ);
	if(!IsMapValid(map))
	{
		//LogError("[MixMap] mapname: %s is invalid", map);
		ReplyToCommand(0, "[MixMap] mapname: %s is invalid", map);
		PrintToChatAll("[MixMap] mapname: %s is invalid", map);

		return Plugin_Handled;
	}

	char tag[BUF_SZ];

	//add the map under only one of the tags
	//TODO - maybe we should add it under all tags, since it might be removed from 1+ or even all of them anyway
	//also, if that ends up being implemented, remember to remove vetoed maps from ALL the pools it belongs to
	if (args == 2) 
	{
		GetCmdArg(2, tag, BUF_SZ);
	} 
	else 
	{
		GetCmdArg(GetRandomInt(2, args), tag, BUF_SZ);
	}

	ArrayList hArrayMapPool;
	if (!g_hTriePools.GetValue(tag, hArrayMapPool)) 
	{
		hArrayMapPool = new ArrayList(BUF_SZ/4);
		g_hTriePools.SetValue(tag, hArrayMapPool);
	}

	hArrayMapPool.PushString(map);

	return Plugin_Handled;
}

// Display current map list
Action MixMaplist(int client, int args) 
{
	if (! g_bMaplistFinalized) 
	{
		CPrintToChat(client, "%T", "Show_Maplist_Not_Start", client);
		return Plugin_Handled;
	}

	char output[BUF_SZ];
	char buffer[BUF_SZ];

	CPrintToChat(client, "%T", "Maplist_Title", client);
	
	for (int i = 0; i < g_hArrayMapOrder.Length; i++) 
	{
		g_hArrayMapOrder.GetString(i, buffer, BUF_SZ);
		if (g_iMapsPlayed == i)
			FormatEx(output, BUF_SZ, "\x04 %d - %s", i + 1, buffer);
		else if (!g_cvNextMapPrint.BoolValue && g_iMapsPlayed < i)
		{
			FormatEx(output, BUF_SZ, "\x01 %d - %T", i + 1, "Secret", client);
			CPrintToChat(client, "%s", output);
			continue;
		}
		else FormatEx(output, BUF_SZ, "\x01 %d - %s", i + 1, buffer);

		//PrintToChatAll("Maplist: %s", buffer);
		if (GetPrettyName(buffer)) 
		{
			if (g_iMapsPlayed == i) 
				FormatEx(output, BUF_SZ, "\x04%d - %s", i + 1, buffer);
			else
				FormatEx(output, BUF_SZ, "%d - %s ", i + 1, buffer);
		}
		CPrintToChat(client, "%s", output);
	}
	CPrintToChat(client, "%T", "Show_Maplist_Cmd", client);

	return Plugin_Handled;
}

// Abort a currently loaded mapset
Action StopMixmap_Cmd(int client, int args) 
{
	if (!g_bMapsetInitialized ) 
	{
		CPrintToChat(client, "%T", "Not_Start", client);
		return Plugin_Handled;
	}
	if (IsClientAndInGame(client))
	{
		if (!IsBuiltinVoteInProgress())
		{
			int iNumPlayers;
			int[] iPlayers = new int[MaxClients];
			for (int i = 1; i <= MaxClients; i++)
			{
				if (!IsClientAndInGame(i) || (GetClientTeam(i) == 1))
				{
					continue;
				}
				iPlayers[iNumPlayers++] = i;
			}
			
			char cVoteTitle[64];
			Format(cVoteTitle, sizeof(cVoteTitle), "%T", "Cvote_Title_Off", LANG_SERVER);

			Handle hVote = CreateBuiltinVote(VoteActionHandler, BuiltinVoteType_Custom_YesNo, BuiltinVoteAction_Cancel | BuiltinVoteAction_VoteEnd | BuiltinVoteAction_End);

			SetBuiltinVoteArgument(hVote, cVoteTitle);
			SetBuiltinVoteInitiator(hVote, client);
			SetBuiltinVoteResultCallback(hVote, VoteStopMixmapResultHandler);
			DisplayBuiltinVote(hVote, iPlayers, iNumPlayers, 20);

			CPrintToChatAllEx(client, "%t", "Vote_Stop", client);
			if(g_bL4D2Version) FakeClientCommand(client, "Vote Yes");
			if(!g_bL4D2Version) EmitSoundToAll("ui/beep_synthtone01.wav");
		}
		else
		{
			CPrintToChat(client, "%T", "Vote_Blocked", client);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

Action StopMixmap(int client, int args) 
{
	if (!g_bMapsetInitialized) 
	{
		CPrintToChatAll("%t", "Not_Start");
		return Plugin_Handled;
	}

	PluginStartInit();

	CPrintToChatAllEx(client, "%t", "Stop_Mixmap_Admin", client);
	return Plugin_Handled;
}

// Event-------------------------------

void map_transition(Event event, const char[] name, bool dontBroadcast) 
{
	if(L4D_HasPlayerControlledZombies() == false && g_bMapsetInitialized)
	{
		if (++g_iMapsPlayed < g_iMapCount) 
		{
			CreateTimer(0.5, Timed_NextMapInfo, _, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(7.5, Timer_map_transition, _, TIMER_FLAG_NO_MAPCHANGE);
			return;
		}

		Call_StartForward(g_hForwardEnd);
		Call_Finish();
	}
}

void finale_win(Event event, const char[] name, bool dontBroadcast) 
{
	if(L4D_HasPlayerControlledZombies() == false && g_bMapsetInitialized)
	{
		++g_iMapsPlayed;
		Call_StartForward(g_hForwardEnd);
		Call_Finish();

		//if (g_cvFinaleEndCoop.BoolValue)
		//{
		//	CreateTimer(10.0, Timed_ContinueMixmap, _, TIMER_FLAG_NO_MAPCHANGE);
		//}
	}
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;

	g_bRoundIsLive = false;
	g_bReadyUpFooterAdded = false;
	g_iReadyUpFooterIndex = -1;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
    if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
        CreateTimer(0.5, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
    g_iPlayerSpawn = 1;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	ClearDefault();
}

// Vote-------------------------------

void VoteActionHandler(Handle vote, BuiltinVoteAction action, int param1, int param2)
{
	switch (action)
	{
		case BuiltinVoteAction_End:
		{
			CloseHandle(vote);
		}
		case BuiltinVoteAction_Cancel:
		{
			//DisplayBuiltinVoteFail(vote, view_as<BuiltinVoteFailReason>(param1));
		}
	}
}

void VoteMixmapResultHandler(Handle vote, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	for (int i = 0; i < num_items; i++)
	{
		if (item_info[i][BUILTINVOTEINFO_ITEM_INDEX] == BUILTINVOTES_VOTE_YES)
		{
			if (item_info[i][BUILTINVOTEINFO_ITEM_VOTES] > (num_clients / 2))
			{
				char cExecTitle[64];
				Format(cExecTitle, sizeof(cExecTitle), "%T", "Cexec_Title", LANG_SERVER);
				DisplayBuiltinVotePass(vote, cExecTitle);

				if(!g_bL4D2Version) EmitSoundToAll("ui/menu_enter05.wav");

				PluginStartInit();
				CreateTimer(3.0, StartVoteMixmap_Timer, _, TIMER_FLAG_NO_MAPCHANGE);
				return;
			}
		}
	}
	
	DisplayBuiltinVoteFail(vote, BuiltinVoteFail_Loses);
	if(!g_bL4D2Version) EmitSoundToAll("ui/beep_error01.wav");
}

void VoteStopMixmapResultHandler(Handle vote, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	for (int i = 0; i < num_items; i++)
	{
		if (item_info[i][BUILTINVOTEINFO_ITEM_INDEX] == BUILTINVOTES_VOTE_YES)
		{
			if (item_info[i][BUILTINVOTEINFO_ITEM_VOTES] > (num_clients / 2))
			{
				char cExecTitle[64];
				Format(cExecTitle, sizeof(cExecTitle), "%T", "Stop Mixmap", LANG_SERVER);
				DisplayBuiltinVotePass(vote, cExecTitle);
				CreateTimer(1.0, StartVoteStopMixmap_Timer);

				if(!g_bL4D2Version) EmitSoundToAll("ui/menu_enter05.wav");

				return;
			}
		}
	}
	
	DisplayBuiltinVoteFail(vote, BuiltinVoteFail_Loses);
	if(!g_bL4D2Version) EmitSoundToAll("ui/beep_error01.wav");
}

// Timer & Frame-------------------------------

Action Timer_PluginStart(Handle timer)
{
	ClearDefault();

	if(g_ReadyUpAvailable) UpdateReadyUpFooter(5.5);

	return Plugin_Continue;
}

Action Timed_NextMapInfo(Handle timer)
{
	char sMapName_Pretty[BUF_SZ];
	g_hArrayMapOrder.GetString(g_iMapsPlayed, sMapName_Pretty, BUF_SZ);

	//PrintToChatAll("%s", sMapName_Pretty);
	GetPrettyName(sMapName_Pretty);
	//PrintToChatAll("%s", sMapName_Pretty);
	
	g_cvNextMapPrint.BoolValue ? CPrintToChatAll("%t", "Show_Next_Map", sMapName_Pretty) : CPrintToChatAll("%t", "Show_Next_Map (Secret)", "Secret");
	
	return Plugin_Continue;
}

/*Action Timed_ContinueMixmap(Handle timer)
{
	ServerCommand("sm_fmixmap %s", cfg_exec);

	return Plugin_Continue;
}*/

Action Timer_map_transition(Handle timer)
{
	//直接強制換圖
	GotoNextMap(true);

	return Plugin_Continue;
}

Action Timer_UpdateReadyUpFooter(Handle timer)
{
	g_hUpdateFooterTimer = null;

	char sMapName_Pretty[BUF_SZ];
	if(g_hArrayMapOrder.Length == 0)
	{
		//FormatEx(sMapName_Pretty, sizeof(sMapName_Pretty), "Mixmap : No active, type !mixmap");
	}
	else
	{
		if(g_iMapsPlayed+1 >= g_iMapCount)
		{
			//FormatEx(sMapName_Pretty, sizeof(sMapName_Pretty), "Mixmap : No Next Map");
		}
		else
		{
			if(g_cvNextMapPrint.BoolValue)
			{
				g_hArrayMapOrder.GetString(g_iMapsPlayed+1, sMapName_Pretty, BUF_SZ);
				GetPrettyName(sMapName_Pretty);

				Format(sMapName_Pretty, sizeof(sMapName_Pretty), "Mixmap : %s", sMapName_Pretty);
			}
		}
	}

	// Check to see if the Ready Up footer has already been added
	if (g_bReadyUpFooterAdded)
	{
		// Ready Up footer already exists, so we can just edit it.
		EditFooterStringAtIndex(g_iReadyUpFooterIndex, sMapName_Pretty);
	}
	else
	{
		// Ready Up footer hasn't been added yet. Must be the start of a new round! Lets add it.
		g_iReadyUpFooterIndex = AddStringToReadyFooter(sMapName_Pretty);
		g_bReadyUpFooterAdded = true;
	}

	return Plugin_Continue;
}

/*Action Timer_FindInfoChangelevel(Handle timer)
{
	if(L4D_HasPlayerControlledZombies() && strlen(g_slandmarkName) > 0)
	{
		float targetPos[3];

		int entity = -1;
		while ((entity = FindEntityByClassname(entity, "info_landmark")) != -1)
		{
			if(!IsValidEntity(entity)) continue;

			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", targetPos);
			int info_landmark = CreateEntityByName("info_landmark");
			if(info_landmark > MaxClients)
			{
				// To prevent server console spam error: Most gross danger! Cannot find Landmark named ｘｘｘｘｘｘ!
				// (只出現於對抗模式) 伺服器啟動選項有寫-dev, 第二回合倖存者過關後
				DispatchKeyValueVector(info_landmark, "origin", targetPos);
				DispatchKeyValue(info_landmark, "targetname", g_slandmarkName);
				DispatchSpawn(info_landmark);
			}
			
			break;
		}
	}

	g_slandmarkName[0] = '\0';
	int ent = FindEntityByClassname(-1, "info_changelevel");
	if(ent == -1)
	{
		ent = FindEntityByClassname(-1, "trigger_changelevel");
	}

	if(ent == -1)
	{
		return Plugin_Continue;
	}
	else
	{
		GetEntPropString(ent, Prop_Data, "m_landmarkName", g_slandmarkName, sizeof(g_slandmarkName)); 
	}

	return Plugin_Continue;
}*/

Action StartVoteMixmap_Timer(Handle timer)
{
	Mixmap();
	
	return Plugin_Continue;
}

Action StartVoteStopMixmap_Timer(Handle timer)
{
	PluginStartInit();
	
	CPrintToChatAll("%t", "Stop_Mixmap");
	return Plugin_Continue;
}

//creates the initial map list after a map set has been loaded
Action Timed_PostMapSet(Handle timer) 
{
	if (g_hTriePools == null) 
	{
		g_bMapsetInitialized = false;	//failed to load it on the exec
		CPrintToChatAll("%t", "Fail_Load_Preset");
		return Plugin_Continue;
	}

	if (g_hArrayTagOrder == null) 
	{
		g_bMapsetInitialized = false;	//failed to load it on the exec
		CPrintToChatAll("%t", "Fail_Load_Preset");
		return Plugin_Continue;
	}

	int mapnum = g_hArrayTagOrder.Length;
	int triesize = g_hTriePools.Size;
	if (triesize == 0 || mapnum == 0) 
	{
		g_bMapsetInitialized = false;	//failed to load it on the exec
		CPrintToChatAll("%t", "Fail_Load_Preset");
		return Plugin_Continue;
	}

	if (g_iMapCount < triesize) 
	{
		g_bMapsetInitialized = false;	//bad preset format
		CPrintToChatAll("%t", "Maps_Not_Match_Rank");
		return Plugin_Continue;
	}

	CPrintToChatAll("%t", "Select_Maps_Succeed");

	SelectRandomMap();
	return Plugin_Continue;
}

Action Timed_GiveThemTimeToReadTheMapList(Handle timer) 
{
	g_hCountDownTimer = null;
	if (IsBuiltinVoteInProgress() && !g_bServerForceStart)
	{
		CPrintToChatAll("%t", "Vote_Progress_delay", 20);
		g_hCountDownTimer = CreateTimer(20.0, Timed_GiveThemTimeToReadTheMapList);
		return Plugin_Continue;
	}
	if (g_bServerForceStart) g_bServerForceStart = false;

	// call starting forward
	char buffer[BUF_SZ];
	g_hArrayMapOrder.GetString(0, buffer, BUF_SZ);

	Call_StartForward(g_hForwardStart);
	Call_PushCell(g_iMapCount);
	Call_PushString(buffer);
	Call_Finish();

	GotoNextMap(true);
	return Plugin_Continue;
}

Action Timer_DifferAbort(Handle timer)
{
	g_hDifferAbortTimer = null;

	return Plugin_Continue;
}

// Function-------------------------------

// Load a mixmap cfg
void Mixmap() 
{
	if(g_bL4D2Version) ServerCommand("exec %s%s.cfg", DIR_CFGS_L4D2, cfg_exec);
	else ServerCommand("exec %s%s.cfg", DIR_CFGS_L4D1, cfg_exec);

	g_bMapsetInitialized = true;
	CreateTimer(0.1, Timed_PostMapSet, _, TIMER_FLAG_NO_MAPCHANGE);
}

void SelectRandomMap() 
{
	g_bMaplistFinalized = true;
	SetRandomSeed(view_as<int>(GetEngineTime()));

	int mapIndex, mapsmax = g_cvMaxMapsNum.IntValue;
	ArrayList hArrayPool;
	char tag[BUF_SZ], map[BUF_SZ];

	// Select 1 random map for each rank out of the remaining ones
	int length = g_hArrayTagOrder.Length;
	for (int i = 0; i < length; i++) 
	{
		g_hArrayTagOrder.GetString(i, tag, BUF_SZ);
		g_hTriePools.GetValue(tag, hArrayPool);
		SortADTArray(hArrayPool, Sort_Random, Sort_String);	//randomlize the array
		mapIndex = GetRandomInt(0, hArrayPool.Length - 1);

		hArrayPool.GetString(mapIndex, map, BUF_SZ);
		hArrayPool.Erase(mapIndex);
		if (mapsmax)	//if limit the number of missions in one campaign, check the number.
		{
			if (CheckSameCampaignNum(map) >= mapsmax)
			{
				while (hArrayPool.Length > 0)	// Reselect if the number will exceed the limit 
				{
					mapIndex = GetRandomInt(0, hArrayPool.Length - 1);
					hArrayPool.GetString(mapIndex, map, BUF_SZ);
					hArrayPool.Erase(mapIndex);
					if (CheckSameCampaignNum(map) < mapsmax) break;
				}
				if (CheckSameCampaignNum(map) >= mapsmax)	//Reselect some missions (like only 1 mission4, the mission4 can't select)
				{
					g_hTriePools.GetValue(tag, hArrayPool);
					hArrayPool.Sort(Sort_Random, Sort_String);
					mapIndex = GetRandomInt(0, hArrayPool.Length - 1);
					hArrayPool.GetString(mapIndex, map, BUF_SZ);
					ReSelectMapOrder(map);
				}
			}
		}
		g_hArrayMapOrder.PushString(map);
	}

	// Clear things because we only need the finalised map order in memory

	StringMapSnapshot hTrieSnapshot;
	ArrayList hArrayList;
	hTrieSnapshot = g_hTriePools.Snapshot();
	int length2 = hTrieSnapshot.Length;
	char sKey[BUF_SZ];
	for(int i = 0; i < length2; i++)
	{
		hTrieSnapshot.GetKey(i, sKey, sizeof(sKey));
		g_hTriePools.GetValue(sKey, hArrayList);
		delete hArrayList;
	}
	delete hTrieSnapshot;

	g_hTriePools.Clear();
	g_hArrayTagOrder.Clear();

	// Show final maplist to everyone
	for (int i = 1; i <= MaxClients; i++) 
	{
		if (IsClientInGame(i) && !IsFakeClient(i)) 
		{
			MixMaplist(i, 0);
		}
	}


	CPrintToChatAll("%t", "Change_Map_First", g_bServerForceStart ? 5 : 15);	//Alternative for remixmap
	delete g_hCountDownTimer;
	g_hCountDownTimer = CreateTimer(g_bServerForceStart ? 5.0 : 15.0, Timed_GiveThemTimeToReadTheMapList);	//Alternative for remixmap
}

void GotoNextMap(bool force = false) 
{
	char sMapName[BUF_SZ];
	g_hArrayMapOrder.GetString(g_iMapsPlayed, sMapName, BUF_SZ);
	
	GotoMap(sMapName, force);
} 

void GotoMap(const char[] sMapName, bool force = false) 
{
	if (force) 
	{
		ForceChangeLevel(sMapName, "Mixmap");
		return;
	}

	// 對抗模式中使用sm_nextmap便足夠，自動換到指定的關卡
	// 戰役模式中使用sm_nextmap，自動換到指定的關卡，但會有bots不見的問題
	ServerCommand("sm_nextmap %s", sMapName);
} 

void PluginStartInit() 
{
	delete g_hCountDownTimer;

	delete g_hArrayTags;
	g_hArrayTags = new ArrayList(BUF_SZ/4);	//1 block = 4 characters => X characters = X/4 blocks
	
	if(g_hTriePools != null)
	{
		StringMapSnapshot hTrieSnapshot;
		ArrayList hArrayList;
		hTrieSnapshot = g_hTriePools.Snapshot();
		int length2 = hTrieSnapshot.Length;
		char sKey[BUF_SZ];
		for(int i = 0; i < length2; i++)
		{
			hTrieSnapshot.GetKey(i, sKey, sizeof(sKey));
			g_hTriePools.GetValue(sKey, hArrayList);
			delete hArrayList;
		}
		delete hTrieSnapshot;
	}

	delete g_hTriePools;
	g_hTriePools = new StringMap();

	delete g_hArrayTagOrder;
	g_hArrayTagOrder = new ArrayList(BUF_SZ/4);

	delete g_hArrayMapOrder;
	g_hArrayMapOrder = new ArrayList(BUF_SZ/4);

	g_bMapsetInitialized = false;
	g_bMaplistFinalized = false;
	
	g_iMapsPlayed = 0;
	g_iMapCount = 0;

	g_slandmarkName[0] = '\0';
	g_sNextMixMap[0] = '\0';
}

// Others-------------------------------

// Return false if pretty name not found, ture otherwise
bool GetPrettyName(char[] map) 
{
	g_hKvMapNames.Rewind();
	char buffer[BUF_SZ];
	g_hKvMapNames.GetString(map, buffer, BUF_SZ, "no");
		
	if (!StrEqual(buffer, "no")) 
	{
		strcopy(map, BUF_SZ, buffer);
		return true;
	}
	return false;
}

bool IsClientAndInGame(int index) 
{
	return (index > 0 && index <= MaxClients && IsClientInGame(index) && IsClientConnected(index) && !IsFakeClient(index));
}

int CheckSameCampaignNum(char[] map)
{
	int count = 0;
	char buffer[BUF_SZ];
	
	for (int i = 0; i < g_hArrayMapOrder.Length; i++)
	{
		g_hArrayMapOrder.GetString(i, buffer, sizeof(buffer));
		if (IsSameCampaign(map, buffer))
			count ++;
	}
	
	return count;
}

bool IsSameCampaign(char[] map1, char[] map2)
{
	char buffer1[BUF_SZ], buffer2[BUF_SZ];
	
	strcopy(buffer1, BUF_SZ, map1);
	strcopy(buffer2, BUF_SZ, map2);
	
	if (GetPrettyName(buffer1)) SplitString(buffer1, "_", buffer1, sizeof(buffer1));
	if (GetPrettyName(buffer2)) SplitString(buffer2, "_", buffer2, sizeof(buffer2));
	
	if (StrEqual(buffer1, buffer2)) return true;
	return false;
}

void ReSelectMapOrder(char[] confirm)	//hope this will work
{
	char buffer[BUF_SZ];
	ArrayList hArrayPool;
	int mapindex;
	
	for (int i = g_hArrayMapOrder.Length - 1; i >= 0; i--) {
		g_hArrayMapOrder.GetString(i, buffer, BUF_SZ);
		if (IsSameCampaign(confirm, buffer)) {
			g_hArrayTagOrder.GetString(i, buffer, BUF_SZ);
			g_hTriePools.GetValue(buffer, hArrayPool);
			hArrayPool.Erase(hArrayPool.FindString(confirm));
			for (int j = 0; j <= i; j++) {
				hArrayPool.Sort(Sort_Random, Sort_String);	//randomlize the array
				mapindex = GetRandomInt(0, hArrayPool.Length - 1);
				hArrayPool.GetString(mapindex, buffer, BUF_SZ);
				hArrayPool.Erase(mapindex);
				if (CheckSameCampaignNum(buffer) < g_cvMaxMapsNum.IntValue) {
					g_hArrayMapOrder.SetString(i, buffer);
					break;
				}
			}
			return;
		}
	}
}

void UpdateReadyUpFooter(float interval = 0.1)
{
	delete g_hUpdateFooterTimer;
	g_hUpdateFooterTimer = CreateTimer(interval, Timer_UpdateReadyUpFooter);
}

bool InSecondHalfOfRound()
{
	return view_as<bool>(GameRules_GetProp("m_bInSecondHalfOfRound"));
}

stock bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

void ClearDefault()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

// Other API--

public void L4D2_OnEndVersusModeRound_Post() 
{
	if (InSecondHalfOfRound())
	{
		if(g_bMapsetInitialized)
		{
			if (++g_iMapsPlayed < g_iMapCount) 
			{
				GotoNextMap(false);
				CreateTimer(5.0, Timed_NextMapInfo, _, TIMER_FLAG_NO_MAPCHANGE);
				return;
			}

			Call_StartForward(g_hForwardEnd);
			Call_Finish();

			//if(g_cvFinaleEndVersus.BoolValue && L4D_IsMissionFinalMap(true))
			//{
			//	CreateTimer(9.0, Timed_ContinueMixmap);
			//}
		}
	}
}

public void OnRoundIsLive() 
{
	g_bRoundIsLive = true;
}

public Action l4d2_map_transitions_OnChangeNextMap_Pre(const char[] sNextMapName)
{
	if (g_bMapsetInitialized)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

// Native------------

// native bool l4d2_mixmap_IsActive();
int Native_IsActive(Handle plugin, int numParams)
{
	return g_bMapsetInitialized;
}

// native void l4d2_mixmap_GetNextMap(char[] buffer, int maxlength);
int Native_GetNextMap(Handle plugin, int numParams)
{
	int maxlength = GetNativeCell(2);
	if (maxlength <= 0) 
		return 0;

	char[] buffer = new char[maxlength];

	FormatEx(buffer, maxlength, "%s", g_sNextMixMap);
	SetNativeString(1, buffer, maxlength);

	return 0;
}