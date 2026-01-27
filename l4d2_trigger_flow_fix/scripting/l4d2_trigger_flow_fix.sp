#pragma semicolon 1

#define PLUGIN_NAME 		"Survivor Set Trigger Fix"
#define PLUGIN_AUTHOR 		"gabuch2, Harry"
#define PLUGIN_DESCRIPTION 	"Fixes bugs when playing with an unintended survivor set."
#define PLUGIN_VERSION 		"1.0h-2026/1/27"  
#define PLUGIN_URL			"https://forums.alliedmods.net/showthread.php?t=339155"

// LEFT 4 DEAD 1
#define MODEL_BILL "models/survivors/survivor_namvet.mdl" 
#define MODEL_FRANCIS "models/survivors/survivor_biker.mdl" 
#define MODEL_LOUIS "models/survivors/survivor_manager.mdl" 
#define MODEL_ZOEY "models/survivors/survivor_teenangst.mdl" 

// LEFT 4 DEAD 2
#define MODEL_NICK "models/survivors/survivor_gambler.mdl" 
#define MODEL_ROCHELLE "models/survivors/survivor_producer.mdl" 
#define MODEL_COACH "models/survivors/survivor_coach.mdl" 
#define MODEL_ELLIS "models/survivors/survivor_mechanic.mdl" 

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

#include <sourcemod>  
#include <sdktools>  
#include <left4dhooks>  

#pragma newdecls required

ConVar g_hCvarEnable;
bool g_bCvarEnable;
bool 	g_bMapIsL4D1Set = false;

public Plugin myinfo =  
{  
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
}  

public void OnPluginStart()  
{  
	g_hCvarEnable = CreateConVar("sm_l4d2_survivorsetfix_enabled", "1", "Enables Survivor Set Trigger Fix", FCVAR_NOTIFY);
	CreateConVar("sm_l4d2_survivorsetfix_version", PLUGIN_VERSION, "Version of Survivor Set Trigger Fix", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
	AutoExecConfig(true,                "l4d2_trigger_flow_fix");

	GetCvars();
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	HookEntityOutput("filter_activator_model", "OnPass", OnCheckActivatorModel);
	HookEntityOutput("filter_activator_model", "OnFail", OnCheckActivatorModel);
}  

void ConVarChanged_Cvars(ConVar hCvar, const char[] sOldVal, const char[] sNewVal)
{
	GetCvars();
}

void GetCvars()
{
    g_bCvarEnable = g_hCvarEnable.BoolValue;
}

public void OnMapStart()
{
	CreateTimer(1.0, Timer_OnMapStart, _, TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_OnMapStart(Handle timer)
{
    if( L4D_GetPointer(POINTER_MISSIONINFO) != Address_Null )
    {
        g_bMapIsL4D1Set = L4D2_GetSurvivorSetMap() == 1 ? true : false;
    }
    else
    {
        g_bMapIsL4D1Set = true;
    }
    
    return Plugin_Continue;
}

Action OnCheckActivatorModel(const char[] output, int iCaller, int iActivator, float fDelay)
{
	if(g_bCvarEnable)
	{
		if(0 == iActivator || MaxClients < iActivator)
			return Plugin_Continue; //I don't care about non-players
		
		int iTeam = GetClientTeam(iActivator);
		if(iTeam != 2 && iTeam != 4)
			return Plugin_Continue; //I don't care about infected

		int iEnt = EntRefToEntIndex(iCaller);

		char sModelName[PLATFORM_MAX_PATH];
		bool bNegated = GetEntProp(iEnt, Prop_Data, "m_bNegated") == 1 ? true : false;
		GetEntPropString(iEnt, Prop_Data, "m_iFilterModel", sModelName, sizeof(sModelName));

		bool bShouldTriggerSurvivor = false;
		if(StrEqual("OnPass", output))
		{
			//prevent players from activating something exclusive to the holdoout team
			if(iTeam == 2)
			{
				if(StrEqual(sModelName, g_bMapIsL4D1Set ? MODEL_BILL : MODEL_NICK, false) || StrEqual(sModelName, g_bMapIsL4D1Set ? MODEL_LOUIS : MODEL_COACH, false) || StrEqual(sModelName, g_bMapIsL4D1Set ? MODEL_FRANCIS : MODEL_ELLIS, false) || StrEqual(sModelName, g_bMapIsL4D1Set ? MODEL_ZOEY : MODEL_ROCHELLE, false))
					bShouldTriggerSurvivor = true;
			}
			else if(iTeam == 4)
			{
				if(StrEqual(sModelName, !g_bMapIsL4D1Set ? MODEL_BILL : MODEL_NICK, false) || StrEqual(sModelName, !g_bMapIsL4D1Set ? MODEL_LOUIS : MODEL_COACH, false) || StrEqual(sModelName, !g_bMapIsL4D1Set ? MODEL_FRANCIS : MODEL_ELLIS, false) || StrEqual(sModelName, !g_bMapIsL4D1Set ? MODEL_ZOEY : MODEL_ROCHELLE, false))
					bShouldTriggerSurvivor = true;
			}
			
			bShouldTriggerSurvivor = bNegated ? !bShouldTriggerSurvivor : bShouldTriggerSurvivor;

			if(bShouldTriggerSurvivor)
				return Plugin_Continue;
			else
				return Plugin_Handled;
		}
		else if(StrEqual("OnFail", output))
		{
			//check failed
			//check if the player is a survivor or holdout
			//and and make the check pass if applicable
			if(iTeam == 2)
			{
				if(g_bMapIsL4D1Set)
				{
					switch(GetEntProp(iActivator, Prop_Send, "m_survivorCharacter"))
					{
						case L4D1_FRANCIS, L4D1_ELLIS:
						{
							if(StrEqual(sModelName, MODEL_FRANCIS, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D1_LOUIS, L4D1_COACH:
						{
							if(StrEqual(sModelName, MODEL_LOUIS, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D1_ZOEY, L4D1_ROCHELLE:
						{
							if(StrEqual(sModelName, MODEL_ZOEY, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D1_BILL, L4D1_NICK:
						{
							if(StrEqual(sModelName, MODEL_BILL, false))
								bShouldTriggerSurvivor = true;
						}
						default:
						{
							if(StrEqual(sModelName, MODEL_BILL, false))
								bShouldTriggerSurvivor = true;
						}
					}
				}
				else
				{
					switch(GetEntProp(iActivator, Prop_Send, "m_survivorCharacter"))
					{
						case L4D2_FRANCIS, L4D2_COACH:
						{
							if(StrEqual(sModelName, MODEL_COACH, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D2_LOUIS, L4D2_ELLIS:
						{
							if(StrEqual(sModelName, MODEL_ELLIS, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D2_ZOEY, L4D2_ROCHELLE:
						{
							if(StrEqual(sModelName, MODEL_ROCHELLE, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D2_BILL, L4D2_NICK:
						{
							if(StrEqual(sModelName, MODEL_NICK, false))
								bShouldTriggerSurvivor = true;
						}
						default:
						{
							if(StrEqual(sModelName, MODEL_NICK, false))
								bShouldTriggerSurvivor = true;
						}
					}
				}
			}
			else if(iTeam == 4)
			{
				//the same as above, but flipped
				if(g_bMapIsL4D1Set)
				{
					switch(GetEntProp(iActivator, Prop_Send, "m_survivorCharacter"))
					{
						case L4D1_FRANCIS, L4D1_ELLIS:
						{
							if(StrEqual(sModelName, MODEL_ELLIS, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D1_LOUIS, L4D1_COACH:
						{
							if(StrEqual(sModelName, MODEL_COACH, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D1_ZOEY, L4D1_ROCHELLE:
						{
							if(StrEqual(sModelName, MODEL_ROCHELLE, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D1_BILL, L4D1_NICK:
						{
							if(StrEqual(sModelName, MODEL_NICK, false))
								bShouldTriggerSurvivor = true;
						}
						default:
						{
							if(StrEqual(sModelName, MODEL_NICK, false))
								bShouldTriggerSurvivor = true;
						}
					}
				}
				else
				{
					switch(GetEntProp(iActivator, Prop_Send, "m_survivorCharacter"))
					{
						case L4D2_FRANCIS, L4D2_COACH:
						{
							if(StrEqual(sModelName, MODEL_FRANCIS, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D2_LOUIS, L4D2_ELLIS:
						{
							if(StrEqual(sModelName, MODEL_LOUIS, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D2_ZOEY, L4D2_ROCHELLE:
						{
							if(StrEqual(sModelName, MODEL_ZOEY, false))
								bShouldTriggerSurvivor = true;
						}
						case L4D2_BILL, L4D2_NICK:
						{
							if(StrEqual(sModelName, MODEL_BILL, false))
								bShouldTriggerSurvivor = true;
						}
						default:
						{
							if(StrEqual(sModelName, MODEL_BILL, false))
								bShouldTriggerSurvivor = true;
						}
					}
				}
			}

			bShouldTriggerSurvivor = bNegated ? !bShouldTriggerSurvivor : bShouldTriggerSurvivor;

			if(bShouldTriggerSurvivor)
			{
				FireEntityOutput(iCaller, "OnPass", iActivator, fDelay);
				return Plugin_Handled;
			}
			else
				return Plugin_Continue;
		}
		else
			return Plugin_Continue;	
	}
	else
		return Plugin_Continue;
}