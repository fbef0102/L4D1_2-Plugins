#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <multicolors>

#define L4D_TEAM_INFECTED 3
#define L4D_TEAM_SURVIVOR 2
#define L4D_TEAM_SPECTATOR 1

int killif[MAXPLAYERS+1];
int killifs[MAXPLAYERS+1];
int damageff[MAXPLAYERS+1];
int iheadshot[MAXPLAYERS+1];
int sheadshot[MAXPLAYERS+1];
bool HasRoundEndedPrinted;

public Plugin myinfo = 
{
	name = "Kill stats (!kills)",
	author = "Harry Potter",
	description = "Show statistics of surviviors (kill S.I, C.I. and FF)on round end",
	version = "1.6",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}
public void OnPluginStart()   
{
	LoadTranslations("kills.phrases");
	RegConsoleCmd("kills", Command_kill);
	
	HookEvent("player_death", event_kill_infectedplayer);
	HookEvent("infected_death", event_kill_infecteds);
	HookEvent("round_start", event_RoundStart);
	HookEvent("player_hurt", event_PlayerHurt);
	HookEvent("round_end", event_RoundEnd, EventHookMode_PostNoCopy);
	HookEvent("map_transition", event_RoundEnd, EventHookMode_PostNoCopy); //戰役過關到下一關的時候 (之後沒有觸發round_end)
	HookEvent("mission_lost", event_RoundEnd, EventHookMode_PostNoCopy); //戰役滅團重來該關卡的時候 (之後有觸發round_end)
	HookEvent("finale_vehicle_leaving", event_RoundEnd, EventHookMode_PostNoCopy); //救援載具離開之時  (之後沒有觸發round_end)

}
public void OnMapStart() 
{ 
	HasRoundEndedPrinted = false;  
	kill_infected();
}

public void event_PlayerHurt(Event event, const char[] name, bool dontBroadcast) 
{
	int victimId = event.GetInt("userid");
	int victim = GetClientOfUserId(victimId);
	int attackerId = event.GetInt("attacker");
	int attackersid = GetClientOfUserId(attackerId);
	int damageDone = event.GetInt("dmg_health");
	
	if (attackerId && victimId && IsClientInGame(attackersid) && GetClientTeam(attackersid) == L4D_TEAM_SURVIVOR && GetClientTeam(victim) == L4D_TEAM_SURVIVOR)
    {
        damageff[attackersid] += damageDone;
    }
    
}

public void event_kill_infecteds(Event event, const char[] name, bool dontBroadcast) 
{
	int killer = GetClientOfUserId(event.GetInt("attacker"));
	
	if (!killer || !IsClientInGame(killer))
        return;

	if(GetClientTeam(killer) == L4D_TEAM_SURVIVOR)
	{
		killifs[killer] += 1;
		bool headshot=event.GetBool("headshot");
		if(headshot) iheadshot[killer] += 1;
	}
}

public void event_kill_infectedplayer(Event event, const char[] name, bool dontBroadcast) 
{
	int killer = GetClientOfUserId(event.GetInt("attacker"));
	int deadbody = GetClientOfUserId(event.GetInt("userid"));
	if (killer && IsClientInGame(killer) && GetClientTeam(killer) == L4D_TEAM_SURVIVOR && deadbody && IsClientInGame(deadbody) && GetClientTeam(deadbody) == L4D_TEAM_INFECTED)
	{
		killif[killer] += 1;
		bool headshot = event.GetBool("headshot");
		if(headshot) sheadshot[killer] += 1;
	}
}

public void event_RoundEnd(Event event, const char[] name, bool dontBroadcast) 
{
	if(!HasRoundEndedPrinted)
	{
		CreateTimer(1.5, KillPinfected_dis);
		HasRoundEndedPrinted = true;
	}
}

Action KillPinfected_dis(Handle timer)
{
	displaykillinfected(0);

	return Plugin_Continue;
}

public void event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	HasRoundEndedPrinted = false;
	kill_infected();
}

public Action Command_kill(int client, int args)
{
	int iTeam = GetClientTeam(client);
	displaykillinfected(iTeam);

	return Plugin_Handled;
}

void displaykillinfected(int team)
{	
	int client;
	int players = 0;
	int[] players_clients = new int[MaxClients+1];
	int killss, killsss, killssss,damageffss,killssssss;
	for (client = 1; client <= MaxClients; client++)
	{
		if (!IsClientInGame(client) || GetClientTeam(client) != L4D_TEAM_SURVIVOR) continue;
		players_clients[players] = client;
		players++;
	}
	SortCustom1D(players_clients, players, SortByDamageDesc);
	for (int i = 0 ; i < players; i++)
	{
		client = players_clients[i];
		killss = killif[client];
		killsss = killifs[client];
		killssss = iheadshot[client];
		killssssss = sheadshot[client];
		damageffss = damageff[client];
		
		if(team == 0){
			CPrintToChatAll("%t","kills1", killss, killssssss, killsss, killssss, damageffss,client);
		}
		else
		{
			for (int j = 1; j <= MaxClients; j++)
			{
				if (IsClientConnected(j) && IsClientInGame(j)&& !IsFakeClient(j) && GetClientTeam(j) == team)
				{
					CPrintToChat(j,"%T","kills1",j, killss, killssssss, killsss, killssss, damageffss,client);
				}
			}
		}
	}
}	
	

public int SortByDamageDesc(int elem1, int elem2, const int[] array, Handle hndl)
{
	if (killif[elem1] > killif[elem2]) return -1;
	else if (killif[elem2] > killif[elem1]) return 1;
	else if (elem1 > elem2) return -1;
	else if (elem2 > elem1) return 1;
	return 0;
}


void kill_infected()
{
	for (int i = 1; i <= MaxClients; i++)
	{ 
		 killif[i] = 0; 
		 killifs[i] = 0; 
		 iheadshot[i] = 0;
		 sheadshot[i] = 0;
		 damageff[i] = 0;
	}
}