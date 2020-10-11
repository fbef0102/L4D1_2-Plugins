#include <sourcemod>
#include <sdktools>
#include <colors>
static Handle:hCvarFlags;
static CvarFlags_original;

public Plugin:myinfo =
{
	name = "L4D round end alltalk",
	author = "Harry",
	description = "enable alltalk every end round and disable every start.",
	version = "1.0",
	url = "https://steamcommunity.com/id/AkemiHomuraGoddess/"
};

public OnPluginStart()
{
	hCvarFlags = FindConVar("sv_alltalk");
	HookEvent("round_start", eventRSLiveCallback);
	HookEvent("round_end", eventRoundEndCallback);
	
	CvarFlags_original = GetConVarInt(hCvarFlags);
}

public OnConfigsExecuted()
{
	CvarFlags_original = GetConVarInt(hCvarFlags);
}

public eventRSLiveCallback(Handle:event, const String:name[], bool:dontBroadcast)
{
	new cvars1 = GetConVarInt(hCvarFlags);
	SetConvarDefault();
	new cvars2 = GetConVarInt(hCvarFlags);
	
	if(cvars1 == 1 && cvars2 == 0)
		CPrintToChatAll("[{green}AllTalk{default}] {olive}Round End All Talk {default}Off");
}

public eventRoundEndCallback(Handle:event, const String:name[], bool:dontBroadcast)
{
	new cvars = GetConVarInt(hCvarFlags);
	SetConVarInt(hCvarFlags,1);
	
	if(cvars == 0)
		CPrintToChatAll("[{green}AllTalk{default}] {olive}Round End All Talk {default}On");
}

public OnPluginEnd()
{
	SetConvarDefault();
}
public OnMapEnd()
{
	SetConvarDefault();
}
SetConvarDefault()
{
	SetConVarInt(hCvarFlags,CvarFlags_original);
}