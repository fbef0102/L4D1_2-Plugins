//Based off retsam code but i have done a complete rewrite with int ffunctions  and more features

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <left4dhooks>
#include <multicolors>
#include <l4d_heartbeat>

#undef REQUIRE_PLUGIN
#tryinclude <LMCCore> //https://github.com/fbef0102/L4D1_2-Plugins/tree/master/Luxs-Model-Changer

#if !defined _LMCCore_included
	native int LMC_GetClientOverlayModel(int client);
#endif

#define PLUGIN_VERSION "1.3h-2026/4/4"

public Plugin myinfo =
{
	name = "LMC_Black_and_White_Notifier",
	author = "Lux, Harry",
	description = "Notify people when player is black and white (Support LMC model if any)",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2449184#post2449184"
}

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

ConVar hCvar_Enabled,
	hCvar_GlowEnabled,
	hCvar_GlowColour,
	hCvar_GlowRange,
	hCvar_GlowFlash,
	hCvar_NoticeTypeHeal, hCvar_NoticeWhoHeal, hCvar_HintRangeHeal, hCvar_HintTimeHeal, hCvar_HintColourHeal,
	hCvar_NoticeTypeBW, hCvar_NoticeWhoBW, hCvar_HintRangeBW, hCvar_HintTimeBW, hCvar_HintColourBW,
	hMaxReviveCount;

bool bEnabled, bGlowEnabled, g_bGlowFlash;
int g_iGlowColour, g_iGlowRange, 
	g_iNoticeTypeHeal, g_iNoticeWhoHeal, g_iHintRangeHeal,
	g_iNoticeTypeBW, g_iNoticeWhoBW, g_iHintRangeBW;
float g_fHintTimeHeal, g_fHintTimeBW;
char g_sHintColourHeal[17], g_sHintColourBW[17];

//char sCharName[17];
bool g_bGlow[MAXPLAYERS+1] = {false, ...};

bool bLMC_Available = false;

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

#define AUTO_EXEC true
public void OnPluginStart()
{
	LoadTranslations("LMC_Black_and_White_Notifier.phrases");

	hMaxReviveCount = FindConVar("survivor_max_incapacitated_count");

	CreateConVar("lmc_bwnotice_version", PLUGIN_VERSION, "Version of black and white notification plugin", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	hCvar_Enabled 				= CreateConVar("lmc_blackandwhite_enable", 				"1", 			"Enable plugin? (1/0 = yes/no)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_GlowEnabled 			= CreateConVar("lmc_blackandwhite_glow", 				"1", 			"Enable making black white players glow?(1/0 = yes/no)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_GlowColour 			= CreateConVar("lmc_blackandwhite_glowcolour", 			"255 255 255", 	"Black and white Glow color (255 255 255)", FCVAR_NOTIFY);
	hCvar_GlowRange 			= CreateConVar("lmc_blackandwhite_glowrange", 			"800.0", 		"Black and white Glow range", FCVAR_NOTIFY, true, 1.0);
	hCvar_GlowFlash 			= CreateConVar("lmc_blackandwhite_glowflash", 			"1", 			"If 1, add a flashing effect on Black and white Glow", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	hCvar_NoticeTypeHeal 		= CreateConVar("lmc_blackandwhite_announce_type_heal", 	"3", 			"(Heal B&W) How to display notification. (0=off, 1=chat, 2=hint text, 3=director hint in survivor team, hint text in infected team)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	hCvar_NoticeWhoHeal 		= CreateConVar("lmc_blackandwhite_announce_who_heal", 	"0", 			"(Heal B&W) Display notification to who? (0=survivors only, 1=infected only, 2=all players)", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	hCvar_HintRangeHeal 		= CreateConVar("lmc_blackandwhite_hintrange_heal", 		"700", 			"(Heal B&W) Director hint range", FCVAR_NOTIFY, true, 1.0, true, 9999.0);
	hCvar_HintTimeHeal 			= CreateConVar("lmc_blackandwhite_hinttime_heal", 		"7.0", 			"(Heal B&W) Director hint Timeout (in seconds)", FCVAR_NOTIFY, true, 1.0, true, 20.0);
	hCvar_HintColourHeal 		= CreateConVar("lmc_blackandwhite_hintcolour_heal", 	"0 255 0", 		"(Heal B&W) Director hint colour (255 255 255)", FCVAR_NOTIFY);
	hCvar_NoticeTypeBW 			= CreateConVar("lmc_blackandwhite_announce_type_bw", 	"3", 			"(Become B&W) How to display notification. (0=off, 1=chat, 2=hint text, 3=director hint in survivor team, hint text in infected team)", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	hCvar_NoticeWhoBW 			= CreateConVar("lmc_blackandwhite_announce_who_bw", 	"0", 			"(Become B&W) Display notification to who? (0=survivors only, 1=infected only, 2=all players)", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	hCvar_HintRangeBW 			= CreateConVar("lmc_blackandwhite_hintrange_bw", 		"1000", 		"(Become B&W) Director hint range", FCVAR_NOTIFY, true, 1.0, true, 9999.0);
	hCvar_HintTimeBW 			= CreateConVar("lmc_blackandwhite_hinttime_bw", 		"10.0", 		"(Become B&W) Director hint Timeout (in seconds)", FCVAR_NOTIFY, true, 1.0, true, 20.0);
	hCvar_HintColourBW 			= CreateConVar("lmc_blackandwhite_hintcolour_bw", 		"255 0 0", 		"(Become B&W) Director hint colour (255 255 255)", FCVAR_NOTIFY);
	
	HookEvent("revive_success", eReviveSuccess);
	HookEvent("heal_success", eHealSuccess);
	HookEvent("player_death", ePlayerDeath);
	HookEvent("player_spawn", ePlayerSpawn);
	HookEvent("player_team", eTeamChange);
	
	hCvar_Enabled.AddChangeHook(eConvarChanged);
	hCvar_GlowEnabled.AddChangeHook(eConvarChanged);
	hCvar_GlowColour.AddChangeHook(eConvarChanged);
	hCvar_GlowRange.AddChangeHook(eConvarChanged);
	hCvar_GlowFlash.AddChangeHook(eConvarChanged);
	hCvar_NoticeTypeHeal.AddChangeHook(eConvarChanged);
	hCvar_NoticeWhoHeal.AddChangeHook(eConvarChanged);
	hCvar_HintRangeHeal.AddChangeHook(eConvarChanged);
	hCvar_HintTimeHeal.AddChangeHook(eConvarChanged);
	hCvar_HintColourHeal.AddChangeHook(eConvarChanged);
	hCvar_NoticeTypeBW.AddChangeHook(eConvarChanged);
	hCvar_NoticeWhoBW.AddChangeHook(eConvarChanged);
	hCvar_HintRangeBW.AddChangeHook(eConvarChanged);
	hCvar_HintTimeBW.AddChangeHook(eConvarChanged);
	hCvar_HintColourBW.AddChangeHook(eConvarChanged);
	
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
	g_iGlowColour = GetColor(sGlowColour);
	g_iGlowRange = hCvar_GlowRange.IntValue;
	g_bGlowFlash = hCvar_GlowFlash.BoolValue;
	g_iNoticeTypeHeal = hCvar_NoticeTypeHeal.IntValue;
	g_iNoticeWhoHeal = hCvar_NoticeWhoHeal.IntValue;
	g_iHintRangeHeal = hCvar_HintRangeHeal.IntValue;
	g_fHintTimeHeal = hCvar_HintTimeHeal.FloatValue;
	GetConVarString(hCvar_HintColourHeal, g_sHintColourHeal, sizeof(g_sHintColourHeal));

	g_iNoticeTypeBW = hCvar_NoticeTypeBW.IntValue;
	g_iNoticeWhoBW = hCvar_NoticeWhoBW.IntValue;
	g_iHintRangeBW = hCvar_HintRangeBW.IntValue;
	g_fHintTimeBW = hCvar_HintTimeBW.FloatValue;
	GetConVarString(hCvar_HintColourBW, g_sHintColourBW, sizeof(g_sHintColourBW));
}

void eReviveSuccess(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled)
		return;
	
	// 如果最後一次倒地時使用give health, "lastlife"=true (必須等到下一偵使用Heartbeat_GetRevives 判定)
	// 黑白掛邊時被拉起來, "lastlife"=false
	if(event.GetBool("lastlife") || event.GetBool("ledge_hang"))
	{
		RequestFrame(NextFrame_ReviveSuccess, event.GetInt("subject"));

	}
}

void NextFrame_ReviveSuccess(int client)
{
	client = GetClientOfUserId(client);
	
	if(client < 1 || client > MaxClients)
		return;
	
	if(!IsClientInGame(client) || !IsPlayerAlive(client))
		return;

	if(Heartbeat_GetRevives(client) < L4D_GetMaxReviveCount())
		return;
	
	int iEntity = -1;
	
	if(bGlowEnabled)
	{
		g_bGlow[client] = true;
		if(bLMC_Available)
		{
			iEntity = LMC_GetClientOverlayModel(client);
			if(iEntity > MaxClients)
			{
				SetEntProp(iEntity, Prop_Send, "m_iGlowType", 3);
				SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", g_iGlowColour);
				SetEntProp(iEntity, Prop_Send, "m_nGlowRange", g_iGlowRange);
				if(g_bGlowFlash) SetEntProp(iEntity, Prop_Send, "m_bFlashing", 1);
				
			}
			else
			{
				SetEntProp(client, Prop_Send, "m_iGlowType", 3);
				SetEntProp(client, Prop_Send, "m_glowColorOverride", g_iGlowColour);
				SetEntProp(client, Prop_Send, "m_nGlowRange", g_iGlowRange);
				if(g_bGlowFlash) SetEntProp(client, Prop_Send, "m_bFlashing", 1);
			}
		}
		else
		{
			SetEntProp(client, Prop_Send, "m_iGlowType", 3);
			SetEntProp(client, Prop_Send, "m_glowColorOverride", g_iGlowColour);
			SetEntProp(client, Prop_Send, "m_nGlowRange", g_iGlowRange);
			if(g_bGlowFlash) SetEntProp(client, Prop_Send, "m_bFlashing", 1);
		}
	}
	
	switch(g_iNoticeWhoBW)
	{
		case 0:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(client) != 2 || IsFakeClient(i))
					continue;
				
				if(g_iNoticeTypeBW == 1)
					CPrintToChat(i, "%T", "BAW_1 (C)", i, client);
				if(g_iNoticeTypeBW == 2)
					PrintHintText(i, "%T", "BAW_1", i, client);

				if(i == client) continue;

				if(g_iNoticeTypeBW == 3)
					BW_DirectorHintToChat(client, i);
			}
			
		}
		case 1:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(client) != 3 || IsFakeClient(i))
					continue;
				
				if(g_iNoticeTypeBW == 1)
					CPrintToChat(i, "%T", "BAW_1 (C)", i, client);
				if(g_iNoticeTypeBW == 2)
					PrintHintText(i, "%T", "BAW_1", i, client);
				if(g_iNoticeTypeBW == 3)
					PrintHintText(i, "%T", "BAW_1", i, client);
			}
		}
		case 2:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || IsFakeClient(i))
					continue;
				
				if(g_iNoticeTypeBW == 1)
					CPrintToChat(i, "%T", "BAW_1 (C)", i, client);
				if(g_iNoticeTypeBW == 2)
					PrintHintText(i, "%T", "BAW_1", i, client);

				if(GetClientTeam(i) != 2)
				{
					PrintHintText(i, "%T", "BAW_1", i, client);
					continue;
				}

				if(i == client) continue;

				if(g_iNoticeTypeBW == 3)
					BW_DirectorHintToChat(client, i);
			}
		}
	}
}

void eHealSuccess(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled)
	return;
	
	int client;
	client = GetClientOfUserId(event.GetInt("subject"));
	
	if(client < 1 || client > MaxClients)
	return;
	
	if(!IsClientInGame(client) || !IsPlayerAlive(client))
	return;
	
	if(!g_bGlow[client])
	return;
	
	int iEntity = -1;
	if(bGlowEnabled)
	{
		g_bGlow[client] = false;
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
	
	//GetModelName(client, iEntity);
	int iHealer;
	iHealer = GetClientOfUserId(event.GetInt("userid"));

	switch(g_iNoticeWhoHeal)
	{
		case 0:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(client) != 2 || IsFakeClient(i) /*|| i == client || i == iHealer*/)
					continue;
				
				if(g_iNoticeTypeHeal == 1)
				{
					if(client != iHealer)
						CPrintToChat(i, "%T", "BAW_2 (C)", i, client, iHealer);
					else
						CPrintToChat(i, "%T", "BAW_3 (C)", i, client);
				}

				if(g_iNoticeTypeHeal == 2)
				{
					if(client != iHealer)
						PrintHintText(i, "%T", "BAW_2", i, client, iHealer);
					else
						PrintHintText(i, "%T", "BAW_3", i, client);
				}

				//if(i == client) continue;

				if(g_iNoticeTypeHeal == 3)
					Heal_DirectorHintToChat(client, iHealer, i);
			}
		}
		case 1:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || GetClientTeam(client) != 3 || IsFakeClient(i) /*|| i == client || i == iHealer*/)
					continue;
				
				if(g_iNoticeTypeHeal == 1)
				{
					if(client != iHealer)
						CPrintToChat(i, "%T", "BAW_2 (C)", i, client, iHealer);
					else
						CPrintToChat(i, "%T", "BAW_3 (C)", i, client);
				}

				if(g_iNoticeTypeHeal == 2)
				{
					if(client != iHealer)
						PrintHintText(i, "%T", "BAW_2", i, client, iHealer);
					else
						PrintHintText(i, "%T", "BAW_3", i, client);
				}

				if(g_iNoticeTypeHeal == 3)
				{
					if(client != iHealer)
						PrintHintText(i, "%T", "BAW_2", i, client, iHealer);
					else
						PrintHintText(i, "%T", "BAW_3", i, client);
				}
			}
		}
		case 2:
		{
			for(int i = 1; i <= MaxClients;i++)
			{
				if(!IsClientInGame(i) || IsFakeClient(i) /*|| i == client || i == iHealer*/)
					continue;
				
				if(g_iNoticeTypeHeal == 1)
				{
					if(client != iHealer)
						CPrintToChat(i, "%T", "BAW_2 (C)", i, client, iHealer);
					else
						CPrintToChat(i, "%T", "BAW_3 (C)", i, client);
				}

				if(g_iNoticeTypeHeal == 2)
				{
					if(client != iHealer)
						PrintHintText(i, "%T", "BAW_2", i, client, iHealer);
					else
						PrintHintText(i, "%T", "BAW_3", i, client);
				}
				
				if(GetClientTeam(i) !=2)
				{
					if(client != iHealer)
					{
						PrintHintText(i, "%T", "BAW_2", i, client, iHealer);
					}
					else
					{
						PrintHintText(i, "%T", "BAW_3", i, client);
					}

					continue;
				}

				//if(i == client) continue;

				if(g_iNoticeTypeHeal == 3)
					Heal_DirectorHintToChat(client, iHealer, i);
			}
		}
	}

}

void ePlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled)
	return;
	
	int client;
	client = GetClientOfUserId(event.GetInt("userid"));
	
	if(client < 1 || client > MaxClients)
	return;
	
	if(!IsClientInGame(client) || GetClientTeam(client) != 2)
	return;
	
	if(!g_bGlow[client])
	return;
	
	g_bGlow[client] = false;
	
	if(bLMC_Available)
	{
		int iEntity;
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

void ePlayerSpawn(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled || !bGlowEnabled)
		return;
	
	CreateTimer(0.1, Timer_ePlayerSpawn, event.GetInt("userid"), TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_ePlayerSpawn(Handle timer, int userid)
{
	int client = GetClientOfUserId(userid);

	if(client < 1 || client > MaxClients)
		return Plugin_Continue;
	
	if(!IsClientInGame(client) || GetClientTeam(client) != 2 || !IsPlayerAlive(client))
		return Plugin_Continue;

	//PrintToChatAll("%d %d", Heartbeat_GetRevives(client), L4D_GetMaxReviveCount());
		
	if(Heartbeat_GetRevives(client) < L4D_GetMaxReviveCount())
	{
		if(bLMC_Available)
		{
			int iEntity;
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
		g_bGlow[client] = false;
		return Plugin_Continue;
	}
	
	g_bGlow[client] = true;
	if(bLMC_Available)
	{
		int iEntity;
		iEntity = LMC_GetClientOverlayModel(client);
		if(iEntity > MaxClients)
		{
			SetEntProp(iEntity, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", g_iGlowColour);
			SetEntProp(iEntity, Prop_Send, "m_nGlowRange", g_iGlowRange);
			if(g_bGlowFlash) SetEntProp(iEntity, Prop_Send, "m_bFlashing", 1);
			
		}
		else
		{
			SetEntProp(client, Prop_Send, "m_iGlowType", 3);
			SetEntProp(client, Prop_Send, "m_glowColorOverride", g_iGlowColour);
			SetEntProp(client, Prop_Send, "m_nGlowRange", g_iGlowRange);
			if(g_bGlowFlash) SetEntProp(client, Prop_Send, "m_bFlashing", 1);
		}
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_iGlowType", 3);
		SetEntProp(client, Prop_Send, "m_glowColorOverride", g_iGlowColour);
		SetEntProp(client, Prop_Send, "m_nGlowRange", g_iGlowRange);
		if(g_bGlowFlash) SetEntProp(client, Prop_Send, "m_bFlashing", 1);
	}

	return Plugin_Continue;
}

void eTeamChange(Event event, const char[] name, bool dontBroadcast) 
{
	if(!bEnabled)
		return;
	
	int client;
	client = GetClientOfUserId(event.GetInt("userid"));
	
	if(client < 1 || client > MaxClients)
	return;
	
	if(!IsClientInGame(client) || GetClientTeam(client) != 2 || !IsPlayerAlive(client))
	return;
	
	if(bLMC_Available)
	{
		int iEntity;
		iEntity = LMC_GetClientOverlayModel(client);
		if(iEntity > MaxClients)
		{
			SetEntProp(iEntity, Prop_Send, "m_iGlowType", 0);
			SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(iEntity, Prop_Send, "m_nGlowRange", 0);
			if(g_bGlowFlash) SetEntProp(client, Prop_Send, "m_bFlashing", 1);
		}
		else
		{
			SetEntProp(client, Prop_Send, "m_iGlowType", 0);
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(client, Prop_Send, "m_nGlowRange", 0);
			if(g_bGlowFlash) SetEntProp(client, Prop_Send, "m_bFlashing", 1);
		}
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_iGlowType", 0);
		SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
		SetEntProp(client, Prop_Send, "m_nGlowRange", 0);
		if(g_bGlowFlash) SetEntProp(client, Prop_Send, "m_bFlashing", 1);
	}
	
}


public void LMC_OnClientModelApplied(int client, int iEntity, const char sModel[PLATFORM_MAX_PATH], bool bBaseReattach)
{
	if(!IsClientInGame(client) || GetClientTeam(client) != 2)
		return;
	
	if(!g_bGlow[client])
		return;
	
	SetEntProp(iEntity, Prop_Send, "m_iGlowType", GetEntProp(client, Prop_Send, "m_iGlowType"));
	SetEntProp(iEntity, Prop_Send, "m_glowColorOverride", GetEntProp(client, Prop_Send, "m_glowColorOverride"));
	SetEntProp(iEntity, Prop_Send, "m_nGlowRange", GetEntProp(client, Prop_Send, "m_glowColorOverride"));
	if(g_bGlowFlash) SetEntProp(iEntity, Prop_Send, "m_bFlashing", 1);
	else SetEntProp(iEntity, Prop_Send, "m_bFlashing", 0);
	
	SetEntProp(client, Prop_Send, "m_iGlowType", 0);
	SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
	SetEntProp(client, Prop_Send, "m_nGlowRange", 0);
	if(g_bGlowFlash) SetEntProp(client, Prop_Send, "m_bFlashing", 1);
	else SetEntProp(client, Prop_Send, "m_bFlashing", 0);
}

public void LMC_OnClientModelDestroyed(int client, int iEntity)
{
	if(!IsClientInGame(client) || !IsPlayerAlive(client) || GetClientTeam(client) != 2)
		return;
	
	if(!IsValidEntity(iEntity))
		return;
	
	if(!g_bGlow[client])
		return;
	
	SetEntProp(client, Prop_Send, "m_iGlowType", GetEntProp(iEntity, Prop_Send, "m_iGlowType"));
	SetEntProp(client, Prop_Send, "m_glowColorOverride", GetEntProp(iEntity, Prop_Send, "m_glowColorOverride"));
	SetEntProp(client, Prop_Send, "m_nGlowRange", GetEntProp(iEntity, Prop_Send, "m_glowColorOverride"));
	if(g_bGlowFlash) SetEntProp(client, Prop_Send, "m_bFlashing", 1);
	else SetEntProp(client, Prop_Send, "m_bFlashing", 0);
}

void BW_DirectorHintToChat(int client, int i)
{
	int iEntity = CreateEntityByName("env_instructor_hint");
	if(iEntity == -1)
		return;
	
	char sValues[128];
	FormatEx(sValues, sizeof(sValues), "hint%d", client);
	DispatchKeyValue(client, "targetname", sValues);
	DispatchKeyValue(iEntity, "hint_target", sValues);
	
	FormatEx(sValues, sizeof(sValues), "%i", g_iHintRangeBW);
	DispatchKeyValue(iEntity, "hint_range", sValues);
	DispatchKeyValue(iEntity, "hint_icon_onscreen", "icon_alert");
	DispatchKeyValue(iEntity, "hint_instance_type", "2"); //2=新的提示出現時結束上一個提示
	DispatchKeyValue(iEntity, "hint_forcecaption", "1"); //1=隔著牆依然提示
	
	FormatEx(sValues, sizeof(sValues), "%f", g_fHintTimeBW);
	DispatchKeyValue(iEntity, "hint_timeout", sValues);
	
	//FormatEx(sValues, sizeof(sValues), "%N(%s) is Black&White", client, sCharName);
	FormatEx(sValues, sizeof(sValues), "%T", "BAW_1", i, client);
	DispatchKeyValue(iEntity, "hint_caption", sValues);
	DispatchKeyValue(iEntity, "hint_color", g_sHintColourBW);
	DispatchSpawn(iEntity);
	AcceptEntityInput(iEntity, "ShowHint", i);
	
	FormatEx(sValues, sizeof(sValues), "OnUser1 !self:Kill::%f:1", g_fHintTimeBW);
	SetVariantString(sValues);
	AcceptEntityInput(iEntity, "AddOutput");
	AcceptEntityInput(iEntity, "FireUser1");
}

void Heal_DirectorHintToChat(int client, int iHealer, int i)
{
	int iEntity = CreateEntityByName("env_instructor_hint");
	if(iEntity == -1)
		return;
	
	char sValues[128];
	FormatEx(sValues, sizeof(sValues), "hint%d", i);
	DispatchKeyValue(client, "targetname", sValues);
	DispatchKeyValue(iEntity, "hint_target", sValues);
	
	FormatEx(sValues, sizeof(sValues), "%i", g_iHintRangeHeal);
	DispatchKeyValue(iEntity, "hint_range", sValues);
	DispatchKeyValue(iEntity, "hint_icon_onscreen", "icon_info");
	DispatchKeyValue(iEntity, "hint_instance_type", "2");
	DispatchKeyValue(iEntity, "hint_forcecaption", "1"); //1=隔著牆依然提示
	
	FormatEx(sValues, sizeof(sValues), "%f", g_fHintTimeHeal);
	DispatchKeyValue(iEntity, "hint_timeout", sValues);
	
	if(client == iHealer)
		FormatEx(sValues, sizeof(sValues), "%T", "BAW_3", i, client);
	else
		FormatEx(sValues, sizeof(sValues), "%T", "BAW_2", i, client, iHealer);
	
	DispatchKeyValue(iEntity, "hint_caption", sValues);
	DispatchKeyValue(iEntity, "hint_color", g_sHintColourHeal);
	DispatchSpawn(iEntity);
	AcceptEntityInput(iEntity, "ShowHint", i);
	
	FormatEx(sValues, sizeof(sValues), "OnUser1 !self:Kill::%f:1", g_fHintTimeHeal);
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

int L4D_GetMaxReviveCount()
{
	return hMaxReviveCount.IntValue;
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
		if(!IsPlayerAlive(client)) continue;

		lastLife = (Heartbeat_GetRevives(client) >= L4D_GetMaxReviveCount() && L4D_GetMaxReviveCount() > 0);

		if(g_bGlow[client] && (lastLife == false || L4D_IsPlayerIncapacitated(client)) )
		{
			g_bGlow[client] = false;
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

