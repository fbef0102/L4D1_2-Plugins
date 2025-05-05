#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

//修正Hunter玩家MIC說話的時候Hunter會發出低吼聲即使Hunter仍然站著不動
#define Hunter_Growl_SOUND1_L4D1	"player/hunter/voice/idle/Hunter_Stalk_01.wav"
#define Hunter_Growl_SOUND4_L4D1 "player/hunter/voice/idle/Hunter_Stalk_04.wav"
#define Hunter_Growl_SOUND5_L4D1 "player/hunter/voice/idle/Hunter_Stalk_05.wav"

#define Hunter_Growl_SOUND1_L4D2	"player/hunter/voice/idle/Hunter_Stalk_01.wav"
#define Hunter_Growl_SOUND4_L4D2 "player/hunter/voice/idle/Hunter_Stalk_04.wav"
#define Hunter_Growl_SOUND5_L4D2 "player/hunter/voice/idle/Hunter_Stalk_05.wav"
#define Hunter_Growl_SOUND6_L4D2 "player/hunter/voice/idle/Hunter_Stalk_06.wav"
#define Hunter_Growl_SOUND7_L4D2 "player/hunter/voice/idle/Hunter_Stalk_07.wav"
#define Hunter_Growl_SOUND8_L4D2 "player/hunter/voice/idle/Hunter_Stalk_08.wav"
#define Hunter_Growl_SOUND9_L4D2 "player/hunter/voice/idle/Hunter_Stalk_09.wav"

#define DEBUG 0

public Plugin myinfo =
{
	name = "Hunter produces growl fix",
	author = "Harry Potter",
	description = "Fix silence Hunter produces growl sound when player MIC on",
	version = "1.5-2025/5/5",
	url = "https://steamcommunity.com/profiles/76561198026784913"
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
	if(g_bL4D2Version)
	{
		PrecacheSound(Hunter_Growl_SOUND1_L4D2);
		PrecacheSound(Hunter_Growl_SOUND4_L4D2);
		PrecacheSound(Hunter_Growl_SOUND5_L4D2);
		PrecacheSound(Hunter_Growl_SOUND6_L4D2);
		PrecacheSound(Hunter_Growl_SOUND7_L4D2);
		PrecacheSound(Hunter_Growl_SOUND8_L4D2);
		PrecacheSound(Hunter_Growl_SOUND9_L4D2);
	}
	else
	{
		PrecacheSound(Hunter_Growl_SOUND1_L4D1);
		PrecacheSound(Hunter_Growl_SOUND4_L4D1);
		PrecacheSound(Hunter_Growl_SOUND5_L4D1);
	}

	AddNormalSoundHook(SI_sh_OnSoundEmitted);
}

Action SI_sh_OnSoundEmitted(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch,int  &flags)
{

	if (numClients >= 1 && IsVaildClient(entity) ){
	
		#if DEBUG
			PrintToChatAll("Sound:%s - numClients %d, entity %d",sample, numClients, entity);
		#endif
		
		//Hunter Stand Still MIC Bug
		if(IsPlayerAlive(entity) && IsHunterGrowlSound(sample) )
		{
			#if DEBUG
				PrintToChatAll("Here");
			#endif
			
			// If they do have the duck button pushed
			if (GetClientButtons(entity) & IN_DUCK){ return Plugin_Continue; }
			
			#if DEBUG
				PrintToChatAll("Block Sound");
			#endif
			
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

bool IsHunterGrowlSound(const char[] sample)
{
	if(g_bL4D2Version)
	{
		if(StrEqual(sample, Hunter_Growl_SOUND1_L4D2) || 
		StrEqual(sample, Hunter_Growl_SOUND4_L4D2) ||
		StrEqual(sample, Hunter_Growl_SOUND5_L4D2) ||
		StrEqual(sample, Hunter_Growl_SOUND6_L4D2) || 
		StrEqual(sample, Hunter_Growl_SOUND7_L4D2) ||
		StrEqual(sample, Hunter_Growl_SOUND8_L4D2) ||
		StrEqual(sample, Hunter_Growl_SOUND9_L4D2) )
			return true;
	}
	else
	{
		if(StrEqual(sample, Hunter_Growl_SOUND1_L4D1) || 
		StrEqual(sample, Hunter_Growl_SOUND4_L4D1) ||
		StrEqual(sample, Hunter_Growl_SOUND5_L4D1) )
			return true;
	}
	  
	return false;
}

bool IsVaildClient(int index)
{
	return index > 0 && index <= MaxClients && IsClientInGame(index);
}