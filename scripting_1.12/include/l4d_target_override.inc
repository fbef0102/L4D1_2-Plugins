/*
*	Target Override
*	Copyright (C) 2026 Silvers
*
*	This program is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*
*	This program is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*
*	You should have received a copy of the GNU General Public License
*	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

#if defined _target_override_included
 #endinput
#endif
#define _target_override_included



public SharedPlugin __pl_target_override = 
{
	name = "l4d_target_override",
	file = "l4d_target_override.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_target_override_SetNTVOptional()
{
	MarkNativeAsOptional("L4D_TargetOverride_GetOption");
	MarkNativeAsOptional("L4D_TargetOverride_SetOption");
	MarkNativeAsOptional("L4D_TargetOverride_GetValue");
}
#endif



// The client values used that can be retrieved:
enum VALUE_OPTION_INDEX
{
	VALUE_INDEX_VICTIM		= 0,	// (int)	- The attackers last client being targeted
	VALUE_INDEX_SWITCH		= 1,	// (float)	- The attackers time since target switched (related to "last" option value)
	VALUE_INDEX_ATTACK		= 2,	// (float)	- Time since last damage to a client
	VALUE_INDEX_ATTACKER	= 3,	// (int)	- Last client to damage the attacker
	VALUE_INDEX_ORDER		= 4,	// (int)	- The attackers last targeting "order" used
	VALUE_INDEX_TOTAL		= 5		// (int)	- Total number of SI targeting the client when "targeted" is active
}

// The Special Infected Values used for the natives:
enum TARGET_SI_INDEX
{
	SI_TANK			= 0,	// Tank
	SI_SMOKER		= 1,	// Smoker
	SI_BOOMER		= 2,	// Boomer
	SI_HUNTER		= 3,	// Hunter
	SI_SPITTER		= 4,	// Spitter
	SI_JOCKEY		= 5,	// Jockey
	SI_CHARGER		= 6		// Charger
}

// The option values used for the natives:
enum TARGET_OPTION_INDEX
{
	INDEX_PINNED	= 0,	// (int)	- "pinned"
	INDEX_INCAP		= 1,	// (int)	- "incap"
	INDEX_VOMS		= 2,	// (int)	- "voms"
	INDEX_VOMS2		= 3,	// (int)	- "voms2"
	INDEX_RANGE		= 4,	// (float)	- "range"
	INDEX_DIST		= 5,	// (float)	- "dist"
	INDEX_WAIT		= 6,	// (float)	- "wait"
	INDEX_LAST		= 7,	// (int)	- "last"
	INDEX_TIME		= 8,	// (float)	- "time"
	INDEX_SAFE		= 9,	// (int)	- "safe"
	INDEX_TARGETED	= 10,	// (int)	- "targeted"
	INDEX_RESCUE	= 11,	// (int)	- "rescue"
	INDEX_RESCUEX	= 12,	// (int)	- "rescuex"
	INDEX_BOMBED	= 13	// (int)	- "bombed"
}



/**
* @brief Fires every frame or whenever someone is being targeted.
* @notes The "order" value is not guaranteed to be correct, mostly provided as a reference.
* @notes When using in a plugin you could put the following code in "OnAllPluginsLoaded" to enable the forward:
* FindConVar("l4d_target_override_forward").IntValue = 1;
*
* @param	attacker	client index of the Special Infected attacking
* @param	victim		client index of the Survivor Special Infected victim
* @param	order		The order value that triggered targeting (see the "/data/l4d_target_override.cfg" for details)
*
* @return	Plugin_Continue to continue targeting, Plugin_Changed to modify the victim or Plugin_Handled to use the games default targeting logic
*/
forward Action L4D_OnTargetOverride(int attacker, int &victim, int order);



/**
* @brief Returns the current value for a client
*
* @param	index			The client to retrieve a value from
* @param	option			The VALUE_OPTION_INDEX value index to retrieve
*
* @return	int or float value for the option selected (-1 on incorrect index)
*/
native any L4D_TargetOverride_GetValue(int client, VALUE_OPTION_INDEX option);



/**
* @brief Returns the current option value for the specified Special Infected
*
* @param	index			The TARGET_SI_INDEX index of the Special Infected type to affect (Tank, etc)
* @param	option			The TARGET_OPTION_INDEX option index to affect ("pinned", "targeted", etc)
*
* @return	int or float value for the option selected (-1 on incorrect index)
*/
native any L4D_TargetOverride_GetOption(TARGET_SI_INDEX index, TARGET_OPTION_INDEX option);



/**
* @brief Sets the current option value for the specified Special Infected
*
* @param	index			The TARGET_SI_INDEX index to affect (tank, etc)
* @param	option			The TARGET_OPTION_INDEX option index to affect ("pinned", "targeted", etc)
*
* @noreturn
*/
native void L4D_TargetOverride_SetOption(TARGET_SI_INDEX index, TARGET_OPTION_INDEX option, any value);