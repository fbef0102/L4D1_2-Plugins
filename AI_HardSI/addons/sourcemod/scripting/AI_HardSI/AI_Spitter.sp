#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法



static ConVar
	g_hCvarEnable,
	g_hSpitterBhop;

static bool
	g_bCvarEnable,	
	g_bSpitterBhop;

void Spitter_OnModuleStart() {
	g_hCvarEnable 		= CreateConVar( "AI_HardSI_Spitter_enable",   "1",   "0=Improves the Spitter behaviour off, 1=Improves the Spitter behaviour on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSpitterBhop 		= CreateConVar( "ai_spitter_bhop", 			  "1", 	 "If 1, enable bhop facsimile on AI spitters", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_EnableCvars);
	g_hSpitterBhop.AddChangeHook(CvarChanged);
}

static void _OnModuleStart()
{
	if(g_bPluginEnd) return;
}

void Spitter_OnModuleEnd() 
{
}

static void ConVarChanged_EnableCvars(ConVar convar, const char[] oldValue, const char[] newValue) 
{
	GetCvars();
	if(g_bCvarEnable)
	{
		_OnModuleStart();
	}
	else
	{
		Spitter_OnModuleEnd();
	}
}

static void CvarChanged(ConVar convar, const char[] oldValue, const char[] newValue) 
{
	GetCvars();
}

static void GetCvars() {
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bSpitterBhop = g_hSpitterBhop.BoolValue;
}

stock Action Spitter_OnPlayerRunCmd(int client, int &buttons) {
	if (!g_bCvarEnable) return Plugin_Continue;

	if (!g_bSpitterBhop)
		return Plugin_Continue;

	if (IsGrounded(client) && GetEntityMoveType(client) != MOVETYPE_LADDER && GetEntProp(client, Prop_Data, "m_nWaterLevel") < 2 && GetEntProp(client, Prop_Send, "m_hasVisibleThreats")) {
		static float vVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
		vVel[2] = 0.0;
		if (!CheckPlayerMove(client, GetVectorLength(vVel)))
			return Plugin_Continue;
	
		if (150.0 < NearestSurDistance(client) < 1500.0) {
			static float vAng[3];
			GetClientEyeAngles(client, vAng);
			buttons |= IN_ATTACK2;
			return BunnyHop(client, buttons, vAng);
		}
	}

	return Plugin_Continue;
}

static Action BunnyHop(int client, int &buttons, const float vAng[3]) {
	float vVec[3];
	if (buttons & IN_FORWARD && !(buttons & IN_BACK)) {
		GetAngleVectors(vAng, vVec, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vVec, vVec);
		ScaleVector(vVec, BOOST * 2.0);
		float vVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vVel);
		AddVectors(vVel, vVec, vVel);
		if (CheckHopVel(client, vAng, vVel)) {
			buttons |= IN_DUCK;
			buttons |= IN_JUMP;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
			return Plugin_Changed;
		}
	}
	else if (buttons & IN_BACK && !(buttons & IN_FORWARD)) {
		GetAngleVectors(vAng, vVec, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vVec, vVec);
		ScaleVector(vVec, -BOOST);
		float vVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vVel);
		AddVectors(vVel, vVec, vVel);
		if (CheckHopVel(client, vAng, vVel)) {
			buttons |= IN_DUCK;
			buttons |= IN_JUMP;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
			return Plugin_Changed;
		}
	}

	if (buttons & IN_MOVERIGHT && !(buttons & IN_MOVELEFT)) {
		GetAngleVectors(vAng, NULL_VECTOR, vVec, NULL_VECTOR);
		NormalizeVector(vVec, vVec);
		ScaleVector(vVec, BOOST);
		float vVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vVel);
		AddVectors(vVel, vVec, vVel);
		if (CheckHopVel(client, vAng, vVel)) {
			buttons |= IN_DUCK;
			buttons |= IN_JUMP;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
			return Plugin_Changed;
		}
	}
	else if (buttons & IN_MOVELEFT && !(buttons & IN_MOVERIGHT)) {
		GetAngleVectors(vAng, NULL_VECTOR, vVec, NULL_VECTOR);
		NormalizeVector(vVec, vVec);
		ScaleVector(vVec, -BOOST);
		float vVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vVel);
		AddVectors(vVel, vVec, vVel);
		if (CheckHopVel(client, vAng, vVel)) {
			buttons |= IN_DUCK;
			buttons |= IN_JUMP;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}