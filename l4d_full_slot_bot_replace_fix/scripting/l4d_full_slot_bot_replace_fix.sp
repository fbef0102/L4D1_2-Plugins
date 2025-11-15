/**
 * SourceMod is licensed under the GNU General Public License, version 3.  
 */

/**
 * l4d_fix_bot_replace by Forgetest 變體插件
 */

/**
 * 當真人玩家
 * 1. 倖存者然後要切換陣營時，會有bot生成並取代倖存者，但因為伺服器滿位子，bot生成失敗導致倖存者直接消失
 *  - 連同身上的武器與物資直接消失
 * 裝了此插件之後: 
 * 	- 被控時才會處死倖存者再換隊
 *  - 沒被控的時強制掉落身上所有武器與物資，不處死直接消失
 * 
 * 2. 活著的特感然後要切換陣營或變成Tank時，會有bot生成並取代特感，但因為伺服器滿位子，bot生成失敗導致特感直接消失
 *  - 如果特感此時正在控人會導致bug，被控的倖存者會卡住無法動彈，倖存者會處於正在被控的階段
 *  - 如果Charger此時正在帶人衝撞且變成Tank時會導致bug，被控的倖存者會卡在Tank身上
 * 裝了此插件之後: 
 *  - 直接處死特感再換隊
 *  - 靈魂特感忽略
 * 
 * 3. 作為活著的Tank失去控制權時，會有bot生成並取代Tank，但因為伺服器滿位子，bot生成失敗導致Tank直接消失
 *  - 目前沒發現有甚麼bug
 * 裝了此插件之後: 
 *  - 直接處死Tank再失去控制權
 * 
 * 4. (新增) 特感Bots接管玩家後，如果沒有控倖存者則直接處死並踢出
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <dhooks>
#include <left4dhooks>

#define PLUGIN_VERSION			"1.1h-2025/11/8"
#define PLUGIN_NAME			    "l4d_full_slot_bot_replace_fix"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "[L4D1/2] Fix No Bot Replace Bot",
	author = "Forgetest, Harry",
	description = "Fix bugs if not enough slots to spawn bots to take over + Kick Previously human-controlled SI bots",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

#define GAMEDATA_FILE           PLUGIN_NAME

#define ZC_SMOKER		1
#define ZC_BOOMER		2
#define ZC_HUNTER		3
#define ZC_SPITTER		4
#define ZC_JOCKEY		5
#define ZC_CHARGER		6

#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar g_hCvarEnable, g_hBotKickDelay;
bool g_bCvarEnable;
float g_fBotKickDelay;

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

int ZC_TANK;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test == Engine_Left4Dead )
    {
        ZC_TANK = 5;
    }
    else if( test == Engine_Left4Dead2 )
    {
        ZC_TANK = 8;
    }
    else
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

int 
	iOffs_m_hSecondaryHiddenWeaponPreDead = -1,
	iOffs_m_SecondaryWeaponDoublePistolPreDead = -1,
	iOffs_m_SecondaryWeaponIDPreDead = -1;

public void OnPluginStart()
{
	iOffs_m_SecondaryWeaponIDPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 108; //死前所持副武器weapon ID
	iOffs_m_SecondaryWeaponDoublePistolPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 112; //死前所持副武器是否双持手槍
	iOffs_m_hSecondaryHiddenWeaponPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 116; //死前所持非手枪副武器EHandle

	GameDataWrapper gd = new GameDataWrapper(PLUGIN_NAME);
	delete gd.CreateDetourOrFail("SurvivorReplacement::Save", DTR_PlayerReplacement_Save);
	delete gd.CreateDetourOrFail("ZombieReplacement::Save", DTR_PlayerReplacement_Save);
	delete gd;

	g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",        	"1",   	"0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hBotKickDelay 	= CreateConVar( PLUGIN_NAME ... "_kick_delay", 		"0.1", 	"How long should we wait before kicking infected bots after bots replace infected player? (Won't kick tank bot)\n0: Don't Kick", CVAR_FLAGS, true, 0.0);
	AutoExecConfig(true,                PLUGIN_NAME);

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hBotKickDelay.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_bot_replace", 	PlayerBotReplace);
}

public void OnAllPluginsLoaded()
{
	if(MaxClients < 31)
	{
		SetFailState("Your maxplayers is not 31, please go install L4dtoolz: https://github.com/lakwsh/l4dtoolz/releases, and set launch parameter: +sv_setmax 31 -maxplayers 31");
		return;
	}

	if(MaxClients > 31)
	{
		SetFailState("Maxplayers can not be set over 31, please set launch parameter: +sv_setmax 31 -maxplayers 31");
		return;
	}
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_fBotKickDelay = g_hBotKickDelay.FloatValue;
}

// Event-------------------------------

void PlayerBotReplace(Event hEvent, const char[] eName, bool dontBroadcast)
{
	if(!g_bCvarEnable || g_fBotKickDelay <= 0.0) return;

	int iUserID = hEvent.GetInt("bot");
	int iBot = GetClientOfUserId(iUserID);

	if (IsClientInGame(iBot) && GetClientTeam(iBot) == L4D_TEAM_INFECTED && IsFakeClient(iBot)) 
	{
		CreateTimer(g_fBotKickDelay, Timer_KillBotDelay, iUserID, TIMER_FLAG_NO_MAPCHANGE);
	}
}

// dhooks-------------------------------

MRESReturn DTR_PlayerReplacement_Save(DHookParam hParams)
{
	if (!g_bCvarEnable || hParams.IsNull(1))
		return MRES_Ignored;
	
	int client = hParams.Get(1);
	if (!IsClientInGame(client) || IsFakeClient(client))
		return MRES_Ignored;

	if (GetClientCount(false) < MaxClients)
		return MRES_Ignored;

	switch(GetClientTeam(client))
	{
		case TEAM_SURVIVOR:
		{
			if(L4D_GetPinnedInfected(client) <= 0)
			{
				int active = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
				int weapon;
				for( int i = 4; i >= 0; i-- )
				{
					if(i == 1 && L4D_IsPlayerIncapacitated(client))
					{
						if(active == GetPlayerWeaponSlot(client, 1)) active = -1;

						weapon = GetSecondaryHiddenWeaponPreDead(client);
						if( weapon > MaxClients && active != weapon && GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity") == client )
						{
							SDKHooks_DropWeapon(client, weapon);
							SetSecondaryWeaponIDPreDead(client, 1);
							SetSecondaryWeaponDoublePistolPreDead(client, 0);
							SetSecondaryHiddenWeapon(client, -1);
							continue;
						}
					}
					
					weapon = GetPlayerWeaponSlot(client, i);
					
					if( weapon > MaxClients && active != weapon && GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity") == client )
					{
						SDKHooks_DropWeapon(client, weapon);
					}
				}
				
				if( active != -1 )
				{
					SDKHooks_DropWeapon(client, active);
				}

				return MRES_Ignored;
			}
			else
			{
				// nothing
			}
		}
		case TEAM_INFECTED:
		{
			if(L4D_IsPlayerGhost(client)) return MRES_Ignored;
		}
	}

	//PrintToServer("%N Suicide, not enough slot for bot taking over", client);
	
	ForcePlayerSuicide(client);

	CleanMusic(client);

	return MRES_Supercede;
}

// Timer-------------------------------

Action Timer_KillBotDelay(Handle hTimer, any iUserID)
{
	if(!g_bCvarEnable) return Plugin_Continue;

	int iBot = GetClientOfUserId(iUserID);
	if (iBot && IsClientInGame(iBot) && IsPlayerAlive(iBot) && ShouldBeKicked(iBot)) 
	{
		ForcePlayerSuicide(iBot);
		KickClient(iBot, "bot");
	}

	return Plugin_Continue;
}

// Others-------------------------------

bool ShouldBeKicked(int iBot)
{
	if (GetClientTeam(iBot) == TEAM_INFECTED)
	{
		int iZombieClassType = GetEntProp(iBot, Prop_Send, "m_zombieClass");

		if (iZombieClassType == ZC_TANK) return false;
	}

	return true;
}

void CleanMusic(int client)
{
	L4D_StopMusic(client, "Event.SurvivorDeath");
	L4D_StopMusic(client, "Event.ScenarioLose");
}

int GetSecondaryHiddenWeaponPreDead(int client)
{
	return GetEntDataEnt2(client, iOffs_m_hSecondaryHiddenWeaponPreDead);
}

void SetSecondaryWeaponIDPreDead(int client, int data)
{
	SetEntData(client, iOffs_m_SecondaryWeaponIDPreDead, data);
}

void SetSecondaryWeaponDoublePistolPreDead(int client, int data)
{
	SetEntData(client, iOffs_m_SecondaryWeaponDoublePistolPreDead, data);
}

void SetSecondaryHiddenWeapon(int client, int data)
{
	SetEntData(client, iOffs_m_hSecondaryHiddenWeaponPreDead, data);
}