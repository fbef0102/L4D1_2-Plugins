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
#if defined  _l4d_heartbeat_included_
 #endinput
#endif
#define _l4d_heartbeat_included_

/**
 * @brief Gets the revive count of a client.
 * @remarks Because this plugin overwrites "m_currentReviveCount" netprop in L4D1, this native allows you to get the actual revive value for clients.
 *
 * @param client			Client index to affect.
 *
 * @return					Number or revives
 */
native int Heartbeat_GetRevives(int client);

/**
 * @brief Sets the revive count on a client.
 * @remarks Because this plugin overwrites "m_currentReviveCount" netprop in L4D1, this native allows you to set the actual revive value for clients.
 *
 * @param client			Client index to affect.
 * @param reviveCount		The Survivors revive count.
 * @param reviveLogic		Triggers the revive logic which determines if someones screen is black and white, if the heartbeat should play etc.
 *							Setting to false would only set their revive count and the Heartbeat settings would not be followed. Should probably always be default: true.
 *
 * @noreturn
 */
native void Heartbeat_SetRevives(int client, int reviveCount, bool reviveLogic = true);

public SharedPlugin __pl_l4d_heartbeat =
{
	name = "l4d_heartbeat",
	file = "l4d_heartbeat.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_heartbeat_SetNTVOptional()
{
	MarkNativeAsOptional("Heartbeat_GetRevives");
	MarkNativeAsOptional("Heartbeat_SetRevives");
}
#endif