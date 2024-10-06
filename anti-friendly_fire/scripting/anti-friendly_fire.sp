#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <left4dhooks>
#include <dhooks>

public Plugin myinfo = 
{
	name = "anti-friendly_fire",
	author = "HarryPotter",
	description = "shoot teammate = shoot yourself",
	version = "1.8-2024/8/6",
	url = "https://steamcommunity.com/profiles/76561198026784913"
}

bool g_bLate, g_bL4D2Version;
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

	g_bLate = late;
	return APLRes_Success; 
}

#define CLASSNAME_LENGTH 64

ConVar g_hGod,
	g_hEnable, g_hFireDisable, g_hPipeBombDisable, g_hGLDisable, g_hDamageShield, g_hDamageMulti;
bool g_bGod, g_bEnable, g_bFireDisable, g_bPipeBombDisable, g_bGLDisable;
int g_iDamageShield;
float g_fDamageMulti;

methodmap GameDataWrapper < GameData {
	public GameDataWrapper(const char[] file) {
		GameData gd = new GameData(file);
		if (!gd) SetFailState("Missing gamedata \"%s\"", file);
		return view_as<GameDataWrapper>(gd);
	}
	public DynamicDetour CreateDetourOrFail(
			const char[] name,
			DHookCallback preHook = INVALID_FUNCTION,
			DHookCallback postHook = INVALID_FUNCTION) {
		DynamicDetour hSetup = DynamicDetour.FromConf(this, name);
		if (!hSetup)
			SetFailState("Missing detour setup \"%s\"", name);
		if (preHook != INVALID_FUNCTION && !hSetup.Enable(Hook_Pre, preHook))
			SetFailState("Failed to pre-detour \"%s\"", name);
		if (postHook != INVALID_FUNCTION && !hSetup.Enable(Hook_Post, postHook))
			SetFailState("Failed to post-detour \"%s\"", name);
		return hSetup;
	}
}

enum struct CTakeDamageInfo_L4D1
{
	float			m_vecDamageForce[3];
	float			m_vecDamagePosition[3];
	float			m_vecReportedPosition[3];	// Position players are told damage is coming from
	
	int				m_hInflictor;
	int				m_hAttacker;
	
	float			m_flDamage;
	float			m_flMaxDamage;
	float			m_flBaseDamage;			// The damage amount before skill leve adjustments are made. Used to get uniform damage forces.
	
	int				m_bitsDamageType;
	int				m_iDamageCustom;
	int				m_iDamageStats;
	int				m_iAmmoType;			// AmmoType of the weapon used to cause this damage, if any
}

enum struct CTakeDamageInfo_L4D2
{
	float			m_vecDamageForce[3];
	float			m_vecDamagePosition[3];
	float			m_vecReportedPosition[3];	// Position players are told damage is coming from
	float			m_vecUnknown[3];
	
	int				m_hInflictor;
	int				m_hAttacker;
	int				m_hWeapon;
	
	float			m_flDamage;
	float			m_flMaxDamage;
	float			m_flBaseDamage;			// The damage amount before skill leve adjustments are made. Used to get uniform damage forces.
	
	int				m_bitsDamageType;
	int				m_iDamageCustom;
	int				m_iDamageStats;
	int				m_iAmmoType;			// AmmoType of the weapon used to cause this damage, if any
	
	float			m_flRadius;
}

int 
	g_iMainHealth[MAXPLAYERS+1];

float 
	g_fTempHealth[MAXPLAYERS+1];

StringMap 
	g_smIgnoreClassName;

public void OnPluginStart()
{
	GameDataWrapper gamedata = new GameDataWrapper("anti_friendly_fire");
	delete gamedata.CreateDetourOrFail("CTerrorPlayer::AllowDamage", DTR__AllowDamage);
	delete gamedata;

	g_hGod = FindConVar("god");

	g_hEnable = CreateConVar(	"anti_friendly_fire_enable", "1",
								"Enable Plugin [0-Disable,1-Enable]",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );

	g_hFireDisable = CreateConVar(	"anti_friendly_fire_immue_fire", "1",
								"1=Disable Molotov, Gascan and Firework Crate friendly fire damage and don't reflect damage\n0=Enable friendly fire damage",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );

	g_hPipeBombDisable = CreateConVar( "anti_friendly_fire_immue_explode", "0",
								"1=Disable Pipe Bomb, Propane Tank, and Oxygen Tank Explosive friendly fire and don't reflect damage\n0=Enable friendly fire damage",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );

	if(g_bL4D2Version)
	{
		g_hGLDisable = CreateConVar( "anti_friendly_fire_immue_GL", "0",
								"(L4D2) 1=Disable Grenade Launcher friendly fire and reflect damage\n0=Enable friendly fire damage",
								FCVAR_NOTIFY, true, 0.0, true, 1.0 );
	}

	g_hDamageShield = CreateConVar( "anti_friendly_fire_damage_sheild", "0",
								"Disable friendly fire damage and don't reflect damage if damage is below this value. (0=Off)",
								FCVAR_NOTIFY, true, 0.0);

	g_hDamageMulti = CreateConVar( "anti_friendly_fire_damage_multi", "1.5",
								"Multiply friendly fire damage value and reflect to attacker. (1.0=original damage value)",
								FCVAR_NOTIFY, true, 1.0 );	

	GetCvars();
	g_hGod.AddChangeHook(ConVarChanged_Cvars);
	g_hEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hFireDisable.AddChangeHook(ConVarChanged_Cvars);
	g_hPipeBombDisable.AddChangeHook(ConVarChanged_Cvars);
	if(g_bL4D2Version) g_hGLDisable.AddChangeHook(ConVarChanged_Cvars);
	g_hDamageShield.AddChangeHook(ConVarChanged_Cvars);
	g_hDamageMulti.AddChangeHook(ConVarChanged_Cvars);

	AutoExecConfig(true, "anti-friendly_fire");

	HookEvent("player_hurt", Event_Hurt);
	//HookEvent("player_incapacitated_start", Event_IncapacitatedStart);

	g_smIgnoreClassName = new StringMap();
	g_smIgnoreClassName.SetValue("insect_swarm", true); // Vomitjar Puddle Spit: https://forums.alliedmods.net/showthread.php?p=2789012

	if(g_bLate)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i)) OnClientPutInServer(i);
		}
	}
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bGod = g_hGod.BoolValue;
	g_bEnable = g_hEnable.BoolValue;
	g_bFireDisable = g_hFireDisable.BoolValue;
	g_bPipeBombDisable = g_hPipeBombDisable.BoolValue;
	if(g_bL4D2Version) g_bGLDisable = g_hGLDisable.BoolValue;
	g_iDamageShield = g_hDamageShield.IntValue;
	g_fDamageMulti = g_hDamageMulti.FloatValue;
}

public void OnClientPutInServer(int client)
{
	//SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
}

// 不可偵測到SDKHooks_TakeDamage，此時玩家未扣血
/*Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(damage <= 0.0 || g_bEnable == false || g_bGod == true) return Plugin_Continue;

	if(attacker == victim ||
		!IsClientAndInGame(attacker)  || 
		!IsClientAndInGame(victim) || 
		GetClientTeam(attacker) == L4D_TEAM_INFECTED ||
		GetClientTeam(victim) != L4D_TEAM_SURVIVOR) return Plugin_Continue;

	if(IsClientInGodFrame(victim)) return Plugin_Continue;

	// 最後實際傷害為"浮點數的傷害數值的整數", 小數點後無條件捨去
	// 但是如果浮點數的傷害大於等於生命值, 依然倒地或死亡
	int iDamage = RoundToFloor(damage);
	if(iDamage <= g_iDamageShield) return Plugin_Handled; 

	//PrintToChatAll("%N attack %N, temp Health: %d, main Health: %d, damage: %d", attacker, victim, L4D_GetPlayerTempHealth(victim), GetClientHealth(victim), iDamage);
	if( GetClientHealth(victim) + L4D_GetPlayerTempHealth(victim) <= iDamage + 1) //倒地或死亡
	{
		if(inflictor > MaxClients && IsValidEntity(inflictor))
		{
			static char WeaponName[CLASSNAME_LENGTH];
			GetEntityClassname(inflictor, WeaponName, sizeof(WeaponName));
			//PrintToChatAll("WeaponName: %s", WeaponName);	
			
			bool bIsSpecialWeapon = false;
			if(IsPipeBombExplode_OnTakeDamage(WeaponName)) 
			{
				bIsSpecialWeapon = true;
				if(g_bPipeBombDisable == false) return Plugin_Continue;
			}
			else if(IsFire(WeaponName) || IsFireworkcrate(WeaponName))
			{
				bIsSpecialWeapon = true;
				if(g_bFireDisable== false) return Plugin_Continue;
			}
			else if(g_bL4D2Version && IsGLExplode(WeaponName)) 
			{
				//bIsSpecialWeapon = true;
				if(g_bGLDisable == false) return Plugin_Continue;
			}
		}
		
		if(!bIsSpecialWeapon && GetClientTeam(attacker) == L4D_TEAM_SURVIVOR)
		{
			if(GetClientTeam(attacker) == L4D_TEAM_SURVIVOR) 
				HurtEntity(attacker, attacker, damage);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}*/

//檢測不到玩家即將死亡 (非倒地)
/*public Action L4D_OnIncapacitated(int client, int &inflictor, int &attacker, float &damage, int &damagetype)
{
	if(damage <= 0.0 || g_bEnable == false || g_bGod == true) return Plugin_Continue;

	if(attacker == client ||
		!IsClientAndInGame(attacker)  || 
		!IsClientAndInGame(client) || 
		GetClientTeam(attacker) == L4D_TEAM_INFECTED ||
		GetClientTeam(client) != L4D_TEAM_SURVIVOR) return Plugin_Continue;

	if(IsClientInGodFrame(client)) return Plugin_Continue;

	//PrintToChatAll("L4D_OnIncapacitated %N attack %N, temp Health: %d, main Health: %d, damage: %f", attacker, client, L4D_GetPlayerTempHealth(client), GetClientHealth(client), damage);
	
	if(inflictor > MaxClients && IsValidEntity(inflictor))
	{
		static char WeaponName[CLASSNAME_LENGTH];
		GetEntityClassname(inflictor, WeaponName, sizeof(WeaponName));
		//PrintToChatAll("WeaponName: %s", WeaponName);	
		
		bool bIsSpecialWeapon = false;
		if(IsPipeBombExplode_OnTakeDamage(WeaponName)) 
		{
			bIsSpecialWeapon = true;
			if(g_bPipeBombDisable == false) return Plugin_Continue;
		}
		else if(IsFire(WeaponName) || IsFireworkcrate(WeaponName))
		{
			bIsSpecialWeapon = true;
			if(g_bFireDisable== false) return Plugin_Continue;
		}
		else if(g_bL4D2Version && IsGLExplode(WeaponName)) 
		{
			//bIsSpecialWeapon = true;
			if(g_bGLDisable == false) return Plugin_Continue;
		}
	}
	
	if(!bIsSpecialWeapon && GetClientTeam(attacker) == L4D_TEAM_SURVIVOR)
	{
		if(GetClientTeam(attacker) == L4D_TEAM_SURVIVOR) 
			HurtEntity(attacker, attacker, damage);
	}

	return Plugin_Handled;
}*/

// 如果傷害造成玩家即將倒地，不會觸發此涵式
// 如果傷害造成玩家即將死亡，會觸發此涵式
// 可偵測到SDKHooks_TakeDamage，此時玩家未扣血
// 使用return Plugin_Handled; 依然會有螢幕上的紅色傷害提示，只是角色不會因為受傷而說話
Action OnTakeDamageAlive(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if(g_bEnable == false || g_bGod == true) return Plugin_Continue;

	if(attacker == victim ||
		!IsClientAndInGame(attacker)  || 
		!IsClientAndInGame(victim) || 
		GetClientTeam(attacker) == L4D_TEAM_INFECTED ||
		GetClientTeam(victim) != L4D_TEAM_SURVIVOR) return Plugin_Continue;

	g_iMainHealth[victim] = GetClientHealth(victim);
	g_fTempHealth[victim] = L4D_GetTempHealth(victim);

	/*if(damage <= 0.0) return Plugin_Continue;
	if(IsClientInGodFrame(victim)) return Plugin_Continue;

	// 最後實際傷害為"浮點數的傷害數值的整數", 小數點後無條件捨去
	// 但是如果浮點數的傷害大於等於生命值, 依然倒地或死亡
	int iDamage = RoundToFloor(damage);
	if(iDamage <= g_iDamageShield) return Plugin_Handled; 

	//PrintToChatAll("%N attack %N, temp Health: %d, main Health: %d, damage: %d", attacker, victim, L4D_GetPlayerTempHealth(victim), g_iMainHealth[victim], iDamage);
	if( g_iMainHealth[victim] + L4D_GetPlayerTempHealth(victim) <= iDamage + 1) //死亡
	{
		if(inflictor > MaxClients && IsValidEntity(inflictor))
		{
			static char WeaponName[CLASSNAME_LENGTH];
			GetEntityClassname(inflictor, WeaponName, sizeof(WeaponName));
			//PrintToChatAll("WeaponName: %s", WeaponName);
			
			bool bIsSpecialWeapon = false;
			if(IsPipeBombExplode_OnTakeDamage(WeaponName)) 
			{
				bIsSpecialWeapon = true;
				if(g_bPipeBombDisable == false) return Plugin_Continue;
			}
			else if(IsFire(WeaponName) || IsFireworkcrate(WeaponName))
			{
				bIsSpecialWeapon = true;
				if(g_bFireDisable== false) return Plugin_Continue;
			}
			else if(g_bL4D2Version && IsGLExplode(WeaponName)) 
			{
				//bIsSpecialWeapon = true;
				if(g_bGLDisable == false) return Plugin_Continue;
			}
		}
		
		// 當浮點數的傷害略等於生命值且受害者已經是黑白狀態時，實血會變成0，改傷害或return Plugin_Handled 通通沒用 ¯\_(ツ)_/¯ 依然死亡（需將實血health變成1 避免死亡）
		if(g_iMainHealth[victim] == 0) SetEntProp(victim, Prop_Data, "m_iHealth", 1);

		if(!bIsSpecialWeapon && GetClientTeam(attacker) == L4D_TEAM_SURVIVOR)
		{
			if(GetClientTeam(attacker) == L4D_TEAM_SURVIVOR) 
				HurtEntity(attacker, attacker, damage);
		}

		return Plugin_Handled;
	}*/

	return Plugin_Continue;
}

//沒有倒地的傷害順序: SDKHook_OnTakeDamage -> DTR__AllowDamage -> SDKHook_OnTakeDamageAlive -> "player_hurt" event -> SDKHook_OnTakeDamageAlivePost -> SDKHook_OnTakeDamagePost
//會倒地的傷害順序: SDKHook_OnTakeDamage -> DTR__AllowDamage (return MRES_Ignored) -> "player_incapacitated_start" event -> "player_incapacitated" event -> SDKHook_OnTakeDamagePost
//會倒地的傷害順序: SDKHook_OnTakeDamage -> DTR__AllowDamage (return MRES_Supercede) -> SDKHook_OnTakeDamagePost
//會死亡(非倒地)的傷害順序: SDKHook_OnTakeDamage -> DTR__AllowDamage (return MRES_Ignored) -> SDKHook_OnTakeDamageAlive -> "player_hurt" event -> SDKHook_OnTakeDamageAlivePost -> "player_death" event -> SDKHook_OnTakeDamagePost
//會死亡(非倒地)的傷害順序: SDKHook_OnTakeDamage -> DTR__AllowDamage (return MRES_Supercede) -> SDKHook_OnTakeDamagePost

//可偵測到SDKHooks_TakeDamage，此時玩家還沒倒地
//@note 在這涵式內使用SDKHooks_TakeDamage會崩潰
MRESReturn DTR__AllowDamage(int client, DHookReturn hReturn, DHookParam hParams)
{
	if (g_bEnable == false || g_bGod == true ) return MRES_Ignored;

	int attacker, inflictor, damagetype;
	float damage;
	if(g_bL4D2Version)
	{
		attacker 	= hParams.GetObjectVar(1, CTakeDamageInfo_L4D2::m_hAttacker *4, ObjectValueType_Ehandle);
		inflictor 	= hParams.GetObjectVar(1, CTakeDamageInfo_L4D2::m_hInflictor *4, ObjectValueType_Ehandle);
		damage 		= hParams.GetObjectVar(1, CTakeDamageInfo_L4D2::m_flDamage *4, ObjectValueType_Float);
		damagetype	= hParams.GetObjectVar(1, CTakeDamageInfo_L4D2::m_bitsDamageType *4, ObjectValueType_Int);
	}
	else
	{
		attacker 	= hParams.GetObjectVar(1, CTakeDamageInfo_L4D1::m_hAttacker *4, ObjectValueType_Ehandle);
		inflictor 	= hParams.GetObjectVar(1, CTakeDamageInfo_L4D1::m_hInflictor *4, ObjectValueType_Ehandle);
		damage 		= hParams.GetObjectVar(1, CTakeDamageInfo_L4D1::m_flDamage *4, ObjectValueType_Float);
		damagetype	= hParams.GetObjectVar(1, CTakeDamageInfo_L4D1::m_bitsDamageType *4, ObjectValueType_Int);
	}

	if (damage <= 0.0 ||
		attacker == client ||
		!IsClientAndInGame(attacker)  || 
		!IsClientAndInGame(client) || 
		GetClientTeam(attacker) == L4D_TEAM_INFECTED ||
		GetClientTeam(client) != L4D_TEAM_SURVIVOR) return MRES_Ignored;

	if(IsClientInGodFrame(client)) return MRES_Ignored;

	//PrintToChatAll("DTR__AllowDamage %N attack %N, temp Health: %d, main Health: %d, damage: %f", attacker, client, L4D_GetPlayerTempHealth(client), GetClientHealth(client), damage);
	
	bool bIsSpecialWeapon = false;
	if(inflictor > MaxClients && IsValidEntity(inflictor))
	{
		static char WeaponName[CLASSNAME_LENGTH];
		GetEntityClassname(inflictor, WeaponName, sizeof(WeaponName));
		//PrintToChatAll("WeaponName: %s", WeaponName);	
		if(g_smIgnoreClassName.ContainsKey(WeaponName) == true) return MRES_Ignored;

		if( (damagetype & DMG_BURN) && !(damagetype & DMG_BULLET) )
		{
			bIsSpecialWeapon = true;
			if(g_bFireDisable== false) return MRES_Ignored;
		}
		else if(strncmp(WeaponName, "pipe_bomb_projectile", 20, false) == 0) 
		{
			bIsSpecialWeapon = true;
			if(g_bPipeBombDisable == false) return MRES_Ignored;
		}
		else if(g_bL4D2Version && strncmp(WeaponName, "grenade_launcher_projectile", 27, false) == 0 ) 
		{
			if(g_bGLDisable == false) return MRES_Ignored;
		}
	}
	
	if(!bIsSpecialWeapon && GetClientTeam(attacker) == L4D_TEAM_SURVIVOR)
	{
		DataPack hPack = new DataPack();
		hPack.WriteCell(GetClientUserId(attacker));
		hPack.WriteFloat(damage);
		RequestFrame(OnNextFrame_HurtDamage, hPack);
	}

	hReturn.Value = 0;
	return MRES_Supercede;
}

void OnNextFrame_HurtDamage(DataPack hPack)
{
	hPack.Reset();
	int attacker = GetClientOfUserId(hPack.ReadCell());
	float damage = hPack.ReadFloat();
	delete hPack;

	HurtEntity(attacker, attacker, damage);
}

void Event_Hurt(Event event, const char[] name, bool dontBroadcast) 
{
	if(g_bEnable == false || g_bGod == true) return;

	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	int damage = event.GetInt("dmg_health");
	int damagetype = event.GetInt("type");
	if(attacker == victim || 
	!IsClientAndInGame(attacker) || 
	!IsClientAndInGame(victim) || 
	GetClientTeam(victim) != L4D_TEAM_SURVIVOR || 
	GetClientTeam(attacker) == L4D_TEAM_INFECTED ||
	!IsPlayerAlive(victim) || 
	damage <= 0 ||
	damage <= g_iDamageShield) { return; }
	
	static char WeaponName[CLASSNAME_LENGTH];
	event.GetString("weapon", WeaponName, sizeof(WeaponName));
	//PrintToChatAll("victim: %N, attacker:%N , WeaponName: %s, damage: %d", victim, attacker, WeaponName, damage);
	if(g_smIgnoreClassName.ContainsKey(WeaponName) == true) return;
	
	bool bIsSpecialWeapon = false;
	if( (damagetype & DMG_BURN) && !(damagetype & DMG_BULLET) )
	{
		bIsSpecialWeapon = true;
		if(g_bFireDisable== false) return;
	}
	else if(strncmp(WeaponName, "pipe_bomb", 20, false) == 0) 
	{
		bIsSpecialWeapon = true;
		if(g_bPipeBombDisable == false) return;
	}
	else if(g_bL4D2Version && strncmp(WeaponName, "grenade_launcher_projectile", 27, false) == 0 ) 
	{
		//bIsSpecialWeapon = true;
		if(g_bGLDisable == false) return;
	}
	
	if(bIsSpecialWeapon)
	{
		if(!IsIncapacitated(victim)) RestoreHp(victim);
	}
	else
	{
		if(!IsIncapacitated(victim)) RestoreHp(victim);
		if(GetClientTeam(attacker) == L4D_TEAM_SURVIVOR) HurtEntity(attacker, attacker, float(damage));
	}
}

/*void Event_IncapacitatedStart(Event event, const char[] name, bool dontBroadcast) 
{
	if(g_bGod) return;

	int victim = GetClientOfUserId(event.GetInt("userid"));
	int attacker = GetClientOfUserId(event.GetInt("attacker"));
	if(g_bEnable == false || 
	attacker == victim ||
	!IsClientAndInGame(attacker)  || 
	!IsClientAndInGame(victim) || 
	GetClientTeam(attacker) == L4D_TEAM_INFECTED ||
	GetClientTeam(victim) != L4D_TEAM_SURVIVOR) { return; }
	
	int health = GetClientHealth(victim) + L4D_GetPlayerTempHealth(victim);

	static char WeaponName[CLASSNAME_LENGTH];
	event.GetString("weapon", WeaponName, sizeof(WeaponName));
	//PrintToChatAll("Event_IncapacitatedStart victim: %d, attacker:%d , health: %d, WeaponName is %s",victim,attacker, health, WeaponName);	
	
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

	if(!bIsSpecialWeapon)
	{
		if(GetClientTeam(attacker) == L4D_TEAM_SURVIVOR) HurtEntity(attacker, attacker, float(health));
	}
}*/

void HurtEntity(int victim, int client, float damage)
{
	SDKHooks_TakeDamage(victim, client, client, damage * g_fDamageMulti, DMG_SLASH);
}

bool IsClientAndInGame(int client)
{
	if (0 < client && client <= MaxClients)
	{	
		return IsClientInGame(client);
	}
	return false;
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

void RestoreHp(int client)
{
	//PrintToChatAll("%d %.2f", g_iMainHealth[client], g_fTempHealth[client]);
	SetEntityHealth(client, g_iMainHealth[client]);
	L4D_SetTempHealth(client, g_fTempHealth[client]);
}