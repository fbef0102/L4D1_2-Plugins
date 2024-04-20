#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <multicolors>


ConVar g_hMaxPounceDistance, g_hMinPounceDistance, g_hMaxPounceDamage;
int g_iMaxPounceDistance, g_iMinPounceDistance, g_iMaxPounceDamage;


ConVar g_hMinPounceAnnounce, g_hCenterChat, g_hShowDistance, g_hCapDamage, g_hKillDamage;
int g_iMinPounceAnnounce, g_iCenterChat, g_iShowDistance, g_iKillDamage;
bool g_bCapDamage;


float infectedPosition[MAXPLAYERS +1][3]; //support up to 32 slots on a server

#define DEBUG 0

//For variable types of pounce display
enum
{
	None = 0, 
	Units = 1, 
	UnitsAndFeet = 2,
	UnitsAndMeters = 3,
	Feet = 4,
	Meters = 5
}

public Plugin myinfo = 
{
	name = "Pounce Announce",
	author = "n0limit & HarryPotter",
	description = "Announces hunter pounces to the entire server",
	version = "1.9",
	url = "http://forums.alliedmods.net/showthread.php?t=93605"
}

public void OnPluginStart()
{
	g_hMinPounceAnnounce 	= CreateConVar("pounceannounce_minimum",		"10",	"The minimum amount of damage required to announce the pounce", FCVAR_NOTIFY, true, 0.0);
	g_hCenterChat 			= CreateConVar("pounceannounce_centerchat",		"0",	"Announces the pounce to 0: chatbox, 1: center chat.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hShowDistance 		= CreateConVar("pounceannounce_showdistance",	"3",	"Show the distance the hunter traveled for the pounce.\n1=units, 2=units & feet, 3=units & meters, 4=feet, 5=meters", FCVAR_NOTIFY, true, 0.0, true, 5.0);
	g_hCapDamage 			= CreateConVar("pounceannounce_capdamage",		"0",	"Caps the displayed pounce damage to the maximum able to be dealt.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hKillDamage 			= CreateConVar("pounceannounce_killdamage",		"0",	"The minimum amount of damage required to instantly kill survivor. (0=Off)", FCVAR_NOTIFY, true, 0.0);
	AutoExecConfig(true, "pounceannounce");

	GetCvars();
	g_hMinPounceAnnounce.AddChangeHook(ConVarChanged_Cvars);
	g_hCenterChat.AddChangeHook(ConVarChanged_Cvars);
	g_hShowDistance.AddChangeHook(ConVarChanged_Cvars);
	g_hCapDamage.AddChangeHook(ConVarChanged_Cvars);
	g_hKillDamage.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("lunge_pounce", 	Event_PlayerPounced);
	HookEvent("ability_use", 	Event_AbilityUse);
}

public void OnAllPluginsLoaded()
{
	g_hMaxPounceDistance = FindConVar("z_pounce_damage_range_max");
	g_hMinPounceDistance = FindConVar("z_pounce_damage_range_min");
	g_hMaxPounceDamage = FindConVar("z_hunter_max_pounce_bonus_damage");

	if ( g_hMaxPounceDistance == null ) { g_hMaxPounceDistance 	= CreateConVar( "z_pounce_damage_range_max",  			"1000.0", 	"Not available on this server, added by pounceannounce.", FCVAR_NONE, true, 0.0, false ); }
	if ( g_hMinPounceDistance == null ) { g_hMinPounceDistance 	= CreateConVar( "z_pounce_damage_range_min",  			"300.0", 	"Not available on this server, added by pounceannounce.", FCVAR_NONE, true, 0.0, false ); }
	if ( g_hMaxPounceDamage == null ) 	{ g_hMaxPounceDamage 	= CreateConVar( "z_hunter_max_pounce_bonus_damage", 	"24", 		"Not available on this server, added by pounceannounce.", FCVAR_NONE, true, 0.0, false ); }
	
	GetPounceCvars();
	g_hMaxPounceDistance.AddChangeHook(ConVarChanged_PounceCvars);
	g_hMinPounceDistance.AddChangeHook(ConVarChanged_PounceCvars);
	g_hMaxPounceDamage.AddChangeHook(ConVarChanged_PounceCvars);
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_iMinPounceAnnounce 	= g_hMinPounceAnnounce.IntValue;
	g_iCenterChat 			= g_hCenterChat.IntValue;
	g_iShowDistance 		= g_hShowDistance.IntValue;
	g_bCapDamage 			= g_hCapDamage.BoolValue;
	g_iKillDamage 			= g_hKillDamage.IntValue;
}

void ConVarChanged_PounceCvars (ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetPounceCvars();
}

void GetPounceCvars()
{
	g_iMaxPounceDistance = g_hMaxPounceDistance.IntValue;
	g_iMinPounceDistance = g_hMinPounceDistance.IntValue;
	g_iMaxPounceDamage = g_hMaxPounceDamage.IntValue;
}

public void Event_AbilityUse(Event event, const char[] name, bool dontBroadcast) 
{
	int user = GetClientOfUserId(event.GetInt("userid"));
	
	//Save the location of the player who just used an infected ability
	GetClientAbsOrigin(user,infectedPosition[user]);
	
	#if DEBUG
	char playerName[MAX_NAME_LENGTH];
	char ability[256];
	GetClientName(user, playerName, sizeof(playerName));
	GetEventString(event, "ability", ability, sizeof(ability));
	PrintToChatAll("%s -> %s: %s (%.1f %.1f %.1f)", name, playerName, ability, infectedPosition[user][0], infectedPosition[user][1], infectedPosition[user][2]);
	#endif 
}

public void Event_PlayerPounced(Event event, const char[] name, bool dontBroadcast) 
{
	float pouncePosition[3];
	int attackerId = event.GetInt("userid");
	int victimId = event.GetInt("victim");
	int attackerClient = GetClientOfUserId(attackerId);
	int victimClient = GetClientOfUserId(victimId);
	
	char attackerName[MAX_NAME_LENGTH];
	char victimName[MAX_NAME_LENGTH];
	char pounceLine[256];
	char distanceBuffer[64];
	
	//distance supplied isn't the actual 2d vector distance needed for damage calculation. See more about it at
	//http://forums.alliedmods.net/showthread.php?t=93207
	//int eventDistance = event.GetInt("distance");
	
	//Get current position while pounced
	GetClientAbsOrigin(attackerClient,pouncePosition);
	
	//Calculate 2d distance between previous position and pounce position
	int distance = RoundToNearest(GetVectorDistance(infectedPosition[attackerClient], pouncePosition));
	
	//Get damage using hunter damage formula
	//damage in this is expressed as a float because my server has competitive hunter pouncing where the decimal counts
	float dmg = (((distance - float(g_iMinPounceDistance)) / float(g_iMaxPounceDistance - g_iMinPounceDistance)) * float(g_iMaxPounceDamage)) + 1;
	
	//Check if calculate damage is higher than max, and cap to max.
	if(g_bCapDamage && dmg > g_iMaxPounceDamage)
		dmg = float(g_iMaxPounceDamage) + 1;
	
	if(distance >= g_iMinPounceDistance && dmg >= g_iMinPounceAnnounce)
	{
		GetClientName(attackerClient,attackerName,sizeof(attackerName));
		GetClientName(victimClient,victimName,sizeof(victimName));
		#if DEBUG
			PrintToServer("Pounce: max: %d min: %d dmg: %d dist: %d dmg: %.01f",g_iMaxPounceDistance,g_iMinPounceDistance,g_iMaxPounceDamage,distance, dmg);
		#endif
		FormatEx(pounceLine,sizeof(pounceLine),"\x04[SM] %s \x01pounced \x05%s \x01for \x03%.01f \x01damage.(Max: \x04%d\x01)", attackerName,victimName,dmg,g_iMaxPounceDamage + 1);
		
		if(g_iShowDistance > 0)
		{
			switch(g_iShowDistance)
			{
				case (Units):
				{
					Format(distanceBuffer,sizeof(distanceBuffer)," over %d units",distance);
				}
				case (UnitsAndFeet):
				{ //units / 16 = feet in game
					Format(distanceBuffer,sizeof(distanceBuffer)," over %d units (%d feet)",distance, distance / 16);
				}
				case (UnitsAndMeters):
				{	//0.0213 = conversion rate for units to meters
					Format(distanceBuffer,sizeof(distanceBuffer)," over %d units (%.0f meters)",distance, distance * 0.0213);
				}
				case (Feet):
				{
					Format(distanceBuffer,sizeof(distanceBuffer)," over %d feet", distance / 16); 
				}
				case (Meters):
				{
					Format(distanceBuffer,sizeof(distanceBuffer)," over %.0f meters", distance * 0.0213);
				}
			}
			StrCat(pounceLine,sizeof(pounceLine),distanceBuffer);
		}

		if(g_iCenterChat == 0)
			CPrintToChatAll(pounceLine);
		else if(g_iCenterChat == 1)
			PrintHintTextToAll(pounceLine);
	}


	//PrintToChatAll("killdamage: %f, dmg, %f, victimClient: %N", g_iKillDamage, dmg, victimClient);
	if(g_iKillDamage != 0.0 && g_iKillDamage <= dmg)
	{
		ForcePlayerSuicide(victimClient);
		CPrintToChatAll("\x04[SM] %N\x01's high pounce causes \x05%N\x01 instant kill!", attackerClient, victimClient);
	}
}