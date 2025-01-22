#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define HUNTER       3
#define MAX_HUNTERSOUND         6
#define IS_VALID_CLIENT(%1)     (%1 > 0 && %1 <= MaxClients)
#define IS_INFECTED(%1)         (GetClientTeam(%1) == 3)
#define IS_VALID_INGAME(%1)     (IS_VALID_CLIENT(%1) && IsClientInGame(%1))
#define IS_VALID_INFECTED(%1)   (IS_VALID_INGAME(%1) && IS_INFECTED(%1))
#define DEBUG 0
#define HUNTERCROUCHTRACKING_TIMER 1.8

static char sHunterSound[MAX_HUNTERSOUND + 1][] =
{
  	"player/hunter/voice/idle/hunter_stalk_01.wav",
	"player/hunter/voice/idle/hunter_stalk_04.wav",
	"player/hunter/voice/idle/hunter_stalk_05.wav",
	"player/hunter/voice/idle/hunter_stalk_06.wav",
	"player/hunter/voice/idle/hunter_stalk_07.wav",
	"player/hunter/voice/idle/hunter_stalk_08.wav",
	"player/hunter/voice/idle/hunter_stalk_09.wav"
};

bool isHunter[MAXPLAYERS+1];
static int g_iOffsetFallVelocity					= -1;
static char CLASSNAME_TERRORPLAYER[] 				= "CTerrorPlayer";
static char NETPROP_FALLVELOCITY[]					= "m_flFallVelocity";

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

public Plugin myinfo = 
{
    name = "Hunter Crouch Sounds",
    author = "Harry",
    description = "Forces silent but crouched hunters to emitt sounds",
    version = "1.5-2023/7/27",
    url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public void OnPluginStart()
{
   HookEvent("player_spawn",Event_PlayerSpawn,              EventHookMode_Post);
   HookEvent("player_death", Event_PlayerDeath);
   HookEvent("round_start", event_RoundStart);
   g_iOffsetFallVelocity = FindSendPropInfo(CLASSNAME_TERRORPLAYER, NETPROP_FALLVELOCITY);
   if (g_iOffsetFallVelocity <= 0) ThrowError("Unable to find fall velocity offset!");
}

public void OnMapStart()
{
    for (int i = 0; i <= MAX_HUNTERSOUND; i++)
    {
        PrefetchSound(sHunterSound[i]);
        PrecacheSound(sHunterSound[i], true);
    }
}


void event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	int i;
	for(i=0;i<=MAXPLAYERS;++i)
	{
		isHunter[i] = false;
	}
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if ( !IS_VALID_INFECTED(client) ) { return; }
    
    int zClass = GetEntProp(client, Prop_Send, "m_zombieClass");
    if (zClass == HUNTER)
	{
		isHunter[client] = true;
		CreateTimer(HUNTERCROUCHTRACKING_TIMER, HunterCrouchTracking, client, TIMER_REPEAT);
	}
}

Action HunterCrouchTracking(Handle timer, any client) 
{
	if (!isHunter[client]) {return Plugin_Stop;}

	if ( !IsClientAndInGame(client) || GetClientTeam(client) != 3 || GetEntProp(client, Prop_Send, "m_zombieClass") != HUNTER || !IsPlayerAlive(client))
	{
		isHunter[client] = false;
		return Plugin_Stop;
	}
	
	if (HasTarget(client))
	{
		return Plugin_Continue;
	}
	
	if (GetClientButtons(client) & IN_DUCK){ return Plugin_Continue; }
	int ducked = GetEntProp(client, Prop_Send, "m_bDucked");
	if (ducked && GetEntDataFloat(client, g_iOffsetFallVelocity) == 0.0)
	{
		#if DEBUG
			PrintToChatAll("0.2s later check again");
		#endif
		CreateTimer(0.2, HunterCrouchReallyCheck, client, _);
	}

	return Plugin_Continue;
}

Action HunterCrouchReallyCheck(Handle timer, any client) 
{
	if ( !IsClientAndInGame(client) || GetClientTeam(client) != 3 || GetEntProp(client, Prop_Send, "m_zombieClass") != HUNTER || !IsPlayerAlive(client))
	{
		return Plugin_Continue;
	}
	if (GetClientButtons(client) & IN_DUCK){ return Plugin_Continue; }
	int ducked = GetEntProp(client, Prop_Send, "m_bDucked");
	if (ducked && GetEntDataFloat(client, g_iOffsetFallVelocity) == 0.0)
	{
		int rndPick = GetRandomInt(0, MAX_HUNTERSOUND);
		EmitSoundToAll(sHunterSound[rndPick], client, SNDCHAN_VOICE);
		#if DEBUG
			PrintToChatAll("Spawn Sound");
		#endif
	}
	return Plugin_Continue;
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)  
{
	int victim = GetEventInt(event, "userid");
	int client = GetClientOfUserId(victim);
	isHunter[client] = false;
}

bool HasTarget(int hunter)
{
	int hasvictim = GetEntPropEnt(hunter, Prop_Send, "m_pounceVictim");
	if(IsSurvivors(hasvictim)) //已經撲人
	{
		return true;
	}
	return false;
}

bool IsSurvivors(int client)
{
	return IsClientAndInGame(client) && GetClientTeam(client) == 2;
}

bool IsClientAndInGame(int index)
{
	return IsClient(index) && IsClientInGame(index);
}

bool IsClient(int index)
{
	return index > 0 && index <= MaxClients;
}
