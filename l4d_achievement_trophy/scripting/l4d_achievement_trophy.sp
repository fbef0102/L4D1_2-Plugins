#define PLUGIN_VERSION 		"2.6"

/*======================================================================================
	Plugin Info:

*	Name	:	[L4D2] Achivement Trophy
*	Author	:	SilverShot
*	Descrp	:	Displays the TF2 trophy when a player unlocks an achievement.
*	Link	:	https://forums.alliedmods.net/showthread.php?t=136174
*	Plugins	:	https://sourcemod.net/plugins.php?exact=exact&sortby=title&search=1&author=Silvers

========================================================================================
	Change Log:

2.6 (10-May-2020)
	- Extra checks to prevent "IsAllowedGameMode" throwing errors.
	- Various changes to tidy up code.

2.5 (01-Apr-2020)
	- Added optional args to "sm_trophy" command to specify a client.
	- Fixed "IsAllowedGameMode" from throwing errors when the "_tog" cvar was changed before MapStart.

2.4.2 (28-Jun-2019)
	- Changed PrecacheParticle method.

2.4.1 (01-Jun-2019)
	- Minor changes to code, has no affect and not required.

2.4 (31-Jul-2018)
	- Added achievement sound. Thanks to "Naomi" for requesting.
	- Added new cvar "l4d_trophy_sound" to control the sound effect.

2.3 (05-May-2018)
	- Converted plugin source to the latest syntax utilizing methodmaps. Requires SourceMod 1.8 or newer.
	- Changed cvar "l4d_trophy_modes_tog" now supports L4D1.

2.2 (25-May-2012)
	- Fixed not creating trophies due to Survivor Thirdperson plugin.

2.1 (21-May-2012)
	- Fixed achievement event using the wrong data. Thanks to "disawar1".

2.0 (20-May-2012)
	- Plugin has been totally re-written. Delete the old plugin and cvars config.
	- Allow and Mode cvars added.
	- Fixed errors being logged.
    - Thirdperson now works for survivors in L4D2 only.

1.4 (04-Oct-2010)
	- retroGamer's versions.

1.3 (30-Aug-2010)
	- Added version cvar.
	- Attempted to cache particles by playing OnClientPutInServer.

1.2 (25-Aug-2010)
	- Added more particles (mini fireworks)!
	- UnhookEvent when plugin turned off.

1.1.1 (25-Aug-2010)
	- Removed 1 event per second limit.

1.1 (25-Aug-2010)
	- Moved event hook from OnMapStart to OnPluginStart.

1.0 (23-Aug-2010)
	- Initial release.

========================================================================================
	Thanks:

	This plugin was made using source code from the following plugins.
	If I have used your code and not credited you, please let me know.

*	"Zuko & McFlurry" for "[L4D2] Weapon/Zombie Spawner" - Modified SetTeleportEndPoint function.
	https://forums.alliedmods.net/showthread.php?t=109659

======================================================================================*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define CVAR_FLAGS			FCVAR_NOTIFY

#define PARTICLE_ACHIEVED	"achieved"
#define PARTICLE_FIREWORK	"mini_fireworks"
#define SOUND_ACHIEVEMENT	"ui/pickup_misc42.wav"
#define MODEL_CONE            "models/editor/spot_cone.mdl"
#define MODEL_mustachio		  "models/props_fairgrounds/mr_mustachio.mdl"

ConVar g_hCvarMPGameMode, g_hCvarAllow, g_hCvarModes, g_hCvarModesOff, g_hCvarModesTog, g_hCvarEffects, g_hCvarSound, g_hCvarThird, g_hCvarTime, g_hCvarWait;
int g_iCvarEffects, g_iCvarSound, g_iParticles[MAXPLAYERS+1][2];
bool g_bCvarAllow, g_bMapStarted, g_bLeft4Dead2;
float g_fCvarThird, g_fCvarTime, g_fCvarWait;
int g_iBoomerHat[MAXPLAYERS+1];
int g_iBoomerHatGlow[MAXPLAYERS+1];

// ====================================================================================================
//					PLUGIN INFO / START / END
// ====================================================================================================
public Plugin myinfo =
{
	name = "[L4D & L4D2] Achievement Trophy",
	author = "SilverShot & HarryPotter",
	description = "Displays the TF2 trophy when a player unlocks an achievement.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=136174"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test == Engine_Left4Dead ) g_bLeft4Dead2 = false;
	else if( test == Engine_Left4Dead2 ) g_bLeft4Dead2 = true;
	else
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	g_hCvarAllow =		CreateConVar(	"l4d_trophy_allow",			"1",			"0=Plugin off, 1=Plugin on.", CVAR_FLAGS );
	g_hCvarModes =		CreateConVar(	"l4d_trophy_modes",			"",				"Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).", CVAR_FLAGS );
	g_hCvarModesOff =	CreateConVar(	"l4d_trophy_modes_off",		"",				"Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).", CVAR_FLAGS );
	g_hCvarModesTog =	CreateConVar(	"l4d_trophy_modes_tog",		"0",			"Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.", CVAR_FLAGS );
	g_hCvarEffects =	CreateConVar(	"l4d_trophy_effects",		"3",			"Which effects to display. 1=Trophy, 2=Fireworks, 3=Both.", CVAR_FLAGS );
	g_hCvarSound =		CreateConVar(	"l4d_trophy_sound",			g_bLeft4Dead2 ? "3" : "1",		"0=Off. 1=Play sound when using the command. 2=When achievement is earned (not required for L4D1). 3=Both.", CVAR_FLAGS );
	if( g_bLeft4Dead2 )
		g_hCvarThird =	CreateConVar(	"l4d_trophy_third",			"4.0",			"0.0=Off. How long to put the player into thirdperson view.", CVAR_FLAGS );
	g_hCvarTime =		CreateConVar(	"l4d_trophy_time",			"3.5",			"Remove the particle effects after this many seconds. Increase time to make the effect loop.", CVAR_FLAGS );
	g_hCvarWait =		CreateConVar(	"l4d_trophy_wait",			"3.5",			"Replay the particles after this many seconds.", CVAR_FLAGS );
	
	CreateConVar(						"l4d_trophy_version",		PLUGIN_VERSION, "Achievement Trophy plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,				"l4d_trophy");

	RegAdminCmd("sm_trophy",			CmdTrophy,		ADMFLAG_ROOT, 	"Display the achievement trophy on yourself. Or optional arg to specify targets [#userid|name]");

	g_hCvarMPGameMode = FindConVar("mp_gamemode");
	g_hCvarMPGameMode.AddChangeHook(ConVarChanged_Allow);
	g_hCvarAllow.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModes.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesOff.AddChangeHook(ConVarChanged_Allow);
	g_hCvarModesTog.AddChangeHook(ConVarChanged_Allow);
	g_hCvarEffects.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarSound.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarTime.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarWait.AddChangeHook(ConVarChanged_Cvars);
	if( g_bLeft4Dead2 )
		g_hCvarThird.AddChangeHook(ConVarChanged_Cvars);
}

public void OnPluginEnd()
{
	ResetPlugin();
}

public void OnMapStart()
{
	g_bMapStarted = true;

	PrecacheModel(MODEL_CONE);
	PrecacheModel(MODEL_mustachio);
	PrecacheParticle(PARTICLE_ACHIEVED);
	PrecacheParticle(PARTICLE_FIREWORK);
	PrecacheSound(SOUND_ACHIEVEMENT);
}

public void OnMapEnd()
{
	g_bMapStarted = false;
	ResetPlugin();
}

void ResetPlugin()
{
	for( int i = 1; i <= MaxClients; i++ )
		RemoveEffects(i);
}

void RemoveEffects(int client)
{
	int entity;

	entity = g_iParticles[client][0];
	if( IsValidEntRef(entity) )
		AcceptEntityInput(entity, "Kill");
	g_iParticles[client][0] = 0;

	entity = g_iParticles[client][1];
	if( IsValidEntRef(entity) )
		AcceptEntityInput(entity, "Kill");
	g_iParticles[client][1] = 0;
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
	g_iCvarEffects = g_hCvarEffects.IntValue;
	g_iCvarSound = g_hCvarSound.IntValue;
	g_fCvarTime = g_hCvarTime.FloatValue;
	g_fCvarWait = g_hCvarWait.FloatValue;
	if( g_bLeft4Dead2 )
		g_fCvarThird = g_hCvarThird.FloatValue;
}

void IsAllowed()
{
	bool bCvarAllow = g_hCvarAllow.BoolValue;
	bool bAllowMode = IsAllowedGameMode();
	GetCvars();

	if( g_bCvarAllow == false && bCvarAllow == true && bAllowMode == true)
	{
		g_bCvarAllow = true;
		HookEvent("achievement_earned",		Event_Achievement);
		HookEvent("player_death",			Event_Remove);
		HookEvent("player_team",			Event_Remove);
		HookEvent("round_end",				Event_RemoveAll,	EventHookMode_PostNoCopy);
		if(g_bLeft4Dead2)
			HookEvent("tank_killed",            Event_AchievementTank);
		else
			HookEvent("player_death", eventplayer_death);
		HookEvent("player_now_it",            Event_AchievementBoomer);
		HookEvent("witch_killed",            Event_AchievementWitch);
	}

	else if( g_bCvarAllow == true && (bCvarAllow == false || bAllowMode == false) )
	{
		ResetPlugin();
		g_bCvarAllow = false;
		UnhookEvent("achievement_earned",	Event_Achievement);
		UnhookEvent("player_death",			Event_Remove);
		UnhookEvent("player_team",			Event_Remove);
		UnhookEvent("round_end",			Event_RemoveAll,	EventHookMode_PostNoCopy);
		if(g_bLeft4Dead2)
			UnhookEvent("tank_killed",            Event_AchievementTank);
		else
			UnhookEvent("player_death", eventplayer_death);
		UnhookEvent("player_now_it",        Event_AchievementBoomer);
		UnhookEvent("witch_killed",            Event_AchievementWitch);
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
public void Event_Remove(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	RemoveEffects(client);
    
}

public void Event_RemoveAll(Event event, const char[] name, bool dontBroadcast)
{
	for( int i = 1; i <= MaxClients; i++ )
		RemoveEffects(i);
}

public void Event_Achievement(Event event, const char[] name, bool dontBroadcast)
{
	int client = event.GetInt("player");
	CreateEffects(client, true);
}

public void Event_AchievementBoomer(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    int boomer = GetClientOfUserId(GetEventInt(event, "attacker"));
    CreateEffects(boomer, false);
    CreateHat(client);
    CreatePropGlow(client, g_iBoomerHat[client]);
}

public void Event_AchievementWitch(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    CreateEffects(client, false);
}

//l4d2
public void Event_AchievementTank(Event event, const char[] name, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "attacker"));
    CreateEffects(client, false);
}

//l4d1
public void eventplayer_death(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(client<=0||client>MaxClients || !IsClientInGame(client) || attacker <=0 || attacker > MaxClients || !IsClientInGame(attacker)) return;
	if(GetClientTeam(client) != 3 || GetClientTeam(attacker) != 2) return;
	
	if(IsPlayerTank(client))
		CreateEffects(attacker, false);
}

void CreateEffects(int client, bool event)
{
	if( client && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) != 1 )
	{
		// Thirdperson view
		if( g_fCvarThird != 0.0 )
		{
			// Survivor Thirdperson plugin sets 99999.3.
			if( GetEntPropFloat(client, Prop_Send, "m_TimeForceExternalView") != 99999.3 )
				SetEntPropFloat(client, Prop_Send, "m_TimeForceExternalView", GetGameTime() + g_fCvarThird);
		}

		// Sound
		if( g_iCvarSound == 3 || (!event && g_iCvarSound == 1) || (event && g_iCvarSound == 2) )
		{
			EmitSoundToAll(SOUND_ACHIEVEMENT, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		}

		// Effect
		int entity;
		if( g_iCvarEffects == 3 || g_iCvarEffects == 1 )
		{
			entity = CreateEntityByName("info_particle_system");
			if( entity != INVALID_ENT_REFERENCE )
			{
				DispatchKeyValue(entity, "effect_name", PARTICLE_ACHIEVED);
				DispatchSpawn(entity);
				ActivateEntity(entity);
				AcceptEntityInput(entity, "start");

				// Attach to survivor
				SetVariantString("!activator");
				AcceptEntityInput(entity, "SetParent", client);
				TeleportEntity(entity, view_as<float>({ 0.0, 0.0, 50.0 }), NULL_VECTOR, NULL_VECTOR);

				// Loop
				char sTemp[64];
				SetVariantString("OnUser1 !self:Start::0.0:-1");
				AcceptEntityInput(entity, "AddOutput");
				Format(sTemp, sizeof(sTemp), "OnUser2 !self:Stop::%f:-1", g_fCvarWait);
				SetVariantString(sTemp);
				AcceptEntityInput(entity, "AddOutput");
				Format(sTemp, sizeof(sTemp), "OnUser2 !self:FireUser1::%f:-1", g_fCvarWait + 0.1);
				SetVariantString(sTemp);
				AcceptEntityInput(entity, "AddOutput");
				Format(sTemp, sizeof(sTemp), "OnUser2 !self:FireUser2::%f:-1", g_fCvarWait + 0.1);
				SetVariantString(sTemp);
				AcceptEntityInput(entity, "AddOutput");

				AcceptEntityInput(entity, "FireUser1");
				AcceptEntityInput(entity, "FireUser2");

				// Remove
				Format(sTemp, sizeof(sTemp), "OnUser3 !self:Kill::%f:-1", g_fCvarTime);
				SetVariantString(sTemp);
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser3");

				g_iParticles[client][0] = EntIndexToEntRef(entity);
			}
		}

		if( g_iCvarEffects == 3 || g_iCvarEffects == 2 )
		{
			entity = CreateEntityByName("info_particle_system");
			{
				DispatchKeyValue(entity, "effect_name", PARTICLE_FIREWORK);
				DispatchSpawn(entity);
				ActivateEntity(entity);
				AcceptEntityInput(entity, "start");

				// Attach to survivor
				SetVariantString("!activator");
				AcceptEntityInput(entity, "SetParent", client);
				TeleportEntity(entity, view_as<float>({ 0.0, 0.0, 50.0 }), NULL_VECTOR, NULL_VECTOR);

				// Loop
				char sTemp[64];
				SetVariantString("OnUser1 !self:Start::0.0:-1");
				AcceptEntityInput(entity, "AddOutput");
				SetVariantString("OnUser2 !self:Stop::4.0:-1");
				AcceptEntityInput(entity, "AddOutput");
				SetVariantString("OnUser2 !self:FireUser1::4.0:-1");
				AcceptEntityInput(entity, "AddOutput");

				AcceptEntityInput(entity, "FireUser1");
				AcceptEntityInput(entity, "FireUser2");

				// Remove
				Format(sTemp, sizeof(sTemp), "OnUser3 !self:Kill::%f:-1", g_fCvarTime);
				SetVariantString(sTemp);
				AcceptEntityInput(entity, "AddOutput");
				AcceptEntityInput(entity, "FireUser3");

				g_iParticles[client][1] = EntIndexToEntRef(entity);
			}
		}
	}
}

void CreateHat(int client)
{
	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2)
		return;

	int entity = CreateEntityByName("prop_dynamic_override");

	if(g_bLeft4Dead2)
	{
		SetEntityModel(entity, MODEL_mustachio);
	}
	else
	{
		SetEntityModel(entity, MODEL_CONE);
	}
	DispatchSpawn(entity);


	float g_vPos[3];
	float g_vAng[3];
	if(g_bLeft4Dead2)
	{
		g_vPos[0] = -2.0;
		g_vPos[1] = 0.0;
		g_vPos[2] = 5.0;

		g_vAng[0] = 0.0;
		g_vAng[1] = 0.0;
		g_vAng[2] = 0.0;
	}
	else
	{
		g_vPos[0] = -3.0;
		g_vPos[1] = 0.0;
		g_vPos[2] = 10.0;

		g_vAng[0] = 90.0;
		g_vAng[1] = 60.0;
		g_vAng[2] = -40.0;
	}

	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", client);
	SetVariantString("eyes");
	AcceptEntityInput(entity, "SetParentAttachment");

	// Lux
	AcceptEntityInput(entity, "DisableCollision");
	SetEntProp(entity, Prop_Send, "m_noGhostCollision", 1, 1);
	SetEntProp(entity, Prop_Data, "m_CollisionGroup", 0x0004);
	SetEntPropVector(entity, Prop_Send, "m_vecMins", view_as<float>({0.0, 0.0, 0.0}));
	SetEntPropVector(entity, Prop_Send, "m_vecMaxs", view_as<float>({0.0, 0.0, 0.0}));
	// Lux

	TeleportEntity(entity, g_vPos, g_vAng, NULL_VECTOR);
	SetEntProp(entity, Prop_Data, "m_iEFlags", 0);

	// if( g_iCvarOpaq )
	// {
	SetEntityRenderMode(entity, RENDER_NORMAL);
		//SetEntityRenderColor(entity, 255, 255, 255, g_iCvarOpaq);
	if(g_bLeft4Dead2)
		SetEntityRenderColor(entity, 50,205,50);
	else
		SetEntityRenderColor(entity, 255, 0, 0, 255);
	// }

	// if( !g_bHatView[client] )
		// SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmit);

	g_iBoomerHat[client] = entity;

	CreateTimer(20.0, Timer_RemoveHat, client);
	SDKHook(entity, SDKHook_SetTransmit, Hook_SetTransmitHat);
}

public Action Hook_SetTransmitHat(int entity, int client)
{
    if(entity == g_iBoomerHat[client])
    {
		return Plugin_Handled;
	}
    return Plugin_Continue;
}

void CreatePropGlow(int client, int entity)
{
	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2) return;

	if(g_bLeft4Dead2)
	{
		g_iBoomerHatGlow[client] = CreateEntityByName("prop_dynamic_override");
		SetEntityModel(g_iBoomerHatGlow[client], MODEL_mustachio);
		DispatchSpawn(g_iBoomerHatGlow[client]);
		
		SetEntProp(g_iBoomerHatGlow[client], Prop_Send, "m_CollisionGroup", 0);
		SetEntProp(g_iBoomerHatGlow[client], Prop_Send, "m_nSolidType", 0);
		SetEntProp(g_iBoomerHatGlow[client], Prop_Send, "m_nGlowRange", 4500);
		SetEntProp(g_iBoomerHatGlow[client], Prop_Send, "m_iGlowType", 2);
		SetEntProp(g_iBoomerHatGlow[client], Prop_Send, "m_glowColorOverride", GetColor(0,255,0));
		AcceptEntityInput(g_iBoomerHatGlow[client], "StartGlowing");

		SetEntityRenderMode(g_iBoomerHatGlow[client], RENDER_TRANSCOLOR);
		SetEntityRenderColor(g_iBoomerHatGlow[client], 0, 0, 0, 0);
		
		SetVariantString("!activator");
		AcceptEntityInput(g_iBoomerHatGlow[client], "SetParent", client);
		SetVariantString("eyes");
		AcceptEntityInput(g_iBoomerHatGlow[client], "SetParentAttachment");
		
		AcceptEntityInput(g_iBoomerHatGlow[client], "DisableCollision");
		SetEntProp(g_iBoomerHatGlow[client], Prop_Send, "m_noGhostCollision", 1, 1);
		SetEntProp(g_iBoomerHatGlow[client], Prop_Data, "m_CollisionGroup", 0x0004);
		SetEntPropVector(g_iBoomerHatGlow[client], Prop_Send, "m_vecMins", view_as<float>({0.0, 0.0, 0.0}));
		SetEntPropVector(g_iBoomerHatGlow[client], Prop_Send, "m_vecMaxs", view_as<float>({0.0, 0.0, 0.0}));
		
		float vPos[3];
		float vAng[3];
		vPos[0] = -2.0;
		vPos[1] = 0.0;
		vPos[2] = 5.0;

		vAng[0] = 0.0;
		vAng[1] = 0.0;
		vAng[2] = 0.0;
		
		TeleportEntity(g_iBoomerHatGlow[client], vPos, vAng, NULL_VECTOR);
		SetEntProp(g_iBoomerHatGlow[client], Prop_Data, "m_iEFlags", 0);
		SDKHook(g_iBoomerHatGlow[client], SDKHook_SetTransmit, Hook_SetTransmitHatGlow);		
	}
	else
	{
		float vPos[3];
		float vAng[3];

		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vPos);
		GetEntPropVector(entity, Prop_Send, "m_angRotation", vAng);

		g_iBoomerHatGlow[client] = CreateEntityByName("prop_glowing_object");

		DispatchKeyValue(g_iBoomerHatGlow[client], "model", MODEL_CONE);
		DispatchKeyValue(g_iBoomerHatGlow[client], "StartGlowing", "1");
		DispatchKeyValue(g_iBoomerHatGlow[client], "targetname", "propglow");

		DispatchKeyValue(g_iBoomerHatGlow[client], "GlowForTeam", "3");

		/* GlowForTeam =  -1:ALL  , 0:NONE , 1:SPECTATOR  , 2:SURVIVOR , 3:INFECTED */

		DispatchKeyValue(g_iBoomerHatGlow[client], "fadescale", "1");

		TeleportEntity(g_iBoomerHatGlow[client], vPos, vAng, NULL_VECTOR);
		DispatchSpawn(g_iBoomerHatGlow[client]);
		//SetEntityRenderMode( g_iBoomerHatGlow[client], RENDER_GLOW );
		//SetEntityRenderColor (g_iBoomerHatGlow[client], 255,0,0,200 );
		SetEntityRenderFx(g_iBoomerHatGlow[client], RENDERFX_FADE_FAST);
		
		//DispatchKeyValueVector(g_iBoomerHatGlow[client], "origin", vPos);
		//DispatchKeyValueVector(g_iBoomerHatGlow[client], "angles", vAng);

		SetVariantString("!activator");
		AcceptEntityInput(g_iBoomerHatGlow[client], "SetParent", entity);

		float g_vPos[3];
		g_vPos[0] = -3.0;
		g_vPos[1] = 0.0;
		g_vPos[2] = 10.0;

		float g_vAng[3];
		g_vAng[0] = 90.0;
		g_vAng[1] = 60.0;
		g_vAng[2] = -40.0;

		SetVariantString("!activator");
		AcceptEntityInput(g_iBoomerHatGlow[client], "SetParent", client);
		SetVariantString("eyes");
		AcceptEntityInput(g_iBoomerHatGlow[client], "SetParentAttachment");

		TeleportEntity(g_iBoomerHatGlow[client], g_vPos, g_vAng, NULL_VECTOR);
	}
}

public Action Hook_SetTransmitHatGlow(int entity, int client)
{
    if(entity == g_iBoomerHatGlow[client])
    {
		return Plugin_Handled;
	}
    return Plugin_Continue;
}

public Action Timer_RemoveHat(Handle timer, int client)
{
	int entityHat = g_iBoomerHat[client];
	int entityHatGlow = g_iBoomerHatGlow[client];
	g_iBoomerHat[client] = 0;
	g_iBoomerHatGlow[client] = 0;

	if(IsValidEntity(entityHat))
		AcceptEntityInput(entityHat, "kill");
	if(IsValidEntity(entityHatGlow))
		AcceptEntityInput(entityHatGlow, "kill");

	return Plugin_Continue;
}

public Action CmdTrophy(int client, int args)
{
	if( args == 0 )
	{
		CreateEffects(client, false);
	}
	else
	{
		char target_name[MAX_TARGET_LENGTH], arg1[32];
		int target_list[MAXPLAYERS], target_count;
		bool tn_is_ml;

		GetCmdArg(1, arg1, sizeof(arg1));

		if( (target_count = ProcessTargetString(
				arg1,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_ALIVE,
				target_name,
				sizeof(target_name),
				tn_is_ml) ) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}

		for( int i = 0; i < target_count; i++ )
			CreateEffects(target_list[i], false);
	}

	return Plugin_Handled;
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

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}

bool IsPlayerTank(int tank_index)
{
	if(g_bLeft4Dead2)
		return GetEntProp(tank_index, Prop_Send, "m_zombieClass") ==  8;
	else
		return GetEntProp(tank_index, Prop_Send, "m_zombieClass") ==  5;
}

int GetColor(int Colors1,int Colors2,int Colors3)
{
	int color = Colors1;
	color += 256 * Colors2;
	color += 65536 * Colors3;

	return color;
}