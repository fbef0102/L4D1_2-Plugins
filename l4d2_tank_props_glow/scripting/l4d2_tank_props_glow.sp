#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <dhooks>
#undef REQUIRE_PLUGIN
#tryinclude <l4d2_hittable_control>

#if !defined _l4d2_hittable_control_included
	native bool AreForkliftsUnbreakable();
#endif


#define PLUGIN_VERSION			"2.9-2026/1/11"
#define PLUGIN_NAME			    "l4d2_tank_props_glow"
#define DEBUG 0

public Plugin myinfo =
{
	name = "L4D2 Tank Hittable Glow",
	author = "Harry Potter, Sir, A1m`, Derpduck",
	version = PLUGIN_VERSION,
	description = "Give Hittable Prop Glow when tank is alive + Stop tank props from fading whilst the tank is alive",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	MarkNativeAsOptional("AreForkliftsUnbreakable");

	return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define Z_TANK			8
#define TEAM_INFECTED	3
#define TEAM_SURVIVOR	2
#define TEAM_SPECTATOR	1

#define MAX_EDICTS		2048 //(1 << 11)

ConVar
	g_hTankPropFade = null,
	g_hCvarTankGlowType = null,
	g_hCvarEnable = null,
	g_hCvarRange = null,
	g_hCvarRangeMin = null,
	g_hCvarColor = null,
	g_hCvarTankOnly = null,
	g_hCvarTankSpec = null,
	g_hCvarTankSur = null,
	g_hCvarTankPropsBeGone = null,
	g_hCvarTankPropsAlive = null;

ArrayList
	g_hTankPropsList = null,
	g_hTankPropsGlowList = null,
	g_hTankPropsHitList = null;

float 	g_fCvarTankPropsBeGone = 0.0,
		g_fCvarTankPropsAlive = 0.0;

int
	g_iGlowEntRef[MAX_EDICTS],
	g_iTankClient = -1,
	g_iCvarRange = 0,
	g_iCvarRangeMin = 0,
	g_iCvarColor = 0,
	g_iCvarTankGlowType = 0;

bool
	g_bCvarEnable = false,
	g_bCvarTankOnly = false,
	g_bCvarTankSpec = false,
	g_bCvarTankSur = false,
	g_bTankSpawned = false,
	g_bHittableControlExists = false;

bool g_bKillTankProp;

public void OnPluginStart()
{
	g_hCvarEnable 			= CreateConVar( PLUGIN_NAME ... "_enable", 					"1", 			"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarTankGlowType		= CreateConVar( PLUGIN_NAME ... "_type", 					"0", 			"0=Show Hittable Glow when tank punches hittable prop, 1=Show Hittable Glow when tank spawns", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarColor 			= CreateConVar( PLUGIN_NAME ... "_color", 					"255 255 255", 	"Prop Glow Color, three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue.", CVAR_FLAGS);
	g_hCvarRange 			= CreateConVar( PLUGIN_NAME ... "_range_max", 				"4500", 		"How near to props do players need to be to enable their glow. (0=Any distance)", CVAR_FLAGS, true, 0.0);
	g_hCvarRangeMin 		= CreateConVar( PLUGIN_NAME ... "_range_min", 				"256", 			"How near to props do players need to be to disable their glow. (0=Off)", CVAR_FLAGS, true, 0.0);
	g_hCvarTankOnly 		= CreateConVar( PLUGIN_NAME ... "_tank_only", 				"0", 			"0=All players in infected team can see the glow, 1=Only Tank in infected team can see the glow", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarTankSpec 		= CreateConVar( PLUGIN_NAME ... "_spectators", 				"1", 			"If 1, Spectators can see the glow too", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarTankSur 			= CreateConVar( PLUGIN_NAME ... "_surs", 					"0", 			"If 1, Survivors can see the glow too", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarTankPropsBeGone 	= CreateConVar( PLUGIN_NAME ... "_dissapear_time_death", 	"10.0", 		"Time it takes for hittables that were punched by Tank to dissapear after the Tank dies.", CVAR_FLAGS, true, 1.0);
	g_hCvarTankPropsAlive 	= CreateConVar( PLUGIN_NAME ... "_dissapear_time_alive", 	"0.0", 			"Time it takes for hittables that were punched by Tank to dissapear while tank is alive. (0=Off)", CVAR_FLAGS, true, 0.0);
	CreateConVar(                       	PLUGIN_NAME ... "_version",       			PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                	PLUGIN_NAME);

	GetCvars();
	g_hTankPropFade = FindConVar("sv_tankpropfade");
	g_hCvarEnable.AddChangeHook(TankPropsGlowAllow);
	g_hCvarTankGlowType.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarColor.AddChangeHook(ConVarChanged_Glow);
	g_hCvarRange.AddChangeHook(ConVarChanged_Range);
	g_hCvarRangeMin.AddChangeHook(ConVarChanged_RangeMin);
	g_hCvarTankOnly.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTankSpec.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTankSur.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTankPropsBeGone.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTankPropsAlive.AddChangeHook(ConVarChanged_Cvars);

	g_hTankPropsList = new ArrayList();
	g_hTankPropsGlowList = new ArrayList();
	g_hTankPropsHitList = new ArrayList();

	HookEvent("round_start", TankPropRoundReset, EventHookMode_PostNoCopy);
	HookEvent("round_end", TankPropRoundReset, EventHookMode_PostNoCopy);
	HookEvent("player_spawn", TankPropTankSpawn, EventHookMode_PostNoCopy);
	
	//有插件會在此事件時把Tank變成靈魂克，這之後不會觸發後續的player_spawn事件，譬如使用confoglcompmod
	// ai tank生成時觸發
	// ai tank靈魂狀態時觸發
	// 玩家接管靈魂狀態的ai tank時觸發
	// 玩家失去控制權變成ai tank時觸發
	HookEvent("tank_spawn", TankPropTankSpawn);

	HookEvent("player_death", TankPropTankKilled, EventHookMode_PostNoCopy);
	HookEvent("player_team", ClearVisionEvent);
	HookEvent("tank_frustrated", OnTankFrustrated);
}

public void OnAllPluginsLoaded()
{
	g_bHittableControlExists = LibraryExists("l4d2_hittable_control");
}

public void OnPluginEnd()
{ 
	PluginDisable();
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "l4d2_hittable_control", true)) {
		g_bHittableControlExists = false;
	}
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "l4d2_hittable_control", true)) {
		g_bHittableControlExists = true;
	}
}

//-------------------------------Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hConvar, const char[] sOldValue, const char[] sNewValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_iCvarTankGlowType = g_hCvarTankGlowType.IntValue;
	g_bCvarTankOnly = g_hCvarTankOnly.BoolValue;
	g_bCvarTankSpec = g_hCvarTankSpec.BoolValue;
	g_bCvarTankSur = g_hCvarTankSur.BoolValue;
	g_iCvarRange = g_hCvarRange.IntValue;
	g_iCvarRangeMin = g_hCvarRangeMin.IntValue;
	g_fCvarTankPropsBeGone = g_hCvarTankPropsBeGone.FloatValue;
	g_fCvarTankPropsAlive = g_hCvarTankPropsAlive.FloatValue;

	char sColor[16];
	g_hCvarColor.GetString(sColor, sizeof(sColor));
	g_iCvarColor = GetColor(sColor);
}

void TankPropsGlowAllow(Handle hConVar, const char[] sOldValue, const char[] sNewValue)
{
	GetCvars();

	if (!g_bCvarEnable) {
		PluginDisable();
	} else {
		PluginEnable();
	}
}

void ConVarChanged_Glow(Handle hConVar, const char[] sOldValue, const char[] sNewValue)
{
	GetCvars();

	if (!g_bTankSpawned) return;

	int iRef = INVALID_ENT_REFERENCE, iSize = g_hTankPropsGlowList.Length;
	for (int i = 0; i < iSize; i++) 
	{
		iRef = g_hTankPropsGlowList.Get(i);

		if (IsValidEntRef(iRef)) 
		{
			SetEntProp(iRef, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iRef, Prop_Send, "m_glowColorOverride", g_iCvarColor);
		}
	}
}

void ConVarChanged_Range(ConVar hConVar, const char[] sOldValue, const char[] sNewValue)
{
	GetCvars();

	if (!g_bTankSpawned) return;

	int iRef = INVALID_ENT_REFERENCE, iSize = g_hTankPropsGlowList.Length;
	for (int i = 0; i < iSize; i++) 
	{
		iRef = g_hTankPropsGlowList.Get(i);

		if (IsValidEntRef(iRef)) 
		{
			SetEntProp(iRef, Prop_Send, "m_nGlowRange", g_iCvarRange);
		}
	}
}

void ConVarChanged_RangeMin(ConVar hConVar, const char[] sOldValue, const char[] sNewValue)
{
	GetCvars();

	if (!g_bTankSpawned) return;

	int iRef = INVALID_ENT_REFERENCE, iSize = g_hTankPropsGlowList.Length;
	for (int i = 0; i < iSize; i++) 
	{
		iRef = g_hTankPropsGlowList.Get(i);

		if (IsValidEntRef(iRef)) 
		{
			SetEntProp(iRef, Prop_Send, "m_nGlowRangeMin", g_iCvarRangeMin);
		}
	}
}

//-------------------------------Sourcemod API Forward-------------------------------

public void OnConfigsExecuted()
{
	GetCvars();
	
	if (g_bCvarEnable) PluginEnable();
}

public void OnMapEnd()
{
	DHookRemoveEntityListener(ListenType_Created, PossibleTankPropCreated);

	delete g_hTankPropsList;
	delete g_hTankPropsGlowList;
	delete g_hTankPropsHitList;

	g_hTankPropsList = new ArrayList();
	g_hTankPropsGlowList = new ArrayList();
	g_hTankPropsHitList = new ArrayList();
}

public void OnClientDisconnect(int client)
{
	if(IsAliveTank(client))
	{
		CreateTimer(1.0, TankDeadCheck, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

//analogue public void OnEntityCreated(int iEntity, const char[] sClassName)
void PossibleTankPropCreated(int iEntity, const char[] sClassName)
{
	if (sClassName[0] != 'p') {
		return;
	}

	if (strncmp(sClassName, "prop_physics", 12, false) == 0 || strcmp(sClassName, "prop_car_alarm", false) == 0) { // Hooks c11m4_terminal World Sphere
		// Use SpawnPost to just push it into the Array right away.
		// These entities get spawned after the Tank has punched them, so doing anything here will not work smoothly.
		SDKHook(iEntity, SDKHook_SpawnPost, Hook_PropSpawned);
	}
}

public void OnEntityDestroyed(int entity)
{
	if (g_bKillTankProp) 
		return;
		
	if (!IsValidEntityIndex(entity))
		return;

	int iRef = EntIndexToEntRef(entity);
	int index = g_hTankPropsList.FindValue(iRef);
	if (index != -1) {
		g_hTankPropsList.Erase(index);
	}

	index = g_hTankPropsHitList.FindValue(iRef);
	if (index != -1) {
		g_hTankPropsHitList.Erase(index);
	}

	index = g_hTankPropsGlowList.FindValue(iRef);
	if (index != -1) {
		g_hTankPropsGlowList.Erase(index);
	}
}

//-------------------------------Event-------------------------------

void TankPropRoundReset(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	if(!g_bCvarEnable) return;

	g_bTankSpawned = false;

	UnhookTankProps();
	DHookRemoveEntityListener(ListenType_Created, PossibleTankPropCreated);
}


void TankPropTankSpawn(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	if (!g_bCvarEnable || g_bTankSpawned) {
		return;
	}

	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if(client && IsAliveTank(client))
	{
		UnhookTankProps(false, false);
		HookTankProps();

		DHookRemoveEntityListener(ListenType_Created, PossibleTankPropCreated);
		DHookAddEntityListener(ListenType_Created, PossibleTankPropCreated);

		g_bTankSpawned = true;
	}
}

void TankPropTankKilled(Event hEvent, const char[] sEventName, bool bDontBroadcast)
{
	if (!g_bCvarEnable || !g_bTankSpawned) {
		return;
	}

	int victim = GetClientOfUserId(hEvent.GetInt("userid"));
	if(victim && IsClientInGame(victim) && GetClientTeam(victim) == TEAM_INFECTED && IsTank(victim))
	{
		CreateTimer(1.0, TankDeadCheck, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

void ClearVisionEvent(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bCvarEnable || !g_bTankSpawned) {
		return;
	}
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client && IsClientInGame(client) && !IsFakeClient(client))
	{
		RequestFrame(RecreateHittableGlow);
	}
}

void OnTankFrustrated(Event event, const char[] name, bool dontBroadcast)
{
	if (!g_bCvarEnable || !g_bTankSpawned) {
		return;
	}

	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client && IsClientInGame(client) && !IsFakeClient(client))
	{
		RequestFrame(RecreateHittableGlow);
	}
}

//-------------------------------SDKHOOKS-------------------------------

void PropDamagedPost(int iEntity, int iAttacker, int iInflictor, float fDamage, int iDamageType)
{
	if (!IsValidAliveTank(iAttacker)) return;
	if (iEntity <= MaxClients || !IsValidEntity(iEntity) || !IsValidEntity(iInflictor) || !IsValidEdict(iInflictor)) return;
	if (!GetEntProp(iEntity, Prop_Send, "m_hasTankGlow")) return;

	//PrintToChatAll("tank hit %d", iEntity);

	int entRef = EntIndexToEntRef(iEntity);
	if (g_hTankPropsHitList.FindValue(entRef) == -1) 
	{
		g_hTankPropsHitList.Push(entRef);
		if(g_iCvarTankGlowType == 0) CreateTankPropGlow(iEntity);

		if(g_fCvarTankPropsAlive > 0.0) CreateTimer(g_fCvarTankPropsAlive, Timer_DeleteProp, entRef, TIMER_FLAG_NO_MAPCHANGE);
	}
}

Action OnTransmit(int iEntity, int iClient)
{
	switch (GetClientTeam(iClient)) {
		case TEAM_INFECTED: {
			if (!g_bCvarTankOnly) {
				return Plugin_Continue;
			}

			if (IsTank(iClient)) {
				return Plugin_Continue;
			}

			return Plugin_Handled;
		}
		case TEAM_SPECTATOR: {
			return (g_bCvarTankSpec) ? Plugin_Continue : Plugin_Handled;
		}
		case TEAM_SURVIVOR: {
			return (g_bCvarTankSur) ? Plugin_Continue : Plugin_Handled;
		}
	}

	return Plugin_Handled;
}

void Hook_PropSpawned(int iEntity)
{
	if (iEntity <= MaxClients || !IsValidEntity(iEntity)) {
		return;
	}

	int iRef = EntIndexToEntRef(iEntity);
	if (g_hTankPropsList.FindValue(iRef) == -1) {
		char sModelName[PLATFORM_MAX_PATH];
		GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));

		if (StrContains(sModelName, "atlas_break_ball") != -1 
			|| StrContains(sModelName, "forklift_brokenlift.mdl") != -1) 
		{
			g_hTankPropsList.Push(iRef);
			g_hTankPropsHitList.Push(iRef);
			CreateTankPropGlow(iEntity);
			if(g_fCvarTankPropsAlive > 0.0) CreateTimer(g_fCvarTankPropsAlive, Timer_DeleteProp, iRef, TIMER_FLAG_NO_MAPCHANGE);

		} 
		else if (StrContains(sModelName, "forklift_brokenfork.mdl") != -1) 
		{
			KillEntity(iEntity);
		}
	}
}

//-------------------------------Timer & Frame-------------------------------

Action TankDeadCheck(Handle hTimer)
{
	if (GetTankClient() == -1) 
	{
		KillAllHittableGlow();

		CreateTimer(g_fCvarTankPropsBeGone, TankPropsBeGone);

		g_bTankSpawned = false;
	}

	return Plugin_Continue;
}

Action TankPropsBeGone(Handle hTimer)
{
	if(g_bTankSpawned) return Plugin_Continue;

	UnhookTankProps();
	DHookRemoveEntityListener(ListenType_Created, PossibleTankPropCreated);

	return Plugin_Continue;
}

Action Timer_DeleteProp(Handle hTimer, int ref)
{
	int entity = EntRefToEntIndex(ref);

	if (entity == INVALID_ENT_REFERENCE) return Plugin_Continue;

	KillEntity(entity);

	return Plugin_Continue;
}

void RecreateHittableGlow()
{
	KillAllHittableGlow();

	int iEntity = -1, iSize;
	if(g_iCvarTankGlowType == 0)
	{
		iSize = g_hTankPropsHitList.Length;
		for (int i = 0; i < iSize; i++) 
		{
			iEntity = EntRefToEntIndex(g_hTankPropsHitList.Get(i));

			if (iEntity != INVALID_ENT_REFERENCE) 
			{
				CreateTankPropGlow(iEntity);
			}
		}
	}
	else 
	{
		iSize = g_hTankPropsList.Length;
		for (int i = 0; i < iSize; i++) 
		{
			iEntity = EntRefToEntIndex(g_hTankPropsList.Get(i));

			if (iEntity != INVALID_ENT_REFERENCE) 
			{
				CreateTankPropGlow(iEntity);
			}
		}
	}
}

//-------------------------------Function-------------------------------

void PluginEnable()
{
	g_hTankPropFade.SetBool(false);
}

void PluginDisable()
{
	g_hTankPropFade.SetBool(true);

	UnhookTankProps(true, false);
	DHookRemoveEntityListener(ListenType_Created, PossibleTankPropCreated);

	g_bTankSpawned = false;
	delete g_hTankPropsList;
	delete g_hTankPropsGlowList;
	delete g_hTankPropsHitList;

	g_hTankPropsList = new ArrayList();
	g_hTankPropsGlowList = new ArrayList();
	g_hTankPropsHitList = new ArrayList();
}

void CreateTankPropGlow(int iTarget)
{
	// just in case
	if(IsValidEntRef(g_iGlowEntRef[iTarget]))
	{
		RemoveEntity(g_iGlowEntRef[iTarget]);
		g_iGlowEntRef[iTarget] = 0;
	}

	// Spawn dynamic prop entity
	int iEntity = CreateEntityByName("prop_dynamic_override");
	if (iEntity == -1) {
		return;
	}

	// Get position of hittable
	float vOrigin[3];
	float vAngles[3];
	GetEntPropVector(iTarget, Prop_Send, "m_vecOrigin", vOrigin);
	GetEntPropVector(iTarget, Prop_Data, "m_angRotation", vAngles);

	// Get Client Model
	char sModelName[PLATFORM_MAX_PATH];
	GetEntPropString(iTarget, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));

	// Set new fake model
	SetEntityModel(iEntity, sModelName);
	DispatchSpawn(iEntity);

	// Set outline glow color
	SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 0);
	SetEntProp(iEntity, Prop_Send, "m_nSolidType", 0);
	SetEntProp(iEntity, Prop_Send, "m_nGlowRange", g_iCvarRange);
	SetEntProp(iEntity, Prop_Send, "m_nGlowRangeMin", g_iCvarRangeMin);
	SetEntProp(iEntity, Prop_Send, "m_iGlowType", 2);
	SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", g_iCvarColor);
	AcceptEntityInput(iEntity, "StartGlowing");

	// Set model invisible
	SetEntityRenderMode(iEntity, RENDER_NONE);
	SetEntityRenderColor(iEntity, 0, 0, 0, 0);

	// Set model to hittable position
	TeleportEntity(iEntity, vOrigin, vAngles, NULL_VECTOR);

	// Set model attach to client, and always synchronize
	SetVariantString("!activator");
	AcceptEntityInput(iEntity, "SetParent", iTarget);

	SDKHook(iEntity, SDKHook_SetTransmit, OnTransmit);
	g_iGlowEntRef[iTarget] = EntIndexToEntRef(iEntity);
	g_hTankPropsGlowList.Push(EntIndexToEntRef(iEntity));
}

void KillAllHittableGlow()
{
	int iRef = INVALID_ENT_REFERENCE, iSize = g_hTankPropsGlowList.Length;

	g_bKillTankProp = true;
	for (int i = 0; i < iSize; i++) 
	{
		iRef = g_hTankPropsGlowList.Get(i);

		if (IsValidEntRef(iRef))  KillEntity(iRef);
	}
	g_bKillTankProp = false;

	delete g_hTankPropsGlowList;
	g_hTankPropsGlowList = new ArrayList();
}

bool IsTankProp(int iEntity)
{
	// CPhysicsProp only
	if (!HasEntProp(iEntity, Prop_Send, "m_hasTankGlow")) {
		return false;
	}

	bool bHasTankGlow = (GetEntProp(iEntity, Prop_Send, "m_hasTankGlow", 1) == 1);
	if (!bHasTankGlow) {
		return false;
	}

	// Exception
	bool bAreForkliftsUnbreakable;
	if (g_bHittableControlExists)
	{
		bAreForkliftsUnbreakable = AreForkliftsUnbreakable();
	}
	else
	{
		bAreForkliftsUnbreakable = false;
	}

	char sModel[PLATFORM_MAX_PATH];
	GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	if (strcmp("models/props/cs_assault/forklift.mdl", sModel) == 0 && bAreForkliftsUnbreakable == false) {
		return false;
	}

	return true;
}

void HookTankProps()
{
	int iEntity = MaxClients+1;
	
	while ((iEntity = FindEntityByClassname(iEntity, "prop_physics*")) != -1) 
	{
		if (!IsValidEntity(iEntity)) continue;
		
		if (!IsTankProp(iEntity)) continue;
		
		SDKUnhook(iEntity, SDKHook_OnTakeDamagePost, PropDamagedPost);
		SDKHook(iEntity, SDKHook_OnTakeDamagePost, PropDamagedPost);
		g_hTankPropsList.Push(EntIndexToEntRef(iEntity));
		if(g_iCvarTankGlowType == 1) CreateTankPropGlow(iEntity);
	}
	
	iEntity = MaxClients+1;
	
	while ((iEntity = FindEntityByClassname(iEntity, "prop_car_alarm*")) != -1) 
	{
		if (!IsValidEntity(iEntity)) continue;
		
		if (!IsTankProp(iEntity)) continue;
		
		SDKUnhook(iEntity, SDKHook_OnTakeDamagePost, PropDamagedPost);
		SDKHook(iEntity, SDKHook_OnTakeDamagePost, PropDamagedPost);
		g_hTankPropsList.Push(EntIndexToEntRef(iEntity));
		if(g_iCvarTankGlowType == 1) CreateTankPropGlow(iEntity);
	}
}

void UnhookTankProps(bool bKillGlow = true, bool bKillPropHit = true)
{
	int iRef, iSize;

	for (int i = 0; i < iSize; i++) 
	{
		iRef = g_hTankPropsList.Get(i);
		if (IsValidEntRef(iRef)) SDKUnhook(iRef, SDKHook_OnTakeDamagePost, PropDamagedPost);
	}

	g_bKillTankProp = true;
	if(bKillGlow)
	{
		iSize = g_hTankPropsGlowList.Length;
		for (int i = 0; i < iSize; i++) 
		{
			iRef = g_hTankPropsGlowList.Get(i);

			if (IsValidEntRef(iRef)) KillEntity(iRef);
		}
	}

	if(bKillPropHit)
	{
		iSize = g_hTankPropsHitList.Length;
		for (int i = 0; i < iSize; i++) 
		{
			iRef = g_hTankPropsHitList.Get(i);

			if (IsValidEntRef(iRef)) KillEntity(iRef);
		}
	}
	g_bKillTankProp = false;

	delete g_hTankPropsList;
	delete g_hTankPropsGlowList;
	delete g_hTankPropsHitList;

	g_hTankPropsList = new ArrayList();
	g_hTankPropsGlowList = new ArrayList();
	g_hTankPropsHitList = new ArrayList();
}

bool IsValidEntRef(int iRef)
{
	return (iRef && EntRefToEntIndex(iRef) != INVALID_ENT_REFERENCE);
}

int GetColor(char[] sTemp)
{
	if (strcmp(sTemp, "") == 0) {
		return 0;
	}

	char sColors[3][4];
	int iColor = ExplodeString(sTemp, " ", sColors, 3, 4);

	if (iColor != 3) {
		return 0;
	}

	iColor = StringToInt(sColors[0]);
	iColor += 256 * StringToInt(sColors[1]);
	iColor += 65536 * StringToInt(sColors[2]);

	return iColor;
}

int GetTankClient()
{
	if (g_iTankClient == -1 || !IsValidAliveTank(g_iTankClient)) {
		g_iTankClient = FindTank();
	}

	return g_iTankClient;
}

int FindTank()
{
	for (int i = 1; i <= MaxClients; i++) {
		if (IsAliveTank(i)) {
			return i;
		}
	}

	return -1;
}

bool IsValidAliveTank(int iClient)
{
	return (iClient > 0 && iClient <= MaxClients && IsAliveTank(iClient));
}

bool IsAliveTank(int iClient)
{
	return (IsClientInGame(iClient) && GetClientTeam(iClient) == TEAM_INFECTED && IsPlayerAlive(iClient) && IsTank(iClient));
}

bool IsTank(int iClient)
{
	return (GetEntProp(iClient, Prop_Send, "m_zombieClass") == Z_TANK);
}

void KillEntity(int iEntity)
{
#if SOURCEMOD_V_MINOR > 8
	RemoveEntity(iEntity);
#else
	AcceptEntityInput(iEntity, "Kill");
#endif
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}