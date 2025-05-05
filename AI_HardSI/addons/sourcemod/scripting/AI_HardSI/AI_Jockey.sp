#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
enum Angle_Vector {
	Pitch = 0,
	Yaw,
	Roll
};

static ConVar g_hJockeyLeapRange;
static float g_fJockeyLeapRange;
static ConVar g_hCvarEnable, g_hCvarHopActivationProximity; 
static bool g_bCvarEnable;
static int g_iCvarHopActivationProximity;

static bool 
	g_bDoNormalJump[MAXPLAYERS + 1]; // used to alternate pounces and normal jumps

void Jockey_OnModuleStart() 
{
	g_hJockeyLeapRange = FindConVar("z_jockey_leap_range"); //If victim is this close, leap at them
	GetOfficialCvars();
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

stock Action Jockey_OnPlayerRunCmd(int jockey, int &buttons) 
{
	if(!g_bCvarEnable) return Plugin_Continue;

	if (!GetEntProp(jockey, Prop_Send, "m_hasVisibleThreats"))
		return Plugin_Continue;

	if (L4D_GetVictimJockey(jockey) > 0)
		return Plugin_Continue;

	float jockeyPos[3];
	GetClientAbsOrigin(jockey, jockeyPos);
	int iSurvivorsProximity = GetSurvivorProximity(jockeyPos);
	if (iSurvivorsProximity == -1) return Plugin_Continue;
	
	if ( iSurvivorsProximity < g_iCvarHopActivationProximity ) {
		
		bool bIsGround = IsGrounded(jockey);
		if (!bIsGround) 
		{
			buttons &= ~IN_JUMP;
			buttons &= ~IN_ATTACK;
			buttons |= IN_ATTACK2;
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
		}
		else 
		{
			if(bIsGround)
			{
				int ability = GetEntPropEnt(jockey, Prop_Send, "m_customAbility");
				if (ability == -1 || !IsValidEntity(ability)) {
					return Plugin_Continue;
				}

				if (iSurvivorsProximity < g_fJockeyLeapRange)
				{

					if(GetEntPropFloat(ability, Prop_Send, "m_nextActivationTimer", 1) < GetGameTime()) // CLeap->m_nextActivationTimer->m_timestamp (GameTime)
					{
						buttons |= IN_ATTACK;
					}
					else
					{
						buttons |= IN_JUMP;
					}
				}
			}
		}

		return Plugin_Changed;
	} 

	return Plugin_Continue;
}