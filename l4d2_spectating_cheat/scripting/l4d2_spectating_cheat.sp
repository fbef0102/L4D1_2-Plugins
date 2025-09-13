#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <multicolors>
#undef REQUIRE_PLUGIN
#tryinclude <attachments_api>

#define ENTITY_SAFE_LIMIT 2000 //don't create model glow when entity index is above this
#define ZC_SMOKER		1
#define ZC_BOOMER		2
#define ZC_HUNTER		3
#define ZC_SPITTER		4
#define ZC_JOCKEY		5
#define ZC_CHARGER		6

bool g_bLateLoad;
int ZC_TANK;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}
	
	ZC_TANK = 8;
	g_bLateLoad = late;
	return APLRes_Success; 
}

ConVar g_hCvarColorGhost, g_hCvarColorAlive, g_hCommandAccess, g_hDefaultValue;

int g_iCvarColorGhost, g_iCvarColorAlive;
bool g_bDefaultValue;

char g_sCommandAccesslvl[AdminFlags_TOTAL];

bool g_bMapStarted;
bool g_bSpecCheatActive[MAXPLAYERS + 1]; //spectatpr open watch
int g_iModelIndex[MAXPLAYERS+1];			// Player Model entity reference
Handle DelayWatchGlow_Timer[MAXPLAYERS+1] ; //prepare to disable player spec glow
int 
	g_iRoundStart, g_iPlayerSpawn,
	g_bInGame[MAXPLAYERS+1];


public Plugin myinfo = 
{
    name = "l4d2 specating cheat",
    author = "Harry Potter",
    description = "A spectator can now see the special infected model glows though the wall",
    version = "3.1-2024/10/30",
    url = "https://steamcommunity.com/profiles/76561198026784913"
}

public void OnPluginStart()
{
	g_hCvarColorGhost =	CreateConVar(	"l4d2_specting_cheat_ghost_color",		"255 255 255",		"Ghost SI glow color, Three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue.", FCVAR_NOTIFY);
	g_hCvarColorAlive =	CreateConVar(	"l4d2_specting_cheat_alive_color",		"255 0 0",			"Alive SI glow color, Three values between 0-255 separated by spaces. RGB Color255 - Red Green Blue.", FCVAR_NOTIFY);
	g_hCommandAccess = 	CreateConVar(	"l4d2_specting_cheat_use_command_flag", "z", 				"Players with these flags have access to use command to toggle Speatator watching cheat. (Empty = Everyone, -1: Nobody)", FCVAR_NOTIFY);
	g_hDefaultValue = 	CreateConVar(	"l4d2_specting_cheat_default_value", 	"0", 				"By default, enable Speatator watching cheat for spectators? [1-Enable/0-Disable]", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	GetCvars();
	g_hCvarColorGhost.AddChangeHook(ConVarChanged_Glow_Ghost);
	g_hCvarColorAlive.AddChangeHook(ConVarChanged_Glow_Alive);
	g_hCommandAccess.AddChangeHook(ConVarChanged_Access);
	g_hDefaultValue.AddChangeHook(ConVarChanged_Cvars);

	//Autoconfig for plugin
	AutoExecConfig(true, "l4d2_specting_cheat");

	HookEvent("round_start",            Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn", 			Event_PlayerSpawn);
	HookEvent("round_end",				Event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("map_transition", 		Event_RoundEnd, EventHookMode_PostNoCopy); //戰役模式下過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", 			Event_RoundEnd, EventHookMode_PostNoCopy); //戰役模式下滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd, EventHookMode_PostNoCopy); //救援載具離開之時  (沒有觸發round_end)
	HookEvent("tank_spawn", Event_TankSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_team",	Event_PlayerTeam);
	HookEvent("jockey_ride_end",	jockey_ride_end);

	HookEvent("player_disconnect", Event_PlayerDisconnect);
	HookEvent("tank_frustrated", OnTankFrustrated);
	
	RegConsoleCmd("sm_speccheat", ToggleSpecCheatCmd, "Toggle Speatator watching cheat");
	RegConsoleCmd("sm_watchcheat", ToggleSpecCheatCmd, "Toggle Speatator watching cheat");
	RegConsoleCmd("sm_lookcheat", ToggleSpecCheatCmd, "Toggle Speatator watching cheat");
	RegConsoleCmd("sm_seecheat", ToggleSpecCheatCmd, "Toggle Speatator watching cheat");
	RegConsoleCmd("sm_meetcheat", ToggleSpecCheatCmd, "Toggle Speatator watching cheat");
	RegConsoleCmd("sm_starecheat", ToggleSpecCheatCmd, "Toggle Speatator watching cheat");
	RegConsoleCmd("sm_hellocheat", ToggleSpecCheatCmd, "Toggle Speatator watching cheat");
	RegConsoleCmd("sm_areyoucheat", ToggleSpecCheatCmd, "Toggle Speatator watching cheat");
	RegConsoleCmd("sm_fuckyoucheat", ToggleSpecCheatCmd, "Toggle Speatator watching cheat");
	RegConsoleCmd("sm_zzz", ToggleSpecCheatCmd, "Toggle Speatator watching cheat");
	
	if(g_bLateLoad)
	{
		g_bMapStarted = true;
		CreateAllModelGlow();
	}
}

public void OnPluginEnd() //unload插件的時候
{
	RemoveAllModelGlow();
	ResetTimer();
	ClearDefault();
}

public void OnMapStart()
{
	g_bMapStarted = true;
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	ResetTimer();
	ClearDefault();
}

bool g_bFirstLoad = true;
public void OnConfigsExecuted()
{
	GetCvars();

	if(g_bFirstLoad)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			g_bSpecCheatActive[i] = g_bDefaultValue;
		}

		g_bFirstLoad = false;
	}
}

public void OnClientDisconnect(int client)
{
	RemoveInfectedModelGlow(client);
	delete DelayWatchGlow_Timer[client];

	if(IsClientInGame(client) && GetClientTeam(client) == L4D_TEAM_SURVIVOR)
	{
		// jockey正在騎的倖存者玩家如果離開遊戲, 光圈會卡住
		int jockey = GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker");
		if(jockey > 0 && IsClientInGame(jockey))
		{
			RequestFrame(OnNextFrame, GetClientUserId(jockey));
		}
	}
} 

Action ToggleSpecCheatCmd(int client, int args) 
{
	if(client == 0 || GetClientTeam(client)!= L4D_TEAM_SPECTATOR)
		return Plugin_Handled;
	
	if(!HasAccess(client, g_sCommandAccesslvl))
	{
		CPrintToChat(client, "{default}[{green}WatchMode{default}]{lightgreen} You don't have access.");
		return Plugin_Handled;
	}

	if(IsClientIdle(client))
	{
		CPrintToChat(client, "{default}[{green}WatchMode{default}]{lightgreen} You are idle.{default} Unable to use.");
		return Plugin_Handled;
	}

	if(g_bSpecCheatActive[client])
	{
		g_bSpecCheatActive[client] = false;
		CPrintToChat(client, "[{green}WatchMode{default}]{lightgreen} Watch Cheater Mode {default}is now {olive}Off{default}.");
		StopAllModelGlow();
		delete DelayWatchGlow_Timer[client];
		DelayWatchGlow_Timer[client] = CreateTimer(0.1, Timer_StopGlowTransmit, client);

		delete DelayWatchGlow_Timer[0];
		DelayWatchGlow_Timer[0] = CreateTimer(0.2, Timer_StartAllGlow);
	}
	else
	{
		g_bSpecCheatActive[client] = true;
		CPrintToChat(client, "[{green}WatchMode{default}]{lightgreen} Watch Cheater Mode {default}is now {olive}On{default}.");
	}

	return Plugin_Handled;
}

Action Timer_StopGlowTransmit(Handle timer, int client)
{
	DelayWatchGlow_Timer[client] = null;
	return Plugin_Continue;
}

Action Timer_StartAllGlow(Handle timer)
{
	StartAllModelGlow();

	DelayWatchGlow_Timer[0] = null;
	return Plugin_Continue;
}

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	g_bSpecCheatActive[client] = g_bDefaultValue;
}

//Tank玩家失去控制權，換人或變成AI
//有插件會將Tank失去控制權時不會換人重新獲得100%控制權，譬如zonemod second pass
void OnTankFrustrated(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	RemoveInfectedModelGlow(GetClientOfUserId(userid));
	RequestFrame(OnNextFrame, userid);
}

//有插件在此事件把Tank變成靈魂克的時候不會觸發後續的player_spawn事件，譬如使用confoglcompmod
void Event_TankSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	
	RemoveInfectedModelGlow(client);
	RequestFrame(OnNextFrame, userid);
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	if( g_iPlayerSpawn == 1 && g_iRoundStart == 0 )
		CreateTimer(1.2, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iRoundStart = 1;
}

Action Timer_PluginStart(Handle timer)
{
	ClearDefault();

	RemoveAllModelGlow();
	CreateAllModelGlow();

	return Plugin_Continue;
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{ 
	if( g_iPlayerSpawn == 0 && g_iRoundStart == 1 )
		CreateTimer(1.2, Timer_PluginStart, _, TIMER_FLAG_NO_MAPCHANGE);
	g_iPlayerSpawn = 1;	

	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);

	RemoveInfectedModelGlow(client); //有可能特感變成坦克復活
	RequestFrame(OnNextFrame, userid);
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{ 
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	RemoveInfectedModelGlow(client);
}

void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	int oldteam = event.GetInt("oldteam");
	
	RemoveInfectedModelGlow(client);
	
	if(client && IsClientInGame(client))
	{
		if(event.GetBool("disconnect") && IsFakeClient(client) && oldteam == 2 && HasEntProp(client, Prop_Send, "m_humanSpectatorUserID"))
		{
			int idle_player = GetClientOfUserId(GetEntProp(client, Prop_Send, "m_humanSpectatorUserID"));
			if(idle_player && IsClientInGame(idle_player))
			{
				g_bInGame[idle_player] = false;
			}
		}

		else if(!IsFakeClient(client) && g_bSpecCheatActive[client] && oldteam == L4D_TEAM_SPECTATOR)
		{
			StopAllModelGlow();
			delete DelayWatchGlow_Timer[client];
			DelayWatchGlow_Timer[client] = CreateTimer(0.1, Timer_StopGlowTransmit, client);

			delete DelayWatchGlow_Timer[0];
			DelayWatchGlow_Timer[0] = CreateTimer(0.2, Timer_StartAllGlow);
		}
		
		CreateTimer(0.1, PlayerChangeTeamCheck, userid);//延遲一秒檢查
	}
}

Action PlayerChangeTeamCheck(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);
	if (client && IsClientInGame(client) && !IsFakeClient(client))
	{
		switch(GetClientTeam(client))
		{
			case L4D_TEAM_SPECTATOR:
			{
				if(IsClientIdle(client))
				{
					g_bInGame[client] = true;
					StopAllModelGlow();
					delete DelayWatchGlow_Timer[client];
					DelayWatchGlow_Timer[client] = CreateTimer(0.1, Timer_StopGlowTransmit, client);

					delete DelayWatchGlow_Timer[0];
					DelayWatchGlow_Timer[0] = CreateTimer(0.2, Timer_StartAllGlow);
				}
				else g_bInGame[client] = false;
			}
			case L4D_TEAM_INFECTED, L4D_TEAM_SURVIVOR, L4D_TEAM_FOUR:
			{
				g_bInGame[client] = true;
			}
			default:
			{
				g_bInGame[client] = false;
			}
		}
	}

	return Plugin_Continue;
}

// jockey正在騎的倖存者bots如果被踢出遊戲, 光圈會卡住
void jockey_ride_end(Event event, const char[] name, bool dontBroadcast)
{
	RequestFrame(OnNextFrame, event.GetInt("userid"));
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	RemoveAllModelGlow();
	ResetTimer();
	ClearDefault();
}

void OnNextFrame(int userid)
{
	CreateInfectedModelGlow(GetClientOfUserId(userid));
}

void CreateInfectedModelGlow(int client)
{
	if (!client || 
	!IsClientInGame(client) || 
	GetClientTeam(client) != L4D_TEAM_INFECTED || 
	!IsPlayerAlive(client) ||
	g_bMapStarted == false) return;

	if ( IsPlayerGhost(client) && GetZombieClass(client) == ZC_TANK)
	{
		CreateTimer(0.25, Timer_CheckGhostTank, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}

	///////設定發光物件//////////
	// Spawn dynamic prop entity
	int entity = CreateEntityByName("prop_dynamic_ornament");
	
	if (CheckIfEntitySafe( entity ) == false)
		return;
		
	// Delete previous glow first just in case
	RemoveInfectedModelGlow(client);
	
	// Get Client Model
	char sModelName[64];
	GetEntPropString(client, Prop_Data, "m_ModelName", sModelName, sizeof(sModelName));
	//CPrintToChatAll("%N: %s",client,sModelName);

	// Set new fake model
	//PrecacheModel(sModelName);
	SetEntityModel(entity, sModelName);
	DispatchSpawn(entity);

	// Set outline glow color
	SetEntProp(entity, Prop_Send, "m_CollisionGroup", 0);
	SetEntProp(entity, Prop_Send, "m_nSolidType", 0);
	SetEntProp(entity, Prop_Send, "m_nGlowRange", 4500);
	SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
	if(IsPlayerGhost(client))
		SetEntProp(entity, Prop_Send, "m_glowColorOverride", g_iCvarColorGhost);
	else
		SetEntProp(entity, Prop_Send, "m_glowColorOverride", g_iCvarColorAlive);

	if(DelayWatchGlow_Timer[0] != null)
	{
		AcceptEntityInput(entity, "StopGlowing");
	}
	else
	{
		AcceptEntityInput(entity, "StartGlowing");
	}

	// Set model invisible
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 0, 0, 0, 0);
	
	// Set model attach to client, and always synchronize
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", client);
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetAttached", client);
	///////發光物件完成//////////
	
	g_iModelIndex[client] = EntIndexToEntRef(entity);
		
	//model 只能給誰看?
	SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit);
}

void RemoveInfectedModelGlow(int client)
{
	int entity = g_iModelIndex[client];
	g_iModelIndex[client] = 0;

	if( IsValidEntRef(entity) )
		AcceptEntityInput(entity, "kill");
}

Action Hook_SetTransmit(int entity, int client)
{
	if(DelayWatchGlow_Timer[client] != null) return Plugin_Continue;

	if( g_bSpecCheatActive[client] && !g_bInGame[client] && GetClientTeam(client) == L4D_TEAM_SPECTATOR)
	{
	 	return Plugin_Continue;
	}
	
	return Plugin_Handled;
}

int GetColor(char[] sTemp)
{
	if( StrEqual(sTemp, "") )
		return 0;

	char sColors[3][4];
	int color = ExplodeString(sTemp, " ", sColors, 3, 4);

	if( color != 3 )
		return 0;

	color = StringToInt(sColors[0]);
	color += 256 * StringToInt(sColors[1]);
	color += 65536 * StringToInt(sColors[2]);

	return color;
}

void ConVarChanged_Glow_Ghost(Handle convar, const char[] oldValue, const char[] newValue) {
	GetCvars();

	int entity;
	for(int i=1; i<=MaxClients ; ++i)
	{
		if(IsClientInGame(i) && GetClientTeam(i)==L4D_TEAM_INFECTED && IsPlayerGhost(i))
		{
			entity = g_iModelIndex[i];
			if( entity && (entity = EntRefToEntIndex(entity)) != INVALID_ENT_REFERENCE )
			{
				SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
				SetEntProp(entity, Prop_Send, "m_glowColorOverride", g_iCvarColorGhost);
			}
		}
	}
}

void ConVarChanged_Glow_Alive(Handle convar, const char[] oldValue, const char[] newValue) {
	GetCvars();
	
	int entity;
	for(int i=1; i<=MaxClients ; ++i)
	{
		if(IsClientInGame(i) && GetClientTeam(i)==L4D_TEAM_INFECTED && IsPlayerAlive(i) && !IsPlayerGhost(i))
		{
			entity = g_iModelIndex[i];
			if( entity && (entity = EntRefToEntIndex(entity)) != INVALID_ENT_REFERENCE )
			{
				SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
				SetEntProp(entity, Prop_Send, "m_glowColorOverride", g_iCvarColorAlive);
			}
		}
	}
}

void ConVarChanged_Access(Handle convar, const char[] oldValue, const char[] newValue) {
	GetCvars();

	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			if(HasAccess(i, g_sCommandAccesslvl) == false) g_bSpecCheatActive[i] = false;
			
			
			RemoveAllModelGlow();
			CreateAllModelGlow();
		}
	}
}

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue) {
	GetCvars();
}

void GetCvars()
{
	char sColor[16],sColor2[16];
	g_hCvarColorGhost.GetString(sColor, sizeof(sColor));
	g_iCvarColorGhost = GetColor(sColor);
	g_hCvarColorAlive.GetString(sColor2, sizeof(sColor2));
	g_iCvarColorAlive = GetColor(sColor2);
	g_hCommandAccess.GetString(g_sCommandAccesslvl,sizeof(g_sCommandAccesslvl));
	g_bDefaultValue = g_hDefaultValue.BoolValue;
}

bool IsPlayerGhost(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isGhost"));
}

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE)
		return true;
	return false;
}

void RemoveAllModelGlow()
{
	for (int i = 1; i <= MaxClients; i++) 
	{
		RemoveInfectedModelGlow(i);
	}
}

void CreateAllModelGlow()
{
	if (g_bMapStarted == false) return;
	
	for (int client = 1; client <= MaxClients; client++) 
	{
		if(!IsClientInGame(client)) continue;

		RequestFrame(OnNextFrame, GetClientUserId(client));
	}
}

Action Timer_CheckGhostTank(Handle timer, int userid)
{
	int tank = GetClientOfUserId(userid);
	
	CreateInfectedModelGlow(tank);

	return Plugin_Continue;
}

void StopAllModelGlow()
{
	int glow;
	for (int i = 1; i <= MaxClients; i++) 
	{
		glow = g_iModelIndex[i];
		if( IsValidEntRef(glow) )
		{
			AcceptEntityInput(glow, "StopGlowing");
		}
	}
}

void StartAllModelGlow()
{
	int glow;
	for (int i = 1; i <= MaxClients; i++) 
	{
		glow = g_iModelIndex[i];
		if( IsValidEntRef(glow) )
		{
			AcceptEntityInput(glow, "StartGlowing");
		}
	}
}

bool CheckIfEntitySafe(int entity)
{
	if(entity == -1) return false;

	if(	entity > ENTITY_SAFE_LIMIT)
	{
		AcceptEntityInput(entity, "Kill");
		return false;
	}
	return true;
}

bool HasAccess(int client, char[] sAcclvl)
{
	// no permissions set
	if (strlen(sAcclvl) == 0)
		return true;

	else if (StrEqual(sAcclvl, "-1"))
		return false;

	// check permissions
	int userFlags = GetUserFlagBits(client);
	if ( (userFlags & ReadFlagString(sAcclvl)) || (userFlags & ADMFLAG_ROOT))
	{
		return true;
	}

	return false;
}

int GetZombieClass(int client) 
{
	return GetEntProp(client, Prop_Send, "m_zombieClass");
}

void ResetTimer()
{
	for (int i = 0; i <= MaxClients; i++)
	{
		delete DelayWatchGlow_Timer[i];
	}
}

void ClearDefault()
{
	g_iRoundStart = 0;
	g_iPlayerSpawn = 0;
}

bool IsClientIdle(int client)
{
	if(GetClientTeam(client) != L4D_TEAM_SPECTATOR)
		return false;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == L4D_TEAM_SURVIVOR && IsPlayerAlive(i))
		{
			if(HasEntProp(i, Prop_Send, "m_humanSpectatorUserID"))
			{
				if(GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID")) == client)
						return true;
			}
		}
	}
	return false;
}

//-------------------------------Left4Dhooks API Forward-------------------------------

public void L4D_OnEnterGhostState(int client)
{
	RequestFrame(OnNextFrame, GetClientUserId(client));
}

//-------------------------------Attachments API-------------------------------

public void Attachments_OnModelChanged(int client)
{
	RequestFrame(OnNextFrame, GetClientUserId(client));
}