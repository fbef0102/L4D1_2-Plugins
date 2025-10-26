#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <dhooks>

public Plugin myinfo =
{
	name = "[L4D2 Linux] Chainsaw Server Srash",
	author = "accelerator74, Hawkins93, HarryPotter",
	description = "Fixed Linux Server Crash: server_srv.so!CSoundPatch::ChangePitch(float, float) + 0x6",
	version = "1.0-2025/10/26",
	url = "https://github.com/ValveSoftware/Source-1-Games/issues/2526"
};

public void OnPluginStart()
{
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "gamedata/chainsaw_fix.txt");
	if( !FileExists(sPath) )
	{
		SetFailState("Failed to load gamedata/chainsaw_fix.");
	}

	Handle hGameConf = LoadGameConfigFile("chainsaw_fix");
	if( hGameConf == null ) SetFailState("Failed to load gamedata/chainsaw_fix.");
	Handle hDetour = DHookCreateFromConf(hGameConf, "CSoundPatch::ChangePitch");
	if( !hDetour )
		SetFailState("Failed to find \"CSoundPatch::ChangePitch\" signature.");
	if( !DHookEnableDetour(hDetour, false, ChangePitch) )
		SetFailState("Failed to detour \"CSoundPatch::ChangePitch\".");

	Handle hDetour2 = DHookCreateFromConf(hGameConf, "CSoundControllerImp::SoundChangePitch");
	if( !hDetour2 )
		SetFailState("Failed to find \"CSoundControllerImp::SoundChangePitch\" signature.");
	if( !DHookEnableDetour(hDetour2, false, SoundChangePitch) )
		SetFailState("Failed to detour \"CSoundControllerImp::SoundChangePitch\".");

	delete hDetour;
	delete hDetour2;
	delete hGameConf;
}

// CChainsaw::ItemPostFrame() crash fix
public MRESReturn ChangePitch(int pThis, Handle hReturn, Handle hParams)
{
	if(!pThis)
	{
		DHookSetReturn(hReturn, 0);
		return MRES_Supercede;
	}
	
	return MRES_Ignored;
}

// CChainsaw::ItemPostFrame() crash fix
public MRESReturn SoundChangePitch(int pThis, Handle hReturn, Handle hParams)
{
	if(!pThis)
	{
		DHookSetReturn(hReturn, 0);
		return MRES_Supercede;
	}
	
	return MRES_Ignored;
}