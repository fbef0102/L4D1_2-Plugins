#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <left4dhooks>
#include <multicolors>

#define MAX(%0,%1) (((%0) > (%1)) ? (%0) : (%1))

ConVar g_hBossBuffer;
int g_iSurCurrent = 0;

public Plugin myinfo =
{
    name = "[L4D1/2] Survivor Progress",
    author = "CanadaRox, Visor, harry",
    description = "Print survivor progress in flow percents",
    version = "2.5-2025/9/11",
    url = "http://steamcommunity.com/profiles/76561198026784913"
};

public void OnPluginStart()
{
	g_hBossBuffer = FindConVar("versus_boss_buffer");

	RegConsoleCmd("sm_cur", CurrentCmd);
	RegConsoleCmd("sm_current", CurrentCmd);

	HookEvent("round_start", RoundStartEvent, EventHookMode_PostNoCopy);
}

Action CurrentCmd(int client, int args)
{
	if(client == 0) return Plugin_Handled;

	RequestFrame(OnNextFrame_CurrentCmd, GetClientUserId(client));

	return Plugin_Handled;
}

void OnNextFrame_CurrentCmd(int client)
{
	client = GetClientOfUserId(client);
	if(!client || !IsClientInGame(client)) return;
	
	g_iSurCurrent = GetMaxSurvivorCompletion();
	CPrintToChat(client, "{default}[{olive}TS{default}] {blue}Current{default}: {green}%d%%", g_iSurCurrent);
}

void RoundStartEvent(Event event, const char[] name, bool dontBroadcast) 
{
	g_iSurCurrent = 0;
}


public void L4D_OnFirstSurvivorLeftSafeArea_Post(int client)
{
	CPrintToChatAll("{default}[{olive}TS{default}] {blue}Current{default}: {green}%d%%", GetMaxSurvivorCompletion());
}

int GetMaxSurvivorCompletion() {
	float flow = 0.0, tmp_flow = 0.0;
	if(L4D_IsVersusMode())
	{
		Address pNavArea;
		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i)) {
				pNavArea = L4D_GetLastKnownArea(i);
				if (pNavArea != Address_Null) {
					tmp_flow = L4D2Direct_GetTerrorNavAreaFlow(pNavArea);
					flow = (flow > tmp_flow) ? flow : tmp_flow;
				}
			}
		}
		
		flow = (flow / L4D2Direct_GetMapMaxFlowDistance()) + (g_hBossBuffer.FloatValue / L4D2Direct_GetMapMaxFlowDistance());
	}
	else
	{
		Address pNavArea;
		for (int i = 1; i <= MaxClients; i++) {
			if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i)) {
				pNavArea = L4D_GetLastKnownArea(i);
				if (pNavArea != Address_Null) {
					tmp_flow = L4D2Direct_GetTerrorNavAreaFlow(pNavArea);
					flow = (flow > tmp_flow) ? flow : tmp_flow;
				}
			}
		}

		flow = flow / L4D2Direct_GetMapMaxFlowDistance();
	}

	//PrintToChatAll("%.2f - %d -%.2f", flow, g_iSurCurrent, (g_hBossBuffer.FloatValue / L4D2Direct_GetMapMaxFlowDistance()));
	flow = flow * 100;
	if (flow <= 1.0) flow = g_iSurCurrent * 1.0;
	else if(flow > 100.0) flow = 100.0;

	return RoundToNearest(flow);
}