/*
 * @Author:             派蒙
 * @Last Modified by:   我是派蒙啊
 * @Create Date:        2022-01-14 11:54:43
 * @Last Modified time: 2024-11-15 22:14:34
 * @Github:             http://github.com/PaimonQwQ
 */

#if defined _paiutils_included
    #endinput
#endif
#define _paiutils_included

#include <regex>
#include <dhooks>
#include <sdktools>
#include <sdkhooks>
#include <sourcemod>

#define WEPUPGFLAG_NONE                  (0 << 0)
#define WEPUPGFLAG_INCENDIARY      (1 << 0)
#define WEPUPGFLAG_EXPLOSIVE         (1 << 1)
#define WEPUPGFLAG_LASER                 (1 << 2) 

#define Pai     3.14159265358979323846

#define TEAM_SPECTATOR     1
#define TEAM_SURVIVOR       2
#define TEAM_INFECTED       3

#define ZC_SMOKER      1
#define ZC_BOOMER      2
#define ZC_HUNTER      3
#define ZC_SPITTER     4
#define ZC_JOCKEY      5
#define ZC_CHARGER     6
#define ZC_WITCH       7
#define ZC_TANK        8

#define CMDBOT_ATTACK  0
#define CMDBOT_MOVE    1
#define CMDBOT_RETREAT 2
#define CMDBOT_RESET   3

enum
{
    Team_All = -1,
    Team_Spectator = 1,
    Team_Survivor,
    Team_Infected
};

enum
{
    ZC_Smoker = 1,
    ZC_Boomer,
    ZC_Hunter,
    ZC_Spitter,
    ZC_Jockey,
    ZC_Charger,
    ZC_Witch,
    ZC_Tank
};

// enum
// {
//     PC_UpperCut = 40,
//     PC_RightHook = 43,
//     PC_LeftHook = 45,
//     PC_PoundGround1 = 46,
//     PC_PoundGround2 = 47,
//     TH_UnderCut = 48,
//     TH_OverHand = 49,
//     TH_FromHip = 50,
//     TH_OverHead = 51
// };

enum
{
    CmdBot_Attack = 0,     // Force the bot to attack a specific target, even bypassing CTerrorPlayer::SetSenseFlags (DirectorScript.BOT_CANT_SEE).
    CmdBot_Move = 1,       // Force the bot to move to a specific location, which then they will do it unconditionally without performing any other AI behaviours controlled by themselves.
                           // This means that Survivor Bots and most player-controllable Special Infected won't attack anything when commanded, but Common Infected still automatically attack enemies if they close in enough.
    CmdBot_Retreat = 2,    // Force the bot to retreat from a target entity. Only works when used on Survivor Bots, and if target is a Tank.
    CmdBot_Reset = 3       // Removes the active bot command and lets the AI resume controlling the bot.
};

/**
 * @brief Returns true if client is correct.
 *
 * @param client    Client index.
 * @return          True if client is correct. False otherwise.
 */
stock bool IsValidClient(int client)
{
    return (0 < client <= MaxClients && IsClientConnected(client) && IsClientInGame(client));
}

/**
 * @brief Returns true if client is a survivor.
 *
 * @param client    Client index.
 * @return          True if client is a survivor. False otherwise.
 */
stock bool IsSurvivor(int client)
{
    return (IsValidClient(client) && GetClientTeam(client) == TEAM_SURVIVOR);
}

/**
 * @brief Returns true if client is a SI(Special Infected).
 *
 * @param client    Client index.
 * @return          True if client is a SI. False otherwise.
 */
stock bool IsInfected(int client)
{
    return (IsValidClient(client) && GetClientTeam(client) == TEAM_INFECTED);
}

/**
 * @brief Returns true if client is a spectator.
 *
 * @param client    Client index.
 * @return          True if client is a spectator. False otherwise.
 */
stock bool IsSpectator(int client)
{
    return (IsValidClient(client) && GetClientTeam(client) == TEAM_SPECTATOR);
}

/**
 * @brief Returns true if client is in ghost mode.
 *
 * @param client    Client index.
 * @return          True if client is in ghost mode. False otherwise.
 */
stock bool IsGhost(int client)
{
    return (IsValidClient(client) && view_as<bool>(GetEntProp(client, Prop_Send, "m_isGhost")));
}

/**
 * @brief Returns true if client is a tank.
 *
 * @param client    Client index.
 * @return          True if client is a tank. False otherwise.
 */
stock bool IsTank(int client)
{
    return (IsValidClient(client) && GetZombieClass(client) == ZC_Tank);
}

/**
 * @brief Returns true if client is being pinned.
 *
 * @param client    Client index.
 * @return          True if client is being pinned. False otherwise.
 */
stock bool IsSurvivorPinned(int client)
{
    return (IsSurvivor(client) && (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0 ||       // smoker grabbed
                                   GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0 ||     // hunter pounded
                                   GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0 ||    // charger carred
                                   GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0 ||    // charger pounded
                                   GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0));    // jockey ridden
}

/**
 * @brief Returns who is pinning a client.
 *
 * @param client    Client index.
 * @return          Infected index if client is being pinned. -1 otherwise.
 */
stock int GetSurvivorPinner(int client)
{
    if (!IsSurvivor(client)) return -1;

    return (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0 ?    // smoker grabbed
                GetEntPropEnt(client, Prop_Send, "m_tongueOwner")
                                                                  : GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0 ?    // hunter pounded
                                                                        GetEntPropEnt(client, Prop_Send, "m_carryAttacker")
                                                                                                                            : GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0 ?    // charger carred
                                                                                                                                  GetEntPropEnt(client, Prop_Send, "m_pounceAttacker")
                                                                                                                                                                                       : GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0 ?    // charger pounded
                                                                                                                                                                                             GetEntPropEnt(client, Prop_Send, "m_pummelAttacker")
                                                                                                                                                                                                                                                  : GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0 ?    // jockey ridden
                                                                                                                                                                                                                                                        GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker")
                                                                                                                                                                                                                                                                                                             : -1);
}

/**
 * @brief Returns survivor who is pinned by client.
 *
 * @param client    Client index.
 * @return          Survivor index who is pinned by client. -1 otherwise.
 */
stock int GetPinningSurvivor(int client)
{
    if (!IsInfected(client)) return -1;
    return (GetEntPropEnt(client, Prop_Send, "m_tongueVictim") > 0 ?    // smoker grabbed
                GetEntPropEnt(client, Prop_Send, "m_tongueVictim")
                                                                   : GetEntPropEnt(client, Prop_Send, "m_pounceVictim") > 0 ?    // hunter pounded
                                                                         GetEntPropEnt(client, Prop_Send, "m_pounceVictim")
                                                                                                                            : GetEntPropEnt(client, Prop_Send, "m_carryVictim") > 0 ?    // charger carred
                                                                                                                                  GetEntPropEnt(client, Prop_Send, "m_carryVictim")
                                                                                                                                                                                    : GetEntPropEnt(client, Prop_Send, "m_pummelVictim") > 0 ?    // charger pounded
                                                                                                                                                                                          GetEntPropEnt(client, Prop_Send, "m_pummelVictim")
                                                                                                                                                                                                                                             : GetEntPropEnt(client, Prop_Send, "m_jockeyVictim") > 0 ?    // jockey ridden
                                                                                                                                                                                                                                                   GetEntPropEnt(client, Prop_Send, "m_jockeyVictim")
                                                                                                                                                                                                                                                                                                      : -1);
}

/**
 * @brief Returns true if client is pinning a survivor.
 *
 * @param client    Client index.
 * @return          True if client is pinning a survivor. False otherwise.
 */
stock bool IsPinningSurvivor(int client)
{
    return (IsInfected(client) && (GetEntPropEnt(client, Prop_Send, "m_tongueVictim") > 0 ||    // smoker grabbing
                                   GetEntPropEnt(client, Prop_Send, "m_pounceVictim") > 0 ||    // hunter pounding
                                   GetEntPropEnt(client, Prop_Send, "m_carryVictim") > 0 ||     // charger carrying
                                   GetEntPropEnt(client, Prop_Send, "m_pummelVictim") > 0 ||    // charger pounding
                                   GetEntPropEnt(client, Prop_Send, "m_jockeyVictim") > 0));    // jockey riding
}

/**
 * @brief Returns who is aiming client.
 *
 * @param aimee   Client who is aimed.
 * @param team    Team type to included.
 * @param sawable       Is target seen threats.
 * @return              Client index for who aimed aimee. -1 otherwise.
 */
stock int GetClientAimedBy(int aimee, int team = 0, bool sawable = true)
{
    int target = -1;
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || (team && GetClientTeam(i) != team) || !IsPlayerAlive(i) || IsPlayerIncap(i) || (sawable && !IsEntitySawThreats(i))) continue;
        int aimed = GetClientAimTarget(i);
        if (aimed != aimee) continue;
        target = i;
        break;
    }

    return target;
}

/**
 * @brief Returns closest client who is aiming aimee.
 *
 * @param aimee     Client who is aimed.
 * @param team      Team type to included.
 * @param sawable   Is target seen threats.
 * @return          Client index for closest client. -1 otherwise.
 */
stock int GetClosestClientAimer(int aimee, int team, bool sawable = true)
{
    int target = -1;
    float dis = -1.0, pos[3], tarPos[3];
    GetClientAbsOrigin(aimee, tarPos);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || (team && GetClientTeam(i) != team) || !IsPlayerAlive(i) || IsPlayerIncap(i) || (sawable && !IsEntitySawThreats(i))) continue;
        int aimed = GetClientAimTarget(i);
        if (aimed != aimee) continue;

        GetClientAbsOrigin(i, pos);
        float tmp = GetVectorDistance(tarPos, pos, true);
        if (dis <= tmp && dis != -1) continue;

        target = i;
        dis = tmp;
    }

    return target;
}

/**
 * @brief Returns closest client of target or origin.
 *
 * @param target        Target entity to begin searching.
 * @param origin        Position to begin searching, no use if target is valid.
 * @param targetTeam    Team type to included.
 * @param sawable       Is target seen threats.
 * @param notAimed      Should client not aim target.
 * @param isIncap       Can target be incap.
 * @param isGhost       Is target a ghost.
 * @return              Client index for closest client. -1 otherwise.
 */
stock int GetClosestClient(int target = -1, const float origin[3], int targetTeam = 0, bool sawable = true, bool notAimed = false, bool isIncapable = false, bool isGhost = false)
{
    int result = -1;
    float dis = -1.0, pos[3], tarPos[3];
    AddVectors(tarPos, origin, tarPos);
    if (IsValidEntity(target)) GetEntPropVector(target, Prop_Send, "m_vecOrigin", tarPos);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (!IsValidClient(i) || !IsPlayerAlive(i) || (targetTeam && GetClientTeam(i) != targetTeam) || (notAimed && GetClientAimTarget(i) == target) || (sawable && !IsEntitySawThreats(i)) || (!isIncapable && IsPlayerIncap(i)) || (!isGhost && IsGhost(i))) continue;

        GetClientAbsOrigin(i, pos);
        float tmp = GetVectorDistance(tarPos, pos, true);
        if (dis <= tmp && dis != -1) continue;

        result = i;
        dis = tmp;
    }

    return result;
}

/**
 * @brief Returns closest zombies of target or origin.
 *
 * @param target        Target entity to begin searching.
 * @param origin        Position to begin searching, no use if target is valid.
 * @param includeWitch  Is included witch.
 * @param includeRock   Is included rock.
 * @return              Entity index for closest zombies. -1 otherwise.
 */
stock int GetClosestZombie(int target = -1, const float origin[3], bool includeWitch = true, bool includeRock = true)
{
    int result = -1;
    int entCnt = GetMaxEntities();
    float dis = -1.0, pos[3], tarPos[3];
    AddVectors(tarPos, origin, tarPos);
    if (IsValidEntity(target)) GetEntPropVector(target, Prop_Send, "m_vecOrigin", tarPos);
    for (int i = MaxClients + 1; i <= entCnt; i++)
    {
        if (!IsValidEntity(i) || IsValidClient(i)) continue;
        char clsName[32];
        GetEntityClassname(i, clsName, sizeof(clsName));
        if (strcmp(clsName, "infected") && (includeWitch && strcmp(clsName, "witch")) && (includeRock && strcmp(clsName, "tank_rock"))) continue;
        if (GetEntProp(i, Prop_Data, "m_lifeState") || !GetEntProp(i, Prop_Data, "m_iHealth")) continue;

        GetEntPropVector(i, Prop_Send, "m_vecOrigin", pos);
        float tmp = GetVectorDistance(tarPos, pos, true);
        if (dis <= tmp && dis != -1) continue;

        result = i;
        dis = tmp;
    }

    return result;
}

/**
 * @brief Returns true if client is incapacitated.
 *
 * @param client    Client index.
 * @return          True if client is incapacitated. False otherwise.
 */
stock bool IsPlayerIncap(int client)
{
    return (IsValidClient(client) && view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated")));
}

/**
 * @brief Returns true if survivor team is full.
 *
 * @return          True if survivor team is full. False otherwise.
 */
stock bool IsSurvivorTeamFull()
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsSurvivor(i) && IsPlayerAlive(i) && IsFakeClient(i))
            return false;

    return true;
}

/**
 * @brief Returns true if survivors are all pinnded.
 *
 * @return          True if survivors are all pinnded. False otherwise.
 */
stock bool IsAllSurvivorPinned()
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsSurvivor(i) && IsPlayerAlive(i) && !(IsSurvivorPinned(i) || IsPlayerIncap(i)))
            return false;

    return true;
}

/**
 * @brief Returns true if survivors are all incapped.
 *
 * @return          True if survivora are all incapped. False otherwise.
 */
stock bool IsAllSurvivorIncapped()
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsSurvivor(i) && !IsPlayerIncap(i))
            return false;

    return true;
}

/**
 * @brief Returns true if player saw threats.
 *
 * @param entity        Entity index.
 * @return              True if player saw threats. False otherwise.
 */
stock bool IsEntitySawThreats(int entity)
{
    return (IsValidEntity(entity) && view_as<bool>(GetEntProp(entity, Prop_Send, "m_hasVisibleThreats")));
}

/**
 * @brief Returns true if any survivor alives.
 *
 * @return          True if any survivor alives. False otherwise.
 */
stock bool HasSurvivorAlive()
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsSurvivor(i) && IsPlayerAlive(i))
            return true;

    return false;
}

/**
 * @brief Returns true if any SI(Special Infected) but not tank alives.
 *
 * @return          True if any SI(Special Infected) but not tank alives. False otherwise.
 */
stock bool HasInfectedAlive(bool includeTank = false)
{
    for (int i = 1; i <= MaxClients; i++)
        if (IsInfected(i) && IsPlayerAlive(i) && !IsPlayerIncap(i))
        {
            if (!includeTank && IsTank(i)) continue;
            return true;
        }

    return false;
}

/**
 * @brief Get tank's frustration.
 *
 * @param tankClient    Client index.
 * @return              Tank's frustration. -1 for false.
 */
stock int GetTankFrustration(int tankClient)
{
    return IsTank(tankClient) ? 100 - GetEntProp(tankClient, Prop_Send, "m_frustration") : -1;
}

/**
 * @brief Set tank's frustration.
 *
 * @param tankClient    Client index.
 * @param frustration   Frustration value.
 * @return              True if succeed. False otherwise.
 */
stock bool SetTankFrustration(int tankClient, int frustration)
{
    if (!IsTank(tankClient)) return false;
    if (frustration < 0 || frustration > 100) return false;

    SetEntProp(tankClient, Prop_Send, "m_frustration", 100 - frustration);
    return true;
}

/**
 * @brief Get player's health.
 *
 * @param client            Client index.
 * @param only_temp    Only client temp health.(Always false if total_heal is true)
 * @param total_heal    Client total health.
 * @return          Player's health. -1 for false.
 */
stock int GetPlayerHealth(int client, bool only_temp = false, bool total_heal = false)
{
    if (!IsValidClient(client)) return -1;
    if (!IsPlayerAlive(client)) return 0;

    if (total_heal) only_temp = true;
    if (!IsSurvivor(client)) only_temp = total_heal = false;

    int temp = 0, health = GetEntProp(client, Prop_Send, "m_iHealth");
    if (only_temp) temp = RoundToCeil(GetEntPropFloat(client, Prop_Send, "m_healthBuffer") - ((GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * FindConVar("pain_pills_decay_rate").FloatValue)) - 1;
    if(temp < 0) temp = 0;
    int result = !total_heal ? (only_temp ? temp : health) : health + temp;

    return result;
}

/**
 * @brief Set player's health.
 *
 * @param client    Client index.
 * @param health    Health value.
 * @return          True if succeed. False otherwise.
 */
stock bool SetPlayerHealth(int client, int health)
{
    if (!IsValidClient(client)) return false;
    if (health < 0) return false;

    SetEntProp(client, Prop_Send, "m_iHealth", health);
    return true;
}

/**
 * Returns whether player is on third strike.
 *
 * @param client        Client index.
 * @return              True if on third strike, false otherwise.
 * @error               Invalid client index.
 */
stock bool IsPlayerOnThirdStrike(int client)
{
    return view_as<bool>(GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike"));
}

/**
 * @brief Execute a command.
 *
 * @param client    Client index.
 * @param strCmd    Command string.
 * @param strPrm    CmdParam string.
 * @return          True if succeed. False otherwise.
 */
stock bool ExecuteCommand(int client, const char[] strCmd, const char[] strPrm = "")
{
    if (!IsValidClient(client)) return false;

    int flags = GetCommandFlags(strCmd);
    SetCommandFlags(strCmd, flags & (~FCVAR_CHEAT));
    FakeClientCommand(client, "%s %s", strCmd, strPrm);
    SetCommandFlags(strCmd, flags);

    return true;
}

/**
 * @brief Get client SI(Special Infected) class.
 *
 * @param client    Client index.
 * @return          SI class. -1 for false.
 */
stock int GetZombieClass(int client)
{
    if (!IsValidClient(client) || !IsInfected(client)) return -1;

    return GetEntProp(client, Prop_Send, "m_zombieClass");
}

/**
 * @brief Get survivor count.
 *
 * @return          Survivor count.
 */
stock int GetSurvivorCount()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsSurvivor(i))
            count++;

    return count;
}

/**
 * @brief Get SI(Special Infected) count.
 *
 * @return          SI count.
 */
stock int GetSICount()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsInfected(i))
            count++;

    return count;
}

/**
 * @brief Get client count without special infected.
 *
 * @return          Client count without special infected.
 */
stock int GetClientNoSICount()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsValidClient(i) && IsClientInGame(i) && !IsInfected(i))
            count++;

    return count;
}

/**
 * @brief Get player survivor count.
 *
 * @return          Player survivor count.
 */
stock int GetSurvivorPlayerCount()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsSurvivor(i) && !IsFakeClient(i))
            count++;

    return count;
}

/**
 * @brief Get player SI(Special Infected) count.
 *
 * @return          Player SI count.
 */
stock int GetInfectedPlayerCount()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsInfected(i) && !IsFakeClient(i))
            count++;

    return count;
}

/**
 * @brief Get alive survivor count.
 *
 * @return          Alive survivor count.
 */
stock int GetAliveSurvivorCount()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsSurvivor(i) && IsPlayerAlive(i))
            count++;

    return count;
}

/**
 * @brief Get alive SI count.
 *
 * @return          Alive SI count.
 */
stock int GetAliveInfectedCount()
{
    int count = 0;
    for (int i = 1; i <= MaxClients; i++)
        if (IsInfected(i) && IsPlayerAlive(i))
            count++;

    return count;
}

/**
 * @brief Clear player's inventory
 *
 * @return          No return.
 */
stock void ClearPlayerInventory(int client)
{
    if (!IsValidClient(client)) return;

    for (int s = 0; s < 5; s++)
    {
        int item = GetPlayerWeaponSlot(client, s);
        if (item > 0) RemovePlayerItem(client, item);
    }
}

/**
 * @brief Uses the VScript "CommandABot" function to command a bot to attack, move, retreat or reset previous command
 *
 * @param entity    The bot or infected to command
 * @param target    The Special Infected to target (used for types "CMDBOT_ATTACK" and "CMDBOT_RETREAT")
 * @param type      Type of command
 * @param pos       Move to this location (Used for type "CMDBOT_MOVE")
 *
 * @return  Returns false when unable to perform, true otherwise.
 */
stock bool CommandABot(int entity, int target = 0, int type, float pos[3] = NULL_VECTOR)
{
    if (!IsValidClient(entity) || !IsFakeClient(entity)) return false;
    char param[PLATFORM_MAX_PATH];
    switch (type)
    {
        case CMDBOT_ATTACK, CMDBOT_RETREAT:
            Format(param, sizeof(param), "CommandABot({cmd = %d, bot = GetPlayerFromUserID(%i), target = GetPlayerFromUserID(%i)})", type, GetClientUserId(entity), GetClientUserId(target));
        case CMDBOT_MOVE:
            Format(param, sizeof(param), "CommandABot({cmd = %d, pos = Vector(%f, %f, %f), bot = GetPlayerFromUserID(%i)})", type, pos[0], pos[1], pos[2], GetClientUserId(entity));
        case CMDBOT_RESET:
            Format(param, sizeof(param), "CommandABot({cmd = %d, bot = GetPlayerFromUserID(%i)})", type, GetClientUserId(entity));

        default:
            return false;
    }

    return ExecuteCommand(entity, "script", param);
}

/**
 * Sets custom ability cooldown of client.
 *
 * Note: Used for the Infected class abilities.
 *
 * @param client        Client index.
 * @param time          How long before client can use their custom ability.
 *
 * @return              True if set, false if no ability found.
 */
stock bool SetAbilityCooldown(int client, float time)
{
    int ability = GetEntPropEnt(client, Prop_Send, "m_customAbility");
    if (ability > 0 && IsValidEdict(ability))
    {
        SetEntPropFloat(ability, Prop_Send, "m_duration", time);
        SetEntPropFloat(ability, Prop_Send, "m_timestamp", GetGameTime() + time);
        return true;
    }
    return false;
}

/**
 * Get entity abs origin.
 *
 * @param entity        Entity index.
 * @param origin        Entity position.
 */
stock void GetEntityAbsOrigin(int entity, float origin[3])
{
    if (!IsValidEntity(entity))
        ThrowError("Invalid entity index %d", entity);
    float mins[3], maxs[3];
    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
    GetEntPropVector(entity, Prop_Send, "m_vecMins", mins);
    GetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs);

    origin[0] += (mins[0] + maxs[0]) * 0.5;
    origin[1] += (mins[1] + maxs[1]) * 0.5;
    origin[2] += (mins[2] + maxs[2]) * 0.5;
}

// stock float GetVectorMinDistanceByPlane(const float vec1[3], const float vec2[3], bool squared = false)
// {
//     float zDis = FloatAbs(vec1[2] - vec2[2]);
//     if(squared) zDis = Pow(zDis, 2.0);
//     float xOyDis = GetVector2Distance(vec1, vec2, squared);

//     return zDis > xOyDis ? xOyDis : zDis;
// }

/**
 * Calculates the distance between two vectors(ignored z axis).
 *
 * @param vec1          First vector.
 * @param vec2          Second vector.
 * @param squared       If true, the result will be squared (for optimization).
 * @return              Vector2D distance.
 */
stock float GetVector2Distance(const float vec1[3], const float vec2[3], bool squared = false)
{
    float vecA[3], vecB[3];
    CopyVector(vec1, vecA);
    CopyVector(vec2, vecB);
    vecA[2] = vecB[2] = 0.0;

    return GetVectorDistance(vecA, vecB, squared);
}

stock void CopyVector(const float origin[3], float vector[3])
{
    for (int i = 0; i < 3; i++)
        vector[i] = origin[i];
}

stock float GetEntityDistance(int ent1, int ent2, bool squared = false)
{
    if (!IsValidEntity(ent1))
        ThrowError("Error: invalid entity index %d", ent1);
    if (!IsValidEntity(ent2))
        ThrowError("Error: invalid entity index %d", ent2);

    float pos1[3], pos2[3];
    if (IsValidClient(ent1))
        GetClientAbsOrigin(ent1, pos1);
    else GetEntityAbsOrigin(ent1, pos1);
    if (IsValidClient(ent2))
        GetClientAbsOrigin(ent2, pos2);
    else GetEntityAbsOrigin(ent2, pos2);

    return GetVectorDistance(pos1, pos2, squared);
}

//== From https://forums.alliedmods.net/showthread.php?t=342637
//== Author: LinLinLin
stock bool IsInClientView(int entity, int client)
{
    float entPos[3], playerPos[3], playerAng[3];
    float eye2entVector[3];
    float eye2fwdVector[3];
    char temp[16];
    GetClientInfo(client, "fov_desired", temp, sizeof(temp));
    int fov = StringToInt(temp);

    GetClientEyePosition(client, playerPos);
    GetEntPropVector(entity, Prop_Data, "m_vecOrigin", entPos);
    MakeVectorFromPoints(playerPos, entPos, eye2entVector);

    GetClientEyeAngles(client, playerAng);
    GetAngleVectors(playerAng, eye2fwdVector, NULL_VECTOR, NULL_VECTOR);

    NormalizeVector(eye2entVector, eye2entVector);
    NormalizeVector(eye2fwdVector, eye2fwdVector);

    float radian = ArcCosine(GetVectorDotProduct(eye2entVector, eye2fwdVector));
    /**
     * let me explain how this degree radian.
     *
     * DotProduct = |a||b|cosθ, this is the vector theorem.
     * we have normalize the vector so |a| = |b| = 1.
     * in this case DotProduct = cosθ.
     * ArcCosine() let us get the radian of θ.
     * FOV is a degree, we need make it become radian.
     */
    return radian <= DegToRad(fov + 0.0) / 2;
}

stock bool IsFirstMap()
{
    int count, entity;
    while ((entity = FindEntityByClassname(entity, "info_landmark")) > 0)
        count++;
    return count < 2 && FindEntityByClassname(0, "trigger_finale") == -1;
}

stock bool IsIntro()
{
    int entity = FindEntityByClassname(0, "terror_gamerules");
    if (!IsValidEntity(entity)) return false;

    return view_as<bool>(GetEntProp(entity, Prop_Send, "m_bInIntro"));
}

stock bool IsMissionFinal()
{
    int count, entity;
    while ((entity = FindEntityByClassname(entity, "info_landmark")) > 0)
        count++;

    return count < 2 && FindEntityByClassname(0, "trigger_finale") > 0;
}

stock void CreateDetour(GameData gamedata, DynamicDetour &detour, DHookCallback callback, const char[] name, bool post = false)
{
    detour = DynamicDetour.FromConf(gamedata, name);
    if (!detour) LogError("Failed to load detour \"%s\" signature.", name);

    if (callback != INVALID_FUNCTION && !detour.Enable(post ? Hook_Post : Hook_Pre, callback))
        LogError("Failed to detour \"%s\".", name);
}