// 2018-2022 @ samuelviveiros a.k.a Dartz8901, Harry

/************************************************************************
  [L4D & L4D2] Graves (v1.3, 2022-2-15)

  DESCRIPTION: 
  
    When a survivor dies, a grave appears near his body, and this grave 
    glows through the objects on the map, allowing a quick location from 
    where the survivor died. 

    And when the survivor respawns, the grave associated with him disappears.

    In addition, there are six types of grave that are chosen randomly.

    Maybe can be useful for use with a defibrillator (L4D2), or even for 
    those who use the "Emergency Treatment With First Aid Kit Revive And 
    CPR" (L4D) plugin, for example.

    Anyway, I made this more for fun than for some utility.

    This plugin is also based on the Tuty plugin (CSS Graves), which can 
    be found here:

    https://forums.alliedmods.net/showthread.php?p=867275

    But I rewrote all the code to run on Left 4 Dead 1 & 2.

    This code can be found on my github page here:

    https://github.com/samuelviveiros/l4d_graves

    Do not forget to update the CFG file with the new CVARs.

    For Left 4 Dead, the file is located in left4dead/cfg/sourcemod/l4d_graves.cfg.

    And for Left 4 Dead 2, the file is located in left4dead2/cfg/sourcemod/l4d_graves.cfg

    Have fun!

  CHANGELOG:
  2022-2-15 (v1.2)
  - Optimaze code

  2018-12-27 (v1.1.1)
    - Added the l4d_graves_delay CVAR that determines how long it will 
      take for the grave to spawn. This delay is necessary to avoid cases, 
      for example, where a Tank has just killed a survivor and the grave
      appears instantly, and Tank immediately breaks the grave.

    - Added the l4d_graves_not_solid CVAR that allows you to turn grave 
      solidity on or off. The reason is that some players have said that 
      they sometimes get stuck on the grave when it spawns. In such cases, 
      the admin may prefer to disable solidity. Do not forget to update 
      the cfg file with this CVAR.

    - Fixed client index issue when calling GetClientTeam function.

  2018-12-27 (v1.0.1)
    - Function RemoveEntity has been replaced by function AcceptEntityInput, 
      passing the "Kill" parameter, so that it work with the online compiler.

  2018-12-26 (v1.0.0)
    - Initial release.

 ************************************************************************/

#include <sourcemod>
#include <sdktools>

/**
 * Compiler requires semicolons and the new syntax.
 */
#pragma semicolon 1
#pragma newdecls   required

/**
 * Semantic versioning <https://semver.org/>
 */
#define PLUGIN_VERSION	"1.3"
#define ENTITY_SAFE_LIMIT 2000

public Plugin myinfo = 
{
	name 			= "[L4D & L4D2] Graves",
	author 			= "samuelviveiros a.k.a Dartz8901, Harry",
	description 	= "When a survivor die, on his body appear a grave.",
	version 		= PLUGIN_VERSION,
	url 			= "https://github.com/samuelviveiros/l4d_graves"
};

#define SOLID_BBOX_SM	2
#define DAMAGE_AIM_SM	2
#define TEAM_SURVIVOR	2

int g_iModelIndex[MAXPLAYERS+1];
Handle SpawnGrave_Timer[MAXPLAYERS+1];

ConVar g_hGravesEnabled,  g_hGraveNotSolid, g_hGraveDelay, g_hGraveGlow, g_hGraveHealth;
ConVar g_hGraveGlowColor, g_hGraveGlowRange; // L4D2 only

char g_aGraveModels[][] = {
	// graves
	"models/props_cemetery/grave_01.mdl",
	"models/props_cemetery/grave_02.mdl",
	"models/props_cemetery/grave_03.mdl",
	"models/props_cemetery/grave_04.mdl",
	"models/props_cemetery/grave_06.mdl",
	"models/props_cemetery/grave_07.mdl",

	// avoiding the "Late precache" message on the client console.
	"models/props_cemetery/gibs/grave_02a_gibs.mdl",
	"models/props_cemetery/gibs/grave_02b_gibs.mdl",
	"models/props_cemetery/gibs/grave_02c_gibs.mdl",
	"models/props_cemetery/gibs/grave_02d_gibs.mdl",
	"models/props_cemetery/gibs/grave_02e_gibs.mdl",
	"models/props_cemetery/gibs/grave_02f_gibs.mdl",
	"models/props_cemetery/gibs/grave_02g_gibs.mdl",
	"models/props_cemetery/gibs/grave_02h_gibs.mdl",
	"models/props_cemetery/gibs/grave_02i_gibs.mdl",
	"models/props_cemetery/gibs/grave_03a_gibs.mdl",
	"models/props_cemetery/gibs/grave_03b_gibs.mdl",
	"models/props_cemetery/gibs/grave_03c_gibs.mdl",
	"models/props_cemetery/gibs/grave_03d_gibs.mdl",
	"models/props_cemetery/gibs/grave_03e_gibs.mdl",
	"models/props_cemetery/gibs/grave_03f_gibs.mdl",
	"models/props_cemetery/gibs/grave_03g_gibs.mdl",
	"models/props_cemetery/gibs/grave_03h_gibs.mdl",
	"models/props_cemetery/gibs/grave_03i_gibs.mdl",
	"models/props_cemetery/gibs/grave_03j_gibs.mdl",
	"models/props_cemetery/gibs/grave_06a_gibs.mdl",
	"models/props_cemetery/gibs/grave_06b_gibs.mdl",
	"models/props_cemetery/gibs/grave_06c_gibs.mdl",
	"models/props_cemetery/gibs/grave_06d_gibs.mdl",
	"models/props_cemetery/gibs/grave_06e_gibs.mdl",
	"models/props_cemetery/gibs/grave_06f_gibs.mdl",
	"models/props_cemetery/gibs/grave_06g_gibs.mdl",
	"models/props_cemetery/gibs/grave_06h_gibs.mdl",
	"models/props_cemetery/gibs/grave_06i_gibs.mdl",
	"models/props_cemetery/gibs/grave_07a_gibs.mdl",
	"models/props_cemetery/gibs/grave_07b_gibs.mdl",
	"models/props_cemetery/gibs/grave_07c_gibs.mdl",
	"models/props_cemetery/gibs/grave_07d_gibs.mdl",
	"models/props_cemetery/gibs/grave_07e_gibs.mdl",
	"models/props_cemetery/gibs/grave_07f_gibs.mdl"
};

static bool L4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test == Engine_Left4Dead )
	{
		L4D2Version = false;
	}
	else if( test == Engine_Left4Dead2 )
	{
		L4D2Version = true;
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
	g_hGravesEnabled 	= CreateConVar("l4d_graves_enable", "1", "Enable or disable this plugin.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGraveNotSolid 	= CreateConVar("l4d_graves_not_solid", "0", "Enables or disables the solidity of the grave.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGraveDelay 		= CreateConVar("l4d_graves_delay", "5.0", "How long will it take for the grave to spawn.", FCVAR_NOTIFY, true, 1.0);
	g_hGraveGlow 		= CreateConVar("l4d_graves_glow", "1", "Turn glow On or Off.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGraveGlowColor 	= CreateConVar("l4d_graves_glow_color", "-1 -1 -1", "L4D2 Only, RGB Color - Change the render color of the glow. Values between 0-255. [-1 -1 -1: Random]", FCVAR_NOTIFY);
	g_hGraveGlowRange 	= CreateConVar("l4d_graves_glow_range", "1500", "L4D2 Only, Change the glow range. ", FCVAR_NOTIFY, true, 1.0);
	g_hGraveHealth 		= CreateConVar("l4d_graves_health", "1500", "Number of points of damage to take before breaking. (In L4D2, 0 means don't break)", FCVAR_NOTIFY, true, 0.0);
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("round_end", Event_RoundEnd, EventHookMode_PostNoCopy); //對抗上下回合結束的時候觸發
	HookEvent("map_transition", Event_RoundEnd, EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (之後沒有觸發round_end)
	HookEvent("mission_lost", Event_RoundEnd, EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd, EventHookMode_PostNoCopy); //救援載具離開之時  (之後沒有觸發round_end)

	GetCvars();
	g_hGravesEnabled.AddChangeHook(ConVarChanged_Cvars);
	g_hGraveNotSolid.AddChangeHook(ConVarChanged_Cvars);
	g_hGraveDelay.AddChangeHook(ConVarChanged_Cvars);
	g_hGraveGlow.AddChangeHook(ConVarChanged_Cvars);
	g_hGraveGlowColor.AddChangeHook(ConVarChanged_Cvars);
	g_hGraveGlowRange.AddChangeHook(ConVarChanged_Cvars);
	g_hGraveHealth.AddChangeHook(ConVarChanged_Cvars);

	AutoExecConfig(true, "l4d_graves");
}

public void OnPluginEnd()
{
	ResetTimer();
	for( int i = 1; i <= MaxClients; i++ )
		RemoveGrave(i);
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

bool g_bGravesEnabled, g_bGraveNotSolid, g_bGraveGlow;
float g_fGraveDelay;
char g_sGraveGlowColor[32], g_sGraveHealth[4];
int g_iGraveHealth, g_iGraveGlowRange;
void GetCvars()
{
	g_bGravesEnabled = g_hGravesEnabled.BoolValue;
	g_bGraveNotSolid = g_hGraveNotSolid.BoolValue;
	g_fGraveDelay = g_hGraveDelay.FloatValue;
	g_bGraveGlow = g_hGraveGlow.BoolValue;
	g_hGraveGlowColor.GetString(g_sGraveGlowColor, sizeof(g_sGraveGlowColor));
	g_iGraveGlowRange = g_hGraveGlowRange.IntValue;
	g_iGraveHealth = g_hGraveHealth.IntValue;
	g_hGraveHealth.GetString(g_sGraveHealth, sizeof(g_sGraveHealth));
}

public void OnMapStart()
{
	for ( int i = 0; i < sizeof(g_aGraveModels); i++ )
	{
		PrecacheModel(g_aGraveModels[i]);
	}
}

public void OnMapEnd()
{
	ResetTimer();
}

public void OnClientDisconnect(int client)
{
	delete SpawnGrave_Timer[client];
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetTimer();
	for( int i = 1; i <= MaxClients; i++ )
		RemoveGrave(i);
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	RemoveGrave(client);
	delete SpawnGrave_Timer[client];
}

public void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	RemoveGrave(client);
	delete SpawnGrave_Timer[client];
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if( g_bGravesEnabled )
	{
		int victim = GetClientOfUserId(event.GetInt("userid"));

		if ( victim > 0 && victim <= MaxClients && IsClientInGame(victim) && GetClientTeam(victim) == TEAM_SURVIVOR )
		{
			float origin[3];
			GetClientAbsOrigin(victim, origin);
			
			DataPack pack;
			delete SpawnGrave_Timer[victim];
			SpawnGrave_Timer[victim] = CreateDataTimer(g_fGraveDelay, Timer_SpawnGrave, pack);
			pack.WriteFloat(origin[0]);
			pack.WriteFloat(origin[1]);
			pack.WriteFloat(origin[2]);
			pack.WriteCell(victim);
		}
	}
}

public Action Timer_SpawnGrave(Handle timer, DataPack corpse)
{
	int grave = -1;
	int client;
	float origin[3];

	corpse.Reset();
	origin[0] = corpse.ReadFloat();
	origin[1] = corpse.ReadFloat();
	origin[2] = corpse.ReadFloat();
	client = corpse.ReadCell();
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != TEAM_SURVIVOR || IsPlayerAlive(client))
	{
		SpawnGrave_Timer[client] = null;
		return Plugin_Continue;
	}

	//just in case
	RemoveGrave(client);

	if ( !L4D2Version )
	{
		grave = CreateEntityByName("prop_glowing_object");
		if (CheckIfEntityMax( grave ) == false) 
		{
			SpawnGrave_Timer[client] = null;
			return Plugin_Continue;
		}

		DispatchKeyValue(grave, "StartGlowing", (g_bGraveGlow != false) ? "1" : "0");
		SetEntityModel(grave, g_aGraveModels[GetRandomInt(0, 5)]);
		DispatchSpawn(grave);
		TeleportEntity(grave, origin, NULL_VECTOR, NULL_VECTOR);
		SetEntityMoveType(grave, MOVETYPE_NONE);
		SetEntProp(grave, Prop_Data, "m_takedamage", DAMAGE_AIM_SM);
		SetEntProp(grave, Prop_Data, "m_iHealth", g_iGraveHealth);
		SetEntProp(grave, Prop_Data, "m_nSolidType", ( g_bGraveNotSolid == false ) ? 2 : 0);
	}
	else
	{
		grave = CreateEntityByName("prop_dynamic_override");
		if (CheckIfEntityMax( grave ) == false) 
		{
			SpawnGrave_Timer[client] = null;
			return Plugin_Continue;
		}

		DispatchKeyValue(grave, "health", g_sGraveHealth);
		DispatchKeyValue(grave, "glowrange", "0");
		DispatchKeyValue(grave, "glowrangemin", "190");

		static char sTemp[12];
		if(strcmp(g_sGraveGlowColor, "-1 -1 -1", false) == 0)
		{
			int iRandom = GetURandomIntRange(1,13);
			switch(iRandom)
			{
				case 1: FormatEx(sTemp, sizeof(sTemp), "255 0 0");
				case 2: FormatEx(sTemp, sizeof(sTemp), "0 255 0");
				case 3: FormatEx(sTemp, sizeof(sTemp), "0 0 255");
				case 4: FormatEx(sTemp, sizeof(sTemp), "155 0 255");
				case 5: FormatEx(sTemp, sizeof(sTemp), "0 255 255");
				case 6: FormatEx(sTemp, sizeof(sTemp), "255 155 0");
				case 7: FormatEx(sTemp, sizeof(sTemp), "255 255 255");
				case 8: FormatEx(sTemp, sizeof(sTemp), "255 0 150");
				case 9: FormatEx(sTemp, sizeof(sTemp), "128 255 0");
				case 10: FormatEx(sTemp, sizeof(sTemp), "128 0 0");
				case 11: FormatEx(sTemp, sizeof(sTemp), "0 128 128");
				case 12: FormatEx(sTemp, sizeof(sTemp), "255 255 0");
				case 13: FormatEx(sTemp, sizeof(sTemp), "50 50 50");
			}
		}
		else
			FormatEx(sTemp, sizeof(sTemp), "%s", g_sGraveGlowColor);

		DispatchKeyValue(grave, "glowcolor", sTemp);
		DispatchKeyValue(grave, "solid", (g_bGraveNotSolid == false) ? "2":"0");
		SetEntityModel(grave, g_aGraveModels[GetRandomInt(0, 5)]);
		DispatchSpawn(grave);
		SetEntProp(grave, Prop_Send, "m_nGlowRange", g_iGraveGlowRange);
		TeleportEntity(grave, origin, NULL_VECTOR, NULL_VECTOR);
		if ( g_bGraveGlow != false ) AcceptEntityInput(grave, "StartGlowing");
	}

	g_iModelIndex[client] = EntIndexToEntRef(grave);
	
	SpawnGrave_Timer[client] = null;
	return Plugin_Continue;
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

stock int GetURandomIntRange(int min, int max)
{
	return (GetURandomInt() % (max-min+1)) + min;
}

void RemoveGrave(int client)
{
	int entity = g_iModelIndex[client];
	g_iModelIndex[client] = 0;

	if( IsValidEntRef(entity) )
		AcceptEntityInput(entity, "kill");
}

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}


void ResetTimer()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		delete SpawnGrave_Timer[i];
	}
}