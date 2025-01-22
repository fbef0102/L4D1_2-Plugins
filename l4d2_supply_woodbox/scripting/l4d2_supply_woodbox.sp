#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

public Plugin myinfo = 
{
	name = "[L4D2] CSO Random Supply Boxes drop", 
	author = "Lux & HarryPotter", 
	description = "CSO Random Supply Boxes in l4d2", 
	version = "1.6-2024/3/1", 
	url = "https://steamcommunity.com/profiles/76561198026784913"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

#define DATA_FILE		        "data/l4d2_supply_woodbox.cfg"

#define MAXENTITIES                   2048
#define ENTITY_SAFE_LIMIT 2000 //don't spawn boxes when it's index is above this

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVORS 		2
#define TEAM_INFECTEDS 		3

#define	OXYGENTANK_MODEL		"models/props_equipment/oxygentank01.mdl"
#define	FIREWORKCRATE_MODEL		"models/props_junk/explosive_box001.mdl"
#define	PROPANETANK_MODEL		"models/props_junk/propanecanister001a.mdl"
#define	GASCAN_MODEL			"models/props_junk/gascan001a.mdl"

#define BOX_1	"models/props_junk/wood_crate001a.mdl"
#define BOX_2	"models/props_junk/wood_crate001a_damagedMAX.mdl"
#define BOX_3	"models/props_junk/wood_crate002a.mdl"

#define CVAR_FLAGS			FCVAR_NOTIFY

// Cvar Handles/Variables
ConVar g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarMapOff;
ConVar g_hCvarDropItemMax, g_hCvarDropItemMin, g_hCvarDropItemChance, g_hCvarDropItemTime,
	g_hCvarColor, g_hCvarGlowRange, g_hSupplyBoxMaxTime, g_hSupplyBoxMinTime, g_hSupplyBoxLimit, 
	g_hSupplyBoxLife, g_hSupplyBoxMaxDrop, g_hSupplyBoxMinDrop, g_hSupplyBoxSpawnFinal, g_hSupplyBoxSoundFile,
	g_hBoxType, g_hItemAnnounceType;

// Plugin Variables
ConVar g_hCvarMPGameMode;
int g_iItemMax, g_iItemMin, g_iCvarColor, g_iCvarGlowRange,
	g_iDropItemChance_Weapon, g_iDropItemChance_Melee, g_iDropItemChance_Medic, g_iDropItemChance_Throwable, g_iDropItemChance_Other,
	g_iCvarSupplyBoxMaxTime, g_iCvarSupplyBoxMinTime, g_iCvarSupplyBoxLimit,
	g_iCvarSupplyBoxMaxDrop, g_iCvarSupplyBoxMinDrop, g_iBoxType, g_iItemAnnounceType;
float g_fSupplyBoxLife, g_fCvarDropItemTime;
char g_sDropItemChance[5][4], g_sCvarSupplyBoxSoundFile[PLATFORM_MAX_PATH];
Handle PlayerLeftStartTimer = null, SupplyBoxDropTimer = null;
bool g_bSupplyBoxSpawnFinal, g_bFinaleStarted;
Handle g_ItemDeleteTimer[MAXENTITIES+1];

int 
	g_iMeleeClassCount,
	g_iGlowEnt[MAXENTITIES+1] = {0};

char 
	g_sMeleeClass[16][32];

#define SOUND_DROP1 "npc/chopper_pilot/hospital_intro_heli_12.wav"
#define SOUND_DROP2 "npc/chopper_pilot/hospital_intro_heli_13.wav"
#define SOUND_DROP3 "npc/chopper_pilot/hospital_intro_heli_14.wav"
#define SOUND_DROP4 "npc/chopper_pilot/hospital_intro_heli_15.wav"
#define SOUND_DROP5 "npc/chopper_pilot/hospital_intro_heli_16.wav"

enum struct EWeaponData
{
	char m_sName[64];
	int m_iAmmoMax;
	int m_iAmmoMin;
}

ArrayList
	g_aeWeaponsList,
	g_aMedicList,
	g_aThrowableList,
	g_aOthersList,
	g_alPluginBoxes;

Handle 
	DelayWatchGlow_Timer[MAXPLAYERS+1] ; //prepare to disable player box glow

StringMap 
	g_smVaildItems;

public void OnPluginStart()
{
	LoadTranslations("l4d2_supply_woodbox.phrases");
	g_hCvarAllow =				CreateConVar(	"l4d2_supply_woodbox_allow",			"1",			"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarModes =				CreateConVar(	"l4d2_supply_woodbox_modes",			"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =			CreateConVar(	"l4d2_supply_woodbox_modes_off",		"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =			CreateConVar(	"l4d2_supply_woodbox_modes_tog",		"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hCvarMapOff =				CreateConVar(	"l4d2_supply_woodbox_map_off",			"",				"Turn off the plugin in these maps, separate by commas (no spaces). (0=All maps, Empty = none).", CVAR_FLAGS );
	g_hCvarDropItemMax =		CreateConVar(	"l4d2_supply_woodbox_item_max",			"4",			"Max Items that could drop in woodbox.", CVAR_FLAGS, true, 0.0); 
	g_hCvarDropItemMin =		CreateConVar(	"l4d2_supply_woodbox_item_min",			"2",			"Min Items that could drop in woodbox.", CVAR_FLAGS, true, 0.0); 
	g_hCvarDropItemChance =		CreateConVar(	"l4d2_supply_woodbox_item_chance",		"25,5,40,15,15","Item chance to drop Weapons/Melee/Medic/Throwable/Others, separate by commas (no spaces), the sum of 5 value must be 100", CVAR_FLAGS); 
	g_hCvarDropItemTime = 		CreateConVar(	"l4d2_supply_woodbox_item_life", 		"60", 			"Time in seconds to remove item if no one picks up after it drops from box (0=off)", CVAR_FLAGS, true, 0.0);
	g_hCvarColor =				CreateConVar(	"l4d2_supply_woodbox_color",			"0 145 200",	"The default Supply box color. Three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue. (empty=disable)", CVAR_FLAGS );
	g_hCvarGlowRange =			CreateConVar(	"l4d2_supply_woodbox_glow_range",		"1800",			"The default Supply box glow range.", CVAR_FLAGS );
	g_hSupplyBoxMaxTime =		CreateConVar(	"l4d2_supply_woodbox_time_max",			"80",			"Set the max spawn time for Supply box drop.", CVAR_FLAGS, true, 5.0); 
	g_hSupplyBoxMinTime =		CreateConVar(	"l4d2_supply_woodbox_time_min",			"60",			"Set the min spawn time for Supply box drop.", CVAR_FLAGS, true, 0.0); 
	g_hSupplyBoxMaxDrop =		CreateConVar(	"l4d2_supply_woodbox_drop_max",			"2",			"Max Supply boxes that could drop once.", CVAR_FLAGS, true, 1.0); 
	g_hSupplyBoxMinDrop =		CreateConVar(	"l4d2_supply_woodbox_drop_min",			"1",			"Min Supply boxes that could drop once.", CVAR_FLAGS, true, 0.0);
	g_hSupplyBoxLimit =			CreateConVar(	"l4d2_supply_woodbox_limit",			"6",			"Set the limit for Supply box spawned by the plugin.", CVAR_FLAGS, true, 0.0); 
	g_hSupplyBoxLife =			CreateConVar(	"l4d2_supply_woodbox_box_life",			"180",			"Set the life time for Supply box.", CVAR_FLAGS, true, 0.0); 
	g_hSupplyBoxSoundFile = 	CreateConVar(	"l4d2_supply_woodbox_soundfile", 		"", 			"Supply Box - Drop sound file (relative to to sound/, empty=random helicopter sound, -1: disable)", CVAR_FLAGS);
	g_hSupplyBoxSpawnFinal = 	CreateConVar(	"l4d2_supply_woodbox_drop_final",		"0", 			"If 1, still dorp supply box in final stage rescue", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBoxType = 				CreateConVar(	"l4d2_supply_woodbox_type",				"1", 			"Supply box model type, 1: wood_crate001a, 2: wood_crate001a_damagedMAX, 3: wood_crate002a (0=random)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hItemAnnounceType = 		CreateConVar(	"l4d2_supply_woodbox_announce_type", 	"3", 			"Changes how Supply box hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	AutoExecConfig(true, "l4d2_supply_woodbox");

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarDropItemMax.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDropItemMin.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDropItemChance.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDropItemTime.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarColor.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarGlowRange.AddChangeHook(ConVarChanged_Cvars);
	g_hSupplyBoxMaxTime.AddChangeHook(ConVarChanged_Cvars);
	g_hSupplyBoxMinTime.AddChangeHook(ConVarChanged_Cvars);
	g_hSupplyBoxLimit.AddChangeHook(ConVarChanged_Cvars);
	g_hSupplyBoxMaxDrop.AddChangeHook(ConVarChanged_Cvars);
	g_hSupplyBoxMinDrop.AddChangeHook(ConVarChanged_Cvars);
	g_hSupplyBoxLife.AddChangeHook(ConVarChanged_Cvars);
	g_hSupplyBoxSoundFile.AddChangeHook(ConVarChanged_Cvars);
	g_hSupplyBoxSpawnFinal.AddChangeHook(ConVarChanged_Cvars);
	g_hBoxType.AddChangeHook(ConVarChanged_Cvars);
	g_hItemAnnounceType.AddChangeHook(ConVarChanged_Cvars);

	RegAdminCmd("sm_box", CmdSpawnBox, ADMFLAG_ROOT);
	RegAdminCmd("sm_supplybox", CmdSpawnBox, ADMFLAG_ROOT);

	g_smVaildItems = new StringMap();
	g_smVaildItems.SetValue("weapon_grenade_launcher", true);
	g_smVaildItems.SetValue("weapon_rifle_m60", true);
	g_smVaildItems.SetValue("weapon_defibrillator", true);
	g_smVaildItems.SetValue("weapon_first_aid_kit", true);
	g_smVaildItems.SetValue("weapon_pain_pills", true);
	g_smVaildItems.SetValue("weapon_adrenaline", true);
	g_smVaildItems.SetValue("weapon_upgradepack_incendiary", true);
	g_smVaildItems.SetValue("weapon_upgradepack_explosive", true);
	g_smVaildItems.SetValue("weapon_molotov", true);
	g_smVaildItems.SetValue("weapon_pipe_bomb", true);
	g_smVaildItems.SetValue("weapon_vomitjar", true);
	g_smVaildItems.SetValue("weapon_gascan", true);
	g_smVaildItems.SetValue("weapon_propanetank", true);
	g_smVaildItems.SetValue("weapon_oxygentank", true);
	g_smVaildItems.SetValue("weapon_fireworkcrate", true);
	g_smVaildItems.SetValue("weapon_pistol", true);
	g_smVaildItems.SetValue("weapon_pistol_magnum", true);
	g_smVaildItems.SetValue("weapon_pumpshotgun", true);
	g_smVaildItems.SetValue("weapon_shotgun_chrome", true);
	g_smVaildItems.SetValue("weapon_smg", true);
	g_smVaildItems.SetValue("weapon_smg_silenced", true);
	g_smVaildItems.SetValue("weapon_smg_mp5", true);
	g_smVaildItems.SetValue("weapon_rifle", true);
	g_smVaildItems.SetValue("weapon_rifle_sg552", true);
	g_smVaildItems.SetValue("weapon_rifle_ak47", true);
	g_smVaildItems.SetValue("weapon_rifle_desert", true);
	g_smVaildItems.SetValue("weapon_shotgun_spas", true);
	g_smVaildItems.SetValue("weapon_autoshotgun", true);
	g_smVaildItems.SetValue("weapon_hunting_rifle", true);
	g_smVaildItems.SetValue("weapon_sniper_military", true);
	g_smVaildItems.SetValue("weapon_sniper_scout", true);
	g_smVaildItems.SetValue("weapon_sniper_awp", true);
	g_smVaildItems.SetValue("weapon_chainsaw", true);
	g_smVaildItems.SetValue("weapon_gnome", true);
	g_smVaildItems.SetValue("weapon_cola_bottles", true);

	delete g_alPluginBoxes;
	g_alPluginBoxes = new ArrayList();
}

public void OnPluginEnd()
{
	ResetTimer();
	RemoveAllBox();
}

bool g_bMapStarted, g_bValidMap;
public void OnMapStart()
{
	g_bMapStarted = true;
	g_bValidMap = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	ResetTimer();
}

public void OnClientDisconnect(int client)
{
	delete DelayWatchGlow_Timer[client];
} 

// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnConfigsExecuted()
{
	IsAllowed();

	char sCvar[512];
	g_hCvarMapOff.GetString(sCvar, sizeof(sCvar));

	if( sCvar[0] != '\0' )
	{
		if( strcmp(sCvar, "0") == 0 )
		{
			g_bValidMap = false;
		} else {
			char sMap[64];
			GetCurrentMap(sMap, sizeof(sMap));

			Format(sMap, sizeof(sMap), ",%s,", sMap);
			Format(sCvar, sizeof(sCvar), ",%s,", sCvar);

			if( StrContains(sCvar, sMap, false) != -1 )
				g_bValidMap = false;
		}
	}

	if(g_bValidMap)
	{
		PrecacheSound(SOUND_DROP1);
		PrecacheSound(SOUND_DROP2);
		PrecacheSound(SOUND_DROP3);
		PrecacheSound(SOUND_DROP4);
		PrecacheSound(SOUND_DROP5);

		PrecacheModel(BOX_1, true);
		PrecacheModel(BOX_2, true);
		PrecacheModel(BOX_3, true);
		PrecacheModel("models/props_junk/wood_crate001a_chunk09.mdl", true);
		PrecacheModel("models/props_junk/wood_crate001a_chunk07.mdl", true);
		PrecacheModel("models/props_junk/wood_crate001a_chunk05.mdl", true);
		PrecacheModel("models/props_junk/wood_crate001a_chunk04.mdl", true);
		PrecacheModel("models/props_junk/wood_crate001a_chunk03.mdl", true);
		PrecacheModel("models/props_junk/wood_crate001a_chunk02.mdl", true);
		PrecacheModel("models/props_junk/wood_crate001a_chunk01.mdl", true);
		PrecacheModel(OXYGENTANK_MODEL, true);
		PrecacheModel(FIREWORKCRATE_MODEL, true);
		PrecacheModel(PROPANETANK_MODEL, true);
		PrecacheModel(GASCAN_MODEL, true);
	}


	delete g_aeWeaponsList;
	g_aeWeaponsList = new ArrayList(sizeof(EWeaponData));

	delete g_aMedicList;
	g_aMedicList = new ArrayList(ByteCountToCells(64));

	delete g_aThrowableList;
	g_aThrowableList = new ArrayList(ByteCountToCells(64));

	delete g_aOthersList;
	g_aOthersList = new ArrayList(ByteCountToCells(64));

	delete g_alPluginBoxes;
	g_alPluginBoxes = new ArrayList();

	GetMeleeClasses();
	LoadData();
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iItemMax = g_hCvarDropItemMax.IntValue;
	g_iItemMin = g_hCvarDropItemMin.IntValue;
	char sCvar[512];
	g_hCvarDropItemChance.GetString(sCvar, sizeof(sCvar));
	ExplodeString(sCvar, ",", g_sDropItemChance, sizeof(g_sDropItemChance), sizeof(g_sDropItemChance[]));
	g_iDropItemChance_Weapon = StringToInt(g_sDropItemChance[0]);
	g_iDropItemChance_Melee = g_iDropItemChance_Weapon + StringToInt(g_sDropItemChance[1]);
	g_iDropItemChance_Medic = g_iDropItemChance_Melee + StringToInt(g_sDropItemChance[2]);
	g_iDropItemChance_Throwable = g_iDropItemChance_Medic + StringToInt(g_sDropItemChance[3]);
	g_iDropItemChance_Other = g_iDropItemChance_Throwable + StringToInt(g_sDropItemChance[4]);
	g_fCvarDropItemTime = g_hCvarDropItemTime.FloatValue;
	char sColor[16];
	g_hCvarColor.GetString(sColor, sizeof(sColor));
	g_iCvarColor = GetColor(sColor);
	g_iCvarGlowRange = g_hCvarGlowRange.IntValue;
	g_iCvarSupplyBoxMaxTime = g_hSupplyBoxMaxTime.IntValue;
	g_iCvarSupplyBoxMinTime = g_hSupplyBoxMinTime.IntValue;
	g_iCvarSupplyBoxLimit = g_hSupplyBoxLimit.IntValue;
	g_iCvarSupplyBoxMaxDrop = g_hSupplyBoxMaxDrop.IntValue;
	g_iCvarSupplyBoxMinDrop = g_hSupplyBoxMinDrop.IntValue;
	g_fSupplyBoxLife = g_hSupplyBoxLife.FloatValue;
	g_hSupplyBoxSoundFile.GetString(g_sCvarSupplyBoxSoundFile, sizeof(g_sCvarSupplyBoxSoundFile));
	if (strlen(g_sCvarSupplyBoxSoundFile) > 0 && strcmp(g_sCvarSupplyBoxSoundFile, "-1") != 0) 
	{
		if(g_bMapStarted) PrecacheSound(g_sCvarSupplyBoxSoundFile);
	}
	g_bSupplyBoxSpawnFinal = g_hSupplyBoxSpawnFinal.BoolValue;
	g_iBoxType = g_hBoxType.IntValue;
	g_iItemAnnounceType = g_hItemAnnounceType.IntValue;
}

bool g_bCvarAllow;
void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true && g_bValidMap == true )
	{
		g_bCvarAllow = true;
		HookEvents();

		delete PlayerLeftStartTimer;
		PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
			}
		}
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false || g_bValidMap == false) )
	{
		g_bCvarAllow = false;
		UnhookEvents();
		RemoveAllBox();
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

	if( g_bMapStarted == false )
		return false;

	g_iCurrentMode = 0;

	int entity = CreateEntityByName("info_gamemode");
	if( IsValidEntity(entity) )
	{
		DispatchSpawn(entity);
		HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
		HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
		ActivateEntity(entity);
		AcceptEntityInput(entity, "PostSpawnActivate");
		if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
			RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
	}

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 )
	{
		if( g_iCurrentMode == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentMode) )
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModes.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 4;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 8;
}

Action CmdSpawnBox(int iClient, int iArgs)
{
	if(g_bCvarAllow == false)
	return Plugin_Continue;
	
	if(iClient < 1)
	return Plugin_Continue;
	
	float vPos[3], vAng[3];
	if( !SetTeleportEndPoint(iClient, vPos, vAng) )
	{
		PrintToChat(iClient, "[TS] Cannot place weapon, please try again.");
		return Plugin_Continue;
	}

	SpawnBox(vPos, vAng);

	return Plugin_Handled;
}

// ====================================================================================================
//					EVENTS
// ====================================================================================================
void HookEvents()
{
	HookEvent("round_start", Event_RoundStart);
	HookEvent("survival_round_start", Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //生存模式之下計時開始之時
	HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
	HookEvent("map_transition", Event_RoundEnd,		EventHookMode_PostNoCopy);//戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", Event_RoundEnd,		EventHookMode_PostNoCopy);//戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy);//救援載具離開之時  (沒有觸發round_end)
	HookEvent("finale_start", 			evtFinaleStart, EventHookMode_PostNoCopy); //final starts, some of final maps won't trigger
	HookEvent("finale_radio_start", 	evtFinaleStart, EventHookMode_PostNoCopy); //final starts, all final maps trigger
	HookEvent("gauntlet_finale_start", 	evtFinaleStart, EventHookMode_PostNoCopy); //final starts, only rushing maps trigger (C5M5, C13M4)	
	HookEvent("player_team",            Event_PlayerTeam);
}

void UnhookEvents()
{
	UnhookEvent("round_start", Event_RoundStart);
	UnhookEvent("survival_round_start", Event_SurvivalRoundStart,		EventHookMode_PostNoCopy); //生存模式之下計時開始之時
	UnhookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
	UnhookEvent("map_transition", Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	UnhookEvent("mission_lost", Event_RoundEnd,			EventHookMode_PostNoCopy);//戰役滅團重來該關卡的時候 (之後有觸發round_end)
	UnhookEvent("finale_vehicle_leaving", Event_RoundEnd,	EventHookMode_PostNoCopy);//救援載具離開之時  (沒有觸發round_end)
	UnhookEvent("finale_start", 			evtFinaleStart, EventHookMode_PostNoCopy); //final starts, some of final maps won't trigger
	UnhookEvent("finale_radio_start", 	evtFinaleStart, EventHookMode_PostNoCopy); //final starts, all final maps trigger
	UnhookEvent("gauntlet_finale_start", 	evtFinaleStart, EventHookMode_PostNoCopy); //final starts, only rushing maps trigger (C5M5, C13M4)	
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	g_bFinaleStarted = false;
	delete PlayerLeftStartTimer;
	PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);
}

void Event_SurvivalRoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	GameStart();
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	ResetTimer();
}

void evtFinaleStart(Event event, const char[] name, bool dontBroadcast) 
{
	g_bFinaleStarted = true;
}

void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!client || !IsClientInGame(client) || IsFakeClient(client)) return;
	int team = event.GetInt("team");
	if(team != TEAM_INFECTEDS) return;

	StopAllModelGlow(); // 所有Box停止發光
	delete DelayWatchGlow_Timer[client];
	DelayWatchGlow_Timer[client] = CreateTimer(0.1, Timer_StopGlowTransmit, client, TIMER_FLAG_NO_MAPCHANGE);

	delete DelayWatchGlow_Timer[0];
	DelayWatchGlow_Timer[0] = CreateTimer(0.2, Timer_StartAllGlow);
}

//function
void eBreakBreakable(const char[] Output, int Caller, int Activator, float Delay)
{
	float fPos[3];		
	GetEntPropVector(Caller, Prop_Send, "m_vecOrigin", fPos);
	fPos[2] += 17.5;

	int iDrops = GetRandomInt(g_iItemMin, g_iItemMax);
	int iItemChance, iWeapon, random;
	int iChanceMax = g_iDropItemChance_Other;
	EWeaponData eWeaponData;
	char sWeaponName[64];
	for (int i = 1; i <= iDrops; i++) 
	{
		iItemChance = GetRandomInt(1, iChanceMax);
		if(0 < iItemChance && iItemChance <= g_iDropItemChance_Weapon) 
		{
			if(g_aeWeaponsList.Length == 0) continue;

			random = GetRandomInt(0, g_aeWeaponsList.Length-1);
			g_aeWeaponsList.GetArray(random, eWeaponData);
			iWeapon = SpawnItem(eWeaponData.m_sName, fPos);
			if(iWeapon != -1 && eWeaponData.m_iAmmoMin > 0 && eWeaponData.m_iAmmoMax > 0)
			{
				SetEntProp(iWeapon, Prop_Send, "m_iExtraPrimaryAmmo", GetRandomInt(eWeaponData.m_iAmmoMin, eWeaponData.m_iAmmoMax));
			}
		}
		else if(g_iDropItemChance_Weapon < iItemChance && iItemChance <= g_iDropItemChance_Melee) 
		{
			SpawnItem("weapon_melee", fPos);
		}
		else if(g_iDropItemChance_Melee < iItemChance && iItemChance <= g_iDropItemChance_Medic) 
		{
			if(g_aMedicList.Length == 0) continue;

			random = GetRandomInt(0, g_aMedicList.Length-1);
			g_aMedicList.GetString(random, sWeaponName, sizeof(sWeaponName));
			iWeapon = SpawnItem(sWeaponName, fPos);
		}
		else if(g_iDropItemChance_Medic < iItemChance && iItemChance <= g_iDropItemChance_Throwable) 
		{
			if(g_aThrowableList.Length == 0) continue;

			random = GetRandomInt(0, g_aThrowableList.Length-1);
			g_aThrowableList.GetString(random, sWeaponName, sizeof(sWeaponName));
			iWeapon = SpawnItem(sWeaponName, fPos);
		}
		else if(g_iDropItemChance_Throwable < iItemChance && iItemChance <= g_iDropItemChance_Other) 
		{
			if(g_aOthersList.Length == 0) continue;

			random = GetRandomInt(0, g_aOthersList.Length-1);

			g_aOthersList.GetString(random, sWeaponName, sizeof(sWeaponName));

			if(strcmp(sWeaponName, "weapon_oxygentank", false) == 0)
			{
				iWeapon = SpawnItem("prop_physics", fPos, FIREWORKCRATE_MODEL);
			}
			else if(strcmp(sWeaponName, "weapon_fireworkcrate", false) == 0)
			{
				iWeapon = SpawnItem("prop_physics", fPos, FIREWORKCRATE_MODEL);
			}
			else if(strcmp(sWeaponName, "weapon_propanetank", false) == 0)
			{
				iWeapon = SpawnItem("prop_physics", fPos, OXYGENTANK_MODEL);
			}
			else if(strcmp(sWeaponName, "weapon_gascan", false) == 0)
			{
				iWeapon = SpawnItem("prop_physics", fPos, GASCAN_MODEL);
			}
			else
			{
				iWeapon = SpawnItem(sWeaponName, fPos);
			}
		}
	}

	AcceptEntityInput(Caller, "Kill");
	RemoveBoxModelGlow(Caller);

	int find = g_alPluginBoxes.FindValue(EntIndexToEntRef(Caller));
	if (find != -1)
		g_alPluginBoxes.Erase(find);
}

Action Timer_StopGlowTransmit(Handle timer, int client)
{
	DelayWatchGlow_Timer[client] = null;

	return Plugin_Continue;
}

Action Timer_StartAllGlow(Handle timer)
{
	// 不讓玩家看到物件發光之後，物件開始發光");
	StartAllModelGlow();

	DelayWatchGlow_Timer[0] = null;
	return Plugin_Continue;
}

Action Timer_SupplyBoxDrop(Handle hTimer)
{
	if( g_bCvarAllow == false ) {
		SupplyBoxDropTimer = null;
		return Plugin_Stop;
	}

	if(	g_bFinaleStarted && g_bSupplyBoxSpawnFinal == false) {
		SupplyBoxDropTimer = null;
		return Plugin_Stop;
	}

	int anyclient = my_GetRandomClient();
	if(anyclient > 0)
	{
		int DropNum = GetRandomInt(g_iCvarSupplyBoxMinDrop, g_iCvarSupplyBoxMaxDrop);
		bool bDrop = false;
		float vecPos[3];
		int iBoxCount = CountAllSupplyBox();
		//PrintToChatAll("there are %d boxed", iBoxCount);
		for(int i = 1 ; i <= DropNum ; ++i )
		{
			if(iBoxCount > g_iCvarSupplyBoxLimit) break;
			else
			{
				if(L4D_GetRandomPZSpawnPosition(anyclient, 7, 5, vecPos) == true)
				{
					vecPos[2] += 20;
					if(SpawnBox(vecPos) == true){
						iBoxCount++;
						bDrop = true;				
					}
				}
				else
				{
					PrintToServer("[TS] Couldn't find a valid position for supply box in 5 tries");
					continue;
				}
			}
		}
		if(bDrop)
		{
			switch(g_iItemAnnounceType)
			{
				case 0: {/*nothing*/}
				case 1: {
					for (int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i) && (GetClientTeam(i) == TEAM_SURVIVORS || GetClientTeam(i) == TEAM_SPECTATOR))
						{
							PrintToChat(i, "%T", "Supply_Drop", i);
						}
					}
				}
				case 2: {
					for (int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i) && (GetClientTeam(i) == TEAM_SURVIVORS || GetClientTeam(i) == TEAM_SPECTATOR))
						{
							PrintHintText(i, "%T", "Supply_Drop", i);
						}
					}
				}
				case 3: {
					for (int i = 1; i <= MaxClients; i++)
					{
						if(IsClientInGame(i) && (GetClientTeam(i) == TEAM_SURVIVORS || GetClientTeam(i) == TEAM_SPECTATOR))
						{
							PrintCenterText(i, "%T", "Supply_Drop", i);
						}
					}
				}
			}

			if (strcmp(g_sCvarSupplyBoxSoundFile, "-1") != 0)
			{
				if (strlen(g_sCvarSupplyBoxSoundFile) > 0) EmitSoundToAll(g_sCvarSupplyBoxSoundFile, _, SNDCHAN_AUTO, SNDLEVEL_CONVO, _, SNDVOL_NORMAL, _, _, _, _, _, _ );
				else {
					int random = GetRandomInt(1, 5);
					switch(random)
					{
						case 1: EmitSoundToAll(SOUND_DROP1, _, SNDCHAN_AUTO, SNDLEVEL_CONVO, _, SNDVOL_NORMAL, _, _, _, _, _, _ );
						case 2: EmitSoundToAll(SOUND_DROP2, _, SNDCHAN_AUTO, SNDLEVEL_CONVO, _, SNDVOL_NORMAL, _, _, _, _, _, _ );
						case 3: EmitSoundToAll(SOUND_DROP3, _, SNDCHAN_AUTO, SNDLEVEL_CONVO, _, SNDVOL_NORMAL, _, _, _, _, _, _ );
						case 4: EmitSoundToAll(SOUND_DROP4, _, SNDCHAN_AUTO, SNDLEVEL_CONVO, _, SNDVOL_NORMAL, _, _, _, _, _, _ );
						case 5: EmitSoundToAll(SOUND_DROP5, _, SNDCHAN_AUTO, SNDLEVEL_CONVO, _, SNDVOL_NORMAL, _, _, _, _, _, _ );
					}
				}
			}
		}
	}

	int SpawnTime = GetRandomInt(g_iCvarSupplyBoxMinTime, g_iCvarSupplyBoxMaxTime);
	SupplyBoxDropTimer = CreateTimer(float(SpawnTime), Timer_SupplyBoxDrop);

	return Plugin_Continue;
}

bool SpawnBox(float vPos[3], float vAng[3] = NULL_VECTOR)
{
	int iBox = CreateEntityByName("prop_physics");
	if (CheckIfEntitySafe( iBox ) == false)
		return false;
	
	TeleportEntity(iBox, vPos, vAng, NULL_VECTOR);
	
	int box_model = g_iBoxType;
	if (box_model == 0 ) box_model = GetRandomInt(1, 3);
	switch (box_model) {
		case 1: DispatchKeyValue(iBox, "model", BOX_1);
		case 2: DispatchKeyValue(iBox, "model", BOX_2);
		case 3: DispatchKeyValue(iBox, "model", BOX_3);
	}
	
	DispatchSpawn(iBox);
	DispatchKeyValue(iBox, "spawnflags", "256");		// 256="Generate output on +USE", 8196:"Force Server Side"
	DispatchKeyValue(iBox, "solid", "1"); //1: 穿透 (只有倖存者能用子彈打中，特感與小殭屍會穿透), 6: 固體
	DispatchKeyValue(iBox, "targetname", "l4d2_supply_woodbox");
	ActivateEntity(iBox);
	SetEntProp(iBox, Prop_Data, "m_iHealth", 20);
	SDKHook(iBox, SDKHook_UsePost, Box_UsePost);

	if(g_iCvarColor > 0) //enable glow
	{
		CreateBoxModelGlow(iBox, box_model, vPos, vAng);
	}

	HookSingleEntityOutput(iBox, "OnBreak", eBreakBreakable);
	g_alPluginBoxes.Push(EntIndexToEntRef(iBox));

	CreateTimer(g_fSupplyBoxLife, KillBox_Timer, EntIndexToEntRef(iBox), TIMER_FLAG_NO_MAPCHANGE);

	return true;
}

Action KillBox_Timer(Handle timer, int ref)
{
	if(g_fSupplyBoxLife == 0 || !g_bCvarAllow) return Plugin_Continue;

	if(ref && EntRefToEntIndex(ref) != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(ref, "kill"); //remove box
	}

	return Plugin_Continue;
}

int SpawnItem(const char[] sClassname, float fPos[3], const char[] sModel = "")
{
	int entity;
	if(strcmp(sClassname, "prop_physics") == 0)
	{
		entity = CreateEntityByName("prop_physics");
		if (CheckIfEntitySafe( entity ) == false)
			return -1;

		DispatchKeyValue(entity, "solid", "6");
		DispatchKeyValue(entity, "model", sModel);
		SDKHook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(entity, SDKHook_Use, Use);
		CreateTimer(5.0, UnHookEnt, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (strcmp(sClassname, "weapon_melee") == 0)
	{
		entity = CreateEntityByName(sClassname);
		if (CheckIfEntitySafe( entity ) == false)
			return -1;

		DispatchKeyValue(entity, "solid", "6");
		DispatchKeyValue(entity, "melee_script_name", g_sMeleeClass[GetRandomInt(0, g_iMeleeClassCount-1)]);
	}
	else
	{
		entity = CreateEntityByName(sClassname);
		if (CheckIfEntitySafe( entity ) == false)
			return -1;
	}

	TeleportEntity(entity, fPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(entity);
	ActivateEntity(entity);
	
	if(g_fCvarDropItemTime > 0.0) SetTimer_DeleteWeapon(entity);
	
	return entity;
}

void SetTimer_DeleteWeapon(int entity)
{
	if (!IsValidEntityIndex(entity)) return;

	delete g_ItemDeleteTimer[entity];

	DataPack hPack;
	g_ItemDeleteTimer[entity] = CreateDataTimer(g_fCvarDropItemTime, Timer_KillWeapon, hPack);
	hPack.WriteCell(EntIndexToEntRef(entity));
	hPack.WriteCell(entity);
}

Action Timer_KillWeapon(Handle timer, DataPack hPack)
{
	hPack.Reset();
	int entity = EntRefToEntIndex(hPack.ReadCell());
	int index = hPack.ReadCell();

	g_ItemDeleteTimer[index] = null;
	if(!g_bCvarAllow) return Plugin_Continue;

	if(entity == INVALID_ENT_REFERENCE) return Plugin_Continue;
	
	if(IsInUse(entity) == false)
	{
		RemoveEntity(entity);
	}

	return Plugin_Continue;
}

void Box_UsePost(int box, int client, int caller, UseType type, float value)
{
	if(client > 0 && client <= MaxClients 
		&& IsClientInGame(client) 
		&& GetClientTeam(client) == TEAM_SURVIVORS
		&& IsPlayerAlive(client))
	{
		AcceptEntityInput(box, "Break"); //break box
	}
}

Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	return Plugin_Handled;
}

void Use(int entity, int activator, int caller, UseType type, float value)
{
	if(entity < 1 || !IsValidEntity(entity))
		return;
	
	SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(entity, SDKHook_Use, Use);
}

Action UnHookEnt(Handle Timer, any iEntRef)
{
	if(!IsValidEntRef(iEntRef))
		return Plugin_Continue;
	
	int entity = EntRefToEntIndex(iEntRef);
	SDKUnhook(entity, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(entity, SDKHook_Use, Use);

	return Plugin_Continue;
}

bool IsValidEntRef(int iEnt)
{
	return (iEnt && EntRefToEntIndex(iEnt) != INVALID_ENT_REFERENCE);
}
// ====================================================================================================
//					POSITION
// ====================================================================================================
float GetGroundHeight(float vPos[3])
{
	float vAng[3];
	Handle trace = TR_TraceRayFilterEx(vPos, view_as<float>({ 90.0, 0.0, 0.0 }), MASK_ALL, RayType_Infinite, _TraceFilter);
	if( TR_DidHit(trace) )
		TR_GetEndPosition(vAng, trace);

	delete trace;
	return vAng[2];
}

bool SetTeleportEndPoint(int client, float vPos[3], float vAng[3])
{
	GetClientEyePosition(client, vPos);
	GetClientEyeAngles(client, vAng);

	Handle trace = TR_TraceRayFilterEx(vPos, vAng, MASK_SHOT, RayType_Infinite, _TraceFilter);

	if( TR_DidHit(trace) )
	{
		float vNorm[3];
		float degrees = vAng[1];
		TR_GetEndPosition(vPos, trace);
		GetGroundHeight(vPos);
		vPos[2] += 20.0;
		TR_GetPlaneNormal(trace, vNorm);
		GetVectorAngles(vNorm, vAng);
		if( vNorm[2] == 1.0 )
		{
			vAng[0] = 0.0;
			vAng[1] = degrees + 180;
		}
		else
		{
			if( degrees > vAng[1] )
				degrees = vAng[1] - degrees;
			else
				degrees = degrees - vAng[1];
			vAng[0] += 90.0;
			RotateYaw(vAng, degrees + 180);
		}
	}
	else
	{
		delete trace;
		return false;
	}

	delete trace;
	return true;
}

bool _TraceFilter(int entity, int contentsMask)
{
	return entity > MaxClients || !entity;
}

//---------------------------------------------------------
// do a specific rotation on the given angles
//---------------------------------------------------------
void RotateYaw(float angles[3], float degree)
{
	float direction[3], normal[3];
	GetAngleVectors( angles, direction, NULL_VECTOR, normal );

	float sin = Sine( degree * 0.01745328 );	 // Pi/180
	float cos = Cosine( degree * 0.01745328 );
	float a = normal[0] * sin;
	float b = normal[1] * sin;
	float c = normal[2] * sin;
	float x = direction[2] * b + direction[0] * cos - direction[1] * c;
	float y = direction[0] * c + direction[1] * cos - direction[2] * a;
	float z = direction[1] * a + direction[2] * cos - direction[0] * b;
	direction[0] = x;
	direction[1] = y;
	direction[2] = z;

	GetVectorAngles( direction, angles );

	float up[3];
	GetVectorVectors( direction, NULL_VECTOR, up );

	float roll = GetAngleBetweenVectors( up, normal, direction );
	angles[2] += roll;
}

//---------------------------------------------------------
// calculate the angle between 2 vectors
// the direction will be used to determine the sign of angle (right hand rule)
// all of the 3 vectors have to be normalized
//---------------------------------------------------------
float GetAngleBetweenVectors(const float vector1[3], const float vector2[3], const float direction[3])
{
	float vector1_n[3], vector2_n[3], direction_n[3], cross[3];
	NormalizeVector( direction, direction_n );
	NormalizeVector( vector1, vector1_n );
	NormalizeVector( vector2, vector2_n );
	float degree = ArcCosine( GetVectorDotProduct( vector1_n, vector2_n ) ) * 57.29577951;   // 180/Pi
	GetVectorCrossProduct( vector1_n, vector2_n, cross );

	if( GetVectorDotProduct( cross, direction_n ) < 0.0 )
		degree *= -1.0;

	return degree;
}

int GetColor(char[] sTemp)
{
	if( strcmp(sTemp, "") == 0 )
		return 0;

	char sColors[3][4];
	int color = ExplodeString(sTemp, " ", sColors, 3, 4);

	if( color != 3 )
		return 0;

	color = StringToInt(sColors[0]);
	color += 256 * StringToInt(sColors[1]);
	color += 65536 * StringToInt(sColors[2]);

	return color;
}

Action Timer_PlayerLeftStart(Handle Timer)
{
	if(!g_bCvarAllow || g_iCurrentMode == 2 )
	{
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}

	if (L4D_HasAnySurvivorLeftSafeArea()) //生存模式之下 always true
	{
		GameStart();
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue; 
}

void ResetTimer()
{
	delete PlayerLeftStartTimer;
	delete SupplyBoxDropTimer;
	for (int entity = 1; entity <= MAXENTITIES; entity++)
	{
		delete g_ItemDeleteTimer[entity];
	}
}

int my_GetRandomClient()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			iClients[iClientCount++] = i;
		}
	}
	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
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

public void OnEntityDestroyed(int entity)
{
	if (!IsValidEntityIndex(entity))
		return;

	delete g_ItemDeleteTimer[entity];
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
}

void OnWeaponEquipPost(int client, int weapon)
{
	if (client <= 0 || client > MaxClients || !IsClientInGame(client))
		return;

	if (!IsValidEntity(weapon))
		return;

	delete g_ItemDeleteTimer[weapon];
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

bool IsInUse(int entity)
{	
	int client;
	if(HasEntProp(entity, Prop_Data, "m_hOwner"))
	{
		client = GetEntPropEnt(entity, Prop_Data, "m_hOwner");
		if (IsValidClient(client))
			return true;
	}
	
	// if(HasEntProp(entity, Prop_Data, "m_hOwnerEntity"))
	// {
	// 	client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	// 	if (IsValidClient(client))
	// 		return true;
	// }

	for (int i = 1; i <= MaxClients; i++) 
	{
		if (IsValidClient(i) && GetActiveWeapon(i) == entity)
			return true;
	}

	return false;
}

int GetActiveWeapon(int client)
{
	int weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	if (!IsValidEntityIndex(weapon)) 
	{
		return 0;
	}
	
	return weapon;
}

bool IsValidClient(int client) 
{
    if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) return false;      
    return true; 
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
		//LogAcitivity( "Function::GetMeleeClasses - Getting melee classes: %s", g_sMeleeClass[i]);
	}	
}
void GameStart()
{
	int SpawnTime = GetRandomInt(g_iCvarSupplyBoxMinTime, g_iCvarSupplyBoxMaxTime);
	SupplyBoxDropTimer = CreateTimer(float(SpawnTime), Timer_SupplyBoxDrop);
}

int CountAllSupplyBox()
{
	int iBoxCount = 0, box = -1;
	/*static char sTargetName[64];
	while ((box = FindEntityByClassname(box, "prop_physics")) != -1)
	{
		if (!IsValidEntity(box))
			continue;	

		GetEntPropString(box, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));

		if(strcmp(sTargetName, "l4d2_supply_woodbox", false) == 0) 
			iBoxCount ++;
	}*/

	for (int i = 0; i < g_alPluginBoxes.Length; i++)
	{
		box = EntRefToEntIndex(g_alPluginBoxes.Get(i));

		if (box == INVALID_ENT_REFERENCE)
		{
			g_alPluginBoxes.Erase(i);
			i--;
			continue;
		}

		iBoxCount++;
	}

	return iBoxCount;
}

void CreateBoxModelGlow(int iBox, int box_model, float vPos[3], float vAng[3])
{
	// Spawn dynamic prop entity
	int glow = CreateEntityByName("prop_dynamic_override");
	if( !CheckIfEntitySafe(glow) ) return;

	// Delete previous glow first
	RemoveBoxModelGlow(iBox);

	// Set model
	switch (box_model) {
		case 1: DispatchKeyValue(glow, "model", BOX_1);
		case 2: DispatchKeyValue(glow, "model", BOX_2);
		case 3: DispatchKeyValue(glow, "model", BOX_3);
	}
	DispatchSpawn(glow);

	TeleportEntity(glow, vPos, vAng, NULL_VECTOR);

	// no collision
	SetEntProp(glow, Prop_Send, "m_CollisionGroup", 0);
	SetEntProp(glow, Prop_Send, "m_nSolidType", 0);

	// Set outline glow color
	SetEntProp(glow, Prop_Send, "m_iGlowType", 3);
	SetEntProp(glow, Prop_Send, "m_nGlowRange", g_iCvarGlowRange);
	SetEntProp(glow, Prop_Send, "m_glowColorOverride", g_iCvarColor);

	if(DelayWatchGlow_Timer[0] != null)
	{
		AcceptEntityInput(glow, "StopGlowing");
	}
	else
	{
		AcceptEntityInput(glow, "StartGlowing");
	}

	// Set model invisible
	SetEntityRenderMode(glow, RENDER_TRANSCOLOR);
	SetEntityRenderColor(glow, 0, 0, 0, 0);

	// Set model attach to item, and always synchronize
	SetVariantString("!activator");
	AcceptEntityInput(glow, "SetParent", iBox);
	///////發光物件完成//////////

	//model 只能給誰看?
	SDKHook(glow, SDKHook_SetTransmit, Hook_SetTransmit);

	g_iGlowEnt[iBox] = EntIndexToEntRef(glow);
}

void RemoveBoxModelGlow(int iBox)
{
	int glowentity = g_iGlowEnt[iBox];
	g_iGlowEnt[iBox] = 0;

	if (IsValidEntRef(glowentity))
		RemoveEntity(glowentity);
}

void RemoveAllBox()
{
	int box;

	for (int i = 0; i < g_alPluginBoxes.Length; i++)
	{
		box = EntRefToEntIndex(g_alPluginBoxes.Get(i));

		if (box == INVALID_ENT_REFERENCE)
			continue;

		RemoveEntity(box);
	}

	delete g_alPluginBoxes;
	g_alPluginBoxes = new ArrayList();
}

void StopAllModelGlow()
{
	int box, glow;

	for (int i = 0; i < g_alPluginBoxes.Length; i++)
	{
		box = EntRefToEntIndex(g_alPluginBoxes.Get(i));

		if (box == INVALID_ENT_REFERENCE)
		{
			g_alPluginBoxes.Erase(i);
			i--;
			continue;
		}

		glow = g_iGlowEnt[box];
		if( IsValidEntRef(glow) )
		{
			AcceptEntityInput(glow, "StopGlowing");
		}
	}
}

void StartAllModelGlow()
{
	int box, glow;

	for (int i = 0; i < g_alPluginBoxes.Length; i++)
	{
		box = EntRefToEntIndex(g_alPluginBoxes.Get(i));

		if (box == INVALID_ENT_REFERENCE)
		{
			g_alPluginBoxes.Erase(i);
			i--;
			continue;
		}

		glow = g_iGlowEnt[box];
		if( IsValidEntRef(glow) )
		{
			AcceptEntityInput(glow, "StartGlowing");
		}
	}
}

Action Hook_SetTransmit(int entity, int client)
{
	if(DelayWatchGlow_Timer[client] != null) return Plugin_Continue;

	if( GetClientTeam(client) == TEAM_INFECTEDS) return Plugin_Handled;

	return Plugin_Continue;
}

// Config-------------------------------

void LoadData()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), DATA_FILE);
	if( !FileExists(sPath) )
	{
		SetFailState("File Not Found: %s", sPath);
		return;
	}

	// Load config
	KeyValues hData = new KeyValues("l4d2_supply_woodbox");
	if (!hData.ImportFromFile(sPath)) {
		SetFailState("File Format Not Correct: %s", sPath);
		delete hData;
	}

	int num;
	char sNum[4], sName[64];
	if(hData.JumpToKey("Weapons"))
	{
		num = hData.GetNum("num", 0);
		for(int i = 1; i <= num; i++)
		{
			IntToString(i, sNum, sizeof(sNum));
			if(hData.JumpToKey(sNum))
			{
				EWeaponData eWeaponData;
				hData.GetString("name", eWeaponData.m_sName, sizeof(eWeaponData.m_sName), "");
				eWeaponData.m_iAmmoMax = hData.GetNum("ammo_max", 0);
				eWeaponData.m_iAmmoMin = hData.GetNum("ammo_min", 0);

				if(g_smVaildItems.ContainsKey(eWeaponData.m_sName) == false)
				{
					LogError("%s is not a valid weapon, please check data file 'data/l4d2_gifts.cfg' \"weapons\" #%d", eWeaponData.m_sName, i);
				}
				else
				{
					g_aeWeaponsList.PushArray(eWeaponData);
				}

				hData.GoBack();	
			}
		}

		hData.GoBack();	
	}

	if(hData.JumpToKey("Medic"))
	{
		num = hData.GetNum("num", 0);
		for(int i = 1; i <= num; i++)
		{
			IntToString(i, sNum, sizeof(sNum));
			if(hData.JumpToKey(sNum))
			{
				hData.GetString("name", sName, sizeof(sName), "");

				if(g_smVaildItems.ContainsKey(sName) == false)
				{
					LogError("%s is not a valid item, please check data file 'data/l4d2_gifts.cfg' \"Medic\" #%d", sName, i);
				}
				else
				{
					g_aMedicList.PushString(sName);
				}

				hData.GoBack();	
			}
		}

		hData.GoBack();	
	}

	if(hData.JumpToKey("Throwable"))
	{
		num = hData.GetNum("num", 0);
		for(int i = 1; i <= num; i++)
		{
			IntToString(i, sNum, sizeof(sNum));
			if(hData.JumpToKey(sNum))
			{
				hData.GetString("name", sName, sizeof(sName), "");

				if(g_smVaildItems.ContainsKey(sName) == false)
				{
					LogError("%s is not a valid item, please check data file 'data/l4d2_gifts.cfg' \"Throwable\" #%d", sName, i);
				}
				else
				{
					g_aThrowableList.PushString(sName);
				}

				hData.GoBack();	
			}
		}

		hData.GoBack();	
	}

	if(hData.JumpToKey("Others"))
	{
		num = hData.GetNum("num", 0);
		for(int i = 1; i <= num; i++)
		{
			IntToString(i, sNum, sizeof(sNum));
			if(hData.JumpToKey(sNum))
			{
				hData.GetString("name", sName, sizeof(sName), "");

				if(g_smVaildItems.ContainsKey(sName) == false)
				{
					LogError("%s is not a valid item, please check data file 'data/l4d2_gifts.cfg' \"Others\" #%d", sName, i);
				}
				else
				{
					g_aOthersList.PushString(sName);
				}

				hData.GoBack();	
			}
		}

		hData.GoBack();	
	}

	delete hData;
}