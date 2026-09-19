#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#define BOOST			90.0

static ConVar g_hVomitRange;
static float g_fVomitRange;

static ConVar g_hCvarEnable, g_hBoomerBhop, g_hBoomerM2, g_hBoomerMultiVomit, g_hBoomerPreventFall; 
static bool g_bCvarEnable, g_bBoomerBhop, g_bBoomerM2, g_bBoomerMultiVomit, g_bBoomerPreventFall;

void Boomer_OnModuleStart() 
{
	g_hVomitRange 		= FindConVar("z_vomit_range");
	GetOfficialCvars();
	g_hVomitRange.AddChangeHook(OnBoomerCvarChange);

	g_hCvarEnable 			= CreateConVar( "AI_HardSI_Boomer_enable",   		"1",   	"0=Improves the Boomer behaviour off, 1=Improves the Boomer behaviour on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBoomerBhop 			= CreateConVar( "AI_HardSI_Boomer_bhop_enable", 	"1", 	"If 1, enable bhop facsimile on AI boomers", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBoomerM2 			= CreateConVar( "AI_HardSI_Boomer_bhop_m2", 		"1", 	"If 1, AI boomers scratch while doing bhop", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBoomerMultiVomit 	= CreateConVar( "AI_HardSI_Boomer_multi_vomit", 	"1", 	"If 1, AI boomers try to vomit on multi survivors instead of only one target", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBoomerPreventFall 	= CreateConVar( "AI_HardSI_Boomer_prevent_fall", 	"1", 	"If 1, AI boomers no longer explode from fall damage on coop/realism/survival mode", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_EnableCvars);
	g_hBoomerBhop.AddChangeHook(CvarChanged);
	g_hBoomerM2.AddChangeHook(CvarChanged);
	g_hBoomerMultiVomit.AddChangeHook(CvarChanged);
	g_hBoomerPreventFall.AddChangeHook(CvarChanged);

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
	g_bBoomerM2 = g_hBoomerM2.BoolValue;
	g_bBoomerMultiVomit = g_hBoomerMultiVomit.BoolValue;
	g_bBoomerPreventFall = g_hBoomerPreventFall.BoolValue;
}

stock Action Boomer_OnPlayerRunCmd(int client, int &buttons) {
	if (!g_bCvarEnable)
		return Plugin_Continue;

	if (!IsGrounded(client) || GetEntityMoveType(client) == MOVETYPE_LADDER || GetEntProp(client, Prop_Data, "m_nWaterLevel") > 1)
		return Plugin_Continue;

	int m_customAbility = GetEntPropEnt(client, Prop_Send, "m_customAbility");
	// is puking
	if(m_customAbility > MaxClients && GetEntProp(m_customAbility, Prop_Send, "m_isSpraying", 1))
	{
		if(g_bBoomerMultiVomit)
		{
			int target = FindVomitTarget(client, g_fVomitRange + 80.0, -1);

			if (!IsAliveSur(target))
				return Plugin_Continue;

			float vPos[3], vTar[3], vFinal[3], vVel[3];
			GetClientEyePosition(client, vPos);
			GetClientEyePosition(target, vTar);
			GetClientEyePosition(target, vFinal);
			float distance = GetVectorDistance(vPos, vTar);
			//float height = vTar[2] - vPos[2];
			//PrintToChatAll("%f", distance);
			if(distance >= 250.0)
			{
				vFinal[2] += 80.0;
			}
			else if(250.0 > distance >= 210.0)
			{
				vFinal[2] += 72.0;
			}
			else if(210.0 > distance >= 180.0)
			{
				vFinal[2] += 48.0;
			}
			else if(180.0 > distance >= 150.0)
			{
				vFinal[2] += 30.0;
			}
			else if(150.0 > distance >= 100.0)
			{
				vFinal[2] += 20.0;
			}
			else if(100.0 > distance)
			{
				vFinal[2] += 5.0;
			}

			MakeVectorFromPoints(vPos, vFinal, vVel);

			float vAng[3];
			GetVectorAngles(vVel, vAng);

			int flags = GetEntityFlags(client);
			SetEntityFlags(client, (flags & ~FL_FROZEN) & ~FL_ONGROUND);
			TeleportEntity(client, NULL_VECTOR, vAng, NULL_VECTOR);
			SetEntityFlags(client, flags);
		}

		return Plugin_Continue;
	}

	if(!g_bBoomerBhop || ( !GetEntProp(client, Prop_Send, "m_hasVisibleThreats") && !TargetSur(client) )) return Plugin_Continue;

	static float vVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);
	vVel[2] = 0.0;
	if (!CheckPlayerMove(client, GetVectorLength(vVel)))
		return Plugin_Continue;

	static float curTargetDist;
	static float nearestSurDist;
	GetSurDistance(client, curTargetDist, nearestSurDist);
	if (curTargetDist > 150.0 && -1.0 < nearestSurDist < 1500.0) {
		static float vAng[3];
		GetClientEyeAngles(client, vAng);
		if(g_bBoomerM2) buttons |= IN_ATTACK2;
		return BunnyHop(client, buttons, vAng);
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

stock Action Boomer_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(g_bCvarEnable == false || g_bBoomerPreventFall == false || victim <= 0 || victim > MaxClients || !IsClientInGame(victim)) return Plugin_Continue;
	if(attacker <= 0 || attacker > MaxClients || !IsClientInGame(attacker) ) return Plugin_Continue;

	if(attacker == victim && attacker == inflictor && weapon == -1 && GetClientTeam(attacker) == 3 && GetInfectedClass(attacker) == L4D2Infected_Boomer
		&& damagetype & DMG_FALL)
	{
		return Plugin_Handled;
	}

	return Plugin_Continue;
}
