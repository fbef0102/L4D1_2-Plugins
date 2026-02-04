#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <dhooks>
#include <left4dhooks>

#undef REQUIRE_PLUGIN
#tryinclude <readyup>

#define DEBUG		   	0
#define PLUGIN_NAME		"l4d_start_safe_area"
#define PLUGIN_VERSION 	"1.2h-2026/1/28"

public Plugin myinfo =
{
	name		= "Custom Start Safe Area",
	author		= "洛琪, Harry",
	description = "强制游戏将开局出生点周围区域判定为安全区,以保证玩家安全",
	version		= PLUGIN_VERSION,
	url			= "https://steamcommunity.com/profiles/76561198812009299/"
};

bool 
	g_bL4D2Version;

GlobalForward 
	g_hFWD_LeaveSafeAreaPre, 
	g_hFWD_LeaveSafeAreaPost, 
	g_hFWD_LeaveSafeAreaPostHandled;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead )
	{
		g_bL4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		g_bL4D2Version = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	CreateNative("L4DSSArea_HasAnySurvivorLeftCustomSafeArea",	Native_HasAnySurvivorLeftSafeArea);
	CreateNative("L4DSSArea_RemoveCustomSafeArea",	Native_RemoveCustomSafeArea);

	g_hFWD_LeaveSafeAreaPre			= new GlobalForward("L4DSSArea_OnFirstSurvivorLeftCustomSafeArea_Pre",	ET_Event, Param_Cell);
	g_hFWD_LeaveSafeAreaPost		= new GlobalForward("L4DSSArea_OnFirstSurvivorLeftCustomSafeArea_Post",	ET_Ignore, Param_Cell);
	g_hFWD_LeaveSafeAreaPostHandled	= new GlobalForward("L4DSSArea_OnFirstSurvivorLeftCustomSafeArea_PostHandled",	ET_Ignore, Param_Cell);

	RegPluginLibrary("l4d_start_safe_area");

	return APLRes_Success;
}

#define GAMEDATA	   PLUGIN_NAME
#define DATA_FILE		        "data/" ... PLUGIN_NAME ... ".cfg"


#define SPRITE_BEAM						"materials/sprites/laserbeam.vmt"

float  
	center_point[3],
	g_fSafeDistance;

int 
    g_iRoundStart, 
    g_iPlayerSpawn,
	g_iBeamSprite;

bool 
	g_bEnable,
	g_bGameOSIsLinux,
	g_bHasLeftCustomSafeArea,
	g_bCreateBeam,
	g_bHasIntroCamera;

Handle
	g_hStartTimer,
	g_hRingTimer;

public void OnPluginStart()
{
	char buffer[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, buffer, sizeof buffer, "gamedata/%s.txt", GAMEDATA);
	if (!FileExists(buffer))
		SetFailState("Missing required file: \"%s\".\n", buffer);

	GameData hGameData = LoadGameConfigFile(GAMEDATA);
	if (hGameData == null) SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);

	g_bGameOSIsLinux = hGameData.GetOffset("OS") == 1 ;

	DynamicDetour dSafeAreaJudge;
	if(g_bL4D2Version)
	{
		dSafeAreaJudge = DynamicDetour.FromConf(hGameData, "CheckForSurvivorsLeavingSafeArea");
		if (!dSafeAreaJudge)
			SetFailState("Failed to setup detour for CheckForSurvivorsLeavingSafeArea");

		if (!dSafeAreaJudge.Enable(Hook_Pre, Detour_DirectorJudgeSafeArea))
			SetFailState("Failed to detour for CheckForSurvivorsLeavingSafeArea");
	}
	else
	{
		if(g_bGameOSIsLinux)
		{
			dSafeAreaJudge = DynamicDetour.FromConf(hGameData, "ForEachPlayer<SurvivorsInSafeArea>");
			if (!dSafeAreaJudge)
				SetFailState("Failed to setup detour for ForEachPlayer<SurvivorsInSafeArea>");

			if (!dSafeAreaJudge.Enable(Hook_Pre, Detour_DirectorJudgeSafeArea))
				SetFailState("Failed to detour for ForEachPlayer<SurvivorsInSafeArea>");
		}
		else
		{
			dSafeAreaJudge = DynamicDetour.FromConf(hGameData, "SurvivorsInSafeArea::operator()");
			if (!dSafeAreaJudge)
				SetFailState("Failed to setup detour for SurvivorsInSafeArea::operator()");

			if (!dSafeAreaJudge.Enable(Hook_Pre, Detour_DirectorJudgeSafeArea))
				SetFailState("Failed to detour for SurvivorsInSafeArea::operator()");
		}
	}

	delete dSafeAreaJudge;
	delete hGameData;

	//if(g_bL4D2Version) HookEvent("player_left_safe_area", Event_PlayerLeftSafeArea, EventHookMode_PostNoCopy);
	HookEvent("round_start",            Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn",           Event_PlayerSpawn);
	HookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy); //trigger twice in versus/survival/scavenge mode, one when all survivors wipe out or make it to saferom, one when first round ends (second round_start begins).
	HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //1. all survivors make it to saferoom in and server is about to change next level in coop mode (does not trigger round_end), 2. all survivors make it to saferoom in versus
	HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy); //final map final rescue vehicle leaving  (does not trigger round_end)
}

// Sourcemod API Forward-------------------------------

public void OnMapStart()
{
	g_bHasLeftCustomSafeArea = false;

	g_iBeamSprite = PrecacheModel( SPRITE_BEAM );

	LoadData();
}

public void OnMapEnd()
{
    ClearDefault();
    ResetTimer();
}

// Data--------------------

void LoadData()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), DATA_FILE);
	if( !FileExists(sPath) )
	{
		SetFailState("File Not Found: %s", sPath);
		return;
	}

	// Load config
	KeyValues hFile = new KeyValues(PLUGIN_NAME);
	if( !hFile.ImportFromFile(sPath) )
	{
		SetFailState("File Format Not Correct: %s", sPath);
		delete hFile;
		return;
	}

	if( !hFile.JumpToKey("Maps") )
	{
		SetFailState("File Format Not Correct: %s", sPath);
		delete hFile;
		return;
	}

	if( hFile.JumpToKey("default") )
	{
		g_bEnable = view_as<bool>(hFile.GetNum("enable", 1));
		g_fSafeDistance = hFile.GetFloat("distance", 250.0);
		g_bCreateBeam = view_as<bool>(hFile.GetNum("beam_ring", 1));

		hFile.GoBack();
	}

	char sCurrentMap[64];
	GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));

	if( hFile.JumpToKey(sCurrentMap) )
	{
		g_bEnable = view_as<bool>(hFile.GetNum("enable", g_bEnable));
		g_fSafeDistance = hFile.GetFloat("distance", g_fSafeDistance);
		g_bCreateBeam = view_as<bool>(hFile.GetNum("beam_ring", g_bCreateBeam));

		hFile.GoBack();
	}

	delete hFile;
}

// Event-------------------------------

/*void Event_PlayerLeftSafeArea(Event event, const char[] name, bool dontBroadcast)
{
	PrintToChatAll("现在离开了安全区");
}*/

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.3, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;

	g_bHasLeftCustomSafeArea = false;
	g_bHasIntroCamera = false;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.3, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;	
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	ClearDefault();
	ResetTimer();
}

// Timer--------------------

Action Timer_PluginStart(Handle timer)
{
	ClearDefault();

	if(!g_bEnable)
	{
		g_bHasLeftCustomSafeArea = false;
		return Plugin_Continue;
	}

	delete g_hStartTimer;
	g_hStartTimer = CreateTimer(0.2, DelayTelepAndGetStartArea, _, TIMER_REPEAT);

	return Plugin_Continue;
}

Action DelayTelepAndGetStartArea(Handle timer, int client)
{
	//left4dhooks sucks, broken in l4d1 linux
	if(!g_bL4D2Version && L4D_GetServerOS() == 1)
	{
		if(g_bHasIntroCamera)
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				if(!IsClientInGame(i)) continue;
				if(GetClientTeam(i) != 2) continue;
				if(!IsPlayerAlive(i)) continue;

				if (GetEntPropEnt(i, Prop_Send, "m_hViewEntity") != -1) return Plugin_Continue;
			}

			g_bHasIntroCamera = false;
		}

		for(int i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i)) continue;
			if(GetClientTeam(i) != 2) continue;
			if(!IsPlayerAlive(i)) continue;

			// 有intro cutscene
			if (!g_bHasIntroCamera && GetEntPropEnt(i, Prop_Send, "m_hViewEntity") != -1)
			{
				g_bHasIntroCamera = true;
				return Plugin_Continue;
			}

			for(int j = 1; j <= MaxClients; j++)
			{
				if(!IsClientInGame(j)) continue;
				if(GetClientTeam(j) != 2) continue;
				if(!IsPlayerAlive(j)) continue;

				AcceptEntityInput(j, "DisableLedgeHang");
				CheatCommand(j, "warp_to_start_area");
			}

			GetClientAbsOrigin(i, center_point);
			center_point[2] += 50.0;
			//LogError("%N,  %.1f %.1f %.1f", i, center_point[0], center_point[1], center_point[2]);
			g_hStartTimer = CreateTimer(0.1, CheckAnyOneLeftSafeArea, _, TIMER_REPEAT);

			if(g_bCreateBeam)
			{
				delete g_hRingTimer;
				g_hRingTimer = CreateTimer(1.0, Timer_CreateVisibleRing, _, TIMER_REPEAT);
			}

			return Plugin_Stop;
		}
	}
	else
	{
		if(g_bHasIntroCamera && L4D_IsInIntro())
		{
			return Plugin_Continue;
		}

		for(int i = 1; i <= MaxClients; i++)
		{
			if(!IsClientInGame(i)) continue;
			if(GetClientTeam(i) != 2) continue;
			if(!IsPlayerAlive(i)) continue;

			// 看intro cutscene
			if (!g_bHasIntroCamera && GetEntPropEnt(i, Prop_Send, "m_hViewEntity") != -1)
			{
				g_bHasIntroCamera = true;
				return Plugin_Continue;
			}

			//AcceptEntityInput(i, "DisableLedgeHang");
			//CheatCommand(i, "warp_to_start_area");

			GetClientAbsOrigin(i, center_point);
			center_point[2] += 50.0;
			//LogError("%N,  %.1f %.1f %.1f", i, center_point[0], center_point[1], center_point[2]);
			g_hStartTimer = CreateTimer(0.1, CheckAnyOneLeftSafeArea, _, TIMER_REPEAT);

			if(g_bCreateBeam)
			{
				delete g_hRingTimer;
				g_hRingTimer = CreateTimer(1.0, Timer_CreateVisibleRing, _, TIMER_REPEAT);
			}

			return Plugin_Stop;
		}
	}

	return Plugin_Continue;
}

Action CheckAnyOneLeftSafeArea(Handle timer)
{
	for (int i = 1; i < MaxClients + 1; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			int viewEnt = GetEntPropEnt(i, Prop_Send, "m_hViewEntity");
			if (viewEnt != -1)
				return Plugin_Continue;

			float v_pos[3];
			GetClientAbsOrigin(i, v_pos);
			//LogError("%.1f %.1f", GetVectorDistance(v_pos, center_point), g_fSafeDistance * g_fSafeDistance);
			if (GetVectorDistance(v_pos, center_point, true) > g_fSafeDistance * g_fSafeDistance)
			{
				Action aResult = Plugin_Continue;
				Call_StartForward(g_hFWD_LeaveSafeAreaPre);
				Call_PushCell(i);
				Call_Finish(aResult);

				if( aResult == Plugin_Handled )
				{
					Call_StartForward(g_hFWD_LeaveSafeAreaPostHandled);
					Call_PushCell(i);
					Call_Finish(aResult);

					continue;
				}

				Call_StartForward(g_hFWD_LeaveSafeAreaPost);
				Call_PushCell(i);
				Call_Finish();

				g_bHasLeftCustomSafeArea = true;
				//LogError("g_bHasLeftCustomSafeArea = true");

				g_hStartTimer = null;
				delete g_hRingTimer;

				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}

Action Timer_CreateVisibleRing(Handle timer)
{
	// 居然是直徑 我襙
	TE_SetupBeamRingPoint(center_point, g_fSafeDistance + g_fSafeDistance, g_fSafeDistance + g_fSafeDistance + 10.0, g_iBeamSprite, 0, 0, 0, 1.0, 2.0, 0.0, { 255, 255, 0, 255 }, 0, 0);
	TE_SendToAll();

	return Plugin_Continue;
}

// Dhooks----------

MRESReturn Detour_DirectorJudgeSafeArea(DHookReturn hReturn, DHookParam hParams)
{
	if (!g_bEnable || g_bHasLeftCustomSafeArea) return MRES_Ignored;

	//PrintToChatAll("Detour_DirectorJudgeSafeArea");

	hReturn.Value = 0;
	return MRES_Supercede;
}

// Function-------------------------------

stock void CheatCommand(int client, const char[] cmd)
{
	int flags = GetCommandFlags(cmd);
	int bits  = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	SetCommandFlags(cmd, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, cmd);
	SetCommandFlags(cmd, flags);
	if(IsClientConnected(client)) SetUserFlagBits(client, bits);
}

void ClearDefault()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

void ResetTimer()
{
	delete g_hStartTimer;
	delete g_hRingTimer;
}

void GameStart()
{
	g_bHasLeftCustomSafeArea = true;

	delete g_hRingTimer;
	delete g_hStartTimer;
}

// API---------

public void OnRoundIsLive()
{
	GameStart();
}

// Native------------

// native int L4DSSArea_HasAnySurvivorLeftCustomSafeArea();
int Native_HasAnySurvivorLeftSafeArea(Handle plugin, int numParams)
{
	return g_bHasLeftCustomSafeArea;
}

// native int L4DSSArea_RemoveCustomSafeArea();
int Native_RemoveCustomSafeArea(Handle plugin, int numParams)
{
	GameStart();

	return 0;
}