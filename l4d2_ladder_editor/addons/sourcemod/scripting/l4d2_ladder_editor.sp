//https://developer.valvesoftware.com/wiki/Func_ladder
//team <integer>
//Team that can climb this ladder.
//0 : Any team
//1 : Survivors
//2 : Infected 

#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#define PLUGIN_VERSION			"1.0h-2025/10/7"

public Plugin myinfo = 
{
    name = "L4D2 Ladder Editor",
    author = "devilesk, dragokas, Harry",
    version = PLUGIN_VERSION,
    description = "Clone and move special infected/survivor ladders.",
    url = "https://github.com/devilesk/rl4d2l-plugins"
};

//bool g_bL4D2Version;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test == Engine_Left4Dead )
    {
        //g_bL4D2Version = false;
    }
    else if( test == Engine_Left4Dead2 )
    {
        //g_bL4D2Version = true;
    }
    else
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

#define MAX_STR_LEN             100
#define DEFAULT_STEP_SIZE       1.0
#define TEAM_INFECTED           3
#define HUD_DRAW_INTERVAL       0.5

int selectedLadder[MAXPLAYERS + 1];
int bEditMode[MAXPLAYERS + 1];
float stepSize[MAXPLAYERS + 1];
Handle hLadders;
bool in_attack[MAXPLAYERS + 1];
bool in_attack2[MAXPLAYERS + 1];
bool in_score[MAXPLAYERS + 1];
bool in_zoom[MAXPLAYERS + 1];
bool in_speed[MAXPLAYERS + 1];
bool bHudActive[MAXPLAYERS + 1];
bool bHudHintShown[MAXPLAYERS + 1];

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar stripper_cfg_path;
char g_sCvar_stripper_cfg_path[128];

ConVar g_hCvarEnable, g_hCvarTab, g_hCvarFreeze;
bool g_bCvarEnable, g_bCvarTab, g_bCvarFreeze;

//https://developer.valvesoftware.com/wiki/Func_simpleladder
static const char g_sTeamNum[6][] =
{
    "Any Team",         //0
    "Spectator",        //1
    "Survivor",         //2
    "Infected",         //3
    "L4D1_Survivor",    //4
    "Unknown"           //5?
};

public void OnPluginStart() 
{
    g_hCvarEnable 		= CreateConVar("l4d2_ladder_editor_enable",    "1", "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarTab 		    = CreateConVar("l4d2_ladder_editor_tab",       "1", "If 1, Use Tab key to toggle edit mode.", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarFreeze 		= CreateConVar("l4d2_ladder_editor_freeze",    "0", "If 1, Freeze player when entering edit mode.", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                      "l4d2_ladder_editor_version",   PLUGIN_VERSION, "l4d2_ladder_editor Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,               "l4d2_ladder_editor");

    GetCvars();
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarTab.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarFreeze.AddChangeHook(ConVarChanged_Cvars);

    RegConsoleCmd("sm_edit",        Command_Edit,                   "Toggle edit mode");
    RegConsoleCmd("sm_step",        Command_Step,                   "Usage: sm_step <size>. Number of units to move when moving ladders in edit mode.");
    RegConsoleCmd("sm_select",      Command_Select,                 "Select the ladder you are aiming at.");
    RegConsoleCmd("sm_clone",       Command_Clone,                  "Clone the selected ladder.");
    RegConsoleCmd("sm_move",        Command_Move,                   "Usage: sm_move <x> <y> <z> - Move the selected ladder to the given coordinate on the map.");
    RegConsoleCmd("sm_nudge",       Command_Nudge,                  "Usage: sm_nudge <x> <y> <z> - Move the selected ladder relative to its current position.");
    RegConsoleCmd("sm_rotate",      Command_Rotate,                 "Usage: sm_rotate <x> <y> <z> - Rotate the selected ladder.");
    RegConsoleCmd("sm_kill",        Command_Kill,                   "Remove the selected ladder.");
    RegConsoleCmd("sm_info",        Command_Info,                   "Display info about the selected ladder entity on console.");
    RegConsoleCmd("sm_togglehud",   Command_ToggleHud,              "Toggle selected ladder info HUD on or off.");
    
    RegConsoleCmd("sm_team",        Command_Team,                   "Usage: sm_team <TeamNum>, 0: Any team, 1: Survivor, 2: Infected - Change team the ladder can used by");
    RegConsoleCmd("sm_flbm",        Command_FindLadderByModel,      "Usage: sm_flbm <model_name> - Find func_simpleladder by model");
    RegConsoleCmd("sm_flbh",        Command_FindLadderByHammerId,   "Usage: sm_flbh <hammerid> - Find func_simpleladder by hammerid");
    RegConsoleCmd("sm_cln",         Command_ChangeLadderNormal,     "Usage: sm_cln <x> <y> <z> | sm_cln <1~6> - Change func_simpleladder normal.x normal.y normal.z");
    
    HookEvent("player_team", PlayerTeam_Event);

    hLadders = CreateTrie();
    for (int i = 1; i <= MaxClients; i++) {
		selectedLadder[i] = -1;
		bEditMode[i] = false;
		in_attack[i] = false;
		in_attack2[i] = false;
		in_score[i] = false;
		in_zoom[i] = false;
		in_speed[i] = false;
		bHudActive[i] = false;
		stepSize[i] = DEFAULT_STEP_SIZE;
    }

    CreateTimer(HUD_DRAW_INTERVAL, HudDrawTimer, _, TIMER_REPEAT);
}

public void OnAllPluginsLoaded()
{
	// stripper extension
	if( FindConVar("stripper_version") == null )
	{
		SetFailState("\n==========\nWarning: You should install \"Stripper:Source\" to spawn objects permanently to the map: https://www.bailopan.net/stripper/snapshots/1.2/\n==========\n");
	}

	stripper_cfg_path = FindConVar("stripper_cfg_path");
	if(stripper_cfg_path != null)
	{
		GetOtherCvars();
		stripper_cfg_path.AddChangeHook(ConVarChanged_OtherCvars);
	}
}

// Cvars-------------------------------

void ConVarChanged_Cvars(Handle hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarEnable = g_hCvarEnable.BoolValue;
    g_bCvarTab = g_hCvarTab.BoolValue;
    g_bCvarFreeze = g_hCvarFreeze.BoolValue;
}

void ConVarChanged_OtherCvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetOtherCvars();
}

void GetOtherCvars()
{
	stripper_cfg_path.GetString(g_sCvar_stripper_cfg_path, sizeof(g_sCvar_stripper_cfg_path));
}

// Sourcemod API Forward-------------------------------


char g_sCurrentMap[256];
public void OnMapStart() 
{
    GetCurrentMap(g_sCurrentMap, sizeof(g_sCurrentMap));
    for (int i = 1; i <= MaxClients; i++) {
		selectedLadder[i] = -1;
		bEditMode[i] = false;
		in_attack[i] = false;
		in_attack2[i] = false;
		in_score[i] = false;
		in_zoom[i] = false;
		in_speed[i] = false;
		bHudActive[i] = false;
		stepSize[i] = DEFAULT_STEP_SIZE;
    }
    ClearTrie(hLadders);
}

public void OnClientPutInServer(int client)
{
    bHudHintShown[client] = false;
}

public void OnClientDisconnect(int client)
{
	bEditMode[client] = false;
	in_attack[client] = false;
	in_attack2[client] = false;
	in_score[client] = false;
	in_zoom[client] = false;
	in_speed[client] = false;
	bHudActive[client] = false;
	stepSize[client] = DEFAULT_STEP_SIZE;
}

// Command-------------------------------

Action Command_Edit(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    if (GetClientTeam(client) != TEAM_INFECTED) {
        PrintToChat(client, "Must be on infected team to enter edit mode.");
        return Plugin_Handled;
    }
    if (bEditMode[client]) {
        bEditMode[client] = false;
        if(g_bCvarFreeze) 
        {
            SetClientFrozen(client, false);
            if(!IsPlayerAlive(client)) SetEntityMoveType(client, MOVETYPE_NOCLIP);
        }
        PrintToChat(client, "Exiting edit mode.");
    }
    else {
        bEditMode[client] = true;
        if(g_bCvarFreeze)
        {
            SetClientFrozen(client, true);
        }
        PrintToChat(client, "Entering edit mode.");
    }
    return Plugin_Handled;
}

Action Command_Step(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    if (args != 1) {
        PrintToChat(client, "[TS] Usage: sm_step <size>");
        return Plugin_Handled;
    }
    char x[8];
    GetCmdArg(1, x, sizeof(x));
    int size = StringToInt(x);
    if (size > 0) {
        stepSize[client] = size * 1.0;
        PrintToChat(client, "Step size set to %i.", size);
    }
    else {
        PrintToChat(client, "Step size must be greater than 0.");
    }
    return Plugin_Handled;
}

Action Command_Select(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    char classname[MAX_STR_LEN];
    int entity = GetClientAimTarget(client, false);
    if (IsValidEntity(entity)) {
        GetEntityClassname(entity, classname, MAX_STR_LEN);
        if (StrEqual(classname, "func_simpleladder", false)) {
            selectedLadder[client] = entity;
            
            char modelname[128];
            float origin[3], position[3], normal[3], angles[3];
            int team;
            GetLadderEntityInfo(entity, modelname, sizeof(modelname), origin, position, normal, angles, team);
            PrintToChat(client, "Selected ladder entity %i, %s at (%.2f %.2f %.2f). origin: (%.2f %.2f %.2f). normal: (%.2f %.2f %.2f)", entity, modelname, position[0], position[1], position[2], origin[0], origin[1], origin[2], normal[0], normal[1], normal[2]);
           
            int iHammerID = Entity_GetHammerId(entity);
            if(iHammerID <= 0)
            {
                PrintToChat(client, "The selected ladder is not original from map");
            }
            else
            {
                PrintToChat(client, "HammerId: %d", iHammerID);
            }
        }
        else {
            float VecOrigin[3];
            float VecAngles[3];
            GetClientEyePosition(client, VecOrigin);
            GetClientEyeAngles(client, VecAngles);
            TR_TraceRayFilter(VecOrigin, VecAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayFilter, client);
            
            if (TR_DidHit(null))
            {
                entity = TR_GetEntityIndex(null);
                if(entity > MaxClients && IsValidEntity(entity))
                {
                    selectedLadder[client] = entity;
                    
                    char modelname[128];
                    float origin[3], position[3], normal[3], angles[3];
                    int team;
                    GetLadderEntityInfo(entity, modelname, sizeof(modelname), origin, position, normal, angles, team);
                    PrintToChat(client, "Selected ladder entity %i, %s at (%.2f %.2f %.2f). origin: (%.2f %.2f %.2f). normal: (%.2f %.2f %.2f)", entity, modelname, position[0], position[1], position[2], origin[0], origin[1], origin[2], normal[0], normal[1], normal[2]);
                    int iHammerID = Entity_GetHammerId(entity);
                    if(iHammerID <= 0)
                    {
                        PrintToChat(client, "The selected ladder is not original from map");
                    }
                    else
                    {
                        PrintToChat(client, "HammerId: %d", iHammerID);
                    }

                    return Plugin_Handled;
                }
            }

            selectedLadder[client] = -1;
            PrintToChat(client, "Not looking at a ladder. Entity %i, classname: %s", entity, classname);
        }
    }
    else {
        selectedLadder[client] = -1;
        PrintToChat(client, "Looking at invalid entity %i", entity);
    }
    return Plugin_Handled;
}

Action Command_Clone(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    char classname[MAX_STR_LEN];
    int sourceEnt = selectedLadder[client];
    if (IsValidEntity(sourceEnt)) 
    {
        int iHammerID = Entity_GetHammerId(sourceEnt);
        if(iHammerID <= 0)
        {
            PrintToChat(client, "\x04Clone Failed!!! \x01The selected ladder is not original from map");
            return Plugin_Handled;
        }

        GetEntityClassname(sourceEnt, classname, MAX_STR_LEN);
        if (!StrEqual(classname, "func_simpleladder", false)) {
            selectedLadder[client] = -1;
            PrintToChat(client, "No ladder selected.");
            return Plugin_Handled;
        }
        char modelname[128];
        float origin[3], position[3], normal[3], angles[3];
        int team;
        GetLadderEntityInfo(sourceEnt, modelname, sizeof(modelname), origin, position, normal, angles, team);
        PrecacheModel(modelname, true);
        int entity = CreateEntityByName("func_simpleladder");
        if (entity == -1)
        {
            PrintToChat(client, "Failed to create ladder.");
            return Plugin_Handled;
        }
        char buf[32];
        DispatchKeyValue(entity, "model", modelname);
        Format(buf, sizeof(buf), "%.6f", normal[2]);
        DispatchKeyValue(entity, "normal.z", buf);
        Format(buf, sizeof(buf), "%.6f", normal[1]);
        DispatchKeyValue(entity, "normal.y", buf);
        Format(buf, sizeof(buf), "%.6f", normal[0]);
        DispatchKeyValue(entity, "normal.x", buf);
        SetEntProp(entity, Prop_Send, "m_iTeamNum", team);
        DispatchKeyValue(entity, "origin", "50 0 0");

        DispatchSpawn(entity);
        selectedLadder[client] = entity;
        char key[8];
        IntToString(entity, key, 8);
        SetTrieValue(hLadders, key, sourceEnt, true);
        PrintToChat(client, "Cloned ladder entity %i. int entity %i", sourceEnt, entity);
    }
    else {
        PrintToChat(client, "No ladder selected.");
    }
    return Plugin_Handled;
}

Action Command_Move(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    if (args != 3) {
        PrintToChat(client, "[TS] Usage: sm_move <x> <y> <z>");
        return Plugin_Handled;
    }
    char x[8], y[8], z[8];
    GetCmdArg(1, x, sizeof(x));
    GetCmdArg(2, y, sizeof(y));
    GetCmdArg(3, z, sizeof(z));
    Move(client, StringToFloat(x), StringToFloat(y), StringToFloat(z), true);
    return Plugin_Handled;
}

Action Command_Nudge(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    if (args != 3) {
        PrintToChat(client, "[TS] Usage: sm_nudge <x> <y> <z>");
        return Plugin_Handled;
    }
    char x[8], y[8], z[8];
    GetCmdArg(1, x, sizeof(x));
    GetCmdArg(2, y, sizeof(y));
    GetCmdArg(3, z, sizeof(z));
    Nudge(client, StringToFloat(x), StringToFloat(y), StringToFloat(z), true);
    return Plugin_Handled;
}

Action Command_Rotate(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    if (args != 3) {
        PrintToChat(client, "[TS] Usage: sm_rotate <x> <y> <z>");
        return Plugin_Handled;
    }
    char x[8], y[8], z[8];
    GetCmdArg(1, x, sizeof(x));
    GetCmdArg(2, y, sizeof(y));
    GetCmdArg(3, z, sizeof(z));
    Rotate(client, StringToFloat(x), StringToFloat(y), StringToFloat(z), true);
    return Plugin_Handled;
}

Action Command_Kill(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    char modelname[128];
    char classname[MAX_STR_LEN];
    int entity = selectedLadder[client];
    if (IsValidEntity(entity)) {
        GetEntityClassname(entity, classname, MAX_STR_LEN);
        float normal[3];
        float origin[3];
        float position[3];
        float mins[3], maxs[3];
        GetEntPropString(entity, Prop_Data, "m_ModelName", modelname, sizeof(modelname));
        GetEntPropVector(entity, Prop_Send, "m_climbableNormal", normal);
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
        GetEntPropVector(entity,Prop_Send,"m_vecMins",mins);
        GetEntPropVector(entity,Prop_Send,"m_vecMaxs",maxs);
        position[0] = origin[0] + (mins[0] + maxs[0]) * 0.5;
        position[1] = origin[1] + (mins[1] + maxs[1]) * 0.5;
        position[2] = origin[1] + (mins[2] + maxs[2]) * 0.5;
        AcceptEntityInput(entity, "Kill");
        selectedLadder[client] = -1;
        char key[8];
        IntToString(entity, key, 8);
        RemoveFromTrie(hLadders, key);
        PrintToChat(client, "Killed ladder entity %i, %s at (%.2f %.2f %.2f). origin: (%.2f %.2f %.2f). normal: (%.2f %.2f %.2f)", entity, modelname, position[0], position[1], position[2], origin[0], origin[1], origin[2], normal[0], normal[1], normal[2]);
    }
    else {
        PrintToChat(client, "No ladder selected.");
    }
    return Plugin_Handled;
}

Action Command_Info(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    char classname[MAX_STR_LEN];
    int entity = GetClientAimTarget(client, false);
    if (IsValidEntity(entity)) {
        GetEntityClassname(entity, classname, MAX_STR_LEN);
        if (StrEqual(classname, "func_simpleladder", false)) {
            char modelname[128];
            float origin[3], position[3], normal[3], angles[3];
            int team;
            GetLadderEntityInfo(entity, modelname, sizeof(modelname), origin, position, normal, angles, team);

            PrintToChat(client, "Ladder entity %i, %s at (%.2f %.2f %.2f). origin: (%.2f %.2f %.2f). normal: (%.2f %.2f %.2f). angles: (%.2f %.2f %.2f)", entity, modelname, position[0], position[1], position[2], origin[0], origin[1], origin[2], normal[0], normal[1], normal[2], angles[0], angles[1], angles[2]);

            char Info[1024];
            Format(Info, 1024, "add:");
            Format(Info, 1024, "%s\n{", Info);
            Format(Info, 1024, "%s\n    \"classname\" \"func_simpleladder\"", Info);
            Format(Info, 1024, "%s\n    \"origin\" \"%.2f %.2f %.2f\"", Info, origin[0], origin[1], origin[2]);
            Format(Info, 1024, "%s\n    \"angles\" \"%.2f %.2f %.2f\"", Info, angles[0], angles[1], angles[2]);
            Format(Info, 1024, "%s\n    \"model\" \"%s\"        ", Info, modelname);
            Format(Info, 1024, "%s\n    \"normal.x\" \"%.2f\"", Info,  normal[0]);
            Format(Info, 1024, "%s\n    \"normal.y\" \"%.2f\"", Info,  normal[1]);
            Format(Info, 1024, "%s\n    \"normal.z\" \"%.2f\"", Info,  normal[2]);
            if(team == 0) Format(Info, 1024, "%s\n    \"team\" \"0\"", Info);
            else if(team == 2) Format(Info, 1024, "%s\n    \"team\" \"1\"", Info);
            else if(team == 3) Format(Info, 1024, "%s\n    \"team\" \"2\"", Info);
            Format(Info, 1024, "%s\n}", Info);

            PrintToConsole(client, Info);

            Format(Info, 1024, "\nTo create a new ladder, copy the code above and paste to %s/maps/%s.cfg", g_sCvar_stripper_cfg_path, g_sCurrentMap);
            PrintToConsole(client, Info);

            CPrintToChat(client, "To create a new ladder, copy the console output and paste to {green}%s/maps/%s.cfg", g_sCvar_stripper_cfg_path, g_sCurrentMap);
        }
        else {
            PrintToChat(client, "Not looking at a ladder. Entity %i, classname: %s", entity, classname);
        }
    }
    else {
        PrintToChat(client, "Looking at invalid entity %i", entity);
    }
    return Plugin_Handled;
}

Action Command_ToggleHud(int client, int args) 
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    bHudActive[client] = !bHudActive[client];
    CPrintToChat(client, "<{olive}HUD{default}> Ladder Editor HUD is now %s.", (bHudActive[client] ? "{blue}on{default}" : "{red}off{default}"));

    return Plugin_Continue;
}

Action Command_Team(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    if (args < 1)
    {
        PrintToChat(client, "Using: sm_team <team num> - 0: Any team, 1: Survivor, 2: Infected");
        return Plugin_Handled;
    }

    char buf[4];
    GetCmdArg(1, buf, sizeof buf);
    int newteam = StringToInt(buf);
    
    char classname[MAX_STR_LEN];
    int entity = GetClientAimTarget(client, false);
    if (IsValidEntity(entity)) {
        GetEntityClassname(entity, classname, MAX_STR_LEN);
        if (StrEqual(classname, "func_simpleladder", false)) {
            int team;
            char modelname[128];
            float origin[3], position[3], normal[3], angles[3];
            GetLadderEntityInfo(entity, modelname, sizeof(modelname), origin, position, normal, angles, team);
            if(newteam == 0) newteam = 0;
            else if(newteam == 1) newteam = 2;
            else if(newteam == 2) newteam = 3;
            else
            {
                PrintToChat(client, "Using: sm_team <team num> - 0: Any team, 1: Survivor, 2: Infected");
                return Plugin_Handled;
            }

            SetEntProp(entity, Prop_Send, "m_iTeamNum", newteam);
            PrintToChat(client, "Ladder entity %i, %s at (%.2f,%.2f,%.2f). Team changed: %s => %s", entity, modelname, position[0], position[1], position[2], g_sTeamNum[team], g_sTeamNum[newteam]);
            
        }
        else {
            selectedLadder[client] = -1;
            PrintToChat(client, "Not looking at a ladder. Entity %i, classname: %s", entity, classname);
        }
    }
    else {
        selectedLadder[client] = -1;
        PrintToChat(client, "Looking at invalid entity %i", entity);
    }
    return Plugin_Handled;
}

Action Command_FindLadderByModel(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    if (args < 1 || args > 1)
    {
        ReplyToCommand(client, "[TS] Usage: sm_flbm <model_name> - Find func_simpleladder by model");
        return Plugin_Handled;	
    }

    char model_name[64];
    GetCmdArg(1, model_name, sizeof(model_name));

    int entity = MaxClients + 1;
    char modelname[128];
    int count = 1;
    bool bFound= false;
    while((entity = FindEntityByClassname(entity, "func_simpleladder")) != -1)
    {
        if (!IsValidEntity(entity))
            continue;	

        GetEntPropString(entity, Prop_Data, "m_ModelName", modelname, sizeof(modelname));

        if(strcmp(model_name, modelname, false) == 0)
        {
            float origin[3], position[3], normal[3], angles[3];
            int team;
            GetLadderEntityInfo(entity, modelname, sizeof(modelname), origin, position, normal, angles, team);
            PrintToChat(client, "Found ladder(%d) by model - entity %i, %s at %.2f %.2f %.2f. origin: (%.2f %.2f %.2f). normal: (%.2f %.2f %.2f)", count++, entity, modelname, position[0], position[1], position[2], origin[0], origin[1], origin[2], normal[0], normal[1], normal[2]);
            if(!bFound) TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
            bFound = true;
            //return Plugin_Handled;
        }
    }

    if(!bFound) PrintToChat(client, "ladder is not found, model_name: %s", model_name);

    return Plugin_Handled;
}

Action Command_FindLadderByHammerId(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    if (args < 1 || args > 1)
    {
        ReplyToCommand(client, "[TS] Usage: sm_flbh <hammerid> - Find func_simpleladder by hammerid");
        return Plugin_Handled;	
    }

    char ArgHammerID[64];
    GetCmdArg(1, ArgHammerID, sizeof(ArgHammerID));
    int iArgHammerID = StringToInt(ArgHammerID);

    int entity = MaxClients + 1;
    int iHammerID;
    char modelname[128];
    while((entity = FindEntityByClassname(entity, "func_simpleladder")) != -1)
    {
        if (!IsValidEntity(entity))
            continue;	

        iHammerID = Entity_GetHammerId(entity);

        if(iHammerID == iArgHammerID)
        {
            float origin[3], position[3], normal[3], angles[3];
            int team;
            GetLadderEntityInfo(entity, modelname, sizeof(modelname), origin, position, normal, angles, team);
            PrintToChat(client, "Found ladder by hammerid - entity %i, %s at (%.2f %.2f %.2f). origin: (%.2f %.2f %.2f). normal: (%.2f %.2f %.2f)", entity, modelname, position[0], position[1], position[2], origin[0], origin[1], origin[2], normal[0], normal[1], normal[2]);
            TeleportEntity(client, position, NULL_VECTOR, NULL_VECTOR);
            return Plugin_Handled;
        }
    }

    PrintToChat(client, "ladder is not found, hammerid: %s", ArgHammerID);

    return Plugin_Handled;
}

Action Command_ChangeLadderNormal(int client, int args)
{
    if(!g_bCvarEnable) return Plugin_Handled;

    if(client == 0) return Plugin_Handled;

    if (args != 3 && args != 1) {
        PrintToChat(client, "[TS] Usage: sm_cln <x> <y> <z> | sm_cln <1~6>");
        return Plugin_Handled;
    }

    if(args == 1)
    {
        char type[4];
        GetCmdArg(1, type, sizeof(type));
        int itype = StringToInt(type);
        switch(itype)
        {
            case 1: ChangeLadderNormal(client, 1.0, 0.0, 0.0, true);
            case 2: ChangeLadderNormal(client, -1.0, 0.0, 0.0, true);
            case 3: ChangeLadderNormal(client, 0.0, 1.0, 0.0, true);
            case 4: ChangeLadderNormal(client, 0.0, -1.0, 0.0, true);
            case 5: ChangeLadderNormal(client, 0.0, 0.0, 1.0, true);
            case 6: ChangeLadderNormal(client, 0.0, 0.0, -1.0, true);
        }
    }

    if(args == 3)
    {
        char x[4], y[4], z[4];
        GetCmdArg(1, x, sizeof(x));
        GetCmdArg(2, y, sizeof(y));
        GetCmdArg(3, z, sizeof(z));

        ChangeLadderNormal(client, StringToFloat(x), StringToFloat(y), StringToFloat(z), true);
    }

    return Plugin_Handled;
}

// Event-------------------------------

void PlayerTeam_Event(Handle event, const char[] nam, bool dontBroadcast)
{
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    int team = GetEventInt(event, "team");
    if (team != TEAM_INFECTED && bEditMode[client]) {
        bEditMode[client] = false;
        PrintToChat(client, "Exiting edit mode.");
    }
}

// ====================================================================================================
// KEYBINDS
// ====================================================================================================
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
    if (!g_bCvarEnable) return Plugin_Continue;
    if (!IsClientInGame(client)) return Plugin_Continue;
    if (IsFakeClient(client)) return Plugin_Continue;

    if(g_bCvarTab)
    {
        // Player was holding tab, and now isn't. (Released)
        if (buttons & IN_SCORE != IN_SCORE && in_score[client]) {
            in_score[client] = false;
            Command_Edit(client, 0);
        }
        // Player was not holding tab, and now is. (Pressed)
        if (buttons & IN_SCORE == IN_SCORE && !in_score[client]) {
            in_score[client] = true;
        }
    }

    if (!bEditMode[client]) return Plugin_Continue;

    int prevButtons = buttons;

    // Player was holding m1, and now isn't. (Released)
    if (buttons & IN_ATTACK != IN_ATTACK && in_attack[client]) {
        in_attack[client] = false;
        Command_Select(client, 0);
    }
    // Player was not holding m1, and now is. (Pressed)
    if (buttons & IN_ATTACK == IN_ATTACK && !in_attack[client]) {
        in_attack[client] = true;
    }

    // Player was holding m2, and now isn't. (Released)
    if (buttons & IN_ATTACK2 != IN_ATTACK2 && in_attack2[client]) {
        in_attack2[client] = false;
        float end[3];
        if (GetEndPosition(client, end))
            Move(client, end[0], end[1], end[2], true);
        else
            PrintToChat(client, "Invalid end position.");
    }
    // Player was not holding m2, and now is. (Pressed)
    if (buttons & IN_ATTACK2 == IN_ATTACK2 && !in_attack2[client]) {
        in_attack2[client] = true;
    }
	
    // Player was holding middle mouse, and now isn't. (Released)
    if (buttons & IN_ZOOM != IN_ZOOM && in_zoom[client]) {
        in_zoom[client] = false;
        Command_Clone(client, 0);
    }
    // Player was not holding middle mouse, and now is. (Pressed)
    if (buttons & IN_ZOOM == IN_ZOOM && !in_zoom[client]) {
        in_zoom[client] = true;
    }
    

    // Player was holding shift, and now isn't. (Released)
    if (buttons & IN_SPEED != IN_SPEED && in_speed[client]) {
        in_speed[client] = false;
        RotateStep(client);
    }
    // Player was not holding shift, and now is. (Pressed)
    if (buttons & IN_SPEED == IN_SPEED && !in_speed[client]) {
        in_speed[client] = true;
    }

    if (buttons & IN_MOVELEFT == IN_MOVELEFT) {
        Nudge(client, -stepSize[client], 0.0, 0.0, false);
    }
    if (buttons & IN_MOVERIGHT == IN_MOVERIGHT) {
        Nudge(client, stepSize[client], 0.0, 0.0, false);
    }
    if (buttons & IN_FORWARD == IN_FORWARD) {
        Nudge(client, 0.0, stepSize[client], 0.0, false);
    }
    if (buttons & IN_BACK == IN_BACK) {
        Nudge(client, 0.0, -stepSize[client], 0.0, false);
    }
    if (buttons & IN_USE == IN_USE) {
        Nudge(client, 0.0, 0.0, stepSize[client], false);
    }
    if (buttons & IN_RELOAD == IN_RELOAD) {
        Nudge(client, 0.0, 0.0, -stepSize[client], false);
    }

    buttons &= ~(IN_ATTACK | IN_ATTACK2 | IN_SCORE | IN_USE | IN_RELOAD);

    if (prevButtons != buttons) {
        return Plugin_Changed;
    }
    return Plugin_Continue;
}

// Timer & Frame-------------------------------

Action HudDrawTimer(Handle hTimer) 
{
    if(!g_bCvarEnable) return Plugin_Continue;

    for (int i = 1; i <= MaxClients; i++) 
    {
        if (!bHudActive[i] || IsFakeClient(i))
            continue;

        Panel hud = new Panel();
        FillHudInfo(i, hud);
        hud.Send(i, DummyHudHandler, 3);
        delete hud;

        if (!bHudHintShown[i])
        {
            bHudHintShown[i] = true;
            CPrintToChat(i, "<{olive}HUD{default}> Type {green}!togglehud{default} into chat to toggle the {blue}Ladder Editor HUD{default}.");
        }
    }

    return Plugin_Continue;
}

// Panel-------------------------------

void FillHudInfo(int client, Handle hHud)
{
    DrawPanelText(hHud, "Ladder Editor HUD");
    char buffer[512];
    Format(buffer, sizeof(buffer), "Edit Mode: %s", (bEditMode[client] ? "On" : "Off"));
    DrawPanelText(hHud, buffer);
    DrawPanelText(hHud, " ");
    int entity = selectedLadder[client];
    if (!IsValidEntity(entity)) {
        Format(buffer, sizeof(buffer), "No ladder selected.");
        DrawPanelText(hHud, buffer);
        return;
    }

    char modelname[128];
    float origin[3], position[3], normal[3], angles[3];
    int team;
    GetLadderEntityInfo(entity, modelname, sizeof(modelname), origin, position, normal, angles, team);

    int iHammerID = Entity_GetHammerId(entity);

    Format(buffer, sizeof(buffer), "Entity: %i (HammerID: %d)", entity, iHammerID);
    DrawPanelText(hHud, buffer);
    Format(buffer, sizeof(buffer), "Model Name: %s", modelname);
    DrawPanelText(hHud, buffer);
    Format(buffer, sizeof(buffer), "Position: %.2f, %.2f, %.2f", position[0], position[1], position[2]);
    DrawPanelText(hHud, buffer);
    Format(buffer, sizeof(buffer), "Origin: %.2f, %.2f, %.2f", origin[0], origin[1], origin[2]);
    DrawPanelText(hHud, buffer);
    Format(buffer, sizeof(buffer), "Normal: %.2f, %.2f, %.2f", normal[0], normal[1], normal[2]);
    DrawPanelText(hHud, buffer);
    Format(buffer, sizeof(buffer), "Angles: %.2f, %.2f, %.2f", angles[0], angles[1], angles[2]);
    DrawPanelText(hHud, buffer);
    Format(buffer, sizeof(buffer), "Team: %s", g_sTeamNum[team]);
    DrawPanelText(hHud, buffer);
}

int DummyHudHandler(Handle hMenu, MenuAction action, int param1, int param2) {return 0;}

// Others-------------------------------

void GetLadderEntityInfo(int entity, char[] modelname, int modelnamelen, float origin[3], float position[3], float normal[3], float angles[3], int &team) {
    float mins[3], maxs[3];
    GetEntPropString(entity, Prop_Data, "m_ModelName", modelname, modelnamelen);
    GetEntPropVector(entity, Prop_Send, "m_vecOrigin", origin);
    GetEntPropVector(entity, Prop_Send, "m_vecMins", mins);
    GetEntPropVector(entity, Prop_Send, "m_vecMaxs", maxs);
    GetEntPropVector(entity, Prop_Send, "m_climbableNormal", normal);
    GetEntPropVector(entity, Prop_Send, "m_angRotation", angles);
    team = GetEntProp(entity, Prop_Send, "m_iTeamNum");

    Math_RotateVector(mins, angles, mins);
    Math_RotateVector(maxs, angles, maxs);
    position[0] = origin[0] + (mins[0] + maxs[0]) * 0.5;
    position[1] = origin[1] + (mins[1] + maxs[1]) * 0.5;
    position[2] = origin[2] + (mins[2] + maxs[2]) * 0.5;
}

void RotateStep(int client)
{
    int entity = selectedLadder[client];
    if (IsValidEntity(entity)) {
        char modelname[128];
        float origin[3], position[3], normal[3], angles[3];
        int team;
        GetLadderEntityInfo(entity, modelname, sizeof(modelname), origin, position, normal, angles, team);
        Rotate(client, 0.0, angles[1] + 90, 0.0, true);
    }
    else {
        PrintToChat(client, "No ladder selected.");
    }
}

void Nudge(int client, float x, float y, float z, bool bPrint)
{
    int entity = selectedLadder[client];
    if (IsValidEntity(entity)) {
        float position[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
        float origin[3];
        origin[0] = position[0] + x;
        origin[1] = position[1] + y;
        origin[2] = position[2] + z;
        TeleportEntity(entity, origin, NULL_VECTOR, NULL_VECTOR);
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
        if (bPrint)
            PrintToChat(client, "Nudged ladder entity %i. Origin (%.2f %.2f %.2f)", entity, origin[0], origin[1], origin[2]);
    }
    else {
        if (bPrint)
            PrintToChat(client, "No ladder selected.");
    }
}

// from smlib https://github.com/bcserv/smlib

/**
 * Rotates a vector around its zero-point.
 * Note: As example you can rotate mins and maxs of an entity and then add its origin to mins and maxs to get its bounding box in relation to the world and its rotation.
 * When used with players use the following angle input:
 *   angles[0] = 0.0;
 *   angles[1] = 0.0;
 *   angles[2] = playerEyeAngles[1];
 *
 * @param vec 			Vector to rotate.
 * @param angles 		How to rotate the vector.
 * @param result		Output vector.
 * @noreturn
 */
void Math_RotateVector(const float vec[3], const float angles[3], float result[3])
{
    // First the angle/radiant calculations
    float rad[3];
    // I don't really know why, but the alpha, beta, gamma order of the angles are messed up...
    // 2 = xAxis
    // 0 = yAxis
    // 1 = zAxis
    rad[0] = DegToRad(angles[2]);
    rad[1] = DegToRad(angles[0]);
    rad[2] = DegToRad(angles[1]);

    // Pre-calc function calls
    float cosAlpha = Cosine(rad[0]);
    float sinAlpha = Sine(rad[0]);
    float cosBeta = Cosine(rad[1]);
    float sinBeta = Sine(rad[1]);
    float cosGamma = Cosine(rad[2]);
    float sinGamma = Sine(rad[2]);

    // 3D rotation matrix for more information: http://en.wikipedia.org/wiki/Rotation_matrix#In_three_dimensions
    float x = vec[0], y = vec[1], z = vec[2];
    float newX, newY, newZ;
    newY = cosAlpha*y - sinAlpha*z;
    newZ = cosAlpha*z + sinAlpha*y;
    y = newY;
    z = newZ;

    newX = cosBeta*x + sinBeta*z;
    newZ = cosBeta*z - sinBeta*x;
    x = newX;
    z = newZ;

    newX = cosGamma*x - sinGamma*y;
    newY = cosGamma*y + sinGamma*x;
    x = newX;
    y = newY;

    // Store everything...
    result[0] = x;
    result[1] = y;
    result[2] = z;
}

bool GetEndPosition(int client, float end[3])
{
    float start[3], angle[3];
    GetClientEyePosition(client, start);
    GetClientEyeAngles(client, angle);
    TR_TraceRayFilter(start, angle, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer, client);
    if (TR_DidHit(INVALID_HANDLE))
    {
        TR_GetEndPosition(end, INVALID_HANDLE);
        return true;
    }
    return false;
}

bool TraceEntityFilterPlayer(int entity, int contentsMask, any data)
{
    return entity > MaxClients;
}

void ChangeLadderNormal(int client, float x, float y, float z, bool bPrint)
{
    int entity = selectedLadder[client];
    if (entity <= MaxClients || !IsValidEntity(entity)) {
        entity = GetClientAimTarget(client, false);
    }

    if (entity > MaxClients && IsValidEntity(entity)) {
        char classname[MAX_STR_LEN];
        GetEntityClassname(entity, classname, MAX_STR_LEN);
        if (StrEqual(classname, "func_simpleladder", false)) {

            float normal[3];
            normal[0] = x;
            normal[1] = y;
            normal[2] = z;

            SetEntPropVector(entity, Prop_Send, "m_climbableNormal", normal);
            
            char modelname[128];
            float origin[3], position[3], angles[3];
            int team;
            GetLadderEntityInfo(entity, modelname, sizeof(modelname), origin, position, normal, angles, team);

            if (bPrint)
                PrintToChat(client, "Change ladder normal entity %i, %s. \nnormal.x: %.2f,\nnormal.y: %.2f,\nnormal.z: %.2f", entity, modelname, normal[0], normal[1], normal[2]);

            char Info[1024];
            Format(Info, 1024, "modify:");
            Format(Info, 1024, "%s\n{", Info);
            Format(Info, 1024, "%s\n    match:", Info);
            Format(Info, 1024, "%s\n    {", Info);
            Format(Info, 1024, "%s\n        \"model\" \"%s\"        ", Info, modelname);
            Format(Info, 1024, "%s\n    }", Info);
            Format(Info, 1024, "%s\n    replace:", Info);
            Format(Info, 1024, "%s\n    {", Info);
            Format(Info, 1024, "%s\n        \"normal.x\" \"%.2f\"", Info,  normal[0]);
            Format(Info, 1024, "%s\n        \"normal.y\" \"%.2f\"", Info,  normal[1]);
            Format(Info, 1024, "%s\n        \"normal.z\" \"%.2f\"", Info,  normal[2]);
            Format(Info, 1024, "%s\n    }", Info);
            Format(Info, 1024, "%s\n}", Info);

            PrintToConsole(client, Info);

            return;
        }
    }

    if (bPrint)
        PrintToChat(client, "No ladder selected.");
}

int Entity_GetHammerId(int entity)
{
	return GetEntProp(entity, Prop_Data, "m_iHammerID");
}

void SetClientFrozen(int client, int freeze)
{
    SetEntityMoveType(client, freeze ? MOVETYPE_NONE : MOVETYPE_WALK);
}

void Rotate(int client, float x, float y, float z, bool bPrint)
{
    int entity = selectedLadder[client];
    if (IsValidEntity(entity)) {
        int sourceEnt;
        char key[8];
        IntToString(entity, key, 8);
        if (!GetTrieValue(hLadders, key, sourceEnt)) {
            if (bPrint)
                PrintToChat(client, "Original ladder not found.");
            return;
        }
        
        char modelname[128];
        float sourceOrigin[3], sourcePos[3], sourceNormal[3], sourceAngles[3];
        int team;
        GetLadderEntityInfo(sourceEnt, modelname, sizeof(modelname), sourceOrigin, sourcePos, sourceNormal, sourceAngles, team);
        if (bPrint)
            PrintToChat(client, "Original ladder entity %i at (%.2f %.2f %.2f)", sourceEnt, sourcePos[0], sourcePos[1], sourcePos[2]);
        
        float origin[3], position[3], normal[3],  angles[3];
        GetLadderEntityInfo(entity, modelname, sizeof(modelname), origin, position, normal, angles, team);
        
        angles[0] = x;
        angles[1] = y;
        angles[2] = z;
        
        float rotatedPos[3];
        Math_RotateVector(sourcePos, angles, rotatedPos);
        
        origin[0] = -rotatedPos[0] + position[0];
        origin[1] = -rotatedPos[1] + position[1];
        origin[2] = -rotatedPos[2] + position[2];
    
        TeleportEntity(entity, origin, angles, NULL_VECTOR);
        
        Math_RotateVector(sourceNormal, angles, normal);
        SetEntPropVector(entity, Prop_Send, "m_climbableNormal", normal);
        
        if (bPrint)
            PrintToChat(client, "Rotated ladder entity %i. Origin (%.2f %.2f %.2f). Angles (%.2f %.2f %.2f). Normal (%.2f %.2f %.2f)", entity, origin[0], origin[1], origin[2], angles[0], angles[1], angles[2], normal[0], normal[1], normal[2]);
    }
    else {
        if (bPrint)
            PrintToChat(client, "No ladder selected.");
    }
}

void Move(int client, float x, float y, float z, bool bPrint)
{
    int entity = selectedLadder[client];
    if (IsValidEntity(entity)) {
        int sourceEnt;
        char key[8];
        IntToString(entity, key, 8);
        if (!GetTrieValue(hLadders, key, sourceEnt)) {
            if (bPrint)
                PrintToChat(client, "Original ladder not found.");
            return;
        }
        
        char modelname[128];
        float origin[3], sourcePos[3], normal[3], angles[3];
        int team;
        GetLadderEntityInfo(sourceEnt, modelname, sizeof(modelname), origin, sourcePos, normal, angles, team);

        if (bPrint)
            PrintToChat(client, "Original ladder entity %i at (%.2f %.2f %.2f)", sourceEnt, sourcePos[0], sourcePos[1], sourcePos[2]);
        
        origin[0] = x - sourcePos[0];
        origin[1] = y - sourcePos[1];
        origin[2] = z - sourcePos[2];
    
        TeleportEntity(entity, origin, NULL_VECTOR, NULL_VECTOR);
        if (bPrint)
            PrintToChat(client, "Moved ladder entity %i. Origin (%.2f %.2f %.2f)", entity, origin[0], origin[1], origin[2]);
    }
    else {
        if (bPrint)
            PrintToChat(client, "No ladder selected.");
    }
}

bool TraceRayFilter(int entity, int contentsMask, int client)
{
    if(entity == client) // Check if the TraceRay hit the itself.
    {
        return false; // Don't let the entity be hit
    }

    if (entity > MaxClients && IsValidEntity(entity))
    {
        static char class[256];
        GetEntityClassname(entity, class, sizeof(class));
        if(strcmp(class,"func_simpleladder") == 0)
        {
            return true;
        }
    }

    return false;
}