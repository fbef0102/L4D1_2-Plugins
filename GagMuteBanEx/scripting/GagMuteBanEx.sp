#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <topmenus>
#include <adminmenu>
#include <basecomm>
#include <multicolors>

#undef REQUIRE_PLUGIN
#tryinclude <sourcecomms>

#if !defined _sourcecomms_included
	/* Punishments types */
	enum bType {
		bNot = 0,  // Player chat or voice is not blocked
		bSess,  // ... blocked for player session (until reconnect)
		bTime,  // ... blocked for some time
		bPerm // ... permanently blocked
	}

	native bType SourceComms_GetClientMuteType(int client);
	native bType SourceComms_GetClientGagType(int client);
	native bool SourceComms_SetClientMute(int client, bool muteState, int muteLength = -1, bool saveToDB = false, const char[] reason = "Muted through natives");
	native bool SourceComms_SetClientGag(int client, bool gagState, int gagLength = -1, bool saveToDB = false, const char[] reason = "Gagged through natives");
#endif

public Plugin myinfo =
{
	name = "GagMuteBanEx",
	author = "HarryPotter",
	description = "Gag & Mute & Ban - Ex",
	version = "1.2h-2024/10/23",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	MarkNativeAsOptional("SourceComms_SetClientMute");
	MarkNativeAsOptional("SourceComms_SetClientGag");
	MarkNativeAsOptional("SourceComms_GetClientMuteType");
	MarkNativeAsOptional("SourceComms_GetClientGagType");

	return APLRes_Success;
}

#define CVAR_FLAGS			FCVAR_NOTIFY
char sg_fileTxt[160];
char sg_log[160];

/* Handler Menu */
TopMenu hTopMenuHandle;

//Convar
ConVar g_hCvarBanAllow, g_hCvarMuteAllow, g_hCvarGagAllow,
	g_hCvarServerVoice, g_hCvarServerChat, g_hCvarServerChatImmuneAccess;

//value
bool g_bCvarBanAllow, g_bCvarMuteAllow, g_bCvarGagAllow,
	g_bCvarServerVoice, g_bCvarServerChat;

int g_iMinutes[MAXPLAYERS+1];
char g_sImmueAcclvl[AdminFlags_TOTAL];
bool 
	g_bHasNotify[MAXPLAYERS+1];

Handle 
	g_hGagTimer[MAXPLAYERS+1],
	g_hMuteTimer[MAXPLAYERS+1];

static char sBan_Time[][][] =
{
	{"1",			"1 min"},
	{"5",			"5 mins"},
	{"30",			"30 mins"},
	{"60",			"60 mins"},
	{"180", 		"3 hrs"},
	{"360", 		"6 hrs"},
	{"720", 		"12 hrs"},
	{"1440", 		"1 day"},
	{"4320", 		"3 days"},
	{"7200", 		"5 days"},
	{"10080", 		"7 days"},
	{"20160", 		"14 days"},
	{"30240", 		"21 days"},
	{"43200", 		"30 days"},
	{"86400", 		"60 days"},
	{"259200", 		"180 days"},
	{"525600", 		"365 days"}
};

KeyValues g_hGM;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("GagMuteBanEx.phrases");

	g_hCvarServerVoice 				= FindConVar("sv_voiceenable");
	g_hCvarBanAllow 				= CreateConVar("GagMuteBanEx_ban_allow", 		"1", "0=Ban Menu off, 1=Ban Menu on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarMuteAllow 				= CreateConVar("GagMuteBanEx_mute_allow", 		"1", "0=Mute Menu off, 1=Mute Menu on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarGagAllow 				= CreateConVar("GagMuteBanEx_gag_allow", 		"1", "0=Gag Menu off, 1=Gag Menu on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarServerChat 				= CreateConVar("sv_chatenable", 				"1", "If 0, Be Quient, No one can chat.", CVAR_FLAGS|FCVAR_DONTRECORD, true, 0.0, true, 1.0);
	g_hCvarServerChatImmuneAccess 	= CreateConVar("GagMuteBanEx_chat_immue_flag", 	"z", "Players with these flags can chat when '_chatenable' is 0 (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
	AutoExecConfig(true, "GagMuteBanEx");

	GetCvars();
	g_hCvarBanAllow.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarMuteAllow.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarGagAllow.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarServerVoice.AddChangeHook(ConVarChanged_CvarServerVoice);
	g_hCvarServerChat.AddChangeHook(ConVarChanged_CvarServerChat);
	g_hCvarServerChatImmuneAccess.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_disconnect",      Event_PlayerDisconnect); //換圖不會觸發該事件

	RegAdminCmd("sm_exban",  CMD_ExBan,  ADMFLAG_BAN,  "sm_exban to Open ExBan Steamid Menu or sm_exban <#userid|name> <minutes|0>");
	RegAdminCmd("sm_exgag",  CMD_ExGag,  ADMFLAG_CHAT, "sm_exgag to Open ExGag Menu or sm_exgag <#userid|name> <minutes|0>");
	RegAdminCmd("sm_exmute", CMD_ExMute, ADMFLAG_CHAT, "sm_exmute to Open ExMute Menu or sm_exmute <#userid|name> <minutes|0>");
	RegAdminCmd("sm_exbanid",  CMD_bansteamid,  ADMFLAG_BAN,  "sm_exbansteam <minutes|0> <STEAM_ID64>");
	RegAdminCmd("sm_exbansteam",  CMD_bansteamid,  ADMFLAG_BAN,  "sm_exbansteam <minutes|0> <STEAM_ID64>");
	RegAdminCmd("sm_exbansteamid",  CMD_bansteamid,  ADMFLAG_BAN,  "sm_exbansteam <minutes|0> <STEAM_ID64>");

	AddCommandListener(CommandListener_removeid, "removeid");

	BuildPath(Path_SM, sg_fileTxt, sizeof(sg_fileTxt), "data/GagMuteBanEx.txt");
	BuildPath(Path_SM, sg_log, sizeof(sg_log), "logs/GagMuteBanEx.log");

	TopMenu hTop_Menu;
	if ( LibraryExists( "adminmenu" ) && ( ( hTop_Menu = GetAdminTopMenu() ) != null ) )
		OnAdminMenuReady( hTop_Menu );
}

bool g_bSourcecommsAvailable;
public void OnAllPluginsLoaded()
{
	g_bSourcecommsAvailable = LibraryExists("sourcecomms++");
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "sourcecomms++") == 0) g_bSourcecommsAvailable = false;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "sourcecomms++")) g_bSourcecommsAvailable = true;
}

public void OnAdminMenuReady( Handle hTop_Menu )
{
	if ( hTop_Menu == hTopMenuHandle )
		return;
	
	hTopMenuHandle = view_as<TopMenu>( hTop_Menu );
	TopMenuObject Menu_Category_Respawn = hTopMenuHandle.AddCategory( "Ban/Mute/Gag Ex", Category_Handler );
	
	if ( Menu_Category_Respawn != INVALID_TOPMENUOBJECT )
	{
		hTopMenuHandle.AddItem( "sm_exbantest", AdminMenu_BanEx, Menu_Category_Respawn, "sm_exbantest", ADMFLAG_BAN );
		hTopMenuHandle.AddItem( "sm_exmutetest", AdminMenu_MuteEx, Menu_Category_Respawn, "sm_exmutetest", ADMFLAG_BAN );
		hTopMenuHandle.AddItem( "sm_exgagtest", AdminMenu_GagEx, Menu_Category_Respawn, "sm_exmutetest", ADMFLAG_BAN );
	}
}

void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue) {
	GetCvars();
}

void ConVarChanged_CvarServerVoice(ConVar convar, const char[] oldValue, const char[] newValue) {
	GetCvars();
	
	if(g_bCvarServerVoice == true)
	{
		CPrintToChatAll("%t", "sv_voiceenable_1");
	}
	else
	{
		CPrintToChatAll("%t", "sv_voiceenable_0");
	}
}

void ConVarChanged_CvarServerChat(ConVar convar, const char[] oldValue, const char[] newValue) {
	GetCvars();

	if(g_bCvarServerChat == true)
	{
		CPrintToChatAll("%t", "sv_chatenable_1");
	}
	else
	{
		CPrintToChatAll("%t", "sv_chatenable_0");
	}
}

void GetCvars()
{
	g_bCvarBanAllow = g_hCvarBanAllow.BoolValue;
	g_bCvarMuteAllow = g_hCvarMuteAllow.BoolValue;
	g_bCvarGagAllow = g_hCvarGagAllow.BoolValue;
	g_bCvarServerChat = g_hCvarServerChat.BoolValue;
	g_bCvarServerVoice = g_hCvarServerVoice.BoolValue;
	g_hCvarServerChatImmuneAccess.GetString(g_sImmueAcclvl,sizeof(g_sImmueAcclvl));
}

public void OnConfigsExecuted()
{
	delete g_hGM;
	g_hGM = new KeyValues("gagmuteban");
	if(!g_hGM.ImportFromFile(sg_fileTxt))
	{
		g_hGM.ExportToFile(sg_fileTxt);
	}
}

void HxClientGagMuteBanEx(int client, bool bAction = true, bool bNotify = true, bool bAllowSourcecomms = false)
{
	if(g_hGM == null) return;
	g_hGM.Rewind();

	bool bModfiy = false;
	static char sTeamID64[32], sTeamID2[32], sName[64];
	GetClientAuthId(client, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));
	GetClientAuthId(client, AuthId_Steam2, sTeamID2, sizeof(sTeamID2));
	GetClientName(client, sName, sizeof(sName));

	if (g_hGM.JumpToKey(sTeamID64))
	{
		int iMute = g_hGM.GetNum("mute", 0);
		int iGag = g_hGM.GetNum("gag", 0);
		int iBan = g_hGM.GetNum("ban", 0);
		int iTime = GetTime();
		int iLeftMinute;
		int userid = GetClientUserId(client);

		if(iMute > 0)
		{
			if (iMute > iTime)
			{
				iLeftMinute = (iMute - iTime) /60;
				if(bAction)
				{
					if(g_bSourcecommsAvailable && bAllowSourcecomms)
					{
						if(BaseComm_IsClientMuted(client) == false)
						{
							if(iLeftMinute > 0) SourceComms_SetClientMute(client, true, iLeftMinute, true, "ExMute");
							else SourceComms_SetClientMute(client, true, 1, true, "ExMute");
						}
					}
					else
					{
						//BaseComm_SetClientMute(client, true);
						ServerCommand("sm_mute #%d", userid);
					}
				}
				if(bNotify) CPrintToChat(client, "%T", "ExMute_1", client, iLeftMinute );
				
				delete g_hMuteTimer[client];
				g_hMuteTimer[client] = CreateTimer(float(iMute - iTime), Timer_UnMute, client);
			}
			else if (iMute != 0) //時間已到
			{
				ServerCommand("sm_unmute #%d", userid);
				g_hGM.SetNum("mute", 0);
				iMute = 0;
				bModfiy = true;
			}
		}

		if(iGag > 0)
		{
			if (iGag > iTime)
			{
				iLeftMinute = (iGag - iTime) /60;
				if(bAction)
				{
					if(g_bSourcecommsAvailable && bAllowSourcecomms)
					{
						if(BaseComm_IsClientGagged(client) == false)
						{
							if(iLeftMinute > 0) SourceComms_SetClientGag(client, true, iLeftMinute, true, "ExGag");
							else SourceComms_SetClientGag(client, true, 1, true, "ExGag");
						}
					}
					else
					{
						BaseComm_SetClientGag(client, true);
						//ServerCommand("sm_gag #%d", userid);
					}
				}
				if(bNotify) CPrintToChat(client, "%T", "ExGag_1", client, iLeftMinute );
				
				delete g_hGagTimer[client];
				g_hGagTimer[client] = CreateTimer(float(iGag - iTime), Timer_UnGag, client);
			}
			else if (iGag != 0) //時間已到
			{
				ServerCommand("sm_ungag #%d", userid);
				g_hGM.SetNum("gag", 0);
				iGag = 0;
				bModfiy = true;
			}
		}

		if(iBan > 0)
		{
			if (iBan > iTime)
			{
				static char sTime[24], sReason[64];
				
				FormatTime(sTime, sizeof(sTime), "%Y-%m-%d %H:%M:%S", iBan);
				FormatEx(sReason, sizeof(sReason), "ExBan, unban time: %s", sTime);

				iLeftMinute = (iBan-iTime)/60;
				if(iLeftMinute == 0)
				{
					KickClient(client, sReason);
				}
				else
				{
					//有使用sourceban++會記錄 (有名子顯示)
					//使用sm_ban 會立即踢人
					ServerCommand("sm_ban #%d %d \"%s\"", userid, iLeftMinute, sReason);
				}
			}
			else
			{
				g_hGM.SetNum("ban", 0);
				iBan = 0;
			}

			bModfiy = true;
		}

		if (iMute == 0 && iGag == 0 && iBan == 0)
		{
			g_hGM.DeleteThis();
			g_hGM.Rewind();
			if (g_hGM.JumpToKey("Steam_Id_Convert", true))
			{
				if(g_hGM.JumpToKey(sTeamID2))
				{
					g_hGM.DeleteThis();
				}
			}
			g_hGM.Rewind();
			g_hGM.ExportToFile(sg_fileTxt);
		}
		else if (bModfiy)
		{
			g_hGM.SetString("Name", sName);
			g_hGM.Rewind();
			if (g_hGM.JumpToKey("Steam_Id_Convert", true))
			{
				g_hGM.JumpToKey(sTeamID2, true);
				g_hGM.SetString("steam_id_64", sTeamID64);
				g_hGM.Rewind();
				g_hGM.ExportToFile(sg_fileTxt);
			}
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	if (IsFakeClient(client)) return;

	if(g_bSourcecommsAvailable)
	{
		CreateTimer(5.0, Timer_PutInServer_Sourcecomms, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		HxClientGagMuteBanEx(client, true, false, false);
		CreateTimer(5.0, Timer_PutInServer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
	
}

public void OnClientDisconnect(int client)
{
	if(!IsClientInGame(client)) return;

	delete g_hGagTimer[client];
	delete g_hMuteTimer[client];
} 

bool HxClientTimeBan(int &client, int iminute)
{
	if(g_hGM == null) return false;
	g_hGM.Rewind();

	if (IsClientInGame(client))
	{
		static char sName[64], sTeamID64[32], sTeamID2[32];

		GetClientName(client, sName, sizeof(sName));
		GetClientAuthId(client, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));
		GetClientAuthId(client, AuthId_Steam2, sTeamID2, sizeof(sTeamID2));

		g_hGM.JumpToKey(sTeamID64, true);

		int iTimeBan = GetTime() + (iminute * 60);
		g_hGM.SetString("Name", sName);
		g_hGM.SetNum("ban", iTimeBan);
		g_hGM.Rewind();
		if (g_hGM.JumpToKey("Steam_Id_Convert", true))
		{
			g_hGM.JumpToKey(sTeamID2, true);
			g_hGM.SetString("steam_id_64", sTeamID64);
			g_hGM.Rewind();
		}
		g_hGM.ExportToFile(sg_fileTxt);

		return true;
	}
	return false;
}

int MenuHandler_BanPlayer(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		static char sInfo[8], sTeamID64[32], sTeamID2[32], sReason[64];
		menu.GetItem(param2, sInfo, sizeof(sInfo));
		int target = StringToInt(sInfo);
		target = GetClientOfUserId(target);
		if (target && IsClientInGame(target))
		{
			if (HxClientTimeBan(target, g_iMinutes[param1]))
			{
				GetClientAuthId(target, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));
				GetClientAuthId(target, AuthId_Steam2, sTeamID2, sizeof(sTeamID2));
				LogToFileEx(sg_log, "Ban: %N(Adm) ExBan %N (ID: %s) for %d minute(s)", param1, target, sTeamID64, g_iMinutes[param1]);
				CPrintToChatAll("%t", "ExBan_1", target, g_iMinutes[param1]);

				FormatEx(sReason, sizeof(sReason),"%d minute(s) Exban.", g_iMinutes[param1]);
				//KickClient(target, sReason);

				//有使用sourceban++會記錄 (有名子顯示)
				//使用sm_ban 會立即踢人
				ServerCommand("sm_ban #%d %d \"%s\"", GetClientUserId(target), g_iMinutes[param1], sReason);

				//有使用sourceban++會記錄 (沒名子顯示)
				//使用sm_addban不會立即踢人
				//ServerCommand("sm_addban %d \"%s\" \"%s\"", g_iMinutes[param1], sTeamID2, sReason);
				
				/*
				//有使用sourceban++不會記錄
				//使用BanIdentity不會立即踢人
				BanIdentity(sTeamID2, 
							g_iMinutes[param1], 
							BANFLAG_AUTHID, 
							sReason, 
							"sm_addban", 
							0);
				*/
			}
		}
		else
		{
			CPrintToChat(param1, "%T", "InValid_Target", param1);
			CMD_ExBan( param1, 0 );
		}
	}
	else if ( action == MenuAction_Cancel )
	{
		if ( param2 == MenuCancel_ExitBack )
			CMD_ExBan( param1, 0 );
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

void Menu_BanPlayer(int client)
{
	if (client)
	{
		if (IsClientInGame(client))
		{
			static char sId[16], name[64];

			Menu hMenu = new Menu(MenuHandler_BanPlayer);
			hMenu.SetTitle("%T", "Menu Ban Ex (player)", client);

			for (int i=1; i <= MaxClients ; ++i)
			{
				if (IsClientInGame(i) && !IsFakeClient(i))
				{
					FormatEx(sId, sizeof sId, "%i", GetClientUserId(i));
					GetClientName(i, name, sizeof(name));
					hMenu.AddItem(sId, name);
				}
			}

			hMenu.ExitBackButton = true;
			hMenu.ExitButton = true;
			hMenu.Display(client, MENU_TIME_FOREVER);
		}
	}
}

int MenuHandler_BanTime(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char sInfo[8];
		menu.GetItem(param2, sInfo, sizeof(sInfo));
		g_iMinutes[param1] = StringToInt(sInfo);
		Menu_BanPlayer(param1);
	}
	else if ( action == MenuAction_Cancel )
	{
		if ( param2 == MenuCancel_ExitBack && hTopMenuHandle )
			hTopMenuHandle.Display( param1, TopMenuPosition_LastCategory );
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

Action CMD_ExBan(int client, int args)
{
	if (g_bCvarBanAllow == false)
	{
		ReplyToCommand(client, "[TS] ExBan Menu is disabled now.");
		return Plugin_Handled;
	}

	if (args != 2 && args != 0)
	{
		ReplyToCommand(client, "[TS] sm_exban <name> <minutes> or sm_exban to open ExBan menu");
	}

	if(args == 2)
	{
		static char arg1[32], arg2[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		int target = FindTarget(client, arg1, true /*nobots*/, false /*immunity*/);
		if(target == -1) return Plugin_Handled;	

		GetCmdArg(2, arg2, sizeof(arg2));
		int minutes = StringToInt(arg2);
		if(minutes==0) minutes = 9999999;

		if (HxClientTimeBan(target, minutes))
		{
			static char sTeamID64[32], sTeamID2[32], sReason[64];
			GetClientAuthId(target, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));
			GetClientAuthId(target, AuthId_Steam2, sTeamID2, sizeof(sTeamID2));
				
			if(client > 0)
			{
				LogToFileEx(sg_log, "[TS] Ban: %N(Adm) ExBan %N (ID: %s) for %d minute(s)", client, target, sTeamID64, minutes);
				CPrintToChatAll("%T", "ExBan_1", target, minutes);
			}
			else
			{
				LogToFileEx(sg_log, "[TS] Ban: Server ExBan %N (ID: %s) for %d minute(s)", target, sTeamID64, minutes);
				CPrintToChatAll("%T", "ExBan_2", target, minutes);
			}

			FormatEx(sReason, sizeof(sReason),"%d minute(s) ExBan.", minutes);
			//KickClient(target, sReason);

			//有使用sourceban++會記錄 (有名子顯示)
			//使用sm_ban 會立即踢人
			ServerCommand("sm_ban #%d %d \"%s\"", GetClientUserId(target), minutes, sReason);

			//有使用sourceban++會記錄 (沒名子顯示)
			//使用sm_addban不會立即踢人
			//ServerCommand("sm_addban %d \"%s\" \"%s\"", minutes, sTeamID2, sReason);
			
			/*
			//有使用sourceban++不會記錄
			BanIdentity(sTeamID2, 
						minutes, 
						BANFLAG_AUTHID, 
						sReason, 
						"sm_addban", 
						0);
			*/
		}
	}
	else
	{
		if (client == 0)
		{
			PrintToServer("[TS] server please uses sm_exban <name> <minutes>");
			return Plugin_Handled;
		}

		Menu menu = new Menu(MenuHandler_BanTime);
		for(int i = 0; i < sizeof(sBan_Time); i++)
		{
			menu.AddItem(sBan_Time[i][0], sBan_Time[i][1]);
		}
		menu.SetTitle("%T", "Menu Ban Ex (Time)", client);
		menu.ExitBackButton = true;
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}

	return Plugin_Handled;
}

bool HxClientTimeGag(int &client, int iminute)
{
	if(g_hGM == null) return false;
	g_hGM.Rewind();

	if (IsClientInGame(client))
	{
		static char sName[128], sTeamID64[32];

		GetClientName(client, sName, sizeof(sName));
		GetClientAuthId(client, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));

		g_hGM.JumpToKey(sTeamID64, true);

		int iTimeGag = GetTime() + (iminute * 60);
		g_hGM.SetString("Name", sName);
		if(iminute == 0)
		{
			g_hGM.SetNum("gag", 0);
		}
		else
		{
			g_hGM.SetNum("gag", iTimeGag);
		}
		g_hGM.Rewind();
		g_hGM.ExportToFile(sg_fileTxt);
		
		if(iminute == 0)
		{
			ServerCommand("sm_ungag #%d", GetClientUserId(client));
		}
		else
		{	
			if(g_bSourcecommsAvailable)
			{
				SourceComms_SetClientGag(client, true, iminute, true, "ExGag");
			}
			else
			{
				BaseComm_SetClientGag(client, true);
			}
		}
		
		return true;
	}

	return false;
}

int MenuHandler_GagPlayer(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		static char sInfo[8], sTeamID64[32];
		menu.GetItem(param2, sInfo, sizeof(sInfo));
		int target = StringToInt(sInfo);
		target = GetClientOfUserId(target);
		if (target && IsClientInGame(target))
		{
			if (HxClientTimeGag(target, g_iMinutes[param1]))
			{
				GetClientAuthId(target, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));
				LogToFileEx(sg_log, "Gag: %N(Adm) ExGag %N (ID: %s) for %d minute(s)", param1, target, sTeamID64, g_iMinutes[param1]);
				CPrintToChatAll("%t", "ExGag_2", target, g_iMinutes[param1]);
			
				delete g_hGagTimer[target];
				g_hGagTimer[target] = CreateTimer(g_iMinutes[param1]*60.0, Timer_UnGag, target);
			}
		}
		else
		{
			CPrintToChat(param1, "%T", "InValid_Target", param1);
			CMD_ExGag( param1, 0 );
		}
	}
	else if ( action == MenuAction_Cancel )
	{
		if ( param2 == MenuCancel_ExitBack)
			CMD_ExGag( param1, 0 );
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

void Menu_GagPlayer(int client)
{
	if (client)
	{
		if (IsClientInGame(client))
		{
			static char sId[16], name[64];

			Menu hMenu = new Menu(MenuHandler_GagPlayer);
			hMenu.SetTitle("%T", "Menu Block Chat Ex (Player)", client);

			for (int i=1; i <= MaxClients ; ++i)
			{
				if (IsClientInGame(i) && !IsFakeClient(i))
				{
					FormatEx(sId, sizeof sId, "%i", GetClientUserId(i));
					GetClientName(i, name, sizeof(name));
					hMenu.AddItem(sId, name);
				}
			}

			hMenu.ExitBackButton = true;
			hMenu.ExitButton = true;
			hMenu.Display(client, MENU_TIME_FOREVER);
		}
	}
}

int MenuHandler_GagTime(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char sInfo[8];
		menu.GetItem(param2, sInfo, sizeof(sInfo));
		g_iMinutes[param1] = StringToInt(sInfo);
		Menu_GagPlayer(param1);
	}
	else if ( action == MenuAction_Cancel )
	{
		if ( param2 == MenuCancel_ExitBack && hTopMenuHandle )
			hTopMenuHandle.Display( param1, TopMenuPosition_LastCategory );
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

Action CMD_ExGag(int client, int args)
{
	if (g_bCvarGagAllow == false)
	{
		ReplyToCommand(client, "[TS] ExGag Menu is disabled now.");
		return Plugin_Handled;
	}

	if (args != 2 && args != 0)
	{
		ReplyToCommand(client, "[TS] sm_exgag <name> <minutes> or sm_exgag to open ExGag menu");
	}

	if(args == 2)
	{
		static char arg1[32], arg2[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		int target = FindTarget(client, arg1, true /*nobots*/, false /*immunity*/);
		if(target == -1) return Plugin_Handled;	

		GetCmdArg(2, arg2, sizeof(arg2));
		int minutes = StringToInt(arg2);
		if(minutes==0) minutes = 9999999;

		if (HxClientTimeGag(target, minutes))
		{
			static char sTeamID64[32];
			GetClientAuthId(target, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));

			if(client > 0)
			{
				LogToFileEx(sg_log, "Gag: %N(Adm) ExGag %N (ID: %s) for %d minute(s)", client, target, sTeamID64, minutes);
				CPrintToChatAll("%t", "ExGag_2", target, minutes);
			}
			else
			{
				LogToFileEx(sg_log, "[TS] Gag: Server ExGag %N (ID: %s) for %d minute(s)", target, sTeamID64, minutes);
				CPrintToChatAll("%t", "ExGag_3", target, minutes);
			}

			delete g_hGagTimer[target];
			g_hGagTimer[target] = CreateTimer(minutes*60.0, Timer_UnGag, target);
		}
	}
	else
	{
		if (client == 0)
		{
			PrintToServer("[TS] server please uses sm_exgag <name> <minutes>");
			return Plugin_Handled;
		}

		Menu menu = new Menu(MenuHandler_GagTime);
		for(int i = 0; i < sizeof(sBan_Time); i++)
		{
			menu.AddItem(sBan_Time[i][0], sBan_Time[i][1]);
		}
		menu.SetTitle("%T", "Menu Block Chat Ex (Time)", client);
		menu.ExitBackButton = true;
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}

	return Plugin_Handled;
}

bool HxClientTimeMute(int &client, int iminute)
{
	if(g_hGM == null) return false;
	g_hGM.Rewind();

	if (IsClientInGame(client))
	{
		static char sName[128], sTeamID64[32];

		GetClientName(client, sName, sizeof(sName));
		GetClientAuthId(client, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));

		g_hGM.JumpToKey(sTeamID64, true);

		int iTimeMute = GetTime() + (iminute * 60);
		g_hGM.SetString("Name", sName);
		if(iminute == 0)
		{
			g_hGM.SetNum("mute", 0);
		}
		else
		{
			g_hGM.SetNum("mute", iTimeMute);
		}
		g_hGM.Rewind();
		g_hGM.ExportToFile(sg_fileTxt);

		if(iminute == 0)
		{
			ServerCommand("sm_unmute #%d", GetClientUserId(client));
		}
		else
		{
			if(g_bSourcecommsAvailable)
			{
				SourceComms_SetClientMute(client, true, iminute, true, "ExMute");
			}
			else
			{
				BaseComm_SetClientMute(client, true);
			}
		}

		return true;
	}

	return false;
}

int MenuHandler_MutePlayer(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		static char sInfo[8], sTeamID64[32];
		menu.GetItem(param2, sInfo, sizeof(sInfo));
		int target = StringToInt(sInfo);
		target = GetClientOfUserId(target);
		if (target && IsClientInGame(target))
		{
			if (HxClientTimeMute(target, g_iMinutes[param1]))
			{
				GetClientAuthId(target, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));
				LogToFileEx(sg_log, "Mute: %N(Adm) ExMute %N (ID: %s) for %d minute(s).", param1, target, sTeamID64, g_iMinutes[param1]);
				CPrintToChatAll("%t", "ExMute_2", target, g_iMinutes[param1]);
			
				delete g_hMuteTimer[target];
				g_hMuteTimer[target] = CreateTimer(g_iMinutes[param1]*60.0, Timer_UnMute, target);
			}
		}
		else
		{
			CPrintToChat(param1, "%T", "InValid_Target", param1);
			CMD_ExMute( param1, 0 );
		}
	}
	else if ( action == MenuAction_Cancel )
	{
		if ( param2 == MenuCancel_ExitBack )
			CMD_ExMute( param1, 0 );
	}
	if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

void Menu_MutePlayer(int client)
{
	if (IsClientInGame(client))
	{
		static char sId[16], name[64];

		Menu hMenu = new Menu(MenuHandler_MutePlayer);
		hMenu.SetTitle("%T", "Menu Block Microphone Ex (Player)", client);

		for (int i=1; i <= MaxClients ; ++i)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				FormatEx(sId, sizeof sId, "%i", GetClientUserId(i));
				GetClientName(i, name, sizeof(name));
				hMenu.AddItem(sId, name);
			}
		}

		hMenu.ExitBackButton = true;
		hMenu.ExitButton = true;
		hMenu.Display(client, MENU_TIME_FOREVER);
	}
}

int MenuHandler_MuteTime(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char sInfo[8];
		menu.GetItem(param2, sInfo, sizeof(sInfo));
		g_iMinutes[param1] = StringToInt(sInfo);
		Menu_MutePlayer(param1);
	}
	else if ( action == MenuAction_Cancel )
	{
		if ( param2 == MenuCancel_ExitBack && hTopMenuHandle )
			hTopMenuHandle.Display( param1, TopMenuPosition_LastCategory );
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}

	return 0;
}

Action CMD_ExMute(int client, int args)
{
	if (g_bCvarMuteAllow == false)
	{
		ReplyToCommand(client, "[TS] ExMute Menu is disabled now.");
		return Plugin_Handled;
	}

	if (args != 2 && args != 0)
	{
		ReplyToCommand(client, "[TS] sm_exmute <name> <minutes> or sm_exmute to open ExMute menu");
	}

	if(args == 2)
	{
		static char arg1[32], arg2[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		int target = FindTarget(client, arg1, true /*nobots*/, false /*immunity*/);
		if(target == -1) return Plugin_Handled;	

		GetCmdArg(2, arg2, sizeof(arg2));
		int minutes = StringToInt(arg2);
		if(minutes==0) minutes = 9999999;

		if (HxClientTimeMute(target, minutes))
		{
			static char sTeamID64[32];
			GetClientAuthId(target, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));

			if(client > 0)
			{
				LogToFileEx(sg_log, "Mute: %N(Adm) ExMute %N (ID: %s) for %d minute(s).", client, target, sTeamID64, minutes);
				CPrintToChatAll("%t", "ExMute_2", target, minutes);
			}
			else
			{
				LogToFileEx(sg_log, "[TS] Mute: Server exmute %N (ID: %s) for %d minute(s)", target, sTeamID64, minutes);
				CPrintToChatAll("%t", "ExMute_3", target, minutes);
			}

			delete g_hMuteTimer[target];
			g_hMuteTimer[target] = CreateTimer(minutes*60.0, Timer_UnMute, target);
		}
	}
	else
	{
		if (client == 0)
		{
			PrintToServer("[TS] server please uses sm_exmute <name> <minutes>");
			return Plugin_Handled;
		}

		Menu menu = new Menu(MenuHandler_MuteTime);
		for(int i = 0; i < sizeof(sBan_Time); i++)
		{
			menu.AddItem(sBan_Time[i][0], sBan_Time[i][1]);
		}
		menu.SetTitle("%T", "Menu Block Microphone Ex (Time)", client);
		menu.ExitBackButton = true;
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}

	return Plugin_Handled;
}

bool HxClientTimeBanSteam(char[] steam_id, int iminute)
{
	if(g_hGM == null) return false;
	g_hGM.Rewind();

	g_hGM.JumpToKey(steam_id, true);
	int iTimeBan = GetTime() + (iminute * 60);
	g_hGM.SetNum("ban", iTimeBan);
	g_hGM.Rewind();
	g_hGM.ExportToFile(sg_fileTxt);

	return true;
}

Action CMD_bansteamid(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_exbansteam <minutes> <STEAM_ID64>");
		return Plugin_Handled;
	}
	
	static char arg_string[256], minute[50], authid[32];

	GetCmdArgString(arg_string, sizeof(arg_string));

	int len, total_len;
	
	/* Get minute */
	if ((len = BreakString(arg_string, minute, sizeof(minute))) == -1)
	{
		ReplyToCommand(client, "Usage: sm_exbansteam <minutes> <steamid64>");
		return Plugin_Handled;
	}	
	total_len += len;
	
	/* Get steamid */
	if ((len = BreakString(arg_string[total_len], authid, sizeof(authid))) != -1)
	{
		total_len += len;
	}
	else
	{
		total_len = 0;
		arg_string[0] = '\0';
	}
	
	/* Verify steamid */
	bool idValid = true;
	if (strncmp(authid, "STEAM_", 6, false) == 0 || strncmp(authid, "U:", 2, false) == 0)
		idValid = false;
	
	if (!idValid)
	{
		ReplyToCommand(client, "Invalid SteamID specified (Must be Steam64 ID )");
		return Plugin_Handled;
	}
	
	int minutes = StringToInt(minute);
	if(minutes==0) minutes = 9999999;
	
	HxClientTimeBanSteam(authid, minutes);
	for ( int i = 1 ; i <= MaxClients ; ++i ) 
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			HxClientGagMuteBanEx(i);
		}
	}
	if(client != 0)
	{
		LogToFileEx(sg_log, "%N(Adm) added steamid %s in GagMuteBanEx list, %d minute(s) ban.", client, authid, minutes);
		CPrintToChat(client, "%t", "ExBan_File", authid, minutes);
	}
	else
		LogToFileEx(sg_log, "Server Console added steamid %s in GagMuteBanEx list, %d minute(s) ban.", authid, minutes);

	return Plugin_Handled;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
	if (client < 0 || client > MaxClients)
		return Plugin_Continue;

	if (g_bCvarServerChat)
		return Plugin_Continue;

	if (BaseComm_IsClientGagged(client) == true) //this client has been gagged
		return Plugin_Continue;	

	if (HasAccess(client, g_sImmueAcclvl) == true)
		return Plugin_Continue;	

	return Plugin_Handled;
}

//Admin Category Names In Main Menu.
int Category_Handler( TopMenu hTop_Menu, TopMenuAction hAction, TopMenuObject topobj_id, int param, char[] buffer, int maxlength )
{
	if ( hAction == TopMenuAction_DisplayTitle )
		Format( buffer, maxlength, Translate(param, "%t", "Select an option"));
	
	else if( hAction == TopMenuAction_DisplayOption)
		Format( buffer, maxlength, Translate(param, "%t", "Ban/Mute/Gag-Ex"));

	return 0;
}

void AdminMenu_BanEx( TopMenu hTop_Menu, TopMenuAction hAction, TopMenuObject object_id, int param, char[] buffer, int maxlength )
{
	if ( hAction == TopMenuAction_DisplayOption )
		Format( buffer, maxlength, Translate(param, "%t", "Ban Player - Ex"));
	
	else if ( hAction == TopMenuAction_SelectOption )
		CMD_ExBan( param , 0);
}

void AdminMenu_MuteEx( TopMenu hTop_Menu, TopMenuAction hAction, TopMenuObject object_id, int param, char[] buffer, int maxlength )
{
	if ( hAction == TopMenuAction_DisplayOption )
		Format( buffer, maxlength, Translate(param, "%t", "Mute Player - Ex"));
	
	else if ( hAction == TopMenuAction_SelectOption )
		CMD_ExMute( param , 0);
}

void AdminMenu_GagEx( TopMenu hTop_Menu, TopMenuAction hAction, TopMenuObject object_id, int param, char[] buffer, int maxlength )
{
	if ( hAction == TopMenuAction_DisplayOption )
		Format( buffer, maxlength, Translate(param, "%t", "Gag Player - Ex"));
	
	else if ( hAction == TopMenuAction_SelectOption )
		CMD_ExGag( param , 0);
}

bool HasAccess(int client, char[] sAcclvl)
{
	// no permissions set
	if (strlen(sAcclvl) == 0)
		return true;

	else if (StrEqual(sAcclvl, "-1"))
		return false;

	// check permissions
	int userFlags = GetUserFlagBits(client);
	if ( (userFlags & ReadFlagString(sAcclvl)) || (userFlags & ADMFLAG_ROOT))
	{
		return true;
	}

	return false;
}

Action Timer_UnGag(Handle timer, int client)
{
	if(client && IsClientInGame(client) && !IsFakeClient(client) && BaseComm_IsClientGagged(client))
	{
		HxClientTimeGag(client, 0);
	}

	g_hGagTimer[client] = null;
	return Plugin_Continue;
}

Action Timer_UnMute(Handle timer, int client)
{
	if(client && IsClientInGame(client) && !IsFakeClient(client) && BaseComm_IsClientMuted(client))
	{
		HxClientTimeMute(client, 0);
	}

	g_hMuteTimer[client] = null;
	return Plugin_Continue;
}

Action Timer_PutInServer(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(client && IsClientInGame(client) && !IsFakeClient(client))
	{
		HxClientGagMuteBanEx(client, false, true);

		if (g_bCvarServerVoice == false) {
			if(!g_bHasNotify[client]) CPrintToChat(client, "%T", "sv_voiceenable_off", client);
			g_bHasNotify[client] = true;
		}

		if (g_bCvarServerChat == false) {
			if(!g_bHasNotify[client]) CPrintToChat(client, "%T", "sv_chatenable_off", client);
			g_bHasNotify[client] = true;
		}
	}

	return Plugin_Continue;
}

Action Timer_PutInServer_Sourcecomms(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(client && IsClientInGame(client) && !IsFakeClient(client))
	{
		HxClientGagMuteBanEx(client, true, true, true);

		if (g_bCvarServerVoice == false) {
			if(!g_bHasNotify[client]) CPrintToChat(client, "%T", "sv_voiceenable_off", client);
			g_bHasNotify[client] = true;
		}

		if (g_bCvarServerChat == false) {
			if(!g_bHasNotify[client]) CPrintToChat(client, "%T", "sv_chatenable_off", client);
			g_bHasNotify[client] = true;
		}
	}

	return Plugin_Continue;
}

// Replace original text with translated text (Zakikun)
char[] Translate(int client, const char[] format, any ...)
{
	char buffer[192];
	SetGlobalTransTarget(client);
	VFormat(buffer, sizeof(buffer), format, 3);
	return buffer;
}

public void BaseComm_OnClientGag(int client, bool gagState)
{
	if(gagState) return;

	if(g_hGM == null) return;
	g_hGM.Rewind();

	if (IsClientInGame(client))
	{
		static char sName[128], sTeamID64[32];

		GetClientName(client, sName, sizeof(sName));
		GetClientAuthId(client, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));

		g_hGM.JumpToKey(sTeamID64, true);
		g_hGM.SetNum("gag", 0);
		g_hGM.Rewind();
		g_hGM.ExportToFile(sg_fileTxt);
	}
}

public void BaseComm_OnClientMute(int client, bool muteState)
{
	if(muteState) return;

	if(g_hGM == null) return;
	g_hGM.Rewind();

	if (IsClientInGame(client))
	{
		static char sName[128], sTeamID64[32];

		GetClientName(client, sName, sizeof(sName));
		GetClientAuthId(client, AuthId_SteamID64, sTeamID64, sizeof(sTeamID64));

		g_hGM.JumpToKey(sTeamID64, true);
		g_hGM.SetNum("mute", 0);
		g_hGM.Rewind();
		g_hGM.ExportToFile(sg_fileTxt);
	}
}

/*
// 只有 basban 會觸發
public Action OnRemoveBan(const char[] identity,
						   int flags,
						   const char[] command,
						   any source)
{
	if(g_hGM == null) return Plugin_Continue;
	g_hGM.Rewind();

	//PrintToServer("OnRemoveBan %s", identity);

	static char sTeamID64[32];

	g_hGM.Rewind();
	if (g_hGM.JumpToKey("Steam_Id_Convert"))
	{
		if(g_hGM.JumpToKey(identity) == false) return Plugin_Continue;

		g_hGM.GetString("steam_id_64", sTeamID64, sizeof(sTeamID64));
		g_hGM.Rewind();
	}
	else
	{
		return Plugin_Continue;
	}

	if (g_hGM.JumpToKey(sTeamID64))
	{
		g_hGM.SetNum("ban", 0);
		g_hGM.Rewind();
		g_hGM.ExportToFile(sg_fileTxt);
	}

	return Plugin_Continue;
}*/


// sourceban++ 與 basban 都會觸發
Action CommandListener_removeid(int client, const char[] command, int args)
{
	static char sTeamID[5][32], sTeamID2[32];
	GetCmdArg(1, sTeamID[0], sizeof(sTeamID[]));
	GetCmdArg(2, sTeamID[1], sizeof(sTeamID[]));
	GetCmdArg(3, sTeamID[2], sizeof(sTeamID[]));
	GetCmdArg(4, sTeamID[3], sizeof(sTeamID[]));
	GetCmdArg(5, sTeamID[4], sizeof(sTeamID[]));
	FormatEx(sTeamID2, sizeof(sTeamID2), "%s%s%s%s%s", sTeamID[0], sTeamID[1], sTeamID[2], sTeamID[3], sTeamID[4]);

	//PrintToServer("removeid args: %s", sTeamID2);

	static char sTeamID64[32];

	g_hGM.Rewind();
	if (g_hGM.JumpToKey("Steam_Id_Convert"))
	{
		if(g_hGM.JumpToKey(sTeamID2) == false) return Plugin_Continue;

		g_hGM.GetString("steam_id_64", sTeamID64, sizeof(sTeamID64));
		g_hGM.Rewind();
	}
	else
	{
		return Plugin_Continue;
	}

	if (g_hGM.JumpToKey(sTeamID64))
	{
		g_hGM.SetNum("ban", 0);
		g_hGM.Rewind();
		g_hGM.ExportToFile(sg_fileTxt);
	}

	return Plugin_Continue;
}

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(client == 0 || !IsClientInGame(client))
		return;

	g_bHasNotify[client] = false;
}