#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

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
int CvarAnnounce;
bool Is1v1;

public Plugin myinfo =
{
	name = "Skeet Announce Edition (Database)",
	description = "Announce dmg/skeet/frag/ds original from thrillkill/n0limit, fixed by JNC",
	author = "Autor: thrillkill - edited: JNC - improve: Harry",
	version = "2.2",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public void OnPluginStart()
{
	hEnablePlugin = CreateConVar("skeet_database_enable", "1", "Enable this plugin?", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	OneShotSkeet = CreateConVar("skeet_database_announce_oneshot", "1", "Only count 'One Shot' skeet?[1: Yes, 0: No]", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvarAnnounce = CreateConVar("skeet_database_announce", "0", "Announce skeet/shots in chatbox when someone skeets.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarModesTog =	CreateConVar("skeet_database_modes_tog",		"4",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus. Add numbers together.", FCVAR_NOTIFY, true, 0.0, true, 7.0);
	g_hCvarSurvivorRequired =	CreateConVar("top_skeet_survivors_required",		"4",			"Numbers of Survivors required at least to enable this plugin", FCVAR_NOTIFY , true, 1.0, true, 32.0);
	g_hCvarAIHunter =	CreateConVar("skeet_database_ai_hunter_enable",		"0",			"Count AI Hunter also?[1: Yes, 0: No]", FCVAR_NOTIFY , true, 0.0, true, 1.0);
	g_hCvar1v1Separate =	CreateConVar("skeet_database_1v1_seprate",		"1",		"Record 1v1 skeet database in 1v1 mode.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	CvarAnnounce = GetConVarInt(hCvarAnnounce);
	HookConVarChange(hCvarAnnounce, ConVarChange_hCvarAnnounce);
	
	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarSurvivorLimit = FindConVar("survivor_limit");
	g_hCvarInfectedLimit = FindConVar("z_max_player_zombies");
	HookConVarChange(hEnablePlugin, ConVarChanged_Allow);
	HookConVarChange(g_hCvarMPGameMode, ConVarChanged_Allow);
	HookConVarChange(g_hCvarModesTog, ConVarChanged_Allow);
	HookConVarChange(g_hCvarSurvivorRequired, ConVarChanged_Allow);
	HookConVarChange(g_hCvarSurvivorLimit, ConVarChanged_Allow);

	BuildPath(Path_SM, datafilepath, 256, "data/%s", "skeet_database.txt");
	BuildPath(Path_SM, datafilepath_1v1, 256, "data/%s", "1v1_skeet_database.txt");
	RegConsoleCmd("sm_skeets", Command_Stats, "Show your current skeet statistics and rank.", 0);
	RegConsoleCmd("sm_top5", Command_Top, "Show TOP 5 players in statistics.", 0);

	AutoExecConfig(true,"skeet_database");
}

public void OnConfigsExecuted()
{
	IsAllowed();

	int SurvivorsLimit = GetConVarInt(g_hCvarSurvivorLimit);
	int InfectedLimit = GetConVarInt(g_hCvarInfectedLimit);
	if(SurvivorsLimit == 1 && InfectedLimit == 1)
	{
		Is1v1 = true;
	}
	else
	{
		Is1v1 = false;
	}
}

void IsAllowed()
{
	bool bCvarAllow = GetConVarBool(hEnablePlugin);
	bool bAllowMode = IsAllowedGameMode();
	int SurvivorsLimit = GetConVarInt(g_hCvarSurvivorLimit);
	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true && SurvivorsLimit>= GetConVarInt(g_hCvarSurvivorRequired))
	{
		g_bCvarAllow = true;
		CvarAnnounce = GetConVarInt(hCvarAnnounce);
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
	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false || SurvivorsLimit < GetConVarInt(g_hCvarSurvivorRequired)) )
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

	int iCvarModesTog = GetConVarInt(g_hCvarModesTog);
	if( iCvarModesTog == 0) return true;

	char CurrentGameMode[32];
	GetConVarString(g_hCvarMPGameMode, CurrentGameMode, sizeof(CurrentGameMode));
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

public void ConVarChanged_Allow(ConVar convar, const char[] oldValue, const char[] newValue)
{	
	IsAllowed();
}

public void ConVarChange_hCvarAnnounce(ConVar convar, const char[] oldValue, const char[] newValue)
{	
	CvarAnnounce = GetConVarInt(hCvarAnnounce);
}

public Action Command_Stats(int client, int args)
{
	if(g_bCvarAllow)
	{
		ShowSkeetRank(client);
		PrintSkeetsToClient(client);
	}
	return Plugin_Continue;
}

public Action Command_Top(int client, int args)
{
	if(g_bCvarAllow)
		PrintTopSkeetersToClient(client);
	return Plugin_Continue;
}

public void OnMapStart()
{
	PrecacheSound("player/orch_hit_Csharp_short.wav", true);
	ClearSkeetCounter();
}

public Action Event_LungePounce(Event event, const char[] name, bool dontBroadcast) 
{
	int attacker = GetClientOfUserId(event.GetInt("userid"));
	g_bIsPouncing[attacker] = false;
	g_bHasLandedPounce[attacker] = true;
	return Plugin_Continue;
}

public Action weapon_fire(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	for (int i=1;i <= MaxClients;++i)
	{
		g_bShotCounted[i][client] = false;
	}
	return Plugin_Continue;
}

public Action Event_Replace(Event event, const char[] name, bool dontBroadcast) 
{
	int player = GetClientOfUserId(event.GetInt("player"));
	int bot = GetClientOfUserId(event.GetInt("bot"));
	Skeets[player] = 0;
	Skeets[bot] = 0;
	Kills[player] = 0;
	Kills[bot] = 0;
	return Plugin_Continue;
}

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (!victim || !IsClientInGame(victim))
	{
		return Plugin_Continue;
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
				return Plugin_Continue;
			}
			g_iLastHealth[victim] = remaining_health;
			g_iDamageDealt[victim][attacker] += damage;
		}
	}
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (!victim || !IsClientInGame(victim))
	{
		return Plugin_Continue;
	}
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if (attacker == 0 || !IsClientInGame(attacker))
	{
		if (GetClientTeam(victim) == 3)
		{
			ClearDamage(victim);
		}
		return Plugin_Continue;
	}
	if (GetClientTeam(attacker) == 2 && GetClientTeam(victim) == 3)
	{
		int zombieclass = GetEntProp(victim, Prop_Send, "m_zombieClass");
		if (zombieclass == 5)
		{
			return Plugin_Continue;
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
						int mode = GetConVarInt(OneShotSkeet);
						if (mode == 1)
						{
							if (shots == 1)
							{
								Statistic(attacker);
								PrintTopSkeeters();
								Skeeted(attacker);
								Skeets[attacker]++;
								Kills[attacker]++;
							}
						}
						else
						{
							Statistic(attacker);
							PrintTopSkeeters();
							Skeeted(attacker);
							Skeets[attacker]++;
							Kills[attacker]++;
						}
						if (shots == 1)
						{
							if(CvarAnnounce == 1)
							{
								PrintToChatAll("\x01[\x04SM\x01] %N skeeted %N in 1 shot%s", attacker, victim, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
							}
						}
						else
						{
							if(CvarAnnounce == 1)
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
	return Plugin_Continue;
}

public Action Event_AbilityUse(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (IsClientInGame(client) && IsPlayerHunter(client))
	{
		g_bIsPouncing[client] = true;
		CreateTimer(0.1, Timer_GroundedCheck, client, TIMER_REPEAT);
	}
	return Plugin_Continue;
}

public Action Timer_GroundedCheck(Handle timer, int client)
{
	if ( !IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 3 || !IsPlayerHunter(client) || IsGrounded(client) || IsOnLadder(client) )
	{
		g_bIsPouncing[client] = false;
		remove_damage(client);

		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Event_PlayerShoved(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (!victim || !IsClientInGame(victim))
	{
		return Plugin_Continue;
	}
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if (attacker == 0 || !IsClientInGame(attacker) || GetClientTeam(attacker) != 2)
	{
		return Plugin_Continue;
	}
	int zombieclass = GetEntProp(victim, Prop_Send, "m_zombieClass");
	if (zombieclass == 3 && g_bIsPouncing[victim])
	{
		if (IsFakeClient(victim) && !GetConVarBool(g_hCvarAIHunter) )
		{
			return Plugin_Continue;
		}
		g_bIsPouncing[victim] = false;
		g_bHasLandedPounce[attacker] = false;
		Handle pack;
		CreateDataTimer(0.2, Timer_DeadstopCheck, pack, TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(pack, attacker);
		WritePackCell(pack, victim);
	}
	return Plugin_Continue;
}

public Action Timer_DeadstopCheck(Handle timer, Handle pack)
{
	ResetPack(pack, false);
	int attacker = ReadPackCell(pack);
	if (!g_bHasLandedPounce[attacker])
	{
		int victim = ReadPackCell(pack);
		if (!IsFakeClient(victim) || (IsFakeClient(victim) && GetConVarBool(g_hCvarAIHunter)) )
		{
			if (IsClientInGame(victim) && IsClientInGame(attacker))
			{
				DeadStoped[attacker]++;
				if (!IsFakeClient(attacker))
				{
					if(CvarAnnounce == 1)
					{
						PrintToChat(attacker, "\x01[\x04SM\x01] \x03You \x01DeadStoped \x04%N%s", victim, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
					}
				}
				if (!IsFakeClient(victim))
				{
					if(CvarAnnounce == 1)
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

void Statistic(int client)
{
	char clientname[32];
	GetClientName(client, clientname, 32);
	ReplaceString(clientname, 32, "'", "", true);
	ReplaceString(clientname, 32, "<", "", true);
	ReplaceString(clientname, 32, "{", "", true);
	ReplaceString(clientname, 32, "}", "", true);
	ReplaceString(clientname, 32, "\n", "", true);
	ReplaceString(clientname, 32, "\"", "", true);
	char clientauth[32];
	GetClientAuthId(client, AuthId_Steam2, clientauth, 32);
	Handle Data = CreateKeyValues("skeetdata", "", "");
	int count;
	int skeet;
	if(g_hCvar1v1Separate.BoolValue && Is1v1)
		FileToKeyValues(Data, datafilepath_1v1);
	else
		FileToKeyValues(Data, datafilepath);

	KvJumpToKey(Data, "data", true);
	if (!KvJumpToKey(Data, clientauth, false))
	{
		KvGoBack(Data);
		KvJumpToKey(Data, "info", true);
		count = KvGetNum(Data, "count", 0);
		count++;
		KvSetNum(Data, "count", count);
		KvGoBack(Data);
		KvJumpToKey(Data, "data", true);
		KvJumpToKey(Data, clientauth, true);
	}
	skeet = KvGetNum(Data, "skeet", 0);
	skeet++;
	KvSetNum(Data, "skeet", skeet);
	KvSetString(Data, "name", clientname);
	KvRewind(Data);
	if(g_hCvar1v1Separate.BoolValue && Is1v1)
		KeyValuesToFile(Data, datafilepath_1v1);
	else
		KeyValuesToFile(Data, datafilepath);
	CloseHandle(Data);
	if(CvarAnnounce == 1)
	{
		PrintToChat(client, "\x01[\x04SM\x01] \x03You \x04have \x01%d skeets%s", skeet, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
	}
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

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	for (int i=1;i <= MaxClients;++i)
	{
		ClearDamage(i);
	}
	if (!g_bRoundEndAnnounce)
	{
		if(CvarAnnounce == 1)
			PrintStats();
		g_bRoundEndAnnounce = true;
	}
	return Plugin_Continue;
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

public int SortByDamageDesc(int elem1, int elem2, const int[] array, Handle hndl)
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

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	ClearSkeetCounter();
	g_bRoundEndAnnounce = false;
	return Plugin_Continue;
}

void Skeeted(int client)
{
	CreateTimer(0.1, Award, client, TIMER_FLAG_NO_MAPCHANGE);
	timerDeath[client] = 200;
}

public Action Award(Handle timer, int client)
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

public Action Command_Say(int client, int args)
{
	if (args < 1)
	{
		return Plugin_Continue;
	}
	char text[16];
	GetCmdArg(1, text, 15);
	if (StrContains(text, "!skeets", true))
	{
		if (StrContains(text, "/skeets", true))
		{
			if (StrContains(text, "!top10", true))
			{
				if (StrContains(text, "!rank", true))
				{
					return Plugin_Continue;
				}
				ShowSkeetRank(client);
				return Plugin_Continue;
			}
			PrintTopSkeetersToClient(client);
			return Plugin_Continue;
		}
		PrintSkeetsToClient(client);
		return Plugin_Continue;
	}
	PrintSkeetsToClient(client);
	return Plugin_Continue;
}

void PrintTopSkeetersToClient(int client)
{
	if (!IsDedicatedServer())
	{
		if (!client)
		{
			client = 1;
		}
	}
	Handle Data = CreateKeyValues("skeetdata", "", "");
	int count;

	if(g_hCvar1v1Separate.BoolValue && Is1v1)
	{
		if (!FileToKeyValues(Data, datafilepath_1v1))
		{
			return;
		}
	}
	else
	{	
		if (!FileToKeyValues(Data, datafilepath))
		{
			return;
		}
	}
	KvJumpToKey(Data, "info", false);
	count = KvGetNum(Data, "count", 0);
	char[][] names = new char[count][64];
	int[][] skeets = new int[count][2];
	int totalskeets=0;
	KvGoBack(Data);
	KvJumpToKey(Data, "data", false);
	KvGotoFirstSubKey(Data, true);
	for (int i=0;i<count;++i)
	{
		KvGetString(Data, "name", names[i], 64, "Unnamed");
		skeets[i][0] = i;
		skeets[i][1] = KvGetNum(Data, "skeet", 0);
		totalskeets += skeets[i][1];
		KvGotoNextKey(Data, true);
	}
	CloseHandle(Data);
	SortCustom2D(skeets, count, Sort_Function);
	Handle Panell = CreatePanel();
	int oneshot = GetConVarInt(OneShotSkeet);
	if (oneshot == 1)
	{
		if(g_hCvar1v1Separate.BoolValue && Is1v1)
			SetPanelTitle(Panell, "Best One Shot Skeeters In 1v1");
		else
			SetPanelTitle(Panell, "Best One Shot Skeeters");
	}
	else
	{
		if(g_hCvar1v1Separate.BoolValue && Is1v1)
			SetPanelTitle(Panell, "Top 5 Skeeters In 1v1");
		else 
			SetPanelTitle(Panell, "Top 5 Skeeters");
	}
	DrawPanelText(Panell, "\n ");
	char text[256];
	if (totalskeets)
	{
		if (count > 5)
		{
			count = 5;
		}
		for (int i=0;i<count;++i)
		{
			Format(text, 255, "%d skeets - %s", skeets[i][1], names[skeets[i][0]]);
			DrawPanelItem(Panell, text);
		}
		DrawPanelText(Panell, "\n ");
		Format(text, 255, "Total %d skeets on the server%s", totalskeets, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
		DrawPanelText(Panell, text);
	}
	else
	{
		Format(text, 255, "There are no skeets on this server yet%s", (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
	}
	SendPanelToClient(Panell, client, TopSkeetPanelHandler, 5);
	CloseHandle(Panell);
	return;
}

void PrintTopSkeeters()
{
	Handle Data = CreateKeyValues("skeetdata", "", "");
	int count;
	if(g_hCvar1v1Separate.BoolValue && Is1v1)
	{
		if (!FileToKeyValues(Data, datafilepath_1v1))
		{
			return;
		}
	}
	else
	{	
		if (!FileToKeyValues(Data, datafilepath))
		{
			return;
		}
	}
	KvJumpToKey(Data, "info", false);
	count = KvGetNum(Data, "count", 0);
	char[][] names = new char[count][64];
	int[][] skeets = new int[count][2];
	int totalskeets=0;
	KvGoBack(Data);
	KvJumpToKey(Data, "data", false);
	KvGotoFirstSubKey(Data, true);
	for (int i=0;i<count;++i)
	{
		KvGetString(Data, "name", names[i], 64, "Unnamed");
		skeets[i][0] = i;
		skeets[i][1] = KvGetNum(Data, "skeet", 0);
		totalskeets += skeets[i][1];
		KvGotoNextKey(Data, true);
	}
	CloseHandle(Data);
	SortCustom2D(skeets, count, Sort_Function);
	Handle Panell = CreatePanel();
	int oneshot = GetConVarInt(OneShotSkeet);
	if (oneshot == 1)
	{
		if(g_hCvar1v1Separate.BoolValue && Is1v1)
			SetPanelTitle(Panell, "5 Best One Shot skeeters In 1v1");
		else
			SetPanelTitle(Panell, "5 Best One Shot skeeters");
	}
	else
	{
		if(g_hCvar1v1Separate.BoolValue && Is1v1)
			SetPanelTitle(Panell, "Top 5 Skeeters In 1v1");
		else 
			SetPanelTitle(Panell, "Top 5 Skeeters");
	}
	DrawPanelText(Panell, "\n ");
	char text[256];
	if (totalskeets)
	{
		if (count > 5)
		{
			count = 5;
		}
		for (int i=0;i<count;++i)
		{
			Format(text, 255, "%d skeets - %s", skeets[i][1], names[skeets[i][0]]);
			DrawPanelItem(Panell, text);
		}
		DrawPanelText(Panell, "\n ");
		Format(text, 255, "Total %d skeets on the server%s", totalskeets, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
		DrawPanelText(Panell, text);
	}
	else
	{
		Format(text, 255, "There are no skeets on this server yet%s", (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
	}
	for (int i=1;i<=MaxClients;++i)
	{	
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			SendPanelToClient(Panell, i, TopSkeetPanelHandler, 5);
		}
	}
	CloseHandle(Panell);
	return;
}

void PrintSkeetsToClient(int client)
{
	if (!IsDedicatedServer())
	{
		if (!client)
		{
			client = 1;
		}
	}
	Handle Data = CreateKeyValues("skeetdata", "", "");
	int skeet;
	if(g_hCvar1v1Separate.BoolValue && Is1v1)
	{
		if (!FileToKeyValues(Data, datafilepath_1v1))
		{
			PrintToChat(client, "\x03There is no \x01data in 1v1.");
			return;
		}
	}
	else
	{	
		if (!FileToKeyValues(Data, datafilepath))
		{
			PrintToChat(client, "\x03There is no \x01data.");
			return;
		}
	}
	char auth[32];
	GetClientAuthId(client, AuthId_Steam2, auth, 32);
	KvJumpToKey(Data, "data", false);
	KvJumpToKey(Data, auth, false);
	skeet = KvGetNum(Data, "skeet", 0);
	CloseHandle(Data);
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
	if (!IsDedicatedServer())
	{
		if (!client)
		{
			client = 1;
		}
	}
	Handle Data = CreateKeyValues("skeetdata", "", "");
	int count;
	if(g_hCvar1v1Separate.BoolValue && Is1v1)
	{
		if (!FileToKeyValues(Data, datafilepath_1v1))
		{
			return;
		}
	}
	else
	{	
		if (!FileToKeyValues(Data, datafilepath))
		{
			return;
		}
	}
	KvJumpToKey(Data, "info", false);
	count = KvGetNum(Data, "count", 0);
	KvGoBack(Data);
	KvJumpToKey(Data, "data", false);
	int skeet;
	char auth[32];
	GetClientAuthId(client, AuthId_Steam2, auth, 32);
	if (KvJumpToKey(Data, auth, false))
	{
		skeet = KvGetNum(Data, "skeet", 0);
	}
	else
	{
		skeet = 0;
	}
	int place = TopTo(skeet);
	PrintToChat(client, "Skeet Ranking: %d/%d%s", place, count, (g_hCvar1v1Separate.BoolValue && Is1v1) ? " in 1v1." : ".");
	CloseHandle(Data);
	return;
}

int TopTo(int skeeti)
{
	Handle Data = CreateKeyValues("skeetdata", "", "");
	int count;
	if(g_hCvar1v1Separate.BoolValue && Is1v1)
	{
		if (!FileToKeyValues(Data, datafilepath_1v1))
		{
			return 0;
		}
	}
	else
	{	
		if (!FileToKeyValues(Data, datafilepath))
		{
			return 0;
		}
	}
	KvJumpToKey(Data, "info", false);
	count = KvGetNum(Data, "count", 0);
	int[] skeet = new int[count];
	KvGoBack(Data);
	KvJumpToKey(Data, "data", false);
	KvGotoFirstSubKey(Data, true);
	int total;
	for (int i=0;i < count;++i)
	{
		skeet[i] = KvGetNum(Data, "skeet", 0);
		if (skeet[i] >= skeeti)
		{
			total++;
		}
		KvGotoNextKey(Data, true);
	}
	CloseHandle(Data);
	return total;
}

public int Sort_Function(int[] array1, int[] array2, int[][] completearray, Handle hndl)
{
	if (array1[1] > array2[1])
	{
		return -1;
	}
	if (array1[1] == array2[1])
	{
		return 0;
	}
	return 1;
}

public int TopSkeetPanelHandler(Handle menu, MenuAction action, int param1, int param2)
{
	return 0;
}

bool IsOnLadder(int entity)
{
    return GetEntityMoveType(entity) == MOVETYPE_LADDER;
}