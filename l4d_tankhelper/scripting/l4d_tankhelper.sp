//Pan Xiaohai & Dragokas & HarryPotter @ 2010-2022

#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <left4dhooks>
#include <actions> // https://forums.alliedmods.net/showthread.php?t=336374

public Plugin myinfo = 
{
	name = "Tanks throw special infected",
	author = "Pan Xiaohai & HarryPotter",
	description = "Tanks throw special infected instead of rock",
	version = "2.0h-2023/9/5",
	url = "https://forums.alliedmods.net/showthread.php?t=140254"
}

static int ZC_TANK;
static char sSpawnCommand[32];
int L4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		L4D2Version = false;
		ZC_TANK = 5;
		sSpawnCommand = "z_spawn";
	}
	else if( test == Engine_Left4Dead2 )
	{
		L4D2Version = true;
		ZC_TANK = 8;
		sSpawnCommand = "z_spawn_old";
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	return APLRes_Success; 
}

#define PARTICLE_ELECTRICAL	"electrical_arc_01_system"

#define MODEL_SMOKER "models/infected/smoker.mdl"
#define MODEL_BOOMER "models/infected/boomer.mdl"
#define MODEL_HUNTER "models/infected/hunter.mdl"
#define MODEL_SPITTER "models/infected/spitter.mdl"
#define MODEL_JOCKEY "models/infected/jockey.mdl"
#define MODEL_CHARGER "models/infected/charger.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
static Handle hCreateSmoker = null;
#define NAME_CreateSmoker "NextBotCreatePlayerBot<Smoker>"
static Handle hCreateBoomer = null;
#define NAME_CreateBoomer "NextBotCreatePlayerBot<Boomer>"
static Handle hCreateHunter = null;
#define NAME_CreateHunter "NextBotCreatePlayerBot<Hunter>"
static Handle hCreateSpitter = null;
#define NAME_CreateSpitter "NextBotCreatePlayerBot<Spitter>"
static Handle hCreateJockey = null;
#define NAME_CreateJockey "NextBotCreatePlayerBot<Jockey>"
static Handle hCreateCharger = null;
#define NAME_CreateCharger "NextBotCreatePlayerBot<Charger>"
static Handle hCreateTank = null;
#define NAME_CreateTank "NextBotCreatePlayerBot<Tank>"

#define SOUND_THROWN_MISSILE 		"player/tank/attack/thrown_missile_loop_1.wav"

#define MAXENTITIES                   2048

#define ZC_SMOKER	1
#define ZC_BOOMER	2
#define ZC_HUNTER	3
#define ZC_SPITTER	4
#define ZC_JOCKEY	5
#define ZC_CHARGER	6
#define ZC_WITCH 	7

ConVar l4d_tank_throw_si_ai, l4d_tank_throw_si_real, l4d_tank_throw_hunter, l4d_tank_throw_smoker, l4d_tank_throw_boomer,
	l4d_tank_throw_charger, l4d_tank_throw_spitter, l4d_tank_throw_jockey, l4d_tank_throw_tank, l4d_tank_throw_self,
	l4d_tank_throw_tank_health, l4d_tank_throw_witch, l4d_tank_throw_witch_health,
	g_hWitchKillTime,
	l4d_tank_throw_hunter_limit, l4d_tank_throw_smoker_limit, l4d_tank_throw_boomer_limit,l4d_tank_throw_charger_limit, l4d_tank_throw_spitter_limit,
	l4d_tank_throw_jockey_limit,l4d_tank_throw_tank_limit,l4d_tank_throw_witch_limit;

ConVar z_tank_throw_force;

bool g_bIsTraceRock[MAXENTITIES +1];
int throw_tank_health, throw_witch_health, iThrowSILimit[9];
bool g_bSpawnWitchBride;
float fl4d_tank_throw_si_ai, fl4d_tank_throw_si_real, fThrowSIChance[9], z_tank_throw_force_speed, g_fWitchKillTime;
Handle g_hNextBotPointer, g_hGetLocomotion, g_hJump;

static float g_99999Position[3] = {9999999.0, 9999999.0, 9999999.0};

forward void L4D_OnTraceRockCreated(int entity); //from l4d_tracerock

public void OnPluginStart()
{
	GetGameData();

	z_tank_throw_force = FindConVar("z_tank_throw_force");
	l4d_tank_throw_si_ai = CreateConVar("l4d_tank_throw_si_ai", "100.0", 		"AI Tank throws helper special infected chance [0.0, 100.0]", FCVAR_NOTIFY, true, 0.0,true, 100.0); 
	l4d_tank_throw_si_real = CreateConVar("l4d_tank_throw_si_player", "70.0", 	"Real Tank Player throws helper special infected chance [0.0, 100.0]", FCVAR_NOTIFY, true, 0.0,true, 100.0); 
	l4d_tank_throw_hunter 	= CreateConVar("l4d_tank_throw_hunter", "5.0", 		"Weight of helper Hunter[0.0, 10.0]", FCVAR_NOTIFY, true, 0.0,true, 10.0); 
	l4d_tank_throw_smoker 	= CreateConVar("l4d_tank_throw_smoker", "5.0", 		"Weight of helper Smoker[0.0, 10.0]", FCVAR_NOTIFY, true, 0.0,true, 10.0); 
	l4d_tank_throw_boomer 	= CreateConVar("l4d_tank_throw_boomer", "5.0", 		"Weight of helper Boomer[0.0, 10.0]", FCVAR_NOTIFY, true, 0.0,true, 10.0); 
	if(L4D2Version)
	{
		l4d_tank_throw_charger 	= CreateConVar("l4d_tank_throw_charger", "5.0", 	"Weight of helper Charger [0.0, 10.0]", FCVAR_NOTIFY, true, 0.0,true, 10.0); 
		l4d_tank_throw_spitter	= CreateConVar("l4d_tank_throw_spitter", "5.0", 	"Weight of helper Spitter [0.0, 10.0]", FCVAR_NOTIFY, true, 0.0,true, 10.0); 
		l4d_tank_throw_jockey	= CreateConVar("l4d_tank_throw_jockey", "5.0",  	"Weight of helper Jockey [0.0, 10.0]", FCVAR_NOTIFY, true, 0.0,true, 10.0); 
	}
	l4d_tank_throw_tank	=	  CreateConVar("l4d_tank_throw_tank", "2.0",  		"Weight of helper Tank[0.0, 10.0]", FCVAR_NOTIFY, true, 0.0,true, 10.0); 
	l4d_tank_throw_self	= 	  CreateConVar("l4d_tank_throw_self", "10.0",  		"Weight of throwing Tank self[0.0, 10.0]", FCVAR_NOTIFY, true, 0.0,true, 10.0); 
	l4d_tank_throw_tank_health=CreateConVar("l4d_tank_throw_tank_health", "750",  "Helper Tank bot health", FCVAR_NOTIFY, true, 1.0); 		
	l4d_tank_throw_witch	= CreateConVar("l4d_tank_throw_witch", "2.0",  			"Weight of helper Witch[0.0, 10.0]", FCVAR_NOTIFY, true, 0.0,true, 10.0); 
	l4d_tank_throw_witch_health=CreateConVar("l4d_tank_throw_witch_health", "250",  "Helper Witch health", FCVAR_NOTIFY, true, 1.0); 	
	g_hWitchKillTime = CreateConVar("l4d_tank_throw_witch_lifespan", "30", 			"Amount of seconds before a helper witch is kicked. (only remove witches spawned by this plugin)", FCVAR_NOTIFY, true, 1.0);
	l4d_tank_throw_hunter_limit 	= CreateConVar("l4d_tank_throw_hunter_limit", "2", 	"Hunter Limit on the field[1 ~ 5] (if limit reached, throw Hunter teammate, if all hunters busy, throw Tank self)", FCVAR_NOTIFY, true, 1.0, true, 5.0); 
	l4d_tank_throw_smoker_limit 	= CreateConVar("l4d_tank_throw_smoker_limit", "2", 	"Smoker Limit on the field[1 ~ 5] (if limit reached, throw Smoker teammate, if all smokers busy, throw Tank self)", FCVAR_NOTIFY, true, 1.0, true, 5.0); 
	l4d_tank_throw_boomer_limit 	= CreateConVar("l4d_tank_throw_boomer_limit", "2", 	"Boomer Limit on the field[1 ~ 5] (if limit reached, throw Boomer teammate)", FCVAR_NOTIFY, true, 1.0, true, 5.0); 
	if(L4D2Version)
	{
		l4d_tank_throw_charger_limit 	= CreateConVar("l4d_tank_throw_charger_limit", "2", "Charger Limit on the field[1 ~ 5] (if limit reached, throw Charger teammate, if all chargers busy, throw Tank self)", FCVAR_NOTIFY, true, 1.0, true, 5.0); 
		l4d_tank_throw_spitter_limit	= CreateConVar("l4d_tank_throw_spitter_limit", "1", "Spitter Limit on the field[1 ~ 5] (if limit reached, throw Spitter teammate)", FCVAR_NOTIFY, true, 1.0, true, 5.0); 
		l4d_tank_throw_jockey_limit		= CreateConVar("l4d_tank_throw_jockey_limit", "2",  "Jockey Limit on the field[1 ~ 5] (if limit reached, throw Jockey teammate, if all jockeys busy, throw Tank self)", FCVAR_NOTIFY, true, 1.0, true, 5.0); 
	}
	l4d_tank_throw_tank_limit		= CreateConVar("l4d_tank_throw_tank_limit", "3",  	"Tank Limit on the field[1 ~ 10] (if limit reached, throw Tank teammate or yourself)", FCVAR_NOTIFY, true, 1.0, true, 10.0); 	
	l4d_tank_throw_witch_limit		= CreateConVar("l4d_tank_throw_witch_limit", "3",  	"Witch Limit on the field[1 ~ 10] (if limit reached, throw Tank self)", FCVAR_NOTIFY, true, 1.0, true, 10.0); 
	
	AutoExecConfig(true, "l4d_tankhelper");
 
	GetConVar();
	z_tank_throw_force.AddChangeHook(ConVarChange);
	l4d_tank_throw_si_ai.AddChangeHook(ConVarChange);
	l4d_tank_throw_si_real.AddChangeHook(ConVarChange);
	l4d_tank_throw_hunter.AddChangeHook(ConVarChange);
	l4d_tank_throw_smoker.AddChangeHook(ConVarChange);
	l4d_tank_throw_boomer.AddChangeHook(ConVarChange);
	if(L4D2Version)
	{
		l4d_tank_throw_charger.AddChangeHook(ConVarChange);
		l4d_tank_throw_spitter.AddChangeHook(ConVarChange);
		l4d_tank_throw_jockey.AddChangeHook(ConVarChange);
	}
	l4d_tank_throw_tank.AddChangeHook(ConVarChange);
	l4d_tank_throw_self.AddChangeHook(ConVarChange);
	l4d_tank_throw_tank_health.AddChangeHook(ConVarChange);
	l4d_tank_throw_witch.AddChangeHook(ConVarChange);
	l4d_tank_throw_witch_health.AddChangeHook(ConVarChange);
	g_hWitchKillTime.AddChangeHook(ConVarChange);
	l4d_tank_throw_hunter_limit.AddChangeHook(ConVarChange);
	l4d_tank_throw_smoker_limit.AddChangeHook(ConVarChange);
	l4d_tank_throw_boomer_limit.AddChangeHook(ConVarChange);
	if(L4D2Version)
	{
		l4d_tank_throw_charger_limit.AddChangeHook(ConVarChange);
		l4d_tank_throw_spitter_limit.AddChangeHook(ConVarChange);
		l4d_tank_throw_jockey_limit.AddChangeHook(ConVarChange);
	}
	l4d_tank_throw_tank_limit.AddChangeHook(ConVarChange);
	l4d_tank_throw_witch_limit.AddChangeHook(ConVarChange);

	AddNormalSoundHook(OnNormalSoundPlay);
}

public void OnMapStart()
{ 
	PrecacheModel(MODEL_SMOKER, true);
	PrecacheModel(MODEL_BOOMER, true);
	PrecacheModel(MODEL_HUNTER, true);
	PrecacheModel(MODEL_SPITTER, true);
	PrecacheModel(MODEL_JOCKEY, true);
	PrecacheModel(MODEL_CHARGER, true);
	PrecacheModel(MODEL_TANK, true);
	if(L4D2Version)
	{ 
		PrecacheParticle(PARTICLE_ELECTRICAL);
	}

	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	if(StrEqual("c6m1_riverbank", sMap, false))
		g_bSpawnWitchBride = true;
}

public void ConVarChange(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetConVar();

}
void GetConVar()
{
	fl4d_tank_throw_si_ai = l4d_tank_throw_si_ai.FloatValue;
	fl4d_tank_throw_si_real = l4d_tank_throw_si_real.FloatValue;
	fThrowSIChance[0]=l4d_tank_throw_hunter.FloatValue;
	fThrowSIChance[1]=fThrowSIChance[0]+l4d_tank_throw_smoker.FloatValue;
	fThrowSIChance[2]=fThrowSIChance[1]+l4d_tank_throw_boomer.FloatValue;
	fThrowSIChance[3]=fThrowSIChance[2]+l4d_tank_throw_tank.FloatValue;	
	fThrowSIChance[4]=fThrowSIChance[3]+l4d_tank_throw_witch.FloatValue;
	fThrowSIChance[5]=fThrowSIChance[4]+l4d_tank_throw_self.FloatValue;
	if(L4D2Version)
	{
		fThrowSIChance[6]=fThrowSIChance[5]+l4d_tank_throw_charger.FloatValue;
		fThrowSIChance[7]=fThrowSIChance[6]+l4d_tank_throw_spitter.FloatValue;
		fThrowSIChance[8]=fThrowSIChance[7]+l4d_tank_throw_jockey.FloatValue;
	}
	iThrowSILimit[0]=l4d_tank_throw_hunter_limit.IntValue;
	iThrowSILimit[1]=l4d_tank_throw_smoker_limit.IntValue;
	iThrowSILimit[2]=l4d_tank_throw_boomer_limit.IntValue;
	iThrowSILimit[3]=l4d_tank_throw_tank_limit.IntValue;
	iThrowSILimit[4]=l4d_tank_throw_witch_limit.IntValue;
	iThrowSILimit[5]=0; // no use
	if(L4D2Version)
	{
		iThrowSILimit[6]=l4d_tank_throw_charger_limit.IntValue;
		iThrowSILimit[7]=l4d_tank_throw_spitter_limit.IntValue;
		iThrowSILimit[8]=l4d_tank_throw_jockey_limit.IntValue;
	}

	throw_tank_health = l4d_tank_throw_tank_health.IntValue;
	z_tank_throw_force_speed = z_tank_throw_force.FloatValue;
	throw_witch_health = l4d_tank_throw_witch_health.IntValue;
	g_fWitchKillTime = g_hWitchKillTime.FloatValue;
}

//-------------------------------Left4Dhooks API Forward-------------------------------

public void L4D_TankRock_OnRelease_Post(int tank, int rock, const float vecPos[3], const float vecAng[3], const float vecVel[3], const float vecRot[3])
{
	if(tank < 0 || g_bIsTraceRock[rock])
	{
		g_bIsTraceRock[rock] = false;
		return;
	}

	float random = GetRandomFloat(1.0, 100.0);
	if( (IsFakeClient(tank) && random <= fl4d_tank_throw_si_ai) ||
		(!IsFakeClient(tank) && random <= fl4d_tank_throw_si_real) )
	{
		if(IsRockStuck(rock, vecPos) == false)
		{
			float velocity[3];
			velocity[0] = vecVel[0]; velocity[1] = vecVel[1]; velocity[2] = vecVel[2];
			
			NormalizeVector(velocity, velocity);
			ScaleVector(velocity, z_tank_throw_force_speed * 1.4);
			int new_helper_si = CreateSI(tank, vecPos, vecAng, velocity);
			if(new_helper_si > 0)
			{
				TeleportEntity(rock, g_99999Position);
				RemoveEdict(rock);
				if(L4D2Version) DisplayParticle(0, PARTICLE_ELECTRICAL, vecPos, NULL_VECTOR);    
				if(new_helper_si <= MaxClients) L4D_WarpToValidPositionIfStuck(new_helper_si);
			}
		}
	}
}

//-------------------------------Other API Forward-------------------------------

// from l4d_tracerock.smx by Harry, Tank's rock will trace survivor until hit something.
public void L4D_OnTraceRockCreated(int rock)
{
	g_bIsTraceRock[rock] = true;
}

//--------------------------------------------------------------

bool IsRockStuck(int ent, const float pos[3])
{
	float vAngles[3];
	float vOrigin[3];
	vAngles[2]=1.0;
	GetVectorAngles(vAngles, vAngles);
	Handle trace = TR_TraceRayFilterEx(pos, vAngles, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelf,ent);

	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(vOrigin, trace);
	 	float dis=GetVectorDistance(vOrigin, pos);
		if(dis>100.0)
		{
			delete trace;
			return false;
		}
	}
	
	delete trace;
	return true;
}

stock int CreateSI(int thetank, const float pos[3], const float ang[3], const float velocity[3])
{
	int selected=0;
	int chooseclass=0;
	float random = GetRandomFloat(1.0, fThrowSIChance[5]);
	if(L4D2Version) random = GetRandomFloat(1.0, fThrowSIChance[8]);
	
	// current count ...
	int boomers=0;
	int smokers=0;
	int hunters=0;
	int spitters=0;
	int jockeys=0;
	int chargers=0;
	int tanks=0;
	int infectedfreeplayer = 0;
	int iClientCount = 0, iClients[MAXPLAYERS+1];
	for (int i=1;i<=MaxClients;i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == L4D_TEAM_INFECTED)
		{
			if (IsPlayerAlive(i))
			{
				// We count depending on class ...
				if (IsPlayerSmoker(i))
					smokers++;
				else if (IsPlayerBoomer(i))
					boomers++;	
				else if (IsPlayerHunter(i))
					hunters++;	
				else if (IsPlayerTank(i))
					tanks++;	
				else if (L4D2Version && IsPlayerSpitter(i))
					spitters++;	
				else if (L4D2Version && IsPlayerJockey(i))
					jockeys++;	
				else if (L4D2Version && IsPlayerCharger(i))
					chargers++;	

				continue;
			}

			if(!IsFakeClient(i))
			{
				iClients[iClientCount++] = i;
				SetLifeState(i, true);
			}
		}
	}

	infectedfreeplayer = (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];

	bool resetGhost[MAXPLAYERS+1];
	bool resetLife[MAXPLAYERS+1];
	if(infectedfreeplayer > 0)
	{
		for(int i = 1; i <= MaxClients; i++)
		{	
			if(i != infectedfreeplayer && IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == L4D_TEAM_INFECTED)
			{
				if (IsPlayerGhost(i))
				{
					resetGhost[i] = true;
					SetGhostStatus(i, false);
					continue;
				}
				if (!IsPlayerAlive(i))
				{
					resetLife[i] = true;
					SetLifeState(i, false);
					continue;
				}
			}		 
		}
	}

	int witches =0;
	int entity = MaxClients + 1;
	while ( ((entity = FindEntityByClassname(entity, "witch")) != -1) )
	{
		if(!IsValidEntity(entity)) continue;

		witches++;
	}

	bool bSpawnSuccessful = false;
	if(random<=fThrowSIChance[0] && fThrowSIChance[0] > 0.0)
	{
		if(hunters < iThrowSILimit[0])
		{
			if(infectedfreeplayer > 0)
			{
				CheatCommand(thetank, sSpawnCommand, "Hunter"); 
				if(IsPlayerAlive(infectedfreeplayer))
				{
					selected = infectedfreeplayer;
					bSpawnSuccessful = true;
				}
			}
			else 
			{
				selected = SDKCall(hCreateHunter, "Helper Hunter Bot");
				if (IsValidClient(selected))
				{
					SetEntityModel(selected, MODEL_HUNTER);
					bSpawnSuccessful = true;
				}
			}
		}
		
		chooseclass = ZC_HUNTER;
	}
	else if(random<=fThrowSIChance[1] && fThrowSIChance[1] > 0.0)
	{
		if(smokers < iThrowSILimit[1])
		{
			if(infectedfreeplayer > 0)
			{
				CheatCommand(thetank, sSpawnCommand, "Smoker"); 
				if(IsPlayerAlive(infectedfreeplayer))
				{
					selected = infectedfreeplayer;
					bSpawnSuccessful = true;
				}
			}
			else 
			{
				selected = SDKCall(hCreateSmoker, "Helper Smoker Bot");
				if (IsValidClient(selected))
				{
					SetEntityModel(selected, MODEL_SMOKER);
					bSpawnSuccessful = true;
				}
			}
		}

		chooseclass = ZC_SMOKER;
	}
	else if(random<=fThrowSIChance[2] && fThrowSIChance[2] > 0.0)
	{
		if(boomers < iThrowSILimit[2])
		{
			if(infectedfreeplayer > 0)
			{
				CheatCommand(thetank, sSpawnCommand, "Boomer"); 
				if(IsPlayerAlive(infectedfreeplayer))
				{
					selected = infectedfreeplayer;
					bSpawnSuccessful = true;
				}
			}
			else 
			{
				selected = SDKCall(hCreateBoomer, "Helper Boomer Bot");
				if (IsValidClient(selected))
				{
					SetEntityModel(selected, MODEL_BOOMER);
					bSpawnSuccessful = true;
				}
			}
		}

		chooseclass = ZC_BOOMER;
	}
	else if(random<=fThrowSIChance[3] && fThrowSIChance[3] > 0.0)
	{
		if(tanks < iThrowSILimit[3])
		{
			if(infectedfreeplayer > 0)
			{
				CheatCommand(thetank, sSpawnCommand, "Tank"); 
				if(IsPlayerAlive(infectedfreeplayer))
				{
					selected = infectedfreeplayer;
					bSpawnSuccessful = true;
				}
			}
			else
			{
				selected = SDKCall(hCreateTank, "Helper Tank Bot");
				if (IsValidClient(selected))
				{
					SetEntityModel(selected, MODEL_TANK);
					bSpawnSuccessful = true;
				}
			}
		}

		chooseclass = ZC_TANK; 
	}
	else if(random<=fThrowSIChance[4] && fThrowSIChance[4] > 0.0)
	{
		if(witches < iThrowSILimit[4])
		{
			if( g_bSpawnWitchBride )
			{
				selected = L4D2_SpawnWitchBride(pos, NULL_VECTOR);
			}
			else
			{
				selected = L4D2_SpawnWitch(pos, NULL_VECTOR);
			}
			if(selected > MaxClients)
			{
				SetEntProp(selected, Prop_Data, "m_iHealth", throw_witch_health);
				ForceWitchJump(selected, velocity, true);
				
				CreateTimer(g_fWitchKillTime, KickWitch_Timer, EntIndexToEntRef(selected), TIMER_FLAG_NO_MAPCHANGE);
				return selected;
			}
		}
		else
		{
			selected = thetank;
		}

		chooseclass = ZC_WITCH;
	}
	else if(random<=fThrowSIChance[5] && fThrowSIChance[5] > 0.0)
	{
		selected=thetank;
	}
	else if(random<=fThrowSIChance[6] && fThrowSIChance[6] > 0.0)
	{
		if(chargers < iThrowSILimit[6])
		{
			if(infectedfreeplayer > 0)
			{
				CheatCommand(thetank, sSpawnCommand, "Charger"); 
				if(IsPlayerAlive(infectedfreeplayer))
				{
					selected = infectedfreeplayer;
					bSpawnSuccessful = true;
				}
			}
			else
			{
				selected = SDKCall(hCreateCharger, "Helper Charger Bot");
				if (IsValidClient(selected))
				{
					SetEntityModel(selected, MODEL_CHARGER);
					bSpawnSuccessful = true;
				}
			}
		}

		chooseclass = ZC_CHARGER;
	}
	else if(random<=fThrowSIChance[7] && fThrowSIChance[7] > 0.0)
	{
		if(spitters < iThrowSILimit[7])
		{
			if(infectedfreeplayer > 0)
			{
				CheatCommand(thetank, sSpawnCommand, "Spitter"); 
				if(IsPlayerAlive(infectedfreeplayer))
				{
					selected = infectedfreeplayer;
					bSpawnSuccessful = true;
				}
			}
			else
			{
				selected = SDKCall(hCreateSpitter, "Helper Spitter Bot");
				if (IsValidClient(selected))
				{
					SetEntityModel(selected, MODEL_SPITTER);
					bSpawnSuccessful = true;
				}
			}
		}

		chooseclass = ZC_SPITTER;
	}
	else if(random<=fThrowSIChance[8] && fThrowSIChance[8] > 0.0)
	{
		if(jockeys < iThrowSILimit[8])
		{
			if(infectedfreeplayer > 0)
			{
				CheatCommand(thetank, sSpawnCommand, "Jockey"); 
				if(IsPlayerAlive(infectedfreeplayer))
				{
					selected = infectedfreeplayer;
					bSpawnSuccessful = true;
				}
			}
			else
			{
				selected = SDKCall(hCreateJockey, "Helper Jockey Bot");
				if (IsValidClient(selected))
				{
					SetEntityModel(selected, MODEL_JOCKEY);
					bSpawnSuccessful = true;
				}
			}
		}

		chooseclass = ZC_JOCKEY;
	}
	else
	{
		return -1;
	}

	if(infectedfreeplayer > 0) // We restore the player's status
	{
		for (int i=1;i<=MaxClients;i++)
		{
			if (resetGhost[i] == true)
				SetGhostStatus(i, true);
			if (resetLife[i] == true)
				SetLifeState(i, true);
		}
	}

	if (bSpawnSuccessful && selected > 0 && selected <= MaxClients) // SpawnSuccessful (AI/Real Player)
	{
		if(IsFakeClient(selected))
		{
			ChangeClientTeam(selected, 3);
			SetEntProp(selected, Prop_Send, "m_usSolidFlags", 16);
			SetEntProp(selected, Prop_Send, "movetype", 2);
			SetEntProp(selected, Prop_Send, "deadflag", 0);
			SetEntProp(selected, Prop_Send, "m_lifeState", 0);
			SetEntProp(selected, Prop_Send, "m_iObserverMode", 0);
			SetEntProp(selected, Prop_Send, "m_iPlayerState", 0);
			SetEntProp(selected, Prop_Send, "m_zombieState", 0);
			DispatchSpawn(selected);
			ActivateEntity(selected);
		}

		if(chooseclass == ZC_TANK) SetEntityHealth(selected, throw_tank_health);
	}
	else if (selected == 0) //throw teammate
	{
		int andidate[MAXPLAYERS+1];
		int index=0;
		for(int i = 1; i <= MaxClients; i++)
		{	
			if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == L4D_TEAM_INFECTED && L4D_GetSurvivorVictim(i) == -1)
			{
				if(GetEntProp(i,Prop_Send,"m_zombieClass") == chooseclass)
				{
					andidate[index++] = i;
				}
			}		 
		}

		if(index > 0) selected = andidate[GetRandomInt(0, index-1)];
		else selected = thetank; //all infected busy, throw tank self
	}

	if (selected > 0) 
	{
		/*PrintToChatAll("%d (%d) was throw: %.2f %.2f %.2f %.2f %.2f %.2f", 
			selected, chooseclass, pos[0], pos[1], pos[2], velocity[0], velocity[1], velocity[2]);*/

		TeleportEntity(selected, pos, NULL_VECTOR, velocity);
	}
 
 	return selected;
}
 
void CheatCommand(int client, char[] command, char[] arguments = "")
{
	int userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userFlags);
}

int DisplayParticle(int target, const char[] sParticle, const float vPos[3], const float vAng[3], float refire = 0.0)
{
	int entity = CreateEntityByName("info_particle_system");
	if( entity == -1)
	{
		LogError("Failed to create 'info_particle_system'");
		return 0;
	}

	DispatchKeyValue(entity, "effect_name", sParticle);
	DispatchSpawn(entity);
	ActivateEntity(entity);
	AcceptEntityInput(entity, "start");

	// Attach
	if( target )
	{
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", target);
	}

	TeleportEntity(entity, vPos, vAng, NULL_VECTOR);

	// Refire
	if( refire )
	{
		static char sTemp[64];
		Format(sTemp, sizeof(sTemp), "OnUser1 !self:Stop::%f:-1", refire - 0.05);
		SetVariantString(sTemp);
		AcceptEntityInput(entity, "AddOutput");
		Format(sTemp, sizeof(sTemp), "OnUser1 !self:FireUser2::%f:-1", refire);
		SetVariantString(sTemp);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");

		SetVariantString("OnUser2 !self:Start::0:-1");
		AcceptEntityInput(entity, "AddOutput");
		SetVariantString("OnUser2 !self:FireUser1::0:-1");
		AcceptEntityInput(entity, "AddOutput");
	}

	return entity;
}

public Action DeleteParticles(Handle timer, any particle)
{
	particle = EntRefToEntIndex(particle);
	if (particle != INVALID_ENT_REFERENCE)
	{
		AcceptEntityInput(particle, "stop");
		AcceptEntityInput(particle, "kill");
	}

	return Plugin_Continue;
}

public bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	if(entity == data) 
	{
		return false; 
	}
	return true;
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

Handle hGameConf;
void GetGameData()
{
	hGameConf = LoadGameConfigFile("l4d_tank_helper");
	if( hGameConf != null )
	{
		PrepSDKCall();

		int offset = GameConfGetOffset(hGameConf, "NextBotPointer");
		if(offset == -1) {SetFailState("Unable to find NextBotPointer offset.");return;}
		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetVirtual(offset);
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		g_hNextBotPointer = EndPrepSDKCall();
		if(g_hNextBotPointer==null) {SetFailState("Cannot initialize NextBotPointer SDKCall, signature is broken.");return;}

		offset = GameConfGetOffset(hGameConf, "GetLocomotion");
		if(offset == -1) {SetFailState("Unable to find GetLocomotion offset.");return;}
		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetVirtual(offset);
		PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
		g_hGetLocomotion = EndPrepSDKCall();
		if(g_hGetLocomotion==null) {SetFailState("Cannot initialize GetLocomotion SDKCall, signature is broken.");return;}

		offset = GameConfGetOffset(hGameConf, "Jump");
		if(offset == -1) {SetFailState("Unable to find Jump offset.");return;}
		StartPrepSDKCall(SDKCall_Raw);
		PrepSDKCall_SetVirtual(offset);
		g_hJump = EndPrepSDKCall();
		if(g_hJump==null) {SetFailState("Cannot initialize Jump SDKCall, signature is broken.");return;}
	}
	else
	{
		SetFailState("Unable to find l4d_tank_helper.txt gamedata file.");
	}
	delete hGameConf;
}

void PrepSDKCall()
{
	//find create bot signature
	Address replaceWithBot = GameConfGetAddress(hGameConf, "NextBotCreatePlayerBot.jumptable");
	if (replaceWithBot != Address_Null && LoadFromAddress(replaceWithBot, NumberType_Int8) == 0x68) {
		// We're on L4D2 and linux
		PrepWindowsCreateBotCalls(replaceWithBot);
	}
	else
	{
		if (L4D2Version)
		{
			PrepL4D2CreateBotCalls();
		}
		else
		{ 
			delete hCreateSpitter; 
			delete hCreateJockey; 
			delete hCreateCharger; 
		}
	
		PrepL4D1CreateBotCalls();
	}
}

void LoadStringFromAdddress(Address addr, char[] buffer, int maxlength) {
	int i = 0;
	while(i < maxlength) {
		char val = LoadFromAddress(addr + view_as<Address>(i), NumberType_Int8);
		if(val == 0) {
			buffer[i] = 0;
			break;
		}
		buffer[i] = val;
		i++;
	}
	buffer[maxlength - 1] = 0;
}

Handle PrepCreateBotCallFromAddress(Handle hSiFuncTrie, const char[] siName) {
	Address addr;
	StartPrepSDKCall(SDKCall_Static);
	if (!GetTrieValue(hSiFuncTrie, siName, addr) || !PrepSDKCall_SetAddress(addr))
	{
		SetFailState("Unable to find NextBotCreatePlayer<%s> address in memory.", siName);
		return null;
	}
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	return EndPrepSDKCall();	
}

void PrepWindowsCreateBotCalls(Address jumpTableAddr) {
	Handle hInfectedFuncs = CreateTrie();
	// We have the address of the jump table, starting at the first PUSH instruction of the
	// PUSH mem32 (5 bytes)
	// CALL rel32 (5 bytes)
	// JUMP rel8 (2 bytes)
	// repeated pattern.
	
	// Each push is pushing the address of a string onto the stack. Let's grab these strings to identify each case.
	// "Hunter" / "Smoker" / etc.
	for(int i = 0; i < 7; i++) {
		// 12 bytes in PUSH32, CALL32, JMP8.
		Address caseBase = jumpTableAddr + view_as<Address>(i * 12);
		Address siStringAddr = view_as<Address>(LoadFromAddress(caseBase + view_as<Address>(1), NumberType_Int32));
		static char siName[32];
		LoadStringFromAdddress(siStringAddr, siName, sizeof(siName));

		Address funcRefAddr = caseBase + view_as<Address>(6); // 2nd byte of call, 5+1 byte offset.
		int funcRelOffset = LoadFromAddress(funcRefAddr, NumberType_Int32);
		Address callOffsetBase = caseBase + view_as<Address>(10); // first byte of next instruction after the CALL instruction
		Address nextBotCreatePlayerBotTAddr = callOffsetBase + view_as<Address>(funcRelOffset);
		//PrintToServer("Found NextBotCreatePlayerBot<%s>() @ %08x", siName, nextBotCreatePlayerBotTAddr);
		SetTrieValue(hInfectedFuncs, siName, nextBotCreatePlayerBotTAddr);
	}

	hCreateSmoker = PrepCreateBotCallFromAddress(hInfectedFuncs, "Smoker");
	if (hCreateSmoker == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateSmoker); return; }

	hCreateBoomer = PrepCreateBotCallFromAddress(hInfectedFuncs, "Boomer");
	if (hCreateBoomer == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateBoomer); return; }

	hCreateHunter = PrepCreateBotCallFromAddress(hInfectedFuncs, "Hunter");
	if (hCreateHunter == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateHunter); return; }

	hCreateTank = PrepCreateBotCallFromAddress(hInfectedFuncs, "Tank");
	if (hCreateTank == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateTank); return; }
	
	hCreateSpitter = PrepCreateBotCallFromAddress(hInfectedFuncs, "Spitter");
	if (hCreateSpitter == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateSpitter); return; }
	
	hCreateJockey = PrepCreateBotCallFromAddress(hInfectedFuncs, "Jockey");
	if (hCreateJockey == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateJockey); return; }

	hCreateCharger = PrepCreateBotCallFromAddress(hInfectedFuncs, "Charger");
	if (hCreateCharger == null)
	{ SetFailState("Cannot initialize %s SDKCall, address lookup failed.", NAME_CreateCharger); return; }
}

void PrepL4D2CreateBotCalls() {
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateSpitter))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateSpitter); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateSpitter = EndPrepSDKCall();
	if (hCreateSpitter == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateSpitter); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateJockey))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateJockey); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateJockey = EndPrepSDKCall();
	if (hCreateJockey == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateJockey); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateCharger))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateCharger); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateCharger = EndPrepSDKCall();
	if (hCreateCharger == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateCharger); return; }
}

void PrepL4D1CreateBotCalls() {
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateSmoker))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateSmoker); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateSmoker = EndPrepSDKCall();
	if (hCreateSmoker == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateSmoker); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateBoomer))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateBoomer); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateBoomer = EndPrepSDKCall();
	if (hCreateBoomer == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateBoomer); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateHunter))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateHunter); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateHunter = EndPrepSDKCall();
	if (hCreateHunter == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateHunter); return; }
	
	StartPrepSDKCall(SDKCall_Static);
	if (!PrepSDKCall_SetFromConf(hGameConf, SDKConf_Signature, NAME_CreateTank))
	{ SetFailState("Unable to find %s signature in gamedata file.", NAME_CreateTank); return; }
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	PrepSDKCall_SetReturnInfo(SDKType_CBasePlayer, SDKPass_Pointer);
	hCreateTank = EndPrepSDKCall();
	if (hCreateTank == null)
	{ SetFailState("Cannot initialize %s SDKCall, signature is broken.", NAME_CreateTank); return; }
}

bool IsValidClient(int client, bool replaycheck = true)
{
	if (client <= 0 || client > MaxClients) return false;
	if (!IsClientInGame(client)) return false;
	//if (GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	if (replaycheck)
	{
		if (IsClientSourceTV(client) || IsClientReplay(client)) return false;
	}
	return true;
}

stock int FindRandomTank(int exclude) 
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++) 
	{
		if (i != exclude && IsClientInGame(i) && GetClientTeam(i) == L4D_TEAM_INFECTED && IsPlayerAlive(i) && GetEntProp(i,Prop_Send,"m_zombieClass") == ZC_TANK)
		{
			iClients[iClientCount++] = i;
		}
	}

	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}

int L4D_GetSurvivorVictim(int client)
{
	int victim;

	if(L4D2Version)
	{
		/* Charger */
		victim = GetEntPropEnt(client, Prop_Send, "m_pummelVictim");
		if (victim > 0)
		{
			return victim;
		}

		victim = GetEntPropEnt(client, Prop_Send, "m_carryVictim");
		if (victim > 0)
		{
			return victim;
		}

		/* Jockey */
		victim = GetEntPropEnt(client, Prop_Send, "m_jockeyVictim");
		if (victim > 0)
		{
			return victim;
		}
	}

    /* Hunter */
	victim = GetEntPropEnt(client, Prop_Send, "m_pounceVictim");
	if (victim > 0)
	{
		return victim;
 	}

    /* Smoker */
 	victim = GetEntPropEnt(client, Prop_Send, "m_tongueVictim");
	if (victim > 0)
	{
		return victim;	
	}

	return -1;
}

public Action OnNormalSoundPlay(int Clients[64], int &NumClients, char StrSample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level,
	int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (StrEqual(StrSample, SOUND_THROWN_MISSILE, false)) {
		NumClients = 0;
		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action KickWitch_Timer(Handle timer, int ref)
{
	if(IsValidEntRef(ref))
	{
		int entity = EntRefToEntIndex(ref);
		bool bKill = true;
		float clientOrigin[3];
		float witchOrigin[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", witchOrigin);
		for (int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && GetClientTeam(i) == L4D_TEAM_SURVIVOR && IsPlayerAlive(i))
			{
				GetClientAbsOrigin(i, clientOrigin);
				if (GetVectorDistance(clientOrigin, witchOrigin, true) < Pow(300.0,2.0))
				{
					bKill = false;
					break;
				}
			}
		}

		if(bKill)
		{
			AcceptEntityInput(ref, "kill"); //remove witch
			return Plugin_Stop;
		}
		else
		{
			CreateTimer(g_fWitchKillTime, KickWitch_Timer, ref, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}
	}

	return Plugin_Stop;
}

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE)
		return true;
	return false;
}

bool IsPlayerSmoker (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZC_SMOKER)
		return true;
	return false;
}

bool IsPlayerHunter (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZC_HUNTER)
		return true;
	return false;
}

bool IsPlayerBoomer (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZC_BOOMER)
		return true;
	return false;
}

bool IsPlayerSpitter (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZC_SPITTER)
		return true;
	return false;
}

bool IsPlayerJockey (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZC_JOCKEY)
		return true;
	return false;
}

bool IsPlayerCharger (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZC_CHARGER)
		return true;
	return false;
}

bool IsPlayerTank (int client)
{
	if(GetEntProp(client,Prop_Send,"m_zombieClass") == ZC_TANK)
		return true;
	return false;
}

bool IsPlayerGhost (int client)
{
	if (GetEntProp(client, Prop_Send, "m_isGhost"))
		return true;
	return false;
}

void SetGhostStatus (int client, bool ghost)
{
	if (ghost)
		SetEntProp(client, Prop_Send, "m_isGhost", 1, 1);
	else
		SetEntProp(client, Prop_Send, "m_isGhost", 0, 1);
}

void SetLifeState (int client, bool ready)
{
	if (ready)
		SetEntProp(client, Prop_Send,  "m_lifeState", 1, 1);
	else
		SetEntProp(client, Prop_Send, "m_lifeState", 0, 1);
}

// by BHaType: https://forums.alliedmods.net/showpost.php?p=2771305&postcount=2
void ForceWitchJump( int witch, const float vVelocity[3], bool add = false )
{
    Address locomotion = GetLocomotion(witch);
    
    if ( !locomotion )
        return;
    
    float vVec[3];
    
    if ( add )
        GetWitchVelocity(locomotion, vVec);

    AddVectors(vVec, vVelocity, vVec);
    
    Jump(witch, locomotion);
    SetWitchVelocity(locomotion, vVec);
}

stock void Jump( int witch, Address locomotion )
{
	if(L4D2Version)
		StoreToAddress(locomotion + view_as<Address>(0xC0), 0, NumberType_Int8);
	else 
		StoreToAddress(locomotion + view_as<Address>(0xB4), 0, NumberType_Int8);

	SDKCall(g_hJump, locomotion);
}

void GetWitchVelocity( Address locomotion, float out[3] )
{
	if(L4D2Version)
	{
		for (int i; i <= 2; i++)
			out[i] = view_as<float>(LoadFromAddress(locomotion + view_as<Address>(0x6C + i * 4), NumberType_Int32));
	}
	else
	{
		for (int i; i <= 2; i++)
			out[i] = view_as<float>(LoadFromAddress(locomotion + view_as<Address>(0x60 + i * 4), NumberType_Int32));
	}
}

void SetWitchVelocity( Address locomotion, const float vVelocity[3] )
{
	if(L4D2Version)
	{
		for (int i; i <= 2; i++)
			StoreToAddress(locomotion + view_as<Address>(0x6C + i * 4), view_as<int>(vVelocity[i]), NumberType_Int32);
	}
	else
	{
		for (int i; i <= 2; i++)
			StoreToAddress(locomotion + view_as<Address>(0x60 + i * 4), view_as<int>(vVelocity[i]), NumberType_Int32);
	}
}

Address GetLocomotion( int entity )
{
    Address nextbot = GetNextBotPointer(entity);
    
    if ( !nextbot )
        return Address_Null;

    return GetLocomotionPointer(nextbot);
}

Address GetNextBotPointer( int entity )
{
    return SDKCall(g_hNextBotPointer, entity);
}

Address GetLocomotionPointer( Address nextbot )
{
    return SDKCall(g_hGetLocomotion, nextbot);
} 

public void OnActionCreated( BehaviorAction action, int actor, const char[] name )
{
	if ( strcmp(name, "WitchIdle") == 0 )
	{
		action.OnUpdate = OnUpdate;
	}
}

public Action OnUpdate( BehaviorAction action, int actor, float interval, ActionResult result ) 
{
	if ( GetEntityFlags(actor) & FL_ONGROUND )
	{
		//action.OnUpdate = INVALID_FUNCTION;
		return Plugin_Continue;
	}

	return Plugin_Handled;
}