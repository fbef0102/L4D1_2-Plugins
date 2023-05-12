#define PLUGIN_VERSION "1.0h"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#define DEBUG 0
#define CVAR_FLAGS FCVAR_NOTIFY

/*
// bug in SM 1.11.0.6902 and some older
#if !defined FINALE_GAUNTLET_1
	enum
	{
		FINALE_GAUNTLET_1 = 0,
		FINALE_HORDE_ATTACK_1 = 1,
		FINALE_HALFTIME_BOSS = 2,
		FINALE_GAUNTLET_2 = 3,
		FINALE_HORDE_ATTACK_2 = 4,
		FINALE_FINAL_BOSS = 5,
		FINALE_HORDE_ESCAPE	= 6,
		FINALE_CUSTOM_PANIC	= 7,
		FINALE_CUSTOM_TANK	= 8,
		FINALE_CUSTOM_SCRIPTED	= 9,
		FINALE_CUSTOM_DELAY	= 10,
		FINALE_CUSTOM_CLEAROUT = 11,
		FINALE_GAUNTLET_START = 12,
		FINALE_GAUNTLET_HORDE = 13,
		FINALE_GAUNTLET_HORDE_BONUSTIME	= 14,
		FINALE_GAUNTLET_BOSS_INCOMING = 15,
		FINALE_GAUNTLET_BOSS = 16,
		FINALE_GAUNTLET_ESCAPE = 17
	}
#endif
*/

char g_sMap[64], g_sLog[PLATFORM_MAX_PATH];
int g_iTankCount, g_iLastTime;
bool g_bTriggerHooked, g_bLeft4Dead2, g_bLateload, g_bFinaleStarted;
Handle g_hTimerWave;
ConVar g_hCvarPanicTimeout;
#pragma unused g_iLastTime

public Plugin myinfo = 
{
	name = "[L4D2] Finale Stage fix (finale tank fix)",
	author = "Dragokas & dr lex, Harry",
	description = "Fixing the hanging of Finals",
	version = PLUGIN_VERSION,
	url = "https://github.com/dragokas"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if (test != Engine_Left4Dead2) {
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	g_bLeft4Dead2 = true;
	g_bLateload = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	BuildPath(Path_SM, g_sLog, sizeof(g_sLog), "logs/stage.log");
	
	CreateConVar("l4d_finale_stage_fix_version", PLUGIN_VERSION, "Plugin Version", FCVAR_DONTRECORD | CVAR_FLAGS);
	g_hCvarPanicTimeout = CreateConVar("l4d_finale_stage_fix_panicstage_timeout",		"60",		"Timeout (in sec.) for finale panic stage waiting for tank/painc horde to appear, otherwise stage forcibly changed", CVAR_FLAGS );
	AutoExecConfig(true, "l4d_finale_stage_fix");
	
	HookEvent("round_start",            Event_RoundStart);
	HookEvent("player_spawn",           Event_PlayerSpawn);
	HookEvent("round_end",       		Event_RoundEnd,  		EventHookMode_PostNoCopy);
	HookEvent("mission_lost", 			Event_RoundEnd,			EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,			EventHookMode_PostNoCopy); //final map final rescue vehicle leaving  (does not trigger round_end)
	HookEvent("tank_spawn",       		Event_TankSpawn,  		EventHookMode_PostNoCopy);
	HookEvent("round_freeze_end", 		Event_RoundFreezeEnd, 	EventHookMode_PostNoCopy);

	HookEvent("finale_escape_start", Finale_Escape_Start);
	HookEvent("finale_vehicle_ready", Finale_Escape_Start);
	
	RegAdminCmd("sm_stage", 		CMD_ShowStage, 	ADMFLAG_ROOT, 	"Prints current stage index and time passed.");
	RegAdminCmd("sm_nextstage", 	CMD_NextStage, 	ADMFLAG_ROOT, 	"Forcibly call the next stage.");
	
	if( g_bLateload ) {
		g_iTankCount = GetTankCount();
	}
}

public void OnMapStart()
{
	GetCurrentMap(g_sMap, sizeof(g_sMap));
	
	#if DEBUG
		StringToLog("\nCurrent map is: %s\n", g_sMap);
	#endif
}

public void OnMapEnd()
{
	g_iTankCount = 0;
	g_bTriggerHooked = false;
	g_bFinaleStarted = false;
	#if DEBUG
		StringToLog("[Trigger] FinaleStart -> FALSE (OnMapEnd)");
	#endif
	delete g_hTimerWave;
}

public void OnClientDisconnect(int client)
{
	if (client && IsTank(client)) {
		g_iTankCount--;
		#if DEBUG
			StringToLog("[Tanks] count is: %i", g_iTankCount);
		#endif
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(g_bFinaleStarted)
	{
		switch (classname[0])
		{
			case 'i':
			{
				if (StrEqual(classname, "infected"))
				{
					if(g_hTimerWave != null)
					{
						#if DEBUG
							StringToLog("[Timer Reset] C.I spawns");
						#endif

						delete g_hTimerWave;
						g_hTimerWave = CreateTimer(g_hCvarPanicTimeout.FloatValue, tmrCheckStageStuck);
					}
				}
			}
		}
	}

	switch (classname[0])
	{
		case 't':
		{
			if (strncmp(classname, "trigger_finale", 14) == 0) //late spawn
			{
				HookSingleEntityOutput(entity, "FinaleEscapeStarted", OnFinaleOutput, false);
				HookSingleEntityOutput(entity, "FinaleWon", OnFinaleOutput, false);
				HookSingleEntityOutput(entity, "FinaleLost", OnFinaleOutput, false);
				HookSingleEntityOutput(entity, "FirstUseStart", OnFinaleOutput, false);
				HookSingleEntityOutput(entity, "UseStart", OnFinaleOutput, false);
				HookSingleEntityOutput(entity, "FinalePause", OnFinaleOutput, false);
				HookSingleEntityOutput(entity, "EscapeVehicleLeaving", OnFinaleOutput, false);
				
				HookSingleEntityOutput(entity, "FinaleStart", OnFinaleStart, false);
				
				g_bTriggerHooked = true;
			}
		}
	}
}

Action CMD_NextStage(int client, int args)
{
	if (!g_bFinaleStarted) return Plugin_Handled;

	if( client == 0) return Plugin_Handled;

	int iOldStage, iNewStage;
	ForceNextStage(iOldStage, iNewStage);
	PrintToChatAll("\x05Force Next Final stage: \x04%i \x01=> \x04%i \x01by \x03%N", iOldStage, iNewStage, client);

	return Plugin_Handled;
}

Action CMD_ShowStage(int client, int args)
{
	if (!g_bFinaleStarted) return Plugin_Handled;

	if( client == 0) return Plugin_Handled;

	int iStage = L4D2_GetCurrentFinaleStage();
	int delta = GetTime() - g_iLastTime;
	if( g_iLastTime == 0 ) delta = 0;
	
	PrintToChat(client, "Stage is: %i (%i sec.)", iStage, delta);
	PrintToChat(client, "Tank count is: %i", g_iTankCount); // L4D2_GetTankCount());

	return Plugin_Handled;
}

void Event_RoundStart(Event hEvent, const char[] name, bool dontBroadcast) 
{
	g_iTankCount = 0;
	g_bTriggerHooked = false;
	g_bFinaleStarted = false;
	#if DEBUG
		StringToLog("[Trigger] FinaleStart -> FALSE (%s)", name);
	#endif
}

void Event_RoundEnd(Event hEvent, const char[] name, bool dontBroadcast) 
{
	g_iTankCount = 0;
	g_bTriggerHooked = false;
	g_bFinaleStarted = false;
	#if DEBUG
		StringToLog("[Trigger] FinaleStart -> FALSE (%s)", name);
	#endif
	delete g_hTimerWave;
}

void Event_RoundFreezeEnd(Event hEvent, const char[] name, bool dontBroadcast)
{
	if( g_bTriggerHooked )
		return;
	
	int iEnt = FindEntityByClassname(-1, "trigger_finale");
	
	if( iEnt != -1 )
	{
		HookSingleEntityOutput(iEnt, "FinaleEscapeStarted", OnFinaleEscapeStarted, false);
		HookSingleEntityOutput(iEnt, "FinaleWon", OnFinaleOutput, false);
		HookSingleEntityOutput(iEnt, "FinaleLost", OnFinaleOutput, false);
		HookSingleEntityOutput(iEnt, "FirstUseStart", OnFinaleOutput, false);
		HookSingleEntityOutput(iEnt, "UseStart", OnFinaleOutput, false);
		HookSingleEntityOutput(iEnt, "FinalePause", OnFinaleOutput, false);
		HookSingleEntityOutput(iEnt, "EscapeVehicleLeaving", OnFinaleOutput, false);
		
		HookSingleEntityOutput(iEnt, "FinaleStart", OnFinaleStart, false);
		
		g_bTriggerHooked = true;
	}
}

void Finale_Escape_Start(Event event, const char[] name, bool dontBroadcast) 
{
	g_bFinaleStarted = false;
	if(g_hTimerWave != null)
	{
		#if DEBUG
			StringToLog("[Timer Stop] OnFinaleEscapeStarted");
		#endif

		delete g_hTimerWave;
	}
}

void OnFinaleEscapeStarted(const char[] output, int caller, int activator, float delay)
{
	#if DEBUG
		StringToLog("[Output] %s. Caller: %i, activator: %i, delay: %f", output, caller, activator, delay);
	#endif

	g_bFinaleStarted = false;
	if(g_hTimerWave != null)
	{
		#if DEBUG
			StringToLog("[Timer Stop] OnFinaleEscapeStarted");
		#endif

		delete g_hTimerWave;
	}
}

void OnFinaleOutput(const char[] output, int caller, int activator, float delay)
{
	#if DEBUG
		StringToLog("[Output] %s. Caller: %i, activator: %i, delay: %f", output, caller, activator, delay);
	#endif

	if(strcmp(output, "FinalePause", false) == 0 || strcmp(output, "FinaleStart", false) == 0) //Fired during the pause between each finale wave.
	{
		#if DEBUG
			StringToLog("[Timer Start] %s", output);
		#endif

		delete g_hTimerWave;
		g_hTimerWave = CreateTimer(g_hCvarPanicTimeout.FloatValue, tmrCheckStageStuck);
	}
}

void OnFinaleStart(const char[] output, int caller, int activator, float delay)
{
	#if DEBUG
		StringToLog("[Output] %s. Caller: %i, activator: %i, delay: %f", output, caller, activator, delay);
	#endif
	
	g_bFinaleStarted = true;

	#if DEBUG
		StringToLog("[Timer Start] OnFinaleStart");
	#endif

	delete g_hTimerWave;
	g_hTimerWave = CreateTimer(g_hCvarPanicTimeout.FloatValue, tmrCheckStageStuck);
}

void Event_PlayerSpawn(Event hEvent, const char[] name, bool dontBroadcast) 
{
	if(!g_bFinaleStarted) return;

	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if (!client || !IsClientInGame(client) || !IsFakeClient(client) || GetClientTeam(client) != 3) return;

	int class = GetEntProp(client, Prop_Send, "m_zombieClass");
	if( class == (g_bLeft4Dead2 ? 8 : 5 )) return;

	if(g_hTimerWave != null)
	{
		#if DEBUG
			StringToLog("[Timer Reset] S.I. bots spawn");
		#endif

		delete g_hTimerWave;
		g_hTimerWave = CreateTimer(g_hCvarPanicTimeout.FloatValue, tmrCheckStageStuck);
	}
}

void Event_TankSpawn(Event hEvent, const char[] name, bool dontBroadcast) 
{
	if(!g_bFinaleStarted) return;

	g_iTankCount++;
	#if DEBUG
		StringToLog("[Tanks] count is: %i", g_iTankCount);
	#endif

	if(g_hTimerWave != null)
	{
		#if DEBUG
			StringToLog("[Timer Stop] Tank spawns");
		#endif

		delete g_hTimerWave;
	}
}

Action tmrCheckStageStuck(Handle timer)
{
	if(!g_bFinaleStarted)
	{
		#if DEBUG
			StringToLog("[Timer Stop] g_bFinaleStarted is false");
		#endif

		g_hTimerWave = null;
		return Plugin_Continue;
	}

	#if DEBUG
		StringToLog("[Timeout] when waiting for tanks/painc horde, ForceNextStage");
	#endif

	PrintToChatAll("\x05[TS]\x01 Force to change next final stage.");
	PrintToChatAll("\x04Final stage is broken\x01.... Please don't play this map next time!");
	
	g_hTimerWave = null;
	ForceNextStage();
	return Plugin_Continue;
}

//Left4Dhooks API Forward-------------------------------

public void L4D2_OnChangeFinaleStage_Post(int finaleType, const char[] arg) // public forward
{
	#if DEBUG
	int delta;
	if( g_iLastTime != 0 )
	{
		delta = GetTime() - g_iLastTime;
	}
	g_iLastTime = GetTime();
	StringToLog("[Stage] changed to => %i (%i sec.)", finaleType, delta);
	#endif
	
	if( g_bFinaleStarted )
	{
		if( finaleType == FINALE_CUSTOM_PANIC )
		{
			#if DEBUG
				StringToLog("[Timer Start] FINALE_CUSTOM_PANIC");
			#endif
			
			delete g_hTimerWave;
			g_hTimerWave = CreateTimer(g_hCvarPanicTimeout.FloatValue, tmrCheckStageStuck);
		}
		else if( finaleType == FINALE_CUSTOM_TANK )
		{
			#if DEBUG
				StringToLog("[Timer Start] FINALE_CUSTOM_TANK");
			#endif
			
			delete g_hTimerWave;
			g_hTimerWave = CreateTimer(g_hCvarPanicTimeout.FloatValue, tmrCheckStageStuck);
		}
	}
}

stock void ForceNextStage(int iOldStage = 0, int iNewStage = 0)
{
	iOldStage = L4D2_GetCurrentFinaleStage();
	L4D2_ForceNextStage();
	iNewStage = L4D2_GetCurrentFinaleStage();
	
	#if DEBUG
		StringToLog("[Forced] Next stage: %i => %i", iOldStage, iNewStage);
	#endif
}

int GetTankCount()
{
	int cnt;
	for (int i = 1; i <= MaxClients; i++)
		if (IsTank(i))
			cnt++;
	
	return cnt;
}

bool IsTank(int client)
{
	if( client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3 )
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if( class == (g_bLeft4Dead2 ? 8 : 5 ))
			return true;
	}
	return false;
}

stock void StringToLog(const char[] format, any ...)
{
	static char buffer[256];
	VFormat(buffer, sizeof(buffer), format, 2);
	LogToFileEx(g_sLog, buffer);
}