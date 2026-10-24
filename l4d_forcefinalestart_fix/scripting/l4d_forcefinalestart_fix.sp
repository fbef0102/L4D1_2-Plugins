#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>
#include <left4dhooks> // https://forums.alliedmods.net/showthread.php?t=321696


#define PLUGIN_NAME                   "l4d_forcefinalestart_fix"
#define PLUGIN_VERSION                "1.0-2026/10/24"

public Plugin myinfo =
{
    name        = PLUGIN_NAME,
    author      = "Harry",
    description = "Prevent finale softlocks when maps use ForceFinaleStart because not all survivors are in FINALE attribute area",
    version     = PLUGIN_VERSION,
    url         = "https://steamcommunity.com/profiles/76561198026784913/"
}

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
        strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}


#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

#define NAV_FINALE                    64

#define MAXENTITIES                   2048
ConVar g_hCvarEnable;
bool g_bCvarEnable;

bool 
    g_bIsFinalMap,
    g_bFinaleStarted;

char 
    g_sCurrentMap[64];

DynamicHook
    g_hAcceptInput;

ArrayList 
    alNavAreasWithoutFinale;

public void OnPluginStart()
{
    GameData hGameData;
    if(g_bL4D2Version)
    {
        hGameData = LoadGameConfigFile("left4dhooks.l4d2");
    }
    else
    {
        hGameData = LoadGameConfigFile("left4dhooks.l4d1");
    }
     
    int offset = hGameData.GetOffset("CBaseEntity::AcceptInput");
    delete hGameData;

    if (offset == -1)
        SetFailState("Failed to get AcceptInput offset");

    g_hAcceptInput = new DynamicHook(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity);
    g_hAcceptInput.AddParam(HookParamType_CharPtr);
    g_hAcceptInput.AddParam(HookParamType_CBaseEntity);
    g_hAcceptInput.AddParam(HookParamType_CBaseEntity);
    g_hAcceptInput.AddParam(HookParamType_Object, 20, DHookPass_ByVal|DHookPass_ODTOR|DHookPass_OCTOR|DHookPass_OASSIGNOP); //varaint_t is a union of 12 (float[3]) plus two int type params 12 + 8 = 20
    g_hAcceptInput.AddParam(HookParamType_Int);

    g_hCvarEnable 		= CreateConVar( PLUGIN_NAME ... "_enable",        "1",   "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0);
    CreateConVar(                       PLUGIN_NAME ... "_version",       PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
    AutoExecConfig(true,                PLUGIN_NAME);

    GetCvars();
    g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);

    HookEvent("round_start",			Event_RoundStart,	EventHookMode_PostNoCopy);

    alNavAreasWithoutFinale = new ArrayList();
}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarEnable = g_hCvarEnable.BoolValue;
}

// Sourcemod API Forward-------------------------------

public void OnMapStart()
{
    g_bIsFinalMap = L4D_IsMissionFinalMap(true);
    GetCurrentMap(g_sCurrentMap, sizeof(g_sCurrentMap));
}

// 部分實體會在OnMapStart之前就生成, 需等待下一偵
public void OnEntityCreated(int entity, const char[] classname)
{
    switch (classname[0])
    {
        case 't':
        {
            //trigger_finale 
            if (strcmp(classname, "trigger_finale") == 0) //late spawn
            {
                RequestFrame(OnNextFrame_trigger_finale, EntIndexToEntRef(entity));
            }
            //trigger_finale_dlc3 => classname becomes trigger_finale on SpawnPost.
            else if (!g_bL4D2Version && strcmp(classname, "trigger_finale_dlc3") == 0) //late spawn
            {
                RequestFrame(OnNextFrame_trigger_finale_dlc3, EntIndexToEntRef(entity));
            }
        }
    }
}

// Event-------------------------------

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    g_bFinaleStarted = false;
}

// Hook-------------------

void EntityOutput_OnFinaleStart(const char[] output, int caller, int activator, float delay)
{
    if(g_bFinaleStarted) return;
    g_bFinaleStarted = true;
}

// DHooks-------------------

MRESReturn Hook_AcceptInputPre_trigger_finale(int pThis, DHookReturn hReturn, DHookParam hParams)
{
    if(g_bFinaleStarted) return MRES_Ignored;

    char inputName[17];
    DHookGetParamString(hParams, 1, inputName, sizeof(inputName));

    if (StrEqual(inputName, "ForceFinaleStart"))
    {
        SetAllNavAreasFinale();
        RequestFrame(Frame_RestoreNavAreas); // Just for safety in case another plugin blocks the input
    }

    // Use 如果activator不是玩家會無視地圖的final nav強制開始救援
    if (StrEqual(inputName, "Use"))
    {
        int activator = -1;
        if (!hParams.IsNull(2))
        {
            activator = hParams.Get(2);
            if (IsValidClient(activator))
            {
                return MRES_Ignored;
            }
        }
            
        //SetAllNavAreasFinale();
        //RequestFrame(Frame_RestoreNavAreas); // Just for safety in case another plugin blocks the input
    }

    return MRES_Ignored;
}

MRESReturn Hook_AcceptInputPost_trigger_finale(int pThis, DHookReturn hReturn, DHookParam hParams)
{
    char inputName[17];
    DHookGetParamString(hParams, 1, inputName, sizeof(inputName));

    if (StrEqual(inputName, "ForceFinaleStart"))
        RestoreNavAreas();

    if (StrEqual(inputName, "Use"))
    {
        int activator = -1;
        if (!hParams.IsNull(2))
        {
            activator = hParams.Get(2);
            if (IsValidClient(activator))
            {
                return MRES_Ignored;
            }
        }
            
        //RestoreNavAreas();
    }

    return MRES_Ignored;
}

// Timer & Frame------------------------

void OnNextFrame_trigger_finale(int entityRef)
{
    if(g_bCvarEnable == false || !g_bIsFinalMap) return;
    
    int entity = EntRefToEntIndex(entityRef);

    if (entity == INVALID_ENT_REFERENCE)
        return;

    int entity2 = MaxClients + 1;
    int count;
    while ((entity2 = FindEntityByClassname(entity2, "trigger_finale")) != -1)
    {
        if (!IsValidEntity(entity2))
            continue;	

        count++;
    }

    if(count > 1)
    {
        LogError("It has more than 1 trigger_finale entity in this shit map: %s, disable the plugin", g_sCurrentMap);

        return;
    }

    g_hAcceptInput.HookEntity(Hook_Pre, entity, Hook_AcceptInputPre_trigger_finale);
    g_hAcceptInput.HookEntity(Hook_Post, entity, Hook_AcceptInputPost_trigger_finale);
    HookSingleEntityOutput(entity, "FinaleStart", EntityOutput_OnFinaleStart);
}

void OnNextFrame_trigger_finale_dlc3(int entityRef)
{
     if(g_bCvarEnable == false || !g_bIsFinalMap) return;

    //"trigger_finale_dlc3" classname會變成 "trigger_finale" on SpawnPost."
    int entity = EntRefToEntIndex(entityRef);

    if (entity == INVALID_ENT_REFERENCE)
        return;

    int entity2 = MaxClients + 1;
    int count;
    while ((entity2 = FindEntityByClassname(entity2, "trigger_finale")) != -1)
    {
        if (!IsValidEntity(entity2))
            continue;	

        count++;
    }

    if(count > 1)
    {
        LogError("It has more than 1 trigger_finale entity in this shit map: %s, disable the plugin", g_sCurrentMap);

        return;
    }

    HookSingleEntityOutput(entity, "FinaleStart", EntityOutput_OnFinaleStart);
}

void Frame_RestoreNavAreas()
{
    RestoreNavAreas();
}

// function

void SetAllNavAreasFinale()
{
    ArrayList areas = new ArrayList();
    L4D_GetAllNavAreas(areas);

    delete alNavAreasWithoutFinale;
    alNavAreasWithoutFinale = new ArrayList();

    for (int i = 0; i < areas.Length; i++)
    {
        Address area = areas.Get(i);
        int navSpawnAttributes = L4D_GetNavArea_SpawnAttributes(area);
        if (!(navSpawnAttributes & NAV_FINALE))
        {
            alNavAreasWithoutFinale.Push(area);
            L4D_SetNavArea_SpawnAttributes(area, navSpawnAttributes|NAV_FINALE);
        }
    }

    delete areas;
}

void RestoreNavAreas()
{
    if (alNavAreasWithoutFinale.Length == 0)
        return;

    for (int i = 0; i < alNavAreasWithoutFinale.Length; i++)
    {
        Address area = alNavAreasWithoutFinale.Get(i);
        int navSpawnAttributes = L4D_GetNavArea_SpawnAttributes(area);
        navSpawnAttributes &= ~NAV_FINALE;
        L4D_SetNavArea_SpawnAttributes(area, navSpawnAttributes);
    }
    delete alNavAreasWithoutFinale;
    alNavAreasWithoutFinale = new ArrayList();
}

// other

bool IsValidClient(int client)
{
    return (IsValidClientIndex(client) && IsClientInGame(client));
}

bool IsValidClientIndex(int client)
{
    return (1 <= client <= MaxClients);
}