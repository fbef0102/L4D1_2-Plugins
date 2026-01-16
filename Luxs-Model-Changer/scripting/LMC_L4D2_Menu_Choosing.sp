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
#include <multicolors>
#include <LMCCore>
#include <LMCL4D2SetTransmit>
#include <clientprefs>

#pragma newdecls required

#define PLUGIN_NAME "LMC_L4D2_Menu_Choosing"
#define PLUGIN_VERSION "1.0h-2025/11/02"

#define DATA_FILE		        "data/LMC_L4D_Model_Data.cfg"

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
	LMCModelSectionType_Common,
	LMCModelSectionType_Max,
};

enum struct CModelData
{
    int m_iIndex;
    char m_sModelPath[256];
    char m_sName[128];

    void Reset()
    {
        this.m_iIndex = 0;
        this.m_sModelPath[0] = '\0';
        this.m_sName[0] = '\0';
    }
}

ArrayList
    g_aModel_List[LMCModelSectionType_Max],
	g_aModel_TotalList;

#define CvarIndexes 5
static const char sSharedCvarNames[CvarIndexes][] =
{
	"lmc_allowtank",
	"lmc_allowhunter",
	"lmc_allowsmoker",
	"lmc_allowboomer",
	"lmc_allowSurvivors",
};

static const char sJoinSound[] = "ui/menu_countdown.wav";

static Handle hCvar_ArrayIndex[CvarIndexes] = {null, ...};

static bool g_bAllowTank = false;
static bool g_bAllowHunter = true;
static bool g_bAllowSmoker = true;
static bool g_bAllowBoomer = true;
static bool g_bAllowSurvivors = true;

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
	hCvar_ThirdPersonTime 	= CreateConVar("lmc_thirdpersontime", 	"1.0", 	"How long (in seconds) the client will be in thirdperson view after selecting a model from !lmc command. (0.5 < = off)", FCVAR_NOTIFY, true, 0.0, true, 360.0);
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
	PrecacheSound(sJoinSound, true);

	HookCvars();
	CvarsChanged();

	LoadData();
}

void LoadData()
{
	for(LMCModelSectionType i = LMCModelSectionType_Human; i < LMCModelSectionType_Max; i++)
	{
		delete g_aModel_List[i];
		g_aModel_List[i] = new ArrayList(sizeof(CModelData));
	}

	delete g_aModel_TotalList;
	g_aModel_TotalList = new ArrayList(sizeof(CModelData));

	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), DATA_FILE);
	if( !FileExists(sPath) )
	{
		SetFailState("File Not Found: %s", sPath);
		return;
	}

	// Load config
	KeyValues hFile = new KeyValues("LMC_L4D_Model_Data");
	if( !hFile.ImportFromFile(sPath) )
	{
		SetFailState("File Format Not Correct: %s", sPath);
		delete hFile;
		return;
	}

	int index;
	char sTemp[4];
	if(hFile.JumpToKey("Left4Dead2"))
	{
		if(hFile.JumpToKey("Human"))
		{
			for(index = 1; index > 0; index++)
			{
				FormatEx(sTemp, sizeof(sTemp), "%d", index);

				if(hFile.JumpToKey(sTemp) == false) break;

				CModelData cModelData;
				cModelData.Reset();

				cModelData.m_iIndex = index;
				hFile.GetString("model", cModelData.m_sModelPath, sizeof(CModelData::m_sModelPath), cModelData.m_sModelPath);
				hFile.GetString("Name", cModelData.m_sName, sizeof(CModelData::m_sModelPath), cModelData.m_sName);

				if(strlen(cModelData.m_sModelPath) <= 0) continue;
				PrecacheModel(cModelData.m_sModelPath, true);

				g_aModel_List[LMCModelSectionType_Human].PushArray(cModelData, sizeof CModelData);
				g_aModel_TotalList.PushArray(cModelData, sizeof CModelData);

				hFile.GoBack();
			}

			hFile.GoBack();
		}

		if(hFile.JumpToKey("Special_Infected"))
		{
			for(index = 1; index > 0; index++)
			{
				FormatEx(sTemp, sizeof(sTemp), "%d", index);

				if(hFile.JumpToKey(sTemp) == false) break;

				CModelData cModelData;
				cModelData.Reset();

				cModelData.m_iIndex = index;
				hFile.GetString("model", cModelData.m_sModelPath, sizeof(CModelData::m_sModelPath), cModelData.m_sModelPath);
				hFile.GetString("Name", cModelData.m_sName, sizeof(CModelData::m_sModelPath), cModelData.m_sName);

				if(strlen(cModelData.m_sModelPath) <= 0) continue;
				PrecacheModel(cModelData.m_sModelPath, true);

				g_aModel_List[LMCModelSectionType_Special].PushArray(cModelData, sizeof CModelData);
				g_aModel_TotalList.PushArray(cModelData, sizeof CModelData);

				hFile.GoBack();
			}

			hFile.GoBack();
		}

		if(hFile.JumpToKey("Uncommon_Infected"))
		{
			for(index = 1; index > 0; index++)
			{
				FormatEx(sTemp, sizeof(sTemp), "%d", index);

				if(hFile.JumpToKey(sTemp) == false) break;

				CModelData cModelData;
				cModelData.Reset();

				cModelData.m_iIndex = index;
				hFile.GetString("model", cModelData.m_sModelPath, sizeof(CModelData::m_sModelPath), cModelData.m_sModelPath);
				hFile.GetString("Name", cModelData.m_sName, sizeof(CModelData::m_sModelPath), cModelData.m_sName);

				if(strlen(cModelData.m_sModelPath) <= 0) continue;
				PrecacheModel(cModelData.m_sModelPath, true);

				g_aModel_List[LMCModelSectionType_UnCommon].PushArray(cModelData, sizeof CModelData);
				g_aModel_TotalList.PushArray(cModelData, sizeof CModelData);

				hFile.GoBack();
			}

			hFile.GoBack();
		}

		if(hFile.JumpToKey("Common_Infected"))
		{
			for(index = 1; index > 0; index++)
			{
				FormatEx(sTemp, sizeof(sTemp), "%d", index);

				if(hFile.JumpToKey(sTemp) == false) break;

				CModelData cModelData;
				cModelData.Reset();

				cModelData.m_iIndex = index;
				hFile.GetString("model", cModelData.m_sModelPath, sizeof(CModelData::m_sModelPath), cModelData.m_sModelPath);
				hFile.GetString("Name", cModelData.m_sName, sizeof(CModelData::m_sModelPath), cModelData.m_sName);

				if(strlen(cModelData.m_sModelPath) <= 0) continue;
				PrecacheModel(cModelData.m_sModelPath, true);

				g_aModel_List[LMCModelSectionType_Common].PushArray(cModelData, sizeof CModelData);
				g_aModel_TotalList.PushArray(cModelData, sizeof CModelData);

				hFile.GoBack();
			}

			hFile.GoBack();
		}
	}
	else
	{
		SetFailState("File Format Not Correct: %s", sPath);
		delete hFile;
		return;
	}

	delete hFile;
}


void ePlayerSpawn(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(client < 1 || client > MaxClients)
		return;

	if(!IsClientInGame(client) || IsFakeClient(client) || !IsPlayerAlive(client))
		return;

	LMC_ResetRenderMode(client);

	if(HasAccess(client, g_sCvar_AdminFlag) == false)
		return;

	switch(GetClientTeam(client))
	{
		case 3:
		{
			switch(GetEntProp(client, Prop_Send, "m_zombieClass"))//1.4
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


	if(iSavedModel[client] < 1)
		return;

	RequestFrame(NextFrame, GetClientUserId(client));
}

void ePlayerBotReplace(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "player"));
	int iBot = GetClientOfUserId(GetEventInt(hEvent, "bot"));

	if(iBot < 1 || iBot > MaxClients || !IsClientInGame(iBot))
		return;

	if(client < 1 || client > MaxClients || !IsClientInGame(client))
		return;

	if(!IsFakeClient(iBot))
		return;

	LMC_ResetRenderMode(iBot);

	if(HasAccess(client, g_sCvar_AdminFlag) == false)
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

	iSavedModel[iBot] = iSavedModel[client];

	if(iSavedModel[iBot] < 1)
		return;

	RequestFrame(NextFrame, GetClientUserId(iBot));
}

void NextFrame(int iUserID)
{
	int client = GetClientOfUserId(iUserID);
	if(client < 1 || !IsClientInGame(client))
		return;

	ModelIndex(client, "", iSavedModel[client], false);
}

Action ShowMenuCmd(int client, int iArgs)
{
	iCurrentPage[client] = 0;
	ShowMenu(client);

	return Plugin_Handled;
}

/*borrowed some code from csm*/
void ShowMenu(int client)
{
	if(client == 0 || !IsClientInGame(client))
	{
		ReplyToCommand(client, "%T", "In-game only", client); // "[LMC] Menu is in-game only.");
		return;
	}
	if(HasAccess(client, g_sCvar_AdminFlag) == false)
	{
		ReplyToCommand(client, "%T", "Admin only", client);// "\x04[LMC] \x03Model Changer is only available to admins.");
		return;
	}
	if(!IsPlayerAlive(client) && bAutoBlockedMsg[client][8])
	{
		ReplyToCommand(client, "%T", "Alive only", client); // "\x04[LMC] \x03Pick a Model to be Applied NextSpawn");
		bAutoBlockedMsg[client][8] = false;
	}
	Menu hMenu = new Menu(CharMenu);
	SetMenuTitle(hMenu, "%T", "Lux's Model Changer", client);//1.4

	AddMenuItem(hMenu, "0", Translate(client, "%t", "Normal Models"), iSavedModel[client] == 0 ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
	AddMenuItem(hMenu, "random", Translate(client, "%t", "Random Model"));
	
	CModelData cModelData;
	char sIndex[4];
	for(int i = 0; i < g_aModel_TotalList.Length; i++)
	{
		g_aModel_TotalList.GetArray(i, cModelData, sizeof cModelData);
		FormatEx(sIndex, sizeof(sIndex), "%d", i+1);
		AddTranslatedMenuItem(hMenu, i+1, sIndex, cModelData.m_sName, client);
	}
	SetMenuExitButton(hMenu, true);

	DisplayMenuAtItem(hMenu, client, iCurrentPage[client], 15);
}

int CharMenu(Handle hMenu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char sItem[64];
			GetMenuItem(hMenu, param2, sItem, sizeof(sItem));
			ModelIndex(param1, sItem, StringToInt(sItem), true);
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

void ModelIndex(int client, const char[] sItem, int iCaseNum, bool bUsingMenu=false)
{
	if(AreClientCookiesCached(client) && bUsingMenu)
	{
		char sCookie[3];
		IntToString(iCaseNum, sCookie, sizeof(sCookie));
		SetClientCookie(client, hCookie_LmcCookie, sCookie);
	}

	if(!IsPlayerAlive(client))
		return;

	switch(GetClientTeam(client))
	{
		case 3:
		{
			switch(GetEntProp(client, Prop_Send, "m_zombieClass"))
			{
				case ZOMBIECLASS_SMOKER:
				{
					if(!g_bAllowSmoker)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[client][0])
							return;

						CPrintToChat(client, "%T", "Disabled_Models_Smoker", client); // "\x04[LMC] \x03Server Has Disabled Models for \x04Smoker");
						bAutoBlockedMsg[client][0] = false;
						return;
					}
				}
				case ZOMBIECLASS_BOOMER:
				{
					if(!g_bAllowBoomer)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[client][1])
							return;

						CPrintToChat(client, "%T", "Disabled_Models_Boomer", client); // "\x04[LMC] \x03Server Has Disabled Models for \x04Boomer");
						bAutoBlockedMsg[client][1] = false;
						return;
					}
				}
				case ZOMBIECLASS_HUNTER:
				{
					if(!g_bAllowHunter)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[client][2])
							return;

						CPrintToChat(client, "%T", "Disabled_Models_Hunter", client); // "\x04[LMC] \x03Server Has Disabled Models for \x04Hunter");
						bAutoBlockedMsg[client][2] = false;
						return;
					}
				}
				case ZOMBIECLASS_SPITTER:
				{
					if(!bUsingMenu && !bAutoBlockedMsg[client][3])
						return;

					CPrintToChat(client, "%T", "Unsupported_Spitter", client); // "\x04[LMC] \x03Models Don't Work for \x04Spitter");
					bAutoBlockedMsg[client][3] = false;
					return;
				}
				case ZOMBIECLASS_JOCKEY:
				{
					if(!bUsingMenu && !bAutoBlockedMsg[client][4])
						return;

					CPrintToChat(client, "%T", "Unsupported_Jockey", client); // "\x04[LMC] \x03Models Don't Work for \x04Jockey");
					bAutoBlockedMsg[client][4] = false;
					return;
				}
				case ZOMBIECLASS_CHARGER:
				{
					if(IsFakeClient(client))
						return;

					if(!bUsingMenu && !bAutoBlockedMsg[client][5])
						return;

					CPrintToChat(client, "%T", "Unsupported_Charger", client); // "\x04[LMC] \x03Models Don't Work for \x04Charger");
					bAutoBlockedMsg[client][5] = false;
					return;
				}
				case ZOMBIECLASS_TANK:
				{
					if(!g_bAllowTank)
					{
						if(!bUsingMenu && !bAutoBlockedMsg[client][6])
							return;

						CPrintToChat(client, "%T", "Disabled_Models_Tank", client); // "\x04[LMC] \x03Server Has Disabled Models for \x04Tank");
						bAutoBlockedMsg[client][6] = false;
						return;
					}
				}
			}
		}
		case 2:
		{
			if(!g_bAllowSurvivors)
			{
				if(!bUsingMenu && !bAutoBlockedMsg[client][7])
					return;

				CPrintToChat(client, "%T", "Disabled_Models_Survivors", client); // "\x04[LMC] \x03Server Has Disabled Models for \x04Survivors");
				bAutoBlockedMsg[client][7] = false;
				return;
			}
		}
		default:
			return;
	}

	//model selection
	if(strcmp(sItem, "random", false) == 0)
	{
		int iChoice = GetRandomInt(1, g_aModel_TotalList.Length);//+1 each time any player picks a common infected
		iChoice = (iChoice == iSavedModel[client]) ? iChoice +1 : iChoice;
		iChoice = (iChoice == g_aModel_TotalList.Length +1 ) ? 1 : iChoice;

		CModelData cModelData;
		g_aModel_TotalList.GetArray(iChoice-1, cModelData, sizeof cModelData);
		if(!IsModelValid(client, cModelData.m_sModelPath))
		{
			if(iSavedModel[client] > 0)
			{
				g_aModel_TotalList.GetArray(iSavedModel[client]-1, cModelData, sizeof cModelData);
				if(IsModelValid(client, cModelData.m_sModelPath))
				{
					LMC_L4D2_SetTransmit(client, LMC_SetClientOverlayModel(client, cModelData.m_sModelPath));
				}
				else
				{
					iSavedModel[client] = 0;
				}
			}
			else
			{
				iSavedModel[client] = 0;
			}
		}
		else
		{
			LMC_L4D2_SetTransmit(client, LMC_SetClientOverlayModel(client, cModelData.m_sModelPath));
			iSavedModel[client] = iChoice;
		}

		if(!bUsingMenu && !bAutoApplyMsg[client])
			return;

		if(iSavedModel[client] > 0)
		{
			char sModelTransate[128];
			if(TranslationPhraseExists(cModelData.m_sName))
			{
				FormatEx(sModelTransate, sizeof(sModelTransate), "%T", cModelData.m_sName, client);
			}
			else
			{
				FormatEx(sModelTransate, sizeof(sModelTransate), "%s", cModelData.m_sName);
			}
			CPrintToChat(client, "%T", "Model_Set", client, sModelTransate);
		}
		ThirdpersonView(client);
		bAutoApplyMsg[client] = false;
	}
	else
	{
		if(iCaseNum >= g_aModel_TotalList.Length+1) iCaseNum = 0;

		if(iCaseNum == 0)
		{
			ResetDefaultModel(client);
			if(!bUsingMenu && !bAutoApplyMsg[client])
				return;

			CPrintToChat(client, "%T", "Default_Models", client); // "\x04[LMC] \x03Models will be default");
			ThirdpersonView(client);
			bAutoApplyMsg[client] = false;
			iSavedModel[client] = 0;
			return;
		}
		else
		{
			CModelData cModelData;
			g_aModel_TotalList.GetArray(iCaseNum-1, cModelData, sizeof cModelData);
			if(IsModelValid(client, cModelData.m_sModelPath))
				LMC_L4D2_SetTransmit(client, LMC_SetClientOverlayModel(client, cModelData.m_sModelPath));

			if(!bUsingMenu && !bAutoApplyMsg[client])
				return;

			char sModelTransate[128];
			if(TranslationPhraseExists(cModelData.m_sName))
			{
				FormatEx(sModelTransate, sizeof(sModelTransate), "%T", cModelData.m_sName, client);
			}
			else
			{
				FormatEx(sModelTransate, sizeof(sModelTransate), "%s", cModelData.m_sName);
			}
			CPrintToChat(client, "%T", "Model_Set", client, sModelTransate);

			ThirdpersonView(client);
			bAutoApplyMsg[client] = false;
			iSavedModel[client] = iCaseNum;
		}
	}

	bAutoApplyMsg[client] = false;
}

public void OnClientPostAdminCheck(int client)
{
	if(IsFakeClient(client))
		return;

	if(g_iAnnounceMode != 0)
		CreateTimer(g_fAnnounceDelay, clientInfo, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

Action clientInfo(Handle hTimer, any iUserID)
{
	int client = GetClientOfUserId(iUserID);
	if(!client || !IsClientInGame(client) || IsFakeClient(client))
		return Plugin_Continue;

	if(HasAccess(client, g_sCvar_AdminFlag) == false)
		return Plugin_Continue;

	switch(g_iAnnounceMode)
	{
		case 1:
		{
			CPrintToChat(client, "%T", "Change_Model_Help_Chat (C)", client); // "\x04[LMC] \x03To Change Model use chat Command \x04!lmc\x03");
			EmitSoundToClient(client, sJoinSound, SOUND_FROM_PLAYER, SNDCHAN_STATIC);
		}
		case 2: PrintHintText(client, "%T", "Change_Model_Help_Chat", client); // "[LMC] To Change Model use chat Command !lmc");
		case 3:
		{
			int iEntity = CreateEntityByName("env_instructor_hint");
			if(iEntity <= MaxClients)
				return Plugin_Continue;

			char sValues[64];

			FormatEx(sValues, sizeof(sValues), "hint%d", client);
			DispatchKeyValue(client, "targetname", sValues);
			DispatchKeyValue(iEntity, "hint_target", sValues);

			Format(sValues, sizeof(sValues), "10");
			DispatchKeyValue(iEntity, "hint_timeout", sValues);
			DispatchKeyValue(iEntity, "hint_range", "100");
			DispatchKeyValue(iEntity, "hint_icon_onscreen", "icon_tip");
			DispatchKeyValue(iEntity, "hint_caption", Translate(client, "%t", "Change_Model_Help_Chat")); // "[LMC] To Change Model use chat Command !lmc");
			Format(sValues, sizeof(sValues), "%i %i %i", GetRandomInt(1, 255), GetRandomInt(100, 255), GetRandomInt(1, 255));
			DispatchKeyValue(iEntity, "hint_color", sValues);
			DispatchSpawn(iEntity);
			AcceptEntityInput(iEntity, "ShowHint", client);

			SetVariantString("OnUser1 !self:Kill::6:1");
			AcceptEntityInput(iEntity, "AddOutput");
			AcceptEntityInput(iEntity, "FireUser1");
		}
	}
	return Plugin_Continue;
}

bool IsModelValid(int client, const char[] sModel)
{
	char sCurrentModel[PLATFORM_MAX_PATH];
	GetClientModel(client, sCurrentModel, sizeof(sCurrentModel));

	bool bSameModel = false;
	bSameModel = StrEqual(sCurrentModel, sModel, false);
	if(!bSameModel && IsModelPrecached(sModel))
		return true;

	if(bSameModel)
		ResetDefaultModel(client);

	return false;

}

void ResetDefaultModel(int client)
{
	int iOverlayModel = LMC_GetClientOverlayModel(client);
	if(iOverlayModel > -1)
		AcceptEntityInput(iOverlayModel, "kill");

	LMC_ResetRenderMode(client);
}

public void OnClientDisconnect(int client)
{
	//1.3
	if(AreClientCookiesCached(client))
	{
		char sCookie[3];
		IntToString(iSavedModel[client], sCookie, sizeof(sCookie));
		SetClientCookie(client, hCookie_LmcCookie, sCookie);
	}
	iCurrentPage[client] = 0;
	bAutoApplyMsg[client] = true;//1.4
	for(int i = 0; i < sizeof(bAutoBlockedMsg[]); i++)//1.4
		bAutoBlockedMsg[client][i] = true;

	iSavedModel[client] = 0;
}

public void OnClientCookiesCached(int client)
{
	char sCookie[3];
	GetClientCookie(client, hCookie_LmcCookie, sCookie, sizeof(sCookie));
	if(StrEqual(sCookie, "\0", false))
		return;

	iSavedModel[client] = StringToInt(sCookie);

	if(!IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	if(HasAccess(client, g_sCvar_AdminFlag) == false)
			return;

	ModelIndex(client, "", iSavedModel[client], false);
}

public void LMC_OnClientModelApplied(int client, int iEntity, const char sModel[PLATFORM_MAX_PATH], bool bBaseReattach)
{
	if(bBaseReattach)//if true because orignal overlay model has been killed
		LMC_L4D2_SetTransmit(client, iEntity);
}

void ThirdpersonView(int client)
{
	if(g_fThirdPersonTime < 0.5)// best time any lower is kinda pointless
		return;

	if (GetEntPropFloat(client, Prop_Send, "m_TimeForceExternalView") != 99999.3)
		SetEntPropFloat(client, Prop_Send, "m_TimeForceExternalView", GetGameTime() + g_fThirdPersonTime);
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

void AddTranslatedMenuItem(Menu menu, int index, const char[] opt, const char[] phrase, int client) 
{
    char buffer[128];
    if(TranslationPhraseExists(phrase))
    {
        Format(buffer, sizeof(buffer), "%T", phrase, client);
    }
    else
    {
        Format(buffer, sizeof(buffer), "%s", phrase, client);
    }
    menu.AddItem(opt, buffer, iSavedModel[client] == index ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT);
}

char[] Translate(int client, const char[] format, any ...)
{
	char buffer[192];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);
	return buffer;
}