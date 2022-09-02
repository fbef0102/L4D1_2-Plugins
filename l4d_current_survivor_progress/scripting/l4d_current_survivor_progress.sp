#pragma semicolon 1

#include <sourcemod>
#include <left4dhooks>
#include <multicolors>

#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

ConVar g_hCpBossBuffer;
int SurCurrent = 0;

public Plugin:myinfo =
{
    name = "L4D1 Survivor Progress",
    author = "CanadaRox, Visor, harry",
    description = "Print survivor progress in flow percents",
    version = "2.3",
    url = "http://steamcommunity.com/profiles/76561198026784913"
};

public OnPluginStart()
{
	g_hCpBossBuffer = FindConVar("versus_boss_buffer");

	RegConsoleCmd("sm_cur", CurrentCmd);
	RegConsoleCmd("sm_current", CurrentCmd);
	HookEvent("round_start", RoundStartEvent, EventHookMode_PostNoCopy);
	HookEvent("player_left_start_area", LeftStartAreaEvent, EventHookMode_PostNoCopy);
}
public RoundStartEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	SurCurrent = 0;
}

public LeftStartAreaEvent(Handle:event, String:name[], bool:dontBroadcast)
{
	CPrintToChatAll("{default}[{olive}TS{default}] {blue}Current{default}: {green}%d%%", SurCurrent);
}

public Action:CurrentCmd(client, args)
{
	SurCurrent = GetMaxSurvivorCompletion();
	CPrintToChat(client, "{default}[{olive}TS{default}] {blue}Current{default}: {green}%d%%", SurCurrent);
	
}
stock int GetMaxSurvivorCompletion() {
	float flow = 0.0;
	float tmp_flow, origin[3];
	Address pNavArea;
	for (int client = 1; client <= MaxClients; client++) {
		if(IsClientInGame(client) && GetClientTeam(client) == 2)
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
	flow = (flow * 100 / L4D2Direct_GetMapMaxFlowDistance()) + (g_hCpBossBuffer.FloatValue / L4D2Direct_GetMapMaxFlowDistance());
	//PrintToChatAll("%.2f - %d", flow, SurCurrent);
	if (flow <= 1.0) flow = SurCurrent * 1.0;
	else if(flow > 100.0) flow = 100.0;

	return RoundToNearest(flow);
}