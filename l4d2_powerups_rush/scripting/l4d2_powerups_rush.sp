#define PLUGIN_VERSION "1.0h-2023/7/5"
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>
//Set this value to 1 to enable debugging
#define DEBUG 0

//Used to track who has the weapon firing.
//Index goes up to 18, but each index has a value indicating a client index with
//DT so the plugin doesn't have to cycle a full 18 times per game frame
int g_iDTRegisterIndex[64] = {-1};
//and this tracks how many have DT
int g_iDTRegisterCount = 0;
//this tracks the current active 'weapon id' in case the player changes guns
int g_iDTEntid[64] = {-1};
//this tracks the engine time of the next attack for the weapon, after modification
//(modified interval + engine time)
float g_flDTNextTime[64] = {-1.0};

//similar to Double Tap
int g_iMARegisterIndex[64] = {-1};
//and this tracks how many have MA
int g_iMARegisterCount = 0;
//these are similar to those used by Double Tap
float g_flMANextTime[64] = {-1.0};
int g_iMAEntid[64] = {-1};
int g_iMAEntid_notmelee[64] = {-1};
//this tracks the attack count, similar to twinSF
int g_iMAAttCount[64] = {-1};

//Rates of the attacks
ConVar g_hDT_rate;
float g_flDT_rate;
ConVar g_h_reload_rate;
float g_fl_reload_rate;
/*float melee_speed[MAXPLAYERS+1];*/
ConVar g_h_melee_rate;
float g_flDT_melee;
//Make sure we stop activity on map changes or we can get disconnects
bool g_bIsLoading;

//This keeps track of the default values for reload speeds for the different shotgun types
//NOTE: I got these values from tPoncho's own source
//NOTE: Pump and Chrome have identical values
const float g_fl_AutoS = 0.4;
const float g_fl_AutoI = 0.4;
const float g_fl_AutoE = 0.4;
const float g_fl_SpasS = 0.4;
const float g_fl_SpasI = 0.4;
const float g_fl_SpasE = 0.4;
const float g_fl_PumpS = 0.4;
const float g_fl_PumpI = 0.4;
const float g_fl_PumpE = 0.4;

// from Killing Adrenaline by NoroHime (https://forums.alliedmods.net/showthread.php?p=2770300)
forward Action OnAdrenalineGiven(int client, float duration);

//tracks if the game is L4D 2 (Support for L4D1 pending...)
bool g_bL4D2Version;

//offsets
int g_iNextPAttO		= -1;
int g_iActiveWO			= -1;
int g_iShotStartDurO	= -1;
int g_iShotInsertDurO	= -1;
int g_iShotEndDurO		= -1;
int g_iPlayRateO		= -1;
int g_iShotRelStateO	= -1;
int g_iNextAttO			= -1;
int g_iTimeIdleO		= -1;
int g_iVMStartTimeO		= -1;
int g_iViewModelO		= -1;
int g_iNextSAttO		= -1;
int g_ActiveWeaponOffset;

//tracks if the client has used an adrenaline (or pills) for that duration
int g_usedhealth[MAXPLAYERS + 1] = {0};

//Timer definitions
Handle WelcomeTimers[MAXPLAYERS + 1];
Handle g_powerups_countdown[MAXPLAYERS + 1];
Handle PlayerLeftStartTimer;
float g_powerups_timeleft[MAXPLAYERS + 1];

//Enables and Disables
ConVar powerups_plugin_on;
ConVar powerups_broadcast_type;
ConVar adren_give_on;
ConVar pills_give_on;
ConVar random_give_on;
//Numbers
ConVar powerups_duration, powerups_notify_type, powerups_timer_type, powerups_adrenaline_effect;
ConVar pills_luck;

public Plugin myinfo = 
{
	name = "[L4D2] PowerUps rush",
	author = "Dusty1029 (a.k.a. {L.2.K} LOL) & HarryPotter",
	description = "When a client pops an adrenaline (or pills), various actions are perform faster (reload, melee swings, firing rates)",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=127513"
}

bool bLate;
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
	
	bLate = late;
	return APLRes_Success; 
}

#define TRANSLATION_FILE		"l4d2_powerups_rush.phrases"

float fGameTimeSave[MAXPLAYERS+1];
ConVar hCvar_AnimSpeed;

bool g_powerups_plugin_on;
float fAnimSpeed = 2.0;
float fTickRate;


public void OnPluginStart()
{
	LoadTranslations(TRANSLATION_FILE);

	//ConVars
	RegAdminCmd("sm_giveadren", Command_GiveAdrenaline, ADMFLAG_CHEATS, "Gives Adrenaline to all Survivors.");
	RegAdminCmd("sm_givepills", Command_GivePills, ADMFLAG_CHEATS, "Give Pills to all Survivors.");
	RegAdminCmd("sm_giverandom", Command_GiveRandom, ADMFLAG_CHEATS, "Give Random item (Adrenaline or Pills) to all Survivors.");
	powerups_plugin_on = CreateConVar("l4d_powerups_plugin_on", "1", "If 1, enable this plugin ? (0 = Disable)", FCVAR_SPONLY, true, 0.0, true, 1.0);
	powerups_broadcast_type = CreateConVar("l4d_powerups_broadcast_type", "1", "How are players notified when connecting to server about the powerups? (0: Disable, 1:In chat, 2: In Hint Box, 3: Chat/Hint Both)", FCVAR_SPONLY, true, 0.0, true, 3.0);
	adren_give_on = CreateConVar("l4d_powerups_adren_give_on", "0", "If 1, players will be given adrenaline when leaving saferoom? (0 = OFF)", FCVAR_SPONLY, true, 0.0, true, 1.0);
	pills_give_on = CreateConVar("l4d_powerups_pills_give_on", "0", "If 1, players will be given pills when leaving saferoom? (0 = OFF)", FCVAR_SPONLY, true, 0.0, true, 1.0);
	random_give_on = CreateConVar("l4d_powerups_random_give_on", "0", "If 1, players will be given either adrenaline or pills when leaving saferoom? (0 = OFF)", FCVAR_SPONLY, true, 0.0, true, 1.0);
	powerups_duration = CreateConVar("l4d_powerups_duration", "20", "How long should the duration of the boosts last?", FCVAR_NOTIFY, true, 1.0);
	powerups_notify_type = CreateConVar("l4d_powerups_notify_type", "1", "Changes how activation hint and deactivation hint display. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	powerups_timer_type = CreateConVar("l4d_powerups_coutdown_type", "2", "Changes how countdown timer hint display. (0: Disable, 1:In chat, 2: In Hint Box, 3: In center text)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	if(g_bL4D2Version) powerups_adrenaline_effect = CreateConVar("l4d_powerups_add_adrenaline_effect", "1", "(L4D2) If 1, set adrenaline effect time same as l4d_powerups_duration (Progress bar faster, such as use kits faster, save teammates faster... etc)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	pills_luck = CreateConVar("l4d_powerups_pills_luck", "3", "The luckey change for pills that will grant the boost. (0=Off, 1 = 1/1  2 = 1/2  3 = 1/3  4 = 1/4  etc.)", FCVAR_NOTIFY, true, 0.0);
	
	g_h_reload_rate = CreateConVar("l4d_powerups_weaponreload_rate", "0.5714", "The interval incurred by reloading is multiplied by this value (clamped between 0.2 ~ 0.9)", FCVAR_NOTIFY, true, 0.2, true, 0.9);
	g_h_melee_rate = CreateConVar("l4d_powerups_weaponmelee_rate", "0.45", "The interval for swinging melee weapon (clamped between 0.3 ~ 0.9)", FCVAR_NOTIFY, true, 0.3, true, 0.9);
	g_hDT_rate = CreateConVar("l4d_powerups_weaponfiring_rate", "0.7", "The interval between bullets fired is multiplied by this value. WARNING: a short enough interval will make SMGs' and rifles' firing accuracy distorted (clamped between 0.02 ~ 0.9)" , FCVAR_NOTIFY, true, 0.02, true, 0.9);
	hCvar_AnimSpeed = CreateConVar("l4d_powerups_animspeed", "2.0", "(1.0 = Minspeed(Default speed) 2.0 = 2x speed of recovery", FCVAR_NOTIFY, true, 1.0, true, 100.0);
	
	CvarsChanged();
	powerups_plugin_on.AddChangeHook(Convar_Cvars);
	g_h_reload_rate.AddChangeHook(Convar_Cvars);
	g_h_melee_rate.AddChangeHook(Convar_Cvars);
	g_hDT_rate.AddChangeHook(Convar_Cvars);
	hCvar_AnimSpeed.AddChangeHook(Convar_Cvars);

	HookAll();

	//Event Hooks
	HookEvent("weapon_reload", Event_Reload);
	HookEvent("adrenaline_used", Event_AdrenalineUsed);
	HookEvent("pills_used", Event_PillsUsed);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("map_transition", Event_RoundEnd); //戰役過關到下一關的時候 (沒有觸發round_end)
	HookEvent("mission_lost", Event_RoundEnd); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", Event_RoundEnd); //救援載具離開之時  (沒有觸發round_end)
	
	//get offsets
	g_iNextPAttO		=	FindSendPropInfo("CBaseCombatWeapon","m_flNextPrimaryAttack");
	g_iActiveWO			=	FindSendPropInfo("CBaseCombatCharacter","m_hActiveWeapon");
	g_iShotStartDurO	=	FindSendPropInfo("CBaseShotgun","m_reloadStartDuration");
	g_iShotInsertDurO	=	FindSendPropInfo("CBaseShotgun","m_reloadInsertDuration");
	g_iShotEndDurO		=	FindSendPropInfo("CBaseShotgun","m_reloadEndDuration");
	g_iPlayRateO		=	FindSendPropInfo("CBaseCombatWeapon","m_flPlaybackRate");
	g_iShotRelStateO	=	FindSendPropInfo("CBaseShotgun","m_reloadState");
	g_iNextAttO			=	FindSendPropInfo("CTerrorPlayer","m_flNextAttack");
	g_iTimeIdleO		=	FindSendPropInfo("CTerrorGun","m_flTimeWeaponIdle");
	g_iVMStartTimeO		=	FindSendPropInfo("CTerrorViewModel","m_flLayerStartTime");
	g_iViewModelO		=	FindSendPropInfo("CTerrorPlayer","m_hViewModel");
	
	g_ActiveWeaponOffset = FindSendPropInfo("CBasePlayer", "m_hActiveWeapon");
	g_iNextSAttO		=	FindSendPropInfo("CBaseCombatWeapon","m_flNextSecondaryAttack");
	
	g_bIsLoading = true;
	
	//Execute or create cfg
	AutoExecConfig(true, "l4d2_powerups_rush");
	
	if (bLate)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				OnClientPutInServer(i);
			}
		}
	}
}

public void OnPluginEnd()
{
	UnHookAll();
	ResetTimer();
}


void Convar_Cvars (ConVar convar, const char[] oldValue, const char[] newValue)
{
	CvarsChanged();
}

void CvarsChanged()
{
	g_powerups_plugin_on = powerups_plugin_on.BoolValue;
	g_fl_reload_rate = g_h_reload_rate.FloatValue;
	g_flDT_melee = g_h_melee_rate.FloatValue;
	g_flDT_rate = g_hDT_rate.FloatValue;
	fAnimSpeed = hCvar_AnimSpeed.FloatValue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PostThinkPost, hOnPostThinkPost);
	
	g_usedhealth[client] = 0;
	if (!IsFakeClient(client))
	{
		delete WelcomeTimers[client];
		WelcomeTimers[client] = CreateTimer(5.0, Timer_Notify, client);
	}
}

public void OnClientDisconnect(int client)
{
	delete g_powerups_countdown[client];
	delete WelcomeTimers[client];
	g_usedhealth[client] = 0;
	
	if (g_powerups_plugin_on == true)
	{
		RebuildAll();
	}
}

Action Timer_Notify(Handle Timer, any client)
{
	if (g_powerups_plugin_on && IsInGame(client))
	{
		switch(powerups_broadcast_type.IntValue)
		{
			case 0: {/*nothing*/}
			case 1: CPrintToChat(client, "%T", "broadcast (C)", client);
			case 2: PrintHintText(client, "%T", "broadcast", client);
			case 3: 
			{
				CPrintToChat(client, "broadcast (C)", client);
				PrintHintText(client, "%T", "broadcast", client);
			}
		}
	}
	WelcomeTimers[client] = null;
	return Plugin_Continue;
}

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( !client ) return;
	
	delete g_powerups_countdown[client];
	delete WelcomeTimers[client];
	g_usedhealth[client] = 0;
}

void Event_PlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if( !client ) return;
	
	delete g_powerups_countdown[client];
	delete WelcomeTimers[client];
	g_usedhealth[client] = 0;
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for(int i = 1; i <= MaxClients; i++)
		fGameTimeSave[i] = 0.0;

	g_bIsLoading = false;
	ClearAll();

	delete PlayerLeftStartTimer;
	PlayerLeftStartTimer = CreateTimer(1.0, Timer_PlayerLeftStart, _, TIMER_REPEAT);
}

Action Timer_PlayerLeftStart(Handle Timer)
{
	if (L4D_HasAnySurvivorLeftSafeArea())
	{
		CreateTimer(0.1, Timer_GiveAdrenaline);
		CreateTimer(0.2, Timer_GivePills);
		CreateTimer(0.3, Timer_GiveRandom);
		
		PlayerLeftStartTimer = null;
		return Plugin_Stop;
	}

	return Plugin_Continue; 
}

Action Timer_GiveAdrenaline(Handle timer)
{
	if (g_powerups_plugin_on)
	{
		if (adren_give_on.IntValue == 1)
		{
			GiveAdrenalineToAll();
		}
	}

	return Plugin_Continue;
}

Action Command_GiveAdrenaline(int client, int args)
{
	GiveAdrenalineToAll();
	return Plugin_Handled;
}

void GiveAdrenalineToAll()
{
	int flags = GetCommandFlags("give");	
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2)
		{
			FakeClientCommand(i, "give adrenaline");
			CPrintToChat(i, "%T", "Grabbin Adrenaline", i);
		}
	}
	SetCommandFlags("give", flags|FCVAR_CHEAT);
}
// ////////////////////////////////////////////////////////////////////////////
Action Timer_GivePills(Handle timer)
{
	if (g_powerups_plugin_on)
	{
		if (pills_give_on.IntValue == 1)
		{
			GivePillsToAll();
		}
	}

	return Plugin_Continue;
}

Action Command_GivePills(int client, int args)
{
	GivePillsToAll();
	return Plugin_Handled;
}

void GivePillsToAll()
{
	int flags = GetCommandFlags("give");	
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2)
		{
			FakeClientCommand(i, "give pain_pills");
			CPrintToChat(i, "%T", "Grabbin Pill", i);
		}
	}
	SetCommandFlags("give", flags|FCVAR_CHEAT);
}
// ////////////////////////////////////////////////////////////////////////////
Action Timer_GiveRandom(Handle timer)
{
	if (g_powerups_plugin_on)
	{
		if (random_give_on.IntValue == 1)
		{
			GiveRandomToAll();
		}
	}

	return Plugin_Continue;
}

Action Command_GiveRandom(int client, int args)
{
	GiveRandomToAll();
	return Plugin_Handled;
}

void GiveRandomToAll()
{
	int flags = GetCommandFlags("give");	
	SetCommandFlags("give", flags & ~FCVAR_CHEAT);	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2)
		{
			int luck = GetRandomInt(1, 2);
			if (luck == 1)
			{
				FakeClientCommand(i, "give adrenaline");
				CPrintToChat(i, "%T", "Grabbin Adrenaline", i);
			}
			if (luck == 2)
			{
				FakeClientCommand(i, "give pain_pills");
				CPrintToChat(i, "%T", "Grabbin Pill", i);
			}
		}
	}
	SetCommandFlags("give", flags|FCVAR_CHEAT);
}

//Popping the Adrenaline
void Event_AdrenalineUsed (Event event, const char[] name, bool dontBroadcast)
{
	if (g_powerups_plugin_on)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if (client == 0 || !IsClientInGame(client)) return;

		if (GetClientTeam(client) == 2)
		{
			//We need to reset the timer in case the client decides to
			//use a second adrenaline while the first one is still active
			delete g_powerups_countdown[client];
			#if DEBUG
				CPrintToChat(client, "{green}[DEBUG] {lightgreen}Resetting powerups timers");
			#endif
			g_usedhealth[client] = 0;
			
			switch(powerups_notify_type.IntValue)
			{
				case 0: {/*nothing*/}
				case 1: {CPrintToChat(client, "%T", "notify (C)", client);}
				case 2: {PrintHintText(client, "%T", "notify", client);}
				case 3: {PrintCenterText(client, "%T", "notify", client);}
			}
			
			g_powerups_timeleft[client] = powerups_duration.FloatValue;
			g_usedhealth[client] = 1;
			RebuildAll();

			g_powerups_countdown[client] = CreateTimer(1.0, Timer_Countdown, client, TIMER_REPEAT);
			//Multiply by 1.0 to prevent tag mismatch
		}
	}
}

//Popping the Pills
void Event_PillsUsed (Event event, const char[] name, bool dontBroadcast)
{
	if (g_powerups_plugin_on && pills_luck.IntValue != 0)
	{
		int client = GetClientOfUserId(event.GetInt("subject"));
		if (client == 0 || !IsClientInGame(client)) return;
		
		if (GetClientTeam(client) == 2)
		{
			int luck = GetRandomInt(1, pills_luck.IntValue);
			if (luck == 1)
			{
				//We need to reset the timer in case the client decides to use
				//a second bottle of pills while the first one is still active
				delete g_powerups_countdown[client];
				#if DEBUG
				CPrintToChat(client, "{green}[DEBUG] {lightgreen}Resetting powerups timers");
				#endif
				g_usedhealth[client] = 0;
				
				switch(powerups_notify_type.IntValue)
				{
					case 0: {/*nothing*/}
					case 1: {CPrintToChat(client, "%T", "notify (C)", client);}
					case 2: {PrintHintText(client, "%T", "notify", client);}
					case 3: {PrintCenterText(client, "%T", "notify", client);}
				}
				
				g_powerups_timeleft[client] = powerups_duration.FloatValue;
				g_usedhealth[client] = 1;
				RebuildAll();

				g_powerups_countdown[client] = CreateTimer(1.0, Timer_Countdown, client, TIMER_REPEAT);
				//Multiply by 1.0 to prevent tag mismatch
			}
		}
	}
}

public Action OnAdrenalineGiven(int client, float duration) {
	if (g_powerups_timeleft[client] > 0.0)
		g_powerups_timeleft[client] += duration;

	return Plugin_Continue;
}

Action Timer_Countdown(Handle timer, any client)
{
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != 2)
	{
		g_powerups_countdown[client] = null;
		g_usedhealth[client] = 0;
		RebuildAll();
		return Plugin_Stop;
	}

	if(g_powerups_timeleft[client] <= 0.0) //Powerups ran out
	{
		switch(powerups_notify_type.IntValue)
		{
			case 0: {/*nothing*/}
				case 1: {CPrintToChat(client, "%T", "notify_normal (C)", client);}
				case 2: {PrintHintText(client, "%T", "notify_normal", client);}
				case 3: {PrintCenterText(client, "%T", "notify_normal", client);}
		}

		g_usedhealth[client] = 0;
		RebuildAll();
		g_powerups_countdown[client] = null;
		return Plugin_Stop;
	}
	else //Countdown progress
	{
		switch(powerups_timer_type.IntValue)
		{
			case 0: {/*nothing*/}
			case 1: {CPrintToChat(client,"%T", "Powerups time (C)", client, g_powerups_timeleft[client]);}
			case 2: {PrintHintText(client,"%T", "Powerups time", client, g_powerups_timeleft[client]);}
			case 3: {PrintCenterText(client,"%T", "Powerups time", client, g_powerups_timeleft[client]);}
		}
		g_powerups_timeleft[client] -= 1.0;

		if(g_bL4D2Version && powerups_adrenaline_effect.BoolValue == true)
		{
			float remaining = Terror_GetAdrenalineTime(client);
			remaining = (remaining > 0) ? remaining : 0.0;
			if(remaining < g_powerups_timeleft[client])
			{
				//PrintToChatAll("remaining: %.2f, add AdrenalineTime %.2f on %N", remaining, g_powerups_timeleft[client], client);
				Terror_SetAdrenalineTime(client, g_powerups_timeleft[client]);
			}
		}

		return Plugin_Continue;
	}
}

void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ClearAll();
	ResetTimer();
}


//Reloading weapon
void Event_Reload (Event event, const char[] name, bool dontBroadcast)
{
	if (g_powerups_plugin_on)
	{
		int client = GetClientOfUserId(event.GetInt("userid"));
		if (g_usedhealth[client] == 1) //If client got the boost(s)
		{
			AdrenReload(client);
		}
		else //Obviously they haven't
		{
			return;
		}
	}
}
// ////////////////////////////////////////////////////////////////////////////
//On the start of a reload
void AdrenReload (int client)
{
	if (GetClientTeam(client) == 2)
	{
		#if DEBUG
			CPrintToChatAll("{lightgreen}Client {default}%i{lightgreen}; start of reload detected",client );
		#endif
		int iEntid = GetEntDataEnt2(client, g_iActiveWO);
		if (IsValidEntity(iEntid)==false) return;
	
		char stClass[32];
		GetEntityNetClass(iEntid,stClass,32);
		#if DEBUG
			CPrintToChatAll("{lightgreen}-class of gun: {default}%s",stClass );
		#endif

		//for non-shotguns
		if (StrContains(stClass,"shotgun",false) == -1)
		{
			MagStart(iEntid, client);
			return;
		}
		//shotguns are a bit trickier since the game tracks per shell inserted
		//and there's TWO different shotguns with different values...
		else if (StrContains(stClass,"autoshotgun",false) != -1)
		{
			//create a pack to send clientid and gunid through to the timer
			DataPack hPack;
			CreateDataTimer(0.1,Timer_AutoshotgunStart, hPack);
			WritePackCell(hPack, client);
			WritePackCell(hPack, iEntid);
			return;
		}
		else if (StrContains(stClass,"shotgun_spas",false) != -1)
		{
			//similar to the autoshotgun, create a pack to send
			DataPack hPack;
			CreateDataTimer(0.1,Timer_SpasShotgunStart,hPack);
			WritePackCell(hPack, client);
			WritePackCell(hPack, iEntid);
			return;
		}
		else if (StrContains(stClass,"pumpshotgun",false) != -1 || StrContains(stClass,"shotgun_chrome",false) != -1)
		{
			DataPack hPack;
			CreateDataTimer(0.1,Timer_PumpshotgunStart,hPack);
			WritePackCell(hPack, client);
			WritePackCell(hPack, iEntid);
			return;
		}
	}
}
// ////////////////////////////////////////////////////////////////////////////
//called for mag loaders
void MagStart (int iEntid, int client)
{
	#if DEBUG
		CPrintToChatAll("{olive}-magazine loader detected,{lightgreen} gametime {default}%f", GetGameTime());
	#endif
	float flGameTime = GetGameTime();
	float flNextTime_ret = GetEntDataFloat(iEntid,g_iNextPAttO);
	#if DEBUG
		CPrintToChatAll("{lightgreen}- pre, gametime {default}%f{lightgreen}, retrieved nextattack{default} %i %f{lightgreen}, retrieved time idle {default}%i %f",
			flGameTime,
			g_iNextAttO,
			GetEntDataFloat(client,g_iNextAttO),
			g_iTimeIdleO,
			GetEntDataFloat(iEntid,g_iTimeIdleO)
			);
	#endif

	//this is a calculation of when the next primary attack will be after applying reload values
	//NOTE: at this point, only calculate the interval itself, without the actual game engine time factored in
	float flNextTime_calc = ( flNextTime_ret - flGameTime ) * g_fl_reload_rate ;
	//we change the playback rate of the gun, just so the player can "see" the gun reloading faster
	SetEntDataFloat(iEntid, g_iPlayRateO, 1.0/g_fl_reload_rate, true);
	//create a timer to reset the playrate after time equal to the modified attack interval
	CreateTimer( flNextTime_calc, Timer_MagEnd, iEntid);
	//experiment to remove double-playback bug
	DataPack hPack = new DataPack();
	WritePackCell(hPack, client);
	//this calculates the equivalent time for the reload to end
	float flStartTime_calc = flGameTime - ( flNextTime_ret - flGameTime ) * ( 1 - g_fl_reload_rate ) ;
	WritePackFloat(hPack, flStartTime_calc);
	//now we create the timer that will prevent the annoying double playback
	if ( (flNextTime_calc - 0.4) > 0 )
		CreateTimer( flNextTime_calc - 0.4 , Timer_MagEnd2, hPack, TIMER_DATA_HNDL_CLOSE);
	//and finally we set the end reload time into the gun so the player can actually shoot with it at the end
	flNextTime_calc += flGameTime;
	SetEntDataFloat(iEntid, g_iTimeIdleO, flNextTime_calc, true);
	SetEntDataFloat(iEntid, g_iNextPAttO, flNextTime_calc, true);
	SetEntDataFloat(client, g_iNextAttO, flNextTime_calc, true);
	#if DEBUG
		CPrintToChatAll("{lightgreen}- post, calculated nextattack {default}%f{lightgreen}, gametime {default}%f{lightgreen}, retrieved nextattack{default} %i %f{lightgreen}, retrieved time idle {default}%i %f",
			flNextTime_calc,
			flGameTime,
			g_iNextAttO,
			GetEntDataFloat(client,g_iNextAttO),
			g_iTimeIdleO,
			GetEntDataFloat(iEntid,g_iTimeIdleO)
			);
	#endif
}

//called for autoshotguns
Action Timer_AutoshotgunStart (Handle timer, DataPack hPack)
{
	ResetPack(hPack);
	int iCid = ReadPackCell(hPack);
	int iEntid = ReadPackCell(hPack);

	if (IsServerProcessing() == false)
	{
		return Plugin_Stop;
	}

	DataPack hPack2 = new DataPack();
	WritePackCell(hPack2, iCid);
	WritePackCell(hPack2, iEntid);

	if (iCid <= 0
		|| iEntid <= 0
		|| IsValidEntity(iCid) == false
		|| IsValidEntity(iEntid) == false
		|| IsClientInGame(iCid) == false)
	{
		delete hPack2;
		return Plugin_Stop;
	}

	#if DEBUG
		CPrintToChatAll("{lightgreen}-autoshotgun detected, iEntid {default}%i{lightgreen}, startO {default}%i{lightgreen}, insertO {default}%i{lightgreen}, endO {default}%i",
			iEntid,
			g_iShotStartDurO,
			g_iShotInsertDurO,
			g_iShotEndDurO
			);
		CPrintToChatAll("{lightgreen}- pre mod, start {default}%f{lightgreen}, insert {default}%f{lightgreen}, end {default}%f",
			g_fl_AutoI,
			g_fl_AutoS,
			g_fl_AutoE
			);
	#endif
		
	//then we set the new times in the gun
	SetEntDataFloat(iEntid,	g_iShotStartDurO,	g_fl_AutoS*g_fl_reload_rate,	true);
	SetEntDataFloat(iEntid,	g_iShotInsertDurO,	g_fl_AutoI*g_fl_reload_rate,	true);
	SetEntDataFloat(iEntid,	g_iShotEndDurO,		g_fl_AutoE*g_fl_reload_rate,	true);

	//we change the playback rate of the gun just so the player can "see" the gun reloading faster
	SetEntDataFloat(iEntid, g_iPlayRateO, 1.0/g_fl_reload_rate, true);

	//and then call a timer to periodically check whether the gun is still reloading or not to reset the animation
	//but first check the reload state; if it's 2, then it needs a pump/cock before it can shoot again, and thus needs more time
	if (g_bL4D2Version)
	{
		CreateTimer(0.3,Timer_ShotgunEnd,hPack2,TIMER_REPEAT|TIMER_DATA_HNDL_CLOSE);
	}
	else
	{
		if (GetEntData(iEntid,g_iShotRelStateO)==2)
			CreateTimer(0.3, Timer_ShotgunEndCock, hPack2, TIMER_REPEAT|TIMER_DATA_HNDL_CLOSE);
		else
			CreateTimer(0.3, Timer_ShotgunEnd, hPack2, TIMER_REPEAT|TIMER_DATA_HNDL_CLOSE);
	}

	#if DEBUG
		CPrintToChatAll("{lightgreen}- after mod, start {default}%f{lightgreen}, insert {default}%f{lightgreen}, end {default}%f",
			g_fl_AutoS,
			g_fl_AutoI,
			g_fl_AutoE
			);
	#endif

	return Plugin_Stop;
}

Action Timer_SpasShotgunStart (Handle timer, DataPack hPack)
{
	ResetPack(hPack);
	int iCid = ReadPackCell(hPack);
	int iEntid = ReadPackCell(hPack);
	if (IsServerProcessing() == false)
	{
		return Plugin_Stop;
	}

	DataPack hPack2 = new DataPack();
	WritePackCell(hPack2, iCid);
	WritePackCell(hPack2, iEntid);

	if (iCid <= 0
		|| iEntid <= 0
		|| IsValidEntity(iCid) == false
		|| IsValidEntity(iEntid) == false
		|| IsClientInGame(iCid) == false)	
	{
		delete hPack2;
		return Plugin_Stop;
	}

	#if DEBUG
		CPrintToChatAll("{lightgreen}-autoshotgun detected, iEntid {default}%i{lightgreen}, startO {default}%i{lightgreen}, insertO {default}%i{lightgreen}, endO {default}%i",
			iEntid,
			g_iShotStartDurO,
			g_iShotInsertDurO,
			g_iShotEndDurO
			);
		CPrintToChatAll("{lightgreen}- pre mod, start {default}%f{lightgreen}, insert {default}%f{lightgreen}, end {default}%f",
			g_fl_SpasS,
			g_fl_SpasI,
			g_fl_SpasE
			);
	#endif
		
	//then we set the new times in the gun
	SetEntDataFloat(iEntid,	g_iShotStartDurO,	g_fl_SpasS*g_fl_reload_rate,	true);
	SetEntDataFloat(iEntid,	g_iShotInsertDurO,	g_fl_SpasI*g_fl_reload_rate,	true);
	SetEntDataFloat(iEntid,	g_iShotEndDurO,		g_fl_SpasE*g_fl_reload_rate,	true);

	//we change the playback rate of the gun just so the player can "see" the gun reloading faster
	SetEntDataFloat(iEntid, g_iPlayRateO, 1.0/g_fl_reload_rate, true);

	//and then call a timer to periodically check whether the gun is still reloading or not to reset the animation
	//but first check the reload state; if it's 2, then it needs a pump/cock before it can shoot again, and thus needs more time
	CreateTimer(0.3, Timer_ShotgunEnd, hPack2, TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);

	#if DEBUG
		CPrintToChatAll("{lightgreen}- after mod, start {default}%f{lightgreen}, insert {default}%f{lightgreen}, end {default}%f",
			g_fl_SpasS,
			g_fl_SpasI,
			g_fl_SpasE
			);
	#endif

	return Plugin_Stop;
}

//called for pump/chrome shotguns
Action Timer_PumpshotgunStart (Handle timer, DataPack hPack)
{
	ResetPack(hPack);
	int iCid = ReadPackCell(hPack);
	int iEntid = ReadPackCell(hPack);

	if (IsServerProcessing() == false)
	{
		return Plugin_Stop;
	}

	DataPack hPack2 = new DataPack();
	WritePackCell(hPack2, iCid);
	WritePackCell(hPack2, iEntid);

	if (iCid <= 0
		|| iEntid <= 0
		|| IsValidEntity(iCid) == false
		|| IsValidEntity(iEntid) == false
		|| IsClientInGame(iCid) == false)
	{
		delete hPack2;
		return Plugin_Stop;
	}

	#if DEBUG
		CPrintToChatAll("{lightgreen}-pumpshotgun detected, iEntid {default}%i{lightgreen}, startO {default}%i{lightgreen}, insertO {default}%i{lightgreen}, endO {default}%i",
			iEntid,
			g_iShotStartDurO,
			g_iShotInsertDurO,
			g_iShotEndDurO
			);
		CPrintToChatAll("{lightgreen}- pre mod, start {default}%f{lightgreen}, insert {default}%f{lightgreen}, end {default}%f",
			g_fl_PumpS,
			g_fl_PumpI,
			g_fl_PumpE
			);
	#endif

	//then we set the new times in the gun
	SetEntDataFloat(iEntid,	g_iShotStartDurO,	g_fl_PumpS*g_fl_reload_rate,	true);
	SetEntDataFloat(iEntid,	g_iShotInsertDurO,	g_fl_PumpI*g_fl_reload_rate,	true);
	SetEntDataFloat(iEntid,	g_iShotEndDurO,		g_fl_PumpE*g_fl_reload_rate,	true);

	//we change the playback rate of the gun just so the player can "see" the gun reloading faster
	SetEntDataFloat(iEntid, g_iPlayRateO, 1.0/g_fl_reload_rate, true);

	//and then call a timer to periodically check whether the gun is still reloading or not to reset the animation
	if (g_bL4D2Version)
	{
		CreateTimer(0.3,Timer_ShotgunEnd,hPack2,TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
	}
	else if (g_bL4D2Version)
	{
		if (GetEntData(iEntid,g_iShotRelStateO) == 2)
			CreateTimer(0.3, Timer_ShotgunEndCock, hPack2, TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
		else
			CreateTimer(0.3, Timer_ShotgunEnd, hPack2, TIMER_REPEAT | TIMER_DATA_HNDL_CLOSE);
	}

	#if DEBUG
		CPrintToChatAll("{lightgreen}- after mod, start {default}%f{lightgreen}, insert {default}%f{lightgreen}, end {default}%f",
			g_fl_PumpS,
			g_fl_PumpI,
			g_fl_PumpE
			);
	#endif

	return Plugin_Stop;
}
// ////////////////////////////////////////////////////////////////////////////
//this resets the playback rate on non-shotguns
Action Timer_MagEnd (Handle timer, any iEntid)
{
	if (IsServerProcessing() == false)
		return Plugin_Stop;

	#if DEBUG
		CPrintToChatAll("{lightgreen}Reset playback, magazine loader");
	#endif

	if (iEntid <= 0
		|| IsValidEntity(iEntid) == false)
		return Plugin_Stop;

	SetEntDataFloat(iEntid, g_iPlayRateO, 1.0, true);

	return Plugin_Stop;
}

Action Timer_MagEnd2 (Handle timer, DataPack hPack)
{
	ResetPack(hPack);
	int iCid = ReadPackCell(hPack);
	float flStartTime_calc = ReadPackFloat(hPack);

	if (IsServerProcessing() == false)
	{
		return Plugin_Stop;
	}

	#if DEBUG
		CPrintToChatAll("{lightgreen}Reset playback, magazine loader");
	#endif

	if (iCid <= 0
		|| IsValidEntity(iCid) == false
		|| IsClientInGame(iCid) == false)
		return Plugin_Stop;

	//experimental, remove annoying double-playback
	int iVMid = GetEntDataEnt2(iCid,g_iViewModelO);
	SetEntDataFloat(iVMid, g_iVMStartTimeO, flStartTime_calc, true);

	#if DEBUG
		CPrintToChatAll("{lightgreen}- end mag loader, icid {default}%i{lightgreen} starttime {default}%f{lightgreen} gametime {default}%f", iCid, flStartTime_calc, GetGameTime());
	#endif

	return Plugin_Stop;
}

Action Timer_ShotgunEnd (Handle timer, DataPack hPack)
{
	#if DEBUG
		CPrintToChatAll("{lightgreen}-autoshotgun tick");
	#endif

	ResetPack(hPack);
	int iCid = ReadPackCell(hPack);
	int iEntid = ReadPackCell(hPack);

	if (IsServerProcessing() == false
		|| iCid <= 0
		|| iEntid <= 0
		|| IsValidEntity(iCid) == false
		|| IsValidEntity(iEntid) == false
		|| IsClientInGame(iCid) == false)
	{
		return Plugin_Stop;
	}

	if (GetEntData(iEntid,g_iShotRelStateO)==0)
	{
		#if DEBUG
			CPrintToChatAll("{lightgreen}-shotgun end reload detected");
		#endif

		SetEntDataFloat(iEntid, g_iPlayRateO, 1.0, true);

		//int iCid = GetEntPropEnt(iEntid,Prop_Data,"m_hOwner");
		float flTime = GetGameTime() + 0.2;
		SetEntDataFloat(iCid,	g_iNextAttO,	flTime,	true);
		SetEntDataFloat(iEntid,	g_iTimeIdleO,	flTime,	true);
		SetEntDataFloat(iEntid,	g_iNextPAttO,	flTime,	true);

		return Plugin_Stop;
	}
	return Plugin_Continue;
}
// ////////////////////////////////////////////////////////////////////////////
//since cocking requires more time, this function does
//exactly as the above, except it adds slightly more time
Action Timer_ShotgunEndCock (Handle timer, DataPack hPack)
{
	#if DEBUG
		CPrintToChatAll("{lightgreen}-autoshotgun tick");
	#endif

	ResetPack(hPack);
	int iCid = ReadPackCell(hPack);
	int iEntid = ReadPackCell(hPack);

	if (IsServerProcessing() == false
		|| iCid <= 0
		|| iEntid <= 0
		|| IsValidEntity(iCid) == false
		|| IsValidEntity(iEntid) == false
		|| IsClientInGame(iCid) == false)
	{
		return Plugin_Stop;
	}

	if (GetEntData(iEntid,g_iShotRelStateO) == 0)
	{
		#if DEBUG
			CPrintToChatAll("{lightgreen}-shotgun end reload + cock detected");
		#endif

		SetEntDataFloat(iEntid, g_iPlayRateO, 1.0, true);

		//int iCid = GetEntPropEnt(iEntid,Prop_Data,"m_hOwner");
		float flTime = GetGameTime() + 1.0;
		SetEntDataFloat(iCid,	g_iNextAttO,	flTime,	true);
		SetEntDataFloat(iEntid,	g_iTimeIdleO,	flTime,	true);
		SetEntDataFloat(iEntid,	g_iNextPAttO,	flTime,	true);

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public void OnGameFrame()
{
	//If frames aren't being processed, don't bother.
	//Otherwise we get LAG or even disconnects on map changes, etc...
	if (IsServerProcessing() == false|| g_bIsLoading == true)
	{
		return;
	}
	else
	{
		MA_OnGameFrame();
		DT_OnGameFrame();
	}
}

public void OnMapEnd()
{
	ClearAll();
	g_bIsLoading = true;
	ResetTimer();
}

void RebuildAll ()
{
	MA_Rebuild();
	DT_Rebuild();
}

void ClearAll ()
{
	MA_Clear();
	DT_Clear();
}
// ////////////////////////////////////////////////////////////////////////////
//called whenever the registry needs to be rebuilt to cull any players who have left or died, etc.
//resets survivor's speeds and reassigns speed boost
//(called on: player death, player disconnect, adrenaline popped, adrenaline ended, -> change teams, convar change)
void MA_Rebuild ()
{
	//clears all DT-related vars
	MA_Clear();
	//if the server's not running or is in the middle of loading, stop
	if (IsServerProcessing()==false)
		return;
	#if DEBUG
		CPrintToChatAll("{lightgreen}Rebuilding melee registry");
	#endif
	for (int iI = 1 ; iI <= MaxClients ; iI++)
	{
		if (IsClientInGame(iI) == true && IsPlayerAlive(iI) == true && GetClientTeam(iI) == 2 && g_usedhealth[iI] == 1)
		{
			g_iMARegisterCount++;
			g_iMARegisterIndex[g_iMARegisterCount]=iI;
			#if DEBUG
				CPrintToChatAll("{lightgreen}-registering {default}%i",iI);
			#endif
		}
	}
}

//called to clear out registry and reset movement speeds
//(called on: round start, round end, map end)
void MA_Clear ()
{
	g_iMARegisterCount=0;
	#if DEBUG
		CPrintToChatAll("{lightgreen}Clearing melee registry");
	#endif
	for (int iI = 1 ; iI <= MaxClients ; iI++)
	{
		g_iMARegisterIndex[iI] = -1;
	}
}
// ////////////////////////////////////////////////////////////////////////////
//called whenever the registry needs to be rebuilt to cull any players who have left or died, etc.
//(called on: player death, player disconnect, closet rescue, change teams)
void DT_Rebuild ()
{
	//clears all DT-related vars
	DT_Clear();

	//if the server's not running or is in the middle of loading, stop
	if (IsServerProcessing()==false)
		return;
	#if DEBUG
		CPrintToChatAll("{lightgreen}Rebuilding weapon firing registry");
	#endif
	for (int iI = 1 ; iI <= MaxClients ; iI++)
	{
		if (IsClientInGame(iI) == true && IsPlayerAlive(iI) == true && GetClientTeam(iI) == 2 && g_usedhealth[iI] == 1)
		{
			g_iDTRegisterCount++;
			g_iDTRegisterIndex[g_iDTRegisterCount]=iI;
			#if DEBUG
				CPrintToChatAll("{lightgreen}-registering {default}%i",iI);
			#endif
		}
	}
}

//called to clear out DT registry
//(called on: round start, round end, map end)
void DT_Clear ()
{
	g_iDTRegisterCount=0;
	#if DEBUG
		CPrintToChatAll("{lightgreen}Clearing weapon firing registry");
	#endif
	for (int iI = 1 ; iI <= MaxClients ; iI++)
	{
		g_iDTRegisterIndex[iI] = -1;
		g_iDTEntid[iI] = -1;
		g_flDTNextTime[iI] = -1.0;
	}
}

//Since this is called EVERY game frame, we need to be careful not to run too many functions
//kinda hard, though, considering how many things we have to check for =.=
void MA_OnGameFrame()
{
	// if plugin is disabled, don't bother
	if (g_powerups_plugin_on == false)
		return;
	// or if no one has MA, don't bother either
	if (g_iMARegisterCount == 0)
		return;

	int iCid;
	//this tracks the player's ability id
	int iEntid;
	//this tracks the calculated next attack
	float flNextTime_calc;
	//this, on the other hand, tracks the current next attack
	float flNextTime_ret;
	//and this tracks the game time
	float flGameTime=GetGameTime();

	//theoretically, to get on the MA registry, all the necessary checks would have already
	//been run, so we don't bother with any checks here
	for (int iI = 1; iI <= g_iMARegisterCount; iI++)
	{
		//PRE-CHECKS 1: RETRIEVE VARS
		//---------------------------
		iCid = g_iMARegisterIndex[iI];
		//stop on this client when the next client id is null
		if (iCid <= 0) continue;
		if(!IsClientInGame(iCid)) continue;
		if (!IsPlayerAlive(iCid)) continue;
		if(GetClientTeam(iCid) != 2) continue;
		iEntid = GetEntDataEnt2(iCid,g_ActiveWeaponOffset);
		//if the retrieved gun id is -1, then...
		//wtf mate? just move on
		if (iEntid == -1) continue;
		//and here is the retrieved next attack time
		flNextTime_ret = GetEntDataFloat(iEntid,g_iNextPAttO);

		//CHECK 1: IS PLAYER USING A KNOWN NON-MELEE WEAPON?
		//--------------------------------------------------
		//as the title states... to conserve processing power,
		//if the player's holding a gun for a prolonged time
		//then we want to be able to track that kind of state
		//and not bother with any checks
		//checks: weapon is non-melee weapon
		//actions: do nothing
		if (iEntid == g_iMAEntid_notmelee[iCid])
		{
			// CPrintToChatAll("{lightgreen}Client {default}%i{lightgreen}; non melee weapon, ignoring",iCid );
			continue;
		}

		//CHECK 1.5: THE PLAYER HASN'T SWUNG HIS WEAPON FOR A WHILE
		//---------------------------------------------------------
		//in this case, if the player made 1 swing of his 2 strikes, and then paused long enough, 
		//we should reset his strike count so his next attack will allow him to strike twice
		//checks: is the delay between attacks greater than 1.5s?
		//actions: set attack count to 0, and CONTINUE CHECKS
		if (g_iMAEntid[iCid] == iEntid
				&& g_iMAAttCount[iCid]!=0
				&& (flGameTime - flNextTime_ret) > 1.0)
		{
			#if DEBUG
				CPrintToChatAll("{lightgreen}Client {default}%i{lightgreen}; hasn't swung weapon",iCid );
			#endif
			g_iMAAttCount[iCid]=0;
		}

		//CHECK 2: BEFORE ADJUSTED ATT IS MADE
		//------------------------------------
		//since this will probably be the case most of the time, we run this first
		//checks: weapon is unchanged; time of shot has not passed
		//actions: do nothing
		if (g_iMAEntid[iCid] == iEntid
				&& g_flMANextTime[iCid] >= flNextTime_ret)
		{
			// CPrintToChatAll("{lightgreen}DT client {default}%i{lightgreen}; before shot made",iCid );
			continue;
		}

		//CHECK 3: AFTER ADJUSTED ATT IS MADE
		//------------------------------------
		//at this point, either a gun was swapped, or the attack time needs to be adjusted
		//checks: stored gun id same as retrieved gun id,
		//        and retrieved next attack time is after stored value
		//actions: adjusts next attack time
		if (g_iMAEntid[iCid] == iEntid
				&& g_flMANextTime[iCid] < flNextTime_ret)
		{
			//----DEBUG----
			//CPrintToChatAll("{lightgreen}DT after adjusted shot\n-pre, client {default}%i{lightgreen}; entid {default}%i{lightgreen}; enginetime{default} %f{lightgreen}; NextTime_orig {default} %f{lightgreen}; interval {default}%f",iCid,iEntid,flGameTime,flNextTime_ret, flNextTime_ret-flGameTime );

			//this is a calculation of when the next primary attack will be after applying double tap values
			//flNextTime_calc = ( flNextTime_ret - flGameTime ) * g_flMA_attrate + flGameTime;
			flNextTime_calc = flGameTime + g_flDT_melee ;
			// flNextTime_calc = flGameTime + melee_speed[iCid] ;

			//then we store the value
			g_flMANextTime[iCid] = flNextTime_calc;

			//and finally adjust the value in the gun
			SetEntDataFloat(iEntid, g_iNextPAttO, flNextTime_calc, true);

			#if DEBUG
				CPrintToChatAll("{lightgreen}-post, NextTime_calc {default} %f{lightgreen}; new interval {default}%f", GetEntDataFloat(iEntid,g_iNextPAttO), GetEntDataFloat(iEntid,g_iNextPAttO)-flGameTime );
			#endif

			continue;
		}

		//CHECK 4: CHECK THE WEAPON
		//-------------------------
		//lastly, at this point we need to check if we are, in fact, using a melee weapon =P
		//we check if the current weapon is the same one stored in memory; if it is, move on;
		//otherwise, check if it's a melee weapon - if it is, store and continue; else, continue.
		//checks: if the active weapon is a melee weapon
		//actions: store the weapon's entid into either
		//         the known-melee or known-non-melee variable

		#if DEBUG
			CPrintToChatAll("{lightgreen}DT client {default}%i{lightgreen}; weapon switch inferred",iCid );
		#endif

		//check if the weapon is a melee
		char stName[32];
		GetEntityNetClass(iEntid,stName,32);
		if (StrEqual(stName,"CTerrorMeleeWeapon",false)==true)
		{
			//if yes, then store in known-melee var
			g_iMAEntid[iCid]=iEntid;
			g_flMANextTime[iCid]=flNextTime_ret;
			continue;
		}
		else
		{
			//if no, then store in known-non-melee var
			g_iMAEntid_notmelee[iCid]=iEntid;
			continue;
		}
	}
}
// ////////////////////////////////////////////////////////////////////////////
void DT_OnGameFrame()
{
	// if plugin is disabled, don't bother
	if (g_powerups_plugin_on == false)
		return;
	// or if no one has DT, don't bother either
	if (g_iDTRegisterCount == 0)
		return;

	//this tracks the player's id, just to make life less painful...
	int iCid;
	//this tracks the player's gun id since we adjust numbers on the gun, not the player
	int iEntid;
	//this tracks the calculated next attack
	float flNextTime_calc;
	//this, on the other hand, tracks the current next attack
	float flNextTime_ret;
	//and this tracks next melee attack times
	float flNextTime2_ret;
	//and this tracks the game time
	float flGameTime=GetGameTime();

	//theoretically, to get on the DT registry all the necessary checks would have already
	//been run, so we don't bother with any checks here
	for (int iI = 1; iI <= g_iDTRegisterCount; iI++)
	{
		//PRE-CHECKS: RETRIEVE VARS
		//-------------------------
		iCid = g_iDTRegisterIndex[iI];
		//stop on this client when the next client id is null
		if (iCid <= 0) return;
		//skip this client if they're disabled
		//if (g_iPState[iCid] == 1) continue;

		//we have to adjust numbers on the gun, not the player so we get the active weapon id here
		iEntid = GetEntDataEnt2(iCid,g_iActiveWO);
		//if the retrieved gun id is -1, then...
		//wtf mate? just move on
		if (iEntid == -1) continue;
		//and here is the retrieved next attack time
		flNextTime_ret = GetEntDataFloat(iEntid,g_iNextPAttO);
		//and for retrieved next melee time
		flNextTime2_ret = GetEntDataFloat(iEntid,g_iNextSAttO);

		//DEBUG
		/*int iNextAttO = FindSendPropInfo("CTerrorPlayer","m_flNextAttack");
		int iIdleTimeO = FindSendPropInfo("CTerrorGun","m_flTimeWeaponIdle");
		CPrintToChatAll("{lightgreen}DT, NextAttack {default}%i %f{lightgreen}, TimeIdle {default}%i %f",
			iNextAttO,
			GetEntDataFloat(iCid,iNextAttO),
			iIdleTimeO,
			GetEntDataFloat(iEntid,iIdleTimeO)
			);*/

		//CHECK 1: BEFORE ADJUSTED SHOT IS MADE
		//------------------------------------
		//since this will probably be the case most of the time, we run this first
		//checks: gun is unchanged; time of shot has not passed
		//actions: nothing
		if (g_iDTEntid[iCid] == iEntid
			&& g_flDTNextTime[iCid] >= flNextTime_ret)
		{
			//----DEBUG----
			//CPrintToChatAll("{lightgreen}DT client {default}%i{lightgreen}; before shot made",iCid );
			continue;
		}

		//CHECK 2: INFER IF MELEEING
		//--------------------------
		//since we don't want to shorten the interval incurred after swinging, we try to guess when
		//a melee attack is made
		//checks: if melee attack time > engine time
		//actions: nothing
		if (flNextTime2_ret > flGameTime)
		{
			//----DEBUG----
			//CPrintToChatAll("{lightgreen}DT client {default}%i{lightgreen}; melee attack inferred",iCid );
			continue;
		}

		//CHECK 3: AFTER ADJUSTED SHOT IS MADE
		//------------------------------------
		//at this point, either a gun was swapped, or the attack time needs to be adjusted
		//checks: stored gun id same as retrieved gun id, and retrieved next attack time is after stored value
		if (g_iDTEntid[iCid] == iEntid
			&& g_flDTNextTime[iCid] < flNextTime_ret)
		{
			#if DEBUG
				CPrintToChatAll("{lightgreen}DT after adjusted shot\n-pre, client {default}%i{lightgreen}; entid {default}%i{lightgreen}; enginetime{default} %f{lightgreen}; NextTime_orig {default} %f{lightgreen}; interval {default}%f",iCid,iEntid,flGameTime,flNextTime_ret, flNextTime_ret-flGameTime );
			#endif
			//this is a calculation of when the next primary attack
			//will be after applying double tap values
			flNextTime_calc = ( flNextTime_ret - flGameTime ) * g_flDT_rate + flGameTime;

			//then we store the value
			g_flDTNextTime[iCid] = flNextTime_calc;

			//and finally adjust the value in the gun
			SetEntDataFloat(iEntid, g_iNextPAttO, flNextTime_calc, true);

			#if DEBUG
				CPrintToChatAll("{lightgreen}-post, NextTime_calc {default} %f{lightgreen}; new interval {default}%f",GetEntDataFloat(iEntid,g_iNextPAttO), GetEntDataFloat(iEntid,g_iNextPAttO)-flGameTime );
			#endif
			continue;
		}

		//CHECK 4: ON WEAPON SWITCH
		//-------------------------
		//at this point, the only reason DT hasn't fired should be that the weapon had switched
		//checks: retrieved gun id doesn't match stored id or stored id is null
		//actions: updates stored gun id and sets stored next attack time to retrieved value
		if (g_iDTEntid[iCid] != iEntid)
		{
			#if DEBUG
				CPrintToChatAll("{lightgreen}DT client {default}%i{lightgreen}; weapon switch inferred", iCid );
			#endif
			//now we update the stored vars
			g_iDTEntid[iCid] = iEntid;
			g_flDTNextTime[iCid] = flNextTime_ret;
			continue;
		}
		#if DEBUG
			CPrintToChatAll("{lightgreen}DT client {default}%i{lightgreen}; reached end of checklist...", iCid );
		#endif
	}
}

stock bool IsInGame(int client)
{
	if ( client < 1 || client > MaxClients ) return false;
	if ( !IsClientInGame( client )) return false;
	return true;
}

void HookAll()
{
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			SDKHook(i, SDKHook_PostThinkPost, hOnPostThinkPost);
}

void UnHookAll()
{
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
			SDKUnhook(i, SDKHook_PostThinkPost, hOnPostThinkPost);
}

void hOnPostThinkPost(int client)
{
	if(IsFakeClient(client) && GetClientTeam(client) != 2)
	{
		SDKUnhook(client, SDKHook_PostThinkPost, hOnPostThinkPost);
		return;
	}
	
	if(!IsPlayerAlive(client) || GetClientTeam(client) != 2 || g_powerups_plugin_on == false) 
		return;
	
	if(g_usedhealth[client] == 0)
		return;
	
	if(ShouldGetUpFaster(client))
		SetEntPropFloat(client, Prop_Send, "m_flPlaybackRate", fAnimSpeed);
	else
	{
		float fGameTime;
		fGameTime = GetGameTime();
		if(fGameTimeSave[client] > fGameTime)
			return;
		
		float fStaggerTimer;
		fStaggerTimer = GetEntPropFloat(client, Prop_Send, "m_staggerTimer", 1);
		if(fStaggerTimer <= fGameTime + fTickRate)// ignore if stagger will last atleast 1 tick
			return;
		
		fStaggerTimer = (((fStaggerTimer - fGameTime) / fAnimSpeed) + fGameTime);
		SetEntPropFloat(client, Prop_Send, "m_staggerTimer", fStaggerTimer, 1);
		fGameTimeSave[client] = fStaggerTimer;
	}
	return;
}

bool ShouldGetUpFaster(int client)
{
	int Activity = PlayerAnimState.FromPlayer(client).GetMainActivity();
	switch (Activity) 
	{
		case L4D2_ACT_TERROR_SHOVED_FORWARD_MELEE, // 633, 634, 635, 636: stumble
			L4D2_ACT_TERROR_SHOVED_BACKWARD_MELEE,
			L4D2_ACT_TERROR_SHOVED_LEFTWARD_MELEE,
			L4D2_ACT_TERROR_SHOVED_RIGHTWARD_MELEE: 
				return true;

		case L4D2_ACT_TERROR_POUNCED_TO_STAND: // 771: get up from hunter
			return true;

		case L4D2_ACT_TERROR_CHARGERHIT_LAND_SLOW: // 526: get up from charger
			return true;

		case L4D2_ACT_TERROR_HIT_BY_CHARGER, // 524, 525, 526: flung by a nearby Charger impact
			L4D2_ACT_TERROR_IDLE_FALL_FROM_CHARGERHIT: 
			return true;

		case L4D2_ACT_TERROR_HIT_BY_TANKPUNCH,
			L4D2_ACT_TERROR_IDLE_FALL_FROM_TANKPUNCH,
			L4D2_ACT_TERROR_TANKPUNCH_LAND: // hit by tank
			return true;

		/*case L4D2_ACT_TERROR_INCAP_TO_STAND: // 697, revive from incap or death
		{
			if(!L4D_IsPlayerIncapacitated(client)) // revive by defibrillator
			{
				return true;
			}
		}*/
	}
	
	return false;
}

void ResetTimer()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		delete g_powerups_countdown[i];
		delete WelcomeTimers[i];
		g_usedhealth[i] = 0;
	}
	delete PlayerLeftStartTimer;
}
