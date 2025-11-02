/*  
*    LMCL4D1SetTransmit - Manages transmitting models to clients in L4D1
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
#include <left4dhooks>
#pragma newdecls required


#define PLUGIN_NAME "LMCL4D1SetTransmit"
#define PLUGIN_VERSION "1.0h-2025/11/02"

enum /*ZOMBIECLASS*/
{
	ZOMBIECLASS_SMOKER = 1,
	ZOMBIECLASS_BOOMER,
	ZOMBIECLASS_HUNTER,
	ZOMBIECLASS_UNKNOWN,
	ZOMBIECLASS_TANK,
}

static int iHiddenOwner[2048+1] = {0, ...};
static bool bThirdPerson[MAXPLAYERS+1] = {false, ...};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if(GetEngineVersion() != Engine_Left4Dead)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead");
		return APLRes_SilentFailure;
	}
	RegPluginLibrary("LMCL4D1SetTransmit");
	CreateNative("LMC_L4D1_SetTransmit", SetTransmit);
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = "Lux",
	description = "Manages transmitting models to clients in L4D1",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2607394"
};

public void OnPluginStart()
{
	CreateConVar("LMCL4D1SetTransmit_version", PLUGIN_VERSION, "LMCL4D1SetTransmit_version", FCVAR_DONTRECORD|FCVAR_NOTIFY);
}

Action HideModel(int iEntity, int client)
{
	if(IsFakeClient(client))
		return Plugin_Continue;
	
	static int iOwner;
	iOwner = GetClientOfUserId(iHiddenOwner[iEntity]);
	if(!IsPlayerAlive(client))
	{
		if(GetEntProp(client, Prop_Send, "m_iObserverMode") == 4)
		{
			if(GetEntPropEnt(client, Prop_Send, "m_hObserverTarget") == iOwner)
			{
				switch(GetClientTeam(iOwner))
				{
					case 2:
					{
						if(IsSurvivorThirdPerson(iOwner, true))
							return Plugin_Continue;
					}
					case 3:
					{
						if(IsInfectedThirdPerson(iOwner, true))
							return Plugin_Continue;
					}
				}
				return Plugin_Handled;
			}
		}
	}
	
	
	if(iOwner < 1 || !IsClientInGame(iOwner))
		return Plugin_Continue;
	
	switch(GetClientTeam(iOwner)) 
	{
		case 2: 
		{
			if(iOwner != client)
				return Plugin_Continue;
			
			if(!IsSurvivorThirdPerson(client, false))
				return Plugin_Handled;
		}
		case 3: 
		{
			static bool bIsGhost;
			bIsGhost = GetEntProp(iOwner, Prop_Send, "m_isGhost", 1) > 0;
			
			if(iOwner != client) 
			{
				//Hide model for everyone else when is ghost mode exapt me
				if(bIsGhost)
					return Plugin_Handled;
			}
			else 
			{
				// Hide my model when not in thirdperson
				if(bIsGhost)
					SetEntityRenderMode(iOwner, RENDER_NONE);
				
				if(!IsInfectedThirdPerson(iOwner, false))
					return Plugin_Handled;
			}
		}
	}
	
	return Plugin_Continue;
}


static bool IsSurvivorThirdPerson(int client, bool bSpecCheck)
{
	if (IsFakeClient(client))
		return false;

	if(!bSpecCheck)
	{
		if(bThirdPerson[client])
			return true;
		
		if(GetEntProp(client, Prop_Send, "m_iObserverMode") == 1)
			return true;
	}

	int Activity = L4D1_GetMainActivity(client);
	switch (Activity) 
	{
		case L4D1_ACT_TERROR_SHOVED_FORWARD, // 1145, 1146, 1147, 1148: stumble
			L4D1_ACT_TERROR_SHOVED_BACKWARD,
			L4D1_ACT_TERROR_SHOVED_LEFTWARD,
			L4D1_ACT_TERROR_SHOVED_RIGHTWARD: 
				return true;

		case L4D1_ACT_TERROR_POUNCED_TO_STAND: // 1263: get up from hunter
			return true;

		case L4D1_ACT_TERROR_HIT_BY_TANKPUNCH, // 1077, 1078, 1079: HIT BY TANK PUNCH
			L4D1_ACT_TERROR_IDLE_FALL_FROM_TANKPUNCH,
			L4D1_ACT_TERROR_TANKPUNCH_LAND:
			return true;
	}

	if (GetEntPropEnt(client, Prop_Send, "m_hViewEntity") > 0)
		return true;
	if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0)
		return true;
	if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0)
	{
		if(Activity == L4D1_ACT_TERROR_PULLED_RUN_RIFLE)
			return false;
		else 
			return true;
	}
	if (GetEntProp(client, Prop_Send, "m_isHangingFromLedge") > 0)
		return true;
	if (GetEntPropEnt(client, Prop_Send, "m_reviveTarget") > 0)
		return true;
	if (GetEntPropEnt(client, Prop_Send, "m_healTarget") > 0)
		return true;

	return false;
}

static bool IsInfectedThirdPerson(int client, bool bSpecCheck)
{
	if (IsFakeClient(client))
		return false;

	if(!bSpecCheck)
	{
		if(bThirdPerson[client])
			return true;
	}

	int Activity = L4D1_GetMainActivity(client);
	switch (Activity) 
	{
		case L4D1_ACT_TERROR_SHOVED_FORWARD, // 1145, 1146, 1147, 1148: stumble
			L4D1_ACT_TERROR_SHOVED_BACKWARD,
			L4D1_ACT_TERROR_SHOVED_LEFTWARD,
			L4D1_ACT_TERROR_SHOVED_RIGHTWARD: 
				return true;
	}

	if(GetEntPropEnt(client, Prop_Send, "m_hViewEntity") > 0)
		return true;

	switch(GetEntProp(client, Prop_Send, "m_zombieClass"))
	{
		case ZOMBIECLASS_SMOKER:
		{
			if(GetEntPropEnt(client, Prop_Send, "m_tongueVictim") > 0) return true;

			int ability = L4D_GetPlayerCustomAbility(client);
			if(ability > MaxClients && GetEntProp(ability, Prop_Send, "m_tongueState") == 2)  return true;
		}
		case ZOMBIECLASS_HUNTER:
		{
			if(GetEntPropEnt(client, Prop_Send, "m_pounceVictim") > 0)
				return true;
		}
		case ZOMBIECLASS_TANK:
		{
			
		}
	}

	return false;
}

public void TP_OnThirdPersonChanged(int client, bool bIsThirdPerson)
{
	bThirdPerson[client] = bIsThirdPerson;
}

int SetTransmit(Handle plugin, int numParams)
{
	if(numParams < 3)
		ThrowNativeError(SP_ERROR_PARAM, "Invalid numParams");
	
	int client = GetNativeCell(1);
	if(client < 1 || client > MaxClients)
		ThrowNativeError(SP_ERROR_PARAM, "Client index out of bounds %i", client);
	
	if(!IsClientInGame(client))
		ThrowNativeError(SP_ERROR_ABORTED, "Client is not ingame %i", client);
	
	int iEntity = GetNativeCell(2);
	if(iEntity < MaxClients+1 || iEntity > 2048)
		ThrowNativeError(SP_ERROR_PARAM, "Entity index out of bounds %i", iEntity);
	
	if(!IsValidEntity(iEntity))
		ThrowNativeError(SP_ERROR_ABORTED, "Entity is Invalid %i", iEntity);
	
	if(GetNativeCell(3))
	{
		iHiddenOwner[iEntity] = GetClientUserId(client);
		SDKHookEx(iEntity, SDKHook_SetTransmit, HideModel);
		return 0;
	}
	SDKUnhook(iEntity, SDKHook_SetTransmit, HideModel);

	return 0;
}
