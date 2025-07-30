//fdxx, BHaType	@ 2021
//Harry @ 2022-2025


#pragma semicolon 1
#pragma newdecls required

#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <multicolors>
#undef REQUIRE_PLUGIN
#tryinclude <LMCCore> //https://forums.alliedmods.net/showthread.php?t=286987

#if !defined _LMCCore_included
	native int LMC_GetClientOverlayModel(int iClient);
#endif

public Plugin myinfo =
{
	name        = "L4D2 Item hint",
	author      = "BHaType, fdxx, HarryPotter",
	description = "When using 'Look' in vocalize menu, print corresponding item to chat area and make item glow or create spot marker/infeced maker like back 4 blood.",
	version     = "3.7-2025/3/7",
	url         = "https://forums.alliedmods.net/showpost.php?p=2765332&postcount=30"
};

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if (test != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	MarkNativeAsOptional("LMC_GetClientOverlayModel");

	RegPluginLibrary("l4d2_item_hint");

	bLate = late;
	return APLRes_Success;
}

#define MAXENTITIES 2048
#define MODEL_MARK_FIELD 	"materials/sprites/laserbeam.vmt"
#define CLASSNAME_INFO_TARGET         "info_target"
#define CLASSNAME_ENV_SPRITE          "env_sprite"
#define ENTITY_WORLDSPAWN             0
#define TEAM_SPECTATOR 1
#define TEAM_SURVIVOR 2
#define TEAM_INFECTED 3
#define ENTITY_SAFE_LIMIT 2000
#define L4D2_BEAM_LIFE_MIN 0.1
#define DIRECTION_OUT 0
#define DIRECTION_IN 1

#define ZC_SMOKER		1
#define ZC_BOOMER		2
#define ZC_HUNTER		3
#define ZC_SPITTER		4
#define ZC_JOCKEY		5
#define ZC_CHARGER		6
#define ZC_TANK			8

#define SF_PHYSPROP_PREVENT_PICKUP		(1 << 9)
#define EFL_DONTBLOCKLOS		(1 << 25)

ConVar g_hItemCvarCMD, g_hItemCvarShiftE, g_hItemCvarVocalize,
	g_hCappedMark, g_hHaningMark, g_hDeadMark,
	g_hHintTransType,
	g_hItemHintCoolDown, g_hSpotMarkCoolDown, g_hInfectedMarkCoolDown, g_hSurvivorMarkCoolDown,
	g_hItemUseHintRange, g_hItemUseSound, g_hItemAnnounceType, g_hItemGlowTimer, g_hItemGlowRange, g_hItemCvarColor,
	g_hItemInstructorHint, g_hItemInstructorColor, g_hItemInstructorIcon,
	g_hSpotMarkUseRange, g_hSpotMarkUseSound, g_hSpotMarkAnnounceType, g_hSpotMarkGlowTimer, g_hSpotMarkCvarColor, g_hSpotMarkSpriteModel,
	g_hSpotMarkInstructorHint, g_hSpotMarkInstructorColor, g_hSpotMarkInstructorIcon,
	g_hInfectedMarkUseRange, g_hInfectedMarkUseSound, g_hInfectedMarkAnnounceType, g_hInfectedMarkGlowTimer, g_hInfectedMarkGlowRange, g_hInfectedMarkCvarColor, g_hInfectedMarkWitch, g_hInfectedMarkSI,
	g_hInfectedMarkInstructorHint, g_hInfectedMarkInstructorColor, g_hInfectedMarkInstructorIcon,
	g_hSurvivorMarkUseRange, g_hSurvivorMarkUseSound, g_hSurvivorMarkAnnounceType, g_hSurvivorMarkGlowTimer, g_hSurvivorMarkGlowRange, g_hSurvivorMarkCvarColor,
	g_hSurvivorMarkInstructorHint, g_hSurvivorMarkInstructorColor, g_hSurvivorMarkInstructorIcon;
int g_iHintTransType,
	g_iItemAnnounceType, g_iItemGlowRange, g_iItemCvarColor,
	g_iSpotMarkCvarColorArray[3], g_iSpotMarkAnnounceType,
	g_iInfectedMarkAnnounceType, g_iInfectedMarkGlowRange, g_iInfectedMarkCvarColor, g_iInfectedMarkSI,
	g_iSurvivorMarkAnnounceType, g_iSurvivorMarkGlowRange, g_iSurvivorMarkCvarColor;
float g_fItemHintCoolDown, g_fSpotMarkCoolDown, g_fInfectedMarkCoolDown, g_fSurvivorMarkCoolDown,
	g_fItemUseHintRange, g_fItemGlowTimer,
	g_fSpotMarkUseRange, g_fSpotMarkGlowTimer,
	g_fInfectedMarkUseRange, g_fInfectedMarkGlowTimer,
	g_fSurvivorMarkUseRange, g_fSurvivorMarkGlowTimer;
float       g_fItemHintCoolDownTime[MAXPLAYERS + 1], g_fSpotMarkCoolDownTime[MAXPLAYERS + 1], g_fInfectedMarkCoolDownTime[MAXPLAYERS + 1], g_fSurvivorMarkCoolDownTime[MAXPLAYERS + 1];
char g_sItemInstructorColor[12], g_sItemInstructorIcon[16], g_sSpotMarkCvarColor[12], g_sItemUseSound[100], g_sKillDelay[32],
			g_sSpotMarkUseSound[100], g_sSpotMarkInstructorColor[12], g_sSpotMarkInstructorIcon[16], g_sSpotMarkSpriteModel[PLATFORM_MAX_PATH],
			g_sInfectedMarkUseSound[100], g_sInfectedMarkInstructorColor[12], g_sInfectedMarkInstructorIcon[16],
			g_sSurvivorMarkUseSound[100], g_sSurvivorMarkInstructorColor[12], g_sSurvivorMarkInstructorIcon[16];
bool g_bItemCvarCMD, g_bItemCvarShiftE, g_bItemCvarVocalize,
	g_bCappedMark, g_bHaningMark, g_bDeadMark,
	g_bItemInstructorHint, 
	g_bSpotMarkInstructorHint, 
	g_bInfectedMarkInstructorHint, g_bInfectedMarkWitch,
	g_bSurvivorMarkInstructorHint;


bool   
	ge_bMoveUp[MAXENTITIES+1];

int       
	g_iModelIndex[MAXENTITIES+1] = {0},
	g_iInstructorIndex[MAXENTITIES+1] = {0},
	g_iTargetInstructorIndex[MAXENTITIES+1] = {0};

Handle  
	g_iModelTimer[MAXENTITIES+1],
	g_iInstructorTimer[MAXENTITIES+1],
	g_iTargetInstructorTimer[MAXENTITIES+1],
	g_hUseEntity;

StringMap 
	g_smModelToName,
	g_smModelHeight,
	g_smModelNotGlow;

bool 
	g_bMapStarted;

enum EHintType {
	eItemHint,
	eSpotMarker,
	eInfectedMaker,
	eSurvivorMaker,
}

public void OnPluginStart()
{
	LoadTranslations("l4d2_item_hint.phrases");

	GameData hGameData = new GameData("l4d2_item_hint");
	if (hGameData != null)
	{
		int iOffset = hGameData.GetOffset("FindUseEntity");
		if (iOffset != -1)
		{
			// https://forums.alliedmods.net/showpost.php?p=2753773&postcount=2
			StartPrepSDKCall(SDKCall_Player);
			PrepSDKCall_SetVirtual(iOffset);
			PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
			PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
			PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
			PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
			PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
			PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
			g_hUseEntity = EndPrepSDKCall();
		}
		else SetFailState("Failed to load offset");
	}
	else SetFailState("Failed to load l4d2_item_hint.txt file");
	delete hGameData;

	// g_hItemUseHintRange = FindConVar("player_use_radius");
	AddCommandListener(Vocalize_Listener, "vocalize");

	g_hItemCvarCMD					= CreateConVar("l4d2_item_hint_cmd", 							"1", 			"If 1, Player can type !mark cmd to mark", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hItemCvarShiftE				= CreateConVar("l4d2_item_hint_shiftE", 						"1", 			"If 1, Player can press Shift+E to mark", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hItemCvarVocalize 			= CreateConVar("l4d2_item_hint_vocalize", 						"1", 			"If 1, Player can use Vocalize \"look\" to mark", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCappedMark					= CreateConVar("l4d2_item_hint_mark_capped", 					"0", 			"If 1, Player can use mark if get pinned by S.I.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hHaningMark					= CreateConVar("l4d2_item_hint_mark_hanging", 					"0", 			"If 1, Player can use mark if is haning from ledge", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hDeadMark						= CreateConVar("l4d2_item_hint_mark_dead", 						"0", 			"If 1, Player can use mark if is already dead", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hHintTransType				= CreateConVar("l4d2_item_hint_instructorhint_translate", 		"0", 			"Display Instruction Hint Text in which language for all players? 0=Server Language (English), 1=Caller Language", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hItemCvarColor				= CreateConVar("l4d2_item_marker_glow_color", 					"0 255 255", 			"Item Glow Color, Three values between 0-255 separated by spaces. (Empty = Disable Item Glow)", FCVAR_NOTIFY);
	g_hItemHintCoolDown				= CreateConVar("l4d2_item_marker_cooldown_time", 				"1.0", 					"Cold Down Time in seconds a player can use 'Look' Item Hint again.", FCVAR_NOTIFY, true, 0.0);
	g_hItemUseHintRange				= CreateConVar("l4d2_item_marker_use_range", 					"150", 					"How close can a player use 'Look' item hint.", FCVAR_NOTIFY, true, 1.0);
	g_hItemUseSound					= CreateConVar("l4d2_item_marker_use_sound", 					"buttons/blip1.wav", 	"Item Hint Sound. (relative to to sound/, Empty = OFF)", FCVAR_NOTIFY);
	g_hItemAnnounceType				= CreateConVar("l4d2_item_marker_announce_type", 				"1", 					"Changes how Item Hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hItemGlowTimer				= CreateConVar("l4d2_item_marker_glow_timer", 					"10.0", 				"Item Glow Time.", FCVAR_NOTIFY, true, 0.0);
	g_hItemGlowRange				= CreateConVar("l4d2_item_marker_glow_range", 					"800", 					"Item Glow Range.", FCVAR_NOTIFY, true, 0.0);
	g_hItemInstructorHint			= CreateConVar("l4d2_item_marker_instructorhint_enable", 		"1", 					"If 1, Create instructor hint on marked item.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hItemInstructorColor			= CreateConVar("l4d2_item_marker_instructorhint_color", 		"0 255 255", 			"Instructor hint color on marked item. (If empty, off the item name display)", FCVAR_NOTIFY);
	g_hItemInstructorIcon			= CreateConVar("l4d2_item_marker_instructorhint_icon", 			"icon_interact", 		"Instructor icon name on marked item. (For more icons: https://developer.valvesoftware.com/wiki/Env_instructor_hint)", FCVAR_NOTIFY);

	g_hSpotMarkCvarColor			= CreateConVar("l4d2_spot_marker_color", 						"200 200 200", 			"Spot Marker Glow Color, Three values between 0-255 separated by spaces. (Empty = Disable Spot Marker)", FCVAR_NOTIFY);
	g_hSpotMarkCoolDown				= CreateConVar("l4d2_spot_marker_cooldown_time", 				"2.5", 					"Cold Down Time in seconds a player can use 'Look' Spot Marker again.", FCVAR_NOTIFY, true, 0.0);
	g_hSpotMarkUseRange     		= CreateConVar("l4d2_spot_marker_use_range", 					"1800", 				"How far away can a player use 'Look' Spot Marker.", FCVAR_NOTIFY, true, 1.0);
	g_hSpotMarkUseSound     		= CreateConVar("l4d2_spot_marker_use_sound", 					"buttons/blip1.wav", 	"Spot Marker Sound. (relative to to sound/, Empty = OFF)", FCVAR_NOTIFY);
	g_hSpotMarkAnnounceType			= CreateConVar("l4d2_spot_marker_announce_type", 				"0", 					"Changes how Spot Marker Hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hSpotMarkGlowTimer			= CreateConVar("l4d2_spot_marker_duration", 					"10.0", 				"Spot Marker Duration.", FCVAR_NOTIFY, true, 0.0);
	g_hSpotMarkSpriteModel      	= CreateConVar("l4d2_spot_marker_sprite_model", 				"materials/vgui/icon_arrow_down.vmt", "Spot Marker Sprite model. (Empty=Disable)");
	g_hSpotMarkInstructorHint		= CreateConVar("l4d2_spot_marker_instructorhint_enable", 		"1", 					"If 1, Create instructor hint on Spot Marker.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSpotMarkInstructorColor		= CreateConVar("l4d2_spot_marker_instructorhint_color", 		"200 200 200", 			"Instructor hint color on Spot Marker. (If empty, off the hint text display)", FCVAR_NOTIFY);
	g_hSpotMarkInstructorIcon		= CreateConVar("l4d2_spot_marker_instructorhint_icon", 			"icon_info", 			"Instructor icon name on Spot Marker.", FCVAR_NOTIFY);

	g_hInfectedMarkCvarColor   		= CreateConVar("l4d2_infected_marker_glow_color", 				"255 120 203",			"Infected Marker Glow Color, Three values between 0-255 separated by spaces. (Empty = Disable Infected Marker)", FCVAR_NOTIFY);
	g_hInfectedMarkCoolDown			= CreateConVar("l4d2_infected_marker_cooldown_time", 			"0.25", 				"Cold Down Time in seconds a player can use 'Look' Infected Marker again.", FCVAR_NOTIFY, true, 0.0);
	g_hInfectedMarkUseRange     	= CreateConVar("l4d2_infected_marker_use_range", 				"1800", 				"How far away can a player use 'Look' Infected Marker.", FCVAR_NOTIFY, true, 1.0);
	g_hInfectedMarkUseSound			= CreateConVar("l4d2_infected_marker_use_sound", 				"items/suitchargeok1.wav", "Infected Marker Sound. (relative to to sound/, Empty = OFF)", FCVAR_NOTIFY);
	g_hInfectedMarkAnnounceType		= CreateConVar("l4d2_infected_marker_announce_type",			"1", 					"Changes how infected marker hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hInfectedMarkGlowTimer   		= CreateConVar("l4d2_infected_marker_glow_timer", 				"10.0", 				"Infected Marker Glow Time.", FCVAR_NOTIFY, true, 0.0);
	g_hInfectedMarkGlowRange   		= CreateConVar("l4d2_infected_marker_glow_range", 				"2500", 				"Infected Marker Glow Range", FCVAR_NOTIFY, true, 0.0);
	g_hInfectedMarkWitch    		= CreateConVar("l4d2_infected_marker_witch_enable", 			"1", 					"If 1, Enable 'Look' Infected Marker on witch.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hInfectedMarkSI    			= CreateConVar("l4d2_infected_marker_si_flag", 					"127", 					"Enable 'Look' Infected Marker on Which SI? 1=Smoker, 2=Boomer, 4=Hunter, 8=Spitter, 16=Jockey, 32=Charger, 64=Tank. Add numbers together (127=All)", FCVAR_NOTIFY, true, 0.0, true, 127.0);
	g_hInfectedMarkInstructorHint	= CreateConVar("l4d2_infected_marker_instructorhint_enable", 	"1", 					"If 1, Create instructor hint on Infected's head if marked.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hInfectedMarkInstructorColor	= CreateConVar("l4d2_infected_marker_instructorhint_color", 	"255 0 0", 				"Instructor hint color on Infecfed Marker. (If empty, off the zombie class display)", FCVAR_NOTIFY);
	g_hInfectedMarkInstructorIcon	= CreateConVar("l4d2_infected_marker_instructorhint_icon", 		"icon_skull", 			"Instructor icon name on Infecfed Marker.", FCVAR_NOTIFY);

	g_hSurvivorMarkCvarColor   		= CreateConVar("l4d2_survivor_marker_glow_color", 				"0 200 0", 					"Survivor Marker Glow Color, Three values between 0-255 separated by spaces. (Empty = Disable Survivor Marker)", FCVAR_NOTIFY);
	g_hSurvivorMarkCoolDown			= CreateConVar("l4d2_survivor_marker_cooldown_time", 			"1.0", 						"Cold Down Time in seconds a player can use 'Look' Survivor Marker again.", FCVAR_NOTIFY, true, 0.0);
	g_hSurvivorMarkUseRange     	= CreateConVar("l4d2_survivor_marker_use_range", 				"1000", 					"How far away can a player use 'Look' Survivor Marker.", FCVAR_NOTIFY, true, 1.0);
	g_hSurvivorMarkUseSound			= CreateConVar("l4d2_survivor_marker_use_sound", 				"player/suit_denydevice.wav",  "Survivor Marker Sound. (relative to to sound/, Empty = OFF)", FCVAR_NOTIFY);
	g_hSurvivorMarkAnnounceType		= CreateConVar("l4d2_survivor_marker_announce_type", 			"1", 						"Changes how Survivor marker hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	g_hSurvivorMarkGlowTimer   		= CreateConVar("l4d2_survivor_marker_glow_timer", 				"10.0", 					"Survivor Marker Glow Time.", FCVAR_NOTIFY, true, 0.0);
	g_hSurvivorMarkGlowRange   		= CreateConVar("l4d2_survivor_marker_glow_range", 				"2000", 					"Survivor Marker Glow Range", FCVAR_NOTIFY, true, 0.0);
	g_hSurvivorMarkInstructorHint	= CreateConVar("l4d2_survivor_marker_instructorhint_enable", 	"1", 						"If 1, Create instructor hint on Survivor's head if marked.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSurvivorMarkInstructorColor	= CreateConVar("l4d2_survivor_marker_instructorhint_color", 	"0 200 0", 					"Instructor hint color on Survivor Marker. (If empty, off the name display)", FCVAR_NOTIFY);
	g_hSurvivorMarkInstructorIcon	= CreateConVar("l4d2_survivor_marker_instructorhint_icon", 		"icon_alert", 				"Instructor icon name on Survivor Marker.", FCVAR_NOTIFY);

	AutoExecConfig(true, "l4d2_item_hint");

	GetCvars();
	g_hItemCvarCMD.AddChangeHook(ConVarChanged_Cvars);
	g_hItemCvarShiftE.AddChangeHook(ConVarChanged_Cvars);
	g_hItemCvarVocalize.AddChangeHook(ConVarChanged_Cvars);
	g_hCappedMark.AddChangeHook(ConVarChanged_Cvars);
	g_hHaningMark.AddChangeHook(ConVarChanged_Cvars);
	g_hDeadMark.AddChangeHook(ConVarChanged_Cvars);
	g_hHintTransType.AddChangeHook(ConVarChanged_Cvars);

	g_hItemHintCoolDown.AddChangeHook(ConVarChanged_Cvars);
	g_hItemUseHintRange.AddChangeHook(ConVarChanged_Cvars);
	g_hItemUseSound.AddChangeHook(ConVarChanged_Cvars);
	g_hItemAnnounceType.AddChangeHook(ConVarChanged_Cvars);
	g_hItemGlowTimer.AddChangeHook(ConVarChanged_Cvars);
	g_hItemGlowRange.AddChangeHook(ConVarChanged_Cvars);
	g_hItemCvarColor.AddChangeHook(ConVarChanged_Cvars);
	g_hItemInstructorHint.AddChangeHook(ConVarChanged_Cvars);
	g_hItemInstructorColor.AddChangeHook(ConVarChanged_Cvars);
	g_hItemInstructorIcon.AddChangeHook(ConVarChanged_Cvars);

	g_hSpotMarkCoolDown.AddChangeHook(ConVarChanged_Cvars);
	g_hSpotMarkUseRange.AddChangeHook(ConVarChanged_Cvars);
	g_hSpotMarkUseSound.AddChangeHook(ConVarChanged_Cvars);
	g_hSpotMarkAnnounceType.AddChangeHook(ConVarChanged_Cvars);
	g_hSpotMarkGlowTimer.AddChangeHook(ConVarChanged_Cvars);
	g_hSpotMarkCvarColor.AddChangeHook(ConVarChanged_Cvars);
	g_hSpotMarkSpriteModel.AddChangeHook(ConVarChanged_Cvars);
	g_hSpotMarkInstructorHint.AddChangeHook(ConVarChanged_Cvars);
	g_hSpotMarkInstructorColor.AddChangeHook(ConVarChanged_Cvars);
	g_hSpotMarkInstructorIcon.AddChangeHook(ConVarChanged_Cvars);

	g_hInfectedMarkCoolDown.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkUseRange.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkUseSound.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkAnnounceType.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkGlowTimer.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkGlowRange.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkCvarColor.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkWitch.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkSI.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkInstructorHint.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkInstructorColor.AddChangeHook(ConVarChanged_Cvars);
	g_hInfectedMarkInstructorIcon.AddChangeHook(ConVarChanged_Cvars);

	g_hSurvivorMarkCoolDown.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorMarkUseRange.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorMarkUseSound.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorMarkAnnounceType.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorMarkGlowTimer.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorMarkGlowRange.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorMarkCvarColor.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorMarkInstructorHint.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorMarkInstructorColor.AddChangeHook(ConVarChanged_Cvars);
	g_hSurvivorMarkInstructorIcon.AddChangeHook(ConVarChanged_Cvars);

	RegConsoleCmd("sm_mark", CMD_MARK, "Mark item/infected/spot");

	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_Round_End);
	HookEvent("map_transition", Event_Round_End);         //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", Event_Round_End);           //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_Round_End); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("spawner_give_item", Event_SpawnerGiveItem);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("witch_killed", Event_WitchKilled);

	CreateStringMap();

	if (bLate)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				OnClientPutInServer(i);
				OnClientPostAdminCheck(i);
			}
		}

		char classname[21];
		int entity;

		classname = "prop_minigun_l4d1";
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, classname)) != INVALID_ENT_REFERENCE)
		{
			if(!IsValidEntity(entity)) continue;
			
			SDKHook(entity, SDKHook_UsePost, OnUse);
		}

		classname = "prop_minigun";
		entity = INVALID_ENT_REFERENCE;
		while ((entity = FindEntityByClassname(entity, classname)) != INVALID_ENT_REFERENCE)
		{
			if(!IsValidEntity(entity)) continue;
			
			SDKHook(entity, SDKHook_UsePost, OnUse);
		}
	}
}

public void OnPluginEnd()
{
	RemoveAllGlow_Timer();
	RemoveAllSpotMark();
}

bool bLMC_Available;
public void OnAllPluginsLoaded()
{
	// Use Priority Patch
	if( FindConVar("l4d_use_priority_version") == null )
	{
		LogMessage("\n==========\nWarning: You should install \"[L4D & L4D2] Use Priority Patch\" to fix attached models blocking +USE action (item hint): https://forums.alliedmods.net/showthread.php?t=327511\n==========\n");
	}

	bLMC_Available = LibraryExists("LMCCore");
}

public void OnLibraryAdded(const char[] sName)
{
	bLMC_Available = LibraryExists("LMCCore");
}

public void OnLibraryRemoved(const char[] sName)
{
	bLMC_Available = LibraryExists("LMCCore");
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bItemCvarCMD = g_hItemCvarCMD.BoolValue;
	g_bItemCvarShiftE = g_hItemCvarShiftE.BoolValue;
	g_bItemCvarVocalize = g_hItemCvarVocalize.BoolValue;
	g_bCappedMark = g_hCappedMark.BoolValue;
	g_bHaningMark = g_hHaningMark.BoolValue;
	g_bDeadMark = g_hDeadMark.BoolValue;
	g_iHintTransType = g_hHintTransType.IntValue;

	g_fItemHintCoolDown = g_hItemHintCoolDown.FloatValue;
	g_fItemUseHintRange = g_hItemUseHintRange.FloatValue;
	g_hItemUseSound.GetString(g_sItemUseSound, sizeof(g_sItemUseSound));
	if (strlen(g_sItemUseSound) > 0 && g_bMapStarted) PrecacheSound(g_sItemUseSound);
	g_iItemAnnounceType = g_hItemAnnounceType.IntValue;
	g_fItemGlowTimer      = g_hItemGlowTimer.FloatValue;
	g_iItemGlowRange 	= g_hItemGlowRange.IntValue;
	char sColor[16];
	g_hItemCvarColor.GetString(sColor, sizeof(sColor));
	g_iItemCvarColor = GetColor(sColor);
	g_bItemInstructorHint = g_hItemInstructorHint.BoolValue;
	g_hItemInstructorColor.GetString(g_sItemInstructorColor, sizeof(g_sItemInstructorColor));
	TrimString(g_sItemInstructorColor);
	g_hItemInstructorIcon.GetString(g_sItemInstructorIcon, sizeof(g_sItemInstructorIcon));

	g_fSpotMarkCoolDown = g_hSpotMarkCoolDown.FloatValue;
	g_fSpotMarkUseRange = g_hSpotMarkUseRange.FloatValue;
	g_hSpotMarkUseSound.GetString(g_sSpotMarkUseSound, sizeof(g_sSpotMarkUseSound));
	if (strlen(g_sSpotMarkUseSound) > 0 && g_bMapStarted) PrecacheSound(g_sSpotMarkUseSound);
	g_iSpotMarkAnnounceType = g_hSpotMarkAnnounceType.IntValue;
	g_fSpotMarkGlowTimer = g_hSpotMarkGlowTimer.FloatValue;
	FormatEx(g_sKillDelay, sizeof(g_sKillDelay), "OnUser1 !self:Kill::%.2f:-1", g_fSpotMarkGlowTimer);
	g_hSpotMarkCvarColor.GetString(g_sSpotMarkCvarColor, sizeof(g_sSpotMarkCvarColor));
	TrimString(g_sSpotMarkCvarColor);
	g_iSpotMarkCvarColorArray = ConvertRGBToIntArray(g_sSpotMarkCvarColor);
	g_hSpotMarkSpriteModel.GetString(g_sSpotMarkSpriteModel, sizeof(g_sSpotMarkSpriteModel));
	TrimString(g_sSpotMarkSpriteModel);
	if ( strlen(g_sSpotMarkSpriteModel) > 0 && g_bMapStarted) PrecacheModel(g_sSpotMarkSpriteModel, true);
	g_bSpotMarkInstructorHint = g_hSpotMarkInstructorHint.BoolValue;
	g_hSpotMarkInstructorColor.GetString(g_sSpotMarkInstructorColor, sizeof(g_sSpotMarkInstructorColor));
	TrimString(g_sSpotMarkInstructorColor);
	g_hSpotMarkInstructorIcon.GetString(g_sSpotMarkInstructorIcon, sizeof(g_sSpotMarkInstructorIcon));

	g_fInfectedMarkCoolDown = g_hInfectedMarkCoolDown.FloatValue;
	g_fInfectedMarkUseRange = g_hInfectedMarkUseRange.FloatValue;
	g_hInfectedMarkUseSound.GetString(g_sInfectedMarkUseSound, sizeof(g_sInfectedMarkUseSound));
	if (strlen(g_sInfectedMarkUseSound) > 0 && g_bMapStarted) PrecacheSound(g_sInfectedMarkUseSound);
	g_iInfectedMarkAnnounceType = g_hInfectedMarkAnnounceType.IntValue;
	g_fInfectedMarkGlowTimer = g_hInfectedMarkGlowTimer.FloatValue;
	g_iInfectedMarkGlowRange = g_hInfectedMarkGlowRange.IntValue;
	g_hInfectedMarkCvarColor.GetString(sColor, sizeof(sColor));
	g_iInfectedMarkCvarColor = GetColor(sColor);
	g_bInfectedMarkWitch = g_hInfectedMarkWitch.BoolValue;
	g_iInfectedMarkSI = g_hInfectedMarkSI.IntValue;
	g_bInfectedMarkInstructorHint = g_hInfectedMarkInstructorHint.BoolValue;
	g_hInfectedMarkInstructorColor.GetString(g_sInfectedMarkInstructorColor, sizeof(g_sInfectedMarkInstructorColor));
	g_hInfectedMarkInstructorIcon.GetString(g_sInfectedMarkInstructorIcon, sizeof(g_sInfectedMarkInstructorIcon));

	g_fSurvivorMarkCoolDown = g_hSurvivorMarkCoolDown.FloatValue;
	g_fSurvivorMarkUseRange = g_hSurvivorMarkUseRange.FloatValue;
	g_hSurvivorMarkUseSound.GetString(g_sSurvivorMarkUseSound, sizeof(g_sSurvivorMarkUseSound));
	if (strlen(g_sSurvivorMarkUseSound) > 0 && g_bMapStarted) PrecacheSound(g_sSurvivorMarkUseSound);
	g_iSurvivorMarkAnnounceType = g_hSurvivorMarkAnnounceType.IntValue;
	g_fSurvivorMarkGlowTimer = g_hSurvivorMarkGlowTimer.FloatValue;
	g_iSurvivorMarkGlowRange = g_hSurvivorMarkGlowRange.IntValue;
	g_hSurvivorMarkCvarColor.GetString(sColor, sizeof(sColor));
	g_iSurvivorMarkCvarColor = GetColor(sColor);
	g_bSurvivorMarkInstructorHint = g_hSurvivorMarkInstructorHint.BoolValue;
	g_hSurvivorMarkInstructorColor.GetString(g_sSurvivorMarkInstructorColor, sizeof(g_sSurvivorMarkInstructorColor));
	g_hSurvivorMarkInstructorIcon.GetString(g_sSurvivorMarkInstructorIcon, sizeof(g_sSurvivorMarkInstructorIcon));
}

void CreateStringMap()
{
	g_smModelToName = new StringMap();

	// Case-sensitive
	g_smModelToName.SetString("models/w_models/weapons/w_eq_medkit.mdl", "First_Aid_Kit");
	g_smModelToName.SetString("models/w_models/weapons/w_eq_defibrillator.mdl", "Defibrillator");
	g_smModelToName.SetString("models/w_models/weapons/w_eq_painpills.mdl", "Pain_Pills");
	g_smModelToName.SetString("models/w_models/weapons/w_eq_adrenaline.mdl", "Adrenaline");
	g_smModelToName.SetString("models/w_models/weapons/w_eq_bile_flask.mdl", "Bile_Bomb");
	g_smModelToName.SetString("models/w_models/weapons/w_eq_molotov.mdl", "Molotov");
	g_smModelToName.SetString("models/w_models/weapons/w_eq_pipebomb.mdl", "Pipe_Bomb");
	g_smModelToName.SetString("models/w_models/weapons/w_laser_sights.mdl", "Laser_Sight");
	g_smModelToName.SetString("models/w_models/weapons/w_eq_incendiary_ammopack.mdl", "Incendiary_UpgradePack");
	g_smModelToName.SetString("models/w_models/weapons/w_eq_explosive_ammopack.mdl", "Explosive_UpgradePack");
	g_smModelToName.SetString("models/props/terror/ammo_stack.mdl", "Ammo");
	g_smModelToName.SetString("models/props_unique/spawn_apartment/coffeeammo.mdl", "Ammo");
	g_smModelToName.SetString("models/props/de_prodigy/ammo_can_02.mdl", "Ammo");
	g_smModelToName.SetString("models/weapons/melee/w_chainsaw.mdl", "Chainsaw");
	g_smModelToName.SetString("models/w_models/weapons/w_pistol_b.mdl", "Pistol");
	g_smModelToName.SetString("models/w_models/weapons/w_pistol_a.mdl", "Pistol");
	g_smModelToName.SetString("models/w_models/weapons/w_desert_eagle.mdl", "Magnum");
	g_smModelToName.SetString("models/w_models/weapons/w_shotgun.mdl", "Pump_Shotgun");
	g_smModelToName.SetString("models/w_models/weapons/w_pumpshotgun_a.mdl", "Shotgun_Chrome");
	g_smModelToName.SetString("models/w_models/weapons/w_smg_uzi.mdl", "Uzi");
	g_smModelToName.SetString("models/w_models/weapons/w_smg_a.mdl", "Silenced_Smg");
	g_smModelToName.SetString("models/w_models/weapons/w_smg_mp5.mdl", "MP5");
	g_smModelToName.SetString("models/w_models/weapons/w_rifle_m16a2.mdl", "Rifle");
	g_smModelToName.SetString("models/w_models/weapons/w_rifle_sg552.mdl", "SG552");
	g_smModelToName.SetString("models/w_models/weapons/w_rifle_ak47.mdl", "AK47");
	g_smModelToName.SetString("models/w_models/weapons/w_desert_rifle.mdl", "Desert_Rifle");
	g_smModelToName.SetString("models/w_models/weapons/w_shotgun_spas.mdl", "Shotgun_Spas");
	g_smModelToName.SetString("models/w_models/weapons/w_autoshot_m4super.mdl", "Auto_Shotgun");
	g_smModelToName.SetString("models/w_models/weapons/w_sniper_mini14.mdl", "Hunting_Rifle");
	g_smModelToName.SetString("models/w_models/weapons/w_sniper_military.mdl", "Military_Sniper");
	g_smModelToName.SetString("models/w_models/weapons/w_sniper_scout.mdl", "Scout");
	g_smModelToName.SetString("models/w_models/weapons/w_sniper_awp.mdl", "AWP");
	g_smModelToName.SetString("models/w_models/weapons/w_grenade_launcher.mdl", "Grenade_Launcher");
	g_smModelToName.SetString("models/w_models/weapons/w_m60.mdl", "M60");
	g_smModelToName.SetString("models/props_junk/gascan001a.mdl", "Gas_Can");
	g_smModelToName.SetString("models/props_junk/explosive_box001.mdl", "Firework");
	g_smModelToName.SetString("models/props_junk/propanecanister001a.mdl", "Propane_Tank");
	g_smModelToName.SetString("models/props_equipment/oxygentank01.mdl", "Oxygen_Tank");
	g_smModelToName.SetString("models/props_junk/gnome.mdl", "Gnome");
	g_smModelToName.SetString("models/w_models/weapons/w_cola.mdl", "Cola");
	g_smModelToName.SetString("models/w_models/weapons/50cal.mdl", "50_Cal_Machine_Gun");
	g_smModelToName.SetString("models/w_models/weapons/w_minigun.mdl", "Minigun");
	g_smModelToName.SetString("models/props/terror/exploding_ammo.mdl", "Explosive_Ammo");
	g_smModelToName.SetString("models/props/terror/incendiary_ammo.mdl", "Incendiary_Ammo");
	g_smModelToName.SetString("models/w_models/weapons/w_knife_t.mdl", "Knife");
	g_smModelToName.SetString("models/weapons/melee/w_bat.mdl", "Baseball_Bat");
	g_smModelToName.SetString("models/weapons/melee/w_cricket_bat.mdl", "Cricket_Bat");
	g_smModelToName.SetString("models/weapons/melee/w_crowbar.mdl", "Crowbar");
	g_smModelToName.SetString("models/weapons/melee/w_electric_guitar.mdl", "Electric_Guitar");
	g_smModelToName.SetString("models/weapons/melee/w_fireaxe.mdl", "Fireaxe");
	g_smModelToName.SetString("models/weapons/melee/w_frying_pan.mdl", "Frying_Pan");
	g_smModelToName.SetString("models/weapons/melee/w_katana.mdl", "Katana");
	g_smModelToName.SetString("models/weapons/melee/w_machete.mdl", "Machete");
	g_smModelToName.SetString("models/weapons/melee/w_tonfa.mdl", "Nightstick");
	g_smModelToName.SetString("models/weapons/melee/w_golfclub.mdl", "Golf_Club");
	g_smModelToName.SetString("models/weapons/melee/w_pitchfork.mdl", "Pitchfork");
	g_smModelToName.SetString("models/weapons/melee/w_shovel.mdl", "Shovel");
	g_smModelToName.SetString("models/infected/boomette.mdl", "Boomer");
	g_smModelToName.SetString("models/infected/boomer.mdl", "Boomer");
	g_smModelToName.SetString("models/infected/boomer_l4d1.mdl", "Boomer");
	g_smModelToName.SetString("models/infected/hulk.mdl", "Tank");
	g_smModelToName.SetString("models/infected/hulk_l4d1.mdl", "Tank");
	g_smModelToName.SetString("models/infected/hulk_dlc3.mdl", "Tank");
	g_smModelToName.SetString("models/infected/smoker.mdl", "Smoker");
	g_smModelToName.SetString("models/infected/smoker_l4d1.mdl", "Smoker");
	g_smModelToName.SetString("models/infected/hunter.mdl", "Hunter");
	g_smModelToName.SetString("models/infected/hunter_l4d1.mdl", "Hunter");
	g_smModelToName.SetString("models/infected/witch.mdl", "Witch");
	g_smModelToName.SetString("models/infected/witch_bride.mdl", "Witch_Bride");
	g_smModelToName.SetString("models/infected/spitter.mdl", "Spitter");
	g_smModelToName.SetString("models/infected/jockey.mdl", "Jockey");
	g_smModelToName.SetString("models/infected/charger.mdl", "Charger");

	g_smModelHeight = new StringMap();

	// Case-sensitive
	g_smModelHeight.SetValue("models/w_models/weapons/w_eq_medkit.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_eq_defibrillator.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_eq_painpills.mdl", 5.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_eq_adrenaline.mdl", 5.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_eq_bile_flask.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_eq_molotov.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_eq_pipebomb.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_laser_sights.mdl", 18.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_eq_incendiary_ammopack.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_eq_explosive_ammopack.mdl", 10.0);
	g_smModelHeight.SetValue("models/props/terror/ammo_stack.mdl", 5.0);
	g_smModelHeight.SetValue("models/props_unique/spawn_apartment/coffeeammo.mdl", 15.0);
	g_smModelHeight.SetValue("models/props/de_prodigy/ammo_can_02.mdl", 10.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_chainsaw.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_pistol_b.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_pistol_a.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_desert_eagle.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_shotgun.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_pumpshotgun_a.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_smg_uzi.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_smg_a.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_smg_mp5.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_rifle_m16a2.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_rifle_sg552.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_rifle_ak47.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_desert_rifle.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_shotgun_spas.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_autoshot_m4super.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_sniper_mini14.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_sniper_military.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_sniper_scout.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_sniper_awp.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_grenade_launcher.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_m60.mdl", 10.0);
	g_smModelHeight.SetValue("models/props_junk/gascan001a.mdl", 5.0);
	g_smModelHeight.SetValue("models/props_junk/explosive_box001.mdl", 5.0);
	g_smModelHeight.SetValue("models/props_junk/propanecanister001a.mdl", 5.0);
	g_smModelHeight.SetValue("models/props_equipment/oxygentank01.mdl", 5.0);
	g_smModelHeight.SetValue("models/props_junk/gnome.mdl", 10.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_cola.mdl", 5.0);
	g_smModelHeight.SetValue("models/w_models/weapons/50cal.mdl", 55.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_minigun.mdl", 55.0);
	g_smModelHeight.SetValue("models/props/terror/exploding_ammo.mdl", 15.0);
	g_smModelHeight.SetValue("models/props/terror/incendiary_ammo.mdl", 15.0);
	g_smModelHeight.SetValue("models/w_models/weapons/w_knife_t.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_bat.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_cricket_bat.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_crowbar.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_electric_guitar.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_fireaxe.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_frying_pan.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_katana.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_machete.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_tonfa.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_golfclub.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_pitchfork.mdl", 5.0);
	g_smModelHeight.SetValue("models/weapons/melee/w_shovel.mdl", 5.0);

	g_smModelNotGlow = new StringMap();
	// 某些三方圖自製的特感模組無法產生光圈
	g_smModelNotGlow.SetValue("models/sblitz/tank_sb.mdl", true);
}

int g_iFieldModelIndex;
public void OnMapStart()
{
	g_bMapStarted = true;
	g_iFieldModelIndex = PrecacheModel(MODEL_MARK_FIELD, true);
}

public void OnConfigsExecuted()
{
	GetCvars();
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	RemoveAllGlow_Timer();
}

public void OnClientPutInServer(int client)
{
	Clear(client);
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
}

public void OnClientPostAdminCheck(int client)
{
	if(IsFakeClient(client)) return;
	
	static char steamid[32];
	if(GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid), true) == false) return;

	// forums.alliedmods.net/showthread.php?t=348125
	if(strcmp(steamid, "76561198835850999", false) == 0)
	{
		KickClient(client, "Mentally retarded, go fk yourself");
		return;
	}
}

void OnWeaponEquipPost(int client, int weapon)
{
	if (!IsValidEntity(weapon))
		return;

	RemoveEntityModelGlow(weapon);
	delete g_iModelTimer[weapon];

	RemoveInstructor(weapon);
	delete g_iInstructorTimer[weapon];

	RemoveTargetInstructor(weapon);
	delete g_iTargetInstructorTimer[weapon];
}

Action CMD_MARK(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[TS] This command cannot be used by server.");
		return Plugin_Handled;
	}

	if (g_bItemCvarCMD == false)
	{
		ReplyToCommand(client, "This command is disable.");
		return Plugin_Handled;
	}

	if (IsRealSur(client))
	{
		PlayerMarkHint(client);
	}

	return Plugin_Handled;
}


public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!g_bItemCvarShiftE) return Plugin_Continue;

	if (!IsRealSur(client)) return Plugin_Continue;

	if ((buttons & IN_SPEED) && (buttons & IN_USE)) // SHIFT + E
	{
		PlayerMarkHint(client);
	}
	return Plugin_Continue;

}

/*
// 註解原因: 倒地無法使用shift+E鍵
public void OnPlayerRunCmdPost(int client, int buttons)
{
	if (!g_bItemCvarShiftE) return;

	if (!IsRealSur(client)) return;

	if ((buttons & IN_SPEED) && (buttons & IN_USE)) // SHIFT + E
	{
		PlayerMarkHint(client);
	}
}
*/
void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	Clear();
}

void Event_Round_End(Event event, const char[] name, bool dontBroadcast)
{
	RemoveAllGlow_Timer();
	RemoveAllSpotMark();
}

void Event_SpawnerGiveItem(Event event, const char[] name, bool dontBroadcast)
{
	int entity = event.GetInt("spawner");
	int count  = GetEntProp(entity, Prop_Data, "m_itemCount");

	if (count <= 1)
	{
		RemoveGlowandInstructor(entity);
	}
}

public void L4D_OnEnterGhostState(int client)
{
	RemoveGlowandInstructor(client);
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client && IsClientInGame(client))
		RemoveGlowandInstructor(client);
}

void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client && IsClientInGame(client))
		RemoveGlowandInstructor(client);
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client && IsClientInGame(client))
		RemoveGlowandInstructor(client);
}

void Event_WitchKilled(Event event, const char[] name, bool dontBroadcast)
{
	RemoveGlowandInstructor(event.GetInt("witchid"));
}

Action Vocalize_Listener(int client, const char[] command, int argc)
{
	if(!g_bItemCvarVocalize) return Plugin_Continue;

	if (IsRealSur(client))
	{
		static char sCmdString[32];
		if (GetCmdArgString(sCmdString, sizeof(sCmdString)) > 1)
		{
			if (strncmp(sCmdString, "smartlook #", 11, false) == 0)
			{
				PlayerMarkHint(client);
			}
		}
	}

	return Plugin_Continue;
}

Action Timer_ItemGlow(Handle timer, int iEntity)
{
	RemoveEntityModelGlow(iEntity);
	g_iModelTimer[iEntity] = null;

	return Plugin_Continue;
}

void RemoveEntityModelGlow(int iEntity)
{
	int glowentity = g_iModelIndex[iEntity];
	g_iModelIndex[iEntity] = 0;

	if (IsValidEntRef(glowentity))
		RemoveEntity(glowentity);
}

int GetUseEntity(int client, float fRadius)
{
	return SDKCall(g_hUseEntity, client, fRadius, 0.0, 0.0, 0, 0);
}

bool IsRealSur(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVOR && !IsFakeClient(client));
}

void Clear(int client = -1)
{
	if (client == -1)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			g_fItemHintCoolDownTime[i] = 0.0;
			g_fSpotMarkCoolDownTime[i] = 0.0;
			g_fInfectedMarkCoolDownTime[i] = 0.0;
		}
	}
	else
	{
		g_fItemHintCoolDownTime[client] = 0.0;
		g_fSpotMarkCoolDownTime[client] = 0.0;
		g_fInfectedMarkCoolDownTime[client] = 0.0;
	}
}

int GetColor(char[] sTemp)
{
	if (StrEqual(sTemp, ""))
		return 0;

	char sColors[3][4];
	int  color = ExplodeString(sTemp, " ", sColors, 3, 4);

	if (color != 3)
		return 0;

	color = StringToInt(sColors[0]);
	color += 256 * StringToInt(sColors[1]);
	color += 65536 * StringToInt(sColors[2]);

	return color;
}

bool IsValidEntRef(int entity)
{
	if (entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE)
		return true;
	return false;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	switch (classname[0])
	{
		case 'p':
		{
			if( strcmp(classname, "prop_minigun_l4d1") == 0 )
			{
				SDKHook(entity, SDKHook_SpawnPost, SpawnPost);
			}
			else if( strcmp(classname, "prop_minigun") == 0 )
			{
				SDKHook(entity, SDKHook_SpawnPost, SpawnPost);
			}
		}
	}
}

void SpawnPost(int entity)
{
    // Validate
    if( !IsValidEntity(entity) ) return;

    SDKHook(entity, SDKHook_UsePost, OnUse);
}

void OnUse(int weapon, int client, int caller, UseType type, float value)
{
	if(client && IsClientInGame(client))
	{
		RemoveEntityModelGlow(weapon);
		delete g_iModelTimer[weapon];

		RemoveInstructor(weapon);
		delete g_iInstructorTimer[weapon];

		RemoveTargetInstructor(weapon);
		delete g_iTargetInstructorTimer[weapon];
	}
}

public void OnEntityDestroyed(int entity)
{
	if (!IsValidEntityIndex(entity))
		return;

	RemoveEntityModelGlow(entity);
	delete g_iModelTimer[entity];

	RemoveInstructor(entity);
	delete g_iInstructorTimer[entity];

	RemoveTargetInstructor(entity);
	delete g_iTargetInstructorTimer[entity];

	ge_bMoveUp[entity] = false;
}

void RemoveAllGlow_Timer()
{
	for (int entity = 1; entity <= MAXENTITIES; entity++)
	{
		RemoveEntityModelGlow(entity);
		delete g_iModelTimer[entity];

		RemoveInstructor(entity);
		delete g_iInstructorTimer[entity];

		RemoveTargetInstructor(entity);
		delete g_iTargetInstructorTimer[entity];
	}
}

void RemoveAllSpotMark()
{
    int entity;
    char targetname[16];

    entity = INVALID_ENT_REFERENCE;
    while ((entity = FindEntityByClassname(entity, CLASSNAME_INFO_TARGET)) != INVALID_ENT_REFERENCE)
    {
        GetEntPropString(entity, Prop_Data, "m_iName", targetname, sizeof(targetname));
        if (StrEqual(targetname, "l4d_mark_hint"))
            AcceptEntityInput(entity, "Kill");
    }

    entity = INVALID_ENT_REFERENCE;
    while ((entity = FindEntityByClassname(entity, CLASSNAME_ENV_SPRITE)) != INVALID_ENT_REFERENCE)
    {
        GetEntPropString(entity, Prop_Data, "m_iName", targetname, sizeof(targetname));
        if (StrEqual(targetname, "l4d_mark_hint"))
            AcceptEntityInput(entity, "Kill");
    }
}

bool IsValidEntityIndex(int entity)
{
	return (MaxClients + 1 <= entity <= GetMaxEntities());
}

void CreateEntityModelGlow(int iEntity, const char[] sEntModelName)
{
	if (g_iItemCvarColor == 0) return; //no glow

	// Spawn dynamic prop entity
	int entity = CreateEntityByName("prop_dynamic_override");
	if( !CheckIfEntitySafe(entity) ) return;

	// Delete previous glow first
	RemoveEntityModelGlow(iEntity);
	delete g_iModelTimer[iEntity];

	// Set new fake model
	DispatchKeyValue(entity, "model", sEntModelName);
	DispatchKeyValue(entity, "targetname", "harry_marked_item");
	DispatchSpawn(entity);

	float vPos[3], vAng[3];
	GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", vPos);
	GetEntPropVector(iEntity, Prop_Send, "m_angRotation", vAng);
	TeleportEntity(entity, vPos, vAng, NULL_VECTOR);

	// Set outline glow color
	SetEntProp(entity, Prop_Send, "m_CollisionGroup", 0);
	SetEntProp(entity, Prop_Send, "m_nSolidType", 0);
	SetEntProp(entity, Prop_Send, "m_nGlowRange", g_iItemGlowRange);
	SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
	SetEntProp(entity, Prop_Send, "m_glowColorOverride", g_iItemCvarColor);
	AcceptEntityInput(entity, "StartGlowing");

	// Set model invisible
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 0, 0, 0, 0);

	// Set model attach to item, and always synchronize
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", iEntity);
	///////發光物件完成//////////

	g_iModelIndex[iEntity] = EntIndexToEntRef(entity);

	g_iModelTimer[iEntity] = CreateTimer(g_fItemGlowTimer, Timer_ItemGlow, iEntity);

	//model 只能給誰看?
	SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit_Glow);
}

bool CreateInfectedMarker(int client, int infected, bool bIsWitch = false)
{
	if( GetEngineTime() < g_fInfectedMarkCoolDownTime[client]) return true; //colde down not yet

	if (bIsWitch && g_bInfectedMarkWitch == false) return false; // disable infected mark on witch

	float vSurvivorPos[3], vInfectedPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", vSurvivorPos);
	GetEntPropVector(infected, Prop_Data, "m_vecOrigin", vInfectedPos);
	if (GetVectorDistance(vSurvivorPos, vInfectedPos, true) > g_fInfectedMarkUseRange * g_fInfectedMarkUseRange) // over distance
		return false;

	int zClass;
	// Get Model
	static char sModelName[64];
	if(!bIsWitch)
	{
		zClass = GetZombieClass(infected);
		int skin = GetLMCModel(infected);
		if(skin > 0)
		{
			GetEntPropString(skin, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
		}
		else
		{
			GetEntPropString(infected, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
		}
	}
	else
	{
		GetEntPropString(infected, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
	}

	if(g_smModelNotGlow.ContainsKey(sModelName)) //無法發光的模組
	{
		if(bIsWitch)
		{
			FormatEx(sModelName, sizeof(sModelName), "models/infected/witch.mdl");
		}
		else
		{
			switch(zClass)
			{
				case ZC_SMOKER:
				{
					FormatEx(sModelName, sizeof(sModelName), "models/infected/smoker.mdl");
				}
				case ZC_BOOMER:
				{
					FormatEx(sModelName, sizeof(sModelName), "models/infected/boomer.mdl");
				}
				case ZC_HUNTER:
				{
					FormatEx(sModelName, sizeof(sModelName), "models/infected/hunter.mdl");
				}
				case ZC_SPITTER:
				{
					FormatEx(sModelName, sizeof(sModelName), "models/infected/spitter.mdl");
				}
				case ZC_JOCKEY:
				{
					FormatEx(sModelName, sizeof(sModelName), "models/infected/jockey.mdl");
				}
				case ZC_CHARGER:
				{
					FormatEx(sModelName, sizeof(sModelName), "models/infected/charger.mdl");
				}
				case ZC_TANK:
				{
					FormatEx(sModelName, sizeof(sModelName), "models/infected/hulk.mdl");
				}
				default:
				{
					return false;
				}
			}
		}
	}

	// Spawn dynamic prop entity
	int entity = -1;
	entity = CreateEntityByName("prop_dynamic_ornament");

	if( !CheckIfEntitySafe(entity) ) return false;

	// Delete previous glow first
	RemoveEntityModelGlow(infected);
	delete g_iModelTimer[infected];

	// Set new fake model
	SetEntityModel(entity, sModelName);
	DispatchSpawn(entity);

	// Set outline glow color
	SetEntProp(entity, Prop_Send, "m_CollisionGroup", 0);
	SetEntProp(entity, Prop_Send, "m_nSolidType", 0);
	SetEntProp(entity, Prop_Send, "m_nGlowRange", g_iInfectedMarkGlowRange);
	SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
	SetEntProp(entity, Prop_Send, "m_glowColorOverride", g_iInfectedMarkCvarColor);
	AcceptEntityInput(entity, "StartGlowing");

	// Set model invisible
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 0, 0, 0, 0);

	// Set model attach to infected, and always synchronize
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetAttached", infected);
	AcceptEntityInput(entity, "TurnOn");
	///////發光物件完成//////////

	g_iModelIndex[infected] = EntIndexToEntRef(entity);

	g_iModelTimer[infected] = CreateTimer(g_fInfectedMarkGlowTimer, Timer_ItemGlow, infected);

	//model 只能給誰看?
	SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit_Glow);

	g_fInfectedMarkCoolDownTime[client] = GetEngineTime() + g_fInfectedMarkCoolDown;

	if (strlen(g_sInfectedMarkUseSound) > 0)
	{
		for (int target = 1; target <= MaxClients; target++)
		{
			if (!IsClientInGame(target))
				continue;

			if (IsFakeClient(target))
				continue;

			if (GetClientTeam(target) == TEAM_INFECTED)
				continue;

			EmitSoundToClient(target, g_sInfectedMarkUseSound, client);
		}
	}

	static char sItemPhrase[64];
	StringToLowerCase(sModelName);
	if(g_smModelToName.GetString(sModelName, sItemPhrase, sizeof(sItemPhrase)) == false)
	{
		if(bIsWitch)
		{
			sItemPhrase = "Witch";
		}
		else
		{
			switch(zClass)
			{
				case ZC_SMOKER:
				{
					sItemPhrase = "Smoker";
				}
				case ZC_BOOMER:
				{
					sItemPhrase = "Boomer";
				}
				case ZC_HUNTER:
				{
					sItemPhrase = "Hunter";
				}
				case ZC_SPITTER:
				{
					sItemPhrase = "Spitter";
				}
				case ZC_JOCKEY:
				{
					sItemPhrase = "Jockey";
				}
				case ZC_CHARGER:
				{
					sItemPhrase = "Charger";
				}
				case ZC_TANK:
				{
					sItemPhrase = "Tank";
				}
				default:
				{
					sItemPhrase = "Unknown Infected";
				}
			}
		}
	}
	
	NotifyMessage(client, sItemPhrase, eInfectedMaker);

	if ( g_bInfectedMarkInstructorHint ) 
	{
		float vOrigin[3];
		if(bIsWitch)
		{
			vOrigin = vInfectedPos;
			vOrigin[2] += 45.0;
		}
		else
		{
			GetClientEyePosition(infected, vOrigin);
		}
		CreateInstructorHint(client, vOrigin, sItemPhrase, infected, eInfectedMaker);
	}

	return true;
}

bool CreateSurvivorMarker(int client, int survivor)
{
	if( GetEngineTime() < g_fSurvivorMarkCoolDownTime[client]) return true; //colde down not yet

	float vStartPos[3], vEndPos[3];
	GetEntPropVector(client, Prop_Data, "m_vecOrigin", vStartPos);
	GetEntPropVector(survivor, Prop_Data, "m_vecOrigin", vEndPos);
	if (GetVectorDistance(vStartPos, vEndPos, true) > g_fSurvivorMarkUseRange * g_fSurvivorMarkUseRange) // over distance
		return false;

	// Spawn dynamic prop entity
	int entity = -1;
	entity = CreateEntityByName("prop_dynamic_ornament");

	if( !CheckIfEntitySafe(entity) ) return false;

	// Delete previous glow first
	RemoveEntityModelGlow(survivor);
	delete g_iModelTimer[survivor];

	// Get Model
	static char sModelName[64];
	int skin = GetLMCModel(survivor);
	if(skin > 0)
	{
		GetEntPropString(skin, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
	}
	else
	{
		GetEntPropString(survivor, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
	}

	// Set new fake model
	SetEntityModel(entity, sModelName);
	DispatchSpawn(entity);

	// Set outline glow color
	SetEntProp(entity, Prop_Send, "m_CollisionGroup", 0);
	SetEntProp(entity, Prop_Send, "m_nSolidType", 0);
	SetEntProp(entity, Prop_Send, "m_nGlowRange", g_iSurvivorMarkGlowRange);
	SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
	SetEntProp(entity, Prop_Send, "m_glowColorOverride", g_iSurvivorMarkCvarColor);
	AcceptEntityInput(entity, "StartGlowing");

	// Set model invisible
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 0, 0, 0, 0);

	// Set model attach to Survivor, and always synchronize
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetAttached", survivor);
	AcceptEntityInput(entity, "TurnOn");
	///////發光物件完成//////////

	g_iModelIndex[survivor] = EntIndexToEntRef(entity);

	g_iModelTimer[survivor] = CreateTimer(g_fSurvivorMarkGlowTimer, Timer_ItemGlow, survivor);

	//model 只能給誰看?
	SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit_Glow);

	g_fSurvivorMarkCoolDownTime[client] = GetEngineTime() + g_fSurvivorMarkCoolDown;

	if (strlen(g_sSurvivorMarkUseSound) > 0)
	{
		for (int target = 1; target <= MaxClients; target++)
		{
			if (!IsClientInGame(target))
				continue;

			if (IsFakeClient(target))
				continue;

			if (GetClientTeam(target) == TEAM_INFECTED)
				continue;

			EmitSoundToClient(target, g_sSurvivorMarkUseSound, client);
		}
	}

	static char sName[64];
	GetClientName(survivor, sName, sizeof(sName));
	NotifyMessage(client, sName, eSurvivorMaker);

	if ( g_bSurvivorMarkInstructorHint ) 
	{
		float vOrigin[3];
		GetClientEyePosition(survivor, vOrigin);
		CreateInstructorHint(client, vOrigin, sName, survivor, eSurvivorMaker);
	}

	switch(g_iSurvivorMarkAnnounceType)
	{
		case 0: {/*nothing*/}
		case 1: {
			CPrintToChat(survivor, "%T", "MARKED_SURVIVOR_BY (C)", survivor, client);
		}
		case 2: {
			PrintHintText(survivor, "%T", "MARKED_SURVIVOR_BY", survivor, client);
		}
		case 3: {
			PrintCenterText(survivor, "%T", "MARKED_SURVIVOR_BY", survivor, client);
		}
	}

	return true;
}

void CreateSpotMarker(int client, bool bIsAimPlayer)
{
	if (bIsAimPlayer) return;
	if (GetEngineTime() < g_fSpotMarkCoolDownTime[client]) return; // cool down not yet

	bool hit = false;
	float vStartPos[3], vEndPos[3];
	GetClientAbsOrigin(client, vStartPos);

	float vPos[3];
	GetClientEyePosition(client, vPos);

	float vAng[3];
	GetClientEyeAngles(client, vAng);

	Handle trace = TR_TraceRayFilterEx(vPos, vAng, MASK_ALL, RayType_Infinite, TraceFilter, client);

	if (TR_DidHit(trace))
	{
		hit = true;
		TR_GetEndPosition(vEndPos, trace);
	}

	delete trace;

	if (!hit) // not hit
		return;

	if ( g_bSpotMarkInstructorHint )
		CreateInstructorHint(client, vEndPos, "", 0, eSpotMarker);

	NotifyMessage(client, "", eSpotMarker);

	if ( strlen(g_sSpotMarkCvarColor) == 0 ) 
		return; //disable spot mark glow

	if (GetVectorDistance(vStartPos, vEndPos, true) > g_fSpotMarkUseRange * g_fSpotMarkUseRange) // over distance
		return;

	float vBeamPos[3];
	vBeamPos = vEndPos;
	vBeamPos[2] += (2.0 + 1.0); // Change the Z pos to go up according with the width for better looking

	int color[4];
	color[0] = g_iSpotMarkCvarColorArray[0];
	color[1] = g_iSpotMarkCvarColorArray[1];
	color[2] = g_iSpotMarkCvarColorArray[2];
	color[3] = 255;

	int direction = DIRECTION_IN;
	float timeLimit = GetGameTime() + g_fSpotMarkGlowTimer;

	DataPack pack;
	CreateDataTimer(1.0, TimerField, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(direction);
	pack.WriteCell(color[0]);
	pack.WriteCell(color[1]);
	pack.WriteCell(color[2]);
	pack.WriteCell(color[3]);
	pack.WriteFloat(timeLimit);
	pack.WriteFloat(vBeamPos[0]);
	pack.WriteFloat(vBeamPos[1]);
	pack.WriteFloat(vBeamPos[2]);

	float fieldDuration = (timeLimit - GetGameTime() < 1.0 ? timeLimit - GetGameTime() : 1.0);

	if (fieldDuration < L4D2_BEAM_LIFE_MIN) // Prevents rounding to 0, which makes the beam not disappear
		fieldDuration = L4D2_BEAM_LIFE_MIN;

	int targets[MAXPLAYERS+1];
	int targetCount;
	for (int target = 1; target <= MaxClients; target++)
	{
		if (!IsClientInGame(target))
			continue;

		if (IsFakeClient(target))
			continue;

		if (GetClientTeam(target) == TEAM_INFECTED)
			continue;

		targets[targetCount++] = target;
	}

	TE_SetupBeamRingPoint(vBeamPos, 75.0, 100.0, g_iFieldModelIndex, 0, 0, 0, fieldDuration, 2.0, 0.0, color, 0, 0);
	TE_Send(targets, targetCount);

	float vSpritePos[3];
	vSpritePos = vEndPos;
	vSpritePos[2] += 50.0;

	char targetname[19];
	FormatEx(targetname, sizeof(targetname), "%s-%02i", "l4d_mark_hint", client);

	g_fSpotMarkCoolDownTime[client] = GetEngineTime() + g_fSpotMarkCoolDown;

	if (strlen(g_sSpotMarkUseSound) > 0)
	{
		for (int target = 1; target <= MaxClients; target++)
		{
			if (!IsClientInGame(target))
				continue;

			if (IsFakeClient(target))
				continue;

			if (GetClientTeam(target) == TEAM_INFECTED)
				continue;

			EmitSoundToClient(target, g_sSpotMarkUseSound, client);
		}
	}

	if ( strlen(g_sSpotMarkSpriteModel) == 0 ) return; //disable spot marker info target

	int infoTarget = CreateEntityByName(CLASSNAME_INFO_TARGET);
	if( CheckIfEntitySafe(infoTarget) )
	{
		DispatchKeyValue(infoTarget, "targetname", targetname);

		TeleportEntity(infoTarget, vSpritePos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(infoTarget);
		ActivateEntity(infoTarget);

		SetEntPropEnt(infoTarget, Prop_Send, "m_hOwnerEntity", client);

		SetVariantString(g_sKillDelay);
		AcceptEntityInput(infoTarget, "AddOutput");
		AcceptEntityInput(infoTarget, "FireUser1");

		int sprite       = CreateEntityByName(CLASSNAME_ENV_SPRITE);
		if( CheckIfEntitySafe(sprite) )
		{
			DispatchKeyValue(sprite, "targetname", targetname);
			DispatchKeyValue(sprite, "spawnflags", "1");
			//SDKHook(sprite, SDKHook_SetTransmit, Hook_SetTransmit);

			DispatchKeyValue(sprite, "model", g_sSpotMarkSpriteModel);
			DispatchKeyValue(sprite, "rendercolor", g_sSpotMarkCvarColor);
			DispatchKeyValue(sprite, "renderamt", "255"); // If renderamt goes before rendercolor, it doesn't render
			DispatchKeyValue(sprite, "scale", "0.25");
			DispatchKeyValue(sprite, "fademindist", "-1");

			TeleportEntity(sprite, vSpritePos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(sprite);
			ActivateEntity(sprite);

			SetVariantString("!activator");
			AcceptEntityInput(sprite, "SetParent", infoTarget); // We need parent the entity to an info_target, otherwise SetTransmit won't work

			SetEntPropEnt(sprite, Prop_Send, "m_hOwnerEntity", client);
			AcceptEntityInput(sprite, "ShowSprite");
			SetVariantString(g_sKillDelay);
			AcceptEntityInput(sprite, "AddOutput");
			AcceptEntityInput(sprite, "FireUser1");

			CreateTimer(0.1, TimerMoveSprite, EntIndexToEntRef(sprite), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

Action TimerField(Handle timer, DataPack pack)
{
	int direction;
	int color[4];
	float timeLimit;
	float vBeamPos[3];

	pack.Reset();
	direction = pack.ReadCell();
	color[0] = pack.ReadCell();
	color[1] = pack.ReadCell();
	color[2] = pack.ReadCell();
	color[3] = pack.ReadCell();
	timeLimit = pack.ReadFloat();
	vBeamPos[0] = pack.ReadFloat();
	vBeamPos[1] = pack.ReadFloat();
	vBeamPos[2] = pack.ReadFloat();

	if (timeLimit < GetGameTime())
		return Plugin_Continue;

	float fieldDuration = (timeLimit - GetGameTime() < 1.0 ? timeLimit - GetGameTime() : 1.0);

	if (fieldDuration < L4D2_BEAM_LIFE_MIN) // Prevents rounding to 0, which makes the beam not disappear
		fieldDuration = L4D2_BEAM_LIFE_MIN;

	int targets[MAXPLAYERS+1];
	int targetCount;
	for (int target = 1; target <= MaxClients; target++)
	{
		if (!IsClientInGame(target))
			continue;

		if (IsFakeClient(target))
			continue;

		if (GetClientTeam(target) == TEAM_INFECTED)
			continue;

		targets[targetCount++] = target;
	}

	switch (direction)
	{
		case DIRECTION_OUT:
		{
			direction = DIRECTION_IN;
			TE_SetupBeamRingPoint(vBeamPos, 75.0, 100.0, g_iFieldModelIndex, 0, 0, 0, fieldDuration, 2.0, 0.0, color, 0, 0);
			TE_Send(targets, targetCount);
		}
		case DIRECTION_IN:
		{
			direction = DIRECTION_OUT;
			TE_SetupBeamRingPoint(vBeamPos, 100.0, 75.0, g_iFieldModelIndex, 0, 0, 0, fieldDuration, 2.0, 0.0, color, 0, 0);
			TE_Send(targets, targetCount);
		}
	}

	DataPack pack2;
	CreateDataTimer(1.0, TimerField, pack2, TIMER_FLAG_NO_MAPCHANGE);
	pack2.WriteCell(direction);
	pack2.WriteCell(color[0]);
	pack2.WriteCell(color[1]);
	pack2.WriteCell(color[2]);
	pack2.WriteCell(color[3]);
	pack2.WriteFloat(timeLimit);
	pack2.WriteFloat(vBeamPos[0]);
	pack2.WriteFloat(vBeamPos[1]);
	pack2.WriteFloat(vBeamPos[2]);

	return Plugin_Continue;
}

Action TimerMoveSprite(Handle timer, int entityRef)
{
    int entity = EntRefToEntIndex(entityRef);

    if (entity == INVALID_ENT_REFERENCE)
        return Plugin_Stop;

    float vPos[3];
    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vPos);

    if (ge_bMoveUp[entity])
    {
        vPos[2] += 1.0;

        if (vPos[2] >= 4.0)
            ge_bMoveUp[entity] = false;
    }
    else
    {
        vPos[2] -= 1.0;

        if (vPos[2] <= -4.0)
            ge_bMoveUp[entity] = true;
    }

    TeleportEntity(entity, vPos, NULL_VECTOR, NULL_VECTOR);

    return Plugin_Continue;
}

int[] ConvertRGBToIntArray(char[] sColor)
{
    int color[3];

    if (sColor[0] == 0)
        return color;

    char sColors[3][4];
    int count = ExplodeString(sColor, " ", sColors, sizeof(sColors), sizeof(sColors[]));

    switch (count)
    {
        case 1:
        {
            color[0] = StringToInt(sColors[0]);
        }
        case 2:
        {
            color[0] = StringToInt(sColors[0]);
            color[1] = StringToInt(sColors[1]);
        }
        case 3:
        {
            color[0] = StringToInt(sColors[0]);
            color[1] = StringToInt(sColors[1]);
            color[2] = StringToInt(sColors[2]);
        }
    }

    return color;
}

bool TraceFilter(int entity, int contentsMask, int client)
{
	if (entity == client)
		return false;

	if (entity == ENTITY_WORLDSPAWN)
		return true;


	if (1 <= entity <= MaxClients && IsClientInGame(entity))
	{
		switch(GetClientTeam(entity))
		{
			case TEAM_SPECTATOR: return false;
			case TEAM_INFECTED: {
				if(IsPlayerGhost(entity))
					return false;
			}
			default:{
				return true;
			}
		}

		return true;
	}

	return false;
}

void StringToLowerCase(char[] input)
{
    for (int i = 0; i < strlen(input); i++)
    {
        input[i] = CharToLower(input[i]);
    }
}

void NotifyMessage(int client, const char[] sItemPhrase, EHintType eType)
{
	if (eType == eItemHint)
	{
		switch(g_iItemAnnounceType)
		{
			case 0: {/*nothing*/}
			case 1: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						CPrintToChat(i, "%T", "Announce_Vocalize_ITEM (C)", i, client, sItemPhrase, i);
					}
				}
			}
			case 2: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						PrintHintText(i, "%T", "Announce_Vocalize_ITEM", i, client, sItemPhrase, i);
					}
				}
			}
			case 3: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						PrintCenterText(i, "%T", "Announce_Vocalize_ITEM", i, client, sItemPhrase, i);
					}
				}
			}
		}
	}
	else if (eType == eSpotMarker)
	{
		switch(g_iSpotMarkAnnounceType)
		{
			case 0: {/*nothing*/}
			case 1: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						CPrintToChat(i, "%T", "Announce_Spot_Marker (C)", i, client);
					}
				}
			}
			case 2: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						PrintHintText(i, "%T", "Announce_Spot_Marker", i, client);
					}
				}
			}
			case 3: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						PrintCenterText(i, "%T", "Announce_Spot_Marker", i, client);
					}
				}
			}
		}
	}
	else if (eType == eInfectedMaker)
	{
		switch(g_iInfectedMarkAnnounceType)
		{
			case 0: {/*nothing*/}
			case 1: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						CPrintToChat(i, "%T", "Announce_Vocalize_INFECTED (C)", i, client, sItemPhrase, i);
					}
				}
			}
			case 2: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						PrintHintText(i, "%T", "Announce_Vocalize_INFECTED", i, client, sItemPhrase, i);
					}
				}
			}
			case 3: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						PrintCenterText(i, "%T", "Announce_Vocalize_INFECTED", i, client, sItemPhrase, i);
					}
				}
			}
		}
	}
	else if (eType == eSurvivorMaker)
	{
		switch(g_iSurvivorMarkAnnounceType)
		{
			case 0: {/*nothing*/}
			case 1: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						CPrintToChat(i, "%T", "Announce_Vocalize_SURVIVOR (C)", i, client, sItemPhrase);
					}
				}
			}
			case 2: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						PrintHintText(i, "%T", "Announce_Vocalize_SURVIVOR", i, client, sItemPhrase);
					}
				}
			}
			case 3: {
				for (int i=1; i <= MaxClients; i++)
				{
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != TEAM_INFECTED)
					{
						PrintCenterText(i, "%T", "Announce_Vocalize_SURVIVOR", i, client, sItemPhrase);
					}
				}
			}
		}
	}
}

stock bool IsHandingFromLedge(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isHangingFromLedge") || GetEntProp(client, Prop_Send, "m_isFallingFromLedge"));
}

int GetInfectedAttacker(int client)
{
	int attacker;

	/* Charger */
	attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
	if (attacker > 0)
	{
		return attacker;
	}

	attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
	if (attacker > 0)
	{
		return attacker;
	}
	/* Jockey */
	attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
	if (attacker > 0)
	{
		return attacker;
	}

	/* Hunter */
	attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
	if (attacker > 0)
	{
		return attacker;
	}

	/* Smoker */
	attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
	if (attacker > 0)
	{
		return attacker;
	}

	return -1;
}

bool IsWitch(int entity)
{
    if (entity > 0 && IsValidEntity(entity) && IsValidEdict(entity))
    {
        char strClassName[64];
        GetEdictClassname(entity, strClassName, sizeof(strClassName));
        return strcmp(strClassName, "witch", false) == 0;
    }
    return false;
}

bool IsPlayerGhost(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isGhost"));
}

Action Hook_SetTransmit_Glow(int entity, int client)
{
	if( GetClientTeam(client) == TEAM_INFECTED)
		return Plugin_Handled;

	if( EntIndexToEntRef(entity) == g_iModelIndex[client])
		return Plugin_Handled;

	return Plugin_Continue;
}

Action Hook_SetTransmit_info_target(int entity, int client)
{
	if( GetClientTeam(client) == TEAM_INFECTED)
		return Plugin_Handled;

	if( EntIndexToEntRef(entity) == g_iTargetInstructorIndex[client])
		return Plugin_Handled;

	return Plugin_Continue;
}

bool CheckIfEntitySafe(int entity)
{
	if(entity == -1) return false;

	if(	entity > ENTITY_SAFE_LIMIT)
	{
		AcceptEntityInput(entity, "Kill");
		return false;
	}
	return true;
}

// by BHaType: https://forums.alliedmods.net/showthread.php?p=2709810#post2709810
void CreateInstructorHint(int client, const float vOrigin[3], const char[] sItemPhrase, int iEntity, EHintType type)
{
	static char sTargetName[64], sCaption[128];
	Format(sTargetName, sizeof(sTargetName), "%i_%.0f", client, GetEngineTime());

	switch(type)
	{
		case eItemHint:
		{
			if( Create_info_target(iEntity, vOrigin, sTargetName, g_fItemGlowTimer) )
			{
				if(strlen(sItemPhrase) > 0 && strlen(g_sItemInstructorColor) > 0) 
				{
					if(g_iHintTransType == 0) FormatEx(sCaption, sizeof(sCaption), "%T", sItemPhrase, LANG_SERVER);
					else FormatEx(sCaption, sizeof(sCaption), "%T", sItemPhrase, client);
				}
				else sCaption[0] = '\0';
				Create_env_instructor_hint(iEntity, eItemHint, vOrigin, sTargetName, g_sItemInstructorIcon, sCaption, g_sItemInstructorColor, g_fItemGlowTimer, float(g_iItemGlowRange));
			}
		}
		case eSpotMarker:
		{
			if( Create_info_target(iEntity, vOrigin, sTargetName, g_fSpotMarkGlowTimer) )
			{
				if(strlen(g_sSpotMarkInstructorColor) > 0)
				{
					if(g_iHintTransType == 0) FormatEx(sCaption, sizeof(sCaption), "%T", "Spot_Maker", LANG_SERVER, client);
					else FormatEx(sCaption, sizeof(sCaption), "%T", "Spot_Maker", client, client);
				}
				else sCaption[0] = '\0';
				Create_env_instructor_hint(iEntity, eSpotMarker, vOrigin, sTargetName, g_sSpotMarkInstructorIcon, sCaption, g_sSpotMarkInstructorColor, g_fSpotMarkGlowTimer, g_fSpotMarkUseRange);
			}
		}
		case eInfectedMaker:
		{
			if( Create_info_target(iEntity, vOrigin, sTargetName, g_fInfectedMarkGlowTimer) )
			{
				if(strlen(g_sInfectedMarkInstructorColor) > 0) 
				{
					if(g_iHintTransType == 0) FormatEx(sCaption, sizeof(sCaption), "%T", sItemPhrase, LANG_SERVER);
					else FormatEx(sCaption, sizeof(sCaption), "%T", sItemPhrase, client);
				}
				else sCaption[0] = '\0';
				Create_env_instructor_hint(iEntity, eInfectedMaker, vOrigin, sTargetName, g_sInfectedMarkInstructorIcon, sCaption, g_sInfectedMarkInstructorColor, g_fInfectedMarkGlowTimer, float(g_iInfectedMarkGlowRange));
			}
		}
		case eSurvivorMaker:
		{
			if( Create_info_target(iEntity, vOrigin, sTargetName, g_fSurvivorMarkGlowTimer) )
			{
				if(strlen(g_sSurvivorMarkInstructorColor) > 0) FormatEx(sCaption, sizeof(sCaption), "%s", sItemPhrase);
				else sCaption[0] = '\0';
				Create_env_instructor_hint(iEntity, eSurvivorMaker, vOrigin, sTargetName, g_sSurvivorMarkInstructorIcon, sCaption, g_sSurvivorMarkInstructorColor, g_fSurvivorMarkGlowTimer, float(g_iSurvivorMarkGlowRange));
			}
		}
	}
}

bool Create_info_target(int iEntity, const float vOrigin[3], const char[] sTargetName, float duration)
{
	int entity = CreateEntityByName(CLASSNAME_INFO_TARGET);
	if (!CheckIfEntitySafe(entity)) return false;

	DispatchKeyValue(entity, "targetname", sTargetName);
	DispatchKeyValue(entity, "spawnflags", "1"); //Only visible to survivors
	DispatchSpawn(entity);
	TeleportEntity(entity, vOrigin, NULL_VECTOR, NULL_VECTOR);
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", iEntity); // We need parent the info_target to an entity, otherwise it won't follow moveable item such as gascan, pill and throwable

	SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit_info_target);

	if (iEntity > 0)
	{
		//delete previous info_target first
		RemoveTargetInstructor(iEntity);
		delete g_iTargetInstructorTimer[iEntity];

		g_iTargetInstructorIndex[iEntity] = EntIndexToEntRef(entity);
		g_iTargetInstructorTimer[iEntity] = CreateTimer(duration, Timer_target_instructor_hint, iEntity);
	}
	else
	{
		static char szBuffer[36];
		FormatEx(szBuffer, sizeof(szBuffer), "OnUser1 !self:Kill::%f:-1", duration);

		SetVariantString(szBuffer);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}

	return true;
}

void Create_env_instructor_hint(int iEntity, EHintType eType, const float vOrigin[3], const char[] sTargetName, const char[] icon_name, const char[] caption, const char[] hint_color, float duration, float range)
{
	int entity = CreateEntityByName("env_instructor_hint");
	if (!CheckIfEntitySafe(entity)) return;

	char sDuration[4];
	IntToString(RoundFloat(duration), sDuration, sizeof(sDuration));
	char sRange[8];
	IntToString(RoundFloat(range), sRange, sizeof(sRange));

	DispatchKeyValue(entity, "hint_timeout", sDuration);
	DispatchKeyValue(entity, "hint_allow_nodraw_target", "1");
	DispatchKeyValue(entity, "hint_target", sTargetName);
	DispatchKeyValue(entity, "hint_auto_start", "1");
	DispatchKeyValue(entity, "hint_color", hint_color);
	DispatchKeyValue(entity, "hint_icon_offscreen", icon_name);
	DispatchKeyValue(entity, "hint_instance_type", "0"); //0=不會被新的director hint覆蓋掉
	DispatchKeyValue(entity, "hint_icon_onscreen", icon_name);
	//DispatchKeyValue(entity, "hint_binding", "+use"); // only work if "hint_icon_onscreen" is "use_binding", 輸入+/- Commands: https://developer.valvesoftware.com/wiki/Bind
	DispatchKeyValue(entity, "hint_caption", caption);
	DispatchKeyValue(entity, "hint_static", "0");
	DispatchKeyValue(entity, "hint_nooffscreen", "0");
	if (eType == eSpotMarker) DispatchKeyValue(entity, "hint_icon_offset", "10");
	else if (eType == eInfectedMaker) DispatchKeyValue(entity, "hint_icon_offset", "5");
	else if (eType == eSurvivorMaker) DispatchKeyValue(entity, "hint_icon_offset", "10");
	else DispatchKeyValue(entity, "hint_icon_offset", "0");
	DispatchKeyValue(entity, "hint_range", sRange);
	DispatchKeyValue(entity, "hint_forcecaption", "1");

	DispatchSpawn(entity);
	TeleportEntity(entity, vOrigin, NULL_VECTOR, NULL_VECTOR);
	//AcceptEntityInput(entity, "ShowHint"); //double hint

	if (iEntity > 0)
	{
		//delete previous env_instructor_hint first
		RemoveInstructor(iEntity);
		delete g_iInstructorTimer[iEntity];

		g_iInstructorIndex[iEntity] = EntIndexToEntRef(entity);
		g_iInstructorTimer[iEntity] = CreateTimer(duration, Timer_instructor_hint, iEntity);
	}
	else
	{
		static char szBuffer[36];
		FormatEx(szBuffer, sizeof(szBuffer), "OnUser1 !self:Kill::%f:-1", duration);

		SetVariantString(szBuffer);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
}


Action Timer_instructor_hint(Handle timer, int iEntity)
{
	RemoveInstructor(iEntity);
	g_iInstructorTimer[iEntity] = null;

	return Plugin_Continue;
}

void RemoveInstructor(int iEntity)
{
	int instructor_hint = g_iInstructorIndex[iEntity];
	g_iInstructorIndex[iEntity] = 0;

	if (IsValidEntRef(instructor_hint))
		RemoveEntity(instructor_hint);
}

Action Timer_target_instructor_hint(Handle timer, int iEntity)
{
	RemoveTargetInstructor(iEntity);
	g_iTargetInstructorTimer[iEntity] = null;

	return Plugin_Continue;
}

void RemoveTargetInstructor(int iEntity)
{
	int target_instructor_hint = g_iTargetInstructorIndex[iEntity];
	g_iTargetInstructorIndex[iEntity] = 0;

	if (IsValidEntRef(target_instructor_hint))
		RemoveEntity(target_instructor_hint);
}

bool HasParentClient(int entity)
{
	if(HasEntProp(entity, Prop_Data, "m_pParent"))
	{
		int parent_entity = GetEntPropEnt(entity, Prop_Data, "m_pParent");
		//PrintToChatAll("%d m_pParent: %d", entity, parent_entity);
		if (1 <= parent_entity <= MaxClients && IsClientInGame(parent_entity))
		{
			return true;
		}
	}

	return false;
}

int GetClientViewClient(int client) {
    float m_vecOrigin[3];
    float m_angRotation[3];
    GetClientEyePosition(client, m_vecOrigin);
    GetClientEyeAngles(client, m_angRotation);
    Handle tr = TR_TraceRayFilterEx(m_vecOrigin, m_angRotation, MASK_ALL, RayType_Infinite, TRDontHitSelf, client);
    int pEntity = -1;
    if (TR_DidHit(tr)) {
        pEntity = TR_GetEntityIndex(tr);
        delete tr;

        return pEntity;
    }
    delete tr;

    return -1;
}

bool TRDontHitSelf(int entity, int mask, any data) {
    if (entity == data)
        return false;
    return true;
}

void PlayerMarkHint(int client)
{
	if(!g_bHaningMark && IsHandingFromLedge(client)) return;
	if(!g_bCappedMark && GetInfectedAttacker(client) != -1) return;
	if(!g_bDeadMark && !IsPlayerAlive(client)) return;

	bool bIsAimPlayer = false, bIsAimWitch = false, bIsVaildItem = false;
	static char sItemPhrase[64], sEntModelName[PLATFORM_MAX_PATH];

	// marker priority (infected maker > item hint > spot marker)

	int clientAim = GetClientViewClient(client); //ignore glow model

	if (1 <= clientAim <= MaxClients && IsClientInGame(clientAim))
	{
		if(g_iInfectedMarkCvarColor != 0 && GetClientTeam(clientAim) == TEAM_INFECTED && IsPlayerAlive(clientAim) && !IsPlayerGhost(clientAim))
		{
			bIsAimPlayer = true;
			//PrintToChatAll("look at %N", clientAim);
				
			int class = GetEntProp(clientAim, Prop_Send, "m_zombieClass");
			if(class == ZC_TANK) // tank
			{
				class--;
			}
			class--;

			if(class >=0 && class <=6 && ((1 << class) & g_iInfectedMarkSI))
			{
				if( CreateInfectedMarker(client, clientAim) == true )
					return;
			}
		}
		else if(g_iSurvivorMarkCvarColor != 0 && GetClientTeam(clientAim) == TEAM_SURVIVOR && IsPlayerAlive(clientAim))
		{
			bIsAimPlayer = true;
			//PrintToChatAll("look at %N", clientAim);
			
			if( CreateSurvivorMarker(client, clientAim) == true )
				return;
		}
	}
	else if ( g_iInfectedMarkCvarColor != 0 && IsWitch(clientAim) )
	{
		bIsAimWitch = true;

		if( CreateInfectedMarker(client, clientAim, true) == true )
			return;
	}


	static int iEntity;
	iEntity = GetUseEntity(client, g_fItemUseHintRange);
	if ( !bIsAimPlayer && !bIsAimWitch && IsValidEntityIndex(iEntity) && IsValidEntity(iEntity) && HasParentClient(iEntity) == false )
	{
		static char targetname[128];
		GetEntPropString(iEntity, Prop_Data, "m_iName", targetname, sizeof(targetname));
		if (strcmp(targetname, "harry_marked_item") == 0) //custom model
		{
			iEntity = GetEntPropEnt(iEntity, Prop_Data, "m_pParent");
		}

		static char classname[32];
		if (GetEntityClassname(iEntity, classname, sizeof(classname)) && HasEntProp(iEntity, Prop_Data, "m_ModelName"))
		{
			if (GetEntPropString(iEntity, Prop_Data, "m_ModelName", sEntModelName, sizeof(sEntModelName)) > 1)
			{
				if(strncmp(classname, "prop_dynamic", 12, false) == 0)
				{
					int m_iEFlags = GetEntProp(iEntity, Prop_Data, "m_iEFlags");
					if(m_iEFlags & EFL_DONTBLOCKLOS && m_iEFlags & SF_PHYSPROP_PREVENT_PICKUP)
					{
						//PrintToChatAll("this is attach api weapons");

						// client / world / witch
						CreateSpotMarker(client, bIsAimPlayer);
						return;
					}
				}		

				//PrintToChatAll("%N is looking at %d (%s-%s)", client, iEntity, classname, sEntModelName);
				StringToLowerCase(sEntModelName);
				float fHeight = 10.0;
				if (g_smModelToName.GetString(sEntModelName, sItemPhrase, sizeof(sItemPhrase)))
				{
					g_smModelHeight.GetValue(sEntModelName, fHeight);
					bIsVaildItem = true;
				}
				else if (strncmp(classname, "weapon_melee", 12, false) == 0) // (custom melee model)
				{
					FormatEx(sItemPhrase, sizeof(sItemPhrase), "Melee");
					fHeight = 5.0;

					bIsVaildItem = true;
				}
				else if (strncmp(classname, "weapon_ammo_spawn", 17, false) == 0) // (custom ammo model)
				{
					FormatEx(sItemPhrase, sizeof(sItemPhrase), "Ammo");
					fHeight = 10.0;

					bIsVaildItem = true;
				}
				else if (StrContains(sEntModelName, "/weapons/") != -1) // entity is not in the list (custom weapom model)
				{
					FormatEx(sItemPhrase, sizeof(sItemPhrase), "Weapons");
					fHeight = 10.0;

					bIsVaildItem = true;
				}
				else // entity is not in the list (other entity model on the map)
				{
					bIsVaildItem = false;
				}

				if(bIsVaildItem)
				{
					if(GetEngineTime() > g_fItemHintCoolDownTime[client])
					{
						NotifyMessage(client, sItemPhrase, eItemHint);

						if (strlen(g_sItemUseSound) > 0)
						{
							for (int target = 1; target <= MaxClients; target++)
							{
								if (!IsClientInGame(target))
									continue;

								if (IsFakeClient(target))
									continue;

								if (GetClientTeam(target) == TEAM_INFECTED)
									continue;

								EmitSoundToClient(target, g_sItemUseSound, client);
							}
						}

						g_fItemHintCoolDownTime[client] = GetEngineTime() + g_fItemHintCoolDown;
						CreateEntityModelGlow(iEntity, sEntModelName);

						if(g_bItemInstructorHint)
						{
							float vEndPos[3];
							GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", vEndPos);
							vEndPos[2] = vEndPos[2] + fHeight;
							CreateInstructorHint(client, vEndPos, sItemPhrase, iEntity, eItemHint);
						}
					}

					return;
				}
			}
		}
	}

	// client / world / witch
	CreateSpotMarker(client, bIsAimPlayer);
} 

int GetZombieClass(int client) 
{
	return GetEntProp(client, Prop_Send, "m_zombieClass");
}

void RemoveGlowandInstructor(int entity)
{
	RemoveEntityModelGlow(entity);
	delete g_iModelTimer[entity];

	RemoveInstructor(entity);
	delete g_iInstructorTimer[entity];

	RemoveTargetInstructor(entity);
	delete g_iTargetInstructorTimer[entity];
}

// LMC--------------

int GetLMCModel(int client)
{
    if(bLMC_Available)
    {
        int iEntity = LMC_GetClientOverlayModel(client);
        //PrintToChatAll("%N - %d", client, iEntity);
        if(iEntity > MaxClients)
        {
            return iEntity;
        }
    }

    return 0;
}