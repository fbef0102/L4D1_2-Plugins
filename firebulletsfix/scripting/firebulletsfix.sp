#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>

public Plugin myinfo =
{
	name = "Bullet position fix",
	author = "xutaxkamay,LuckyServ",
	description = "Fixes shoot position",
	version = "1.0h-2024/3/7",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

Handle g_hWeapon_ShootPosition = INVALID_HANDLE;
float  g_vecOldWeaponShootPos[MAXPLAYERS + 1][3];

public void OnPluginStart()
{
	Handle gameData = LoadGameConfigFile("dhooks.weapon_shootposition");
	
	if (gameData == INVALID_HANDLE)
	{
		SetFailState("[FireBullets Fix] No game data present");
	}
			
	int offset = GameConfGetOffset(gameData, "Weapon_ShootPosition");

	if (offset == -1)
	{
		SetFailState("[FireBullets Fix] failed to find offset");
	}

	g_hWeapon_ShootPosition = DHookCreate(offset, HookType_Entity, ReturnType_Vector, ThisPointer_CBaseEntity);

	if (g_hWeapon_ShootPosition == INVALID_HANDLE)
	{
		SetFailState("[FireBullets Fix] couldn't hook Weapon_ShootPosition");
	}

	CloseHandle(gameData);

	for (int client = 1; client <= MaxClients; client++)
		OnClientPutInServer(client);
}

public void OnClientPutInServer(int client)
{
	if (IsClientConnected(client) && IsClientInGame(client) && !IsFakeClient(client))
	{
		DHookEntity(g_hWeapon_ShootPosition, true, client, _, Weapon_ShootPosition_Post);
	}
}

public Action OnPlayerRunCmd(int client)
{	
	if (IsSurvivor(client) && IsClientConnected(client) && !IsFakeClient(client))
	{
		GetClientEyePosition(client, g_vecOldWeaponShootPos[client]);
	}
		
	return Plugin_Continue;
}

MRESReturn Weapon_ShootPosition_Post(int client, Handle hReturn)
{
    if (IsSurvivor(client)) 
    {
        // At this point we always want to use our old origin.
        DHookSetReturnVector(hReturn, g_vecOldWeaponShootPos[client]);
        return MRES_Supercede;
    }
    return MRES_Ignored;
}

bool IsSurvivor(int client)
{
    return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2;
}