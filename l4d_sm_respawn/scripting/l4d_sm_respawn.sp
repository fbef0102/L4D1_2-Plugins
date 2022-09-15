#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <adminmenu>
#include <left4dhooks>

#define PLUGIN_VERSION "2.5"

#define CVAR_FLAGS	FCVAR_NOTIFY

public Plugin myinfo =
{
	name = "[L4D & L4D2] SM Respawn",
	author = "AtomicStryker & Ivailosp (Modified by Crasher, SilverShot), fork by Dragokas & Harry",
	description = "Allows players to be respawned at one's crosshair.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=323220"
};

int ACCESS_FLAG = ADMFLAG_BAN;

float VEC_DUMMY[3]	= {99999.0, 99999.0, 99999.0};

ConVar g_cvLoadout;
ConVar g_cvShowAction;
ConVar g_cvAddTopMenu;
ConVar g_cvGameMode;

bool g_bLeft4dead2;
bool g_bMenuAdded;

Handle g_WarpToValidPositionSDKCall;

TopMenuObject hAdminSpawnItem;

int g_iDeadBody[MAXPLAYERS+1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "SM Respawn only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLeft4dead2 = (evEngine == Engine_Left4Dead2);
	CreateNative("SM_Respawn", NATIVE_Respawn);
	return APLRes_Success;
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("l4d_sm_respawn.phrases");
	
	CreateConVar("l4d_sm_respawn2_version", PLUGIN_VERSION, "SM Respawn Version", CVAR_FLAGS | FCVAR_DONTRECORD);
	g_cvLoadout = 		CreateConVar("l4d_sm_respawn_loadout", 		"pistol,smg", "Respawn players with this loadout, separate by commas", CVAR_FLAGS);
	g_cvShowAction = 	CreateConVar("l4d_sm_respawn_showaction", 	"1", 	"Notify in chat and log action about respawn? (0 - No, 1 - Yes)", CVAR_FLAGS);
	g_cvAddTopMenu = 	CreateConVar("l4d_sm_respawn_adminmenu", 	"1", 	"Add 'Respawn player' item in admin menu under 'Player commands' category? (0 - No, 1 - Yes)", CVAR_FLAGS);
	AutoExecConfig(true, "l4d_sm_respawn");
	
	g_cvGameMode = FindConVar("mp_gamemode");
	
	Handle hGameData = LoadGameConfigFile("l4drespawn");
	if (hGameData == null) SetFailState("Could not find gamedata file at addons/sourcemod/gamedata/l4drespawn.txt , you FAILED AT INSTALLING");
	
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "WarpToValidPositionIfStuck");
	g_WarpToValidPositionSDKCall = EndPrepSDKCall();
	if(g_WarpToValidPositionSDKCall == null)
	{
		SetFailState("Could not find signature \"WarpToValidPositionIfStuck\".");
	}
	delete hGameData;
	
	if( g_bLeft4dead2 )
	{
		HookEvent("dead_survivor_visible", Event_DeadSurvivorVisible);
	}
	
	RegAdminCmd("sm_respawn", 		CmdRespawn, 	ACCESS_FLAG, "<opt.target> Respawn a player at your crosshair. Without argument - opens menu to select players");
	
	g_cvAddTopMenu.AddChangeHook(OnCvarChanged);
	
	OnAdminMenuReady(null);
}

public void OnCvarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if( convar == g_cvAddTopMenu )
	{
		OnAdminMenuReady(null);
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if( strcmp(name, "adminmenu") == 0 )
	{
		g_bMenuAdded = false;
		hAdminSpawnItem = INVALID_TOPMENUOBJECT;
	}
}

public void OnAdminMenuReady(Handle hTopMenu)
{
	AddAdminItem(hTopMenu);
}

stock void RemoveAdminItem()
{
	AddAdminItem(null, true);
}

void AddAdminItem(Handle hTopMenu, bool bRemoveItem = false)
{
	TopMenu hAdminMenu;
	
	if( hTopMenu != null )
	{
		hAdminMenu = TopMenu.FromHandle(hTopMenu);
	}
	else {
		if( !LibraryExists("adminmenu") )
		{
			return;
		}	
		if( null == (hAdminMenu = GetAdminTopMenu()) )
		{
			return;
		}
	}
	
	if( g_bMenuAdded )
	{
		if( (bRemoveItem || !g_cvAddTopMenu.BoolValue) && hAdminSpawnItem != INVALID_TOPMENUOBJECT )
		{
			hAdminMenu.Remove(hAdminSpawnItem);
			g_bMenuAdded = false;
		}
	}
	else {
		if( g_cvAddTopMenu.BoolValue )
		{
			TopMenuObject hMenuCategory = hAdminMenu.FindCategory(ADMINMENU_PLAYERCOMMANDS);

			if( hMenuCategory )
			{
				hAdminSpawnItem = hAdminMenu.AddItem("L4D_SM_RespawnPlayer_Item", AdminMenuSpawnHandler, hMenuCategory, "sm_respawn", ACCESS_FLAG, "Respawn a player at your crosshair");
				g_bMenuAdded = true;
			}
		}
	}
}

public void AdminMenuSpawnHandler(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if( action == TopMenuAction_SelectOption )
	{
		MenuClientsToSpawn(param);
	}
	else if( action == TopMenuAction_DisplayOption )
	{
		FormatEx(buffer, maxlength, "%T", "Respawn_Player", param);
	}
}

void MenuClientsToSpawn(int client, int item = 0)
{
	Menu menu = new Menu(MenuHandler_MenuList, MENU_ACTIONS_DEFAULT);
	menu.SetTitle("%T", "List_Players", client);
	
	char sGameMode[16];
	g_cvGameMode.GetString(sGameMode, sizeof sGameMode);
	//bool bVersus = (0 == strcmp(sGameMode, "versus"));
	
	static char sId[16], name[64];
	bool bNoOneDead = true;
	for( int i = 1; i <= MaxClients; i++ )
	{
		//if( IsClientInGame(i) && GetClientTeam(i) != 1 )
		if( IsClientInGame(i) && GetClientTeam(i) == 2 )
		{
			//if( bVersus && GetClientTeam(i) == 3 && IsFakeClient(i) )
			//{
			//	continue;
			//}
			
			if(IsPlayerAlive(i)) continue;
			
			FormatEx(sId, sizeof sId, "%i", GetClientUserId(i));
			FormatEx(name, sizeof name, "%N", i);
			
			menu.AddItem(sId, name);
			
			bNoOneDead = false;
		}
	}
	if(bNoOneDead) menu.AddItem("1.", "There Are No Any Dead Survivor");
	menu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int MenuHandler_MenuList(Menu menu, MenuAction action, int param1, int param2)
{
	switch( action )
	{
		case MenuAction_End:
			delete menu;
		
		case MenuAction_Select:
		{
			int client = param1;
			int ItemIndex = param2;
			
			static char sUserId[16];
			menu.GetItem(ItemIndex, sUserId, sizeof sUserId);
			
			int UserId = StringToInt(sUserId);
			int target = GetClientOfUserId(UserId);
			
			if( target && IsClientInGame(target) )
			{
				vRespawnPlayer(client, target);
			}
			MenuClientsToSpawn(client, menu.Selection);
		}
	}

	return 0;
}

public int NATIVE_Respawn(Handle plugin, int numParams)
{
	if( numParams < 1 )
		ThrowNativeError(SP_ERROR_PARAM, "Invalid numParams");
	
	int iTarget = GetNativeCell(1);
	int iClient;
	float vec[3];
	vec = VEC_DUMMY;
	
	if( numParams >= 2 )
	{
		iClient = GetNativeCell(2);
	}
	if( numParams >= 3 )
	{
		GetNativeArray(3, vec, 3);
	}
	return vRespawnPlayer(iClient, iTarget, vec);
}

public void Event_DeadSurvivorVisible(Event event, const char[] name, bool dontBroadcast)
{
	int iDeadBody = event.GetInt("subject");
	int iDeadPlayer = GetClientOfUserId(event.GetInt("deadplayer"));
	
	if( iDeadPlayer && iDeadBody && IsValidEntity(iDeadBody) )
	{
		g_iDeadBody[iDeadPlayer] = EntIndexToEntRef(iDeadBody);
	}
}

public Action CmdRespawnMenu(int client, int args)
{
	MenuClientsToSpawn(client);
	return Plugin_Handled;
}

public Action CmdRespawn(int client, int args)
{
	if( args < 1 )
	{
		if( GetCmdReplySource() == SM_REPLY_TO_CONSOLE )
		{
			PrintToConsole(client, "[SM] Usage: sm_respawn <player1> [player2] ... [playerN] - respawn all listed players");
		}
		CmdRespawnMenu(client, 0);
		return Plugin_Handled;
	}
	char arg1[MAX_TARGET_LENGTH], target_name[MAX_TARGET_LENGTH];
	int target_list[MAXPLAYERS], target_count, target;
	bool tn_is_ml;
	
	GetCmdArg(1, arg1, sizeof arg1);
	if( (target_count = ProcessTargetString(arg1, client, target_list, MAXPLAYERS, 0, target_name, sizeof target_name, tn_is_ml)) <= 0 )
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	for( int i = 0; i < target_count; i++ )
	{
		target = target_list[i];
		
		if( target && IsClientInGame(target) )
		{
			vRespawnPlayer(client, target);
		}
	}
	return Plugin_Handled;
}

bool vRespawnPlayer(int client, int target, float vec[3] = {99999.0, 99999.0, 99999.0})
{
	bool bShouldTeleport;
	float ang[3];
	
	if( vec[0] != VEC_DUMMY[0] || vec[1] != VEC_DUMMY[1] || vec[2] != VEC_DUMMY[2] )
	{
		bShouldTeleport = true;
	}
	else if( GetSpawnEndPoint(client, vec) )
	{
		bShouldTeleport = true;
	}
	if( client )
	{
		GetClientEyeAngles(client, ang);
	}

	switch( GetClientTeam(target) )
	{
		case 2:
		{
			if(IsPlayerAlive(target))
			{
				PrintToChat(client, "[SM] You Dumb? %N is still alive!",target);
				return false;
			}
			L4D_RespawnPlayer(target);
			
			//if( result )
			{
				char sItems[6][64], sLoadout[512];
				
				g_cvLoadout.GetString(sLoadout, sizeof sLoadout);
				if(strlen(sLoadout) > 0)
				{
					StripWeapons( target );

					ExplodeString(sLoadout, ",", sItems, sizeof sItems, sizeof sItems[]);
					
					for( int iItem = 0; iItem < sizeof sItems; iItem++ )
					{
						if ( sItems[iItem][0] != '\0' )
						{
							vCheatCommand(target, "give", sItems[iItem]);
						}
					}
				}
				
				if( bShouldTeleport )
				{
					vPerformTeleport(client, target, vec, ang);
				}
				if( g_cvShowAction.BoolValue && client )
				{
					//ShowActivity2(client, "[SM] ", "%t", "Respawn_Info", target); // "Respawned player '%N'"
				}
			}
		}
		
		case 3:
		{
			PrintToChat(client, "[SM] Failed! %N is not survivor",target);
			return false;
		}
		
		case 1:
		{
			PrintToChat(client, "[SM] Failed! %N is spectator",target);
			return false;
		}
	}
	
	if( g_iDeadBody[target] && GetClientTeam(target) == 2)
	{
		int iDeadBody = EntRefToEntIndex(g_iDeadBody[target]);
		
		if( iDeadBody && iDeadBody != INVALID_ENT_REFERENCE && IsValidEntity(iDeadBody) )
		{
			AcceptEntityInput(iDeadBody, "kill");
		}
	}
	return true;
}

public bool bTraceEntityFilterPlayer(int entity, int contentsMask)
{
	return (entity > MaxClients);
}

bool GetSpawnEndPoint(int client, float vSpawnVec[3])
{
	if( !client )
	{
		return false;
	}
	float vEnd[3], vEye[3];
	if( GetDirectionEndPoint(client, vEnd) )
	{
		GetClientEyePosition(client, vEye);
		ScaleVectorDirection(vEye, vEnd, 0.1); // to allow collision to be happen
		
		if( GetNonCollideEndPoint(client, vEnd, vSpawnVec) )
		{
			return true;
		}
	}
	if( g_cvShowAction.BoolValue && client )
	{
		PrintToChat(client, "[SM] %s", "Could not teleport player after respawn");
	}
	return false;
}

void ScaleVectorDirection(float vStart[3], float vEnd[3], float fMultiple)
{
    float dir[3];
    SubtractVectors(vEnd, vStart, dir);
    ScaleVector(dir, fMultiple);
    AddVectors(vEnd, dir, vEnd);
}

stock bool GetDirectionEndPoint(int client, float vEndPos[3])
{
	float vDir[3], vPos[3];
	GetClientEyePosition(client, vPos);
	GetClientEyeAngles(client, vDir);
	
	Handle hTrace = TR_TraceRayFilterEx(vPos, vDir, MASK_PLAYERSOLID, RayType_Infinite, bTraceEntityFilterPlayer, client);
	if( hTrace != INVALID_HANDLE )
	{
		if( TR_DidHit(hTrace) )
		{
			TR_GetEndPosition(vEndPos, hTrace);
			delete hTrace;
			return true;
		}
		delete hTrace;
	}
	return false;
}

stock bool GetNonCollideEndPoint(int client, float vEnd[3], float vEndNonCol[3])
{
	float vMin[3], vMax[3], vStart[3];
	GetClientEyePosition(client, vStart);
	GetClientMins(client, vMin);
	GetClientMaxs(client, vMax);
	vStart[2] += 20.0; // if nearby area is irregular
	Handle hTrace = TR_TraceHullFilterEx(vStart, vEnd, vMin, vMax, MASK_PLAYERSOLID, bTraceEntityFilterPlayer, client);
	if( hTrace != INVALID_HANDLE )
	{
		if( TR_DidHit(hTrace) )
		{
			TR_GetEndPosition(vEndNonCol, hTrace);
			delete hTrace;
			return true;
		}
		delete hTrace;
	}
	return false;
}

void vPerformTeleport(int client, int target, float pos[3], float ang[3])
{
	pos[2] += 5.0;
	TeleportEntity(target, pos, ang, NULL_VECTOR);

	SDKCall(g_WarpToValidPositionSDKCall, target, 0); //if stuck

	if( g_cvShowAction.BoolValue && client )
	{
		LogAction(client, target, "\"%L\" teleported \"%L\" after respawning him" , client, target);
	}
}

void vCheatCommand(int client, char[] command, char[] arguments = "")
{
	int iCmdFlags = GetCommandFlags(command);
	SetCommandFlags(command, iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments);
	SetCommandFlags(command, iCmdFlags | GetCommandFlags(command));
}

void StripWeapons(int client) // strip all items from client
{
	int itemIdx;
	for (int x = 0; x <= 4; x++)
	{
		if((itemIdx = GetPlayerWeaponSlot(client, x)) != -1)
		{  
			RemovePlayerItem(client, itemIdx);
			AcceptEntityInput(itemIdx, "Kill");
		}
	}
}