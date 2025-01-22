#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
enum Angle_Vector {
	Pitch = 0,
	Yaw,
	Roll
};

static ConVar g_hJockeyLeapRange, g_hJockeyLeapAgain;
static float g_fJockeyLeapRange, g_fJockeyLeapAgain;
static ConVar g_hCvarEnable, g_hCvarHopActivationProximity; 
static bool g_bCvarEnable;
static int g_iCvarHopActivationProximity;

static float
	g_fLeapAgainTime[MAXPLAYERS + 1];

static bool 
	g_bDoNormalJump[MAXPLAYERS + 1]; // used to alternate pounces and normal jumps

void Jockey_OnModuleStart() 
{
	g_hJockeyLeapAgain = FindConVar("z_jockey_leap_again_timer");
	g_hJockeyLeapRange = FindConVar("z_jockey_leap_range");
	GetOfficialCvars();
	g_hJockeyLeapAgain.AddChangeHook(OnJockeyCvarChange);
	g_hJockeyLeapRange.AddChangeHook(OnJockeyCvarChange);

	g_hCvarEnable 		= CreateConVar( "AI_HardSI_Jockey_enable",   "1",   "0=Improves the Jockey behaviour off, 1=Improves the Jockey behaviour on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvarHopActivationProximity = CreateConVar("ai_hop_activation_proximity", "500", "How close a jockey will approach before it starts hopping", FCVAR_NOTIFY, true, 0.0);


	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_EnableCvars);
	g_hCvarHopActivationProximity.AddChangeHook(CvarChanged);

	if(g_bCvarEnable) _OnModuleStart();
}

static void _OnModuleStart()
{
	if(g_bPluginEnd) return;
}

void Jockey_OnModuleEnd() 
{
	
}

static void OnJockeyCvarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
    GetOfficialCvars();
}

static void GetOfficialCvars()
{
	g_fJockeyLeapRange = g_hJockeyLeapRange.FloatValue;
	g_fJockeyLeapAgain = g_hJockeyLeapAgain.FloatValue;
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
        Jockey_OnModuleEnd();
    }
}

static void CvarChanged(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
    GetCvars();
}

static void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_iCvarHopActivationProximity = g_hCvarHopActivationProximity.IntValue;
}

/***********************************************************************************************************************************************************************************

																	HOPS: ALTERNATING LEAP AND JUMP

***********************************************************************************************************************************************************************************/

stock Action Jockey_OnPlayerRunCmd(int jockey, int &buttons) {
	if(!g_bCvarEnable) return Plugin_Continue;

	if (!GetEntProp(jockey, Prop_Send, "m_hasVisibleThreats"))
		return Plugin_Continue;

	float jockeyPos[3];
	GetClientAbsOrigin(jockey, jockeyPos);
	int iSurvivorsProximity = GetSurvivorProximity(jockeyPos);
	if (iSurvivorsProximity == -1) return Plugin_Continue;
	
	if ( iSurvivorsProximity < g_iCvarHopActivationProximity ) {
		
		if (!IsGrounded(jockey)) {
			buttons &= ~IN_JUMP;
			buttons &= ~IN_ATTACK;
		}

		if (g_bDoNormalJump[jockey]) {
			g_bDoNormalJump[jockey] = false;
			if (buttons & IN_FORWARD && WithinViewAngle(jockey, 60.0)) {
				switch (Math_GetRandomInt(0, 1)) {
					case 0:
						buttons |= IN_MOVELEFT;
		
					case 1:
						buttons |= IN_MOVERIGHT;
				}
			}

			buttons |= IN_JUMP;

			switch (Math_GetRandomInt(0, 2)) {
				case 0:
					buttons |= IN_DUCK;
		
				case 1:
					buttons |= IN_ATTACK2;
			}
		}
		else {
			static float time;
			time = GetEngineTime();
			if (g_fLeapAgainTime[jockey] < time) {
				if (iSurvivorsProximity < g_fJockeyLeapRange )
					buttons |= IN_ATTACK;

				g_bDoNormalJump[jockey] = true;
				g_fLeapAgainTime[jockey] = time + g_fJockeyLeapAgain;
			}
		}

		return Plugin_Changed;
	} 

	return Plugin_Continue;
}

// Enable hopping on spawned jockeys
void Jockey_OnSpawn(int botJockey) {
	if(!g_bCvarEnable) return;
	
	g_fLeapAgainTime[botJockey] = 0.0;
}