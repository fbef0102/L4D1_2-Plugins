#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#include <left4dhooks>
#include <spawn_infected_nolimit> //https://github.com/fbef0102/L4D1_2-Plugins/tree/master/spawn_infected_nolimit
#define PLUGIN_VERSION "5.6-2024/1/27"

#define UNLOCK 0
#define LOCK 1

#define MODEL_END_SAFEROOM_DOOR_1 "models/props_doors/checkpoint_door_02.mdl"
#define MODEL_END_SAFEROOM_DOOR_2 "models/props_doors/checkpoint_door_-02.mdl"
#define MODEL_END_SAFEROOM_DOOR_3 "models/lighthouse/checkpoint_door_lighthouse02.mdl"

#define MODEL_START_SAFEROOM_DOOR_1 "models/props_doors/checkpoint_door_01.mdl"
#define MODEL_START_SAFEROOM_DOOR_2 "models/props_doors/checkpoint_door_-01.mdl"
#define MODEL_START_SAFEROOM_DOOR_3 "models/lighthouse/checkpoint_door_lighthouse01.mdl"

ConVar lsAnnounce, lsAntiFarmDuration, lsDuration, lsMobs, lsTankDemolitionBefore, lsTankDemolitionAfter,
	lsType, lsMinSurvivorPercent, lsHint, lsGetInLimit, lsDoorOpeningTeleport, lsDoorOpeningTankInterval,
	lsDoorBotDisable, lsMapOff, lsPreventDoorSpamDuration, lsDoorLockColor, lsDoorUnlockColor, lsDoorGlowRange, lsDoorOpenChance,
	lsCountDownHintType;

int iAntiFarmDuration, iDuration, iMobs, iType, g_iEndCheckpointDoor, g_iStartCheckpointDoor, iSystemTime, iGetInLimit, 
	iDoorOpeningTankInterval, iDoorGlowRange, g_iDoorOpenChance, iDoorOpenChance, iCountDownHintType;
int _iDoorOpeningTankInterval, g_iRoundStart, g_iPlayerSpawn, g_iDoorLockColors[3], g_iDoorUnlockColors[3],
	iMinSurvivorPercent;
float fDoorSpeed, fFirstUserOrigin[3], fPreventDoorSpamDuration;
bool bAntiFarmInit, bLockdownInit, bLDFinished, bAnnounce, bDoorOpeningTeleport, 
	bTankDemolitionBefore, bTankDemolitionAfter, bSurvivorsAssembleAlready,
	blsHint, bDoorBotDisable;
bool bSpawnTank, bRoundEnd, g_bIsSafeRoomOpen, g_bFirstRecord;
char sKeyMan[128];
Handle hAntiFarmTime = null, hLockdownTime = null;

ConVar lsMapTwoTanks, sb_unstick;
bool g_bMapTwoTanks;
bool sb_unstick_default;

GlobalForward g_hForwardOpenSafeRoomFinish;

bool g_bL4D2Version;
static char sSpawnCommand[32];
static int ZOMBIECLASS_TANK;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		ZOMBIECLASS_TANK = 5;
		sSpawnCommand = "z_spawn";
		g_bL4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		ZOMBIECLASS_TANK = 8;
		sSpawnCommand = "z_spawn_old";
		g_bL4D2Version = true;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	g_hForwardOpenSafeRoomFinish	= new GlobalForward("L4D2_OnLockDownOpenDoorFinish", ET_Ignore, Param_String);
	return APLRes_Success; 
}

public Plugin myinfo = 
{
	name = "[L4D1/2] Lockdown System",
	author = "cravenge, Harry",
	description = "Locks Saferoom Door Until Someone Opens It.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/forumdisplay.php?f=108"
};

public void OnPluginStart()
{
	LoadTranslations("lockdown_system-l4d2_b.phrases");

	sb_unstick = FindConVar("sb_unstick");

	lsAnnounce = CreateConVar("lockdown_system-l4d2_announce", "1", "If 1, Enable saferoom door status Announcements", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	lsAntiFarmDuration = CreateConVar("lockdown_system-l4d2_anti-farm_duration", "50", "Duration Of Anti-Farm", FCVAR_NOTIFY, true, 0.0);
	lsDuration = CreateConVar("lockdown_system-l4d2_duration", "100", "Duration Of Lockdown", FCVAR_NOTIFY, true, 0.0);
	lsMobs = CreateConVar("lockdown_system-l4d2_mobs", "5", "Number Of Mobs To Spawn", FCVAR_NOTIFY, true, 0.0, true, 15.0);
	lsTankDemolitionBefore = CreateConVar("lockdown_system-l4d2_tank_demolition_before", "1", "If 1, Enable Tank Demolition, server will spawn tank before door open ", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	lsTankDemolitionAfter = CreateConVar("lockdown_system-l4d2_tank_demolition_after", "1", "If 1, Enable Tank Demolition, server will spawn tank after door open ", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	lsType = CreateConVar("lockdown_system-l4d2_type", "0", "Lockdown Type: 0=Random, 1=Improved (opening slowly), 2=Default", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	lsMinSurvivorPercent = CreateConVar("lockdown_system-l4d2_percentage_survivors_near_saferoom", "50", "What percentage of the ALIVE survivors must assemble near the saferoom door before open. (0=off)", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	lsHint = CreateConVar(	"lockdown_system-l4d2_spam_hint", "1", "0=Off. 1=Display a message showing who opened or closed the saferoom door.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	lsGetInLimit = CreateConVar( "lockdown_system-l4d2_outside_slay_duration", "60", "After saferoom door is opened, slay players who are not inside saferoom in seconds. (0=off)", FCVAR_NOTIFY, true, 0.0);
	lsDoorOpeningTeleport = CreateConVar( "lockdown_system-l4d2_teleport", "1", "0=Off. 1=Teleport common, special infected, and witch if they touch the door inside saferoom when door is opening. (prevent spawning and be stuck inside the saferoom, only works if Lockdown Type is 2)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	lsDoorOpeningTankInterval = CreateConVar( "lockdown_system-l4d2_opening_tank_interval", "50", "Time Interval to spawn a tank when door is opening (0=off)", FCVAR_NOTIFY, true, 0.0);
	lsDoorBotDisable = CreateConVar( "lockdown_system-l4d2_spam_bot_disable", "1", "If 1, prevent AI survivor from opening and closing the door.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	lsMapOff = CreateConVar("lockdown_system-l4d2_map_off",	"c10m3_ranchhouse,l4d_reverse_hos03_sewers,l4d2_stadium4_city2,l4d_fairview10_church,l4d2_wanli01,l4d_smalltown03_ranchhouse,l4d_vs_smalltown03_ranchhouse",	"Turn off the plugin in these maps, separate by commas (no spaces). (0=All maps, Empty = none).", FCVAR_NOTIFY );
	lsPreventDoorSpamDuration = CreateConVar("lockdown_system-l4d2_prevent_spam_duration", "3.0", "How many seconds to lock after opening and closing the saferoom door.", FCVAR_NOTIFY, true, 0.0);
	if(g_bL4D2Version)
	{
		lsDoorLockColor = CreateConVar(	"lockdown_system-l4d2_lock_glow_color",	"255 0 0",	"The default glow color for saferoom door when lock. Three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue.", FCVAR_NOTIFY );
		lsDoorUnlockColor = CreateConVar( "lockdown_system-l4d2_unlock_glow_color",	"200 200 200",	"The default glow color for saferoom door when unlock. Three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue.", FCVAR_NOTIFY );
		lsDoorGlowRange = CreateConVar( "lockdown_system-l4d2_glow_range", "550", "The default value for saferoom door glow range.", FCVAR_NOTIFY, true, 0.0);
	}
	lsDoorOpenChance = CreateConVar("lockdown_system-l4d2_open_chance",	"2",	"After saferoom door is opened, how many chance can the survivors open the door. (0=Can't open door after close, -1=No limit)", FCVAR_NOTIFY );
	lsCountDownHintType = CreateConVar("lockdown_system-l4d2_count_hint_type", "2", "Change how Count Down Timer Hint displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	lsMapTwoTanks = CreateConVar("lockdown_system-l4d2_map_two_Tank",	"c1m3_mall",	"Two tanks during opening door in these maps, separate by commas (no spaces). (0=All maps, Empty = none).", FCVAR_NOTIFY );
	
	GetCvars();
	lsAnnounce.AddChangeHook(OnLSCVarsChanged);
	lsAntiFarmDuration.AddChangeHook(OnLSCVarsChanged);
	lsDuration.AddChangeHook(OnLSCVarsChanged_lsDuration);
	lsMobs.AddChangeHook(OnLSCVarsChanged);
	lsTankDemolitionBefore.AddChangeHook(OnLSCVarsChanged);
	lsTankDemolitionAfter.AddChangeHook(OnLSCVarsChanged);
	lsMinSurvivorPercent.AddChangeHook(OnLSCVarsChanged);
	lsHint.AddChangeHook(OnLSCVarsChanged);
	lsGetInLimit.AddChangeHook(OnLSCVarsChanged);
	lsDoorOpeningTeleport.AddChangeHook(OnLSCVarsChanged);
	lsDoorOpeningTankInterval.AddChangeHook(OnLSCVarsChanged);
	lsDoorBotDisable.AddChangeHook(OnLSCVarsChanged);
	lsPreventDoorSpamDuration.AddChangeHook(OnLSCVarsChanged);
	if(g_bL4D2Version)
	{
		lsDoorLockColor.AddChangeHook(OnLSCVarsChanged);
		lsDoorUnlockColor.AddChangeHook(OnLSCVarsChanged);
		lsDoorGlowRange.AddChangeHook(OnLSCVarsChanged);
	}
	lsDoorOpenChance.AddChangeHook(OnLSCVarsChanged);
	lsCountDownHintType.AddChangeHook(OnLSCVarsChanged);

	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("mission_lost", Event_RoundEnd); //wipe out
	HookEvent("map_transition", Event_RoundEnd); //mission complete
	HookEvent("entity_killed", TC_ev_EntityKilled);
	HookEvent("door_open",			Event_DoorOpen);
	HookEvent("door_close",			Event_DoorClose);

	AutoExecConfig(true, "lockdown_system-l4d2");
}

public void OnPluginEnd()
{
	SetCheckpointDoor_Default();
	ResetPlugin();
	g_bFirstRecord = false;
	sb_unstick.SetBool(sb_unstick_default);
}

bool g_bValidMap, g_bSLSDisable;
public void OnMapStart()
{
	g_bValidMap = true;
}

public void OnMapEnd()
{
	bAntiFarmInit = false;
	bLockdownInit = false;
	bLDFinished = false;
	
	SetCheckpointDoor_Default();

	ResetPlugin();
}

public void OnConfigsExecuted()
{
	GetCvars();

	if(!g_bFirstRecord)
	{
		sb_unstick_default = sb_unstick.BoolValue;
		g_bFirstRecord = true;
	}

	char sCvar[1024];
	lsMapOff.GetString(sCvar, sizeof(sCvar));

	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	if( sCvar[0] != '\0' )
	{
		if( strcmp(sCvar, "0") == 0 )
		{
			g_bValidMap = false;
		} else {
			Format(sMap, sizeof(sMap), ",%s,", sMap);
			Format(sCvar, sizeof(sCvar), ",%s,", sCvar);

			if( StrContains(sCvar, sMap, false) != -1 )
			{
				g_bValidMap = false;
			}
		}
	}

	g_bMapTwoTanks = false;
	lsMapTwoTanks.GetString(sCvar, sizeof(sCvar));
	if( sCvar[0] != '\0' )
	{
		if( strcmp(sCvar, "0") == 0 )
		{
			g_bMapTwoTanks = true;
		} else {
			Format(sCvar, sizeof(sCvar), ",%s,", sCvar);

			if( StrContains(sCvar, sMap, false) != -1 )
			{
				g_bMapTwoTanks = true;
			}
		}
	}

	if(L4D_IsMissionFinalMap(true))
	{
		g_bValidMap = false;
	}

	if (g_bValidMap)
	{
		PrecacheSound("doors/latchlocked2.wav", true);
		PrecacheSound("doors/door_squeek1.wav", true);	
		PrecacheSound("ambient/alarms/klaxon1.wav", true);
		PrecacheSound("level/highscore.wav", true);
	}
}

void OnLSCVarsChanged_lsDuration(ConVar cvar, const char[] sOldValue, const char[] sNewValue)
{
	GetCvars();
	
	if (IsValidEntRef(g_iEndCheckpointDoor))
	{
		if (iType != 1)
		{
			return;
		}
		
		SetEntPropFloat(g_iEndCheckpointDoor, Prop_Data, "m_flSpeed", 89.0 / float(iDuration));
	}
}

void OnLSCVarsChanged(ConVar cvar, const char[] sOldValue, const char[] sNewValue)
{
	GetCvars();
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;

	g_bSLSDisable = false;
	g_iStartCheckpointDoor = -1;
	g_iEndCheckpointDoor = -1;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

Action tmrStart(Handle timer)
{
	if (g_bValidMap == false)
	{
		return Plugin_Continue;
	}

	iType = (lsType.IntValue == 0) ? GetRandomInt(1, 2) : lsType.IntValue;
	
	bAntiFarmInit = false;
	bLockdownInit = false;
	bLDFinished = false;
	bSurvivorsAssembleAlready = false;
	bRoundEnd = false;
	bSpawnTank = false;
	g_bIsSafeRoomOpen = false;
	iDoorOpenChance = (g_iDoorOpenChance == -1) ? -1 : g_iDoorOpenChance + 1;
	_iDoorOpeningTankInterval = 0;

	InitDoor();

	ResetPlugin();

	sb_unstick.SetBool(sb_unstick_default);
	
	return Plugin_Continue;
}


void TC_ev_EntityKilled(Event event, const char[] name, bool dontBroadcast) 
{
	if (g_bValidMap == false || !bTankDemolitionAfter || !bLDFinished)
	{
		return;
	}

	if (IsPlayerTank(event.GetInt("entindex_killed")))
	{
		CreateTimer(1.5, Timer_SpawnTank, _,TIMER_FLAG_NO_MAPCHANGE);
	}
}

Action Timer_SpawnTank(Handle timer)
{
	if(RealFreePlayersOnInfected())
		CheatCommand(my_GetRandomClient(), sSpawnCommand, "tank auto");
	else
		ExecuteSpawn(true, 1);
	
	return Plugin_Continue;
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (bRoundEnd) return;

	bRoundEnd = true;

	if (g_bValidMap == false)
	{
		return;
	}
	
	if (hAntiFarmTime != null)
	{
		bLockdownInit = true;
		delete hAntiFarmTime;
		
		CreateTimer(1.75, ForceEndLockdown,_, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		CreateTimer(1.5, ForceEndLockdown,_, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	CreateTimer(2.0, OrderShutDown,_,TIMER_FLAG_NO_MAPCHANGE);

	ResetPlugin();

	sb_unstick.SetBool(sb_unstick_default);
}

Action ForceEndLockdown(Handle timer)
{
	delete hLockdownTime;
	bLDFinished = true;
	
	return Plugin_Continue;
}

Action OrderShutDown(Handle timer)
{
	SetCheckpointDoor_Default();
	return Plugin_Continue;
}

Action OnUse_EndCheckpointDoor(int door, int client, int caller, UseType type, float value)
{
	if (g_bValidMap == false || bRoundEnd || g_bSLSDisable)
	{
		return Plugin_Continue;
	}
	
	if (IsSurvivor(client))
	{
		if(bDoorBotDisable && IsFakeClient(client))
		{
			return Plugin_Handled;
		}

		if (!IsPlayerAlive(client))
		{
			return Plugin_Continue;
		}

		if(IsValidEntRef(g_iStartCheckpointDoor))
		{
			AcceptEntityInput(g_iStartCheckpointDoor, "Kill");
			g_iStartCheckpointDoor = -1;
		}

		if(g_bIsSafeRoomOpen == true && iDoorOpenChance == 0)
		{
			PrintHintText(client, "[TS] %T", "No Chance", client);
			return Plugin_Handled;
		}
		
		int state = GetEntProp(door, Prop_Data, "m_eDoorState");
		if (state==DOOR_STATE_CLOSED)
		{
			if(iMinSurvivorPercent > 0 && !bSurvivorsAssembleAlready)
			{
				float clientOrigin[3];
				float doorOrigin[3];
				int iParam = 0, iReached = 0;
				GetEntPropVector(door, Prop_Send, "m_vecOrigin", doorOrigin);
				for (int i = 1; i <= MaxClients; i++)
				{
					if(IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
					{
						iParam ++;
						GetClientAbsOrigin(i, clientOrigin);
						if (GetVectorDistance(clientOrigin, doorOrigin, true) <= 750 * 750)
						{
							iReached++;
						}
					}
				}

				iParam = RoundToCeil(iMinSurvivorPercent / 100.0 * iParam);
				if(iReached < iParam)
				{
					PrintHintText(client, "[TS] %T", "SurvivorReached", client, iReached, iParam);
					return Plugin_Handled;
				}

				bSurvivorsAssembleAlready = true;
			}

			if(bTankDemolitionBefore && !bSpawnTank) 
			{
				if(g_bMapTwoTanks)
					ExecuteSpawn(true , 2);
				else
					ExecuteSpawn(true , 1);

				bSpawnTank = true;
			}
			
			sb_unstick.SetBool(false);
			
			if (GetTankCount() > 0)
			{
				if (bLDFinished || bLockdownInit)
				{
					bAntiFarmInit = true;
					return Plugin_Handled;
				}
				
				
				if (!bAntiFarmInit)
				{
					bAntiFarmInit = true;
					iSystemTime = iAntiFarmDuration;
					
					PrintHintText(client, "[TS] %T", "Tank is still alive", client);
					EmitSoundToAll("doors/latchlocked2.wav", door, SNDCHAN_AUTO);

					GetClientAbsOrigin(client, fFirstUserOrigin);
					GetClientName(client, sKeyMan, sizeof(sKeyMan));
					
					ExecuteSpawn(false, iMobs);
					
					if (hAntiFarmTime == null)
					{
						hAntiFarmTime = CreateTimer(float(iAntiFarmDuration) + 1.0, EndAntiFarm);
					}
					CreateTimer(1.0, CheckAntiFarm, EntIndexToEntRef(door), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
					SDKHook(door, SDKHook_Touch, OnTouch);
				}
			}
			else
			{
				if (bAntiFarmInit)
				{
					return Plugin_Handled;
				}
				
				if (!bLockdownInit)
				{
					bLockdownInit = true;
					iSystemTime = iDuration;

					GetClientAbsOrigin(client, fFirstUserOrigin);
					GetClientName(client, sKeyMan, sizeof(sKeyMan));
					
					ExecuteSpawn(false, iMobs);
					if (iType == 1)
					{
						ControlDoor(g_iEndCheckpointDoor, UNLOCK);
					}
					
					if (hLockdownTime == null)
					{
						hLockdownTime = CreateTimer(float(iDuration) + 1.0, EndLockdown);
					}

					CreateTimer(1.0, LockdownOpening, EntIndexToEntRef(door), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
					SDKHook(door, SDKHook_Touch, OnTouch);
				}
			}
		}
	}

	return Plugin_Continue;
}

Action CheckAntiFarm(Handle timer, any entity)
{
	if (!entity || (entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE || !IsValidEntRef(g_iEndCheckpointDoor))
	{
		delete hAntiFarmTime;
		return Plugin_Stop;
	}

	if (GetTankCount() < 1 || hAntiFarmTime == null)
	{
		delete hAntiFarmTime;
		
		if (!bLockdownInit)
		{
			bLockdownInit = true;
			ExecuteSpawn(false, iMobs);
			
			if (iType == 1)
			{
				ControlDoor(g_iEndCheckpointDoor, UNLOCK);
			}
			
			if (hLockdownTime == null)
			{
				hLockdownTime = CreateTimer(float(iDuration) + 1.0, EndLockdown);
			}
			iSystemTime = iDuration;
			CreateTimer(1.0, LockdownOpening, EntIndexToEntRef(entity), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
		return Plugin_Stop;
	}
	
	switch(iCountDownHintType)
	{
		case 0: {/*nothing*/}
		case 1: {
			PrintToChatAll("[ANTI-FARM] %t", "Tank is still alive, or wait", iSystemTime);
		}
		case 2: {
			PrintHintTextToAll("[ANTI-FARM] %t", "Tank is still alive, or wait", iSystemTime);
		}
		case 3: {
			PrintCenterTextAll("[ANTI-FARM] %t", "Tank is still alive, or wait", iSystemTime);
		}
	}
	
	iSystemTime -= 1;
	
	return Plugin_Continue;
}

Action EndAntiFarm(Handle timer)
{
	hAntiFarmTime = null;
	
	return Plugin_Continue;
}

Action LockdownOpening(Handle timer, any entity)
{
	if (!entity || (entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}

	if (hLockdownTime == null)
	{
		if (!bLDFinished)
		{
			bLDFinished = true;
			
			EmitSoundToAll("doors/door_squeek1.wav", entity);
			if (iType != 1)
			{
				ControlDoor(entity, UNLOCK);
			}
			else
			{
				SetEntPropFloat(entity, Prop_Data, "m_flSpeed", fDoorSpeed);
				SetEntProp(entity, Prop_Data, "m_hasUnlockSequence", UNLOCK);
				AcceptEntityInput(entity, "Unlock");
				AcceptEntityInput(entity, "Close");
				AcceptEntityInput(entity, "ForceClosed");
				AcceptEntityInput(entity, "Open");
			}
			
			EmitSoundToAll("level/highscore.wav", entity, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_LOW, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);

			if(blsHint) CPrintToChatAll("{default}[{olive}TS{default}]{green} <{olive}%s{green}>{default} %t", sKeyMan, "open the door already");
			if(bAnnounce)
			{
				PrintHintTextToAll("%t","Door is opened! GET IN!!");
				if(g_iDoorOpenChance >= 0) CPrintToChatAll("{default}[{olive}TS{default}] %t", "Chance", iDoorOpenChance - 1);
			}
			CreateTimer(5.0, LaunchTankDemolition, _, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(5.0, LaunchSlayTimer, _, TIMER_FLAG_NO_MAPCHANGE);

			g_bIsSafeRoomOpen = true;

			Call_StartForward(g_hForwardOpenSafeRoomFinish);
			Call_PushString(sKeyMan);
			Call_Finish();
		}
		return Plugin_Stop;
	}
	
	
	switch(iCountDownHintType)
	{
		case 0: {/*nothing*/}
		case 1: {
			PrintToChatAll("[LOCKDOWN] %t", "Lockdown in seconds", iSystemTime);
		}
		case 2: {
			PrintHintTextToAll("[LOCKDOWN] %t", "Lockdown in seconds", iSystemTime);
		}
		case 3: {
			PrintCenterTextAll("[LOCKDOWN] %t", "Lockdown in seconds", iSystemTime);
		}
	}
	
	EmitSoundToAll("ambient/alarms/klaxon1.wav", entity, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_LOW, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);	


	iSystemTime --;

	if(iDoorOpeningTankInterval > 0 && _iDoorOpeningTankInterval >= iDoorOpeningTankInterval)
	{
		CreateTimer(0.1, Timer_SpawnTank, _,TIMER_FLAG_NO_MAPCHANGE);

		if(g_bMapTwoTanks)
		{
			CreateTimer(0.2, Timer_SpawnTank, _,TIMER_FLAG_NO_MAPCHANGE);
		}
		
		_iDoorOpeningTankInterval = 0;
	}
	_iDoorOpeningTankInterval++;

	return Plugin_Continue;
}

Action EndLockdown(Handle timer)
{
	if (hLockdownTime == null)
	{
		return Plugin_Stop;
	}
	
	KillTimer(hLockdownTime);
	hLockdownTime = null;
	
	return Plugin_Stop;
}

Action LaunchTankDemolition(Handle timer)
{
	if (bTankDemolitionAfter == false)
	{
		return Plugin_Continue;
	}
	
	ExecuteSpawn(true, 4);
	if (bAnnounce)
	{
		CPrintToChatAll("{default}[{olive}TS{default}] %t","Tanks are coming");
	}
	
	return Plugin_Continue;
}

Action LaunchSlayTimer(Handle timer)
{
	iSystemTime = iGetInLimit;
	if(iSystemTime > 0) CreateTimer(1.0, AntiPussy, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Continue;
}

Action AntiPussy(Handle timer)
{
	if (bRoundEnd) return Plugin_Stop;
	
	if (!IsValidEntRef(g_iEndCheckpointDoor)) return Plugin_Stop;
	
	EmitSoundToAll("ambient/alarms/klaxon1.wav", g_iEndCheckpointDoor, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_LOW, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	
	switch(iCountDownHintType)
	{
		case 0: {/*nothing*/}
		case 1: {
			PrintToChatAll("[LOCKDOWN] %t", "Slay in seconds", iSystemTime);
		}
		case 2: {
			PrintHintTextToAll("[LOCKDOWN] %t", "Slay in seconds", iSystemTime);
		}
		case 3: {
			PrintCenterTextAll("[LOCKDOWN] %t", "Slay in seconds", iSystemTime);
		}
	}
	
	if(iSystemTime <= 0)
	{
		//AcceptEntityInput(g_iEndCheckpointDoor, "Close");
		//AcceptEntityInput(g_iEndCheckpointDoor, "ForceClosed");

		if(bAnnounce) CPrintToChatAll("{default}[{olive}TS{default}] %t","Outside Slay");
		
		CreateTimer(2.5, _AntiPussy, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Stop;
	}

	iSystemTime -= 1;
	return Plugin_Continue;
}

Action _AntiPussy(Handle timer)
{
	if(bRoundEnd) return Plugin_Stop;
	
	for( int i = 1; i <= MaxClients; i++ ) 
	{
		if(IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && !L4D_IsInLastCheckpoint(i))
		{
			ForcePlayerSuicide(i);
			if(bAnnounce) {
				PrintHintText(i, "[TS] %T", "You have been executed for outside the saferoom!", i);
			}
		}
	}
	return Plugin_Continue;
}

void InitDoor()
{
	g_iEndCheckpointDoor = L4D_GetCheckpointLast();
	if( g_iEndCheckpointDoor == -1 )
	{
		g_iEndCheckpointDoor = FindEndSafeRoomDoor();
		return;
	}
	else
	{
		char sModelName[128];
		GetEntPropString(g_iEndCheckpointDoor, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
		if( strcmp(sModelName, MODEL_START_SAFEROOM_DOOR_1, false) == 0 ||
			strcmp(sModelName, MODEL_START_SAFEROOM_DOOR_2, false) == 0 ||
			strcmp(sModelName, MODEL_START_SAFEROOM_DOOR_3, false) == 0) //抓錯安全門
		{
			g_iEndCheckpointDoor = FindEndSafeRoomDoor();
		}
	}

	if(g_iEndCheckpointDoor == -1)
	{
		g_iEndCheckpointDoor = 0;
		return;
	}

	fDoorSpeed = GetEntPropFloat(g_iEndCheckpointDoor, Prop_Data, "m_flSpeed");
	
	ControlDoor(g_iEndCheckpointDoor, LOCK);
	
	HookSingleEntityOutput(g_iEndCheckpointDoor, "OnFullyOpen", OnDoorAntiSpam);
	HookSingleEntityOutput(g_iEndCheckpointDoor, "OnFullyClosed", OnDoorAntiSpam);
	
	HookSingleEntityOutput(g_iEndCheckpointDoor, "OnBlockedOpening", OnDoorBlocked);
	HookSingleEntityOutput(g_iEndCheckpointDoor, "OnBlockedClosing", OnDoorBlocked);

	SDKHook(g_iEndCheckpointDoor, SDKHook_Use, OnUse_EndCheckpointDoor);

	g_iEndCheckpointDoor = EntIndexToEntRef(g_iEndCheckpointDoor);

	//抓起始安全室
	g_iStartCheckpointDoor = L4D_GetCheckpointFirst();
	if(g_iStartCheckpointDoor > 0)
	{
		int state = GetEntProp(g_iStartCheckpointDoor, Prop_Data, "m_eDoorState");
		if( state == DOOR_STATE_OPENED ) //抓錯安全門
		{
			g_iStartCheckpointDoor = FindStartSafeRoomDoor();
		}
		else
		{
			char sModelName[128];
			GetEntPropString(g_iStartCheckpointDoor, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
			if( strcmp(sModelName,MODEL_END_SAFEROOM_DOOR_1, false) == 0 ||
				strcmp(sModelName,MODEL_END_SAFEROOM_DOOR_2, false) == 0 ||
				strcmp(sModelName,MODEL_END_SAFEROOM_DOOR_3, false) == 0) //抓錯安全門
			{
				g_iStartCheckpointDoor = FindStartSafeRoomDoor();
			}
		}
	}

	if( g_iStartCheckpointDoor == -1 ) 
		return;

	g_iStartCheckpointDoor = EntIndexToEntRef(g_iStartCheckpointDoor);
}

void OnDoorAntiSpam(const char[] output, int caller, int activator, float delay)
{
	if (g_bSLSDisable) return;

	if (strcmp(output, "OnFullyClosed") == 0)
	{
		if(!bLDFinished) return;
	}
	
	AcceptEntityInput(caller, "Lock");
	SetEntProp(caller, Prop_Data, "m_hasUnlockSequence", LOCK);
	
	if(g_bL4D2Version) L4D2_SetEntityGlow(caller, L4D2Glow_Constant, iDoorGlowRange, 0, g_iDoorLockColors, false);
	
	if(strcmp(output, "OnFullyClosed") == 0 && g_bIsSafeRoomOpen && g_iDoorOpenChance >= 0)
	{
		CPrintToChatAll("{default}[{olive}TS{default}] %t", "Chance Left", --iDoorOpenChance);
		if(iDoorOpenChance == 0) return;
	}

	CreateTimer(fPreventDoorSpamDuration, PreventDoorSpam, EntIndexToEntRef(caller), TIMER_FLAG_NO_MAPCHANGE);
}

Action PreventDoorSpam(Handle timer, any entity)
{
	if (!entity || (entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE)
	{
		return Plugin_Continue;
	}
	
	if(g_bL4D2Version) L4D2_SetEntityGlow(entity, L4D2Glow_Constant, iDoorGlowRange, 0, g_iDoorUnlockColors, false);
	
	SetEntProp(entity, Prop_Data, "m_hasUnlockSequence", UNLOCK);
	AcceptEntityInput(entity, "Unlock");
	
	return Plugin_Continue;
}

void OnDoorBlocked(const char[] output, int caller, int activator, float delay)
{
	if (g_bSLSDisable) return;

	if (!IsCommonInfected(activator))
	{
		return;
	}

	AcceptEntityInput(activator, "BecomeRagdoll");
}

void ControlDoor(int entity, int iOperation)
{
	switch (iOperation)
	{
		case LOCK:
		{
			if(g_bL4D2Version) L4D2_SetEntityGlow(entity, L4D2Glow_Constant, iDoorGlowRange, 0, g_iDoorLockColors, false);
			
			AcceptEntityInput(entity, "Close");
			if (iType == 1)
			{
				SetEntPropFloat(entity, Prop_Data, "m_flSpeed", 89.0 / float(iDuration));
			}
			AcceptEntityInput(entity, "Lock");
			if (iType != 1)
			{
				AcceptEntityInput(entity, "ForceClosed");
			}
			SetEntProp(entity, Prop_Data, "m_hasUnlockSequence", LOCK);
		}
		case UNLOCK:
		{
			if(g_bL4D2Version) L4D2_SetEntityGlow(entity, L4D2Glow_Constant, iDoorGlowRange, 0, g_iDoorUnlockColors, false);
			
			SetEntProp(entity, Prop_Data, "m_hasUnlockSequence", UNLOCK);
			AcceptEntityInput(entity, "Unlock");
			AcceptEntityInput(entity, "ForceClosed");
			AcceptEntityInput(entity, "Open");
		}
	}
}

int my_GetRandomClient()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			iClients[iClientCount++] = i;
		}
	}
	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

int GetTankCount()
{
	int iCount = 0;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 3 && GetEntProp(i, Prop_Send, "m_zombieClass") == ZOMBIECLASS_TANK && IsPlayerAlive(i))
		{
			iCount += 1;
		}
	}
	return iCount;
}

stock bool IsSurvivor(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2);
}

stock bool IsValidEnt(int entity)
{
	return (entity > 0 && IsValidEntity(entity) && IsValidEdict(entity));
}

stock bool IsCommonInfected(int entity)
{
	if (IsValidEnt(entity))
	{
		char sEntityClass[64];
		GetEntityClassname(entity, sEntityClass, sizeof(sEntityClass));
		return strcmp(sEntityClass, "infected") == 0;
	}
	
	return false;
}

stock void ExecuteSpawn(bool btank, int iCount)
{
	if (btank)
	{
		CreateTankBot();
		iCount--;
		for (int i = 1; i <= iCount; i++)
		{
			CreateTimer(0.5 * i, Timer_CreateTank, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else
	{
		L4D_ForcePanicEvent();
		int anyclient = my_GetRandomClient();
		if(anyclient > 0)
		{
			char sCommand[16];
			strcopy(sCommand, sizeof(sCommand), sSpawnCommand);
			int iFlags = GetCommandFlags(sCommand);
			SetCommandFlags(sCommand, iFlags & ~FCVAR_CHEAT);
			for (int i = 0; i < iCount-1; i++)
			{
				if(g_bL4D2Version)
				{
					FakeClientCommand(anyclient, "z_spawn_old mob auto");
				}
				else
				{
					FakeClientCommand(anyclient, "z_spawn mob auto");
				}
			}
			SetCommandFlags(sCommand, iFlags);
		}	
	}
}

Action Timer_CreateTank(Handle timer)
{
	CreateTankBot();

	return Plugin_Continue;
}

void CreateTankBot()
{
	float vecPos[3];
	int anyclient = my_GetRandomClient();
	if(anyclient > 0 && L4D_GetRandomPZSpawnPosition(anyclient,8,5,vecPos) == true)
	{
		int newtankbot = NoLimit_CreateInfected("tank", vecPos, NULL_VECTOR);//召喚坦克
		if (newtankbot > 0)
		{
			CreateTimer(3.0, AttackOnTank, GetClientUserId(newtankbot), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

Action AttackOnTank(Handle timer, int tank)
{
	tank = GetClientOfUserId(tank);
	if(tank && IsClientInGame(tank))
	{
		SetEntProp(tank, Prop_Send, "m_zombieState", 1);
		SetEntProp(tank, Prop_Send, "m_hasVisibleThreats", 1);
		DealDamage(tank, 0,  GetSurvivor(), DMG_BULLET, "weapon_smg");
	}
	
	return Plugin_Continue;
}

stock bool IsPlayerGhost(int client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost", 1)) return true;
	return false;
}

bool IsValidClient(int client, bool replaycheck = true)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	//if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	if (replaycheck)
	{
		if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	}
	return true;
}

stock void CheatCommand(int client,  char[] command, char[] arguments = "")
{
	if(client == 0) return;
	int userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userFlags);
}

bool RealFreePlayersOnInfected ()
{
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 3 && (IsPlayerGhost(i) || !IsPlayerAlive(i)))
			return true;
	}
	return false;
}

bool IsPlayerTank (int client)
{
    return (GetEntProp(client, Prop_Send, "m_zombieClass") == ZOMBIECLASS_TANK);
}

void Event_DoorOpen(Event event, const char[] name, bool dontBroadcast)
{
	if( event.GetBool("checkpoint") )
		DoorPrint(event, true);
}

void Event_DoorClose(Event event, const char[] name, bool dontBroadcast)
{
	if( event.GetBool("checkpoint") )
		DoorPrint(event, false);
}

void DoorPrint(Event event, bool open)
{
	if( !bRoundEnd && bLDFinished && blsHint)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if( client && IsClientInGame(client) && GetClientTeam(client) == 2)
		{
			if(open) CPrintToChatAll("{default}[{olive}TS{default}]{green} ---{olive}%N{green}---{default} %t", client, "someone opens the door");
			else CPrintToChatAll("{default}[{olive}TS{default}]{green} ---{olive}%N{green}---{default} %t", client, "someone closes the door");
		}
	}
}

void GetCvars()
{
	iAntiFarmDuration = lsAntiFarmDuration.IntValue;
	iDuration = lsDuration.IntValue;
	iMobs = lsMobs.IntValue;
	
	bAnnounce = lsAnnounce.BoolValue;
	bTankDemolitionBefore = lsTankDemolitionBefore.BoolValue;
	bTankDemolitionAfter = lsTankDemolitionAfter.BoolValue;
	iMinSurvivorPercent = lsMinSurvivorPercent.IntValue;
	blsHint = lsHint.BoolValue;
	iGetInLimit = lsGetInLimit.IntValue;
	bDoorOpeningTeleport = lsDoorOpeningTeleport.BoolValue;
	iDoorOpeningTankInterval = lsDoorOpeningTankInterval.IntValue;
	bDoorBotDisable = lsDoorBotDisable.BoolValue;
	fPreventDoorSpamDuration = lsPreventDoorSpamDuration.FloatValue;
	if(g_bL4D2Version) iDoorGlowRange = lsDoorGlowRange.IntValue;
	g_iDoorOpenChance = lsDoorOpenChance.IntValue;
	iCountDownHintType = lsCountDownHintType.IntValue;
	
	if(g_bL4D2Version)
	{
		char sColor[16];
		lsDoorLockColor.GetString(sColor, sizeof(sColor));
		GetColor(g_iDoorLockColors, sColor);
		lsDoorUnlockColor.GetString(sColor, sizeof(sColor));
		GetColor(g_iDoorUnlockColors, sColor);
	}
}

void OnTouch(int door, int other)
{
	if(!bDoorOpeningTeleport || iType == 1) return;

	if(bRoundEnd || bLDFinished)
	{
		SDKUnhook(door, SDKHook_Touch, OnTouch);
	}
	//PrintToChatAll("%d touches door %d",other,door);

	if (IsValidClient(other) && IsPlayerAlive(other) && GetClientTeam(other) != 1 && L4D_IsInLastCheckpoint(other))
	{
		TeleportEntity(other, fFirstUserOrigin, NULL_VECTOR, NULL_VECTOR);
		return;
	}

	if (IsCommonInfected(other))
	{
		TeleportEntity(other, fFirstUserOrigin, NULL_VECTOR, NULL_VECTOR);
		return;
	}

	if (IsWitch(other))
	{
		TeleportEntity(other, fFirstUserOrigin, NULL_VECTOR, NULL_VECTOR);
		return;
	}
}

bool IsWitch(int entity)
{
    if (entity > 0 && IsValidEntity(entity) && IsValidEdict(entity))
    {
        char strClassName[64];
        GetEntityClassname(entity, strClassName, sizeof(strClassName));
        return strcmp(strClassName, "witch") == 0;
    }
    return false;
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

void SetCheckpointDoor_Default()
{
	if (IsValidEntRef(g_iEndCheckpointDoor))
	{
		UnhookSingleEntityOutput(g_iEndCheckpointDoor, "OnFullyOpen", OnDoorAntiSpam);
		UnhookSingleEntityOutput(g_iEndCheckpointDoor, "OnFullyClosed", OnDoorAntiSpam);
		
		UnhookSingleEntityOutput(g_iEndCheckpointDoor, "OnBlockedOpening", OnDoorBlocked);
		UnhookSingleEntityOutput(g_iEndCheckpointDoor, "OnBlockedClosing", OnDoorBlocked);

		if (iType == 1)
		{
			SetEntProp(g_iEndCheckpointDoor, Prop_Data, "m_hasUnlockSequence", UNLOCK);
			SetEntPropFloat(g_iEndCheckpointDoor, Prop_Data, "m_flSpeed", fDoorSpeed);
			AcceptEntityInput(g_iEndCheckpointDoor, "Unlock");
			AcceptEntityInput(g_iEndCheckpointDoor, "Close");
			AcceptEntityInput(g_iEndCheckpointDoor, "ForceClosed");
			AcceptEntityInput(g_iEndCheckpointDoor, "Open");
		}
		else
		{
			ControlDoor(g_iEndCheckpointDoor, UNLOCK);
		}

		L4D2_RemoveEntityGlow(g_iEndCheckpointDoor);

		g_iEndCheckpointDoor = -1;
	}
}

void GetColor(int[] array, char[] sTemp)
{
	if( StrEqual(sTemp, "") )
	{
		array[0] = array[1] = array[2] = 0;
		return;
	}

	char sColors[3][4];
	int color = ExplodeString(sTemp, " ", sColors, 3, 4);

	if( color != 3 )
	{
		array[0] = array[1] = array[2] = 0;
		return;
	}

	array[0] = StringToInt(sColors[0]);
	array[1] = StringToInt(sColors[1]);
	array[2] = StringToInt(sColors[2]);
}

int GetSurvivor() {
	for( int i = 1; i <= MaxClients; i++ ) {
		if( IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) ) {
		    return i;
		}
	}

	return 0;
}

void DealDamage(int victim, int damage, int attacker = 0, int dmg_type = DMG_GENERIC, char[] weapon = "") {
	if(victim>0 && IsValidEdict(victim) && IsClientInGame(victim) && IsPlayerAlive(victim)) {
		char dmg_str[16];
		IntToString(damage,dmg_str,16);
		char dmg_type_str[32];
		IntToString(dmg_type,dmg_type_str,32);
		int pointHurt=CreateEntityByName("point_hurt");
		if (pointHurt) {
			DispatchKeyValue(victim,"targetname","war3_hurtme");
			DispatchKeyValue(pointHurt,"DamageTarget","war3_hurtme");
			DispatchKeyValue(pointHurt,"Damage",dmg_str);
			DispatchKeyValue(pointHurt,"DamageType",dmg_type_str);
			
			if(!StrEqual(weapon,"")) {
				DispatchKeyValue(pointHurt,"classname",weapon);
			}
			DispatchSpawn(pointHurt);
			AcceptEntityInput(pointHurt,"Hurt",(attacker>0)?attacker:-1);
			DispatchKeyValue(victim,"targetname","war3_donthurtme");
			RemoveEdict(pointHurt);
		}
	}
}

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}

int FindStartSafeRoomDoor()
{
	// Search for a locked checkpoint door...
	int ent = MaxClients+1;
	int state;
	char sModelName[128];
	while((ent = FindEntityByClassname(ent, "prop_door_rotating_checkpoint")) != -1)
	{
		if(!IsValidEntity(ent)) continue;

		state = GetEntProp(ent, Prop_Data, "m_eDoorState");
		
		if(state == DOOR_STATE_CLOSED)
		{
			GetEntPropString(ent, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
			if( strcmp(sModelName,MODEL_START_SAFEROOM_DOOR_1, false) == 0 ||
				strcmp(sModelName,MODEL_START_SAFEROOM_DOOR_2, false) == 0 ||
				strcmp(sModelName,MODEL_START_SAFEROOM_DOOR_3, false) == 0)
			{
				return ent;
			}
		}
	}

	return -1;
}

int FindEndSafeRoomDoor()
{
	// Search for a locked checkpoint door...
	int ent = MaxClients+1;
	char sModelName[128];
	while((ent = FindEntityByClassname(ent, "prop_door_rotating_checkpoint")) != -1)
	{
		if(!IsValidEntity(ent)) continue;

		GetEntPropString(ent, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
		if( strcmp(sModelName, MODEL_END_SAFEROOM_DOOR_1, false) == 0 ||
			strcmp(sModelName, MODEL_END_SAFEROOM_DOOR_2, false) == 0 ||
			strcmp(sModelName, MODEL_END_SAFEROOM_DOOR_3, false) == 0)
		{
			return ent;
		}
	}

	return -1;
}

//Other API Forward-------------------------------

/*--l4d2_safelockscavenge--*/
public void SLS_OnDoorStatusChanged(bool locked)
{
	if(locked == true)
	{
		g_bSLSDisable = true;
		if(IsValidEntRef(g_iEndCheckpointDoor))
		{
			SetEntProp(g_iEndCheckpointDoor, Prop_Data, "m_hasUnlockSequence", UNLOCK);
			AcceptEntityInput(g_iEndCheckpointDoor, "Unlock");
		}
	}
	else
	{
		if(IsValidEntRef(g_iEndCheckpointDoor))
		{
			SetEntProp(g_iEndCheckpointDoor, Prop_Data, "m_hasUnlockSequence", LOCK);
			AcceptEntityInput(g_iEndCheckpointDoor, "lock");
		}
		g_bSLSDisable = false;
	}
}