#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "1.4"
#define MODEL_CAR1			"models/props_vehicles/taxi_cab.mdl"
#define MODEL_CAR2			"models/props_vehicles/police_car.mdl"
#define MODEL_GLASS			"models/props_vehicles/police_car_glass.mdl"
#define MODEL_PROPANE 	"models/props_junk/propanecanister001a.mdl"

Handle l4d_flying_car_color;
Handle l4d_flying_car_enable;
Handle l4d_flying_car_explode;
Handle l4d_flying_car_ignite;
Handle l4d_flying_car_model;
Handle l4d_flying_car_random_color;
Handle l4d_flying_car_random_model;
int g_iCar = INVALID_ENT_REFERENCE;
int g_iExplosion = INVALID_ENT_REFERENCE;
int g_iFlame = INVALID_ENT_REFERENCE;
int g_iProbability;

public Plugin myinfo =
{
	name = "L4D2 C8 No Mercy Flying Car",
	author = "Axel Juan Nieves, HarryPotter",
	description = "Replaces getaway chopper by flying car.",
	version = PLUGIN_VERSION,
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

public void OnPluginStart()
{
	CreateConVar("l4d_flying_car_version", PLUGIN_VERSION, "", 0|FCVAR_DONTRECORD);
	l4d_flying_car_color = CreateConVar("l4d_flying_car_color", "", "Custom color (rgb), leave black to use default color", 0);
	l4d_flying_car_enable = CreateConVar("l4d_flying_car_enable", "1", "Enable/Disable this plugin. 0:disable, 1:enable", 0, true, 0.0, true, 1.0);
	l4d_flying_car_explode = CreateConVar("l4d_flying_car_explode", "1", "Explode car? 0:disable, 1:enable", 0, true, 0.0, true, 1.0);
	l4d_flying_car_ignite = CreateConVar("l4d_flying_car_ignite", "1", "Ignite car on leaving? 0:disable, 1:enable", 0, true, 0.0, true, 1.0);
	l4d_flying_car_model = CreateConVar("l4d_flying_car_model", "1", "Car model (1:taxi, 2:police car)", 0, true, 1.0, true, 2.0);
	l4d_flying_car_random_color = CreateConVar("l4d_flying_car_random_color", "1", "Choose color randomly instead using custom one? 0:disable, 1:enable", 0, true, 0.0, true, 1.0);
	l4d_flying_car_random_model = CreateConVar("l4d_flying_car_random_model", "1", "Choose model randomly instead using custom one? 0:disable, 1:enable", 0, true, 0.0, true, 1.0);
	
	AutoExecConfig(true, "l4d_flying_car");

	HookEvent("finale_escape_start", event_finale_escape_start, EventHookMode_PostNoCopy);
	HookEvent("finale_vehicle_leaving", event_finale_vehicle_leaving, EventHookMode_PostNoCopy);
	HookEvent("finale_vehicle_ready", event_finale_vehicle_ready, EventHookMode_PostNoCopy);
}

bool g_bValidMap;
public void OnMapStart()
{	
	g_bValidMap = false;

	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	if( strcmp(sMap, "c8m5_rooftop") == 0 )
		g_bValidMap = true;
	
	if(g_bValidMap)
	{
		PrecacheModel(MODEL_CAR1);
		PrecacheModel(MODEL_CAR2);
		PrecacheModel(MODEL_GLASS);
		PrecacheModel(MODEL_PROPANE);

		PrecacheParticle("env_fire_medium");
	}
}

public void event_finale_escape_start(Handle event, const char[] name, bool dontBroadcast)
{
	if ( !GetConVarBool(l4d_flying_car_enable) || !g_bValidMap)
	{
		return;
	}
	
	char modelname[256];
	char rgb[16];
	
	//creating a car without glasses:
	int car = CreateEntityByName("prop_dynamic");
	if ( car <= MaxClients || !IsValidEntity(car) )
		return;
	
	g_iCar = EntIndexToEntRef(car);
	
	if ( GetConVarBool(l4d_flying_car_random_model) )
	{
		switch(GetRandomInt(1, 2))
		{
			case 1: SetEntityModel(car, MODEL_CAR1);
			case 2: SetEntityModel(car, MODEL_CAR2);
		}
	}
	else
	{
		switch( GetConVarInt(l4d_flying_car_model) )
		{
			case 1: SetEntityModel(car, MODEL_CAR1);
			case 2: SetEntityModel(car, MODEL_CAR2);
		}
	}
	
	//creating glasses:
	int glass = CreateEntityByName("prop_dynamic");
	if ( glass <= MaxClients || !IsValidEntity(glass) )
		return;

	SetEntityModel(glass, MODEL_GLASS);
	
	//bugfix: glasses fading...
	DispatchKeyValue(glass, "fadescale", "0");
	DispatchKeyValue(glass, "fademindist", "9999999");
	DispatchKeyValue(glass, "fademaxdist", "-1");
	
	//get custom rgb color...
	GetConVarString(l4d_flying_car_color, rgb, sizeof(rgb));
	TrimString(rgb);
	
	//scan all entities...
	int EntityCount = GetEntityCount();
	for (int entity = 1; entity <= EntityCount; entity++)
	{
		if (!IsValidEntity(entity))
			continue;
		
		GetEntPropString(entity, Prop_Data, "m_ModelName", modelname, sizeof(modelname));
		
		if ( StrContains(modelname, ".mdl", false)<0 )
			continue;
		
		if ( StrContains(modelname, "pilot", false)>=0 ) 
		{
			SetEntityRenderMode(entity, RENDER_NONE); //make pilot invisible
			
			//attach car and window glasses to pilot...
			SetVariantString("!activator");
			AcceptEntityInput(car, "SetParent", entity);
			SetVariantString("!activator");
			AcceptEntityInput(glass, "SetParent", entity);
			
			//bugfix: car fading...
			DispatchKeyValue(car, "fadescale", "0");
			DispatchKeyValue(car, "fademindist", "9999999");
			DispatchKeyValue(car, "fademaxdist", "-1");
			
			//check random color...
			if ( GetConVarBool(l4d_flying_car_random_color) )
			{
				switch(GetRandomInt(2, 8))
				{
					case 1: SetEntityRenderColor(car, 0, 0, 0, 255); //black
					case 2: SetEntityRenderColor(car, 255, 255, 255, 255); //white
					case 3: SetEntityRenderColor(car, 255, 0, 0, 255); //red
					case 4: SetEntityRenderColor(car, 0, 255, 0, 255); //green
					case 5: SetEntityRenderColor(car, 0, 0, 255, 255); //blue
					case 6: SetEntityRenderColor(car, 255, 0, 255, 255); //purple
					case 7: SetEntityRenderColor(car, 255, 255, 0, 255); //yellow
					case 8: SetEntityRenderColor(car, 0, 255, 255, 200); //lightblue
				}
			}
			//check custom color...
			else if ( strlen(rgb)>=5 )
			{
				DispatchKeyValue(car, "rendercolor", rgb);
			}
		}
		//remove helicopter's headlights...
		else if ( StrContains(modelname, "searchlight_small_01", false)>=0 ) 
		{
			RemoveEntity(entity);
		}
		//make helicopter invisible...
		else if ( StrContains(modelname, "heli", false)>=0 ) 
		{
			SetEntityRenderMode(entity, RENDER_NONE);
		}
	}
	//correct position and angles:
	TeleportEntity(car, view_as<float>({-110.0, 0.0, -75.0}), view_as<float>({0.0, 270.0, 0.0}), NULL_VECTOR);
	TeleportEntity(glass, view_as<float>({-110.0, 0.0, -75.0}), view_as<float>({0.0, 270.0, 0.0}), NULL_VECTOR);
	
	//Preparing explosions...
	if ( GetConVarBool(l4d_flying_car_explode) )
	{
		g_iProbability = 5;
		CreateTimer(0.5, RandomExplosions, _, TIMER_REPEAT);
	}
	
	//Ignite car before it arrives...
	if ( GetConVarBool(l4d_flying_car_ignite) )
	{
		int particle = CreateEntityByName("info_particle_system");
		if ( particle <= MaxClients || !IsValidEdict(particle) ) return;

		g_iFlame = EntIndexToEntRef(particle); //make it global
		DispatchKeyValue(particle, "effect_name", "env_fire_medium");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		SetVariantString("!activator");
		AcceptEntityInput(particle, "SetParent", car);
		TeleportEntity(particle, view_as<float>({50.0, 0.0, 15.0}), view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR);
	}
}

public void event_finale_vehicle_ready(Handle event, const char[] name, bool dontBroadcast)
{
	if ( !GetConVarBool(l4d_flying_car_enable) || !g_bValidMap)
	{
		return;
	}
	
	//reduce explosions at this point...
	g_iProbability = 20;
	
	//extinguish car at this point...
	if ( GetConVarBool(l4d_flying_car_ignite) )
	{
		int particle = EntRefToEntIndex(g_iFlame);
		if ( !IsValidEdict(particle) )
			return;
		
		AcceptEntityInput(particle, "stop");
	}
}

public void event_finale_vehicle_leaving(Handle event, const char[] name, bool dontBroadcast)
{
	if ( !GetConVarBool(l4d_flying_car_enable) || !g_bValidMap)
	{
		return;
	}
	
	int car = EntRefToEntIndex(g_iCar);
	if ( !IsValidEntity(car) )
	{
		return;
	}
	
	PrintToChatAll("\x04Harry Potter: \x03It's time to Hogwarts School !!\n(前往出發霍格華茲學院!!)");
	
	//re-ignite car...
	int particle = EntRefToEntIndex(g_iFlame);
	if ( IsValidEdict(particle) )
		AcceptEntityInput(particle, "start");
	
	//explode car more frequentrly...
	if ( GetConVarBool(l4d_flying_car_explode) )
	{
		g_iProbability = 3;
	}
}

Action RandomExplosions(Handle timer)
{
	if ( !GetConVarBool(l4d_flying_car_enable) )
		return Plugin_Stop;
	
	if ( !GetConVarBool(l4d_flying_car_explode) )
		return Plugin_Stop;
	
	int car = EntRefToEntIndex(g_iCar);
	if ( !IsValidEntity(car) )
	{
		//LogError("Invalid car entity. Timer stopped!");
		return Plugin_Stop;
	}
	
	//------------------------------------------------------
	//If everything above went ok............................
	
	//check if already exploded...
	int explosion = EntRefToEntIndex(g_iExplosion);
	if ( !IsValidEntity(explosion) )
	{
		//create a new explosion...
		explosion = CreateEntityByName("prop_physics");
		if ( explosion <= MaxClients || !IsValidEntity(explosion) )
		{
			return Plugin_Continue;
		}
		
		g_iExplosion = EntIndexToEntRef(explosion); //make it global
		DispatchKeyValue(explosion, "physdamagescale", "0.0");
		DispatchKeyValue(explosion, "model", MODEL_PROPANE);
		DispatchSpawn(explosion); //spawn a propane tank
		SetEntityRenderMode(explosion, RENDER_NONE); //make propane tank invisible
		SetVariantString("!activator");
		AcceptEntityInput(explosion, "SetParent", car);
		TeleportEntity(explosion, view_as<float>({0.0, 0.0, 0.0}), view_as<float>({0.0, 0.0, 0.0}), NULL_VECTOR);
		SetEntityMoveType(explosion, MOVETYPE_VPHYSICS);
	}
	
	//check probabilities....
	if ( GetRandomInt(1, g_iProbability)==1 )
	{
		AcceptEntityInput(explosion, "Break"); //detonate propane tank
		AcceptEntityInput(explosion, "ClearParent"); //remove references before killing entity
		RemoveEntity(explosion);//remove it from world
		g_iExplosion = INVALID_ENT_REFERENCE;
	}
	return Plugin_Continue;
}

void PrecacheParticle(const char[] sEffectName)
{
	static int table = INVALID_STRING_TABLE;
	if( table == INVALID_STRING_TABLE )
	{
		table = FindStringTable("ParticleEffectNames");
	}

	if( FindStringIndex(table, sEffectName) == INVALID_STRING_INDEX )
	{
		bool save = LockStringTables(false);
		AddToStringTable(table, sEffectName);
		LockStringTables(save);
	}
}