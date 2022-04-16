/************************************************
* Plugin name:		[L4D(2)] MultiSlots 2010~2022
* Plugin author:	SwiftReal, MI 5, ururu, KhMaIBQ, HarryPotter
* 
* Based upon:
* - (L4D) Zombie Havoc by Bigbuck
* - (L4D2) Bebop by frool
************************************************/
#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <left4dhooks>
#undef REQUIRE_PLUGIN
#include <CreateSurvivorBot>

#define PLUGIN_VERSION 				"4.7"
#define CVAR_FLAGS					FCVAR_NOTIFY
#define DELAY_KICK_FAKECLIENT 		0.1
#define DELAY_KICK_NONEEDBOT 		5.0
#define DELAY_KICK_NONEEDBOT_SAFE   25.0
#define DELAY_CHANGETEAM_NEWPLAYER 	3.5

#define TEAM_SPECTATORS 			1
#define TEAM_SURVIVORS 				2
#define TEAM_INFECTED				3

#define DAMAGE_EVENTS_ONLY			1
#define	DAMAGE_YES					2
#define	DAMAGE_NO					0

#define CLOSE_RANGE 100

//ConVar
ConVar hMaxSurvivors, hDeadBotTime, hSpecCheckInterval, 
	hFirstWeapon, hSecondWeapon, hThirdWeapon, hFourthWeapon, hFifthWeapon,
	hRespawnHP, hRespawnBuffHP, hStripBotWeapons, hSpawnSurvivorsAtStart,
	hGiveKitSafeRoom, hGiveKitFinalStart, hNoSecondChane, hCvar_InvincibleTime;

//value
int iMaxSurvivors, iDeadBotTime, g_iFirstWeapon, g_iSecondWeapon, g_iThirdWeapon, g_iFourthWeapon, g_iFifthWeapon,
	iRespawnHP, iRespawnBuffHP;
static Handle hSetHumanSpec, hTakeOver;
int g_iRoundStart, g_iPlayerSpawn, BufferHP = -1;
bool bKill, bLeftSafeRoom, g_bStripBotWeapons, g_bSpawnSurvivorsAtStart, g_bEnableKick,
	g_bGiveKitSafeRoom, g_bGiveKitFinalStart, g_bNoSecondChane;
float g_fSpecCheckInterval, g_fInvincibleTime;
Handle SpecCheckTimer = null, PlayerLeftStartTimer = null, CountDownTimer = null;
float clinetSpawnGodTime[ MAXPLAYERS + 1 ];

StringMap g_hSteamIDs;

#define	MAX_WEAPONS			10
#define	MAX_WEAPONS2		29
static char g_sWeaponModels[MAX_WEAPONS][] =
{
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/weapons/w_smg_uzi.mdl",
	"models/w_models/weapons/w_pumpshotgun_A.mdl",
	"models/w_models/weapons/w_pistol_a.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_medkit.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl"
};

static char g_sWeaponModels2[MAX_WEAPONS2][] =
{
	"models/w_models/weapons/w_rifle_m16a2.mdl",
	"models/w_models/weapons/w_autoshot_m4super.mdl",
	"models/w_models/weapons/w_sniper_mini14.mdl",
	"models/w_models/weapons/w_smg_uzi.mdl",
	"models/w_models/weapons/w_pumpshotgun_A.mdl",
	"models/w_models/weapons/w_pistol_a.mdl",
	"models/w_models/weapons/w_eq_molotov.mdl",
	"models/w_models/weapons/w_eq_pipebomb.mdl",
	"models/w_models/weapons/w_eq_medkit.mdl",
	"models/w_models/weapons/w_eq_painpills.mdl",

	"models/w_models/weapons/w_shotgun.mdl",
	"models/w_models/weapons/w_desert_rifle.mdl",
	"models/w_models/weapons/w_grenade_launcher.mdl",
	"models/w_models/weapons/w_m60.mdl",
	"models/w_models/weapons/w_rifle_ak47.mdl",
	"models/w_models/weapons/w_rifle_sg552.mdl",
	"models/w_models/weapons/w_shotgun_spas.mdl",
	"models/w_models/weapons/w_smg_a.mdl",
	"models/w_models/weapons/w_smg_mp5.mdl",
	"models/w_models/weapons/w_sniper_awp.mdl",
	"models/w_models/weapons/w_sniper_military.mdl",
	"models/w_models/weapons/w_sniper_scout.mdl",
	"models/weapons/melee/w_chainsaw.mdl",
	"models/w_models/weapons/w_desert_eagle.mdl",
	"models/w_models/weapons/w_eq_bile_flask.mdl",
	"models/w_models/weapons/w_eq_defibrillator.mdl",
	"models/w_models/weapons/w_eq_explosive_ammopack.mdl",
	"models/w_models/weapons/w_eq_incendiary_ammopack.mdl",
	"models/w_models/weapons/w_eq_adrenaline.mdl"
};

public Plugin myinfo = 
{
	name 			= "[L4D(2)] MultiSlots Improved",
	author 			= "SwiftReal, MI 5, ururu, KhMaIBQ, HarryPotter",
	description 	= "Allows additional survivor players in coop/survival/realism when 5+ player joins the server",
	version 		= PLUGIN_VERSION,
	url 			= "https://steamcommunity.com/id/TIGER_x_DRAGON/"
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

ConVar g_hSurvivorLimit;
public void OnPluginStart()
{
	g_hSurvivorLimit = FindConVar("survivor_limit");
	if(g_hSurvivorLimit == null)
	{
		SetFailState("Unable to find \"survivor_limit\" convar.");
	}
	if(g_hSurvivorLimit.IntValue > 4)
	{
		SetFailState("Do not modify \"survivor_limit\" valve above 4, unload l4dmultislots.smx now!");
	}
	g_hSurvivorLimit.AddChangeHook(ConVarChanged_SurvivorCvars);

	// Load translation
	LoadTranslations("l4dmultislots.phrases");
	
	//store PropInfo
	BufferHP = FindSendPropInfo( "CTerrorPlayer", "m_healthBuffer" );
	
	// Register commands
	RegAdminCmd("sm_muladdbot", ADMAddBot, ADMFLAG_KICK, "Attempt to add a survivor bot (this bot will not be kicked by this plugin until someone takes over)");
	RegConsoleCmd("sm_join", JoinTeam, "Attempt to join Survivors");
	RegConsoleCmd("sm_js", JoinTeam, "Attempt to join Survivors");
	
	// Register cvars
	hMaxSurvivors	= CreateConVar("l4d_multislots_max_survivors", "4", "Kick AI Survivor bots if numbers of survivors has exceeded the certain value. (does not kick real player, minimum is 4)", CVAR_FLAGS, true, 4.0, true, 32.0);
	hStripBotWeapons = CreateConVar("l4d_multislots_bot_items_delete", "1", "Delete all items form survivor bots when they got kicked by this plugin. (0=off)", CVAR_FLAGS, true, 0.0, true, 1.0);
	hDeadBotTime = CreateConVar("l4d_multislots_alive_bot_time", "0", "When 5+ new player joins the server but no any bot can be taken over, the player will appear as a dead survivor if survivors have left start safe area for at least X seconds. (0=Always spawn alive bot for new player)", CVAR_FLAGS, true, 0.0);
	hSpecCheckInterval = CreateConVar("l4d_multislots_spec_message_interval", "25", "Setup time interval the instruction message to spectator.(0=off)", CVAR_FLAGS, true, 0.0);
	hRespawnHP 		= CreateConVar("l4d_multislots_respawnhp", 		"80", 	"Amount of HP a new 5+ Survivor will spawn with (Def 80)", CVAR_FLAGS, true, 0.0, true, 100.0);
	hRespawnBuffHP 	= CreateConVar("l4d_multislots_respawnbuffhp", 	"20", 	"Amount of buffer HP a new 5+ Survivor will spawn with (Def 20)", CVAR_FLAGS, true, 0.0, true, 100.0);
	hSpawnSurvivorsAtStart = CreateConVar("l4d_multislots_spawn_survivors_roundstart", "0", "If 1, Spawn 5+ survivor bots when round starts. (Numbers depends on Convar l4d_multislots_max_survivors)", CVAR_FLAGS, true, 0.0, true, 1.0);
	
	if ( g_bLeft4Dead2 ) {
		hFirstWeapon 		= CreateConVar("l4d_multislots_firstweapon", 		"19", 	"First slot weapon for new 5+ Survivor (1-Autoshot, 2-SPAS, 3-M16, 4-SCAR, 5-AK47, 6-SG552, 7-Mil Sniper, 8-AWP, 9-Scout, 10=Hunt Rif, 11=M60, 12=GL, 13-SMG, 14-Sil SMG, 15=MP5, 16-Pump Shot, 17=Chrome Shot, 18=Rand T1, 19=Rand T2, 20=Rand T3, 0=off)", CVAR_FLAGS, true, 0.0, true, 20.0);
		hSecondWeapon 		= CreateConVar("l4d_multislots_secondweapon", 		"16", 	"Second slot weapon for new 5+ Survivor (1- Dual Pistol, 2-Magnum, 3-Chainsaw, 4-Fry Pan, 5-Katana, 6-Shovel, 7-Golfclub, 8-Machete, 9-Cricket, 10=Fireaxe, 11=Knife, 12=Bball Bat, 13=Crowbar, 14=Pitchfork, 15=Guitar, 16=Random, 0=Only Pistol)", CVAR_FLAGS, true, 0.0, true, 16.0);
		hThirdWeapon 		= CreateConVar("l4d_multislots_thirdweapon", 		"4", 	"Third slot item for new 5+ Survivor (1 - Moltov, 2 - Pipe Bomb, 3 - Bile Jar, 4=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 4.0);
		hFourthWeapon 		= CreateConVar("l4d_multislots_forthweapon", 		"0", 	"Fourth slot item for new 5+ Survivor (1 - Medkit, 2 - Defib, 3 - Incendiary Pack, 4 - Explosive Pack, 5=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 5.0);
		hFifthWeapon 		= CreateConVar("l4d_multislots_fifthweapon", 		"0", 	"Fifth slot item for new 5+ Survivor (1 - Pills, 2 - Adrenaline, 3=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 3.0);
		} else {
		hFirstWeapon 		= CreateConVar("l4d_multislots_firstweapon", 		"6", 	"First slot weapon for new 5+ Survivor (1 - Autoshotgun, 2 - M16, 3 - Hunting Rifle, 4 - smg, 5 - shotgun, 6=Random T1, 7=Random T2, 0=off)", CVAR_FLAGS, true, 0.0, true, 7.0);
		hSecondWeapon 		= CreateConVar("l4d_multislots_secondweapon", 		"1", 	"Second slot weapon for new 5+ Survivor (1 - Dual Pistol, 0=Only Pistol)", CVAR_FLAGS, true, 0.0, true, 1.0);
		hThirdWeapon 		= CreateConVar("l4d_multislots_thirdweapon", 		"3", 	"Third slot item for new 5+ Survivor (1 - Moltov, 2 - Pipe Bomb, 3=Random, 0=off)", CVAR_FLAGS, true, 0.0, true, 3.0);
		hFourthWeapon 		= CreateConVar("l4d_multislots_forthweapon", 		"0", 	"Fourth slot item for new 5+ Survivor (1 - Medkit, 0=off)", CVAR_FLAGS, true, 0.0, true, 1.0);
		hFifthWeapon 		= CreateConVar("l4d_multislots_fifthweapon", 		"0", 	"Fifth slot item for new 5+ Survivor (1 - Pills, 0=off)", CVAR_FLAGS, true, 0.0, true, 1.0);
	}
	hGiveKitSafeRoom 		= CreateConVar("l4d_multislots_saferoom_extra_first_aid", "1", "If 1, allow extra first aid kits for 5+ players when in start saferoom, One extra kit per player above four. (0=No extra kits)", CVAR_FLAGS, true, 0.0, true, 1.0);
	hGiveKitFinalStart 		= CreateConVar("l4d_multislots_finale_extra_first_aid", "1" , "If 1, allow extra first aid kits for 5+ players when the finale is activated, One extra kit per player above four. (0=No extra kits)", CVAR_FLAGS, true, 0.0, true, 1.0);
	hNoSecondChane 			= CreateConVar("l4d_multislots_no_second_free_spawn", "0" , "If 1, when same player reconnect the server or rejoin survivor team but no any bot can be taken over, give him a dead bot. (0=Always spawn alive bot for same player)", CVAR_FLAGS, true, 0.0, true, 1.0);
	hCvar_InvincibleTime 	= CreateConVar("l4d_multislots_respawn_invincibletime", 	"3.0", "Invincible time after new 5+ Survivor spawn by this plugin. (0=off)",  FCVAR_NOTIFY, true, 0.0);
	
	GetCvars();
	hMaxSurvivors.AddChangeHook(ConVarChanged_Cvars);
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
	hGiveKitSafeRoom.AddChangeHook(ConVarChanged_Cvars);
	hGiveKitFinalStart.AddChangeHook(ConVarChanged_Cvars);
	hNoSecondChane.AddChangeHook(ConVarChanged_Cvars);
	hCvar_InvincibleTime.AddChangeHook(ConVarChanged_Cvars);
	
	// Hook events
	
	HookEvent("player_bot_replace", OnBotSwap);
	HookEvent("bot_player_replace", OnBotSwap);
	HookEvent("survivor_rescued", evtSurvivorRescued);
	HookEvent("player_bot_replace", evtBotReplacedPlayer);
	HookEvent("player_team", evtPlayerTeam, EventHookMode_Pre);
	HookEvent("player_spawn", evtPlayerSpawn);
	HookEvent("player_death", evtPlayerDeath);
	HookEvent("round_start", 		Event_RoundStart);
	HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
	HookEvent("map_transition", Event_RoundEnd); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", Event_RoundEnd); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("finale_start", Event_FinaleStart, EventHookMode_Post);

	// ======================================
	// Prep SDK Calls
	// ======================================

	Handle hGameConf = LoadGameConfigFile("l4dmultislots");
	if(hGameConf == null)
	{
		SetFailState("Gamedata l4dmultislots.txt not found");
		return;
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "SetHumanSpec");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	hSetHumanSpec = EndPrepSDKCall();
	if (hSetHumanSpec == null)
	{
		SetFailState("Cant initialize SetHumanSpec SDKCall");
		return;
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, "TakeOverBot");
	PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
	hTakeOver = EndPrepSDKCall();
	if( hTakeOver == null)
	{
		SetFailState("Could not prep the \"TakeOverBot\" function.");
		return;
	}
	delete hGameConf;
	
	// Create or execute plugin configuration file
	AutoExecConfig(true, "l4dmultislots");

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

public void OnPluginEnd()
{
	g_hSteamIDs.Clear(); delete g_hSteamIDs;
	ClearDefault();
	ResetTimer();
	ResetConVar(FindConVar("z_spawn_flow_limit"), true, true);
}

public void OnMapStart()
{
	TweakSettings();

	int max = 0;
	if( g_bLeft4Dead2 )
	{
		max = MAX_WEAPONS2;
		for( int i = 0; i < max; i++ )
		{
			PrecacheModel(g_sWeaponModels2[i], true);
		}
		PrecacheModel("models/weapons/melee/v_bat.mdl", true);
		PrecacheModel("models/weapons/melee/v_cricket_bat.mdl", true);
		PrecacheModel("models/weapons/melee/v_crowbar.mdl", true);
		PrecacheModel("models/weapons/melee/v_electric_guitar.mdl", true);
		PrecacheModel("models/weapons/melee/v_fireaxe.mdl", true);
		PrecacheModel("models/weapons/melee/v_frying_pan.mdl", true);
		PrecacheModel("models/weapons/melee/v_golfclub.mdl", true);
		PrecacheModel("models/weapons/melee/v_katana.mdl", true);
		PrecacheModel("models/weapons/melee/v_machete.mdl", true);
		PrecacheModel("models/weapons/melee/v_tonfa.mdl", true);
		PrecacheModel("models/weapons/melee/v_pitchfork.mdl", true);
		PrecacheModel("models/weapons/melee/v_shovel.mdl", true);

		PrecacheModel("models/weapons/melee/w_bat.mdl", true);
		PrecacheModel("models/weapons/melee/w_cricket_bat.mdl", true);
		PrecacheModel("models/weapons/melee/w_crowbar.mdl", true);
		PrecacheModel("models/weapons/melee/w_electric_guitar.mdl", true);
		PrecacheModel("models/weapons/melee/w_fireaxe.mdl", true);
		PrecacheModel("models/weapons/melee/w_frying_pan.mdl", true);
		PrecacheModel("models/weapons/melee/w_golfclub.mdl", true);
		PrecacheModel("models/weapons/melee/w_katana.mdl", true);
		PrecacheModel("models/weapons/melee/w_machete.mdl", true);
		PrecacheModel("models/weapons/melee/w_tonfa.mdl", true);
		PrecacheModel("models/weapons/melee/w_pitchfork.mdl", true);
		PrecacheModel("models/weapons/melee/w_shovel.mdl", true);

		PrecacheGeneric("scripts/melee/baseball_bat.txt", true);
		PrecacheGeneric("scripts/melee/cricket_bat.txt", true);
		PrecacheGeneric("scripts/melee/crowbar.txt", true);
		PrecacheGeneric("scripts/melee/electric_guitar.txt", true);
		PrecacheGeneric("scripts/melee/fireaxe.txt", true);
		PrecacheGeneric("scripts/melee/frying_pan.txt", true);
		PrecacheGeneric("scripts/melee/golfclub.txt", true);
		PrecacheGeneric("scripts/melee/katana.txt", true);
		PrecacheGeneric("scripts/melee/machete.txt", true);
		PrecacheGeneric("scripts/melee/tonfa.txt", true);
		PrecacheGeneric("scripts/melee/pitchfork.txt", true);
		PrecacheGeneric("scripts/melee/shovel.txt", true);
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
}

public void OnMapEnd()
{
	g_hSteamIDs.Clear();
	ClearDefault();
	ResetTimer();
}

public void ConVarChanged_SurvivorCvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(g_hSurvivorLimit.IntValue > 4)
	{
		SetFailState("Do not modify \"survivor_limit\" valve above 4, unload l4dmultislots.smx now!");
	}	
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	iMaxSurvivors = hMaxSurvivors.IntValue;
	g_bStripBotWeapons = hStripBotWeapons.BoolValue;
	iDeadBotTime = hDeadBotTime.IntValue;
	g_fSpecCheckInterval = hSpecCheckInterval.FloatValue;
	g_bSpawnSurvivorsAtStart = hSpawnSurvivorsAtStart.BoolValue;
	
	iRespawnHP = hRespawnHP.IntValue;
	iRespawnBuffHP = hRespawnBuffHP.IntValue;
	
	g_iFirstWeapon = hFirstWeapon.IntValue;
	g_iSecondWeapon = hSecondWeapon.IntValue;
	g_iThirdWeapon = hThirdWeapon.IntValue;
	g_iFourthWeapon = hFourthWeapon.IntValue;
	g_iFifthWeapon = hFifthWeapon.IntValue;
	g_bGiveKitSafeRoom = hGiveKitSafeRoom.BoolValue;
	g_bGiveKitFinalStart = hGiveKitFinalStart.BoolValue;
	g_bNoSecondChane = hNoSecondChane.BoolValue;
	g_fInvincibleTime = hCvar_InvincibleTime.FloatValue;
}

////////////////////////////////////
// Callbacks
////////////////////////////////////
public Action ADMAddBot(int client, int args)
{
	if(client == 0)
		return Plugin_Continue;
	
	if(SpawnFakeClient(true) == true)
		PrintToChat(client, "%T", "A surviving Bot was added.", client);
	else
		PrintToChat(client, "%T", "Impossible to generate a bot at the moment.", client);
	
	return Plugin_Handled;
}


public Action JoinTeam(int client,int args)
{
	if(!client || !IsClientInGame(client))
		return Plugin_Handled;

	CreateTimer(0.15, JoinTeam_ColdDown, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
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
		CreateTimer(DELAY_CHANGETEAM_NEWPLAYER, Timer_NewPlayerAutoJoinTeam, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void evtPlayerTeam(Event event, const char[] name, bool dontBroadcast) 
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
				if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsAlive(i))
				{
					if(HasEntProp(i, Prop_Send, "m_humanSpectatorUserID"))
					{
						if(GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID")) == client)
						{
							//LogMessage("afk player %N changes team or leaves the game, his bot is %N",client,i);
							if(!bLeftSafeRoom)
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

public Action Timer_ChangeTeam(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SPECTATORS && IsPlayerAlive(client))
	{
		RecordSteamID(client); // Record SteamID of player.
	}

	return Plugin_Continue;
}

public void OnBotSwap(Event event, const char[] name, bool dontBroadcast)
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

public void evtSurvivorRescued(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("victim"));
	if(client && IsClientInGame(client))
	{	
		GiveRandomT1Weapon(client);
	}
}

public void evtBotReplacedPlayer(Event event, const char[] name, bool dontBroadcast) 
{
	int fakebotid = event.GetInt("bot");
	int fakebot = GetClientOfUserId(fakebotid);
	if(fakebot && IsClientInGame(fakebot) && GetClientTeam(fakebot) == TEAM_SURVIVORS && IsFakeClient(fakebot))
	{
		if(!bLeftSafeRoom)
			CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, fakebotid);
		else
			CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, fakebotid);
	}
}

public void evtPlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS)
	{
		if(IsFakeClient(client))
		{
			if(g_bEnableKick == false) return;
			
			g_bEnableKick = false;

			//LogMessage("will kick %N bot in few seconds", client);

			if(!bLeftSafeRoom)
				CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, userid);
			else
				CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, userid);
		}
		else
		{
			RecordSteamID(client); // Record SteamID of player.

			if(g_bSpawnSurvivorsAtStart)
				CreateTimer(0.2, Timer_KickNoNeededBot2);
		}
	}

	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, PluginStart);
	g_iPlayerSpawn = 1;	
}

public void evtPlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && GetClientTeam(client) == TEAM_SURVIVORS && IsFakeClient(client))
	{
		if(!bLeftSafeRoom)
			CreateTimer(DELAY_KICK_NONEEDBOT_SAFE, Timer_KickNoNeededBot, userid);
		else
			CreateTimer(DELAY_KICK_NONEEDBOT, Timer_KickNoNeededBot, userid);
	}	
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_hSteamIDs.Clear();
	g_bEnableKick = false;
	ClearDefault();
	ResetTimer();
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_bEnableKick = false;

	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, PluginStart);
	g_iRoundStart = 1;
}

public void Event_FinaleStart(Event event, const char[] name, bool dontBroadcast)
{
	if(g_bGiveKitFinalStart)
	{
		int client = GetRandomAliveSurvivor();
		int amount = TotalSurvivors() - 4;

		if(amount > 0 && client > 0)
		{
			for(int i = 1; i <= amount; i++)
			{
				CheatCommand(client, "give", "first_aid_kit", "");
			}
		}
	}
}

////////////////////////////////////
// timers
////////////////////////////////////
public Action JoinTeam_ColdDown(Handle timer, int userid)
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
			else if((DispatchKeyValue(client, "classname", "info_survivor_position") == true) && !IsAlive(client))
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
						SDKCall(hSetHumanSpec, bot, client);
						SDKCall(hTakeOver, client, true);
						return Plugin_Continue;
					}
				}

				if(SpawnFakeClient() == true)
				{
					if( bLeftSafeRoom && IsSecondTime(client) && g_bNoSecondChane ) CreateTimer(0.4, Timer_TakeOverBotAndDie2, userid, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					else if( bKill && iDeadBotTime > 0 ) CreateTimer(0.4, Timer_TakeOverBotAndDie, userid, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					else CreateTimer(0.4, Timer_AutoJoinTeam, userid);	
				}
				else
				{
					PrintHintText(client, "%T", "Impossible to generate a bot at the moment.", client);
				}
			}
			else
			{
				TakeOverBot(client);
			}
		}
	}

	return Plugin_Continue;
}

int iCountDownTime;
public Action PluginStart(Handle timer)
{
	ClearDefault();
	if(g_bSpawnSurvivorsAtStart) CreateTimer(0.25, Timer_SpawnSurvivorWhenRoundStarts, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	if(PlayerLeftStartTimer == null) PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);
	if(SpecCheckTimer == null && g_fSpecCheckInterval > 0.0) SpecCheckTimer = CreateTimer(g_fSpecCheckInterval, Timer_SpecCheck, _, TIMER_REPEAT)	;

	int client = GetRandomAliveSurvivor();
	int amount = TotalSurvivors() - 4;
	int weapon;
	float vPos[3];

	if( g_bGiveKitSafeRoom && amount > 0 && client > 0 )
	{
		GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);
		for(int i = 1; i <= amount; i++)
		{
			weapon = CreateEntityByName("weapon_first_aid_kit");
			if (weapon <= MaxClients || !IsValidEntity(weapon)) continue;
			
			DispatchSpawn(weapon);
			TeleportEntity(weapon, vPos, NULL_VECTOR, NULL_VECTOR);
		}
	}

	return Plugin_Continue;
}

public Action Timer_SpecCheck(Handle timer)
{
	if(g_fSpecCheckInterval == 0.0)
	{
		SpecCheckTimer = null;
		return Plugin_Stop;
	}
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if((GetClientTeam(i) == TEAM_SPECTATORS) && !IsFakeClient(i))
			{
				if(!IsClientIdle(i))
				{
					static char PlayerName[100];
					GetClientName(i, PlayerName, sizeof(PlayerName))		;
					CPrintToChat(i, "{default}[{green}MultiSlots{default}] %s, %T", PlayerName, "Type in chat !join To join the survivors", i);
				}
			}
		}
	}	
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))		
		{
			if((GetClientTeam(i) == TEAM_SURVIVORS) && !IsFakeClient(i) && !IsAlive(i))
			{
				static char PlayerName[100];
				GetClientName(i, PlayerName, sizeof(PlayerName));
				PrintToChat(i, "\x01[\x04MultiSlots\x01] %s, %T", PlayerName, "Please wait to be revived or rescued", i);
			}
		}
	}	

	return Plugin_Continue;
}

public Action Timer_TakeOverBotAndDie(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) return Plugin_Stop;

	int team = GetClientTeam(client);
	if(team == TEAM_SPECTATORS)
	{
		if(IsClientIdle(client))
		{
			SDKCall(hTakeOver, client, true);
		}
		else
		{
			int fakebot = FindBotToTakeOver(true);
			if (fakebot == 0)
			{
				PrintHintText(client, "%T", "No Bots for replacement.", client);
				return Plugin_Stop;
			}

			SDKCall(hSetHumanSpec, fakebot, client);
			SDKCall(hTakeOver, client, true);
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

public Action Timer_TakeOverBotAndDie2(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) return Plugin_Stop;

	int team = GetClientTeam(client);
	if(team == TEAM_SPECTATORS)
	{
		if(IsClientIdle(client))
		{
			SDKCall(hTakeOver, client, true);
		}
		else
		{
			int fakebot = FindBotToTakeOver(true);
			if (fakebot == 0)
			{
				PrintHintText(client, "%T", "No Bots for replacement.", client);
				return Plugin_Stop;
			}

			SDKCall(hSetHumanSpec, fakebot, client);
			SDKCall(hTakeOver, client, true);
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

public Action Timer_KillSurvivor(Handle timer, int client)
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
public Action Timer_KillSurvivor2(Handle timer, int client)
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

public Action Timer_AutoJoinTeam(Handle timer, int userid)
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

public Action Timer_NewPlayerAutoJoinTeam(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(!client || !IsClientInGame(client))
		return Plugin_Stop;
	
	if(GetClientTeam(client) == TEAM_SURVIVORS || GetClientTeam(client) == TEAM_INFECTED)
		return Plugin_Stop;
	
	if(IsClientIdle(client))
		return Plugin_Stop;

	CreateTimer(0.1, JoinTeam_ColdDown, userid, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

public Action Timer_KickNoNeededBot(Handle timer, int botid)
{
	int botclient = GetClientOfUserId(botid);

	if((TotalSurvivors() <= iMaxSurvivors))
		return Plugin_Continue;
	
	if(botclient && IsClientInGame(botclient) && IsFakeClient(botclient) && GetClientTeam(botclient) == TEAM_SURVIVORS)
	{
		if(!IsAlive(botclient) || !HasIdlePlayer(botclient))
		{
			if(g_bStripBotWeapons) StripWeapons(botclient);
			KickClient(botclient, "Kicking No Needed Bot");
		}
	}	
	return Plugin_Continue;
}

public Action Timer_KickNoNeededBot2(Handle timer)
{
	if((TotalSurvivors() <= iMaxSurvivors))
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

public Action Timer_SpawnSurvivorWhenRoundStarts(Handle timer, int client)
{
	int team_count = TotalAliveSurvivors();
	if(team_count < 4) return Plugin_Continue;

	//LogMessage("Spawn Timer_SpawnSurvivorWhenRoundStarts: %d, %d", team_count, iMaxSurvivors);
	if(team_count < iMaxSurvivors)
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
	bKill = false;
	bLeftSafeRoom = false;
	
	for ( int client = 1; client <= MaxClients; client ++ )
	{
		clinetSpawnGodTime[client] = 0.0;
	}
}


void TweakSettings()
{
	SetConVarInt(FindConVar("z_spawn_flow_limit"), 50000) ;// allow spawning bots at any time
}

void TakeOverBot(int client)
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
		SDKCall(hSetHumanSpec, fakebot, client);
		SetEntProp(client, Prop_Send, "m_iObserverMode", 5);
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

void GiveRandomT1Weapon(int client) // give client random weapon
{
	if(GetPlayerWeaponSlot(client, 1) != -1)
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

int TotalSurvivors() // total bots, including players
{
	int kk = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && (GetClientTeam(i) == TEAM_SURVIVORS))
			kk++;
	}
	return kk;
}

int TotalAliveFreeBots() // total bots (excl. IDLE players)
{
	int kk = 0;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i)==TEAM_SURVIVORS && IsAlive(i))
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
		if(IsClientInGame(i) && GetClientTeam(i)==TEAM_SURVIVORS && IsAlive(i))
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
	int iAliveSurvivor = my_GetRandomClient();
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

public void OnNextFrame(DataPack hPack)
{
	float nPos[3];
	hPack.Reset();
	int fakeclient = GetClientOfUserId(hPack.ReadCell());
	nPos[0] = hPack.ReadFloat();
	nPos[1] = hPack.ReadFloat();
	nPos[2] = hPack.ReadFloat();
	delete hPack;

	if(!fakeclient || !IsClientInGame(fakeclient)) return;
	
	TeleportEntity( fakeclient, nPos, NULL_VECTOR, NULL_VECTOR);

	if ( !(bKill && iDeadBotTime > 0) )
	{
		StripWeapons( fakeclient );
		SetHealth( fakeclient );
		GiveItems( fakeclient );
	}

	if(!bLeftSafeRoom && g_bGiveKitSafeRoom)
	{
		int weapon = CreateEntityByName("weapon_first_aid_kit");
		if (weapon <= MaxClients || !IsValidEntity(weapon)) return;
		
		DispatchSpawn(weapon);
		TeleportEntity(weapon, nPos, NULL_VECTOR, NULL_VECTOR);
	}
	
	clinetSpawnGodTime[fakeclient] = GetEngineTime() + g_fInvincibleTime;
}

bool HasIdlePlayer(int bot)
{
	if(HasEntProp(bot, Prop_Send, "m_humanSpectatorUserID"))
	{
		int client = GetClientOfUserId(GetEntProp(bot, Prop_Send, "m_humanSpectatorUserID"));		
		if(client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && IsClientObserver(client))
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
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsAlive(i))
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

bool IsAlive(int client)
{
	if(!GetEntProp(client, Prop_Send, "m_lifeState"))
		return true;
	
	return false;
}

public Action Timer_PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea())
	{	
		bLeftSafeRoom = true;
		iCountDownTime = iDeadBotTime;
		if(iCountDownTime > 0)
		{
			if(CountDownTimer == null) CountDownTimer = CreateTimer(1.0, Timer_CountDown, _, TIMER_REPEAT);
		}
		
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Timer_CountDown(Handle timer)
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


int my_GetRandomClient()
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

	SetEntProp( client, Prop_Send, "m_iHealth", iRespawnHP, 1 );
	SetEntDataFloat( client, BufferHP, Buff + iRespawnBuffHP, true );
}

void GiveItems(int client) // give client weapon
{
	int flags = GetCommandFlags("give");
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);
	
	int iRandom = g_iSecondWeapon;
	if(g_bLeft4Dead2 && iRandom == 16) iRandom = GetRandomInt(1,15);
		
	switch ( iRandom )
	{
		case 1:
		{
			FakeClientCommand( client, "give pistol" );
			FakeClientCommand( client, "give pistol" );
		}
		case 2: FakeClientCommand(client, "give pistol_magnum");
		case 3: FakeClientCommand(client, "give chainsaw");
		case 4: FakeClientCommand(client, "give frying_pan");
		case 5: FakeClientCommand(client, "give katana");
		case 6: FakeClientCommand(client, "give shovel");
		case 7: FakeClientCommand(client, "give golfclub");
		case 8: FakeClientCommand(client, "give machete");
		case 9: FakeClientCommand(client, "give cricket_bat");
		case 10: FakeClientCommand(client, "give fireaxe");
		case 11: FakeClientCommand(client, "give knife");
		case 12: FakeClientCommand(client, "give baseball_bat");
		case 13: FakeClientCommand(client, "give crowbar");
		case 14: FakeClientCommand(client, "give pitchfork");
		case 15: FakeClientCommand(client, "give electric_guitar");
		default: {
			FakeClientCommand( client, "give pistol" );
		}
	}

	iRandom = g_iFirstWeapon;
	if(g_bLeft4Dead2)
	{
		if(g_iFirstWeapon == 18) iRandom = GetRandomInt(13,17);
		else if(g_iFirstWeapon == 19) iRandom = GetRandomInt(1,10);
		else if(g_iFirstWeapon == 20) iRandom = GetRandomInt(11,12);
		
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
		if(g_iFirstWeapon == 6) iRandom = GetRandomInt(4,5);
		else if(g_iFirstWeapon == 7) iRandom = GetRandomInt(1,3);
		
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
	
	iRandom = g_iThirdWeapon;
	if (g_bLeft4Dead2 && iRandom == 4) iRandom = GetRandomInt(1,3);
	if (!g_bLeft4Dead2 && iRandom == 3) iRandom = GetRandomInt(1,2);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give molotov" );
		case 2: FakeClientCommand( client, "give pipe_bomb" );
		case 3: FakeClientCommand( client, "give vomitjar" );
		default: {}//nothing
	}
	
	
	iRandom = g_iFourthWeapon;
	if(g_bLeft4Dead2 && iRandom == 5) iRandom = GetRandomInt(1,4);
	
	switch ( iRandom )
	{
		case 1: FakeClientCommand( client, "give first_aid_kit" );
		case 2: FakeClientCommand( client, "give defibrillator" );
		case 3: FakeClientCommand( client, "give weapon_upgradepack_incendiary" );
		case 4: FakeClientCommand( client, "give weapon_upgradepack_explosive" );
		default: {}//nothing
	}
	
	iRandom = g_iFifthWeapon;
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
		if (IsClientInGame(i) && GetClientTeam(i) == TEAM_SURVIVORS && IsPlayerAlive(i) && !IsClientInKickQueue(i))
		{
			iClients[iClientCount++] = i;
		}
	}
	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

void CheatCommand(int client, const char[] command, const char[] argument1, const char[] argument2)
{
	int userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s", command, argument1, argument2);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userFlags);
}

// ------------------------------------------------------------------------
// Returns true if client never spawned as survivor this game. Used to allow 1 free spawn
// ------------------------------------------------------------------------
bool IsSecondTime(int client)
{
	char SteamID[64];
	bool valid = GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));		
	
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
	bool valid = GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
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

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damageType)
{
	if(!IsValidEntity(inflictor) || damage <= 0.0) return Plugin_Continue;

	static char sClassname[64];
	GetEntityClassname(inflictor, sClassname, 64);
	if(victim > 0 && victim < MaxClients && IsClientInGame(victim) && GetClientTeam(victim) == TEAM_SURVIVORS && clinetSpawnGodTime[victim] > GetEngineTime() )
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