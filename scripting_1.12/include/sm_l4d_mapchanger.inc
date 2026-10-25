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
#if defined  _sm_l4d_mapchanger_included_
 #endinput
#endif
#define _sm_l4d_mapchanger_included_

/**
 * @brief Called when the plugin has created the timer to change next map
 * 
 * @param mapName			The next mapname code
 * @param delay				Delay time to change next map
 *
 * @noreturn
 */
forward void l4d_mapchanger_OnCreateChangeMapTimer(const char[] mapName, float delay);

public SharedPlugin __pl_sm_l4d_mapchanger =
{
	name = "sm_l4d_mapchanger",
	file = "sm_l4d_mapchanger.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_sm_l4d_mapchanger_SetNTVOptional()
{

}
#endif