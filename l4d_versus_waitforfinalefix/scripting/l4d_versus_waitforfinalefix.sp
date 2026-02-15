/**
 * https://github.com/devilesk/rl4d2l-plugins/blob/master/suicideblitzfinalefix.sp
 * "1.3.0" 變體插件
 * 使用一勞永逸的方式無需自行增加地圖
 */

#pragma newdecls required
#pragma semicolon 1
#include <sourcemod>
#include <left4dhooks>

// Spawn State - These look like flags, but get used like static values quite often.
// These names were pulled from reversing client.dll--specifically CHudGhostPanel::OnTick()'s uses of the "#L4D_Zombie_UI_*" strings

#define SPAWN_OK             0
#define SPAWN_DISABLED       1  // "Spawning has been disabled..." (e.g. director_no_specials 1)
#define WAIT_FOR_SAFE_AREA   2  // "Waiting for the Survivors to leave the safe area..."
#define WAIT_FOR_FINALE      4  // "Waiting for the finale to begin..."
#define WAIT_FOR_TANK        8  // "Waiting for Tank battle conclusion..."
#define SURVIVOR_ESCAPED    16  // "The Survivors have escaped..."
#define DIRECTOR_TIMEOUT    32  // "The Director has called a time-out..." (lol wat)
#define WAIT_FOR_STAMPEDE   64  // "Waiting for the next stampede of Infected..."
#define CAN_BE_SEEN        128  // "Can't spawn here" "You can be seen by the Survivors"
#define TOO_CLOSE          256  // "Can't spawn here" "You are too close to the Survivors"
#define RESTRICTED_AREA    512  // "Can't spawn here" "This is a restricted area"
#define INSIDE_ENTITY     1024  // "Can't spawn here" "Something is blocking this spot"

// Offset of the prop we're looking for from m_ghostSpawnState,
// since its relative offset should be more stable than other stuff...
const int OFFS_FROM_SPAWNSTATE = 0x26;
int g_SawSurvivorsOutsideBattlefieldOffset;

bool 
	g_bAutoFixThisMap;

public Plugin myinfo =
{
		name = "Finale Can't Spawn Glitch Fix",
		author = "ProdigySim, modified by Wicket and devilesk, Harry",
		description = "Fixing Waiting For Survivors To Start The Finale or w/e",
		version = "1.0h-2026/2/16",
		url = "https://github.com/devilesk/rl4d2l-plugins/blob/master/suicideblitzfinalefix.sp"
}
 
public void OnPluginStart()
{
	RegAdminCmd("sm_fix_wff", AdminFixWaitingForFinale, ADMFLAG_GENERIC, "Manually fix the 'Waiting for finale to start' issue for all infected.");
	
	g_SawSurvivorsOutsideBattlefieldOffset = FindSendPropInfo("CTerrorPlayer", "m_ghostSpawnState") + OFFS_FROM_SPAWNSTATE;
}

public void OnMapStart()
{
	g_bAutoFixThisMap = false;
}

public void L4D_OnFirstSurvivorLeftSafeArea_Post(int client)
{
	if(g_bAutoFixThisMap || HasBug_WAIT_FOR_FINALE())
	{
		FixAllInfected();
	}
}

void FixAllInfected()
{
	PrintToChatAll("Fixing Waiting For Finale to Start issue for all infected");
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 3) 
		{
			SetSeenSurvivorsState(i, true);
			// This part shouldn't be necessary, but just for good measure:
			// Remove the "WAIT_FOR_FINALE" spawn flag
			SetSpawnFlags(i, GetSpawnFlags(i) & ~WAIT_FOR_FINALE);
		}
	}
}


Action AdminFixWaitingForFinale(int client, int args)
{
	FixAllInfected();

	return Plugin_Handled;
}

void SetSpawnFlags(int entity, int flags)
{
	SetEntProp(entity, Prop_Send, "m_ghostSpawnState", flags);
}

int GetSpawnFlags(int entity)
{
	return GetEntProp(entity, Prop_Send, "m_ghostSpawnState");
}

stock bool GetSeenSurvivorsState(int entity)
{
	// m_ghostSawSurvivorsOutsideFinaleArea
	return view_as<bool>(GetEntData(entity, g_SawSurvivorsOutsideBattlefieldOffset, 1));
}

void SetSeenSurvivorsState(int entity, bool seen)
{
	// m_ghostSawSurvivorsOutsideFinaleArea
	SetEntData(entity, g_SawSurvivorsOutsideBattlefieldOffset, seen ? 1: 0, 1);
}

bool HasBug_WAIT_FOR_FINALE()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 3) 
		{
			if(GetSpawnFlags(i) & WAIT_FOR_FINALE)
			{
				return true;
			}
		}
	}

	return false;
}