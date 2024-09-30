#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <builtinvotes>
#define PLUGIN_VERSION          "1.2h-2024/9/30"
#define PLUGIN_NAME			    "l4d2_vote_manager3"

public Plugin myinfo =
{
    name = "[L4D1/2] Vote Manager Remake",
    author = "McFlurry, Harry",
    description = "Unable to call valve vote if player does not have access",
    version = PLUGIN_VERSION,
    url = "https://steamcommunity.com/profiles/76561198026784913/"
}

bool g_bL4D2Version;
int ZC_Tank;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test == Engine_Left4Dead )
    {
        ZC_Tank = 5;
        g_bL4D2Version = false;
    }
    else if( test == Engine_Left4Dead2 )
    {
        ZC_Tank = 8;
        g_bL4D2Version = true;
    }
    else
    {
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 1 & 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

#define MSGTAG "{green}[VoteManager]{default}"

#define TRANSLATION_FILE		PLUGIN_NAME ... ".phrases"
#define CVAR_FLAGS FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define VOTE_NONE 0
#define VOTE_POLLING 1

char votes[][] =
{
    "veto",
    "pass",
    "cooldown_immunity",
    "notify",
    "returntolobby",
    "restartgame",
    "changedifficulty",
    "changemission",
    "changechapter",
    "changealltalk",
    "kick",
    "kick_immunity"
};

char filepath[PLATFORM_MAX_PATH];

ConVar hCreationTimer;
int initVal;

ConVar g_hCvarCooldownMode, g_hCvarVoteCooldown, g_hCvarTankImmunity, g_hCvarRespectImmunity, g_hCvarLog,
    g_hCvarVetoFlag, g_hCvarPassFlag, g_hCvarCDImmunityFlag, g_hCvarNotifyFlag, 
    g_hCvarReturnLobbyFlag, g_hCvarRestartGameFlag, g_hCvarChangeDifficultyFlag, g_hCvarChangeMissionFlag, g_hCvarChangeChapterFlag,
    g_hCvarChangeAllTalkFlag, g_hCvarKickPlayerFlag, g_hCvarKickImmunityFlag;
int g_iCvarCooldownMode, g_iCvarLog;
float g_fCvarVoteCooldown;
bool g_bCvarTankImmunity, g_bCvarRespectImmunity;
char g_sCvarVetoFlag[AdminFlags_TOTAL], g_sCvarPassFlag[AdminFlags_TOTAL], g_sCvarCDImmunityFlag[AdminFlags_TOTAL], g_sCvarNotifyFlag[AdminFlags_TOTAL], 
    g_sCvarReturnLobbyFlag[AdminFlags_TOTAL], g_sCvarRestartGameFlag[AdminFlags_TOTAL], g_sCvarChangeDifficultyFlag[AdminFlags_TOTAL], g_sCvarChangeMissionFlag[AdminFlags_TOTAL], g_sCvarChangeChapterFlag[AdminFlags_TOTAL],
    g_sCvarChangeAllTalkFlag[AdminFlags_TOTAL], g_sCvarKickPlayerFlag[AdminFlags_TOTAL], g_sCvarKickImmunityFlag[AdminFlags_TOTAL];

int VoteStatus;
char sCaller[32];
char sIssue[128];
char sOption[128];
char sCmd[192];

enum VoteManager_Vote
{
    Voted_No = 0,
    Voted_Yes,
    Voted_CantVote,
    Voted_CanVote
};

VoteManager_Vote iVote[MAXPLAYERS + 1] = { Voted_CantVote, ... };
float iNextVote[MAXPLAYERS + 1];
float flLastVote;

public void OnPluginStart()
{
    LoadTranslations(TRANSLATION_FILE);

    hCreationTimer = FindConVar("sv_vote_creation_timer");
    initVal = hCreationTimer.IntValue;
    hCreationTimer.AddChangeHook(TimerChanged);

    g_hCvarCooldownMode             = CreateConVar( PLUGIN_NAME ... "_cooldown_mode",             "0",    "0=Cooldown is shared 1=Cooldown is independant", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarVoteCooldown             = CreateConVar( PLUGIN_NAME ... "_cooldown",                  "60.0", "Clients can call votes again after this many seconds", CVAR_FLAGS, true, 0.0);
    g_hCvarTankImmunity             = CreateConVar( PLUGIN_NAME ... "_tank_immunity",             "0",    "Tanks have immunity against kick votes", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarRespectImmunity          = CreateConVar( PLUGIN_NAME ... "_respect_immunity",          "1",    "Respect admin immunity levels in kick votes (Only work when admin tries to kick admin)", CVAR_FLAGS, true, 0.0, true, 1.0);
    g_hCvarLog                      = CreateConVar( PLUGIN_NAME ... "_log",                       "3",    "1=Log vote info to files 2=Log vote info to server; 3=Both", CVAR_FLAGS, true, 0.0, true, 3.0);
    
    g_hCvarVetoFlag                 = CreateConVar( PLUGIN_NAME ... "_veto_flag",                 "z",    "Players with these flags can use !veto to force veto the current vote (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hCvarPassFlag                 = CreateConVar( PLUGIN_NAME ... "_pass_flag",                 "z",    "Players with these flags can use !pass to forece pass the current vote (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hCvarCDImmunityFlag           = CreateConVar( PLUGIN_NAME ... "_cooldown_immunity_flag",    "-1",   "Players with these flags can ignore Cooldown and start the new vote (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hCvarNotifyFlag               = CreateConVar( PLUGIN_NAME ... "_notify_flag",               "",     "Players with these flags can see the chatbox notify (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hCvarReturnLobbyFlag          = CreateConVar( PLUGIN_NAME ... "_returntolobby_flag",        "z",    "Players with these flags can call a vote \"Return To Lobby\" from ESC (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hCvarRestartGameFlag          = CreateConVar( PLUGIN_NAME ... "_restartgame_flag",          "z",    "Players with these flags can call a vote \"Restart Chapter/Restart Campaign\" from ESC (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hCvarChangeDifficultyFlag     = CreateConVar( PLUGIN_NAME ... "_changedifficulty_flag",     "z",    "Players with these flags can call a vote \"Change Diffciulty\" from ESC (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hCvarChangeMissionFlag        = CreateConVar( PLUGIN_NAME ... "_changemission_flag",        "z",    "Players with these flags can call a vote \"Start New Campaign\" from ESC (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hCvarChangeChapterFlag        = CreateConVar( PLUGIN_NAME ... "_changechapter_flag",        "z",    "Players with these flags can call a vote \"Change Chapter\" from ESC (Empty = Everyone, -1: Nobody)\nDoesn't work, It is blocked by default", CVAR_FLAGS);
    g_hCvarChangeAllTalkFlag        = CreateConVar( PLUGIN_NAME ... "_changealltalk_flag",        "z",    "Players with these flags can call a vote \"Change All Talk\" from ESC (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hCvarKickPlayerFlag           = CreateConVar( PLUGIN_NAME ... "_kick_flag",                 "z",    "Players with these flags can call a vote \"Kick Player\" from ESC (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);
    g_hCvarKickImmunityFlag         = CreateConVar( PLUGIN_NAME ... "_kick_immunity_flag",        "z",    "Players with these flags are immune to be kicked (Empty = Everyone, -1: Nobody)", CVAR_FLAGS);

    CreateConVar(                                   PLUGIN_NAME ... "_version",          PLUGIN_VERSION,   PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                            PLUGIN_NAME);

    GetCvars();
    g_hCvarCooldownMode.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarVoteCooldown.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarTankImmunity.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarRespectImmunity.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarLog.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarVetoFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarPassFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarCDImmunityFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarNotifyFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarReturnLobbyFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarRestartGameFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarChangeDifficultyFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarChangeMissionFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarChangeChapterFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarChangeAllTalkFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarKickPlayerFlag.AddChangeHook(ConVarChanged_Cvars);
    g_hCvarKickImmunityFlag.AddChangeHook(ConVarChanged_Cvars);

    if(g_bL4D2Version)
    {
        HookUserMessage(GetUserMessageId("VotePass"), VotePass);
        HookUserMessage(GetUserMessageId("VoteFail"), VoteFail);
    }

    AddCommandListener(VoteStart, "callvote");
    AddCommandListener(VoteAction, "vote");
    RegConsoleCmd("sm_pass", Command_VotePassvote, "Force pass a current vote");
    RegConsoleCmd("sm_veto", Command_VoteVeto, "Force veto a current vote");

    BuildPath(Path_SM, filepath, sizeof(filepath), "logs/" ... PLUGIN_NAME ... ".log");
}

//Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_iCvarCooldownMode = g_hCvarCooldownMode.IntValue;
    g_fCvarVoteCooldown = g_hCvarVoteCooldown.FloatValue;
    g_bCvarTankImmunity = g_hCvarTankImmunity.BoolValue;
    g_bCvarRespectImmunity = g_hCvarRespectImmunity.BoolValue;
    g_iCvarLog = g_hCvarLog.IntValue;

    g_hCvarVetoFlag.GetString(g_sCvarVetoFlag, sizeof g_sCvarVetoFlag);
    g_hCvarPassFlag.GetString(g_sCvarPassFlag, sizeof g_sCvarPassFlag);
    g_hCvarCDImmunityFlag.GetString(g_sCvarCDImmunityFlag, sizeof g_sCvarCDImmunityFlag);
    g_hCvarNotifyFlag.GetString(g_sCvarNotifyFlag, sizeof g_sCvarNotifyFlag);
    g_hCvarReturnLobbyFlag.GetString(g_sCvarReturnLobbyFlag, sizeof g_sCvarReturnLobbyFlag);
    g_hCvarRestartGameFlag.GetString(g_sCvarRestartGameFlag, sizeof g_sCvarRestartGameFlag);
    g_hCvarChangeDifficultyFlag.GetString(g_sCvarChangeDifficultyFlag, sizeof g_sCvarChangeDifficultyFlag);
    g_hCvarChangeMissionFlag.GetString(g_sCvarChangeMissionFlag, sizeof g_sCvarChangeMissionFlag);
    g_hCvarChangeChapterFlag.GetString(g_sCvarChangeChapterFlag, sizeof g_sCvarChangeChapterFlag);
    g_hCvarChangeAllTalkFlag.GetString(g_sCvarChangeAllTalkFlag, sizeof g_sCvarChangeAllTalkFlag);
    g_hCvarKickPlayerFlag.GetString(g_sCvarKickPlayerFlag, sizeof g_sCvarKickPlayerFlag);
    g_hCvarKickImmunityFlag.GetString(g_sCvarKickImmunityFlag, sizeof g_sCvarKickImmunityFlag);
}

void TimerChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    hCreationTimer.SetInt(0);
}

//Sourcemod API Forward-------------------------------

public void OnMapStart()
{
    hCreationTimer.SetInt(0);
    VoteStatus = VOTE_NONE;
}

public void OnPluginEnd()
{
    hCreationTimer.SetInt(initVal);
}

public void OnClientDisconnect(int client)
{
    if(IsFakeClient(client))
    {
        return;
    }
    int userid = GetClientUserId(client);
    CreateTimer(5.0, TransitionCheck, userid);
    iVote[client] = Voted_CantVote;
}

Action VoteAction(int client, const char[] command, int argc)
{
    if(client == 0) return Plugin_Handled;

    if(argc == 1 && iVote[client] == Voted_CanVote && client != 0 && IfVoteIsInPOLLING())
    {
        char vote[5];
        GetCmdArg(1, vote, sizeof(vote));
        if(StrEqual(vote, "yes", false))
        {
            iVote[client] = Voted_Yes;
            return Plugin_Continue;
        }
        else if(StrEqual(vote, "no", false))
        {
            iVote[client] = Voted_No;
            return Plugin_Continue;
        }
    }

    return Plugin_Continue;
}

Action VoteStart(int client, const char[] command, int argc)
{
    if(GetServerClientCount(true) == 0 || client == 0 || IsFakeClient(client)) return Plugin_Continue; //prevent votes while server is empty or if server tries calling vote
    
    if(argc <= 0)
    {
        return Plugin_Continue;
    }

    if(!IsNewBuiltinVoteAllowed())
    {
        CPrintToChat(client, "%s %T", MSGTAG, "NotAllowed", client);
        return Plugin_Handled;
    }
    
    float flEngineTime = GetEngineTime();
    GetCmdArg(1, sIssue, sizeof(sIssue));
    if(argc == 2) GetCmdArg(2, sOption, sizeof(sOption));
    VoteStringsToLower();
    Format(sCaller, sizeof(sCaller), "%N", client);

    if(!IsValidVoteType(sIssue))
    {
        static char steam64[MAX_AUTHID_LENGTH];
        GetClientAuthId(client, AuthId_SteamID64, steam64, sizeof(steam64));

        LogVoteManager("%T", "Client Exploit Attempt", LANG_SERVER, client, steam64, sIssue);

        VoteLogAction(client, -1, "'%L' (Steam ID: %s) call invalid vote exploit attempted (Votetype: '%s')", client, steam64, sIssue);
        return Plugin_Continue;
    }

    if( (HasAccess(client, g_sCvarCDImmunityFlag) || iNextVote[client] <= flEngineTime) && VoteStatus == VOTE_NONE)
    {
        if(flEngineTime-flLastVote <= 5.5) //minimum time that is required by the voting system itself before another vote can be called
        {
            return Plugin_Handled;
        }

        if(ClientHasVoteAccess(client, sIssue))
        {
            if(StrEqual(sIssue, "kick", false))
            {
                return ClientCanKick(client, sOption);
            }

            DataPack hPack = new DataPack();
            hPack.WriteCell(argc);
            hPack.WriteCell(GetClientUserId(client));
            RequestFrame(NextFrame_CallVote, hPack);

            return Plugin_Continue;
        }
        else
        {
            LogVoteManager("%T", "No Vote Access", LANG_SERVER, sCaller, sIssue);
            VoteManagerNotify(client, "%s %t", MSGTAG, "No Vote Access", sCaller, sIssue);
            VoteLogAction(client, -1, "'%L' callvote denied (reason 'no access')", client);
            ClearVoteStrings();
            return Plugin_Handled;
        }
    }
    else if(IfVoteIsInPOLLING())
    {
        CPrintToChat(client, "%s %T", MSGTAG, "Conflict", client);
        VoteLogAction(client, -1, "'%L' callvote denied (reason 'vote already called')", client);
        ClearVoteStrings();
        return Plugin_Handled;
    }
    else if(iNextVote[client] > flEngineTime)
    {
        CPrintToChat(client, "%s %T", MSGTAG, "Wait", client, RoundToNearest(iNextVote[client]-flEngineTime));
        VoteLogAction(client, -1, "'%L' callvote denied (reason 'timeout')", client);
        ClearVoteStrings();
        return Plugin_Handled;
    }
    else
    {
        ClearVoteStrings();
        return Plugin_Handled;
    }
}

Action VotePass(UserMsg msg_id, BfRead bf, const int[] players, int playersNum, bool reliable, bool init)
{
    LogVoteManager("%T", "Vote Passed", LANG_SERVER);
    VoteLogAction(-1, -1, "callvote (verdict 'passed')");
    ClearVoteStrings();
    VoteStatus = VOTE_NONE;
    return Plugin_Continue;
}

Action VoteFail(UserMsg msg_id, BfRead bf, const int[] players, int playersNum, bool reliable, bool init)
{
    LogVoteManager("%T", "Vote Failed", LANG_SERVER);
    VoteLogAction(-1, -1, "callvote (verdict 'failed')");
    ClearVoteStrings();
    VoteStatus = VOTE_NONE;
    return Plugin_Continue;
}

Action Command_VoteVeto(int client, int args)
{
    if(client == 0) return Plugin_Handled;
    if(!HasAccess(client, g_sCvarVetoFlag)) return Plugin_Handled;

    if(IfVoteIsInPOLLING())
    {
        int yesvoters = VoteManagerGetVotedAll(Voted_Yes);
        int undecided = VoteManagerGetVotedAll(Voted_CanVote);
        if(undecided * 2 > yesvoters)
        {
            for(int i = 1; i <= MaxClients; i++)
            {
                VoteManager_Vote info = VoteManagerGetVoted(i);
                if(info == Voted_CanVote)
                {
                    VoteManagerSetVoted(i, Voted_No);
                }
            }
        }
        else
        {
            LogVoteManager("%T", "Cant VetoPass", LANG_SERVER, client);
            CPrintToChat(client, "%s %T", MSGTAG, "Cant Veto", client);
            VoteLogAction(client, -1, "'%L' sm_veto ('not enough undecided players')", client);
            return Plugin_Handled;
        }
        LogVoteManager("%T", "Vetoed", LANG_SERVER, client);
        CPrintToChatAll("%s %t", MSGTAG, "Vetoed", client);
        VoteLogAction(client, -1, "'%L' sm_veto ('allowed')", client);
        VoteStatus = VOTE_NONE;

        return Plugin_Handled;
    }
    else
    {
        CPrintToChat(client, "%s %T", MSGTAG, "No Vote", client);
        VoteLogAction(client, -1, "'%L' sm_veto ('no vote')", client);

        return Plugin_Handled;
    }
}

Action Command_VotePassvote(int client, int args)
{
    if(client == 0) return Plugin_Handled;
    if(!HasAccess(client, g_sCvarPassFlag)) return Plugin_Handled;

    if(IfVoteIsInPOLLING())
    {
        int novoters = VoteManagerGetVotedAll(Voted_No);
        int undecided = VoteManagerGetVotedAll(Voted_CanVote);
        if(undecided * 2 > novoters)
        {
            for(int i = 1; i <= MaxClients; i++)
            {
                VoteManager_Vote info = VoteManagerGetVoted(i);
                if(info == Voted_CanVote)
                {
                    VoteManagerSetVoted(i, Voted_Yes);
                }
            }
        }
        else
        {
            LogVoteManager("%T", "Cant VetoPass", LANG_SERVER, client);
            CPrintToChat(client, "%s %T", MSGTAG, "Cant Pass", client);
            VoteLogAction(client, -1, "'%L' sm_veto ('not enough undecided players')", client);
            return Plugin_Handled;
        }
        LogVoteManager("%T", "Passed", LANG_SERVER, client);
        CPrintToChatAll("%s %t", MSGTAG, "Passed", client);
        VoteLogAction(client, -1, "'%L' sm_pass ('allowed')", client);
        VoteStatus = VOTE_NONE;

        return Plugin_Handled;
    }
    else
    {
        CPrintToChat(client, "%s %T", MSGTAG, "No Vote", client);
        VoteLogAction(client, -1, "'%L' sm_pass ('no vote')", client);

        return Plugin_Handled;
    }
}

Action TransitionCheck(Handle Timer, any userid)
{
    int client = GetClientOfUserId(userid);
    if(client == 0)
    {
        iNextVote[client] == 0.0;
    }
    return Plugin_Stop;
}

void NextFrame_KickVote(DataPack hPack)
{
    hPack.Reset();
    int client  = GetClientOfUserId(hPack.ReadCell());
    int target  = GetClientOfUserId(hPack.ReadCell());
    int cTeam   = hPack.ReadCell();
    delete hPack;

    if(!client || !IsClientInGame(client)) return;
    if(!target || !IsClientInGame(target)) return;
    if(!IsBuiltinVoteInProgress()) return;

    LogVoteManager("%T", "Kick Vote", LANG_SERVER, client, target);
    VoteManagerNotify(client, "%s %t", MSGTAG, "Kick Vote", client, target);
    VoteLogAction(client, -1, "'%L' callvote kick started (kickee: '%L')", client, target);
    
    VoteManagerPrepareVoters(cTeam);
    VoteManagerHandleCooldown(client);

    VoteStatus = VOTE_POLLING;
    flLastVote = GetEngineTime();
}

void NextFrame_CallVote(DataPack hPack)
{
    hPack.Reset();
    int argc    = hPack.ReadCell();
    int client  = GetClientOfUserId(hPack.ReadCell());
    delete hPack;

    if(!client || !IsClientInGame(client)) return;
    if(!IsBuiltinVoteInProgress()) return;

    if(argc == 2)
    {
        LogVoteManager("%T", "Vote Called 2 Arguments", LANG_SERVER, sCaller, sIssue, sOption);
        VoteManagerNotify(client, "%s %t", MSGTAG, "Vote Called 2 Arguments", sCaller, sIssue, sOption);
        VoteLogAction(client, -1, "'%L' callvote (issue '%s') (option '%s')", client, sIssue, sOption);
    }
    else
    {
        LogVoteManager("%T", "Vote Called", LANG_SERVER, sCaller, sIssue);
        VoteManagerNotify(client, "%s %t", MSGTAG, "Vote Called", sCaller, sIssue);
        VoteLogAction(client, -1, "'%L' callvote (issue '%s')", client, sIssue);
    }

    VoteManagerPrepareVoters(0);
    VoteManagerHandleCooldown(client);

    VoteStatus = VOTE_POLLING;
    flLastVote = GetEngineTime();
}


bool ClientHasVoteAccess(int client, const char[] vote_sIssue)
{
    if( strcmp(vote_sIssue, "returntolobby", false) == 0 )
    {
        if(HasAccess(client, g_sCvarReturnLobbyFlag)) return true;
    }
    else if( strcmp(vote_sIssue, "restartgame", false) == 0 )
    {
        if(HasAccess(client, g_sCvarRestartGameFlag)) return true;
    }
    else if( strcmp(vote_sIssue, "changedifficulty", false) == 0 )
    {
        if(HasAccess(client, g_sCvarChangeDifficultyFlag)) return true;
    }
    else if( strcmp(vote_sIssue, "changemission", false) == 0 )
    {
        if(HasAccess(client, g_sCvarChangeMissionFlag)) return true;
    }
    else if( strcmp(vote_sIssue, "changechapter", false) == 0 )
    {
        if(HasAccess(client, g_sCvarChangeChapterFlag)) return true;
    }
    else if( strcmp(vote_sIssue, "changealltalk", false) == 0 )
    {
        if(HasAccess(client, g_sCvarChangeAllTalkFlag)) return true;
    }
    else if(strcmp(vote_sIssue, "kick", false) == 0 )
    {
        if(HasAccess(client, g_sCvarKickPlayerFlag)) return true;
    }
    
    return false;
}

bool IsValidVoteType(const char[] what)
{
    for(int i = 0; i < sizeof(votes); i++)
    {
        if(StrEqual(what, votes[i]))
        {
            return true;
        }
    }
    return false;
}

Action ClientCanKick(int client, const char[] userid)
{
    if(strlen(userid) < 1 || client == 0) //empty userid/console can't call votes
    {
        ClearVoteStrings();
        return Plugin_Handled;
    }

    int target = GetClientOfUserId(StringToInt(userid));
    int cTeam = GetClientTeam(client);

    if(0 >= target || target > MaxClients || !IsClientInGame(target))
    {
        LogVoteManager("%T", "Invalid Kick Userid", LANG_SERVER, client, userid);
        VoteManagerNotify(client, "%s %t", MSGTAG, "Invalid Kick Userid", client, userid);
        VoteLogAction(client, -1, "'%L' callvote kick denied (reason: 'invalid userid<%d>')", client, StringToInt(userid));
        ClearVoteStrings();

        return Plugin_Handled;
    }

    if(g_bCvarTankImmunity && IsPlayerAlive(target) && cTeam == 3 && GetEntProp(target, Prop_Send, "m_zombieClass") == ZC_Tank)
    {
        LogVoteManager("%T", "Tank Immune Response", LANG_SERVER, client, target);
        VoteManagerNotify(client, "%s %t", MSGTAG, "Tank Immune Response", client, target);
        VoteLogAction(client, -1, "'%L' callvote kick denied (reason: '%L has tank immunity')", client, target);
        ClearVoteStrings();

        return Plugin_Handled;
    }

    if(cTeam == 1)
    {
        LogVoteManager("%T", "Spectator Response", LANG_SERVER, client, target);
        VoteManagerNotify(client, "%s %t", MSGTAG, "Spectator Response", client, target);
        VoteLogAction(client, -1, "'%L' callvote kick denied (reason: 'spectators have no kick access')", client);
        ClearVoteStrings();

        return Plugin_Handled;
    }

    AdminId id = GetUserAdmin(client);
    AdminId targetid = GetUserAdmin(target);

    if(g_bCvarRespectImmunity && id != INVALID_ADMIN_ID && targetid != INVALID_ADMIN_ID) //both targets need to be admin.
    {
        if(!CanAdminTarget(id, targetid))
        {
            LogVoteManager("%T", "Kick Vote Call Failed", LANG_SERVER, client, target);
            VoteManagerNotify(client, "%s %t", MSGTAG, "Kick Vote Call Failed", client, target);
            VoteLogAction(client, -1, "'%L' callvote kick denied (reason: '%L has higher immunity')", client, target);
            ClearVoteStrings();
            
            return Plugin_Handled;
        }
    }

    if(HasAccess(target, g_sCvarKickImmunityFlag))
    {
        LogVoteManager("%T", "Kick Immunity", LANG_SERVER, client, target);
        VoteManagerNotify(client, "%s %t", MSGTAG, "Kick Immunity", client, target);
        VoteLogAction(client, -1, "'%L' callvote kick denied (reason: '%L has kick vote immunity')", client, target);
        ClearVoteStrings();

        return Plugin_Handled;
    }

    DataPack hPack = new DataPack();
    hPack.WriteCell(GetClientUserId(client));
    hPack.WriteCell(GetClientUserId(target));
    hPack.WriteCell(cTeam);
    RequestFrame(NextFrame_KickVote, hPack);

    return Plugin_Continue;
}

void VoteManagerHandleCooldown(int client)
{
    float time = GetEngineTime();
    switch(g_iCvarCooldownMode)
    {
        case 0:
        {
            for(int i = 1; i <= MaxClients; i++)
            {
                if(IsClientInGame(i))
                {
                    iNextVote[i] = time + g_fCvarVoteCooldown;
                }
            }
            return;
        }
        case 1:
        {
            iNextVote[client] = time + g_fCvarVoteCooldown;
            return;
        }
    }
}

void VoteManagerSetVoted(int client, VoteManager_Vote vote)
{
    if(vote > Voted_Yes || client == 0)
    {
        return;
    }
    else
    {
        switch(vote)
        {
            case Voted_Yes:
            {
                FakeClientCommand(client, "Vote Yes");
            }
            case Voted_No:
            {
                FakeClientCommand(client, "Vote No");
            }
        }
        iVote[client] = vote;
    }
}

VoteManager_Vote VoteManagerGetVoted(int client)
{
    return iVote[client];
}

int VoteManagerGetVotedAll(VoteManager_Vote vote)
{
    int total;
    for(int i = 1; i <= MaxClients; i++)
    {
        if(VoteManagerGetVoted(i) == vote)
        {
            total++;
        }
    }
    return total;
}

void VoteManagerPrepareVoters(int team)
{
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && !IsFakeClient(i))
        {
            if(team == 0)
            {
                iVote[i] = Voted_CanVote;
            }
            else if(GetClientTeam(i) == team)
            {
                iVote[i] = Voted_CanVote;
            }
        }
        else
        {
            iVote[i] = Voted_CantVote;
        }
    }
}

void ClearVoteStrings()
{
    Format(sIssue, sizeof(sIssue), "");
    Format(sOption, sizeof(sOption), "");
    Format(sCaller, sizeof(sCaller), "");
    Format(sCmd, sizeof(sCmd), "");
}

void VoteStringsToLower()
{
    StringToLower(sIssue, strlen(sIssue));
    StringToLower(sOption, strlen(sOption));
}

void StringToLower(char[] string, int stringlength)
{
    int maxlength = stringlength + 1;
    char[] buffer = new char[maxlength], sChar = new char[maxlength];
    Format(buffer, maxlength, string);

    for(int i; i <= stringlength; i++)
    {
        Format(sChar, maxlength, buffer[i]);
        if(strlen(buffer[i+1]) > 0) ReplaceString(sChar, maxlength, buffer[i+1], "");
        if(IsCharUpper(sChar[0]))
        {
            sChar[0] += 0x20;
            //CharToLower(char[0]); this fails for some reason
            Format(sChar, maxlength, "%s%s", sChar, buffer[i+1]);
            ReplaceString(buffer, maxlength, sChar, sChar, false);
        }
    }
    Format(string, maxlength, buffer);
}

int GetServerClientCount(bool filterbots = false)
{
    int total;
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i))
        {
            total++;
            if(IsFakeClient(i) && filterbots) total--;
        }
    }
    return total;
}

void VoteLogAction(int client, int target, const char[] message, any ...)
{
    if(g_iCvarLog < 2) return;
    char buffer[512];
    VFormat(buffer, sizeof(buffer), message, 4);
    LogAction(client, target, buffer);
}

void VoteManagerNotify(int client, const char[] message, any ...)
{
    static char buffer[256];
    for(int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && !IsFakeClient(i))
        {
            if(HasAccess(client, g_sCvarNotifyFlag))
            {
                SetGlobalTransTarget(i);
                VFormat(buffer, sizeof(buffer), message, 3);
                CPrintToChat(i, buffer);
            }
        }
    }
}

void LogVoteManager(const char[] log, any ...)
{
    if(g_iCvarLog < 1) return;

    char buffer[256], time[64];
    FormatTime(time, sizeof(time), "%x %X");
    VFormat(buffer, sizeof(buffer), log, 2);
    Format(buffer, sizeof(buffer), "[%s] %s", time, buffer);


    File file = OpenFile(filepath, "a");
    if(file)
    {
        ReplaceString(buffer, sizeof(buffer), "{default}",		"", false);
        ReplaceString(buffer, sizeof(buffer), "{white}",		"", false);
        ReplaceString(buffer, sizeof(buffer), "{cyan}",			"", false);
        ReplaceString(buffer, sizeof(buffer), "{lightgreen}",	"", false);
        ReplaceString(buffer, sizeof(buffer), "{orange}",		"", false);
        ReplaceString(buffer, sizeof(buffer), "{green}",		"", false);
        ReplaceString(buffer, sizeof(buffer), "{olive}",		"", false);
        
        WriteFileLine(file, buffer);
        FlushFile(file);
        delete file;
    }
    else
    {
        LogError("%T", "Log Error", LANG_SERVER);
    }
}

bool IfVoteIsInPOLLING()
{
    if(VoteStatus == VOTE_NONE) return false;

    if(IsBuiltinVoteInProgress())
    {
        VoteStatus = VOTE_POLLING;
        return true;
    }
    else
    {
        VoteStatus = VOTE_NONE;
        return false;
    }
}

bool HasAccess(int client, char[] sAcclvl)
{
	// no permissions set
	if (strlen(sAcclvl) == 0)
		return true;

	else if (StrEqual(sAcclvl, "-1"))
		return false;

	// check permissions
	int flag = GetUserFlagBits(client);
	if ( flag & ReadFlagString(sAcclvl) || flag & ADMFLAG_ROOT )
	{
		return true;
	}

	return false;
}
