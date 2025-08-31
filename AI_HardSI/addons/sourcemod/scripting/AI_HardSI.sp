#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#include <actions>

bool g_bL4D2Version;
bool bLate;
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

    bLate = late;
    return APLRes_Success;
}

bool 
	g_bPluginEnd;

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define L4D2Team_Spectator 1
#define L4D2Team_Survivor 2
#define L4D2Team_Infected 3

#define L4D2Infected_Smoker 1
#define L4D2Infected_Boomer 2
#define L4D2Infected_Hunter 3
#define L4D2Infected_Spitter 4
#define L4D2Infected_Jockey 5
#define L4D2Infected_Charger 6
#define L4D2Infected_Witch 7
#define L4D2Infected_Tank 8
#define L4D1Infected_Tank 5

#define PLAYER_HEIGHT	72.0

#include "AI_HardSI/AI_Smoker.sp"
#include "AI_HardSI/AI_Boomer.sp"
#include "AI_HardSI/AI_Hunter.sp"
#include "AI_HardSI/AI_Spitter.sp"
#include "AI_HardSI/AI_Charger.sp"
#include "AI_HardSI/AI_Jockey.sp"
#include "AI_HardSI/AI_Tank.sp"

public Plugin myinfo = 
{
	name = "[L4D1/L4D2] AI: Hard SI",
	author = "Breezy & HarryPotter",
	description = "Improves the AI behaviour of special infected",
	version = "2.5-2025/8/31",
	url = "github.com/breezyplease"
};

ConVar g_hCvarEnable, g_hCvarAssaultReminderInterval, g_hCvarExecAggressiveCfg;
bool g_bCvarEnable;
float g_fCvarAssaultReminderInterval;
char g_sCvarExecAggressiveCfg[64];

int 
	g_iCurTarget[MAXPLAYERS + 1];

float 
	g_fRunTopSpeed[MAXPLAYERS + 1];

public void OnPluginStart() 
{ 
	// Cvars
	g_hCvarEnable 				 	= CreateConVar( "AI_HardSI_enable",        		"1",   	"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	if(g_bL4D2Version)
	{
		g_hCvarAssaultReminderInterval 	= CreateConVar( "ai_assault_reminder_interval", "2", 	"Frequency(sec) at which the 'nb_assault' command is fired to make SI attack", CVAR_FLAGS, true, 0.0 );
	}
	g_hCvarExecAggressiveCfg 		= CreateConVar( "AI_HardSI_aggressive_cfg", 	"aggressive_ai.cfg", 	"File to execute for AI aggressive cvars (in cfg/AI_HardSI folder)\nExecute file every map changed", CVAR_FLAGS );

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	if(g_bL4D2Version)
	{
		g_hCvarAssaultReminderInterval.AddChangeHook(ConVarChanged_Cvars);
	}
	g_hCvarExecAggressiveCfg.AddChangeHook(ConVarChanged_Cvars);

	// Event hooks
	HookEvent("player_spawn", player_spawn);
	HookEvent("ability_use", ability_use); 

	// Load modules
	Smoker_OnModuleStart();
	Boomer_OnModuleStart();
	Hunter_OnModuleStart();
	if(g_bL4D2Version)
	{
		Spitter_OnModuleStart();
		Jockey_OnModuleStart();
		Charger_OnModuleStart();
	}
	Tank_OnModuleStart();

	//Autoconfig for plugin
	AutoExecConfig(true, "AI_HardSI");

	if(bLate)
	{
		LateLoad();
	}
}

void LateLoad()
{
	if(g_bL4D2Version && L4D_HasAnySurvivorLeftSafeArea())
	{
		CreateTimer( g_fCvarAssaultReminderInterval, Timer_ForceInfectedAssault, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
	}
}

public void OnPluginEnd() 
{
	g_bPluginEnd = true;
	// Unload modules
	Smoker_OnModuleEnd();
	Boomer_OnModuleEnd();
	Hunter_OnModuleEnd();
	if(g_bL4D2Version)
	{
		Spitter_OnModuleEnd();
		Jockey_OnModuleEnd();
		Charger_OnModuleEnd();
	}
	Tank_OnModuleEnd();
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	if(g_bL4D2Version)
	{
		g_fCvarAssaultReminderInterval = g_hCvarAssaultReminderInterval.FloatValue;
	}
	g_hCvarExecAggressiveCfg.GetString(g_sCvarExecAggressiveCfg, sizeof(g_sCvarExecAggressiveCfg));
}

//Sourcemod API Forward-------------------------------

public void OnConfigsExecuted()
{
	GetCvars();

	if(g_bCvarEnable)
	{
		ServerCommand("exec AI_HardSI/%s", g_sCvarExecAggressiveCfg);
	}
}

/***********************************************************************************************************************************************************************************

																	KEEP SI AGGRESSIVE
																	
***********************************************************************************************************************************************************************************/

public void L4D_OnFirstSurvivorLeftSafeArea_Post(int client) 
{	
	if(!g_bL4D2Version) return;

	CreateTimer( g_fCvarAssaultReminderInterval, Timer_ForceInfectedAssault, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE );
}

Action Timer_ForceInfectedAssault( Handle timer ) 
{
	if(!g_bCvarEnable) return Plugin_Continue;

	CheatServerCommand("nb_assault");

	return Plugin_Continue;
}

// Actions API--------------

public void OnActionCreated(BehaviorAction action, int actor, const char[] name)
{
	if(!g_bCvarEnable) return;

	switch (name[0])
	{
		case 'S':
		{ 
			if (strncmp(name, "Smoker", 6) == 0)
			{
				AI_Smoker_OnActionCreated(action, name);
			}
		}
		case 'H':
		{ 
			if (strncmp(name, "Hunter", 6) == 0)
			{
				AI_Hunter_OnActionCreated(action, name);
			}
		}
	}

}

/***********************************************************************************************************************************************************************************

																		SI MOVEMENT
																	
***********************************************************************************************************************************************************************************/

// Modify SI movement
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) {
	if(!g_bCvarEnable) return Plugin_Continue;
	
	if( IsBotInfected(client) && IsPlayerAlive(client) && !L4D_IsPlayerGhost(client) ) 
	{ 
		if (L4D_IsPlayerStaggering(client))
			return Plugin_Continue;

		if(g_bL4D2Version)
		{
			switch( GetInfectedClass(client) ) {

				case (L4D2Infected_Boomer): {
					return Boomer_OnPlayerRunCmd( client, buttons);
				}
			
				case (L4D2Infected_Hunter): {
					return Hunter_OnPlayerRunCmd( client, buttons);
				}		

				case (L4D2Infected_Spitter): {
					return Spitter_OnPlayerRunCmd( client, buttons );
				}	
				
				case (L4D2Infected_Charger): {
					return Charger_OnPlayerRunCmd( client, buttons);
				}	
				
				case (L4D2Infected_Jockey): {
					return Jockey_OnPlayerRunCmd( client, buttons);
				}
					
				case (L4D2Infected_Tank): {
					return Tank_OnPlayerRunCmd( client, buttons, vel);
				}
					
				default: {
					return Plugin_Continue;
				}		
			}
		}
		else
		{
			switch( GetInfectedClass(client) ) {

				case (L4D2Infected_Boomer): {
					return Boomer_OnPlayerRunCmd( client, buttons);
				}
			
				case (L4D2Infected_Hunter): {
					return Hunter_OnPlayerRunCmd( client, buttons);
				}		
					
				case (L4D1Infected_Tank): {
					return Tank_OnPlayerRunCmd( client, buttons, vel);
				}
					
				default: {
					return Plugin_Continue;
				}		
			}
		}
	}
	return Plugin_Continue;
}

/***********************************************************************************************************************************************************************************

																		EVENT HOOKS

***********************************************************************************************************************************************************************************/

// Initialise relevant module flags for SI when they spawn
void player_spawn(Event event, char[] name, bool dontBroadcast) {
	if(!g_bCvarEnable) return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	if( IsBotInfected(client) ) {
		int botInfected = client;
		// Process for SI class
		if(g_bL4D2Version)
		{
			switch( GetInfectedClass(botInfected) ) {
				
				case (L4D2Infected_Hunter): {
					Hunter_OnSpawn(botInfected);
				}

				case (L4D2Infected_Charger): {
					Charger_OnSpawn(botInfected);
				}			
			}
		}
		else
		{
			switch( GetInfectedClass(botInfected) ) {
				
				case (L4D2Infected_Hunter): {
					Hunter_OnSpawn(botInfected);
				}				
			}
		}
	}
}

// Modify hunter lunges and block smokers/spitters from fleeing after using their ability
void ability_use(Event event, char[] name, bool dontBroadcast) {
	if(!g_bCvarEnable) return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	if( IsBotInfected(client) ) {
		int bot = client;
		// Process for different SI
		char abilityName[32];
		event.GetString("ability", abilityName, sizeof(abilityName));
		if( strcmp(abilityName, "ability_lunge") == 0) {
			ability_use_OnPounce(bot);
		} else if( g_bL4D2Version && strcmp(abilityName, "ability_charge") == 0) {
			ability_use_OnCharge(bot);
		} else if( strcmp(abilityName, "ability_vomit") == 0) {
			ability_use_OnVomit(bot);
		}
	}
}

// Left 4 Dhooks API----------

public Action L4D2_OnChooseVictim(int specialInfected, int &curTarget) 
{
	g_iCurTarget[specialInfected] = curTarget;

	return Plugin_Continue;
}

public Action L4D_OnGetRunTopSpeed(int target, float &retVal)
{
	g_fRunTopSpeed[target] = retVal;
	return Plugin_Continue;
}

public Action L4D2_OnSelectTankAttack(int client, int &sequence) 
{
	if(!g_bCvarEnable) return Plugin_Continue;

	return Tank_OnSelectTankAttack(client, sequence);
}

public Action L4D_TankRock_OnRelease(int tank, int rock, float vecPos[3], float vecAng[3], float vecVel[3], float vecRot[3])
{
	if(!g_bCvarEnable) return Plugin_Continue;

	return Tank_TankRock_OnRelease(tank, rock, vecAng, vecVel);
}

public void L4D_TankRock_OnRelease_Post(int tank, int rock, const float vecPos[3], const float vecAng[3], const float vecVel[3], const float vecRot[3])
{
	if(!g_bCvarEnable) return;

	Tank_TankRock_OnRelease_Post(tank);
}

// Other----------

void GetSurDistance(int client, float &curTargetDist, float &nearestSurDist) {
	static float vPos[3];
	static float vTar[3];

	GetClientAbsOrigin(client, vPos);
	if (!IsAliveSur(g_iCurTarget[client]))
		curTargetDist = -1.0;
	else {
		GetClientAbsOrigin(g_iCurTarget[client], vTar);
		curTargetDist = GetVectorDistance(vPos, vTar);
	}

	static int i;
	static float dist;

	nearestSurDist = -1.0;
	GetClientAbsOrigin(client, vPos);
	for (i = 1; i <= MaxClients; i++) {
		if (i != client && IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i)) {
			GetClientAbsOrigin(i, vTar);
			dist = GetVectorDistance(vPos, vTar);
			if (nearestSurDist == -1.0 || dist < nearestSurDist)
				nearestSurDist = dist;
		}
	}
}

float CurTargetDistance(int client) {
	if (!IsAliveSur(g_iCurTarget[client]))
		return -1.0;

	static float vPos[3];
	static float vTar[3];
	GetClientAbsOrigin(client, vPos);
	GetClientAbsOrigin(g_iCurTarget[client], vTar);
	return GetVectorDistance(vPos, vTar);
}

int GetCurTarget(int client)
{
	return g_iCurTarget[client];
}

float GetTargetRunTopSpeed(int client)
{
	return g_fRunTopSpeed[client];
}

/**
 * Returns true if the player is currently on the survivor team. 
 *
 * @param client: client ID
 * @return bool
 */
bool IsSurvivor(int client) {
	if( IsValidClient(client) && GetClientTeam(client) == L4D2Team_Survivor ) {
		return true;
	} else {
		return false;
	}
}

/**
 * Returns true if the player is incapacitated. 
 *
 * @param client client ID
 * @return bool
 */
bool IsIncapacitated(int client) {
    return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated"));
}

/**
 * Finds the closest survivor excluding a given survivor 
 * @param referenceClient: compares survivor distances to this client
 * @param excludeSurvivor: ignores this survivor
 * @return: the entity index of the closest survivor
**/
int GetClosestSurvivor( float referencePos[3], int excludeSurvivor = -1 ) {
	float survivorPos[3];
	int closestSurvivor = GetRandomSurvivor(1, -1);	
	if (closestSurvivor <= 0) return -1;
	GetClientAbsOrigin( closestSurvivor, survivorPos );
	int iClosestAbsDisplacement = RoundToNearest( GetVectorDistance(referencePos, survivorPos) );
	for (int client = 1; client <= MaxClients; client++) {
		if( IsSurvivor(client) && IsPlayerAlive(client) && client != excludeSurvivor ) {
			GetClientAbsOrigin( client, survivorPos );
			int iAbsDisplacement = RoundToNearest( GetVectorDistance(referencePos, survivorPos) );			
			if( iClosestAbsDisplacement < 0 ) { // Start with the absolute displacement to the first survivor found:
				iClosestAbsDisplacement = iAbsDisplacement;
				closestSurvivor = client;
			} else if( iAbsDisplacement < iClosestAbsDisplacement ) { // closest survivor so far
				iClosestAbsDisplacement = iAbsDisplacement;
				closestSurvivor = client;
			}			
		}
	}
	return closestSurvivor;
}

/**
 * Returns the distance of the closest survivor or a specified survivor
 * @param referenceClient: the client from which to measure distance to survivor
 * @param specificSurvivor: the index of the survivor to be measured, -1 to search for distance to closest survivor
 * @return: the distance
 */
int GetSurvivorProximity( const float rp[3], int specificSurvivor = -1 ) {
	
	int targetSurvivor;
	float targetSurvivorPos[3];
	float referencePos[3]; // non constant var
	referencePos[0] = rp[0];
	referencePos[1] = rp[1];
	referencePos[2] = rp[2];
	

	if( specificSurvivor > 0 && IsSurvivor(specificSurvivor) ) { // specified survivor
		targetSurvivor = specificSurvivor;		
	} else { // closest survivor		
		targetSurvivor = GetClosestSurvivor( referencePos );
	}
	
	if (targetSurvivor <= 0) return -1;

	GetEntPropVector( targetSurvivor, Prop_Send, "m_vecOrigin", targetSurvivorPos );
	return RoundToNearest( GetVectorDistance(referencePos, targetSurvivorPos) );
}

/***********************************************************************************************************************************************************************************

                                                                   	SPECIAL INFECTED 
                                                                    
***********************************************************************************************************************************************************************************/

/**
 * @return: the special infected class of the client
 */
int GetInfectedClass(int client) {
    return GetEntProp(client, Prop_Send, "m_zombieClass");
}

bool IsInfected(int client) {
    if (!IsClientInGame(client) || GetClientTeam(client) != L4D2Team_Infected) {
        return false;
    }
    return true;
}

/**
 * @return: true if client is a special infected bot
 */
bool IsBotInfected(int client) {
    // Check the input is valid
    if (!IsValidClient(client))return false;
    
    // Check if player is a bot on the infected team
    if (IsInfected(client) && IsFakeClient(client)) {
        return true;
    }
    return false; // otherwise
}

bool IsBotCharger(int client) {
	return (IsBotInfected(client) && GetInfectedClass(client) == L4D2Infected_Charger);
}


/***********************************************************************************************************************************************************************************

                                                                   			MISC
                                                                    
***********************************************************************************************************************************************************************************/

void CheatServerCommand(char[] command)
{
    int flags = GetCommandFlags(command);
    SetCommandFlags(command, flags & ~FCVAR_CHEAT);
    ServerCommand("%s", command);
    ServerExecute();
    SetCommandFlags(command, flags);
}

/**
 * Returns true if the client ID is valid
 *
 * @param client: client ID
 * @return bool
 */
bool IsValidClient(int client) {
    if( client > 0 && client <= MaxClients && IsClientInGame(client) ) {
    	return true;
    } else {
    	return false;
    }    
}

/**
	Determines whether an attacking SI is being watched by the survivor
	@return: true if the survivor's crosshair is within the specified radius
	@param attacker: the client number of the attacking SI
	@param offsetThreshold: the radius(degrees) of the cone of detection around the straight line from the attacked survivor to the SI
**/
bool IsTargetWatchingAttacker( int attacker, float offsetThreshold ) {
	bool isWatching = true;
	if( GetClientTeam(attacker) == 3 && IsPlayerAlive(attacker) ) { // SI continue to hold on to their targets for a few seconds after death
		int target = GetClientAimTarget(attacker);
		if( IsSurvivor(target) ) { 
			if( GetPlayerAimOffset(target, attacker) <= offsetThreshold ) {
				isWatching = true;
			} else {
				isWatching = false;
			}		
		} 
	}	
	return isWatching;
}

/**
	Calculates how much a player's aim is off another player
	@return: aim offset in degrees
	@attacker: considers this player's eye angles
	@target: considers this player's position
	Adapted from code written by Guren with help from Javalia
**/
float GetPlayerAimOffset( int attacker, int target ) {
	if( !IsClientConnected(attacker) || !IsClientInGame(attacker) || !IsPlayerAlive(attacker) )
		ThrowError("Client is not Alive."); 
	if(!IsClientConnected(target) || !IsClientInGame(target) || !IsPlayerAlive(target) )
		ThrowError("Target is not Alive.");
		
	float attackerPos[3], targetPos[3];
	float aimVector[3], directVector[3];
	float resultAngle;
	
	// Get the unit vector representing the attacker's aim
	GetClientEyeAngles(attacker, aimVector);
	aimVector[0] = aimVector[2] = 0.0; // Restrict pitch and roll, consider yaw only (angles on horizontal plane)
	GetAngleVectors(aimVector, aimVector, NULL_VECTOR, NULL_VECTOR); // extract the forward vector[3]
	NormalizeVector(aimVector, aimVector); // convert into unit vector
	
	// Get the unit vector representing the vector between target and attacker
	GetClientAbsOrigin(target, targetPos); 
	GetClientAbsOrigin(attacker, attackerPos);
	attackerPos[2] = targetPos[2] = 0.0; // Restrict to XY coordinates
	MakeVectorFromPoints(attackerPos, targetPos, directVector);
	NormalizeVector(directVector, directVector);
	
	// Calculate the angle between the two unit vectors
	resultAngle = RadToDeg(ArcCosine(GetVectorDotProduct(aimVector, directVector)));
	return resultAngle;
}

bool IsGrounded(int client) {
	return GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") != -1;
}

bool TargetSur(int client) {
	return IsAliveSur(GetClientAimTarget(client, true));
}

bool CheckPlayerMove(int client, float vel) {
	return vel > 0.9 * GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") > 0.0;
}

bool CheckHopVel(int client, const float vAng[3], const float vVel[3]) {
	float vMins[3];
	float vMaxs[3];
	GetClientMins(client, vMins);
	GetClientMaxs(client, vMaxs);

	float vPos[3];
	float vEnd[3];
	GetClientAbsOrigin(client, vPos);
	float vel = GetVectorLength(vVel);
	NormalizeVector(vVel, vEnd);
	ScaleVector(vEnd, vel + FloatAbs(vMaxs[0] - vMins[0]) + 3.0);
	AddVectors(vPos, vEnd, vEnd);

	bool hit;
	Handle hndl;
	float vVec[3];
	float vNor[3];
	float vPlane[3];

	hit = false;
	vPos[2] += 10.0;
	vEnd[2] += 10.0;
	hndl = TR_TraceHullFilterEx(vPos, vEnd, vMins, vMaxs, MASK_PLAYERSOLID, TraceEntityFilter);
	if (TR_DidHit(hndl)) {
		hit = true;
		TR_GetEndPosition(vVec, hndl);

		NormalizeVector(vVel, vNor);
		TR_GetPlaneNormal(hndl, vPlane);
		if (RadToDeg(ArcCosine(GetVectorDotProduct(vNor, vPlane))) > 165.0) {
			delete hndl;
			return false;
		}

		vNor[1] = vAng[1];
		vNor[0] = vNor[2] = 0.0;
		GetAngleVectors(vNor, vNor, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vNor, vNor);
		if (RadToDeg(ArcCosine(GetVectorDotProduct(vNor, vPlane))) > 165.0) {
			delete hndl;
			return false;
		}
	}
	else {
		vNor[1] = vAng[1];
		vNor[0] = vNor[2] = 0.0;
		GetAngleVectors(vNor, vNor, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vNor, vNor);
		vPlane = vNor;
		ScaleVector(vPlane, 128.0);
		AddVectors(vPos, vPlane, vPlane);
		delete hndl;
		hndl = TR_TraceHullFilterEx(vPos, vPlane, view_as<float>({-16.0, -16.0, 0.0}), view_as<float>({16.0, 16.0, 33.0}), MASK_PLAYERSOLID, TraceWallFilter, client);
		if (TR_DidHit(hndl)) {
			TR_GetPlaneNormal(hndl, vPlane);
			if (RadToDeg(ArcCosine(GetVectorDotProduct(vNor, vPlane))) > 165.0) {
				delete hndl;
				return false;
			}
		}

		delete hndl;
	}

	delete hndl;
	if (!hit)
	{
		vVec[0] = vEnd[0];
		vVec[1] = vEnd[1];
		vVec[2] = vEnd[2];
	}

	static float vDown[3];
	vDown[0] = vVec[0];
	vDown[1] = vVec[1];
	vDown[2] = vVec[2] - 100000.0;

	hndl = TR_TraceHullFilterEx(vVec, vDown, vMins, vMaxs, MASK_PLAYERSOLID, TraceSelfFilter, client);
	if (!TR_DidHit(hndl)) {
		delete hndl;
		return false;
	}

	TR_GetEndPosition(vEnd, hndl);
	delete hndl;
	return vVec[2] - vEnd[2] < 104.0;
}

bool TraceSelfFilter(int entity, int contentsMask, any data) {
	return entity != data;
}

bool TraceWallFilter(int entity, int contentsMask, any data) {
	if (entity != data) {
		static char cls[5];
		GetEdictClassname(entity, cls, sizeof cls);
		return cls[3] != 'e' && cls[3] != 'c';
	}

	return false;
}

bool TraceEntityFilter(int entity, int contentsMask) {
	if (!entity || entity > MaxClients) {
		static char cls[5];
		GetEdictClassname(entity, cls, sizeof cls);
		return cls[3] != 'e' && cls[3] != 'c';
	}

	return false;
}

float NearestSurDistance(int client) {
	static int i;
	static float vPos[3];
	static float vTar[3];
	static float dist;
	static float minDist;

	minDist = -1.0;
	GetClientAbsOrigin(client, vPos);
	for (i = 1; i <= MaxClients; i++) {
		if (i != client && IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i)) {
			GetClientAbsOrigin(i, vTar);
			dist = GetVectorDistance(vPos, vTar);
			if (minDist == -1.0 || dist < minDist)
				minDist = dist;
		}
	}

	return minDist;
}

bool IsAliveSur(int client) {
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client);
}

void ResetAbilityTime(int charger, float time) {
	static int ent;
	ent = GetEntPropEnt(charger, Prop_Send, "m_customAbility");
	if (ent > MaxClients)
		SetEntPropFloat(ent, Prop_Send, "m_timestamp", GetGameTime() + time);
}

bool entHitWall(int client, int target) {
	static float vPos[3];
	static float vTar[3];
	GetClientAbsOrigin(client, vPos);
	GetClientAbsOrigin(target, vTar);
	vPos[2] += 10.0;
	vTar[2] += 10.0;

	MakeVectorFromPoints(vPos, vTar, vTar);
	static float dist;
	dist = GetVectorLength(vTar);
	NormalizeVector(vTar, vTar);
	ScaleVector(vTar, dist);
	AddVectors(vPos, vTar, vTar);

	static float vMins[3];
	static float vMaxs[3];
	GetClientMins(client, vMins);
	GetClientMaxs(client, vMaxs);
	vMins[2] += dist > 49.0 ? 10.0 : 44.0;
	vMaxs[2] -= 10.0;

	static bool hit;
	static Handle hndl;
	hndl = TR_TraceHullFilterEx(vPos, vTar, vMins, vMaxs, MASK_PLAYERSOLID, TraceEntityFilter);
	hit = TR_DidHit(hndl);
	delete hndl;
	return hit;
}

bool vecHitWall(int client, float vPos[3], float vTar[3]) {
	vPos[2] += 10.0;
	vTar[2] += 10.0;
	MakeVectorFromPoints(vPos, vTar, vTar);
	static float dist;
	dist = GetVectorLength(vTar);
	NormalizeVector(vTar, vTar);
	ScaleVector(vTar, dist);
	AddVectors(vPos, vTar, vTar);

	static float vMins[3];
	static float vMaxs[3];
	GetClientMins(client, vMins);
	GetClientMaxs(client, vMaxs);
	vMins[2] += 10.0;
	vMaxs[2] -= 10.0;

	static bool hit;
	static Handle hndl;
	hndl = TR_TraceHullFilterEx(vPos, vTar, vMins, vMaxs, MASK_PLAYERSOLID, TraceEntityFilter);
	hit = TR_DidHit(hndl);
	delete hndl;
	return hit;
}

bool WithinViewAngle(int client, float offsetThreshold, int target = 0) {
	
	if(target == 0)
	{
		target = GetClientAimTarget(client);
		if (!IsAliveSur(target))
			return true;
	}
	
	static float vSrc[3];
	static float vTar[3];
	static float vAng[3];
	GetClientEyePosition(target, vSrc);
	GetClientEyePosition(client, vTar);
	if (IsVisibleTo(vSrc, vTar)) {
		GetClientEyeAngles(target, vAng);
		return PointWithinViewAngle(vSrc, vTar, vAng, GetFOVDotProduct(offsetThreshold));
	}

	return false;
}

bool WithinViewAngle2(int client, int viewer, float offsetThreshold) {
	static float vSrc[3];
	static float vTar[3];
	static float vAng[3];
	GetClientEyePosition(viewer, vSrc);
	GetClientEyePosition(client, vTar);
	if (IsVisibleTo(vSrc, vTar)) {
		GetClientEyeAngles(viewer, vAng);
		return PointWithinViewAngle(vSrc, vTar, vAng, GetFOVDotProduct(offsetThreshold));
	}

	return false;
}

int Math_GetRandomInt(int min, int max)
{
	int random = GetURandomInt();

	if (random == 0) {
		random++;
	}

	return RoundToCeil(float(random) / (float(2147483647) / float(max - min + 1))) + min - 1;
}

// credits = "AtomicStryker"
bool IsVisibleTo(const float vPos[3], const float vTarget[3]) {
	static float vLookAt[3];
	MakeVectorFromPoints(vPos, vTarget, vLookAt);
	GetVectorAngles(vLookAt, vLookAt);

	static Handle hndl;
	hndl = TR_TraceRayFilterEx(vPos, vLookAt, MASK_VISIBLE, RayType_Infinite, TraceEntityFilter);

	static bool isVisible;
	isVisible = false;
	if (TR_DidHit(hndl)) {
		static float vStart[3];
		TR_GetEndPosition(vStart, hndl);

		if ((GetVectorDistance(vPos, vStart, false) + 25.0) >= GetVectorDistance(vPos, vTarget))
			isVisible = true;
	}

	delete hndl;
	return isVisible;
}

bool PointWithinViewAngle(const float vecSrcPosition[3], const float vecTargetPosition[3], const float vecLookDirection[3], float flCosHalfFOV) {
	static float vecDelta[3];
	SubtractVectors(vecTargetPosition, vecSrcPosition, vecDelta);
	static float cosDiff;
	cosDiff = GetVectorDotProduct(vecLookDirection, vecDelta);
	if (cosDiff < 0.0)
		return false;

	// a/sqrt(b) > c  == a^2 > b * c ^2
	return cosDiff * cosDiff >= GetVectorLength(vecDelta, true) * flCosHalfFOV * flCosHalfFOV;
}

float GetFOVDotProduct(float angle) {
	return Cosine(DegToRad(angle) / 2.0);
}

bool IsPinned(int client) 
{
	if(g_bL4D2Version)
	{
		if (GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") > 0)
			return true;
		if (GetEntPropEnt(client, Prop_Send, "m_carryAttacker") > 0)
			return true;
		if (GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") > 0)
			return true;
		if (L4D2_GetQueuedPummelAttacker(client) > 0)
			return true;
	}
	
	if (GetEntPropEnt(client, Prop_Send, "m_tongueOwner") > 0)
		return true;
	if (GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") > 0)
		return true;

	return false;
}