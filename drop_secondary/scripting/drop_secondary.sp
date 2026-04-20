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

#define PLUGIN_VERSION			"2.8-2026/4/20"
#define PLUGIN_NAME			    "drop_secondary"
#define DEBUG 0

public Plugin myinfo =
{
	name		= "L4D1/2 Drop Secondary",
	author		= "HarryPotter",
	version		=  PLUGIN_VERSION,
	description	= "Survivor players will drop their secondary weapon when they die",
	url			= "https://steamcommunity.com/profiles/76561198026784913/"
};

bool g_bL4D2Version, bLate;
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

	bLate = late;
	return APLRes_Success; 
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar director_no_survivor_bots;
bool g_bCvar_director_no_survivor_bots;

ConVar g_hCvarBotDropKick;
bool g_bCvarBotDropKick;

int iOffs_m_hSecondaryHiddenWeaponPreDead = -1;
int iOffs_m_SecondaryWeaponDoublePistolPreDead = -1;
int iOffs_m_SecondaryWeaponIDPreDead = -1;

int 
	//g_iSecondary[MAXPLAYERS+1] = {-1},
	g_iHidden[MAXPLAYERS+1] = {-1};

bool 
	g_bIgnore[MAXPLAYERS+1];

public void OnPluginStart()
{
	if(g_bL4D2Version)
	{
		iOffs_m_SecondaryWeaponIDPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 108;
		iOffs_m_SecondaryWeaponDoublePistolPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 112;
		iOffs_m_hSecondaryHiddenWeaponPreDead = FindSendPropInfo("CTerrorPlayer", "m_knockdownTimer") + 116;
	}

	director_no_survivor_bots = FindConVar("director_no_survivor_bots");
	GetOfficialCvars();
	director_no_survivor_bots.AddChangeHook(ConVarChanged_OfficialCvars);

	g_hCvarBotDropKick 		= CreateConVar( PLUGIN_NAME ... "_bot_kick",      "1",   "If 1, Survivor bots will drop their secondary weapon when they were kicked", CVAR_FLAGS, true, 0.0, true, 1.0);
	CreateConVar(                       	PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true,                	PLUGIN_NAME);

	GetCvars();
	g_hCvarBotDropKick.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("round_start",  				Event_RoundStart, EventHookMode_PostNoCopy);
	HookEvent("player_spawn", 				Event_PlayerSpawn,	EventHookMode_Post);
	//HookEvent("player_death", 				OnPlayerDeathPre, 		EventHookMode_Pre);
	HookEvent("player_incapacitated", 		PlayerIncap_Event);
	HookEvent("revive_success", 			Event_ReviveSuccess);
	if(g_bL4D2Version) HookEvent("weapon_drop", 				Event_WeaponDrop);

	HookEvent("player_bot_replace", 		Event_BotReplacePlayer);

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

// Cvars-------------------------------

void ConVarChanged_OfficialCvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetOfficialCvars();
}

void GetOfficialCvars()
{
    g_bCvar_director_no_survivor_bots = director_no_survivor_bots.BoolValue;
}

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarBotDropKick = g_hCvarBotDropKick.BoolValue;
}

// Sourcemod API Forward-------------------------------

public void OnClientPutInServer(int client)
{
	if(g_bL4D2Version) return;

	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDropped);
}

// SDKHooks----

void OnWeaponDropped(int client, int weapon)
{
	if(weapon <= MaxClients || GetClientTeam(client) != 2)
		return;

	if(weapon == g_iHidden[client]) g_iHidden[client] = -1;
}

// Event-------------------------------

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
	if(client && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
	{
		Clear(client);
		if(g_bL4D2Version) CreateTimer(0.1, Timer_TraceHiddenWeapon, userid);
	}
}

void Event_BotReplacePlayer(Event event, const char[] name, bool dontBroadcast)
{
	int bot = GetClientOfUserId(GetEventInt(event, "bot"));
	int player = GetClientOfUserId(GetEventInt(event, "player"));
	if(bot > 0 && IsClientInGame(bot) && player > 0 && IsClientInGame(player))
	{
		g_bIgnore[player] = true;
		RequestFrame(NextFrame_Replace, player);
	}
}

/*void OnPlayerDeathPre(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != 2)
		return;

	int secondary = EntRefToEntIndex(g_iSecondary[client]);
	int HiddenWeapon = EntRefToEntIndex(g_iHidden[client]);
	//PrintToChatAll("OnPlayerDeathPre %N - secondary: %d, hidden: %d", client, secondary, HiddenWeapon);
	if(g_bL4D2Version)
	{
		if(HiddenWeapon != INVALID_ENT_REFERENCE && GetEntPropEnt(HiddenWeapon, Prop_Data, "m_hOwnerEntity") == client)
		{
			float origin[3];
			GetClientEyePosition(client, origin);
			SDKHooks_DropWeapon(client, HiddenWeapon, origin);

			// 如果其他玩家體內隱藏的副武器是相同的, 則清除
			for(int i = 1; i <= MaxClients; i++)
			{
				if(!IsClientInGame(i)) continue;

				if(GetSecondaryHiddenWeaponPreDead(i) != HiddenWeapon) continue;

				SetSecondaryHiddenWeapon(i, -1);
			}
		}
		else if(secondary != INVALID_ENT_REFERENCE && GetEntPropEnt(secondary, Prop_Data, "m_hOwnerEntity") == client)
		{
			float origin[3];
			GetClientEyePosition(client, origin);
			SDKHooks_DropWeapon(client, secondary, origin); //二代如果持雙手槍會掉兩把手槍

			// 如果其他玩家體內隱藏的副武器是相同的, 則清除
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
		if(secondary != INVALID_ENT_REFERENCE)
		{
			float origin[3];
			float ang[3];
			GetClientEyePosition(client, origin);
			GetClientEyeAngles(client, ang);
			SDKHooks_DropWeapon(client, secondary, origin); //一代如果持雙手槍會掉兩把手槍
		}
	}

	// 清空死掉的玩家體內隱藏的副武器
	// 避免bug 1: 復活之後掛邊再救活會得到副武器
	// 避免bug 2: 副武器佔據實體空間位置
	if(g_bL4D2Version)
	{
		int hidden = GetSecondaryHiddenWeaponPreDead(client);
		if(hidden > MaxClients && IsValidEntity(hidden))
		{
			RemoveEntity(hidden);
		}
	}

	Clear(client);
}*/

void PlayerIncap_Event(Event event, const char[] name, bool dontBroadcast) 
{
	int userid = event.GetInt("userid");
	int client = GetClientOfUserId(userid);
	
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != 2 )
		return;

	g_iHidden[client] = -1;

	if(g_bL4D2Version) CreateTimer(0.1, Timer_TraceHiddenWeapon, userid);
}

void Event_ReviveSuccess(Event event, const char[] name, bool dontBroadcast) 
{
	int subject = GetClientOfUserId(event.GetInt("subject"));
	
	g_iHidden[subject] = -1;
}

void Event_WeaponDrop(Event event, const char[] name, bool dontBroadcast)
{
	int entity = event.GetInt("propid");	
	if(entity <= MaxClients) return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		if(entity == g_iHidden[client]) g_iHidden[client] = -1;
	}
}

// API---------------

public Action L4D_OnTakeOverBot(int client)
{
	if( client <= 0 || client > MaxClients || !IsClientInGame(client) || IsFakeClient(client)) return Plugin_Continue;

	//PrintToChatAll("%f - L4D_OnTakeOverBot - %N", GetEngineTime(), client);
	int bot = GetClientIdleBot(client);

	g_bIgnore[bot] = true;
	RequestFrame(NextFrame_Replace, bot);

	return Plugin_Continue;
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


public void L4D_OnDeathDroppedWeapons(int client, int weapons[6])
{
	if( !IsClientInGame(client) 
		|| GetClientTeam(client) != 2
		|| g_bIgnore[client] //(二代) bot取代玩家時 -> 玩家觸發: Event_BotReplacePlayer -> L4D_OnDeathDroppedWeapons, // (二代) 玩家取代bot時 -> bot觸發: L4D_OnDeathDroppedWeapons -> Event_PlayerReplaceBot
		) 
		return;
	
	int iDropWeapon = -1;
	if(!IsClientInKickQueue(client))
	{
		// 死前觸發 (L4D_OnDeathDroppedWeapons -> "weapon_drop" -> "player_death" pre -> "player_death" post )
		// (director_no_survivor_bots=1) 玩家從倖存者切換隊伍時觸發 (L4D_OnDeathDroppedWeapons -> "weapon_drop" -> "player_team" event)

		if(g_bL4D2Version)
		{
			bool bIsInap = false;
			if(L4D_IsPlayerIncapacitated(client) && !L4D_IsPlayerHangingFromLedge(client))
			{
				// 如果持近戰或是電鋸->倒地期間給予其他副武器的話(如l4d2_incap_gun_replace插件)->L4D_OnDeathDroppedWeapons時隱藏的副武器與weapons[1]會被替換成剛才給予的副武器
				// 所以需要事先知道隱藏的副武器
				iDropWeapon = EntRefToEntIndex(g_iHidden[client]);
				if(iDropWeapon == INVALID_ENT_REFERENCE) iDropWeapon = GetSecondaryHiddenWeaponPreDead(client);
				
				bIsInap = true;
			}
			else
			{
				// 如果是死亡, 持麥格農/電鋸/近戰武器時, GetPlayerWeaponSlot(client, 1)=-1
				iDropWeapon = GetPlayerWeaponSlot(client, 1);
				if(iDropWeapon <= MaxClients) iDropWeapon = weapons[1];
			}

			if(iDropWeapon <= MaxClients) return;

			//PrintToChatAll("L4D_OnDeathDroppedWeapons(1) %d - %d - %d - slot 1: %d", client, weapons[1], iDropWeapon, GetPlayerWeaponSlot(client, 1));

			// 玩家拿近戰或電鋸->閒置->bot先倒地->取代->死亡->該近戰或電鋸的m_hOwnerEntity為-1, 而非玩家 (會有error)
			// 玩家拿近戰或電鋸->先倒地->閒置->bot取代->死亡->該近戰的m_hOwnerEntity為玩家, 而非bot (會有error)
			// 倒地期間->閒置->取代->掉落的近戰或電鋸會穿透至地下，永久墬落
			//PrintToChatAll("L4D_OnDeathDroppedWeapons(1) owner: %d, client: %d", GetEntPropEnt(iDropWeapon, Prop_Data, "m_hOwnerEntity"), client);
			if(bIsInap)
			{
				if(GetEntPropEnt(iDropWeapon, Prop_Data, "m_hOwnerEntity") != client)
				{
					if(weapons[1] > MaxClients && weapons[1] != iDropWeapon)
					{
						RemovePlayerItem(client, weapons[1]);
						RemoveEntity(weapons[1]);
					}
					SetEntPropEnt(iDropWeapon, Prop_Data, "m_hOwnerEntity", -1);
					SetEntPropEnt(iDropWeapon, Prop_Data, "m_hOwner", -1);
					EquipPlayerWeapon(client, iDropWeapon); //<--給玩家拿隱藏武器, 重置m_hOwnerEntity
					SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", iDropWeapon); //<--強制玩家用該武器，修復丟電鋸時崩潰
				}
				else
				{
					EquipPlayerWeapon(client, iDropWeapon); //<--給玩家拿隱藏武器, 修復掉落的近戰或電鋸會穿透至地下，永久墬落
				}
			}
		}
		else
		{
			iDropWeapon = GetPlayerWeaponSlot(client, 1);
		}
	}
	else
	{
		// (director_no_survivor_bots=0) bot被踢出遊戲前觸發 (OnClientDisconnect() -> L4D_OnDeathDroppedWeapons -> "weapon_drop")
		// (director_no_survivor_bots=1) 玩家被踢出遊戲前觸發 (OnClientDisconnect() -> L4D_OnDeathDroppedWeapons -> "weapon_drop")
	
		if(!g_bCvarBotDropKick) return;

		if( (g_bCvar_director_no_survivor_bots && !IsFakeClient(client)) ||
			(!g_bCvar_director_no_survivor_bots && IsFakeClient(client)) )
		{

			if(g_bL4D2Version)
			{
				bool bIsInap = false;

				if(L4D_IsPlayerIncapacitated(client) && !L4D_IsPlayerHangingFromLedge(client))
				{
					iDropWeapon = EntRefToEntIndex(g_iHidden[client]);
					if(iDropWeapon == INVALID_ENT_REFERENCE) iDropWeapon = GetSecondaryHiddenWeaponPreDead(client);
					
					bIsInap = true;
				}
				else
				{
					iDropWeapon = GetPlayerWeaponSlot(client, 1);
				}

				if(iDropWeapon <= MaxClients) return;

				//PrintToChatAll("L4D_OnDeathDroppedWeapons(2) %d - %d - %d", client, weapons[1], iDropWeapon);
				if(bIsInap)
				{
					//PrintToChatAll("L4D_OnDeathDroppedWeapons(2) owner: %d, client: %d", GetEntPropEnt(iDropWeapon, Prop_Data, "m_hOwnerEntity"), client);
					if(GetEntPropEnt(iDropWeapon, Prop_Data, "m_hOwnerEntity") != client)
					{
						if(weapons[1] > MaxClients && weapons[1] != iDropWeapon)
						{
							RemovePlayerItem(client, weapons[1]);
							RemoveEntity(weapons[1]);
						}
						SetEntPropEnt(iDropWeapon, Prop_Data, "m_hOwnerEntity", -1);
						SetEntPropEnt(iDropWeapon, Prop_Data, "m_hOwner", -1);
						EquipPlayerWeapon(client, iDropWeapon); //<--給玩家拿隱藏武器, 重置m_hOwnerEntity
						SetEntPropEnt(client, Prop_Data, "m_hActiveWeapon", iDropWeapon); //<--強制玩家用該武器，修復丟電鋸時崩潰
					}
					else
					{
						EquipPlayerWeapon(client, iDropWeapon); //<--給玩家拿隱藏武器, 修復掉落的近戰或電鋸會穿透至地下，永久墬落
					}
				}
			}
			else
			{
				iDropWeapon = GetPlayerWeaponSlot(client, 1);
			}
		}
	}

	if(iDropWeapon > MaxClients && GetEntPropEnt(iDropWeapon, Prop_Data, "m_hOwnerEntity") == client)
	{
		float origin[3];
		float ang[3];
		GetClientEyePosition(client, origin);
		GetClientEyeAngles(client, ang);
		SDKHooks_DropWeapon(client, iDropWeapon, origin); //一代與二代如果持雙手槍會掉兩把手槍

		if(g_bL4D2Version)
		{
			for(int i = 1; i <= MaxClients; i++)
			{
				if(!IsClientInGame(i)) continue;

				if(GetSecondaryHiddenWeaponPreDead(i) != iDropWeapon) continue;

				SetSecondaryHiddenWeapon(i, -1);
			}

			SetSecondaryWeaponIDPreDead(client, 1);
			SetSecondaryWeaponDoublePistolPreDead(client, 0);
			SetSecondaryHiddenWeapon(client, -1);
		}
	}
}

// Timer & Frame-------------------------------

void NextFrame_Replace(int client)
{
	g_bIgnore[client] = false;
}

Action Timer_TraceHiddenWeapon(Handle Timer, int client)
{
	client = GetClientOfUserId(client);
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != 2 || !IsPlayerAlive(client) || !L4D_IsPlayerIncapacitated(client))
		return Plugin_Continue;

	int hidden = GetSecondaryHiddenWeaponPreDead(client);
	//PrintToChatAll("Timer_TraceHiddenWeapon %d", hidden);
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

// Function-------------------------------

int GetClientIdleBot(int client)
{
	if(GetClientTeam(client) != 1)
		return 0;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
		{
			if(HasEntProp(i, Prop_Send, "m_humanSpectatorUserID"))
			{
				if(GetClientOfUserId(GetEntProp(i, Prop_Send, "m_humanSpectatorUserID")) == client)
						return i;
			}
		}
	}

	return 0;
}

void Clear(int client)
{
	if(g_bL4D2Version)
	{
		SetSecondaryWeaponIDPreDead(client, 1);
		SetSecondaryWeaponDoublePistolPreDead(client, 0);
		SetSecondaryHiddenWeapon(client, -1);
		g_iHidden[client] = -1;
	}

	//g_iSecondary[client] = -1;
}

/*int GetSecondaryWeaponIDPreDead(int client)
{
	return GetEntData(client, iOffs_m_SecondaryWeaponIDPreDead);
}*/

void SetSecondaryWeaponIDPreDead(int client, int data)
{
	SetEntData(client, iOffs_m_SecondaryWeaponIDPreDead, data);
}

/*int GetSecondaryWeaponDoublePistolPreDead(int client)
{
	return GetEntData(client, iOffs_m_SecondaryWeaponDoublePistolPreDead);
}*/

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