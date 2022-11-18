#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#define PLUGIN_VERSION "1.7"

#define ZOEY 0
#define LOUIS 1
#define FRANCIS 2
#define BILL 3
#define ROCHELLE 4
#define COACH 5
#define ELLIS 6
#define NICK 7


public Plugin myinfo =
{
	name = "L4D Black and White Notifier",
	author = "DarkNoghri, HarryPotter",
	description = "Notify people when player is black and white.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
};

ConVar h_cvarNoticeType, h_cvarPrintType, h_cvarGlowEnable, h_cvarColor, h_cvarRange;
int bandw_notice, bandw_type, bandw_glow, g_iCvarColor,  g_iCvarRange;

Handle BWCheckTimer[MAXPLAYERS+1];

bool g_bL4D2Version;
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

	return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvent("revive_success", EventReviveSuccess);
	HookEvent("heal_success", EventHealSuccess);
	HookEvent("player_bot_replace", OnBotSwap);
	HookEvent("bot_player_replace", OnBotSwap);
	HookEvent("round_end",	Event_RoundStart);

	h_cvarNoticeType = CreateConVar("l4d_bandw_notice", "1", "0=turns notifications off, 1=notifies survivors, 2=notifies all, 3=notifies infected.", FCVAR_NOTIFY, true, 0.0, true, 3.0);
	h_cvarPrintType = CreateConVar("l4d_bandw_type", "1", "0=prints to chat, 1=displays hint box.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	if(g_bL4D2Version)
	{
		h_cvarGlowEnable = CreateConVar("l4d_bandw_glow", "0", "(L4D2 only) 0=turns black&white glow off, 1=turns glow on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
		h_cvarColor = CreateConVar("thirdstrike_glow_color", "255 255 255", "color of black&white glow, split up with ");
		h_cvarRange = CreateConVar("thirdstrike_glow_range", "1600", "max black&white glow range ", _, true, 1.0);
	}
	AutoExecConfig(true, "l4d_blackandwhite");
	
	GetCvars();
	
	h_cvarNoticeType.AddChangeHook(ChangeVars);
	h_cvarPrintType.AddChangeHook(ChangeVars);
	if(g_bL4D2Version)
	{
		h_cvarGlowEnable.AddChangeHook(ChangeVars);
		h_cvarColor.AddChangeHook(ChangeVars);
		h_cvarRange.AddChangeHook(ChangeVars);
	}

}

public void ChangeVars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	bandw_notice = h_cvarNoticeType.IntValue;
	bandw_type = h_cvarPrintType.IntValue;
	if(g_bL4D2Version)
	{
		bandw_glow = h_cvarGlowEnable.IntValue;
		char g_sCvarCols[12];
		h_cvarColor.GetString(g_sCvarCols, sizeof(g_sCvarCols));

		char sColors[3][4];
		g_iCvarColor = ExplodeString(g_sCvarCols, " ", sColors, sizeof(sColors), sizeof(sColors[]));
		if( g_iCvarColor == 3 )
		{
			g_iCvarColor = StringToInt(sColors[0]);
			g_iCvarColor += 256 * StringToInt(sColors[1]);
			g_iCvarColor += 65536 * StringToInt(sColors[2]);
		}
		else
		{
			g_iCvarColor = 0;
		}

		g_iCvarRange = h_cvarRange.IntValue;
	}
}

public void OnMapEnd()
{
	ResetTimer();
}

public void OnClientDisconnect(int client)
{
	if(!IsClientInGame(client)) return;

	delete BWCheckTimer[client];
}

public void EventReviveSuccess(Event event, const char[] name, bool dontBroadcast) 
{
	int target = GetClientOfUserId(event.GetInt("subject"));
	if(target == 0 || !IsClientInGame(target)) return;

	if(event.GetBool("lastlife"))
	{
		char targetModel[128]; 
		char charName[32];
		GetClientModel(target, targetModel, sizeof(targetModel));
		//fill string with character names
		if(StrContains(targetModel, "teenangst", false) > 0) 
		{
			strcopy(charName, sizeof(charName), "Zoey");
		}
		else if(StrContains(targetModel, "biker", false) > 0)
		{
			strcopy(charName, sizeof(charName), "Francis");
		}
		else if(StrContains(targetModel, "manager", false) > 0)
		{
			strcopy(charName, sizeof(charName), "Louis");
		}
		else if(StrContains(targetModel, "namvet", false) > 0)
		{
			strcopy(charName, sizeof(charName), "Bill");
		}
		else if(StrContains(targetModel, "producer", false) > 0)
		{
			strcopy(charName, sizeof(charName), "Rochelle");
		}
		else if(StrContains(targetModel, "mechanic", false) > 0)
		{
			strcopy(charName, sizeof(charName), "Ellis");
		}
		else if(StrContains(targetModel, "coach", false) > 0)
		{
			strcopy(charName, sizeof(charName), "Coach");
		}
		else if(StrContains(targetModel, "gambler", false) > 0)
		{
			strcopy(charName, sizeof(charName), "Nick");
		}
		else{
			strcopy(charName, sizeof(charName), "Unknown");
		}

		if(g_bL4D2Version && bandw_glow)
		{
			SetEntProp(target, Prop_Send, "m_iGlowType", 3); 				
			SetEntProp(target, Prop_Send, "m_glowColorOverride", g_iCvarColor);	
			SetEntProp(target, Prop_Send, "m_nGlowRange", g_iCvarRange);

			delete BWCheckTimer[target];
			BWCheckTimer[target] = CreateTimer(0.4, Timer_CheckThirdstrike, target, TIMER_REPEAT);
		}
		
		//turned off
		if(bandw_notice == 0) return;
		
		//print to all
		else if(bandw_notice == 2) 
		{
			if(IsFakeClient(target))
			{
				if(bandw_type == 1) PrintHintTextToAll("%N 黑白了.", target);
				else PrintToChatAll("%N 黑白了.", target);
			}
			{
				if(bandw_type == 1) PrintHintTextToAll("%N (%s) 黑白了.", target, charName);
				else PrintToChatAll("%N (%s) 黑白了.", target, charName);
			}
		}
		//print to infected
		else if(bandw_notice == 3)
		{
			for( int x = 1; x <= MaxClients; x++)
			{
				if(!IsClientInGame(x) || GetClientTeam(x) == GetClientTeam(target) || x == target || IsFakeClient(x))
					continue;

				if(IsFakeClient(target))
				{	
					if(bandw_type == 1) PrintHintText(x, "%N 黑白了.", target);
					else PrintToChat(x, "%N 黑白了.", target);
				}
				else
				{
					if(bandw_type == 1) PrintHintText(x, "%N (\x04%s\x01) 黑白了.", target, charName);
					else PrintToChat(x, "%N (\x04%s\x01) 黑白了.", target, charName);	
				}
			}
		}
		//print to survivors
		else
		{
			for( int x = 1; x <= MaxClients; x++)
			{
				if(!IsClientInGame(x) || GetClientTeam(x) != GetClientTeam(target) || x == target || IsFakeClient(x)) 
					continue;
				if(IsFakeClient(target))
				{		
					if(bandw_type == 1) PrintHintText(x, "%N 黑白了.", target);
					else PrintToChat(x, "%N 黑白了.", target);
				}
				else
				{
					if(bandw_type == 1) PrintHintText(x, "%N (\x04%s\x01) 黑白了.", target, charName);
					else PrintToChat(x, "%N (\x04%s\x01) 黑白了.", target, charName);					
				}
			}
		}	
	}
	
	return;
}

public void EventHealSuccess(Event event, const char[] name, bool dontBroadcast) 
{
	int target = GetClientOfUserId(event.GetInt("subject"));
	
	if(target == 0 || !IsClientInGame(target)) return;
	
	if(g_bL4D2Version && bandw_glow && BWCheckTimer[target] != null)
	{	
		SetEntProp(target, Prop_Send, "m_iGlowType", 0);
		SetEntProp(target, Prop_Send, "m_glowColorOverride", 0);
		delete BWCheckTimer[target];
	}
	
	return;
}

public void OnBotSwap(Event event, const char[] name, bool dontBroadcast) 
{
	int bot = GetClientOfUserId(event.GetInt("bot"));
	int player = GetClientOfUserId(event.GetInt("player"));
	if (IsClientIndex(bot) && IsClientIndex(player)) 
	{
		if (StrEqual(name, "player_bot_replace")) 
		{
			if(g_bL4D2Version && BWCheckTimer[player] != null) 
			{
				SetEntProp(bot, Prop_Send, "m_iGlowType", 3); 
				SetEntProp(bot, Prop_Send, "m_glowColorOverride", g_iCvarColor);
				SetEntProp(bot, Prop_Send, "m_nGlowRange", g_iCvarRange);
				delete BWCheckTimer[bot];
				BWCheckTimer[bot] = CreateTimer(0.4, Timer_CheckThirdstrike, bot, TIMER_REPEAT);

				SetEntProp(player, Prop_Send, "m_iGlowType", 0); 
				SetEntProp(player, Prop_Send, "m_glowColorOverride", 0);
				delete BWCheckTimer[player];
			}
		}
		else 
		{
			if(g_bL4D2Version && BWCheckTimer[bot] != null) 
			{
				SetEntProp(player, Prop_Send, "m_iGlowType", 3); 
				SetEntProp(player, Prop_Send, "m_glowColorOverride", g_iCvarColor);
				SetEntProp(player, Prop_Send, "m_nGlowRange", g_iCvarRange);
				delete BWCheckTimer[player];
				BWCheckTimer[player] = CreateTimer(0.4, Timer_CheckThirdstrike, player, TIMER_REPEAT);

				SetEntProp(bot, Prop_Send, "m_iGlowType", 0); 
				SetEntProp(bot, Prop_Send, "m_glowColorOverride", 0);
				delete BWCheckTimer[bot];
			}
		}
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
    ResetTimer();
}

bool IsClientIndex(int client)
{
	return (client > 0 && client <= MaxClients);
}

Action Timer_CheckThirdstrike(Handle timer, int client)
{
	if(IsClientInGame(client))
	{
		if(GetClientTeam(client) == 2 && IsPlayerAlive(client) && is_on_thirdstrike(client))
		{
			return Plugin_Continue;
		}
		
		SetEntProp(client, Prop_Send, "m_iGlowType", 0);
		SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);

		BWCheckTimer[client] = null;
		return Plugin_Stop;
	}

	BWCheckTimer[client] = null;
	return Plugin_Stop;
}

bool is_on_thirdstrike(int client)
{
	return GetEntProp(client, Prop_Send, "m_bIsOnThirdStrike") != 0;
}

void ResetTimer()
{
	for(int i = 1; i <= MaxClients; i++)
	{
		delete BWCheckTimer[i];
	}
}
