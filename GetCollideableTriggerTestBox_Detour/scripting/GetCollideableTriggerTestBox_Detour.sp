#define PLUGIN_VERSION		"1.1-2025/10/27"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>

#define DEBUG 0
#define GAMEDATA		"GetCollideableTriggerTestBox_Detour"

public Plugin myinfo =
{
	name = "[L4D2] GetCollideableTriggerTestBox_Detour",
	author = "Dragokas",
	description = "Fixing the crash with null pointer dereference in CM_GetCollideableTriggerTestBox",
	version = PLUGIN_VERSION,
	url = "https://github.com/dragokas"
}

enum struct ARG_ORDER
{
	int ptr;
	int vec1;
	int vec2;
}

ARG_ORDER g_ArgOrder;
bool g_bLinuxOS;
DynamicDetour hDetour;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/%s.txt", GAMEDATA);

	GameData hGameData = new GameData(GAMEDATA);
	if( hGameData == null ) SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);

	int offest = hGameData.GetOffset("OS");
	if(offest == -1)
	{
		SetFailState("Offset for \"OS\" not found");
	}
	
	g_bLinuxOS = hGameData.GetOffset("OS") != 0;
	
	if( g_bLinuxOS )
	{
		g_ArgOrder.ptr = 1;
		g_ArgOrder.vec1 = 2;
		g_ArgOrder.vec2 = 3;
	}
	else {
		g_ArgOrder.ptr = 3;
		g_ArgOrder.vec1 = 1;
		g_ArgOrder.vec2 = 2;
	}
	
	#if DEBUG
		LogError("OS Linux? %b", g_bLinuxOS);
	#endif
	
	SetupDetour(hGameData);
	
	delete hGameData;
}

public void OnPluginEnd()
{
	if( !hDetour.Disable(Hook_Pre, CM_GetCollideableTriggerTestBox) )
		SetFailState("Failed to disable detour \"CM_GetCollideableTriggerTestBox\".");
}

void SetupDetour(GameData hGameData)
{
	hDetour = DynamicDetour.FromConf(hGameData, "CM_GetCollideableTriggerTestBox");
	if( !hDetour )
		SetFailState("Failed to find \"CM_GetCollideableTriggerTestBox\" signature.");
	if( !hDetour.Enable(Hook_Pre, CM_GetCollideableTriggerTestBox) )
		SetFailState("Failed to start detour \"CM_GetCollideableTriggerTestBox\".");
}

public MRESReturn CM_GetCollideableTriggerTestBox(DHookReturn hReturn, DHookParam hParams)
{
	#if DEBUG
		float vec1[3], vec2[3];
		hParams.GetVector(g_ArgOrder.vec1, vec1);
		hParams.GetVector(g_ArgOrder.vec2, vec2);
		
		LogError("vector1= %f %f %f", vec1[0], vec1[1], vec1[2]);
		LogError("vector2= %f %f %f", vec2[0], vec2[1], vec2[2]);
	#endif
	
	int ptr = hParams.Get(g_ArgOrder.ptr);
	
	if( ptr == 0 )
	{
		#if DEBUG
			LogError("########### CM_GetCollideableTriggerTestBox. Crash is successfully prevented!");
		#endif
	
		hReturn.Value = 0.0;
		return MRES_Supercede;
	}
	
	return MRES_Ignored;
}
