/**
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <www.sourcemod.net/license.php>.
 *
*/
#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <topmenus>
#include <adminmenu>
#include <multicolors>
#include <basecomm>

#define HX_DELETE 1
#define CVAR_FLAGS			FCVAR_NOTIFY
char sg_fileTxt[160];
char sg_log[160];

/* Handler Menu */
TopMenu hTopMenu;
TopMenu hTopMenuHandle;

//Convar
ConVar g_hCvarBanAllow, g_hCvarMuteAllow, g_hCvarGagAllow,
	g_hCvarServerVoice, g_hCvarServerChat, g_hCvarServerChatImmuneAccess;

//value
bool g_bCvarBanAllow, g_bCvarMuteAllow, g_bCvarGagAllow,
	g_bCvarServerVoice, g_bCvarServerChat;

int ig_minutes;
char g_sImmueAcclvl[16];

static char sBan_Time[][][] =
{
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

public Plugin myinfo =
{
	name = "GagMuteBanEx",
	author = "MAKS & dr lex & HarryPotter",
	description = "gag & mute & ban",
	version = "1.6",
	url = "forums.alliedmods.net/showthread.php?p=2347844"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");

	ig_minutes = 1;
	RegAdminCmd("sm_exban",  CMD_addbanmenu,  ADMFLAG_BAN,  "sm_exban to Open exBan Steamid Menu or sm_exban <name> <minutes>");
	RegAdminCmd("sm_exgag",  CMD_addgagmenu,  ADMFLAG_CHAT, "sm_exgag to Open exGag Menu or sm_exgag <name> <minutes>");
	RegAdminCmd("sm_exmute", CMD_addmutemenu, ADMFLAG_CHAT, "sm_exmute to Open exMute Menu or sm_exmute <name> <minutes>");
	RegAdminCmd("sm_exbanid",  CMD_bansteamid,  ADMFLAG_BAN,  "sm_exbansteam <minutes> <STEAM_ID>");
	RegAdminCmd("sm_exbansteam",  CMD_bansteamid,  ADMFLAG_BAN,  "sm_exbansteam <minutes> <STEAM_ID>");
	RegAdminCmd("sm_exbansteamid",  CMD_bansteamid,  ADMFLAG_BAN,  "sm_exbansteam <minutes> <STEAM_ID>");

	BuildPath(Path_SM, sg_fileTxt, sizeof(sg_fileTxt)-1, "data/GagMuteBanEx.txt");
	BuildPath(Path_SM, sg_log, sizeof(sg_log)-1, "logs/GagMuteBanEx.log");

	TopMenu hTop_Menu;
	if ( LibraryExists( "adminmenu" ) && ( ( hTop_Menu = GetAdminTopMenu() ) != null ) )
		OnAdminMenuReady( hTop_Menu );

	g_hCvarBanAllow = CreateConVar("GagMuteBanEx_ban_allow", "1", "0=Ban Menu off, 1=Ban Menu on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarMuteAllow = CreateConVar("GagMuteBanEx_mute_allow", "1", "0=Mute Menu off, 1=Mute Menu on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarGagAllow = CreateConVar("GagMuteBanEx_gag_allow", "1", "0=Gag Menu off, 1=Gag Menu on.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarServerVoice = FindConVar("sv_voiceenable");
	g_hCvarServerChat = CreateConVar("sv_chatenable", "1", "If 0, Be Quient, No one can chat.", CVAR_FLAGS, true, 0.0, true, 1.0);
	g_hCvarServerChatImmuneAccess = CreateConVar("GagMuteBanEx_chat_immue_flag", "z", "Players with these flags can chat when 'sv_chatenable' is 0 (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);

	GetCvars();
	g_hCvarBanAllow.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarMuteAllow.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarGagAllow.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarServerVoice.AddChangeHook(ConVarChanged_CvarServerVoice);
	g_hCvarServerChat.AddChangeHook(ConVarChanged_CvarServerChat);
	g_hCvarServerChatImmuneAccess.AddChangeHook(ConVarChanged_ServerChatImmuneAccess);

	HookEvent("round_start", Event_RoundStart);

	AutoExecConfig(true, "GagMuteBanEx");
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue) {
	GetCvars();
}

public void ConVarChanged_CvarServerVoice(ConVar convar, const char[] oldValue, const char[] newValue) {
	GetCvars();
	
	if(g_bCvarServerVoice == true)
	{
		CPrintToChatAll("[{olive}TS{default}] sv_voiceenable @ {green}1{default}. 開放語音功能! We can Talk Now !");
	}
	else
	{
		CPrintToChatAll("[{olive}TS{default}] sv_voiceenable @ {green}0{default}. 伺服器禁用語音! Everyone Shut Up!");
	}
}

public void ConVarChanged_CvarServerChat(ConVar convar, const char[] oldValue, const char[] newValue) {
	GetCvars();

	if(g_bCvarServerChat == true)
	{
		CPrintToChatAll("[{olive}TS{default}] sv_chatenable @ {green}1{default}. 聊天功能開啟! Let's chat !");

		for ( int i = 1 ; i <= MaxClients ; ++i ) 
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && BaseComm_IsClientGagged(i))
			{
				ServerCommand("sm_ungag #%d", GetClientUserId(i));
				HxClientGagMuteBanEx(i);
			}
		}
	}
	else
	{
		CPrintToChatAll("[{olive}TS{default}] sv_chatenable @ {green}0{default}. 歲月靜好! Everyone be quient !");

		for ( int i = 1 ; i <= MaxClients ; ++i ) 
		{
			if (IsClientInGame(i) && !IsFakeClient(i) && HasAccess(i, g_sImmueAcclvl) == false)
			{
				ServerCommand("sm_gag #%d", GetClientUserId(i));
			}
		}
	}
}

public void ConVarChanged_ServerChatImmuneAccess(ConVar convar, const char[] oldValue, const char[] newValue) {
	GetCvars();

	if(g_bCvarServerChat == false)
	{
		for ( int i = 1 ; i <= MaxClients ; ++i ) 
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				if(BaseComm_IsClientGagged(i) && HasAccess(i, g_sImmueAcclvl) == true)
				{
					ServerCommand("sm_ungag #%d", GetClientUserId(i));
					HxClientGagMuteBanEx(i);
				}
				if(!BaseComm_IsClientGagged(i) && HasAccess(i, g_sImmueAcclvl) == false)
					ServerCommand("sm_gag #%d", GetClientUserId(i));
			}
		}
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

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(5.0, _tmrStart, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action _tmrStart(Handle timer) //回合開始 檢查所有人
{
	for ( int i = 1 ; i <= MaxClients ; ++i ) 
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			HxClientGagMuteBanEx(i);
		}
	}
}

void HxClientGagMuteBanEx(int &client)
{
	KeyValues hGM = new KeyValues("gagmuteban");

	if (hGM.ImportFromFile(sg_fileTxt))
	{
	#if HX_DELETE
		int iDelete = 1;
	#endif
		char sTeamID[24];
		GetClientAuthId(client, AuthId_Steam2, sTeamID, sizeof(sTeamID)-1);

		if (hGM.JumpToKey(sTeamID))
		{
			int iMute = hGM.GetNum("mute", 0);
			int iGag = hGM.GetNum("gag", 0);
			int iBan = hGM.GetNum("ban", 0);
			int iTime = GetTime();
			int iLeftMinute;
			int userid = GetClientUserId(client);

			if (iMute > iTime)
			{
				iLeftMinute = (iMute - iTime) /60;
				ServerCommand("sm_mute #%d", userid);
				CPrintToChat(client, "[{olive}TS{default}] 你還是被 {lightgreen}禁止MIC語音{default}，剩下 {green}%d{default} 分鐘解除", iLeftMinute );
				#if HX_DELETE
					iDelete = 0;
				#endif
			}
			else if (iMute != 0) //時間已到
			{
				ServerCommand("sm_unmute #%d", userid);
			}
			if (iGag > iTime)
			{
				iLeftMinute = (iGag - iTime) /60;
				ServerCommand("sm_gag #%d", userid);
				CPrintToChat(client, "[{olive}TS{default}] 你還是被 {lightgreen}禁用Chat文字{default}，剩下 {green}%d{default} 分鐘解除", iLeftMinute );
				#if HX_DELETE
					iDelete = 0;
				#endif
			}
			else if (iGag != 0) //時間已到
			{
				ServerCommand("sm_ungag #%d", userid);
			}
			if (iBan > iTime)
			{
				char sTime[24];
				FormatTime(sTime, sizeof(sTime)-1, "%Y-%m-%d %H:%M:%S", iBan);
				KickClient(client,"Banned (%s)", sTime);
				#if HX_DELETE
					iDelete = 0;
				#endif
			}

			#if HX_DELETE
				if (iDelete)
				{
					hGM.DeleteThis();
					hGM.Rewind();
					hGM.ExportToFile(sg_fileTxt);
				}
			#endif
		}
	}
	delete hGM;
}

public void OnClientPostAdminCheck(int client)
{
	if (!IsFakeClient(client)) {
		HxClientGagMuteBanEx(client);
		if (g_bCvarServerChat == false && BaseComm_IsClientGagged(client) == false) {
			if(HasAccess(client, g_sImmueAcclvl) == false)
				ServerCommand("sm_gag #%d", GetClientUserId(client));
			CPrintToChat(client, "[{olive}TS{default}] 伺服器聊天功能已關閉 (Chat off)");
		}

		if (g_bCvarServerVoice == false) {
			CPrintToChat(client, "[{olive}TS{default}] 伺服器語音功能已關閉 (Mic off)");
		}
	}
}

int HxClientTimeBan(int &client, int iminute)
{
	if (IsClientInGame(client))
	{
		char sName[128];
		char sTeamID[24];

		KeyValues hGM = new KeyValues("gagmuteban");
		hGM.ImportFromFile(sg_fileTxt);

		GetClientName(client, sName, sizeof(sName)-12);
		GetClientAuthId(client, AuthId_Steam2, sTeamID, sizeof(sTeamID)-1);

		hGM.JumpToKey(sTeamID, true);

		int iTimeBan = GetTime() + (iminute * 60);
		hGM.SetString("Name", sName);
		hGM.SetNum("ban", iTimeBan);
		hGM.Rewind();
		hGM.ExportToFile(sg_fileTxt);
		delete hGM;
		return 1;
	}
	return 0;
}

public int MenuHandler_Ban(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char sInfo[8];
		bool found = menu.GetItem(param2, sInfo, sizeof(sInfo)-1);
		if (found && param1)
		{
			int client = StringToInt(sInfo);
			if (client > 0)
			{
				if (ig_minutes < 1)
				{
					ig_minutes = 1;
				}
				
				if (HxClientTimeBan(client, ig_minutes))
				{
					LogToFileEx(sg_log, "Ban: %N(Adm) -> %N -> %d minute(s)", param1, client, ig_minutes);
					CPrintToChatAll("[{olive}TS{default}] {olive}%N{default} 被管理員 封鎖SteamId，長達 {green}%d{default} 分鐘", client, ig_minutes);
					KickClient(client, "%d minute(s) ban.", ig_minutes);
				}
			}
		}
	}

	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_addban(int client)
{
	if (client)
	{
		if (IsClientInGame(client))
		{
			char sName[128];
			char sNumber[8];

			Menu hMenu = new Menu(MenuHandler_Ban);
			hMenu.SetTitle("Menu Ban SteamID (player)");

			for (int i=1; i <= MaxClients ; ++i)
			{
				if (IsClientInGame(i) && !IsFakeClient(i))
				{
					//if (client != i)
					//{
						GetClientName(i, sName, sizeof(sName)-12);
						Format(sNumber, sizeof(sNumber)-1, "%d", i);
						hMenu.AddItem(sNumber, sName);
					//}
				}
			}

			hMenu.ExitButton = false;
			hMenu.Display(client, 20);
		}
	}

	return Plugin_Handled;
}

public int AddMenuBan(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[8];
		bool found = menu.GetItem(param2, info, sizeof(info)-1);
		if (found && param1)
		{
			int iTime = StringToInt(info);
			if (iTime > 0)
			{
				ig_minutes = iTime;
				CMD_addban(param1);
			}
		}
	}
	else if ( action == MenuAction_Cancel )
	{
		if ( param2 == MenuCancel_ExitBack && hTopMenu )
			hTopMenu.Display( param1, TopMenuPosition_LastCategory );
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_addbanmenu(int client, int args)
{
	if (g_bCvarBanAllow == false)
	{
		ReplyToCommand(client, "[TS] exBan Menu is disabled now.");
		return Plugin_Handled;
	}

	if (args != 2 && args != 0)
	{
		ReplyToCommand(client, "[TS] sm_exban <name> <minutes> or sm_exban to open exBan menu");
	}

	if(args == 2)
	{
		char arg1[32], arg2[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		int target = FindTarget(client, arg1, true /*nobots*/, false /*immunity*/);
		if(target == -1) return Plugin_Handled;	

		GetCmdArg(2, arg2, sizeof(arg2));
		int minutes = StringToInt(arg2);
		if(minutes==0) minutes = 9999;

		if (HxClientTimeBan(target, minutes))
		{
			if(client > 0)
			{
				LogToFileEx(sg_log, "[TS] Ban: %N(Adm) exban %N for %d minute(s)", client, target, minutes);
				CPrintToChatAll("[{olive}TS{default}] {olive}%N{default} 被管理員 封鎖SteamId，長達 {green}%d{default} 分鐘", target, ig_minutes);
			}
			else
			{
				LogToFileEx(sg_log, "[TS] Ban: Server exban %N for %d minute(s)", target, minutes);
			}
			KickClient(target, "%d minute(s) ban.", minutes);
		}
	}
	else
	{
		if (client == 0)
		{
			PrintToServer("[TS] server please uses sm_exban <name> <minutes>");
			return Plugin_Handled;
		}

		Menu menu = new Menu(AddMenuBan);
		for(int i = 0; i < sizeof(sBan_Time); i++)
		{
			menu.AddItem(sBan_Time[i][0], sBan_Time[i][1]);
		}
		menu.SetTitle("Menu Ban SteamID (Time)", client);
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}

	return Plugin_Handled;
}

int HxClientTimeGag(int &client, int iminute)
{
	if (IsClientInGame(client))
	{
		char sName[128];
		char sTeamID[24];

		KeyValues hGM = new KeyValues("gagmuteban");
		hGM.ImportFromFile(sg_fileTxt);

		GetClientName(client, sName, sizeof(sName)-12);
		GetClientAuthId(client, AuthId_Steam2, sTeamID, sizeof(sTeamID)-1);

		hGM.JumpToKey(sTeamID, true);

		int iTimeGag = GetTime() + (iminute * 60);
		hGM.SetString("Name", sName);
		hGM.SetNum("gag", iTimeGag);
		hGM.Rewind();
		hGM.ExportToFile(sg_fileTxt);
		delete hGM;
		ServerCommand("sm_gag #%d", GetClientUserId(client));
		return 1;
	}
	return 0;
}

public int MenuHandler_Gage(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char sInfo[8];
		bool found = menu.GetItem(param2, sInfo, sizeof(sInfo)-1);
		if (found && param1)
		{
			int client = StringToInt(sInfo);
			if (client > 0)
			{
				if (ig_minutes < 1)
				{
					ig_minutes = 1;
				}
				
				if (HxClientTimeGag(client, ig_minutes))
				{
					LogToFileEx(sg_log, "Gag: %N(Adm) exgag %N for %d minute(s)", param1, client, ig_minutes);
					CPrintToChatAll("[{olive}TS{default}] {olive}%N{default} 被管理員 {lightgreen}禁用Chat文字{default}，長達 {green}%d{default} 分鐘", client, ig_minutes);
				}
			}
		}
	}

	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_addgag(int client)
{
	if (client)
	{
		if (IsClientInGame(client))
		{
			char sName[128];
			char sNumber[8];

			Menu hMenu = new Menu(MenuHandler_Gage);
			hMenu.SetTitle("Menu Block Chat (Player)");

			for (int i=1; i <= MaxClients ; ++i)
			{
				if (IsClientInGame(i) && !IsFakeClient(i))
				{
					//if (client != i)
					//{
						GetClientName(i, sName, sizeof(sName)-12);
						Format(sNumber, sizeof(sNumber)-1, "%d", i);
						hMenu.AddItem(sNumber, sName);
					//}
				}
			}

			hMenu.ExitButton = false;
			hMenu.Display(client, 20);
		}
	}

	return Plugin_Handled;
}

public int AddMenuGag(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[8];
		bool found = menu.GetItem(param2, info, sizeof(info)-1);
		if (found && param1)
		{
			int iTime = StringToInt(info);
			if (iTime > 0)
			{
				ig_minutes = iTime;
				CMD_addgag(param1);
			}
		}
	}
	else if ( action == MenuAction_Cancel )
	{
		if ( param2 == MenuCancel_ExitBack && hTopMenu )
			hTopMenu.Display( param1, TopMenuPosition_LastCategory );
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_addgagmenu(int client, int args)
{
	if (g_bCvarGagAllow == false)
	{
		ReplyToCommand(client, "[TS] exGag Menu is disabled now.");
		return Plugin_Handled;
	}

	if (args != 2 && args != 0)
	{
		ReplyToCommand(client, "[TS] sm_exgag <name> <minutes> or sm_exgag to open exGag menu");
	}

	if(args == 2)
	{
		char arg1[32], arg2[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		int target = FindTarget(client, arg1, true /*nobots*/, false /*immunity*/);
		if(target == -1) return Plugin_Handled;	

		GetCmdArg(2, arg2, sizeof(arg2));
		int minutes = StringToInt(arg2);
		if(minutes==0) minutes = 9999;

		if (HxClientTimeGag(target, minutes))
		{
			if(client > 0)
			{
				LogToFileEx(sg_log, "Gag: %N(Adm) exgag %N for %d minute(s)", client, target, minutes);
				CPrintToChatAll("[{olive}TS{default}] {olive}%N{default} 被管理員 {lightgreen}禁用Chat文字{default}，長達 {green}%d{default} 分鐘", target, minutes);
			}
			else
			{
				LogToFileEx(sg_log, "[TS] Gag: Server exgag %N for %d minute(s)", target, minutes);
			}
		}
	}
	else
	{
		if (client == 0)
		{
			PrintToServer("[TS] server please uses sm_exgag <name> <minutes>");
			return Plugin_Handled;
		}

		Menu menu = new Menu(AddMenuGag);
		for(int i = 0; i < sizeof(sBan_Time); i++)
		{
			menu.AddItem(sBan_Time[i][0], sBan_Time[i][1]);
		}
		menu.SetTitle("Menu Block Chat (Time)", client);
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}

	return Plugin_Handled;
}

int HxClientTimeMute(int &client, int iminute)
{
	if (IsClientInGame(client))
	{
		char sName[128];
		char sTeamID[24];

		KeyValues hGM = new KeyValues("gagmuteban");
		hGM.ImportFromFile(sg_fileTxt);

		GetClientName(client, sName, sizeof(sName)-12);
		GetClientAuthId(client, AuthId_Steam2, sTeamID, sizeof(sTeamID)-1);

		hGM.JumpToKey(sTeamID, true);

		int iTimeMute = GetTime() + (iminute * 60);
		hGM.SetString("Name", sName);
		hGM.SetNum("mute", iTimeMute);
		hGM.Rewind();
		hGM.ExportToFile(sg_fileTxt);
		delete hGM;

		ServerCommand("sm_mute #%d", GetClientUserId(client));
		return 1;
	}
	return 0;
}

public int MenuHandler_Mute(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char sInfo[8];
		bool found = menu.GetItem(param2, sInfo, sizeof(sInfo)-1);
		if (found && param1)
		{
			int client = StringToInt(sInfo);
			if (client > 0)
			{
				if (ig_minutes < 1)
				{
					ig_minutes = 1;
				}
				
				if (HxClientTimeMute(client, ig_minutes))
				{
					LogToFileEx(sg_log, "Mute: %N(Adm) exMute %N for %d minute(s).", param1, client, ig_minutes);
					CPrintToChatAll("[{olive}TS{default}] {olive}%N{default} 被管理員 {lightgreen}禁止MIC語音{default}，長達 {green}%d{default} 分鐘", client, ig_minutes);
				}
			}
		}
	}

	if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_addmute(int client)
{
	if (IsClientInGame(client))
	{
		char sName[128];
		char sNumber[8];

		Menu hMenu = new Menu(MenuHandler_Mute);
		hMenu.SetTitle("Menu Block Microphone (Player)");

		for (int i=1; i <= MaxClients ; ++i)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				//if (client != i)
				//{
					GetClientName(i, sName, sizeof(sName)-12);
					Format(sNumber, sizeof(sNumber)-1, "%d", i);
					hMenu.AddItem(sNumber, sName);
				//}
			}
		}

		hMenu.ExitButton = false;
		hMenu.Display(client, 20);
	}

	return Plugin_Handled;
}

public int AddMenuMute(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[8];
		bool found = menu.GetItem(param2, info, sizeof(info)-1);
		if (found && param1)
		{
			int iTime = StringToInt(info);
			if (iTime > 0)
			{
				ig_minutes = iTime;
				CMD_addmute(param1);
			}
		}
	}
	else if ( action == MenuAction_Cancel )
	{
		if ( param2 == MenuCancel_ExitBack && hTopMenu )
			hTopMenu.Display( param1, TopMenuPosition_LastCategory );
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CMD_addmutemenu(int client, int args)
{
	if (g_bCvarMuteAllow == false)
	{
		ReplyToCommand(client, "[TS] exMute Menu is disabled now.");
		return Plugin_Handled;
	}

	if (args != 2 && args != 0)
	{
		ReplyToCommand(client, "[TS] sm_exmute <name> <minutes> or sm_exmute to open exMute menu");
	}

	if(args == 2)
	{
		char arg1[32], arg2[32];
		GetCmdArg(1, arg1, sizeof(arg1));
		int target = FindTarget(client, arg1, true /*nobots*/, false /*immunity*/);
		if(target == -1) return Plugin_Handled;	

		GetCmdArg(2, arg2, sizeof(arg2));
		int minutes = StringToInt(arg2);
		if(minutes==0) minutes = 9999;

		if (HxClientTimeMute(target, minutes))
		{
			if(client > 0)
			{
				LogToFileEx(sg_log, "Mute: %N(Adm) exMute %N for %d minute(s).", client, target, minutes);
				CPrintToChatAll("[{olive}TS{default}] {olive}%N{default} 被管理員 {lightgreen}禁止MIC語音{default}，長達 {green}%d{default} 分鐘", target, minutes);
			}
			else
			{
				LogToFileEx(sg_log, "[TS] Mute: Server exmute %N for %d minute(s)", target, minutes);
			}
		}
	}
	else
	{
		if (client == 0)
		{
			PrintToServer("[TS] server please uses sm_exmute <name> <minutes>");
			return Plugin_Handled;
		}

		Menu menu = new Menu(AddMenuMute);
		for(int i = 0; i < sizeof(sBan_Time); i++)
		{
			menu.AddItem(sBan_Time[i][0], sBan_Time[i][1]);
		}
		menu.SetTitle("Menu Block Microphone (Time)", client);
		menu.ExitButton = true;
		menu.Display(client, MENU_TIME_FOREVER);
	}

	return Plugin_Handled;
}

int HxClientTimeBanSteam(char[] steam_id, int iminute)
{
	KeyValues hGM = new KeyValues("gagmuteban");
	hGM.ImportFromFile(sg_fileTxt);

	if (!hGM.JumpToKey(steam_id))
	{
		hGM.JumpToKey(steam_id, true);
	}

	int iTimeBan = GetTime() + (iminute * 60);
	hGM.SetNum("ban", iTimeBan);
	hGM.Rewind();
	hGM.ExportToFile(sg_fileTxt);
	delete hGM;
	return 0;
}

public Action CMD_bansteamid(int client, int args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_exbansteam <minutes> <STEAM_ID>");
		return Plugin_Handled;
	}
	
	char arg_string[256];
	char minute[50];
	char authid[50];

	GetCmdArgString(arg_string, sizeof(arg_string));

	int len, total_len;
	
	/* Get minute */
	if ((len = BreakString(arg_string, minute, sizeof(minute))) == -1)
	{
		ReplyToCommand(client, "Usage: sm_bansteam <minutes> <steamid>");
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
	bool idValid = false;
	if (!strncmp(authid, "STEAM_", 6) && authid[7] == ':')
		idValid = true;
	
	if (!idValid)
	{
		ReplyToCommand(client, "Invalid SteamID specified (Must be STEAM_ )");
		return Plugin_Handled;
	}
	
	int minutes = StringToInt(minute);
	
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
		CPrintToChat(client, "[{olive}TS{default}] 你已新增 {lightgreen}%s(SteamID){default} 於GagMuteBanEx.txt檔案中，封鎖長達 {green}%d{default} 分鐘.", authid, minutes);
	}
	else
		LogToFileEx(sg_log, "Server Console added steamid %s in GagMuteBanEx list, %d minute(s) ban.", client, authid, minutes);
	return Plugin_Handled;
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

//Admin Category Names In Main Menu.
public int Category_Handler( TopMenu hTop_Menu, TopMenuAction hAction, TopMenuObject topobj_id, int param, char[] buffer, int maxlength )
{
	if ( hAction == TopMenuAction_DisplayTitle )
		Format( buffer, maxlength, "Select an option");
	
	else if( hAction == TopMenuAction_DisplayOption)
		Format( buffer, maxlength, "Ban/Mute/Gag-Ex");
}

public void AdminMenu_BanEx( TopMenu hTop_Menu, TopMenuAction hAction, TopMenuObject object_id, int param, char[] buffer, int maxlength )
{
	if ( hAction == TopMenuAction_DisplayOption )
		Format( buffer, maxlength, "Ban Player - Ex" );
	
	else if ( hAction == TopMenuAction_SelectOption )
		CMD_addbanmenu( param , 0);
}

public void AdminMenu_MuteEx( TopMenu hTop_Menu, TopMenuAction hAction, TopMenuObject object_id, int param, char[] buffer, int maxlength )
{
	if ( hAction == TopMenuAction_DisplayOption )
		Format( buffer, maxlength, "Mute Player - Ex" );
	
	else if ( hAction == TopMenuAction_SelectOption )
		CMD_addmutemenu( param , 0);
}

public void AdminMenu_GagEx( TopMenu hTop_Menu, TopMenuAction hAction, TopMenuObject object_id, int param, char[] buffer, int maxlength )
{
	if ( hAction == TopMenuAction_DisplayOption )
		Format( buffer, maxlength, "Gag Player - Ex" );
	
	else if ( hAction == TopMenuAction_SelectOption )
		CMD_addgagmenu( param , 0);
}

public bool HasAccess(int client, char[] g_sAcclvl)
{
	// no permissions set
	if (strlen(g_sAcclvl) == 0)
		return true;

	else if (StrEqual(g_sAcclvl, "-1"))
		return false;

	// check permissions
	if ( GetUserFlagBits(client) & ReadFlagString(g_sAcclvl) )
	{
		return true;
	}

	return false;
}