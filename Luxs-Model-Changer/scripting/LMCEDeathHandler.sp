/*  
*    LMCEDeathHandler - Manages deaths regarding lmc for entities ragdolls, module required to handle (witch & common deaths)
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
#include <LMCCore>

#pragma newdecls required


#define PLUGIN_NAME "LMCEDeathHandler"
#define PLUGIN_VERSION "1.0h-2025/11/02"


public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion iEngineVersion = GetEngineVersion();
	if(iEngineVersion != Engine_Left4Dead2 && iEngineVersion != Engine_Left4Dead)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1/2");
		return APLRes_SilentFailure;
	}
	RegPluginLibrary("LMCEDeathHandler");
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "Lux",
	description = "Manages deaths regarding lmc for entities ragdolls, module required to handle (witch & common deaths)",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2607394"
};

public void OnPluginStart()
{
	CreateConVar("LMCEDeathHandler_version", PLUGIN_VERSION, "LMCL4D2EDeathHandler_version", FCVAR_DONTRECORD|FCVAR_NOTIFY);
}

public void OnAllPluginsLoaded()// makesure my hook is last if it can
{
	HookEvent("player_death", ePlayerDeath);
}

void ePlayerDeath(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iVictim = GetEventInt(hEvent, "entityid");
	if(iVictim < MaxClients+1 || iVictim > 2048 || !IsValidEntity(iVictim))
		return;
	
	int iEntity = LMC_GetEntityOverlayModel(iVictim);
	if(iEntity < 1)
		return;
	
	NextBotRagdollHandler(iVictim, iEntity);
	
}

void NextBotRagdollHandler(int iEntity, int iPreRagdoll)
{
	if(GetEntProp(iEntity, Prop_Send, "m_bIsBurning", 1))
	{
		int iRagdoll = CreateEntityByName("cs_ragdoll");
		if(iRagdoll > 0)
		{
			float fPos[3];
			float fAng[3];
			GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", fPos);
			GetEntPropVector(iEntity, Prop_Data, "m_angRotation", fAng);
			TeleportEntity(iRagdoll, fPos, fAng, NULL_VECTOR);
			
			SetEntProp(iRagdoll, Prop_Send, "m_nModelIndex", GetEntProp(iPreRagdoll, Prop_Send, "m_nModelIndex", 2), 2);
			SetEntProp(iRagdoll, Prop_Send, "m_iTeamNum", 3, 1);
			SetEntProp(iRagdoll, Prop_Send, "m_hPlayer", -1, 3);
			SetEntProp(iRagdoll, Prop_Send, "m_ragdollType", 1, 1);
			SetEntProp(iRagdoll, Prop_Send, "m_bOnFire", 1, 1);
			
			SetVariantString("OnUser1 !self:Kill::0.1:1");
			AcceptEntityInput(iRagdoll, "AddOutput");
			AcceptEntityInput(iRagdoll, "FireUser1");
			AcceptEntityInput(iPreRagdoll, "Kill");
		}
		else
			AcceptEntityInput(iPreRagdoll, "BecomeRagdoll");
	}
	else
		AcceptEntityInput(iPreRagdoll, "BecomeRagdoll");
	
	SDKHook(iEntity, SDKHook_SetTransmit, HideNextBot);
}

Action HideNextBot(int iEntity, int iClient)
{
	return Plugin_Handled;
}