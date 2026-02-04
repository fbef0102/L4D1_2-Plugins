#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sceneprocessor>
#include <sdktools_functions>
#include <sdkhooks>
#include <left4dhooks>

#define MAXENTITIES 4096
#define CVAR_SURVIVOR_MAX_INCAP_COUNT "survivor_max_incapacitated_count"
#define PLUGIN_VERSION "1.0h-2026/2/4"

public Plugin myinfo =  
{
	name = "[L4D2] Survivor Mourn Fix", 
	author = "DeathChaos25, Harry", 
	description = "Fixes the bug where any survivor is unable to mourn a L4D1 survivor on the L4D2 set", 
	version = PLUGIN_VERSION, 
	url = "https://forums.alliedmods.net/showthread.php?t=258189"
}


#define MODEL_FRANCIS		"models/survivors/survivor_biker.mdl"
#define MODEL_LOUIS			"models/survivors/survivor_manager.mdl"
#define MODEL_ZOEY			"models/survivors/survivor_teenangst.mdl"
#define MODEL_BILL			"models/survivors/survivor_namvet.mdl"
#define MODEL_NICK			"models/survivors/survivor_gambler.mdl"
#define MODEL_COACH			"models/survivors/survivor_coach.mdl"
#define MODEL_ROCHELLE		"models/survivors/survivor_producer.mdl"
#define MODEL_ELLIS			"models/survivors/survivor_mechanic.mdl"

#define COOLDOWNTIME		10.0

ConVar g_hCvar_SurvivorDeathNameSayEnabled;
bool g_bCvar_SurvivorDeathNameSayEnabled;

int 
	iDeathBody[MAXPLAYERS + 1] = {0};

int 
	MODEL_LOUIS_INDEX,
	MODEL_FRANCIS_INDEX,
	MODEL_BILL_INDEX,
	MODEL_ZOEY_INDEX;

float 
	g_fMournTime[MAXPLAYERS+1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

public void OnPluginStart()
{
	g_hCvar_SurvivorDeathNameSayEnabled = CreateConVar("l4d2_survivor_mourn_fix_death", "1", "If 1, Enable a feature that allows survivors to say the name of an L4D1 survivor when an L4D1 survivor dies. (2019 The last stand update removed this feature)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	CreateConVar("l4d2_mourn_fix_version", PLUGIN_VERSION, "Current Version of Survivor Mourn Fix", FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
	AutoExecConfig(true, "l4d2_survivor_mourn_fix");

	GetCvars();
	g_hCvar_SurvivorDeathNameSayEnabled.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_death", Event_PlayerDeath);

	CreateTimer(1.25, TimerUpdate, _, TIMER_REPEAT);
}

public void OnMapStart()
{
	CheckModelPreCache(MODEL_NICK);
	CheckModelPreCache(MODEL_ROCHELLE);
	CheckModelPreCache(MODEL_COACH);
	CheckModelPreCache(MODEL_ELLIS);
	CheckModelPreCache(MODEL_BILL);
	CheckModelPreCache(MODEL_ZOEY);
	CheckModelPreCache(MODEL_FRANCIS);
	CheckModelPreCache(MODEL_LOUIS);
	
	MODEL_LOUIS_INDEX = PrecacheModel(MODEL_LOUIS, true);
	MODEL_FRANCIS_INDEX = PrecacheModel(MODEL_FRANCIS, true);
	MODEL_BILL_INDEX = PrecacheModel(MODEL_BILL, true);
	MODEL_ZOEY_INDEX = PrecacheModel(MODEL_ZOEY, true);
}

// Cvars-------------------------------

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvar_SurvivorDeathNameSayEnabled = g_hCvar_SurvivorDeathNameSayEnabled.BoolValue;
}

// Timer---

Action TimerUpdate(Handle timer)
{
	if (!IsServerProcessing()) return Plugin_Continue;
	
	bool bIsValidDeathBody;
	float Origin[3], TOrigin[3], distance;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsSurvivor(i) && IsPlayerAlive(i)
			&& g_fMournTime[i] <= GetEngineTime())
		{
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", Origin);
			bIsValidDeathBody = IsValidEntRef(iDeathBody[i]);
			if (!bIsValidDeathBody)
			{
				int entity = -1;
				while ((entity = FindEntityByClassname(entity, "survivor_death_model")) != INVALID_ENT_REFERENCE)
				{
					if(!IsValidEntity(entity)) continue;

					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", TOrigin);
					distance = GetVectorDistance(Origin, TOrigin);
					if (distance <= 200.0)
					{
						iDeathBody[i] = EntIndexToEntRef(entity);
						MournSurvivor(i);
						g_fMournTime[i] = GetEngineTime() + COOLDOWNTIME;
						break;
					}
				}
			}
			else
			{
				GetEntPropVector(iDeathBody[i], Prop_Send, "m_vecOrigin", TOrigin);
				distance = GetVectorDistance(Origin, TOrigin);
				if (distance > 350.0)
				{
					iDeathBody[i] = 0;
				}
			}
		}
	}
	return Plugin_Continue;
}

// Event-----

void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if (!g_bCvar_SurvivorDeathNameSayEnabled)
	{
		return;
	}
	
	int client = GetClientOfUserId(GetEventInt(event, "userid")); // Player that died
	
	if (!IsSurvivor(client))
	{
		return;
	}
	
	//PrintToChatAll("Player %N has died!", client);
	// In here we fix L4D1 survivors not screaming the names of other L4D1 survivors when they die
	int randscene;
	static char sModel_Victom[64], sModel_Reactor[64];
	GetEntPropString(client, Prop_Data, "m_ModelName", sModel_Victom, sizeof(sModel_Victom));
	if (IsClientZoey(sModel_Victom)) // Zoey died
	{
		int iReactor = GetRandomAliveSurvivor();
		if(iReactor <= 0) return;
		GetEntPropString(iReactor, Prop_Data, "m_ModelName", sModel_Reactor, sizeof(sModel_Reactor));

		if (IsClientNick(sModel_Reactor))
		{
			PerformSceneEx(iReactor, "", "scenes/gambler/dlc1_c6m3_finalel4d1killing04.vcd", 1.0);
		}
		else if (IsClientEllis(sModel_Reactor))
		{
			PerformSceneEx(iReactor, "", "scenes/mechanic/dlc1_c6m3_finalel4d1killing11.vcd", 1.0);
		}
		else if (IsClientCoach(sModel_Reactor) )
		{
			PerformSceneEx(iReactor, "", "scenes/coach/nameproducerc103.vcd", 1.0);
		}
		else if (IsClientBill(sModel_Reactor))
		{
			randscene = GetRandomInt(1, 3);
			switch (randscene)
			{
				case 1:PerformSceneEx(iReactor, "", "scenes/NamVet/C6DLC3ZOEYDIES01.vcd", 1.0);
				case 2:PerformSceneEx(iReactor, "", "scenes/NamVet/C6DLC3ZOEYDIES04.vcd", 1.0);
				case 3:PerformSceneEx(iReactor, "", "scenes/NamVet/NameZoey01.vcd", 1.0);
			}
		}
		else if (IsClientLouis(sModel_Reactor))
		{
			randscene = GetRandomInt(1, 3);
			switch (randscene)
			{
				case 1:PerformSceneEx(iReactor, "", "scenes/Manager/GriefTeengirl06.vcd", 1.0);
				case 2:PerformSceneEx(iReactor, "", "scenes/Manager/NameZoey01.vcd", 1.0);
				case 3:PerformSceneEx(iReactor, "", "scenes/Manager/NameZoey02.vcd", 1.0);
			}
		}
		else if (IsClientFrancis(sModel_Reactor))
		{
			randscene = GetRandomInt(1, 4);
			switch (randscene)
			{
				case 1:PerformSceneEx(iReactor, "", "scenes/Biker/C6DLC3ZOEYDIES02.vcd", 1.0);
				case 2:PerformSceneEx(iReactor, "", "scenes/Biker/C6DLC3ZOEYDIES03.vcd", 1.0);
				case 3:PerformSceneEx(iReactor, "", "scenes/Biker/NameZoey01.vcd", 1.0);
			}
		}
	}
	else if (IsClientFrancis(sModel_Victom)) // Francis Died
	{
		int iReactor = GetRandomAliveSurvivor();
		if(iReactor <= 0) return;
		GetEntPropString(iReactor, Prop_Data, "m_ModelName", sModel_Reactor, sizeof(sModel_Reactor));

		if (IsClientEllis(sModel_Reactor))
		{
			PerformSceneEx(iReactor, "", "scenes/mechanic/dlc1_c6m3_finalel4d1killing13.vcd", 1.0);
		}
		if (IsClientRochelle(sModel_Reactor))
		{
			PerformSceneEx(iReactor, "", "scenes/producer/dlc1_c6m3_finalel4d1killing04.vcd", 1.0);
		}
		else if (IsClientBill(sModel_Reactor) )
		{
			randscene = GetRandomInt(1, 3);
			switch (randscene)
			{
				case 1:PerformSceneEx(iReactor, "", "scenes/NamVet/C6DLC3FRANCISDIES01.vcd", 1.0);
				case 2:PerformSceneEx(iReactor, "", "scenes/NamVet/NameFrancis01.vcd", 1.0);
				case 3:PerformSceneEx(iReactor, "", "scenes/NamVet/NameFrancis02.vcd", 1.0);
			}
		}
		else if (IsClientLouis(sModel_Reactor))
		{
			randscene = GetRandomInt(1, 5);
			switch (randscene)
			{
				case 1:PerformSceneEx(iReactor, "", "scenes/Manager/C6DLC3FRANCISDIES02.vcd", 1.0);
				case 2:PerformSceneEx(iReactor, "", "scenes/Manager/C6DLC3FRANCISDIES05.vcd", 1.0);
				case 3:PerformSceneEx(iReactor, "", "scenes/Manager/GriefBiker01.vcd", 1.0);
				case 4:PerformSceneEx(iReactor, "", "scenes/Manager/GriefBiker07.vcd", 1.0);
				case 5:PerformSceneEx(iReactor, "", "scenes/Manager/NameFrancis02.vcd", 1.0);
			}
		}
		else if (IsClientZoey(sModel_Reactor))
		{
			randscene = GetRandomInt(1, 4);
			switch (randscene)
			{
				case 1:PerformSceneEx(iReactor, "", "scenes/TeenGirl/C6DLC3FRANCISDIES01.vcd", 1.0);
				case 2:PerformSceneEx(iReactor, "", "scenes/TeenGirl/C6DLC3FRANCISDIES02.vcd", 1.0);
				case 3:PerformSceneEx(iReactor, "", "scenes/TeenGirl/GriefBiker02.vcd", 1.0);
				case 4:PerformSceneEx(iReactor, "", "scenes/TeenGirl/GriefBiker04.vcd", 1.0);
			}
		}
	}
	else if (IsClientLouis(sModel_Victom))
	{
		int iReactor = GetRandomAliveSurvivor();
		if(iReactor <= 0) return;
		GetEntPropString(iReactor, Prop_Data, "m_ModelName", sModel_Reactor, sizeof(sModel_Reactor));

		if (IsClientEllis(sModel_Reactor))
		{
			PerformSceneEx(iReactor, "", "scenes/mechanic/dlc1_c6m3_finalel4d1killing20.vcd", 1.0);
		}
		if (IsClientBill(sModel_Reactor))
		{
			randscene = GetRandomInt(1, 2);
			switch (randscene)
			{
				case 1:PerformSceneEx(iReactor, "", "scenes/NamVet/C6DLC3LOUISDIES01.vcd", 1.0);
				case 2:PerformSceneEx(iReactor, "", "scenes/NamVet/NameLouis01.vcd", 1.0);
			}
		}
		else if (IsClientFrancis(sModel_Reactor) )
		{
			randscene = GetRandomInt(1, 3);
			switch (randscene)
			{
				case 1:PerformSceneEx(iReactor, "", "scenes/Biker/C6DLC3LOUISDIES06.vcd", 1.0);
				case 2:PerformSceneEx(iReactor, "", "scenes/Biker/NameLouis01.vcd", 1.0);
				case 3:PerformSceneEx(iReactor, "", "scenes/Biker/NameLouis02.vcd", 1.0);
			}
		}
		else if (IsClientZoey(sModel_Reactor))
		{
			randscene = GetRandomInt(1, 3);
			switch (randscene)
			{
				case 1:PerformSceneEx(iReactor, "", "scenes/TeenGirl/C6DLC3LOUISDIES04.vcd", 1.0);
				case 2:PerformSceneEx(iReactor, "", "scenes/TeenGirl/C6DLC3LOUISDIES05.vcd", 1.0);
				case 3:PerformSceneEx(iReactor, "", "scenes/TeenGirl/GriefManager02.vcd", 1.0);
			}
		}
	}
}

void Event_RoundStart(Event event, const char[] name, bool dontBroadcast) 
{
	for (int i = 0; i <= MaxClients; i++)
	{
		iDeathBody[i] = 0;
	}
}

// Function---

bool MournSurvivor(int client)
{
	if(IsActorBusy(client)) return false;

	static char model[64];
	GetEntPropString(client, Prop_Data, "m_ModelName", model, sizeof(model));

	int random, index;
	if (StrEqual(model, MODEL_ZOEY, false))
	{
		random = GetRandomInt(1, 5);
		index = GetEntProp(iDeathBody[client], Prop_Data, "m_nModelIndex");
		if (index == MODEL_LOUIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/TeenGirl/GriefManager03.vcd");
				case 2:PerformSceneEx(client, "", "scenes/TeenGirl/GriefManager08.vcd");
				case 3:PerformSceneEx(client, "", "scenes/TeenGirl/GriefManager09.vcd");
				case 4:PerformSceneEx(client, "", "scenes/TeenGirl/GriefManager11.vcd");
				case 5:PerformSceneEx(client, "", "scenes/TeenGirl/GriefManager12.vcd");
			}
		}
		else if (index == MODEL_BILL_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/TeenGirl/GriefVet02.vcd");
				case 2:PerformSceneEx(client, "", "scenes/TeenGirl/GriefVet03.vcd");
				case 3:PerformSceneEx(client, "", "scenes/TeenGirl/GriefVet12.vcd");
				case 4:PerformSceneEx(client, "", "scenes/TeenGirl/GriefVet07.vcd");
				case 5:PerformSceneEx(client, "", "scenes/TeenGirl/GriefVet11.vcd");
			}
		}
		else if (index == MODEL_FRANCIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/TeenGirl/GriefBiker01.vcd");
				case 2:PerformSceneEx(client, "", "scenes/TeenGirl/GriefBiker02.vcd");
				case 3:PerformSceneEx(client, "", "scenes/TeenGirl/GriefBiker04.vcd");
				case 4:PerformSceneEx(client, "", "scenes/TeenGirl/GriefBiker06.vcd");
				case 5:PerformSceneEx(client, "", "scenes/TeenGirl/GriefBiker07.vcd");
			}
		}
		else if (index == MODEL_ZOEY_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/TeenGirl/Generic10.vcd");
				case 2:PerformSceneEx(client, "", "scenes/TeenGirl/Generic10.vcd");
				case 3:PerformSceneEx(client, "", "scenes/TeenGirl/Generic10.vcd");
				case 4:PerformSceneEx(client, "", "scenes/TeenGirl/Generic10.vcd");
				case 5:PerformSceneEx(client, "", "scenes/TeenGirl/Generic10.vcd");
			}
		}
		else
		{
			return false;
		}
	}
	else if (StrEqual(model, MODEL_BILL, false))
	{
		random = GetRandomInt(1, 5);
		index = GetEntProp(iDeathBody[client], Prop_Data, "m_nModelIndex");
		if (index == MODEL_LOUIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/NamVet/C6DLC3LOUISDIES03.vcd");
				case 2:PerformSceneEx(client, "", "scenes/NamVet/C6DLC3LOUISDIES04.vcd");
				case 3:PerformSceneEx(client, "", "scenes/NamVet/GriefManager01.vcd");
				case 4:PerformSceneEx(client, "", "scenes/NamVet/GriefManager02.vcd");
				case 5:PerformSceneEx(client, "", "scenes/NamVet/GriefManager03.vcd");
			}
		}
		else if (index == MODEL_BILL_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/NamVet/GriefBiker03.vcd");
				case 2:PerformSceneEx(client, "", "scenes/NamVet/GriefManager03.vcd");
				case 3:PerformSceneEx(client, "", "scenes/NamVet/GriefBiker03.vcd");
				case 4:PerformSceneEx(client, "", "scenes/NamVet/GriefManager03.vcd");
				case 5:PerformSceneEx(client, "", "scenes/NamVet/GriefBiker03.vcd");
			}
		}
		else if (index == MODEL_FRANCIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/NamVet/C6DLC3FRANCISDIES03.vcd");
				case 2:PerformSceneEx(client, "", "scenes/NamVet/C6DLC3FRANCISDIES04.vcd");
				case 3:PerformSceneEx(client, "", "scenes/NamVet/GriefBiker01.vcd");
				case 4:PerformSceneEx(client, "", "scenes/NamVet/GriefBiker02.vcd");
				case 5:PerformSceneEx(client, "", "scenes/NamVet/GriefBiker03.vcd");
			}
		}
		else if (index == MODEL_ZOEY_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/NamVet/C6DLC3ZOEYDIES02.vcd");
				case 2:PerformSceneEx(client, "", "scenes/NamVet/C6DLC3ZOEYDIES03.vcd");
				case 3:PerformSceneEx(client, "", "scenes/NamVet/C6DLC3ZOEYDIES06.vcd");
				case 4:PerformSceneEx(client, "", "scenes/NamVet/GriefTeengirl01.vcd");
				case 5:PerformSceneEx(client, "", "scenes/NamVet/GriefTeengirl02.vcd");
			}
		}
		else
		{
			return false;
		}
	}
	else if (StrEqual(model, MODEL_FRANCIS, false))
	{
		random = GetRandomInt(1, 5);
		index = GetEntProp(iDeathBody[client], Prop_Data, "m_nModelIndex");
		if (index == MODEL_LOUIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Biker/GriefManager01.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Biker/C6DLC3LOUISDIES02.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Biker/GriefManager03.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Biker/GriefManager04.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Biker/GriefManager05.vcd");
			}
		}
		else if (index == MODEL_BILL_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Biker/C6DLC3BILLDIES01.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Biker/C6DLC3BILLDIES06.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Biker/GriefVet01.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Biker/GriefVet02.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Biker/GriefVet03.vcd");
			}
		}
		else if (index == MODEL_FRANCIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Biker/DLC1_C6M3_Loss01.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Biker/DLC1_C6M3_Loss02.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Biker/GriefManager02.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Biker/GriefManager03.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Biker/GriefManager05.vcd");
			}
		}
		else if (index == MODEL_ZOEY_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Biker/C6DLC3ZOEYDIES01.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Biker/GriefFemaleGeneric03.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Biker/GriefTeengirl01.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Biker/GriefTeengirl02.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Biker/GriefTeengirl02.vcd");
			}
		}
		else
		{
			return false;
		}
	}
	else if (StrEqual(model, MODEL_LOUIS, false))
	{
		random = GetRandomInt(1, 8);
		index = GetEntProp(iDeathBody[client], Prop_Data, "m_nModelIndex");
		if (index == MODEL_LOUIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Manager/C6DLC3FRANCISDIES03.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Manager/C6DLC3FRANCISDIES04.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Manager/C6DLC3FRANCISDIES03.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Manager/C6DLC3FRANCISDIES04.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Manager/C6DLC3FRANCISDIES03.vcd");
				case 6:PerformSceneEx(client, "", "scenes/Manager/C6DLC3FRANCISDIES04.vcd");
				case 7:PerformSceneEx(client, "", "scenes/Manager/C6DLC3FRANCISDIES03.vcd");
				case 8:PerformSceneEx(client, "", "scenes/Manager/C6DLC3FRANCISDIES04.vcd");
			}
		}
		else if (index == MODEL_BILL_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Manager/C6DLC3BILLDIES04.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Manager/C6DLC3BILLDIES05.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Manager/GriefVet01.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Manager/GriefVet03.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Manager/GriefVet04.vcd");
				case 6:PerformSceneEx(client, "", "scenes/Manager/GriefVet06.vcd");
				case 7:PerformSceneEx(client, "", "scenes/Manager/GriefVet07.vcd");
				case 8:PerformSceneEx(client, "", "scenes/Manager/GriefVet08.vcd");
			}
		}
		else if (index == MODEL_FRANCIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Manager/C6DLC3FRANCISDIES03.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Manager/C6DLC3FRANCISDIES04.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Manager/GriefBiker01.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Manager/GriefBiker04.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Manager/GriefBiker05.vcd");
				case 6:PerformSceneEx(client, "", "scenes/Manager/GriefBiker07.vcd");
				case 7:PerformSceneEx(client, "", "scenes/Manager/GriefBiker07.vcd");
				case 8:PerformSceneEx(client, "", "scenes/Manager/GriefBiker05.vcd");
			}
		}
		else if (index == MODEL_ZOEY_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Manager/GriefTeengirl01.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Manager/GriefTeengirl02.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Manager/GriefTeengirl03.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Manager/GriefTeengirl04.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Manager/GriefTeengirl05.vcd");
				case 6:PerformSceneEx(client, "", "scenes/Manager/GriefTeengirl06.vcd");
				case 7:PerformSceneEx(client, "", "scenes/Manager/GriefTeengirl07.vcd");
				case 8:PerformSceneEx(client, "", "scenes/Manager/GriefTeengirl08.vcd");
			}
		}
		else
		{
			return false;
		}
	}
	else if (StrEqual(model, MODEL_ELLIS, false))
	{
		random = GetRandomInt(1, 5);
		index = GetEntProp(iDeathBody[client], Prop_Data, "m_nModelIndex");
		if (index == MODEL_LOUIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Mechanic/SurvivorMournNick03.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B100.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B102.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B147.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B148.vcd");
			}
		}
		else if (index == MODEL_BILL_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Mechanic/SurvivorMournGamblerC101.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B100.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B102.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B147.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B148.vcd");
			}
		}
		else if (index == MODEL_FRANCIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Mechanic/DLC1_C6M3_FinaleFinalGas10.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B100.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B102.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B147.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Mechanic/WorldC1M1B148.vcd");
			}
		}
		else if (index == MODEL_ZOEY_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/mechanic/survivormournproducerc101.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Mechanic/DLC1_C6M3_FinaleFinalGas02.vcd");
				case 3:PerformSceneEx(client, "", "scenes/mechanic/survivormournproducerc102.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Mechanic/DLC1_C6M3_FinaleFinalGas05.vcd");
				case 5:PerformSceneEx(client, "", "scenes/Mechanic/DLC1_C6M3_FinaleFinalGas04.vcd");
			}
		}
		else
		{
			return false;
		}
	}
	else if (StrEqual(model, MODEL_COACH, false))
	{
		random = GetRandomInt(1, 4);
		index = GetEntProp(iDeathBody[client], Prop_Data, "m_nModelIndex");
		if (index == MODEL_LOUIS_INDEX || index == MODEL_BILL_INDEX || index == MODEL_FRANCIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Coach/SurvivorMournMechanicC101.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Coach/WorldC2M112.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Coach/WorldC2M113.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Coach/SurvivorMournMechanicC101.vcd");
			}
		}
		else if (index == MODEL_ZOEY_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Coach/SurvivorMournProducerC101.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Coach/SurvivorMournProducerC102.vcd");
				case 3:PerformSceneEx(client, "", "scenes/Coach/SurvivorMournRochelle01.vcd");
				case 4:PerformSceneEx(client, "", "scenes/Coach/SurvivorMournRochelle03.vcd");
			}
		}
		else
		{
			return false;
		}
	}
	else if (StrEqual(model, MODEL_NICK, false))
	{
		random = GetRandomInt(1, 2);
		index = GetEntProp(iDeathBody[client], Prop_Data, "m_nModelIndex");
		if (index == MODEL_LOUIS_INDEX || index == MODEL_BILL_INDEX || index == MODEL_FRANCIS_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Gambler/SurvivorMournMechanicC102.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Gambler/SurvivorMournMechanicC102.vcd");
			}
		}
		else if (index == MODEL_ZOEY_INDEX)
		{
			switch (random)
			{
				case 1:PerformSceneEx(client, "", "scenes/Gambler/SurvivorMournProducerC101.vcd");
				case 2:PerformSceneEx(client, "", "scenes/Gambler/SurvivorMournProducerC102.vcd");
			}
		}
		else
		{
			return false;
		}
	}
	else if (StrEqual(model, MODEL_ROCHELLE, false))
	{
		index = GetEntProp(iDeathBody[client], Prop_Data, "m_nModelIndex");
		if (index == MODEL_LOUIS_INDEX || index == MODEL_BILL_INDEX)
		{
			PerformSceneEx(client, "", "scenes/Producer/SurvivorMournGamblerC101.vcd");
		}
		else if (index == MODEL_ZOEY_INDEX)
		{
			PerformSceneEx(client, "", "scenes/Producer/Generic02.vcd");
		}
		else if (index == MODEL_FRANCIS_INDEX)
		{
			PerformSceneEx(client, "", "scenes/Producer/DLC1_C6M3_FinaleChat10.vcd");
		}
		else
		{
			return false;
		}
	}

	return true;
}

void CheckModelPreCache(const char[] Modelfile)
{
	if (!IsModelPrecached(Modelfile))
	{
		PrecacheModel(Modelfile, true);
		PrintToServer("Precaching Model:%s", Modelfile);
	}
}

/* stock bools to identify which survivors is who */
bool IsSurvivor(int client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		return true;
	}

	return false;
}

bool IsClientNick(const char[] sModel)
{
	if (StrEqual(sModel, MODEL_NICK, false))
	{
		return true;
	}
	
	return false;
}

bool IsClientRochelle(const char[] sModel)
{
	if (StrEqual(sModel, MODEL_ROCHELLE, false))
	{
		return true;
	}
	
	return false;
}

bool IsClientCoach(const char[] sModel)
{
	if (StrEqual(sModel, MODEL_COACH, false))
	{
		return true;
	}
	
	return false;
}

bool IsClientEllis(const char[] sModel)
{
	if (StrEqual(sModel, MODEL_ELLIS, false))
	{
		return true;
	}
	
	return false;
}

bool IsClientBill(const char[] sModel)
{
	if (StrEqual(sModel, MODEL_BILL, false))
	{
		return true;
	}

	return false;
}

bool IsClientZoey(const char[] sModel)
{
	if (StrEqual(sModel, MODEL_ZOEY, false))
	{
		return true;
	}

	return false;
}

bool IsClientLouis(const char[] sModel)
{
	if (StrEqual(sModel, MODEL_LOUIS, false))
	{
		return true;
	}

	return false;
}

bool IsClientFrancis(const char[] sModel)
{
	if (StrEqual(sModel, MODEL_FRANCIS, false))
	{
		return true;
	}

	return false;
}

bool IsValidEntRef(int entity)
{
	if( entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE )
		return true;
	return false;
}

int GetRandomAliveSurvivor()
{
	int iClientCount, iClients[MAXPLAYERS+1];
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == 2 && IsPlayerAlive(i) && !IsActorBusy(i))
		{
			iClients[iClientCount++] = i;
		}
	}
	return (iClientCount == 0) ? 0 : iClients[GetRandomInt(0, iClientCount - 1)];
}