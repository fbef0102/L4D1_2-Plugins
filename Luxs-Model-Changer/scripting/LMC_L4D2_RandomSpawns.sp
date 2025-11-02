/*  
*    LMC_L4D2_RandomSpawns - Makes lmc models random for humans&ai
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

#define REQUIRE_PLUGIN
#include <LMCL4D2SetTransmit>
#include <LMCCore>
#undef REQUIRE_PLUGIN

#pragma newdecls required

#define PLUGIN_NAME "LMC_L4D2_RandomSpawns"
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
static Handle hCvar_ArrayIndex[CvarIndexes] = {INVALID_HANDLE, ...};

static bool g_bAllowTank = false;
static bool g_bAllowHunter = true;
static bool g_bAllowSmoker = true;
static bool g_bAllowBoomer = true;
static bool g_bAllowSurvivors = true;

static Handle hCvar_RNGHumans = INVALID_HANDLE;
static Handle hCvar_Survivors = INVALID_HANDLE;
static Handle hCvar_Infected = INVALID_HANDLE;
static bool g_bRNGHumans = false;
static int g_iChanceSurvivor = 10;
static int g_iChanceInfected = 20;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if(GetEngineVersion() != Engine_Left4Dead2 )
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
	description = "Makes lmc models random for humans&ai",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2607394"
};

public void OnPluginStart()
{
	CreateConVar("lmc_l4d2_randomspawns_version", PLUGIN_VERSION, "LMC_RandomAiSpawns_Version", FCVAR_DONTRECORD|FCVAR_NOTIFY);
	hCvar_RNGHumans = CreateConVar("lmc_rng_humans", "0", "Allow humans to be considered by rng, menu selection will overwrite this in LMC_Menu_Choosing", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_Survivors = CreateConVar("lmc_rng_model_survivor", "10", "(0 = disable custom models)chance on which will get a custom model, [1~100]%", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	hCvar_Infected = CreateConVar("lmc_rng_model_infected", "20", "(0 = disable custom models)chance on which will get a custom model, [1~100]%\nDoes not work in Jockey, Charger, Spitter ", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	HookConVarChange(hCvar_RNGHumans, eConvarChanged);
	HookConVarChange(hCvar_Survivors, eConvarChanged);
	HookConVarChange(hCvar_Infected, eConvarChanged);
	AutoExecConfig(true, "LMC_L4D2_RandomSpawns");
	CvarsChanged();
	
	HookEvent("player_spawn", ePlayerSpawn);
}

void eConvarChanged(Handle hCvar, const char[] sOldVal, const char[] sNewVal)
{
	CvarsChanged();
}

void CvarsChanged()
{
	if(hCvar_ArrayIndex[0] != INVALID_HANDLE)
		g_bAllowTank = GetConVarInt(hCvar_ArrayIndex[0]) > 0;
	if(hCvar_ArrayIndex[1] != INVALID_HANDLE)
		g_bAllowHunter = GetConVarInt(hCvar_ArrayIndex[1]) > 0;
	if(hCvar_ArrayIndex[2] != INVALID_HANDLE)
		g_bAllowSmoker = GetConVarInt(hCvar_ArrayIndex[2]) > 0;
	if(hCvar_ArrayIndex[3] != INVALID_HANDLE)
		g_bAllowBoomer = GetConVarInt(hCvar_ArrayIndex[3]) > 0;
	if(hCvar_ArrayIndex[4] != INVALID_HANDLE)
		g_bAllowSurvivors = GetConVarInt(hCvar_ArrayIndex[4]) > 0;
	
	g_bRNGHumans = GetConVarInt(hCvar_RNGHumans) > 0;
	g_iChanceSurvivor = GetConVarInt(hCvar_Survivors);
	g_iChanceInfected = GetConVarInt(hCvar_Infected);
}

void HookCvars()
{
	for(int i = 0; i < CvarIndexes; i++)
	{
		if(hCvar_ArrayIndex[i] != INVALID_HANDLE)
			continue;
		
		if((hCvar_ArrayIndex[i] = FindConVar(sSharedCvarNames[i])) == INVALID_HANDLE)
		{
			PrintToServer("[LMC]Unable to find shared cvar \"%s\" using fallback value plugin:(%s)", sSharedCvarNames[i], PLUGIN_NAME);
			continue;
		}
		HookConVarChange(hCvar_ArrayIndex[i], eConvarChanged);
	}
}

public void OnMapStart()
{
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
	int iUserID = GetEventInt(hEvent, "userid");
	int iClient = GetClientOfUserId(iUserID);
	if(iClient < 1 || iClient > MaxClients)
		return;
	
	
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return;
	
	LMC_ResetRenderMode(iClient);
	
	if(!g_bRNGHumans && !IsFakeClient(iClient))
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
	
	RequestFrame(NextFrame, iUserID);
}

void NextFrame(int iUserID)
{
	int iClient = GetClientOfUserId(iUserID);
	if(iClient < 1 || !IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return;
	
	if(LMC_GetClientOverlayModel(iClient) > -1)
		return;
	
	char sModel[PLATFORM_MAX_PATH];
	
	switch(GetClientTeam(iClient))
	{
		case 2:
			if(GetRandomInt(1, 100) <= g_iChanceSurvivor)
				if(!ChooseRNGModel(sModel))
					return;
		case 3:
			if(GetRandomInt(1, 100) <= g_iChanceInfected)
				if(!ChooseRNGModel(sModel))
					return;
		default:
			return;
	}
	
	if(sModel[0] == '\0')
		return;
	
	if(!SameModel(iClient, sModel))
		if(IsModelPrecached(sModel))
			LMC_L4D2_SetTransmit(iClient, LMC_SetClientOverlayModel(iClient, sModel));
}

bool ChooseRNGModel(char sModel[PLATFORM_MAX_PATH])
{
	sModel[0] = '\0';
	if(g_aModel_TotalList.Length <= 0) return false;

	int randomtype = GetRandomInt(view_as<int>(LMCModelSectionType_Human), view_as<int>(LMCModelSectionType_Common));
	if(g_aModel_List[randomtype].Length <= 0) return false;

	CModelData cModelData;
	int random = GetRandomInt(0, g_aModel_List[randomtype].Length-1);

	g_aModel_List[randomtype].GetArray(random, cModelData, sizeof cModelData);
	FormatEx(sModel, sizeof(sModel), "%s", cModelData.m_sModelPath);

	return true;
}

bool SameModel(int iClient, const char[] sPendingModel)
{
	char sModel[PLATFORM_MAX_PATH];
	GetEntPropString(iClient, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	return StrEqual(sModel, sPendingModel, false);
}

public void LMC_OnClientModelApplied(int iClient, int iEntity, const char sModel[PLATFORM_MAX_PATH], bool bBaseReattach)
{
	if(bBaseReattach)//if true because orignal overlay model has been killed
		LMC_L4D2_SetTransmit(iClient, iEntity);
}