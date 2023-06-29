#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <multicolors>

public Plugin myinfo = 
{
	name = "l4d_limit_weapon",
	author = "Harry Potter",
	description = "As the name says, you dumb fuck!",
	version = "1.0",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_Left4Dead )
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1.");
        return APLRes_SilentFailure;
    }

    bLate = late;
    return APLRes_Success;
}

#define TEAM_SURVIVOR 2

char WEAPON_HUNTING_RIFLE[]			= "weapon_hunting_rifle";
char WEAPON_AUTOSHOTGUN[]			= "weapon_autoshotgun";
char WEAPON_RIFLE[]					= "weapon_rifle";
char WEAPON_PUMPSHOTGUN[]			= "weapon_pumpshotgun";
char WEAPON_SMG[]					= "weapon_smg";

ConVar g_hLimitHuntingRifle_Cvar;
ConVar g_hLimitAutoShotgun_Cvar;
ConVar g_hLimitRifle_Cvar;
ConVar g_hLimitPumpShotgun_Cvar;
ConVar g_hLimitSmg_Cvar;
int g_iLimitHuntingRifle			= 1;
int g_iLimitAutoShotgun				= 1;
int g_iLimitRifle					= 1;
int g_iLimitPumpShotgun				= 1;
int g_iLimitSmg						= 1;

float TIP_TIMEOUT					= 8.0;
bool g_bHaveTipped[MAXPLAYERS + 1] 	= {false};

public void OnPluginStart()
{
	g_hLimitHuntingRifle_Cvar = CreateConVar("l4d1_weapon_limitshuntingrifle", "1", "Maximum of hunting rifles the survivors can pick up. [-1:No limit]", FCVAR_NOTIFY);
	g_hLimitAutoShotgun_Cvar = CreateConVar("l4d1_weapon_limitsautoshotgun", "1", "Maximum of autoshotguns the survivors can pick up. [-1:No limit]", FCVAR_NOTIFY);
	g_hLimitRifle_Cvar = CreateConVar("l4d1_weapon_limitsrifle", "1", "Maximum of rifles the survivors can pick up. [-1:No limit]", FCVAR_NOTIFY);
	g_hLimitPumpShotgun_Cvar = CreateConVar("l4d1_weapon_limitspumpshotgun", "4", "Maximum of pumpshotguns the survivors can pick up. [-1:No limit]", FCVAR_NOTIFY);
	g_hLimitSmg_Cvar  = CreateConVar("l4d1_weapon_limitssmg", "3", "Maximum of smgs the survivors can pick up. [-1:No limit]", FCVAR_NOTIFY);
	AutoExecConfig(true, "l4d1_weapon_limits");

	GetCvars();
	g_hLimitHuntingRifle_Cvar.AddChangeHook(ConVarChanged_Cvars);
	g_hLimitAutoShotgun_Cvar.AddChangeHook(ConVarChanged_Cvars);
	g_hLimitRifle_Cvar.AddChangeHook(ConVarChanged_Cvars);
	g_hLimitPumpShotgun_Cvar.AddChangeHook(ConVarChanged_Cvars);
	g_hLimitSmg_Cvar.AddChangeHook(ConVarChanged_Cvars);


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

}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_iLimitHuntingRifle = g_hLimitHuntingRifle_Cvar.IntValue;
	g_iLimitAutoShotgun = g_hLimitAutoShotgun_Cvar.IntValue;
	g_iLimitRifle = g_hLimitRifle_Cvar.IntValue;
	g_iLimitPumpShotgun = g_hLimitPumpShotgun_Cvar.IntValue;
	g_iLimitSmg = g_hLimitSmg_Cvar.IntValue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, _LHR_OnWeaponCanUse);
}

Action _LHR_OnWeaponCanUse(int client, int weapon)
{
	if (GetClientTeam(client) != TEAM_SURVIVOR) return Plugin_Continue;
	
	static char classname[128];
	GetEdictClassname(weapon, classname, sizeof(classname));
	//LogMessage("%N: %s",client,classname);
	if (!(StrEqual(classname, WEAPON_HUNTING_RIFLE)||
			StrEqual(classname, WEAPON_AUTOSHOTGUN)||
			StrEqual(classname, WEAPON_RIFLE) ||
			StrEqual(classname, WEAPON_PUMPSHOTGUN)||
			StrEqual(classname, WEAPON_SMG))) return Plugin_Continue;

	static char curclassname[128];
	int curWeapon = GetPlayerWeaponSlot(client, 0); // Get current primary weapon
	if (curWeapon != -1 && IsValidEntity(curWeapon))
	{
		GetEdictClassname(curWeapon, curclassname, sizeof(curclassname));
		if (StrEqual(curclassname, classname))
		{
			return Plugin_Continue; // Survivor already got Same Weapons and trying to pick up a ammo refill, allow it
		}
	}

	if(StrEqual(classname, WEAPON_HUNTING_RIFLE)){
		if (GetActiveWeapons(WEAPON_HUNTING_RIFLE) >= g_iLimitHuntingRifle && g_iLimitHuntingRifle >=0) // If ammount of active hunting rifles are at the limit
		{
			if (!IsFakeClient(client) && !g_bHaveTipped[client])
			{
				g_bHaveTipped[client] = true;
				if (g_iLimitHuntingRifle > 0)
				{
					CPrintToChat(client, "[{olive}TS{default}] The maximum amount of {lightgreen}Hunting Rifle{default} is {green}%d{default}.", g_iLimitHuntingRifle);
				}
				else
				{
					CPrintToChat(client, "[{olive}TS{default}] {lightgreen}Hunting Rifle{default} is not allowed.");
				}
				CreateTimer(TIP_TIMEOUT, _LHR_Tip_Timer, client);
			}
			CheatCommand(client, "give", "ammo");//_EF_DoAmmoPilesFix(client,false);
			return Plugin_Handled; // Dont allow survivor picking up the hunting rifle
		}
	}
	else if(StrEqual(classname, WEAPON_AUTOSHOTGUN)){
		if (GetActiveWeapons(WEAPON_AUTOSHOTGUN) >= g_iLimitAutoShotgun && g_iLimitAutoShotgun >=0)
		{
			if (!IsFakeClient(client) && !g_bHaveTipped[client])
			{
				g_bHaveTipped[client] = true;
				if (g_iLimitAutoShotgun > 0)
				{
					CPrintToChat(client, "[{olive}TS{default}] The maximum amount of {lightgreen}Auto Shotgun{default} is {green}%d{default}.", g_iLimitAutoShotgun);
					if(!StrEqual(curclassname,"weapon_pumpshotgun"))
					{
						if (g_iLimitPumpShotgun == -1 || g_iLimitPumpShotgun > GetActiveWeapons(WEAPON_PUMPSHOTGUN)) 
						{
							CheatCommand(client,"give", "pumpshotgun");
						}
					}
				}
				else
				{
					CPrintToChat(client, "[{olive}TS{default}] {lightgreen}Auto Shotgun{default} is not allowed.");
				}
				CreateTimer(TIP_TIMEOUT, _LHR_Tip_Timer, client);
			}
			CheatCommand(client, "give", "ammo");//_EF_DoAmmoPilesFix(client,false);
			return Plugin_Handled; // Dont allow survivor picking up the auto shotgun
		}
	}
	else if(StrEqual(classname, WEAPON_RIFLE)){
		if (GetActiveWeapons(WEAPON_RIFLE) >= g_iLimitRifle && g_iLimitRifle >=0)
		{
			if (!IsFakeClient(client) && !g_bHaveTipped[client])
			{
				g_bHaveTipped[client] = true;
				if (g_iLimitRifle > 0)
				{
					CPrintToChat(client, "[{olive}TS{default}] The maximum amount of {lightgreen}Rifle{default} is {green}%d{default}.", g_iLimitRifle);
					if(!StrEqual(curclassname,"weapon_smg"))
					{
						if (g_iLimitSmg == -1 || g_iLimitSmg > GetActiveWeapons(WEAPON_SMG)) 
						{
							CheatCommand(client,"give", "smg");
						}
					}
				}
				else
				{
					CPrintToChat(client, "[{olive}TS{default}] {lightgreen}Rifle{default} is not allowed.");
				}
				CreateTimer(TIP_TIMEOUT, _LHR_Tip_Timer, client);
			}
			CheatCommand(client, "give", "ammo");//_EF_DoAmmoPilesFix(client,false);
			return Plugin_Handled; // Dont allow survivor picking up the rifle
		}
	}
	else if(StrEqual(classname, WEAPON_PUMPSHOTGUN)){
		if (GetActiveWeapons(WEAPON_PUMPSHOTGUN) >= g_iLimitPumpShotgun && g_iLimitPumpShotgun >=0) 
		{
			if (!IsFakeClient(client) && !g_bHaveTipped[client])
			{
				g_bHaveTipped[client] = true;
				if (g_iLimitPumpShotgun > 0)
				{
					CPrintToChat(client, "[{olive}TS{default}] The maximum amount of {lightgreen}Pump Shotgun{default} is {green}%d{default}.", g_iLimitPumpShotgun);
				}
				else
				{
					CPrintToChat(client, "[{olive}TS{default}] {lightgreen}Pump Shotgun{default} is not allowed.");
				}
				CreateTimer(TIP_TIMEOUT, _LHR_Tip_Timer, client);
			}
			CheatCommand(client, "give", "ammo");//_EF_DoAmmoPilesFix(client,false);
			return Plugin_Handled; // Dont allow survivor picking up the pumpshotgun
		}
	}
	else if(StrEqual(classname, WEAPON_SMG)){
		if (GetActiveWeapons(WEAPON_SMG) >= g_iLimitSmg && g_iLimitSmg >=0) 
		{
			if (!IsFakeClient(client) && !g_bHaveTipped[client])
			{
				g_bHaveTipped[client] = true;
				if (g_iLimitSmg > 0)
				{
					CPrintToChat(client, "[{olive}TS{default}] The maximum amount of {lightgreen}Smg{default} is {green}%d{default}.", g_iLimitSmg);
				}
				else
				{
					CPrintToChat(client, "[{olive}TS{default}] {lightgreen}Smg{default} is not allowed.");
				}
				CreateTimer(TIP_TIMEOUT, _LHR_Tip_Timer, client);
			}
			CheatCommand(client, "give", "ammo");//_EF_DoAmmoPilesFix(client,false);
			return Plugin_Handled; // Dont allow survivor picking up the smg
		}
	}
	return Plugin_Continue;
}

Action _LHR_Tip_Timer(Handle timer, int client)
{
	g_bHaveTipped[client] = false;
	return Plugin_Continue;
}

int  GetActiveWeapons(const char[] WEAPON_NAME)
{
	int weapon;
	static char classname[128];
	int count;
	for (int client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || GetClientTeam(client) != TEAM_SURVIVOR || !IsPlayerAlive(client)) continue;
		weapon = GetPlayerWeaponSlot(client, 0); // Get primary weapon
		if (weapon == -1 || !IsValidEntity(weapon)) continue;

		GetEdictClassname(weapon, classname, sizeof(classname));
		if (!(StrEqual(classname, WEAPON_NAME))) continue;
		count++;
	}
	return count;
}

void CheatCommand(int client, char[] command, char[] arguments = "")
{
	int userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, flags);
	if(IsClientInGame(client)) SetUserFlagBits(client, userFlags);
}