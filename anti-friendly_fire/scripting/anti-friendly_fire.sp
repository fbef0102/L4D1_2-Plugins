#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <left4dhooks>

#define CLASSNAME_LENGTH 64

ConVar g_hGod, g_hEnable, g_hFireDisable, g_hPipeBombDisable, g_hDamageShield, g_hIncapProtect;
bool g_bGod, g_bEnable, g_bFireDisable, g_bPipeBombDisable, g_bIncapProtect;
int g_iDamageShield;

public Plugin myinfo = 
{
	name = "anti-friendly_fire",
	author = "HarryPotter",
	description = "shoot teammate = shoot yourself",
	version = "1.3",
	url = "https://steamcommunity.com/profiles/76561198026784913"
}

bool g_bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 && test != Engine_Left4Dead) 
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}

	g_bLate = late;
	return APLRes_Success; 
}

public void OnPluginStart()
{
	g_hGod = FindConVar("god");

	g_hEnable = CreateConVar(	"anti_friendly_fire_enable", "1",
								"Enable anti-friendly_fire plugin [0-Disable,1-Enable]",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );

	g_hFireDisable = CreateConVar(	"anti_friendly_fire_immue_fire", "1",
								"If 1, Disable Fire friendly fire.",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );

	g_hPipeBombDisable = CreateConVar( "anti_friendly_fire_immue_explode", "0",
								"If 1, Disable Pipe Bomb, Propane Tank, and Oxygen Tank Explosive friendly fire.",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );

	g_hDamageShield = CreateConVar( "anti_friendly_fire_damage_sheild", "0",
								"Do not reflect friendly_fire if damage is below this value (0=Off).",
								FCVAR_NOTIFY, true, 0.0);

	g_hIncapProtect = CreateConVar( "anti_friendly_fire_incap_protect", "1",
								"If 1, Disable Friendly Fire if damge is about to incapacitate victim.",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );	

	GetCvars();
	g_hGod.AddChangeHook(ConVarChanged_Cvars);
	g_hEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hFireDisable.AddChangeHook(ConVarChanged_Cvars);
	g_hPipeBombDisable.AddChangeHook(ConVarChanged_Cvars);
	g_hDamageShield.AddChangeHook(ConVarChanged_Cvars);
	g_hIncapProtect.AddChangeHook(ConVarChanged_Cvars);

	AutoExecConfig(true, "anti-friendly_fire");

	HookEvent("player_hurt", Event_Hurt);
	HookEvent("player_incapacitated_start", Event_IncapacitatedStart);

	if(g_bLate)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i)) OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bGod = g_hGod.BoolValue;
	g_bEnable = g_hEnable.BoolValue;
	g_bFireDisable = g_hFireDisable.BoolValue;
	g_bPipeBombDisable = g_hPipeBombDisable.BoolValue;
	g_bIncapProtect = g_hIncapProtect.BoolValue;
	g_iDamageShield = g_hDamageShield.IntValue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(damage <= 0.0 || g_bEnable == false || g_bIncapProtect == false || g_bGod == true) return Plugin_Continue;

	if(attacker == victim ||
		!IsClientAndInGame(attacker)  || 
		!IsClientAndInGame(victim) || 
		GetClientTeam(attacker) != L4D_TEAM_SURVIVOR || 
		GetClientTeam(victim) != L4D_TEAM_SURVIVOR) return Plugin_Continue;

	if(IsClientInGodFrame(victim)) return Plugin_Continue;

	int iHealth = GetClientHealth(victim);
	float fHealth = GetTempHealth(victim);
	//PrintToChatAll("%N attack %N, fHealth: %.2f, iHealth: %d, damage: %.2f", attacker, victim, fHealth, iHealth, damage);
	
	if(fHealth + iHealth <= RoundToFloor(damage)) return Plugin_Handled;

	return Plugin_Continue;
}

public void Event_Hurt(Event event, const char[] name, bool dontBroadcast) 
{
	if(g_bGod) return;

	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int damage = event.GetInt("dmg_health");
	if(g_bEnable == false || 
	attacker == victim || 
	!IsClientAndInGame(attacker) || 
	!IsClientAndInGame(victim) || 
	GetClientTeam(victim) != L4D_TEAM_SURVIVOR || 
	damage <= 0 ||
	damage <= g_iDamageShield) { return; }
	
	
	static char WeaponName[CLASSNAME_LENGTH];
	event.GetString("weapon", WeaponName, sizeof(WeaponName));
	//PrintToChatAll("victim: %d,attacker:%d ,WeaponName is %s, damage is %d",victim,attacker,WeaponName,damage);	
	
	bool bIsSpecialWeapon = false;
	if(IsPipeBombExplode(WeaponName)) 
	{
		bIsSpecialWeapon = true;
		if(g_bPipeBombDisable == false) return;
	}
	else if(IsFire(WeaponName) || IsFireworkcrate(WeaponName))
	{
		bIsSpecialWeapon = true;
		if(g_bFireDisable== false) return;
	}
	
	if(bIsSpecialWeapon)
	{
		if(!IsIncapacitated(victim)) SetEntityHealth(victim, event.GetInt("health") + damage);
	}
	else if(!bIsSpecialWeapon && GetClientTeam(attacker) == L4D_TEAM_SURVIVOR)
	{
		if(!IsIncapacitated(victim)) SetEntityHealth(victim, event.GetInt("health") + damage);
		HurtEntity(attacker, attacker, float(damage));
	}
}

public void Event_IncapacitatedStart(Event event, const char[] name, bool dontBroadcast) 
{
	if(g_bGod) return;

	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if(g_bEnable == false || 
	attacker == victim ||
	!IsClientAndInGame(attacker)  || 
	!IsClientAndInGame(victim) || 
	GetClientTeam(victim) != L4D_TEAM_SURVIVOR) { return; }
	
	int damage = GetClientHealth(victim) + RoundToFloor(GetTempHealth(victim));

	static char WeaponName[CLASSNAME_LENGTH];
	event.GetString("weapon", WeaponName, sizeof(WeaponName));
	//PrintToChatAll("Event_IncapacitatedStart victim: %d, attacker:%d , damage: %d, WeaponName is %s",victim,attacker, damage, WeaponName);	
	
	bool bIsSpecialWeapon = false;
	if(IsPipeBombExplode(WeaponName)) 
	{
		bIsSpecialWeapon = true;
		if(g_bPipeBombDisable == false) return;
	}
	else if(IsFire(WeaponName) || IsFireworkcrate(WeaponName))
	{
		bIsSpecialWeapon = true;
		if(g_bFireDisable== false) return;
	}

	if(!bIsSpecialWeapon && GetClientTeam(attacker) == L4D_TEAM_SURVIVOR)
	{
		HurtEntity(attacker, attacker, float(damage));
	}
}


void HurtEntity(int victim, int client, float damage)
{
	SDKHooks_TakeDamage(victim, client, client, damage, DMG_SLASH);
}

stock bool IsClientAndInGame(int client)
{
	if (0 < client && client <= MaxClients)
	{	
		return IsClientInGame(client);
	}
	return false;
}

stock bool IsFire(char[] classname)
{
	return StrEqual(classname, "inferno");
} 

stock bool IsPipeBombExplode(char[] classname)
{
	return StrEqual(classname, "pipe_bomb");
} 

stock bool IsFireworkcrate(char[] classname)
{
	return StrEqual(classname, "fire_cracker_blast");
} 

stock float GetTempHealth(int client)
{
	static float fCvarDecayRate = -1.0;

	if (fCvarDecayRate == -1.0)
		fCvarDecayRate = FindConVar("pain_pills_decay_rate").FloatValue;

	float fTempHealth = GetEntPropFloat(client, Prop_Send, "m_healthBuffer");
	fTempHealth -= (GetGameTime() - GetEntPropFloat(client, Prop_Send, "m_healthBufferTime")) * fCvarDecayRate;
	return fTempHealth < 0.0 ? 0.0 : fTempHealth;
}

stock void SetTempHealth(int client, float health)
{
	SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
	SetEntPropFloat(client, Prop_Send, "m_healthBuffer", health);
}

bool IsClientInGodFrame( int client )
{
	CountdownTimer timer = L4D2Direct_GetInvulnerabilityTimer(client);
	if(timer == CTimer_Null) return false;

	return (CTimer_GetRemainingTime(timer) > 0.0);
}

bool IsIncapacitated(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated"));
}