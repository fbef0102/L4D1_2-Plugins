#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin myinfo =
{
	name = "Upgrade Pack Fixes",
	author = "bullet28, V10, Silvers, Harry",
	description = "Fixes upgrade packs pickup bug when using survivor model change + remove upgrade pack",
	version = "1.0h-2024/3/27",
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

#define sDENY_SOUND "buttons/button11.wav"
#define MAXENTITIES                   2048

ConVar cvarDeniedSound, cvarIncendiaryMulti, cvarExplosiveMulti, cvarClearUpgradeTime;

bool cvarDeniedSoundValue;
float cvarIncendiaryMultiValue, cvarExplosiveMultiValue, cvarClearUpgradeTimeValue;

int 
	g_UpgradePackCanUseCount;

ArrayList 
	g_aUsedUpgrades[MAXPLAYERS+1];

float 
	g_fLastSoundTime[MAXPLAYERS+1];

bool 
	g_bUsingExplosive[MAXPLAYERS+1], 
	g_bIsExplosiveAmmo[MAXENTITIES+1];

Handle 
	g_hDeleteTimer[MAXENTITIES+1];

public void OnAllPluginsLoaded() {

	static char smxFileName[32] = "l4d2_upgradepackfix.smx";
	if ( FindPluginByFile(smxFileName) != null ) 
		SetFailState("Please remove '%s' before using this plugin", smxFileName);

	smxFileName = "l4d2_upgrade_block.smx";
	if ( FindPluginByFile(smxFileName) != null ) 
		SetFailState("Please remove '%s' before using this plugin", smxFileName);
}

public void OnPluginStart() {
	Handle hGameData = LoadGameConfigFile("lfd_both_fixUpgradePack");
	g_UpgradePackCanUseCount = GameConfGetOffset(hGameData, "m_iUpgradePackCanUseCount");
	delete hGameData;

	ResetAllUsedUpgrades();

	cvarDeniedSound 		= CreateConVar("lfd_both_fixUpgradePack_denied_sound", 		"1", 	"Play sound when ammo already used", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	cvarIncendiaryMulti 	= CreateConVar("lfd_both_fixUpgradePack_incendiary_multi", 	"1.0", 	"Incendiary ammo multiplier on pickup (Max clip in L4D: 254)", FCVAR_NOTIFY, true, 1.0);
	cvarExplosiveMulti 		= CreateConVar("lfd_both_fixUpgradePack_explosive_multi", 	"1.0", 	"Explosive ammo multiplier on pickup (Max clip in L4D: 254)", FCVAR_NOTIFY, true, 1.0);
	cvarClearUpgradeTime 	= CreateConVar("lfd_both_fixUpgradePack_clear_time", 		"100", 	"Time in seconds to remove upgradepack after first use. (0=off)", FCVAR_NOTIFY, true, 0.0);

	GetCvars();
	cvarDeniedSound.AddChangeHook(OnConVarChange);
	cvarIncendiaryMulti.AddChangeHook(OnConVarChange);
	cvarExplosiveMulti.AddChangeHook(OnConVarChange);
	cvarClearUpgradeTime.AddChangeHook(OnConVarChange);

	HookEvent("round_start", EventRoundStart);
	HookEvent("player_bot_replace", OnBotSwap);
	HookEvent("bot_player_replace", OnBotSwap);

	AutoExecConfig(true, "lfd_both_fixUpgradePack");
}

public void OnMapStart()
{
	PrecacheSound(sDENY_SOUND, true);
}

void OnConVarChange(ConVar convar, char[] oldValue, char[] newValue) {
	GetCvars();
}

void GetCvars()
{
	cvarDeniedSoundValue = cvarDeniedSound.BoolValue;
	cvarIncendiaryMultiValue = cvarIncendiaryMulti.FloatValue;
	cvarExplosiveMultiValue = cvarExplosiveMulti.FloatValue;
	cvarClearUpgradeTimeValue = cvarClearUpgradeTime.FloatValue;
}

public void OnClientDisconnect(int client) {
	ResetUsedUpgrades(client);
}

void EventRoundStart(Event event, const char[] name, bool dontBroadcast) {
	ResetAllUsedUpgrades();
}

void OnBotSwap(Event event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(GetEventInt(event, "bot"));
	int player = GetClientOfUserId(GetEventInt(event, "player"));
	if (bot > 0 && bot <= MaxClients && player > 0 && player<= MaxClients) 
	{
		if(g_aUsedUpgrades[player] != null && g_aUsedUpgrades[bot] != null)
		{
			if (strcmp(name, "player_bot_replace") == 0) 
			{
				delete g_aUsedUpgrades[bot];
				g_aUsedUpgrades[bot] = g_aUsedUpgrades[player];
				g_aUsedUpgrades[player] = new ArrayList();	
			}
			else 
			{
				delete g_aUsedUpgrades[player];
				g_aUsedUpgrades[player] = g_aUsedUpgrades[bot];
				g_aUsedUpgrades[bot] = new ArrayList();	
			}
		}
	}
}

void ResetAllUsedUpgrades() 
{
	for (int client = 1; client <= MaxClients; client++) 
	{
		ResetUsedUpgrades(client);
	}
}

void ResetUsedUpgrades(int client) {
	delete g_aUsedUpgrades[client];
	g_aUsedUpgrades[client] = new ArrayList();
}

public void OnEntityCreated(int entity, const char[] classname) {

	if (!IsValidEntityIndex(entity))
		return;

	switch(classname[0])
	{
		case 'u':
		{
			if (strcmp(classname, "upgrade_ammo_explosive", false) == 0)
			{
				RequestFrame(NextFrame_explosive, EntIndexToEntRef(entity));
			}
			else if	(strcmp(classname, "upgrade_ammo_incendiary", false) == 0)
			{
				RequestFrame(NextFrame_incendiary, EntIndexToEntRef(entity));
			}
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if (!IsValidEntityIndex(entity))
		return;

	delete g_hDeleteTimer[entity];
}

void NextFrame_explosive(int entRef)
{
	int entity = EntRefToEntIndex(entRef);

	if( entity == INVALID_ENT_REFERENCE ) return;
	
	SDKHook(entity, SDKHook_Use, OnUpgradeUse);
	g_bIsExplosiveAmmo[entity] = true;

	int index;
	for (int i = 1; i <= MaxClients; i++) 
	{
		if((index = g_aUsedUpgrades[i].FindValue(entRef)) != -1)
			g_aUsedUpgrades[i].Erase(index);
	}
} 

void NextFrame_incendiary(int entRef)
{
	int entity = EntRefToEntIndex(entRef);

	if( entity == INVALID_ENT_REFERENCE ) return;
	
	SDKHook(entity, SDKHook_Use, OnUpgradeUse);
	g_bIsExplosiveAmmo[entity] = false;

	int index;
	for (int i = 1; i <= MaxClients; i++) 
	{
		if((index = g_aUsedUpgrades[i].FindValue(entRef)) != -1)
			g_aUsedUpgrades[i].Erase(index);
	}
} 

Action OnUpgradeUse(int entity, int activator, int caller, UseType type, float value) 
{
	SetEntData(entity, g_UpgradePackCanUseCount, 127, 1, true);

	int client = caller;
	if (!isPlayerSurvivor(client)) return Plugin_Continue;

	int primaryItem = GetPlayerWeaponSlot(client, 0);
	if (primaryItem == -1) return Plugin_Continue;

	g_bUsingExplosive[client] = g_bIsExplosiveAmmo[entity] ;
	
	if(!IsFakeClient(client)) //prevent bot taken action loop
		SetEntProp(entity, Prop_Send, "m_iUsedBySurvivorsMask", 0);

	int entRef = EntIndexToEntRef(entity);
	
	if (g_aUsedUpgrades[client].FindValue(entRef) != -1) 
	{
		PlayDenySound(client);
		CheckKillPackage(entity);
		return Plugin_Handled;
	} 

	//PrintToChatAll("%f: First use of %N", GetGameTime(), client);
	g_aUsedUpgrades[client].Push(entRef);
	g_fLastSoundTime[client] = GetEngineTime();
	SetUsedBySurvivor(client, entity);

	if ((g_bUsingExplosive[client] && cvarExplosiveMultiValue > 1.0) || (!g_bUsingExplosive[client] && cvarIncendiaryMultiValue > 1.0)) {
		SDKHook(client, SDKHook_PostThink, PostThinkMultiply);
	}
	CheckKillPackage(entity);

	return Plugin_Continue;
}

void PostThinkMultiply(int client) 
{
	if (isPlayerAliveSurvivor(client)) {
		int primaryItem = GetPlayerWeaponSlot(client, 0);
		if (primaryItem != -1) {
			int currentUpgradedAmmo = GetEntProp(primaryItem, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded");
			int targetUpgradedAmmo = RoundToFloor(currentUpgradedAmmo * (g_bUsingExplosive[client] ? cvarExplosiveMultiValue : cvarIncendiaryMultiValue));
			targetUpgradedAmmo = (targetUpgradedAmmo >= 255) ? 254 : targetUpgradedAmmo;
			if (targetUpgradedAmmo > currentUpgradedAmmo) {
				SetEntProp(primaryItem, Prop_Send, "m_nUpgradedPrimaryAmmoLoaded", targetUpgradedAmmo);
			}
		}
	}

	SDKUnhook(client, SDKHook_PostThink, PostThinkMultiply);
}

void SetUsedBySurvivor(int client, int entity) {
	int usedMask = GetEntProp(entity, Prop_Send, "m_iUsedBySurvivorsMask");
	bool bAlreadyUsed = !(usedMask & (1 << client - 1));
	if (bAlreadyUsed) return;

	int newMask = usedMask | (1 << client - 1);
	SetEntProp(entity, Prop_Send, "m_iUsedBySurvivorsMask", newMask);
}

void PlayDenySound(int client) {
	if (cvarDeniedSoundValue) {
		float currentTime = GetEngineTime();
		if (currentTime > g_fLastSoundTime[client] + 2.0) {
			if(!IsFakeClient(client)) EmitSoundToClient(client, sDENY_SOUND, client, SNDCHAN_ITEM);
			g_fLastSoundTime[client] = currentTime;
		}
	}
}

void CheckKillPackage(int entity)
{
	int entRef = EntIndexToEntRef(entity);

	bool bAllSurvivorPickUp = true;
	for(int i =1; i <= MaxClients;++i)
	{
		if(isPlayerSurvivor(i) && g_aUsedUpgrades[i].FindValue(entRef) == -1) //still someone didn't pick up package
		{
			bAllSurvivorPickUp = false;
			break;
		}
	}

	if(bAllSurvivorPickUp) 
	{
		int index;
		for (int i = 1; i <= MaxClients; i++) 
		{
			if((index = g_aUsedUpgrades[i].FindValue(entRef)) != -1)
				g_aUsedUpgrades[i].Erase(index);
		}

		AcceptEntityInput(entRef, "Kill");
		return;
	}
	
	if(g_hDeleteTimer[entity] == null && cvarClearUpgradeTimeValue > 0.0) 
	{
		delete g_hDeleteTimer[entity];
		DataPack hPack;
		g_hDeleteTimer[entity] = CreateDataTimer(cvarClearUpgradeTimeValue, Timer_RemoveEntity, hPack);
		hPack.WriteCell(entity);
		hPack.WriteCell(EntIndexToEntRef(entity));
	}
}

Action Timer_RemoveEntity(Handle timer, DataPack hPack)
{
	hPack.Reset();
	int index = hPack.ReadCell();
	int entity = EntRefToEntIndex(hPack.ReadCell());
	g_hDeleteTimer[index] = null;

	if(entity != INVALID_ENT_REFERENCE )
	{
		RemoveEntity(entity);
	}

	return Plugin_Continue;
}

bool isPlayerValid(int client) 
{
	return client > 0 && client <= MaxClients && IsClientInGame(client);
}

bool isPlayerSurvivor(int client) {
	return isPlayerValid(client) && GetClientTeam(client) == 2;
}

bool isPlayerAliveSurvivor(int client) {
	return isPlayerSurvivor(client) && IsPlayerAlive(client);
}


bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}