/**
 * -Relate Valve ConVar-
 * If true, survivor bots will be used as placeholders for survivors who are still changing levels
 * If false, prevent bots from moving, changing weapons, using kits while human survivors are still changing levels
 * need to write down in cfg/server.cfg
 * 
 * sm_cvar sb_transition 1
 * 
*/
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#include <l4d_heartbeat>
#include <l4d_transition_entity> // https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_transition_entity
#define PLUGIN_VERSION			"6.6-2026/2/20"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D1/2] Save Weapon",
	author = "MAKS, HarryPotter",
	description = "Save weapons/health when map transition if more than 4 players in l4d1/2",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

GlobalForward 
	g_hForwardSaveWeaponGive,
	g_hForwardSaveWeaponSave;

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

	g_hForwardSaveWeaponGive = new GlobalForward("L4D2_OnSaveWeaponHxGiveC", ET_Ignore, Param_Cell);
	g_hForwardSaveWeaponSave = new GlobalForward("L4D2_OnSaveWeaponHxSaveC", ET_Ignore, Param_Cell);

	RegPluginLibrary("l4d2_ty_saveweapons");

	return APLRes_Success;
}

#define GAMEDATA	"l4d2_ty_saveweapons"

static char g_sWeaponModels_L4D1[][] =
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

static char g_sWeaponModels_L4D2[][] =
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

static char survivor_names_L4D1[4][] = { "Bill", "Zoey", "Francis", "Louis"};
static char survivor_names_L4D2[8][] = { "Nick", "Rochelle", "Coach", "Ellis", "Bill", "Zoey", "Francis", "Louis"};
static char survivor_models_L4D1[4][] =
{
	"models/survivors/survivor_namvet.mdl",
	"models/survivors/survivor_teenangst.mdl",
	"models/survivors/survivor_biker.mdl",
	"models/survivors/survivor_manager.mdl"
};
static char survivor_models_L4D2[8][] =
{
	"models/survivors/survivor_gambler.mdl",
	"models/survivors/survivor_producer.mdl",
	"models/survivors/survivor_coach.mdl",
	"models/survivors/survivor_mechanic.mdl",
	"models/survivors/survivor_namvet.mdl",
	"models/survivors/survivor_teenangst.mdl",
	"models/survivors/survivor_biker.mdl",
	"models/survivors/survivor_manager.mdl"
};

ConVar g_hFullHealth, /*g_hGameTimeBlock, */
	g_hSaveBot, g_hSaveHealth, g_hSaveCharacter, g_hCvarReviveHealth, g_hSurvivorMaxInc;

char sg_slot0[MAXPLAYERS+1][64];			/* slot0 weapon */
char sg_slot1[MAXPLAYERS+1][64];			/* slot1 weapon*/
char sg_slot2[MAXPLAYERS+1][64];			/* slot2 weapon */
char sg_slot3[MAXPLAYERS+1][64];			/* slot3 weapon */
char sg_slot4[MAXPLAYERS+1][64];			/* slot4 weapon */
int ig_slots0_clip[MAXPLAYERS+1]; 			/* slot0 m_iClip */
int ig_slots1_clip[MAXPLAYERS+1]; 			/* slot1 m_iClip */
int ig_slots0_upgrade_bit[MAXPLAYERS+1]; 	/* slot0 m_upgradeBitVec */
int ig_slots0_upgraded_ammo[MAXPLAYERS+1]; 	/* slot0 m_nUpgradedPrimaryAmmoLoaded */
int ig_slots0_skin[MAXPLAYERS+1]; 			/* slot0 m_nSkin */
int ig_slots1_skin[MAXPLAYERS+1]; 			/* slot1 m_nSkin */
int ig_slots0_ammo[MAXPLAYERS+1]; 			/* slot0 ammo */
//bool g_bMapGiven[MAXPLAYERS+1];				/* client is already stored */
//bool g_bThroughMap[MAXPLAYERS+1];				/* client is recorded to save */
bool g_bSlot1_IsMelee[MAXPLAYERS+1];		/* slot1 is melee */

enum Enum_Health
{
	iHealth,
	iHealthTemp,
	iHealthTime,
	iReviveCount,
	iGoingToDie,
	iThirdStrike,
	iHealthMAX,
	
}
int 	g_iHealthInfo[MAXPLAYERS+1][view_as<int>(iHealthMAX)]; 	//client health
int 	g_iProp[MAXPLAYERS+1]; 									//client character index
char 	g_sModelInfo[MAXPLAYERS+1][64]; 						//client character model

bool 
	//g_bGiveWeaponBlock, 
	//g_bRoundStarted,
	g_bMapTransition,
	g_bOldClientThroughMap[MAXPLAYERS+1],
	g_bOldClientGiven[MAXPLAYERS+1];

int 
	//g_iCountDownTime,	
	g_iOffsetAmmo, 
	g_iPrimaryAmmoType;

//Handle 
//	PlayerLeftStartTimer, 
//	CountDownTime;

int g_iReviveTempHealth;

static char g_sMeleeClass[16][32];
static int g_iMeleeClassCount;

int
	g_iOff_m_hHiddenWeapon;

Handle 
	g_hCheckPlayerTimer[MAXPLAYERS+1];

public void OnPluginStart()
{
	if(g_bL4D2Version)
	{
		GameData hGameData = new GameData(GAMEDATA);
		if (!hGameData)
			SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);

		g_iOff_m_hHiddenWeapon = hGameData.GetOffset("CTerrorPlayer::OnIncapacitatedAsSurvivor::m_hHiddenWeapon");
		if (g_iOff_m_hHiddenWeapon == -1)
			SetFailState("Failed to find offset: CTerrorPlayer::OnIncapacitatedAsSurvivor::m_hHiddenWeapon");
	
		delete hGameData;
	}

	g_iOffsetAmmo = FindSendPropInfo("CTerrorPlayer", "m_iAmmo");
	g_iPrimaryAmmoType = FindSendPropInfo("CBaseCombatWeapon", "m_iPrimaryAmmoType");

	g_hCvarReviveHealth = FindConVar("survivor_revive_health");
	g_hSurvivorMaxInc = FindConVar("survivor_max_incapacitated_count");

	g_hFullHealth = 	CreateConVar("l4d2_ty_saveweapons_health", 				"0", "If 1, restore 100 full health when end of chapter.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	//g_hGameTimeBlock = 	CreateConVar("l4d2_ty_saveweapons_game_seconds_block", "60", "Do not restore weapons and health after survivors have left start safe area for at least x seconds. (0=Always restore)", FCVAR_NOTIFY, true, 0.0);
	g_hSaveBot = 		CreateConVar("l4d2_ty_saveweapons_save_bot", 			"1", "If 1, save weapons and health for bots as well.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSaveHealth = 	CreateConVar("l4d2_ty_saveweapons_save_health",			"1", "If 1, save health and restore. (can save >100 hp)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSaveCharacter = 	CreateConVar("l4d2_ty_saveweapons_save_character",		"0", "If 1, save character model and restore.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig(true,	"l4d2_ty_saveweapons");
	
	GetCvars();
	g_hCvarReviveHealth.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorMaxInc.AddChangeHook(ConVarChanged_Cvars);
	
	g_hFullHealth.AddChangeHook(ConVarChanged_Cvars);
	//g_hGameTimeBlock.AddChangeHook(ConVarChanged_Cvars);
	g_hSaveBot.AddChangeHook(ConVarChanged_Cvars);
	g_hSaveHealth.AddChangeHook(ConVarChanged_Cvars);
	g_hSaveCharacter.AddChangeHook(ConVarChanged_Cvars);
	
	
	HookEvent("round_start",  			Event_RoundStart,	 	EventHookMode_PostNoCopy);
	HookEvent("player_spawn", 			Event_PlayerSpawn, 		EventHookMode_PostNoCopy);
	HookEvent("round_end",				Event_RoundEnd,			EventHookMode_PostNoCopy);
	HookEvent("map_transition", 		Event_RoundEnd,			EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", 			Event_RoundEnd,			EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,			EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("map_transition", 		Event_MapTransition, 	EventHookMode_Pre);
	//HookEvent("player_bot_replace", 	Event_BotReplacedPlayer);
	//HookEvent("player_disconnect", 		Event_PlayerDisconnect, EventHookMode_Pre); //換圖不會觸發該事件

	HxCleaningAll();
}

public void OnPluginEnd()
{
	ResetPlugin();
	ResetTimer();
}

public void OnMapStart()
{
	g_bMapTransition = false;

	if (L4D_IsFirstMapInScenario())
	{
		HxCleaningAll();
	}
	
	if(g_bL4D2Version)
	{
		for( int i = 0; i < sizeof(g_sWeaponModels_L4D2); i++ )
		{
			PrecacheModel(g_sWeaponModels_L4D2[i], true);
		}

		for( int i = 0; i < sizeof(survivor_models_L4D2); i++ )
		{
			PrecacheModel(survivor_models_L4D2[i], true);
		}

		CreateTimer(1.0, Timer_GetMeleeTable, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		for( int i = 0; i < sizeof(g_sWeaponModels_L4D1); i++ )
		{
			PrecacheModel(g_sWeaponModels_L4D1[i], true);
		}

		for( int i = 0; i < sizeof survivor_models_L4D1; i++ )
		{
			PrecacheModel(survivor_models_L4D1[i], true);
		}
	}
}

public void OnMapEnd()
{
	ResetPlugin();
	ResetTimer();

	if(g_bMapTransition == false)
	{
		HxCleaningAll();
	}
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

//int g_iGameTimeBlock;
bool g_bFullhealth, g_bSaveBot, g_bSaveHealth, g_bSaveCharacter;
void GetCvars()
{
	g_bFullhealth = g_hFullHealth.BoolValue;
	//g_iGameTimeBlock = g_hGameTimeBlock.IntValue;
	g_bSaveBot = g_hSaveBot.BoolValue;
	g_bSaveHealth = g_hSaveHealth.BoolValue;
	g_bSaveCharacter = g_hSaveCharacter.BoolValue;
	g_iReviveTempHealth = g_hCvarReviveHealth.IntValue;
}

public void OnClientDisconnect(int client)
{
	delete g_hCheckPlayerTimer[client];
}

Action HxTimerRestore(Handle timer, DataPack hPack)
{
	hPack.Reset();
	int index = hPack.ReadCell();
	int client = GetClientOfUserId(hPack.ReadCell());
	int oldindex = hPack.ReadCell();

	g_hCheckPlayerTimer[index] = null;

	//if(g_bGiveWeaponBlock) return Plugin_Continue;
	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2) return Plugin_Continue;
	
	/*if(IsFakeClient(client))
	{
		if(!g_bSaveBot)
			return Plugin_Continue;

		if(HasIdlePlayer(client))
			return Plugin_Continue;
	}*/

	HxGiveC(client, oldindex);

	return Plugin_Continue;
}


int g_iRoundStart, g_iPlayerSpawn;
void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	//g_bRoundStarted = false;
	//for( int i = 1; i <= MaxClients; i++) g_bMapGiven[i] = false;
	//g_bGiveWeaponBlock = false;

	for( int i = 1; i <= MaxClients; i++) 
		g_bOldClientGiven[i] = false;

	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;

	/*int client = GetClientOfUserId(event.GetInt("userid"));

	if(g_bRoundStarted && g_bGiveWeaponBlock == false
		&& client && IsClientInGame(client))
	{
		delete g_hCheckPlayerTimer[client];
		g_hCheckPlayerTimer[client] = CreateTimer(0.5, HxTimerRestore, client);
	}*/
}

Action tmrStart(Handle timer)
{
	ResetPlugin();

	//g_bRoundStarted = true;

	/*if(L4D_GetGameModeType() == GAMEMODE_COOP)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				delete g_hCheckPlayerTimer[i];
				g_hCheckPlayerTimer[i] = CreateTimer(0.5, HxTimerRestore, i);
			}
		}
	}

	delete PlayerLeftStartTimer;
	PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);*/
	
	return Plugin_Continue;
}

/*Action Timer_PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea())
	{
		g_iCountDownTime = g_iGameTimeBlock;
		if(g_iCountDownTime > 0)
		{
			delete CountDownTimer;
			CountDownTimer = CreateTimer(1.0, Timer_CountDown, _, TIMER_REPEAT);
		}

		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue; 
}

Action Timer_CountDown(Handle timer)
{
	if(g_iCountDownTime <= 0) 
	{
		g_bGiveWeaponBlock = true;
		CountDownTimer = null;
		return Plugin_Stop;
	}
	g_iCountDownTime--;
	return Plugin_Continue;
}
*/
void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
	ResetTimer();
	//g_bRoundStarted = false;
}

void Event_MapTransition(Event event, const char[] name, bool dontBroadcast)
{
	if(L4D_GetGameModeType() != GAMEMODE_COOP) return;

	g_bMapTransition = true;
	if (g_bFullhealth)
	{
		for (int client = 1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
			{
				if (L4D_IsPlayerIncapacitated(client))
				{
					if(L4D2_GetInfectedAttacker(client) < 0) //沒被控
					{
						CheatCommand(client, "give", "health");
						SetEntProp(client, Prop_Send, "m_iHealth", 100, 1);
						SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
						SetEntPropFloat(client, Prop_Send, "m_healthBufferTime",  GetGameTime());
					}
					else //被控
					{
						SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);	
						SetEntProp(client, Prop_Send, "m_iHealth", 100, 1);
						SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
						SetEntPropFloat(client, Prop_Send, "m_healthBufferTime",  GetGameTime());
					}
				}
				else
				{
					if(GetEntProp(client, Prop_Send, "m_iHealth") + RoundToNearest( GetEntPropFloat(client, Prop_Send, "m_healthBuffer") ) < 100)
					{
						CheatCommand(client, "give", "health");
						SetEntProp(client, Prop_Send, "m_iHealth", 100, 1);
						SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 0.0);
						SetEntPropFloat(client, Prop_Send, "m_healthBufferTime",  GetGameTime());
					}
				}

				/*SetEntProp(client, Prop_Send, "m_currentReviveCount", 0);
				SetEntProp(client, Prop_Send, "m_isGoingToDie", 0);
				SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 0);
				
				// Disable heart beat sound
				StopSound(client, SNDCHAN_STATIC, "player/heartbeatloop.wav");
				StopSound(client, SNDCHAN_STATIC, "player/heartbeatloop.wav");
				StopSound(client, SNDCHAN_STATIC, "player/heartbeatloop.wav");
				StopSound(client, SNDCHAN_STATIC, "player/heartbeatloop.wav");*/
			}
		}
	}
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client)) continue;

		if (GetClientTeam(client) == 1 && !IsFakeClient(client))
		{
			if (IsClientIdle(client))
			{
				L4D_TakeOverBot(client);
			}
		}
	}

	//CreateTimer(1.5, Timer_Event_MapTransition, _, TIMER_FLAG_NO_MAPCHANGE); //delay is necessary for waiting all afk human players to take over bot or slot 2 throwable weapon is gone
}

/*Action Timer_Event_MapTransition(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		HxCleaning(i);
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			if(IsFakeClient(i) && !g_bSaveBot) continue;
				
			HxSaveC(i);
		}
	}
	
	return Plugin_Continue;
}*/

/*void Event_BotReplacedPlayer(Event event, const char[] name, bool dontBroadcast) 
{
	int bot = GetClientOfUserId(event.GetInt("bot"));
	if(bot && IsClientInGame(bot) && GetClientTeam(bot) == 2 && IsPlayerAlive(bot)) g_bMapGiven[bot] = true;
}*/

/*void Event_PlayerDisconnect(Event event, char[] name, bool bDontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	HxCleaning(client);
}*/

void HxGiveC(int client, int oldindex)
{
	//if(g_bThroughMap[client] == false || g_bMapGiven[client] == true) return;
	//g_bMapGiven[client] = true;

	if(g_bOldClientThroughMap[oldindex] == false || g_bOldClientGiven[oldindex] == true) return;
	g_bOldClientGiven[oldindex] = true;

	// Update model & props
	if(g_bSaveCharacter)
	{
		SetEntProp(client, Prop_Send, "m_survivorCharacter", g_iProp[oldindex]);  
		SetEntityModel(client, g_sModelInfo[oldindex]);
		if (IsFakeClient(client))		// if bot, replace name
		{
			if(g_bL4D2Version)
			{
				for (int i = 0; i < 8; i++)
				{
					if (StrEqual(g_sModelInfo[oldindex], survivor_models_L4D2[i])) SetClientInfo(client, "name", survivor_names_L4D2[i]);
				}
			}
			else
			{
				for (int i = 0; i < 8; i++)
				{
					if (StrEqual(g_sModelInfo[oldindex], survivor_models_L4D1[i])) SetClientInfo(client, "name", survivor_names_L4D1[i]);
				}
			}
		}
	}
	
	// Restore health
	if (g_bSaveHealth)
	{
		if (GetEntProp(client, Prop_Send, "m_isIncapacitated") == 1) SetEntProp(client, Prop_Send, "m_isIncapacitated", 0);	
		
		SetEntProp(client, Prop_Send, "m_iHealth", g_iHealthInfo[oldindex][iHealth], 1);
		SetEntPropFloat(client, Prop_Send, "m_healthBuffer", 1.0*g_iHealthInfo[oldindex][iHealthTemp]);
		SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime() - 1.0*g_iHealthInfo[oldindex][iHealthTime]);
		
		/*
		SetEntProp(client, Prop_Send, "m_currentReviveCount", g_iHealthInfo[oldindex][iReviveCount]);
		SetEntProp(client, Prop_Send, "m_isGoingToDie", g_iHealthInfo[oldindex][iGoingToDie]);
		SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", g_iHealthInfo[oldindex][iThirdStrike]);

		// Disable heart beat sound if not B&W
		if (!g_iHealthInfo[oldindex][iThirdStrike])
		{
			StopSound(client, SNDCHAN_STATIC, "player/heartbeatloop.wav");
			StopSound(client, SNDCHAN_STATIC, "player/heartbeatloop.wav");
			StopSound(client, SNDCHAN_STATIC, "player/heartbeatloop.wav");
			StopSound(client, SNDCHAN_STATIC, "player/heartbeatloop.wav");
		}
		*/

		Heartbeat_SetRevives(client, g_iHealthInfo[oldindex][iReviveCount]);
	}

	// Restore weapons
	/*int active;
	if (sg_slot0[oldindex][0] != '\0' || sg_slot1[oldindex][0] != '\0' || 
		sg_slot2[oldindex][0] != '\0' || sg_slot3[oldindex][0] != '\0' ||
		sg_slot4[oldindex][0] != '\0') 
	{
		HxRemoveWeaponSlot(client, 0);
		HxRemoveWeaponSlot(client, 1);
		HxRemoveWeaponSlot(client, 2);
		HxRemoveWeaponSlot(client, 3);
		HxRemoveWeaponSlot(client, 4);

		active = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		if(active > MaxClients) //拿著汽油桶或可樂瓶之類
		{
			SDKHooks_DropWeapon(client, active);
			active = EntIndexToEntRef(active);
		}
	}*/

	PrintToChatAll("here");
	int weapon;
	bool IsIncap = L4D_IsPlayerIncapacitated(client) && !L4D_IsPlayerHangingFromLedge(client);
	if (sg_slot1[oldindex][0] != '\0' && GetPlayerWeaponSlot(client, 1) <= MaxClients)
	{
		if(g_bL4D2Version)
		{
			if(g_bSlot1_IsMelee[oldindex] == true)
			{
				weapon = HxCreateWeapon("weapon_melee", sg_slot1[oldindex]);
				if (weapon != -1)
				{
					SetEntProp(weapon, Prop_Send, "m_nSkin", ig_slots1_skin[oldindex]);
					if(IsIncap)
					{
						int pistol = CreateEntityByName("weapon_pistol");
						DispatchSpawn(pistol);
						SetEntProp(pistol, Prop_Send, "m_iClip1", 0);
						AcceptEntityInput(pistol, "Use", client);

						SetEntDataEnt2(client, g_iOff_m_hHiddenWeapon, weapon);
					}
					else
					{
						AcceptEntityInput(weapon, "Use", client);
					}
				}
			}
			else
			{
				if (strcmp(sg_slot1[oldindex], "dual_pistol", false) == 0)
				{
					weapon = HxCreateWeapon("weapon_pistol");
					if (weapon != -1)
					{
						AcceptEntityInput(weapon, "Use", client);
						int weapon2 = HxCreateWeapon("weapon_pistol");
						if (weapon2 != -1)
						{
							AcceptEntityInput(weapon2, "Use", client);
							SetEntProp(weapon, Prop_Send, "m_iClip1", ig_slots1_clip[oldindex]);
						}
					}
				}
				else if (strcmp(sg_slot1[oldindex], "weapon_pistol", false) == 0)
				{
					weapon = HxCreateWeapon("weapon_pistol");
					if (weapon != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_iClip1", ig_slots1_clip[oldindex]);
						AcceptEntityInput(weapon, "Use", client);
					}
				}
				else if (strcmp(sg_slot1[oldindex], "weapon_chainsaw", false) == 0)
				{
					weapon = HxCreateWeapon(sg_slot1[oldindex]);
					if (weapon != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_nSkin", ig_slots1_skin[oldindex]);
						SetEntProp(weapon, Prop_Send, "m_iClip1", ig_slots1_clip[oldindex]);
						if(IsIncap)
						{
							int pistol = CreateEntityByName("weapon_pistol");
							DispatchSpawn(pistol);
							SetEntProp(pistol, Prop_Send, "m_iClip1", 0);
							AcceptEntityInput(pistol, "Use", client);

							SetEntDataEnt2(client, g_iOff_m_hHiddenWeapon, weapon);
						}
						else
						{
							AcceptEntityInput(weapon, "Use", client);
						}
					}
				}
				else if (strcmp(sg_slot1[oldindex], "weapon_pistol_magnum", false) == 0)
				{
					weapon = HxCreateWeapon(sg_slot1[oldindex]);
					if (weapon != -1)
					{
						SetEntProp(weapon, Prop_Send, "m_nSkin", ig_slots1_skin[oldindex]);
						SetEntProp(weapon, Prop_Send, "m_iClip1", ig_slots1_clip[oldindex]);
						AcceptEntityInput(weapon, "Use", client);
					}
				}
			}
		}
		else
		{
			if (strcmp(sg_slot1[oldindex], "dual_pistol", false) == 0)
			{
				weapon = HxCreateWeapon("weapon_pistol");
				if (weapon != -1)
				{
					AcceptEntityInput(weapon, "Use", client);
					int weapon2 = HxCreateWeapon("weapon_pistol");
					if (weapon2 != -1)
					{
						AcceptEntityInput(weapon2, "Use", client);
						SetEntProp(weapon, Prop_Send, "m_iClip1", ig_slots1_clip[oldindex]);
					}
				}
			}
			else if (strcmp(sg_slot1[oldindex], "weapon_pistol", false) == 0)
			{
				weapon = HxCreateWeapon("weapon_pistol");
				if (weapon != -1)
				{
					SetEntProp(weapon, Prop_Send, "m_iClip1", ig_slots1_clip[oldindex]);
					AcceptEntityInput(weapon, "Use", client);
				}
			}
		}
	}

	if (sg_slot0[oldindex][0] != '\0' && GetPlayerWeaponSlot(client, 0) == -1)
	{
		weapon = HxCreateWeapon(sg_slot0[oldindex]);
		if (weapon != -1)
		{
			AcceptEntityInput(weapon, "Use", client);
			SetEntProp(weapon, Prop_Send, "m_iClip1", ig_slots0_clip[oldindex]);
			if(g_bL4D2Version)
			{
				SetEntProp(weapon, Prop_Send, "m_upgradeBitVec", ig_slots0_upgrade_bit[oldindex]);
				SetEntProp(weapon, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", ig_slots0_upgraded_ammo[oldindex]);
				SetEntProp(weapon, Prop_Send, "m_nSkin", ig_slots0_skin[oldindex]);
			}
			GetOrSetPlayerAmmo(client, weapon, ig_slots0_ammo[oldindex]);
		}
	}

	if (sg_slot2[oldindex][0] != '\0' && GetPlayerWeaponSlot(client, 2) == -1)
	{
		weapon = HxCreateWeapon(sg_slot2[oldindex]);
		if (weapon != -1) AcceptEntityInput(weapon, "Use", client);
	}
	if (sg_slot3[oldindex][0] != '\0' && GetPlayerWeaponSlot(client, 3) == -1)
	{
		weapon = HxCreateWeapon(sg_slot3[oldindex]);
		if (weapon != -1) AcceptEntityInput(weapon, "Use", client);
	}
	if (sg_slot4[oldindex][0] != '\0' && GetPlayerWeaponSlot(client, 4) == -1)
	{
		weapon = HxCreateWeapon(sg_slot4[oldindex]);
		if (weapon != -1) AcceptEntityInput(weapon, "Use", client);
	}

	//if(EntRefToEntIndex(active) != INVALID_ENT_REFERENCE)
	//{
	//	AcceptEntityInput(active, "Use", client);
	//}

	Call_StartForward(g_hForwardSaveWeaponGive);
	Call_PushCell(client);
	Call_Finish();
}

stock void HxRemoveWeaponSlot(int client, int slot)
{
	int weapon = GetPlayerWeaponSlot(client, slot);

	if (weapon > MaxClients)
	{
		RemovePlayerItem(client, weapon);
		AcceptEntityInput(weapon, "Kill");
	}
}

void HxSaveC(int client)
{
	//g_bThroughMap[client] = true;
	
	int iSlot0;
	int iSlot1;
	int iSlot2;
	int iSlot3;
	int iSlot4;

	if(g_bSaveCharacter)
	{
		// Store model
		GetClientModel(client, g_sModelInfo[client], sizeof(g_sModelInfo[]));
		
		// Store prop
		g_iProp[client] = GetEntProp(client, Prop_Send, "m_survivorCharacter");
	}
	
	if (g_bSaveHealth)
	{
		// Save health
		if (GetEntProp(client, Prop_Send, "m_isIncapacitated") == 1) 
		{
			g_iHealthInfo[client][iHealth]      =  1;	
			g_iHealthInfo[client][iHealthTemp]  =  g_iReviveTempHealth;
			g_iHealthInfo[client][iHealthTime]  =  0;
			//g_iHealthInfo[client][iGoingToDie]  =  1;
			//g_iHealthInfo[client][iReviveCount] =  GetEntProp(client, Prop_Send, "m_currentReviveCount") + 1;
			//g_iHealthInfo[client][iThirdStrike] =  g_iHealthInfo[client][iReviveCount] >= g_iSurvivorMaxInc ? 1 : 0;
			g_iHealthInfo[client][iReviveCount] = Heartbeat_GetRevives(client);
		}
		else 
		{
			g_iHealthInfo[client][iHealth]		= GetEntProp(client, Prop_Send, "m_iHealth");
			g_iHealthInfo[client][iHealthTemp]	= RoundToNearest( GetEntPropFloat(client, Prop_Send, "m_healthBuffer") );
			g_iHealthInfo[client][iHealthTime]  = RoundToNearest( GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime") );
			//g_iHealthInfo[client][iGoingToDie]  = GetEntProp(client, Prop_Send, "m_isGoingToDie");
			//g_iHealthInfo[client][iReviveCount] = GetEntProp(client, Prop_Send, "m_currentReviveCount");
			//g_iHealthInfo[client][iThirdStrike] = GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike");
			g_iHealthInfo[client][iReviveCount] = Heartbeat_GetRevives(client);
		}
	}
	
	iSlot0 = GetPlayerWeaponSlot(client, 0);

	if(g_bL4D2Version)
	{
		if(L4D_IsPlayerIncapacitated(client) && !L4D_IsPlayerHangingFromLedge(client))
		{
			iSlot1 = GetEntDataEnt2(client, g_iOff_m_hHiddenWeapon);
		}

		if(iSlot1 <= MaxClients || !IsValidEntity(iSlot1))
		{
			iSlot1 = GetPlayerWeaponSlot(client, 1);
		}
	}
	else
	{
		iSlot1 = GetPlayerWeaponSlot(client, 1);
	}

	iSlot2 = GetPlayerWeaponSlot(client, 2);
	iSlot3 = GetPlayerWeaponSlot(client, 3);
	iSlot4 = GetPlayerWeaponSlot(client, 4);

	if (iSlot0 > MaxClients)
	{
		GetEntityClassname(iSlot0, sg_slot0[client], sizeof(sg_slot0[]));
		ig_slots0_clip[client] = GetEntProp(iSlot0, Prop_Send, "m_iClip1");
		if(g_bL4D2Version)
		{
			ig_slots0_upgrade_bit[client] = GetEntProp(iSlot0, Prop_Send, "m_upgradeBitVec");
			ig_slots0_upgraded_ammo[client] = GetEntProp(iSlot0, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
			ig_slots0_skin[client] = GetEntProp(iSlot0, Prop_Send, "m_nSkin");
		}
		ig_slots0_ammo[client] = GetOrSetPlayerAmmo(client, iSlot0);
	}
	if (iSlot1 > MaxClients)
	{
		HxGetSlot1(client, iSlot1);
		if(g_bL4D2Version) ig_slots1_skin[client] = GetEntProp(iSlot1, Prop_Send, "m_nSkin");
	}
	if (iSlot2 > MaxClients && GetOrSetPlayerAmmo(client, iSlot2) > 0)
	{
		GetEntityClassname(iSlot2, sg_slot2[client], sizeof(sg_slot2[]));
	}
	if (iSlot3 > MaxClients)
	{
		GetEntityClassname(iSlot3, sg_slot3[client], sizeof(sg_slot3[]));
	}
	if (iSlot4 > MaxClients)
	{
		GetEntityClassname(iSlot4, sg_slot4[client], sizeof(sg_slot4[]));
	}

	Call_StartForward(g_hForwardSaveWeaponSave);
	Call_PushCell(client);
	Call_Finish();
}

void HxCleaning(int client)
{
	ig_slots0_clip[client] = 0;
	ig_slots1_clip[client] = 0;
	ig_slots0_upgrade_bit[client] = 0;
	ig_slots0_upgraded_ammo[client] = 0;
	ig_slots0_skin[client] = 0;
	ig_slots1_skin[client] = 0;
	ig_slots0_ammo[client] = 0;

	sg_slot0[client][0] = '\0';
	sg_slot1[client][0] = '\0';
	sg_slot2[client][0] = '\0';
	sg_slot3[client][0] = '\0';
	sg_slot4[client][0] = '\0';
	
	g_iHealthInfo[client][iHealth] = 100;
	g_iHealthInfo[client][iHealthTemp] = 0;
	g_iHealthInfo[client][iHealthTime] = 0;
	g_iHealthInfo[client][iReviveCount] = 0;
	g_iHealthInfo[client][iGoingToDie] = 0;
	g_iHealthInfo[client][iThirdStrike] = 0;
	
	g_iProp[client] = 0;
	g_sModelInfo[client][0] = '\0';
	
	//g_bThroughMap[client] = false;
	g_bSlot1_IsMelee[client] = false;
	g_bOldClientThroughMap[client] = false;
}

int GetOrSetPlayerAmmo(int client, int iWeapon, int iAmmo = -1)
{
	int offset = GetEntData(iWeapon, g_iPrimaryAmmoType) * 4; // Thanks to "Root" or whoever for this method of not hard-coding offsets: https://github.com/zadroot/AmmoManager/blob/master/scripting/ammo_manager.sp

	if( offset )
	{
		if( iAmmo != -1 ) SetEntData(client, g_iOffsetAmmo + offset, iAmmo);
		else
		{
			int ammo = GetEntData(client, g_iOffsetAmmo + offset);
			return ammo;
		}
	}

	return 0;
}

void HxGetSlot1(int client, int iSlot1)
{
	char wep_name[64]; wep_name[0] = '\0';
	GetEntityClassname(iSlot1, wep_name, sizeof(wep_name));
	if(g_bL4D2Version)
	{
		if (strcmp(wep_name, "weapon_melee") == 0) //support custom melee
		{
			int meleeWeaponId = GetEntProp(iSlot1, Prop_Send, "m_hMeleeWeaponInfo");
			if(meleeWeaponId < 0 && meleeWeaponId > g_iMeleeClassCount) return;

			strcopy(wep_name, sizeof(wep_name), g_sMeleeClass[meleeWeaponId]);
			g_bSlot1_IsMelee[client] = true;
		}
		else
		{
			g_bSlot1_IsMelee[client]= false;
			if (strcmp(wep_name, "weapon_pistol") == 0 && 
			GetEntProp(iSlot1, Prop_Send, "m_isDualWielding") > 0) //dual pistol
			{
				strcopy(wep_name, sizeof(wep_name), "dual_pistol");
				ig_slots1_clip[client] = GetEntProp(iSlot1, Prop_Send, "m_iClip1");
			}
			
			if (strcmp(wep_name, "weapon_chainsaw", false) == 0 
				|| strcmp(wep_name, "weapon_pistol", false) == 0
				|| strcmp(wep_name, "weapon_pistol_magnum", false) == 0)
			{
				ig_slots1_clip[client] = GetEntProp(iSlot1, Prop_Send, "m_iClip1");
			}
		}
	}
	else
	{
		g_bSlot1_IsMelee[client]= false;
		if (GetEntProp(iSlot1, Prop_Send, "m_isDualWielding") > 0) //dual pistol
		{
			strcopy(wep_name, sizeof(wep_name), "dual_pistol");
			ig_slots1_clip[client] = GetEntProp(iSlot1, Prop_Send, "m_iClip1");
		}
	}
	
	if (wep_name[0] != '\0')
	{
		strcopy(sg_slot1[client], sizeof(sg_slot1[]), wep_name);
	}
}

/*
void HxFakeCHEAT(int client, const char[] sCmd, const char[] sArg)
{
	int iFlags = GetCommandFlags(sCmd);
	SetCommandFlags(sCmd, iFlags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", sCmd, sArg);
	SetCommandFlags(sCmd, iFlags);
}
*/

int HxCreateWeapon(const char[] class_name, const char[] melee_name = "")
{
	int weapon = -1;
	if(g_bL4D2Version && strcmp(class_name, "weapon_melee") == 0)
	{
		weapon = CreateEntityByName(class_name);
		if (!RealValidEntity(weapon)) weapon = -1;
		else
		{
			DispatchKeyValue(weapon, "solid", "6");
			DispatchKeyValue(weapon, "melee_script_name", melee_name);
			DispatchSpawn(weapon);
		}
	}
	else
	{
		char wep_str[128];
		strcopy(wep_str, sizeof(wep_str), class_name);
		if (strncmp(wep_str, "weapon_", 7, false) != 0)
		{
			Format(wep_str, sizeof(wep_str), "weapon_%s", wep_str);
		}
		
		weapon = CreateEntityByName(wep_str);
		if (!RealValidEntity(weapon)) weapon = -1;
		else DispatchSpawn(weapon);
	}
	
	return weapon;
}

bool RealValidEntity(int entity)
{
	if (entity <= MaxClients || !IsValidEntity(entity)) return false;
	return true;
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

void ResetTimer()
{
	//delete PlayerLeftStartTimer;
	//delete CountDownTimer;
	for(int i = 1; i <= MaxClients; i++)
	{
		delete g_hCheckPlayerTimer[i];
	}
}

void HxCleaningAll()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		HxCleaning(i);
	}
}

stock bool HasIdlePlayer(int bot)
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

Action Timer_GetMeleeTable(Handle timer)
{
	GetMeleeClasses();
	return Plugin_Continue;
}

//credit spirit12 for auto melee detection
void GetMeleeClasses()
{
	int MeleeStringTable = FindStringTable( "MeleeWeapons" );
	g_iMeleeClassCount = GetStringTableNumStrings( MeleeStringTable );
	
	int len = sizeof(g_sMeleeClass[]);
	
	for( int i = 0; i < g_iMeleeClassCount; i++ )
	{
		ReadStringTable( MeleeStringTable, i, g_sMeleeClass[i], len );
		#if DEBUG
			char sMap[64];
			GetCurrentMap(sMap, sizeof(sMap));
			LogMessage( "[%s] Function::GetMeleeClasses - Getting melee classes: %s", sMap, g_sMeleeClass[i]);
		#endif
	}	
}

bool IsClientIdle(int client)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == 1 && IsPlayerAlive(i))
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

void CheatCommand(int client, const char[] command, const char[] argument1 = "", const char[] argument2 = "")
{
	int userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s", command, argument1, argument2);
	SetCommandFlags(command, flags);
	if(IsClientInGame(client)) SetUserFlagBits(client, userFlags);
}

// other API----

// 保存玩家的資訊(血量 黑白等等)
// 死亡的倖存者也會觸發
// 玩家如果閒置bot, 則會先取代bot (觸發的是玩家)
// 順序: "map_transition" -> L4D_OnPlayerTransitioning -> L4D_OnPlayerItemTransitioning
public void L4D_OnPlayerTransitioning(int client)
{
	HxCleaning(client);

	if(L4D_GetGameModeType() != GAMEMODE_COOP) return;
	if(!g_bMapTransition) return;
	if(!IsPlayerAlive(client)) return;

	if(IsFakeClient(client) && !g_bSaveBot) return;

	HxSaveC(client);
	g_bOldClientThroughMap[client] = true;
}

// 恢復玩家的資訊(血量 黑白等等)
// 順序: "player_spawn" -> L4D_OnPlayerTransitioned -> L4D_OnPlayerItemTransitioned
public void L4D_OnPlayerTransitioned(int client, int oldindex, int olduserid)
{
	if(L4D_GetGameModeType() != GAMEMODE_COOP) return;

	delete g_hCheckPlayerTimer[client];

	DataPack hPack;
	g_hCheckPlayerTimer[client] = CreateDataTimer(0.1, HxTimerRestore, hPack);
	hPack.WriteCell(client);
	hPack.WriteCell(GetClientUserId(client));
	hPack.WriteCell(oldindex);
}