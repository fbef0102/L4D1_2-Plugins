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
#if defined  _l4d_start_safe_area_included_
 #endinput
#endif
#define _l4d_start_safe_area_included_

/**
 * @brief Returns true if any survivor has left the custom starting area created by l4d_start_safe_area
 *
 * @return			True if a survivor has left the custom starting area. False otherwise
 */
native int L4DSSArea_HasAnySurvivorLeftCustomSafeArea();

/**
 * @brief Force to remove the custom starting area 
 *
 * @noreturn
 */
native void L4DSSArea_RemoveCustomSafeArea();

/**
 * @brief Called whenever any survivor tries to leave the custom starting area created by l4d_start_safe_area
 *
 * @param client		the survivor that left the custom safe area first
 *
 * @return				Plugin_Handled to block the custom starting area from being removed, Plugin_Continue otherwise
 */
forward Action L4DSSArea_OnFirstSurvivorLeftCustomSafeArea_Pre(int client);

/**
 * @brief Called whenever any survivor tries to leave the custom starting area created by l4d_start_safe_area
 * @remarks This forward will not trigger if the relative pre-hook forward has been blocked with Plugin_Handled
 *
 * @param client		the survivor that left the custom safe area first
 *
 * @noreturn
 */
forward void L4DSSArea_OnFirstSurvivorLeftCustomSafeArea_Post(int client);

/**
 * @brief Called whenever any survivor tries to leave the custom starting area created by l4d_start_safe_area
 * @remarks This forward will ONLY trigger if the relative pre-hook forward has been blocked with Plugin_Handled
 *
 * @param client		the survivor that left the custom safe area first
 *
 * @noreturn
 */
forward void L4DSSArea_OnFirstSurvivorLeftCustomSafeArea_PostHandled(int client);

public SharedPlugin __pl_l4d_start_safe_area =
{
	name = "l4d_start_safe_area",
	file = "l4d_start_safe_area.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_start_safe_area_SetNTVOptional()
{
	MarkNativeAsOptional("L4DSSArea_HasAnySurvivorLeftCustomSafeArea");
	MarkNativeAsOptional("L4DSSArea_RemoveCustomSafeArea");
}
#endif