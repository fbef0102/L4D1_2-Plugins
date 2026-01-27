/**
 * 修正玩家在遊戲中切換模組之後角色語音錯亂，配合會在遊戲轉換角色模組的插件，依照目前模組判定是一二代倖存者則給予相對應的角色語音
 * 譬如!csm插件: https://forums.alliedmods.net/showthread.php?p=969651，選擇模組導致自己角色講不出話
 * 譬如Survivor Bot Holdout插件: https://forums.alliedmods.net/showthread.php?t=188966，在一代地圖上使用二代NPC，二代的NPC語音卻是一代的角色語音
 * 
 * 副作用: 导致三方图的机关需要語音互动觸發而卡关
 * 譬如 https://steamcommunity.com/sharedfiles/filedetails/?id=3420955785 （map2）
 * -如果是用一代角色可觸發救援機關的對話->vscript腳本檢測到對話->繼續救援關卡
 * -如果是用二代角色則無法觸發救援機關的對話->vscript腳本沒有檢測->卡關
 * 
 * 2026年修復
 * 三方图的机关需要語音互动時，暫時將玩家角色變回地圖預設的角色
 * 觸發地圖機關語音互動之後，再變回原本的角色
 */

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>  
#include <sdkhooks>
#include <sdktools>
#include <dhooks>
#include <left4dhooks>

public Plugin myinfo = 
{
	name = "Voice based on model",
	author = "TBK Duy, Harry",
	description = "Survivors will vocalize based on their model + Fixes conversation stucks when playing with l4d1+2 survivor models in custom maps",
	version = "1.0h-2026/1/27",
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

bool bLate;
public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	bLate = late;
	return APLRes_Success;
}

#define GAMEDATA_FILE           "l4d2_vocalizebasedmodel"

#define     L4D1_NICK     		4
#define     L4D1_ROCHELLE    	5
#define     L4D1_COACH     		6
#define     L4D1_ELLIS     		7
#define     L4D1_BILL     		0
#define     L4D1_ZOEY     		1
#define     L4D1_LOUIS     		2
#define     L4D1_FRANCIS     	3

#define     L4D2_NICK     		0
#define     L4D2_ROCHELLE    	1
#define     L4D2_COACH     		2
#define     L4D2_ELLIS     		3
#define     L4D2_BILL     		4
#define     L4D2_ZOEY     		5
#define     L4D2_FRANCIS     	6
#define     L4D2_LOUIS     		7

#define     SPEAK_TIME     		3.0

enum
{
	L4D2_SurvivorSet_Default = 0,
	L4D2_SurvivorSet_L4D1,
	L4D2_SurvivorSet_L4D2,
}

DynamicHook 
	g_hAcceptInput;

bool 
	g_bMapIsL4D1Set;

Handle
	g_hSpeakResponseConceptFromEntityTimer[MAXPLAYERS+1];

public void OnPluginStart()
{
	GameData hConfig = new GameData(GAMEDATA_FILE);
	
	if (hConfig == INVALID_HANDLE)
	{
		SetFailState("Could not find gamedata file: %s.txt", GAMEDATA_FILE);
	}
	
	int offset = hConfig.GetOffset("AcceptInput");
	
	if (offset == -1)
	{
		SetFailState("Failed to find AcceptInput offset");
	}
	
	delete hConfig;

	// DHooks.
	// "AcceptInput"
	g_hAcceptInput = new DynamicHook(offset, HookType_Entity, ReturnType_Bool, ThisPointer_CBaseEntity);
	g_hAcceptInput.AddParam(HookParamType_CharPtr);
	g_hAcceptInput.AddParam(HookParamType_CBaseEntity);
	g_hAcceptInput.AddParam(HookParamType_CBaseEntity);
	g_hAcceptInput.AddParam(HookParamType_Object, 20);
	g_hAcceptInput.AddParam(HookParamType_Int);

	if(bLate)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i)) OnClientPutInServer(i);
		}
	}
}

// sourcemod api----

public void OnMapStart()
{
    CreateTimer(1.0, Timer_OnMapStart, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_PostThinkPost, Hook_OnPostThinkPost);
}

public void OnClientDisconnect(int client)
{
	delete g_hSpeakResponseConceptFromEntityTimer[client];
}

public void OnEntityCreated(int entity, const char[] classname)
{
	switch (classname[0])
	{
		case 'f':
		{
			if (strncmp(classname, "func_orator", 11, false) == 0)
			{
				g_hAcceptInput.HookEntity(Hook_Pre, entity, Hook_AcceptInput_func_orator);
			}
		}
	}
}

// SDKHooks------------

void Hook_OnPostThinkPost(int client)
{
	if(!IsPlayerAlive(client)) 
		return;

	if(g_hSpeakResponseConceptFromEntityTimer[client] != null)
		return;

	if(GetClientTeam(client) == 2)
	{
		VoiceModel(client);
	}
}	

// dhooks------

MRESReturn Hook_AcceptInput_func_orator(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	// 1 = input動作, 2 = 觸發者 (activator), pThis = 物件本身 (entity), 3= caller (呼叫input動作的 entity, 與pThis不同)
	static char sCommand[64];
	hParams.GetString(1, sCommand, sizeof(sCommand));

	int activator = -999;
	if(hParams.IsNull(2)) return MRES_Ignored;
	activator = hParams.Get(2);

	static char sThisClassName[64];
	GetEntityClassname(pThis, sThisClassName, sizeof(sThisClassName));
	//PrintToChatAll("[Hook_AcceptInput_filter_test] input: %s, activator: %d, pThis: %d (%s)", sCommand, activator, pThis, sThisClassName);
	if(activator > 0 && activator <= MaxClients && IsClientInGame(activator) && IsPlayerAlive(activator)
		&& GetClientTeam(activator) == L4D_TEAM_SURVIVOR
		&& strcmp(sCommand, "SpeakResponseConcept", false) == 0)
	{
		TryToFixMapFlow_ByVoice(activator);
	}

	return MRES_Ignored;
}

// leftd4hooks api---

public void L4D_OnSpeakResponseConcept_Pre(int entity)
{
	//PrintToChatAll("L4D_OnSpeakResponseConcept_Pre: %d doing the talking", entity);
	if(0 < entity <= MaxClients && IsClientInGame(entity) && IsPlayerAlive(entity) && 
		GetClientTeam(entity) == L4D_TEAM_SURVIVOR )
	{
		TryToFixMapFlow_ByVoice(entity);
	}
}

// timer & Frame---

Action Timer_OnMapStart(Handle timer)
{
    if( L4D_GetPointer(POINTER_MISSIONINFO) != Address_Null )
    {
        g_bMapIsL4D1Set = L4D2_GetSurvivorSetMap() == L4D2_SurvivorSet_L4D1 ? true : false;
    }
    else
    {
        g_bMapIsL4D1Set = true;
    }
    
    return Plugin_Continue;
}

Action Timer_RestoreCharacterVoice(Handle timer, DataPack hPack)
{
	hPack.Reset();
	int index = hPack.ReadCell();
	int client = GetClientOfUserId(hPack.ReadCell());
	int character = hPack.ReadCell();

	g_hSpeakResponseConceptFromEntityTimer[index] = null;
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != 2) return Plugin_Continue;
	if(GetEntProp(client, Prop_Send, "m_survivorCharacter") == character) return Plugin_Continue;

	SetEntProp(client, Prop_Send, "m_survivorCharacter", character);

	return Plugin_Continue;
}

// functions---

void TryToFixMapFlow_ByVoice (int client)
{
	if(g_hSpeakResponseConceptFromEntityTimer[client] != null) return;

	int SurCharacter = GetEntProp(client, Prop_Send, "m_survivorCharacter");
	static char sModel[31];
	GetEntPropString(client, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

	//PrintToChatAll("try to restore original character voice");
	DataPack hPack;
	switch(sModel[29])
	{
		case 'c'://coach
		{
			if(g_bMapIsL4D1Set)
			{
				SetEntProp(client, Prop_Send, "m_survivorCharacter", L4D1_LOUIS);
				LouisVoice(client);
			}
			else
			{
				return;
			}
		}
		case 'b'://nick
		{
			if(g_bMapIsL4D1Set)
			{
				SetEntProp(client, Prop_Send, "m_survivorCharacter", L4D1_BILL);
				BillVoice(client);
			}
			else
			{
				return;
			}
		}
		case 'd'://rochelle
		{
			if(g_bMapIsL4D1Set)
			{
				SetEntProp(client, Prop_Send, "m_survivorCharacter", L4D1_ZOEY);
				ZoeyVoice(client);
			}
			else
			{
				return;
			}
		}
		case 'h'://ellis
		{
			if(g_bMapIsL4D1Set)
			{
				SetEntProp(client, Prop_Send, "m_survivorCharacter", L4D1_FRANCIS);
				FrancisVoice(client);
			}
			else
			{
				return;
			}
		}
		case 'v'://bill
		{
			if(g_bMapIsL4D1Set)
			{
				return;
			}
			else
			{
				SetEntProp(client, Prop_Send, "m_survivorCharacter", L4D2_NICK);
				NickVoice(client);
			}
		}
		case 'n'://zoey
		{
			if(g_bMapIsL4D1Set)
			{
				return;
			}
			else
			{
				SetEntProp(client, Prop_Send, "m_survivorCharacter", L4D2_ROCHELLE);
				RochelleVoice(client);
			}
		}
		case 'e'://francis
		{
			if(g_bMapIsL4D1Set)
			{
				return;
			}
			else
			{
				SetEntProp(client, Prop_Send, "m_survivorCharacter", L4D2_COACH);
				CoachVoice(client);
			}
		}
		case 'a'://louis
		{
			if(g_bMapIsL4D1Set)
			{
				return;
			}
			else
			{
				SetEntProp(client, Prop_Send, "m_survivorCharacter", L4D2_ELLIS);
				EllisVoice(client);
			}
		}
		default:
		{
			if(g_bMapIsL4D1Set)
			{
				SetEntProp(client, Prop_Send, "m_survivorCharacter", L4D1_BILL);
				BillVoice(client);
			}
			else
			{
				SetEntProp(client, Prop_Send, "m_survivorCharacter", L4D2_NICK);
				NickVoice(client);
			}
		}
	}

	g_hSpeakResponseConceptFromEntityTimer[client] = CreateDataTimer(SPEAK_TIME, Timer_RestoreCharacterVoice, hPack);
	hPack.WriteCell(client);
	hPack.WriteCell(GetClientUserId(client));
	hPack.WriteCell(SurCharacter);
}

void BillVoice(int client)  
{
	SetVariantString("who:NamVet:0");
	//DispatchKeyValue(client, "targetname", "NamVet");
	AcceptEntityInput(client, "AddContext");
}

void ZoeyVoice(int client)  
{
	SetVariantString("who:TeenGirl:0");
	//DispatchKeyValue(client, "targetname", "TeenGirl");
	AcceptEntityInput(client, "AddContext");
}

void LouisVoice(int client)  
{
	SetVariantString("who:Manager:0");
	//DispatchKeyValue(client, "targetname", "Manager");
	AcceptEntityInput(client, "AddContext");
}

void FrancisVoice(int client)  
{
	SetVariantString("who:Biker:0");
	//DispatchKeyValue(client, "targetname", "Biker");
	AcceptEntityInput(client, "AddContext");
}

void NickVoice(int client)  
{
	SetVariantString("who:Gambler:0");
	//DispatchKeyValue(client, "targetname", "Gambler");
	AcceptEntityInput(client, "AddContext");
}

void RochelleVoice(int client)  
{
	SetVariantString("who:Producer:0");
	//DispatchKeyValue(client, "targetname", "Producer");
	AcceptEntityInput(client, "AddContext");
}

void CoachVoice(int client)  
{
	SetVariantString("who:Coach:0");
	//DispatchKeyValue(client, "targetname", "Coach");
	AcceptEntityInput(client, "AddContext");
}

void EllisVoice(int client)  
{
	SetVariantString("who:Mechanic:0");
	//DispatchKeyValue(client, "targetname", "Mechanic");
	AcceptEntityInput(client, "AddContext");
}
	
void VoiceModel(int client)
{
	static char sModel[31];
	GetEntPropString(client, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
	switch(sModel[29])
	{
		case 'c'://coach
		{
			CoachVoice(client);
		}
		case 'b'://nick
		{
			NickVoice(client);
		}
		case 'd'://rochelle
		{
			RochelleVoice(client);
		}
		case 'h'://ellis
		{
			EllisVoice(client);
		}
		case 'v'://bill
		{
			BillVoice(client);
		}
		case 'n'://zoey
		{
			ZoeyVoice(client);
		}
		case 'e'://francis
		{
			FrancisVoice(client);
		}
		case 'a'://louis
		{
			LouisVoice(client);
		}
	}
}

