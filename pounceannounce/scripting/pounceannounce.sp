#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <multicolors>

//globals
ConVar hMaxPounceDistance;
ConVar hMinPounceDistance;
ConVar hMaxPounceDamage;
//hunter position store
float infectedPosition[32][3]; //support up to 32 slots on a server
//cvars
ConVar hMinPounceAnnounce;
ConVar hCenterChat;
ConVar hShowDistance;
ConVar hCapDamage;
ConVar hKillDamage;
int ConVar_maxdmg,ConVar_max,ConVar_min;

#define DEBUG 0

//For variable types of pounce display
enum PounceDistanceDisplay
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
	version = "1.8",
	url = "http://forums.alliedmods.net/showthread.php?t=93605"
}

public void OnPluginStart()
{
	hMaxPounceDistance = FindConVar("z_pounce_damage_range_max");
	hMinPounceDistance = FindConVar("z_pounce_damage_range_min");
	hMaxPounceDamage = FindConVar("z_hunter_max_pounce_bonus_damage");
	hMinPounceAnnounce = CreateConVar("pounceannounce_minimum","0","The minimum amount of damage required to announce the pounce", FCVAR_NOTIFY);
	hCenterChat = CreateConVar("pounceannounce_centerchat","0","Announces the pounce to 0: chatbox, 1: center chat.",FCVAR_NOTIFY);
	hShowDistance = CreateConVar("pounceannounce_showdistance","3","Show the distance the hunter traveled for the pounce.",FCVAR_NOTIFY);
	hCapDamage = CreateConVar("pounceannounce_capdamage","0","Caps the displayed pounce damage to the maximum able to be dealt.",FCVAR_NOTIFY);
	hKillDamage = CreateConVar("pounceannounce_killdamage","0","The minimum amount of damage required to instantly kill survivor.(0=Off)",FCVAR_NOTIFY);

	ConVar_maxdmg = hMaxPounceDamage.IntValue;
	ConVar_max = hMaxPounceDistance.IntValue;
	ConVar_min = hMinPounceDistance.IntValue;
	hMaxPounceDamage.AddChangeHook(Convar_MaxPounceDamage);
	hMaxPounceDistance.AddChangeHook(Convar_Max);
	hMinPounceDistance.AddChangeHook(Convar_Min);
	
	HookEvent("lunge_pounce",Event_PlayerPounced);
	HookEvent("ability_use",Event_AbilityUse);

	AutoExecConfig(true,"pounceannounce");
}

public void Convar_MaxPounceDamage (ConVar convar, const char[] oldValue, const char[] newValue)
{
	ConVar_maxdmg = hMaxPounceDamage.IntValue;
}

public void Convar_Max(ConVar convar, const char[] oldValue, const char[] newValue)
{
	ConVar_max = hMaxPounceDistance.IntValue;
}
public void Convar_Min(ConVar convar, const char[] oldValue, const char[] newValue)
{
	ConVar_min = hMinPounceDistance.IntValue;
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
	int minAnnounce = hMinPounceAnnounce.IntValue;
	bool centerChat = hCenterChat.BoolValue;
	
	char attackerName[MAX_NAME_LENGTH];
	char victimName[MAX_NAME_LENGTH];
	char pounceLine[256];
	char distanceBuffer[64];
	
	int showDistance;
	//distance supplied isn't the actual 2d vector distance needed for damage calculation. See more about it at
	//http://forums.alliedmods.net/showthread.php?t=93207
	//int eventDistance = event.GetInt("distance");
	
	//get hunter-related pounce cvars
	int max = ConVar_max;
	int min = ConVar_min;
	int maxDmg = ConVar_maxdmg;
	
	//Get current position while pounced
	GetClientAbsOrigin(attackerClient,pouncePosition);
	
	//Calculate 2d distance between previous position and pounce position
	int distance = RoundToNearest(GetVectorDistance(infectedPosition[attackerClient], pouncePosition));
	
	//Get damage using hunter damage formula
	//damage in this is expressed as a float because my server has competitive hunter pouncing where the decimal counts
	float dmg = (((distance - float(min)) / float(max - min)) * float(maxDmg)) + 1;
	float killdamage = hKillDamage.FloatValue;
	
	//Check if calculate damage is higher than max, and cap to max.
	if(hCapDamage.BoolValue && dmg > maxDmg)
		dmg = float(maxDmg) + 1;
	
	if(distance >= min && dmg >= minAnnounce)
	{
		GetClientName(attackerClient,attackerName,sizeof(attackerName));
		GetClientName(victimClient,victimName,sizeof(victimName));
		#if DEBUG
		PrintToServer("Pounce: max: %d min: %d dmg: %d dist: %d dmg: %.01f",max,min,maxDmg,distance, dmg);
		#endif
		Format(pounceLine,sizeof(pounceLine),"\x04[SM] %s \x01高撲 \x05%s \x01造成了 \x03%.01f \x01傷害.(最大: \x04%d\x01)",attackerName,victimName,dmg,maxDmg + 1);
		
		showDistance = hShowDistance.IntValue;
		if(showDistance > 0)
		{
			switch(showDistance)
			{
				case (view_as<int>(Units)):
				{
					Format(distanceBuffer,sizeof(distanceBuffer)," 距離 %d 單位",distance);
				}
				case (view_as<int>(UnitsAndFeet)):
				{ //units / 16 = feet in game
					Format(distanceBuffer,sizeof(distanceBuffer)," 距離 %d 單位 (%d 呎)",distance, distance / 16);
				}
				case (view_as<int>(UnitsAndMeters)):
				{	//0.0213 = conversion rate for units to meters
					Format(distanceBuffer,sizeof(distanceBuffer)," 距離 %d 單位 (%.0f 公尺)",distance, distance * 0.0213);
				}
				case (view_as<int>(Feet)):
				{
					Format(distanceBuffer,sizeof(distanceBuffer)," 距離 %d 呎", distance / 16); 
				}
				case (view_as<int>(Meters)):
				{
					Format(distanceBuffer,sizeof(distanceBuffer)," 距離 %.0f 公尺", distance * 0.0213);
				}
			}
			StrCat(pounceLine,sizeof(pounceLine),distanceBuffer);
		}

		if(centerChat)
			PrintHintTextToAll(pounceLine);
		else
			CPrintToChatAll(pounceLine);

		//PrintToChatAll("killdamage: %f, dmg, %f, victimClient: %N", killdamage, dmg, victimClient);
		if(killdamage != 0.0 && killdamage <= dmg)
		{
			ForcePlayerSuicide(victimClient);
			CPrintToChatAll("\x04[SM] %N \x01的高撲對 \x05%N \x01造成了致命一擊");
		}	
	}
}