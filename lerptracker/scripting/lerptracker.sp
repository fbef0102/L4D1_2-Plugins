#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <multicolors>

//#define clamp(%0, %1, %2) ( ((%0) < (%1)) ? (%1) : ( ((%0) > (%2)) ? (%2) : (%0) ) )
#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))
#define CVAR_FLAGS				FCVAR_NOTIFY

public Plugin myinfo = 
{
	name = "LerpTracker",
	author = "ProdigySim (archer edit) & HarryPotter",
	description = "Keep track of players' lerp settings",
	version = "1.1",
	url = "https://bitbucket.org/ProdigySim/misc-sourcemod-plugins"
};

/* Global Vars */
float g_fCurrentLerps[MAXPLAYERS+1];

/* My CVars */
ConVar hLogLerp;
ConVar hAnnounceLerp;
ConVar hFixLerpValue;
ConVar hMaxLerpValue;

/* Valve CVars */
ConVar hMinUpdateRate;
ConVar hMaxUpdateRate;
ConVar hMinInterpRatio;
ConVar hMaxInterpRatio;
//what even?
ConVar hPrintLerpStyle;

ConVar cVarMinLerp;
ConVar cVarMaxLerp;

// psychonic made me do it

#define ShouldFixLerp() (hFixLerpValue.BoolValue)

#define ShouldAnnounceLerpChanges() (hAnnounceLerp.BoolValue)

#define DefaultLerpStyle() (hPrintLerpStyle.BoolValue)

#define ShouldLogLerpChanges() (hLogLerp.BoolValue)

#define IsCurrentLerpValid(%0) (g_fCurrentLerps[(%0)] >= 0.0)

#define InvalidateCurrentLerp(%0) (g_fCurrentLerps[(%0)] = -1.0)

#define GetCurrentLerp(%0) (g_fCurrentLerps[(%0)])
#define SetCurrentLerp(%0,%1) (g_fCurrentLerps[(%0)] = (%1))
static bool blerpdetect[MAXPLAYERS + 1];
int ClientTeam[MAXPLAYERS + 1];
#define COLDDOWN_DELAY 6.0

public void OnPluginStart()
{
	hMinUpdateRate = FindConVar("sv_minupdaterate");
	hMaxUpdateRate = FindConVar("sv_maxupdaterate");
	hMinInterpRatio = FindConVar("sv_client_min_interp_ratio");
	hMaxInterpRatio= FindConVar("sv_client_max_interp_ratio");
	hLogLerp = CreateConVar("sm_log_lerp", "1", "Log changes to client lerp. 1=Log initial lerp and changes 2=Log changes only", CVAR_FLAGS);
	hAnnounceLerp = CreateConVar("sm_announce_lerp", "1", "Announce changes to client lerp. 1=Announce initial lerp and changes 2=Announce changes only", CVAR_FLAGS);
	hFixLerpValue = CreateConVar("sm_fixlerp", "1", "Fix Lerp values clamping incorrectly when interp_ratio 0 is allowed", CVAR_FLAGS);
	hMaxLerpValue = CreateConVar("sm_max_interp", "0.5", "Kick players whose settings breach this Hard upper-limit for player lerps.", CVAR_FLAGS);
	hPrintLerpStyle = CreateConVar("sm_lerpstyle", "1", "Display Style, 0 = default, 1 = team based", CVAR_FLAGS);
	cVarMinLerp = CreateConVar("sm_min_lerp", "0.000", "Minimum allowed lerp value", CVAR_FLAGS);
	cVarMaxLerp = CreateConVar("sm_max_lerp", "0.1", "Maximum allowed lerp value, 超過踢到旁觀", CVAR_FLAGS);
	
	RegConsoleCmd("sm_lerps", Lerps_Cmd, "List the Lerps of all players in game", CVAR_FLAGS);
	
	HookEvent("player_team", OnTeamChange);
	
	ScanAllPlayersLerp();

	AutoExecConfig(true, "lerptracker");
}


public void OnClientDisconnect_Post(int client)
{
	InvalidateCurrentLerp(client);
}

/* Lerp calculation adapted from hl2sdk's CGameServerClients::OnClientSettingsChanged */
public void OnClientSettingsChanged(int client)
{
	if(IsValidEntity(client) &&  !IsFakeClient(client)&& blerpdetect[client])
	{
		ProcessPlayerLerp(client);
	}
}

public void OnTeamChange(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (client > 0 && client < MaxClients+1)
	{
		if (IsClientInGame(client) && !IsFakeClient(client))
		{
			CreateTimer(1.0, OnTeamChangeDelay, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public void OnClientPutInServer(int client)
{
	blerpdetect[client] = false;
	CreateTimer(COLDDOWN_DELAY, COLDOWN,client, TIMER_FLAG_NO_MAPCHANGE);
	ClientTeam[client] = 0;
}

public Action COLDOWN(Handle timer, any client)
{
	blerpdetect[client] = true;
	if (client && IsClientConnected(client) && IsClientInGame(client)&& !IsFakeClient(client) && GetClientTeam(client) != 1 && blerpdetect[client])
	{
		ClientTeam[client] = GetClientTeam(client);
		ProcessPlayerLerp(client,true);
	}

	return Plugin_Continue;
}

public Action OnTeamChangeDelay(Handle timer, any client)
{
	int iTeam;
	if(!(client && IsClientConnected(client) && IsClientInGame(client)&& !IsFakeClient(client)))
		return Plugin_Continue;
	else
		iTeam = GetClientTeam(client);
	if (blerpdetect[client] && ClientTeam[client] != iTeam)
	{
		ClientTeam[client] = iTeam;
		if(iTeam != 1)
			ProcessPlayerLerp(client,true);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


public Action Lerps_Cmd(int client, int args)
{
	if(!DefaultLerpStyle())
	{
		int lerpcnt;
		
		for(int rclient=1; rclient <= MaxClients; rclient++)
		{
			if(IsClientInGame(rclient) && !IsFakeClient(rclient) && GetClientTeam(rclient) != 1)
			{
				ReplyToCommand(client, "%02d. %N Lerp: %.01f", ++lerpcnt, rclient, (GetCurrentLerp(rclient)*1000));
			}
		}
	}
	else
	{
		int survivorCount = 0;
		int infectedCount = 0;
		
		
		for(int rclient=1; rclient <= MaxClients; rclient++)
		{
			if(IsClientInGame(rclient) && !IsFakeClient(rclient))
			{
				if (GetClientTeam(rclient) == 2) survivorCount = 1;
				if (GetClientTeam(rclient) == 3) infectedCount = 1;
			}
		}
		
		if (survivorCount == 1 || infectedCount == 1) CPrintToChat(client, "{blue}{green}______________________________");
		
		for(int rclient=1; rclient <= MaxClients; rclient++)
		{
			if(IsClientInGame(rclient) && !IsFakeClient(rclient) && GetClientTeam(rclient) == 2)
			{
				CPrintToChat(client, "{blue}%N {default}@ {green}%.01f", rclient, (GetCurrentLerp(rclient)*1000));				
			}			
		}
		
		for(int rclient=1; rclient <= MaxClients; rclient++)
		{
			if(IsClientInGame(rclient) && !IsFakeClient(rclient) && GetClientTeam(rclient) == 3)
			{
				CPrintToChat(client, "{red}%N {default}@ {green}%.01f", rclient, (GetCurrentLerp(rclient)*1000));
			}
		}
		if (survivorCount == 1 || infectedCount == 1) CPrintToChat(client, "{blue}{green}______________________________");
	}
	return Plugin_Handled;
}

void ScanAllPlayersLerp()
{
	for(int client=1; client <= MaxClients; client++)
	{
		InvalidateCurrentLerp(client);
		if(IsClientInGame(client) && !IsFakeClient(client))
		{
			ProcessPlayerLerp(client);
		}
	}
}

void ProcessPlayerLerp(int client,bool teamchange = false)
{	
	float m_fLerpTime = GetEntPropFloat(client, Prop_Data, "m_fLerpTime");
	int iTeam = GetClientTeam(client);
	if(ShouldFixLerp())
	{
		m_fLerpTime = GetLerpTime(client);
		SetEntPropFloat(client, Prop_Data, "m_fLerpTime", m_fLerpTime);
	}
	
	if(IsCurrentLerpValid(client))
	{
		if(m_fLerpTime != GetCurrentLerp(client))
		{
			if(ShouldAnnounceLerpChanges())
			{
				if (iTeam == 2)
					CPrintToChatAll("<{olive}Lerp{default}> {blue}%N{green}'s Lerp改變 {olive}%.01f {green}成 {olive}%.01f", client, GetCurrentLerp(client)*1000, m_fLerpTime*1000);
				else if (iTeam == 3)
					CPrintToChatAll("<{olive}Lerp{default}> {red}%N{green}'s Lerp改變 {olive}%.01f {green}成 {olive}%.01f", client, GetCurrentLerp(client)*1000, m_fLerpTime*1000);
			}
		}
	}
	
	float max= hMaxLerpValue.FloatValue;
	if(m_fLerpTime > max)
	{
		if (iTeam != 1)
		{
			KickClient(client, "Lerp %.01f exceeds server max of %.01f", m_fLerpTime*1000, max*1000);
			CPrintToChatAll("<{olive}Lerp{default}> %N kicked for lerp too high. %.01f > %.01f", client, m_fLerpTime*1000, max*1000);
		}
		if(ShouldLogLerpChanges())
		{
			LogMessage("Kicked %L for having lerp %.01f (max: %.01f)", client, m_fLerpTime*1000, max*1000);
		}
	}
	else
	{
		SetCurrentLerp(client, m_fLerpTime);
	}
	
	if ( ((FloatCompare(m_fLerpTime, cVarMinLerp.FloatValue) == -1) || (FloatCompare(m_fLerpTime, cVarMaxLerp.FloatValue) == 1)) && GetClientTeam(client) != 1) {
		
		CPrintToChatAll("<{olive}Lerp{default}> {lightgreen}%N{default}'s Lerp {olive}%.01f{default} 被移至旁觀!", client, m_fLerpTime*1000);
		ChangeClientTeam(client, 1);
		CPrintToChat(client, "{blue}{default}[{green}提示{default}] Illegal lerp value (min: {olive}%.01f{default}, max: {olive}%.01f{default})",
					cVarMinLerp.FloatValue*1000, cVarMaxLerp.FloatValue*1000);
		// nothing else to do
		return;
	}
	if(teamchange)
	{
		if(iTeam == 2)
			CPrintToChatAll("<{olive}Lerp{default}> {blue}%N {default}@{blue} %.01f",client,m_fLerpTime*1000);
		else if (iTeam == 3)
			CPrintToChatAll("<{olive}Lerp{default}> {red}%N {default}@{red} %.01f",client,m_fLerpTime*1000);
	}
}



float GetLerpTime(int client)
{
	char buf[64];
	float lerpTime;
	
	#define QUICKGETCVARVALUE(%0) (GetClientInfo(client, (%0), buf, sizeof(buf)) ? buf : "")
	
	int updateRate = StringToInt( QUICKGETCVARVALUE("cl_updaterate") );
	updateRate = RoundFloat(clamp(float(updateRate), hMinUpdateRate.FloatValue, hMaxUpdateRate.FloatValue));
	
	float flLerpRatio = StringToFloat( QUICKGETCVARVALUE("cl_interp_ratio") );
	float flLerpAmount = StringToFloat( QUICKGETCVARVALUE("cl_interp") );
	
	if ( hMinInterpRatio != INVALID_HANDLE && hMaxInterpRatio != INVALID_HANDLE && hMinInterpRatio.FloatValue != -1.0 )
	{
		flLerpRatio = clamp( flLerpRatio, hMinInterpRatio.FloatValue, hMaxInterpRatio.FloatValue );
	}
	else
	{
		/*if ( flLerpRatio == 0 )
			flLerpRatio = 1.0;*/
	}

	lerpTime = MAX( flLerpAmount, flLerpRatio / updateRate );
	
#undef QUICKGETCVARVALUE
	return lerpTime;
}

float clamp(float yes, float low, float high)
{
	return yes > high ? high : (yes < low ? low : yes);
}