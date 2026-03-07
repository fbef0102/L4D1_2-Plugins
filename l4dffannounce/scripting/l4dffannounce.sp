#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>
#define PLUGIN_VERSION			"1.9-2026/3/7"

public Plugin myinfo = 
{
	name = "L4D FF Announce Plugin",
	author = "Frustian & HarryPotter & apples1949",
	description = "Display Friendly Fire Announcements",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913"
}

#define MAXENTITIES 2048

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar g_hCvarEnable, g_hCvarAnnounceType;
bool g_bCvarEnable;
int g_iCvarAnnounceType;

int g_iDamageTempCache[MAXPLAYERS+1][MAXPLAYERS+1]; //Used to temporarily store Friendly Fire Damage between teammates
Handle g_hFFTimer[MAXPLAYERS+1]; //Used to be able to disable the FF timer when they do more FF
int g_iTotalDamage[MAXPLAYERS+1][MAXPLAYERS+1]; // g_iTotalDamage

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 && test != Engine_Left4Dead) 
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success; 
}

public void OnPluginStart()
{
	LoadTranslations("l4dffannounce.phrases");
	g_hCvarEnable 			= CreateConVar( "l4dffannounce_enable",     "1",   	"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarAnnounceType 	= CreateConVar( "l4dffannounce_type", 		"1", 	"Changes how ff announce displays FF damage (0: Disable, 1:In chat; 2: In Hint Box; 3: In center text)",CVAR_FLAGS, true, 0.0, true, 3.0);
	CreateConVar(                       	"l4dffannounce_version",     PLUGIN_VERSION, "l4dffannounce Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                	"l4dffannounce");

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarAnnounceType.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_hurt_concise", 		Event_HurtConcise, EventHookMode_Post);
	HookEvent("player_incapacitated_start", Event_IncapacitatedStart);

	HookEvent("round_start", 				Event_RoundStart);
	HookEvent("player_death", 				Event_PlayerDeath);
	HookEvent("round_end",					Event_RoundEnd,		EventHookMode_PostNoCopy); //trigger twice in versus mode, one when all survivors wipe out or make it to saferom, one when first round ends (second round_start begins).
	HookEvent("map_transition", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //all survivors make it to saferoom, and server is about to change next level in coop mode (does not trigger round_end) 
	HookEvent("mission_lost", 				Event_RoundEnd,		EventHookMode_PostNoCopy); //all survivors wipe out in coop mode (also triggers round_end)
	HookEvent("finale_win", 				Event_RoundEnd,		EventHookMode_PostNoCopy); 
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarEnable = g_hCvarEnable.BoolValue;
    g_iCvarAnnounceType = g_hCvarAnnounceType.IntValue;
}

public void OnMapEnd()
{
	ResetTimer();
}

void Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	// clear total damage
	for (int i = 0; i <= MaxClients; i++)
	{
		for (int j = 0; j <= MaxClients; j++)
		{
			g_iTotalDamage[i][j] = 0;
		}
	}
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	ResetTimer();
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if ( !victim || !IsClientInGame(victim) || attacker == victim ) return;
	if ( !attacker || !IsClientInGame(attacker) ) return;

	if(GetClientTeam(attacker) == 2 && GetClientTeam(victim) == 2) //人類 kill &友傷
	{
		CPrintToChatAll("[{olive}TS{default}] %t", "KILL", attacker, victim);
	}	
}

void Event_HurtConcise(Event event, const char[] name, bool dontBroadcast) 
{
	int attacker = event.GetInt("attackerentid");
	int victim = GetClientOfUserId(event.GetInt("userid"));
	if (!g_bCvarEnable || 
	attacker == victim ||
	attacker > MaxClients || 
	attacker < 1 || 
	!IsClientInGame(attacker) || 
	IsFakeClient(attacker) || 
	GetClientTeam(attacker) != 2 || 
	!IsClientInGame(victim) || 
	GetClientTeam(victim) != 2)
		return;  
	
	int damage = event.GetInt("dmg_health");
	if (g_hFFTimer[attacker] != null)  //If the player is already friendly firing teammates, resets the announce timer and adds to the damage
	{
		g_iDamageTempCache[attacker][victim] += damage;
		g_iTotalDamage[attacker][victim] += damage;
		delete g_hFFTimer[attacker];
		g_hFFTimer[attacker] = CreateTimer(1.0, AnnounceFF, attacker);
	}
	else //If it's the first friendly fire by that player, it will start the announce timer and store the damage done.
	{
		g_iDamageTempCache[attacker][victim] = damage;
		g_iTotalDamage[attacker][victim] += damage;
		delete g_hFFTimer[attacker];
		g_hFFTimer[attacker] = CreateTimer(1.0, AnnounceFF, attacker);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (i != attacker && i != victim)
			{
				g_iDamageTempCache[attacker][i] = 0;
			}
		}
	}
}

void Event_IncapacitatedStart(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));

	if (!g_bCvarEnable || 
	attacker == victim ||
	attacker > MaxClients || 
	attacker < 1 || 
	!IsClientInGame(attacker) || 
	IsFakeClient(attacker) || 
	GetClientTeam(attacker) != 2 || 
	!IsClientInGame(victim) || 
	GetClientTeam(victim) != 2)
		return;  

	int damage = GetClientHealth(victim) + RoundToFloor(GetTempHealth(victim));
	if (g_hFFTimer[attacker] != null)  //If the player is already friendly firing teammates, resets the announce timer and adds to the damage
	{
		g_iDamageTempCache[attacker][victim] += damage;
		delete g_hFFTimer[attacker];
		g_hFFTimer[attacker] = CreateTimer(1.0, AnnounceFF, attacker);
	}
	else //If it's the first friendly fire by that player, it will start the announce timer and store the damage done.
	{
		g_iDamageTempCache[attacker][victim] = damage;
		delete g_hFFTimer[attacker];
		g_hFFTimer[attacker] = CreateTimer(1.0, AnnounceFF, attacker);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (i != attacker && i != victim)
			{
				g_iDamageTempCache[attacker][i] = 0;
			}
		}
	}
}

Action AnnounceFF(Handle timer, int attacker) //Called if the attacker did not friendly fire recently, and announces all FF they did
{
	g_hFFTimer[attacker] = null;

	char sVictimName[128];
	char sAttackerName[128];

	if (IsClientInGame(attacker) && !IsFakeClient(attacker))
		GetClientName(attacker, sAttackerName, sizeof(sAttackerName));
	else
		FormatEx(sAttackerName, sizeof(sAttackerName), "Disconnected Player");

	for (int i = 1; i <= MaxClients; i++)
	{
		if (g_iDamageTempCache[attacker][i] != 0 && attacker != i)
		{
			if (IsClientInGame(i))
			{
				GetClientName(i, sVictimName, sizeof(sVictimName));
				switch(g_iCvarAnnounceType)
				{
					case 1:
					{
						if (IsClientInGame(attacker) && !IsFakeClient(attacker))
							CPrintToChat(attacker, "[{olive}TS{default}] %T", "FF_dealt (C)", attacker, g_iDamageTempCache[attacker][i], sVictimName, g_iTotalDamage[attacker][i]);
						if (IsClientInGame(i) && !IsFakeClient(i))
							CPrintToChat(i, "[{olive}TS{default}] %T", "FF_receive (C)", i, sAttackerName, g_iDamageTempCache[attacker][i], g_iTotalDamage[attacker][i]);
					}
					case 2:
					{
						if (IsClientInGame(attacker) && !IsFakeClient(attacker))
							PrintHintText(attacker, "%T", "FF_dealt", attacker, g_iDamageTempCache[attacker][i], sVictimName, g_iTotalDamage[attacker][i]);
						if (IsClientInGame(i) && !IsFakeClient(i))
							PrintHintText(i, "%T", "FF_receive", i, sAttackerName, g_iDamageTempCache[attacker][i], g_iTotalDamage[attacker][i]);
					}
					case 3:
					{
						if (IsClientInGame(attacker) && !IsFakeClient(attacker))
							PrintCenterText(attacker, "%T", "FF_dealt", attacker, g_iDamageTempCache[attacker][i], sVictimName, g_iTotalDamage[attacker][i]);
						if (IsClientInGame(i) && !IsFakeClient(i))
							PrintCenterText(i, "%T", "FF_receive", i, sAttackerName, g_iDamageTempCache[attacker][i], g_iTotalDamage[attacker][i]);
					}
					default:
					{
						//nothing
					}
				}
			}
			g_iDamageTempCache[attacker][i] = 0;
		}
	}

	return Plugin_Continue;
}

void ResetTimer()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		delete g_hFFTimer[i];
	}
}

float GetTempHealth(int client)
{
	static float fCvarDecayRate = -1.0;

	if (fCvarDecayRate == -1.0)
		fCvarDecayRate = FindConVar("pain_pills_decay_rate").FloatValue;

	float fTempHealth = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	fTempHealth -= (GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * fCvarDecayRate;
	return fTempHealth < 0.0 ? 0.0 : fTempHealth;
}
