#define PLUGIN_VERSION "1.3h-2025/3/6"

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>

#define DEBUG 0

public Plugin myinfo = 
{
	name = "[L4D1/2] Finale Stage fix (finale tank fix)",
	author = "Dragokas & dr lex, Harry",
	description = "Fixing the hanging of Finals",
	version = PLUGIN_VERSION,
	url = "https://github.com/dragokas"
}

int ZC_TANK;
bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead )
	{
		g_bL4D2Version = false;
		ZC_TANK = 5;
	}
	else if( test == Engine_Left4Dead2 )
	{
		g_bL4D2Version = true;
		ZC_TANK = 8;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define CVAR_FLAGS FCVAR_NOTIFY

ConVar g_hCvarPanicTimeout, 
	g_hCvarCISpawn, g_hCvarCIDeath,
	g_hCvarSISpawn, g_hCvarSIDeath;
int g_iCvarPanicTimeout;

char g_sMap[64], g_sLog[PLATFORM_MAX_PATH];
int g_iLastTime;
bool g_bTriggerHooked, g_bFinaleStarted, g_bFinaleEscape, g_bFinaleVehicleReady,
	g_bCvarCISpawn, g_bCvarCIDeath,
	g_bCvarSISpawn, g_bCvarSIDeath;
Handle g_hTimerWave;
int g_iPanicTimeout;

public void OnPluginStart()
{
	BuildPath(Path_SM, g_sLog, sizeof(g_sLog), "logs/stage.log");
	
	CreateConVar("l4d_finale_stage_fix_version", PLUGIN_VERSION, "Plugin Version", FCVAR_DONTRECORD | CVAR_FLAGS);
	g_hCvarPanicTimeout = CreateConVar("l4d_finale_stage_fix_panicstage_timeout",		"60",		"Timeout (in sec.) for finale panic stage waiting for tank/painc horde to appear, otherwise stage forcibly changed", CVAR_FLAGS );
	g_hCvarCISpawn  = CreateConVar("l4d_finale_stage_fix_reset_ci_spawn",				"1",		"If 1, reset timer when common infected spawns", CVAR_FLAGS, true, 0.0, true, 1.0 );
	g_hCvarCIDeath  = CreateConVar("l4d_finale_stage_fix_reset_ci_death",				"1",		"If 1, reset timer when common infected death", CVAR_FLAGS, true, 0.0, true, 1.0 );
	g_hCvarSISpawn  = CreateConVar("l4d_finale_stage_fix_reset_si_spawn",				"1",		"If 1, reset timer when special infected bot or tank bot spawns", CVAR_FLAGS, true, 0.0, true, 1.0 );
	g_hCvarSIDeath  = CreateConVar("l4d_finale_stage_fix_reset_si_death",				"1",		"If 1, reset timer when special infected bot or tank bot death", CVAR_FLAGS, true, 0.0, true, 1.0 );
	AutoExecConfig(true, "l4d_finale_stage_fix");
	
	GetCvars();
	g_hCvarPanicTimeout.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarCISpawn.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarCIDeath.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarSISpawn.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarSIDeath.AddChangeHook(ConVarChanged_Cvars);
	
	HookEvent("round_start",            Event_RoundStart);
	HookEvent("player_spawn",           Event_PlayerSpawn);
	HookEvent("player_death",           Event_PlayerDeath);
	HookEvent("round_end",       		Event_RoundEnd,  		EventHookMode_PostNoCopy);
	HookEvent("mission_lost", 			Event_RoundEnd,			EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,			EventHookMode_PostNoCopy); //final map final rescue vehicle leaving  (does not trigger round_end)

	HookEvent("finale_start", 			OnFinaleStart_Event, EventHookMode_PostNoCopy); //final starts, some of final maps won't trigger
	HookEvent("finale_radio_start", 	OnFinaleStart_Event, EventHookMode_PostNoCopy); //final starts, all final maps trigger

	HookEvent("finale_escape_start", Finale_Escape_Start);
	HookEvent("finale_vehicle_ready", Finale_Vehicle_Ready);
	
	if(g_bL4D2Version)
	{
		RegAdminCmd("sm_stage", 		CMD_ShowStage, 	ADMFLAG_ROOT, 	"(L4D2) Prints current stage index and time passed.");
		RegAdminCmd("sm_nextstage", 	CMD_NextStage, 	ADMFLAG_ROOT, 	"(L4D2) Forcibly call the next stage.");
	}
	RegAdminCmd("sm_callrescue", 	CMD_CallRescue, ADMFLAG_ROOT, 	"Call rescue vehicle immediately.");
}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_iCvarPanicTimeout = g_hCvarPanicTimeout.IntValue;
	g_bCvarCISpawn = g_hCvarCISpawn.BoolValue;
	g_bCvarCIDeath = g_hCvarCIDeath.BoolValue;
	g_bCvarSISpawn = g_hCvarSISpawn.BoolValue;
	g_bCvarSIDeath = g_hCvarSIDeath.BoolValue;
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
	g_bTriggerHooked = false;
	g_bFinaleStarted = false;
	g_bFinaleEscape = false;
	g_bFinaleVehicleReady = false;

	#if DEBUG
		StringToLog("[Trigger] FinaleStart -> FALSE (OnMapEnd)");
	#endif
	delete g_hTimerWave;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(g_bFinaleStarted && !g_bFinaleEscape)
	{
		switch (classname[0])
		{
			case 'i':
			{
				if (g_bCvarCISpawn && StrEqual(classname, "infected"))
				{
					if(g_hTimerWave != null)
					{
						#if DEBUG
							StringToLog("[Timer Reset] C.I spawns");
						#endif

						g_iPanicTimeout = g_iCvarPanicTimeout;

						delete g_hTimerWave;
						g_hTimerWave = CreateTimer(1.0, tmrCheckStageStuck, _, TIMER_REPEAT);
					}
				}
			}
		}
	}

	if(g_bTriggerHooked) return;

	switch (classname[0])
	{
		case 't':
		{
			if (strncmp(classname, "trigger_finale", 14) == 0) //late spawn
			{
				HookSingleEntityOutput(entity, "FinaleStart", OnFinaleStart, false);
				HookSingleEntityOutput(entity, "FinalePause", OnFinalePause, false);
				HookSingleEntityOutput(entity, "FinaleEscapeStarted", OnFinaleEscapeStarted, false);
				
				
				g_bTriggerHooked = true;
			}
		}
	}
}

Action CMD_NextStage(int client, int args)
{
	if (!g_bFinaleStarted) return Plugin_Handled;
	if (g_bFinaleEscape) return Plugin_Handled;

	if( client == 0) return Plugin_Handled;

	int iOldStage, iNewStage;
	iOldStage = L4D2_GetCurrentFinaleStage();
	L4D2_ForceNextStage();
	iNewStage = L4D2_GetCurrentFinaleStage();

	PrintToChatAll("\x05Force Next Final stage: \x04%i \x01=> \x04%i \x01by \x03%N", iOldStage, iNewStage, client);

	return Plugin_Handled;
}

Action CMD_CallRescue(int client, int args)
{
	if (!g_bFinaleStarted || g_bFinaleVehicleReady)
	{
		ReplyToCommand(client, "Not on final stage");
		return Plugin_Handled;
	}

	L4D2_SendInRescueVehicle();

	if(client == 0)
	{
		ReplyToCommand(client, "Call Rescue Vechicle immediately");
		PrintToChatAll("\x05Call Rescue Vechicle immediately by Server");
	}
	else
	{
		PrintToChatAll("\x05Call Rescue Vechicle immediately by \x03%N", client);
	}

	return Plugin_Handled;
}

Action CMD_ShowStage(int client, int args)
{
	if (!g_bFinaleStarted) return Plugin_Handled;

	int iStage = L4D2_GetCurrentFinaleStage();
	int delta = GetTime() - g_iLastTime;
	if( g_iLastTime == 0 ) delta = 0;
	
	ReplyToCommand(client, "Stage is: %i (%i sec.)", iStage, delta);
	ReplyToCommand(client, "Tank count is: %i", GetTankCount());

	return Plugin_Handled;
}

void Event_RoundStart(Event hEvent, const char[] name, bool dontBroadcast) 
{
	g_bTriggerHooked = false;
	g_bFinaleStarted = false;
	g_bFinaleEscape = false;
	g_bFinaleVehicleReady = false;
	#if DEBUG
		StringToLog("[Trigger] FinaleStart -> FALSE (%s)", name);
	#endif
}

void Event_RoundEnd(Event hEvent, const char[] name, bool dontBroadcast) 
{
	#if DEBUG
		StringToLog("[Trigger] FinaleStart -> FALSE (%s)", name);
	#endif
	delete g_hTimerWave;
}

void OnFinaleStart_Event(Event event, const char[] name, bool dontBroadcast) 
{
	g_bFinaleStarted = true;

	g_iPanicTimeout = g_iCvarPanicTimeout;

	delete g_hTimerWave;
	g_hTimerWave = CreateTimer(1.0, tmrCheckStageStuck, _, TIMER_REPEAT);
}

void Finale_Escape_Start(Event event, const char[] name, bool dontBroadcast) 
{
	g_bFinaleEscape = true;
	if(g_hTimerWave != null)
	{
		#if DEBUG
			StringToLog("[Timer Stop] Finale_Escape_Start");
		#endif

		delete g_hTimerWave;
	}
}

void Finale_Vehicle_Ready(Event event, const char[] name, bool dontBroadcast) 
{
	g_bFinaleEscape = true;
	g_bFinaleVehicleReady = true;
	if(g_hTimerWave != null)
	{
		#if DEBUG
			StringToLog("[Timer Stop] Finale_Vehicle_Ready");
		#endif

		delete g_hTimerWave;
	}
}

void OnFinaleEscapeStarted(const char[] output, int caller, int activator, float delay)
{
	#if DEBUG
		StringToLog("[Output] %s. Caller: %i, activator: %i, delay: %f", output, caller, activator, delay);
	#endif

	g_bFinaleEscape = true;
	if(g_hTimerWave != null)
	{
		#if DEBUG
			StringToLog("[Timer Stop] OnFinaleEscapeStarted");
		#endif

		delete g_hTimerWave;
	}
}

void OnFinalePause(const char[] output, int caller, int activator, float delay)
{
	#if DEBUG
		StringToLog("[Output] %s. Caller: %i, activator: %i, delay: %f", output, caller, activator, delay);
	#endif

	#if DEBUG
		StringToLog("[Timer Reset] %s", output);
	#endif

	g_iPanicTimeout = g_iCvarPanicTimeout;

	delete g_hTimerWave;
	g_hTimerWave = CreateTimer(1.0, tmrCheckStageStuck, _, TIMER_REPEAT);
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

	g_iPanicTimeout = g_iCvarPanicTimeout;

	delete g_hTimerWave;
	g_hTimerWave = CreateTimer(1.0, tmrCheckStageStuck, _, TIMER_REPEAT);
}

void Event_PlayerSpawn(Event hEvent, const char[] name, bool dontBroadcast) 
{
	if(!g_bFinaleStarted || g_bFinaleEscape || !g_bCvarSISpawn) return;

	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if (!client || !IsClientInGame(client) || !IsFakeClient(client) || GetClientTeam(client) != 3) return;

	if(g_hTimerWave != null)
	{
		#if DEBUG
			StringToLog("[Timer Reset] S.I. bots spawn");
		#endif

		g_iPanicTimeout = g_iCvarPanicTimeout;

		delete g_hTimerWave;
		g_hTimerWave = CreateTimer(1.0, tmrCheckStageStuck, _, TIMER_REPEAT);
	}
}

//witch跟小殭屍被殺死也會觸發
void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_bFinaleStarted || g_bFinaleEscape) return;

	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (victim && IsClientInGame(victim) && IsFakeClient(victim) && GetClientTeam(victim) == 3)
	{
		if(!g_bCvarSIDeath) return;

		if(g_hTimerWave != null)
		{
			#if DEBUG
				StringToLog("[Timer Reset] S.I. bots death");
			#endif

			g_iPanicTimeout = g_iCvarPanicTimeout;

			delete g_hTimerWave;
			g_hTimerWave = CreateTimer(1.0, tmrCheckStageStuck, _, TIMER_REPEAT);
		}
	}
	else 
	{
		if(!g_bCvarCIDeath) return;

		int entityid = event.GetInt("entityid");
		if(IsCommonInfected(entityid))
		{
			#if DEBUG
				StringToLog("[Timer Reset] common death");
			#endif

			g_iPanicTimeout = g_iCvarPanicTimeout;

			delete g_hTimerWave;
			g_hTimerWave = CreateTimer(1.0, tmrCheckStageStuck, _, TIMER_REPEAT);
		}
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
		return Plugin_Stop;
	}

	if(g_bFinaleEscape)
	{
		#if DEBUG
			StringToLog("[Timer Stop] g_bFinaleEscape is true");
		#endif

		g_hTimerWave = null;
		return Plugin_Stop;
	}

	if(GetTankCount() > 0)
	{
		#if DEBUG
			StringToLog("[Timer Stop] Tank in game");
		#endif

		return Plugin_Continue;
	}

	g_iPanicTimeout--;

	if(g_iPanicTimeout <= 0)
	{
		g_hTimerWave = null;

		#if DEBUG
			StringToLog("[Timeout] when waiting for tanks/painc horde, ForceNextStage");
		#endif

		char sMap[64];
		GetCurrentMap(sMap, sizeof(sMap));
		StringToLog("[Timeout] Waiting for tanks/painc horde time out, Call Rescue Vehicle");
		StringToLog("[Timeout] Final stage is broken.... Please don't play %s map next time", sMap);

		PrintToChatAll("\x05[TS]\x01 Force to call Rescue Vehicle.");
		PrintToChatAll("\x04Final stage is broken\x01.... Please don't play this map next time!");
		
		ForceNextStage();

		g_iPanicTimeout = g_iCvarPanicTimeout;

		delete g_hTimerWave;
		g_hTimerWave = CreateTimer(1.0, tmrCheckStageStuck, _, TIMER_REPEAT);

		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

bool IsCommonInfected(int entity)
{
	if (entity > MaxClients && IsValidEntity(entity))
	{
		static char entType[64];
		GetEntityClassname(entity, entType, sizeof(entType));
		return strcmp(entType, "infected", false) == 0;
	}

	return false;
}

void ForceNextStage()
{
	if(g_bL4D2Version)
	{
		#if DEBUG
			int iOldStage = L4D2_GetCurrentFinaleStage();
			L4D2_ForceNextStage();
			int iNewStage = L4D2_GetCurrentFinaleStage();
			StringToLog("[Forced] Next stage: %i => %i", iOldStage, iNewStage);
		#else
			L4D2_ForceNextStage();
		#endif	
	}
	else
	{
		L4D2_SendInRescueVehicle();
		
		#if DEBUG
			StringToLog("[Forced] Call Rescue Vehicle");
		#endif
	}
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
	if( client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3 && IsPlayerAlive(client) )
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		if( class == ZC_TANK)
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
	#else
		g_iLastTime = GetTime();
	#endif
	
	if( g_bFinaleStarted && !g_bFinaleEscape)
	{
		if( finaleType == FINALE_CUSTOM_PANIC )
		{
			#if DEBUG
				StringToLog("[Timer Start] FINALE_CUSTOM_PANIC");
			#endif
			
			g_iPanicTimeout = g_iCvarPanicTimeout;

			delete g_hTimerWave;
			g_hTimerWave = CreateTimer(1.0, tmrCheckStageStuck, _, TIMER_REPEAT);
		}
		else if( finaleType == FINALE_CUSTOM_TANK )
		{
			#if DEBUG
				StringToLog("[Timer Start] FINALE_CUSTOM_TANK");
			#endif
			
			g_iPanicTimeout = g_iCvarPanicTimeout;

			delete g_hTimerWave;
			g_hTimerWave = CreateTimer(1.0, tmrCheckStageStuck, _, TIMER_REPEAT);
		}
	}
}