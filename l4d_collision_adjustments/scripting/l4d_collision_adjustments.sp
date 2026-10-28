#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <left4dhooks>
#include <collisionhook>

public Plugin myinfo = 
{
	name = "[L4D1/L4D2] Collision Adjustments",
	author = "Sir, Harry Potter",
	description = "No collisions to fix a handful of silly collision bugs in l4d",
	version = "1.3h-2026/10/23",
	url = "http://steamcommunity.com/profiles/76561198026784913"
}

bool g_bL4D2Version;
bool bLate;
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

	bLate = late;
	return APLRes_Success;
}

#define CLASSNAME_LENGTH 64
#define L4D_TEAM_SPEC 1 
#define L4D_TEAM_SUR 2
#define L4D_TEAM_INF 3

#define ZC_HUNTER	3

#define MODEL_GASCAN                  "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANECANISTER         "models/props_junk/propanecanister001a.mdl"
#define MODEL_OXYGENTANK              "models/props_equipment/oxygentank01.mdl"
#define MODEL_FIREWORKS_CRATE         "models/props_junk/explosive_box001.mdl"
#define MODEL_GNOME                   "models/props_junk/gnome.mdl"
#define MODEL_COLA                    "models/w_models/weapons/w_cola.mdl"

#define MAXENTITIES                   2048

ConVar g_hCvarRockFix, g_hCvarPullThrough, g_hCvarRockThroughIncap, g_hCvarHunterThroughInacp, g_hCvarSIThroughWitch,
	g_hCvarClientPushPipeBombFix, g_hCvarWeaponCommon, g_hSurvivorLadder;
bool g_bCvarRockFix,g_bCvarPullThrough,g_bCvarRockThroughIncap, g_bCvarHunterThroughInacp, g_bCvarSIThroughWitch,
	g_bCvarClientPushPipeBombFix, g_bCvarWeaponCommon, g_bSurvivorLadder;

bool g_bPulled[MAXPLAYERS + 1] = {false, ...};

enum EEntity_Type
{
	EEntity_Unknown,

	EEntity_Rock,
	EEntity_Infected,
	EEntity_Witch,
	EEntity_PipeBombProj,
	EEntity_MolotovProj,
	EEntity_WeaponItems,
	EEntity_InfLadder
}

EEntity_Type 
	g_iEntityType[MAXENTITIES+1];

int 
	g_iZombieClass,
	g_iModel_Gascan = -1,
	g_iModel_PropaneCanister = -1,
	g_iModel_OxygenTank = -1,
	g_iModel_FireworksCrate = -1,
	g_iModel_Gnome = -1,
	g_iModel_Cola = -1;

float 
	g_flPlayerNoCollideTime[MAXPLAYERS+1][MAXPLAYERS+1];

public void OnPluginStart()
{
	g_iZombieClass = FindSendPropInfo("CTerrorPlayer", "m_zombieClass");

	g_hCvarRockFix 					= CreateConVar("l4d_collision_adjustments_tankrock_common", "1", "If 1, Rocks can go through Common Infected (and also kill them) instead of possibly getting stuck on them", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarPullThrough 				= CreateConVar("l4d_collision_adjustments_smoker_common", 	"1", "If 1, Pulled Survivors can go through Common Infected", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarRockThroughIncap 		= CreateConVar("l4d_collision_adjustments_tankrock_incap", 	"1", "If 1, Rocks can go through Incapacitated Survivors? (Won't go through new incaps caused by the Rock)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarHunterThroughInacp 		= CreateConVar("l4d_collision_adjustments_hunter_incap", 	"1", "If 1, Hunter can go through incapacitated survivor (Prevent hunter stuck inside incapacitated survivor, still can pounce them)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarSIThroughWitch 			= CreateConVar("l4d_collision_adjustments_si_witch", 		"1", "If 1, Special infected and Tank can go through witch (Prevent stuck and stagger)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarClientPushPipeBombFix 	= CreateConVar("l4d_collision_adjustments_client_pipebomb", "1", "If 1, Fix the bug where survivor and special infected can push pipebomb projectiles", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarWeaponCommon 			= CreateConVar("l4d_collision_adjustments_weapon_common",   "1", "If 1, Common Infected can go through Weapons, items, and carryables (GasCan, Prop tank, Oxygen tank, Fireworks crate, Gnome, Cola)\n (Prevent stuck)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSurvivorLadder 				= CreateConVar("l4d_collision_adjustments_survivor_ladder", "1", "If 1, Remove survivor collision with infected ladders. (Prevents Survivors from getting jitter/rubberbanding on infected ladder)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	AutoExecConfig(true,            "l4d_collision_adjustments");

	GetCvars();
	g_hCvarRockFix.AddChangeHook(ConVarChanged);
	g_hCvarPullThrough.AddChangeHook(ConVarChanged);
	g_hCvarRockThroughIncap.AddChangeHook(ConVarChanged);
	g_hCvarHunterThroughInacp.AddChangeHook(ConVarChanged);
	g_hCvarSIThroughWitch.AddChangeHook(ConVarChanged);
	g_hCvarClientPushPipeBombFix.AddChangeHook(ConVarChanged);
	g_hCvarWeaponCommon.AddChangeHook(ConVarChanged);
	g_hSurvivorLadder.AddChangeHook(ConVarChanged);
	
	HookEvent("tongue_grab", Event_SurvivorPulled);
	HookEvent("tongue_release", Event_PullEnd);
	HookEvent("round_start", event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_bot_replace", OnBotSwap);
	HookEvent("bot_player_replace", OnBotSwap);
	HookEvent("ability_use", Event_AbilityUse);
	HookEvent("player_spawn", Event_PlayerSpawn);

	if(bLate)
	{
		LateLoad();
	}
}

void LateLoad()
{
    int entity;
    char classname[36];

    entity = INVALID_ENT_REFERENCE;
    while ((entity = FindEntityByClassname(entity, "*")) != INVALID_ENT_REFERENCE)
    {
        if (entity < 0)
            continue;

        GetEntityClassname(entity, classname, sizeof(classname));
        OnEntityCreated(entity, classname);
    }
}

// Cvars-------------------------------

void ConVarChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarRockFix = g_hCvarRockFix.BoolValue;
	g_bCvarPullThrough = g_hCvarPullThrough.BoolValue;
	g_bCvarRockThroughIncap = g_hCvarRockThroughIncap.BoolValue;
	g_bCvarHunterThroughInacp = g_hCvarHunterThroughInacp.BoolValue;
	g_bCvarSIThroughWitch = g_hCvarSIThroughWitch.BoolValue;
	g_bCvarClientPushPipeBombFix = g_hCvarClientPushPipeBombFix.BoolValue;
	g_bCvarWeaponCommon = g_hCvarWeaponCommon.BoolValue;
	g_bSurvivorLadder = g_hSurvivorLadder.BoolValue;
}

// Collision Hook API

public Action CH_PassFilter(int ent1, int ent2, bool &result)
{
	// riverside1: every rule below needs two clients, or a non-client whose g_iEntityType is known.
	// Bail out before any native when neither holds (most commons, props and world traces).
	bool bClient1 = (ent1 > 0 && ent1 <= MaxClients);
	bool bClient2 = (ent2 > 0 && ent2 <= MaxClients);
	if (!(bClient1 && bClient2)
		&& (bClient1 || ent1 < 0 || ent1 > MAXENTITIES || g_iEntityType[ent1] == EEntity_Unknown)
		&& (bClient2 || ent2 < 0 || ent2 > MAXENTITIES || g_iEntityType[ent2] == EEntity_Unknown))
	{
		return Plugin_Continue;
	}

	if ( ent1 > 0 && ent1 <= MaxClients && IsClientInGame(ent1) && IsPlayerAlive(ent1) )
	{
		int team1 = GetClientTeam(ent1);
		if(ent2 > 0 && ent2 <= MaxClients && IsClientInGame(ent2) && IsPlayerAlive(ent2))
		{
			if( g_bCvarHunterThroughInacp && team1 == L4D_TEAM_SUR && L4D_IsPlayerIncapacitated(ent1)
				&& GetClientTeam(ent2) == L4D_TEAM_INF && GetZombieClass(ent2) == ZC_HUNTER 
				&& g_flPlayerNoCollideTime[ent2][ent1] > GetGameTime())
			{
				result = false;
				return Plugin_Handled;
			}
		}
		else if(ent2 > MaxClients && IsValidEntity(ent2))
		{
			if( g_bCvarClientPushPipeBombFix && g_iEntityType[ent2] == EEntity_PipeBombProj )
			{
				result = false;
				return Plugin_Handled;
			}

			if ( g_bCvarPullThrough && g_iEntityType[ent2] == EEntity_Infected 
				&& team1 == L4D_TEAM_SUR && g_bPulled[ent1] )
			{
				result = false;
				return Plugin_Handled;			
			}

			if ( g_bCvarRockThroughIncap && g_iEntityType[ent2] == EEntity_Rock
				&& team1 == L4D_TEAM_SUR && L4D_IsPlayerIncapacitated(ent1) )
			{
				result = false;
				return Plugin_Handled;
			}

			if (g_bCvarSIThroughWitch && g_iEntityType[ent2] == EEntity_Witch
				&& team1 == L4D_TEAM_INF)
			{
				result = false;
				return Plugin_Handled;
			}	

			// We don't let survivors collide with infected ladders, this bit handles the server side collision (actual collision)
			if (g_bSurvivorLadder && g_iEntityType[ent2] == EEntity_InfLadder
				&& team1 == L4D_TEAM_SUR)
			{
				result = false;
				return Plugin_Handled;
			}	
		}
	}

	if ( ent2 > 0 && ent2 <= MaxClients && IsClientInGame(ent2) && IsPlayerAlive(ent2) )
	{
		int team2 = GetClientTeam(ent2);
		if( ent1 > 0 && ent1 <= MaxClients && IsClientInGame(ent1) && IsPlayerAlive(ent1) )
		{
			if( g_bCvarHunterThroughInacp && team2 == L4D_TEAM_SUR && L4D_IsPlayerIncapacitated(ent2)
				&& GetClientTeam(ent1) == L4D_TEAM_INF && GetZombieClass(ent1) == ZC_HUNTER 
				&& g_flPlayerNoCollideTime[ent1][ent2] > GetGameTime())
			{
				result = false;
				return Plugin_Handled;
			}
		}
		else if(ent1 > MaxClients && IsValidEntity(ent1))
		{
			if( g_bCvarClientPushPipeBombFix && g_iEntityType[ent1] == EEntity_PipeBombProj )
			{
				result = false;
				return Plugin_Handled;
			}

			if ( g_bCvarPullThrough && g_iEntityType[ent1] == EEntity_Infected
				&& team2 == L4D_TEAM_SUR && g_bPulled[ent2] )
			{
				result = false;
				return Plugin_Handled;			
			}

			if ( g_bCvarRockThroughIncap && g_iEntityType[ent1] == EEntity_Rock
				&& team2 == L4D_TEAM_SUR && L4D_IsPlayerIncapacitated(ent2) )
			{
				result = false;
				return Plugin_Handled;
			}

			if (g_bCvarSIThroughWitch && g_iEntityType[ent1] == EEntity_Witch
				&& team2 == L4D_TEAM_INF)
			{
				result = false;
				return Plugin_Handled;
			}	

			// We don't let survivors collide with infected ladders, this bit handles the server side collision (actual collision)
			if (g_bSurvivorLadder && g_iEntityType[ent1] == EEntity_InfLadder
				&& team2 == L4D_TEAM_SUR)
			{
				result = false;
				return Plugin_Handled;
			}	
		}
	}

	if (ent1 > MaxClients && IsValidEntity(ent1) 
		&& ent2 > MaxClients && IsValidEntity(ent2) )
	{
		if (g_iEntityType[ent1] == EEntity_Infected)
		{
			if (g_bCvarRockFix && g_iEntityType[ent2] == EEntity_Rock)
			{
				result = false;
				return Plugin_Handled;
			}
			else if (g_bCvarWeaponCommon && g_iEntityType[ent2] == EEntity_WeaponItems)
			{
				result = false;
				return Plugin_Handled;
			}
		}

		if (g_iEntityType[ent2] == EEntity_Infected)
		{
			if (g_bCvarRockFix && g_iEntityType[ent1] == EEntity_Rock)
			{
				result = false;
				return Plugin_Handled;
			}
			else if (g_bCvarWeaponCommon && g_iEntityType[ent1] == EEntity_WeaponItems)
			{
				result = false;
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

// Sourcemod API Forward-------------------------------

public void OnMapStart()
{
	g_iModel_Gascan = PrecacheModel(MODEL_GASCAN, true);
	g_iModel_PropaneCanister = PrecacheModel(MODEL_PROPANECANISTER, true);
	g_iModel_OxygenTank = PrecacheModel(MODEL_OXYGENTANK, true);
	if (g_bL4D2Version)
	{
		g_iModel_FireworksCrate = PrecacheModel(MODEL_FIREWORKS_CRATE, true);
		g_iModel_Gnome = PrecacheModel(MODEL_GNOME, true);
		g_iModel_Cola = PrecacheModel(MODEL_COLA, true);
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntityIndex(entity))
		return;

	g_iEntityType[entity] = EEntity_Unknown;

	switch (classname[0])
	{
		case 'w':
		{
			if (StrEqual(classname, "witch"))
			{
				g_iEntityType[entity] = EEntity_Witch;
			}
			else if (strncmp(classname, "weapon_", 7 ,false) == 0)
			{
				g_iEntityType[entity] = EEntity_WeaponItems;
			}
		}
		case 'i':
		{
			if (StrEqual(classname, "infected"))
			{
				g_iEntityType[entity] = EEntity_Infected;
			}
		}
		case 't':
		{
			if (StrEqual(classname, "tank_rock"))
			{
				g_iEntityType[entity] = EEntity_Rock;
			}
		}
		case 'p':
		{
			if (StrEqual(classname, "pipe_bomb_projectile"))
			{
				g_iEntityType[entity] = EEntity_PipeBombProj;
			}
			else if (HasEntProp(entity, Prop_Send, "m_isCarryable")) // CPhysicsProp
				RequestFrame(OnNextFramePhysics, EntIndexToEntRef(entity)); // 1 frame later required to apply the collision properly
		}
		/*case 'm':
		{
			if (StrEqual(classname, "molotov_projectile"))
			{
				g_iEntityType[entity] = EEntity_MolotovProj;
			}
		}*/
		case 'f':
		{
			if (StrEqual(classname, "func_simpleladder"))
			{
				RequestFrame(OnNextFrame_func_simpleladder, EntIndexToEntRef(entity));
			}
		}
	}
}

// Timer & Frame-------------------------------

void OnNextFramePhysics(int entityRef)
{
    int entity = EntRefToEntIndex(entityRef);

    if (entity == INVALID_ENT_REFERENCE)
        return;

    int modelIndex = GetEntProp(entity, Prop_Send, "m_nModelIndex");

    if (modelIndex == g_iModel_Gascan)
    {
        g_iEntityType[entity] = EEntity_WeaponItems;
        return;
    }

    if (modelIndex == g_iModel_PropaneCanister)
    {
        g_iEntityType[entity] = EEntity_WeaponItems;
        return;
    }

    if (modelIndex == g_iModel_OxygenTank)
    {
        g_iEntityType[entity] = EEntity_WeaponItems;
        return;
    }

    if (!g_bL4D2Version)
        return;

    if (modelIndex == g_iModel_FireworksCrate)
    {
        g_iEntityType[entity] = EEntity_WeaponItems;
        return;
    }

    if (modelIndex == g_iModel_Gnome)
    {
        g_iEntityType[entity] = EEntity_WeaponItems;
        return;
    }

    if (modelIndex == g_iModel_Cola)
    {
        g_iEntityType[entity] = EEntity_WeaponItems;
        return;
    }
}

void OnNextFrame_func_simpleladder(int entityRef)
{
	int entity = EntRefToEntIndex(entityRef);

	if (entity == INVALID_ENT_REFERENCE)
		return;

	//PrintToChatAll("m_iTeamNum %d", GetEntProp(entity, Prop_Send, "m_iTeamNum"));
	if (GetEntProp(entity, Prop_Send, "m_iTeamNum") == L4D_TEAM_INF) {
		g_iEntityType[entity] = EEntity_InfLadder;
		SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit);
	}
}

// SDKHooks-------------------------------

// Credit: github.com/SirPlease/L4D2-Competitive-Rework/blob/master/addons/sourcemod/scripting/l4d2_fix_ladder_collision.sp 
// We don't send infected ladder data to survivors, this bit handles the clientside prediction so that they don't get visual bugs (jitter/rubberbanding)
Action Hook_SetTransmit(int entity, int client)
{
	if (g_bSurvivorLadder && GetClientTeam(client) == L4D_TEAM_SUR) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

// Event

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

		g_flPlayerNoCollideTime[client][0] = GetGameTime() + 0.5;
		for (int i = 1; i <= MaxClients; ++i)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && L4D_IsPlayerIncapacitated(i))
			{
				float AA[3], AB[3], BA[3], BB[3];
				GetEntityWorldSpaceBounds(client, AA, AB);
				GetEntityWorldSpaceBounds(i, BA, BB);

				if (IsBoxIntersectingBox(AA, AB, BA, BB))
				{
					g_flPlayerNoCollideTime[client][i] = GetGameTime() + 0.5;
				}
			}
		}
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
		for (int j = 0; j <= MaxClients; j++)
		{
			g_flPlayerNoCollideTime[i][j] = 0.0;
		}
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

// Other-----

bool IsClientIndex(int client)
{
	return (client > 0 && client <= MaxClients);
}

int GetZombieClass(int client)
{
	return GetEntData(client, g_iZombieClass);
}

bool IsValidEntityIndex(int entity)
{
	return (MaxClients+1 <= entity <= MAXENTITIES);
}

void GetEntityWorldSpaceBounds(int entity, float worldMins[3], float worldMaxs[3])
{
	float pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", pos);

	float mins[3], maxs[3];
	GetEntPropVector(entity, Prop_Data, "m_vecMins", mins);
	GetEntPropVector(entity, Prop_Data, "m_vecMaxs", maxs);

	AddVectors(pos, mins, worldMins);
	AddVectors(pos, maxs, worldMaxs);
}

bool IsBoxIntersectingBox( const float boxMin1[3], const float boxMax1[3], 
						const float boxMin2[3], const float boxMax2[3] )
{
	if ( (boxMin1[0] > boxMax2[0]) || (boxMax1[0] < boxMin2[0]) )
		return false;
	if ( (boxMin1[1] > boxMax2[1]) || (boxMax1[1] < boxMin2[1]) )
		return false;
	if ( (boxMin1[2] > boxMax2[2]) || (boxMax1[2] < boxMin2[2]) )
		return false;
	return true;
}