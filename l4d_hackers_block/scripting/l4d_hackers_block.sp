/**
 * SourceMod is licensed under the GNU General Public License, version 3.  
 */
/*
H attacking l4d server, he somehow activates somthing that prints to chat BUG REPORTER ACTIVATED BY: after that he uses the commands bugpause and bugunpause to pause the game rendering it frozen. what is this bug reporter activated and how to prevent that?
Yikes — sounds like someone’s exploiting developer commands that were never meant for public mischief. Let’s break it down:

🐞 What “BUG REPORTER ACTIVATED BY:” Means
This message is triggered when a player uses the bugpause command. It’s part of Left 4 Dead 2’s internal bug reporting system, originally intended for developers to pause the game and capture a snapshot for debugging. When activated:

It prints BUG REPORTER ACTIVATED BY: [player name] in chat.

The game may freeze or pause, disrupting gameplay.

bugunpause resumes the game — but if spammed, it can crash or lock up the server.

🛡️ How Hackers Exploit It
These commands are normally restricted, but if your server has insecure settings, or if the attacker has admin access or uses a modded client, they can trigger them remotely.

There’s no built-in limit to how often these commands can be executed, which makes them ripe for abuse.

🧰 How to Prevent It
Here are some steps to lock things down:

Secure Your Server Config:

Add sv_allow_wait_command 0 to your server.cfg to block certain pause-related exploits.

Use sv_cheats 0 and ensure no plugins override it.

Block the Commands:

Use a SourceMod plugin like UnPause by Dragokas, which disables the pause command entirely.

You can also write a custom plugin to intercept and block bugpause and bugunpause.

Restrict Access:

Audit your admin list and remove any suspicious entries.

Use sm_who or similar commands to monitor who has elevated permissions.
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION			"1.0"
#define PLUGIN_NAME			    "l4d_hackers_block"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[L4D1/2] Hackers Block",
	author = "xxx",
	description = "Block hackers using some exploit to crash server",
	version = PLUGIN_VERSION,
	url = "zzzzzzz"
};

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

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define LOG_FILE		        "logs/" ... PLUGIN_NAME ... ".log"

ConVar g_hCvarEnable, g_hCvarKick;
bool g_bCvarEnable;
int g_iCvarKick;

char sg_log[256];

public void OnPluginStart()
{
    g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",        "1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarKick         = CreateConVar( PLUGIN_NAME ... "_kick",          "1",   "1=Kick players if client's authentication failed (steam id is not valid), 0=Log only", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                       PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                PLUGIN_NAME);

    GetCvars();
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarKick.AddChangeHook(ConVarChanged_Cvars);

    // 開發者測試用的命令, 在客戶端輸入命令會導致遊戲凍結或暫停, 聊天框出現 "BUG REPORTER ACTIVATED BY:"
    RegConsoleCmd("bugpause", bugpause);
    RegConsoleCmd("bugunpause", bugunpause);
   
    if(g_bL4D2Version)
    {
        // 別問我, 伺服器端輸入這條直接崩潰
        RegConsoleCmd("jockey", jockey);
    }

    BuildPath(Path_SM, sg_log, sizeof(sg_log), "%s", LOG_FILE);
}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarEnable = g_hCvarEnable.BoolValue;
    g_iCvarKick = g_hCvarKick.IntValue;
}

// Sourcemod API Forward-------------------------------

bool g_bServerLoaded = false,
    g_bServerFirstMap = true;
public void OnConfigsExecuted()
{
    if(g_bServerFirstMap)
    {
        g_bServerFirstMap = false;
        CreateTimer(30.0, Timer_ServerLoaded);
    }
}

public void OnClientPutInServer(int client) 
{
    if(IsFakeClient(client)) return;

    int userid = GetClientUserId(client);
    CreateTimer(10.0, CheckSteamID, userid, TIMER_FLAG_NO_MAPCHANGE);
}
// Command-------------------------------

Action bugpause(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Continue;

    return Plugin_Handled;
}

Action bugunpause(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Continue;

    return Plugin_Handled;
}

Action jockey(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Continue;

    return Plugin_Handled;
}

// Timer & Frame-------------------------------

Action Timer_ServerLoaded(Handle timer)
{
    g_bServerLoaded = true;

    return Plugin_Continue;
}

//駭客阻止Steam ID驗證導致ban失效
Action CheckSteamID(Handle timer, int userid) 
{
    int client = GetClientOfUserId(userid);

    if (client == 0 || !IsClientInGame(client)) {
        return Plugin_Continue;
    }

    if(!g_bServerLoaded)
    {
        CreateTimer(10.0, CheckSteamID, userid, TIMER_FLAG_NO_MAPCHANGE);
        return Plugin_Continue;
    }

    char steamID[32];
    if (!GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID))) 
    {
        char ip[32];
        GetClientIP(client, ip, sizeof(ip));

        if(g_iCvarKick == 1)
        {
            LogToFileEx(sg_log, "Kick %N <STEAM_ID_PENDING>, IP: %s", client, ip);
            KickClient(client, "AuthId not valid");
        }
        else 
        {
            LogToFileEx(sg_log, "Warning! %N <STEAM_ID_PENDING>, IP: %s", client, ip);
        }
    }

    return Plugin_Continue;
}