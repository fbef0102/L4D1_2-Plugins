#pragma semicolon 1
#pragma newdecls required;
#include <sourcemod>

char path[256];

ConVar g_hPenalty;
int g_iPenalty;

public Plugin myinfo =
{
	name = "Mathack Block",
	author = "Sir, Visor, NightTime & extrav3rt, Harry Potter",
	description = "Kicks out clients who are potentially attempting to enable mathack",
	version = "1.6",
	url = "http://steamcommunity.com/profiles/76561198026784913"
};

public void OnPluginStart()
{
	g_hPenalty = CreateConVar("l4d1_penalty", "1", "1 - kick clients, 0 - record players in log file(sourcemod/logs/mathack_cheaters.txt), other value: ban minutes");
	
	g_iPenalty = g_hPenalty.IntValue;
	g_hPenalty.AddChangeHook(ConVarChanged_Cvars);
	
	BuildPath(Path_SM, path, 256, "logs/mathack_cheaters.txt");
	
	CreateTimer(2.5, CheckClients, _, TIMER_REPEAT);

	AutoExecConfig(true, "l4d_texture_manager_block");
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	g_iPenalty = g_hPenalty.IntValue;
}

public Action CheckClients(Handle timer)
{
    for (int client = 1; client <= MaxClients; client++)
    {
        if (IsClientInGame(client) && !IsFakeClient(client))
        {
			QueryClientConVar(client, "mat_texture_list", ClientQueryCallback);
			QueryClientConVar(client, "mat_queue_mode", ClientQueryCallback_AntiVomit);
			QueryClientConVar(client, "mat_hdr_level", ClientQueryCallback_HDRLevel);
			QueryClientConVar(client, "mat_postprocess_enable", ClientQueryCallback_PostPrecess);
			QueryClientConVar(client, "r_drawothermodels", ClientQueryCallback_DrawModels);
			QueryClientConVar(client, "l4d_bhop", ClientQueryCallback_l4d_bhop); //ban auto bhop from dll
			QueryClientConVar(client, "l4d_bhop_autostrafe", ClientQueryCallback_l4d_bhop_autostrafe); //ban auto bhop from dll
			QueryClientConVar(client, "cl_fov", ClientQueryCallback_cl_fov);
		}
    }	
}

public void ClientQueryCallback(QueryCookie cookie,  int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	if(!IsClientInGame(client)) return;

	switch (result)
	{
		case 0:
		{
			int  mathax = StringToInt(cvarValue);
			if (mathax > 0)
			{
				char t_name[MAX_NAME_LENGTH];
				char SteamID[32];
				GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
				
				LogToFile(path, ".:[Name: %N | STEAMID: %s | r_drawothermodels: %d]:.", client, SteamID, mathax);
				
				if (g_iPenalty == 1)
				{
					PrintToChatAll("\x01[\x05TS\x01] \x03%s \x01has been kicked for using \x04mathack: mat_texture_list\x01!", t_name);
					KickClient(client, "ConVar mat_texture_list violation");
				}
				else if (g_iPenalty > 1)
				{
					PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been banned for using \x04mathack: mat_texture_list\x01!", client);
					static char reason[255];
					FormatEx(reason, sizeof(reason), "%s", "Banned for using mat_texture_list violation");

					BanClient(client, g_iPenalty, BANFLAG_AUTHID, reason, reason);
					ServerCommand("sm_exbanid %d \"%s\"", g_iPenalty, SteamID);
				}

			}
		}
		case 1:
		{
			KickClient(client, "ConVarQuery_NotFound");
		}
		case 2:
		{
			KickClient(client, "ConVarQuery_NotValid");
		}
		case 3:
		{
			KickClient(client, "ConVarQuery_Protected");
		}
	}
}


public void ClientQueryCallback_DrawModels(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{	
	if(!IsClientInGame(client)) return;

	int clientCvarValue = StringToInt(cvarValue);

	if (clientCvarValue != 1)
	{
		char t_name[MAX_NAME_LENGTH];
		GetClientName(client,t_name,MAX_NAME_LENGTH);

		char SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

		LogToFile(path, ".:[Name: %N | STEAMID: %s | r_drawothermodels: %d]:.", client, SteamID, clientCvarValue);

		if (g_iPenalty == 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%s \x01has been kicked for using \x04mathack: r_drawothermodels\x01!", t_name);
			KickClient(client, "ConVar r_drawothermodels violation");
		}
		else if (g_iPenalty > 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been banned for using \x04mathack: r_drawothermodels\x01!", client);
			static char reason[255];
			FormatEx(reason, sizeof(reason), "%s", "Banned for using r_drawothermodels violation");
			
			BanClient(client, g_iPenalty, BANFLAG_AUTHID, reason, reason);
			ServerCommand("sm_exbanid %d \"%s\"", g_iPenalty, SteamID);
		}
	}
}

public void ClientQueryCallback_PostPrecess(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{	
	if(!IsClientInGame(client)) return;

	int clientCvarValue = StringToInt(cvarValue);

	if (clientCvarValue != 1)
	{
		char t_name[MAX_NAME_LENGTH];
		GetClientName(client,t_name,MAX_NAME_LENGTH);

		char SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

		LogToFile(path, ".:[Name: %N | STEAMID: %s | mat_postprocess_enable: %d]:.", client, SteamID, clientCvarValue);

		if (g_iPenalty == 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been kicked for using \x04mathack: mat_postprocess_enable\x01!", client);
			KickClient(client, "ConVar mat_postprocess_enable violation");
		}
		else if (g_iPenalty > 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been banned for using \x04mathack: mat_postprocess_enable\x01!", client);
			static char reason[255];
			FormatEx(reason, sizeof(reason), "%s", "Banned for using mat_postprocess_enable violation");
			
			BanClient(client, g_iPenalty, BANFLAG_AUTHID, reason, reason);
			ServerCommand("sm_exbanid %d \"%s\"", g_iPenalty, SteamID);
		}
	}
}

public void ClientQueryCallback_AntiVomit(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{	
	if(!IsClientInGame(client)) return;

	int clientCvarValue = StringToInt(cvarValue);

	if (clientCvarValue >= 3)
	{
		char t_name[MAX_NAME_LENGTH];
		GetClientName(client,t_name,MAX_NAME_LENGTH);

		char SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
		LogToFile(path, ".:[Name: %N | STEAMID: %s | mat_queue_mode: %d]:.", client, SteamID, clientCvarValue);

		if (g_iPenalty == 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been kicked for using \x04mathack: mat_queue_mode\x01!", client);
			KickClient(client, "ConVar mat_queue_mode violation");
		}
		else if (g_iPenalty > 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been banned for using \x04mathack: mat_queue_mode\x01!", client);
			static char reason[255];
			FormatEx(reason, sizeof(reason), "%s", "Banned for using mat_queue_mode violation");
			
			BanClient(client, g_iPenalty, BANFLAG_AUTHID, reason, reason);
			ServerCommand("sm_exbanid %d \"%s\"", g_iPenalty, SteamID);
		}
	}
}

public void ClientQueryCallback_HDRLevel(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{	
	if(!IsClientInGame(client)) return;

	int clientCvarValue = StringToInt(cvarValue);

	if (clientCvarValue != 2)
	{
		char t_name[MAX_NAME_LENGTH];
		GetClientName(client,t_name,MAX_NAME_LENGTH);

		char SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
		LogToFile(path, ".:[Name: %N | STEAMID: %s | mat_hdr_level: %d]:.", client, SteamID, clientCvarValue);

		if (g_iPenalty == 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been kicked for using \x04mathack: mat_hdr_level\x01!", client);
			KickClient(client, "ConVar mat_hdr_level violation");
		}
		else if (g_iPenalty > 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been banned for using \x04mathack: mat_hdr_level\x01!", client);
			static char reason[255];
			FormatEx(reason, sizeof(reason), "%s", "Banned for using mat_hdr_level violation");
			
			BanClient(client, g_iPenalty, BANFLAG_AUTHID, reason, reason);
			ServerCommand("sm_exbanid %d \"%s\"", g_iPenalty, SteamID);
		}
	}
}

public void ClientQueryCallback_l4d_bhop(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{	
	if(!IsClientInGame(client)) return;

	int clientCvarValue = StringToInt(cvarValue);

	if (clientCvarValue > 0)
	{
		char t_name[MAX_NAME_LENGTH];
		GetClientName(client,t_name,MAX_NAME_LENGTH);
		
		char SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
		LogToFile(path, ".:[Name: %N | STEAMID: %s | l4d_bhop: %d]:.", client, SteamID, clientCvarValue);

		if (g_iPenalty == 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been kicked for using \x04l4dbhop.dll: l4d_bhop\x01!", client);
			KickClient(client, "ConVar l4d_bhop violation");
		}
		else if (g_iPenalty > 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been banned for using \x04l4dbhop.dll: l4d_bhop\x01!", client);
			static char reason[255];
			FormatEx(reason, sizeof(reason), "%s", "Banned for using l4dbhop.dll");
			
			BanClient(client, g_iPenalty, BANFLAG_AUTHID, reason, reason);
			ServerCommand("sm_exbanid %d \"%s\"", g_iPenalty, SteamID);
		}
	}
}

public void ClientQueryCallback_l4d_bhop_autostrafe(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{	
	if(!IsClientInGame(client)) return;

	int clientCvarValue = StringToInt(cvarValue);

	if (clientCvarValue > 0)
	{
		char t_name[MAX_NAME_LENGTH];
		GetClientName(client,t_name,MAX_NAME_LENGTH);

		char SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
		LogToFile(path, ".:[Name: %N | STEAMID: %s | l4d_bhop: %d]:.", client, SteamID, clientCvarValue);

		if (g_iPenalty == 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been kicked for using \x04l4dbhop.dll: l4d_bhop_autostrafe\x01!", client);
			KickClient(client, "ConVar l4d_bhop_autostrafe violation");
		}
		else if (g_iPenalty > 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been banned for using \x04l4dbhop.dll: l4d_bhop_autostrafe\x01!", client);
			static char reason[255];
			FormatEx(reason, sizeof(reason), "%s", "Banned for using l4dbhop.dll");
			
			BanClient(client, g_iPenalty, BANFLAG_AUTHID, reason, reason);
			ServerCommand("sm_exbanid %d \"%s\"", g_iPenalty, SteamID);
		}
	}
}

public void ClientQueryCallback_cl_fov(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{	
	if(!IsClientInGame(client)) return;

	int clientCvarValue = StringToInt(cvarValue);

	if (clientCvarValue > 120 || clientCvarValue < 75)
	{
		char t_name[MAX_NAME_LENGTH];
		GetClientName(client,t_name,MAX_NAME_LENGTH);
		
		char SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
		LogToFile(path, ".:[Name: %N | STEAMID: %s | cl_fov: %d]:.", client, SteamID, clientCvarValue);

		if (g_iPenalty == 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been kicked for using \x04cl_fov %d\x01!", client, clientCvarValue);
			KickClient(client, "ConVar cl_fov violation (must be 75~120)");
		}
		else if (g_iPenalty > 1)
		{
			PrintToChatAll("\x01[\x05TS\x01] \x03%N \x01has been banned for using \x04cl_fov %d\x01!", client, clientCvarValue);
			static char reason[255];
			FormatEx(reason, sizeof(reason), "%s", "Banned for using cl_fov %d (must be 75~120)", clientCvarValue);
			
			BanClient(client, g_iPenalty, BANFLAG_AUTHID, reason, reason);
			ServerCommand("sm_exbanid %d \"%s\"", g_iPenalty, SteamID);
		}
	}
}