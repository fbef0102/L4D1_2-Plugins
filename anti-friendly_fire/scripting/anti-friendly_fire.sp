#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define CLASSNAME_LENGTH 64
#define L4D_TEAM_SURVIVOR

ConVar g_hEnable, g_hFireDisable, g_hPipeBombDisable;

public Plugin myinfo = 
{
	name = "anti-friendly_fire",
	author = "HarryPotter",
	description = "shoot teammate = shoot yourself",
	version = "1.1",
	url = "https://steamcommunity.com/id/fbef0102/"
}

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
	g_hEnable = CreateConVar(	"anti_friendly_fire_enable", "1",
								"Enable anti-friendly_fire plugin [0-Disable,1-Enable]",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );

	g_hFireDisable = CreateConVar(	"anti_friendly_fire_immue_fire", "1",
								"If 1, Disable Fire friendly fire.",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );

	g_hPipeBombDisable = CreateConVar( "anti_friendly_fire_immue_pipebomb", "0",
								"If 1, Disable Pipe Bomb Explosive friendly fire.",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );

	HookEvent("player_hurt", Event_PlayerHurt);

	AutoExecConfig(true, "anti-friendly_fire");
}	

public Action Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int damage = event.GetInt("dmg_health");
	if(g_hEnable.BoolValue == false || !IsClientAndInGame(attacker)  || !IsClientAndInGame(victim) || GetClientTeam(victim)!=2 || attacker == victim || damage <=0) { return Plugin_Continue; }
	
	char WeaponName[CLASSNAME_LENGTH];
	event.GetString("weapon", WeaponName, sizeof(WeaponName));
	//PrintToChatAll("victim: %d,attacker:%d ,WeaponName is %s, damage is %d",victim,attacker,WeaponName,damage);	
	
	bool bIsSpecialWeapon = false;
	if(IsPipeBombExplode(WeaponName)) 
	{
		bIsSpecialWeapon = true;
		if(g_hPipeBombDisable.BoolValue == false) return Plugin_Continue;
	}
	else if(IsFire(WeaponName) || IsFireworkcrate(WeaponName))
	{
		bIsSpecialWeapon = true;
		if(g_hFireDisable.BoolValue == false) return Plugin_Continue;
	}
	
	if(bIsSpecialWeapon)
	{
		int health = event.GetInt("health");
		SetEntityHealth(victim, health + damage);
	}
	else if(!bIsSpecialWeapon && GetClientTeam(attacker) == 2)
	{
		int health = event.GetInt("health");
		SetEntityHealth(victim, health + damage);
		HurtEntity(attacker, attacker, float(damage));
	}
	
	return Plugin_Changed;
}

void HurtEntity(int victim, int client, float damage)
{
	SDKHooks_TakeDamage(victim, client, client, damage, DMG_SLASH);
}

stock bool IsClientAndInGame(int client)
{
	if (0 < client && client < MaxClients)
	{	
		return IsClientInGame(client);
	}
	return false;
}

bool IsFire(char[] classname)
{
	return StrEqual(classname, "inferno");
} 

bool IsPipeBombExplode(char[] classname)
{
	return StrEqual(classname, "pipe_bomb");
} 

bool IsFireworkcrate(char[] classname)
{
	return StrEqual(classname, "fire_cracker_blast");
} 