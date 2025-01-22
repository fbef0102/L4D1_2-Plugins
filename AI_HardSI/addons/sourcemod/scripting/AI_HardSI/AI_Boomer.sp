#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#define BOOST			90.0

static ConVar g_hVomitRange;
static float g_fVomitRange;

static ConVar g_hCvarEnable, g_hBoomerBhop; 
static bool g_bCvarEnable, g_bBoomerBhop;

void Boomer_OnModuleStart() 
{
	g_hVomitRange 		= FindConVar("z_vomit_range");
	GetOfficialCvars();
	g_hVomitRange.AddChangeHook(OnBoomerCvarChange);

	g_hCvarEnable 		= CreateConVar( "AI_HardSI_Boomer_enable",   "1",   "0=Improves the Boomer behaviour off, 1=Improves the Boomer behaviour on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBoomerBhop 		= CreateConVar( "ai_boomer_bhop", 			 "1", 	"If 1, enable bhop facsimile on AI boomers", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_EnableCvars);
	g_hBoomerBhop.AddChangeHook(CvarChanged);

	if(g_bCvarEnable) _OnModuleStart();
}

static void _OnModuleStart()
{
	if(g_bPluginEnd) return;
}

void Boomer_OnModuleEnd() 
{

}

static void OnBoomerCvarChange(ConVar convar, const char[] oldValue, const char[] newValue) 
{
    GetOfficialCvars();
}

static void GetOfficialCvars()
{
	g_fVomitRange = g_hVomitRange.FloatValue;
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
        Boomer_OnModuleEnd();
    }
}

static void CvarChanged(ConVar convar, const char[] oldValue, const char[] newValue) 
{
	GetCvars();
}

static void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bBoomerBhop = g_hBoomerBhop.BoolValue;
}

stock Action Boomer_OnPlayerRunCmd(int client, int &buttons) {
	if (!g_bCvarEnable || !g_bBoomerBhop)
		return Plugin_Continue;

	if (!IsGrounded(client) || GetEntityMoveType(client) == MOVETYPE_LADDER || GetEntProp(client, Prop_Data, "m_nWaterLevel") > 1 && (!GetEntProp(client, Prop_Send, "m_hasVisibleThreats") && !TargetSur(client)))
		return Plugin_Continue;

	static float vVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
	vVel[2] = 0.0;
	if (!CheckPlayerMove(client, GetVectorLength(vVel)))
		return Plugin_Continue;

	static float curTargetDist;
	static float nearestSurDist;
	GetSurDistance(client, curTargetDist, nearestSurDist);
	if (curTargetDist > 0.50 * g_fVomitRange && -1.0 < nearestSurDist < 1500.0) {
		static float vAng[3];
		GetClientEyeAngles(client, vAng);
		return BunnyHop(client, buttons, vAng);
	}

	return Plugin_Continue;
}

void ability_use_OnVomit(int client) {
	if(!g_bCvarEnable) return;

	int target = GetClientAimTarget(client, false); //g_iCurTarget[client];
	if (!IsAliveSur(target) || GetEntPropFloat(target, Prop_Send, "m_itTimer", 1) != -1.0)
		target = FindVomitTarget(client, g_fVomitRange + 2.0 * PLAYER_HEIGHT, target);

	if (!IsAliveSur(target))
		return;

	float vPos[3], vTar[3], vVel[3];
	GetClientAbsOrigin(client, vPos);
	GetClientEyePosition(target, vTar);
	MakeVectorFromPoints(vPos, vTar, vVel);

	float vel = GetVectorLength(vVel);
	if (vel < g_fVomitRange)
		vel = 0.5 * g_fVomitRange;

	float height = vTar[2] - vPos[2];
	if (height > PLAYER_HEIGHT)
		vel += GetVectorDistance(vPos, vTar) / vel * PLAYER_HEIGHT;

	float vAng[3];
	GetVectorAngles(vVel, vAng);
	NormalizeVector(vVel, vVel);
	ScaleVector(vVel, vel);

	int flags = GetEntityFlags(client);
	SetEntityFlags(client, (flags & ~FL_FROZEN) & ~FL_ONGROUND);
	TeleportEntity(client, NULL_VECTOR, vAng, vVel);
	SetEntityFlags(client, flags);
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

static int FindVomitTarget(int client, float range, int exclude = -1) {
	static int i;
	static int num;
	static float dist;
	static float vecPos[3];
	static float vecTarget[3];
	static int clients[MAXPLAYERS + 1];
	
	num = 0;
	GetClientEyePosition(client, vecPos);
	num = GetClientsInRange(vecPos, RangeType_Visibility, clients, MAXPLAYERS);
	
	if (!num)
		return exclude;

	static ArrayList al_targets;
	al_targets = new ArrayList(2);
	for (i = 0; i < num; i++) {
		if (!clients[i] || clients[i] == exclude)
			continue;
		
		if (GetClientTeam(clients[i]) != 2 || !IsPlayerAlive(clients[i]) || GetEntPropFloat(clients[i], Prop_Send, "m_itTimer", 1) != -1.0)
			continue;

		GetClientAbsOrigin(clients[i], vecTarget);
		dist = GetVectorDistance(vecPos, vecTarget);
		if (dist < range)
			al_targets.Set(al_targets.Push(dist), clients[i], 1);
	}

	if (!al_targets.Length) {
		delete al_targets;
		return exclude;
	}

	al_targets.Sort(Sort_Ascending, Sort_Float);
	num = al_targets.Get(0, 1);
	delete al_targets;
	return num;
}