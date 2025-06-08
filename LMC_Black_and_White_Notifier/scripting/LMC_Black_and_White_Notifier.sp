//Based off retsam code but i have done a complete rewrite with int ffunctions  and more features

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <multicolors>
#include <l4d_heartbeat>

native int LMC_GetClientOverlayModel(int iClient);

#define PLUGIN_VERSION "1.2h-2025/6/8"

ConVar hCvar_Enabled = null;
ConVar hCvar_GlowEnabled = null;
ConVar hCvar_GlowColour = null;
ConVar hCvar_GlowRange = null;
ConVar hCvar_GlowFlash = null;
ConVar hCvar_NoticeType = null;
ConVar hCvar_TeamNoticeType = null;
ConVar hCvar_HintRange = null;
ConVar hCvar_HintTime = null;
ConVar hCvar_HintColour = null;
ConVar hMaxReviveCount;

bool bEnabled = false;
bool bGlowEnabled = false;
int iGlowColour;
int iGlowRange = 1800;
int iGlowFlash = 30;
int iNoticeType = 2;
int iTeamNoticeType = 2;
int iHintRange = 600;
float fHintTime = 5.0;
char sHintColour[17];

//char sCharName[17];
bool bGlow[MAXPLAYERS+1] = {false, ...};

bool bLMC_Available = false;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if(GetEngineVersion() != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2");
		return APLRes_SilentFailure;
	}

	MarkNativeAsOptional("LMC_GetClientOverlayModel");
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	bLMC_Available = LibraryExists("LMCCore");

	/* For people using admin cheats and other stuff that changes survivor health */
	CreateTimer(1.0, CheckBlackAndWhiteGlows_Timer, _, TIMER_REPEAT);
}

public void OnLibraryAdded(const char[] sName)
{
	if(StrEqual(sName, "LMCCore"))
	bLMC_Available = true;
}

public void OnLibraryRemoved(const char[] sName)
{
	if(StrEqual(sName, "LMCCore"))
	bLMC_Available = false;
}

public Plugin myinfo =
{
	name = "LMC_Black_and_White_Notifier",
	author = "Lux",
	description = "Notify people when player is black and white Using LMC model if any",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2449184#post2449184"
}

#define AUTO_EXEC true
public void OnPluginStart()
{
	LoadTranslations("LMC_Black_and_White_Notifier.phrases");

	hMaxReviveCount = FindConVar("survivor_max_incapacitated_count");

	CreateConVar("lmc_bwnotice_version", PLUGIN_VERSION, "Version of black and white notification plugin", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	hCvar_Enabled = CreateConVar("lmc_blackandwhite", "1", "Enable black and white notification plugin?(1/0 = yes/no)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_GlowEnabled = CreateConVar("lmc_glow", "1", "Enable making black white players glow?(1/0 = yes/no)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_GlowColour = CreateConVar("lmc_glowcolour", "255 255 255", "Glow(255 255 255)", FCVAR_NOTIFY);
	hCvar_GlowRange = CreateConVar("lmc_glowrange", "800.0", "Glow range before you don't see the glow max distance", FCVAR_NOTIFY, true, 1.0);
	hCvar_GlowFlash = CreateConVar("lmc_glowflash", "20", "while black and white if below 20(Def) start pulsing (0 = disable)", FCVAR_NOTIFY, true, 0.0);
	hCvar_NoticeType = CreateConVar("lmc_noticetype", "3", "Type to use for notification. (0= off, 1=chat, 2=hint text, 3=director hint)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	hCvar_TeamNoticeType = CreateConVar("lmc_teamnoticetype", "0", "Method of notification. (0=survivors only, 1=infected only, 2=all players)", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	hCvar_HintRange = CreateConVar("lmc_hintrange", "600", "Director hint range On Black and white", FCVAR_NOTIFY, true, 1.0, true, 9999.0);
	hCvar_HintTime = CreateConVar("lmc_hinttime", "5.0", "Director hint Timeout (in seconds)", FCVAR_NOTIFY, true, 1.0, true, 20.0);
	hCvar_HintColour = CreateConVar("lmc_hintcolour", "255 0 0", "Director hint colour Layout(255 255 255)", FCVAR_NOTIFY);
	
	HookEvent("revive_success", eReviveSuccess);
	HookEvent("heal_success", eHealSuccess);
	HookEvent("player_death", ePlayerDeath);
	HookEvent("player_spawn", ePlayerSpawn);
	HookEvent("player_team", eTeamChange);
	HookEvent("pills_used", eItemUsedPill);
	HookEvent("adrenaline_used", eItemUsed);
	
	hCvar_Enabled.AddChangeHook(eConvarChanged);
	hCvar_GlowEnabled.AddChangeHook(eConvarChanged);
	hCvar_GlowColour.AddChangeHook(eConvarChanged);
	hCvar_GlowRange.AddChangeHook(eConvarChanged);
	hCvar_GlowFlash.AddChangeHook(eConvarChanged);
	hCvar_NoticeType.AddChangeHook(eConvarChanged);
	hCvar_TeamNoticeType.AddChangeHook(eConvarChanged);
	hCvar_HintRange.AddChangeHook(eConvarChanged);
	hCvar_HintTime.AddChangeHook(eConvarChanged);
	hCvar_HintColour.AddChangeHook(eConvarChanged);
	
	#if AUTO_EXEC
	AutoExecConfig(true, "LMC_Black_and_White_Notifier");
	#endif
	CvarsChanged();
	
}

public void OnMapStart()
{
	CvarsChanged();
}

void eConvarChanged(Handle hCvar, const char[] sOldVal, const char[] sNewVal)
{
	CvarsChanged();
}

void CvarsChanged()
{
	bEnabled = hCvar_Enabled.BoolValue;
	bGlowEnabled = hCvar_GlowEnabled.BoolValue;
	char sGlowColour[13];
	GetConVarString(hCvar_GlowColour, sGlowColour, sizeof(sGlowColour));
	iGlowColour = GetColor(sGlowColour);
	iGlowRange = hCvar_GlowRange.IntValue;
	iGlowFlash = hCvar_GlowFlash.IntValue;
	iNoticeType = hCvar_NoticeType.IntValue;
	iTeamNoticeType = hCvar_TeamNoticeType.IntValue;
	iHintRange = hCvar_HintRange.IntValue;
	fHintTime = hCvar_HintTime.FloatValue;
	GetConVarString(hCvar_HintColour, sHintColour, sizeof(sHintColour));
}

void eReviveSuccess(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled)
		return;
	
	// 如果最後一次倒地時使用give health, 此參數依然為true (必須使用Heartbeat_GetRevives 判定)
	if(!event.GetBool("lastlife"))
		return;

	RequestFrame(NextFrame_ReviveSuccess, event.GetInt("subject"));
}

void NextFrame_ReviveSuccess(int iClient)
{
	iClient = GetClientOfUserId(iClient);
	
	if(iClient < 1 || iClient > MaxClients)
		return;
	
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient))
		return;

	if(Heartbeat_GetRevives(iClient) < L4D_GetMaxReviveCount())
		return;
	
	int iEntity = -1;
	
	if(bGlowEnabled)
	{
		bGlow[iClient] = true;
		if(bLMC_Available)
		{
			iEntity = LMC_GetClientOverlayModel(iClient);
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_iGlowType", 3);
				SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", iGlowColour);
				SetEntProp(iEntity, Prop_Send, "m_nGlowRange", iGlowRange);
				
			}
			else
			{
				SetEntProp(iClient, Prop_Send, "m_iGlowType", 3);
				SetEntProp(iClient, Prop_Send, "m_glowColorOverride", iGlowColour);
				SetEntProp(iClient, Prop_Send, "m_nGlowRange", iGlowRange);
			}
		}
		else
		{
			SetEntProp(iClient, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iClient, Prop_Send, "m_glowColorOverride", iGlowColour);
			SetEntProp(iClient, Prop_Send, "m_nGlowRange", iGlowRange);
		}
	}
	
	//GetModelName(iClient, iEntity);
	
	// switch(iTeamNoticeType)
	// {
	// 	case 0:
	// 	{
	// 		for(int i = 1; i <= MaxClients;i++)
	// 		{
	// 			if(!IsClientInGame(i) || GetClientTeam(iClient) != 2 || IsFakeClient(i) || i == iClient)
	// 			continue;
				
	// 			if(iNoticeType == 1)
	// 			CPrintToChat(i, "\x04[BW] \x03%N\x04(\x03%s\x04) is Black&White", iClient, sCharName);
	// 			if(iNoticeType == 2)
	// 			PrintHintText(i, "[BW] %N(%s\x04) is Black&White", iClient, sCharName);
	// 			if(iNoticeType == 3)
	// 			DirectorHintRevive(iClient, i);
	// 		}
			
	// 	}
	// 	case 1:
	// 	{
	// 		for(int i = 1; i <= MaxClients;i++)
	// 		{
	// 			if(!IsClientInGame(i) || GetClientTeam(iClient) != 3 || IsFakeClient(i))
	// 			continue;
				
	// 			if(iNoticeType == 1)
	// 			CPrintToChat(i, "\x04[BW] \x03%N\x04(\x03%s\x04) is Black&White", iClient, sCharName);
	// 			if(iNoticeType == 2)
	// 			PrintHintText(i, "[BW] %N(%s\x04) is Black&White", iClient, sCharName);
	// 			if(iNoticeType == 3)
	// 			PrintHintText(i, "[BW] %N(%s\x04) is Black&White", iClient, sCharName);
	// 		}
	// 	}
	// 	case 2:
	// 	{
	// 		for(int i = 1; i <= MaxClients;i++)
	// 		{
	// 			if(!IsClientInGame(i) || IsFakeClient(i) || i == iClient)
	// 			continue;
				
	// 			if(iNoticeType == 1)
	// 			CPrintToChat(i, "\x04[BW] \x03%N\x04(\x03%s\x04) is Black&White", iClient, sCharName);
	// 			if(iNoticeType == 2)
	// 			PrintHintText(i, "[BW] %N(%s) is Black&White", iClient, sCharName);
	// 			if(GetClientTeam(i) !=2)
	// 			{
	// 				PrintHintText(i, "[BW] %N(%s) is Black&White", iClient, sCharName);
	// 				continue;
	// 			}
	// 			if(iNoticeType == 3)
	// 			DirectorHintRevive(iClient, i);
	// 		}
	// 	}
	// }
	switch(iTeamNoticeType)
	{
		case 0:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(iClient) != 2 || IsFakeClient(i))
				continue;
				
				if(iNoticeType == 1)
				CPrintToChat(i, "{green}[BW] %T", "BAW_1 (C)", i, iClient);
				if(iNoticeType == 2)
				PrintHintText(i, "[BW] %T", "BAW_1", i, iClient);

				if(i == iClient) continue;

				if(iNoticeType == 3)
					DirectorHintRevive(iClient, i);
			}
			
		}
		case 1:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(iClient) != 3 || IsFakeClient(i))
				continue;
				
				if(iNoticeType == 1)
				CPrintToChat(i, "{green}[BW] %T", "BAW_1 (C)", i, iClient);
				if(iNoticeType == 2)
				PrintHintText(i, "[BW] %T", "BAW_1", i, iClient);
				if(iNoticeType == 3)
				PrintHintText(i, "[BW] %T", "BAW_1", i, iClient);
			}
		}
		case 2:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || IsFakeClient(i))
				continue;
				
				if(iNoticeType == 1)
				CPrintToChat(i, "{green}[BW] %T", "BAW_1 (C)", i, iClient);
				if(iNoticeType == 2)
				PrintHintText(i, "[BW] %T", "BAW_1", i, iClient);
				if(GetClientTeam(i) !=2)
				{
					PrintHintText(i, "[BW] %T", "BAW_1", i, iClient);
					continue;
				}

				if(i == iClient) continue;

				if(iNoticeType == 3)
					DirectorHintRevive(iClient, i);
			}
		}
	}
}

void eHealSuccess(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled)
	return;
	
	int iClient;
	iClient = GetClientOfUserId(event.GetInt("subject"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient))
	return;
	
	if(!bGlow[iClient])
	return;
	
	int iEntity = -1;
	if(bGlowEnabled)
	{
		bGlow[iClient] = false;
		if(bLMC_Available)
		{
			iEntity = LMC_GetClientOverlayModel(iClient);
			if(iEntity > MaxClients)
			{
				ResetGlows(iEntity);
			}
			else
			{
				ResetGlows(iClient);
			}
		}
		else
		{
			ResetGlows(iClient);
		}
	}
	
	//GetModelName(iClient, iEntity);
	int iHealer;
	iHealer = GetClientOfUserId(event.GetInt("userid"));
	
	// switch(iTeamNoticeType)
	// {
	// 	case 0:
	// 	{
	// 		for(int i = 1; i <= MaxClients;i++)
	// 		{
	// 			if(!IsClientInGame(i) || GetClientTeam(iClient) != 2 || IsFakeClient(i) || i == iClient /*|| i == iHealer*/)
	// 			continue;
				
	// 			if(iNoticeType == 1)
	// 			if(iClient != iHealer)
	// 			CPrintToChat(i, "\x04[BW] \x03%N\x04(\x03%s\x04) is no longer Black&White (Thanks to \x04%N\x01)", iClient, sCharName, iHealer);
	// 			else
	// 			CPrintToChat(i, "\x04[BW] \x03%N\x04(\x03%s\x04) healed themselves", iClient, sCharName);
				
	// 			if(iNoticeType == 2)
	// 			if(iClient != iHealer)
	// 			PrintHintText(i, "[BW] %N(%s) is no longer Black&White (Thanks to %N)", iClient, sCharName, iHealer);
	// 			else
	// 			PrintHintText(i, "[BW] %N(%s) healed themselves", iClient, sCharName);
				
	// 			if(iNoticeType == 3)
	// 			DirectorHintReviveHeal(iClient, iHealer, i);
	// 		}
	// 	}
	// 	case 1:
	// 	{
	// 		for(int i = 1; i <= MaxClients;i++)
	// 		{
	// 			if(!IsClientInGame(i) || GetClientTeam(iClient) != 3 || IsFakeClient(i) || i == iClient /*|| i == iHealer*/)
	// 			continue;
				
	// 			if(iNoticeType == 1)
	// 			if(iClient != iHealer)
	// 			CPrintToChat(i, "\x04[BW] \x03%N\x04(\x03%s\x04) is no longer Black&White (Thanks to \x04%N\x01)", iClient, sCharName, iHealer);
	// 			else
	// 			CPrintToChat(i, "\x04[BW] \x03%N\x04(\x03%s\x04) healed themselves", iClient, sCharName);
				
	// 			if(iNoticeType == 2)
	// 			if(iClient != iHealer)
	// 			PrintHintText(i, "[BW] %N(%s) is no longer Black&White (Thanks to %N)", iClient, iHealer);
	// 			else
	// 			PrintHintText(i, "[BW] %N(%s) healed themselves", iClient, sCharName);
				
	// 			if(iNoticeType == 3)
	// 			if(iClient != iHealer)
	// 			PrintHintText(i, "[BW] %N(%s) is no longer Black&White (Thanks to %N)", iClient, iHealer);
	// 			else
	// 			PrintHintText(i, "[BW] %N(%s) healed themselves", iClient, sCharName);
	// 		}
	// 	}
	// 	case 2:
	// 	{
	// 		for(int i = 1; i <= MaxClients;i++)
	// 		{
	// 			if(!IsClientInGame(i) || IsFakeClient(i) || i == iClient /*|| i == iHealer*/)
	// 			continue;
				
	// 			if(iNoticeType == 1)
	// 			if(iClient != iHealer)
	// 			CPrintToChat(i, "\x04[BW] \x03%N\x04(\x03%s\x04) is no longer Black&White (Thanks to \x04%N\x01)", iClient, sCharName, iHealer);
	// 			else
	// 			CPrintToChat(i, "\x04[BW] \x03%N\x04(\x03%s\x04) healed themselves", iClient, sCharName);
				
	// 			if(iNoticeType == 2)
	// 			if(iClient != iHealer)
	// 			PrintHintText(i, "[BW] %N(%s) is no longer Black&White (Thanks to %N)", iClient, sCharName, iHealer);
	// 			else
	// 			PrintHintText(i, "[BW] %N(%s) healed themselves", iClient, sCharName);
				
	// 			if(GetClientTeam(i) !=2)
	// 			if(iClient != iHealer)
	// 			{
	// 				PrintHintText(i, "[BW] %N(%s) is no longer Black&White (Thanks to %N)", iClient, sCharName, iHealer);
	// 				continue;
	// 			}
	// 			else
	// 			{
	// 				PrintHintText(i, "[BW] %N(%s) healed themselves", iClient, sCharName);
	// 				continue;
	// 			}
	// 			if(iNoticeType == 3)
	// 			DirectorHintReviveHeal(iClient, iHealer, i);
	// 		}
	// 	}
	// }
	switch(iTeamNoticeType)
	{
		case 0:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(iClient) != 2 || IsFakeClient(i) /*|| i == iClient || i == iHealer*/)
				continue;
				
				if(iNoticeType == 1)
				if(iClient != iHealer)
				CPrintToChat(i, "{green}[BW] %T", "BAW_2 (C)", i, iClient, iHealer);
				else
				CPrintToChat(i, "{green}[BW] %T", "BAW_3 (C)", i, iClient);
				
				if(iNoticeType == 2)
				if(iClient != iHealer)
				PrintHintText(i, "[BW] %T", "BAW_2", i, iClient, iHealer);
				else
				PrintHintText(i, "[BW] %T", "BAW_3", i, iClient);
				
				//if(i == iClient) continue;

				if(iNoticeType == 3)
					DirectorHintReviveHeal(iClient, iHealer, i);
			}
		}
		case 1:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(iClient) != 3 || IsFakeClient(i) /*|| i == iClient || i == iHealer*/)
				continue;
				
				if(iNoticeType == 1)
				if(iClient != iHealer)
				CPrintToChat(i, "{green}[BW] %T", "BAW_2 (C)", i, iClient, iHealer);
				else
				CPrintToChat(i, "{green}[BW] %T", "BAW_3 (C)", i, iClient);
				
				if(iNoticeType == 2)
				if(iClient != iHealer)
				PrintHintText(i, "[BW] %T", "BAW_2", i, iClient, iHealer);
				else
				PrintHintText(i, "[BW] %T", "BAW_3", i, iClient);
				
				if(iNoticeType == 3)
				if(iClient != iHealer)
				PrintHintText(i, "[BW] %T", "BAW_2", i, iClient, iHealer);
				else
				PrintHintText(i, "[BW] %T", "BAW_3", i, iClient);
			}
		}
		case 2:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || IsFakeClient(i) /*|| i == iClient || i == iHealer*/)
				continue;
				
				if(iNoticeType == 1)
				if(iClient != iHealer)
				CPrintToChat(i, "{green}[BW] %T", "BAW_2 (C)", i, iClient, iHealer);
				else
				CPrintToChat(i, "{green}[BW] %T", "BAW_3 (C)", i, iClient);
				
				if(iNoticeType == 2)
				if(iClient != iHealer)
				PrintHintText(i, "[BW] %T", "BAW_2", i, iClient, iHealer);
				else
				PrintHintText(i, "[BW] %T", "BAW_3", i, iClient);
				
				if(GetClientTeam(i) !=2)
				if(iClient != iHealer)
				{
					PrintHintText(i, "[BW] %T", "BAW_2", i, iClient, iHealer);
					continue;
				}
				else
				{
					PrintHintText(i, "[BW] %T", "BAW_3", i, iClient);
					continue;
				}

				//if(i == iClient) continue;

				if(iNoticeType == 3)
					DirectorHintReviveHeal(iClient, iHealer, i);
			}
		}
	}

}

void ePlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled)
	return;
	
	int iClient;
	iClient = GetClientOfUserId(event.GetInt("userid"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2)
	return;
	
	if(!bGlow[iClient])
	return;
	
	bGlow[iClient] = false;
	
	if(bLMC_Available)
	{
		int iEntity;
		iEntity = LMC_GetClientOverlayModel(iClient);
		if(iEntity > MaxClients)
		{
			ResetGlows(iEntity);
		}
		else
		{
			ResetGlows(iClient);
		}
	}
	else
	{
		ResetGlows(iClient);
	}
}

void ePlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled || !bGlowEnabled)
		return;
	
	CreateTimer(0.1, Timer_ePlayerSpawn, event.GetInt("userid"), TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_ePlayerSpawn(Handle timer, int userid)
{
	int iClient = GetClientOfUserId(userid);

	if(iClient < 1 || iClient > MaxClients)
		return Plugin_Continue;
	
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2 || !IsPlayerAlive(iClient))
		return Plugin_Continue;

	//PrintToChatAll("%d %d", GetEntProp(iClient, Prop_Send, "m_currentReviveCount"), L4D_GetMaxReviveCount());
		
	if(GetEntProp(iClient, Prop_Send, "m_currentReviveCount") < L4D_GetMaxReviveCount())
	{
		if(bLMC_Available)
		{
			int iEntity;
			iEntity = LMC_GetClientOverlayModel(iClient);
			if(iEntity > MaxClients)
			{
				ResetGlows(iEntity);
			}
			else
			{
				ResetGlows(iClient);
			}
		}
		else
		{
			ResetGlows(iClient);
		}
		bGlow[iClient] = false;
		return Plugin_Continue;
	}
	
	bGlow[iClient] = true;
	if(bLMC_Available)
	{
		int iEntity;
		iEntity = LMC_GetClientOverlayModel(iClient);
		if(iEntity > MaxClients)
		{
			SetEntProp(iEntity, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", iGlowColour);
			SetEntProp(iEntity, Prop_Send, "m_nGlowRange", iGlowRange);
			
		}
		else
		{
			SetEntProp(iClient, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iClient, Prop_Send, "m_glowColorOverride", iGlowColour);
			SetEntProp(iClient, Prop_Send, "m_nGlowRange", iGlowRange);
		}
	}
	else
	{
		SetEntProp(iClient, Prop_Send, "m_iGlowType", 3);
		SetEntProp(iClient, Prop_Send, "m_glowColorOverride", iGlowColour);
		SetEntProp(iClient, Prop_Send, "m_nGlowRange", iGlowRange);
	}

	return Plugin_Continue;
}

void eTeamChange(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled)
		return;
	
	int iClient;
	iClient = GetClientOfUserId(event.GetInt("userid"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2 || !IsPlayerAlive(iClient))
	return;
	
	if(bLMC_Available)
	{
		int iEntity;
		iEntity = LMC_GetClientOverlayModel(iClient);
		if(iEntity > MaxClients)
		{
			SetEntProp(iEntity, Prop_Send, "m_iGlowType", 0);
			SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(iEntity, Prop_Send, "m_nGlowRange", 0);
			SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0, 1);
		}
		else
		{
			SetEntProp(iClient, Prop_Send, "m_iGlowType", 0);
			SetEntProp(iClient, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(iClient, Prop_Send, "m_nGlowRange", 0);
			SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
		}
	}
	else
	{
		SetEntProp(iClient, Prop_Send, "m_iGlowType", 0);
		SetEntProp(iClient, Prop_Send, "m_glowColorOverride", 0);
		SetEntProp(iClient, Prop_Send, "m_nGlowRange", 0);
		SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
	}
	
}


public void LMC_OnClientModelApplied(int iClient, int iEntity, const char sModel[PLATFORM_MAX_PATH], int bBaseReattach)
{
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2)
	return;
	
	if(!bGlow[iClient])
	return;
	
	SetEntProp(iEntity, Prop_Send, "m_iGlowType", GetEntProp(iClient, Prop_Send, "m_iGlowType"));
	SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", GetEntProp(iClient, Prop_Send, "m_glowColorOverride"));
	SetEntProp(iEntity, Prop_Send, "m_nGlowRange", GetEntProp(iClient, Prop_Send, "m_glowColorOverride"));
	SetEntProp(iEntity, Prop_Send, "m_bFlashing", GetEntProp(iClient, Prop_Send, "m_bFlashing", 1), 1);
	
	SetEntProp(iClient, Prop_Send, "m_iGlowType", 0);
	SetEntProp(iClient, Prop_Send, "m_glowColorOverride", 0);
	SetEntProp(iClient, Prop_Send, "m_nGlowRange", 0);
	SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
}

public void LMC_OnClientModelDestroyed(int iClient, int iEntity)
{
	if(!IsClientInGame(iClient) || !IsPlayerAlive(iClient) || GetClientTeam(iClient) != 2)
	return;
	
	if(!IsValidEntity(iEntity))
	return;
	
	if(!bGlow[iClient])
	return;
	
	SetEntProp(iClient, Prop_Send, "m_iGlowType", GetEntProp(iEntity, Prop_Send, "m_iGlowType"));
	SetEntProp(iClient, Prop_Send, "m_glowColorOverride", GetEntProp(iEntity, Prop_Send, "m_glowColorOverride"));
	SetEntProp(iClient, Prop_Send, "m_nGlowRange", GetEntProp(iEntity, Prop_Send, "m_glowColorOverride"));
	SetEntProp(iClient, Prop_Send, "m_bFlashing", GetEntProp(iEntity, Prop_Send, "m_bFlashing", 1), 1);
}

/*
int GetModelName(int iClient, int iEntity)
{
	char sModel[64];
	if(!IsValidEntity(iEntity))
	{
		GetEntPropString(iClient, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		
		if(StrContains(sModel, "teenangst", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Zoey");
		else if(StrContains(sModel, "biker", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Francis");
		else if(StrContains(sModel, "manager", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Louis");
		else if(StrContains(sModel, "namvet", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Bill");
		else if(StrContains(sModel, "producer", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Rochelle");
		else if(StrContains(sModel, "mechanic", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Ellis");
		else if(StrContains(sModel, "coach", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Coach");
		else if(StrContains(sModel, "gambler", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Nick");
		else if(StrContains(sModel, "adawong", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "AdaWong");
		else
		strcopy(sCharName, sizeof(sCharName), "Unknown");
	}
	else if(IsValidEntity(iEntity))
	{
		GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		
		if(StrContains(sModel, "Bride", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Witch Bride");
		else if(StrContains(sModel, "Witch", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Witch");
		else if(StrContains(sModel, "hulk", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Tank");
		else if(StrContains(sModel, "boomer", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Boomer");
		else if(StrContains(sModel, "boomette", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Female Boomer");
		else if(StrContains(sModel, "hunter", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Hunter");
		else if(StrContains(sModel, "smoker", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Smoker");
		else if(StrContains(sModel, "teenangst", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Zoey");
		else if(StrContains(sModel, "biker", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Francis");
		else if(StrContains(sModel, "manager", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Louis");
		else if(StrContains(sModel, "namvet", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Bill");
		else if(StrContains(sModel, "producer", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Rochelle");
		else if(StrContains(sModel, "mechanic", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Ellis");
		else if(StrContains(sModel, "coach", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Coach");
		else if(StrContains(sModel, "gambler", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Nick");
		else if(StrContains(sModel, "adawong", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "AdaWong");
		else if(StrContains(sModel, "rescue", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Chopper Pilot");
		else if(StrContains(sModel, "common", false) > 0)
		strcopy(sCharName, sizeof(sCharName), "Infected");
		else
		strcopy(sCharName, sizeof(sCharName), "Unknown");
	}
}
*/

void DirectorHintRevive(int iClient, int i)
{
	int iEntity = CreateEntityByName("env_instructor_hint");
	if(iEntity == -1)
	return;
	
	char sValues[128];
	FormatEx(sValues, sizeof(sValues), "hint%d", iClient);
	DispatchKeyValue(iClient, "targetname", sValues);
	DispatchKeyValue(iEntity, "hint_target", sValues);
	
	FormatEx(sValues, sizeof(sValues), "%i", iHintRange);
	DispatchKeyValue(iEntity, "hint_range", sValues);
	DispatchKeyValue(iEntity, "hint_icon_onscreen", "icon_alert");
	
	FormatEx(sValues, sizeof(sValues), "%f", fHintTime);
	DispatchKeyValue(iEntity, "hint_timeout", sValues);
	
	//FormatEx(sValues, sizeof(sValues), "%N(%s) is Black&White", iClient, sCharName);
	FormatEx(sValues, sizeof(sValues), "%T", "BAW_1", i, iClient);
	DispatchKeyValue(iEntity, "hint_caption", sValues);
	DispatchKeyValue(iEntity, "hint_color", sHintColour);
	DispatchSpawn(iEntity);
	AcceptEntityInput(iEntity, "ShowHint", i);
	
	FormatEx(sValues, sizeof(sValues), "OnUser1 !self:Kill::%f:1", fHintTime);
	SetVariantString(sValues);
	AcceptEntityInput(iEntity, "AddOutput");
	AcceptEntityInput(iEntity, "FireUser1");
}

// void DirectorHintReviveHeal(iClient, iHealer, i)
// {
// 	int iEntity;
// 	iEntity = CreateEntityByName("env_instructor_hint");
// 	if(iEntity == -1)
// 	return;
	
// 	char sValues[128];
// 	FormatEx(sValues, sizeof(sValues), "hint%d", i);
// 	DispatchKeyValue(i, "targetname", sValues);
// 	DispatchKeyValue(iEntity, "hint_target", sValues);
	
// 	DispatchKeyValue(iEntity, "hint_range", "0.1");
// 	DispatchKeyValue(iEntity, "hint_icon_onscreen", "icon_info");
	
// 	FormatEx(sValues, sizeof(sValues), "%f", fHintTime);
// 	DispatchKeyValue(iEntity, "hint_timeout", sValues);
	
// 	if(iClient == iHealer)
// 	FormatEx(sValues, sizeof(sValues), "%N(%s) healed themselves", iClient, sCharName);
// 	else
// 	FormatEx(sValues, sizeof(sValues), "%N(%s) is no longer Black&White (Thanks to %N)", iClient, sCharName, iHealer);
	
// 	DispatchKeyValue(iEntity, "hint_caption", sValues);
// 	DispatchKeyValue(iEntity, "hint_color", sHintColour);
// 	DispatchSpawn(iEntity);
// 	AcceptEntityInput(iEntity, "ShowHint", i);
	
// 	FormatEx(sValues, sizeof(sValues), "OnUser1 !self:Kill::%f:1", fHintTime);
// 	SetVariantString(sValues);
// 	AcceptEntityInput(iEntity, "AddOutput");
// 	AcceptEntityInput(iEntity, "FireUser1");
// }
void DirectorHintReviveHeal(int iClient, int iHealer, int i)
{
	int iEntity = CreateEntityByName("env_instructor_hint");
	if(iEntity == -1)
	return;
	
	char sValues[128];
	FormatEx(sValues, sizeof(sValues), "hint%d", i);
	DispatchKeyValue(i, "targetname", sValues);
	DispatchKeyValue(iEntity, "hint_target", sValues);
	
	DispatchKeyValue(iEntity, "hint_range", "0.1");
	DispatchKeyValue(iEntity, "hint_icon_onscreen", "icon_info");
	
	FormatEx(sValues, sizeof(sValues), "%f", fHintTime);
	DispatchKeyValue(iEntity, "hint_timeout", sValues);
	
	if(iClient == iHealer)
	FormatEx(sValues, sizeof(sValues), "%T", "BAW_3", i, iClient);
	else
	FormatEx(sValues, sizeof(sValues), "%T", "BAW_2", i, iClient, iHealer);
	
	DispatchKeyValue(iEntity, "hint_caption", sValues);
	DispatchKeyValue(iEntity, "hint_color", sHintColour);
	DispatchSpawn(iEntity);
	AcceptEntityInput(iEntity, "ShowHint", i);
	
	FormatEx(sValues, sizeof(sValues), "OnUser1 !self:Kill::%f:1", fHintTime);
	SetVariantString(sValues);
	AcceptEntityInput(iEntity, "AddOutput");
	AcceptEntityInput(iEntity, "FireUser1");
}

//silvers colour converter
int GetColor(char sTemp[13])
{
	char sColors[3][4];
	ExplodeString(sTemp, " ", sColors, 3, 4);
	
	int color;
	color = StringToInt(sColors[0]);
	color += 256 * StringToInt(sColors[1]);
	color += 65536 * StringToInt(sColors[2]);
	return color;
}

public void OnClientPutInServer(int iClient)
{
	SDKHook(iClient, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
}

void OnTakeDamagePost(int victim, int attacker, int inflictor, float damage, int damagetype)
{
	if(!bEnabled)
		return;
	
	if(victim < 1 || victim > MaxClients)
	return;
	
	if(!IsClientInGame(victim) || GetClientTeam(victim) != 2)
	return;
	
	if(!bGlow[victim])
	return;
	
	int iEntity = -1;
	if(bLMC_Available)
	iEntity = LMC_GetClientOverlayModel(victim);
	
	
	if(L4D_GetPlayerTempHealth(victim) + GetEntProp(victim, Prop_Send, "m_iHealth") <= iGlowFlash)
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
			else
			{
				SetEntProp(victim, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
		}
		SetEntProp(victim, Prop_Send, "m_bFlashing", 1, 1);
	}
	else
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
			else
			{
				SetEntProp(victim, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
		}
		SetEntProp(victim, Prop_Send, "m_bFlashing", 0, 1);
	}
}

int L4D_GetMaxReviveCount()
{
	if (hMaxReviveCount == null)
	{
		return -1;
	}
	
	return hMaxReviveCount.IntValue;
}

void eItemUsedPill(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled)
		return;
	
	int iClient = GetClientOfUserId(event.GetInt("subject"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2 || !IsPlayerAlive(iClient))
	return;
	
	if(!bGlow[iClient])
	return;
	
	int iEntity = -1;
	if(bLMC_Available)
	iEntity = LMC_GetClientOverlayModel(iClient);
	
	if(L4D_GetPlayerTempHealth(iClient) + GetEntProp(iClient, Prop_Send, "m_iHealth") <= iGlowFlash)
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
			else
			{
				SetEntProp(iClient, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
		}
		SetEntProp(iClient, Prop_Send, "m_bFlashing", 1, 1);
		
	}
	else
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
			else
			{
				SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
		}
		SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
	}
}

void eItemUsed(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled)
		return;
	
	int iClient = GetClientOfUserId(event.GetInt("userid"));
	
	if(iClient < 1 || iClient > MaxClients)
	return;
	
	if(!IsClientInGame(iClient) || GetClientTeam(iClient) != 2 || !IsPlayerAlive(iClient))
	return;
	
	if(!bGlow[iClient])
	return;
	
	int iEntity = -1;
	if(bLMC_Available)
	iEntity = LMC_GetClientOverlayModel(iClient);
	
	if(L4D_GetPlayerTempHealth(iClient) + GetEntProp(iClient, Prop_Send, "m_iHealth") <= iGlowFlash)
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
			else
			{
				SetEntProp(iClient, Prop_Send, "m_bFlashing", 1, 1);
				return;
			}
		}
		SetEntProp(iClient, Prop_Send, "m_bFlashing", 1, 1);
		
	}
	else
	{
		if(bLMC_Available)
		{
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
			else
			{
				SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
				return;
			}
		}
		SetEntProp(iClient, Prop_Send, "m_bFlashing", 0, 1);
	}
}

Action CheckBlackAndWhiteGlows_Timer(Handle timer)
{
	if(!bGlowEnabled) return Plugin_Continue;

	int iEntity = -1;
	bool lastLife;
	for(int client = 1; client <= MaxClients; client++)
	{
		if(!IsClientInGame(client)) continue;
		if(GetClientTeam(client) != 2) continue;

		lastLife = (L4D_GetPlayerReviveCount(client) >= L4D_GetMaxReviveCount() && L4D_GetMaxReviveCount() > 0);

		if(bGlow[client] && lastLife == false)
		{
			bGlow[client] = false;
			if(bLMC_Available)
			{
				iEntity = LMC_GetClientOverlayModel(client);
				if(iEntity > MaxClients)
				{
					ResetGlows(iEntity);
				}
				else
				{
					ResetGlows(client);
				}
			}
			else
			{
				ResetGlows(client);
			}
		}
	}

	return Plugin_Continue;
}

void ResetGlows(int iEntity)
{
	SetEntProp(iEntity, Prop_Send, "m_iGlowType", 0);
	SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", 0);
	SetEntProp(iEntity, Prop_Send, "m_nGlowRange", 0);
	SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0, 1);
}

