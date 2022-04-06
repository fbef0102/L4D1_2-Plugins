#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define CVAR_FLAGS FCVAR_NOTIFY
#define PLUGIN_VERSION "1.4"

#define sDENY_SOUND "buttons/button11.wav"

float lastSoundTime[MAXPLAYERS+1];
Handle usedAmmos[MAXPLAYERS+1];

ConVar g_hCvarDeniedSound, g_hCvarOneTime, g_hAnnounceType;
bool g_bCvarDeniedSound, g_bCvarOneTime;
int g_iAnnounceType;
int g_iPickAmmoIndex[MAXPLAYERS+1];			// Player Ammo entity reference

public Plugin myinfo = 
{
	name = "[L4D1/2] Limited Ammo Piles",
	author = "Thraka, HarryPotter",
	description = "Once everyone has used the same ammo pile at least once, it is removed.",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=115898"
}

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 && test != Engine_Left4Dead )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	bLate = late;
	return APLRes_Success; 
}

public void OnAllPluginsLoaded() {

	static char smxFileName[32] = "l4d1-2_limited_ammo_pile.smx";
	if ( FindPluginByFile(smxFileName) != null ) 
		SetFailState("Please remove '%s' before using this plugin", smxFileName);
}

public void OnPluginStart() {
	LoadTranslations("l4d_limited_ammo_pile.phrases");

	ResetAllUsedAmmo();

	g_hCvarDeniedSound = CreateConVar("l4d_limited_ammo_pile_denied_sound", "1", "If 1, Play sound when ammo already used.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarOneTime = CreateConVar("l4d_limited_ammo_pile_one_time", "1", "If 1, Each player has only one chance to pick up ammo from each ammo pile. (0=No limit until ammo pile removed)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hAnnounceType = CreateConVar("l4d_limited_ammo_pile_announce_type", "2", "Changes how message displays. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);

	GetCvars();
	g_hCvarDeniedSound.AddChangeHook(OnConVarChange);
	g_hCvarOneTime.AddChangeHook(OnConVarChange);
	g_hAnnounceType.AddChangeHook(OnConVarChange);

	HookEvent("round_start", Event_Round_Start);
	HookEvent("player_bot_replace", OnBotSwap);
	HookEvent("bot_player_replace", OnBotSwap);
	HookEvent("ammo_pickup", Event_AmmoPickup);

	AutoExecConfig(true, "l4d_limited_ammo_pile");

	if(bLate)
	{
		int entity = -1;
		while ((entity = FindEntityByClassname(entity, "weapon_ammo_spawn")) != INVALID_ENT_REFERENCE)
		{
			if (IsValidEdict(entity) && IsValidEntity(entity))
			{
				RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
			}
		}
	}
}

public void OnPluginEnd()
{
	for (int client = 1; client <= MaxClients; client++) {
		delete usedAmmos[client];
	}
}

public void OnMapStart()
{
	PrecacheSound(sDENY_SOUND, true);
}

bool g_bConfigLoaded;
public void OnMapEnd()
{
	g_bConfigLoaded = false;
}

public void OnConfigsExecuted()
{
   g_bConfigLoaded = true;
}

public void OnConVarChange(ConVar convar, char[] oldValue, char[] newValue) {
	GetCvars();
}

void GetCvars()
{
	g_bCvarDeniedSound = g_hCvarDeniedSound.BoolValue;
	g_bCvarOneTime = g_hCvarOneTime.BoolValue;
	g_iAnnounceType = g_hAnnounceType.IntValue;
}

public void OnClientPutInServer (int client) {
	ResetUsedAmmo(client);
}

public void Event_Round_Start(Event event, const char[] name, bool dontBroadcast) {
	ResetAllUsedAmmo();
}

public void OnBotSwap(Event event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(GetEventInt(event, "bot"));
	int player = GetClientOfUserId(GetEventInt(event, "player"));
	int entity;
	if (bot > 0 && bot <= MaxClients && player > 0 && player<= MaxClients) 
	{
		if(usedAmmos[player] != INVALID_HANDLE && usedAmmos[bot] != INVALID_HANDLE)
		{
			int size;
			if (strcmp(name, "player_bot_replace") == 0) 
			{
				size = GetArraySize(usedAmmos[player]);
				for( int i=0 ; i < size ; ++i )
				{
					entity = GetArrayCell(usedAmmos[player], i);
					if(FindValueInArray(usedAmmos[bot], entity) == -1)
					{
						PushArrayCell(usedAmmos[bot], entity);
					}
				}		
			}
			else 
			{
				size = GetArraySize(usedAmmos[bot]);
				for( int i=0 ; i < size ; ++i )
				{
					entity = GetArrayCell(usedAmmos[bot], i);
					if(FindValueInArray(usedAmmos[player], entity) == -1)
					{
						PushArrayCell(usedAmmos[player], entity);
					}
				}
			}
		}
	}
}

//player does picks up ammo from ammo pile
public void Event_AmmoPickup(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (IsPlayerSurvivor(client))
	{
		int entity = g_iPickAmmoIndex[client];
		g_iPickAmmoIndex[client] = 0;
		if( entity && (entity = EntRefToEntIndex(entity)) != INVALID_ENT_REFERENCE )
		{
			PushArrayCell(usedAmmos[client], entity);
			lastSoundTime[client] = GetEngineTime();

			CheckKillAmmo(entity, client);
		}
	}
}

public void OnEntityCreated(int entity, const char[] classname) {
	
	if (!IsValidEntityIndex(entity))
		return;

	switch (classname[0])
	{
		case 'w':
		{
			if (strcmp(classname, "weapon_ammo_spawn") == 0 )
				RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
		}
	}
}

public void OnNextFrame(int entityRef)
{
	int entity = EntRefToEntIndex(entityRef);

	if (entity == INVALID_ENT_REFERENCE)
		return;

	SDKHook(entity, SDKHook_Use, OnAmmoUse);

	int index;
	for (int i = 1; i <= MaxClients; i++) {
		if( (index = FindValueInArray(usedAmmos[i], entity)) != -1 )
			RemoveFromArray(usedAmmos[i],index);
	}
}

public void OnEntityDestroyed(int entity)
{
	if (!IsValidEntityIndex(entity))
		return;

	if (!g_bConfigLoaded)
		return;

	int index;
	for (int i = 1; i <= MaxClients; i++) {
		if( (index = FindValueInArray(usedAmmos[i], entity)) != -1 )
			RemoveFromArray(usedAmmos[i],index);
	}
}

public Action OnAmmoUse(int entity, int activator, int caller, UseType type, float value) {
	
	int client = caller;
	if (!IsPlayerAliveSurvivor(client)) return Plugin_Continue;

	int primaryItem = GetPlayerWeaponSlot(client, 0);
	if (primaryItem == -1) return Plugin_Continue;
	
	//PrintToChatAll("OnAmmoUse: %N, entity: %d", client, entity);

	if (FindValueInArray(usedAmmos[client], entity) != -1) {

		if(!g_bCvarOneTime) return Plugin_Continue;

		if(!IsFakeClient(client)) PlayDeny(client);
		
		CheckKillAmmo(entity, client);
		
		return Plugin_Handled;
	} else {
		g_iPickAmmoIndex[client] = EntIndexToEntRef(entity);
	}

	return Plugin_Continue;
}

void PlayDeny(int client) {
	float currentTime = GetEngineTime();
	if (currentTime > lastSoundTime[client] + 2.0) {
		if (g_bCvarDeniedSound) EmitSoundToClient(client, sDENY_SOUND, client, 3);
		switch(g_iAnnounceType)
		{
			case 0: {/*nothing*/}
			case 1: {
				PrintToChat(client, "[\x05TS\x01] %T", "Block", client);
			}
			case 2: {
				PrintHintText(client, "[TS] %T", "Block", client);
			}
			case 3: {
				PrintCenterText(client, "[TS] %T", "Block", client);
			}
		}
		lastSoundTime[client] = currentTime;
	}
}

void CheckKillAmmo(int entity, int lastclient)
{
	bool bAllSurvivorPickUp = true;
	for(int i =1; i <= MaxClients;++i)
	{
		if(IsPlayerSurvivor(i) && FindValueInArray(usedAmmos[i], entity) == -1) //still someone didn't pick up package
		{
			bAllSurvivorPickUp = false;
			break;
		}
	}

	if(bAllSurvivorPickUp) 
	{
		int index;
		for (int i = 1; i <= MaxClients; i++) {
			if(IsPlayerSurvivor(i) && (index = FindValueInArray(usedAmmos[i], entity)) != -1)
				RemoveFromArray(usedAmmos[i],index);
		}
		
		RemoveEntity(entity);

		switch(g_iAnnounceType)
		{
			case 0: {/*nothing*/}
			case 1: {
				PrintToChat(lastclient, "[\x05TS\x01] %T", "Remove", lastclient);
			}
			case 2: {
				PrintHintText(lastclient, "[TS] %T", "Remove", lastclient);
			}
			case 3: {
				PrintCenterText(lastclient, "[TS] %T", "Remove", lastclient);
			}
		}
	}
}

void ResetAllUsedAmmo() {
	for (int client = 1; client <= MaxClients; client++) {
		ResetUsedAmmo(client);
	}
}

void ResetUsedAmmo(int client) {
	delete usedAmmos[client];
	usedAmmos[client] = CreateArray();
}


bool IsPlayerValid(int client) {
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}

bool IsPlayerSurvivor(int client) {
	return IsPlayerValid(client) && GetClientTeam(client) == 2;
}

bool IsPlayerAliveSurvivor(int client) {
	return IsPlayerSurvivor(client) && IsPlayerAlive(client);
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}