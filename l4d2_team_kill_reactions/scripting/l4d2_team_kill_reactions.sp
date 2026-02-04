/* Includes */
#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sceneprocessor> // https://forums.alliedmods.net/showpost.php?p=2766130&postcount=59
#include <sdktools_functions>
#include <sdkhooks>
#define PLUGIN_VERSION "1.0h-2026/2/4"

/* Plugin Information */ 
public Plugin myinfo = { 
	name        = "[L4D2] Team Kill Reactions", 
	author        = "DeathChaos25 & HarryPotter", 
	description    = "Implements unused TeamKillAccident reaction lines for all 8 survivors",
	url        = "https://forums.alliedmods.net/showthread.php?t=259791" 
}

/* Globals */ 

static char MODEL_NICK[] 		= "models/survivors/survivor_gambler.mdl";
static char MODEL_ROCHELLE[] 		= "models/survivors/survivor_producer.mdl";
static char MODEL_COACH[] 		= "models/survivors/survivor_coach.mdl";
static char MODEL_ELLIS[] 		= "models/survivors/survivor_mechanic.mdl";
static char MODEL_BILL[] 		= "models/survivors/survivor_namvet.mdl";
static char MODEL_ZOEY[] 		= "models/survivors/survivor_teenangst.mdl";
static char MODEL_FRANCIS[] 		= "models/survivors/survivor_biker.mdl";
static char MODEL_LOUIS[] 		= "models/survivors/survivor_manager.mdl";

/* Plugin Functions */ 
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
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_incapacitated", Event_PlayerIncap);
	CreateConVar("l4d2_teamkill_voc_version", PLUGIN_VERSION, "Current Version of Team Kill Vocalizations", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
}

public void OnMapStart()
{
	CheckModelPreCache(MODEL_NICK);
	CheckModelPreCache(MODEL_ROCHELLE);
	CheckModelPreCache(MODEL_COACH);
	CheckModelPreCache(MODEL_ELLIS);
	CheckModelPreCache(MODEL_BILL);
	CheckModelPreCache(MODEL_ZOEY);
	CheckModelPreCache(MODEL_FRANCIS);
	CheckModelPreCache(MODEL_LOUIS);
}

void Event_PlayerIncap(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if(!IsSurvivor(victim) || !IsSurvivor(attacker) || attacker == victim || GetClientTeam(attacker) != GetClientTeam(victim)) 
	{
		return;
	}

	DataPack pack;
	CreateDataTimer(1.5, ReactionDelayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(attacker));
	WritePackCell(pack, GetClientUserId(victim));

	DataPack pack2;
	CreateDataTimer(5.5, SwearDelayTimer, pack2, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack2, GetClientUserId(victim));
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if(!IsSurvivor(victim) || !IsSurvivor(attacker) || victim == attacker || GetClientTeam(attacker) != GetClientTeam(victim)) 
	{
		return;
	}

	DataPack pack;
	CreateDataTimer(2.5, ReactionDelayTimer, pack, TIMER_FLAG_NO_MAPCHANGE);
	WritePackCell(pack, GetClientUserId(attacker));
	WritePackCell(pack, GetClientUserId(victim));
}

Action ReactionDelayTimer(Handle timer, Handle pack) 
{
	ResetPack(pack);
	int attacker = GetClientOfUserId(ReadPackCell(pack));
	int victim = GetClientOfUserId(ReadPackCell(pack));
	if (victim == 0 || attacker == 0)
	{
		return Plugin_Stop;
	}

	int reactor = my_GetRandomSurvivor(attacker, victim);
	ReactToTeamKill(reactor);
	PerformSceneEx(attacker, "PlayerSorry", _, 2.0);
	return Plugin_Stop;
}

Action SwearDelayTimer(Handle timer, Handle pack) 
{
	ResetPack(pack);
	int victim = GetClientOfUserId(ReadPackCell(pack));
	if (victim == 0 || !IsSurvivor(victim) || IsActorBusy(victim))
	{
		return Plugin_Stop;
	}
	PerformSceneEx(victim, "PlayerNegative");
	return Plugin_Stop;
}

void ReactToTeamKill(int client)
{
	if (!IsSurvivor(client) || !IsPlayerAlive(client))
	{
		return;
	}
	char model[PLATFORM_MAX_PATH] = "";
	char s_Vocalize[PLATFORM_MAX_PATH] = "";
	int i_Rand;
	GetClientModel(client, model, sizeof(model));
	
	if (StrEqual(model, MODEL_COACH)) {
		i_Rand = GetRandomInt(1, 8);
		Format(s_Vocalize, sizeof(s_Vocalize),"scenes/coach/teamkillaccident0%i.vcd", i_Rand);
		PerformSceneEx(client, "", s_Vocalize);
	}
	else if (StrEqual(model, MODEL_ELLIS)) {
		i_Rand = GetRandomInt(1, 5);
		Format(s_Vocalize, sizeof(s_Vocalize),"scenes/mechanic/teamkillaccident0%i.vcd", i_Rand);
		PerformSceneEx(client, "", s_Vocalize);
	}
	
	else if (StrEqual(model, MODEL_NICK)) {
		i_Rand = GetRandomInt(1, 3);
		Format(s_Vocalize, sizeof(s_Vocalize),"scenes/gambler/teamkillaccident0%i.vcd", i_Rand);
		PerformSceneEx(client, "", s_Vocalize);
	}
	else if (StrEqual(model, MODEL_ROCHELLE)) {
		i_Rand = GetRandomInt(1, 4);
		Format(s_Vocalize, sizeof(s_Vocalize),"scenes/producer/teamkillaccident0%i.vcd", i_Rand);
		PerformSceneEx(client, "", s_Vocalize);
	}
	else if (StrEqual(model, MODEL_FRANCIS)) {
		i_Rand = GetRandomInt(1, 6);
		Format(s_Vocalize, sizeof(s_Vocalize),"scenes/biker/teamkillaccident0%i.vcd", i_Rand);
		PerformSceneEx(client, "", s_Vocalize);
	}
	else if (StrEqual(model, MODEL_BILL)) {
		i_Rand = GetRandomInt(1, 4);
		Format(s_Vocalize, sizeof(s_Vocalize),"scenes/namvet/teamkillaccident0%i.vcd", i_Rand);
		PerformSceneEx(client, "", s_Vocalize);
	}	
	else if (StrEqual(model, MODEL_LOUIS)) {
		i_Rand = GetRandomInt(1, 4);
		Format(s_Vocalize, sizeof(s_Vocalize),"scenes/manager/teamkillaccident0%i.vcd", i_Rand);
		PerformSceneEx(client, "", s_Vocalize);
	}
	else if (StrEqual(model, MODEL_ZOEY)) {
		i_Rand = GetRandomInt(3, 8);
		if (i_Rand == 4)
		{
			i_Rand = 3;
		}
		else if (i_Rand == 7)
		{
			i_Rand = 6;
		}
		
		Format(s_Vocalize, sizeof(s_Vocalize),"scenes/teengirl/teamkillaccident0%i.vcd", i_Rand);
		PerformSceneEx(client, "", s_Vocalize);
	}
}
void CheckModelPreCache(const char[] Modelfile)
{
	if (!IsModelPrecached(Modelfile))
	{
		PrecacheModel(Modelfile, true);
		PrintToServer("Precaching Model:%s",Modelfile);
	}
}
bool IsSurvivor(int client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		return true;
	}
	return false;
}

int my_GetRandomSurvivor(int attacker, int victim)
{
	int[] clients = new int[MaxClients+1];
	int clientCount;
	
	for(int i = 1; i <= MaxClients; i++)
		if(i != attacker && i != victim && IsSurvivor(i) && IsPlayerAlive(i) && !IsActorBusy(i) )
			clients[clientCount++] = i;
		
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}
