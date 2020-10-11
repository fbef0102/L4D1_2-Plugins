#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <glow>

#define TEAM_INFECTED                        3
#define SPRITE_MODEL3            "materials/vgui/healthbar_white.vmt"
#define SPRITE_MODEL2            "materials/vgui/s_panel_healing_mini_prog.vmt"
#define SPRITE_MODEL             "materials/vgui/hud/zombieteamimage_tank.vmt"
#define SPRITE_MODEL4            "materials/vgui/healthbar_orange.vmt"
#define SPRITE_DEATH             "materials/sprites/death_icon.vmt"

//RIP DIMINUIR?

static bool   g_bL4D2Version;

static int TankSprite[MAXPLAYERS+1];
static int TankHealth[MAXPLAYERS+1];
static bool TankNow[MAXPLAYERS+1];
static bool TankIncapped[MAXPLAYERS+1];
static float LastUseTime[MAXPLAYERS+1];

static int AlgorithmType = 2;
static bool EnableGlow = false;
static int ZOMBIECLASS_TANK;

// ====================================================================================================
// Plugin Start
// ====================================================================================================
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		ZOMBIECLASS_TANK = 5;
		g_bL4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		ZOMBIECLASS_TANK = 8;
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
    HookEvent("tank_spawn", Event_TankSpawn);
    HookEvent("tank_killed", event_TankKilled);
    HookEvent("player_hurt", OnPlayerHurt);
}

public void OnMapStart()
{
    PrecacheModel(SPRITE_MODEL, true);
    PrecacheModel(SPRITE_MODEL2, true);
    PrecacheModel(SPRITE_MODEL3, true);
    PrecacheModel(SPRITE_MODEL4, true);
    PrecacheModel(SPRITE_DEATH, true);
}

public Action event_TankKilled( Event event, const char[] sName, bool bDontBroadcast )
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if (client <= 0 || client > MaxClients|| !IsClientInGame(client))
        return;

    if (!TankIncapped[client])
    {
        TankHealth[client] = -1;
        int env_sprite = TankSprite[client];

        if (!IsValidEntRef(env_sprite))
            return;

        DispatchKeyValue(env_sprite, "model", SPRITE_DEATH);
        DispatchKeyValue(env_sprite, "rendercolor", "127 0 0");
        DispatchKeyValue(env_sprite, "renderamt", "240");
        DispatchSpawn(env_sprite);

        if (g_bL4D2Version && EnableGlow)
            L4D2_SetEntGlow_Flashing(client, true);
    }
}

public Action OnPlayerHurt( Event event, const char[] sName, bool bDontBroadcast )
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    if (!client || !IsClientConnected(client) || !IsClientInGame(client) || (!IsFakeClient(client) && !IsPlayerAlive(client)) || GetClientTeam(client) != TEAM_INFECTED || TankHealth[client] == -1)
        return Plugin_Continue;

    if(IsPlayerTank(client) == false)
    {
        return Plugin_Continue;
    }

    int nowHP = GetEventInt(event, "health");
    int maxHP = TankHealth[client];

    if (TankHealth[client] == -1)
         return Plugin_Continue;

    int env_sprite = TankSprite[client];

    if (!IsValidEntRef(env_sprite))
        return Plugin_Continue;

    if (IsPlayerIncapped(client))
    {
        if (!TankIncapped[client])
        {
            TankIncapped[client] = true;
            DispatchKeyValue(env_sprite, "targetname", "tanksprite");
            DispatchKeyValue(env_sprite, "model", SPRITE_DEATH);
            DispatchKeyValue(env_sprite, "rendercolor", "127 0 0");
            DispatchKeyValue(env_sprite, "renderamt", "240");
            DispatchSpawn(env_sprite);

            if (g_bL4D2Version && EnableGlow)
                L4D2_SetEntGlow_Flashing(client, true);
        }

        return Plugin_Continue;
    }

    float fCountdownHeat = float(nowHP) / maxHP;

    char sTemp[12];

    bool bHalfHp = false;
    bHalfHp = fCountdownHeat <= 0.5 ? true : false;
    if (AlgorithmType == 1)
        Format(sTemp, sizeof(sTemp), "%i %i 0", bHalfHp ? 255 : RoundFloat(255.0 * ((1.0 - fCountdownHeat) * 2)), bHalfHp ? RoundFloat(255.0 * (fCountdownHeat) * 2) : 255);
    else
        Format(sTemp, sizeof(sTemp), "%i %i 0", RoundFloat(255 * (1 - fCountdownHeat)), RoundFloat(255 * fCountdownHeat));
    DispatchKeyValue(env_sprite, "rendercolor", sTemp);
    DispatchKeyValue(env_sprite, "model", SPRITE_MODEL3);
    DispatchKeyValue(env_sprite, "renderamt", "240");

    if (g_bL4D2Version && EnableGlow)
    {
        if (!TankNow[client])
        {
            L4D2_SetEntGlow_Type(client, view_as<L4D2GlowType>(3));
            L4D2_SetEntGlow_Range(client, 0);
            L4D2_SetEntGlow_MinRange(client, 0);

            int color[3];
            if (AlgorithmType == 1)
            {
                color[0] = bHalfHp ? 255 : RoundFloat(255.0 * ((1.0 - fCountdownHeat) * 2));
                color[1] = bHalfHp ? RoundFloat(255.0 * (fCountdownHeat) * 2) : 255;
                color[2] = 0;
            }
            else if (AlgorithmType == 2)
            {
                color[0] = RoundFloat(255 * (1 - fCountdownHeat));
                color[1] = RoundFloat(255 * fCountdownHeat);
                color[2] = 0;
            }

            L4D2_SetEntGlow_ColorOverride(client, color);
            if (fCountdownHeat <= 0.1)
                L4D2_SetEntGlow_Flashing(client, true);
        }
    }

    LastUseTime[client] = GetEngineTime();

    return Plugin_Continue;
}

int iSwitch = 0;
public void Event_TankSpawn( Event event, const char[] sName, bool bDontBroadcast )
{
    int client =    GetClientOfUserId(GetEventInt(event, "userid"));

    if (IsValidClient(client))
    {
        TankHealth[client] = -1;
        TankNow[client] = false;
        TankIncapped[client] = false;
        CreateTimer(0.5, Timer_TankSprite, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
        CreateTimer(1.0, Timer_HealthModifierSet, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

        if (g_bL4D2Version && EnableGlow)
        {
            L4D2_SetEntGlow_Type(client, view_as<L4D2GlowType>(3));
            L4D2_SetEntGlow_Range(client, 0);
            L4D2_SetEntGlow_MinRange(client, 0);
            L4D2_SetEntGlow_ColorOverride(client, view_as<int>({0, 255, 0}));
            L4D2_SetEntGlow_Flashing(client, false);
        }

        iSwitch = iSwitch +1;
        if (iSwitch > 4)
        iSwitch = 1;
        int env_sprite = CreateEntityByName("env_sprite");

        if (env_sprite == -1)
            return;

        // decl String:Buffer[64];
        // Format(Buffer, sizeof(Buffer), "client%i", client);
        // DispatchKeyValue(env_sprite, "targetname", Buffer);

        DispatchKeyValue(env_sprite, "model", SPRITE_MODEL3);
        DispatchKeyValue(env_sprite, "rendermode", "1");
        DispatchKeyValue(env_sprite, "rendercolor", "0 255 0");
        DispatchKeyValue(env_sprite, "renderamt", "240");
        DispatchKeyValue(env_sprite, "disablereceiveshadows", "1");
        DispatchKeyValue(env_sprite, "spawnflags", "1");
        DispatchKeyValueFloat(env_sprite, "fademindist", 600.0);
        DispatchKeyValueFloat(env_sprite, "fademaxdist", 600.0);

        DispatchSpawn(env_sprite);
        DispatchKeyValue(env_sprite, "renderamt", "0");

        SetVariantString("!activator");
        AcceptEntityInput(env_sprite, "SetParent", client);

        float vPos[3];
        // vPos[0] = 200.0;
        // vPos[1] = 200.0;
        vPos[2] = 100.0;

        TeleportEntity(env_sprite, vPos, NULL_VECTOR, NULL_VECTOR);

        TankSprite[client] =  EntIndexToEntRef(env_sprite);
    }
}

public Action Timer_HealthModifierSet(Handle timer, int client)
{
    if (IsValidClient(client) && !IsPlayerGhost(client) && IsPlayerAlive(client) && GetClientTeam(client) == TEAM_INFECTED && GetClientHealth(client) > 0 && TankHealth[client] == -1)
    {
       TankHealth[client] = GetClientHealth(client);
       return Plugin_Stop;
    }

    return Plugin_Continue;

}

public Action Timer_TankSprite(Handle timer, int client)
{
    int env_sprite = TankSprite[client];

    if (!IsValidEntRef(env_sprite))
    {
        return Plugin_Stop;
    }

    if (!IsClientInGame(client) || (!IsFakeClient(client) && !IsPlayerAlive(client)) || GetClientTeam(client) != 3)
	{
        AcceptEntityInput(env_sprite, "Kill");
        return Plugin_Stop;
	}
	
    if(IsPlayerTank(client) == false)
    {
        AcceptEntityInput(env_sprite, "Kill"); 
        return Plugin_Stop;
    }

    if (GetEngineTime()-LastUseTime[client] >= 2.0 && IsPlayerAlive(client) && !IsPlayerIncapped(client))
    {
        DispatchKeyValue(env_sprite, "model", SPRITE_MODEL3);
        DispatchKeyValue(env_sprite, "renderamt", "0");
    }

    return Plugin_Continue;
}

bool IsValidClient(int client)
{
    return (1 <= client <= MaxClients && IsClientInGame(client));
}

bool IsPlayerGhost(int client)
{
    return GetEntProp(client, Prop_Send, "m_isGhost", 1) == 1;
}

bool IsPlayerIncapped(int client)
{
    return GetEntProp(client, Prop_Send, "m_isIncapacitated") == 1;
}

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE && entity!= -1 )
		return true;
	return false;
}

bool IsPlayerTank (int client)
{
	if(GetZombieClass(client) == ZOMBIECLASS_TANK)
		return true;
	return false;
}

int GetZombieClass(int client)
{
    return GetEntProp(client, Prop_Send, "m_zombieClass");
}