/*
 * ============================================================================
 *
 *  File:			unscramble.inc
 *  Language:       SourcePawn
 *  Description:	l4d_team_unscramble plugin natives & forwards API
 *  Version:        1.0
 *
 *  Copyright (C) 2020 raziEiL [disawar1] <mr.raz4291@gmail.com>
 *  Copyright (C) 2023 HarryPotter
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * ============================================================================
 */

#if defined _l4d_team_unscramble_included
 #endinput
#endif
#define _l4d_team_unscramble_included

/**
 * @brief Called whenever unscramble process is completed.
 *
 * @noreturn
 */
forward void l4d_team_unscramble_End();

/**
 * Force to store players team data.
 *
 * @noreturn
 */
native void l4d_team_unscramble_Keep();

/**
 * Force to start unscramble process (Puts players on the right team).
 * @note To make unscramble process works you need call l4d_team_unscramble_Keep first.
 *
 * @noreturn
 */
native void l4d_team_unscramble_Start();

/**
 * Force to abort unscramble process.
 *
 * @param fireOnUnscrambleEnd    Whether or not l4d_team_unscramble_End forward should be fired.
 *
 * @noreturn
 */
native void l4d_team_unscramble_Abort(bool fireOnUnscrambleEnd = true);

/**
 * Returns whether or not unscramble process is completed.
 *
 * @return			If true then unscramble is completed, false means unscramble is processing and team changes is locked.
 */
native bool l4d_team_unscramble_IsUnscrambled();

public SharedPlugin __pl_l4d_team_unscramble =
{
	name = "l4d_team_unscramble",
	file = "l4d_team_unscramble.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_team_unscramble_SetNTVOptional()
{
	MarkNativeAsOptional("l4d_team_unscramble_Keep");
	MarkNativeAsOptional("l4d_team_unscramble_Start");
	MarkNativeAsOptional("l4d_team_unscramble_Abort");
	MarkNativeAsOptional("l4d_team_unscramble_IsUnscrambled");
}
#endif