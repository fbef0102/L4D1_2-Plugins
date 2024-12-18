#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#define MAX_FRAMECHECK 10

#define PLUGIN_VERSION "1.0h-2024/12/19"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PIPEBOMB_SOUND "weapons/hegrenade/beep.wav" //"PipeBomb.TimerBeep"
#define MOLOTOV_SOUND "weapons/molotov/fire_ignite_2.wav" //"Molotov.Throw"

public Plugin myinfo =
{
	name = "EnhancedThrowables",
	author = "Timocop, Lux & HarryPotter",
	description = "Add Dynamic Lights to handheld throwables",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2413605"
};


enum EnumHandheld
{
	EnumHandheld_None,
	EnumHandheld_Pipebomb,
	EnumHandheld_Molotov,
	EnumHandheld_MaxEnum
}

bool bIsL4D2 = false;

ConVar hCvar_HandheldLightPipBomb = null;
ConVar hCvar_HandheldLightMolotov = null;
ConVar hCvar_HandheldThrowLightEnabled = null;


ConVar hCvar_PipebombFuseColor = null;
ConVar hCvar_PipebombFlashColor = null;
ConVar hCvar_PipebombLightDistance = null;
ConVar hCvar_MolotovColor = null;
ConVar hCvar_MolotovLightDistance = null;

bool g_bHandheldLightPipeBomb = false;
bool g_bHandheldLightMolotov = false;
bool g_bHandheldThrowLightEnabled = false;

char g_sPipebombFuseColor[12];
char g_sPipebombFlashColor[12];
float g_fPipebombLightDistance;

char g_sMoloFlashColour[12];
float g_fMolotovLightDistance;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		bIsL4D2 = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		bIsL4D2 = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{
	CreateConVar("EnhanceThrowables_Version", PLUGIN_VERSION, "Enhance Handheld Throwables version", FCVAR_SPONLY|FCVAR_DONTRECORD|FCVAR_NOTIFY);
	
	hCvar_HandheldLightPipBomb = CreateConVar("l4d_handheld_light_pipe_bomb", "1", "Enables/Disables handheld pipebomb light.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_HandheldLightMolotov = CreateConVar("l4d_handheld_light_Molotov", "1", "Enables/Disables Molotov light.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_HandheldThrowLightEnabled = CreateConVar("l4d_handheld_throw_light_enable", "1", "Enables/Disables handheld light after throwing.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	hCvar_PipebombFuseColor = CreateConVar("l4d_handheld_light_pipebomb_fuse_colour", "215 215 1", "Pipebomb fure light color (0-255 0-255 0-255)", FCVAR_NOTIFY);
	hCvar_PipebombFlashColor = CreateConVar("l4d_handheld_light_pipebomb_flash_colour", "200 1 1", "Pipebomb flash light color (0-255 0-255 0-255)", FCVAR_NOTIFY);
	hCvar_PipebombLightDistance = CreateConVar("l4d_handheld_light_pipebomb_light_distance", "255.0", "Pipebomb Max light distance (0 = disabled)", FCVAR_NOTIFY, true, 0.1, true, 9999.0);
	
	hCvar_MolotovColor = CreateConVar("l4d_handheld_light_molotov_colour", "255 50 0", "Molotovs light color (0-255 0-255 0-255)", FCVAR_NOTIFY);
	hCvar_MolotovLightDistance = CreateConVar("l4d_handheld_light_molotov_light_distance", "200.0", "Molotovs light distance (0 = disabled)", FCVAR_NOTIFY, true, 0.1, true, 9999.0);
	
	hCvar_HandheldLightPipBomb.AddChangeHook(eConvarChanged);
	hCvar_HandheldLightMolotov.AddChangeHook(eConvarChanged);
	hCvar_HandheldThrowLightEnabled.AddChangeHook(eConvarChanged);
	
	hCvar_PipebombFuseColor.AddChangeHook(eConvarChanged);
	hCvar_PipebombFlashColor.AddChangeHook(eConvarChanged);
	hCvar_PipebombLightDistance.AddChangeHook(eConvarChanged);
	
	hCvar_MolotovColor.AddChangeHook(eConvarChanged);
	hCvar_MolotovLightDistance.AddChangeHook(eConvarChanged);
	
	CvarsChanged();
	
	AddNormalSoundHook(HandheldSoundHook);
	
	AutoExecConfig(true, "Enhanced_Throwables");
}

public Action HandheldSoundHook(int iClients[64], int &iNumClients, char sSampleFile[PLATFORM_MAX_PATH], int &iEntity, int &iChannel, float &fVolume, int &fLevel, int &iPitch, int &iFlags)
{
	if(!g_bHandheldThrowLightEnabled)
		return Plugin_Continue;
	
	if(iEntity < 0 || iEntity > 2048)
		return Plugin_Continue;
	
	static int iAlreadyThrownEntityRef[2048+1] = {INVALID_ENT_REFERENCE, ...};
	if(IsValidEntRef(iAlreadyThrownEntityRef[iEntity]))
		return Plugin_Continue;
	
	iAlreadyThrownEntityRef[iEntity] = EntIndexToEntRef(iEntity);
	
	if(!IsValidEntity(iEntity))
		return Plugin_Continue;
	
	char sClassname[32];
	
	GetEntityClassname(iEntity, sClassname, sizeof(sClassname));
	if(!StrEqual(sClassname, "pipe_bomb_projectile") && !StrEqual(sClassname, "molotov_projectile"))
		return Plugin_Continue;
	
	switch(sClassname[0])
	{
		case 'p':
		{
			if(!StrEqual(sSampleFile, PIPEBOMB_SOUND))
				return Plugin_Continue;
			
			int iLight = CreateLight(iEntity, EnumHandheld_Pipebomb);
			if(iLight == -1 || !IsValidEntity(iLight))
				return Plugin_Continue;
			
			//float fPos[3];
			//EntityGetPosition(iEntity, fPos);
			//TeleportEntity(iEntity, fPos, NULL_VECTOR, NULL_VECTOR);
			EntitySetParent(iLight, iEntity);
		}
		case 'm':
		{
			if(!StrEqual(sSampleFile, MOLOTOV_SOUND))
				return Plugin_Continue;
			
			int iLight = CreateLight(iEntity, EnumHandheld_Molotov);
			if(iLight == -1 || !IsValidEntity(iLight))
				return Plugin_Continue;
			
			//float fPos[3];
			//EntityGetPosition(iEntity, fPos);
			//TeleportEntity(iEntity, fPos, NULL_VECTOR, NULL_VECTOR);
			EntitySetParent(iLight, iEntity);
		}
	}
	
	return Plugin_Continue;
}

public void OnGameFrame()
{
	static int iClientLightRef[MAXPLAYERS+1] = {INVALID_ENT_REFERENCE, ...};
	static EnumHandheld iClienthandheld[MAXPLAYERS+1] = {EnumHandheld_None, ...};
	
	static int iFrameskip = 0;
	iFrameskip = (iFrameskip + 1) % MAX_FRAMECHECK;
	
	if(iFrameskip != 0 || !IsServerProcessing())
		return;
	
	//Dont use OnPlayerRunCmd, it doenst run when the player isnt in-game!
	//But you need to check if hes in-game or not, cuz remove light.
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i)
				|| GetClientTeam(i) != 2
				|| !IsPlayerAlive(i)
				|| IsSurvivorIncapacitated(i)
				|| IsSurvivorBusyWithInfected(i)
				|| IsSurvivorUsingMountedWeapon(i))
		{
			
			if(IsValidEntRef(iClientLightRef[i]))
			{
				AcceptEntityInput(iClientLightRef[i], "Kill");
				iClientLightRef[i] = INVALID_ENT_REFERENCE;
			}
		}
		else
		{
			EnumHandheld flCurrentHandheld;
			flCurrentHandheld = GetHoldingHandheld(i);
			
			//Fix on picking up other handhelds while holding an handheld
			if(flCurrentHandheld != iClienthandheld[i])
			{
				iClienthandheld[i] = flCurrentHandheld;
				
				if(IsValidEntRef(iClientLightRef[i]))
				{
					AcceptEntityInput(iClientLightRef[i], "Kill");
					iClientLightRef[i] = INVALID_ENT_REFERENCE;
				}
			}
			
			if(!IsValidEntRef(iClientLightRef[i]))
			{
				int iLight = CreateLight(i, flCurrentHandheld);
				if(iLight != -1 && IsValidEntity(iLight))
				{
					iClientLightRef[i] = EntIndexToEntRef(iLight);
				}
			}
		}
	}
}

int CreateLight(int iEntity, EnumHandheld iHandheld=EnumHandheld_None)
{
	if(iHandheld != EnumHandheld_Pipebomb
			&& iHandheld != EnumHandheld_Molotov)
		return -1;
	
	switch(iHandheld)
	{
		case EnumHandheld_Pipebomb:
		{
			if(g_fPipebombLightDistance < 1.0)
				return -1;
		}
		case EnumHandheld_Molotov:
		{
			if(g_fMolotovLightDistance < 1.0)
				return -1;
		}
	}
	
	int iLight = CreateEntityByName("light_dynamic");
	if(iLight == -1)
		return -1;
	
	float fPos[3];
	EntityGetPosition(iEntity, fPos);
	
	TeleportEntity(iLight, fPos, NULL_VECTOR, NULL_VECTOR);
	
	if(iEntity <= MaxClients)// should block the error on olderversion on error parent attachment
	{
		char sModel[31];
		GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		
		switch(sModel[29])
		{
			case 'b', 'd', 'h', 'w' ://nick, rochelle, ellis, adawong
			{
				EntitySetParentAttachment(iLight, iEntity, "weapon_bone");
			}
			case 'v', 'e', 'a', 'c'://bill, francis, louis, coach
			{
				EntitySetParentAttachment(iLight, iEntity, "armR_T");
				TeleportEntity(iLight, view_as<float>( {8.0, 18.0, 0.0 } ), view_as<float>( { -20.0, 100.0, 0.0 }), NULL_VECTOR);
			}
			case 'n'://zoey
			{
				EntitySetParentAttachment(iLight, iEntity, "armR_T");
				TeleportEntity(iLight, view_as<float>({ 0.0, 20.0, 0.0 }), view_as<float>({ 0.0, 90.0, 0.0 }), NULL_VECTOR);
			}
			default:
			{
				//EntitySetParentAttachment(iLight, iEntity, "survivor_light");
			}
		}
	}
	
	switch(iHandheld)
	{
		case EnumHandheld_Pipebomb:
		{
			char sBuffer[64];
			
			DispatchKeyValue(iLight, "brightness", "1");
			DispatchKeyValueFloat(iLight, "spotlight_radius", 32.0);
			DispatchKeyValueFloat(iLight, "distance", g_fPipebombLightDistance / 8);
			DispatchKeyValue(iLight, "style", "-1");
			
			DispatchSpawn(iLight);
			ActivateEntity(iLight);
			
			AcceptEntityInput(iLight, "TurnOff");
			
			Format(sBuffer, sizeof(sBuffer), g_sPipebombFuseColor);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "Color");
			
			AcceptEntityInput(iLight, "TurnOn");
			
			Format(sBuffer, sizeof(sBuffer), "OnUser1 !self:Color:%s:0.0167:-1", g_sPipebombFlashColor);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "AddOutput");
			
			Format(sBuffer, sizeof(sBuffer), "OnUser1 !self:distance:%f:0.0344:-1", (g_fPipebombLightDistance / 7) * 2);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "AddOutput");
			
			Format(sBuffer, sizeof(sBuffer), "OnUser1 !self:distance:%f:0.0501:-1", (g_fPipebombLightDistance / 7) * 3);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "AddOutput");
			
			Format(sBuffer, sizeof(sBuffer), "OnUser1 !self:distance:%f:0.0668:-1", (g_fPipebombLightDistance / 7) * 4);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "AddOutput");
			
			Format(sBuffer, sizeof(sBuffer), "OnUser1 !self:distance:%f:0.0835:-1", (g_fPipebombLightDistance / 7) * 5);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "AddOutput");
			
			Format(sBuffer, sizeof(sBuffer), "OnUser1 !self:distance:%f:0.1002:-1", (g_fPipebombLightDistance / 7) * 6);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "AddOutput");
			
			Format(sBuffer, sizeof(sBuffer), "OnUser1 !self:distance:%f:0.1169:-1", g_fPipebombLightDistance);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "AddOutput");
			
			Format(sBuffer, sizeof(sBuffer), "OnUser1 !self:distance:%f.0:0.1336:-1", g_fPipebombLightDistance / 4);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "AddOutput");
			
			Format(sBuffer, sizeof(sBuffer), "OnUser1 !self:distance:%f.0:0.1503:-1", g_fPipebombLightDistance / 8);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "AddOutput");
			
			Format(sBuffer, sizeof(sBuffer), "OnUser1 !self:Color:%s:0.1503:-1", g_sPipebombFuseColor);
			SetVariantString(sBuffer);
			AcceptEntityInput(iLight, "AddOutput");
			
			SetVariantString("OnUser1 !self:FireUser1::0.20004:-1");
			AcceptEntityInput(iLight, "AddOutput");
			
			AcceptEntityInput(iLight, "FireUser1");
			
			return iLight;
		}
		case EnumHandheld_Molotov:
		{
			DispatchKeyValue(iLight, "brightness", "1");
			DispatchKeyValueFloat(iLight, "spotlight_radius", 32.0);
			DispatchKeyValueFloat(iLight, "distance", g_fMolotovLightDistance);
			DispatchKeyValue(iLight, "style", "6");
			
			DispatchSpawn(iLight);
			ActivateEntity(iLight);
			
			AcceptEntityInput(iLight, "TurnOff");
			
			SetVariantString(g_sMoloFlashColour);
			AcceptEntityInput(iLight, "Color");
			
			AcceptEntityInput(iLight, "TurnOn");
			
			return iLight;
		}
	}
	return -1;
}

public void OnMapStart()
{
	CvarsChanged();
}

public void eConvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	CvarsChanged();
}

void CvarsChanged()
{
	g_bHandheldLightPipeBomb = hCvar_HandheldLightPipBomb.BoolValue;
	g_bHandheldLightMolotov = hCvar_HandheldLightMolotov.BoolValue;
	g_bHandheldThrowLightEnabled = hCvar_HandheldThrowLightEnabled.BoolValue;
	
	g_fPipebombLightDistance = hCvar_PipebombLightDistance.FloatValue;
	hCvar_PipebombFuseColor.GetString(g_sPipebombFuseColor, sizeof(g_sPipebombFuseColor));
	hCvar_PipebombFlashColor.GetString(g_sPipebombFlashColor, sizeof(g_sPipebombFlashColor));
	
	g_fMolotovLightDistance = hCvar_MolotovLightDistance.FloatValue;
	hCvar_MolotovColor.GetString(g_sMoloFlashColour, sizeof(g_sMoloFlashColour));
}

//Tools Folding
bool IsValidEntRef(int iEntRef)
{
	return (iEntRef != 0 && EntRefToEntIndex(iEntRef) != INVALID_ENT_REFERENCE);
}

void EntityGetPosition(int iEntity, float fPos[3])
{
	GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", fPos);
}

void EntitySetParent(int iEntity, int iTarget)
{
	SetVariantString("!activator");
	AcceptEntityInput(iEntity, "SetParent", iTarget);
}

void EntitySetParentAttachment(int iEntity, int iTarget, const char[] sAttachName)
{
	EntitySetParent(iEntity, iTarget);
	
	SetVariantString(sAttachName);
	AcceptEntityInput(iEntity, "SetParentAttachment");
}

EnumHandheld GetHoldingHandheld(int iClient)
{
	char sHandheld[32];
	sHandheld[0] = 0;
	GetClientWeapon(iClient, sHandheld, sizeof(sHandheld));
	
	if(sHandheld[7] != 'p' && sHandheld[7] != 'm')
		return EnumHandheld_None;
	
	if(StrEqual(sHandheld, "weapon_pipe_bomb") && g_bHandheldLightPipeBomb)
		return EnumHandheld_Pipebomb;
	else if(StrEqual(sHandheld, "weapon_molotov") && g_bHandheldLightMolotov)
		return EnumHandheld_Molotov;
	
	return EnumHandheld_None;
}

bool IsSurvivorIncapacitated(int iClient)
{
	return GetEntProp(iClient, Prop_Send, "m_isIncapacitated", 1) > 0;
}

bool IsSurvivorBusyWithInfected(int iClient)
{
	if(bIsL4D2)
	{
		if(GetEntPropEnt(iClient, Prop_Send, "m_pummelAttacker") > 0)
			return true;
		if(GetEntPropEnt(iClient, Prop_Send, "m_carryAttacker") > 0)
			return true;
		if(GetEntPropEnt(iClient, Prop_Send, "m_pounceAttacker") > 0)
			return true;
		if(GetEntPropEnt(iClient, Prop_Send, "m_tongueOwner") > 0)
			return true;
		if(GetEntPropEnt(iClient, Prop_Send, "m_jockeyAttacker") > 0)
			return true;
	}
	else
	{
		if(GetEntPropEnt(iClient, Prop_Send, "m_pounceAttacker") > 0)
			return true;
		if(GetEntPropEnt(iClient, Prop_Send, "m_tongueOwner") > 0)
			return true;
	}
	
	return false;
}

bool IsSurvivorUsingMountedWeapon(int iClient)
{
	return (GetEntProp(iClient, Prop_Send, "m_usingMountedWeapon") > 0);
}
