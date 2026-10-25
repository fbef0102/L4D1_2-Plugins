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
#if defined  _l4d_h_csm_included_
 #endinput
#endif
#define _l4d_h_csm_included_

/**
* @brief Called whenever player changed character via csm
*
* @param client		The client index who changed character
* @param m_survivorCharacter The Character index that client changed to
* @param sCharacterName The Character name that client changed to: "bill", "zoey", "louis", "francis", "nick", "rochelle", "coach", "ellis"
*
* @noreturn
*/
forward void CSM_OnClientChangeCharacter(int client, int m_survivorCharacter, const char sCharacterName[64]);

/**
 * Re-attach and re-equip all weapons and items
 *
 * @param client    client index
 * 
* @noreturn
 */
native int CSM_ReWeaponsAndItems(int client);

public SharedPlugin __pl_readyup =
{
	name = "l4d_h_csm",
	file = "l4d_h_csm.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d_h_csm_SetNTVOptional()
{
	MarkNativeAsOptional("CSM_ReWeaponsAndItems");
}
#endif