#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

enum struct CPlayerSkeetData
{
	char m_sName[64];
	int m_iSkeets;

	int m_iPosition;
}

#define TOP_NUMBER 5

ConVar hEnablePlugin, OneShotSkeet,hCvarAnnounce, g_hCvarMPGameMode,
	g_hCvarModesTog, g_hCvarSurvivorRequired, g_hCvarAIHunter, g_hCvar1v1Separate;
bool g_bCvarAllow;
ConVar g_hCvarSurvivorLimit, g_hCvarInfectedLimit;
bool g_bRoundEndAnnounce;
bool g_bShotCounted[MAXPLAYERS+1][MAXPLAYERS+1];
bool g_bIsPouncing[MAXPLAYERS+1];
bool g_bHasLandedPounce[MAXPLAYERS+1];
char datafilepath[256];
char datafilepath_1v1[256];
int timerDeath[MAXPLAYERS+1];
int Skeets[MAXPLAYERS+1];
int Kills[MAXPLAYERS+1];
int DeadStoped[MAXPLAYERS+1];
int g_iShotsDealt[MAXPLAYERS+1][MAXPLAYERS+1];
int g_damage[MAXPLAYERS+1][MAXPLAYERS+1];
int g_iDamageDealt[MAXPLAYERS+1][MAXPLAYERS+1];
int g_iLastHealth[MAXPLAYERS+1];
int g_iSurvivorLimit = 4;
bool CvarAnnounce;
bool Is1v1;

KeyValues g_hData;

public Plugin myinfo =
{
	name = "Top Skeet Announce (Data Support)",
	description = "Announce hunter skeet to the entire server, and save record to data/skeet_database.tx",
	author = "thrillkill, JNC, Harry",
	version = "2.4-2023/6/12",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 && test != Engine_Left4Dead)
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{
	hEnablePlugin = CreateConVar("skeet_database_enable", "1", "Enable this plugin?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	OneShotSkeet = CreateConVar("skeet_database_announce_oneshot", "1", "Only count 'One Shot' skeet?[1: Yes, 0: No]", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvarAnnounce = CreateConVar("skeet_database_announce", "0", "Announce skeet/shots in chatbox when someone skeets.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarModesTog =	CreateConVar("skeet_database_modes_tog",		"4",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus. Add numbers together.", FCVAR_NOTIFY, true, 0.0, true, 7.0);
	g_hCvarSurvivorRequired =	CreateConVar("top_skeet_survivors_required",		"4",			"Numbers of Survivors required at least to enable this plugin", FCVAR_NOTIFY , true, 1.0, true, 32.0);
	g_hCvarAIHunter =	CreateConVar("skeet_database_ai_hunter_enable",		"0",			"Count AI Hunter also?[1: Yes, 0: No]", FCVAR_NOTIFY , true, 0.0, true, 1.0);
	g_hCvar1v1Separate =	CreateConVar("skeet_database_1v1_seprate",		"1",		"Record 1v1 skeet database in 1v1 mode.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	GetCvars();
	hCvarAnnounce.AddChangeHook(ConVarChange_hCvarAnnounce);
	
	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarSurvivorLimit = FindConVar("survivor_limit");
	g_hCvarInfectedLimit = FindConVar("z_max_player_zombies");
	hEnablePlugin.AddChangeHook(ConVarChanged_Allow);
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarSurvivorRequired.AddChangeHook(ConVarChanged_Allow);
	g_hCvarSurvivorLimit.AddChangeHook(ConVarChanged_Allow);

	BuildPath(Path_SM, datafilepath, 256, "data/%s", "skeet_database.txt");
	BuildPath(Path_SM, datafilepath_1v1, 256, "data/%s", "1v1_skeet_database.txt");
	RegConsoleCmd("sm_skeets", Command_Stats, "Show your current skeet statistics and rank.", 0);
	RegConsoleCmd("sm_top5", Command_Top, "Show TOP 5 players in statistics.", 0);

	AutoExecConfig(true,"skeet_database");
}

public void OnPluginEnd()
{
	delete g_hData;
}

public void OnConfigsExecuted()
{
	IsAllowed();

	int SurvivorsLimit = g_hCvarSurvivorLimit.IntValue;
	int InfectedLimit = g_hCvarInfectedLimit.IntValue;
	if(SurvivorsLimit == 1 && InfectedLimit == 1)
	{
		Is1v1 = true;
	}
	else
	{
		Is1v1 = false;
	}

	g_hData = new KeyValues("skeetdata");
	if(g_hCvar1v1Separate.BoolValue && Is1v1)
	{
		if (!g_hData.ImportFromFile(datafilepath_1v1))
		{
			g_hData.JumpToKey("data", true);
			g_hData.GoBack();
			g_hData.JumpToKey("info", true);
			g_hData.SetNum("count", 0);
			g_hData.Rewind();
			g_hData.ExportToFile(datafilepath_1v1);
		}
	}
	else
	{	
		if (!g_hData.ImportFromFile(datafilepath))
		{
			g_hData.JumpToKey("data", true);
			g_hData.GoBack();
			g_hData.JumpToKey("info", true);
			g_hData.SetNum("count", 0);
			g_hData.Rewind();
			g_hData.ExportToFile(datafilepath);
		}
	}
}

void IsAllowed()
{
	bool bCvarAllow = hEnablePlugin.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	int SurvivorsLimit = g_hCvarSurvivorLimit.IntValue;
	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true && SurvivorsLimit>= g_hCvarSurvivorRequired.IntValue)
	{
		g_bCvarAllow = true;
		GetCvars();
		HookEvent("player_hurt", Event_PlayerHurt);
		HookEvent("ability_use", Event_AbilityUse);
		HookEvent("player_death", Event_PlayerDeath);
		HookEvent("round_start", Event_RoundStart);
		HookEvent("round_end", Event_RoundEnd);
		HookEvent("weapon_fire", weapon_fire);
		HookEvent("player_bot_replace", Event_Replace);
		HookEvent("bot_player_replace", Event_Replace);
		HookEvent("player_shoved", Event_PlayerShoved);
		HookEvent("lunge_pounce", Event_LungePounce);
	}
	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false || SurvivorsLimit < g_hCvarSurvivorRequired.IntValue) )
	{
		g_bCvarAllow = false;
		UnhookEvent("player_hurt", Event_PlayerHurt);
		UnhookEvent("ability_use", Event_AbilityUse);
		UnhookEvent("player_death", Event_PlayerDeath);
		UnhookEvent("round_start", Event_RoundStart);
		UnhookEvent("round_end", Event_RoundEnd);
		UnhookEvent("weapon_fire", weapon_fire);
		UnhookEvent("player_bot_replace", Event_Replace);
		UnhookEvent("bot_player_replace", Event_Replace);
		UnhookEvent("player_shoved", Event_PlayerShoved);
		UnhookEvent("lunge_pounce", Event_LungePounce);
	}
}

bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == INVALID_HANDLE )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog == 0) return true;

	char CurrentGameMode[32];
	g_hCvarMPGameMode.GetString(CurrentGameMode, sizeof(CurrentGameMode));
	int g_iCurrentMode = 0;
	if(StrEqual(CurrentGameMode,"coop", false))
	{
		g_iCurrentMode = 1;
	}
	else if (StrEqual(CurrentGameMode,"versus", false))
	{
		g_iCurrentMode = 4;
	}
	else if (StrEqual(CurrentGameMode,"survival", false))
	{
		g_iCurrentMode = 2;
	}

	if( g_iCurrentMode == 0 )
		return false;
		
	if(!(iCvarModesTog & g_iCurrentMode))
		return false;

	return true;
}

void ConVarChanged_Allow(ConVar convar, const char[] oldValue, const char[] newValue)
{	
	IsAllowed();
}

void ConVarChange_hCvarAnnounce(ConVar convar, const char[] oldValue, const char[] newValue)
{	
	GetCvars();
}

void GetCvars()
{
	CvarAnnounce = hCvarAnnounce.BoolValue;
}

public void OnMapStart()
{
	PrecacheSound("player/orch_hit_Csharp_short.wav", true);
	ClearSkeetCounter();
}

public void OnMapEnd()
{
    delete g_hData;
}

Action Command_Stats(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	if(!g_bCvarAllow) return Plugin_Handled;

	ShowSkeetRank(client);
	PrintSkeetsToClient(client);

	return Plugin_Handled;
}

Action Command_Top(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	if(!g_bCvarAllow) return Plugin_Handled;

	PrintTopSkeeters(client);

	return Plugin_Handled;
}

void Event_LungePounce(Event event, const char[] name, bool dontBroadcast) 
{
	int attacker = GetClientOfUserId(event.GetInt("userid"));
	g_bIsPouncing[attacker] = false;
	g_bHasLandedPounce[attacker] = true;
}

void weapon_fire(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	for (int i=1;i <= MaxClients;++i)
	{
		g_bShotCounted[i][client] = false;
	}
}

void Event_Replace(Event event, const char[] name, bool dontBroadcast) 
{
	int player = GetClientOfUserId(event.GetInt("player"));
	int bot = GetClientOfUserId(event.GetInt("bot"));
	Skeets[player] = 0;
	Skeets[bot] = 0;
	Kills[player] = 0;
	Kills[bot] = 0;
}

void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (!victim || !IsClientInGame(victim))
	{
		return;
	}
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int damage = event.GetInt("dmg_health");
	if (IsValidClient(attacker) && GetClientTeam(attacker) == 2)
	{
		if (IsPlayerHunter(victim))
		{
			if (!g_bShotCounted[victim][attacker])
			{
				g_iShotsDealt[victim][attacker]++;
				g_bShotCounted[victim][attacker] = true;
			}
			int remaining_health = event.GetInt("health");
			if (0 >= remaining_health)
			{
				return;
			}
			g_iLastHealth[victim] = remaining_health;
			g_iDamageDealt[victim][attacker] += damage;
		}
	}
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (!victim || !IsClientInGame(victim))
	{
		return;
	}

	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if (attacker == 0 || !IsClientInGame(attacker))
	{
		if (GetClientTeam(victim) == 3)
		{
			ClearDamage(victim);
		}

		return;
	}
	if (GetClientTeam(attacker) == 2 && GetClientTeam(victim) == 3)
	{
		int zombieclass = GetEntProp(victim, Prop_Send, "m_zombieClass");
		if (zombieclass == 5)
		{
			return;
		}

		int lasthealth = g_iLastHealth[victim];
		g_iDamageDealt[victim][attacker] += lasthealth ;
		if (zombieclass == 3 && g_bIsPouncing[victim] == true)
		{
			int[][] assisters = new int[g_iSurvivorLimit][2];
			int assister_count;
			int shots = g_iShotsDealt[victim][attacker];
			for (int i=1;i <= MaxClients;++i)
			{
				if (!(attacker == i))
				{
					if (g_iDamageDealt[victim][i] > 0 && IsClientInGame(i))
					{
						assisters[assister_count][0] = i;
						assisters[assister_count][1] = g_iDamageDealt[victim][i];
						assister_count++;
					}
				}
			}
			if (assister_count)
			{
			}
			else
			{
				if (!IsFakeClient(victim) || (IsFakeClient(victim) && GetConVarBool(g_hCvarAIHunter)) )
				{
					if (!IsFakeClient(attacker))
					{
						int mode = OneShotSkeet.IntValue;
						if (mode == 1)
						{
							if (shots == 1)
							{
								CreateTimer(0.0, Timer_Statistic, GetClientUserId(attacker), TIMER_FLAG_NO_MAPCHANGE);
								CreateTimer(0.1, Timer_PrintTopSkeeters, 0, TIMER_FLAG_NO_MAPCHANGE);
								Skeeted(attacker);
								Skeets[attacker]++;
								Kills[attacker]++;
							}
						}
						else
						{
							CreateTimer(0.0, Timer_Statistic, GetClientUserId(attacker), TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, Timer_PrintTopSkeeters, 0, TIMER_FLAG_NO_MAPCHANGE);
							Skeeted(attacker);
							Skeets[attacker]++;
							Kills[attacker]++;
						}
						if (shots == 1)
						{
							if(CvarAnnounce)
							{
								PrintToChatAll("\x01[\x04SM\x01] %N skeeted %N in 1 shot%s", attacker, victim, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
							}
						}
						else
						{
							if(CvarAnnounce)
							{
								PrintToChatAll("\x01[\x04SM\x01] %N skeeted %N in %i shots%s", attacker, victim, shots, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
							}
						}
					}
				}
			}
		}
		else
		{
			Kills[attacker]++;
		}
	}
	if (GetClientTeam(victim) == 3)
	{
		ClearDamage(victim);
	}
}

void Event_AbilityUse(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsClientInGame(client) && IsPlayerHunter(client))
	{
		g_bIsPouncing[client] = true;
		CreateTimer(0.1, Timer_GroundedCheck, client, TIMER_REPEAT);
	}
}

Action Timer_GroundedCheck(Handle timer, int client)
{
	if ( !IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 3 || !IsPlayerHunter(client) || IsGrounded(client) || IsOnLadder(client) )
	{
		g_bIsPouncing[client] = false;
		remove_damage(client);

		return Plugin_Stop;
	}
	return Plugin_Continue;
}

void Event_PlayerShoved(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (!victim || !IsClientInGame(victim))
	{
		return;
	}
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if (attacker == 0 || !IsClientInGame(attacker) || GetClientTeam(attacker) != 2)
	{
		return;
	}
	int zombieclass = GetEntProp(victim, Prop_Send, "m_zombieClass");
	if (zombieclass == 3 && g_bIsPouncing[victim])
	{
		if (IsFakeClient(victim) && !g_hCvarAIHunter.BoolValue )
		{
			return;
		}
		g_bIsPouncing[victim] = false;
		g_bHasLandedPounce[attacker] = false;
		Handle pack;
		CreateDataTimer(0.2, Timer_DeadstopCheck, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, attacker);
		WritePackCell(pack, victim);
	}
}

Action Timer_DeadstopCheck(Handle timer, Handle pack)
{
	ResetPack(pack, false);
	int attacker = ReadPackCell(pack);
	if (!g_bHasLandedPounce[attacker])
	{
		int victim = ReadPackCell(pack);
		if (!IsFakeClient(victim) || (IsFakeClient(victim) && g_hCvarAIHunter.BoolValue) )
		{
			if (IsClientInGame(victim) && IsClientInGame(attacker))
			{
				DeadStoped[attacker]++;
				if (!IsFakeClient(attacker))
				{
					if(CvarAnnounce)
					{
						PrintToChat(attacker, "\x01[\x04SM\x01] \x03You \x01DeadStoped \x04%N%s", victim, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
					}
				}
				if (!IsFakeClient(victim))
				{
					if(CvarAnnounce)
					{
						PrintToChat(victim, "\x01[\x04SM\x01] \x03You \x01were deadstopped by \x04%N%s", attacker, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

void remove_damage(int client)
{
	for (int i=1;MaxClients >= i;++i)
	{
		g_damage[client][i] = 0;
	}
}

bool IsGrounded(int client)
{
	return (GetEntProp(client, Prop_Data, "m_fFlags") & FL_ONGROUND) > 0;
}

void ClearDamage(int client)
{
	for (int i=1;i <= MaxClients;++i)
	{
		g_iDamageDealt[client][i] = 0;
		g_iShotsDealt[client][i] = 0;
	}
}

bool IsValidClient(int client)
{
	if (client < 1 || client > MaxClients)
	{
		return false;
	}
	if (!IsValidEntity(client))
	{
		return false;
	}
	return true;
}

void ClearSkeetCounter()
{
	for (int i=1;i <= MaxClients;++i)
	{
		Skeets[i] = 0;
		Kills[i] = 0;
		DeadStoped[i] = 0;
	}
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	for (int i=1;i <= MaxClients;++i)
	{
		ClearDamage(i);
	}
	if (!g_bRoundEndAnnounce)
	{
		if(CvarAnnounce)
			PrintStats();
		g_bRoundEndAnnounce = true;
	}
}

void PrintStats()
{
	int survivor_index = 0;
	int[] survivor_clients = new int[MaxClients+1];
	int client;
	for (client=1;client <= MaxClients;++client)
	{
		if (!IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2) continue;

		survivor_clients[survivor_index] = client;
		survivor_index++;
	}

	SortCustom1D(survivor_clients, survivor_index, SortByDamageDesc);

	PrintToChatAll("\x01------------------------------");
	int frags;
	int skeetscount;
	int shoved;
	for (int i=0;i < survivor_index;++i)
	{
		client = survivor_clients[i];
		frags = Kills[client];
		skeetscount = Skeets[client];
		shoved = DeadStoped[client];
		PrintToChatAll("\x04%N \x03(Kills: \x01%i \x03| Skeets: \x01%i \x03| Deadstops: \x01%i\x03)", client, frags, skeetscount, shoved);
	}
	PrintToChatAll("\x01------------------------------");
}

int SortByDamageDesc(int elem1, int elem2, const int[] array, Handle hndl)
{
	if (Kills[elem1] > Kills[elem2])
	{
		return -1;
	}
	if (Kills[elem2] > Kills[elem1])
	{
		return 1;
	}
	if (elem1 > elem2)
	{
		return -1;
	}
	if (elem2 > elem1)
	{
		return 1;
	}
	return 0;
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	ClearSkeetCounter();
	g_bRoundEndAnnounce = false;
}

void Skeeted(int client)
{
	CreateTimer(0.1, Award, client, TIMER_FLAG_NO_MAPCHANGE);
	timerDeath[client] = 200;
}

Action Award(Handle timer, int client)
{
	if (!IsClientInGame(client)) return Plugin_Continue;

	timerDeath[client] -= 20;
	if (timerDeath[client] > 101)
	{
		EmitSoundToAll("player/orch_hit_Csharp_short.wav", client, 3, 140, 0, 1.0, timerDeath[client], -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		switch (timerDeath[client])
		{
			case 120:
			{
				CreateTimer(1.1, Award, client, TIMER_FLAG_NO_MAPCHANGE);
			}
			case 140:
			{
				CreateTimer(0.8, Award, client, TIMER_FLAG_NO_MAPCHANGE);
			}
			case 160:
			{
				CreateTimer(0.5, Award, client, TIMER_FLAG_NO_MAPCHANGE);
			}
			case 180:
			{
				CreateTimer(0.3, Award, client, TIMER_FLAG_NO_MAPCHANGE);
			}
			default:
			{
				CreateTimer(1.3, Award, client, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}

	return Plugin_Continue;
}

bool IsPlayerHunter(int client)
{
	if (GetEntProp(client, Prop_Send, "m_zombieClass") == 3)
	{
		return true;
	}
	return false;
}

Action Timer_PrintTopSkeeters(Handle timer, int attacker)
{
	PrintTopSkeeters(0);
	return Plugin_Continue;
}

void PrintTopSkeeters(int client)
{
	if(g_hData == null) return;
	g_hData.Rewind();

	g_hData.JumpToKey("info", false);
	int count = g_hData.GetNum("count", 0);

	CPlayerSkeetData CTopPlayer[TOP_NUMBER];
	int totalskeets=0, Max_skeets, iSkeets, Max_index;
	bool bIgnore;
	g_hData.GoBack();
	g_hData.JumpToKey("data", false);
	
	for(int current = 0; current < TOP_NUMBER; current++)
	{
		g_hData.GotoFirstSubKey(true);

		Max_skeets = 0;
		Max_index = 0;
		for (int index=1; index <= count ;++index, g_hData.GotoNextKey(true))
		{
			iSkeets = g_hData.GetNum("skeet", 0);
			if(iSkeets <= 0) continue;

			if(current == 0)
			{
				totalskeets += iSkeets;
			}
			else
			{
				bIgnore = false;
				for(int previous = 0; previous < current; previous++)
				{
					//PrintToChatAll("%d - CTopPlayer[previous].m_iPosition: %d", previous, CTopPlayer[previous].m_iPosition);
					if(index == CTopPlayer[previous].m_iPosition)
					{
						//PrintToChatAll("index(%d) == CTopPlayer[previous].m_iPosition", index);
						if(current-1==previous) g_hData.GetString("name", CTopPlayer[previous].m_sName, sizeof(CPlayerSkeetData::m_sName), "Unnamed");
						bIgnore = true;
						break;
					}
				}
				if(bIgnore) continue;
			}
			
			if(iSkeets > Max_skeets)
			{
				//PrintToChatAll("iSkeets: %d, Max_skeets: %d, index: %d", iSkeets, Max_skeets, index);
				Max_skeets 	= iSkeets;
				Max_index 	= index;
			}
		}
		//PrintToChatAll("Max_skeets: %d, Max_index: %d", Max_skeets, Max_index);
		CTopPlayer[current].m_iSkeets 		= Max_skeets;
		CTopPlayer[current].m_iPosition 	= Max_index;
		g_hData.GoBack();
	}
	g_hData.GotoFirstSubKey(true);
	for (int index=1; index <= count ;++index, g_hData.GotoNextKey(true))
	{
		if(index == CTopPlayer[TOP_NUMBER-1].m_iPosition)
		{
			g_hData.GetString("name", CTopPlayer[TOP_NUMBER-1].m_sName, sizeof(CPlayerSkeetData::m_sName), "Unnamed");
			break;
		}
	}

	Panel panel = new Panel();
	int oneshot = OneShotSkeet.IntValue;
	static char sBuffer[128];
	if (oneshot == 1)
	{
		if(g_hCvar1v1Separate.BoolValue && Is1v1)
			FormatEx(sBuffer, sizeof(sBuffer), "Best One Shot Skeeters In 1v1");
		else
			FormatEx(sBuffer, sizeof(sBuffer), "Best One Shot Skeeters");
	}
	else
	{
		if(g_hCvar1v1Separate.BoolValue && Is1v1)
			FormatEx(sBuffer, sizeof(sBuffer), "Top %d Skeeters In 1v1", TOP_NUMBER);
		else 
			FormatEx(sBuffer, sizeof(sBuffer), "Top %d Skeeters", TOP_NUMBER);
	}
	panel.SetTitle(sBuffer);
	panel.DrawText("\n ");
	if (totalskeets)
	{
		for (int i=0 ; i<TOP_NUMBER && i < count;++i)
		{
			FormatEx(sBuffer, sizeof(sBuffer), "%d skeets - %s", CTopPlayer[i].m_iSkeets, CTopPlayer[i].m_sName);
			panel.DrawItem(sBuffer);
		}
		panel.DrawText("\n ");
		FormatEx(sBuffer, sizeof(sBuffer), "Total %d skeets on the server%s", totalskeets, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
		panel.DrawText(sBuffer);
	}
	else
	{
		Format(sBuffer, sizeof(sBuffer), "There are no skeets on this server yet%s", (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
	}

	if(client == 0)
	{
		for (int player = 1; player<=MaxClients; ++player)
		{	
			if (IsClientInGame(player) && !IsFakeClient(player))
			{
				panel.Send(player, TopSkeetPanelHandler, 5);
			}
		}
	}
	else 
	{
		panel.Send(client, TopSkeetPanelHandler, 5);
	}

	delete panel;
}

Action Timer_Statistic(Handle timer, int attacker)
{
	if(g_hData == null) return Plugin_Continue;
	g_hData.Rewind();
	g_hData.JumpToKey("data", true);

	attacker = GetClientOfUserId(attacker);
	if(attacker > 0 && IsClientInGame(attacker))
	{
		static char clientname[32];
		GetClientName(attacker, clientname, 32);
		ReplaceString(clientname, 32, "'", "", true);
		ReplaceString(clientname, 32, "<", "", true);
		ReplaceString(clientname, 32, "{", "", true);
		ReplaceString(clientname, 32, "}", "", true);
		ReplaceString(clientname, 32, "\n", "", true);
		ReplaceString(clientname, 32, "\"", "", true);
		static char clientauth[32];
		GetClientAuthId(attacker, AuthId_Steam2, clientauth, 32);
		if (!g_hData.JumpToKey(clientauth, false))
		{
			g_hData.GoBack();
			g_hData.JumpToKey("info", true);
			int count = g_hData.GetNum("count", 0);
			count++;
			g_hData.SetNum("count", count);
			g_hData.GoBack();
			g_hData.JumpToKey("data", true);
			g_hData.JumpToKey(clientauth, true);
		}
		int skeet = g_hData.GetNum("skeet", 0);
		skeet++;
		g_hData.SetNum("skeet", skeet);
		g_hData.SetString("name", clientname);
		g_hData.Rewind();

		if(g_hCvar1v1Separate.BoolValue && Is1v1)
			g_hData.ExportToFile(datafilepath_1v1);
		else
			g_hData.ExportToFile(datafilepath);
		if(CvarAnnounce)
		{
			PrintToChat(attacker, "\x01[\x04SM\x01] \x03You \x04have \x01%d skeets%s", skeet, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
		}
	}

	return Plugin_Continue;
}

void PrintSkeetsToClient(int client)
{
	if(g_hData == null) return;
	g_hData.Rewind();

	char auth[32];
	GetClientAuthId(client, AuthId_Steam2, auth, 32);
	g_hData.JumpToKey("data", false);
	g_hData.JumpToKey(auth, false);
	int skeet = g_hData.GetNum("skeet", 0);
	if (skeet == 1)
	{
		PrintToChat(client, "\x04You \x03only \x011 skeet%s", (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
	}
	else if (skeet < 1)
	{
		PrintToChat(client, "\x03You \x01don't have skeets%s", (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
	}
	else
	{
		PrintToChat(client, "\x04You \x03have \x01%d skeets%s", skeet, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
	}
	return;
}

void ShowSkeetRank(int client)
{
	if(g_hData == null) return;
	g_hData.Rewind();

	g_hData.JumpToKey("info", false);
	int count = g_hData.GetNum("count", 0);
	g_hData.GoBack();
	g_hData.JumpToKey("data", false);
	int skeet;
	char auth[32];
	GetClientAuthId(client, AuthId_Steam2, auth, 32);
	if (g_hData.JumpToKey(auth, false))
	{
		skeet = g_hData.GetNum("skeet", 0);
	}
	else
	{
		skeet = 0;
	}
	int rank = TopTo(skeet);
	PrintToChat(client, "Skeet Ranking: %d/%d%s", rank, count, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
}

int TopTo(int skeeti)
{
	if(g_hData == null) return 0;
	g_hData.Rewind();
	
	g_hData.JumpToKey("info", false);
	int count = g_hData.GetNum("count", 0);
	int skeet;
	g_hData.GoBack();
	g_hData.JumpToKey("data", false);
	g_hData.GotoFirstSubKey(true);
	int total;
	for (int i=0;i < count;++i)
	{
		skeet = g_hData.GetNum("skeet", 0);
		if (skeet >= skeeti)
		{
			total++;
		}
		g_hData.GotoNextKey(true);
	}
	return total;
}

int TopSkeetPanelHandler(Handle menu, MenuAction action, int param1, int param2)
{
	return 0;
}

bool IsOnLadder(int entity)
{
    return GetEntityMoveType(entity) == MOVETYPE_LADDER;
}