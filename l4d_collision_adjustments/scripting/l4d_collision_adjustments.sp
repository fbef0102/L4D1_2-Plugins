#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <left4dhooks>
#include <collisionhook>

#define CLASSNAME_LENGTH 64
#define L4D_TEAM_SPEC 1 
#define L4D_TEAM_SUR 2
#define L4D_TEAM_INF 3

#define ZC_HUNTER		3

ConVar g_hCvarRockFix, g_hCvarPullThrough, g_hCvarRockThroughIncap ,g_hCvarCommonThroughWitch, g_hCvarHunterThroughInacp, g_hCvarSIThroughWitch;
bool g_bCvarRockFix,g_bCvarPullThrough,g_bCvarRockThroughIncap,g_bCvarCommonThroughWitch, g_bCvarHunterThroughInacp, g_bCvarSIThroughWitch;
bool g_bPulled[MAXPLAYERS + 1] = {false};
char sEntityCNameOne[20];
char sEntityCNameTwo[20];
float g_fPouncingStartTime[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = "[L4D1/L4D2] Collision Adjustments",
	author = "Sir, Harry Potter",
	description = "No collisions to fix a handful of silly collision bugs in l4d",
	version = "1.0h-2025/7/25",
	url = "http://steamcommunity.com/profiles/76561198026784913"
}

bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test == Engine_Left4Dead )
    {
        g_bL4D2Version = false;
    }
    else if( test == Engine_Left4Dead2 )
    {
        g_bL4D2Version = true;
    }
    else
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

public void OnPluginStart()
{
	g_hCvarRockFix 					= CreateConVar("l4d_collision_adjustments_tankrock_common", "1", "If 1, Rocks can go through Common Infected (and also kill them) instead of possibly getting stuck on them", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarPullThrough 				= CreateConVar("l4d_collision_adjustments_smoker_common", 	"1", "If 1, Pulled Survivors can go through Common Infected", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarRockThroughIncap 		= CreateConVar("l4d_collision_adjustments_tankrock_incap", 	"1", "If 1, Rocks can go through Incapacitated Survivors? (Won't go through new incaps caused by the Rock)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	if(!g_bL4D2Version)
	{
		g_hCvarCommonThroughWitch 	= CreateConVar("l4d_collision_adjustments_common_witch", 	"1", "(L4D1) If 1, Commons can go through Witch (Prevent commons from pushing witch in l4d1)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	}
	g_hCvarHunterThroughInacp 		= CreateConVar("l4d_collision_adjustments_hunter_incap", 	"1", "If 1, Hunter can go through incapacitated survivor (Prevent hunter stuck inside incapacitated survivor, still can pounce them)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarSIThroughWitch 			= CreateConVar("l4d_collision_adjustments_si_witch", 		"1", "If 1, Special infected and Tank can go through witch (Prevent stuck and stagger)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig(true,            "l4d_collision_adjustments");

	GetCvars();
	g_hCvarRockFix.AddChangeHook(ConVarChanged);
	g_hCvarPullThrough.AddChangeHook(ConVarChanged);
	g_hCvarRockThroughIncap.AddChangeHook(ConVarChanged);
	if(!g_bL4D2Version) g_hCvarCommonThroughWitch.AddChangeHook(ConVarChanged);
	g_hCvarHunterThroughInacp.AddChangeHook(ConVarChanged);
	g_hCvarSIThroughWitch.AddChangeHook(ConVarChanged);
	
	HookEvent("tongue_grab", Event_SurvivorPulled);
	HookEvent("tongue_release", Event_PullEnd);
	HookEvent("round_start", event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_bot_replace", OnBotSwap);
	HookEvent("bot_player_replace", OnBotSwap);
	HookEvent("ability_use", Event_AbilityUse);
	HookEvent("player_spawn", Event_PlayerSpawn);
}

public Action CH_PassFilter(int ent1, int ent2, bool &result)
{
	if (ent1 > 0 && ent1 < MaxClients && IsClientInGame(ent1) && IsPlayerAlive(ent1) 
		&& ent2 > 0 && ent2 < MaxClients && IsClientInGame(ent2) && IsPlayerAlive(ent2) )
	{
		if(g_bCvarHunterThroughInacp && GetClientTeam(ent1) == L4D_TEAM_SUR && L4D_IsPlayerIncapacitated(ent1))
		{
			if(GetClientTeam(ent2) == L4D_TEAM_INF && GetZombieClass(ent2) == ZC_HUNTER && IsStartToPounce(ent2))
			{
				result = false;
				return Plugin_Handled;
			}
		}
		else if(g_bCvarHunterThroughInacp && GetClientTeam(ent2) == L4D_TEAM_SUR && L4D_IsPlayerIncapacitated(ent2))
		{
			if(GetClientTeam(ent1) == L4D_TEAM_INF && GetZombieClass(ent1) == ZC_HUNTER && IsStartToPounce(ent1))
			{
				result = false;
				return Plugin_Handled;
			}
		}
	}

	if (ent1 > MaxClients && IsValidEntity(ent1) 
		&& ent2 > MaxClients && IsValidEntity(ent2) )
	{
		GetEntityClassname(ent1, sEntityCNameOne, 20);
		GetEntityClassname(ent2, sEntityCNameTwo, 20);

		if (StrEqual(sEntityCNameOne, "infected"))
		{
			if (g_bCvarRockFix && StrEqual(sEntityCNameTwo, "tank_rock"))
			{
				result = false;
				return Plugin_Handled;
			}

			if (g_bCvarPullThrough && IsSurvivor(ent2) && g_bPulled[ent2])
			{
				result = false;
				return Plugin_Handled;			
			}
			if (!g_bL4D2Version && g_bCvarCommonThroughWitch && StrEqual(sEntityCNameTwo, "witch"))
			{
				result = false;
				return Plugin_Handled;			
			}
		}
		else if (StrEqual(sEntityCNameTwo, "infected"))
		{
			if (g_bCvarRockFix && StrEqual(sEntityCNameOne, "tank_rock"))
			{
				result = false;
				return Plugin_Handled;
			}

			if (g_bCvarPullThrough && IsSurvivor(ent1) && g_bPulled[ent1])
			{
				result = false;
				return Plugin_Handled;			
			}
			if (!g_bL4D2Version && g_bCvarCommonThroughWitch && StrEqual(sEntityCNameOne, "witch"))
			{
				result = false;
				return Plugin_Handled;			
			}
		}
		else if (StrEqual(sEntityCNameOne, "tank_rock"))
		{
			if (g_bCvarRockThroughIncap && IsSurvivor(ent2) && IsIncapacitatedOrHangingFromLedge(ent2))
			{
				result = false;
				return Plugin_Handled;
			}
		}
		else if (StrEqual(sEntityCNameTwo, "tank_rock"))
		{
			if (g_bCvarRockThroughIncap && IsSurvivor(ent1) && IsIncapacitatedOrHangingFromLedge(ent1))
			{
				result = false;
				return Plugin_Handled;
			}		
		}
		else if (StrEqual(sEntityCNameOne, "witch"))
		{
			if (g_bCvarSIThroughWitch && IsInfected(ent2))
			{
				result = false;
				return Plugin_Handled;
			}		
		}
		else if (StrEqual(sEntityCNameTwo, "witch"))
		{
			if (g_bCvarSIThroughWitch && IsInfected(ent1))
			{
				result = false;
				return Plugin_Handled;
			}		
		}
	}

	return Plugin_Continue;
}

// hunters pouncing / tracking
void Event_AbilityUse(Event hEvent, const char[] name, bool dontBroadcast)
{
	// track hunters pouncing
	char abilityName[64];
	hEvent.GetString("ability", abilityName, sizeof(abilityName));
	
	if (strcmp(abilityName, "ability_lunge", false) == 0) {
		int client = GetClientOfUserId(hEvent.GetInt("userid"));
		
		if (client <= 0 
		|| client > MaxClients 
		|| !IsClientInGame(client) 
		|| GetClientTeam(client) != L4D_TEAM_INF)
			return;

		// Hunter pounce
		g_fPouncingStartTime[client] = GetEngineTime();
	}
}

void Event_SurvivorPulled(Handle event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event, "victim"));
	g_bPulled[victim] = true;
}

void Event_PullEnd(Handle event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(GetEventInt(event, "victim"));
	g_bPulled[victim] = false;
}

void event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i <= MaxClients; i++) //clear
	{
		g_bPulled[i] = false;
		g_fPouncingStartTime[i] = 0.0;
	}
}

void OnBotSwap(Handle event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(GetEventInt(event, "bot"));
	int player = GetClientOfUserId(GetEventInt(event, "player"));
	if (IsClientIndex(bot) && IsClientIndex(player)) 
	{
		if (StrEqual(name, "player_bot_replace")) //bot take over
		{
			g_bPulled[bot] = g_bPulled[player];
			g_bPulled[player] = false;
		}
		else //player take over bot
		{
			g_bPulled[player] = g_bPulled[bot];
			g_bPulled[bot] = false;
		}
	}
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
	int client = GetClientOfUserId(event.GetInt("userid"));
	g_bPulled[client] = false;
}

void ConVarChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarRockFix = g_hCvarRockFix.BoolValue;
	g_bCvarPullThrough = g_hCvarPullThrough.BoolValue;
	g_bCvarRockThroughIncap = g_hCvarRockThroughIncap.BoolValue;
	if(!g_bL4D2Version) g_bCvarCommonThroughWitch = g_hCvarCommonThroughWitch.BoolValue;
	g_bCvarHunterThroughInacp = g_hCvarHunterThroughInacp.BoolValue;
	g_bCvarSIThroughWitch = g_hCvarSIThroughWitch.BoolValue;
}

// ----------------------------
bool IsClientIndex(int client)
{
	return (client > 0 && client <= MaxClients);
}

bool IsValidClient(int client) { 
    if (client <= 0 || client > MaxClients || !IsClientConnected(client)) return false; 
    return IsClientInGame(client); 
} 

bool IsSurvivor(int client) {
	return IsValidClient(client) && GetClientTeam(client) == L4D_TEAM_SUR;
}

bool IsInfected(int client) {
	return IsValidClient(client) && GetClientTeam(client) == L4D_TEAM_INF;
}

bool IsIncapacitatedOrHangingFromLedge(int client) 
{
	if (GetEntProp(client, Prop_Send, "m_isHangingFromLedge"))
		return true;

	if (GetEntProp(client, Prop_Send, "m_isIncapacitated") > 0)
		return true;
		
	return false;
}

int GetZombieClass(int client)
{
	return GetEntProp(client, Prop_Send, "m_zombieClass");
}

bool IsStartToPounce(int client)
{
	if(g_bL4D2Version)
	{
		int Activity = PlayerAnimState.FromPlayer(client).GetMainActivity();
		if(Activity == L4D2_ACT_TERROR_HUNTER_POUNCE 
			&& g_fPouncingStartTime[client] + 0.09 > GetEngineTime())
		{
			return true;
		}
	}
	else
	{
		int Activity = L4D1_GetMainActivity(client);
		if(Activity == L4D1_ACT_TERROR_HUNTER_POUNCE 
			&& g_fPouncingStartTime[client] + 0.09 > GetEngineTime())
		{
			return true;
		}
	}

	return false;
}