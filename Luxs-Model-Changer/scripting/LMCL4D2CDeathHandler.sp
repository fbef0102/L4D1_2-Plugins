/*  
*    LMCL4D2CDeathHandler - Manages deaths regarding lmc, overlay deathmodels and ragdolls, and fixes clonesurvivors deathmodels teleporting around.
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
#include <sdkhooks>

#define REQUIRE_PLUGIN
#include <LMCCore>
#undef REQUIRE_PLUGIN

#pragma newdecls required


#define PLUGIN_NAME "LMCL4D2CDeathHandler"
#define PLUGIN_VERSION "1.0h-2025/11/02"

static char sModelStrings[MAXPLAYERS+1][PLATFORM_MAX_PATH];

static int iDeathModelRef = INVALID_ENT_REFERENCE;
static int iCSRagdollRef = INVALID_ENT_REFERENCE;
static bool bIgnore = false;

Handle g_hOnClientDeathModelCreated = INVALID_HANDLE;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if(GetEngineVersion() != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2");
		return APLRes_SilentFailure;
	}
	
	RegPluginLibrary("LMCL4D2CDeathHandler");
	g_hOnClientDeathModelCreated  = CreateGlobalForward("LMC_OnClientDeathModelCreated", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "Lux",
	description = "Manages deaths regarding lmc, overlay deathmodels and ragdolls, and fixes clonesurvivors deathmodels teleporting around.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2607394"
};


public void OnPluginStart()
{
	CreateConVar("lmcl4d2cdeathhandler_version", PLUGIN_VERSION, "LMCL4D2CDeathHandler_version", FCVAR_DONTRECORD|FCVAR_NOTIFY);
	HookEvent("player_death", ePlayerDeath);
}

Action SpawnHook(int iClient)
{
	SDKUnhook(iClient, SDKHook_Spawn, SpawnHook);
	SetEntityModel(iClient, sModelStrings[iClient]);

	return Plugin_Continue;
}


public void Cs_Ragdollhandler(int iRagdoll, int iClient)
{
	SDKUnhook(iRagdoll, SDKHook_SetTransmit, Cs_Ragdollhandler);
	int iOwner = GetEntPropEnt(iRagdoll, Prop_Send, "m_hPlayer");
	if(iOwner < 1 || iOwner > MaxClients)
		return;
	
	GetEntPropString(iOwner, Prop_Data, "m_ModelName", sModelStrings[iOwner], PLATFORM_MAX_PATH);
	SDKHook(iOwner, SDKHook_Spawn, SpawnHook);
	SetEntProp(iOwner, Prop_Send, "m_nModelIndex", GetEntProp(iRagdoll, Prop_Send, "m_nModelIndex", 2), 2);
}

public void ePlayerDeath(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iVictim = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(iVictim < 1 || iVictim > MaxClients || !IsClientInGame(iVictim))
		return;
	
	int iTeam = GetClientTeam(iVictim);
	if(iTeam != 2 && iTeam != 3)
		return;
	
	int iEntity = LMC_GetClientOverlayModel(iVictim);
	if(IsValidEntity(iEntity) && IsValidEntRef(iCSRagdollRef) && iVictim == GetEntPropEnt(iCSRagdollRef, Prop_Send, "m_hPlayer"))
	{
		int iRagdoll = EntRefToEntIndex(iCSRagdollRef);
		iCSRagdollRef = INVALID_ENT_REFERENCE;
		iDeathModelRef = INVALID_ENT_REFERENCE;
		
		SetEntProp(iRagdoll, Prop_Send, "m_nModelIndex", GetEntProp(iEntity, Prop_Send, "m_nModelIndex", 2), 2);
		SetEntProp(iRagdoll, Prop_Send, "m_ragdollType", 1);
		SDKHook(iRagdoll, SDKHook_SetTransmit, Cs_Ragdollhandler);
		
		LMC_ResetRenderMode(iVictim);
		AcceptEntityInput(iEntity, "Kill");
		
		iCSRagdollRef = INVALID_ENT_REFERENCE;
		iDeathModelRef = INVALID_ENT_REFERENCE;
		return;
	}
	
	if(iTeam == 2 && IsValidEntRef(iDeathModelRef))
	{
		float fPos[3];
		GetClientAbsOrigin(iVictim, fPos);
		int iEnt = EntRefToEntIndex(iDeathModelRef);
		iDeathModelRef = INVALID_ENT_REFERENCE;
		TeleportEntity(iEnt, fPos, NULL_VECTOR, NULL_VECTOR);// fix valve issue with teleporting clones
		
		if(iEntity > MaxClients && IsValidEntity(iEntity))
		{
			char sModel[PLATFORM_MAX_PATH];
			GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
			AcceptEntityInput(iEntity, "Kill");
			iEntity = -1;
			
			if(sModel[0] != '\0')
			{
				iEntity = LMC_SetEntityOverlayModel(iEnt, sModel);
				SetEntityRenderMode(iEnt, RENDER_NONE);
			}
		}
		Call_StartForward(g_hOnClientDeathModelCreated);
		Call_PushCell(iVictim);
		Call_PushCell(iEnt);
		Call_PushCell(iEntity);
		Call_Finish();
		return;
	}
	
	if(IsValidEntity(iEntity))
		AcceptEntityInput(iEntity, "Kill");
}

public void OnEntityCreated(int iEntity, const char[] sClassname)
{
	if(sClassname[0] != 's' && sClassname[0] != 'c')
		return;
	
	if(StrEqual(sClassname, "cs_ragdoll", false))
		iCSRagdollRef = EntIndexToEntRef(iEntity);
	else if(StrEqual(sClassname, "survivor_death_model", false))
		SDKHook(iEntity, SDKHook_SpawnPost, SpawnPostDeathModel);
}

public void SpawnPostDeathModel(int iEntity)
{
	SDKUnhook(iEntity, SDKHook_SpawnPost, SpawnPostDeathModel);
	if(!IsValidEntity(iEntity))
		return;
	
	iDeathModelRef = EntIndexToEntRef(iEntity);
	
	if(bIgnore)
		return;
	
	bIgnore = true;
	RequestFrame(ClearVar);
}

public void ClearVar(any nothing)
{
	iDeathModelRef = INVALID_ENT_REFERENCE;
	bIgnore = false;
}

static bool IsValidEntRef(int iEntRef)
{
	return (iEntRef != 0 && EntRefToEntIndex(iEntRef) != INVALID_ENT_REFERENCE);
}
