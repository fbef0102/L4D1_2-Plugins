/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2024  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#if defined _mtclone_included
	#endinput
#endif
#define _mtclone_included

#if defined MT_CLONE_COMPILE_METHOD
	#endinput
#endif
#define MT_CLONE_COMPILE_METHOD 0 // 0: packaged, 1: standalone

public SharedPlugin __pl_mtclone =
{
	name = "mt_clone",
#if MT_CLONE_COMPILE_METHOD == 0
	file = "mt_abilities.smx",
#else
	file = "mt_clone.smx",
#endif
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_mtclone_SetNTVOptional()
{
	MarkNativeAsOptional("MT_IsCloneSupported");
	MarkNativeAsOptional("MT_IsTankClone");
}
#endif

/**
 * Returns if the clone can use abilities.
 *
 * @param tank			Client index of the Tank.
 *
 * @return			True if clone can use abilities, false otherwise.
 * @error			Invalid client index.
 **/
native bool MT_IsCloneSupported(int tank);

/**
 * Returns if a Tank is a clone.
 *
 * @param tank			Client index of the Tank.
 *
 * @return			True if the Tank is a clone, false otherwise.
 * @error			Invalid client index.
 **/
native bool MT_IsTankClone(int tank);

/**
 * Returns whether the clone can use abilities.
 *
 * @param tank			Client index of the Tank.
 * @param clone			Checks whether "mt_clone.smx" is installed.
 *
 * @return			True if clone can use abilities, false otherwise.
 * @error			Invalid client index.
 **/
#pragma deprecated Use the MT_IsCloneSupported() native instead.
stock bool MT_CloneAllowed(int tank, bool clone)
{
	return MT_IsCloneSupported(tank) && clone;
}

/**
 * Returns whether the clone can use abilities.
 *
 * @param tank			Client index of the Tank.
 * @param clone			Checks whether "st_clone.smx" is installed.
 *
 * @return			True if clone can use abilities, false otherwise.
 * @error			Invalid client index.
 **/
#pragma deprecated Use the MT_IsCloneSupported() native instead.
stock bool ST_CloneAllowed(int tank, bool clone)
{
	return MT_IsCloneSupported(tank) && clone;
}