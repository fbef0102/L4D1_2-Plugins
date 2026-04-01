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
#if defined  _l4dmultislots_included_
 #endinput
#endif
#define _l4dmultislots_included_

/**
 * Force the client to join survivor team
 * 
 * @note If not any bots, would a create a new one
 * @note If numbers of survivors reached limit, no any new bots would be created
 * @note Unaffected by "no_second_free_spawn" cvar
 * 
 * @param client    Client id to join survivor team
 * 
 * @noreturn     
 */
native void L4DMultiSlots_Join(int client);

/**
 * Returns the total survivors allowed on the server.
 * 
 * @note The value of plugin cvar 'l4d_multislots_min_survivors'
 *
 * @noparam
 * @return          Number
 */
native int L4DMultiSlots_MaxSurvivors();


public SharedPlugin __pl_l4dmultislots =
{
	name = "l4dmultislots",
	file = "l4dmultislots.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4dmultislots_SetNTVOptional()
{
	MarkNativeAsOptional("L4DMultiSlots_Join");
	MarkNativeAsOptional("L4DMultiSlots_MaxSurvivors");
}
#endif