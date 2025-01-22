#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <multicolors>
#include <left4dhooks>
#define DEBUG 0

#define Timer_KeepPlayerDeath_Seconds 1.5

//survivor
#define L4D_TEAM_SURVIVOR 2
enum ModelID
{
	MODEL_NONE,
	MODEL_NICK,
	MODEL_ROCHELLE,
	MODEL_COACH,
	MODEL_ELLIS,
	MODEL_BILL,
	MODEL_ZOEY,
	MODEL_FRANCIS,
	MODEL_LOUIS,
	MODEL_MAX
}

//cvars
ConVar hEnable;
bool g_bEnable;

//value
bool bDeath_Model[view_as<int>(MODEL_MAX)];
char sModel_Name[view_as<int>(MODEL_MAX)][PLATFORM_MAX_PATH];			
		
public Plugin myinfo = 
{
	name = "L4D2 death survivor",
	author = "Harry Potter",
	description = "If a player die as a survivor, this model character(Nick/Ellis/Bill/Zoey...) keep death until map change or server shutdown",
	version = "1.3",
	url = "Harry Potter myself, you bitch shit"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{	
	hEnable	= CreateConVar("l4d2_enable_death_survivor", "1", 	"Enable this plugin?[1-Enable,0-Disable]" , FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_bEnable = hEnable.BoolValue;
	HookConVarChange(hEnable, ConVarChange_hEnable);
	
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_bot_replace", Event_OnBotSwap);
	HookEvent("bot_player_replace", Event_OnBotSwap);
	
	SetCharacterName();
	
	AutoExecConfig(true, "l4d2_Death_Survivor");
}

public void OnMapStart()
{
	if(L4D_IsFirstMapInScenario())
	{
		for(ModelID i = MODEL_NICK ; i < MODEL_MAX ; ++i)
		{
			bDeath_Model[i] = false;
		}
	}
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (!IsClientSurvivorIndex(client) ||
		g_bEnable == false)
		return;
		
	char sModelName[PLATFORM_MAX_PATH];
	GetClientModel(client, sModelName, sizeof(sModelName));
	#if DEBUG
		PrintToChatAll("Event_PlayerDeath timer check: %N - sModelName: %s",client,sModelName);
	#endif
	
	ModelID modelId = GetModelID(sModelName);
	bDeath_Model[modelId] = true;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(Timer_KeepPlayerDeath_Seconds,Timer_KeepPlayerDeath, event.GetInt("userid"), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_KeepPlayerDeath(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if(!IsClientSurvivorIndex(client) || g_bEnable == false) return Plugin_Stop;
	
	if(IsPlayerAlive(client))
	{
		char sModelName[PLATFORM_MAX_PATH];
		GetClientModel(client, sModelName, sizeof(sModelName));
		#if DEBUG
			PrintToChatAll("Timer_KeepPlayerDeath: %N - sModelName: %s",client,sModelName);
		#endif
		ModelID modelId = GetModelID(sModelName);
		if(bDeath_Model[modelId] == true)
		{
			ForcePlayerSuicide(client);
			CPrintToChat(client,"[{olive}摸魚{default}] {green}Surprise Dead, Mother Fucker!");
		}
		else
		{
			return Plugin_Stop;
		}
	}
	else
	{
		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action Event_OnBotSwap(Event event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(event.GetInt("bot"));
	int player = GetClientOfUserId(event.GetInt("player"));
	
	if (!IsClientSurvivorIndex(bot)||
		!IsClientSurvivorIndex(player)||
		g_bEnable == false)
		return Plugin_Continue;
		
	int client;
	if (StrEqual(name, "player_bot_replace")) //When a bot replaces a player (i.e. player switches to spectate or infected)
	{
		#if DEBUG
			char sModelName[PLATFORM_MAX_PATH];
			GetClientModel(bot, sModelName, sizeof(sModelName));
			PrintToChatAll("When a bot replaces a player: %N - sModelName: %s",bot,sModelName);
		#endif
		client = bot;
	}
	else // When a player replaces a bot (i.e. player joins survivors team)
	{
		#if DEBUG
			char sModelName[PLATFORM_MAX_PATH];
			GetClientModel(player, sModelName, sizeof(sModelName));
			PrintToChatAll("player joins survivors team: %N - sModelName: %s",player,sModelName);
		#endif
		client = player;
	}
		
	CreateTimer(Timer_KeepPlayerDeath_Seconds,Timer_KeepPlayerDeath, GetClientUserId(client),TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	
	return Plugin_Continue;
}

stock ModelID GetModelID(const char[] model_name)
{
	for(ModelID i = MODEL_NICK ; i < MODEL_MAX ; ++i)
	{
		if(strcmp(model_name,sModel_Name[i],false) == 0)
			return i;
	}
	return MODEL_NONE;
}

bool IsClientSurvivorIndex(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_SURVIVOR);
}

public void ConVarChange_hEnable(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_bEnable = hEnable.BoolValue;
}

void SetCharacterName()
{
	sModel_Name[MODEL_NICK] 	= "models/survivors/survivor_gambler.mdl";
	sModel_Name[MODEL_ROCHELLE] = "models/survivors/survivor_producer.mdl";
	sModel_Name[MODEL_COACH] 	= "models/survivors/survivor_coach.mdl";
	sModel_Name[MODEL_ELLIS] 	= "models/survivors/survivor_mechanic.mdl";
	sModel_Name[MODEL_BILL] 	= "models/survivors/survivor_namvet.mdl";
	sModel_Name[MODEL_ZOEY] 	= "models/survivors/survivor_teenangst.mdl";
	sModel_Name[MODEL_FRANCIS] 	= "models/survivors/survivor_biker.mdl";
	sModel_Name[MODEL_LOUIS] 	= "models/survivors/survivor_manager.mdl";
	
	for(ModelID i = MODEL_NICK ; i < MODEL_MAX ; ++i)
	{
		bDeath_Model[i] = false;
	}
}
