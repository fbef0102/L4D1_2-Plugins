#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <dhooks>

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	bLate = late;
	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "[L4D2 Windows/Linux] Chainsaw Crash",
	author = "accelerator74, Hawkins93, HarryPotter, Forgetest",
	description = "Fixed Chainsaw Crash: CSoundPatch::ChangePitch, CSoundControllerImp::SoundChangePitch, CChainsaw::Drop",
	version = "1.1-2026/11/3",
	url = "https://github.com/ValveSoftware/Source-1-Games/issues/2526"
};

public void OnPluginStart()
{
	GameData hGameConf = new GameData("l4d2_chainsaw_fix");
	if( hGameConf == null ) SetFailState("Failed to load gamedata/l4d2_chainsaw_fix.");
	DynamicDetour hDetour = DynamicDetour.FromConf(hGameConf, "CSoundPatch::ChangePitch");
	if( !hDetour )
		SetFailState("Failed to find \"CSoundPatch::ChangePitch\" signature.");
	if( !hDetour.Enable(Hook_Pre, ChangePitch) )
		SetFailState("Failed to detour \"CSoundPatch::ChangePitch\".");

	DynamicDetour hDetour2 = DynamicDetour.FromConf(hGameConf, "CSoundControllerImp::SoundChangePitch");
	if( !hDetour2 )
		SetFailState("Failed to find \"CSoundControllerImp::SoundChangePitch\" signature.");
	if( !hDetour2.Enable(Hook_Pre, SoundChangePitch) )
		SetFailState("Failed to detour \"CSoundControllerImp::SoundChangePitch\".");

	delete hDetour;
	delete hDetour2;
	delete hGameConf;

    if(bLate)
    {
        LateLoad();
    }
}

void LateLoad()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
            continue;

        OnClientPutInServer(client);
    }
}

// 1.
// Issue: https://github.com/ValveSoftware/Source-1-Games/issues/2526
// CSoundPatch::ChangePitch crash fix
// 0 server_srv.so!CSoundPatch::ChangePitch(float, float) + 0x6
//
// int __cdecl CSoundPatch::ChangePitch(CSoundPatch *this, float a2, float a3)
// CSoundPatch *this 為 null
MRESReturn ChangePitch(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if(!pThis)
	{
		hReturn.Value = 0;
		return MRES_Supercede;
	}
	
	return MRES_Ignored;
}

// 2.
// https://github.com/ValveSoftware/Source-1-Games/issues/3607
// CSoundControllerImp::SoundChangePitch crash fix
// 0: server_srv.so!CSoundControllerImp::SoundChangePitch(CSoundPatch*, float, float) + 0x10
//
// int __cdecl CSoundControllerImp::SoundChangePitch(CSoundControllerImp *this, CSoundPatch *a2, float a3, float a4)
// CSoundPatch*a2 為 null
//
// 如何觸發這個crash: 快倒地的血量時拿著電鋸對著地上的瓦斯桶開始攻擊->崩潰
MRESReturn SoundChangePitch(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	if(!pThis || hParams.IsNull(1))
	{
		hReturn.Value = 0;
		return MRES_Supercede;
	}
	
	return MRES_Ignored;
}

// 3.
// 推测有switch插件 給玩家equip電鋸但不会直接切出来 或是 过关之后电锯equip但是没有切出来
// 没有切出来就导致电锯里的owner指针没有update，然后再拿一下别的副武器，就炸了
// int __cdecl CChainsaw::Drop(CSoundPatch **a1, int a2)
// {
//   if ( a1[1537] )
//   {
//     CChainsaw::StopSound((CChainsaw *)a1, a1 + 1533, 0.0);
//     CChainsaw::StopSound((CChainsaw *)a1, a1 + 1534, 0.0);
//     CChainsaw::StopSound((CChainsaw *)a1, a1 + 1535, 0.0);
//     CChainsaw::StopSound((CChainsaw *)a1, a1 + 1536, 0.0);
//     CBasePlayer::RumbleEffect(a1[1537], 0x1Eu, 0, 1u); <-- 電鋸內部存的玩家指標a1[1537]指向了一個已經無效的記憶體區段，傳入CBasePlayer::RumbleEffect
//     CBasePlayer::RumbleEffect(a1[1537], 0x1Fu, 0, 1u); 
//   }
//   return CTerrorWeapon::Drop((CBaseCombatWeapon *)a1, a2);
// }
//
// void __cdecl CBasePlayer::RumbleEffect(CBasePlayer *this, unsigned __int8 a2, unsigned __int8 a3, unsigned __int8 a4)
// {
//   _DWORD v4[14]; // [esp+10h] [ebp-38h] BYREF
// 
//   if ( (*(unsigned __int8 (__cdecl **)(CBasePlayer *))(*(_DWORD *)this + 300))(this) <-- Crash: CBasePlayer *this 已為無效的記憶體區段
//     && !(*(unsigned __int8 (__cdecl **)(CBasePlayer *))(*(_DWORD *)this + 1912))(this) )
//   {
//     ...
//   }
// }

#define MAXENTITIES                   2048
bool g_bIsChainsaw[MAXENTITIES+1];
public void OnEntityCreated(int entity, const char[] classname)
{
    if (!IsValidEntityIndex(entity))
        return;

	g_bIsChainsaw[entity] = false;
    switch (classname[0])
    {
        case 'w':
        {
            if (StrEqual(classname, "weapon_chainsaw"))
                g_bIsChainsaw[entity] = true;
        }
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);
}

void OnWeaponEquipPost(int client, int weapon)
{
	if (client <= 0)
		return;

	if (weapon <= MaxClients)
		return;

	if (!g_bIsChainsaw[weapon])
		return;

	static int s_iOffs_m_pChainsawOwner = -1;
	if (s_iOffs_m_pChainsawOwner == -1)
		s_iOffs_m_pChainsawOwner = FindSendPropInfo("CChainsaw", "m_bHitting") + 32;

	//if(GetEntData(weapon, s_iOffs_m_pChainsawOwner))
	//	return;
	
	SetEntData(weapon, s_iOffs_m_pChainsawOwner, GetEntityAddress(client), 4);
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= MAXENTITIES);
}