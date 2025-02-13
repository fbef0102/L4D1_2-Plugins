/*  
*    LMCCore - Core of LMC, manages overlay models
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
#pragma newdecls required

//Cannot really add crazy face toggle without making unnecessary checks

#define PLUGIN_VERSION "3.1.1"

//https://github.com/alliedmodders/hl2sdk/blob/0ef5d3d482157bc0bb3aafd37c08961373f87bfd/public/const.h#L281-L298
// entity effects
enum
{
	EF_BONEMERGE			= 0x001,	// Performs bone merge on client side
	EF_BRIGHTLIGHT 			= 0x002,	// DLIGHT centered at entity origin
	EF_DIMLIGHT 			= 0x004,	// player flashlight
	EF_NOINTERP				= 0x008,	// don't interpolate the next frame
	EF_NOSHADOW				= 0x010,	// Don't cast no shadow
	EF_NODRAW				= 0x020,	// don't draw entity
	EF_NORECEIVESHADOW		= 0x040,	// Don't receive no shadow
	EF_BONEMERGE_FASTCULL	= 0x080,	// For use with EF_BONEMERGE. If this is set, then it places this ent's origin at its
										// parent and uses the parent's bbox + the max extents of the aiment.
										// Otherwise, it sets up the parent's bones every frame to figure out where to place
										// the aiment, which is inefficient because it'll setup the parent's bones even if
										// the parent is not in the PVS.
	EF_ITEM_BLINK			= 0x100,	// blink an item so that the user notices it.
	EF_PARENT_ANIMATES		= 0x200,	// always assume that the parent entity is animating
	EF_MAX_BITS = 10
};

static int iHiddenEntity[2048+1] = {0, ...};
static int iHiddenEntityRef[2048+1];
static int iHiddenIndex[MAXPLAYERS+1] = {0, ...};
static int iHiddenOwner[2048+1] = {0, ...};
static Handle hCvar_AggressiveChecks = INVALID_HANDLE;
static bool g_bAggressiveChecks = false;

Handle g_hOnClientModelApplied = INVALID_HANDLE;
Handle g_hOnClientModelChanged = INVALID_HANDLE;
Handle g_hOnClientModelDestroyed = INVALID_HANDLE;

static bool bL4D2 = false;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion iEngineVersion = GetEngineVersion();
	if(iEngineVersion == Engine_Left4Dead2)
		bL4D2 = true;
	else if(iEngineVersion == Engine_Left4Dead)
		bL4D2 = false;
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1/2");
		return APLRes_SilentFailure;
	}
	
	RegPluginLibrary("L4D2ModelChanger");// for compatibility with older plugins
	RegPluginLibrary("LMCCore");
	CreateNative("LMC_GetClientOverlayModel", GetOverlayModel);
	CreateNative("LMC_SetClientOverlayModel", SetOverlayModel);
	CreateNative("LMC_SetEntityOverlayModel", SetEntityOverlayModel);
	CreateNative("LMC_GetEntityOverlayModel", GetEntityOverlayModel);
	CreateNative("LMC_HideClientOverlayModel", HideOverlayModel);
	CreateNative("LMC_ResetRenderMode", ResetRenderMode);
	
	g_hOnClientModelApplied = CreateGlobalForward("LMC_OnClientModelApplied", ET_Event, Param_Cell, Param_Cell, Param_String, Param_Cell);
	g_hOnClientModelChanged  = CreateGlobalForward("LMC_OnClientModelChanged", ET_Event, Param_Cell, Param_Cell, Param_String);
	g_hOnClientModelDestroyed  = CreateGlobalForward("LMC_OnClientModelDestroyed", ET_Event, Param_Cell, Param_Cell);
	
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "LMCCore",
	author = "Lux",
	description = "Core of LMC, manages overlay models",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2607394"
};


public void OnPluginStart()
{
	CreateConVar("lmccore_version", PLUGIN_VERSION, "LMCCore_version", FCVAR_DONTRECORD|FCVAR_NOTIFY);
	
	hCvar_AggressiveChecks = CreateConVar("lmc_aggressive_model_checks", "0", "1 = (When client has no lmc model (enforce aggressive model showing base model render mode)) 0 = (compatibility mode (should help with plugins like incap crawling) Depends on the plugin)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(hCvar_AggressiveChecks, eConvarChanged);
	CvarsChanged();
	AutoExecConfig(true, "LMCCore");
	
	HookEvent("player_team", eTeamChange);
	HookEvent("player_incapacitated", eSetColour);
	HookEvent("revive_end", eSetColour);
	HookEvent("player_spawn", ePlayerSpawn, EventHookMode_Pre);
}

void eConvarChanged(Handle hCvar, const char[] sOldVal, const char[] sNewVal)
{
	CvarsChanged();
}

void CvarsChanged()
{
	g_bAggressiveChecks = GetConVarInt(hCvar_AggressiveChecks) > 0;
}

void ePlayerSpawn(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(iClient < 1 || iClient > MaxClients)
		return;
	
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return;
	
	if(IsValidEntRef(iHiddenIndex[iClient]))
	{
		AcceptEntityInput(iHiddenIndex[iClient], "kill");
		iHiddenIndex[iClient] = -1;
	}
}

int BeWitched(int iClient, const char[] sModel, const bool bBaseReattach)
{
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return -1;
	
	CheckForSameModel(iClient, sModel);
	
	int iEntity = EntRefToEntIndex(iHiddenIndex[iClient]);
	if(IsValidEntRef(iHiddenIndex[iClient]) && !bBaseReattach)
	{
		SetEntityModel(iEntity, sModel);
		Call_StartForward(g_hOnClientModelChanged);
		Call_PushCell(iClient);
		Call_PushCell(iEntity);
		Call_PushString(sModel);
		Call_Finish();
		return iEntity;
	}
	else if(bBaseReattach)
		AcceptEntityInput(iEntity, "Kill");
	
	iEntity = CreateEntityByName("commentary_dummy");
	if(iEntity < 0)
		return -1;
	
	DispatchKeyValue(iEntity, "model", sModel);
	
	float fVec[3];
	GetClientAbsOrigin(iClient, fVec);
	TeleportEntity(iEntity, fVec, NULL_VECTOR, NULL_VECTOR);
	
	DispatchSpawn(iEntity);
	ActivateEntity(iEntity);
	
	SetAttach(iEntity, iClient);
	
	SetEntityRenderMode(iClient, RENDER_NONE);
	
	iHiddenIndex[iClient] = EntIndexToEntRef(iEntity);
	iHiddenOwner[iEntity] = GetClientUserId(iClient);
	
	
	Call_StartForward(g_hOnClientModelApplied);
	Call_PushCell(iClient);
	Call_PushCell(iEntity);
	Call_PushString(sModel);
	Call_PushCell(bBaseReattach);
	Call_Finish();
	
	return iEntity;
}

int BeWitchOther(int iEntity, const char[] sModel)// dont pass refs
{
	if(iEntity < 1 || iEntity > 2048)
		return -1;
	
	CheckForSameModel(iEntity, sModel);
	
	if(IsValidEntRef(iHiddenEntity[iEntity]))
	{
		SetEntityModel(iHiddenEntity[iEntity], sModel);
		return EntRefToEntIndex(iHiddenEntity[iEntity]);
	}
	
	int iEnt = CreateEntityByName("commentary_dummy");
	if(iEnt < 0)
		return -1;
	
	DispatchKeyValue(iEnt, "model", sModel);
	
	float fVec[3];
	GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", fVec);
	TeleportEntity(iEnt, fVec, NULL_VECTOR, NULL_VECTOR);
	
	DispatchSpawn(iEnt);
	ActivateEntity(iEnt);
	
	SetAttach(iEnt, iEntity);
	
	iHiddenEntity[iEntity] = EntIndexToEntRef(iEnt);
	iHiddenEntityRef[iEntity] = EntIndexToEntRef(iEntity);
	
	SetEntityRenderFx(iEntity, RENDERFX_HOLOGRAM);
	SetEntityRenderColor(iEntity, 0, 0, 0, 0);
	return iEnt;
}

void CheckForSameModel(int iEntity, const char[] sPendingModel)// justincase 
{
	char sModel[PLATFORM_MAX_PATH];
	char sNetClass[64];
	if(!GetEntityNetClass(iEntity, sNetClass, sizeof(sNetClass)))
		return;
	
	GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	if(!StrEqual(sModel, sPendingModel, false))
		return;
	
	PrintToServer("[LMC][%i]%s(NetClass) overlay_model is the same as base model! \"%s\"", iEntity, sNetClass, sModel);// used netclass because classname can be changed!
}

void SetAttach(int iEntToAttach, int iEntToAttachTo)
{
	SetVariantString("!activator");
	AcceptEntityInput(iEntToAttach, "SetParent", iEntToAttachTo);
	
	SetEntityMoveType(iEntToAttach, MOVETYPE_NONE);
	
	SetEntProp(iEntToAttach, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_BONEMERGE_FASTCULL|EF_PARENT_ANIMATES);
	
	//thanks smlib for flag understanding
	int iFlags = GetEntProp(iEntToAttach, Prop_Data, "m_usSolidFlags", 2);
	iFlags = iFlags |= 0x0004;
	SetEntProp(iEntToAttach, Prop_Data, "m_usSolidFlags", iFlags, 2);
	
	TeleportEntity(iEntToAttach, view_as<float>({0.0, 0.0, 0.0}), view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR);
}

public void OnGameFrame()
{
	if(!IsServerProcessing())
		return;
	
	static int iClient = 1;
	if(iClient > MaxClients || iClient < 1)
		iClient = 1;
	
	
	if(IsClientInGame(iClient) && IsPlayerAlive(iClient))
	{
		if(IsValidEntRef(iHiddenIndex[iClient]))
		{
			SetEntityRenderMode(iClient, RENDER_NONE);
			static int iEnt;
			iEnt = EntRefToEntIndex(iHiddenIndex[iClient]);
			
			if(bL4D2)
			{
				if((GetEntProp(iClient, Prop_Send, "m_nGlowRange") > 0 && GetEntProp(iEnt, Prop_Send, "m_nGlowRange") == 0)
						&& (GetEntProp(iClient, Prop_Send, "m_iGlowType") > 0 && GetEntProp(iEnt, Prop_Send, "m_iGlowType") == 0)
						&& (GetEntProp(iClient, Prop_Send, "m_glowColorOverride") > 0 && GetEntProp(iEnt, Prop_Send, "m_glowColorOverride") == 0)
						&& (GetEntProp(iClient, Prop_Send, "m_nGlowRangeMin") > 0 && GetEntProp(iEnt, Prop_Send, "m_nGlowRangeMin") == 0))
				{
					SetEntProp(iEnt, Prop_Send, "m_nGlowRange", GetEntProp(iClient, Prop_Send, "m_nGlowRange"));
					SetEntProp(iEnt, Prop_Send, "m_iGlowType", GetEntProp(iClient, Prop_Send, "m_iGlowType"));
					SetEntProp(iEnt, Prop_Send, "m_glowColorOverride", GetEntProp(iClient, Prop_Send, "m_glowColorOverride"));
					SetEntProp(iEnt, Prop_Send, "m_nGlowRangeMin", GetEntProp(iClient, Prop_Send, "m_nGlowRangeMin"));
				}
			}
		}
		else if(g_bAggressiveChecks && !IsValidEntRef(iHiddenEntityRef[iClient]))
		{
			SetEntityRenderMode(iClient, RENDER_NORMAL);
		}
		
		static int iModelIndex[MAXPLAYERS+1] = {-1, ...};
		if(iModelIndex[iClient] != GetEntProp(iClient, Prop_Data, "m_nModelIndex", 2))
		{
			iModelIndex[iClient] = GetEntProp(iClient, Prop_Data, "m_nModelIndex", 2);
			if(IsValidEntRef(iHiddenIndex[iClient]))
			{
				static char sModel[PLATFORM_MAX_PATH];
				GetEntPropString(iHiddenIndex[iClient], Prop_Data, "m_ModelName", sModel, sizeof(sModel));
				BeWitched(iClient, sModel, true);
			}
		}
	}
	++iClient;
	
	
	static int iEntity;
	if(iEntity <= MaxClients || iEntity > 2048)
		iEntity = MaxClients+1;
	
	if(IsValidEntRef(iHiddenEntity[iEntity] && IsValidEntRef(iHiddenEntityRef[iEntity])))
	{
		static int iEnt;
		iEnt = EntRefToEntIndex(iHiddenEntity[iEntity]);
		SetEntityRenderFx(iEntity, RENDERFX_HOLOGRAM);
		SetEntityRenderColor(iEntity, 0, 0, 0, 0);
		
		if(bL4D2)
		{
			if(HasEntProp(iEntity, Prop_Send, "m_iGlowType"))
			{
				if((GetEntProp(iEntity, Prop_Send, "m_nGlowRange") > 0 && GetEntProp(iEnt, Prop_Send, "m_nGlowRange") == 0)
						&& (GetEntProp(iEntity, Prop_Send, "m_iGlowType") > 0 && GetEntProp(iEnt, Prop_Send, "m_iGlowType") == 0)
						&& (GetEntProp(iEntity, Prop_Send, "m_glowColorOverride") > 0 && GetEntProp(iEnt, Prop_Send, "m_glowColorOverride") == 0)
						&& (GetEntProp(iEntity, Prop_Send, "m_nGlowRangeMin") > 0 && GetEntProp(iEnt, Prop_Send, "m_nGlowRangeMin") == 0))
				{
					SetEntProp(iEnt, Prop_Send, "m_nGlowRange", GetEntProp(iEntity, Prop_Send, "m_nGlowRange"));
					SetEntProp(iEnt, Prop_Send, "m_iGlowType", GetEntProp(iEntity, Prop_Send, "m_iGlowType"));
					SetEntProp(iEnt, Prop_Send, "m_glowColorOverride", GetEntProp(iEntity, Prop_Send, "m_glowColorOverride"));
					SetEntProp(iEnt, Prop_Send, "m_nGlowRangeMin", GetEntProp(iEntity, Prop_Send, "m_nGlowRangeMin"));
				}
			}
		}
	}
	++iEntity;
}


int GetOverlayModel(Handle plugin, int numParams)
{
	if(numParams < 1)
		ThrowNativeError(SP_ERROR_PARAM, "Invalid numParams");
	
	int iClient = GetNativeCell(1);
	if(iClient < 1 || iClient > MaxClients)
		ThrowNativeError(SP_ERROR_PARAM, "Client index out of bounds %i", iClient);
	
	if(!IsClientInGame(iClient))
		ThrowNativeError(SP_ERROR_ABORTED, "Client is not ingame %i", iClient);
	
	if(!IsValidEntRef(iHiddenIndex[iClient]))
		return -1;
	
	return EntRefToEntIndex(iHiddenIndex[iClient]);
}

public int SetOverlayModel(Handle plugin, int numParams)
{
	if(numParams < 2)
		ThrowNativeError(SP_ERROR_PARAM, "Invalid numParams");
	
	int iClient = GetNativeCell(1);
	if(iClient < 1 || iClient > MaxClients)
		ThrowNativeError(SP_ERROR_PARAM, "Client index out of bounds %i", iClient);
	
	if(!IsClientInGame(iClient))
		ThrowNativeError(SP_ERROR_ABORTED, "Client is not ingame %i", iClient);
	
	char sModel[PLATFORM_MAX_PATH];
	GetNativeString(2, sModel, sizeof(sModel));
	
	if(sModel[0] == '\0')
		ThrowNativeError(SP_ERROR_PARAM, "Error Empty String");
	
	return BeWitched(iClient, sModel, false);
}

int SetEntityOverlayModel(Handle plugin, int numParams)
{
	if(numParams < 2)
		ThrowNativeError(SP_ERROR_PARAM, "Invalid numParams");
	
	int iEntity = GetNativeCell(1);
	if(iEntity < 1 || iEntity > 2048)
		ThrowNativeError(SP_ERROR_PARAM, "Entity index out of bounds %i", iEntity);
		
	if(!IsValidEntity(iEntity))
		ThrowNativeError(SP_ERROR_ABORTED, "Entity Invalid %i", iEntity);
	
	if(iEntity <= MaxClients)
		if(!IsClientInGame(iEntity))
			ThrowNativeError(SP_ERROR_ABORTED, "Client is not ingame %i", iEntity);
	
	char sModel[PLATFORM_MAX_PATH];
	GetNativeString(2, sModel, sizeof(sModel));
	
	if(sModel[0] == '\0')
		ThrowNativeError(SP_ERROR_PARAM, "Error Empty String");
	
	return BeWitchOther(iEntity, sModel);
}

int GetEntityOverlayModel(Handle plugin, int numParams)
{
	if(numParams < 1)
		ThrowNativeError(SP_ERROR_PARAM, "Invalid numParams");
	
	int iEntity = GetNativeCell(1);
	if(iEntity < MaxClients+1 || iEntity > 2048+1)
		ThrowNativeError(SP_ERROR_PARAM, "Entity index out of bounds %i", iEntity);
	
	if(!IsValidEntity(iEntity))
		ThrowNativeError(SP_ERROR_ABORTED, "Entity Invalid %i", iEntity);
	
	if(iEntity <= MaxClients)
		if(!IsClientInGame(iEntity))
			ThrowNativeError(SP_ERROR_ABORTED, "Client is not ingame %i", iEntity);
	
	if(!IsValidEntRef(iHiddenEntityRef[iEntity]))
		return -1;
	
	if(!IsValidEntRef(iHiddenEntity[iEntity]))
		return -1;
	
	return EntRefToEntIndex(iHiddenEntity[iEntity]);
}

int ResetRenderMode(Handle plugin, int numParams)
{
	if(numParams < 1)
		ThrowNativeError(SP_ERROR_PARAM, "Invalid numParams");
	
	int iEntity = GetNativeCell(1);
	if(iEntity < 1 || iEntity > 2048+1)
		ThrowNativeError(SP_ERROR_PARAM, "Entity index out of bounds %i", iEntity);
	
	if(!IsValidEntity(iEntity))
		ThrowNativeError(SP_ERROR_ABORTED, "Entity Invalid %i", iEntity);
	
	if(iEntity <= MaxClients)
		if(!IsClientInGame(iEntity))
			ThrowNativeError(SP_ERROR_ABORTED, "Client is not ingame %i", iEntity);
	
	ResetRender(iEntity);

	return 0;
}

public void OnEntityDestroyed(int iEntity)
{
	if(!IsServerProcessing() || iEntity < MaxClients+1 || iEntity > 2048)
		return;
	
	int iClient = GetClientOfUserId(iHiddenOwner[iEntity]);
	if(iClient < 1)
		return;
	
	iHiddenOwner[iEntity] = -1;
	if(!IsValidEntRef(iHiddenIndex[iClient]))
		return;
	
	Call_StartForward(g_hOnClientModelDestroyed);
	Call_PushCell(iClient);
	Call_PushCell(EntRefToEntIndex(iHiddenIndex[iClient]));
	Call_Finish();
}

void ResetRender(int iEntity)
{
	if(iEntity < MaxClients+1)
	{
		SetEntityRenderMode(iEntity, RENDER_NORMAL);
	}
	else
	{
		SetEntityRenderFx(iEntity, RENDERFX_NONE);
		SetEntityRenderColor(iEntity, 255, 255, 255, 255);
	}
}

public void OnClientDisconnect(int iClient)
{
	if(!IsValidEntRef(iHiddenIndex[iClient]))
		return;
	
	AcceptEntityInput(iHiddenIndex[iClient], "kill");
	iHiddenIndex[iClient] = -1;
}

void eSetColour(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(iClient < 1 || iClient > MaxClients || !IsClientInGame(iClient))
		return;
	
	if(!IsValidEntRef(iHiddenIndex[iClient]))
		return;
	
	SetEntityRenderMode(iClient, RENDER_NONE);
}

void eTeamChange(Handle hEvent, const char[] sEventName, bool bDontBroadcast)
{
	int iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if(iClient < 1 || iClient > MaxClients || !IsClientInGame(iClient))
		return;
	
	if(!IsValidEntRef(iHiddenIndex[iClient]))
		return;
	
	AcceptEntityInput(iHiddenIndex[iClient], "kill");
	iHiddenIndex[iClient] = -1;
}

static bool IsValidEntRef(int iEntRef)
{
	return (iEntRef != 0 && EntRefToEntIndex(iEntRef) != INVALID_ENT_REFERENCE);
}


//deprecated stuff
int HideOverlayModel(Handle plugin, int numParams)
{
	ThrowNativeError(SP_ERROR_NOT_RUNNABLE, "Deprecated function not longer included in LMC since \"2.0.3\" use older build if you want to use this function.");

	return 0;
}