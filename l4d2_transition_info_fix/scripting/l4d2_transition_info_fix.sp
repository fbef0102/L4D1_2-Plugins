/*====================================================
1.0.1 - 2023/5/25
	  - Updated signature. Thanks to "sorallll" for provide.

1.0
	- Initial release
======================================================*/
#pragma newdecls required

#include <sdktools>
#include <sourcemod>
#include <dhooks>

bool bTransition, bIsVersus
Handle hServerShutdown
Address pCDirector

public Plugin myinfo = 
{
	name = "Transition Info Fix",
	author = "IA/NanaNana",
	description = "Fix the transition info bug",
	version = "1.0.2-2024/12/30",
	url = "http://steamcommunity.com/profiles/76561198291983872"
}

public void OnPluginStart()
{
	GameData gamedata = new GameData("l4d2_transition_info_fix");
	Handle z;

	if((z = DHookCreateFromConf(gamedata, "ChangeLevelNow"))) DHookEnableDetour(z, true, DH_ChangeLevelNow)
	else SetFailState("Detour ChangeLevelNow invalid.");

	if(!(pCDirector = GameConfGetAddress(gamedata, "CDirector"))) SetFailState("Address CDirector invalid.")

	StartPrepSDKCall(SDKCall_Raw);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "ServerShutdown")
	if(!(hServerShutdown = EndPrepSDKCall())) SetFailState("Signature ServerShutdown invalid.")

	HookEntityOutput("info_gamemode", "OnCoop", OnGameMode)
	HookEntityOutput("info_gamemode", "OnVersus", OnGameMode)
	HookEntityOutput("info_gamemode", "OnSurvival", OnGameMode)
	HookEntityOutput("info_gamemode", "OnScavenge", OnGameMode)

	delete gamedata;
	delete z;
	
	CreateConVar("l4d2_transition_info_fix_version", "1.0.1", _, FCVAR_NOTIFY|FCVAR_DONTRECORD);
}

public void OnGameMode(const char[] output, int caller, int activator, float delay)
{
	bIsVersus = strcmp(output[2], "Versus") == 0
}

MRESReturn DH_ChangeLevelNow(int i, Handle hReturn, Handle hParams)
{
	bTransition = true
	return MRES_Ignored
}

public void OnMapEnd()
{
	if(!bTransition && !bIsVersus)
	{
		SDKCall(hServerShutdown, pCDirector)
	}
	bTransition = false
}