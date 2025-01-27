#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>

#define PLUGIN_VERSION "2.6-2025/1/27"

public Plugin myinfo = 
{
	name = "L4D1/2 Assistance System",
	author = "[E]c & Max Chu & ViRaGisTe & HarryPotter",
	description = "Show assists made by survivors",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=123811"
}

bool bLate, g_bL4D2Version;
int ZC_TANK;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test == Engine_Left4Dead )
	{
		g_bL4D2Version = false;
		ZC_TANK = 5;
	}
	else if( test == Engine_Left4Dead2 )
	{
		g_bL4D2Version = true;
		ZC_TANK = 8;
	}
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	
	bLate = late;
	return APLRes_Success; 
}

#define L4D_TEAM_SURVIVOR 2
#define L4D_TEAM_INFECTED 3

#define ZC_SMOKER		1

#define MAXENTITIES 2048
#define CVAR_FLAGS			FCVAR_NOTIFY

ConVar g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, 
	g_hCvarInfectedFlag, g_hCvarDisplayNum;
ConVar g_hCvarMPGameMode;
int g_iCvarInfectedFlag, g_iCvarDisplayNum;


char Temp2[] = ", ";
char Temp3[] = "(";
char Temp4[] = ")";
char Temp5[] = "\x05";
char Temp6[] = "\x01";
int 
	g_iDamage[MAXPLAYERS+1][MAXPLAYERS+1], //Used to temporarily store dmg to S.I.
	g_iSIHealth[MAXPLAYERS+1], //S.I last hp before damage hurt
	g_iOtherDamage[MAXPLAYERS+1]; //S.I other damage

bool g_bTankDied[MAXPLAYERS+1], //tank already dead
	g_bReplaceNewTank[MAXPLAYERS+1], //tank was replaced
	g_bSmokerTakeDamageAlive[MAXPLAYERS+1]; //smoker OnTakeDamageAlive

public void OnPluginStart()
{
	LoadTranslations("l4d2_assist.phrases");
	
	g_hCvarAllow = 			CreateConVar(	"sm_assist_enable", 		"1", 			"If 1, Enables this plugin.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarModes =			CreateConVar(	"sm_assist_modes",			"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =		CreateConVar(	"sm_assist_modes_off",		"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =		CreateConVar(	"sm_assist_modes_tog",		"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	if(g_bL4D2Version)
		g_hCvarInfectedFlag = 	CreateConVar(	"sm_assist_infected_flag", 	"127", 		"Which zombie class should report damage on death, 0=None, 1=Smoker, =Boomer, 4=Hunter, 8=Spitter, 16=Jockey, 32=Charger, 64=Tank. Add numbers together.",CVAR_FLAGS, true, 0.0, true, 127.0);
	else
		g_hCvarInfectedFlag = 	CreateConVar(	"sm_assist_infected_flag", 	"15", 		"Which zombie class should report damage on death, 0=None, 1=Smoker, 2=Boomer, 4=Hunter, 8=Tank. Add numbers together.",CVAR_FLAGS, true, 0.0, true, 15.0);
	g_hCvarDisplayNum 	= 		CreateConVar(	"sm_assist_display_num", 	"2", 		"How many players displayed on assist message each line", CVAR_FLAGS, true, 1.0);
	AutoExecConfig(true, "l4d2_assist");


	g_hCvarMPGameMode 	= FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarInfectedFlag.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDisplayNum.AddChangeHook(ConVarChanged_Cvars);

	if(bLate)
	{
		LateLoad();
	}
}

void LateLoad()
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
            continue;

        OnClientPutInServer(client);
    }
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

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
}

Action OnTakeDamageAlive(int client, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{ 
	if(GetClientTeam(client) == L4D_TEAM_INFECTED && IsPlayerAlive(client))
	{
		int class = GetEntProp(client, Prop_Send, "m_zombieClass");
		int health = GetEntProp(client, Prop_Data, "m_iHealth");
		//PrintToChatAll("client: %d, attacker: %d, health: %d, last health: %d", client, attacker, health, g_iSIHealth[client] );
		if(class == ZC_TANK)
		{
			// Tank死亡動畫時, 為倒地狀態
			if(GetEntProp(client, Prop_Send, "m_isIncapacitated")) return Plugin_Continue;
		}
		else if(class == ZC_SMOKER)
		{

			//AI Smoker拉人時被打超過50 (tongue_break_from_damage_amount) 會有二次傷害
			//OnTakeDamageAlive -> OnTakeDamageAlive(第二次) -> player_hurt -> player_death -> player_hurt
			if(g_bSmokerTakeDamageAlive[client])
			{
				//PrintToChatAll("Same Frame");
				//Smoker拉人時被打死會有負數血量
				if(health < 0) health = 0;

				g_iDamage[attacker][client] += g_iSIHealth[client] - health;
			}
			else
			{
				g_bSmokerTakeDamageAlive[client] = true;
			}
		}

		g_iSIHealth[client] = health;
	}

	return Plugin_Continue;
}

public void OnConfigsExecuted()
{
	IsAllowed();
}

void ConVarChanged_Allow(Handle convar, const char[] oldValue, const char[] newValue)
{
	IsAllowed();
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iCvarInfectedFlag = g_hCvarInfectedFlag.IntValue;
	g_iCvarDisplayNum = g_hCvarDisplayNum.IntValue;
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

void OnGamemode(const char[] output, int caller, int activator, float delay)
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
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
	HookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("player_bot_replace", 	Event_BotReplacePlayer);
	HookEvent("bot_player_replace",     Event_PlayerReplaceBot);
}

void UnhookEvents()
{
	UnhookEvent("player_hurt", Event_PlayerHurt);
	UnhookEvent("player_spawn", Event_PlayerSpawn);
	UnhookEvent("player_death", Event_PlayerDeath);
	UnhookEvent("round_end",				Event_RoundEnd,		EventHookMode_PostNoCopy);
	UnhookEvent("map_transition", 		Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (沒有觸發round_end)
	UnhookEvent("mission_lost", 			Event_RoundEnd,		EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	UnhookEvent("finale_vehicle_leaving", Event_RoundEnd,		EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
	UnhookEvent("player_bot_replace", 	Event_BotReplacePlayer);
	UnhookEvent("bot_player_replace",     Event_PlayerReplaceBot);
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	ResetPlugin();
}

void Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) 
{
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int damageDone = g_iSIHealth[victim] - event.GetInt("health");
	if(damageDone <= 0) return;
	
	if (0 < victim && victim <= MaxClients && IsClientInGame(victim) && GetClientTeam(victim) == L4D_TEAM_INFECTED)
	{
		if (GetEntProp(victim, Prop_Send, "m_zombieClass") == ZC_TANK)
		{
			if( g_bTankDied[victim] || g_iSIHealth[victim] - damageDone < 0) //坦克死亡動畫或是散彈槍重複計算
			{
				return;
			}
			
			if( GetEntProp(victim, Prop_Send, "m_isIncapacitated") ) //坦克死掉播放動畫，即使是玩家造成傷害，attacker還是0
			{
				g_bTankDied[victim] = true;
				return;
			}

			g_iSIHealth[victim] = event.GetInt("health");
			
			if( 0 < attacker <= MaxClients && IsClientInGame(attacker))
			{
				//PrintToChatAll("g_iSIHealth[victim]: %d, damageDone: %d, g_bTankDied[victim]: %d", g_iSIHealth[victim], damageDone, g_bTankDied[victim]);
				g_iDamage[attacker][victim] += damageDone;
			}
			else
			{
				static char weapon[64];
				event.GetString("weapon", weapon, sizeof(weapon));
				if( g_bTankDied[victim] && strlen(weapon) == 0 ) return;

				//PrintToChatAll("Tank: %d - type: %d, weapon: %s", victim, event.GetInt("type"), weapon);
				g_iOtherDamage[victim] += damageDone;
			}
		}
		else
		{
			g_bSmokerTakeDamageAlive[victim] = false;

			//PrintToChatAll("g_iSIHealth[victim]: %d, damageDone: %d", g_iSIHealth[victim], damageDone);
			if( g_iSIHealth[victim] - damageDone <= 0) //超過最後血量
			{
				damageDone = g_iSIHealth[victim];
			}

			g_iSIHealth[victim] = event.GetInt("health");

			if( 0 < attacker <= MaxClients && IsClientInGame(attacker))
			{
				g_iDamage[attacker][victim] += damageDone;
			}
			else
			{
				g_iOtherDamage[victim] += damageDone;
			}
		}
	}
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
	int client = GetClientOfUserId(event.GetInt("userid"));
		
	if(client && IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_INFECTED)
	{
		if(g_bReplaceNewTank[client]) return;

		g_bTankDied[client] = false;
		g_iSIHealth[client] = GetEntProp(client, Prop_Data, "m_iHealth");
		for( int i = 1; i <= MaxClients; i++ ) g_iDamage[i][client] = 0;
		g_iOtherDamage[client] = 0;
	}
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	//PrintToChatAll("Event_PlayerDeath: %d %d", attacker, victim);
	
	if(!victim || !IsClientInGame(victim) || GetClientTeam(victim) != L4D_TEAM_INFECTED) return;

	if (attacker && IsClientInGame(attacker))
	{
		if(GetEntProp(victim, Prop_Send, "m_zombieClass") == ZC_TANK)
		{
			g_iDamage[attacker][victim] += g_iSIHealth[victim];
		}
		else
		{
			g_iDamage[attacker][victim] += g_iSIHealth[victim];
		}

		if (GetClientTeam(attacker) == L4D_TEAM_SURVIVOR)
		{
			int class = GetEntProp(victim, Prop_Send, "m_zombieClass");
			if( (g_bL4D2Version && class == ZC_TANK) || (!g_bL4D2Version && class == ZC_TANK))  // tank
			{
				--class;
			}	

			if( class <= 0 || class > 7 || !((1 << (class-1)) & g_iCvarInfectedFlag) )
			{
				ClearDmgSI(victim);
				return;
			}
			
			char MsgAssist[512];
			bool start = true, firstline = true;
			char sName[MAX_NAME_LENGTH], sTempMessage[64];
			int count;

			CPrintToChatAll("%t", "Got_Killed_By", victim, attacker, g_iDamage[attacker][victim]);
			bool next = false;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (i != attacker && IsClientInGame(i) && GetClientTeam(i) == L4D_TEAM_SURVIVOR && g_iDamage[i][victim] > 0)
				{
					count++;
					
					if(start == false && count >= 2)
						StrCat(MsgAssist, sizeof(MsgAssist), Temp2);
					
					GetClientName(i, sName, sizeof(sName));
					FormatEx(sTempMessage, sizeof(sTempMessage), "%s%s%s %s%i %T%s", Temp5,sName,Temp6,Temp3,g_iDamage[i][victim],"DMG", LANG_SERVER, Temp4);
					StrCat(MsgAssist, sizeof(MsgAssist), sTempMessage);
					start = false;

					if(count % g_iCvarDisplayNum == 0)
					{
						FormatEx(MsgAssist, sizeof(MsgAssist), "%s", MsgAssist);
						next = false;
						for(int j = i+1; j <= MaxClients; j++)
						{
							if (j != attacker && IsClientInGame(j) && GetClientTeam(j) == L4D_TEAM_SURVIVOR && g_iDamage[j][victim] > 0)
							{
								next = true;
								break;
							}
						}

						if(firstline)
						{
							if(next)
							{
								CPrintToChatAll("{olive}{default} %t,", "Assist", MsgAssist);
							}
							else
							{
								CPrintToChatAll("{olive}{default} %t.", "Assist", MsgAssist);
							}
							firstline = false;
						}
						else
						{
							if(next)
							{
								CPrintToChatAll("{olive}{default} %s,", MsgAssist);
							}
							else
							{
								CPrintToChatAll("{olive}{default} %s.", MsgAssist);
							}
						}

						MsgAssist[0] = '\0';
						count = 0;
					}
				}
			}

			if(count > 0)
			{
				if(firstline)
				{
					CPrintToChatAll("{olive}{default} %t.", "Assist", MsgAssist);
				}
				else
				{
					CPrintToChatAll("{olive}{default} %s.", MsgAssist);
				}
			}
		}
	}
	else
	{
		g_iOtherDamage[victim] += g_iSIHealth[victim];
	}

	ClearDmgSI(victim);
}

void Event_BotReplacePlayer(Event event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(event.GetInt("bot"));
	int player = GetClientOfUserId(event.GetInt("player"));

	if (bot > 0 && bot <= MaxClients && IsClientInGame(bot) && GetClientTeam(bot) == L4D_TEAM_INFECTED && GetEntProp(bot, Prop_Send, "m_zombieClass") == ZC_TANK 
		&& player > 0 && player <= MaxClients && IsClientInGame(player)) 
	{
		ReplaceData(player, bot);
	}
}

void Event_PlayerReplaceBot(Event event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(event.GetInt("bot"));
	int player = GetClientOfUserId(event.GetInt("player"));
	
	if (bot > 0 && bot <= MaxClients && IsClientInGame(bot) 
		&& player > 0 && player <= MaxClients && IsClientInGame(player) && GetClientTeam(player) == L4D_TEAM_INFECTED && GetEntProp(player, Prop_Send, "m_zombieClass") == ZC_TANK) 
	{
		ReplaceData(bot, player);
	}
}

public void L4D_OnReplaceTank(int tank, int newtank)
{
	g_bReplaceNewTank[newtank] = true;
	RequestFrame(NextFrame_ReplaceData, newtank);
	
	if(tank == newtank)
	{
		return;
	}

	ReplaceData(tank, newtank);
}

void ReplaceData(int tank, int newtank)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		g_iDamage[i][newtank] = g_iDamage[i][tank]; g_iDamage[i][tank] = 0;
	}

	g_bTankDied[newtank] = g_bTankDied[tank]; g_bTankDied[tank] = false;
	g_iSIHealth[newtank] = g_iSIHealth[tank]; g_iSIHealth[tank] = 0;
	g_iOtherDamage[newtank] = g_iOtherDamage[tank]; g_iOtherDamage[tank] = 0;
}

void NextFrame_ReplaceData(int client)
{
	g_bReplaceNewTank[client] = false;
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
}

void ClearDmgSI(int victim)
{
	for (int i = 0; i <= MaxClients; i++)
	{
		g_iDamage[i][victim] = 0;
	}
}
