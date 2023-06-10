/* 
* Pounce Announce
*/

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

//globals
ConVar hEnablePlugin;
ConVar hMaxPounceDistance;
ConVar hMinPounceDistance;
ConVar hMaxPounceDamage;
ConVar g_hCvarMPGameMode;
ConVar g_hCvarModesTog;
ConVar g_hCvarSurvivorRequired;
new bool:g_bCvarAllow;
ConVar g_hCvarSurvivorLimit;
//hunter position store
new Float:infectedPosition[MAXPLAYERS+1][3]; //support up to 32 slots on a server
//cvars
ConVar hMinPounceAnnounce;
ConVar hChat;
new ConVar_maxdmg,ConVar_max,ConVar_min;
new String:datafilepath[256];
#define DATA_FILE_NAME "pounce_database.txt"

public Plugin:myinfo = 
{
	name = "Pounce Announce (database)",
	author = "Harry Potter",
	description = "Announces hunter pounces to the entire server, and save record to data/pounce_database.txt",
	version = "1.2-2023/6/11",
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

public OnPluginStart()
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

	HookConVarChange(hMaxPounceDamage, Convar_MaxPounceDamage);
	ConVar_maxdmg = GetConVarInt(hMaxPounceDamage);
	
	if(hMaxPounceDistance != null)
	{
		HookConVarChange(hMaxPounceDistance, Convar_Max);
		ConVar_max = GetConVarInt(hMaxPounceDistance);
	}

	if(hMinPounceDistance != null)
	{
		HookConVarChange(hMinPounceDistance, Convar_Min);
		ConVar_min = GetConVarInt(hMinPounceDistance);
	}

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarSurvivorLimit = FindConVar("survivor_limit");
	HookConVarChange(hEnablePlugin, ConVarChanged_Allow);
	HookConVarChange(g_hCvarMPGameMode, ConVarChanged_Allow);
	HookConVarChange(g_hCvarModesTog, ConVarChanged_Allow);
	HookConVarChange(g_hCvarSurvivorRequired, ConVarChanged_Allow);
	HookConVarChange(g_hCvarSurvivorLimit, ConVarChanged_Allow);

	BuildPath(PathType:0, datafilepath, 256, "data/%s", DATA_FILE_NAME);
	RegConsoleCmd("sm_pounces", Command_Stats, "Show your current pounce statistics and rank.", 0);
	RegConsoleCmd("sm_pounce5", Command_Top, "Show TOP 5 pounce players in statistics.", 0);

	AutoExecConfig(true,"pounce_database");
}

public OnConfigsExecuted()
{
	IsAllowed();
}

IsAllowed()
{
	new bool:bCvarAllow = GetConVarBool(hEnablePlugin);
	new bool:bAllowMode = IsAllowedGameMode();
	new SurvivorsLimit = GetConVarInt(g_hCvarSurvivorLimit);
	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true && SurvivorsLimit>= GetConVarInt(g_hCvarSurvivorRequired))
	{
		g_bCvarAllow = true;
		ConVar_maxdmg = GetConVarInt(hMaxPounceDamage);
		ConVar_max = GetConVarInt(hMaxPounceDistance);
		ConVar_min = GetConVarInt(hMinPounceDistance);
		
		HookEvent("lunge_pounce",Event_PlayerPounced);
		HookEvent("ability_use",Event_AbilityUse);
	}
	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false || SurvivorsLimit < GetConVarInt(g_hCvarSurvivorRequired)) )
	{
		g_bCvarAllow = false;
		UnhookEvent("lunge_pounce",Event_PlayerPounced);
		UnhookEvent("ability_use",Event_AbilityUse);
	}
}


bool:IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == INVALID_HANDLE )
		return false;

	new iCvarModesTog = GetConVarInt(g_hCvarModesTog);
	if( iCvarModesTog == 0) return true;

	decl String:CurrentGameMode[32];
	GetConVarString(g_hCvarMPGameMode, CurrentGameMode, sizeof(CurrentGameMode));
	new g_iCurrentMode = 0;
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

public ConVarChanged_Allow(Handle:convar, const String:oldValue[], const String:newValue[])
{	
	IsAllowed();
}

public OnMapStart()
{
	PrecacheSound("player/damage1.wav", true);
	PrecacheSound("player/damage2.wav", true);
	PrecacheSound("player/neck_snap_01.wav", true);
}

public Action:Command_Stats(client, args)
{
	if(g_bCvarAllow)
	{
		PrintPouncesToClient(client);
		ShowPounceRank(client);
	}
	return Plugin_Continue;
}

public Action:Command_Top(client, args)
{
	if(g_bCvarAllow)
		PrintTopPouncers(client);
	return Plugin_Continue;
}

public Convar_MaxPounceDamage (Handle:convar, const String:oldValue[], const String:newValue[])
{
	new newdmg=StringToInt(newValue);
	if (newdmg<1)
		newdmg=1;
	else if (newdmg>1000)
		newdmg=1000;
	ConVar_maxdmg = newdmg;
	
}
public Convar_Max (Handle:convar, const String:oldValue[], const String:newValue[])
{
	new newmax=StringToInt(newValue);
	if (newmax<1)
		newmax=1;

	ConVar_max = newmax;
	
}
public Convar_Min (Handle:convar, const String:oldValue[], const String:newValue[])
{
	new newmin=StringToInt(newValue);
	if (newmin<1)
		newmin=1;

	ConVar_min = newmin;	
}

public Event_AbilityUse(Handle:event, const String:name[], bool:dontBroadcast)
{
	new user = GetClientOfUserId(GetEventInt(event, "userid"));
	
	//Save the location of the player who just used an infected ability
	GetClientAbsOrigin(user,infectedPosition[user]);

}
public Event_PlayerPounced(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attackerClient = GetClientOfUserId(GetEventInt(event, "userid"));
	new victimClient = GetClientOfUserId(GetEventInt(event, "victim"));
	if(!IsClientInGame(attackerClient) || IsFakeClient(attackerClient) || GetClientTeam(attackerClient) != 3) return;
	if(!IsClientInGame(victimClient) || IsFakeClient(victimClient) || GetClientTeam(victimClient) != 2) return;
	
	new Float:pouncePosition[3];
	new minAnnounce = GetConVarInt(hMinPounceAnnounce);
	
	//get hunter-related pounce cvars
	new max = ConVar_max;
	new min = ConVar_min;
	new maxDmg = ConVar_maxdmg;
	
	//Get current position while pounced
	GetClientAbsOrigin(attackerClient,pouncePosition);
	
	//Calculate 2d distance between previous position and pounce position
	new distance = RoundToNearest(GetVectorDistance(infectedPosition[attackerClient], pouncePosition));
	
	//Get damage using hunter damage formula
	//damage in this is expressed as a float because my server has competitive hunter pouncing where the decimal counts
	new Float:dmg = (((distance - float(min)) / float(max - min)) * float(maxDmg)) + 1;
	
	if(distance >= min && dmg >= minAnnounce)
	{
		Statistic(attackerClient);
		PrintTopPouncers();
		Pounced(attackerClient);
		
		if(GetConVarBool(hChat) == true)
		{
			decl String:pounceLine[256];
			Format(pounceLine,sizeof(pounceLine),"\x01[\x05TS\x01] \x04%N \x01pounced \x05%N \x01for \x03%.01f \x01damage.(Max: %d)",attackerClient,victimClient,dmg,maxDmg + 1);
			PrintToChatAll(pounceLine);	
		}
	}
}

Pounced(client)
{
	CreateTimer(0.1, Award, client, 2);
}

public Action:Award(Handle:timer, any:client)
{
	if (client < any:0 && !IsClientInGame(client))
	{
		return Action:4;
	}
	
	new random = GetRandomInt(1, 3);
	switch(random)
	{
		case 1 : EmitSoundToAll("player/damage1.wav", client, 3, 140, 0, 1.0);
		case 2 : EmitSoundToAll("player/damage2.wav", client, 3, 140, 0, 1.0);
		case 3 : EmitSoundToAll("player/neck_snap_01.wav", client, 3, 140, 0, 1.0);
	}
	return Action:4;
}

Statistic(client)
{
	new String:clientname[32];
	GetClientName(client, clientname, 32);
	ReplaceString(clientname, 32, "'", "", true);
	ReplaceString(clientname, 32, "<", "", true);
	ReplaceString(clientname, 32, "{", "", true);
	ReplaceString(clientname, 32, "}", "", true);
	ReplaceString(clientname, 32, "\n", "", true);
	ReplaceString(clientname, 32, "\"", "", true);
	new String:clientauth[32];
	GetClientAuthId(client, AuthId_Steam2, clientauth, 32);
	Handle Data = CreateKeyValues("pouncedata", "", "");
	new count;
	new pounce;
	FileToKeyValues(Data, datafilepath);
	KvJumpToKey(Data, "data", true);
	if (!KvJumpToKey(Data, clientauth, false))
	{
		KvGoBack(Data);
		KvJumpToKey(Data, "info", true);
		count = KvGetNum(Data, "count", 0);
		KvSetNum(Data, "count", ++count);
		KvGoBack(Data);
		KvJumpToKey(Data, "data", true);
		KvJumpToKey(Data, clientauth, true);
	}
	pounce = KvGetNum(Data, "pounce", 0);
	KvSetNum(Data, "pounce", ++pounce);
	KvSetString(Data, "name", clientname);
	KvRewind(Data);
	KeyValuesToFile(Data, datafilepath);
	delete Data;
	if(GetConVarBool(hChat) == true)
	{
		PrintToChat(client, "\x01[\x04SM\x01] \x03You \x04have \x01%d pounces.", pounce);
	}
}

PrintTopPouncers(client = 0)
{
	Handle Data = CreateKeyValues("pouncedata", "", "");
	new count;
	if (!FileToKeyValues(Data, datafilepath))
	{
		delete Data;
		return;
	}
	KvJumpToKey(Data, "info", false);
	count = KvGetNum(Data, "count", 0);
	new String:names[count][32];
	new pounces[count][2];
	new totalspounces=0;
	KvGoBack(Data);
	KvJumpToKey(Data, "data", false);
	KvGotoFirstSubKey(Data, true);
	for (new i=0;i<count;++i)
	{
		KvGetString(Data, "name", names[i], 32, "Unnamed");
		pounces[i][0] = i;
		pounces[i][1] = KvGetNum(Data, "pounce", 0);
		totalspounces += pounces[i][1];
		KvGotoNextKey(Data, true);
	}
	delete Data;
	SortCustom2D(pounces, count, Sort_Function, Handle:0);
	
	new Handle:Panell = CreatePanel(Handle:0);
	SetPanelTitle(Panell, "Top 5 Pouncers                     ", false);
	DrawPanelText(Panell, "\n ");
	new String:text[256];
	if (totalspounces)
	{
		if (count > 5) count = 5;
		for (new i=0;i<count;++i)
		{
			Format(text, 255, "%d pounces - %s", pounces[i][1], names[pounces[i][0]]);
			DrawPanelItem(Panell, text);
		}
		DrawPanelText(Panell, "\n");
		Format(text, 255, "Total %d pounces on the server.", totalspounces);
		DrawPanelText(Panell, text);
	}
	else
	{
		Format(text, 255, "There are no pounces on this server yet.");
	}
	
	if(client == 0)
	{
		for (new i=1;i<=MaxClients;++i)
		{	
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				SendPanelToClient(Panell, i, TopPouncePanelHandler, 5);
			}
		}
	}
	else
	{
		SendPanelToClient(Panell, client, TopPouncePanelHandler, 5);
	}
	delete Panell;
}

public TopPouncePanelHandler(Handle:menu, MenuAction:action, param1, param2)
{
	return 0;
}

ShowPounceRank(client)
{
	if (!IsDedicatedServer())
	{
		if (!client)
		{
			client = 1;
		}
	}
	Handle Data = CreateKeyValues("pouncedata", "", "");
	new count;
	if (!FileToKeyValues(Data, datafilepath))
	{
		delete Data;
		return;
	}
	KvJumpToKey(Data, "info", false);
	count = KvGetNum(Data, "count", 0);
	KvGoBack(Data);
	KvJumpToKey(Data, "data", false);
	new pounce;
	new String:auth[32];
	GetClientAuthId(client, AuthId_Steam2, auth, 32);
	if (KvJumpToKey(Data, auth, false))
	{
		pounce = KvGetNum(Data, "pounce", 0);
	}
	else
	{
		pounce = 0;
	}
	new place = TopTo(pounce);
	PrintToChat(client, "Pounce Ranking: \x04%d\x01/\x05%d", place, count);
	delete Data;
}

TopTo(pouncei)
{
	Handle Data = CreateKeyValues("pouncedata", "", "");
	new count;
	if (!FileToKeyValues(Data, datafilepath))
	{
		delete Data;
		return 0;
	}
	KvJumpToKey(Data, "info", false);
	count = KvGetNum(Data, "count", 0);
	new pounce[count];
	KvGoBack(Data);
	KvJumpToKey(Data, "data", false);
	KvGotoFirstSubKey(Data, true);
	new totalwin;
	for (new i=0;i < count;++i)
	{
		pounce[i] = KvGetNum(Data, "pounce", 0);
		if (pounce[i] >= pouncei)
		{
			totalwin++;
		}
		KvGotoNextKey(Data, true);
	}
	delete Data;
	return totalwin;
}

PrintPouncesToClient(client)
{
	if (!IsDedicatedServer())
	{
		if (!client)
		{
			client = 1;
		}
	}
	Handle Data = CreateKeyValues("pouncedata", "", "");
	new pounce;
	if (!FileToKeyValues(Data, datafilepath))
	{
		PrintToChat(client, "\x03There is no \x01data yet.");
		delete Data;
		return;
	}
	new String:auth[32];
	GetClientAuthId(client, AuthId_Steam2, auth, 32);
	KvJumpToKey(Data, "data", false);
	KvJumpToKey(Data, auth, false);
	pounce = KvGetNum(Data, "pounce", 0);
	delete Data;
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

public Sort_Function(array1[], array2[], completearray[][], Handle:hndl)
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