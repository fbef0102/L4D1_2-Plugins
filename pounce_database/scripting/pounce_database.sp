#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

enum struct CPlayerPounceData
{
	char m_sName[64];
	int m_iPounces;

	int m_iPosition;
}

#define TOP_NUMBER 5

//globals
ConVar hEnablePlugin;
ConVar hMaxPounceDistance;
ConVar hMinPounceDistance;
ConVar hMaxPounceDamage;
ConVar g_hCvarMPGameMode;
ConVar g_hCvarModesTog;
ConVar g_hCvarSurvivorRequired;
bool g_bCvarAllow;
ConVar g_hCvarSurvivorLimit;
//hunter position store
float infectedPosition[MAXPLAYERS+1][3]; //support up to 32 slots on a server
//cvars
ConVar hMinPounceAnnounce;
ConVar hChat;
int ConVar_maxdmg,ConVar_max,ConVar_min;
char datafilepath[256];
#define DATA_FILE_NAME "pounce_database.txt"

KeyValues g_hData;

public Plugin myinfo = 
{
	name = "Top Pounce Announce (Data Support)",
	author = "Harry Potter",
	description = "Announces hunter pounces to the entire server, and save record to data/pounce_database.txt",
	version = "1.3-2023/6/12",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

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
	hMaxPounceDistance = FindConVar("z_pounce_damage_range_max");
	hMinPounceDistance = FindConVar("z_pounce_damage_range_min");
	hMaxPounceDamage = FindConVar("z_hunter_max_pounce_bonus_damage");

	if(hMaxPounceDistance == null) hMaxPounceDistance = CreateConVar("z_pounce_damage_range_max", "1000.0", "Not available on this server, added by pounce_database.", FCVAR_NOTIFY, true, 0.0, false );
	if(hMinPounceDistance == null) hMinPounceDistance = CreateConVar("z_pounce_damage_range_min", "300.0", "Not available on this server, added by pounce_database.", FCVAR_NOTIFY, true, 0.0, false );
	if(hMaxPounceDamage == null) hMaxPounceDamage = CreateConVar( "z_hunter_max_pounce_bonus_damage",  "49", "Not available on this server, added by pounce_database.", FCVAR_NOTIFY, true, 0.0, false );

	hEnablePlugin = CreateConVar("pounce_database_enable", "1", "Enable this plugin?", 262144, false, 0.0, false, 0.0);
	hMinPounceAnnounce = CreateConVar("pounce_database_minimum","25","The minimum amount of damage required to record the pounce", FCVAR_SPONLY|FCVAR_NOTIFY);
	hChat = CreateConVar("pounce_database_announce","0","Announces the pounce in chatbox.", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_hCvarModesTog =	CreateConVar("pounce_database_modes_tog",		"4",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus. Add numbers together.", FCVAR_SPONLY|FCVAR_NOTIFY );
	g_hCvarSurvivorRequired =	CreateConVar("pounce_database_survivors_required",		"4",			"Numbers of Survivors required at least to enable this plugin", FCVAR_SPONLY|FCVAR_NOTIFY );

	hMaxPounceDamage.AddChangeHook(Convar_MaxPounceDamage);
	ConVar_maxdmg = hMaxPounceDamage.IntValue;
	
	if(hMaxPounceDistance != null)
	{
		hMaxPounceDistance.AddChangeHook(Convar_Max);
		ConVar_max = hMaxPounceDistance.IntValue;
	}

	if(hMinPounceDistance != null)
	{
		hMinPounceDistance.AddChangeHook(Convar_Min);
		ConVar_min = hMinPounceDistance.IntValue;
	}

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarSurvivorLimit = FindConVar("survivor_limit");
	hEnablePlugin.AddChangeHook(ConVarChanged_Allow);
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarSurvivorRequired.AddChangeHook(ConVarChanged_Allow);
	g_hCvarSurvivorLimit.AddChangeHook(ConVarChanged_Allow);

	BuildPath(Path_SM, datafilepath, 256, "data/%s", DATA_FILE_NAME);
	RegConsoleCmd("sm_pounces", Command_Stats, "Show your current pounce statistics and rank.", 0);
	RegConsoleCmd("sm_pounce5", Command_Top, "Show TOP 5 pounce players in statistics.", 0);

	AutoExecConfig(true,"pounce_database");
}

public void OnPluginEnd()
{
	delete g_hData;
}

public void OnConfigsExecuted()
{
	IsAllowed();

	delete g_hData;
	g_hData = new KeyValues("pouncedata");
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

void IsAllowed()
{
	bool bCvarAllow = hEnablePlugin.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	int SurvivorsLimit = g_hCvarSurvivorLimit.IntValue;
	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true && SurvivorsLimit>= g_hCvarSurvivorRequired.IntValue)
	{
		g_bCvarAllow = true;
		ConVar_maxdmg = hMaxPounceDamage.IntValue;
		ConVar_max = hMaxPounceDistance.IntValue;
		ConVar_min = hMinPounceDistance.IntValue;
		
		HookEvent("lunge_pounce",Event_PlayerPounced);
		HookEvent("ability_use",Event_AbilityUse);
	}
	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false || SurvivorsLimit < g_hCvarSurvivorRequired.IntValue) )
	{
		g_bCvarAllow = false;
		UnhookEvent("lunge_pounce",Event_PlayerPounced);
		UnhookEvent("ability_use",Event_AbilityUse);
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

public void OnMapStart()
{
	PrecacheSound("player/damage1.wav", true);
	PrecacheSound("player/damage2.wav", true);
	PrecacheSound("player/neck_snap_01.wav", true);
}

public void OnMapEnd()
{
    delete g_hData;
}

Action Command_Stats(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	if(!g_bCvarAllow) return Plugin_Handled;

	PrintPouncesToClient(client);
	ShowPounceRank(client);
	
	return Plugin_Handled;
}

Action Command_Top(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	if(!g_bCvarAllow) return Plugin_Handled;

	PrintTopPouncers(client);
	
	return Plugin_Handled;
}

void Convar_MaxPounceDamage (ConVar convar, const char[] oldValue, const char[] newValue)
{
	int newdmg=StringToInt(newValue);
	if (newdmg<1)
		newdmg=1;
	else if (newdmg>1000)
		newdmg=1000;
	ConVar_maxdmg = newdmg;
	
}
void Convar_Max (ConVar convar, const char[] oldValue, const char[] newValue)
{
	int newmax=StringToInt(newValue);
	if (newmax<1)
		newmax=1;

	ConVar_max = newmax;
	
}
void Convar_Min (ConVar convar, const char[] oldValue, const char[] newValue)
{
	int newmin=StringToInt(newValue);
	if (newmin<1)
		newmin=1;

	ConVar_min = newmin;	
}

void Event_AbilityUse(Event event, const char[] name, bool dontBroadcast) 
{
	int user = GetClientOfUserId(GetEventInt(event, "userid"));
	
	//Save the location of the player who just used an infected ability
	GetClientAbsOrigin(user,infectedPosition[user]);

}

void Event_PlayerPounced(Event event, const char[] name, bool dontBroadcast) 
{
	int attackerClient = GetClientOfUserId(GetEventInt(event, "userid"));
	int victimClient = GetClientOfUserId(GetEventInt(event, "victim"));
	if(!IsClientInGame(attackerClient) || IsFakeClient(attackerClient) || GetClientTeam(attackerClient) != 3) return;
	if(!IsClientInGame(victimClient) || IsFakeClient(victimClient) || GetClientTeam(victimClient) != 2) return;
	
	float pouncePosition[3];
	int minAnnounce = hMinPounceAnnounce.IntValue;
	
	//get hunter-related pounce cvars
	int max = ConVar_max;
	int min = ConVar_min;
	int maxDmg = ConVar_maxdmg;
	
	//Get current position while pounced
	GetClientAbsOrigin(attackerClient,pouncePosition);
	
	//Calculate 2d distance between previous position and pounce position
	int distance = RoundToNearest(GetVectorDistance(infectedPosition[attackerClient], pouncePosition));
	
	//Get damage using hunter damage formula
	//damage in this is expressed as a float because my server has competitive hunter pouncing where the decimal counts
	float dmg = (((distance - float(min)) / float(max - min)) * float(maxDmg)) + 1;
	
	if(distance >= min && dmg >= minAnnounce)
	{
		CreateTimer(0.0, Timer_Statistic, GetClientUserId(attackerClient), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(0.1, Timer_PrintTopPouncers, 0, TIMER_FLAG_NO_MAPCHANGE);
								
		Pounced(attackerClient);
		
		if(hChat.BoolValue)
		{
			char pounceLine[256];
			Format(pounceLine,sizeof(pounceLine),"\x01[\x05TS\x01] \x04%N \x01pounced \x05%N \x01for \x03%.01f \x01damage.(Max: %d)",attackerClient,victimClient,dmg,maxDmg + 1);
			PrintToChatAll(pounceLine);	
		}
	}
}

void Pounced(int client)
{
	CreateTimer(0.1, Award, client, 2);
}

Action Award(Handle timer, int client)
{
	if (client <= 0 && !IsClientInGame(client))
	{
		return Plugin_Continue;
	}
	
	int random = GetRandomInt(1, 3);
	switch(random)
	{
		case 1 : EmitSoundToAll("player/damage1.wav", client, 3, 140, 0, 1.0);
		case 2 : EmitSoundToAll("player/damage2.wav", client, 3, 140, 0, 1.0);
		case 3 : EmitSoundToAll("player/neck_snap_01.wav", client, 3, 140, 0, 1.0);
	}

	return Plugin_Continue;
}

Action Timer_PrintTopPouncers(Handle timer, int attacker)
{
	PrintTopPouncers(0);
	return Plugin_Continue;
}

void PrintTopPouncers(int client = 0)
{
	if(g_hData == null) return;
	g_hData.Rewind();

	g_hData.JumpToKey("info", false);
	int count = g_hData.GetNum("count", 0);

	CPlayerPounceData CTopPlayer[TOP_NUMBER];
	int totalspounces=0, Max_pounces, iPounces, Max_index;
	bool bIgnore;
	g_hData.GoBack();
	g_hData.JumpToKey("data", false);
	
	for(int current = 0; current < TOP_NUMBER; current++)
	{
		g_hData.GotoFirstSubKey(true);

		Max_pounces = 0;
		Max_index = 0;
		for (int index=1; index <= count ;++index, g_hData.GotoNextKey(true))
		{
			iPounces = g_hData.GetNum("pounce", 0);
			if(iPounces <= 0) continue;

			if(current == 0)
			{
				totalspounces += iPounces;
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
						if(current-1==previous) g_hData.GetString("name", CTopPlayer[previous].m_sName, sizeof(CPlayerPounceData::m_sName), "Unnamed");
						bIgnore = true;
						break;
					}
				}
				if(bIgnore) continue;
			}
			
			if(iPounces > Max_pounces)
			{
				//PrintToChatAll("iPounces: %d, Max_pounces: %d, index: %d", iPounces, Max_pounces, index);
				Max_pounces 	= iPounces;
				Max_index 		= index;
			}
		}
		//PrintToChatAll("Max_pounces: %d, Max_index: %d", Max_pounces, Max_index);
		CTopPlayer[current].m_iPounces 		= Max_pounces;
		CTopPlayer[current].m_iPosition 	= Max_index;
		g_hData.GoBack();
	}
	g_hData.GotoFirstSubKey(true);
	for (int index=1; index <= count ;++index, g_hData.GotoNextKey(true))
	{
		if(index == CTopPlayer[TOP_NUMBER-1].m_iPosition)
		{
			g_hData.GetString("name", CTopPlayer[TOP_NUMBER-1].m_sName, sizeof(CPlayerPounceData::m_sName), "Unnamed");
			break;
		}
	}
	
	Panel panel = new Panel();
	static char sBuffer[128];
	FormatEx(sBuffer, sizeof(sBuffer), "Top %d Pouncers", TOP_NUMBER);
	panel.SetTitle(sBuffer);
	panel.DrawText("\n ");
	if (totalspounces)
	{
		for (int i=0 ; i<TOP_NUMBER && i < count;++i)
		{
			FormatEx(sBuffer, sizeof(sBuffer), "%d pounces - %s", CTopPlayer[i].m_iPounces, CTopPlayer[i].m_sName);
			panel.DrawItem(sBuffer);
		}
		panel.DrawText("\n ");
		FormatEx(sBuffer, sizeof(sBuffer), "Total %d pounces on the server.", totalspounces);
		panel.DrawText(sBuffer);
	}
	else
	{
		FormatEx(sBuffer, sizeof(sBuffer), "There are no pounces on this server yet.");
	}
	
	if(client == 0)
	{
		for (int player = 1; player<=MaxClients; ++player)
		{	
			if (IsClientInGame(player) && !IsFakeClient(player))
			{
				panel.Send(player, TopPouncePanelHandler, 5);
			}
		}
	}
	else
	{
		panel.Send(client, TopPouncePanelHandler, 5);
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
		int pounce = g_hData.GetNum("pounce", 0);
		pounce++;
		g_hData.SetNum("pounce", pounce);
		g_hData.SetString("name", clientname);
		g_hData.Rewind();

		g_hData.ExportToFile(datafilepath);
		if(hChat.BoolValue)
		{
			PrintToChat(attacker, "\x01[\x04SM\x01] \x03You \x04have \x01%d pounces.", pounce);
		}
	}

	return Plugin_Continue;
}

int TopPouncePanelHandler(Handle menu, MenuAction action, int param1, int param2)
{
	return 0;
}

void ShowPounceRank(int client)
{
	if(g_hData == null) return;
	g_hData.Rewind();

	g_hData.JumpToKey("info", false);
	int count = g_hData.GetNum("count", 0);
	g_hData.GoBack();
	g_hData.JumpToKey("data", false);
	int pounce;
	char auth[32];
	GetClientAuthId(client, AuthId_Steam2, auth, 32);
	if (g_hData.JumpToKey(auth, false))
	{
		pounce = g_hData.GetNum("pounce", 0);
	}
	else
	{
		pounce = 0;
	}
	int rank = TopTo(pounce);
	PrintToChat(client, "Pounce Ranking: \x04%d\x01/\x05%d", rank, count);
	delete g_hData;
}

int TopTo(int pouncei)
{
	if(g_hData == null) return 0;
	g_hData.Rewind();
	
	g_hData.JumpToKey("info", false);
	int count = g_hData.GetNum("count", 0);
	int pounce;
	g_hData.GoBack();
	g_hData.JumpToKey("data", false);
	g_hData.GotoFirstSubKey(true);
	int total;
	for (int i=0;i < count;++i)
	{
		pounce = g_hData.GetNum("pounce", 0);
		if (pounce >= pouncei)
		{
			total++;
		}
		g_hData.GotoNextKey(true);
	}
	return total;
}

void PrintPouncesToClient(int client)
{
	if(g_hData == null) return;
	g_hData.Rewind();

	char auth[32];
	GetClientAuthId(client, AuthId_Steam2, auth, 32);
	g_hData.JumpToKey("data", false);
	g_hData.JumpToKey(auth, false);
	int pounce = g_hData.GetNum("pounce", 0);
	delete g_hData;
	if (pounce == 1)
	{
		PrintToChat(client, "\x04You \x03only \x01have 1 pounce.");
	}
	else if (pounce <= 0)
	{
		PrintToChat(client, "\x03You \x01don't have pounces.");
	}
	else
	{
		PrintToChat(client, "\x04You \x03have \x01%d pounces.", pounce);
	}
}