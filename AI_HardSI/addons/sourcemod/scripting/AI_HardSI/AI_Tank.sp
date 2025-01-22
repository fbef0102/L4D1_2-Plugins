#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#define BoostForward 60.0 // Bhop

#define VelocityOvr_None 0
#define VelocityOvr_Velocity 1
#define VelocityOvr_OnlyWhenNegative 2
#define VelocityOvr_InvertReuseVelocity 3

static ConVar g_hCvarEnable, g_hCvarTankBhop, g_hCvarTankRock; 
static bool g_bCvarEnable, g_bCvarTankBhop, g_bCvarTankRock;

void Tank_OnModuleStart() 
{

	g_hCvarEnable 				= CreateConVar("AI_HardSI_Tank_enable",   				"1",   	"0=Improves the Tank behaviour off, 1=Improves the Tank behaviour on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvarTankBhop 			= CreateConVar("ai_tank_bhop", 							"1", 	"If 1, enable bhop facsimile on AI tanks", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarTankRock 			= CreateConVar("ai_tank_rock", 							"1", 	"1=AI tanks throw rock, 0=Ai tanl won't throw rocks", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_EnableCvars);
	g_hCvarTankBhop.AddChangeHook(CvarChanged);
	g_hCvarTankRock.AddChangeHook(CvarChanged);
}
static void _OnModuleStart()
{
	if(g_bPluginEnd) return;
}

void Tank_OnModuleEnd() 
{
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
        Tank_OnModuleEnd();
    }
}

static void CvarChanged(ConVar convar, const char[] oldValue, const char[] newValue) 
{
	GetCvars();
}

static void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarTankBhop = g_hCvarTankBhop.BoolValue;
	g_bCvarTankRock = g_hCvarTankRock.BoolValue;
}

// Tank bhop and blocking rock throw
stock Action Tank_OnPlayerRunCmd( int tank, int &buttons, float vel[3] ) {
	if(!g_bCvarEnable) return Plugin_Continue;

	// block rock throws
	if( g_bCvarTankRock == false ) 
	{
		buttons &= ~IN_ATTACK2;
	}
	
	if( g_bCvarTankBhop ) 
	{
		if (GetEntityMoveType(tank) == MOVETYPE_LADDER || GetEntProp(tank, Prop_Data, "m_nWaterLevel") > 1 || (!GetEntProp(tank, Prop_Send, "m_hasVisibleThreats") && !TargetSur(tank)))
			return Plugin_Continue;

		int flags = GetEntityFlags(tank);
		
		// Get the player velocity:
		float fVelocity[3];
		GetEntPropVector(tank, Prop_Data, "m_vecVelocity", fVelocity);
		float currentspeed = SquareRoot(Pow(fVelocity[0],2.0)+Pow(fVelocity[1],2.0));
		//PrintCenterTextAll("Tank Speed: %.1f", currentspeed);
		
		// Get Angle of Tank
		float clientEyeAngles[3];
		GetClientEyeAngles(tank,clientEyeAngles);
		
		// LOS and survivor proximity
		float tankPos[3];
		GetClientAbsOrigin(tank, tankPos);
		int iSurvivorsProximity = GetSurvivorProximity(tankPos);
		if (iSurvivorsProximity == -1) return Plugin_Continue;

		// Near survivors
		if( (1500 > iSurvivorsProximity > 105) && currentspeed > 190.0 ) 
		{ 
			if (flags & FL_ONGROUND) 
			{
				buttons |= IN_DUCK;
				buttons |= IN_JUMP;
				
				if(buttons & IN_FORWARD) 
				{
					Client_Push( tank, clientEyeAngles, BoostForward, {VelocityOvr_None,VelocityOvr_None,VelocityOvr_None} );
				}	
				
				if(buttons & IN_BACK) 
				{
					clientEyeAngles[1] += 180.0;
					Client_Push( tank, clientEyeAngles, BoostForward, {VelocityOvr_None,VelocityOvr_None,VelocityOvr_None} );
				}
						
				if(buttons & IN_MOVELEFT) 
				{
					clientEyeAngles[1] += 90.0;
					Client_Push( tank, clientEyeAngles, BoostForward, {VelocityOvr_None,VelocityOvr_None,VelocityOvr_None} );
				}
						
				if(buttons & IN_MOVERIGHT) 
				{
					clientEyeAngles[1] += -90.0;
					Client_Push( tank, clientEyeAngles, BoostForward, {VelocityOvr_None,VelocityOvr_None,VelocityOvr_None} );
				}
			}
			//Block Jumping and Crouching when on ladder
			if (GetEntityMoveType(tank) & MOVETYPE_LADDER) 
			{
				buttons &= ~IN_JUMP;
				buttons &= ~IN_DUCK;
			}

			if(buttons & IN_JUMP)
			{
				int Activity = PlayerAnimState.FromPlayer(tank).GetMainActivity();
				if(Activity == L4D2_ACT_HULK_THROW || Activity == L4D2_ACT_TANK_OVERHEAD_THROW || Activity == L4D2_ACT_HULK_ATTACK_LOW)
				{
					GetEntPropVector(tank, Prop_Data, "m_vecVelocity", vel);
					vel[2] = 280.0;
					TeleportEntity(tank, NULL_VECTOR, NULL_VECTOR, vel);  
					//buttons &= ~IN_JUMP;
				}
			}
		}
	}

	return Plugin_Continue;	
}

Action Tank_OnSelectTankAttack(int client, int &sequence) {
	if(!g_bCvarEnable) return Plugin_Continue;

	if (IsFakeClient(client) && sequence == 50) // underhand rock
	{
		sequence = GetRandomInt(0, 1) ? 49 : 51;
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

stock void Client_Push(int client, float clientEyeAngle[3], float power, int override[3]) {
	float forwardVector[3], newVel[3];
	
	GetAngleVectors(clientEyeAngle, forwardVector, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(forwardVector, forwardVector);
	ScaleVector(forwardVector, power);
	//PrintToChatAll("Tank velocity: %.2f", forwardVector[1]);
	
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", newVel);
	
	for( int i = 0; i < 3; i++ ) {
		switch( override[i] ) {
			case VelocityOvr_Velocity: {
				newVel[i] = 0.0;
			}
			case VelocityOvr_OnlyWhenNegative: {				
				if( newVel[i] < 0.0 ) {
					newVel[i] = 0.0;
				}
			}
			case VelocityOvr_InvertReuseVelocity: {				
				if( newVel[i] < 0.0 ) {
					newVel[i] *= -1.0;
				}
			}
		}
		
		newVel[i] += forwardVector[i];
	}
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, newVel);
}