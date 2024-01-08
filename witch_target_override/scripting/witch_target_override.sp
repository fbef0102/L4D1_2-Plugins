//Harry @ 2021~2022

#pragma semicolon 1
#pragma newdecls required
#define PLUGIN_VERSION "1.8"
#define DEBUG 0

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define L4D_TEAM_SPECTATOR		1
#define L4D_TEAM_SURVIVORS 		2
#define L4D_TEAM_INFECTED 		3
#define Pai 3.14159265358979323846 
#define MAXENTITY 2048

public Plugin myinfo = 
{
	name = "Witch Target Override",
	author = "xZk, BHaType, HarryPotter",
	description = "Change target when the witch incapacitates or kills victim + witchs auto follow survivors",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

bool L4D2Version;
int anim_ducking, anim_walk;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		L4D2Version = false;
		anim_ducking = 2;
		anim_walk=6; 
	}
	else if( test == Engine_Left4Dead2 )
	{
		L4D2Version = true;
		anim_ducking = 4; 
		anim_walk=10; 
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

ConVar g_hCvarAllow, g_hCvarIncapOverride, g_hCvarKillOverride,
    g_hCvarIncapOverrideHealth, g_hCvarKillOverrideHealth, g_hRequiredRange, g_hCvarReCalculateBurnOverride,
    g_hWitchChanceFollowsurvivor, g_hWitchFollowRange, g_hWitchFollowSpeed;
ConVar z_witch_burn_time;
int g_iCvarIncapOverrideHealth, g_iCvarKillOverrideHealth, g_iWitchChanceFollowsurvivor;
bool g_bCvarAllow, g_bCvarIncapOverride, g_bCvarKillOverride, g_bCvarReCalculateBurnOverride;
float g_fRequiredRange, g_fWitchFollowRange, g_fWitchFollowSpeed;
float witch_burn_time;

int Enemy[MAXENTITY+1];
float ActionTime[MAXENTITY+1], EnemyTime[MAXENTITY+1], StuckTime[MAXENTITY+1], PauseTime[MAXENTITY+1], LastTime[MAXENTITY+1], 
    TargetDir[MAXENTITY+1][3], LastPos[MAXENTITY+1][3], LastSetPos[MAXENTITY+1][3];
bool bWitchScared[MAXENTITY+1], bWitchSit[MAXENTITY+1];
Handle BurnWitchTimer[MAXENTITY+1] = {null};
bool ge_bInvalidTrace[MAXENTITY+1];
float  g_fVPlayerMins[3] = {-16.0, -16.0,  0.0};
float  g_fVPlayerMaxs[3] = { 16.0,  16.0, 71.0};
static bool   g_bConfigLoaded;

public void OnPluginStart()
{
	g_hCvarAllow = CreateConVar("witch_target_override_on", "1", "1=Plugin On. 0=Plugin Off", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarIncapOverride = CreateConVar("witch_target_override_incap", "1", "If 1, allow witch to chase another target after she incapacitates a survivor.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarKillOverride = CreateConVar("witch_target_override_kill", "1", "If 1, allow witch to chase another target after she kills a survivor.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarIncapOverrideHealth = CreateConVar("witch_target_override_incap_health_add", "100", "Add witch health if she is allowed to chase another target after she incapacitates a survivor. (0=Off)", FCVAR_NOTIFY, true, 0.0, true, 9999.0);
	g_hCvarKillOverrideHealth = CreateConVar("witch_target_override_kill_health_add", "400", "Add witch health if she is allowed to chase another target after she kills a survivor. (0=Off)", FCVAR_NOTIFY, true, 0.0, true, 9999.0);
	g_hRequiredRange = CreateConVar("witch_target_override_range", "9999", "This controls the range for witch to reacquire another target. [1.0, 9999.0] (If no targets within range, witch default behavior)", FCVAR_NOTIFY, true, 1.0, true, 9999.0);
	g_hCvarReCalculateBurnOverride = CreateConVar("witch_target_override_recalculate_burn_time", "0", "If 1, the burning witch restarts and recalculates burning time if she is allowed to chase another target. (0=after witch burns for a set amount of time z_witch_burn_time, she dies from the fire)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hWitchChanceFollowsurvivor = CreateConVar("witch_target_override_chance_followsurvivor", "100", "Chance of following survivors [0, 100]", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	g_hWitchFollowRange = CreateConVar("witch_target_override_followsurvivor_range", "500.0", "Witch's vision range , witch will follow you if in range. [100.0, 9999.0] ", FCVAR_NOTIFY, true, 100.0, true, 9999.0);
	g_hWitchFollowSpeed = CreateConVar("witch_target_override_followsurvivor_speed", "45.0", "Witch's following speed.", FCVAR_NOTIFY, true, 1.0);

	z_witch_burn_time = FindConVar("z_witch_burn_time");

	GetCvars();
	g_hCvarAllow.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarIncapOverride.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarKillOverride.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarIncapOverrideHealth.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarKillOverrideHealth.AddChangeHook(ConVarChanged_Cvars);
	g_hRequiredRange.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarReCalculateBurnOverride.AddChangeHook(ConVarChanged_Cvars);
	g_hWitchChanceFollowsurvivor.AddChangeHook(ConVarChanged_Cvars);
	g_hWitchFollowRange.AddChangeHook(ConVarChanged_Cvars);
	g_hWitchFollowSpeed.AddChangeHook(ConVarChanged_Cvars);
	z_witch_burn_time.AddChangeHook(ConVarChanged_Cvars);

	#if DEBUG
		RegConsoleCmd("sm_test", sm_insult);
	#endif

	HookEvent("player_incapacitated", Player_Incapacitated);
	HookEvent("player_death", Player_Death);
	HookEvent("witch_spawn", witch_spawn);
	HookEvent("witch_harasser_set", WitchHarasserSet_Event);
	HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy); //對抗模式下會觸發兩次 (第一次人類滅團之時 第二次隊伍換邊之時)
	HookEvent("map_transition", Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役模式下過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役模式下滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,	EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)

	//Autoconfig for plugin
	AutoExecConfig(true, "witch_target_override");
}

public void OnPluginEnd()
{
	ResetTimer();
}

public void OnMapEnd()
{
	ResetTimer();
	g_bConfigLoaded = false;
}

public void OnConfigsExecuted()
{
    g_bConfigLoaded = true;
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarAllow = g_hCvarAllow.BoolValue;
	g_bCvarIncapOverride = g_hCvarIncapOverride.BoolValue;
	g_bCvarKillOverride = g_hCvarKillOverride.BoolValue;
	g_iCvarIncapOverrideHealth = g_hCvarIncapOverrideHealth.IntValue;
	g_iCvarKillOverrideHealth = g_hCvarKillOverrideHealth.IntValue;
	g_fRequiredRange = g_hRequiredRange.FloatValue;
	g_bCvarReCalculateBurnOverride = g_hCvarReCalculateBurnOverride.BoolValue;
	g_iWitchChanceFollowsurvivor = g_hWitchChanceFollowsurvivor.IntValue;
	g_fWitchFollowRange = g_hWitchFollowRange.FloatValue;
	g_fWitchFollowSpeed = g_hWitchFollowSpeed.FloatValue;
	witch_burn_time = z_witch_burn_time.FloatValue;
}

#if DEBUG
Action sm_insult ( int client, int args )
{
    if(client == 0 || g_bCvarAllow == false) return Plugin_Handled;

    int target = GetClientAimTarget(client);
    
    if ( target == -1 )
        return Plugin_Handled;

    int witch = -1;
    while ( (witch = FindEntityByClassname(witch, "witch")) && IsValidEntity(witch) )
    {
        WitchAttackTarget(witch, target, 0);
    }

    return Plugin_Handled;
}
#endif

void Player_Incapacitated(Event event, const char[] event_name, bool dontBroadcast)
{
    if(g_bCvarAllow == false || g_bCvarIncapOverride == false) return;

    int victim = GetClientOfUserId(event.GetInt("userid"));
    int entity = event.GetInt("attackerentid");
    if (IsWitch(entity) && victim > 0 && victim <= MaxClients && IsSurvivor(victim))
    {
        int target = GetNearestSurvivorDist(entity);
        if(target == 0) return;

        WitchAttackTarget(entity, target, g_iCvarIncapOverrideHealth);
    }
}

void Player_Death(Event event, const char[] event_name, bool dontBroadcast)
{
    if(g_bCvarAllow == false || g_bCvarKillOverride == false ) return;

    int victim = GetClientOfUserId(event.GetInt("userid"));
    int entity = event.GetInt("attackerentid");
    if (IsWitch(entity) && victim > 0 && victim <= MaxClients && IsSurvivor(victim))
    {
        int target = GetNearestSurvivorDist(entity);
        if(target == 0) return;

        WitchAttackTarget(entity, target, g_iCvarKillOverrideHealth);
    }
}

void WitchAttackTarget(int witch, int target, int addHealth)
{
	if(GetEntProp(witch, Prop_Data, "m_iHealth") < 0) return;
	#if DEBUG
		PrintToChatAll("witch attacking new target %N, her max health: %d, now health: %d", target, GetEntProp(witch, Prop_Data, "m_iMaxHealth"), GetEntProp(witch, Prop_Data, "m_iHealth"));
	#endif

	if(addHealth > 0)
	{
		SetEntProp(witch, Prop_Data, "m_iHealth", GetEntProp(witch, Prop_Data, "m_iHealth") + addHealth);
	}

	if(GetEntityFlags(witch) & FL_ONFIRE )
	{
		ExtinguishEntity(witch);
		int flame = GetEntPropEnt(witch, Prop_Send, "m_hEffectEntity");
		if( flame != -1 )
		{
			AcceptEntityInput(flame, "Kill");
		}

		SDKHooks_TakeDamage(witch, target, target, 0.0, DMG_BURN);
	}
	else
	{
		int anim = GetEntProp(witch, Prop_Send, "m_nSequence");
		SDKHooks_TakeDamage(witch, target, target, 0.0, DMG_BURN);
		SetEntProp(witch, Prop_Send, "m_nSequence", anim);
		SetEntProp(witch, Prop_Send, "m_bIsBurning", 0);
		SDKHook(witch, SDKHook_ThinkPost, PostThink);
	}
}

void PostThink(int witch)
{
	SDKUnhook(witch, SDKHook_ThinkPost, PostThink);

	ExtinguishEntity(witch);

	int flame = GetEntPropEnt(witch, Prop_Send, "m_hEffectEntity");
	if( flame != -1 )
	{
		AcceptEntityInput(flame, "Kill");
	}
}

int GetNearestSurvivorDist(int entity)
{
    int target = 0, IncapTarget= 0;
    float s_fRequiredRange = Pow (g_fRequiredRange, 2.0);
    float Origin[3], TOrigin[3], distance = 0.0;
    float fMinDistance = 0.0, fMinIncapDistance = 0.0;
    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Origin);
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsSurvivor(i) && IsPlayerAlive(i))
        {
            GetEntPropVector(i, Prop_Send, "m_vecOrigin", TOrigin);
            distance = GetVectorDistance(Origin, TOrigin, true);
            if (s_fRequiredRange >= distance)
            {
                if(IsPlayerIncapOrHanging(i))
                {
                    if (fMinIncapDistance == 0.0 || fMinIncapDistance > distance)
                    {
                        fMinIncapDistance = distance;
                        IncapTarget = i;
                    } 
                }
                else
                {
                    if (fMinDistance == 0.0 || fMinDistance > distance)
                    {
                        fMinDistance = distance;
                        target = i;
                    } 
                }
            }
        }
    }

    if(target == 0) return IncapTarget;

    return target;
}

bool IsSurvivor(int client)
{
	if (IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_SURVIVORS)
	{
		return true;
	}
	return false;   
}


bool IsPlayerIncapOrHanging(int client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated")) 
		return true;
	if (GetEntProp(client, Prop_Send, "m_isHangingFromLedge") || GetEntProp(client, Prop_Send, "m_isFallingFromLedge"))
		return true;

	return false;
}


void WitchHarasserSet_Event(Event event, const char[] name, bool dontBroadcast)
{
	int witchid = event.GetInt("witchid");
	bWitchScared[witchid] = true;
}

//witch follows survivor
void witch_spawn(Event event, const char[] event_name, bool dontBroadcast)
{
	if(g_bCvarAllow == false || GetRandomInt(0, 100) > g_iWitchChanceFollowsurvivor ) return;

	int witchid = event.GetInt("witchid");
	bWitchScared[witchid] = false;
	bWitchSit[witchid] = false;
	CreateTimer(0.5, DelayHookWitch, EntIndexToEntRef(witchid), TIMER_FLAG_NO_MAPCHANGE );

	SDKHook(witchid, SDKHook_OnTakeDamageAlivePost, OnTakeDamageWitchPost);	

	if(g_bCvarReCalculateBurnOverride == false)
	{
		delete BurnWitchTimer[witchid];
	}
}

Action DelayHookWitch(Handle timer, int ref)
{
	int witch;
	if(g_bCvarAllow && ref && (witch = EntRefToEntIndex(ref)) != INVALID_ENT_REFERENCE)
	{
		StartHookWitch(witch);
	}

	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
    if (!g_bConfigLoaded)
        return;

    if (!IsValidEntityIndex(entity))
        return;

    switch (classname[0])
    {
        case 't':
        {
            if (StrEqual(classname, "tank_rock"))
                ge_bInvalidTrace[entity] = true;
        }
        case 'i':
        {
            if (StrEqual(classname, "infected"))
                ge_bInvalidTrace[entity] = true;
        }
        case 'w':
        {
            if (StrEqual(classname, "witch"))
                ge_bInvalidTrace[entity] = true;
        }
    }
}


public void OnEntityDestroyed(int entity)
{
	if (!IsValidEntityIndex(entity))
		return;

	StopHookWitch(entity);
	bWitchScared[entity] = false;
	bWitchSit[entity] = false;
	delete BurnWitchTimer[entity];

	ge_bInvalidTrace[entity] = false;
}

void StartHookWitch(int witch)
{
	StopHookWitch(witch);

	EnemyTime[witch] = GetEngineTime(); 
	Enemy[witch] = 0; 
	LastTime[witch] = GetEngineTime()-0.01;
	StuckTime[witch] = 0.0;
	PauseTime[witch] = 0.0; 
	ActionTime[witch] = 0.0;
	
	GetEntPropVector(witch, Prop_Send, "m_vecOrigin", LastPos[witch]);
	SetVector(TargetDir[witch], GetRandomFloat(-1.0, 1.0), GetRandomFloat(-1.0, 1.0), 0.0);
	SetVector(LastSetPos[witch], 0.0, 0.0, 0.0);
	NormalizeVector(TargetDir[witch], TargetDir[witch]); 
	SDKHook(witch, SDKHook_ThinkPost, ThinkWitch);

	if(GetEntProp(witch, Prop_Send, "m_nSequence") == anim_ducking)
	{
		#if DEBUG
			PrintToChatAll("witch %d is sitting", witch);
		#endif
		bWitchSit[witch] = true;
	}
}

void StopHookWitch(int witch)
{
    SDKUnhook(witch, SDKHook_ThinkPost, ThinkWitch);		
    DeleteWitch(witch);
}

void DeleteWitch(int witch)
{
    Enemy[witch] = 0;
    EnemyTime[witch] = 0.0;
    LastTime[witch] = 0.0;
    StuckTime[witch] = 0.0;
    PauseTime[witch] = 0.0;
    ActionTime[witch] = 0.0;
    LastPos[witch][0] = LastPos[witch][1] = LastPos[witch][2] = 0.0;
    TargetDir[witch][0] = TargetDir[witch][1] = TargetDir[witch][2] = 0.0;
    LastSetPos[witch][0] = LastSetPos[witch][1] = LastSetPos[witch][2] = 0.0;
}

Action ThinkWitch(int witch)
{
	if(bWitchScared[witch])
	{
		SDKUnhook(witch, SDKHook_ThinkPost, ThinkWitch);
		return Plugin_Continue;
	}

	float time = GetEngineTime();
	float duration = time-LastTime[witch];
	if(duration>0.1) duration = 0.1;
	LastTime[witch] = time;
	
	if(time-ActionTime[witch]>5.0)
	{	
		ActionTime[witch] = time;
	}

	int m_nSequence = GetEntProp(witch, Prop_Send, "m_nSequence");
	int m_mobRush = GetEntProp(witch, Prop_Send, "m_mobRush");

	int flag = GetEntProp(witch, Prop_Send, "m_fFlags");
	bool onground = !(GetEntPropEnt(witch, Prop_Data, "m_hGroundEntity") == -1);
	
	float witchAngle[3]; 
	float witchPos[3];
	float lastPos[3]; 
	GetEntPropVector(witch, Prop_Send, "m_angRotation", witchAngle);
 	GetEntPropVector(witch, Prop_Send, "m_vecOrigin", witchPos);	
	CopyVector(LastPos[witch], lastPos);
	CopyVector(witchPos, LastPos[witch]);
	int m_hOwnerEntity = GetEntProp(witch, Prop_Send, "m_hOwnerEntity"); 
	#if DEBUG
		PrintToChatAll("witch m_nSequence: %d, m_mobRush: %d", m_nSequence, m_mobRush);
	#endif
	if(L4D2Version)
	{
		// 39: no target burn, 44 ~ 51: stumble 
		if( m_nSequence == 39 || ( 44 <= m_nSequence && m_nSequence <= 51) )
		{		
			SDKUnhook(witch, SDKHook_ThinkPost, ThinkWitch);
			return Plugin_Continue;
		}
	}
	else
	{
		if( m_nSequence == 31 || ( 36 <= m_nSequence && m_nSequence <= 39) )
		{		
			SDKUnhook(witch, SDKHook_ThinkPost, ThinkWitch);
			return Plugin_Continue;
		}
	}

	float m_rage;
 	float m_wanderrage;
	float rage = GetRage(witch, m_rage, m_wanderrage);
	#if DEBUG
		PrintToChatAll("rage: %.2f, m_rage: %.2f, m_wanderrage: %.2f ", rage, m_rage, m_wanderrage );
	#endif
	if(rage > 0.5 || m_rage == 1.0)
	{
		StuckTime[witch] = 0.0;
		return Plugin_Continue;
	}
	
	if( !onground || m_hOwnerEntity > 0 || m_mobRush == 1 )
	{		
		StuckTime[witch] = 0.0;
		return Plugin_Continue;
	}

	float up[3];  
 
	float newWitchPos[3];
	float newWitchAngle[3]; 
	 
	float moveDir[3]; 
	
	float temp[3]; 
	float temp2[3];
	
	SetVector(up, 0.0, 0.0, 1.0); 
 
	float targetPos[3];
	if(time-EnemyTime[witch] > 1.0)
	{	
		Enemy[witch] = FindNextEnemy(witchPos);
		EnemyTime[witch] = time;  
	} 
	PauseTime[witch] -= duration; 
	Enemy[witch] = FreshEnemy(Enemy[witch], targetPos);
	if(Enemy[witch] > 0)
	{ 
		#if DEBUG
			PrintToChatAll("%d witch enemy %d", witch, Enemy[witch]);
		#endif	
		if(PauseTime[witch] <= 0.0)
		{
			SubtractVectors(targetPos, witchPos, TargetDir[witch]);
			TargetDir[witch][2] = 0.0;
			NormalizeVector(TargetDir[witch], TargetDir[witch]);
		}
	}
	else
	{
		if(L4D2Version && !bWitchSit[witch]) return Plugin_Continue;

		int newFlag = flag | FL_DUCKING; 
		
		SetEntProp(witch, Prop_Send, "m_fFlags",newFlag);
		if(m_nSequence != anim_ducking)
		{
			SetEntProp(witch, Prop_Send, "m_nSequence" , anim_ducking); 
			SetEntPropFloat(witch, Prop_Send, "m_flPlaybackRate" ,1.0); 
		}

		return Plugin_Continue;
	}

	StuckTime[witch] += duration; 
	if(StuckTime[witch]>0.5)
	{
		StuckTime[witch] = 0.0;
		CopyVector(witchPos, temp);
		CopyVector(LastSetPos[witch], temp2);
		CopyVector(witchPos, LastSetPos[witch] );
		temp2[2] = temp[2] = 0.0;  
		float a = GetVectorDistance(temp2, temp, true); 
		if(a< 10.0 * 10.0)
		{ 
			RotateVector(up, TargetDir[witch], GetRandomFloat(50.0, 310.0)*Pai/180.0, TargetDir[witch]);
			
			TargetDir[witch][2] = 0.0;
			NormalizeVector(TargetDir[witch],TargetDir[witch]); 
			PauseTime[witch] = 2.0;
		}
	} 

	int newFlag = flag & ~FL_DUCKING; 

	CopyVector(TargetDir[witch],moveDir);	 	
	
	GetVectorAngles(moveDir,newWitchAngle);
	newWitchAngle[0] = 0.0;
	
	CopyVector(moveDir,temp);
	ScaleVector(temp, g_fWitchFollowSpeed*duration);
	AddVectors(witchPos,temp,newWitchPos);
	TeleportEntity(witch, newWitchPos, newWitchAngle,  NULL_VECTOR);
	CopyVector(witchPos, lastPos);	
	SetEntProp(witch, Prop_Send, "m_fFlags",newFlag);
	 
	if(m_nSequence != anim_walk)
	{
		SetEntProp(witch, Prop_Send, "m_nSequence" , anim_walk); 
		SetEntPropFloat(witch, Prop_Send, "m_flPlaybackRate" ,1.0); 
	}

	return Plugin_Continue;
}

int FreshEnemy(int enemy, float enemyPos[3] )
{
	if(g_fRequiredRange == 0.0) return 0; 

	if(enemy> 0 && IsClientInGame(enemy) && IsPlayerAlive(enemy) && GetClientTeam(enemy) == L4D_TEAM_SURVIVORS)
	{ 
		GetClientAbsOrigin(enemy, enemyPos);  
	}
	else enemy = 0;
	return enemy;
}

int FindNextEnemy(float witchPos[3] )
{ 
	float s_fRequiredRange = Pow(g_fWitchFollowRange, 2.0);
 		 
	float minDis = 0.0, dislength, distanceHeight;
	int selectedPlayer = 0;
	float playerPos[3];
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) )
		{
			GetClientEyePosition(i, playerPos);

			distanceHeight = (witchPos[2] - playerPos[2]);
			if(Absolute(distanceHeight) > 500) continue;
			if(IsVisibleTo(witchPos, playerPos, i) == false) continue;

			dislength = GetVectorDistance(playerPos, witchPos, true);  
			if( dislength <= s_fRequiredRange && (dislength <= minDis || minDis == 0.0) )
			{
				selectedPlayer = i ;
				minDis = dislength;	
			}
		}
	} 
 
	return selectedPlayer;	 
}

void CopyVector(float source[3], float target[3])
{
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2];
}

void SetVector(float target[3], float x, float y, float z)
{
	target[0] = x;
	target[1] = y;
	target[2] = z;
}

float GetRage(int witch, float rage, float wanderRage)
{
	rage = GetEntPropFloat(witch, Prop_Send, "m_rage");
	if(L4D2Version)
	{
		wanderRage = GetEntPropFloat(witch, Prop_Send, "m_wanderrage");
	}
	else
	{
		wanderRage = 0.0;
	}
	
	if(rage>wanderRage)
		return rage;
	else 
		return wanderRage;
}

bool IsWitch(int entity)
{
	if (entity > MaxClients && IsValidEntity(entity))
	{
		static char classname[16];
		GetEdictClassname(entity, classname, sizeof(classname));
		if (strcmp(classname, "witch", false) == 0)
			return true;
	}
	return false;
}

void RotateVector(float direction[3], float vec[3], float alfa, float result[3])
{
    float v[3];
    CopyVector(vec,v);

    float u[3];
    CopyVector(direction,u);
    NormalizeVector(u,u);

    float uv[3];
    GetVectorCrossProduct(u,v,uv);

    float sinuv[3];
    CopyVector(uv, sinuv);
    ScaleVector(sinuv, Sine(alfa));

    float uuv[3];
    GetVectorCrossProduct(u,uv,uuv);
    ScaleVector(uuv, 2.0*Pow(Sine(alfa*0.5), 2.0));	

    AddVectors(v, sinuv, result);
    AddVectors(result, uuv, result);
}

void OnTakeDamageWitchPost(int witch, int attacker, int inflictor, float damage, int damagetype)
{
	if(EnemyTime[witch] > 0.0 && attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == 2)
	{
		StopHookWitch(witch);
	}

	if( damagetype & DMG_BURN && BurnWitchTimer[witch] == null && g_bCvarReCalculateBurnOverride == false)
	{
		delete BurnWitchTimer[witch];

		DataPack hPack = new DataPack();
		hPack.WriteCell(witch);
		hPack.WriteCell(EntIndexToEntRef(witch));
		BurnWitchTimer[witch] = CreateTimer(witch_burn_time, BurnWitchDead_Timer, EntIndexToEntRef(witch));
	}
}

Action BurnWitchDead_Timer(Handle timer, DataPack hPack)
{
	hPack.Reset();
	int index = hPack.ReadCell();
	int witch = EntRefToEntIndex(hPack.ReadCell());
	delete hPack;
	
	if ( witch != INVALID_ENT_REFERENCE )
	{
		SetEntProp(witch, Prop_Data, "m_iHealth", 1);
		ForceDamageEntity(-1, 99999, witch);
	}

	BurnWitchTimer[index] = null;
	return Plugin_Continue;
}

void ForceDamageEntity(int causer, int damage, int victim)
{
	float victim_origin[3];
	char rupture[32];
	char damage_victim[32];
	IntToString(damage, rupture, sizeof(rupture));
	Format(damage_victim, sizeof(damage_victim), "hurtme%d", victim);
	GetEntPropVector(victim, Prop_Send, "m_vecOrigin", victim_origin);
	int entity = CreateEntityByName("point_hurt");
	DispatchKeyValue(victim, "targetname", damage_victim);
	DispatchKeyValue(entity, "DamageTarget", damage_victim);
	DispatchKeyValue(entity, "Damage", rupture);
	DispatchSpawn(entity);
	TeleportEntity(entity, victim_origin, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(entity, "Hurt", (causer > 0 && causer <= MaxClients) ? causer : -1);
	DispatchKeyValue(victim, "targetname", "null");
	AcceptEntityInput(entity, "Kill");
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	ResetTimer();
}

void ResetTimer()
{
	int maxents = GetMaxEntities();
	for (int entity = MaxClients + 1; entity <= maxents; entity++)
	{
		delete BurnWitchTimer[entity];
	}
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

float Absolute(float number)
{
	if (number < 0) return -number;
	return number;
}

bool IsVisibleTo(float fWitchPos[3], float fPlayerPos[3], int player)
{
    float vLookAt[3];
    float vAng[3];

    MakeVectorFromPoints(fWitchPos, fPlayerPos, vLookAt);
    GetVectorAngles(vLookAt, vAng);

    Handle trace = TR_TraceRayFilterEx(fWitchPos, vAng, MASK_PLAYERSOLID, RayType_Infinite, TraceFilter, player);

    bool isVisible;

    if (TR_DidHit(trace))
    {
        isVisible = (TR_GetEntityIndex(trace) == player);

        if (!isVisible)
        {
            fPlayerPos[2] -= 62.0; // results the same as GetClientAbsOrigin

            delete trace;
            trace = TR_TraceHullFilterEx(fWitchPos, fPlayerPos, g_fVPlayerMins, g_fVPlayerMaxs, MASK_PLAYERSOLID, TraceFilter, player);

            if (TR_DidHit(trace))
                isVisible = (TR_GetEntityIndex(trace) == player);
        }
    }

    delete trace;

    return isVisible;
}

bool TraceFilter(int entity, int contentsMask, int client)
{
    if (entity == client)
        return true;

    if (IsValidClientIndex(entity))
        return false;

    if( !IsValidEntityIndex(entity) )
        return false;

    return ge_bInvalidTrace[entity] ? false : true;
}

bool IsValidClientIndex(int client)
{
    return (1 <= client <= MaxClients);
}