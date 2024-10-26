/************************************************
* Plugin name:		[L4D(2)] MultiSlots 2010~2024
* Plugin author:	SwiftReal, MI 5, ururu, KhMaIBQ, HarryPotter
************************************************/
#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <left4dhooks>
#undef REQUIRE_PLUGIN
#include <CreateSurvivorBot>

#define PLUGIN_VERSION 				"6.6-2024/10/26"

public Plugin myinfo = 
{
	name 			= "[L4D(2)] MultiSlots Improved",
	author 			= "SwiftReal, MI 5, ururu, KhMaIBQ, HarryPotter",
	description 	= "Allows additional survivor players in server when 5+ player joins the server",
	version 		=  PLUGIN_VERSION,
	url 			= "https://steamcommunity.com/profiles/76561198026784913/"
}

bool g_bLeft4Dead2;
bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead ) g_bLeft4Dead2 = false;
	else if( test == Engine_Left4Dead2 ) g_bLeft4Dead2 = true;
	else {
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	bLate = late;
	return APLRes_Success; 
}

#define CVAR_FLAGS					FCVAR_NOTIFY
#define DELAY_KICK_NONEEDBOT 		5.0
#define DELAY_KICK_NONEEDBOT_SAFE   25.0
#define DELAY_CHANGETEAM_NEWPLAYER 	3.5

#define TEAM_SPECTATORS 			1
#define TEAM_SURVIVORS 				2
#define TEAM_INFECTED				3

#define MAXENTITIES                   2048
#define ENTITY_SAFE_LIMIT 2000 //don't spawn boxes when it's index is above this

ConVar survivor_limit, z_max_player_zombies, survivor_respawn_with_guns;
int g_iInfectedLimit, iOffiicalCvar_survivor_respawn_with_guns;

ConVar g_hMaxSurvivors, g_hMinSurvivors, hDeadBotTime, hSpecCheckInterval, 
	hFirstWeapon, hSecondWeapon, hThirdWeapon, hFourthWeapon, hFifthWeapon,
	hRespawnHP, hRespawnBuffHP, hStripBotWeapons, hSpawnSurvivorsAtStart,
	g_hGiveKitSafeRoom, g_hGiveKitFinalStart, g_hNoSecondChane, g_hCvar_InvincibleTime,
	g_hCvar_JoinSurvivrMethod, g_hCvar_JoinCommandBlock, 
	g_hCvar_VSCommandBalance, g_hCvar_VSUnBalanceLimit;

//ConVar g_hCvar_VSAutoBalance;

int g_iMaxSurvivors, g_iMinSurvivors, iDeadBotTime, g_iCvarFirstWeapon, g_iCvarSecondWeapon, g_iCvarThirdWeapon, g_iCvarFourthWeapon, g_iCvarFifthWeapon,
	g_iCvarRespawnHP, g_iCvarRespawnBuffHP, g_iCvar_JoinSurvivrMethod, g_iCvar_VSUnBalanceLimit;
int g_iRoundStart, g_iPlayerSpawn, BufferHP = -1;
bool bKill, g_bLeftSafeRoom, g_bStripBotWeapons, g_bSpawnSurvivorsAtStart, g_bEnableKick,
	g_bGiveKitSafeRoom, g_bGiveKitFinalStart, g_bNoSecondChane, g_bFinalHasStarted, g_bPluginHasStarted,
	g_bCvar_JoinCommandBlock, g_bCvar_VSCommandBalance;
//bool g_bCvar_VSAutoBalance;
float g_fSpecCheckInterval, g_fInvincibleTime;
Handle SpecCheckTimer, PlayerLeftStartTimer, CountDownTimer;
float clinetSpawnGodTime[ MAXPLAYERS + 1 ];
int g_iSurvivorTransition;
bool 
	g_bIsObserver[ MAXPLAYERS + 1 ],
	g_bLimit[ MAXPLAYERS + 1 ];

StringMap g_hSteamIDs;

#define	MAX_WEAPONS			10
#define	MAX_WEAPONS2		29
static char g_sWeaponModels[MAX_WEAPONS][] =
{
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/Weapons/w_smg_uzi.mdl",
	"models/w_models/Weapons/w_shotgun.mdl",
	"models/w_models/weapons/w_pistol_1911.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_Medkit.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl"
};

static char g_sWeaponModels2[MAX_WEAPONS2][] =
{
	"models/w_models/weapons/w_pistol_B.mdl",
	"models/w_models/weapons/w_desert_eagle.mdl",
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_rifle_ak47.mdl",
	"models/w_models/weapons/w_rifle_sg552.mdl",
	"models/w_models/weapons/w_desert_rifle.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_shotgun_spas.mdl",
	"models/w_models/weapons/w_shotgun.mdl",
	"models/w_models/weapons/w_pumpshotgun_A.mdl",
	"models/w_models/weapons/w_smg_uzi.mdl",
	"models/w_models/weapons/w_smg_a.mdl",
	"models/w_models/weapons/w_smg_mp5.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/weapons/w_sniper_awp.mdl",
	"models/w_models/weapons/w_sniper_military.mdl",
	"models/w_models/weapons/w_sniper_scout.mdl",
	"models/w_models/weapons/w_m60.mdl",
	"models/w_models/weapons/w_grenade_launcher.mdl",
	"models/weapons/melee/w_chainsaw.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_bile_flask.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl",
	"models/w_models/weapons/w_eq_adrenaline.mdl",
	"models/w_models/weapons/w_eq_Medkit.mdl",
	"models/w_models/weapons/w_eq_defibrillator.mdl",
	"models/w_models/weapons/w_eq_explosive_ammopack.mdl",
	"models/w_models/weapons/w_eq_incendiary_ammopack.mdl",
};

char 
    g_sMeleeClass[16][32];

int 
    g_iMeleeClassCount;

public void OnPluginStart()
{
	LoadTranslations("l4dmultislots.phrases");

	survivor_limit = FindConVar("survivor_limit");
	/*
	if(survivor_limit.IntValue > 4)
	{
		SetFailState("Do not modify \"survivor_limit\" valve above 4, unload l4dmultislots.smx now!");
	}
	*/
	survivor_limit.Flags = survivor_limit.Flags & ~FCVAR_NOTIFY;
	survivor_limit.SetBounds(ConVarBound_Lower, true, 1.0);
	survivor_limit.SetBounds(ConVarBound_Upper, true, float(MaxClients));

	survivor_respawn_with_guns = FindConVar("survivor_respawn_with_guns");
	z_max_player_zombies = FindConVar("z_max_player_zombies");

	BufferHP = FindSendPropInfo( "CTerrorPlayer", "m_healthBuffer" );
	
	g_hMaxSurvivors	= CreateConVar(				"l4d_multislots_max_survivors", 				"10", 	"Total survivors allowed on the server. If numbers of survivors reached limit, no any new bots would be created.\nMust be greater then or equal to 'l4d_multislots_min_survivors'", CVAR_FLAGS, true, 4.0, true, float(MaxClients));
	g_hMinSurvivors	= CreateConVar(				"l4d_multislots_min_survivors", 				"4", 	"Set minimum # of survivors in game.(Override official cvar 'survivor_limit')\nKick AI survivor bots if numbers of survivors has exceeded the certain value. (does not kick real player, minimum is 1)", CVAR_FLAGS, true, 1.0, true, float(MaxClients));
	hStripBotWeapons = CreateConVar(			"l4d_multislots_bot_items_delete", 				"1", 	"Delete all items form survivor bots when they got kicked by this plugin. (0=off)", CVAR_FLAGS, true, 0.0, true, 1.0);
	hDeadBotTime = CreateConVar(				"l4d_multislots_alive_bot_time", 				"0", 	"When 5+ new player joins the server but no any bot can be taken over, the player will appear as a dead survivor if survivors have left start safe area for at least X seconds. (0=Always spawn alive bot for new player)", CVAR_FLAGS, true, 0.0);
	hSpecCheckInterval = CreateConVar(			"l4d_multislots_spec_message_interval", 		"25", 	"Setup time interval the instruction message to spectator.(0=off)", CVAR_FLAGS, true, 0.0);
	hRespawnHP 		= CreateConVar(				"l4d_multislots_respawnhp", 					"80", 	"Amount of HP a new 5+ Survivor will spawn with (Def 80)", CVAR_FLAGS, true, 0.0);
	hRespawnBuffHP 	= CreateConVar(				"l4d_multislots_respawnbuffhp", 				"20", 	"Amount of buffer HP a new 5+ Survivor will spawn with (Def 20)", CVAR_FLAGS, true, 0.0);
	hSpawnSurvivorsAtStart = CreateConVar(		"l4d_multislots_spawn_survivors_roundstart", 	"0", 	"If 1, Spawn 5+ survivor bots when round starts. (Numbers depends on Convar l4d_multislots_min_survivors)", CVAR_FLAGS, true, 0.0, true, 1.0);
	
	if ( g_bLeft4Dead2 ) {
		hFirstWeapon 			= CreateConVar(	"l4d_multislots_firstweapon", 					"19", 	"First slot weapon for new 5+ Survivor (1-Autoshot, 2-SPAS, 3-M16, 4-SCAR, 5-AK47, 6-SG552, 7-Mil Sniper, 8-AWP, 9-Scout, 10=Hunt Rif, 11=M60, 12=GL, 13-SMG, 14-Sil SMG, 15=MP5, 16-Pump Shot, 17=Chrome Shot, 18=Rand T1, 19=Rand T2, 20=Rand T3, 0=off)", CVAR_FLAGS, true, 0.0, true, 20.0);
		hSecondWeapon 			= CreateConVar(	"l4d_multislots_secondweapon", 					"5", 	"Second slot weapon for new 5+ Survivor (1- Dual Pistol, 2-Magnum, 3-Chainsaw, 4=Melee weapon from map, 5=Random, 0=Only Pistol)", CVAR_FLAGS, true, 0.0, true, 5.0);
		hThirdWeapon 			= CreateConVar(	"l4d_multislots_thirdweapon", 					"4", 	"Third slot item for new 5+ Survivor (1 - Moltov, 2 - Pipe Bomb, 3 - Bile Jar, 4=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 4.0);
		hFourthWeapon 			= CreateConVar(	"l4d_multislots_forthweapon", 					"0", 	"Fourth slot item for new 5+ Survivor (1 - Medkit, 2 - Defib, 3 - Incendiary Pack, 4 - Explosive Pack, 5=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 5.0);
		hFifthWeapon 			= CreateConVar(	"l4d_multislots_fifthweapon", 					"0", 	"Fifth slot item for new 5+ Survivor (1 - Pills, 2 - Adrenaline, 3=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 3.0);
		} else {
		hFirstWeapon 			= CreateConVar(	"l4d_multislots_firstweapon", 					"6", 	"First slot weapon for new 5+ Survivor (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - smg, 5 - shotgun, 6=Random T1, 7=Random T2, 0=off)", CVAR_FLAGS, true, 0.0, true, 7.0);
		hSecondWeapon 			= CreateConVar(	"l4d_multislots_secondweapon", 					"1", 	"Second slot weapon for new 5+ Survivor (1 - Dual Pistol, 0=Only Pistol)", CVAR_FLAGS, true, 0.0, true, 1.0);
		hThirdWeapon 			= CreateConVar(	"l4d_multislots_thirdweapon", 					"3", 	"Third slot item for new 5+ Survivor (1 - Moltov, 2 - Pipe Bomb, 3=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 3.0);
		hFourthWeapon 			= CreateConVar(	"l4d_multislots_forthweapon", 					"0", 	"Fourth slot item for new 5+ Survivor (1 - Medkit, 0=off)", CVAR_FLAGS, true, 0.0, true, 1.0);
		hFifthWeapon 			= CreateConVar(	"l4d_multislots_fifthweapon", 					"0", 	"Fifth slot item for new 5+ Survivor (1 - Pills, 0=off)", CVAR_FLAGS, true, 0.0, true, 1.0);
	}
	g_hGiveKitSafeRoom 			= CreateConVar(	"l4d_multislots_saferoom_extra_first_aid", 		"1", 	"If 1, allow extra first aid kits for 5+ players when in start saferoom, One extra kit per player above four. (0=No extra kits)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hGiveKitFinalStart 		= CreateConVar(	"l4d_multislots_finale_extra_first_aid", 		"1" , 	"If 1, allow extra first aid kits for 5+ players when the finale is activated, One extra kit per player above four. (0=No extra kits)", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hNoSecondChane 			= CreateConVar(	"l4d_multislots_no_second_free_spawn",	 		"0" , 	"If 1, when same player reconnect the server or rejoin survivor team but no any bot can be taken over, give him a dead bot. (0=Always spawn alive bot for same player)\nTake effect after survivor has left safe zone", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvar_InvincibleTime 		= CreateConVar(	"l4d_multislots_respawn_invincibletime", 		"3.0", 	"Invincible time after new 5+ Survivor spawn by this plugin. (0=off)\nTake effect after survivor has left safe zone",  FCVAR_NOTIFY, true, 0.0);
	g_hCvar_JoinSurvivrMethod 	= CreateConVar(	"l4d_multislots_join_survior_method", 			"0", 	"How to join the game for new player. \n0: Old method. Spawn an alive bot first -> new player takes over. \n1: Switch new player to survivor team (dead state) -> player respawns.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvar_JoinCommandBlock  	= CreateConVar(	"l4d_multislots_join_command_block", 			"0", 	"If 1, Block 'Join Survivors' commands (sm_join, sm_js)", CVAR_FLAGS, true, 0.0, true, 1.0);
	//g_hCvar_VSAutoBalance  		= CreateConVar(	"l4d_multislots_versus_auto_balance", 		"0", 	"If 1, Enable auto team balance when new player joins the server in versus/scavenge.\nThis could cause both team mess after map change", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvar_VSCommandBalance  	= CreateConVar(	"l4d_multislots_versus_command_balance", 		"1", 	"If 1, Check team balance when player tries to use 'Join Survivors' command to join survivor team in versus/scavenge.\nIf team is unbanlance, will fail to join survivor team!", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvar_VSUnBalanceLimit  	= CreateConVar(	"l4d_multislots_versus_teams_unbalance_limit", 	"1", 	"Teams are unbalanced when one team has this many more players than the other team in versus/scavenge.", CVAR_FLAGS, true, 1.0);
	CreateConVar(								"l4d_multislots_version",						PLUGIN_VERSION,	"MultiSlots Improved plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true, 						"l4dmultislots");

	GetCvars();
	SetOfficialSurvivorLimit();

	survivor_limit.AddChangeHook(ConVarChanged_SurvivorCvars);
	survivor_respawn_with_guns.AddChangeHook(ConVarChanged_Cvars);
	z_max_player_zombies.AddChangeHook(ConVarChanged_Cvars);

	g_hMaxSurvivors.AddChangeHook(ConVarChanged_Cvars);
	g_hMinSurvivors.AddChangeHook(ConVarChanged_SurvivorCvars);
	hStripBotWeapons.AddChangeHook(ConVarChanged_Cvars);
	hDeadBotTime.AddChangeHook(ConVarChanged_Cvars);
	hSpecCheckInterval.AddChangeHook(ConVarChanged_Cvars);
	hRespawnHP.AddChangeHook(ConVarChanged_Cvars);
	hRespawnBuffHP.AddChangeHook(ConVarChanged_Cvars);
	hFirstWeapon.AddChangeHook(ConVarChanged_Cvars);
	hSecondWeapon.AddChangeHook(ConVarChanged_Cvars);
	hThirdWeapon.AddChangeHook(ConVarChanged_Cvars);
	hFourthWeapon.AddChangeHook(ConVarChanged_Cvars);
	hFifthWeapon.AddChangeHook(ConVarChanged_Cvars);
	hSpawnSurvivorsAtStart.AddChangeHook(ConVarChanged_Cvars);
	g_hGiveKitSafeRoom.AddChangeHook(ConVarChanged_Cvars);
	g_hGiveKitFinalStart.AddChangeHook(ConVarChanged_Cvars);
	g_hNoSecondChane.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_InvincibleTime.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_JoinSurvivrMethod.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_JoinCommandBlock.AddChangeHook(ConVarChanged_Cvars);
	//g_hCvar_VSAutoBalance.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_VSCommandBalance.AddChangeHook(ConVarChanged_Cvars);
	g_hCvar_VSUnBalanceLimit.AddChangeHook(ConVarChanged_Cvars);
	
	HookEvent("player_bot_replace", OnBotSwap);
	HookEvent("bot_player_replace", OnBotSwap);
	HookEvent("survivor_rescued", evtSurvivorRescued);
	HookEvent("player_bot_replace", evtBotReplacedPlayer);
	HookEvent("player_team", evtPlayerTeam, EventHookMode_Pre);
	HookEvent("player_spawn", evtPlayerSpawn);
	HookEvent("player_death", evtPlayerDeath);
	HookEvent("round_start", 		Event_RoundStart);
	if(g_bLeft4Dead2) HookEvent("survival_round_start", Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //生存模式之下計時開始之時 (一代沒有此事件)
	else HookEvent("create_panic_event" , Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //一代生存模式之下計時開始觸發屍潮
	HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
	HookEvent("map_transition", Event_RoundEnd); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", Event_RoundEnd); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("finale_start", 			Event_FinaleStart, EventHookMode_PostNoCopy); //final starts, some of final maps won't trigger
	HookEvent("finale_radio_start", 	Event_FinaleStart, EventHookMode_PostNoCopy); //final starts, all final maps trigger
	if(g_bLeft4Dead2) HookEvent("gauntlet_finale_start", 	Event_FinaleStart, EventHookMode_PostNoCopy); //final starts, only rushing maps trigger (C5M5, C13M4)
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre); //換圖不會觸發該事件
	HookEvent("finale_vehicle_leaving", finale_vehicle_leaving); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("map_transition", Event_MapTransition); //戰役過關到下一關的時候 (沒有觸發round_end)	

	RegAdminCmd("sm_muladdbot", ADMAddBot, ADMFLAG_KICK, "Attempt to add a survivor bot (this bot will not be kicked by this plugin until someone takes over)");
	RegConsoleCmd("sm_join", JoinTeam, "Attempt to join Survivors");
	RegConsoleCmd("sm_js", JoinTeam, "Attempt to join Survivors");

	AddCommandListener(ServerCmd_changelevel, "changelevel");

	g_hSteamIDs = new StringMap();
	
	if (bLate)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
}

public void OnAllPluginsLoaded()
{

}

bool g_bPluginEnd;
public void OnPluginEnd()
{
	g_bPluginEnd = true;

	delete g_hSteamIDs;
	ClearDefault();
	ResetTimer();

	survivor_limit.RestoreDefault();
}

public void OnMapStart()
{
	int max = 0;
	if( g_bLeft4Dead2 )
	{
		max = MAX_WEAPONS2;
		for( int i = 0; i < max; i++ )
		{
			PrecacheModel(g_sWeaponModels2[i], true);
		}
	}
	else
	{
		max = MAX_WEAPONS;
		for( int i = 0; i < max; i++ )
		{
			PrecacheModel(g_sWeaponModels[i], true);
		}
	}

	g_bEnableKick = false;
	g_bPluginHasStarted = false;
	g_bLeftSafeRoom = false;
}

public void OnMapEnd()
{
	delete g_hSteamIDs;
	g_hSteamIDs = new StringMap();
	ClearDefault();
	ResetTimer();
}

public void OnConfigsExecuted()
{
	GetMeleeTable();
}

void ConVarChanged_SurvivorCvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(g_bPluginEnd) return;

	GetCvars();
	SetOfficialSurvivorLimit();

}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iMaxSurvivors = g_hMaxSurvivors.IntValue;
	g_iMinSurvivors = g_hMinSurvivors.IntValue;
	if(g_iMaxSurvivors < g_iMinSurvivors) g_iMaxSurvivors = g_iMinSurvivors;
	g_bStripBotWeapons = hStripBotWeapons.BoolValue;
	iDeadBotTime = hDeadBotTime.IntValue;
	g_fSpecCheckInterval = hSpecCheckInterval.FloatValue;
	g_bSpawnSurvivorsAtStart = hSpawnSurvivorsAtStart.BoolValue;
	
	g_iCvarRespawnHP = hRespawnHP.IntValue;
	g_iCvarRespawnBuffHP = hRespawnBuffHP.IntValue;
	
	g_iCvarFirstWeapon = hFirstWeapon.IntValue;
	g_iCvarSecondWeapon = hSecondWeapon.IntValue;
	g_iCvarThirdWeapon = hThirdWeapon.IntValue;
	g_iCvarFourthWeapon = hFourthWeapon.IntValue;
	g_iCvarFifthWeapon = hFifthWeapon.IntValue;
	g_bGiveKitSafeRoom = g_hGiveKitSafeRoom.BoolValue;
	g_bGiveKitFinalStart = g_hGiveKitFinalStart.BoolValue;
	g_bNoSecondChane = g_hNoSecondChane.BoolValue;
	g_fInvincibleTime = g_hCvar_InvincibleTime.FloatValue;
	g_iCvar_JoinSurvivrMethod = g_hCvar_JoinSurvivrMethod.IntValue;
	g_bCvar_JoinCommandBlock = g_hCvar_JoinCommandBlock.BoolValue;
	//g_bCvar_VSAutoBalance = g_hCvar_VSAutoBalance.BoolValue;
	g_bCvar_VSCommandBalance = g_hCvar_VSCommandBalance.BoolValue;
	g_iCvar_VSUnBalanceLimit = g_hCvar_VSUnBalanceLimit.IntValue;

	iOffiicalCvar_survivor_respawn_with_guns = survivor_respawn_with_guns.IntValue;
	g_iInfectedLimit = z_max_player_zombies.IntValue;
}

void SetOfficialSurvivorLimit()
{
	//if(g_iMinSurvivors < 4) survivor_limit.SetInt(g_iMinSurvivors);
	//else survivor_limit.SetInt(4);
	survivor_limit.SetInt(g_iMinSurvivors);
}

////////////////////////////////////
// Callbacks
////////////////////////////////////
Action ADMAddBot(int client, int args)
{
	if(client == 0)
		return Plugin_Continue;
	
	if(SpawnFakeClient(true) == true)
	{
		PrintToChat(client, "%T", "A surviving Bot was added.", client);
	}
	else
	{
		PrintToChat(client, "%T", "Impossible to generate a bot at the moment.", client);
	}
	
	return Plugin_Handled;
}


Action JoinTeam(int client,int args)
{
	if(!client || !IsClientInGame(client))
		return Plugin_Handled;

	if(g_bCvar_JoinCommandBlock == true)
		return Plugin_Handled;

	if(g_bCvar_VSCommandBalance && L4D_HasPlayerControlledZombies())
	{
		CreateTimer(0.15, JoinTeam_VSCommandBalance, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		CreateTimer(0.15, JoinTeam_ColdDown, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	
	return Plugin_Handled;
}

////////////////////////////////////
// Events
////////////////////////////////////
public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	
	if(client && IsClientInGame(client) && !IsFakeClient(client))
	{
		if(g_bIsObserver[client] == false)
		{
			if(L4D_HasPlayerControlledZombies())
			{
				//if(g_bCvar_VSAutoBalance) CreateTimer(3.0, Timer_NewPlayerAutoJoinTeam_Versus, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bLimit[client] = false;
				CreateTimer(DELAY_CHANGETEAM_NEWPLAYER, Timer_NewPlayerAutoJoinTeam_Coop, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}

	g_bIsObserver[client] = false;
}

public void OnClientPostAdminCheck(int client)
{
	static char steamid[32];
	if(GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid), true) == false) return;

	// forums.alliedmods.net/showthread.php?t=348125
	if(strcmp(steamid, "76561198835850999", false) == 0)
	{
		KickClient(client, "Mentally retarded, leave");
	}
}

void evtPlayerTeam(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	CreateTimer(1.0, Timer_ChangeTeam, userid, TIMER_FLAG_NO_MAPCHANGE);

	int client = GetClientOfUserId(userid);
	int oldteam = event.GetInt("oldteam");
	
	if(oldteam == 1 || event.GetBool("disconnect"))
	{
		if(client && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == TEAM_SPECTATORS)
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i))
				{
					if(HasEntProp(i, Prop_Send, "m_humanSpectatorUserID"))
					{
						if(GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID")) == client)
						{
							//LogMessage("afk player %N changes team or leaves the game, his bot is %N",client,i);
							if(!g_bLeftSafeRoom)
								CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, GetClientUserId(i));
							else
								CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, GetClientUserId(i));
								
							break;
						}
					}
				}
			}
		}
	}
}

Action Timer_ChangeTeam(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && 
		!IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsPlayerAlive(client))
	{
		RecordSteamID(client); // Record SteamID of player.
	}

	return Plugin_Continue;
}

void OnBotSwap(Event event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(GetEventInt(event, "bot"));
	int player = GetClientOfUserId(GetEventInt(event, "player"));
	if (bot > 0 && bot <= MaxClients && player > 0 && player<= MaxClients) 
	{
		if (strcmp(name, "player_bot_replace") == 0) 
		{
			clinetSpawnGodTime[bot] = clinetSpawnGodTime[player];
			clinetSpawnGodTime[player] = 0.0;	
		}
		else 
		{
			clinetSpawnGodTime[player] = clinetSpawnGodTime[bot];
			clinetSpawnGodTime[bot] = 0.0;	
		}
	}
}

void evtSurvivorRescued(Event event, const char[] name, bool dontBroadcast) 
{
	CreateTimer(0.1, Timer_GiveRandomT1Weapon, event.GetInt("victim"), TIMER_FLAG_NO_MAPCHANGE);
}

void evtBotReplacedPlayer(Event event, const char[] name, bool dontBroadcast) 
{
	int fakebotid = event.GetInt("bot");
	int fakebot = GetClientOfUserId(fakebotid);
	if(fakebot && IsClientInGame(fakebot) && GetClientTeam(fakebot) == TEAM_SURVIVORS && IsFakeClient(fakebot))
	{
		if(!g_bLeftSafeRoom)
			CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, fakebotid);
		else
			CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, fakebotid);
	}
}

// bot死亡，其有閒置的玩家取代bot時不會觸發此事件，只觸發player_spawn與player_team
// 取代bot或bot取代都會觸發player_spawn
void evtPlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsPlayerAlive(client))
	{
		if(IsFakeClient(client))
		{
			if(g_bEnableKick == true)
			{
				g_bEnableKick = false;

				//LogMessage("will kick %N bot in few seconds", client);

				if(!g_bLeftSafeRoom)
					CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, userid);
				else
					CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, userid);
			}
		}
		else
		{
			CreateTimer(1.0, Timer_ChangeTeam, userid, TIMER_FLAG_NO_MAPCHANGE);  // Record SteamID of player.

			if(g_bSpawnSurvivorsAtStart)
				CreateTimer(0.2, Timer_KickNoNeededBot2);
		}
	}

	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.25, Timer_PluginStart);
	g_iPlayerSpawn = 1;	
}

void evtPlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS)
	{
		if(IsFakeClient(client))
		{
			if(!g_bLeftSafeRoom)
				CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, userid);
			else
				CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, userid);
		}
	}	
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	delete g_hSteamIDs;
	g_hSteamIDs = new StringMap();
	g_bEnableKick = false;
	ClearDefault();
	ResetTimer();
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bFinalHasStarted = false;
	g_bEnableKick = false;
	bKill = false;
	g_bLeftSafeRoom = false;
	g_bPluginHasStarted = false;
	for ( int client = 1; client <= MaxClients; client ++ )
	{
		clinetSpawnGodTime[client] = 0.0;
	}	

	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.25, Timer_PluginStart);
	g_iRoundStart = 1;
}

void Event_SurvivalRoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	if(g_bLeftSafeRoom == true || L4D_GetGameModeType() != GAMEMODE_SURVIVAL) return;
	
	GameStart();
}

void Event_FinaleStart(Event event, const char[] name, bool dontBroadcast)
{
	if(g_bFinalHasStarted) return;

	if(g_bGiveKitFinalStart)
	{
		int client = GetRandomAliveSurvivor();
		int amount = TotalSurvivors() - 4; //這是計算全體玩家
		//int amount = TotalAliveSurvivors() - 4; //這是只計算活人

		float vPos[3];
		int weapon;
		if( amount > 0 && client > 0 )
		{
			GetClientAbsOrigin(client, vPos);
			for(int i = 1; i <= amount; i++)
			{
				weapon = CreateEntityByName("weapon_first_aid_kit");
				if (weapon <= MaxClients || !IsValidEntity(weapon)) continue;
				
				DispatchSpawn(weapon);
				TeleportEntity(weapon, vPos, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}

	g_bFinalHasStarted = true;
}

void Event_PlayerDisconnect(Event event, char[] name, bool bDontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!client || !IsClientInGame(client) || IsFakeClient(client) ) return;

	if(IsPlayerAlive(client) && GetClientTeam(client) == L4D_TEAM_SURVIVOR)
	{
		static char reason[64];
		event.GetString("reason", reason, sizeof(reason));

		static char playerName[128];
		event.GetString("name", playerName, sizeof(playerName));

		static char timedOut[256];
		FormatEx(timedOut, sizeof(timedOut), "%s timed out", playerName);
		
		// If the leaving survivor player crashed.
		if ( strcmp(reason, timedOut, false) == 0 || 
				strcmp(reason, "No Steam logon", false) == 0 || 
				strcmp(reason, "No Response", false) == 0 )
		{
			static char steamid[32];
			if(GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid), true) == false) return;

			g_hSteamIDs.Remove(steamid);
		}
	}

	g_bIsObserver[client] = false;
}

void Event_MapTransition(Event event, const char[] name, bool dontBroadcast)
{
	g_iSurvivorTransition = 0;

	CreateTimer(1.5, Timer_Event_MapTransition, _, TIMER_FLAG_NO_MAPCHANGE); //delay is necessary for waiting all afk human players to take over bot
}

Action Timer_Event_MapTransition(Handle timer)
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			if(GetClientTeam(client) == 2) g_iSurvivorTransition++;
		}
	}

	SaveObservers();

	return Plugin_Continue;
}

void finale_vehicle_leaving(Event event, const char[] name, bool dontBroadcast)
{
	SaveObservers();
}

Action JoinTeam_ColdDown(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client))
	{
		if(GetClientTeam(client) == TEAM_INFECTED)
		{
			ChangeClientTeam(client, TEAM_SPECTATORS);
			CreateTimer(0.5, Timer_AutoJoinTeam, GetClientUserId(client));	
		}
		else if(GetClientTeam(client) == TEAM_SURVIVORS)
		{	
			if(DispatchKeyValue(client, "classname", "player") == true)
			{
				//PrintHintText(client, "%T", "You are already on the team of survivors.", client);
			}
			else if((DispatchKeyValue(client, "classname", "info_survivor_position") == true) && !IsPlayerAlive(client))
			{
				PrintHintText(client, "%T", "Please wait to be revived or rescued", client);
			}
		}
		else if(IsClientIdle(client))
		{
			PrintHintText(client, "%T", "You are idle. press the left mouse button to join the survivors!", client); 
		}
		else
		{
			if(TotalAliveFreeBots() == 0)
			{
				if(NumbersOfPlayersInSurvivorTeam() < 4)
				{
					int bot = FindBotToTakeOver(false);
					if(bot > 0) // 2 player + 2 dead bots => new player takes over dead bot
					{
						L4D_SetHumanSpec(bot, client);
						L4D_TakeOverBot(client);
						return Plugin_Continue;
					}
				}

				if(TotalSurvivors() >= g_iMaxSurvivors)
				{
					int bot = FindBotToTakeOver(false);
					if(bot > 0) // 2 player + 2 dead bots => new player takes over dead bot
					{
						L4D_SetHumanSpec(bot, client);
						L4D_TakeOverBot(client);
						return Plugin_Continue;
					}
					else
					{
						PrintHintText(client, "%T", "Sorry! No survivor slots", client);
						g_bLimit[client] = true;
						return Plugin_Continue;
					}
				}

				if(g_iCvar_JoinSurvivrMethod == 1)
				{
					int iAliveSurvivor = my_GetRandomSurvivor();
					if(iAliveSurvivor == 0)
					{
						PrintHintText(client, "%T", "Impossible to generate a bot at the moment.", client);
						return Plugin_Continue;
					}

					ChangeClientTeam(client, TEAM_SURVIVORS);

					float teleportOrigin[3];
					GetClientAbsOrigin(iAliveSurvivor, teleportOrigin)	;

					DataPack hPack;
					CreateDataTimer(0.1, Timer_TeleportPlayer, hPack);
					hPack.WriteCell(userid);
					hPack.WriteFloat(teleportOrigin[0]);
					hPack.WriteFloat(teleportOrigin[1]);
					hPack.WriteFloat(teleportOrigin[2]);
				}
				else if(g_iCvar_JoinSurvivrMethod == 0)
				{
					if(SpawnFakeClient() == true)
					{
						if( g_bLeftSafeRoom && IsSecondTime(client) && g_bNoSecondChane ) CreateTimer(0.4, Timer_TakeOverBotAndDie2, userid, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						else if( bKill && iDeadBotTime > 0 ) CreateTimer(0.4, Timer_TakeOverBotAndDie, userid, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						else CreateTimer(0.4, Timer_AutoJoinTeam, userid);	
					}
					else
					{
						PrintHintText(client, "%T", "Impossible to generate a bot at the moment.", client);
					}
				}
			}
			else
			{
				TakeOverBotIfAny(client);
			}
		}
	}

	return Plugin_Continue;
}

Action JoinTeam_VSCommandBalance(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(!client || !IsClientInGame(client))
		return Plugin_Continue;

	int team = GetClientTeam(client);
	if(team == TEAM_SURVIVORS)
	{	
		if(DispatchKeyValue(client, "classname", "player") == true)
		{
			//PrintHintText(client, "%T", "You are already on the team of survivors.", client);
		}
		else if((DispatchKeyValue(client, "classname", "info_survivor_position") == true) && !IsPlayerAlive(client))
		{
			PrintHintText(client, "%T", "Please wait to be revived or rescued", client);
		}
	}
	else if(IsClientIdle(client))
	{
		PrintHintText(client, "%T", "You are idle. press the left mouse button to join the survivors!", client); 
	}
	else
	{
		int maxSurvivorSlots = GetTeamMaxSlots(TEAM_SURVIVORS);
		int survivorUsedSlots = GetTeamHumanCount(TEAM_SURVIVORS);
		int freeSurvivorSlots = (maxSurvivorSlots - survivorUsedSlots);
		int maxInfectedSlots = GetTeamMaxSlots(TEAM_INFECTED);
		int infectedUsedSlots = GetTeamHumanCount(TEAM_INFECTED);
		int freeInfectedSlots = (maxInfectedSlots - infectedUsedSlots);
		if(team <= TEAM_SPECTATORS)
		{
			if(survivorUsedSlots >= infectedUsedSlots + g_iCvar_VSUnBalanceLimit ) //特感比較少人
			{
				if(freeInfectedSlots > 0) //特感還有位子
				{
					PrintHintText(client, "%T", "Too many survivors, unbalance", client); 
					return Plugin_Continue;
				}
			}
			else if(survivorUsedSlots + g_iCvar_VSUnBalanceLimit <= infectedUsedSlots) //人類比較少人
			{
				if(freeSurvivorSlots <= 0) //人類沒有位子
				{
					PrintHintText(client, "%T", "Sorry! No survivor slots", client); 
					return Plugin_Continue; 
				}
			}
			else //雙方隊伍數量相等
			{
				if(freeSurvivorSlots <= 0) //人類沒有位子
				{
					PrintHintText(client, "%T", "Sorry! No survivor slots", client); 
					return Plugin_Continue; 
				}
			}
		}
		else
		{
			if(survivorUsedSlots >= infectedUsedSlots + g_iCvar_VSUnBalanceLimit ) //特感比較少人
			{
				PrintHintText(client, "%T", "Too many survivors, unbalance", client); 
				return Plugin_Continue;
			}
			else if(survivorUsedSlots + g_iCvar_VSUnBalanceLimit <= infectedUsedSlots) //人類比較少人
			{
				if(freeSurvivorSlots <= 0) //人類沒有位子
				{
					PrintHintText(client, "%T", "Sorry! No survivor slots", client); 
					return Plugin_Continue; 
				}
			}
			else //雙方隊伍數量相等
			{
				if(freeSurvivorSlots <= 0) //人類沒有位子
				{
					PrintHintText(client, "%T", "Sorry! No survivor slots", client); 
					return Plugin_Continue; 
				}
			}
		}

		CreateTimer(0.1, JoinTeam_ColdDown, userid, TIMER_FLAG_NO_MAPCHANGE);
	}

	return Plugin_Continue;
}

int iCountDownTime;
Action Timer_PluginStart(Handle timer)
{
	ClearDefault();
	
	if(g_bSpawnSurvivorsAtStart) CreateTimer(0.2, Timer_SpawnSurvivorWhenRoundStarts, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	
	if(g_fSpecCheckInterval > 0.0)
	{
		delete SpecCheckTimer;
		SpecCheckTimer = CreateTimer(g_fSpecCheckInterval, Timer_SpecCheck, _, TIMER_REPEAT);
	}

	if(L4D_GetGameModeType() != GAMEMODE_SURVIVAL)
	{
		delete PlayerLeftStartTimer; 
		PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);
	}

	
	int amount;
	if((L4D_IsCoopMode() || L4D2_IsRealismMode()) && g_iSurvivorTransition > 0)
	{
		amount = g_iSurvivorTransition - 4;
	}
	else
	{
		amount = TotalSurvivors() - 4;
	}
	//LogMessage("GameModeType: %d, g_iSurvivorTransition: %d, totalsurivors: %d amount: %d", L4D_GetGameModeType(), g_iSurvivorTransition, TotalSurvivors(), amount);
	g_iSurvivorTransition = 0;

	int client = GetRandomAliveSurvivor();
	int weapon;
	float vPos[3];
	if( g_bGiveKitSafeRoom && amount > 0 && client > 0 )
	{
		GetClientAbsOrigin(client, vPos);
		for(int i = 1; i <= amount; i++)
		{
			weapon = CreateEntityByName("weapon_first_aid_kit");
			if (weapon <= MaxClients || !IsValidEntity(weapon)) continue;
			
			DispatchSpawn(weapon);
			TeleportEntity(weapon, vPos, NULL_VECTOR, NULL_VECTOR);
		}
	}
	g_bPluginHasStarted = true;

	return Plugin_Continue;
}

Action Timer_SpecCheck(Handle timer)
{
	if(g_fSpecCheckInterval == 0.0)
	{
		SpecCheckTimer = null;
		return Plugin_Stop;
	}
	
	if(g_bCvar_JoinCommandBlock == false)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				if((GetClientTeam(i) == TEAM_SPECTATORS))
				{
					if(!IsClientIdle(i))
					{
						CPrintToChat(i, "{default}[{green}MultiSlots{default}] %N, %T", i, "Type in chat !join To join the survivors", i);
					}
				}
			}
		}	
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))		
		{
			if((GetClientTeam(i) == TEAM_SURVIVORS) && !IsFakeClient(i) && !IsPlayerAlive(i))
			{
				static char PlayerName[100];
				GetClientName(i, PlayerName, sizeof(PlayerName));
				PrintToChat(i, "\x01[\x04MultiSlots\x01] %s, %T", PlayerName, "Please wait to be revived or rescued", i);
			}
		}
	}	

	return Plugin_Continue;
}

Action Timer_TakeOverBotAndDie(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) return Plugin_Stop;

	int team = GetClientTeam(client);
	if(team == TEAM_SPECTATORS)
	{
		if(IsClientIdle(client))
		{
			L4D_TakeOverBot(client);
		}
		else
		{
			int fakebot = FindBotToTakeOver(true);
			if (fakebot == 0)
			{
				PrintHintText(client, "%T", "No Bots for replacement.", client);
				return Plugin_Stop;
			}

			L4D_SetHumanSpec(fakebot, client);
			L4D_TakeOverBot(client);
		}

		CreateTimer(0.1, Timer_KillSurvivor, userid);
	}
	else if (team == TEAM_SURVIVORS)
	{
		if(IsPlayerAlive(client))
		{
			CreateTimer(0.1, Timer_KillSurvivor, userid);
		}
		else
		{
			return Plugin_Stop;
		}
	}
	else if (team == TEAM_INFECTED)
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

Action Timer_TakeOverBotAndDie2(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) return Plugin_Stop;

	int team = GetClientTeam(client);
	if(team == TEAM_SPECTATORS)
	{
		if(IsClientIdle(client))
		{
			L4D_TakeOverBot(client);
		}
		else
		{
			int fakebot = FindBotToTakeOver(true);
			if (fakebot == 0)
			{
				PrintHintText(client, "%T", "No Bots for replacement.", client);
				return Plugin_Stop;
			}

			L4D_SetHumanSpec(fakebot, client);
			L4D_TakeOverBot(client);
		}

		CreateTimer(0.1, Timer_KillSurvivor2, userid);
	}
	else if (team == TEAM_SURVIVORS)
	{
		if(IsPlayerAlive(client))
		{
			CreateTimer(0.1, Timer_KillSurvivor2, userid);
		}
		else
		{
			return Plugin_Stop;
		}
	}
	else if (team == TEAM_INFECTED)
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

Action Timer_KillSurvivor(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsPlayerAlive(client))
	{
		StripWeapons(client);
		ForcePlayerSuicide(client);
		PrintHintText(client, "%T", "The survivors has started the game, please wait to be resurrected or rescued", client);
	}

	return Plugin_Continue;
}

Action Timer_KillSurvivor2(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsPlayerAlive(client))
	{
		StripWeapons(client);
		ForcePlayerSuicide(client);
		CPrintToChat(client, "{default}[{green}MultiSlots{default}] %T", "No Second Chance", client);
	}

	return Plugin_Continue;
}

Action Timer_AutoJoinTeam(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(!client || !IsClientInGame(client))
		return Plugin_Continue;
	
	if(GetClientTeam(client) == TEAM_SURVIVORS)
		return Plugin_Continue;
	
	if(IsClientIdle(client))
		return Plugin_Continue;

	CreateTimer(0.1, JoinTeam_ColdDown, userid, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

Action Timer_NewPlayerAutoJoinTeam_Coop(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(!client || !IsClientInGame(client))
		return Plugin_Stop;

	if(g_bLimit[client] == true)
		return Plugin_Stop;
	
	if(GetClientTeam(client) == TEAM_SURVIVORS || GetClientTeam(client) == TEAM_INFECTED)
		return Plugin_Stop;
	
	if(IsClientIdle(client))
		return Plugin_Stop;

	CreateTimer(0.1, JoinTeam_ColdDown, userid, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}
/*
Action Timer_NewPlayerAutoJoinTeam_Versus(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(!client || !IsClientInGame(client))
		return Plugin_Continue;

	int team = GetClientTeam(client);
	int maxSurvivorSlots = GetTeamMaxSlots(TEAM_SURVIVORS);
	int survivorUsedSlots = GetTeamHumanCount(TEAM_SURVIVORS);
	int freeSurvivorSlots = (maxSurvivorSlots - survivorUsedSlots);
	int maxInfectedSlots = GetTeamMaxSlots(TEAM_INFECTED);
	int infectedUsedSlots = GetTeamHumanCount(TEAM_INFECTED);
	int freeInfectedSlots = (maxInfectedSlots - infectedUsedSlots);
	if(team <= TEAM_SPECTATORS)
	{
		if(survivorUsedSlots >= infectedUsedSlots + g_iCvar_VSUnBalanceLimit) //特感比較少人
		{
			if(freeInfectedSlots > 0) //特感還有位子
			{
				ChangeClientTeam(client, TEAM_INFECTED);
			}
		}
		else if(survivorUsedSlots + g_iCvar_VSUnBalanceLimit <= infectedUsedSlots) //人類比較少人
		{
			if(freeSurvivorSlots > 0) //人類還有位子
			{
				CreateTimer(0.1, JoinTeam_ColdDown, userid, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else //雙方隊伍數量相等
		{
			if(freeSurvivorSlots > 0) //人類還有位子
			{
				CreateTimer(0.1, JoinTeam_ColdDown, userid, TIMER_FLAG_NO_MAPCHANGE);
			}
			else if(freeInfectedSlots > 0) // 特感還有位子
			{
				ChangeClientTeam(client, TEAM_INFECTED);
			}
		}
	}
	else
	{
		if(survivorUsedSlots >= infectedUsedSlots + 1 + g_iCvar_VSUnBalanceLimit) //特感比較少人且相差一位以上
		{
			if(team == TEAM_INFECTED) return Plugin_Stop;

			if(freeInfectedSlots > 0) //特感還有位子
			{
				ChangeClientTeam(client, TEAM_INFECTED);
			}
		}
		else if(survivorUsedSlots + 1 + g_iCvar_VSUnBalanceLimit <= infectedUsedSlots) //人類比較少人且相差一位以上
		{
			if(team == TEAM_SURVIVORS) return Plugin_Stop;

			if(freeSurvivorSlots > 0) //人類還有位子
			{
				CreateTimer(0.1, JoinTeam_ColdDown, userid, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		else //隊伍相差一位玩家有平衡
		{
			return Plugin_Continue;
		}
	}

	return Plugin_Continue;
}
*/

Action Timer_KickNoNeededBot(Handle timer, int botid)
{
	int botclient = GetClientOfUserId(botid);

	if(TotalSurvivors() <= g_iMinSurvivors)
		return Plugin_Continue;
	
	if(botclient && IsClientInGame(botclient) && IsFakeClient(botclient) && GetClientTeam(botclient) == TEAM_SURVIVORS)
	{
		if(!IsPlayerAlive(botclient) || !HasIdlePlayer(botclient))
		{
			if(g_bStripBotWeapons) StripWeapons(botclient);
			KickClient(botclient, "Kicking No Needed Bot");
		}
	}	
	return Plugin_Continue;
}

Action Timer_KickNoNeededBot2(Handle timer)
{
	if(TotalSurvivors() <= g_iMinSurvivors)
		return Plugin_Continue;

	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i)==TEAM_SURVIVORS && !HasIdlePlayer(i))
		{
			if(g_bStripBotWeapons) StripWeapons(i);
			KickClient(i, "Kicking No Needed Bot");
			return Plugin_Continue;
		}
	}

	return Plugin_Continue;
}

Action Timer_SpawnSurvivorWhenRoundStarts(Handle timer)
{
	int team_count = TotalAliveSurvivors();
	if(team_count < 4) return Plugin_Continue;

	//LogMessage("Spawn Timer_SpawnSurvivorWhenRoundStarts: %d, %d", team_count, g_iMinSurvivors);
	if(team_count < g_iMinSurvivors)
	{
		SpawnFakeClient();
		return Plugin_Continue;
	}

	return Plugin_Stop;
}
////////////////////////////////////
// stocks
////////////////////////////////////
void ClearDefault()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

void TakeOverBotIfAny(int client)
{
	if (!IsClientInGame(client)) return;
	if (GetClientTeam(client) == TEAM_SURVIVORS) return;
	if (IsFakeClient(client)) return;

	int fakebot = FindBotToTakeOver(true);
	if (fakebot == 0)
	{
		PrintHintText(client, "%T", "No Bots for replacement.", client);
		return;
	}

	if(IsPlayerAlive(fakebot))
	{
		L4D_SetHumanSpec(fakebot, client);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 5);
		if(L4D_HasPlayerControlledZombies())
		{
			L4D_TakeOverBot(client);
		}
	}

	return;
}

int FindBotToTakeOver(bool alive)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if (IsFakeClient(i) && GetClientTeam(i)==TEAM_SURVIVORS && !HasIdlePlayer(i) && IsPlayerAlive(i) == alive)
				return i;
		}
	}
	return 0;
}

void BypassAndExecuteCommand(int client, char[] strCommand, char[] strParam1)
{
	int flags = GetCommandFlags(strCommand);
	SetCommandFlags(strCommand, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", strCommand, strParam1);
	SetCommandFlags(strCommand, flags);
}

void StripWeapons(int client) // strip all items from client
{
	int itemIdx;
	for (int x = 0; x <= 4; x++)
	{
		if((itemIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{  
			RemovePlayerItem(client, itemIdx);
			AcceptEntityInput(itemIdx, "Kill");
		}
	}
}

int TotalSurvivors() // total bots, including players
{
	int kk = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS && !IsClientInKickQueue(i))
			kk++;
	}
	return kk;
}

int TotalAliveFreeBots() // total bots (excl. IDLE players)
{
	int kk = 0;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i)==TEAM_SURVIVORS && IsPlayerAlive(i))
		{
			if(!HasIdlePlayer(i))
				kk++;
		}
	}
	return kk;
}

int TotalAliveSurvivors() // total alive survivors, including players
{
	int kk = 0;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i)==TEAM_SURVIVORS && IsPlayerAlive(i))
		{
			kk++;
		}
	}
	return kk;
}

void ResetTimer()
{
	delete SpecCheckTimer;
	delete PlayerLeftStartTimer;
	delete CountDownTimer;
}


//try to spawn survivor
bool SpawnFakeClient(bool bAdmBot = false)
{
	//check if there are any alive survivor in server
	int iAliveSurvivor = my_GetRandomSurvivor();
	if(iAliveSurvivor == 0)
		return false;
		
	// create fakeclient
	int fakeclient = CreateSurvivorBot();
	
	// if entity is valid
	if(fakeclient > 0 && IsClientInGame(fakeclient))
	{
		int fakeuserid = GetClientUserId(fakeclient);
		float teleportOrigin[3];
		GetClientAbsOrigin(iAliveSurvivor, teleportOrigin)	;
		DataPack hPack = new DataPack();
		hPack.WriteCell(fakeuserid);
		hPack.WriteFloat(teleportOrigin[0]);
		hPack.WriteFloat(teleportOrigin[1]);
		hPack.WriteFloat(teleportOrigin[2]);
		
		RequestFrame(OnNextFrame, hPack); //first time teleport
		g_bEnableKick = !bAdmBot;
		return true;
	}
	
	return false;
}

void OnNextFrame(DataPack hPack)
{
	float nPos[3];
	hPack.Reset();
	int client = GetClientOfUserId(hPack.ReadCell());
	nPos[0] = hPack.ReadFloat();
	nPos[1] = hPack.ReadFloat();
	nPos[2] = hPack.ReadFloat();
	delete hPack;

	if(!client || !IsClientInGame(client)) return;
	
	TeleportEntity( client, nPos, NULL_VECTOR, NULL_VECTOR);

	if ( !(bKill && iDeadBotTime > 0) )
	{
		StripWeapons( client );
		SetHealth( client );
		GiveItems( client );
	}

	if(g_bGiveKitSafeRoom && g_bPluginHasStarted && !g_bLeftSafeRoom)
	{
		int weapon = CreateEntityByName("weapon_first_aid_kit");
		if (weapon <= MaxClients || !IsValidEntity(weapon)) return;
		
		DispatchSpawn(weapon);
		TeleportEntity(weapon, nPos, NULL_VECTOR, NULL_VECTOR);
	}

	if(g_bLeftSafeRoom && g_fInvincibleTime > 0.0) clinetSpawnGodTime[client] = GetEngineTime() + g_fInvincibleTime;
}

bool HasIdlePlayer(int bot)
{
	if(HasEntProp(bot, Prop_Send, "m_humanSpectatorUserID"))
	{
		if(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID") > 0)
		{
			return true;
		}
	}
	
	return false;
}

bool IsClientIdle(int client)
{
	if(GetClientTeam(client) != TEAM_SPECTATORS)
		return false;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i))
		{
			if(HasEntProp(i, Prop_Send, "m_humanSpectatorUserID"))
			{
				if(GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID")) == client)
						return true;
			}
		}
	}
	return false;
}

Action Timer_PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea())
	{	
		GameStart();
		
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

Action Timer_CountDown(Handle timer)
{
	if(iCountDownTime <= 0) 
	{
		bKill = true;
		CountDownTimer = null;
		return Plugin_Stop;
	}
	iCountDownTime--;
	return Plugin_Continue;
}


int my_GetRandomSurvivor()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i))
		{
			iClients[iClientCount++] = i;
		}
	}
	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

void SetHealth( int client )
{
	float Buff = GetEntDataFloat( client, BufferHP );

	SetEntProp( client, Prop_Send, "m_iHealth", g_iCvarRespawnHP, 1 );
	SetEntDataFloat( client, BufferHP, Buff + g_iCvarRespawnBuffHP, true );
}

void GiveItems(int client) // give client weapon
{
	int flags = GetCommandFlags("give");
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);
	
	int iRandom = g_iCvarSecondWeapon;
	if(g_bLeft4Dead2 && iRandom == 5) iRandom = GetRandomInt(1,4);
		
	switch ( iRandom )
	{
		case 1:
		{
			FakeClientCommand( client, "give pistol" );
			FakeClientCommand( client, "give pistol" );
		}
		case 2: FakeClientCommand(client, "give pistol_magnum");
		case 3: FakeClientCommand(client, "give chainsaw");
		case 4: 
		{
			int entity = CreateEntityByName("weapon_melee");
			if (CheckIfEntitySafe( entity ) == false)
				return;

			DispatchKeyValue(entity, "solid", "6");
			DispatchKeyValue(entity, "melee_script_name", g_sMeleeClass[GetRandomInt(0, g_iMeleeClassCount-1)]);
			DispatchSpawn(entity);
			EquipPlayerWeapon(client, entity);
		}
		default: {
			FakeClientCommand( client, "give pistol" );
		}
	}

	iRandom = g_iCvarFirstWeapon;
	if(g_bLeft4Dead2)
	{
		if(g_iCvarFirstWeapon == 18) iRandom = GetRandomInt(13,17);
		else if(g_iCvarFirstWeapon == 19) iRandom = GetRandomInt(1,10);
		else if(g_iCvarFirstWeapon == 20) iRandom = GetRandomInt(11,12);
		
		switch ( iRandom )
		{
			case 1: FakeClientCommand(client, "give autoshotgun");
			case 2: FakeClientCommand(client, "give shotgun_spas");
			case 3: FakeClientCommand(client, "give rifle");
			case 4: FakeClientCommand(client, "give rifle_desert");
			case 5: FakeClientCommand(client, "give rifle_ak47");
			case 6: FakeClientCommand(client, "give rifle_sg552");
			case 7: FakeClientCommand(client, "give sniper_military");
			case 8: FakeClientCommand(client, "give sniper_awp");
			case 9: FakeClientCommand(client, "give sniper_scout");
			case 10: FakeClientCommand(client, "give hunting_rifle");
			case 11: FakeClientCommand(client, "give rifle_m60");
			case 12: FakeClientCommand(client, "give grenade_launcher");
			case 13: FakeClientCommand(client, "give smg");
			case 14: FakeClientCommand(client, "give smg_silenced");
			case 15: FakeClientCommand(client, "give smg_mp5");
			case 16: FakeClientCommand(client, "give pumpshotgun");
			case 17: FakeClientCommand(client, "give shotgun_chrome");
			default: {}//nothing
		}
	}
	else
	{
		if(g_iCvarFirstWeapon == 6) iRandom = GetRandomInt(4,5);
		else if(g_iCvarFirstWeapon == 7) iRandom = GetRandomInt(1,3);
		
		switch ( iRandom )
		{
			case 1: FakeClientCommand( client, "give autoshotgun" );
			case 2: FakeClientCommand( client, "give rifle" );
			case 3: FakeClientCommand( client, "give hunting_rifle" );
			case 4: FakeClientCommand( client, "give smg" );
			case 5: FakeClientCommand( client, "give pumpshotgun" );
			default: {}//nothing
		}
	}
	
	iRandom = g_iCvarThirdWeapon;
	if (g_bLeft4Dead2 && iRandom == 4) iRandom = GetRandomInt(1,3);
	if (!g_bLeft4Dead2 && iRandom == 3) iRandom = GetRandomInt(1,2);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give molotov" );
		case 2: FakeClientCommand( client, "give pipe_bomb" );
		case 3: FakeClientCommand( client, "give vomitjar" );
		default: {}//nothing
	}
	
	
	iRandom = g_iCvarFourthWeapon;
	if(g_bLeft4Dead2 && iRandom == 5) iRandom = GetRandomInt(1,4);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give first_aid_kit" );
		case 2: FakeClientCommand( client, "give defibrillator" );
		case 3: FakeClientCommand( client, "give weapon_upgradepack_incendiary" );
		case 4: FakeClientCommand( client, "give weapon_upgradepack_explosive" );
		default: {}//nothing
	}
	
	iRandom = g_iCvarFifthWeapon;
	if(g_bLeft4Dead2 && iRandom == 3) iRandom = GetRandomInt(1,2);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give pain_pills" );
		case 2: FakeClientCommand( client, "give adrenaline" );
		default: {}//nothing
	}
	
	SetCommandFlags( "give", flags);
}

int GetRandomAliveSurvivor()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i))
		{
			iClients[iClientCount++] = i;
		}
	}
	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

// ------------------------------------------------------------------------
// Returns true if client never spawned as survivor this game. Used to allow 1 free spawn
// ------------------------------------------------------------------------
bool IsSecondTime(int client)
{
	char SteamID[64];
	bool valid = GetClientAuthId(client, AuthId_SteamID64, SteamID, sizeof(SteamID));		
	
	if (valid == false) return false;

	bool bSecondTime = false;
	g_hSteamIDs.GetValue(SteamID, bSecondTime);
	return bSecondTime;
}

// ------------------------------------------------------------------------
// Stores the Steam ID, so if reconnect/rejoin we don't allow free respawn
// ------------------------------------------------------------------------
void RecordSteamID(int client)
{
	// Stores the Steam ID, so if reconnect/rejoin we don't allow free respawn
	char SteamID[64];
	bool valid = GetClientAuthId(client, AuthId_SteamID64, SteamID, sizeof(SteamID));
	if (valid && !g_hSteamIDs.GetValue(SteamID, valid))
	{
		g_hSteamIDs.SetValue(SteamID, true, true);
	}
}

int NumbersOfPlayersInSurvivorTeam()
{
	int count = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == TEAM_SPECTATORS)
		{
			if(!IsFakeClient(i)) count++;
			else if(HasIdlePlayer(i)) count++;
		}
	}
	
	return count;
}

Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damageType)
{
	if(!IsValidEntity(inflictor) || damage <= 0.0) return Plugin_Continue;

	static char sClassname[64];
	GetEntityClassname(inflictor, sClassname, 64);
	if(victim > 0 && victim <= MaxClients && IsClientInGame(victim) && GetClientTeam(victim) == TEAM_SURVIVORS && clinetSpawnGodTime[victim] > GetEngineTime() )
	{
		if( (attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) != TEAM_SPECTATORS) ||
			strcmp(sClassname, "infected") == 0 || 
			strcmp(sClassname, "witch") == 0)
		{
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

Action Timer_TeleportPlayer(Handle timer, DataPack hPack)
{
	hPack.Reset();
	float nPos[3];
	int userid = hPack.ReadCell();
	int client = GetClientOfUserId(userid);
	nPos[0] = hPack.ReadFloat();
	nPos[1] = hPack.ReadFloat();
	nPos[2] = hPack.ReadFloat();

	if (!client || !IsClientInGame(client)) return Plugin_Continue;

	if (GetClientTeam(client) == TEAM_SURVIVORS && !IsFakeClient(client))
	{
		if(g_bLeftSafeRoom && IsSecondTime(client) && g_bNoSecondChane ) 
		{
			if(IsPlayerAlive(client))
			{
				TeleportEntity( client, nPos, NULL_VECTOR, NULL_VECTOR);
				ForcePlayerSuicide(client);
			}
			CPrintToChat(client, "{default}[{green}MultiSlots{default}] %T", "No Second Chance", client);
			return Plugin_Continue;
		}
		else if(bKill && iDeadBotTime > 0 )
		{
			if(IsPlayerAlive(client))
			{
				TeleportEntity( client, nPos, NULL_VECTOR, NULL_VECTOR);
				ForcePlayerSuicide(client);
			}
			PrintHintText(client, "%T", "The survivors has started the game, please wait to be resurrected or rescued", client);
			return Plugin_Continue;
		}
		
		if(!IsPlayerAlive(client)) L4D_RespawnPlayer(client);
		
		DataPack hPack2 = new DataPack();
		hPack2.WriteCell(userid);
		hPack2.WriteFloat(nPos[0]);
		hPack2.WriteFloat(nPos[1]);
		hPack2.WriteFloat(nPos[2]);
		RequestFrame(OnNextFrame, hPack2); //first time teleport

		//CreateTimer(0.5, Timer_TeleportPlayer, userid);
	}

	return Plugin_Continue;
}

Action Timer_GiveRandomT1Weapon(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsPlayerAlive(client))
	{
		if(GetPlayerWeaponSlot(client, 0) != -1) return Plugin_Continue;

		if(iOffiicalCvar_survivor_respawn_with_guns == 0) // 0: Just a pistol
		{
			return Plugin_Continue;
		}
		else if(iOffiicalCvar_survivor_respawn_with_guns > 0) // 1: Downgrade of last primary weapon, 2: Last primary weapon.
		{
			int random;
			if(g_bLeft4Dead2) random = GetRandomInt(1,4);
			else random = GetRandomInt(1,2);
			switch(random)
			{
				case 1: BypassAndExecuteCommand(client, "give", "smg");
				case 2: BypassAndExecuteCommand(client, "give", "pumpshotgun");
				case 3: BypassAndExecuteCommand(client, "give", "smg_silenced");
				case 4: BypassAndExecuteCommand(client, "give", "shotgun_chrome");
			}
		}
	}

	return Plugin_Continue;
}

void GameStart()
{
	g_bLeftSafeRoom = true;
	iCountDownTime = iDeadBotTime;
	if(iCountDownTime > 0)
	{
		delete CountDownTimer;
		CountDownTimer = CreateTimer(1.0, Timer_CountDown, _, TIMER_REPEAT);
	}
}
int GetTeamMaxSlots(int team)
{
	int teammaxslots = 0;
	if(team == TEAM_SURVIVORS)
	{
		return g_iMaxSurvivors;
	}
	else if (team == TEAM_INFECTED)
	{
		return g_iInfectedLimit;
	}
	
	return teammaxslots;
}

int GetTeamHumanCount(int team)
{
	int humans = 0;
	int iTeam;
	for(int i = 1; i < (MaxClients + 1); i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			iTeam = GetClientTeam(i);
			if(iTeam == 1 && team == 2)
			{
				if(IsClientIdle(i)) humans++;
			}
			else if (iTeam == team)
			{
				humans++;
			}
		}
	}
	
	return humans;
}

void SaveObservers()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			if(GetClientTeam(client) == 1 && !IsClientIdle(client))
			{
				g_bIsObserver[client] = true;
			}
		}
	}
}

bool CheckIfEntitySafe(int entity)
{
	if(entity == -1) return false;

	if(	entity > ENTITY_SAFE_LIMIT)
	{
		RemoveEntity(entity);
		return false;
	}
	return true;
}

void GetMeleeTable()
{
    int table = FindStringTable("meleeweapons");
    if (table != INVALID_STRING_TABLE) 
    {
        g_iMeleeClassCount = GetStringTableNumStrings(table);

        for (int i = 0; i < g_iMeleeClassCount; i++) 
        {
            ReadStringTable(table, i, g_sMeleeClass[i], sizeof(g_sMeleeClass[]));
        }
    }
}

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
	if(client == 0)
	{
		SaveObservers();
	}

	return Plugin_Continue;
}