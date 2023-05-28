#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>

#define GETVERSION "2.2"
#define ARRAY_SIZE 2048
#define ENTITY_SAFE_LIMIT 2000 //don't spawn entity when it's index is above this
#define EXLOPDE_INTERVAL 6.0

static const char FIRE_PARTICLE[] = 		"gas_explosion_ground_fire";
static const char EXPLOSION_PARTICLE[] = 	"weapon_pipebomb";
static const char EXPLOSION_PARTICLE2[] = 	"weapon_grenade_explosion";
static const char EXPLOSION_PARTICLE3[] = 	"explosion_huge_b";
static const char DAMAGE_WHITE_SMOKE[] = 	"minigun_overheat_smoke";
static const char DAMAGE_BLACK_SMOKE[] = 	"smoke_burning_engine_01";
static const char DAMAGE_FIRE_SMALL[] = 	"burning_engine_01";
static const char DAMAGE_FIRE_HUGE[] = 		"fire_window_hotel2";
static const char EXPLOSION_SOUND[] = 		"ambient/explosions/explode_1.wav";
static const char EXPLOSION_SOUND2[] = 		"ambient/explosions/explode_2.wav";
static const char EXPLOSION_SOUND3[] = 		"ambient/explosions/explode_3.wav";
static const char FIRE_SOUND[] = 			"ambient/fire/fire_med_loop1.wav";
static bool g_bConfigLoaded;

bool g_bLowWreck[ARRAY_SIZE+1];
bool g_bMidWreck[ARRAY_SIZE+1];
bool g_bHighWreck[ARRAY_SIZE+1];
bool g_bCritWreck[ARRAY_SIZE+1];
bool g_bExploded[ARRAY_SIZE+1];
bool g_bHooked[ARRAY_SIZE+1];
int g_iEntityDamage[ARRAY_SIZE+1];
int g_iParticle[ARRAY_SIZE+1] = {-1};
bool g_bDisabled = false;
int g_iPlayerSpawn, g_iRoundStart;
float g_GameExplodeTime;

ConVar g_cvarMaxHealth;
ConVar g_cvarRadius;
ConVar g_cvarPower;
ConVar g_cvarTrace;
ConVar g_cvarPanic;
ConVar g_cvarPanicChance;
ConVar g_cvarInfected;
ConVar g_cvarTankDamage;
ConVar g_cvarBurnTimeout;
ConVar g_cvarUnload;
ConVar g_cvarExplosionDmg;
ConVar g_cvarFireDmgInterval;
ConVar g_cvarDamage;

public Plugin myinfo = 
{
	name = "[L4D1/2] Explosive Cars",
	author = "honorcode23,Fixed: kochiurun119, HarryPotter",
	description = "Cars explode after they take some damage",
	version = GETVERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=138644"
}

bool g_bL4D2Version;
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

	return APLRes_Success; 
}

public void OnPluginStart()
{
	//Convars
	g_cvarMaxHealth = CreateConVar("l4d_explosive_cars_health", "5000", "Maximum health of the cars", FCVAR_NOTIFY);
	g_cvarRadius = CreateConVar("l4d_explosive_cars_radius", "420", "Maximum radius of the explosion", FCVAR_NOTIFY);
	g_cvarPower = CreateConVar("l4d_explosive_cars_power", "300", "(L4D2 only) Power of the explosion when the car explodes", FCVAR_NOTIFY);
	g_cvarDamage = CreateConVar("l4d_explosive_cars_damage", "10", "Damage made by the explosion", FCVAR_NOTIFY);
	g_cvarTrace = CreateConVar("l4d_explosive_cars_trace", "25", "Time before the fire trace left by the explosion expires", FCVAR_NOTIFY);
	g_cvarPanic = CreateConVar("l4d_explosive_cars_panic", "1", "Should the car explosion cause a panic event? (1: Yes 0: No)", FCVAR_NOTIFY);
	g_cvarPanicChance = CreateConVar("l4d_explosive_cars_panic_chance", "5", "Chance that the cars explosion might call a horde (1 / CVAR) [1: Always]", FCVAR_NOTIFY);
	g_cvarInfected = CreateConVar("l4d_explosive_cars_infected", "1", "Should infected trigger the car explosion? (1: Yes 0: No)", FCVAR_NOTIFY);
	g_cvarTankDamage = CreateConVar("l4d_explosive_cars_tank", "0", "How much damage do the tank deal to the cars? (0: Default, which is 999 from the engine)", FCVAR_NOTIFY);
	g_cvarBurnTimeout = CreateConVar("l4d_explosive_cars_removetime", "60", "Time to wait before removing the exploded car in case it blockes the way. (0: Don't remove)", FCVAR_NOTIFY);
	g_cvarUnload = CreateConVar("l4d_explosive_cars_unload", "c5m3_cemetery,c5m5_bridge", "On which maps should the plugin disable itself? separate by commas (no spaces). (Example: c5m3_cemetery,c5m5_bridge)", FCVAR_NOTIFY);
	g_cvarExplosionDmg = CreateConVar("l4d_explosive_cars_explosion_damage", "1", "Should cars get damaged by another car's explosion?", FCVAR_NOTIFY);
	g_cvarFireDmgInterval = CreateConVar("l4d_explosive_cars_trace_interval", "0.4", "How often should the fire trace left by the explosion hurt?", FCVAR_NOTIFY);
	CreateConVar("l4d_explosive_cars_version", GETVERSION, "Version of the l4d Explosive Cars plugin", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	AutoExecConfig(true, "l4d_explosive_cars");
	
	//Events
	HookEvent("player_spawn",		Event_PlayerSpawn,	EventHookMode_PostNoCopy);
	HookEvent("round_start",		Event_RoundStart,	EventHookMode_PostNoCopy);
	HookEvent("round_end",			Event_RoundEnd,		EventHookMode_PostNoCopy);
}

public void OnPluginEnd()
{
	ResetPlugin();
}

public void OnConfigsExecuted()
{
	g_bConfigLoaded = true;

	g_bDisabled = false;
	char sCurrentMap[64], sCvarMap[512];
	GetCurrentMap(sCurrentMap, sizeof(sCurrentMap));
	g_cvarUnload.GetString(sCvarMap, sizeof(sCvarMap));
	//LogMessage("sCvarMap: %s, sCurrentMap: %s", sCvarMap, sCurrentMap);
	if(StrContains(sCvarMap, sCurrentMap) >= 0)
	{
		g_bDisabled = true;
	}

	if(g_bDisabled == false)
	{
		if(g_bL4D2Version)
		{
			PrecacheParticle(EXPLOSION_PARTICLE2);
			PrecacheParticle(DAMAGE_FIRE_SMALL);
			PrecacheParticle(DAMAGE_FIRE_HUGE);
		}

		PrecacheParticle(FIRE_PARTICLE);
		PrecacheParticle(DAMAGE_BLACK_SMOKE);
		PrecacheParticle(EXPLOSION_PARTICLE);
		PrecacheParticle(EXPLOSION_PARTICLE3);
		PrecacheParticle(DAMAGE_WHITE_SMOKE);
		PrecacheModel("sprites/muzzleflash4.vmt");
		PrecacheModel("models/props_vehicles/cara_82hatchback_wrecked.mdl");
		PrecacheModel("models/props_vehicles/cara_95sedan_wrecked.mdl");

		PrecacheSound(FIRE_SOUND);
		PrecacheSound(EXPLOSION_SOUND);
		PrecacheSound(EXPLOSION_SOUND2);
		PrecacheSound(EXPLOSION_SOUND3);
	}
}

public void OnMapStart()
{
	// call before OnConfigsExecuted()
}

public void OnMapEnd()
{
	ResetPlugin();
	g_bConfigLoaded = false;
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetPlugin();
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_GameExplodeTime = 0.0;

	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(0.5, TimerStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(0.5, TimerStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;
}

public Action TimerStart(Handle timer)
{
	ResetPlugin();

	if(g_bDisabled) return Plugin_Continue;

	FindMapCars();

	return Plugin_Continue;
}

//Thanks to AtomicStryker
void FindMapCars()
{
	for(int i = 1; i <= ARRAY_SIZE; i++)
	{
		g_iEntityDamage[i] = 0;
		g_bLowWreck[i] = false;
		g_bMidWreck[i] = false;
		g_bHighWreck[i] = false;
		g_bCritWreck[i] = false;
		g_bHooked[i] = false;
		g_bExploded[i] = false;
		g_iParticle[i] = -1;
	}

	int maxEnts = GetMaxEntities();
	char classname[128], model[256];

	for (int entity = MaxClients +1; entity <= maxEnts; entity++)
	{
		if (!IsValidEdict(entity)||!IsValidEntity(entity)) continue;
		if (g_bHooked[entity]) continue;

		if (!HasEntProp(entity, Prop_Send, "m_hasTankGlow")) {
			continue;
		}

		if (GetEntProp(entity, Prop_Send, "m_hasTankGlow", 1) != 1) {
			continue;
		}

		GetEdictClassname(entity, classname, sizeof(classname));
		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));

		if(strncmp(classname, "prop_physics", 12) == 0)
		{
			if(StrContains(model, "vehicle", false) != -1)
			{
				g_bHooked[entity] = true;
				SDKHook(entity, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
			}
			else if (strcmp(model, "models/props/cs_assault/forklift.mdl", false) == 0)
			{
				g_bHooked[entity] = true;
				SDKHook(entity, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
			}

			float vpos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", vpos);
			//LogMessage("pos: %.2f %.2f %.2f", vpos[0], vpos[1], vpos[2]);
		}
		else if(strcmp(classname, "prop_car_alarm") == 0)
		{
			if(StrContains(model, "vehicle", false) != -1)
			{
				g_bHooked[entity] = true;
				SDKHook(entity, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
			}
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if(g_bDisabled) return;

	if(entity > 0 && entity <= ARRAY_SIZE)
	{
		g_bHooked[entity] = false;
		g_iEntityDamage[entity] = 0;
		g_bLowWreck[entity] = false;
		g_bMidWreck[entity] = false;
		g_bHighWreck[entity] = false;
		g_bCritWreck[entity] = false;
		g_bHooked[entity] = false;
		g_bExploded[entity] = false;
		g_iParticle[entity] = -1;
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(g_bDisabled) 
		return;

	if (!g_bConfigLoaded)
		return;

	if (!IsValidEntityIndex(entity))
		return;

	RequestFrame(OnNextFrame, EntIndexToEntRef(entity));
}

public void OnNextFrame(int entityRef)
{
	if(g_bDisabled) 
		return;

	int entity = EntRefToEntIndex(entityRef);

	if (entity == INVALID_ENT_REFERENCE)
		return;

	if (g_bHooked[entity])
		return;

	char classname[15];
	GetEntityClassname(entity, classname, sizeof(classname));
	char model[256];
	if(strncmp(classname, "prop_physics", 12) == 0)
	{
		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
		if(StrContains(model, "vehicle", false) != -1)
		{
			SDKHook(entity, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
			g_bHooked[entity] = true;
			g_iEntityDamage[entity] = 0;
			g_bLowWreck[entity] = false;
			g_bMidWreck[entity] = false;
			g_bHighWreck[entity] = false;
			g_bCritWreck[entity] = false;
			g_bHooked[entity] = false;
			g_bExploded[entity] = false;
			g_iParticle[entity] = -1;
		}
	}
	else if(strcmp(classname, "prop_car_alarm") == 0)
	{
		SDKHook(entity, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
		g_bHooked[entity] = true;
		g_iEntityDamage[entity] = 0;
		g_bLowWreck[entity] = false;
		g_bMidWreck[entity] = false;
		g_bHighWreck[entity] = false;
		g_bCritWreck[entity] = false;
		g_bHooked[entity] = false;
		g_bExploded[entity] = false;
		g_iParticle[entity] = -1;
	}
}

public void OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	if(g_bDisabled) return;

	if( inflictor > 0 && IsValidEntity(inflictor) && attacker > 0)
	{
		char attackerClass[256];
		GetEdictClassname(attacker, attackerClass, sizeof(attackerClass));

		char inflictorClass[256];
		GetEdictClassname(inflictor, inflictorClass, sizeof(inflictorClass));

		int MaxDamageHandle = g_cvarMaxHealth.IntValue / 5;

		//PrintToChatAll("%d - attackerClass: %s - inflictorClass: %s, %.1f damage", victim, attackerClass, inflictorClass, damage);
		if(strcmp(attackerClass, "player")  == 0)
		{
			if(g_bL4D2Version && (strcmp(inflictorClass, "weapon_chainsaw") == 0 || strcmp(inflictorClass, "weapon_melee") == 0))
			{
				damage = 5.0;
			}
			else if(strcmp(inflictorClass, "tank_rock") == 0|| strcmp(inflictorClass, "weapon_tank_claw") == 0)
			{
				float tank_damage = g_cvarTankDamage.FloatValue;
				if(tank_damage > 0.0)
				{
					damage = tank_damage;
				}
			}
			if(attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) && GetClientTeam(attacker) == 3 && g_cvarInfected.BoolValue == false)
			{
				damage = 0.0;
			}
		}
		if( strcmp(inflictorClass, "env_explosion") == 0 || strcmp(inflictorClass, "env_physexplosion") == 0) //explode dmg by another car
		{
			if(g_cvarExplosionDmg.BoolValue == false)
				damage = 0.0;
			else 
				damage = 3000.0;
		}
		else if (strcmp(inflictorClass, "pipe_bomb_projectile") == 0 || (g_bL4D2Version && strcmp(inflictorClass, "grenade_launcher_projectile") == 0) )
		{
			damage = 3000.0;
		}
		else if (strcmp(inflictorClass, "inferno")  == 0 || (g_bL4D2Version &&strcmp(inflictorClass, "fire_cracker_blast") == 0) )
		{
			damage = 100.0;
		}

		g_iEntityDamage[victim] += RoundToFloor(damage);
		int tdamage = g_iEntityDamage[victim];
		//PrintHintTextToAll("%i damaged by <%s>(%i) for %f damage [%i | %i]", victim, attackerClass, attacker, damage, tdamage, g_cvarMaxHealth.IntValue); //TEST

		if(tdamage >= MaxDamageHandle && tdamage < MaxDamageHandle * 2 && !g_bLowWreck[victim])
		{
			AttachParticle(victim, DAMAGE_WHITE_SMOKE);
			g_bLowWreck[victim] = true;
		}
		else if(tdamage >= MaxDamageHandle * 2 && tdamage < MaxDamageHandle * 3 && !g_bMidWreck[victim])
		{
			AttachParticle(victim, DAMAGE_BLACK_SMOKE);
			g_bMidWreck[victim] = true;
		}
		else if(tdamage >= MaxDamageHandle * 3 && tdamage < MaxDamageHandle * 4 && !g_bHighWreck[victim])
		{
			EmitSoundToAll(FIRE_SOUND, victim);
			if(g_bL4D2Version) AttachParticle(victim, DAMAGE_FIRE_SMALL);
			g_bHighWreck[victim] = true;
		}
		else if(tdamage >= MaxDamageHandle * 4 && tdamage < MaxDamageHandle * 5 && !g_bCritWreck[victim])
		{
			if(g_bL4D2Version) AttachParticle(victim, DAMAGE_FIRE_HUGE);
			g_bCritWreck[victim] = true;
		}
		else if(tdamage > MaxDamageHandle * 5 && !g_bExploded[victim])
		{
			if(!g_bCritWreck[victim])
			{
				EmitSoundToAll(FIRE_SOUND, victim);
				if(g_bL4D2Version) AttachParticle(victim, DAMAGE_FIRE_HUGE);
				g_bCritWreck[victim] = true;
			}

			CreateTimer(GetRandomInt(0, 100) * 0.0001, Timer_ExplodeCar, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

Action Timer_ExplodeCar(Handle timer, any entityRef)
{
	if(g_bDisabled) return Plugin_Continue;

	int car = EntRefToEntIndex(entityRef);

	if (car == INVALID_ENT_REFERENCE)
		return Plugin_Continue;

	if(g_GameExplodeTime < GetEngineTime())
	{
		g_bExploded[car] = true;
		float carPos[3];
		GetEntPropVector(car, Prop_Data, "m_vecOrigin", carPos);
		CreateExplosion(carPos);
		EditCar(car);
		LaunchCar(car);

		SDKUnhook(car, SDKHook_OnTakeDamagePost, OnTakeDamagePost);

		g_GameExplodeTime = GetEngineTime() + EXLOPDE_INTERVAL;
	}

	return Plugin_Continue;
}

stock void EditCar(int car)
{
	SetEntityRenderColor(car, 51, 51, 51, 255);
	char sModel[256];
	GetEntPropString(car, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	if(strcmp(sModel, "models/props_vehicles/cara_82hatchback.mdl") == 0)
	{
		SetEntityModel(car, "models/props_vehicles/cara_82hatchback_wrecked.mdl");
	}
	else if(strcmp(sModel, "models/props_vehicles/cara_95sedan.mdl") == 0)
	{
		SetEntityModel(car, "models/props_vehicles/cara_95sedan_wrecked.mdl");
	}
}

void LaunchCar(int car)
{
	float vel[3];
	GetEntPropVector(car, Prop_Data, "m_vecVelocity", vel);
	vel[0] += GetRandomFloat(50.0, 300.0);
	vel[1] += GetRandomFloat(50.0, 300.0);
	vel[2] += GetRandomFloat(1000.0, 2500.0);
	
	TeleportEntity(car, NULL_VECTOR, NULL_VECTOR, vel);
	CreateTimer(4.0, timerNormalVelocity, EntIndexToEntRef(car), TIMER_FLAG_NO_MAPCHANGE);
	float burnTime = g_cvarBurnTimeout.FloatValue;
	if(burnTime > 0.0)
	{
		CreateTimer(burnTime, timerRemoveCarFire, EntIndexToEntRef(car), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action timerNormalVelocity(Handle timer, any entityRef)
{
	if(g_bDisabled) return Plugin_Continue;

	int car = EntRefToEntIndex(entityRef);

	if (car == INVALID_ENT_REFERENCE)
		return Plugin_Continue;

	if(IsValidEntity(car))
	{
		float vel[3];
		SetEntPropVector(car, Prop_Data, "m_vecVelocity", vel);
		TeleportEntity(car, NULL_VECTOR, NULL_VECTOR, vel);
	}

	return Plugin_Continue;
}

public Action timerRemoveCarFire(Handle timer, int ref)
{
	if(g_bDisabled) return Plugin_Continue;

	int car;
	if(ref && (car = EntRefToEntIndex(ref)) != INVALID_ENT_REFERENCE)
	{
		int entity = g_iParticle[car];
		if( IsValidEntRef(entity) )
		{
			AcceptEntityInput(entity, "Kill");
			g_iParticle[car] = -1;
			AcceptEntityInput(car, "Kill");
		}
	}

	return Plugin_Continue;
}

void CreateExplosion(float carPos[3])
{
	char sRadius[16], sPower[16], sDamage[11], sInterval[11];
	float flMxDistance = g_cvarRadius.FloatValue;
	float power = g_cvarPower.FloatValue;
	int iDamage = g_cvarDamage.IntValue;
	float flInterval = g_cvarFireDmgInterval.FloatValue;
	FloatToString(flInterval, sInterval, sizeof(sInterval));
	IntToString(g_cvarRadius.IntValue, sRadius, sizeof(sRadius));
	IntToString(g_cvarPower.IntValue, sPower, sizeof(sPower));
	IntToString(iDamage, sDamage, sizeof(sDamage));
	int exParticle3 = CreateEntityByName("info_particle_system");
	int exTrace = CreateEntityByName("info_particle_system");
	int exPhys = CreateEntityByName("env_physexplosion");
	int exHurt = CreateEntityByName("point_hurt");
	int exParticle = CreateEntityByName("info_particle_system");
	int exEntity = CreateEntityByName("env_explosion");

	//Set up the particle explosion
	if( CheckIfEntityMax(exParticle) )
	{
		DispatchKeyValue(exParticle, "effect_name", EXPLOSION_PARTICLE);
		DispatchSpawn(exParticle);
		ActivateEntity(exParticle);
		TeleportEntity(exParticle, carPos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(exParticle, "Start");
		CreateTimer(g_cvarTrace.FloatValue + 1.5, timerDeleteParticles, EntIndexToEntRef(exParticle), TIMER_FLAG_NO_MAPCHANGE);
	}

	if(g_bL4D2Version)
	{
		int exParticle2 = CreateEntityByName("info_particle_system");
		if( CheckIfEntityMax(exParticle2) )
		{
			DispatchKeyValue(exParticle2, "effect_name", EXPLOSION_PARTICLE2);
			DispatchSpawn(exParticle2);
			ActivateEntity(exParticle2);
			TeleportEntity(exParticle2, carPos, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(exParticle2, "Start");
			CreateTimer(g_cvarTrace.FloatValue + 1.5, timerDeleteParticles, EntIndexToEntRef(exParticle2), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	if( CheckIfEntityMax(exParticle3) )
	{
		DispatchKeyValue(exParticle3, "effect_name", EXPLOSION_PARTICLE3);
		DispatchSpawn(exParticle3);
		ActivateEntity(exParticle3);
		TeleportEntity(exParticle3, carPos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(exParticle3, "Start");
		CreateTimer(g_cvarTrace.FloatValue + 1.5, timerDeleteParticles, EntIndexToEntRef(exParticle3), TIMER_FLAG_NO_MAPCHANGE);
	}

	if( CheckIfEntityMax(exTrace) )
	{
		DispatchKeyValue(exTrace, "effect_name", FIRE_PARTICLE);
		DispatchSpawn(exTrace);
		ActivateEntity(exTrace);
		TeleportEntity(exTrace, carPos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(exTrace, "Start");
		CreateTimer(g_cvarTrace.FloatValue, timerStop, EntIndexToEntRef(exTrace), TIMER_FLAG_NO_MAPCHANGE);
	}

	//Set up explosion entity
	if( CheckIfEntityMax(exEntity) )
	{
		DispatchKeyValue(exEntity, "fireballsprite", "sprites/muzzleflash4.vmt");
		DispatchKeyValue(exEntity, "iMagnitude", sDamage);
		DispatchKeyValue(exEntity, "iRadiusOverride", sRadius);
		DispatchKeyValue(exEntity, "spawnflags", "828");
		DispatchSpawn(exEntity);
		TeleportEntity(exEntity, carPos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(exEntity, "Explode");
		CreateTimer(g_cvarTrace.FloatValue + 1.5, timerDeleteParticles, EntIndexToEntRef(exEntity), TIMER_FLAG_NO_MAPCHANGE);
	}

	//Set up physics movement explosion
	if( CheckIfEntityMax(exPhys) )
	{
		DispatchKeyValue(exPhys, "radius", sRadius);
		DispatchKeyValue(exPhys, "magnitude", sPower);
		DispatchSpawn(exPhys);
		TeleportEntity(exPhys, carPos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(exPhys, "Explode");
		CreateTimer(g_cvarTrace.FloatValue + 1.5, timerDeleteParticles, EntIndexToEntRef(exPhys), TIMER_FLAG_NO_MAPCHANGE);
	}
	//Set up hurt point
	if( CheckIfEntityMax(exHurt) )
	{
		DispatchKeyValue(exHurt, "DamageRadius", sRadius);
		DispatchKeyValue(exHurt, "DamageDelay", sInterval);
		DispatchKeyValue(exHurt, "Damage", "1");
		DispatchKeyValue(exHurt, "DamageType", "8");
		DispatchSpawn(exHurt);
		TeleportEntity(exHurt, carPos, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(exHurt, "TurnOn");
		CreateTimer(g_cvarTrace.FloatValue, timerTurnOff, EntIndexToEntRef(exHurt), TIMER_FLAG_NO_MAPCHANGE);
	}

	switch(GetRandomInt(1, 3))
	{
		case 1:
		{
			EmitSoundToAll(EXPLOSION_SOUND);
		}
		case 2:
		{
			EmitSoundToAll(EXPLOSION_SOUND2);
		}
		case 3:
		{
			EmitSoundToAll(EXPLOSION_SOUND3);
		}
	}
	
	if(g_cvarPanic.BoolValue == true)
	{
		int luck = g_cvarPanicChance.IntValue;
		switch(GetRandomInt(1, luck))
		{
			case 1:
			{
				PanicEvent();
				PrintToChatAll("\x04[SM] \x03The car exploded and the infected heard the noise!");
			}
		}
	}
	
	float survivorPos[3], traceVec[3], resultingFling[3], currentVelVec[3];
	for(int player = 1; player <= MaxClients; player++)
	{
		if(!IsClientInGame(player) || !IsPlayerAlive(player) || GetClientTeam(player) != 2)
		{
			continue;
		}

		GetEntPropVector(player, Prop_Data, "m_vecOrigin", survivorPos);

		//Vector and radius distance calcs by AtomicStryker!
		if(GetVectorDistance(carPos, survivorPos) <= flMxDistance)
		{
			if(g_bL4D2Version)
			{
				MakeVectorFromPoints(carPos, survivorPos, traceVec);				// draw a line from car to Survivor
				GetVectorAngles(traceVec, resultingFling);							// get the angles of that line

				resultingFling[0] = Cosine(DegToRad(resultingFling[1])) * power;	// use trigonometric magic
				resultingFling[1] = Sine(DegToRad(resultingFling[1])) * power;
				resultingFling[2] = power;

				GetEntPropVector(player, Prop_Data, "m_vecVelocity", currentVelVec);		// add whatever the Survivor had before
				resultingFling[0] += currentVelVec[0];
				resultingFling[1] += currentVelVec[1];
				resultingFling[2] += currentVelVec[2];

				FlingPlayer(player, resultingFling, player);
			}
			else
			{
				/*MakeVectorFromPoints(carPos, survivorPos, survivorPos);
				NormalizeVector(survivorPos, survivorPos);
				ScaleVector(survivorPos, power);
				survivorPos[2] = power;
				TeleportEntity(player, NULL_VECTOR, NULL_VECTOR, survivorPos);*/
				L4D_StaggerPlayer(player, player, carPos);
			}
		}
	}
}

public Action timerStop(Handle timer, int ref)
{
	if(IsValidEntRef(ref))
	{
		AcceptEntityInput(ref, "Stop");
		AcceptEntityInput(ref, "kill");
	}

	return Plugin_Continue;
}

public Action timerTurnOff(Handle timer, int ref)
{
	if(IsValidEntRef(ref))
	{
		AcceptEntityInput(ref, "TurnOff");
		AcceptEntityInput(ref, "kill");
	}

	return Plugin_Continue;
}

public Action timerDeleteParticles(Handle timer, int ref)
{
	if(IsValidEntRef(ref))
	{
		AcceptEntityInput(ref, "kill");
	}

	return Plugin_Continue;
}

void FlingPlayer(int target, float vector[3], int attacker)
{
	L4D2_CTerrorPlayer_Fling(target, attacker, vector);
}

int PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}

	int index = FindStringIndex(table, sEffectName);
	if( index == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
		index = FindStringIndex(table, sEffectName);
	}

	return index;
}

void AttachParticle(int car, const char[] Particle_Name)
{
	float carPos[3];
	char sName[64], sTargetName[64];
	int Particle = CreateEntityByName("info_particle_system");
	int entity = g_iParticle[car];
	if( IsValidEntRef(entity) )
	{
		AcceptEntityInput(entity, "Kill");
		g_iParticle[car] = -1;
	}
	if( CheckIfEntityMax(Particle) )
	{
		g_iParticle[car] = EntIndexToEntRef(Particle);
		GetEntPropVector(car, Prop_Data, "m_vecOrigin", carPos);
		TeleportEntity(Particle, carPos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(Particle, "effect_name", Particle_Name);

		int userid = car;
		Format(sName, sizeof(sName), "%d", userid+25);
		DispatchKeyValue(car, "targetname", sName);
		GetEntPropString(car, Prop_Data, "m_iName", sName, sizeof(sName));

		Format(sTargetName, sizeof(sTargetName), "%d", userid+1000);
		DispatchKeyValue(Particle, "targetname", sTargetName);
		DispatchKeyValue(Particle, "parentname", sName);
		DispatchSpawn(Particle);
		DispatchSpawn(Particle);
		SetVariantString(sName);
		AcceptEntityInput(Particle, "SetParent", Particle, Particle);
		ActivateEntity(Particle);
		AcceptEntityInput(Particle, "start");
	}
}

void PanicEvent()
{
	int anyclient = GetAnyRandomClient();
	if(anyclient == 0) return;

	CheatCommand(anyclient, "z_spawn", "mob", "auto");
}

bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}

bool CheckIfEntityMax(int entity)
{
	if(entity == -1) return false;

	if(	entity > ENTITY_SAFE_LIMIT)
	{
		AcceptEntityInput(entity, "Kill");
		return false;
	}
	return true;
}

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}

void ResetPlugin()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

void CheatCommand(int client, char[] command, char[] arguments = "", char[] extra = "")
{
	int userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s", command, arguments, extra);
	SetCommandFlags(command, flags);
	if(IsClientInGame(client)) SetUserFlagBits(client, userFlags);
}
