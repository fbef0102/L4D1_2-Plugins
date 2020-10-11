

#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <multicolors>

#define PLUGIN_VERSION "1.3"
#define DEBUG 0
#define L4D_TEAM_SURVIVORS 2
#define L4D_TEAM_INFECTED 3
#define L4D_TEAM_SPECTATE 1

bool GameCodeLock;
int GameCode;
int GameCodeClient;
int OriginalTeam[MAXPLAYERS+1];

#define MIX_DELAY 5.0

int result_int;
char client_name[32]; // Used to store the client_name of the player who calls coinflip
int previous_timeC = 0; // Used for coinflip
int current_timeC = 0; // Used for coinflip
int previous_timeN = 0; // Used for picknumber
int current_timeN = 0; // Used for picknumber
Handle delay_time; // Handle for the coinflip_delay cvar
int number_max = 6; // Default maximum bound for picknumber

public Plugin myinfo = 
{
	name = "L4D Game",
	author = "Harry Potter",
	description = "Let's play a game, Duel 決鬥!!",
	version = PLUGIN_VERSION,
	url = "myself"
}

public void OnPluginStart()
{
	delay_time = CreateConVar("coinflip_delay","1", "Time delay in seconds between allowed coinflips. Set at -1 if no delay at all is desired.");
	
	RegConsoleCmd("say", Game_Say);
	RegConsoleCmd("say_team", Game_Say);

	RegConsoleCmd("sm_roll", Game_Roll);
	RegConsoleCmd("sm_picknumber", Game_Roll);
	RegConsoleCmd("sm_code", Game_Code);
	HookEvent("round_start", Event_Round_Start);
	RegConsoleCmd("sm_coinflip", Command_Coinflip);
	RegConsoleCmd("sm_coin", Command_Coinflip);
	RegConsoleCmd("sm_cf", Command_Coinflip);
	RegConsoleCmd("sm_flip", Command_Coinflip);

	//Autoconfig for plugin
	AutoExecConfig(true, "games");
}

public void OnMapStart()
{
	GameCodeLock = false;
}

public void Event_Round_Start(Event event, const char[] name, bool dontBroadcast) 
{
	for (int i = 1; i <= MaxClients; i++)
	{
		OriginalTeam[i] = 0;
	}
}

public void OnClientPutInServer(int client)
{
	OriginalTeam[client] = 0;	
}

public Action Command_Coinflip(int client, int args)
{
	current_timeC = GetTime();
	
	if((current_timeC - previous_timeC) > GetConVarInt(delay_time)) // Only perform a coinflip if enough time has passed since the last one. This prevents spamming.
	{
		result_int = GetURandomInt() % 2; // Gets a random integer and checks to see whether it's odd or even
		GetClientName(client, client_name, sizeof(client_name)); // Gets the client_name of the person using the command
		
		int iTeam = GetClientTeam(client);
		if(result_int == 0){
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i)&& !IsFakeClient(i) && GetClientTeam(i) == iTeam)
					CPrintToChat(i,"[{green}決鬥!{default}] {olive}%s{default} flipped a coin!. It's {green}Heads{default}!",client_name); // Here \x04 is actually yellow
			}
		}
		else{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i)&& !IsFakeClient(i) && GetClientTeam(i) == iTeam)
					CPrintToChat(i,"[{green}決鬥!{default}] {olive}%s{default} flipped a coin!. It's {green}Tails{default}!",client_name); // Here \x04 is actually yellow
			}
		}
		
		previous_timeC = current_timeC; // Update the previous time
	}
	else
	{
		ReplyToCommand(client, "[決鬥!] Whoa there buddy, slow down. Wait at least %d seconds.", GetConVarInt(delay_time));
	}
	
	return Plugin_Handled;
}

public Action Game_Say(int client, int args)
{
	if (client == 0)
	{
		return Plugin_Continue;
	}
	if(args < 1 || !GameCodeLock)
	{
		return Plugin_Continue;
	}
	
	char arg1[64];
	GetCmdArg(1, arg1, 64);
	if(IsInteger(arg1))
	{
		int iTeam = GetClientTeam(client);
		int result = StringToInt(arg1);
		if(result == GameCode){
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i)&& !IsFakeClient(i) && GetClientTeam(i) == iTeam)
					CPrintToChat(i,"[{green}決鬥!{default}] BINGO! {olive}%N {default}has guessed the right {olive}%N{default}'s code:{lightgreen} %d{default}. Cheer!",client,GameCodeClient,result);
			}
			GameCodeLock = false;
		}
		else if(result < GameCode){
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i)&& !IsFakeClient(i) && GetClientTeam(i) == iTeam)
					CPrintToChat(i,"[{green}決鬥!{default}] {olive}%N {default}guessed {green}%d{default}. Code is greater than{default} it.",client,result);
			}
		}
		else if(result > GameCode)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i)&& !IsFakeClient(i) && GetClientTeam(i) == iTeam)
					CPrintToChat(i,"[{green}決鬥!{default}] {olive}%N {default}guessed {green}%d{default}. Code is less than {default}it.",client,result);
			}
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action Game_Code(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[決鬥!] sm_code cannot be used by server.");
		return Plugin_Handled;
	}
	if(GameCodeLock)
	{
		ReplyToCommand(client, "[決鬥!] Someone has chosen a Da Vinci Code. Figure it out first!");		
		return Plugin_Handled;
	}
	if(args < 1)
	{
		ReplyToCommand(client, "[決鬥!] Usage: sm_code <0-100000> - Play a Da Vinci Code.");		
		return Plugin_Handled;
	}
	if(args > 1)
	{
		ReplyToCommand(client, "[決鬥!] Usage: sm_code <0-100000> - Play a Da Vinci Code.");		
		return Plugin_Handled;
	}
	
	char arg1[64];
	GetCmdArg(1, arg1, 64);
	if(IsInteger(arg1))
	{
		int iTeam = GetClientTeam(client);
		GameCode = StringToInt(arg1);
		if(GameCode > 100000|| GameCode < 0)
		{
			ReplyToCommand(client, "[決鬥!] Usage: sm_code <0-100000> - Play a Da Vinci Code.");
			return Plugin_Handled;
		}
		
		GameCodeClient = client;
		CPrintToChat(client,"[{green}決鬥!{default}] {default}You choose {lightgreen}%d{default} as code.",GameCode);
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientConnected(i) && IsClientInGame(i)&& !IsFakeClient(i) && GetClientTeam(i) == iTeam)
				CPrintToChat(i,"[{green}決鬥!{default}] {olive}%N {default}has chosen a {green}Da Vinci Code{default}. Anyone Wants to guess it ?",client);
		}
		GameCodeLock = true;
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[決鬥!] Usage: sm_code <0-100000> - Play a Da Vinci Code.");
		return Plugin_Handled;
	}
}

public Action Game_Roll(int client, int args)
{
	if (client == 0)
	{
		PrintToServer("[決鬥!] sm_roll/sm_picknumber cannot be used by server.");
		return Plugin_Handled;
	}
	if(args < 1)
	{
		current_timeN = GetTime();
		if((current_timeN - previous_timeN) > GetConVarInt(delay_time)) // Only perform a numberpick if enough time has passed since the last one.
		{
			current_timeN = GetTime();
			int iTeam = GetClientTeam(client);
			int result = GetRandomInt(1, number_max);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i)&& !IsFakeClient(i) && GetClientTeam(i) == iTeam)
					CPrintToChat(i,"[{green}決鬥!{default}] {olive}%N {default}rolled a {lightgreen}%d {default}sided die!. It's {green}%d{default}!",client,number_max,result);
			}
			previous_timeN = current_timeN; // Update the previous time
		}
		else
		{
			ReplyToCommand(client, "[決鬥!] Whoa there buddy, slow down. Wait at least %d seconds.", GetConVarInt(delay_time));
		}	
		return Plugin_Handled;
	}
	if(args > 1)
	{
		ReplyToCommand(client, "[決鬥!] Usage: sm_roll/sm_picknumber <Integer> - Play a Integer-sided dice.");		
		return Plugin_Handled;
	}
	
	char arg1[64];
	GetCmdArg(1, arg1, 64);
	if(IsInteger(arg1))
	{
		current_timeN = GetTime();
		
		if((current_timeN - previous_timeN) > GetConVarInt(delay_time)) // Only perform a numberpick if enough time has passed since the last one.
		{
			int iTeam = GetClientTeam(client);
			int side = StringToInt(arg1);
			if(side <= 0)
			{
				ReplyToCommand(client, "[決鬥!] Usage: sm_roll/sm_picknumber <Integer> - Play a Integer-sided dice.");	
				return Plugin_Handled;
			}
			
			int result = GetRandomInt(1, side);
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientConnected(i) && IsClientInGame(i)&& !IsFakeClient(i) && GetClientTeam(i) == iTeam)
					CPrintToChat(i,"[{green}決鬥!{default}] {olive}%N {default}rolled a {lightgreen}%d {default}sided die!. It's {green}%d{default}!",client,side,result);
			}
			previous_timeN = current_timeN; // Update the previous time
		}
		else
		{
			ReplyToCommand(client, "[決鬥!] Whoa there buddy, slow down. Wait at least %d seconds.", GetConVarInt(delay_time));
		}
		return Plugin_Handled;
	}
	else
	{
		ReplyToCommand(client, "[決鬥!] Usage: sm_roll/sm_picknumber <Integer> - Play a Integer-sided dice.");
		return Plugin_Handled;
	}
}

public bool IsInteger(const char[] buffer)
{
    int len = strlen(buffer);
    for (int i = 0; i < len; i++)
    {
        if ( !IsCharNumeric(buffer[i]) )
            return false;
    }

    return true;    
}

public Action Survivor_Take_Control(Handle timer, any client)
{
		int localClientTeam = GetClientTeam(client);
		char command[] = "sb_takecontrol";
		int flags = GetCommandFlags(command);
		SetCommandFlags(command, flags & ~FCVAR_CHEAT);
		char botNames[][] = { "teengirl", "manager", "namvet", "biker","coach","gambler","mechanic","producer" };
		
		int i = 0;
		while((localClientTeam != 2) && i < 8)
		{
			FakeClientCommand(client, "sb_takecontrol %s", botNames[i]);
			localClientTeam = GetClientTeam(client);
			i++;
		}
		SetCommandFlags(command, flags);
}