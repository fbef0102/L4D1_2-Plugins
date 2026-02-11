/*  
*    Fixes for gamebreaking bugs and stupid gameplay aspects
*    Copyright (C) 2019  LuxLuma		acceliacat@gmail.com
*
*    This program is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <dhooks>

#define PLUGIN_VERSION	"1.1h-2026/2/11"

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion Engine = GetEngineVersion();
	if( Engine != Engine_Left4Dead && Engine != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Plugin only supports Left 4 Dead 1/2.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "[L4D1/2] physics_object_pushfix",
	author = "Lux, Harry",
	description = "Prevents firework crates, gascans, oxygen, propane tanks being pushed when players walk into them",
	version = PLUGIN_VERSION,
	url = "https://github.com/LuxLuma/Left-4-fix"
};

#define GAMEDATA "physics_object_pushfix"

#define PROPMODELS_MAX 4

int g_iPropModelIndex[4];
char g_sPropModels[4][] =
{
	"models/props_equipment/oxygentank01.mdl",
	"models/props_junk/explosive_box001.mdl",
	"models/props_junk/gascan001a.mdl",
	"models/props_junk/propanecanister001a.mdl"
};

#define MAX_EDICTS		2048 //(1 << 11)

bool 
	g_bIsPhysics[MAX_EDICTS+1],
	g_bIsHittable[MAX_EDICTS+1];

public void OnPluginStart()
{
	Handle hGamedata = LoadGameConfigFile(GAMEDATA);
	if(hGamedata == null) 
		SetFailState("Failed to load \"%s.txt\" gamedata.", GAMEDATA);
	
	Handle hDetour = DHookCreateFromConf(hGamedata, "MovePropAway");
	if(!hDetour)
		SetFailState("Failed to find 'MovePropAway' signature");
	
	if(!DHookEnableDetour(hDetour, false, MovePropAwayPre))
		SetFailState("Failed to detour 'MovePropAway'");
	
	delete hDetour;
	delete hGamedata;
	
	CreateConVar("physics_object_pushfix_version", PLUGIN_VERSION, "", FCVAR_NOTIFY|FCVAR_DONTRECORD);
}

public void OnMapStart()
{
	int iModelIndex;
	for(int i = 0; i < PROPMODELS_MAX; i++)
	{
		iModelIndex = PrecacheModel(g_sPropModels[i], true);
		g_iPropModelIndex[i] = (iModelIndex != 0 ? iModelIndex : -1);// failsafe
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (!IsValidEntityIndex(entity))
		return;
	
	g_bIsPhysics[entity] = false;
	g_bIsHittable[entity] = false;
	
	if(classname[0] != 'p')
		return;
	
	if(	strncmp(classname, "prop_physics", 12, false) == 0 // prop_physics, prop_physics_override, prop_physics_multiplayer
		|| strncmp(classname, "physics_prop", 12, false) == 0) // physics_prop
	{
		RequestFrame(OnNextFrame_prop, EntIndexToEntRef(entity));
	}
}

void OnNextFrame_prop(int entityRef)
{
	int entity = EntRefToEntIndex(entityRef);

	if (entity == INVALID_ENT_REFERENCE)
		return;

	int iModelIndex = GetEntProp(entity, Prop_Data, "m_nModelIndex", 2);
	for(int i = 0; i < PROPMODELS_MAX; i++)
	{
		if(iModelIndex == g_iPropModelIndex[i])
		{
			g_bIsPhysics[entity] = true;
			return;
		}
	}
}

MRESReturn MovePropAwayPre(Handle hReturn, Handle hParams)
{
	//param 1 = physics entity
	//param 2 = client

	int iEnt = DHookGetParam(hParams, 1);

	if(iEnt == -1 || iEnt > 2048) return MRES_Ignored;

	if(g_bIsPhysics[iEnt])
	{
		DHookSetReturn(hReturn, false);
		return MRES_Supercede;
	}

	return MRES_Ignored;
}

bool IsValidEntityIndex(int entity)
{
	return (MaxClients+1 <= entity <= GetMaxEntities());
}