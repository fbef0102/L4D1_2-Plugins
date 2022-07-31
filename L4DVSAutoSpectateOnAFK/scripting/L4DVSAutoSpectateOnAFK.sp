/********************************************************************************************
* Plugin	: L4DVSAutoSpectateOnAFK
* Version	: 2.1
* Game		: Left 4 Dead 1/2
* Author	: djromero (SkyDavid, David) & Harry
* Testers	: Myself
* Website	: www.sky.zebgames.com
* A
* Purpose	: This plugins forces AFK players to spectate, and later it kicks them. Admins 
* 			  are inmune to kick.
*********************************************************************************************/
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>
#include <left4dhooks>
#define PLUGIN_VERSION "2.1"


// For cvars
ConVar h_AfkWarnSpecTime;
ConVar h_AfkSpecTime;
ConVar h_AfkWarnKickTime;
ConVar h_AfkKickTime;
ConVar h_AfkCheckInterval;
ConVar h_AfkKickEnabled;
ConVar h_AfkSpecOnConnect;
ConVar h_AfkSaferoomIgnore;
ConVar g_hImmuneAccess;
int afkWarnSpecTime;
int afkSpecTime;
int afkWarnKickTime;
int afkKickTime;
int afkCheckInterval;
bool afkKickEnabled;
bool afkSpecOnConnect;
bool bAfkSaferoomIgnore;


// work variables
bool afkManager_Active = false;
int afkPlayerTimeLeftWarn[MAXPLAYERS + 1];
int afkPlayerTimeLeftAction[MAXPLAYERS + 1];
float afkPlayerLastPos[MAXPLAYERS + 1][3];
float afkPlayerLastEyes[MAXPLAYERS + 1][3];
bool g_bLeftSafeRoom;
bool L4D2Version;
bool PlayerJustConnected[MAXPLAYERS + 1];
char g_sAccesslvl[16];
int g_iPlayerSpawn, g_iRoundStart;
Handle PlayerLeftStartTimer = null;

public Plugin myinfo = 
{
	name = "[L4D1/2] VS Auto-spectate on AFK",
	author = "djromero (SkyDavid, David Romero) & Harry",
	description = "Auto-spectate for AFK players on VS mode",
	version = PLUGIN_VERSION,
	url = "www.sky.zebgames.com"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	// Checks to see if the game is a L4D game. If it is, check if its the sequel. L4DVersion is L4D if false, L4D2 if true.
	EngineVersion test = GetEngineVersion();
	if( test == Engine_Left4Dead)
		L4D2Version = false;
	else if (test == Engine_Left4Dead2 )
		L4D2Version = true;
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("L4DVSAutoSpectateOnAFK.phrases");
	// We register the spectate command
	//RegConsoleCmd("spectate", cmd_spectate);
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say);
	
	
	// Changed teams
	HookEvent("player_team", afkChangedTeam);
	
	// Player actions
	HookEvent("entity_shoved", afkPlayerAction);
	HookEvent("player_shoved", afkPlayerAction);
	HookEvent("player_shoot", afkPlayerAction);
	HookEvent("player_jump", afkPlayerAction);
	HookEvent("player_hurt", afkPlayerAction);
	HookEvent("player_hurt_concise", afkPlayerAction);
	
	// For roundstart and roundend..
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Pre);
	HookEvent("finale_vehicle_leaving", Event_RoundEnd, EventHookMode_Pre);
	HookEvent("mission_lost", Event_RoundEnd);
	HookEvent("map_transition", Event_RoundEnd, EventHookMode_Pre);
	HookEvent("player_spawn",		Event_PlayerSpawn,	EventHookMode_PostNoCopy);

	// Afk manager time limits
	h_AfkWarnSpecTime = CreateConVar("l4d_specafk_warnspectime", "20", "Warn time before spec", FCVAR_NOTIFY, true, 0.0);
	h_AfkSpecTime = CreateConVar("l4d_specafk_spectime", "15", "time before spec (after warn)", FCVAR_NOTIFY, true, 0.0);
	h_AfkWarnKickTime = CreateConVar("l4d_specafk_warnkicktime", "60", "Warn time before kick (while already on spec)", FCVAR_NOTIFY, true, 0.0);
	h_AfkKickTime = CreateConVar("l4d_specafk_kicktime", "30", "time before kick (while already on spec after warn)", FCVAR_NOTIFY, true, 0.0);
	h_AfkCheckInterval = CreateConVar("l4d_specafk_checkinteral", "1", "Check/warn time interval", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_AfkKickEnabled = CreateConVar("l4d_specafk_kickenabled", "1", "If 1, kick enabled on afk while on spec", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_AfkSpecOnConnect = CreateConVar("l4d_specafk_speconconnect", "0", "If 1, player will be forced to spectate on connect", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	h_AfkSaferoomIgnore = CreateConVar("l4d_specafk_saferoom_ignore", "0", "If 1, player will still be forced to spectate and kicked whether surviros leave saferoom or not.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hImmuneAccess = CreateConVar("l4d_specafk_immune_access_flag", "z", "Players with these flags have immune to be kicked while spec. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);

	// We read the cvars
	ReadCvars();
	// Hook cvars changes ...
	h_AfkWarnSpecTime.AddChangeHook(ConVarChanged);
	h_AfkSpecTime.AddChangeHook(ConVarChanged);
	h_AfkWarnKickTime.AddChangeHook(ConVarChanged);
	h_AfkKickTime.AddChangeHook(ConVarChanged);
	h_AfkCheckInterval.AddChangeHook(ConVarChanged);
	h_AfkKickEnabled.AddChangeHook(ConVarChanged);
	h_AfkSpecOnConnect.AddChangeHook(ConVarChanged);
	h_AfkSaferoomIgnore.AddChangeHook(ConVarChanged);
	g_hImmuneAccess.AddChangeHook(ConVarChanged);
	
	// We register the version cvar
	CreateConVar("l4d_specafk_version", PLUGIN_VERSION, "Version of L4D VS Auto spectate on AFK", FCVAR_DONTRECORD|FCVAR_NOTIFY);
	
	// We tweak some settings ..
	SetConVarInt(FindConVar("vs_max_team_switches"), 9999); // so that players can switch multiple times
	
	CreateTimer(3.0, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);

	AutoExecConfig(true, "L4DVSAutoSpectateOnAFK");
}

public void OnPluginEnd()
{
	ResetPlugin();
	ResetTimer();
}

public void ReadCvars()
{
	// first we read all the variables ...
	afkWarnSpecTime = h_AfkWarnSpecTime.IntValue;
	afkSpecTime = h_AfkSpecTime.IntValue;
	afkWarnKickTime = h_AfkWarnKickTime.IntValue;
	afkKickTime = h_AfkKickTime.IntValue;
	afkCheckInterval = h_AfkCheckInterval.IntValue;
	afkKickEnabled = h_AfkKickEnabled.BoolValue;
	afkSpecOnConnect = h_AfkSpecOnConnect.BoolValue;
	bAfkSaferoomIgnore = h_AfkSaferoomIgnore.BoolValue;

	g_hImmuneAccess.GetString(g_sAccesslvl,sizeof(g_sAccesslvl));
}

public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	ReadCvars();
}

public void OnMapStart()
{
	int i;
	for (i=1;i<=MAXPLAYERS;i++)
		PlayerJustConnected[i] = false;
}

public void OnMapEnd()
{
	afkManager_Stop();
	ResetPlugin();
	ResetTimer();
}

public void OnClientPutInServer(int client)
{
	PlayerJustConnected[client] = false;
	afkResetTimers(client);
}

public bool OnClientConnect(int client)
{
	// If players already leaved safe room we mark the player as just connected ...
	PlayerJustConnected[client] = true;

	afkPlayerTimeLeftWarn[client] = 1000;
	afkPlayerTimeLeftAction[client] = 1000;	
	return true;
}

public bool IsValidClient (int client)
{
	if (client > 0 && client <= MaxClients)
		return true;
	else
	return false;
}

public bool IsValidPlayer (int client)
{
	if (client == 0)
		return false;

	if (IsFakeClient(client))
		return false;
	
	if (!IsClientInGame(client))
		return false;
	
	return true;
}

public bool HasAccess(int client, char[] g_sAcclvl)
{
	// no permissions set
	if (strlen(g_sAcclvl) == 0)
		return true;

	else if (StrEqual(g_sAcclvl, "-1"))
		return false;

	// check permissions
	if ( GetUserFlagBits(client) & ReadFlagString(g_sAcclvl) )
	{
		return true;
	}

	return false;
}

public Action Command_Say(int client, int args)
{
	if(client && IsClientInGame(client))
		afkResetTimers(client);

	return Plugin_Handled;
}

public Action Event_RoundStart (Event event, const char[] name, bool dontBroadcast)
{
	g_bLeftSafeRoom = false;
	afkManager_Stop();
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(3.0, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
	
	return Plugin_Continue;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(3.0, tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

public Action tmrStart(Handle timer)
{
	ResetPlugin();

	delete PlayerLeftStartTimer;
	CreateTimer(1.0, PlayerLeftStart, _, TIMER_REPEAT);

	// We start the AFK manager
	if(!afkManager_Active)
	{
		afkManager_Start();
	}

	return Plugin_Continue;
}


public void Event_RoundEnd (Event event, const char[] name, bool dontBroadcast)
{
	//PrintToServer("******* ROUND END *********");
	
	afkManager_Stop();
	ResetPlugin();
	ResetTimer();
}


public void afkPlayerAction (Event event, const char[] name, bool dontBroadcast)
{
	char propname[200];
	
	// gets the property name
	if (strcmp(name, "entity_shoved", false)==0)
		propname = "attacker";
	else if (strcmp(name, "player_shoved", false)==0)
		propname = "attacker";
	else if (strcmp(name, "player_hurt", false)==0)
		propname = "attacker";
	else if (strcmp(name, "player_hurt_concise", false)==0)
		propname = "attacker";
	else 
	propname = "userid";
	
	// gets the id
	int id = GetClientOfUserId(event.GetInt(propname));
	
	// resets his timers
	if (id > 0)
		afkResetTimers(id);
}

public Action afkChangedTeam (Event event, const char[] name, bool dontBroadcast)
{
	// we get the victim
	CreateTimer(0.5, ClientReallyChangeTeam, event.GetInt("userid"), TIMER_FLAG_NO_MAPCHANGE); // check delay
	return Plugin_Continue;
}

public Action ClientReallyChangeTeam(Handle timer, int victim)
{
	victim = GetClientOfUserId(victim);

	if( victim <= 0 || victim > MaxClients || !IsClientInGame(victim) || IsFakeClient(victim)) return Plugin_Continue;

	// If players left the safe room and this player just connected and we have set spec on connect ...
	if (g_bLeftSafeRoom && PlayerJustConnected[victim] && afkSpecOnConnect)
	{
		// If player is on survivors and is dead ... we don't force him to spec
		if ((GetClientTeam(victim) == 2) && (!IsPlayerAlive(victim)))
			return Plugin_Continue;
		
		// force him to spectate
		CreateTimer(0.1, afkForceSpectateJoin, victim);
	}
	
	// Mark as already connected
	PlayerJustConnected[victim] = false;
	
	// Reset his afk status
	afkResetTimers(victim);
	
	return Plugin_Continue;
}

public Action afkJoinHint (Handle Timer, int client)
{
	client = GetClientOfUserId(client);
	// If player is valid
	if (client && IsClientInGame(client) && afkPlayerTimeLeftWarn[client] > 0)
	{
		// If player is still on spectators ...
		if (GetClientTeam(client) == 1)
		{
			// We send him a hint text ...
			PrintHintText(client, "%T", "You're spectating. Join any team to play.", client);
			
			return Plugin_Continue;
		}
	}
	
	return Plugin_Stop;
}

void afkResetTimers (int client)
{
	// if client is not valid
	if (!IsValidClient(client))
		return;
	
	// if client is valid ...
	if (!IsClientInGame(client)||IsFakeClient(client))
		return;
	
	
	// If client is not on spec team
	if (GetClientTeam(client)!=1)
	{
		afkPlayerTimeLeftWarn[client] = afkWarnSpecTime;
		afkPlayerTimeLeftAction[client] = afkSpecTime;
	}
	else // if player is on spectators
	{
		afkPlayerTimeLeftWarn[client] = afkWarnKickTime;
		afkPlayerTimeLeftAction[client] = afkKickTime;
	}
	
	// if player just joined, we double his warn time
	if (PlayerJustConnected[client])
	{
		afkPlayerTimeLeftWarn[client] = afkPlayerTimeLeftWarn[client] * 2;
	}
	
	// if player is already connected ....
	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		GetClientAbsOrigin(client, afkPlayerLastPos[client]);
		GetClientEyeAngles(client, afkPlayerLastEyes[client]);
	}
}

void afkManager_Start()
{
	// mark as active
	afkManager_Active = true; 
	
	// now we reset all the timers ...
	int i;
	for (i=1;i<=MAXPLAYERS;i++)
	{
		afkResetTimers(i);
	}
	
	// we start the check thread ....
	CreateTimer(float(afkCheckInterval), afkCheckThread, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action afkCheckThread(Handle timer)
{
	// if afkmanager is not active ...
	if (!afkManager_Active)
		return Plugin_Stop;
		
	int i;
	float pos[3];
	float eyes[3];
	
	// we check all connected (and alive) clients ...
	for (i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			// If player is not on spectators team ...
			if (GetClientTeam(i) != 1)
			{
				// If client is alive 
				if (IsPlayerAlive(i))
				{
					// we get his current coordinates and eyes
					GetClientAbsOrigin(i, pos);
					GetClientEyeAngles(i, eyes);
					
					// if he hasn't moved ..
					if ((pos[0] == afkPlayerLastPos[i][0])&&(pos[1] == afkPlayerLastPos[i][1])&&(pos[2] == afkPlayerLastPos[i][2])&&(eyes[0] == afkPlayerLastEyes[i][0])&&(eyes[1] == afkPlayerLastEyes[i][1])&&(eyes[2] == afkPlayerLastEyes[i][2]))
					{
						// if the player is not trapped (incapacitated, pounced, etc)
						if (GetInfectedAttacker(i) == -1)
						{
							// If player has not been warned ...
							if (afkPlayerTimeLeftWarn[i] > 0) // warn time ...
							{
								// we reduce his warn time ...
								afkPlayerTimeLeftWarn[i] = afkPlayerTimeLeftWarn[i] - afkCheckInterval;
								
								// if his warn time reached 0 ....
								if (afkPlayerTimeLeftWarn[i] <= 0)
								{
									// we set his time left to spectate
									afkPlayerTimeLeftAction[i] = afkSpecTime;
									
									// We warn the player ....
									PrintHintText(i, "%T", "[AFK] Inactivity detected! 1", i, afkPlayerTimeLeftAction[i]);
								}
							}
							else // player warn timeout reached ...
							{
								// we reduce his action time
								afkPlayerTimeLeftAction[i] = afkPlayerTimeLeftAction[i] - afkCheckInterval;
								
								// if his action time reached 0 ...
								if (afkPlayerTimeLeftAction[i] <= 0)
								{
									// If players leaved safe room we force him to spectate
									if (g_bLeftSafeRoom || bAfkSaferoomIgnore)
									{
										// reset the timers
										afkResetTimers(i);

										// we force the player to spectate
										afkForceSpectate(i, true, false);
									}
									else // if players haven't leaved safe room ... we warn this player that he will be forced to spectate as soon as a player leaves
									{
										PrintHintText(i, "%T", "[AFK] Inactivity detected! 2", i);
									}
								}
								else // we just warn him ...
									PrintHintText(i,"%T", "[AFK] Inactivity detected! 1", i, afkPlayerTimeLeftAction[i]);
								
							}
						} // player is not trapped
						else // player is trapped
						{
							afkResetTimers(i);
						}
					} // player hasn't moved ...
					else // player moved ...
					{
						
						// we reset his timers
						afkResetTimers(i);
					}
					
				} // player is alive or is infected
			} // player is not on spectators ...
			else if (afkKickEnabled)  // if player is on spectators and kick on spectators is enabled ...
			{
				// If the player is not registered ...
				if (HasAccess(i, g_sAccesslvl) == false)
				{
					// If player has not been warned ...
					if (afkPlayerTimeLeftWarn[i] > 0) // warn time ...
					{
						// we reduce his warn time ...
						afkPlayerTimeLeftWarn[i] = afkPlayerTimeLeftWarn[i] - afkCheckInterval;
						
						// if his warn time reached 0 ....
						if (afkPlayerTimeLeftWarn[i] <= 0)
						{
							// We warn the player ....
							PrintHintText(i, "%T", "[AFK] Inactivity detected! 3", i, afkPlayerTimeLeftAction[i]);
						}
					}
					else // player warn timeout reached ...
					{
						// we reduce his action time
						afkPlayerTimeLeftAction[i] = afkPlayerTimeLeftAction[i] - afkCheckInterval;
						
						// if his action time reached 0 ...
						if (afkPlayerTimeLeftAction[i] <=  0)
						{
							// If players haven't leaved the safe room ..
							if (g_bLeftSafeRoom || bAfkSaferoomIgnore)
							{
								// we kick the player
								afkKickClient(i);

								// reset the timers
								afkResetTimers(i);
							}
							else // We warn him that he will be kicked ...
							{
								PrintHintText(i, "%T", "[AFK] Inactivity detected! 4", i);
							}
						}
						else // we just warn him ...
							PrintHintText(i, "%T", "[AFK] Inactivity detected! 3", i, afkPlayerTimeLeftAction[i]);	
					}			
				} // player is not admin
			} // player is on spectators
			
		} // player is connected and in-game
	}
	
	// We continue with the timer
	return Plugin_Continue;
}


void afkForceSpectate (int client, bool advertise, bool self)
{
	if (IsFakeClient(client))
	{
		return;
	}
	
	// If player was on infected .... 
	if (GetClientTeam(client) == 3)
	{
		// ... and he wasn't a tank ...
		char iClass[100];
		GetClientModel(client, iClass, sizeof(iClass));
		if (StrContains(iClass, "hulk", false) == -1)
		{
			ForcePlayerSuicide(client);	// we kill him
		}
		else // if he was a tank, we can't force him to spectate ... we wait for him to lose the tank
		{
			return;
		}
	}
	
	// We force him to spectate
	ChangeClientTeam(client, 1);
	
	// We send him a hint message 5 seconds later, in case he hasn't joined any team
	CreateTimer(5.0, afkJoinHint, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	
	// Print forced info
	if (advertise)
	{
		char PlayerName[200];
		GetClientName(client, PlayerName, sizeof(PlayerName));
		//PrintToChatAll("\x01\x04[TS] \x03%s \x01has been switched to \x03Spectators", PlayerName);
	}
	else if (self) 	// If player switched itself ...
	{
		char PlayerName[200];
		GetClientName(client, PlayerName, sizeof(PlayerName));
		//PrintToChatAll("\x01\x04[TS] \x03%s \x01switched himself to \x03Spectators", PlayerName);
	}
	
}

public Action afkForceSpectateJoin (Handle timer, int client)
{
	afkForceSpectate(client, false, false);

	return Plugin_Continue;
}

void afkKickClient (int client)
{
	if (IsFakeClient(client))
		return;
	
	// If player was on infected ....
	if (GetClientTeam(client) == 3)
	{
		// ... and he wasn't a tank ...
		char iClass[100];
		GetClientModel(client, iClass, sizeof(iClass));
		if (StrContains(iClass, "hulk", false) == -1)
			ForcePlayerSuicide(client);	// we kill him
	}
	
	// We force him to spectate
	ChangeClientTeam(client, 1);
	
	// Then we kick him
	KickClient(client, "[AFK] You've been kicked due to inactivity.");
	
	// Print forced info
	char PlayerName[200];
	GetClientName(client, PlayerName, sizeof(PlayerName));
	
	PrintToChatAll("\x01\x04[TS] \x03%s \x01%t.", PlayerName, "have been kicked from server due to inactivity.");
}


void afkManager_Stop()
{
	// if it was not active ...
	if (!afkManager_Active) return;
	
	// mark as not active
	afkManager_Active = false;
}

public Action PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea() || g_bLeftSafeRoom)
	{
		g_bLeftSafeRoom = true;
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

stock int GetInfectedAttacker(int client)
{
	int attacker;

	if(L4D2Version)
	{
		/* Charger */
		attacker = GetEntPropEnt(client, Prop_Send, "m_pummelAttacker");
		if (attacker > 0)
		{
			return attacker;
		}

		attacker = GetEntPropEnt(client, Prop_Send, "m_carryAttacker");
		if (attacker > 0)
		{
			return attacker;
		}
		/* Jockey */
		attacker = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
		if (attacker > 0)
		{
			return attacker;
		}
	}

	/* Hunter */
	attacker = GetEntPropEnt(client, Prop_Send, "m_pounceAttacker");
	if (attacker > 0)
	{
		return attacker;
	}

	/* Smoker */
	attacker = GetEntPropEnt(client, Prop_Send, "m_tongueOwner");
	if (attacker > 0)
	{
		return attacker;
	}

	return -1;
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

void ResetTimer()
{
	delete PlayerLeftStartTimer;
}
/////////////////
///////////////////
/////
