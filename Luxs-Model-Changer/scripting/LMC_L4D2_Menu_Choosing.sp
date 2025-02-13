/*
*    LMC_L4D2_Menu_Choosing - Allows humans to choose LMC model with cookiesaving
*    Copyright (C) 2019  LuxLuma		acceliacat@gmail.com
*
*    This program is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/


#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

#define REQUIRE_EXTENSIONS
#include <clientprefs>
#undef REQUIRE_EXTENSIONS

#define REQUIRE_PLUGIN
#include <LMCCore>
#include <LMCL4D2CDeathHandler>
#include <LMCL4D2SetTransmit>
#undef REQUIRE_PLUGIN

#pragma newdecls required


#define PLUGIN_NAME "LMC_L4D2_Menu_Choosing"
#define PLUGIN_VERSION "1.1.1"

#define HUMAN_MODEL_PATH_SIZE 11
#define SPECIAL_MODEL_PATH_SIZE 8
#define UNCOMMON_MODEL_PATH_SIZE 6
#define COMMON_MODEL_PATH_SIZE 34


enum /*ZOMBIECLASS*/
{
	ZOMBIECLASS_SMOKER = 1,
	ZOMBIECLASS_BOOMER,
	ZOMBIECLASS_HUNTER,
	ZOMBIECLASS_SPITTER,
	ZOMBIECLASS_JOCKEY,
	ZOMBIECLASS_CHARGER,
	ZOMBIECLASS_UNKNOWN,
	ZOMBIECLASS_TANK,
}

enum LMCModelSectionType
{
	LMCModelSectionType_Human = 0,
	LMCModelSectionType_Special,
	LMCModelSectionType_UnCommon,
	LMCModelSectionType_Common
};

static const char sHumanPaths[HUMAN_MODEL_PATH_SIZE][] =
{
	"models/survivors/survivor_gambler.mdl",
	"models/survivors/survivor_producer.mdl",
	"models/survivors/survivor_coach.mdl",
	"models/survivors/survivor_mechanic.mdl",
	"models/survivors/survivor_namvet.mdl",
	"models/survivors/survivor_teenangst.mdl",
	"models/survivors/survivor_teenangst_light.mdl",
	"models/survivors/survivor_biker.mdl",
	"models/survivors/survivor_biker_light.mdl",
	"models/survivors/survivor_manager.mdl",
	"models/npcs/rescue_pilot_01.mdl"
};

enum LMCHumanModelType
{
	LMCHumanModelType_Nick = 0,
	LMCHumanModelType_Rochelle,
	LMCHumanModelType_Coach,
	LMCHumanModelType_Ellis,
	LMCHumanModelType_Bill,
	LMCHumanModelType_Zoey,
	LMCHumanModelType_ZoeyLight,
	LMCHumanModelType_Francis,
	LMCHumanModelType_FrancisLight,
	LMCHumanModelType_Louis,
	LMCHumanModelType_Pilot
};

static const char sSpecialPaths[SPECIAL_MODEL_PATH_SIZE][] =
{
	"models/infected/witch.mdl",
	"models/infected/witch_bride.mdl",
	"models/infected/boomer.mdl",
	"models/infected/boomette.mdl",
	"models/infected/hunter.mdl",
	"models/infected/smoker.mdl",
	"models/infected/hulk.mdl",
	"models/infected/hulk_dlc3.mdl"
};

enum LMCSpecialModelType
{
	LMCSpecialModelType_Witch = 0,
	LMCSpecialModelType_WitchBride,
	LMCSpecialModelType_Boomer,
	LMCSpecialModelType_Boomette,
	LMCSpecialModelType_Hunter,
	LMCSpecialModelType_Smoker,
	LMCSpecialModelType_Tank,
	LMCSpecialModelType_TankDLC3
};

static const char sUnCommonPaths[UNCOMMON_MODEL_PATH_SIZE][] =
{
	"models/infected/common_male_riot.mdl",
	"models/infected/common_male_mud.mdl",
	"models/infected/common_male_ceda.mdl",
	"models/infected/common_male_clown.mdl",
	"models/infected/common_male_jimmy.mdl",
	"models/infected/common_male_fallen_survivor.mdl"
};

enum LMCUnCommonModelType
{
	LMCUnCommonModelType_RiotCop = 0,
	LMCUnCommonModelType_MudMan,
	LMCUnCommonModelType_Ceda,
	LMCUnCommonModelType_Clown,
	LMCUnCommonModelType_Jimmy,
	LMCUnCommonModelType_Fallen
};

static const char sCommonPaths[COMMON_MODEL_PATH_SIZE][] =
{
	"models/infected/common_male_tshirt_cargos.mdl",
	"models/infected/common_male_tankTop_jeans.mdl",
	"models/infected/common_male_dressShirt_jeans.mdl",
	"models/infected/common_female_tankTop_jeans.mdl",
	"models/infected/common_female_tshirt_skirt.mdl",
	"models/infected/common_male_roadcrew.mdl",
	"models/infected/common_male_tankTop_overalls.mdl",
	"models/infected/common_male_tankTop_jeans_rain.mdl",
	"models/infected/common_female_tankTop_jeans_rain.mdl",
	"models/infected/common_male_roadcrew_rain.mdl",
	"models/infected/common_male_tshirt_cargos_swamp.mdl",
	"models/infected/common_male_tankTop_overalls_swamp.mdl",
	"models/infected/common_female_tshirt_skirt_swamp.mdl",
	"models/infected/common_male_formal.mdl",
	"models/infected/common_female_formal.mdl",
	"models/infected/common_military_male01.mdl",
	"models/infected/common_police_male01.mdl",
	"models/infected/common_male_baggagehandler_01.mdl",
	"models/infected/common_tsaagent_male01.mdl",
	"models/infected/common_shadertest.mdl",
	"models/infected/common_female_nurse01.mdl",
	"models/infected/common_surgeon_male01.mdl",
	"models/infected/common_worker_male01.mdl",
	"models/infected/common_morph_test.mdl",
	"models/infected/common_male_biker.mdl",
	"models/infected/common_female01.mdl",
	"models/infected/common_male01.mdl",
	"models/infected/common_male_suit.mdl",
	"models/infected/common_patient_male01_l4d2.mdl",
	"models/infected/common_male_polo_jeans.mdl",
	"models/infected/common_female_rural01.mdl",
	"models/infected/common_male_rural01.mdl",
	"models/infected/common_male_pilot.mdl",
	"models/infected/common_test.mdl"
};

#define CvarIndexes 7
static const char sSharedCvarNames[CvarIndexes][] =
{
	"lmc_allowtank",
	"lmc_allowhunter",
	"lmc_allowsmoker",
	"lmc_allowboomer",
	"lmc_allowSurvivors",
	"lmc_allow_tank_model_use",
	"lmc_precache_prevent"
};

static const char sJoinSound[] = "ui/menu_countdown.wav";

static Handle hCvar_ArrayIndex[CvarIndexes] = {null, ...};

static bool g_bAllowTank = false;
static bool g_bAllowHunter = true;
static bool g_bAllowSmoker = true;
static bool g_bAllowBoomer = true;
static bool g_bAllowSurvivors = true;
static bool g_bTankModel = false;

static Handle hCookie_LmcCookie = null;

static ConVar hCvar_AdminFlag = null;
static ConVar hCvar_AnnounceDelay = null;
static ConVar hCvar_AnnounceMode = null;
static ConVar hCvar_ThirdPersonTime = null;

static float g_fAnnounceDelay = 15.0;
static int g_iAnnounceMode = 1;
static char g_sCvar_AdminFlag[AdminFlags_TOTAL];
static float g_fThirdPersonTime = 2.0;

static int iSavedModel[MAXPLAYERS+1] = {0, ...};
static bool bAutoApplyMsg[MAXPLAYERS+1];
static bool bAutoBlockedMsg[MAXPLAYERS+1][9];

static int iCurrentPage[MAXPLAYERS+1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if(GetEngineVersion() != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "Lux",
	description = "Allows humans to choose LMC model with cookiesaving",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2607394"
};

public void OnPluginStart()
{
	LoadTranslations("lmc.phrases");

	CreateConVar("lmc_l4d2_menu_choosing", PLUGIN_VERSION, "LMC_L4D2_Menu_Choosing_Version", FCVAR_DONTRECORD|FCVAR_NOTIFY);

	hCvar_AdminFlag 		= CreateConVar("lmc_admin_flag", 		"n", 	"Players with these flags have access to use !lmc command and change model. (Empty = Everyone, -1: Nobody)\nNOTE: this will enable announcement to player who join server.", FCVAR_NOTIFY);
	hCvar_AnnounceDelay 	= CreateConVar("lmc_announcedelay", 	"15.0", "Delay On which a message is displayed for !lmc command", FCVAR_NOTIFY, true, 1.0, true, 360.0);
	hCvar_AnnounceMode 		= CreateConVar("lmc_announcemode", 		"1", 	"Display Mode for !lmc command (0 = off, 1 = Print to chat, 2 = Hint text, 3 = Director Hint)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	hCvar_ThirdPersonTime 	= CreateConVar("lmc_thirdpersontime", 	"0.0", 	"How long (in seconds) the client will be in thirdperson view after selecting a model from !lmc command. (0.5 < = off)", FCVAR_NOTIFY, true, 0.0, true, 360.0);
	HookConVarChange(hCvar_AdminFlag, eConvarChanged);
	HookConVarChange(hCvar_AnnounceDelay, eConvarChanged);
	HookConVarChange(hCvar_AnnounceMode, eConvarChanged);
	HookConVarChange(hCvar_ThirdPersonTime, eConvarChanged);
	AutoExecConfig(true, "LMC_L4D2_Menu_Choosing");
	CvarsChanged();

	hCookie_LmcCookie = RegClientCookie("lmc_cookie", "", CookieAccess_Protected);
	RegConsoleCmd("sm_lmc", ShowMenuCmd, "Brings up a menu to select a client's model");

	HookEvent("player_spawn", ePlayerSpawn);
	HookEvent("player_bot_replace", ePlayerBotReplace);
}

void eConvarChanged(Handle hCvar, const char[] sOldVal, const char[] sNewVal)
{
	CvarsChanged();
}

void CvarsChanged()
{
	if(hCvar_ArrayIndex[0] != null)
		g_bAllowTank = GetConVarInt(hCvar_ArrayIndex[0]) > 0;
	if(hCvar_ArrayIndex[1] != null)
		g_bAllowHunter = GetConVarInt(hCvar_ArrayIndex[1]) > 0;
	if(hCvar_ArrayIndex[2] != null)
		g_bAllowSmoker = GetConVarInt(hCvar_ArrayIndex[2]) > 0;
	if(hCvar_ArrayIndex[3] != null)
		g_bAllowBoomer = GetConVarInt(hCvar_ArrayIndex[3]) > 0;
	if(hCvar_ArrayIndex[4] != null)
		g_bAllowSurvivors = GetConVarInt(hCvar_ArrayIndex[4]) > 0;
	if(hCvar_ArrayIndex[5] != null)
		g_bTankModel = GetConVarInt(hCvar_ArrayIndex[5]) > 0;

	hCvar_AdminFlag.GetString(g_sCvar_AdminFlag, sizeof(g_sCvar_AdminFlag));
	g_fAnnounceDelay = hCvar_AnnounceDelay.FloatValue;
	g_iAnnounceMode = hCvar_AnnounceMode.IntValue;
	g_fThirdPersonTime = hCvar_ThirdPersonTime.FloatValue;
}

void HookCvars()
{
	for(int i = 0; i < CvarIndexes; i++)
	{
		if(hCvar_ArrayIndex[i] != null)
			continue;

		if((hCvar_ArrayIndex[i] = FindConVar(sSharedCvarNames[i])) == null)
		{
			PrintToServer("[LMC]Unable to find shared cvar \"%s\" using fallback value plugin:(%s)", sSharedCvarNames[i], PLUGIN_NAME);
			continue;
		}
		HookConVarChange(hCvar_ArrayIndex[i], eConvarChanged);
	}
}


public void OnMapStart()
{
	bool bPrecacheModels = true;
	if(FindConVar(sSharedCvarNames[6]) != null)
	{
		char sCvarString[4096];
		char sMap[67];
		GetConVarString(FindConVar(sSharedCvarNames[6]), sCvarString, sizeof(sCvarString));
		GetCurrentMap(sMap, sizeof(sMap));

		Format(sMap, sizeof(sMap), ",%s,", sMap);
		Format(sCvarString, sizeof(sCvarString), ",%s,", sCvarString);

		if(StrContains(sCvarString, sMap, false) != -1)
			bPrecacheModels = false;

		if(!bPrecacheModels)
		{
			ReplaceString(sMap, sizeof(sMap), ",", "", false);
			PrintToServer("[%s] \"%s\" Model Precaching Disabled.", PLUGIN_NAME, sMap);
		}
	}

	if(bPrecacheModels)
	{
		int i;
		for(i = 0; i < HUMAN_MODEL_PATH_SIZE; i++)
			PrecacheModel(sHumanPaths[i], true);

		for(i = 0; i < SPECIAL_MODEL_PATH_SIZE; i++)
			PrecacheModel(sSpecialPaths[i], true);

		for(i = 0; i < UNCOMMON_MODEL_PATH_SIZE; i++)
			PrecacheModel(sUnCommonPaths[i], true);

		for(i = 0; i < COMMON_MODEL_PATH_SIZE; i++)
			PrecacheModel(sCommonPaths[i], true);
	}

	PrecacheSound(sJoinSound, true);

	HookCvars();
	CvarsChanged();
}

void ePlayerSpawn(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(iClient < 1 || iClient > MaxClients)
		return;

	if(!IsClientInGame(iClient) || IsFakeClient(iClient) || !IsPlayerAlive(iClient))
		return;

	LMC_ResetRenderMode(iClient);

	if(HasAccess(iClient, g_sCvar_AdminFlag) == false)
		return;

	switch(GetClientTeam(iClient))
	{
		case 3:
		{
			switch(GetEntProp(iClient, Prop_Send, "m_zombieClass"))//1.4
			{
				case ZOMBIECLASS_SMOKER:
				{
					if(!g_bAllowSmoker)
						return;
				}
				case ZOMBIECLASS_BOOMER:
				{
					if(!g_bAllowBoomer)
						return;
				}
				case ZOMBIECLASS_HUNTER:
				{
					if(!g_bAllowHunter)
						return;
				}
				case ZOMBIECLASS_CHARGER, ZOMBIECLASS_JOCKEY, ZOMBIECLASS_SPITTER, ZOMBIECLASS_UNKNOWN:
				{
					return;
				}
				case ZOMBIECLASS_TANK:
				{
					if(!g_bAllowTank)
						return;
				}
				default:
				{
					return;
				}
			}
		}
		case 2:
		{
			if(!g_bAllowSurvivors)
				return;
		}
		default:
		{
			return;
		}
	}


	if(iSavedModel[iClient] < 2)
		return;

	RequestFrame(NextFrame, GetClientUserId(iClient));
}

void ePlayerBotReplace(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "player"));
	int iBot = GetClientOfUserId(GetEventInt(hEvent, "bot"));

	if(iBot < 1 || iBot > MaxClients || !IsClientInGame(iBot))
		return;

	if(iClient < 1 || iClient > MaxClients || !IsClientInGame(iClient))
		return;

	if(!IsFakeClient(iBot))
		return;

	LMC_ResetRenderMode(iBot);

	if(HasAccess(iClient, g_sCvar_AdminFlag) == false)
			return;

	switch(GetClientTeam(iBot))
	{
		case 3:
		{
			switch(GetEntProp(iBot, Prop_Send, "m_zombieClass"))//1.4
			{
				case ZOMBIECLASS_SMOKER:
				{
					if(!g_bAllowSmoker)
						return;
				}
				case ZOMBIECLASS_BOOMER:
				{
					if(!g_bAllowBoomer)
						return;
				}
				case ZOMBIECLASS_HUNTER:
				{
					if(!g_bAllowHunter)
						return;
				}
				case ZOMBIECLASS_CHARGER, ZOMBIECLASS_JOCKEY, ZOMBIECLASS_SPITTER, ZOMBIECLASS_UNKNOWN:
				{
					return;
				}
				case ZOMBIECLASS_TANK:
				{
					if(!g_bAllowTank)
						return;
				}
				default:
				{
					return;
				}
			}
		}
		case 2:
		{
			if(!g_bAllowSurvivors)
				return;
		}
		default:
		{
			return;
		}
	}

	iSavedModel[iBot] = iSavedModel[iClient];

	if(iSavedModel[iBot] < 2)
		return;

	RequestFrame(NextFrame, GetClientUserId(iBot));
}

void NextFrame(int iUserID)
{
	int iClient = GetClientOfUserId(iUserID);
	if(iClient < 1 || !IsClientInGame(iClient))
		return;

	ModelIndex(iClient, iSavedModel[iClient], false);
}

Action ShowMenuCmd(int iClient, int iArgs)
{
	iCurrentPage[iClient] = 0;
	ShowMenu(iClient);

	return Plugin_Handled;
}

/*borrowed some code from csm*/
void ShowMenu(int iClient)
{
	if(iClient == 0 || !IsClientInGame(iClient))
	{
		ReplyToCommand(iClient, LMC_Translate(iClient, "%t", "In-game only")); // "[LMC] Menu is in-game only.");
		return;
	}
	if(HasAccess(iClient, g_sCvar_AdminFlag) == false)
	{
		LMC_CPrintToChat(iClient, "%t", "Admin only");// "\x04[LMC] \x03Model Changer is only available to admins.");
		return;
	}
	if(!IsPlayerAlive(iClient) && bAutoBlockedMsg[iClient][8])
	{
		LMC_CPrintToChat(iClient, "%t", "Alive only"); // "\x04[LMC] \x03Pick a Model to be Applied NextSpawn");
		bAutoBlockedMsg[iClient][8] = false;
	}
	Handle hMenu = CreateMenu(CharMenu);
	SetMenuTitle(hMenu, LMC_Translate(iClient, "%t", "Lux's Model Changer"));//1.4

	AddMenuItem(hMenu, "1", LMC_Translate(iClient, "%t", "Normal Models"), iSavedModel[iClient] == 1 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	AddMenuItem(hMenu, "2", LMC_Translate(iClient, "%t", "Random Common"));
	if(IsModelPrecached(sSpecialPaths[LMCSpecialModelType_Witch]))
		AddMenuItem(hMenu, "3", LMC_Translate(iClient, "%t", "Witch"), iSavedModel[iClient] == 3 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sSpecialPaths[LMCSpecialModelType_WitchBride]))
		AddMenuItem(hMenu, "4", LMC_Translate(iClient, "%t", "Witch Bride"), iSavedModel[iClient] == 4 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sSpecialPaths[LMCSpecialModelType_Boomer]))
		AddMenuItem(hMenu, "5", LMC_Translate(iClient, "%t", "Boomer"), iSavedModel[iClient] == 5 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sSpecialPaths[LMCSpecialModelType_Boomette]))
		AddMenuItem(hMenu, "6", LMC_Translate(iClient, "%t", "Boomette"), iSavedModel[iClient] == 6 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sSpecialPaths[LMCSpecialModelType_Hunter]))
		AddMenuItem(hMenu, "7", LMC_Translate(iClient, "%t", "Hunter"), iSavedModel[iClient] == 7 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sSpecialPaths[LMCSpecialModelType_Smoker]))
		AddMenuItem(hMenu, "8", LMC_Translate(iClient, "%t", "Smoker"), iSavedModel[iClient] == 8 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sUnCommonPaths[LMCUnCommonModelType_RiotCop]))
		AddMenuItem(hMenu, "9", LMC_Translate(iClient, "%t", "Riot Cop"), iSavedModel[iClient] == 9 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sUnCommonPaths[LMCUnCommonModelType_MudMan]))
		AddMenuItem(hMenu, "10", LMC_Translate(iClient, "%t", "MudMan"), iSavedModel[iClient] == 10 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sHumanPaths[LMCHumanModelType_Pilot]))
		AddMenuItem(hMenu, "11", LMC_Translate(iClient, "%t", "Chopper Pilot"), iSavedModel[iClient] == 11 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sUnCommonPaths[LMCUnCommonModelType_Ceda]))
		AddMenuItem(hMenu, "12", LMC_Translate(iClient, "%t", "CEDA"), iSavedModel[iClient] == 12 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sUnCommonPaths[LMCUnCommonModelType_Clown]))
		AddMenuItem(hMenu, "13", LMC_Translate(iClient, "%t", "Clown"), iSavedModel[iClient] == 13 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sUnCommonPaths[LMCUnCommonModelType_Jimmy]))
		AddMenuItem(hMenu, "14", LMC_Translate(iClient, "%t", "Jimmy Gibs"), iSavedModel[iClient] == 14 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sUnCommonPaths[LMCUnCommonModelType_Fallen]))
		AddMenuItem(hMenu, "15", LMC_Translate(iClient, "%t", "Fallen Survivor"), iSavedModel[iClient] == 15 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sHumanPaths[LMCHumanModelType_Nick]))
		AddMenuItem(hMenu, "16", LMC_Translate(iClient, "%t", "Nick"), iSavedModel[iClient] == 16 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sHumanPaths[LMCHumanModelType_Rochelle]))
		AddMenuItem(hMenu, "17", LMC_Translate(iClient, "%t", "Rochelle"), iSavedModel[iClient] == 17 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sHumanPaths[LMCHumanModelType_Coach]))
		AddMenuItem(hMenu, "18", LMC_Translate(iClient, "%t", "Coach"), iSavedModel[iClient] == 18 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sHumanPaths[LMCHumanModelType_Ellis]))
		AddMenuItem(hMenu, "19", LMC_Translate(iClient, "%t", "Ellis"), iSavedModel[iClient] == 19 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sHumanPaths[LMCHumanModelType_Bill]))
		AddMenuItem(hMenu, "20", LMC_Translate(iClient, "%t", "Bill"), iSavedModel[iClient] == 20 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sHumanPaths[LMCHumanModelType_Zoey]))// not going to filter light model other checks will get that.
		AddMenuItem(hMenu, "21", LMC_Translate(iClient, "%t", "Zoey"), iSavedModel[iClient] == 21 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sHumanPaths[LMCHumanModelType_Francis]))// not going to filter light model other checks will get that.
		AddMenuItem(hMenu, "22", LMC_Translate(iClient, "%t", "Francis"), iSavedModel[iClient] == 22 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	if(IsModelPrecached(sHumanPaths[LMCHumanModelType_Louis]))
		AddMenuItem(hMenu, "23", LMC_Translate(iClient, "%t", "Louis"), iSavedModel[iClient] == 23 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);

	if(g_bTankModel)
	{
		if(IsModelPrecached(sSpecialPaths[LMCSpecialModelType_Tank]))
			AddMenuItem(hMenu, "24", LMC_Translate(iClient, "%t", "Tank"), iSavedModel[iClient] == 24 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
		if(IsModelPrecached(sSpecialPaths[LMCSpecialModelType_TankDLC3]))
			AddMenuItem(hMenu, "25", LMC_Translate(iClient, "%t", "Tank DLC"), iSavedModel[iClient] == 25 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	}
	SetMenuExitButton(hMenu, true);

	DisplayMenuAtItem(hMenu, iClient, iCurrentPage[iClient], 15);
}

int CharMenu(Handle hMenu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[4];
			GetMenuItem(hMenu, param2, sItem, sizeof(sItem));
			ModelIndex(param1, StringToInt(sItem), true);
			iCurrentPage[param1] = GetMenuSelectionPosition();
			ShowMenu(param1);
		}
		case MenuAction_Cancel:
		{
			iCurrentPage[param1] = 0;
		}
		case MenuAction_End:
		{
			CloseHandle(hMenu);
		}
	}

	return 0;
}

void ModelIndex(int iClient, int iCaseNum, bool bUsingMenu=false)
{
	if(AreClientCookiesCached(iClient) && bUsingMenu)
	{
		char sCookie[3];
		IntToString(iCaseNum, sCookie, sizeof(sCookie));
		SetClientCookie(iClient, hCookie_LmcCookie, sCookie);
	}
	iSavedModel[iClient] = iCaseNum;

	if(!IsPlayerAlive(iClient))
		return;

	switch(GetClientTeam(iClient))
	{
		case 3:
		{
			switch(GetEntProp(iClient, Prop_Send, "m_zombieClass"))
			{
				case ZOMBIECLASS_SMOKER:
				{
					if(!g_bAllowSmoker)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[iClient][0])
							return;

						LMC_CPrintToChat(iClient, "%t", "Disabled_Models_Smoker"); // "\x04[LMC] \x03Server Has Disabled Models for \x04Smoker");
						bAutoBlockedMsg[iClient][0] = false;
						return;
					}
				}
				case ZOMBIECLASS_BOOMER:
				{
					if(!g_bAllowBoomer)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[iClient][1])
							return;

						LMC_CPrintToChat(iClient, "%t", "Disabled_Models_Boomer"); // "\x04[LMC] \x03Server Has Disabled Models for \x04Boomer");
						bAutoBlockedMsg[iClient][1] = false;
						return;
					}
				}
				case ZOMBIECLASS_HUNTER:
				{
					if(!g_bAllowHunter)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[iClient][2])
							return;

						LMC_CPrintToChat(iClient, "%t", "Disabled_Models_Hunter"); // "\x04[LMC] \x03Server Has Disabled Models for \x04Hunter");
						bAutoBlockedMsg[iClient][2] = false;
						return;
					}
				}
				case ZOMBIECLASS_SPITTER:
				{
					if(!bUsingMenu && !bAutoBlockedMsg[iClient][3])
						return;

					LMC_CPrintToChat(iClient, "%t", "Unsupported_Spitter"); // "\x04[LMC] \x03Models Don't Work for \x04Spitter");
					bAutoBlockedMsg[iClient][3] = false;
					return;
				}
				case ZOMBIECLASS_JOCKEY:
				{
					if(!bUsingMenu && !bAutoBlockedMsg[iClient][4])
						return;

					LMC_CPrintToChat(iClient, "%t", "Unsupported_Jockey"); // "\x04[LMC] \x03Models Don't Work for \x04Jockey");
					bAutoBlockedMsg[iClient][4] = false;
					return;
				}
				case ZOMBIECLASS_CHARGER:
				{
					if(IsFakeClient(iClient))
						return;

					if(!bUsingMenu && !bAutoBlockedMsg[iClient][5])
						return;

					LMC_CPrintToChat(iClient, "%t", "Unsupported_Charger"); // "\x04[LMC] \x03Models Don't Work for \x04Charger");
					bAutoBlockedMsg[iClient][5] = false;
					return;
				}
				case ZOMBIECLASS_TANK:
				{
					if(!g_bAllowTank)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[iClient][6])
							return;

						LMC_CPrintToChat(iClient, "%t", "Disabled_Models_Tank"); // "\x04[LMC] \x03Server Has Disabled Models for \x04Tank");
						bAutoBlockedMsg[iClient][6] = false;
						return;
					}
				}
			}
		}
		case 2:
		{
			if(!g_bAllowSurvivors)
			{
				if(!bUsingMenu && !bAutoBlockedMsg[iClient][7])
					return;

				LMC_CPrintToChat(iClient, "%t", "Disabled_Models_Survivors"); // "\x04[LMC] \x03Server Has Disabled Models for \x04Survivors");
				bAutoBlockedMsg[iClient][7] = false;
				return;
			}
		}
		default:
			return;
	}

	//model selection
	switch(iCaseNum)
	{
		case 1:
		{
			ResetDefaultModel(iClient);
			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Default_Models"); // "\x04[LMC] \x03Models will be default");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
			return;
		}
		case 2:
		{
			static int iChoice = 0;//+1 each time any player picks a common infected
			static int iLastValidModel = 0;// just try until we have a valid model to give people.
			if(!IsModelValid(iClient, LMCModelSectionType_Common, iChoice))
			{
				if(IsModelValid(iClient, LMCModelSectionType_Common, iLastValidModel))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sCommonPaths[iLastValidModel]));
			}
			else
			{
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sCommonPaths[iChoice]));
				iLastValidModel = iChoice;
			}

			if(++iChoice >= COMMON_MODEL_PATH_SIZE)
				iChoice = 0;

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Common"); // "\x04[LMC] \x03Model is \x04Common Infected");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 3:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Witch)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Witch]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Witch"); // "\x04[LMC] \x03Model is \x04Witch");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 4:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_WitchBride)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_WitchBride]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Witch_Bride"); // "\x04[LMC] \x03Model is \x04Witch Bride");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 5:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Boomer)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Boomer]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Boomer"); // "\x04[LMC] \x03Model is \x04Boomer");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 6:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Boomette)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Boomette]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Boomette"); // "\x04[LMC] \x03Model is \x04Boomette");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 7:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Hunter)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Hunter]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;
			LMC_CPrintToChat(iClient, "%t", "Model_Hunter"); // "\x04[LMC] \x03Model is \x04Hunter");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 8:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Smoker)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Smoker]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Smoker"); // "\x04[LMC] \x03Model is \x04Smoker");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 9:
		{
			if(IsModelValid(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_RiotCop)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_RiotCop]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_RiotCop"); // "\x04[LMC] \x03Model is \x04RiotCop");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 10:
		{
			if(IsModelValid(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_MudMan)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_MudMan]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_MudMen"); // "\x04[LMC] \x03Model is \x04MudMen");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 11:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Pilot)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Pilot]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Chopper_Pilot"); // "\x04[LMC] \x03Model is \x04Chopper Pilot");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 12:
		{
			if(IsModelValid(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_Ceda)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_Ceda]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_CEDA"); // "\x04[LMC] \x03Model is \x04CEDA Suit");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 13:
		{
			if(IsModelValid(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_Clown)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_Clown]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Clown"); // "\x04[LMC] \x03Model is \x04Clown");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 14:
		{
			if(IsModelValid(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_Jimmy)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_Jimmy]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Jimmy_Gibs"); // "\x04[LMC] \x03Model is \x04Jimmy Gibs");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 15:
		{
			if(IsModelValid(iClient, LMCModelSectionType_UnCommon, view_as<int>(LMCUnCommonModelType_Fallen)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sUnCommonPaths[LMCUnCommonModelType_Fallen]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Fallen_Survivor"); // "\x04[LMC] \x03Model is \x04Fallen Survivor");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}

		case 16:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Nick)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Nick]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Nick"); // "\x04[LMC] \x03Model is \x04Nick");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 17:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Rochelle)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Rochelle]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Rochelle"); // "\x04[LMC] \x03Model is \x04Rochelle");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 18:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Coach)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Coach]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Coach"); // "\x04[LMC] \x03Model is \x04Coach");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 19:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Ellis)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Ellis]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Ellis"); // "\x04[LMC] \x03Model is \x04Ellis");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 20:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Bill)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Bill]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Bill"); // "\x04[LMC] \x03Model is \x04Bill");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 21:
		{
			if(GetRandomInt(1, 100) >= 50)
			{
				if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Zoey)))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Zoey]));
			}
			else
			{
				if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_ZoeyLight)))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_ZoeyLight]));
				else if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Zoey)))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Zoey]));
			}

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Zoey"); // "\x04[LMC] \x03Model is \x04Zoey");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 22:
		{
			if(GetRandomInt(1, 100) >= 50)
			{
				if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Francis)))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Francis]));
			}
			else
			{
				if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_FrancisLight)))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_FrancisLight]));
				else if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Francis)))
					LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Francis]));
			}

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Francis"); // "\x04[LMC] \x03Model is \x04Francis");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 23:
		{
			if(IsModelValid(iClient, LMCModelSectionType_Human, view_as<int>(LMCHumanModelType_Louis)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sHumanPaths[LMCHumanModelType_Louis]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Louis"); // "\x04[LMC] \x03Model is \x04Louis");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 24:
		{
			if(!g_bTankModel)
				return;

			if(IsModelValid(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_Tank)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_Tank]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Tank"); // "\x04[LMC] \x03Model is \x04Tank");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
		case 25:
		{
			if(!g_bTankModel)
				return;

			if(IsModelValid(iClient, LMCModelSectionType_Special, view_as<int>(LMCSpecialModelType_TankDLC3)))
				LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sSpecialPaths[LMCSpecialModelType_TankDLC3]));

			if(!bUsingMenu && !bAutoApplyMsg[iClient])
				return;

			LMC_CPrintToChat(iClient, "%t", "Model_Tank_DLC"); // "\x04[LMC] \x03Model is \x04Tank DLC");
			SetExternalView(iClient);
			bAutoApplyMsg[iClient] = false;
		}
	}
	bAutoApplyMsg[iClient] = false;
}

public void OnClientPostAdminCheck(int iClient)
{
	if(IsFakeClient(iClient))
		return;

	if(g_iAnnounceMode != 0)
		CreateTimer(g_fAnnounceDelay, iClientInfo, GetClientUserId(iClient), TIMER_FLAG_NO_MAPCHANGE);
}

Action iClientInfo(Handle hTimer, any iUserID)
{
	int iClient = GetClientOfUserId(iUserID);
	if(!iClient || !IsClientInGame(iClient) || IsFakeClient(iClient))
		return Plugin_Continue;

	if(HasAccess(iClient, g_sCvar_AdminFlag) == false)
		return Plugin_Continue;

	switch(g_iAnnounceMode)
	{
		case 1:
		{
			LMC_CPrintToChat(iClient, "%t", "Change_Model_Help_Chat"); // "\x04[LMC] \x03To Change Model use chat Command \x04!lmc\x03");
			EmitSoundToClient(iClient, sJoinSound, SOUND_FROM_PLAYER, SNDCHAN_STATIC);
		}
		case 2: PrintHintText(iClient, "%s", LMC_TranslateNoColor(iClient, "%t", "Change_Model_Help_Chat")); // "[LMC] To Change Model use chat Command !lmc");
		case 3:
		{
			int iEntity = CreateEntityByName("env_instructor_hint");
			if(iEntity <= MaxClients)
				return Plugin_Continue;

			char sValues[64];

			FormatEx(sValues, sizeof(sValues), "hint%d", iClient);
			DispatchKeyValue(iClient, "targetname", sValues);
			DispatchKeyValue(iEntity, "hint_target", sValues);

			Format(sValues, sizeof(sValues), "10");
			DispatchKeyValue(iEntity, "hint_timeout", sValues);
			DispatchKeyValue(iEntity, "hint_range", "100");
			DispatchKeyValue(iEntity, "hint_icon_onscreen", "icon_tip");
			DispatchKeyValue(iEntity, "hint_caption", LMC_TranslateNoColor(iClient, "%t", "Change_Model_Help_Chat")); // "[LMC] To Change Model use chat Command !lmc");
			Format(sValues, sizeof(sValues), "%i %i %i", GetRandomInt(1, 255), GetRandomInt(100, 255), GetRandomInt(1, 255));
			DispatchKeyValue(iEntity, "hint_color", sValues);
			DispatchSpawn(iEntity);
			AcceptEntityInput(iEntity, "ShowHint", iClient);

			SetVariantString("OnUser1 !self:Kill::6:1");
			AcceptEntityInput(iEntity, "AddOutput");
			AcceptEntityInput(iEntity, "FireUser1");
		}
	}
	return Plugin_Continue;
}

bool IsModelValid(int iClient, LMCModelSectionType iModelSectionType, int iModelIndex)
{
	char sCurrentModel[PLATFORM_MAX_PATH];
	GetClientModel(iClient, sCurrentModel, sizeof(sCurrentModel));

	switch(iModelSectionType)
	{
		case LMCModelSectionType_Human:
		{
			bool bSameModel = false;
			bSameModel = StrEqual(sCurrentModel, sHumanPaths[iModelIndex], false);
			if(!bSameModel && IsModelPrecached(sHumanPaths[iModelIndex]))
				return true;

			if(bSameModel)
				ResetDefaultModel(iClient);

			return false;
		}
		case LMCModelSectionType_Special:
		{
			bool bSameModel = false;
			bSameModel = StrEqual(sCurrentModel, sSpecialPaths[iModelIndex], false);
			if(!bSameModel && IsModelPrecached(sSpecialPaths[iModelIndex]))
				return true;

			if(bSameModel)
				ResetDefaultModel(iClient);

			return false;
		}
		case LMCModelSectionType_UnCommon:
		{
			bool bSameModel = false;
			bSameModel = StrEqual(sCurrentModel, sUnCommonPaths[iModelIndex], false);
			if(!bSameModel && IsModelPrecached(sUnCommonPaths[iModelIndex]))
				return true;

			if(bSameModel)
				ResetDefaultModel(iClient);

			return false;
		}
		case LMCModelSectionType_Common:
		{
			bool bSameModel = false;
			bSameModel = StrEqual(sCurrentModel, sCommonPaths[iModelIndex], false);
			if(!bSameModel && IsModelPrecached(sCommonPaths[iModelIndex]))
				return true;

			if(bSameModel)
				ResetDefaultModel(iClient);

			return false;
		}
	}
	ResetDefaultModel(iClient);
	return false;

}

void ResetDefaultModel(int iClient)
{
	int iOverlayModel = LMC_GetClientOverlayModel(iClient);
	if(iOverlayModel > -1)
		AcceptEntityInput(iOverlayModel, "kill");

	LMC_ResetRenderMode(iClient);
}

public void OnClientDisconnect(int iClient)
{
	//1.3
	if(AreClientCookiesCached(iClient))
	{
		char sCookie[3];
		IntToString(iSavedModel[iClient], sCookie, sizeof(sCookie));
		SetClientCookie(iClient, hCookie_LmcCookie, sCookie);
	}
	iCurrentPage[iClient] = 0;
	bAutoApplyMsg[iClient] = true;//1.4
	for(int i = 0; i < sizeof(bAutoBlockedMsg[]); i++)//1.4
		bAutoBlockedMsg[iClient][i] = true;

	iSavedModel[iClient] = 0;
}

public void OnClientCookiesCached(int iClient)
{
	char sCookie[3];
	GetClientCookie(iClient, hCookie_LmcCookie, sCookie, sizeof(sCookie));
	if(StrEqual(sCookie, "\0", false))
		return;

	iSavedModel[iClient] = StringToInt(sCookie);

	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return;

	if(HasAccess(iClient, g_sCvar_AdminFlag) == false)
			return;

	ModelIndex(iClient, iSavedModel[iClient], false);
}

public void LMC_OnClientModelApplied(int iClient, int iEntity, const char sModel[PLATFORM_MAX_PATH], bool bBaseReattach)
{
	if(bBaseReattach)//if true because orignal overlay model has been killed
		LMC_L4D2_SetTransmit(iClient, iEntity);
}

void SetExternalView(int iClient)
{
	if(g_fThirdPersonTime < 0.5)// best time any lower is kinda pointless
		return;

	float fCurrentTPtime = GetForcedThirdPerson(iClient);
	float fTime = GetGameTime();
	if(fCurrentTPtime > (fTime + g_fThirdPersonTime))
		return;

	if(fCurrentTPtime < fTime + 0.5)
		if(fCurrentTPtime > fTime - 1.0)//helps to prevent a strange rare bug with models that include particles(e.g. witch) model spamming just about to go back to firstperson, causing stuff to not render correctly (Could be only me) this seems to be client bug, this only seems to happen on maps with modded func_precipitation.
			return;

	SetEntPropFloat(iClient, Prop_Send, "m_TimeForceExternalView", fTime + g_fThirdPersonTime);
}

float GetForcedThirdPerson(int iClient)
{
	return GetEntPropFloat(iClient, Prop_Send, "m_TimeForceExternalView");
}

bool HasAccess(int client, char[] sAcclvl)
{
	// no permissions set
	if (strlen(sAcclvl) == 0)
		return true;

	else if (StrEqual(sAcclvl, "-1"))
		return false;

	// check permissions
	int flag = GetUserFlagBits(client);
	if ( flag & ReadFlagString(sAcclvl) || flag & ADMFLAG_ROOT )
	{
		return true;
	}

	return false;
}