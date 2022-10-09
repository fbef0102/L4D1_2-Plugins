#pragma semicolon 1

#include <sourcemod>
#include <left4dhooks>
#include <multicolors>

#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

ConVar g_hBossBuffer;
int SurCurrent = 0;

public Plugin:myinfo =
{
    name = "L4D Survivor Progress",
    author = "CanadaRox, Visor, harry",
    description = "Print survivor progress in flow percents",
    version = "2.4",
    url = "http://steamcommunity.com/profiles/76561198026784913"
};

public OnPluginStart()
{
	g_hBossBuffer = FindConVar("versus_boss_buffer");

	RegConsoleCmd("sm_cur", CurrentCmd);
	RegConsoleCmd("sm_current", CurrentCmd);
	HookEvent("round_start", RoundStartEvent, EventHookMode_PostNoCopy);
}
public RoundStartEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	SurCurrent = 0;
}


public void L4D_OnFirstSurvivorLeftSafeArea_Post(int client)
{
	CPrintToChatAll("{default}[{olive}TS{default}] {blue}Current{default}: {green}%d%%", GetMaxSurvivorCompletion());
}

public Action:CurrentCmd(client, args)
{
	SurCurrent = GetMaxSurvivorCompletion();
	CPrintToChat(client, "{default}[{olive}TS{default}] {blue}Current{default}: {green}%d%%", SurCurrent);
	
}
stock int GetMaxSurvivorCompletion() {
	float flow = 0.0;
	if(L4D_IsVersusMode())
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i))
			{
				flow = MAX(flow, L4D2Direct_GetFlowDistance(i));
			}
		}
		
		flow = (flow / L4D2Direct_GetMapMaxFlowDistance()) + (g_hBossBuffer.FloatValue / L4D2Direct_GetMapMaxFlowDistance());
	}
	else
	{
		float tmp_flow, origin[3];
		Address pNavArea;
		for (int client = 1; client <= MaxClients; client++) {
			if(IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client))
			{
				GetClientAbsOrigin(client, origin);
				pNavArea = L4D2Direct_GetTerrorNavArea(origin);
				if (pNavArea != Address_Null)
				{
					tmp_flow = L4D2Direct_GetTerrorNavAreaFlow(pNavArea);
					flow = MAX(flow, tmp_flow);
				}
			}
		}

		flow = flow / L4D2Direct_GetMapMaxFlowDistance();
	}

	//PrintToChatAll("%.2f - %d -%.2f", flow, SurCurrent, (g_hBossBuffer.FloatValue / L4D2Direct_GetMapMaxFlowDistance()));
	flow = flow * 100;
	if (flow <= 1.0) flow = SurCurrent * 1.0;
	else if(flow > 100.0) flow = 100.0;

	return RoundToNearest(flow);
}