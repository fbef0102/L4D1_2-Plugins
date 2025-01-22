#define PLUGIN_VERSION "1.3"

#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define Hunter_Growl_SOUND	"player/hunter/voice/idle/Hunter_Stalk_01.wav"
#define Hunter_Growl_SOUND4 "player/hunter/voice/idle/Hunter_Stalk_04.wav"
#define Hunter_Growl_SOUND5 "player/hunter/voice/idle/Hunter_Stalk_05.wav"
#define Hunter_Growl_SOUND6 "player/hunter/voice/idle/Hunter_Stalk_06.wav"
#define Hunter_Growl_SOUND7 "player/hunter/voice/idle/Hunter_Stalk_07.wav"
#define Hunter_Growl_SOUND8 "player/hunter/voice/idle/Hunter_Stalk_08.wav"
#define Hunter_Growl_SOUND9 "player/hunter/voice/idle/Hunter_Stalk_09.wav"

#define DEBUG 0

public Plugin myinfo =
{
	name = "Hunter produces growl fix",
	author = "Harry Potter",
	description = "Fix silence Hunter produces growl sound when player MIC on",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{
	AddNormalSoundHook(SI_sh_OnSoundEmitted);
}

public Action SI_sh_OnSoundEmitted(int clients[64], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch,int  &flags)
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
	if(StrEqual(sample, Hunter_Growl_SOUND) || 
	   StrEqual(sample, Hunter_Growl_SOUND4) ||
	   StrEqual(sample, Hunter_Growl_SOUND5) ||
	   StrEqual(sample, Hunter_Growl_SOUND6) || 
	   StrEqual(sample, Hunter_Growl_SOUND7) ||
	   StrEqual(sample, Hunter_Growl_SOUND8) ||
	   StrEqual(sample, Hunter_Growl_SOUND9) )
		return true;
	  
	return false;
}

bool IsVaildClient(int index)
{
	return index > 0 && index <= MaxClients && IsClientInGame(index);
}