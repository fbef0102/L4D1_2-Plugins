#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <l4d2_weapons>

#define TEAM_SURVIVOR 2
#define MAX_DIST_SQUARED 48400 /* Normal pill pass range is ~220 units */
#define TRACE_TOLERANCE 30.0

public Plugin myinfo =
{
	name = "Easier Pill Passer",
	author = "CanadaRox & HarryPotter",
	description = "Lets players pass pills and adrenaline with +reload when they are holding one of those items",
	version = "4.0",
	url = "http://github.com/CanadaRox/sourcemod-plugins/"
};

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (buttons & IN_RELOAD && !(buttons & IN_USE) && !IsFakeClient(client))
	{
		char weapon_name[64];
		GetClientWeapon(client, weapon_name, sizeof(weapon_name));
		/* L4D2 specific stuff here */
		int wep = WeaponNameToId(weapon_name);
		if (wep == WEPID_PAIN_PILLS || wep == WEPID_ADRENALINE)
		{
			/* end of L4D2 specific stuff */
			int target = GetClientAimTarget(client);
			if (target != -1 && GetClientTeam(target) == TEAM_SURVIVOR && GetPlayerWeaponSlot(target, 4) == -1 && !IsPlayerIncap(target))
			{
				float clientOrigin[3], targetOrigin[3];
				GetClientAbsOrigin(client, clientOrigin);
				GetClientAbsOrigin(target, targetOrigin);
				if (GetVectorDistance(clientOrigin, targetOrigin, true) < MAX_DIST_SQUARED)
				{
					if (IsVisibleTo(client, target) || IsVisibleTo(client, target, true))
					{
						AcceptEntityInput(GetPlayerWeaponSlot(client, 4), "Kill");
						int ent = CreateEntityByName(WeaponNames[wep]);
						DispatchSpawn(ent);
						EquipPlayerWeapon(target, ent);

						Event hFakeEvent = CreateEvent("weapon_given");
						hFakeEvent.SetInt("userid", GetClientUserId(target));
						hFakeEvent.SetInt("giver", GetClientUserId(client));
						hFakeEvent.SetInt("weapon", view_as<int>(wep));
						hFakeEvent.SetInt("weaponentid", ent);
						FireEvent(hFakeEvent);
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

bool IsPlayerIncap(int client)
{
	return view_as<bool>(GetEntProp(client, Prop_Send, "m_isIncapacitated"));
}

bool IsVisibleTo(int client, int client2, bool ghetto_lagcomp = false) // check an entity for being visible to a client
{
	float vAngles[3], vOrigin[3], vEnt[3], vLookAt[3];
	float vClientVelocity[3], vClient2Velocity[3];

	GetClientEyePosition(client, vOrigin); // get both player and zombie position
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vClientVelocity);

	GetClientAbsOrigin(client2, vEnt);
	GetEntPropVector(client2, Prop_Data, "m_vecAbsVelocity", vClient2Velocity);

	float ping = GetClientAvgLatency(client, NetFlow_Outgoing);
	float lerp = GetEntPropFloat(client, Prop_Data, "m_fLerpTime");
	lerp *= 4;
	/* This number is pretty much pulled out of my ass with a little bit of testing on a local server with NF */
	/* If you have a problem with this number, blame NF!!! */

	if (ghetto_lagcomp)
	{
		vOrigin[0] += vClientVelocity[0] * (ping + lerp) * -1;
		vOrigin[1] += vClientVelocity[1] * (ping + lerp) * -1;
		vOrigin[2] += vClientVelocity[2] * (ping + lerp) * -1;

		vEnt[0] += vClient2Velocity[0] * (ping) * -1;
		vEnt[1] += vClient2Velocity[1] * (ping) * -1;
		vEnt[2] += vClient2Velocity[2] * (ping) * -1;
	}

	MakeVectorFromPoints(vOrigin, vEnt, vLookAt); // compute vector from player to zombie

	GetVectorAngles(vLookAt, vAngles); // get angles from vector for trace

	// execute Trace
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_OPAQUE_AND_NPCS, RayType_Infinite, TraceFilter);

	bool isVisible = false;
	if (TR_DidHit(trace))
	{
		float vStart[3];
		TR_GetEndPosition(vStart, trace); // retrieve our trace endpoint

		if ((GetVectorDistance(vOrigin, vStart, false) + TRACE_TOLERANCE) >= GetVectorDistance(vOrigin, vEnt))
		{
			isVisible = true;
		}
	}
	else
	{
		isVisible = true;
	}
	delete trace;
	return isVisible;
}

bool TraceFilter(int entity, int contentsMask)
{
	if (entity <= MaxClients)
		return false;
	return true;
}