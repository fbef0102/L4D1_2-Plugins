#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <left4dhooks>
#include <multicolors>

#define PLUGIN_VERSION "1.1h-2024/12/9"

public Plugin myinfo = 
{
	name = "Chainsaw Refuelling",
	author = "DJ_WEST, Lossy (Round Start Fix), Shao (downstate support), HarryPotter (Improve)",
	description = "Allow refuelling of a chainsaw",
	version = PLUGIN_VERSION,
	url = "https://github.com/fbef0102/L4D1_2-Plugins/tree/master/l4d2_chainsaw_refuelling"
}

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	bLate = late;
	return APLRes_Success;
}

#define CHAINSAW_DISTANCE 50.0
#define CHAINSAW "chainsaw"
#define CHAINSAW_CLASS "weapon_chainsaw"
#define CHAINSAW_SPAWN_CLASS "weapon_chainsaw_spawn"
#define GASCAN_CLASS "weapon_gascan"
#define GASCAN_SKIN 0
#define TEAM_SURVIVOR 2

ConVar g_hCvarEnable, g_hCvarRemove, g_hCvarMode, g_hCvarDrop, g_hCvarHint;
bool g_bCvarEnable, g_bCvarRemove, g_bCvarDrop, g_bCvarHint;
int g_iCvarMode;

bool 
	g_bClientInfoOnce[MAXPLAYERS+1];

float 
	g_fActionEngineTime[MAXPLAYERS+1];

Handle 
	g_Timer[MAXPLAYERS+1];

int 
	g_iChainsawMaxClip,
	g_ActiveWeaponOffset,  
	g_ShotsFiredOffset,
	g_iChainsawToPour[2048+1], // chainsaw -> point_prop_use_target
	g_iPourToChainsaw[2048+1]; // point_prop_use_target -> chainsaw

public void OnPluginStart()
{
	LoadTranslations("chainsaw_refuelling.phrases");

	g_hCvarEnable 	= CreateConVar( "l4d2_chainsaw_refuelling_enable", 		"1", "Chainsaw Refuelling plugin status (0 - Disable, 1 - Enable)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarRemove 	= CreateConVar( "l4d2_chainsaw_refuelling_remove", 		"0", "If 1, Remove a chainsaw if it empty", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarMode 	= CreateConVar( "l4d2_chainsaw_refuelling_mode", 		"2", "Allow refuelling of a chainsaw (0 - On the ground, 1 - On players, 2 - Both)", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	g_hCvarDrop 	= CreateConVar( "l4d2_chainsaw_refuelling_drop", 		"1", "If 1, Enable dropping a chainsaw with Reload button", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarHint		= CreateConVar( "l4d2_chainsaw_refuelling_hint", 		"1", "If 1, Enable hint message", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateConVar(					"l4d2_chainsaw_refuelling_version", 	PLUGIN_VERSION, "Chainsaw Refuelling version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	AutoExecConfig(true, 			"l4d2_chainsaw_refuelling");

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarRemove.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarMode.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarDrop.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarHint.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("item_pickup", EventItemPickup);
	HookEvent("round_end", evtRoundEnd, EventHookMode_PostNoCopy); //對抗上下回合結束的時候觸發
	HookEvent("map_transition", evtRoundEnd, EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (之後沒有觸發round_end)
	HookEvent("mission_lost", evtRoundEnd, EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", evtRoundEnd, EventHookMode_PostNoCopy); //救援載具離開之時  (之後沒有觸發round_end)

	g_ActiveWeaponOffset = FindSendPropInfo("CBasePlayer", "m_hActiveWeapon");
	g_ShotsFiredOffset = FindSendPropInfo("CCSPlayer", "m_iShotsFired");

	AddCommandListener(CmdListen_weapon_reparse_server, "weapon_reparse_server");

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

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarRemove = g_hCvarRemove.BoolValue;
	g_iCvarMode = g_hCvarMode.IntValue;
	g_bCvarDrop = g_hCvarDrop.BoolValue;
	g_bCvarHint = g_hCvarHint.BoolValue;
}

public void OnMapEnd()
{
	ResetTimer();
}

public void OnConfigsExecuted()
{
	GetChainsawMaxClip();
}

public void OnClientPutInServer(int client)
{
	// 撿起地上的武器
	SDKHook(client, SDKHook_WeaponEquipPost, OnWeaponEquipPost);

	g_bClientInfoOnce[client] = false;
}

public void OnClientDisconnect(int client)
{
	if(!IsClientInGame(client)) return;
	
	delete g_Timer[client];
}

Action CmdListen_weapon_reparse_server(int client, const char[] command, int argc)
{
	RequestFrame(OnNextFrame_weapon_reparse_server);

	return Plugin_Continue;
}

void OnNextFrame_weapon_reparse_server()
{
	GetChainsawMaxClip();
}

void GetChainsawMaxClip()
{
	g_iChainsawMaxClip = L4D2_GetIntWeaponAttribute(CHAINSAW_CLASS, L4D2IWA_ClipSize);
}

void evtRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	ResetTimer();
}

void EventItemPickup(Event event, const char[] name, bool dontBroadcast) 
{
	if(!g_bCvarEnable) return;

	int i_UserID, client;
	char s_Weapon[16];
	
	i_UserID = event.GetInt("userid");
	client = GetClientOfUserId(i_UserID);

	event.GetString("item", s_Weapon, sizeof(s_Weapon));

	if (StrEqual(s_Weapon, CHAINSAW))
	{
		if (!g_bClientInfoOnce[client])
		{
			if(g_bCvarHint)
			{
				CPrintToChat(client, "{green}%t{default} %t.", "Information", "Refuelling");
				CPrintToChat(client, "{green}%t{default} %t.", "Information", "Drop");
			}
			g_bClientInfoOnce[client] = true;
		}
	}
}

bool TryToFuelChainsaw(int client)
{
	char s_Class[64];

	int i_Ent = GetClientAimTarget(client, false);
	
	if ((g_iCvarMode == 1 || g_iCvarMode == 2) && i_Ent > 0 && i_Ent <= MaxClients && IsClientInGame(i_Ent) && IsPlayerAlive(i_Ent))
	{
		int i_Weapon = GetEntDataEnt2(i_Ent, g_ActiveWeaponOffset);
		if(IsValidEnt(i_Weapon))
		{
			GetEntityClassname(i_Weapon, s_Class, sizeof(s_Class));
			if (StrEqual(s_Class, CHAINSAW_CLASS))
				CheckChainsaw(client, i_Weapon, i_Ent);
		}
	}
	else if((g_iCvarMode == 0 || g_iCvarMode == 2) && i_Ent > MaxClients && IsValidEntity(i_Ent))
	{
		GetEntityClassname(i_Ent, s_Class, sizeof(s_Class));
		
		if (StrEqual(s_Class, CHAINSAW_SPAWN_CLASS))
		{
			if(g_bCvarHint) CPrintToChat(client, "{lightgreen}%t{default} %t.", "Information", "Full");
		}
		else if (StrEqual(s_Class, CHAINSAW_CLASS))
		{
			return CheckChainsaw(client, i_Ent, -1);

			
		}
	}

	return false;
}

bool CheckChainsaw(int client, int i_Weapon, int player)
{
	float f_EntPos[3], f_ClientPos[3];
	
	GetEntPropVector(player == -1 ? i_Weapon : player, Prop_Send, "m_vecOrigin", f_EntPos);
	GetClientAbsOrigin(client, f_ClientPos);
			
	if (GetVectorDistance(f_EntPos, f_ClientPos) <= CHAINSAW_DISTANCE)
	{	
		int i_Clip = GetEntProp(i_Weapon, Prop_Data, "m_iClip1");
				
		if (i_Clip >= g_iChainsawMaxClip)
		{
			if(g_bCvarHint) CPrintToChat(client, "{lightgreen}%t{default} %t.", "Information", "Full");
			
			return false;
		}
				
		int i_ChainsawPointEnt = EntRefToEntIndex(g_iChainsawToPour[i_Weapon]);
				
		if (!IsValidEntRef(i_ChainsawPointEnt))
		{
			i_ChainsawPointEnt = (player == -1) ? CreatePointEntity(i_Weapon, 10.0) : CreatePointEntity(player, 50.0);
				
			if (i_ChainsawPointEnt > 0)
			{
				g_iChainsawToPour[i_Weapon] = EntIndexToEntRef(i_ChainsawPointEnt);
				g_iPourToChainsaw[i_ChainsawPointEnt] = EntIndexToEntRef(i_Weapon);
			}
		}

		return true;
	}

	return false;
}

int CreatePointEntity(int i_Ent, float f_Add)
{
	float f_Position[3];
	
	GetEntPropVector(i_Ent, Prop_Send, "m_vecOrigin", f_Position);
	f_Position[2] += f_Add;
	
	int i_PointEnt = CreateEntityByName("point_prop_use_target");
	if(i_PointEnt <= 0) return -1;

	DispatchKeyValueVector(i_PointEnt, "origin", f_Position);
	DispatchKeyValue(i_PointEnt, "nozzle", "gas_nozzle");
	DispatchKeyValueInt(i_PointEnt, "spawnflags", 1);
	DispatchSpawn(i_PointEnt);
	HookSingleEntityOutput(i_PointEnt, "OnUseCancelled", OnUseCancelled);
	HookSingleEntityOutput(i_PointEnt, "OnUseFinished", OnUseFinished);

	return i_PointEnt;
}

public Action OnPlayerRunCmd(int client, int &i_Buttons, int &i_Impulse, float f_Velocity[3], float f_Angles[3], int &i_Wpn)
{
	if (!g_bCvarEnable)
		return Plugin_Continue;

	if (IsFakeClient(client) || !IsPlayerAlive(client))
		return Plugin_Continue;
		
	if (GetClientTeam(client) != 2)
		return Plugin_Continue;

	if (L4D_IsPlayerIncapacitated(client))
		return Plugin_Continue;
		
	if (g_fActionEngineTime[client] > GetEngineTime())
		return Plugin_Continue;

	if (GetEntData(client, g_ShotsFiredOffset) > 0)
		return Plugin_Continue;
	
	int i_Weapon;
	
	if (i_Buttons & IN_USE || i_Buttons & IN_ATTACK)
	{
		char s_Weapon[32];
		int i_Skin;
		
		i_Weapon = GetEntDataEnt2(client, g_ActiveWeaponOffset);
		
		if (!IsValidEnt(i_Weapon)) return Plugin_Continue;
		
		GetEntityClassname(i_Weapon, s_Weapon, sizeof(s_Weapon));
		i_Skin = GetEntProp(i_Weapon, Prop_Send, "m_nSkin");
		
		if (StrEqual(s_Weapon, GASCAN_CLASS) && i_Skin == GASCAN_SKIN)
		{
			if(TryToFuelChainsaw(client))
			{
				g_fActionEngineTime[client] = GetEngineTime() + 0.25;
			}
		}
		else if (!g_bCvarRemove && StrEqual(s_Weapon, CHAINSAW_CLASS))
		{
			if (GetEntProp(i_Weapon, Prop_Data, "m_iClip1") <= 1)
			{
				i_Buttons &= ~IN_ATTACK;
				return Plugin_Changed;
			}
		}
	}
	
	if (i_Buttons & IN_RELOAD)
	{
		i_Weapon = GetEntDataEnt2(client, g_ActiveWeaponOffset);
		
		if (IsValidEnt(i_Weapon))
		{
			char s_Weapon[32];
			GetEntityClassname(i_Weapon, s_Weapon, sizeof(s_Weapon));
			if (StrEqual(s_Weapon, CHAINSAW_CLASS) && g_bCvarDrop)
			{
				SDKHooks_DropWeapon(client, i_Weapon);
				g_fActionEngineTime[client] = GetEngineTime() + 0.25;
			}
		}
	}
	
	return Plugin_Continue;
}

void OnUseCancelled(const char[] output, int caller, int activator, float delay)
{
	RemoveEntity(caller);
}

void OnUseFinished(const char[] output, int caller, int activator, float delay)
{
	int chainsaw = g_iPourToChainsaw[caller];

	if(IsValidEntRef(chainsaw))
	{	
		SetEntProp(chainsaw, Prop_Data, "m_iClip1", g_iChainsawMaxClip);
	}

	RemoveEntity(caller);
}
void OnWeaponEquipPost(int client, int weapon)
{
	if (weapon <= MaxClients || GetClientTeam(client) != TEAM_SURVIVOR) 
	{
		return;
	}

	int point_prop_use_target = EntRefToEntIndex(g_iChainsawToPour[weapon]);
	if (IsValidEntRef(point_prop_use_target))
	{
		RemoveEntity(point_prop_use_target);
	}
}

bool IsValidEnt(int i_Ent)
{
	return (i_Ent > MaxClients && IsValidEntity(i_Ent));
}

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}

void ResetTimer()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		delete g_Timer[i];
	}
}
