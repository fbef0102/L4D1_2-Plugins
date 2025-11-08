/**
 * L4D2 Windows/Linux
 * CTerrorPlayer,m_knockdownTimer + 100 = 死前所持主武器weapon ID
 * CTerrorPlayer,m_knockdownTimer + 104 = 死前所持主武器ammo
 * CTerrorPlayer,m_knockdownTimer + 108 = 死前所持副武器weapon ID
 * CTerrorPlayer,m_knockdownTimer + 112 = 死前所持副武器是否双持
 * CTerrorPlayer,m_knockdownTimer + 116 = 死前所持非手枪副武器EHandle
 */

#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <left4dhooks>

#define DEBUG 0

public Plugin myinfo =
{
	name		= "L4D2 Drop Secondary",
	author		= "HarryPotter",
	version		= "1.0-2025/11/8",
	description	= "Survivor bots will drop their secondary weapon when they were kicked",
	url			= "https://steamcommunity.com/profiles/76561198026784913/"
};

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

ConVar director_no_survivor_bots;
bool g_bCvar_director_no_survivor_bots;

int 
	iOffs_m_hSecondaryHiddenWeaponPreDead = -1,
	iOffs_m_SecondaryWeaponDoublePistolPreDead = -1,
	iOffs_m_SecondaryWeaponIDPreDead = -1;

public void OnPluginStart()
{
	if(g_bL4D2Version)
	{
		iOffs_m_SecondaryWeaponIDPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 108;
		iOffs_m_SecondaryWeaponDoublePistolPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 112;
		iOffs_m_hSecondaryHiddenWeaponPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 116;
	}

	director_no_survivor_bots = FindConVar("director_no_survivor_bots");
	GetOfficialCvars();
	director_no_survivor_bots.AddChangeHook(ConVarChanged_OfficialCvars);
}

void ConVarChanged_OfficialCvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetOfficialCvars();
}

void GetOfficialCvars()
{
    g_bCvar_director_no_survivor_bots = director_no_survivor_bots.BoolValue;
}

public void OnClientDisconnect(int client)
{
	if(!IsClientInGame(client) || !IsClientInKickQueue(client)) return;

	if( (g_bCvar_director_no_survivor_bots && !IsFakeClient(client)) ||
		(!g_bCvar_director_no_survivor_bots && IsFakeClient(client)) )
	{
		if(GetClientTeam(client) == L4D_TEAM_SURVIVOR && IsPlayerAlive(client))
		{
			int iDropWeapon;
			if(g_bL4D2Version && L4D_IsPlayerIncapacitated(client))
			{
				iDropWeapon = GetSecondaryHiddenWeaponPreDead(client);
				if(iDropWeapon <= MaxClients || !IsValidEntity(iDropWeapon))
				{
					iDropWeapon = GetPlayerWeaponSlot(client, 1);
				}
			}
			else
			{
				iDropWeapon = GetPlayerWeaponSlot(client, 1);
			}
			if(iDropWeapon <= MaxClients) return;

			if(GetEntPropEnt(iDropWeapon, Prop_Data, "m_hOwnerEntity") == client)
			{
				float origin[3];
				float ang[3];
				GetClientEyePosition(client, origin);
				GetClientEyeAngles(client, ang);
				SDKHooks_DropWeapon(client, iDropWeapon, origin); //一代與二代如果持雙手槍會掉兩把手槍

				if(g_bL4D2Version)
				{
					for(int i = 1; i <= MaxClients; i++)
					{
						if(!IsClientInGame(i)) continue;

						if(GetSecondaryHiddenWeaponPreDead(i) != iDropWeapon) continue;

						SetSecondaryHiddenWeapon(i, -1);
					}

					SetSecondaryWeaponIDPreDead(client, 1);
					SetSecondaryWeaponDoublePistolPreDead(client, 0);
					SetSecondaryHiddenWeapon(client, -1);
				}
				else
				{
					/*if (GetEntProp(iDropWeapon, Prop_Send, "m_isDualWielding") > 0)
					{
						int entity = CreateEntityByName("weapon_pistol");
						int clip = GetEntProp(iDropWeapon, Prop_Send, "m_iClip1")/2;

						TeleportEntity(entity, origin, NULL_VECTOR, ang);
						DispatchSpawn(entity);
						SetEntProp(entity, Prop_Send, "m_iClip1", clip);

						Event hEvent = CreateEvent("weapon_drop");
						if( hEvent != null )
						{
							hEvent.SetInt("userid", GetClientUserId(client));
							hEvent.SetInt("propid", entity);
							hEvent.Fire();
						}
					}*/
				}
			}
		}
	}
} 

stock int GetSecondaryWeaponIDPreDead(int client)
{
	return GetEntData(client, iOffs_m_SecondaryWeaponIDPreDead);
}

void SetSecondaryWeaponIDPreDead(int client, int data)
{
	SetEntData(client, iOffs_m_SecondaryWeaponIDPreDead, data);
}

stock int GetSecondaryWeaponDoublePistolPreDead(int client)
{
	return GetEntData(client, iOffs_m_SecondaryWeaponDoublePistolPreDead);
}

void SetSecondaryWeaponDoublePistolPreDead(int client, int data)
{
	SetEntData(client, iOffs_m_SecondaryWeaponDoublePistolPreDead, data);
}

int GetSecondaryHiddenWeaponPreDead(int client)
{
	return GetEntDataEnt2(client, iOffs_m_hSecondaryHiddenWeaponPreDead);
}

void SetSecondaryHiddenWeapon(int client, int data)
{
	SetEntData(client, iOffs_m_hSecondaryHiddenWeaponPreDead, data);
}

stock int GetWeaponOwner(int weapon)
{
	return GetEntPropEnt(weapon, Prop_Data, "m_hOwner");
}