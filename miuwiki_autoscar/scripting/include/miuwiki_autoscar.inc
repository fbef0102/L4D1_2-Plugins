/*
	SourcePawn is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	SourceMod is Copyright (C) 2006-2008 AlliedModders LLC.  All rights reserved.
	Pawn and SMALL are Copyright (C) 1997-2008 ITB CompuPhase.
	Source is Copyright (C) Valve Corporation.
	All trademarks are property of their respective owners.

	This program is free software: you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your
	option) any later version.

	This program is distributed in the hope that it will be useful, but
	WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
#if defined  _miuwiki_autoscar_included_
 #endinput
#endif
#define _miuwiki_autoscar_included_


/**
 * @brief Tells if client use 'Full Auto' SCAR rifle
 * @Note Always return false if client is bot or not an alive survivor
 * 
 * @param client    	Client id of the Survivor player
 * @return          	True if client use 'Full Auto' SCAR rifle, false otherwise
 */
native bool miuwiki_IsClientHoldAutoScar(int client);

/**
 * @brief Returns the game time when 'Full Auto' SCAR rifle finished weapon switch delay
 * @remarks Please use miuwiki_IsClientHoldAutoScar to check before using this function
 * @remarks Weapon is switching if return value > GetGameTime()
 * 
 * @param client    	Client id of the Survivor player
 * @return          	The game time based on the game tick.
 */
native float miuwiki_GetAutoScarSwitchTime(int client);

/**
 * @brief Returns the game time when 'Full Auto' SCAR rifle finished weapon reload
 * @remarks Please use miuwiki_IsClientHoldAutoScar to check before using this function
 * @remarks Weapon is reloading if return value > GetGameTime()
 * 
 * @param client    	Client id of the Survivor player
 * @return          	The game time based on the game tick.
 */
native float miuwiki_GetAutoScarReloadTime(int client);

/**
 * @brief Returns the game time when 'Full Auto' SCAR rifle finished weapon primary attack
 * @remarks Please use miuwiki_IsClientHoldAutoScar to check before using this function
 * @remarks Weapon is shooting if return value > GetGameTime()
 * 
 * @param client    	Client id of the Survivor player
 * @return          	The game time based on the game tick.
 */
native float miuwiki_GetAutoPrimaryAttackTime(int client);

/**
 * @brief Returns the game time when 'Full Auto' SCAR rifle finished weapon secondary attack
 * @remarks Please use miuwiki_IsClientHoldAutoScar to check before using this function
 * @remarks Weapon is shoving if return value > GetGameTime()
 * 
 * @param client    	Client id of the Survivor player
 * @return          	The game time based on the game tick.
 */
native float miuwiki_GetAutoSecondaryAttackTime(int client);


public SharedPlugin __pl_miuwiki_autoscar =
{
	name = "miuwiki_autoscar",
	file = "miuwiki_autoscar.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_miuwiki_autoscar_SetNTVOptional()
{
	MarkNativeAsOptional("miuwiki_IsClientHoldAutoScar");
	MarkNativeAsOptional("miuwiki_GetAutoScarSwitchTime");
	MarkNativeAsOptional("miuwiki_GetAutoScarReloadTime");
	MarkNativeAsOptional("miuwiki_GetAutoPrimaryAttackTime");
	MarkNativeAsOptional("miuwiki_GetAutoSecondaryAttackTime");
}
#endif