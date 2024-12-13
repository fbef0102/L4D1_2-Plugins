#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION 				"1.0h-2024/12/13"

public Plugin myinfo = 
{
	name 			= "[L4D1 & L4D2] CreateSurvivorBot",
	author 			= "MicroLeo (port by Dragokas), Harry",
	description 	= "Provide natives, spawn survivor bots without limit.",
	version 		= PLUGIN_VERSION,
	url 			= "https://github.com/dragokas"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 && test != Engine_Left4Dead  )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	CreateNative("CreateSurvivorBot", NATIVE_CreateSurvivorBot);
	RegPluginLibrary("l4d_CreateSurvivorBot");
	return APLRes_Success;
}

Handle g_hSDK_NextBotCreatePlayerBot;
Handle g_hSDK_RespawnPlayer;

public void OnPluginStart()
{
	GameData hGameData = LoadGameConfigFile("l4d_CreateSurvivorBot");
	if( hGameData == null ) SetFailState("Could not find gamedata file at addons/sourcemod/gamedata/l4d_CreateSurvivorBot.txt , you FAILED AT INSTALLING");

	StartPrepSDKCall(SDKCall_Player);
	if( PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::RoundRespawn") == false )
		SetFailState("Failed to find signature: CTerrorPlayer::RoundRespawn");
	g_hSDK_RespawnPlayer = EndPrepSDKCall();
	if( g_hSDK_RespawnPlayer == null ) SetFailState("Failed to create SDKCall: CTerrorPlayer::RoundRespawn");

	StartPrepSDKCall(SDKCall_Static);
	Address addr = hGameData.GetAddress("NextBotCreatePlayerBot<SurvivorBot>");
	if( addr == Address_Null ) SetFailState("Failed to find signature: NextBotCreatePlayerBot<SurvivorBot> in CDirector::AddSurvivorBot");
	int iOS = hGameData.GetOffset("OS"); // 1 - windows, 2 - linux
	if( iOS == 1 ) // it's hard to get uniq. sig in windows => will use XRef.
	{
		Address offset = view_as<Address>(LoadFromAddress(addr + view_as<Address>(1), NumberType_Int32));
		addr += offset + view_as<Address>(5); // sizeof(instruction)
	}
	if( PrepSDKCall_SetAddress(addr) == false )	SetFailState("Failed to find signature: NextBotCreatePlayerBot<SurvivorBot>");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	g_hSDK_NextBotCreatePlayerBot = EndPrepSDKCall();
	if( g_hSDK_NextBotCreatePlayerBot == null ) SetFailState("Failed to create SDKCall: NextBotCreatePlayerBot<SurvivorBot>");
	
	delete hGameData;
}

int NATIVE_CreateSurvivorBot(Handle plugin, int numParams)
{
	if (GetClientCount(false) >= MaxClients)
	{
		//PrintToServer("[Bot] Not enough player slots");
		return -1;
	}

	int bot = SDKCall(g_hSDK_NextBotCreatePlayerBot, "I am Bot");
	if( bot > 0 && IsValidEntity(bot) )
	{
		ChangeClientTeam(bot, 2);
		
		if( !IsPlayerAlive(bot) )
		{
			SDKCall(g_hSDK_RespawnPlayer, bot);
		}
		return bot;
	}

	return -1;
}