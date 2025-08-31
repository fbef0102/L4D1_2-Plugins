#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#define BoostForward 60.0 // Bhop

#define VelocityOvr_None 0
#define VelocityOvr_Velocity 1
#define VelocityOvr_OnlyWhenNegative 2
#define VelocityOvr_InvertReuseVelocity 3

static ConVar g_hTankThrowForce;
static float g_fTankThrowForce;

static ConVar g_hCvarEnable, g_hCvarTankBhop, g_hCvarTankRock, g_hCvarTankThrow, g_hAimOffsetSensitivity; 
static bool g_bCvarEnable, g_bCvarTankBhop, g_bCvarTankRock, g_bCvarTankThrow;
static float g_fAimOffsetSensitivity;

methodmap PlayerBody
{
	property CountdownTimer m_lookAtExpireTimer {
		public get() {
			return view_as<CountdownTimer>(
				view_as<Address>(this) + view_as<Address>(100)
			);
		}
	}
}

void Tank_OnModuleStart() 
{
	g_hTankThrowForce =			FindConVar("z_tank_throw_force");

	g_hCvarEnable 				= CreateConVar("AI_HardSI_Tank_enable",   				"1",   	"0=Improves the Tank behaviour off, 1=Improves the Tank behaviour on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hCvarTankBhop 			= CreateConVar("ai_tank_bhop", 							"1", 	"If 1, enable bhop facsimile on AI tanks", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarTankRock 			= CreateConVar("ai_tank_rock", 							"1", 	"1=AI tanks throw rock, 0=AI tanks won't throw rocks", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarTankThrow 			= CreateConVar("ai_tank_smart_throw", 					"1", 	"If 1, Prevents AI tanks from throwing underhand rocks (L4D2 only)\nIf 1, AI tank can quickly turn around if someone behind him after throws", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hAimOffsetSensitivity 	= CreateConVar("ai_tank_aim_offset_sensitivity",		"22.5",	"If the tank has a target while throwing the rock, the rock would fly to the closest survivor if the target's aim on the horizontal axis is within this radius (-1=Off)", _, true, -1.0, true, 180.0);
	
	GetCvars();
	g_hTankThrowForce.AddChangeHook(CvarChanged);
	g_hCvarEnable.AddChangeHook(ConVarChanged_EnableCvars);
	g_hCvarTankBhop.AddChangeHook(CvarChanged);
	g_hCvarTankRock.AddChangeHook(CvarChanged);
	g_hCvarTankThrow.AddChangeHook(CvarChanged);
	g_hAimOffsetSensitivity.AddChangeHook(CvarChanged);
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
	g_fTankThrowForce =			g_hTankThrowForce.FloatValue;

	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarTankBhop = g_hCvarTankBhop.BoolValue;
	g_bCvarTankRock = g_hCvarTankRock.BoolValue;
	g_bCvarTankThrow = g_hCvarTankThrow.BoolValue;
	g_fAimOffsetSensitivity = g_hAimOffsetSensitivity.FloatValue;
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
				if(g_bL4D2Version)
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
				else
				{
					int Activity = L4D1_GetMainActivity(tank);
					if(Activity == L4D1_ACT_HULK_THROW || Activity == L4D1_ACT_TANK_OVERHEAD_THROW || Activity == L4D1_ACT_HULK_ATTACK_LOW)
					{
						GetEntPropVector(tank, Prop_Data, "m_vecVelocity", vel);
						vel[2] = 280.0;
						TeleportEntity(tank, NULL_VECTOR, NULL_VECTOR, vel);  
						//buttons &= ~IN_JUMP;
					}
				}
			}
		}
	}

	return Plugin_Continue;	
}

Action Tank_OnSelectTankAttack(int client, int &sequence) 
{
	if(!g_bL4D2Version) return Plugin_Continue;
	if(!g_bCvarEnable || !g_bCvarTankThrow) return Plugin_Continue;

	if (IsFakeClient(client) && sequence == 50) // underhand rock
	{
		sequence = GetRandomInt(0, 1) ? 49 : 51;
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

// rock 自動轉向最近的倖存者
Action Tank_TankRock_OnRelease(int tank, int rock, float vecAng[3], float vecVel[3])
{
	if(!g_bCvarEnable || g_fAimOffsetSensitivity < 0) return Plugin_Continue;
	
	if (rock <= MaxClients || !IsValidEntity(rock))
		return Plugin_Continue;

	if (tank < 1 || tank > MaxClients || !IsClientInGame(tank)|| GetClientTeam(tank) != 3)
		return Plugin_Continue;

	if(g_bL4D2Version && GetEntProp(tank, Prop_Send, "m_zombieClass") != L4D2Infected_Tank) return Plugin_Continue;
	if(!g_bL4D2Version && GetEntProp(tank, Prop_Send, "m_zombieClass") != L4D1Infected_Tank) return Plugin_Continue;

	if (!IsFakeClient(tank))
		return Plugin_Continue;

	int target = GetClientAimTarget(tank, true);
	if (IsAliveSur(target) && !L4D_IsPlayerIncapacitated(target) && !IsPinned(target) && !RockHitWall(tank, rock, target) && !WithinViewAngle(tank, g_fAimOffsetSensitivity, target))
		return Plugin_Continue;
	
	target = GetClosestSur(tank, rock, 2.0 * g_fTankThrowForce, target);
	if (!IsAliveSur(target))
		return Plugin_Continue;

	float vPos[3];
	float vTar[3];
	float vVec[3];
	GetClientAbsOrigin(tank, vPos);
	GetClientAbsOrigin(target, vTar);

	vVec[2] = vPos[2];
	vPos[2] = vTar[2];
	vTar[2] += GetVectorDistance(vPos, vTar) / g_fTankThrowForce * PLAYER_HEIGHT;

	vPos[2] = vVec[2];
	float delta = vTar[2] - vPos[2];
	if (delta > PLAYER_HEIGHT)
		vTar[2] += delta / PLAYER_HEIGHT * 7.2;
	else {
		bool success;
		while (delta < PLAYER_HEIGHT) {
			if (!RockHitWall(tank, rock, -1, vTar)) {
				success = true;
				break;
			}

			delta += 7.0;
			vTar[2] += 7.0;
		}

		if (!success)
			vTar[2] -= 14.0;
	}

	GetClientEyePosition(tank, vPos);
	MakeVectorFromPoints(vPos, vTar, vVec);
	GetVectorAngles(vVec, vTar);
	vecAng = vTar;

	float vel = GetVectorLength(vVec);
	vel = vel > g_fTankThrowForce ? vel : g_fTankThrowForce;
	NormalizeVector(vVec, vVec);
	ScaleVector(vVec, vel + GetTargetRunTopSpeed(target));
	vecVel = vVec;
	return Plugin_Changed;
}

// 丟完rock之後馬上轉身打背後的倖存者
void Tank_TankRock_OnRelease_Post(int client)
{
	if(!g_bCvarEnable || !g_bCvarTankThrow) return;

	if (client <= 0 || client > MaxClients || !IsClientInGame(client) || !IsFakeClient(client))
		return;
	
	int ability = GetEntPropEnt(client, Prop_Send, "m_customAbility");
	if (ability == -1)
		return;

	CountdownTimer throwTimer = CThrow__GetThrowTimer(ability);
	float flThrowEndTime = CTimer_GetTimestamp(throwTimer);
	
	CreateTimer(flThrowEndTime - GetGameTime() + 0.01, Timer_ExpireLookAt, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_ExpireLookAt(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (!client || !IsClientInGame(client)) // gone
		return Plugin_Stop;
	
	if (GetClientTeam(client) != 3) // taken over
		return Plugin_Stop;
	
	if (L4D_IsPlayerIncapacitated(client) || !IsPlayerAlive(client)) // dead
		return Plugin_Stop;
	
	PlayerBody pBody = Tank__GetBodyInterface(client);
	CTimer_SetTimestamp(pBody.m_lookAtExpireTimer, GetGameTime());
	
	return Plugin_Stop;
}

PlayerBody Tank__GetBodyInterface(int tank)
{
	static int s_iOffs_m_playerBody = -1;
	if (s_iOffs_m_playerBody == -1)
		s_iOffs_m_playerBody = FindSendPropInfo("SurvivorBot"/* lol */, "m_humanSpectatorEntIndex") + 12 - 4 * view_as<int>(L4D_IsEngineLeft4Dead2());
	
	return view_as<PlayerBody>(
		LoadFromAddress(GetEntityAddress(tank) + view_as<Address>(s_iOffs_m_playerBody), NumberType_Int32)
	);
}

CountdownTimer CThrow__GetThrowTimer(int ability)
{
	static int s_iOffs_m_throwTimer = -1;
	if (s_iOffs_m_throwTimer == -1)
		s_iOffs_m_throwTimer = FindSendPropInfo("CThrow", "m_hasBeenUsed") + 4;
	
	return view_as<CountdownTimer>(
		GetEntityAddress(ability) + view_as<Address>(s_iOffs_m_throwTimer)
	);
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

stock int GetClosestSur(int client, int ent, float range, int exclude = -1) {
	static int i;
	static int num;
	static int index;
	static float dist;
	static float vAng[3];
	static float vSrc[3];
	static float vTar[3];
	static int clients[MAXPLAYERS + 1];
	
	num = 0;
	GetClientEyePosition(client, vSrc);
	num = GetClientsInRange(vSrc, RangeType_Visibility, clients, MAXPLAYERS);

	if (!num)
		return exclude;

	static ArrayList al_targets;
	al_targets = new ArrayList(3);
	float fov = GetFOVDotProduct(g_fAimOffsetSensitivity);
	for (i = 0; i < num; i++) {
		if (!clients[i] || clients[i] == exclude)
			continue;

		if (GetClientTeam(clients[i]) != 2 || !IsPlayerAlive(clients[i]) || L4D_IsPlayerIncapacitated(clients[i]) || IsPinned(clients[i]) || RockHitWall(client, ent, clients[i]))
			continue;

		GetClientEyePosition(clients[i], vTar);
		dist = GetVectorDistance(vSrc, vTar);
		if (dist < range) {
			index = al_targets.Push(dist);
			al_targets.Set(index, clients[i], 1);

			GetClientEyeAngles(clients[i], vAng);
			al_targets.Set(index, !PointWithinViewAngle(vTar, vSrc, vAng, fov) ? 0 : 1, 2);
		}
	}

	if (!al_targets.Length) {
		delete al_targets;
		return exclude;
	}

	al_targets.Sort(Sort_Ascending, Sort_Float);
	index = al_targets.FindValue(0, 2);
	i = al_targets.Get(index != -1 && al_targets.Get(index, 0) < g_fTankThrowForce ? index : Math_GetRandomInt(0, RoundToCeil((al_targets.Length - 1) * 0.8)), 1);
	delete al_targets;
	return i;
}

stock bool RockHitWall(int tank, int ent, int target = -1, const float vEnd[3] = NULL_VECTOR) {
	static float vSrc[3];
	static float vTar[3];
	GetClientEyePosition(tank, vSrc);

	if (target == -1)
		vTar = vEnd;
	else
		GetClientEyePosition(target, vTar);

	static float vMins[3];
	static float vMaxs[3];
	GetEntPropVector(ent, Prop_Send, "m_vecMins", vMins);
	GetEntPropVector(ent, Prop_Send, "m_vecMaxs", vMaxs);

	static bool hit;
	static Handle hndl;
	hndl = TR_TraceHullFilterEx(vSrc, vTar, vMins, vMaxs, MASK_SOLID, TraceRockFilter, ent);
	hit = TR_DidHit(hndl);
	delete hndl;
	return hit;
}

stock bool TraceRockFilter(int entity, int contentsMask, any data) {
	if (entity == data)
		return false;

	if (!entity || entity > MaxClients) {
		static char cls[5];
		GetEdictClassname(entity, cls, sizeof cls);
		return cls[3] != 'e' && cls[3] != 'c';
	}

	return false;
}