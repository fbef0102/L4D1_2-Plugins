#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <dhooks>
#define PLUGIN_NAME			    "gameuifix"
#define PLUGIN_VERSION 			"v1.0h-2024/3/7"

public Plugin myinfo =
{
	name = "GameUI Crash Fix",
	author = "GoD-Tony, Harry",
	description = "Fixes a crash in game_ui entities",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

#define GAMEDATA_FILE           PLUGIN_NAME

Handle g_hAcceptInput = null;

public void OnPluginStart()
{
	// Convars.
	CreateConVar(PLUGIN_NAME ... "_version", PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	
	// Gamedata.
	GameData hConfig = new GameData(GAMEDATA_FILE);
	
	if (hConfig == INVALID_HANDLE)
	{
		SetFailState("Could not find gamedata file: gameuifix.txt");
	}
	
	int offset = hConfig.GetOffset("AcceptInput");
	
	if (offset == -1)
	{
		SetFailState("Failed to find AcceptInput offset");
	}
	
	delete hConfig;
	
	// DHooks.
	g_hAcceptInput = DHookCreate(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity, Hook_AcceptInput);
	DHookAddParam(g_hAcceptInput, HookParamType_CharPtr);
	DHookAddParam(g_hAcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_hAcceptInput, HookParamType_CBaseEntity);
	DHookAddParam(g_hAcceptInput, HookParamType_Object, 20); //varaint_t is a union of 12 (float[3]) plus two int type params 12 + 8 = 20
	DHookAddParam(g_hAcceptInput, HookParamType_Int);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	switch (classname[0])
	{
		case 'g':
		{
			if (StrEqual(classname, "game_ui"))
			{
				DHookEntity(g_hAcceptInput, false, entity);
			}
		}
	}
}

MRESReturn Hook_AcceptInput(int pThis, Handle hReturn, Handle hParams)
{
	static char sCommand[64];
	DHookGetParamString(hParams, 1, sCommand, sizeof(sCommand));
	
	if (StrEqual(sCommand, "Deactivate"))
	{
		int pPlayer = GetEntPropEnt(pThis, Prop_Data, "m_player");
		
		if (pPlayer == -1)
		{
			// Manually disable think.
			SetEntProp(pThis, Prop_Data, "m_nNextThinkTick", -1);
			
			DHookSetReturn(hReturn, false);
			return MRES_Supercede;
		}
	}
	
	DHookSetReturn(hReturn, true);
	return MRES_Ignored;
}
