/**
 * L4D2 Windows/Linux
 * CTerrorPlayer,m_knockdownTimer + 100 = 死前所持主武器weapon ID
 * CTerrorPlayer,m_knockdownTimer + 104 = 死前所持主武器ammo
 * CTerrorPlayer,m_knockdownTimer + 108 = 死前所持副武器weapon ID
 * CTerrorPlayer,m_knockdownTimer + 112 = 死前所持副武器是否双持
 * CTerrorPlayer,m_knockdownTimer + 116 = 死前所持非手枪副武器EHandle
 */

#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <left4dhooks>

#define DEBUG 0

public Plugin myinfo =
{
	name		= "L4D2 Drop Secondary",
	author		= "HarryPotter",
	version		= "2.6-2025/1/16",
	description	= "Survivor players will drop their secondary weapon when they die",
	url			= "https://steamcommunity.com/profiles/76561198026784913/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	EngineVersion test = GetEngineVersion();
	
	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success; 
}

int iOffs_m_hSecondaryHiddenWeaponPreDead = -1;
int iOffs_m_SecondaryWeaponDoublePistolPreDead = -1;
int iOffs_m_SecondaryWeaponIDPreDead = -1;

char g_sMeleeClass[16][32];
int g_iMeleeClassCount;

int 
	g_iSecondary[MAXPLAYERS+1] = {-1},
	g_iHidden[MAXPLAYERS+1] = {-1};

public void OnPluginStart()
{
	iOffs_m_SecondaryWeaponIDPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 108;
	iOffs_m_SecondaryWeaponDoublePistolPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 112;
	iOffs_m_hSecondaryHiddenWeaponPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 116;

	HookEvent("round_start",  				Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn", 				Event_PlayerSpawn,	EventHookMode_Post);
	HookEvent("player_death", 				OnPlayerDeath, 		EventHookMode_Pre);

	HookEvent("player_incapacitated", 		PlayerIncap_Event);
}

public void OnMapStart()
{
	CreateTimer(1.0, Timer_GetMeleeTable, _, TIMER_FLAG_NO_MAPCHANGE);
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i)) continue;

		Clear(i);
	}
}

//playerspawn is triggered even when bot or human takes over each other (even they are already dead state) or a survivor is spawned
void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	if(client && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		Clear(client);
		CreateTimer(0.1, Timer_TraceHiddenWeapon, userid);
	}
}

/**
 * @brief Called when CTerrorPlayer::DropWeapons() is invoked
 * @remarks Called when a player dies, listing their currently held weapons and objects that are being dropped
 * @remarks Array index is as follows:
 * @remarks [0] = L4DWeaponSlot_Primary
 * @remarks [1] = L4DWeaponSlot_Secondary
 * @remarks [2] = L4DWeaponSlot_Grenade
 * @remarks [3] = L4DWeaponSlot_FirstAid
 * @remarks [4] = L4DWeaponSlot_Pills
 * @remarks [5] = Held item (e.g. weapon_gascan, weapon_gnome etc)
 *
 * @param client		Client index of the player who died
 * @param weapons		Array of weapons dropped, valid entity index or -1 if empty
 *
 * @noreturn
 **/

// bot取代玩家時 -> 玩家觸發
// 玩家取代bot時 -> bot觸發
// 死前觸發
public void L4D_OnDeathDroppedWeapons(int client, int weapons[6])
{
	if(!IsClientInGame(client) || GetClientTeam(client) != 2
		|| weapons[1] <= MaxClients)
		return;

	int HiddenWeapon = EntRefToEntIndex(g_iHidden[client]);
	if(HiddenWeapon == INVALID_ENT_REFERENCE)
	{
		HiddenWeapon = GetSecondaryHiddenWeaponPreDead(client);
	}

	//PrintToChatAll("L4D_OnDeathDroppedWeapons %N - %d - %d", client, weapons[1], HiddenWeapon);
	if(HiddenWeapon > MaxClients && IsValidEntity(HiddenWeapon))
	{
		g_iHidden[client] = EntIndexToEntRef(HiddenWeapon);

		// 玩家拿近戰->閒置->bot先倒地->取代->死亡->該近戰的m_hOwnerEntity為bot, 而非玩家 (會有error)
		if(GetEntPropEnt(HiddenWeapon, Prop_Data, "m_hOwnerEntity") != client)
		{
			//PrintToChatAll("L4D_OnDeathDroppedWeapons wrong m_hOwnerEntity");

			RemovePlayerItem(client, weapons[1]);
			RemoveEntity(weapons[1]);
			SetEntPropEnt(HiddenWeapon, Prop_Data, "m_hOwnerEntity", -1);
			SetEntPropEnt(HiddenWeapon, Prop_Data, "m_hOwner", -1);
			EquipPlayerWeapon(client, HiddenWeapon); //<--給玩家拿隱藏武器, 重置
			SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", HiddenWeapon); //<--強制玩家用該武器，避免丟電鋸時崩潰

			g_iSecondary[client] = -1;
			return;
		}
	}

	g_iSecondary[client] = EntIndexToEntRef(weapons[1]);
}

void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != 2)
		return;

	int secondary = EntRefToEntIndex(g_iSecondary[client]);
	int HiddenWeapon = EntRefToEntIndex(g_iHidden[client]);
	//PrintToChatAll("OnPlayerDeath %N - secondary: %d, hidden: %d", client, secondary, HiddenWeapon);
	if(HiddenWeapon == INVALID_ENT_REFERENCE)
	{
		if(secondary != INVALID_ENT_REFERENCE)
		{
			float origin[3];
			GetClientEyePosition(client, origin);
			SDKHooks_DropWeapon(client, secondary, origin);

			for(int i = 1; i <= MaxClients; i++)
			{
				if(!IsClientInGame(i)) continue;

				if(GetSecondaryHiddenWeaponPreDead(i) != secondary) continue;

				SetSecondaryHiddenWeapon(i, -1);
			}
		}
	}
	else
	{
		if(GetEntPropEnt(HiddenWeapon, Prop_Data, "m_hOwnerEntity") == client)
		{
			float origin[3];
			GetClientEyePosition(client, origin);
			SDKHooks_DropWeapon(client, HiddenWeapon, origin);

			for(int i = 1; i <= MaxClients; i++)
			{
				if(!IsClientInGame(i)) continue;

				if(GetSecondaryHiddenWeaponPreDead(i) != HiddenWeapon) continue;

				SetSecondaryHiddenWeapon(i, -1);
			}
		}
	}

	int hidden = GetSecondaryHiddenWeaponPreDead(client);
	if(hidden > MaxClients && IsValidEntity(hidden))
	{
		RemoveEntity(hidden);
	}

	Clear(client);
}

void PlayerIncap_Event(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != 2)
		return;

	g_iSecondary[client] = -1;
	g_iHidden[client] = -1;

	CreateTimer(0.1, Timer_TraceHiddenWeapon, userid);
}

Action Timer_TraceHiddenWeapon(Handle Timer, int client)
{
	client = GetClientOfUserId(client);
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != 2 || !IsPlayerAlive(client) || !L4D_IsPlayerIncapacitated(client))
		return Plugin_Continue;

	int hidden = GetSecondaryHiddenWeaponPreDead(client);
	if(hidden > MaxClients && IsValidEntity(hidden))
	{
		g_iHidden[client] = EntIndexToEntRef(hidden);
	}
	else
	{
		g_iHidden[client] = -1;
	}

	return Plugin_Continue;
}

Action Timer_GetMeleeTable(Handle timer)
{
	GetMeleeClasses();
	return Plugin_Continue;
}

//credit spirit12 for auto melee detection
void GetMeleeClasses()
{
	int MeleeStringTable = FindStringTable( "MeleeWeapons" );
	g_iMeleeClassCount = GetStringTableNumStrings( MeleeStringTable );
	
	int len = sizeof(g_sMeleeClass[]);
	
	for( int i = 0; i < g_iMeleeClassCount; i++ )
	{
		ReadStringTable( MeleeStringTable, i, g_sMeleeClass[i], len );
		#if DEBUG
			char sMap[64];
			GetCurrentMap(sMap, sizeof(sMap));
			LogMessage( "[%s] Function::GetMeleeClasses - Getting melee classes: %s", sMap, g_sMeleeClass[i]);
		#endif
	}	
}

void Clear(int client)
{
	SetSecondaryWeaponIDPreDead(client, 1);
	SetSecondaryWeaponDoublePistolPreDead(client, 0);
	SetSecondaryHiddenWeapon(client, -1);

	g_iSecondary[client] = -1;
	g_iHidden[client] = -1;
}

stock int GetSecondaryWeaponIDPreDead(int client)
{
	return GetEntData(client, iOffs_m_SecondaryWeaponIDPreDead);
}

void SetSecondaryWeaponIDPreDead(int client, int data)
{
	SetEntData(client, iOffs_m_SecondaryWeaponIDPreDead, data);
}

stock int GetSecondaryWeaponDoublePistolPreDead(int client)
{
	return GetEntData(client, iOffs_m_SecondaryWeaponDoublePistolPreDead);
}

void SetSecondaryWeaponDoublePistolPreDead(int client, int data)
{
	SetEntData(client, iOffs_m_SecondaryWeaponDoublePistolPreDead, data);
}

int GetSecondaryHiddenWeaponPreDead(int client)
{
	return GetEntDataEnt2(client, iOffs_m_hSecondaryHiddenWeaponPreDead);
}

void SetSecondaryHiddenWeapon(int client, int data)
{
	SetEntData(client, iOffs_m_hSecondaryHiddenWeaponPreDead, data);
}

stock int GetWeaponOwner(int weapon)
{
	return GetEntPropEnt(weapon, Prop_Data, "m_hOwner");
}