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
#if defined  _clear_weapon_drop_included_
 #endinput
#endif
#define _clear_weapon_drop_included_

/**
 * @brief Create Timer to remove weapon on the ground
 * @remarks Timer will be removed if someone already picks up weapon
 * 
 * @param weapon	Weapon index
 * @param time		Time in seconds to remove. -1=Time defined by plugin data
 *
 * @noreturn
 */
native void L4D_RemoveWeaponOnGround(int weapon, float time = -1.0);

public SharedPlugin __pl_clear_weapon_drop =
{
	name = "clear_weapon_drop",
	file = "clear_weapon_drop.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_clear_weapon_drop_SetNTVOptional()
{
	MarkNativeAsOptional("L4D_RemoveWeaponOnGround");
}
#endif