#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <sdktools>
#include <multicolors>

#define PLUGIN_VERSION "2.0"

#define L4D_TEAM_SURVIVOR 2
#define L4D_TEAM_INFECTED 3

#define MAXENTITIES 2048
#define CVAR_FLAGS			FCVAR_NOTIFY

ConVar g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog;
ConVar g_hTankOnly;
ConVar g_hCvarMPGameMode;


char Temp2[] = ", ";
char Temp3[] = " (";
char Temp4[] = " dmg)";
char Temp5[] = "\x05";
char Temp6[] = "\x01";
int g_iDamage[MAXPLAYERS+1][MAXPLAYERS+1]; //Used to temporarily store dmg to S.I.
bool g_bDied[MAXPLAYERS+1]; //tank already dead
int g_iLastHP[MAXPLAYERS+1]; //tank last hp before dead
bool g_bIsWitch[MAXENTITIES+1];// Membership testing for fast witch checking
bool g_bShouldAnnounceWitchDamage[MAXENTITIES+1];
bool g_bTankOnly;
int ZC_TANK;

public Plugin myinfo = 
{
	name = "L4D1/2 Assistance System",
	author = "[E]c & Max Chu, SilverS & ViRaGisTe & HarryPotter",
	description = "Show assists made by survivors",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=123811"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		ZC_TANK = 5;
	}
	else if( test == Engine_Left4Dead2 )
	{
		ZC_TANK = 8;
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
	g_hCvarAllow = 		CreateConVar(	"sm_assist_enable", 		"1", 			"If 1, Enables this plugin.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarModes =		CreateConVar(	"sm_assist_modes",			"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =	CreateConVar(	"sm_assist_modes_off",		"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =	CreateConVar(	"sm_assist_modes_tog",		"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hTankOnly = 		CreateConVar(	"sm_assist_tank_only", 		"1", 			"If 1, only show Damage done to Tank.",CVAR_FLAGS, true, 0.0, true, 1.0);
	
	g_hCvarMPGameMode 	= FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hTankOnly.AddChangeHook(ConVarChanged_Cvars);
	
	AutoExecConfig(true, "l4d2_assist");
}

public void OnPluginEnd()
{
	ResetPlugin();
}

bool g_bMapStarted;
public void OnMapStart()
{
	g_bMapStarted = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	ResetPlugin();
}

// ====================================================================================================
//					CVARS
// ====================================================================================================
public void OnConfigsExecuted()
{
	IsAllowed();
}

public void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bTankOnly = g_hTankOnly.BoolValue;
}

bool g_bCvarAllow;
void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true )
	{
		ResetPlugin();
		g_bCvarAllow = true;
		HookEvents();
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		ResetPlugin();
		g_bCvarAllow = false;
		UnhookEvents();
	}
}

int g_iCurrentMode;
bool IsAllowedGameMode()
{
	if( g_hCvarMPGameMode == null )
		return false;

	int iCvarModesTog = g_hCvarModesTog.IntValue;
	if( iCvarModesTog != 0 )
	{
		if( g_bMapStarted == false )
			return false;

		g_iCurrentMode = 0;

		int entity = CreateEntityByName("info_gamemode");
		if( IsValidEntity(entity) )
		{
			DispatchSpawn(entity);
			HookSingleEntityOutput(entity, "OnCoop", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnSurvival", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnVersus", OnGamemode, true);
			HookSingleEntityOutput(entity, "OnScavenge", OnGamemode, true);
			ActivateEntity(entity);
			AcceptEntityInput(entity, "PostSpawnActivate");
			if( IsValidEntity(entity) ) // Because sometimes "PostSpawnActivate" seems to kill the ent.
				RemoveEdict(entity); // Because multiple plugins creating at once, avoid too many duplicate ents in the same frame
		}

		if( g_iCurrentMode == 0 )
			return false;

		if( !(iCvarModesTog & g_iCurrentMode) )
			return false;
	}

	char sGameModes[64], sGameMode[64];
	g_hCvarMPGameMode.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);

	g_hCvarModes.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) == -1 )
			return false;
	}

	g_hCvarModesOff.GetString(sGameModes, sizeof(sGameModes));
	if( sGameModes[0] )
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", sGameModes);
		if( StrContains(sGameModes, sGameMode, false) != -1 )
			return false;
	}

	return true;
}

public void OnGamemode(const char[] output, int caller, int activator, float delay)
{
	if( strcmp(output, "OnCoop") == 0 )
		g_iCurrentMode = 1;
	else if( strcmp(output, "OnSurvival") == 0 )
		g_iCurrentMode = 2;
	else if( strcmp(output, "OnVersus") == 0 )
		g_iCurrentMode = 4;
	else if( strcmp(output, "OnScavenge") == 0 )
		g_iCurrentMode = 8;
}

// ====================================================================================================
//					EVENTS
// ====================================================================================================
void HookEvents()
{
	HookEvent("player_hurt", Event_Player_Hurt);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_Player_Death);
	HookEvent("player_incapacitated", Event_PlayerIncapacitated);
	HookEvent("witch_spawn", Event_WitchSpawn);
	HookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
	HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
}

void UnhookEvents()
{
	UnhookEvent("player_hurt", Event_Player_Hurt);
	UnhookEvent("player_spawn", Event_PlayerSpawn);
	UnhookEvent("player_death", Event_Player_Death);
	UnhookEvent("player_incapacitated", Event_PlayerIncapacitated);
	UnhookEvent("witch_spawn", Event_WitchSpawn);
	UnhookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
	UnhookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	UnhookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	UnhookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
}

public void Event_PlayerIncapacitated(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int witchid = event.GetInt("attackerentid");
	if (!g_bIsWitch[witchid]||
	!g_bShouldAnnounceWitchDamage[witchid]					// Prevent double print on witch incapping 2 players (rare)
	) return;

	if(!victim || !IsClientInGame(victim)) return;
	
	int health = GetEntityHealth(witchid);
	if (health < 0) health = 0;
	
	CPrintToChatAll("{default}[{olive}TS{default}]{green} Witch{default} had{green} %d{default} health remaining.", health);
	CPrintToChatAll("{green}[提示]{lightgreen} %N {default}反被 {green}Witch {olive}擊☆殺{default}.", victim);

	g_bShouldAnnounceWitchDamage[witchid] = false;
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	ResetPlugin();
}

public void Event_Player_Hurt(Event event, const char[] name, bool dontBroadcast) 
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int damageDone = event.GetInt("dmg_health");
	
	if (0 < victim && victim <= MaxClients && IsClientInGame(victim))
	{
		if( GetClientTeam(victim) == L4D_TEAM_INFECTED )
		{
			if (GetEntProp(victim, Prop_Send, "m_zombieClass") == ZC_TANK)
			{
				if( g_bDied[victim] || g_iLastHP[victim] - damageDone < 0) //坦克死亡動畫或是散彈槍重複計算
				{
					return;
				}
				
				if( GetEntProp(victim, Prop_Send, "m_isIncapacitated") ) //坦克死掉播放動畫，即使是玩家造成傷害，attacker還是0
				{
					g_bDied[victim] = true;
				}
				else
				{
					g_iLastHP[victim] = event.GetInt("health");
				}
			}
			
			if( 0 < attacker <= MaxClients && IsClientInGame(attacker))
			{
				g_iDamage[attacker][victim] += damageDone;
			}
		}
	}
}

public void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
	int client = GetClientOfUserId(event.GetInt("userid"));
		
	if(client && IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_INFECTED)
	{
		for( int i = 1; i <= MaxClients; i++ )
		{
			g_bDied[client] = false;
			g_iLastHP[client] = GetEntProp(client, Prop_Data, "m_iHealth");
			g_iDamage[i][client] = 0;
		}
	}
}

public void Event_Player_Death(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	
	if(!victim || !IsClientInGame(victim)) return;
	
	if (attacker == 0)
	{
		int witchid = event.GetInt("attackerentid");
		if (g_bIsWitch[witchid] && g_bShouldAnnounceWitchDamage[witchid])  // Prevent double print on witch incapping 2 players (rare)
		{
			int health = GetEntityHealth(witchid);
			if (health < 0) health = 0;

			CPrintToChatAll("{default}[{olive}TS{default}]{green} Witch{default} had{green} %d{default} health remaining.", health);
			CPrintToChatAll("{green}[提示]{lightgreen} %N {default}反被 {green}Witch {olive}爆☆殺{default}.", victim);
			g_bShouldAnnounceWitchDamage[witchid] = false;
			return;
		}
	}
	
	if (attacker && IsClientInGame(attacker) && GetClientTeam(attacker) == L4D_TEAM_SURVIVOR && GetClientTeam(victim) == L4D_TEAM_INFECTED)
	{

		if(GetEntProp(victim, Prop_Send, "m_zombieClass") == ZC_TANK)
		{
			g_iDamage[attacker][victim] += g_iLastHP[victim];
		}
		else
		{
			if(g_bTankOnly == true)
			{
				ClearDmgSI(victim);
				return;
			}
		}
		
		char MsgAssist[512];
		bool start = true;
		bool AssistFlag = false;
		char sName[MAX_NAME_LENGTH], sTempMessage[64];
		for (int i = 1; i <= MaxClients; i++)
		{
			if (i != attacker && IsClientInGame(i) && GetClientTeam(i) == L4D_TEAM_SURVIVOR && g_iDamage[i][victim] > 0)
			{
				AssistFlag = true;
				
				if(start == false)
					StrCat(MsgAssist, sizeof(MsgAssist), Temp2);
				
				GetClientName(i, sName, sizeof(sName));
				FormatEx(sTempMessage, sizeof(sTempMessage), "%s%s%s%s%i%s", Temp5,sName,Temp6,Temp3,g_iDamage[i][victim],Temp4);
				StrCat(MsgAssist, sizeof(MsgAssist), sTempMessage);
				start = false;
			}
		}
		
		PrintToChatAll("\x01[\x05TS\x01] \x04%N\x01 got killed by \x03%N\x01 (%d dmg).", victim, attacker, g_iDamage[attacker][victim]);
		if (AssistFlag == true) 
		{
			PrintToChatAll("\x05\x01|| Assist: %s.", MsgAssist);
		}
	}
	
	ClearDmgSI(victim);
}

public void Event_WitchSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int witchid = event.GetInt("witchid");
	g_bIsWitch[witchid] = true;
	g_bShouldAnnounceWitchDamage[witchid] = true;
}

public void OnEntityDestroyed(int entity)
{
	if( entity > 0 && IsValidEdict(entity) )
	{
		char strClassName[64];
		GetEdictClassname(entity, strClassName, sizeof(strClassName));
		if(strcmp(strClassName, "witch") == 0)	
		{
			g_bIsWitch[entity] = false;
			g_bShouldAnnounceWitchDamage[entity] = false;
		}
	}
}

void ResetPlugin()
{
	for (int i = 0; i <= MaxClients; i++)
	{
		for (int j = 1; j <= MaxClients; j++)
		{
			g_iDamage[i][j] = 0;
		}
	}
	for (int i = MaxClients + 1; i < MAXENTITIES; i++) g_bIsWitch[i] = false;
}

void ClearDmgSI(int victim)
{
	for (int i = 0; i <= MaxClients; i++)
	{
		g_iDamage[i][victim] = 0;
	}
}

public int GetEntityHealth(int client)
{
	return GetEntProp(client, Prop_Data, "m_iHealth");
}