#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sdktools>
#define DEBUG_HUNTER_AIM 0
#define DEBUG_HUNTER_RNG 0
#define DEBUG_HUNTER_ANGLE 0

#define POSITIVE 0
#define NEGATIVE 1
#define X 0
#define Y 1
#define Z 2

// Vanilla Cvars
static ConVar g_hCvarLungeInterval, g_hCvarHunterLeapAwayGiveUpRange;
static float g_fCvarLungeInterval;
static int g_iCvarHunterLeapAwayGiveUpRange;
static ConVar g_hCvarEnable, g_hCvarPounceAngleMean, g_hCvarPounceAngleStd, g_hCvarPounceVerticalAngle, g_hCvarFastPounceProximity, g_hCvarStraightPounceProximity, 
	g_hCvarAimOffsetSensitivity, g_hCvarWallDetectionDistance, g_hCvarPounceDancing;
static bool g_bCvarEnable, g_bCvarPounceDancing;
static int g_iCvarFastPounceProximity, g_iCvarStraightPounceProximity, g_iCvarWallDetectionDistance;
static float g_fCvarPounceAngleMean, g_fCvarPounceAngleStd, g_fCvarPounceVerticalAngle, g_fCvarAimOffsetSensitivity;

static bool 
	g_bHasQueuedLunge[MAXPLAYERS+1], 
	g_bCanLunge[MAXPLAYERS+1];

static float 
	g_fAttack2[MAXPLAYERS+1];

void Hunter_OnModuleStart() 
{
	g_hCvarLungeInterval = FindConVar("z_lunge_interval"); // cooldown on lunges
	g_hCvarHunterLeapAwayGiveUpRange = FindConVar("hunter_leap_away_give_up_range"); // range at which shooting a non-committed hunter will cause it to leap away	
	
	GetOfficialCvars();
	g_hCvarLungeInterval.AddChangeHook(OnHunterCvarChange);
	g_hCvarHunterLeapAwayGiveUpRange.AddChangeHook(OnHunterCvarChange);

	g_hCvarEnable 					= CreateConVar( "AI_HardSI_Hunter_enable",  		"1",   	"0=Improves the Hunter behaviour off, 1=Improves the Hunter behaviour on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvarFastPounceProximity 		= CreateConVar( "ai_fast_pounce_proximity", 		"1000", "At what distance to start pouncing fast", FCVAR_NOTIFY, true, 0.0);
	g_hCvarPounceVerticalAngle 		= CreateConVar( "ai_pounce_vertical_angle", 		"7", 	"Vertical angle to which AI hunter pounces will be restricted", FCVAR_NOTIFY, true, 0.0);
	g_hCvarPounceAngleMean 			= CreateConVar( "ai_pounce_angle_mean", 			"10", 	"Mean angle produced by Gaussian RNG", FCVAR_NOTIFY, true, 0.0 );
	g_hCvarPounceAngleStd 			= CreateConVar( "ai_pounce_angle_std", 				"20", 	"One standard deviation from mean as produced by Gaussian RNG", FCVAR_NOTIFY, true, 0.0 );
	g_hCvarStraightPounceProximity 	= CreateConVar( "ai_straight_pounce_proximity", 	"200", 	"Distance to nearest survivor at which hunter will consider pouncing straight", FCVAR_NOTIFY, true, 0.0);
	g_hCvarAimOffsetSensitivity 	= CreateConVar( "ai_aim_offset_sensitivity_hunter", "30",  	"If the hunter has a target, it will not straight pounce if the target's aim on the horizontal axis is within this radius", FCVAR_NOTIFY, true, 0.0, true, 179.0 );
	g_hCvarWallDetectionDistance 	= CreateConVar( "ai_wall_detection_distance", 		"-1", 	"How far in front of hunter infected bot will check for a wall. Use '-1' to disable feature", FCVAR_NOTIFY, true, -1.0);
	g_hCvarPounceDancing 			= CreateConVar( "ai_pounce_dancing_enable", 		"1", 	"If 1, Hunter do scratch animation when pouncing", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_EnableCvars);
	g_hCvarFastPounceProximity.AddChangeHook(CvarChanged);
	g_hCvarPounceVerticalAngle.AddChangeHook(CvarChanged);
	g_hCvarPounceAngleMean.AddChangeHook(CvarChanged);
	g_hCvarPounceAngleStd.AddChangeHook(CvarChanged);
	g_hCvarStraightPounceProximity.AddChangeHook(CvarChanged);
	g_hCvarAimOffsetSensitivity.AddChangeHook(CvarChanged);
	g_hCvarWallDetectionDistance.AddChangeHook(CvarChanged);
	g_hCvarPounceDancing.AddChangeHook(CvarChanged);

	if(g_bCvarEnable) _OnModuleStart();
}

static void _OnModuleStart()
{
	if(g_bPluginEnd) return;
}

void Hunter_OnModuleEnd() 
{

}

static void OnHunterCvarChange(ConVar convar, const char[] oldValue, const char[] newValue) 
{
	GetOfficialCvars();
}

static void GetOfficialCvars()
{
	g_fCvarLungeInterval = g_hCvarLungeInterval.FloatValue;
	g_iCvarHunterLeapAwayGiveUpRange = g_hCvarHunterLeapAwayGiveUpRange.IntValue;
}

static void ConVarChanged_EnableCvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
    GetCvars();
    if(g_bCvarEnable)
    {
        _OnModuleStart();
    }
    else
    {
        Hunter_OnModuleEnd();
    }
}

static void CvarChanged(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

static void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_iCvarFastPounceProximity = g_hCvarFastPounceProximity.IntValue;
	g_fCvarPounceVerticalAngle = g_hCvarPounceVerticalAngle.FloatValue;
	g_fCvarPounceAngleMean = g_hCvarPounceAngleMean.FloatValue;
	g_fCvarPounceAngleStd = g_hCvarPounceAngleStd.FloatValue;
	g_iCvarStraightPounceProximity = g_hCvarStraightPounceProximity.IntValue;
	g_fCvarAimOffsetSensitivity = g_hCvarAimOffsetSensitivity.FloatValue;
	g_iCvarWallDetectionDistance = g_hCvarWallDetectionDistance.IntValue;
	g_bCvarPounceDancing = g_hCvarPounceDancing.BoolValue;
}

void Hunter_OnSpawn(int botHunter) {
	if(!g_bCvarEnable) return;

	g_bHasQueuedLunge[botHunter] = false;
	g_bCanLunge[botHunter] = true;
}

/***********************************************************************************************************************************************************************************

																		FAST POUNCING

***********************************************************************************************************************************************************************************/

stock Action Hunter_OnPlayerRunCmd(int hunter, int &buttons ) {	
	if(!g_bCvarEnable) return Plugin_Continue;

	if (!GetEntProp(hunter, Prop_Send, "m_hasVisibleThreats"))
		return Plugin_Continue;

	int flags = GetEntityFlags(hunter);
	//Proceed if the hunter is in a position to pounce
	if( flags & FL_ONGROUND ) 
	{	
		if ( view_as<bool>(GetEntProp(hunter, Prop_Send, "m_bDucked")) )
		{
			float hunterPos[3];
			GetClientAbsOrigin(hunter, hunterPos);		
			int iSurvivorsProximity = GetSurvivorProximity(hunterPos);
			if (iSurvivorsProximity == -1) return Plugin_Continue;
			
			if( iSurvivorsProximity < g_iCvarFastPounceProximity ) {
				buttons &= ~IN_ATTACK; // release attack button; precautionary					
				// Queue a pounce/lunge
				if (!g_bHasQueuedLunge[hunter]) { // check lunge interval timer has not already been initiated
					g_bCanLunge[hunter] = false;
					g_bHasQueuedLunge[hunter] = true; // block duplicate lunge interval timers
					CreateTimer(g_fCvarLungeInterval, Timer_LungeInterval, hunter, TIMER_FLAG_NO_MAPCHANGE);
				} else if (g_bCanLunge[hunter]) { // end of lunge interval; lunge!
					float now = GetEngineTime();
					if (g_bCvarPounceDancing == true && g_fAttack2[hunter] < now) 
					{
						buttons |= IN_ATTACK2;
						g_fAttack2[hunter] = GetEngineTime() + 0.2;
					}	

					buttons |= IN_ATTACK;
					g_bHasQueuedLunge[hunter] = false; // unblock lunge interval timer

					return Plugin_Changed;
				} 
			}
		}
	} 

	return Plugin_Changed;
}

void ability_use_OnPounce(int botHunter) {	
	if(!g_bCvarEnable) return;
	
	int entLunge = GetEntPropEnt(botHunter, Prop_Send, "m_customAbility"); // get the hunter's lunge entity				
	float lungeVector[3]; 
	GetEntPropVector(entLunge, Prop_Send, "m_queuedLunge", lungeVector); // get the vector from the lunge entity
	
	// Avoid pouncing straight forward if there is a wall close in front
	float hunterPos[3];
	float hunterAngle[3];
	GetClientAbsOrigin(botHunter, hunterPos);
	GetClientEyeAngles(botHunter, hunterAngle); 
	// Fire traceray in front of hunter 
	TR_TraceRayFilter( hunterPos, hunterAngle, MASK_PLAYERSOLID, RayType_Infinite, TracerayFilter, botHunter );
	float impactPos[3];
	TR_GetEndPosition( impactPos );
	// Check first object hit
	if( GetVectorDistance(hunterPos, impactPos) < g_iCvarWallDetectionDistance ) { // wall detected in front
		if( GetRandomInt(0, 1) ) { // 50% chance left or right
			AngleLunge( entLunge, 45.0 );
		} else {
			AngleLunge( entLunge, 315.0 );
		}
		
			#if DEBUG_HUNTER_AIM
				PrintToChatAll("Pouncing sideways to avoid wall");
			#endif
		
	} else {
		// Angle pounce if survivor is watching the hunter approach
		GetClientAbsOrigin(botHunter, hunterPos);		
		if( IsTargetWatchingAttacker(botHunter, g_fCvarAimOffsetSensitivity) && GetSurvivorProximity(hunterPos) > g_iCvarStraightPounceProximity ) {			
			float pounceAngle = GaussianRNG( g_fCvarPounceAngleMean, g_fCvarPounceAngleStd );
			AngleLunge( entLunge, pounceAngle );
			LimitLungeVerticality( entLunge );
			
				#if DEBUG_HUNTER_AIM
					int target = GetClientAimTarget(botHunter);
					if( IsSurvivor(target) ) {
						char targetName[32];
						GetClientName(target, targetName, sizeof(targetName));
						PrintToChatAll("The aim of hunter's target(%s) is %f degrees off", targetName, GetPlayerAimOffset(target, botHunter));
						PrintToChatAll("Angling pounce to throw off survivor");
					} 
					
				#endif
	
			return;					
		}	
	}
}

static bool TracerayFilter( int impactEntity, int contentMask, any rayOriginEntity ) {
	return impactEntity != rayOriginEntity;
}
// Credits to High Cookie and Standalone for working out the math behind hunter lunges
static void AngleLunge( int lungeEntity, float turnAngle ) {	
	// Get the original lunge's vector
	float lungeVector[3];
	GetEntPropVector(lungeEntity, Prop_Send, "m_queuedLunge", lungeVector);
	float x = lungeVector[X];
	float y = lungeVector[Y];
	float z = lungeVector[Z];
    
    // Create a int vector of the desired angle from the original
	turnAngle = DegToRad(turnAngle); // convert angle to radian form
	float forcedLunge[3];
	forcedLunge[X] = x * Cosine(turnAngle) - y * Sine(turnAngle); 
	forcedLunge[Y] = x * Sine(turnAngle)   + y * Cosine(turnAngle);
	forcedLunge[Z] = z;
	
	SetEntPropVector(lungeEntity, Prop_Send, "m_queuedLunge", forcedLunge);	
}

// Stop pounces being too high
static void LimitLungeVerticality( int lungeEntity ) {
	// Get vertical angle restriction
	float vertAngle = g_fCvarPounceVerticalAngle;
	// Get the original lunge's vector
	float lungeVector[3];
	GetEntPropVector(lungeEntity, Prop_Send, "m_queuedLunge", lungeVector);
	float x = lungeVector[X];
	float y = lungeVector[Y];
	float z = lungeVector[Z];
	
	vertAngle = DegToRad(vertAngle);	
	float flatLunge[3];
	// First rotation
	flatLunge[Y] = y * Cosine(vertAngle) - z * Sine(vertAngle);
	flatLunge[Z] = y * Sine(vertAngle) + z * Cosine(vertAngle);
	// Second rotation
	flatLunge[X] = x * Cosine(vertAngle) + z * Sine(vertAngle);
	flatLunge[Z] = x * -Sine(vertAngle) + z * Cosine(vertAngle);
	
	SetEntPropVector(lungeEntity, Prop_Send, "m_queuedLunge", flatLunge);
}

/** 
 * Thanks to Newteee:
 * Random number generator fit to a bellcurve. Function to generate Gaussian Random Number fit to a bellcurve with a specified mean and std
 * Uses Polar Form of the Box-Muller transformation
*/
static float GaussianRNG( float mean, float std ) {	 	
	// Randomising positive/negative
	float chanceToken = GetRandomFloat( 0.0, 1.0 );
	int signBit;	
	if( chanceToken >= 0.5 ) {
		signBit = POSITIVE;
	} else {
		signBit = NEGATIVE;
	}	   
	
	float x1;
	float x2;
	float w;
	// Box-Muller algorithm
	do {
	    // Generate random number
	    float random1 = GetRandomFloat( 0.0, 1.0 );	// Random number between 0 and 1
	    float random2 = GetRandomFloat( 0.0, 1.0 );	// Random number between 0 and 1
	 
	    x1 = 2.0 * random1 - 1.0;
	    x2 = 2.0 * random2 - 1.0;
	    w = x1 * x1 + x2 * x2;
	 
	} while( w >= 1.0 );	 
	static float e = 2.71828;
	w = SquareRoot( -2.0 * ( Logarithm(w, e)/ w )); 

	// Random normal variable
	float y1 = x1 * w;
	float y2 = x2 * w;
	 
	// Random gaussian variable with std and mean
	float z1 = y1 * std + mean;
	float z2 = y2 * std - mean;
	
	#if DEBUG_HUNTER_RNG	
		if( signBit == NEGATIVE )PrintToChatAll("Angle: %f", z1);
		else PrintToChatAll("Angle: %f", z2);
	#endif
	
	// Output z1 or z2 depending on sign
	if( signBit == NEGATIVE )return z1;
	else return z2;
}

// After the given interval, hunter is allowed to pounce/lunge
static Action Timer_LungeInterval(Handle timer, any client) {
	g_bCanLunge[client] = true;

	return Plugin_Continue;
}

// Actions API--------------

stock void AI_Hunter_OnActionCreated(BehaviorAction action, const char[] name)
{
	if (strcmp(name[6], "Attack") == 0)
	{
		action.OnCommandAssault = HunterAttack_OnCommandAssault;
	}
}

static Action HunterAttack_OnCommandAssault(any action, int actor, ActionDesiredResult result)
{	
	if(g_iCvarHunterLeapAwayGiveUpRange <= 0) return Plugin_Continue;
	
	// 回復Leap Away能力，也會導致Hunter原地不動等倖存者過來
	return Plugin_Handled;
}