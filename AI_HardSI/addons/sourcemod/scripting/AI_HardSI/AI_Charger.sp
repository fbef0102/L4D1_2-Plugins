#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#define DEBUG_CHARGER_TARGET 0
#define FIXFLY			1

static ConVar g_hCvarEnable, g_hChargerBhop,
	g_hCvarChargeProximity, g_hCvarAimOffsetSensitivity, g_hCvarHealthThreshold,
	g_hChargeMaxSpeed, g_hChargeStartSpeed;
static int g_iCvarChargeProximity, g_iCvarHealthThreshold;
static float g_fCvarAimOffsetSensitivity, g_fChargeMaxSpeed, g_fChargeStartSpeed;
static bool g_bCvarEnable, g_bChargerBhop;

static int 
	g_bShouldCharge[MAXPLAYERS+ 1];

static bool 
	g_bModify[MAXPLAYERS + 1];

void Charger_OnModuleStart() {
	g_hCvarEnable 						= CreateConVar("AI_HardSI_Charger_enable",   			"1",   		"0=Improves the Charger behaviour off, 1=Improves the Charger behaviour on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	g_hChargerBhop 						= CreateConVar("ai_charger_bhop",			  			"1",	 	"If 1, enable bhop facsimile on AI chargers", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarChargeProximity 				= CreateConVar("ai_charger_proximity", 		  			"300", 		"How close a charger will approach before charging", FCVAR_NOTIFY, true, 0.0);	
	g_hCvarAimOffsetSensitivity 		= CreateConVar("ai_charger_aim_offset_sensitivity", 	"22.5", 	"If the charger has a target, it will not straight pounce if the target's aim on the horizontal axis is within this radius", FCVAR_NOTIFY, true, 0.0, true, 179.0);
	g_hCvarHealthThreshold 				= CreateConVar("ai_charger_health_threshold", 			"300", 		"Charger will charge if its health drops to this level", FCVAR_NOTIFY, true, 0.0);	

	g_hChargeMaxSpeed =			FindConVar("z_charge_max_speed");
	g_hChargeStartSpeed =		FindConVar("z_charge_start_speed");

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_EnableCvars);
	g_hChargerBhop.AddChangeHook(CvarChanged);
	g_hCvarChargeProximity.AddChangeHook(CvarChanged);
	g_hCvarAimOffsetSensitivity.AddChangeHook(CvarChanged);
	g_hCvarHealthThreshold.AddChangeHook(CvarChanged);
	g_hChargeMaxSpeed.AddChangeHook(CvarChanged);
	g_hChargeStartSpeed.AddChangeHook(CvarChanged);

	HookEvent("charger_charge_start",	Event_ChargerChargeStart);
}

static void _OnModuleStart()
{
	if(g_bPluginEnd) return;
}

void Charger_OnModuleEnd() 
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
        Charger_OnModuleEnd();
    }
}

static void CvarChanged(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

static void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bChargerBhop = g_hChargerBhop.BoolValue;
	g_iCvarChargeProximity = g_hCvarChargeProximity.IntValue;
	g_fCvarAimOffsetSensitivity = g_hCvarAimOffsetSensitivity.FloatValue;
	g_iCvarHealthThreshold = g_hCvarHealthThreshold.IntValue;

	g_fChargeMaxSpeed =			g_hChargeMaxSpeed.FloatValue;
	g_fChargeStartSpeed =		g_hChargeStartSpeed.FloatValue;
}

void Charger_OnSpawn(int botCharger) {
	if(!g_bCvarEnable) return;

	g_bShouldCharge[botCharger] = false;
}

stock Action Charger_OnPlayerRunCmd(int charger, int &buttons) {
	if(!g_bCvarEnable) return Plugin_Continue;

	if (L4D_GetVictimCarry(charger) > 0) //抓人
		return Plugin_Continue;

	if (L4D_GetVictimCharger(charger) > 0) //垂人
		return Plugin_Continue;

	if (L4D2_GetQueuedPummelVictim(charger) > 0) //準備垂 (抓人之後開始垂人之前的動作)
		return Plugin_Continue;

	if (IsCharging(charger)) //正在衝鋒
		return Plugin_Continue;

	// prevent charge until survivors are within the defined proximity
	float chargerPos[3];
	GetClientAbsOrigin(charger, chargerPos);
	int target = GetClientAimTarget(charger);	
	int nearestSurDist = GetSurvivorProximity(chargerPos, target); // invalid(=-1) target will cause GetSurvivorProximity() to return distance to closest survivor
	if (nearestSurDist == -1) return Plugin_Continue;	
	
	if( GetEntProp(charger, Prop_Send, "m_iHealth") > g_iCvarHealthThreshold && nearestSurDist > g_iCvarChargeProximity ) {	
		if( !g_bShouldCharge[charger] ) { 				
			ResetAbilityTime(charger, 0.1);
		} 			
	} else {
		g_bShouldCharge[charger] = true;
	}
	
	if (g_bShouldCharge[charger] && CanCharge(charger)) {
		target = GetClientAimTarget(charger, false);
		if (IsAliveSur(target) && !IsIncapacitated(target) && GetEntPropEnt(target, Prop_Send, "m_carryAttacker") == -1) {
			static float vPos[3];
			static float vTar[3];
			GetClientAbsOrigin(charger, vPos);
			GetClientAbsOrigin(target, vTar);
			if (GetVectorDistance(vPos, vTar) < 100.0 && !entHitWall(charger, target)) {
				buttons |= IN_ATTACK;
				buttons |= IN_ATTACK2;
				return Plugin_Changed;
			}
		}
	}

	if (!g_bChargerBhop || GetEntityMoveType(charger) == MOVETYPE_LADDER || GetEntProp(charger, Prop_Data, "m_nWaterLevel") > 1 || !GetEntProp(charger, Prop_Send, "m_hasVisibleThreats"))
		return Plugin_Continue;

	static float val;
	static float vVel[3];
	GetEntPropVector(charger, Prop_Data, "m_vecVelocity", vVel);
	vVel[2] = 0.0;
	val = GetVectorLength(vVel);
	if (!CheckPlayerMove(charger, val))
		return Plugin_Continue;

	static float vAng[3];
	if (IsGrounded(charger)) {
		g_bModify[charger] = false;

		if (CurTargetDistance(charger) > 100.0 && -1.0 < nearestSurDist < 1500) {
			GetClientEyeAngles(charger, vAng);
			buttons |= IN_ATTACK2;
			return BunnyHop(charger, buttons, vAng);
		}
	}
	else {
		if (g_bModify[charger] || val < GetEntPropFloat(charger, Prop_Send, "m_flMaxspeed") + BOOST)
			return Plugin_Continue;

		target = GetClientAimTarget(charger, false);
		if (!IsAliveSur(target))
			target = GetCurTarget(charger);

		if (!IsAliveSur(target))
			return Plugin_Continue;

		static float vPos[3];
		static float vTar[3];
		static float vEye1[3];
		static float vEye2[3];
		GetClientAbsOrigin(charger, vPos);
		GetClientAbsOrigin(target, vTar);
		val = GetVectorDistance(vPos, vTar);
		if (val < 100.0 || val > 440.0)
			return Plugin_Continue;

		GetClientEyePosition(charger, vEye1);
		if (vEye1[2] < vTar[2])
			return Plugin_Continue;

		GetClientEyePosition(target, vEye2);
		if (vPos[2] > vEye2[2])
			return Plugin_Continue;

		vAng = vVel;
		vAng[2] = 0.0;
		NormalizeVector(vAng, vAng);

		static float vBuf[3];
		MakeVectorFromPoints(vPos, vTar, vBuf);
		vBuf[2] = 0.0;
		NormalizeVector(vBuf, vBuf);
		if (RadToDeg(ArcCosine(GetVectorDotProduct(vAng, vBuf))) < 90.0)
			return Plugin_Continue;

		if (vecHitWall(charger, vPos, vTar))
			return Plugin_Continue;

		MakeVectorFromPoints(vPos, vEye2, vVel);
		TeleportEntity(charger, NULL_VECTOR, NULL_VECTOR, vVel);
		g_bModify[charger] = true;
	}
	
	return Plugin_Continue;
}

static void Event_ChargerChargeStart(Event event, const char[] name, bool dontBroadcast) {
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!g_bCvarEnable || !client || !IsClientInGame(client) || !IsFakeClient(client))
		return;

	ChargerCharge(client);
}

void ability_use_OnCharge(int charger) {
	if(!g_bCvarEnable) return;

	// Assign charger a int survivor target if they are not specifically targetting anybody with their charge or their target is watching
	int aimTarget = GetClientAimTarget(charger);
	if( !IsSurvivor(aimTarget) || IsTargetWatchingAttacker(charger, g_fCvarAimOffsetSensitivity) ) {	
		float chargerPos[3];
		GetClientAbsOrigin(charger, chargerPos);
		int newTarget = GetClosestSurvivor(chargerPos, aimTarget);	// try and find another closeby survivor
		int distance = GetSurvivorProximity(chargerPos, newTarget);
		if( newTarget != -1 && distance != -1 && distance <= g_hCvarChargeProximity.IntValue ) {
			aimTarget = newTarget; // might be the same survivor if there were no other survivors within configured charge proximity
			
			#if DEBUG_CHARGER_TARGET	
				char targetName[32];
				GetClientName(newTarget, targetName, sizeof(targetName));
				PrintToChatAll("Charger forced to charge survivor %s", targetName);
			#endif
			ChargePrediction(charger, aimTarget);
		}
	}
}

// other------------------

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

static void ChargePrediction(int charger, int survivor) {
	if( !IsBotCharger(charger) || !IsSurvivor(survivor) ) {
		return;
	}
	float survivorPos[3];
	float chargerPos[3];
	float attackDirection[3];
	float attackAngle[3];
	// Add some fancy schmancy trignometric prediction here; as a placeholder charger will face survivor directly
	GetClientAbsOrigin(charger, chargerPos);
	GetClientAbsOrigin(survivor, survivorPos);
	MakeVectorFromPoints( chargerPos, survivorPos, attackDirection );
	GetVectorAngles(attackDirection, attackAngle);	
	TeleportEntity(charger, NULL_VECTOR, attackAngle, NULL_VECTOR); 
}

static bool CanCharge(int client) {
	if (GetEntPropEnt(client, Prop_Send, "m_pummelVictim") > 0 || GetEntPropEnt(client, Prop_Send, "m_carryVictim") > 0)
		return false;

	static int ent;
	ent = GetEntPropEnt(client, Prop_Send, "m_customAbility");
	return ent > MaxClients && !GetEntProp(ent, Prop_Send, "m_isCharging") && GetEntPropFloat(ent, Prop_Send, "m_timestamp") < GetGameTime();
}

static bool IsCharging(int client) {
	static int ent;
	ent = GetEntPropEnt(client, Prop_Send, "m_customAbility");
	return ent > MaxClients && GetEntProp(ent, Prop_Send, "m_isCharging");
}

void ChargerCharge(int client) {
	int target = GetClientAimTarget(client, false); //g_iCurTarget[client];
	if (!IsAliveSur(target) || IsIncapacitated(target) || L4D_GetPinnedInfected(target) > 0 || entHitWall(client, target) || WithinViewAngle2(client, target, g_fCvarAimOffsetSensitivity) )
		target = GetClosestSur(client, g_fChargeMaxSpeed, target);

	if (!IsAliveSur(target))
		return;

	float vVel[3];
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vVel);

	float vel = GetVectorLength(vVel);
	vel = vel < g_fChargeStartSpeed ? g_fChargeStartSpeed : vel;

	float vPos[3], vTar[3];
	GetClientAbsOrigin(client, vPos);
	GetClientAbsOrigin(target, vTar);
	float height = vTar[2] - vPos[2];
	if (height >= 44.0) {
		vTar[2] += 44.0;
		vel += FloatAbs(height);
		vTar[2] += GetVectorDistance(vPos, vTar) / vel * PLAYER_HEIGHT;
	}

	if (!IsGrounded(client))
		vel += g_fChargeMaxSpeed;

	MakeVectorFromPoints(vPos, vTar, vVel);

	float vAng[3];
	GetVectorAngles(vVel, vAng);
	NormalizeVector(vVel, vVel);
	ScaleVector(vVel, vel);

	int flags = GetEntityFlags(client);
	SetEntityFlags(client, (flags & ~FL_FROZEN) & ~FL_ONGROUND);
	TeleportEntity(client, NULL_VECTOR, vAng, vVel);
	SetEntityFlags(client, flags);
}

static int GetClosestSur(int client, float range, int exclude = -1) {
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
	float fov = GetFOVDotProduct(g_fCvarAimOffsetSensitivity);
	for (i = 0; i < num; i++) {
		if (!clients[i] || clients[i] == exclude)
			continue;

		if (GetClientTeam(clients[i]) != 2 || !IsPlayerAlive(clients[i]) || IsIncapacitated(clients[i]) || L4D_GetPinnedInfected(clients[i]) > 0 || entHitWall(client, clients[i]))
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
	i = al_targets.Get(index != -1 && al_targets.Get(index, 0) < 0.5 * range ? index : 0, 1);
	delete al_targets;
	return i;
}

// left4dhooks api------------------

#if FIXFLY
	// 避免charger仰角携带玩家冲出地图外 (from umlka AI_HardSI/ai_charger.sp)
	public void L4D2_OnStartCarryingVictim_Post(int victim, int attacker) {
		if (GetEntPropEnt(attacker, Prop_Send, "m_carryVictim") != -1) {
			DataPack dPack = new DataPack();
			dPack.WriteCell(GetClientUserId(victim));
			dPack.WriteCell(GetClientUserId(attacker));
			RequestFrame(NextFrame_SetVelocity, dPack);
		}
	}

	void NextFrame_SetVelocity(DataPack dPack) {
		dPack.Reset();
		int victim = dPack.ReadCell();
		int attacker = dPack.ReadCell();
		delete dPack;

		victim = GetClientOfUserId(victim);
		if (!victim || !IsClientInGame(victim))
			return;

		attacker = GetClientOfUserId(attacker);
		if (!attacker || !IsClientInGame(attacker))
			return;

		if (GetEntPropEnt(attacker, Prop_Send, "m_carryVictim") == -1)
			return;

		if (GetEntPropEnt(attacker, Prop_Send, "m_pummelVictim") != -1)
			return;

		float vVel[3];
		GetEntPropVector(attacker, Prop_Data, "m_vecVelocity", vVel);

		TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, vVel);
	}
#endif