#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

ConVar ClearTime = null;
ConVar g_hCvarAllow = null;
bool bCvarAllow;
float fClearTime;

public Plugin myinfo = 
{
	name = "[L4D2] Remove Dead Body Entity",
	author = "Harry Potter",
	description = "As the name says, you dumb shit.",
	version = "1.1",
	url = "https://steamcommunity.com/id/TIGER_x_DRAGON/"
}

public void OnPluginStart()
{
	g_hCvarAllow =	CreateConVar("sm_clear_dead_body_allow",	"1", "0=Plugin off, 1=Plugin on.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	ClearTime = CreateConVar("sm_clear_dead_body_time", "100.0", "clear dead body in seconds", FCVAR_NOTIFY, true, 5.0);
	
	GetCvars();

	g_hCvarAllow.AddChangeHook(ConVarChanged_Cvars);
	ClearTime.AddChangeHook(ConVarChanged_Cvars);

	AutoExecConfig(true, "clear_dead_body");
}

public void ConVarChanged_Cvars(Handle convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	fClearTime = ClearTime.FloatValue;
	bCvarAllow = g_hCvarAllow.BoolValue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntityIndex(entity))
		return;

	if(bCvarAllow)
	{
		switch (classname[0])
		{
			case 's':
			{
				if (strcmp(classname , "survivor_death_model") == 0)
				{
					RequestFrame (OnNextFrame, EntIndexToEntRef(entity));
				}
			}
		}
	}
}

public void OnNextFrame(int entityRef)
{
	if(!bCvarAllow) return;

	int entity = EntRefToEntIndex(entityRef);

	if (entity == INVALID_ENT_REFERENCE)
		return;

	//PrintToChatAll("%d Entity dead body , %f", entity,fClearTime);
	CreateTimer(fClearTime,Timer_KickDeadBody, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_KickDeadBody(Handle timer, int ref)
{
	if(bCvarAllow && ref && EntRefToEntIndex(ref) != INVALID_ENT_REFERENCE)
	{
		//PrintToChatAll("%d remove dead body", EntRefToEntIndex(ref));
		AcceptEntityInput(ref, "kill"); //remove dead boddy entity
	}
	return Plugin_Continue;
}


bool IsValidEntityIndex(int entity)
{
    return (MaxClients+1 <= entity <= GetMaxEntities());
}