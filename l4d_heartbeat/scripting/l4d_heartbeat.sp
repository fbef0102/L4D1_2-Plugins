/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define PLUGIN_VERSION 		"1.0h-2024/10/3"

public Plugin myinfo =
{
	name = "[L4D1/2] Heartbeat (Revive & BW Fix)",
	author = "SilverShot, Harry",
	description = "Fixes survivor_max_incapacitated_count cvar increased values reverting black and white screen.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=322132"
}

bool g_bLeft4Dead2, bLate;
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

	CreateNative("Heartbeat_GetRevives", Native_GetRevives);
	CreateNative("Heartbeat_SetRevives", Native_SetRevives);

	RegPluginLibrary("l4d_heartbeat");

	return APLRes_Success;
}

#define CVAR_FLAGS			FCVAR_NOTIFY
#define SOUND_HEART			"player/heartbeatloop.wav"
#define DEBUG				0

ConVar g_hCvarMaxIncap, g_hCvarDecay;
float g_fDecayDecay;
int g_iCvarRevives;

ConVar g_hCvarEnable;
bool g_bCvarEnable;

int g_iReviveCount[MAXPLAYERS+1];
bool g_bHookedDamage[MAXPLAYERS+1];
bool g_bIsGoingToDie[MAXPLAYERS+1];

public void OnPluginStart()
{
	g_hCvarDecay = FindConVar("pain_pills_decay_rate");
	g_hCvarMaxIncap = FindConVar("survivor_max_incapacitated_count");

	g_hCvarEnable =			CreateConVar(	"l4d_heartbeat_enable",			"1",				"0=Plugin off, 1=Plugin on.", CVAR_FLAGS );
	CreateConVar(							"l4d_heartbeat_version",		PLUGIN_VERSION,		"Heartbeat plugin version.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	AutoExecConfig(true,					"l4d_heartbeat");

	GetCvars();
	g_hCvarDecay.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarMaxIncap.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("bot_player_replace",		Event_BotReplace);
	HookEvent("player_bot_replace",		Event_ReplaceBot);
	HookEvent("player_death",			Event_Spawned);
	HookEvent("player_spawn",			Event_Spawned);
	HookEvent("heal_success",			Event_Healed);
	HookEvent("revive_success",			Event_Revive);

	AddCommandListener(CommandListener, "give");

	if(bLate)
	{
		for( int i = 1; i <= MaxClients; i++ )
		{
			if( IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) )
			{
				g_iReviveCount[i] = GetEntProp(i, Prop_Send, "m_currentReviveCount");

				if( !g_bHookedDamage[i] && g_iReviveCount[i] >= g_iCvarRevives )
				{
					g_bHookedDamage[i] = true;
					SDKHook(i, g_bLeft4Dead2 ? SDKHook_OnTakeDamageAlive : SDKHook_OnTakeDamage, OnTakeDamage);
					SDKHook(i, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
				}
			}
		}
	}
}

// Cvars-------------------------------

void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_iCvarRevives = g_hCvarMaxIncap.IntValue;

	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_fDecayDecay = g_hCvarDecay.FloatValue;
}

// Command-------------------------------

// won't trigger if sv_cheats is 0
Action CommandListener(int client, const char[] command, int args)
{
	if(!g_bCvarEnable) return Plugin_Continue;

	if( args > 0 )
	{
		char buffer[8];
		GetCmdArg(1, buffer, sizeof(buffer));

		if( strcmp(buffer, "health") == 0 )
		{
			ResetCount(client);
		}
	}

	return Plugin_Continue;
}

// Sourcemod API Forward-------------------------------

public void OnMapStart()
{
	PrecacheSound(SOUND_HEART);
}

// Event-------------------------------

void Event_BotReplace(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_bCvarEnable) return;

	int client = GetClientOfUserId(event.GetInt("player"));
	int bot = GetClientOfUserId(event.GetInt("bot"));
	if( client )
	{
		ResetSound(client);
		ResetSound(client);
		ResetSound(client);
		ResetSoundObs(client);
	}

	g_iReviveCount[client] = g_iReviveCount[bot];
}

void Event_ReplaceBot(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_bCvarEnable) return;

	int client = GetClientOfUserId(event.GetInt("player"));
	int bot = GetClientOfUserId(event.GetInt("bot"));

	g_iReviveCount[bot] = g_iReviveCount[client];
}

void Event_Spawned(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_bCvarEnable) return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	if( client )
	{
		ResetCount(client);
		ResetSound(client);
		ResetSound(client);
		ResetSound(client);
		ResetSoundObs(client);
	}
}

void Event_Healed(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_bCvarEnable) return;

	int client = GetClientOfUserId(event.GetInt("subject"));
	ResetCount(client);
}

void Event_Revive(Event event, const char[] name, bool dontBroadcast)
{
	if(!g_bCvarEnable) return;

	int userid;
	if( (userid = event.GetInt("subject")) && event.GetInt("ledge_hang") == 0 )
	{
		int client = GetClientOfUserId(userid);
		if( client )
		{
			// 等待FakeClientCommand(client, "give health");
			RequestFrame(OnFrameRevive, userid);
		}
	}
}

// SDKHooks-------------------------------

void OnTakeDamagePost(int client, int attacker, int inflictor, float damage, int damagetype, int weapon, float damageForce[3], float damagePosition[3])
{
	if(!g_bCvarEnable) return;

	// Prevent yelling
	//if( g_iReviveCount[client] < g_iCvarVocal )
	if( g_iReviveCount[client] < g_iCvarRevives && g_iCvarRevives > 0 )
	{
		g_bIsGoingToDie[client] = GetEntProp(client, Prop_Send, "m_isGoingToDie") == 1;

		if( g_bIsGoingToDie[client] )
		{
			SetEntProp(client, Prop_Send, "m_isGoingToDie", 0);
		}
	}
}

Action OnTakeDamage(int client, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(!g_bCvarEnable) return Plugin_Continue;

	// Prevent yelling
	//if( g_iReviveCount[client] < g_iCvarVocal )
	if( g_iReviveCount[client] < g_iCvarRevives && g_iCvarRevives > 0 )
	{
		if( g_bIsGoingToDie[client] )
		{
			SetEntProp(client, Prop_Send, "m_isGoingToDie", 1);
		}
	}

	// Allow to die
	if( g_iReviveCount[client] >= g_iCvarRevives )
	{
		int health = GetClientHealth(client) + RoundToFloor(GetTempHealth(client));

		if( health <= 0.0 || (!g_bLeft4Dead2 && health - damage < 0.0) )
		{
			// PrintToServer("Heartbeat: Allow die %N (%d/%d)", client, g_iReviveCount[client], g_iCvarRevives);
			ResetSoundObs(client);
			ResetSound(client);

			// Allow to die
			if( g_bLeft4Dead2 )
				SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 1);
			else
				SetEntProp(client, Prop_Send, "m_currentReviveCount", g_iCvarRevives);

			// Unhook
			if( g_bHookedDamage[client] )
			{
				g_bHookedDamage[client] = false;
				SDKUnhook(client, g_bLeft4Dead2 ? SDKHook_OnTakeDamageAlive : SDKHook_OnTakeDamage, OnTakeDamage);
				SDKUnhook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
			}
		}
	}

	return Plugin_Continue;
}

// Timer & Frame-------------------------------

void OnFrameRevive(int client)
{
	client = GetClientOfUserId(client);
	if( client && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) )
	{
		g_iReviveCount[client] = GetEntProp(client, Prop_Send, "m_currentReviveCount");
		ReviveLogic(client);
	}
}

void OnFrameSound(int client)
{
	client = GetClientOfUserId(client);
	if( client )
	{
		ResetSound(client);
	}
}

Action TimerSound(Handle timer, int client)
{
	client = GetClientOfUserId(client);
	if( client )
	{
		EmitSoundToClient(client, SOUND_HEART, SOUND_FROM_PLAYER, SNDCHAN_STATIC);
	}

	return Plugin_Continue;
}

// Others-------------------------------

void ReviveLogic(int client)
{
	// PrintToServer("Revives: %N (%d)", client, g_iReviveCount[client]);

	// Monitor for death
	if( !g_bHookedDamage[client] && g_iReviveCount[client] >= g_iCvarRevives )
	{
		g_bHookedDamage[client] = true;
		SDKHook(client, g_bLeft4Dead2 ? SDKHook_OnTakeDamageAlive : SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	}

	if( g_bLeft4Dead2 )
	{
		SetEntProp(client, Prop_Send, "m_currentReviveCount", g_iReviveCount[client]);
	}

	// Set black and white or not
	//if( g_iReviveCount[client] >= g_iCvarScreen )
	if( g_iReviveCount[client] >= g_iCvarRevives )
	{
		if( g_bLeft4Dead2 )
			SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 1);
		else
			SetEntProp(client, Prop_Send, "m_currentReviveCount", 2);
	} else {
		if( g_bLeft4Dead2 )
			SetEntProp(client, Prop_Send, "m_bIsOnThirdStrike", 0);
		else
			SetEntProp(client, Prop_Send, "m_currentReviveCount", g_iReviveCount[client] == 2 ? 1 : g_iReviveCount[client]);
	}

	// Vocalize death
	if( g_iReviveCount[client] < g_iCvarRevives )
	{
		if( !g_bHookedDamage[client] )
		{
			g_bHookedDamage[client] = true;
			SDKHook(client, g_bLeft4Dead2 ? SDKHook_OnTakeDamageAlive : SDKHook_OnTakeDamage, OnTakeDamage);
			SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
		}

		SetEntProp(client, Prop_Send, "m_isGoingToDie", 0);
	}

	// Heartbeat sound, stop dupe sound bug, only way.
	RequestFrame(OnFrameSound, GetClientUserId(client));
	ResetSound(client);
	ResetSound(client);
	ResetSound(client);
	ResetSound(client);
	ResetSoundObs(client);

	if( g_iReviveCount[client] >= g_iCvarRevives )
	{
		// if( g_bLeft4Dead2 && fromEvent && g_iReviveCount[client] == g_iCvarRevives ) return; // Game emits itself, would duplicate sound even with stop... Seems to work fine now with multiple resets..?
		CreateTimer(0.1, TimerSound, GetClientUserId(client));
	}
}

void ResetSoundObs(int client)
{
	for( int i = 1; i <= MaxClients; i++ )
	{
		if( IsClientInGame(i) && !IsPlayerAlive(i) && GetEntPropEnt(i, Prop_Send, "m_hObserverTarget") == client )
		{
			RequestFrame(OnFrameSound, GetClientUserId(i));
			ResetSound(i);
			ResetSound(i);
			ResetSound(i);
			ResetSound(i);
		}
	}
}

void ResetSound(int client)
{
	StopSound(client, SNDCHAN_AUTO, SOUND_HEART);
	StopSound(client, SNDCHAN_STATIC, SOUND_HEART);
}

void ResetCount(int client)
{
	g_bIsGoingToDie[client] = false;
	g_iReviveCount[client] = 0;
	ResetSoundObs(client);
	ResetSound(client);

	if( g_bHookedDamage[client] )
	{
		g_bHookedDamage[client] = false;
		SDKUnhook(client, g_bLeft4Dead2 ? SDKHook_OnTakeDamageAlive : SDKHook_OnTakeDamage, OnTakeDamage);
		SDKUnhook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	}
}

float GetTempHealth(int client)
{
	float fHealth = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	fHealth -= (GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * g_fDecayDecay;
	return fHealth < 0.0 ? 0.0 : fHealth;
}

// Native-------------------------------

int Native_GetRevives(Handle plugin, int numParams)
{
	return g_iReviveCount[GetNativeCell(1)];
}

int Native_SetRevives(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	g_iReviveCount[client] = GetNativeCell(2);

	if( numParams != 3 || GetNativeCell(3) )
	{
		ReviveLogic(client);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_currentReviveCount", g_iReviveCount[client]);
	}

	return 0;
}